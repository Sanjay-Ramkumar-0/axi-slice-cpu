# AXI-Integrated Lightweight CPU

**Architecture, Integration, and Verification Exploration**

This project explores a lightweight CPU architecture integrated with an AXI-Lite interface, focusing on **system-level design decisions, modular RTL structure, and verification readiness**, rather than raw performance or feature completeness.

The intent is to study how a simple CPU core interacts with its surrounding system and how architectural choices affect **debuggability, integration complexity, and verification effort**.

---

## Motivation

The primary motivation for this project was to move beyond isolated datapath design and understand how a CPU core behaves as part of a **larger SoC-style environment**.

Instead of optimizing for throughput or instruction richness, this design intentionally prioritizes:

* architectural clarity,
* clean separation of control and datapath,
* explicit visibility into internal state,
* and realistic system integration using a standard bus interface.

This project was built as a **learning and exploration exercise**, aligned with the kind of trade-offs faced in real CPU and SoC design teams.

---

## Architecture Overview

At a high level, the design consists of:

* A **modular CPU core** with clear boundaries between control logic and datapath
* A **multi-cycle FSM-based control unit** for deterministic execution and debuggability
* A **slice-based ALU architecture** enabling scalable datapath width
* An **AXI-Lite slave interface** for register-level system integration
* RTL written with **simulation and observability** as first-class concerns

The architecture intentionally favors **clarity and traceability** over aggressive optimization.

---

## Slice-Based Datapath Design

Rather than implementing a monolithic wide ALU, the datapath is constructed from **multiple small ALU slices** operating in parallel and coordinated through explicit interconnect logic.

This approach makes datapath scaling, signal flow, and control interactions easier to reason about.

### Input Arranger

The input arranger preprocesses operands before they reach the ALU slices.
It handles alignment and ordering so that slice-based execution works correctly for operations such as:

* comparison (MSB-first evaluation),
* shifts and rotates,
* multi-slice accumulation.

This avoids embedding ordering assumptions inside individual ALU slices and keeps the slice logic simple.

### Slice Interconnect

The slice interconnect is responsible for coordinating slice-level execution by managing:

* carry propagation across slices,
* shift bit forwarding between slices,
* accumulation for population count,
* early-exit behavior for compare operations,
* concatenation of slice outputs into a unified result.

Together, the input arranger and slice interconnect allow multiple small ALUs to behave as a single logical datapath.

---

## Control and Instruction Flow

The CPU uses a **multi-cycle finite state machine** to control execution.
This was chosen intentionally to keep control behavior explicit and easy to debug.

A typical instruction progresses through:

1. Instruction fetch
2. Decode
3. Execute
4. Writeback
5. Program counter update

While this limits throughput, it significantly simplifies control logic and verification.

---

## Why AXI-Lite?

AXI-Lite was chosen to enable **realistic system integration** without introducing unnecessary protocol complexity.

* AXI-Lite is commonly used for control and status registers in SoC designs
* It aligns with industry integration practices
* It avoids the complexity of full AXI while still exposing real architectural considerations

The AXI interface does **not directly drive internal CPU registers**.
Instead, it provides configuration and observation points that the CPU core consumes synchronously.

In a production design, this interface would likely be extended, replaced, or complemented depending on bandwidth and latency requirements.

---

## Current Status

### Implemented

* CPU core RTL
* Slice-based ALU and interconnect
* FSM-controlled instruction execution
* AXI-Lite slave interface
* Simulation-ready design with debug visibility

### Not Yet Implemented / Simplified

* Pipelining
* Cache or memory hierarchy
* Formal verification
* Full AXI protocol support
* Performance-oriented optimizations

---

## Verification Approach

Verification is currently **simulation-driven**.

The design includes:

* Unit-level testbenches for ALU slices
* Integration-level testbenches for the CPU core
* Explicit debug outputs to simplify waveform analysis

The RTL was written with future **assertion-based and constrained-random verification** in mind, although these are not yet implemented.

---

## Design Trade-offs & Lessons Learned

Key trade-offs explored in this project include:

* **Simplicity vs performance**
  Multi-cycle execution improves clarity at the cost of throughput.

* **Ease of integration vs flexibility**
  AXI-Lite simplifies control integration but limits bandwidth.

* **Modular RTL vs optimized logic depth**
  Clear module boundaries improve maintainability and verification at the cost of raw efficiency.

This project reinforced how **architectural decisions propagate into verification complexity, debug strategy, and system-level integration effort**.

---

## How to Run

* Tool: Xilinx Vivado (XSIM)
* Add RTL files under *Design Sources*
* Add testbenches under *Simulation Sources*
* Run behavioral simulation for functional verification

No board-specific constraints are required for simulation.

---

## Notes

This project is intentionally **not positioned as a production-grade CPU**.
It is an exploration of **architecture, control, integration, and verification concerns** that arise in real CPU and SoC development environments.

---

### Author

**Sanjay Ramkumar**
Electronics and Communication Engineering
Interest areas: CPU architecture, SoC design, verification, and system integration

