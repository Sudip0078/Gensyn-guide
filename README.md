# 🚀 RL-Swarm Launcher

A simple **bash script** to install, update, and manage the [Gensyn RL-Swarm](https://github.com/gensyn-ai/rl-swarm) node.  
This script is designed to make setup and management easier with a **colorful menu-driven interface**.  

---

## ✨ Features
- 🎨 **Electric Cyan theme** with a clean TUI (text-based UI)
- 📥 Auto-clones the RL-Swarm repo
- 🔍 Detects `package.json` or `requirements.txt` and installs dependencies
- 📖 Warns if no dependency files are present
- 🔄 Update, reset config, or delete everything easily
- 📝 Logs all actions to `swarm_log.txt`

---

## 🛠️ Requirements
Make sure you have the following installed:
- `bash` (Default in most systems)
- `git`
- `npm` or `pip` (if RL-Swarm uses Node.js or Python)

---

## 🚀 Installation

```bash
# Clone this repo
git clone https://github.com/YOUR-USERNAME/rl-swarm-launcher.git
cd rl-swarm-launcher

# Make the script executable
chmod +x swarm_launcher.sh

# Run it
./swarm_launcher.sh
