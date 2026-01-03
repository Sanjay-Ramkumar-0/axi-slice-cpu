# AXI-Slice-CPU

*A Scalable Slice-Based CPU Core with AXI-Lite Interface*

---

## 📌 Overview

This project implements a **custom CPU core** built around a **slice-based ALU architecture**, where the datapath width can be scaled by chaining multiple small ALU slices.
The CPU supports basic arithmetic, logical, shift, comparison, and population-count operations and is controlled using a **multi-cycle FSM**.

The design is written entirely in **Verilog HDL** and includes:

* A standalone CPU execution path (PC + instruction memory)
* A scalable, bit-slice ALU
* A register file
* FSM-based control
* Optional **AXI-Lite interface** for SoC integration

This project focuses on **architecture clarity and modularity**, rather than maximum performance.

---

## 🎯 Design Goals

* Demonstrate **CPU micro-architecture design**
* Show how **bit-slice / scalable ALUs** work
* Separate **datapath and control**
* Integrate a CPU with **AXI-Lite** in a clean way
* Keep the design **platform-agnostic**

---

## 🧠 High-Level Architecture

```
                 +---------------------+
                 |   Instruction       |
                 |     Memory          |
                 +----------+----------+
                            |
                            v
+---------+     +------------+------------+
|  PC     | --> | Instruction Register   |
+---------+     +------------+------------+
                            |
                            v
                 +----------+----------+
                 |   Control FSM        |
                 +----------+----------+
                            |
     +----------------------+----------------------+
     |                                             |
     v                                             v
+------------+                             +----------------+
| Register   |                             | Slice-Based    |
| File       |                             | ALU Core       |
+------------+                             +----------------+
                                                    |
                                                    v
                                            +---------------+
                                            | Result / Flags|
                                            +---------------+
```

---

## 🧩 Key Modules Explained

### 1️⃣ `cpu_core_v2`

Top-level CPU core that connects:

* Program Counter (PC)
* Instruction Memory
* Instruction Register
* Control FSM
* Register File
* Slice-based ALU

This module orchestrates instruction execution.

---

### 2️⃣ Program Counter (`pc.v`)

* Holds the current instruction address
* Increments when enabled by the FSM
* Width is parameterized (`PC_W`)

---

### 3️⃣ Instruction Memory (`instruction_memory.v`)

* Simple ROM
* Stores instructions in binary form
* Used for standalone CPU execution (no AXI needed)

---

### 4️⃣ Instruction Register (`instruction_register.v`)

* Latches the fetched instruction
* Splits instruction into:

  * `opcode`
  * `rd` (destination register)
  * `rs1`, `rs2` (source registers)

---

### 5️⃣ Register File (`reg_file.v`)

* 4 general-purpose registers (R0–R3)
* Two read ports, one write port
* Controlled by FSM (`reg_we`)

---

## 🧠 Slice-Based ALU Architecture (Core Idea)

Instead of a single wide ALU, the datapath is built using **multiple small ALU slices**.

Example:

* Slice width (`S`) = 4 bits
* Number of slices (`N_A`) = 2
* Total datapath width = 8 bits

Each slice:

* Operates on `S` bits
* Communicates with neighboring slices via carry / shift signals

This architecture is inspired by **classic bit-slice processors**.

---

## 🔀 Input Arranger (`input_arranger.v`)

### Why is this needed?

Some operations (like comparison or shifts) require **processing bits in a different order**.

### What it does:

* Reorders input operands **before** they reach the ALU slices
* Supports:

  * Normal order (LSB slice first)
  * Reversed order (MSB slice first)

### Used for:

* Comparison (start checking from MSB)
* Shift and rotate operations
* General slice alignment

> Think of it as a **pre-processing stage** for slice-based execution.

---

## 🔗 Slice Interconnect (`slice_interconnect.v`)

This module **connects all ALU slices together**.

### Responsibilities:

* Carry propagation (for ADD / SUB)
* Shift bit propagation (left/right)
* Popcount accumulation
* Compare early-exit logic
* Concatenation of slice outputs into final result

### Why it is important:

Without this module, each ALU slice would work in isolation.
The slice interconnect **turns multiple small ALUs into one logical wide ALU**.

---

## ⚙️ ALU Operations Supported

| Opcode | Operation | Description                        |
| ------ | --------- | ---------------------------------- |
| `000`  | ADD       | Addition (slice-chained carry)     |
| `001`  | SHIFT     | Logical shift (via slice chaining) |
| `010`  | POPCOUNT  | Count number of 1s                 |
| `011`  | COMPARE   | Less / Equal / Greater             |

> The ALU output width scales automatically with number of slices.

---

## 🧾 Instruction Format

Each instruction is **9 bits wide**:

```
[8:6]  opcode
[5:4]  rd   (destination register)
[3:2]  rs1  (source register 1)
[1:0]  rs2  (source register 2)
```

---

## 🧠 Control FSM (`control_fsm.v`)

The CPU uses a **multi-cycle FSM**, not a single-cycle design.

### FSM States (example):

| State       | Meaning                       |
| ----------- | ----------------------------- |
| `FETCH`     | Fetch instruction from memory |
| `DECODE`    | Decode opcode & registers     |
| `EXECUTE`   | Perform ALU operation         |
| `WRITEBACK` | Write result to register      |
| `NEXT`      | Increment PC                  |

### Why multi-cycle?

* Simpler control
* Clear separation of stages
* Easy to debug and extend

---

## 🔌 AXI-Lite Interface (Optional)

The CPU can be wrapped with an **AXI-Lite slave** to allow:

* Software access to registers
* External control of execution
* Integration into SoC designs

⚠️ AXI does **not directly drive internal CPU registers**.
It writes configuration registers that the CPU reads synchronously.

---

## 🧪 Verification Strategy

* **Unit-level testbenches**

  * `tb_alu_slice.v`
  * `tb_top_simple_cpu.v`
* **Core-level testbench**

  * `tb_cpu_core_v2.v`
* AXI verification is intentionally separated for SoC-level testing

---

## 🛠 Tools Used

* Verilog HDL
* Xilinx Vivado
* XSIM (simulation)

---

## 📌 Project Status

* RTL complete
* Synthesis clean
* Simulation verified at unit and core level
* Implementation requires board-specific constraints

---

## 👤 Author

**Sanjay Ramkumar**
ECE Undergraduate
Interested in CPU architecture, VLSI, and SoC design

---

## 📜 License

MIT License

---

### ⭐ Final Note

This project is intended as an **educational and architectural exploration**, demonstrating how scalable datapaths, FSM-controlled CPUs, and SoC interfaces can be built from scratch.
* Write a **“How to run simulation”** section
* Create a **README-lite** for quick viewers
