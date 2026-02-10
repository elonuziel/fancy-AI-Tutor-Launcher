# AI Tutor Launcher 🚀

A portable, lightweight Windows batch interface for running local AI models using the `llama-cli.exe` engine. This launcher is designed for simplicity, allowing users to select models, adjust performance based on hardware, and choose AI personalities.

## ✨ Features
* **Model Browser:** Automatically detects `.gguf` files and calculates their size in MB.
* **Performance Profiles:** Choose between Low, Medium, and High modes to match your RAM and CPU threads.
* **Personality Presets:** Quickly switch between an Excel/Python Tutor, General Assistant, or Code Expert.
* **System Checks:** Automatically verifies that engine binaries and the models folder exist.

## 🛠️ Folder Structure
Maintain this structure for the launcher to function:
```text
.
├── engine/                 # Binary files (llama-cli.exe, DLLs)
├── models/                 # Place your .gguf files here
└── Start_Tutor_Improved.bat # The main launcher script
```

## 💻 Performance Modes
| Mode | Threads | Context | Best For |
| :--- | :--- | :--- | :--- |
| **LOW** | 1 Core | 512 tokens | Older PCs / 4GB RAM |
| **MEDIUM** | 2 Cores | 1024 tokens | Standard Q&A |
| **HIGH** | 4 Cores | 2048 tokens | Complex tasks |

## 🤖 Recommended Models (for Slow PCs)
To get the best speed on older hardware, look for small-ish GGUF versions on HuggingFace, like:
1. **Phi-3 Mini (3.8B):** Excellent logic and coding.
2. **Qwen2.5 1.5B:** Extremely fast, very low RAM usage.
3. **Llama-3.2 1B:** Great for basic instructions and chat.

## 🚀 Getting Started
1. Download this repository.
2. Place your `.gguf` model files into the `models/` folder.
3. Run `Start_Tutor_Improved.bat`.
4. Select your model and performance level, then start chatting!
