# Music Code Decoder

**Music Code Decoder** is a hardware-based signal processing project implemented on a **Digilent Basys 3 FPGA board** using **VHDL**. It decodes **ASCII messages embedded in audio signals** by analyzing waveforms through an **Analog-to-Digital Converter (ADC), a symbol detector, and a UART interface**. This project was developed for **ELEC3342** coursework at **The University of Hong Kong**, enhancing a provided **Vivado template** with custom modules to improve **audio decoding accuracy in noisy environments**.

## 🎵 Project Overview
- **Audio-to-ASCII Decoding**: Extracts ASCII messages (e.g., "ENJOY FLATWHITE!") from music-encoded waveforms.
- **Noise-Resilient Symbol Detection**: Enhances detection reliability by filtering **high-frequency noise**.
- **Hardware Integration**: Interfaces with **ADCS7476 ADC** and **Pmod MIC3** on the **Basys 3 FPGA**.
- **UART Output**: Transmits decoded messages serially for external display or further processing.

---
## 📁 Project Structure
```plaintext
MusicCodeDecoder/
├── src/    # Custom VHDL modules
│   ├── adccntrl.vhd      # ADC driver module (provided, unmodified)
│   ├── clk_div.vhd       # Clock divider generating 96 kHz clock (provided, unmodified)
│   ├── mcdecoder.vhd     # Custom ASCII decoder
│   ├── myuart.vhd        # Custom UART transmitter
│   ├── sim_top.vhd       # Simulation module with noisy ADC input
│   ├── symb_det.vhd      # Enhanced symbol detector
│   ├── sys_top.vhd       # Top-level design (modified for integration)
├── ip/     # Xilinx IP cores (pre-configured)
├── prj/    # Vivado project files
├── rtl/    # RTL design files (VHDL source)
├── tb/     # Testbench files (VHDL & scripts)
│   ├── audio_gen.py      # Generates .wav audio for testing
│   ├── info_wave_gen.py  # Generates input waveforms for simulation
│   ├── sim_top_tb.vhd    # Testbench for noisy signal handling
├── xdc/    # Constraint files for Basys 3 board
└── README.md             # Project documentation
```

---
## 🏗 Implementation Details
### **1️⃣ Symbol Detection & ASCII Decoding**
- Captures audio input via **Pmod MIC3**, processed by **ADCS7476 ADC**.
- Decodes embedded symbols from **waveform zero-crossings and frequency content**.
- Translates detected symbols into **ASCII characters** using `mcdecoder.vhd`.

### **2️⃣ Noise-Resilient Processing**
- Improved `symb_det.vhd` to **filter high-frequency noise** for reliable detection.
- Simulation (`sim_top.vhd`) tests performance under **noisy conditions**.

### **3️⃣ UART Serial Output**
- Uses `myuart.vhd` to transmit decoded ASCII characters **for real-time monitoring**.
- Works with external **serial display or data logging system**.

---
## 🚀 Setup & Usage
### **1️⃣ Clone Repository**
```bash
git clone https://github.com/Ngonidzashe-ux/MusicCodeDecoder.git
cd MusicCodeDecoder
```
### **2️⃣ Open Vivado Project**
```bash
vivado -source prj/music_code_decoder.xpr
```
### **3️⃣ Simulate & Synthesize**
- **Run Simulation**: Test symbol detection in noisy conditions.
- **Synthesize & Implement**: Generate bitstream for Basys 3 FPGA.

### **4️⃣ Hardware Testing**
- Connect **Pmod MIC3** to Basys 3 FPGA.
- Program FPGA & monitor UART output.

---
## 📜 References
- **[Digilent Basys 3](https://digilent.com/reference/_media/basys3:basys3_rm.pdf)**
- **[Digilent PMOD MIC3](https://digilent.com/reference/_media/reference/pmod/pmodmic3/pmodmic3_rm.pdf)**
- **[ADCS7476 Datasheet](https://www.ti.com/lit/ds/symlink/adcs7476.pdf)**

## 📝 License
MIT License — Free to use and modify.

## 👤 About the Author
Developed by **Ngonidzashe Maposa**, a Computer Engineering student at **The University of Hong Kong**. Passionate about **hardware acceleration, signal processing, and FPGA development**.

🔗 **Connect with me:** [LinkedIn](#) | [GitHub](https://github.com/Ngonidzashe-ux)
