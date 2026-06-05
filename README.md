# Asynchronous FIFO with Safe Clock Domain Crossing (CDC)

A production-ready Asynchronous FIFO (First-In, First-Out) design implemented in Verilog. This architecture enables reliable data transfer between two completely independent and unsynchronized clock domains (write clock and read clock) without data corruption or loss.

---

## Overview

Asynchronous FIFOs are critical in digital systems where data must safely cross clock domains operating at different frequencies. This design focuses on correctness, robustness, and scalability, making it suitable for real-world RTL and ASIC workflows.

---

## Key Features

* **True Dual-Clock Operation**
  Independent read and write clock domains operating at different frequencies.

* **Robust Clock Domain Crossing (CDC)**
  Uses a 2-stage flip-flop synchronizer to significantly reduce metastability risk.

* **Gray Code Pointer Scheme**
  Ensures only one bit changes per transition, preventing multi-bit sampling errors.

* **Pessimistic Flag Generation**
  Prevents overflow and underflow by safely handling full and empty conditions.

* **Parameterizable Design**
  Easily configurable data width (`DATA_WIDTH`) and depth (`ADDR_WIDTH`).

---

## Architecture

### Block Diagram

```text
                 +-----------------------------------------------------------+
                 |                         FIFO_TOP                          |
                 |                                                           |
  wr_clk --------+----> [ WRITE POINTER ] ------------------------+          |
  wr_en  --------+           | (wptr_gray)                        |          |
  din    --------+--+        v                                    v          |
                 |  |   [cdc_sync: w2r]                     [fifo_mem]       |
                 |  |        | (wptr_gray_sync)                   ^          |
                 |  |        v                                    |          |
  rd_clk --------+--+--------+----> [ READ POINTER ]              |          |
  rd_en  --------+-----------+--+        | (rptr_gray)           |          |
  dout   <-------+-----------+--+--------+                        |          |
                 |              v                                 |          |
                 |       [cdc_sync: r2w]                          |          |
                 |              | (rptr_gray_sync)                |          |
                 |              +---------------------------------+          |
                 +-----------------------------------------------------------+
```

---

## Module Structure

The design is modular and separates functionality cleanly:

* **fifo_top.v**
  Top-level module connecting all sub-blocks.

* **fifo_mem.v**
  Dual-port memory with synchronous write and asynchronous read.

* **write_pointer.v**
  Handles write pointer increment, Gray conversion, and full flag logic.

* **read_pointer.v**
  Handles read pointer increment, Gray conversion, and empty flag logic.

* **cdc_sync.v**
  Two-stage synchronizer for safe clock domain crossing.

* **gray_counter.v**
  Utility logic for binary-to-Gray conversion.

* **fifo_tb.v**
  Testbench for functional verification.

---

## Interface Description

### Top Module: `fifo_top`

| Signal | Direction | Width      | Description                           |
| ------ | --------- | ---------- | ------------------------------------- |
| wr_clk | Input     | 1          | Write clock (higher frequency domain) |
| rd_clk | Input     | 1          | Read clock (lower frequency domain)   |
| rst    | Input     | 1          | Active-high asynchronous reset        |
| wr_en  | Input     | 1          | Write enable (ignored if full)        |
| rd_en  | Input     | 1          | Read enable (ignored if empty)        |
| din    | Input     | DATA_WIDTH | Input data                            |
| dout   | Output    | DATA_WIDTH | Output data                           |
| full   | Output    | 1          | FIFO full flag (write domain)         |
| empty  | Output    | 1          | FIFO empty flag (read domain)         |

---

## Design Details

### 1. Gray Code Conversion

To safely transfer pointers across clock domains, binary values are converted to Gray code:

$$
G = (B >> 1) \oplus B
$$

This ensures only one bit changes at a time, avoiding sampling inconsistencies.

---

### 2. Empty Condition

The FIFO is empty when:

```verilog
assign empty = (rptr_gray == wptr_gray_sync);
```

---

### 3. Full Condition

The FIFO is full when the write pointer wraps around the read pointer:

```verilog
assign full = (wptr_gray == {
    ~rptr_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1],
     rptr_gray_sync[ADDR_WIDTH-2:0]
});
```

---

## Verification

### Simulation Setup

* Write Clock: 100 MHz (10 ns period)
* Read Clock: Asynchronous (~14 ns period)

### Observations

* Data integrity maintained across clock domains
* No overflow or underflow observed
* Stable behavior under asynchronous conditions

### Synchronization Latency

Due to the 2-stage synchronizer:

* Pointer updates take up to 2 clock cycles to propagate
* Empty and full signals are intentionally delayed (pessimistic behavior)

---

## Reset Behavior

* All pointers reset to zero
* FIFO initializes to empty state
* Safe recovery from reset ensured

---

## Running Simulation

### Using Icarus Verilog

```bash
iverilog -o fifo_sim cdc_sync.v fifo_mem.v write_pointer.v read_pointer.v fifo_top.v fifo_tb.v
vvp fifo_sim
```

### Viewing Waveforms

Add the following to your testbench:

```verilog
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, fifo_tb);
end
```

Then run:

```bash
gtkwave waveform.vcd
```

---

## Applications

* Clock domain crossing in SoCs
* High-speed communication interfaces
* Data buffering between subsystems
* ASIC and FPGA designs

---

## Conclusion

This design demonstrates a reliable and industry-standard approach to asynchronous FIFO implementation. It emphasizes safe CDC practices, modular RTL design, and thorough verification, making it suitable for both academic and professional use.

---
