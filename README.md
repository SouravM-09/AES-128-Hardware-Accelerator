# AES-128 Hardware Accelerator 🚀

**Author:** Sourav Mandal  
**Language:** Verilog HDL  
**Platform:** FPGA (Xilinx Vivado)

A high-performance AES-128 hardware accelerator implemented using a fully pipelined architecture with AXI4-Lite integration. The design is optimized for high throughput and deterministic hardware execution.

---

## 📌 Project Overview

This project implements the AES-128 encryption algorithm completely in hardware. The architecture uses a fully unrolled 11-stage synchronous pipeline architecture to maximize throughput while maintaining deterministic timing behavior.

The system integrates:
* An AES encryption core.
* A key expansion unit that generates all required round keys from the input key.
* An AXI4-Lite control interface used to load the encryption key and manage start/stop operations.
* A memory-mapped datapath that receives 32-bit input words.
* A 32-bit to 128-bit assembler for plaintext blocks.

The design successfully demonstrates a high-performance AES-128 hardware accelerator with deterministic behavior, efficient pipelining, and reliable AXI-based integration.

---

## 🔹 Features

* Fully pipelined AES-128 architecture utilizing an 11-stage unrolled pipeline.
* AXI4-Lite control interface for Start/Stop control, key loading, and status tracking.
* Separate 32-bit memory-mapped slave data interface.
* Internal 32-bit to 128-bit data assembly, utilizing four 32-bit words to form one 128-bit AES block.
* Support for safe key updates, requiring the system to be in the idle state to prevent corruption of data already present inside the pipeline.
* Hardware-based combinational key expansion where all required 11 round keys are generated internally without external precomputation.
* Combinational Look-Up Table (LUT) approach for the SubBytes operation, ensuring fast and predictable timing.
* One encrypted block produced per clock cycle after the pipeline is filled.

---

## 🏗️ System Architecture

The complete system consists of several distinct modules designed for compatibility with a 32-bit system interface while maintaining high-performance 128-bit internal processing.

| Module | Function |
|--------|----------|
| **AES_core_pipeline** | Fully pipelined AES core consisting of 11 stages (AddRoundKey + 10 AES rounds). |
| **key_expansion** | Key expansion unit that generates all required round keys from the 128-bit input key. |
| **AES_axi_slave** | AXI4-Lite control interface for managing the 128-bit key (split into registers) and operational states. |
| **AES_wrapper_32bit** | Assembles 32-bit inputs into 128-bit blocks and temporarily buffers output data before serialization. |
| **AES_axi_slave_memory** | AXI memory interface that handles standard 32-bit read/write transactions. |

---

## 🔐 AES Pipeline Architecture

The AES engine is implemented using a fully unrolled 11-stage pipeline. Pipeline registers are inserted between each stage and clocked on the positive edge, ensuring that the critical path is limited to approximately one AES round per stage. This allows the design to achieve higher operating frequencies.

| Stage | Operation |
|------|-----------|
| **Stage 0** | AddRoundKey |
| **Stage 1–9** | SubBytes → ShiftRows → MixColumns → AddRoundKey |
| **Stage 10** | SubBytes → ShiftRows → AddRoundKey |

A parallel valid signal pipeline is maintained to track data validity across all 11 stages, ensuring that output data is correctly aligned with the corresponding input block.

---

## ⚙️ Synthesis Results & Resource Utilization

The fully unrolled pipeline architecture relies entirely on Look-Up Tables (LUTs) and Flip-Flops (FFs) for cryptographic transformations and state registers, consuming zero BRAM resources.

* **Look-Up Tables (LUT):** 9983
* **Flip-Flops (FF):** 3164
* **Block RAM (BRAM):** 0
* **DSP Slices:** 0
* **UltraRAM (URAM):** 0

---

## ⏱️ Timing and Performance Metrics

The AES core processes one 128-bit block per clock cycle after the initial pipeline fill. *Note: At the system interface level, data is transferred using a 32-bit datapath, requiring four clock cycles to assemble one 128-bit block. Therefore, the reported throughput corresponds to the internal AES core capability.*

### Timing Analysis
* **Target Clock Period:** 30.000 ns (33.33 MHz)
* **Minimum Achievable Period:** 28.244 ns
* **Maximum Operating Frequency (Fmax):** 35.41 MHz
* **Worst Negative Slack (WNS):** +1.756 ns
* **Worst Hold Slack (WHS):** +0.081 ns

### Latency & Throughput
* **Cycle Latency:** 11 clock cycles
* **Time Latency (at 33.33 MHz):** 330.00 ns
* **Time Latency (at Fmax 35.41 MHz):** 310.68 ns
* **Throughput (at 33.33 MHz):** 4.27 Gbps
* **Maximum Throughput (at Fmax):** 4.53 Gbps

---

## ⚖️ Tradeoff Analysis

* **Throughput vs Area:** The fully unrolled pipeline enables processing of one block per cycle, resulting in high throughput. However, this significantly increases hardware resource utilization compared to iterative architectures.
* **Latency vs Throughput:** Although throughput is maximized, the pipeline introduces a fixed latency of 11 cycles. This is a tradeoff inherent to deep pipelining.
* **S-Box Implementation:** The LUT-based S-box implementation offers fast and predictable timing, improving maximum frequency, but consumes more LUT resources compared to arithmetic implementations.
* **Interface Design:** The use of AXI4-Lite simplifies integration and control but limits support for high-performance features such as burst transfers and streaming-based backpressure handling.

---

## ✅ Verification

Comprehensive verification was performed using multiple test scenarios. The design was verified using multiple testbenches including:
* Standard AES test vectors
* Multi-block encryption
* Randomized inputs
* Key update scenarios
* AXI protocol and delayed-ready conditions
