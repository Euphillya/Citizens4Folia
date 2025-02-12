# Citizens-Folia

This repository is a fork of [CitizensAPI](https://github.com/CitizensDev/CitizensAPI) and [Citizens](https://github.com/CitizensDev/Citizens2), specifically modified to be compatible with Folia. The modifications are managed using patch files to facilitate application and updates.

## 📌 Prerequisites

Before starting, make sure you have the following tools installed:

- **Git**
- **Bash** (if you are on Windows, use Git Bash or WSL)
- **Java Development Kit 21 (JDK 21)** to compile the plugins

## 📥 Download

You can download the compiled versions here: [GitHub Actions](https://github.com/Euphillya/Citizens-Folia/actions)

## 📦 Installation

### 🔹 Cloning the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/Euphillya/Citizens-Folia.git
cd Citizens-Folia
```

### 🔹 Using the Management Script

A Bash script is provided to handle recloning, creating, and applying patches.

#### Update the Repositories

To update the source code by deleting and recloning the CitizensAPI and Citizens repositories:

```bash
./script.sh updateUpstream
```

Available options:
```bash
./script.sh updateUpstream repo  # Update only Citizens
./script.sh updateUpstream api   # Update only CitizensAPI
./script.sh updateUpstream both  # Update both (default)
```

#### Create Patches

To generate patches from changes made in the `Citizens-Patchs` directory:

```bash
./script.sh createPatches
```

Available options:
```bash
./script.sh createPatches repo  # Create patches only for Citizens
./script.sh createPatches api   # Create patches only for CitizensAPI
./script.sh createPatches both  # Create patches for both (default)
```

Patches will be saved in `patches/plugins` and `patches/api`.

#### Apply Patches

To apply existing patches:

```bash
./script.sh applyPatches
```

Available options:
```bash
./script.sh applyPatches repo  # Apply patches only for Citizens
./script.sh applyPatches api   # Apply patches only for CitizensAPI
./script.sh applyPatches both  # Apply patches for both (default)
```

If a patch causes an issue, the script will display the patch name and the exact error.

## 📂 Repository Structure

- `Citizens/` - Contains the cloned source code from the Citizens repository.
- `Citizens-Patchs/` - Working directory where modifications are made and patches are applied.
- `CitizensAPI/` - Contains the cloned source code from the CitizensAPI repository.
- `CitizensAPI-Patchs/` - Working directory where modifications are made and patches are applied for the API.
- `patches/plugins/` - Contains the patch files for Citizens.
- `patches/api/` - Contains the patch files for CitizensAPI.

## 🛠 Contributing

Want to contribute? Follow these steps:

1. **Fork** this repository.
2. Create a new branch:  
   ```bash
   git checkout -b my-feature
   ```
3. Make your modifications in `Citizens-Patchs` or `CitizensAPI-Patchs`.
4. Create patches using:
   ```bash
   ./script.sh createPatches
   ```
5. Commit and push your patches:
   ```bash
   git add patches/
   git commit -m "Added new modifications"
   git push origin my-feature
   ```
6. Create a **Pull Request** on this repository.

## ❓ Need Help?

Join my **Discord** server to ask questions or report issues:  
[![Discord](https://img.shields.io/discord/123456789012345678?color=7289DA&label=Join&logo=discord&logoColor=white)](https://discord.gg/uUJQEB7XNN)

## 📜 License

This project is licensed under **OSL 3.0**, in accordance with the CitizensAPI and Citizens projects. More details can be found in the [LICENSE](LICENSE) file.
