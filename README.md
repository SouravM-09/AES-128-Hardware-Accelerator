# AES-128 Hardware Accelerator 🚀

**Author:** Sourav Mandal
**Language:** Verilog HDL
**Platform:** FPGA (Xilinx Vivado)

[cite_start]A high-performance AES-128 hardware accelerator implemented using a fully pipelined architecture with AXI4-Lite integration[cite: 1, 3, 38, 116]. [cite_start]The design is optimized for high throughput and deterministic hardware execution[cite: 3, 116].

---

## 📌 Project Overview

[cite_start]This project implements the AES-128 encryption algorithm completely in hardware[cite: 3, 116]. [cite_start]The architecture uses a fully unrolled 11-stage synchronous pipeline architecture to maximize throughput while maintaining deterministic timing behavior[cite: 3].

The system integrates:
* [cite_start]An AES encryption core[cite: 17].
* [cite_start]A key expansion unit that generates all required round keys from the input key[cite: 40].
* [cite_start]An AXI4-Lite control interface used to load the encryption key and manage start/stop operations[cite: 39].
* [cite_start]A memory-mapped datapath that receives 32-bit input words[cite: 41].
* [cite_start]A 32-bit to 128-bit assembler for plaintext blocks[cite: 41].

[cite_start]The design successfully demonstrates a high-performance AES-128 hardware accelerator with deterministic behavior, efficient pipelining, and reliable AXI-based integration[cite: 116].

---

## 🔹 Features

* [cite_start]Fully pipelined AES-128 architecture utilizing an 11-stage unrolled pipeline[cite: 3, 120].
* [cite_start]AXI4-Lite control interface for Start/Stop control, key loading, and status tracking[cite: 63, 65, 66, 67].
* [cite_start]Separate 32-bit memory-mapped slave data interface[cite: 69, 122].
* [cite_start]Internal 32-bit to 128-bit data assembly, utilizing four 32-bit words to form one 128-bit AES block[cite: 71, 73].
* [cite_start]Support for safe key updates, requiring the system to be in the idle state to prevent corruption of data already present inside the pipeline[cite: 58, 59, 123].
* [cite_start]Hardware-based combinational key expansion where all required 11 round keys are generated internally without external precomputation[cite: 53, 55, 56].
* [cite_start]Combinational Look-Up Table (LUT) approach for the SubBytes operation, ensuring fast and predictable timing[cite: 47, 49].
* [cite_start]One encrypted block produced per clock cycle after the pipeline is filled[cite: 95].

---

## 🏗️ System Architecture

[cite_start]The complete system consists of several distinct modules designed for compatibility with a 32-bit system interface while maintaining high-performance 128-bit internal processing[cite: 45].

| Module | Function |
|--------|----------|
| **AES_core_pipeline** | [cite_start]Fully pipelined AES core consisting of 11 stages (AddRoundKey + 10 AES rounds)[cite: 42]. |
| **key_expansion** | [cite_start]Key expansion unit that generates all required round keys from the 128-bit input key[cite: 40]. |
| **AES_axi_slave** | [cite_start]AXI4-Lite control interface for managing the 128-bit key (split into registers) and operational states[cite: 39, 66]. |
| **AES_wrapper_32bit** | [cite_start]Assembles 32-bit inputs into 128-bit blocks and temporarily buffers output data before serialization[cite: 41, 76]. |
| **AES_axi_slave_memory** | [cite_start]AXI memory interface that handles standard 32-bit read/write transactions[cite: 69]. |

---

## 🔐 AES Pipeline Architecture

[cite_start]The AES engine is implemented using a fully unrolled 11-stage pipeline[cite: 3]. [cite_start]Pipeline registers are inserted between each stage and clocked on the positive edge, ensuring that the critical path is limited to approximately one AES round per stage[cite: 8]. [cite_start]This allows the design to achieve higher operating frequencies[cite: 9].

| Stage | Operation |
|------|-----------|
| **Stage 0** | [cite_start]AddRoundKey [cite: 5] |
| **Stage 1–9** | [cite_start]SubBytes → ShiftRows → MixColumns → AddRoundKey [cite: 6] |
| **Stage 10** | [cite_start]SubBytes → ShiftRows → AddRoundKey [cite: 7] |

[cite_start]A parallel valid signal pipeline is maintained to track data validity across all 11 stages, ensuring that output data is correctly aligned with the corresponding input block[cite: 10].

---

## ⚙️ Synthesis Results & Resource Utilization

[cite_start]The fully unrolled pipeline architecture relies entirely on Look-Up Tables (LUTs) and Flip-Flops (FFs) for cryptographic transformations and state registers, consuming zero BRAM resources[cite: 79].

* [cite_start]**Look-Up Tables (LUT):** 9983 [cite: 80, 85]
* **Flip-Flops (FF):** 3164 [cite: 81, 85]
* [cite_start]**Block RAM (BRAM):** 0 [cite: 82, 85]
* [cite_start]**DSP Slices:** 0 [cite: 83, 85]
* **UltraRAM (URAM):** 0 [cite: 84, 85]

---

## ⏱️ Timing and Performance Metrics

The AES core processes one 128-bit block per clock cycle after the initial pipeline fill[cite: 95]. *Note: At the system interface level, data is transferred using a 32-bit datapath, requiring four clock cycles to assemble one 128-bit block[cite: 96]. [cite_start]Therefore, the reported throughput corresponds to the internal AES core capability[cite: 97].*

### Timing Analysis
* [cite_start]**Target Clock Period:** 30.000 ns (33.33 MHz) [cite: 87, 89]
* **Minimum Achievable Period:** 28.244 ns [cite: 91]
* [cite_start]**Maximum Operating Frequency (Fmax):** 35.41 MHz [cite: 92]
* [cite_start]**Worst Negative Slack (WNS):** +1.756 ns [cite: 89, 93]
* **Worst Hold Slack (WHS):** +0.081 ns [cite: 90, 93]

### Latency & Throughput
* [cite_start]**Cycle Latency:** 11 clock cycles [cite: 99]
* [cite_start]**Time Latency (at 33.33 MHz):** 330.00 ns [cite: 100]
* **Time Latency (at Fmax 35.41 MHz):** 310.68 ns [cite: 101]
* [cite_start]**Throughput (at 33.33 MHz):** 4.27 Gbps [cite: 103]
* [cite_start]**Maximum Throughput (at Fmax):** 4.53 Gbps [cite: 104]

---

## ⚖️ Tradeoff Analysis

* **Throughput vs Area:** The fully unrolled pipeline enables processing of one block per cycle, resulting in high throughput[cite: 107]. However, this significantly increases hardware resource utilization compared to iterative architectures[cite: 107, 108].
* [cite_start]**Latency vs Throughput:** Although throughput is maximized, the pipeline introduces a fixed latency of 11 cycles[cite: 110]. [cite_start]This is a tradeoff inherent to deep pipelining[cite: 111].
* **S-Box Implementation:** The LUT-based S-box implementation offers fast and predictable timing, improving maximum frequency, but consumes more LUT resources compared to arithmetic implementations[cite: 113].
* [cite_start]**Interface Design:** The use of AXI4-Lite simplifies integration and control but limits support for high-performance features such as burst transfers and streaming-based backpressure handling[cite: 115].

---

## ✅ Verification

[cite_start]Comprehensive verification was performed using multiple test scenarios[cite: 124]. The design was verified using multiple testbenches including:
* Standard AES test vectors [cite: 126]
* [cite_start]Multi-block encryption [cite: 127]
* [cite_start]Randomized inputs [cite: 128]
* Key update scenarios [cite: 129]
* [cite_start]AXI protocol and delayed-ready conditions [cite: 130]
