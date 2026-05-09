# RISC-V Processor Design

![Language](https://img.shields.io/badge/language-Verilog-blue)
![Architecture](https://img.shields.io/badge/architecture-RISC--V-green)
![Width](https://img.shields.io/badge/width-64--bit-orange)

A 64-bit RISC-V processor implemented in Verilog, covering both sequential and pipelined designs. Supports the full RV64I base integer instruction set including R-type, I-type, S-type, B-type, U-type, and J-type instructions. The pipelined implementation includes a hazard detection unit and forwarding unit for correct execution across data and control hazards.

---

## Implementations

### Sequential
A single-cycle processor where each instruction completes fully before the next begins. Simpler control logic, used as the baseline reference design.

### Pipelined
A 5-stage pipeline (IF → ID → EX → MEM → WB) with:
- **Pipeline registers** — IF/ID, ID/EX, EX/MEM, MEM/WB
- **Hazard Detection Unit** — detects load-use hazards and inserts stalls
- **Forwarding Unit** — resolves data hazards by forwarding results from EX/MEM and MEM/WB stages, minimising stalls

### ALU
Standalone ALU design and testbenches, developed independently before integration into the full processor.

---

## Repository Structure

```
processor-design/
├── pipelined/
│   ├── src/
│   │   ├── processor.v               # Top-level pipelined processor
│   │   ├── IF_ID.v                   # IF/ID pipeline register
│   │   ├── ID_EX.v                   # ID/EX pipeline register
│   │   ├── EX_MEM.v                  # EX/MEM pipeline register
│   │   ├── MEM_WB.v                  # MEM/WB pipeline register
│   │   ├── hazard_detection_unit.v   # Stall insertion for load-use hazards
│   │   ├── forwardingunit.v          # Data forwarding logic
│   │   ├── alu.v                     # ALU
│   │   ├── alu_control.v             # ALU control unit
│   │   ├── cu.v                      # Main control unit
│   │   ├── imm_gen.v                 # Immediate generator
│   │   ├── instruction_mem.v         # Instruction memory
│   │   ├── data_mem.v                # Data memory
│   │   ├── register_file.v           # 32x64 register file
│   │   ├── pc.v                      # Program counter
│   │   ├── add64.v / sub64.v         # Arithmetic units
│   │   ├── and64.v / or64.v          # Logic units
│   │   └── fulladder.v               # Full adder
│   ├── testbench/
│   │   └── pipe_tb.v                 # Pipelined processor testbench
│   ├── docs/
│   │   └── pipe_report.pdf           # Full design report
│   └── instructions.txt              # Test instruction sequences
│
├── sequential/
│   ├── src/
│   │   ├── processor.v               # Top-level sequential processor
│   │   ├── alu.v / alu_control.v     # ALU and control
│   │   ├── cu.v                      # Control unit
│   │   ├── imm_gen.v                 # Immediate generator
│   │   ├── instruction_mem.v         # Instruction memory
│   │   ├── data_mem.v                # Data memory
│   │   ├── register_file.v           # Register file
│   │   ├── pc.v / pc_mux.v           # Program counter and mux
│   │   ├── alu_src_mux.v             # ALU source mux
│   │   ├── mem_to_reg_mux.v          # Memory to register mux
│   │   ├── add64.v / sub64.v         # Arithmetic units
│   │   ├── and64.v / or64.v          # Logic units
│   │   └── fulladder.v               # Full adder
│   ├── testbench/
│   │   ├── seq_tb.v                  # Sequential processor testbench
│   │   └── alu_tb.v                  # ALU testbench
│   ├── docs/
│   │   └── seq_report.pdf            # Full design report
│   ├── assembler.py                  # Python assembler for generating instruction hex
│   └── instructions.txt             # Test instruction sequences
│
└── alu/
    ├── src/                          # Standalone ALU source
    └── testbench/
        ├── alu_tb.v
        └── alu_tb_1.v
```

---

## Pipeline Stages

```
IF          ID          EX          MEM         WB
──────      ──────      ──────      ──────      ──────
Fetch    →  Decode   →  Execute  →  Memory   →  Writeback
Instruction Register    ALU         Load/Store  Register
Memory      Read        Operation   Access      Write
            Immediate
            Generate
```

### Hazard Handling

**Data Hazards — Forwarding**
Results from the EX/MEM and MEM/WB pipeline registers are forwarded directly to the EX stage inputs, eliminating most data hazard stalls without waiting for writeback.

**Load-Use Hazards — Stalling**
When a load instruction is followed immediately by an instruction that uses the loaded value, the hazard detection unit inserts a one-cycle stall (pipeline bubble) to allow the load to complete before the dependent instruction executes.

**Control Hazards**
Branch outcomes are resolved in the EX stage. The pipeline flushes instructions fetched after a taken branch.

---

## Supported Instructions

Full RV64I base integer instruction set:

| Type | Instructions |
|---|---|
| R-type | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| I-type | ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU |
| Load | LB, LH, LW, LD, LBU, LHU, LWU |
| Store | SB, SH, SW, SD |
| Branch | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| Jump | JAL, JALR |
| Upper | LUI, AUIPC |

---

## Simulation

### Prerequisites
- Icarus Verilog (`iverilog`) or any Verilog simulator
- GTKWave for waveform viewing (optional)

### Run Pipelined Testbench
```bash
cd pipelined/testbench
iverilog -o sim pipe_tb.v ../src/*.v
vvp sim
```

### Run Sequential Testbench
```bash
cd sequential/testbench
iverilog -o sim seq_tb.v ../src/*.v
vvp sim
```

### Run ALU Testbench
```bash
cd alu/testbench
iverilog -o sim alu_tb.v
vvp sim
```

### Generate Instructions
The assembler converts RISC-V assembly to hex instruction sequences for loading into instruction memory:
```bash
cd sequential
python3 assembler.py
```

---

## Reports

Detailed design reports for both implementations are available in their respective `docs/` folders:
- `pipelined/docs/pipe_report.pdf`
- `sequential/docs/seq_report.pdf`

---

## Authors

[Monishram Selvaraj](https://github.com/monishram2508) (2024102076)  
IIIT Hyderabad — Department of Electronics and Communication Engineering
