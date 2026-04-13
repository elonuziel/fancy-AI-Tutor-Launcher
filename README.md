# AI Tutor Launcher 🚀

A portable, lightweight Windows batch interface for running local AI models using the `llama.cpp` engine. This launcher is designed for simplicity, allowing users to select models, adjust performance based on hardware, and choose AI personalities. It acts as the bridge between you and a powerful AI engine, running entirely on your computer—no internet required.

## ✨ Features
* **Model Browser:** Automatically detects `.gguf` files and calculates their size in MB.
* **Multi-Engine Support:** Supports multiple `llama.cpp` backends (CPU, Vulkan, CUDA, etc.) for optimized performance.
* **Interface Modes:** Supports both classic Terminal Mode and a beautiful browser-based Web UI.
* **Performance Profiles:** Choose between Low, Medium, and High modes to match your RAM and CPU threads.
* **Personality Presets:** Quickly switch between an Excel/Python Tutor, General Assistant, or Code Expert.

## 🛠️ Folder Structure
Maintain this structure for the launcher to function:
```text
.
├── engine-*/                 # Binary files (e.g., engine-cpu, engine-vulkan, engine-cuda)
├── models/                   # Place your .gguf files here
└── Start_Tutor_Improved.bat  # The main launcher script
```
*Note: You can have multiple engine folders! The launcher will automatically detect any folder that starts with `engine-`.*

## 🚀 The Complete Setup Guide

### 1. Getting the Engine(s) (The "Brain")
The engine is what actually processes your questions. You can download multiple engines that match your hardware:
- **CPU (`engine-cpu`):** Slower but guaranteed to work on any Windows PC natively.
- **Vulkan (`engine-vulkan`):** Very fast, works on almost any dedicated or modern integrated graphics card (AMD, Intel, older NVIDIA).
- **etc (other gpu)**

**Installation:**
1. Go to: https://github.com/ggerganov/llama.cpp/releases
2. Download the `win-XXX-x64` zip file that corresponds to your hardware. 
   - For CPU, look for the basic `win-XXX-x64.zip`.
   - For others, look for the suffix (e.g., `-vulkan`, `-cu1220`, `-hip`, `-sycl`).
3. Create a new folder starting with `engine-` (for example: `engine-cpu`).
4. Extract **all** files from your downloaded zip into that folder. You should see `llama-cli.exe` and/or `llama-server.exe` inside.

### 2. Getting the Models (The "Knowledge")
Models define the AI's memory and intelligence. They end in `.gguf`.
1. Go to: https://huggingface.co/models?search=gguf
2. Download a `.gguf` file and put it in your `models/` folder.

**How to Find Good Models (Future-Proof Guide):**
Since new AI models are released constantly, focus on these metrics rather than specific names when searching HuggingFace for `.gguf` files:
- **Parameter Count (Size):** For standard or older PCs, stick to the **1B to 4B** range (e.g., 1.5B, 3B). They consume minimal RAM and process words much faster on older CPUs. 
- **Quantization (Level):** Look for files ending in **`Q4_K_M`** or **`Q5_K_M`**. These formats provide the ideal balance between low hardware requirements and retaining the AI's intelligence.
- **Type:** Always choose the **"Instruct"** or **"Chat"** version of a model so it knows how to answer questions properly.
- **Vision (Image) Support:** If you want to upload images in the Web UI, you must download a multimodal projector file (ends in `mmproj...gguf`) that matches your main model. Place it in the `models/` folder. Note that Vision uses significant extra RAM and is slow on older hardware.
- **Discovery:** Browse `r/LocalLLaMA` on Reddit or HuggingFace's "Trending" section for the newest breakthroughs. *(For context, historical examples of great lightweight models included Qwen 2.5 1.5B, Llama 3.2 3B, and Phi-3).*

### 3. Launching your AI
1. Double-click `Start_Tutor_Improved.bat`.
2. Select your model from the list.
3. Choose a performance mode:
   - **LOW** (1 Core / 512 tokens): Best if you have 4GB RAM or an older PC.
   - **MEDIUM** (2 Cores / 1024 tokens): Good for most tasks.
   - **HIGH** (4 Cores / 2048 tokens): Fastest processing for complex tasks, uses more RAM.
4. Choose your Interface Mode:
   - **Terminal Mode:** Fast CLI interface. Pick your personality next, and start chatting.
   - **Browser Mode (Web UI):** Opens a complete "ChatGPT-like" display in your web browser. This mode also provides:
     - **Custom Aliases:** Name your AI Tutor directly in the start-up script.
     - **Vision Support:** If you downloaded an `mmproj` file, the script asks to enable it, letting you drag-and-drop images into the chat!
     - **Network Sharing:** Optionally expose the Web UI to your local Wi-Fi, protected by an API Key, so you can chat from your phone.

## ❓ Troubleshooting
- **Error: Could not find any engine files!:** You didn't put the files in a folder starting with `engine-` properly, or didn't extract `llama-cli.exe` / `llama-server.exe`.
- **Error: No .gguf files found:** Download a model and put it in the `models/` folder.
- **AI is too slow:** Try a smaller model (under 3GB) or use "LOW" mode.
