# Asynchronous FIFO with Safe Clock Domain Crossing (CDC)

An optimized, production-ready Asynchronous FIFO (First-In, First-Out) design implemented in Verilog. This architecture manages reliable data transfers between two completely independent, unsynchronized clock domains (**Write Clock** and **Read Clock**) without data corruption or loss.

---

## 📌 Features

* **True Asynchronous Dual-Clock Operation:** Supports independent read and write clock domains operating at different frequencies.
* **Robust CDC Architecture:** Incorporates a 2-stage Flip-Flop (2-FF) synchronizer chain to significantly lower the probability of metastability.
* **Gray-Coded Pointer Scheme:** Pointers are converted to Gray Code before crossing domains, ensuring only a single bit transitions per clock cycle to eliminate multi-bit sampling skew.
* **Pessimistic Flag Generation:** Full and empty indicators are handled defensively to prevent data overwrites (overflow) or invalid reads (underflow).
* **Parameterizable RTL:** Easily scales data width (`DATA_WIDTH`) and address depth (`ADDR_WIDTH`) via top-level parameter configurations.

---

## 🏗️ Architectural Block Diagram

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


---

## 📁 Module Directory Structure

The project RTL is divided modularly into isolated structural and behavioral blocks:

* **`fifo_top.v`**: The top-level structural wrapper that wires up the sub-modules.
* **`fifo_mem.v`**: A dual-port memory block utilizing a write-clock synchronous latch and a continuous asynchronous readout setup.
* **`write_pointer.v`**: Manages the binary write counter, tracking Gray generation, and calculates the pessimistic `wfull` flag.
* **`read_pointer.v`**: Tracks the binary read counter, generates local Gray pointers, and handles the `rempty` flag assertion.
* **`cdc_sync.v`**: A parameterizable 2-stage shift register chain implementing a standard synchronizer structure to safely capture signals across domains.
* **`gray_counter.v`**: Utility code logic mapping standard binary data values straight to single-step Gray format.
* **`fifo_tb.v`**: Comprehensive simulation verification setup generating dual asynchronous clocks (100 MHz write vs custom period read).

---

## 🎛️ Port Descriptions

### `fifo_top` (Top-Level Wrapper)

| Port Name | Direction | Width (Bits) | Description |
| :--- | :---: | :---: | :--- |
| `wr_clk` | Input | 1 | Write Domain Clock (Higher frequency domain) |
| `rd_clk` | Input | 1 | Read Domain Clock (Lower frequency domain) |
| `rst` | Input | 1 | Active-High Asynchronous System Reset |
| `wr_en` | Input | 1 | Write Enable (Ignored if `full` is asserted) |
| `rd_en` | Input | 1 | Read Enable (Ignored if `empty` is asserted) |
| `din` | Input | `DATA_WIDTH` | Data Input Bus to be queued |
| `dout` | Output | `DATA_WIDTH` | Data Output Bus read from memory |
| `full` | Output | 1 | FIFO Full Flag (Synchronized to `wr_clk`) |
| `empty` | Output | 1 | FIFO Empty Flag (Synchronized to `rd_clk`) |

---

## ⚡ Mathematical & Logic Implementations

### 1. Binary-to-Gray Conversion
Multi-bit binary pointers crossing clock boundaries risk severe sampling corruption if bits flip asynchronously. Gray code guarantees only one bit toggles per increment step:

$$G_i = B_i \oplus B_{i+1}$$

In Verilog code, this is optimized as an architectural shortcut expression:
```verilog
assign gray = (bin >> 1) ^ bin;
2. Flag Conditions
Both pointers are extended by an extra bit (ADDR_WIDTH + 1) to clearly distinguish between an empty memory array and a full state condition:

empty Assertion: Occurs when the local read Gray pointer matches the synchronized write Gray pointer exactly:

Verilog
assign empty = (rptr_gray == wptr_gray_sync);
full Assertion: Occurs when the write pointer loops past the read pointer. In Gray space, this corresponds to the two most significant bits being inverted, while the lower bits match perfectly:

Verilog
assign full = (wptr_gray == {~rptr_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1], rptr_gray_sync[ADDR_WIDTH-2:0]});
📈 Verification & Behavioral Waveform Analysis
Simulation testing run via a dedicated testbench setup confirms highly reliable operation under heavily mismatched performance constraints:

1. Clock Domain Disparity
Write Clock (wr_clk): Programmed at 100 MHz (10 ns cycle).

Read Clock (rd_clk): Driven asynchronously on a ~142.8 MHz (14 ns cycle).

Data cleanly transfers from a fast domain down to a slower consuming node without a single bit dropping.

2. Synchronization Penalty (Latency)
Due to the defensive 2-stage Flip-Flop structure utilized inside cdc_sync, pointer updates take up to 2 target clock cycles to manifest across boundaries.

Pessimistic Empty Fall: When a burst write sequence triggers on an empty FIFO, the empty line doesn't instantly de-assert. It drops exactly after a 2-cycle stabilization latency penalty on rd_clk, preventing invalid state assessment.

3. Reset Execution
The system maps safely back to an initialization state upon declaring a high reset (rst) toggle. All active memory indexes point safely to base 0 coordinates, while empty cleanly returns to 1.

🛠️ Simulating the Design
To run using common EDA suites such as AMD Vivado, Siemens QuestaSim, or Icarus Verilog:

Compiling via Icarus Verilog:
Bash
# Compile all source blocks and the testbench wrapper
iverilog -o fifo_sim cdc_sync.v fifo_mem.v write_pointer.v read_pointer.v fifo_top.v fifo_tb.v

# Execute the simulation file
vvp fifo_sim
Viewing Waveform Traces:
Add standard dump options inside fifo_tb.v to inspect output configurations using GTKWave or integrated waveform viewers:

Verilog
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, fifo_tb);
end
Bash
gtkwave waveform.vcd
