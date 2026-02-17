# CPU Microarchitecture Details

**Slice-Based Datapath & Control Design**

This document provides a deeper look into the internal architecture of the AXI-Integrated Lightweight CPU.
It complements the top-level README by describing **how the CPU is built**, rather than why it was built.

The intent of this document is to expose design reasoning, signal flow, and structural trade-offs in a form similar to an internal architecture note.

---

## 1. Design Philosophy

The CPU was designed around the following principles:

* Prefer **explicit control** over hidden behavior
* Keep datapath scaling **structural, not ad-hoc**
* Separate concerns cleanly:

  * control vs datapath
  * computation vs integration
* Optimize for **observability and verification clarity**

As a result, the architecture avoids pipelining and aggressive optimizations in favor of transparency.

---

## 2. Parameterization and Scaling

The CPU datapath width is determined by two parameters:

* `S` – slice width (bits per ALU slice)
* `N_A` – number of ALU slices

Total datapath width = `S × N_A`

This parameterization allows:

* easy scaling from 8-bit to wider datapaths,
* reuse of the same ALU slice logic,
* controlled complexity growth in interconnect logic.

---

## 3. Instruction Format

Each instruction is **9 bits wide** and divided as follows:

```
[8:6]  opcode   – operation selector
[5:4]  rd       – destination register
[3:2]  rs1      – source register 1
[1:0]  rs2      – source register 2
```

This compact format was chosen to:

* simplify decode logic,
* reduce instruction memory complexity,
* keep control FSM manageable.

---

## 4. Register File Architecture

The register file consists of **four general-purpose registers**:

* R0
* R1
* R2
* R3

Characteristics:

* Two read ports
* One write port
* Write-back controlled by FSM

The small register count is intentional and keeps:

* decode logic simple,
* control signals minimal,
* simulation easy to inspect.

---

## 5. Slice-Based ALU Architecture

### 5.1 ALU Slice

Each ALU slice operates on `S` bits and supports:

* addition (with carry-in and carry-out)
* logical shifts (via inter-slice signaling)
* population count (local)
* comparison (local result)

Slices are **stateless combinational blocks**, which simplifies verification and reuse.

---

### 5.2 Input Arranger

The input arranger preprocesses operands before they are distributed to ALU slices.

Responsibilities:

* Split wide operands into slice-sized chunks
* Optionally reverse slice order
* Align operands correctly for slice-based execution

This block is critical for operations such as:

* comparison (MSB-first evaluation)
* shifts and rotates
* multi-slice accumulation

By isolating operand ordering here, ALU slices remain simple and uniform.

---

### 5.3 Slice Interconnect

The slice interconnect coordinates all ALU slices and produces a unified result.

Its responsibilities include:

* Carry propagation across slices during addition
* Shift-bit forwarding between neighboring slices
* Accumulation of partial results for population count
* Early-exit handling for comparison operations
* Concatenation of slice outputs into the final result

This module effectively turns multiple small ALUs into a single logical datapath.

---

## 6. Supported ALU Operations

| Opcode | Operation | Notes                              |
| ------ | --------- | ---------------------------------- |
| `000`  | ADD       | Slice-chained carry                |
| `001`  | SHIFT     | Logical shift via slice forwarding |
| `010`  | POPCOUNT  | Accumulated across slices          |
| `011`  | COMPARE   | Early-exit MSB-first comparison    |

The opcode space is intentionally small to keep control logic compact.

---

## 7. Control FSM

The CPU uses a **multi-cycle finite state machine**.

### FSM States (conceptual)

1. **FETCH**
   Instruction fetched from instruction memory.

2. **DECODE**
   Opcode and register fields decoded.

3. **EXECUTE**
   ALU operation enabled and evaluated.

4. **WRITEBACK**
   Result written to destination register.

5. **PC_UPDATE**
   Program counter incremented.

This structure provides deterministic behavior and simplifies debugging.

---

## 8. Program Counter and Instruction Fetch

The program counter:

* increments sequentially,
* is enabled only by FSM control,
* does not support branching in the current design.

Instruction memory is implemented as a simple ROM for standalone execution and simulation.

---

## 9. Debug and Observability

The CPU exposes several **debug-only outputs**, including:

* program counter value
* ALU result
* comparison flags
* FSM state

These signals are intended for:

* waveform-based debugging,
* educational inspection,
* verification clarity.

They are not meant as production interfaces.

---

## 10. AXI-Lite Integration Model

The AXI-Lite interface provides:

* register-level access
* configuration and observation points
* external control hooks

Important design rule:

> AXI does not directly drive internal CPU registers.

Instead, AXI writes to shadow registers that the CPU reads synchronously.
This avoids multiple-driver conditions and keeps timing predictable.

---

## 11. Known Limitations

This architecture intentionally omits:

* instruction pipelining
* caches or memory hierarchy
* branch prediction
* formal verification
* full AXI protocol support

These omissions are conscious design choices made to preserve clarity.

---

## 12. Future Extensions

Potential extensions include:

* pipelined execution
* branch support
* wider datapath scaling
* assertion-based verification
* replacement of AXI-Lite with higher-throughput interfaces

---

## 13. Summary

This microarchitecture emphasizes **clarity, modularity, and integration awareness** over performance.

The design choices made here reflect a focus on:

* understanding architectural trade-offs,
* writing maintainable RTL,
* and preparing designs for realistic SoC environments.

---

## Why this document matters (meta)

This file demonstrates:

* architectural reasoning
* disciplined documentation
* awareness of real-world CPU design constraints


You are doing this *the right way*.
