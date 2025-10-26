#!/bin/bash

# Définition des chemins
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_DIR="$SCRIPT_DIR/Citizens2"
REPO_DIR_PATCH="$SCRIPT_DIR/Citizens2-Patchs"
REPO_URL="https://github.com/CitizensDev/Citizens2"
BRANCH_GIT_REPO="master"

API_REPO_DIR="$SCRIPT_DIR/CitizensAPI"
API_REPO_DIR_PATCH="$SCRIPT_DIR/CitizensAPI-Patchs"
API_REPO_URL="https://github.com/Euphillya/CitizensAPI"
BRANCH_GIT_API="master"

PATCHES_DIR="$SCRIPT_DIR/patches/plugins"
API_PATCHES_DIR="$SCRIPT_DIR/patches/api"

# S'assurer que les répertoires des patches existent
mkdir -p "$PATCHES_DIR"
mkdir -p "$API_PATCHES_DIR"

# Fonction pour recloner un dépôt
reclone_repo() {
    local repo_dir=$1
    local repo_patch_dir=$2
    local repo_url=$3

    echo "Suppression du dépôt local $repo_dir..."
    rm -rf "$repo_dir"
    rm -rf "$repo_patch_dir"
    echo "Clonage du dépôt $repo_url..."
    git clone "$repo_url" "$repo_dir"
    echo "Le dépôt $repo_url a été recloné."
    echo "Début de la copie du code de $repo_dir vers $repo_patch_dir"
    cp -r "$repo_dir" "$repo_patch_dir"
    echo "Les patches peuvent être appliqués pour $repo_patch_dir"
}

# Fonction pour créer des patches
create_patches() {
    local repo_patch_dir=$1
    local patches_dir=$2
    local branch_git=$3

    cd "$repo_patch_dir" || exit
    echo "Création des patches pour $repo_patch_dir..."
    git format-patch -o "$patches_dir" origin/$branch_git
    echo "Les patches ont été créés dans $patches_dir"
}

# Fonction pour appliquer des patches
apply_patches() {
    local repo_patch_dir=$1
    local patches_dir=$2

    cd "$repo_patch_dir" || exit
    echo "Application des patches pour $repo_patch_dir..."
    for patch in "$patches_dir"/*.patch; do
        [ -e "$patch" ] || continue
        if git apply --check "$patch" 2>&1; then
            if git apply "$patch" 2>&1; then
                patch_name=$(basename "$patch" .patch)
                patch_description=$(echo "$patch_name" | sed 's/^[0-9]*-//')
                patch_description=$(echo "$patch_description" | sed 's/-/ /g')
                git add .
                git commit -m "$patch_description"
                echo "Patch \"$patch_description\" appliqué à $repo_patch_dir."
            else
                echo "Erreur lors de l'application du patch : $patch"
                git apply --check "$patch" 2>&1
                exit 1
            fi
        else
            echo "Le patch $patch pose problème :"
            git apply --check "$patch" 2>&1
            exit 1
        fi
    done
}


# Fonction pour cloner un dépôt à un commit spécifique
clone_specific_commit() {
    local name=$1
    local url=$2
    local commit=$3
    local dest_dir=$4

    echo "Clonage de $name depuis $url à $commit..."
    rm -rf "$dest_dir"
    git clone "$url" "$dest_dir"
    cd "$dest_dir" || exit
    git checkout "$commit"
    echo "$name cloné à $commit dans $dest_dir"
}

update_submodules_conf() {
    local repo_dir=$1
    local repo_url=$2
    local module_name=$3

    cd "$repo_dir" || exit
    local commit_hash
    commit_hash=$(git rev-parse HEAD)

    # Supprimer ancienne ligne du module (si existante)
    grep -v "^$module_name=" "$SCRIPT_DIR/submodules.conf" 2>/dev/null > "$SCRIPT_DIR/submodules.conf.tmp" || true
    echo "$module_name=$repo_url@$commit_hash" >> "$SCRIPT_DIR/submodules.conf.tmp"
    mv "$SCRIPT_DIR/submodules.conf.tmp" "$SCRIPT_DIR/submodules.conf"
    echo "submodules.conf mis à jour pour $module_name → $commit_hash"
}

# Vérification des arguments pour choisir l'action
case "$1" in
    upstream)
        if [ ! -f "$SCRIPT_DIR/submodules.conf" ]; then
            echo "Fichier submodules.conf introuvable"
            exit 1
        fi

        while IFS= read -r line; do
            name=$(echo "$line" | cut -d'=' -f1)
            url_commit=$(echo "$line" | cut -d'=' -f2)
            url=$(echo "$url_commit" | cut -d'@' -f1)
            commit=$(echo "$url_commit" | cut -d'@' -f2)

            case "$name" in
                Citizens2)
                    dest="$REPO_DIR"
                    patch_dest="$REPO_DIR_PATCH"
                    ;;
                CitizensAPI)
                    dest="$API_REPO_DIR"
                    patch_dest="$API_REPO_DIR_PATCH"
                    ;;
                *)
                    echo "Dépôt inconnu : $name"
                    continue
                    ;;
            esac

            # Clone au commit ciblé
            clone_specific_commit "$name" "$url" "$commit" "$dest"

            # Préparer la copie patchable
            echo "Préparation de la copie patchable : $patch_dest"
            rm -rf "$patch_dest"
            cp -r "$dest" "$patch_dest"
            echo "Copie réalisée : $dest -> $patch_dest"
        done < "$SCRIPT_DIR/submodules.conf"
        ;;

    updateUpstream)
        case "$2" in
            repo)
                echo "Mise à jour du repo PLUGINS :"
                reclone_repo "$REPO_DIR" "$REPO_DIR_PATCH" "$REPO_URL"
                update_submodules_conf "$REPO_DIR" "$REPO_URL" "Citizens2"
                ;;
            api)
                echo "Mise à jour du repo API :"
                reclone_repo "$API_REPO_DIR" "$API_REPO_DIR_PATCH" "$API_REPO_URL"
                update_submodules_conf "$API_REPO_DIR" "$API_REPO_URL" "CitizensAPI"
                ;;
            both|"")
                echo "Mise à jour du repo API :"
                reclone_repo "$API_REPO_DIR" "$API_REPO_DIR_PATCH" "$API_REPO_URL"
                update_submodules_conf "$API_REPO_DIR" "$API_REPO_URL" "CitizensAPI"

                echo "Mise à jour du repo PLUGINS :"
                reclone_repo "$REPO_DIR" "$REPO_DIR_PATCH" "$REPO_URL"
                update_submodules_conf "$REPO_DIR" "$REPO_URL" "Citizens2"
                ;;
            *)
                echo "Option invalide pour updateUpstream. Utilisez : repo, api ou both"
                exit 1
                ;;
        esac
        ;;
    createPatches)
        case "$2" in
            repo)
                echo "Créations des patches PLUGINS :"
                create_patches "$REPO_DIR_PATCH" "$PATCHES_DIR" "$BRANCH_GIT_REPO"
                ;;
            api)
                echo "Créations des patches API :"
                create_patches "$API_REPO_DIR_PATCH" "$API_PATCHES_DIR" "$BRANCH_GIT_API"
                ;;
            both|"")
                echo "Créations des patches API :"
                create_patches "$API_REPO_DIR_PATCH" "$API_PATCHES_DIR" "$BRANCH_GIT_API"
                echo "Créations des patches PLUGINS :"
                create_patches "$REPO_DIR_PATCH" "$PATCHES_DIR" "$BRANCH_GIT_REPO"
                ;;
            *)
                echo "Option invalide pour createPatches. Utilisez : repo, api ou both"
                exit 1
                ;;
        esac
        ;;
    applyPatches)
        case "$2" in
            repo)
                echo "Application des patches PLUGINS :"
                apply_patches "$REPO_DIR_PATCH" "$PATCHES_DIR"
                ;;
            api)
                echo "Application des patches API :"
                apply_patches "$API_REPO_DIR_PATCH" "$API_PATCHES_DIR"
                ;;
            both|"")
                echo "Application des patches API :"
                apply_patches "$API_REPO_DIR_PATCH" "$API_PATCHES_DIR"
                echo "Application des patches PLUGINS :"
                apply_patches "$REPO_DIR_PATCH" "$PATCHES_DIR"
                ;;
            *)
                echo "Option invalide pour applyPatches. Utilisez : repo, api ou both"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Utilisation possible du script:
            $0 updateUpstream [repo|api|both]
                Met à jour le code source des dépôts spécifiés en les supprimant et reclonant (par défaut sur les deux)
            $0 createPatches [repo|api|both]
                Crée les patches pour les dépôts spécifiés (par défaut sur les deux)
            $0 applyPatches [repo|api|both]
                Applique les patches aux dépôts spécifiés (par défaut sur les deux)"
        exit 1
        ;;
esac
