# Pipelined-RISC-Processor-Verilog

A complete hardware design and verification of a five-stage pipelined RISC processor implemented in Verilog HDL for the ENCS4370 Computer Architecture course at Birzeit University.

## Project Overview

This project implements a functional 32-bit pipelined processor featuring a Harvard architecture with separate instruction and data memories. The processor executes a custom instruction set architecture (ISA) with support for arithmetic, logical, memory access, and control flow operations.

### Key Features

- **5-Stage Pipeline**: Instruction Fetch (IF) → Decode (ID) → Execute (EX) → Memory Access (MEM) → Write-Back (WB)
- **32-bit Architecture**: 32-bit word size and instruction size for efficient processing
- **16 General-Purpose Registers**: R0-R15 with R15 as Program Counter and R14 as return address register
- **Harvard Memory Architecture**: Separate instruction and data memories (word-addressable)
- **Hazard Detection & Forwarding**: Data hazard resolution through forwarding logic and pipeline stalls
- **Special Instruction Support**: Multi-cycle operations (LDW, SDW) with pipeline control
- **Branch Prediction**: Branch decision making in decode stage to minimize stalls

## System Architecture

### Processor Specifications

| Specification | Details |
|---|---|
| Instruction Size | 32 bits |
| Word Size | 32 bits |
| General-Purpose Registers | 16 (R0-R15) |
| Program Counter | R15 (hardwired) |
| Return Address Register | R14 (conventional) |
| Memory Type | Harvard Architecture |
| Memory Addressing | Word-addressable |
| Pipeline Stages | 5 stages |

### Instruction Format

```
┌─────────────────────────────────────────────────────────┐
│ Opcode(6) │ Rd(4) │ Rs(4) │ Rt(4) │ Imm(14) │
└─────────────────────────────────────────────────────────┘
   [31:26]   [25:22] [21:18] [17:14]   [13:0]
```

- **Opcode (6 bits)**: Operation code
- **Rd (4 bits)**: Destination register
- **Rs (4 bits)**: First source register
- **Rt (4 bits)**: Second source register
- **Imm (14 bits)**: Immediate value (zero-extended for logical, sign-extended otherwise)

## Supported Instruction Set

### Arithmetic Instructions

| Instruction | Format | Operation | Opcode |
|---|---|---|---|
| ADD | ADD Rd, Rs, Rt | Reg(Rd) = Reg(Rs) + Reg(Rt) | 0x01 |
| SUB | SUB Rd, Rs, Rt | Reg(Rd) = Reg(Rs) - Reg(Rt) | 0x02 |
| CMP | CMP Rd, Rs, Rt | Compare and set flags | 0x03 |

### Logical Instructions

| Instruction | Format | Operation | Opcode |
|---|---|---|---|
| OR | OR Rd, Rs, Rt | Reg(Rd) = Reg(Rs) \| Reg(Rt) | 0x00 |
| ORI | ORI Rd, Rs, Imm | Reg(Rd) = Reg(Rs) \| Imm | 0x04 |

### Immediate Instructions

| Instruction | Format | Operation | Opcode |
|---|---|---|---|
| ADDI | ADDI Rd, Rs, Imm | Reg(Rd) = Reg(Rs) + Imm | 0x05 |

### Memory Instructions

| Instruction | Format | Operation | Opcode |
|---|---|---|---|
| LW | LW Rd, Imm(Rs) | Reg(Rd) = Mem[Reg(Rs) + Imm] | 0x06 |
| SW | SW Rd, Imm(Rs) | Mem[Reg(Rs) + Imm] = Reg(Rd) | 0x07 |
| LDW | LDW Rd, Imm(Rs) | Load double word (2 cycles) | 0x08 |
| SDW | SDW Rd, Imm(Rs) | Store double word (2 cycles) | 0x09 |

### Control Flow Instructions

| Instruction | Format | Operation | Opcode |
|---|---|---|---|
| BZ | BZ Rs, Label | Branch if Zero | 0x0A |
| BGZ | BGZ Rs, Label | Branch if Greater than Zero | 0x0B |
| BLZ | BLZ Rs, Label | Branch if Less than Zero | 0x0C |
| JR | JR Rs | Jump to Register | 0x0D |
| J | J Label | Unconditional Jump | 0x0E |
| CALL | CALL Label | Call Subroutine (R14 = PC) | 0x0F |

## Pipeline Architecture

### Stage 1: Instruction Fetch (IF)
- Retrieves instruction from instruction memory using PC
- Increments PC by 1
- Supports 4-input multiplexer for PC update based on control signals:
  - **PCSrc=0**: PC + 1 (normal flow)
  - **PCSrc=1**: Branch target address
  - **PCSrc=2**: Jump register address
  - **PCSrc=3**: PC (hold for multi-cycle instructions)

### Stage 2: Instruction Decode (ID)
- Decodes opcode and extracts register fields
- Reads source register values from register file
- Performs sign/zero extension of immediate values
- Evaluates branch conditions (move decision to ID stage for faster branches)
- Generates control signals for subsequent stages
- Supports forwarding from later stages

**Key Components:**
- Register File (16×32-bit)
- Control Unit
- Sign Extender
- PC Control Logic
- 4-to-1 Forwarding Multiplexers (ForwardA, ForwardB)
- Branch comparator

### Stage 3: Execution (EX)
- Performs arithmetic and logical operations using ALU
- Supports operand forwarding to handle data dependencies
- ALU operations: ADD, SUB, OR, AND, etc.
- Generates effective address for memory operations
- Detects and signals hazards

**Key Components:**
- Arithmetic Logic Unit (ALU)
- Forwarding & Hazard Detection Unit
- 2-to-1 Multiplexers for ALU operand selection
- Immediate value adjustment for multi-cycle instructions

### Stage 4: Memory Access (MEM)
- Reads from or writes to data memory
- Memory address calculated in previous stage
- Write-back multiplexer selects between memory output and ALU result

**Key Components:**
- Data Memory
- Write-Back Multiplexer
- Address and data buses

### Stage 5: Write-Back (WB)
- Writes computation results back to destination register
- Final stage of instruction execution

**Key Components:**
- Register File write port
- Write-back enable control

### Pipeline Registers

| Register | Function |
|---|---|
| IF/ID | Stores instruction and PC values |
| ID/EX | Stores decoded instruction info and operand values |
| EX/MEM | Stores ALU result and destination register |
| MEM/WB | Stores memory or ALU result and destination register |

## Hazard Detection & Resolution

### Data Hazards
**Supported Hazard Types:**
- Read-After-Write (RAW) hazards
- Write-After-Write (WAW) hazards
- Write-After-Read (WAR) hazards

**Resolution Mechanisms:**
1. **Forwarding**: Pass results directly from later stages to earlier stages
2. **Stalling**: Insert pipeline bubbles (no-op instructions) when forwarding insufficient
3. **Hazard Unit**: Automatically detects conflicts and applies appropriate resolution

### Control Hazards
- **Branch Decision in ID Stage**: Reduces branch penalty from 3 cycles to 1 cycle
- **Pipeline Flushing**: Kills fetched instruction after branch decision
- **Multi-cycle Instruction Handling**: Prevents new instruction fetch during second cycle of LDW/SDW

## Test Cases

### Test Case 1: Arithmetic & Logical Operations

**Objective**: Verify correct execution of ADD, SUB, OR, and CMP instructions

**Test Program**:
```assembly
ADD R1, R2, R3    ; R1 = R2 + R3 = 2 + 3 = 5
SUB R4, R1, R3    ; R4 = R1 - R3 = 5 - 3 = 2
OR  R5, R1, R2    ; R5 = R1 | R2 = 5 | 2 = 7
CMP R6, R1, R2    ; R6 = +1 (5 > 2)
```

**Expected Results**:
- R1 = 0x00000005
- R4 = 0x00000002
- R5 = 0x00000007
- R6 = 0x00000001

**Performance**:
- Total instructions: 4
- Total cycles: 8
- Stall cycles: 0 (no data dependencies)

### Test Case 2: Immediate Instructions

**Objective**: Validate ORI and ADDI operations with sign/zero extension

**Test Program**:
```assembly
ORI  R7, R1, 0x3FFF    ; R7 = R1 | zero-extended(0x3FFF) = 0x003FFF
ADDI R8, R1, 100       ; R8 = R1 + sign-extended(100) = 0x65
```

**Expected Results**:
- R7 = 0x003FFF
- R8 = 0x00000065

**Performance**:
- Total instructions: 2
- Total load instructions: 1
- Total store instructions: 1
- Total stall cycles: 1 (RAW with load)
- Total cycles: 7

## Verification Results

### Simulation Screenshots

The project includes comprehensive waveform captures demonstrating:

1. **Pipeline Stages in Action**: All 5 stages processing instructions simultaneously
2. **Control Signal Generation**: Proper multiplexer selections and enable signals
3. **Register Updates**: Destination registers receiving correct values
4. **Memory Operations**: Load/store transactions with correct addressing
5. **Hazard Handling**: Stalling and forwarding behavior
6. **Branch Execution**: PC updates and pipeline flushing

### Performance Statistics

Example output from test case execution:
```
=== PERFORMANCE STATISTICS ===
Total number of executed instructions: 4
Total number of load instructions: 0
Total number of store instructions: 0
Total number of alu instructions: 4
Total number of control instructions: 0
Total number of stall cycles: 0
Total number of cycles: 8
```

## Design Decisions & Justifications

### 1. Branch Decision in Decode Stage
**Decision**: Evaluate branch conditions in ID stage rather than EX stage
**Justification**: 
- Reduces branch penalty from 3 cycles to 1 cycle
- Branch comparator in ID stage enables early decision
- Improves pipeline efficiency for conditional branches

### 2. Harvard Architecture
**Decision**: Separate instruction and data memories
**Justification**:
- Enables simultaneous instruction fetch and data access
- Reduces memory bandwidth pressure
- Aligns with RISC processor design principles

### 3. 5-Stage Pipeline
**Decision**: Divide processor into IF, ID, EX, MEM, WB stages
**Justification**:
- Balanced workload distribution across stages
- Good performance without excessive complexity
- Typical for RISC processors with 32-bit words
- Manageable hazard detection and forwarding

### 4. Forwarding Multiplexers
**Decision**: 4-to-1 multiplexers for operand forwarding
**Justification**:
- Provides maximum flexibility for data bypass
- Supports forwarding from EX, MEM, and WB stages
- Minimizes unnecessary stalls
- Common in modern pipelined processors

### 5. Multi-Cycle Instruction Support
**Decision**: Handle LDW/SDW with pipeline stalling
**Justification**:
- Maintains pipeline correctness for double-word operations
- Prevents instruction interleaving issues
- Simple implementation with minimal hardware overhead

## Code Organization & Modularity

### Project Structure
```text
Pipelined-RISC-Processor-Verilog/
├── README.md                         
├── ENCS4370_Project2_Specification.pdf
├── Pipelined_Processor_Report.pdf
├── Full_Datapath.pdf
├── src/
│   ├── ALU.v                         # Arithmetic Logic Unit
│   ├── components.v                  # Common components
│   ├── ControlUnit.v                 # Control signal generation
│   ├── DataMemory.v                  # Data memory module
│   ├── DataPath.v                    # Datapath assembly
│   ├── EXE_MEM.v                     # EX/MEM pipeline register
│   ├── EXEStage.v                    # Execution stage
│   ├── ID_EXE.v                      # ID/EX pipeline register
│   ├── IDStage.v                     # Decode stage
│   ├── IF_ID.v                       # IF/ID pipeline register
│   ├── IFStage.v                     # Fetch stage
│   ├── InstructionMemory.v           # Instruction memory module
│   ├── MEM_WB.v                      # MEM/WB pipeline register
│   ├── MEMStage.v                    # Memory stage
│   └── RegisterFile.v                # Register file (16×32-bit)
├── testbench/
│   ├── datapath_tb.v                 
│   └── Clock.v                 
└── simulation/
    ├── datapath_simulation.vcd       # Exported waveform data
    └── waveforms/                    # Execution trace captures for case 1
```
### Naming Conventions

- **Signals**: Lower case with underscores (e.g., `clk`, `rst_n`, `alu_out`)
- **Buses**: Bus name followed by component (e.g., `Bus1`, `Bus2`, `ALUOut`)
- **Control Signals**: Short descriptive names (e.g., `RegWrite`, `MemRead`, `Branch`)
- **Registers**: Stage abbreviation + register type (e.g., `EXE_Rd`, `MEM_DataOut`)

### Documentation Standards

- **File Headers**: Include module purpose, inputs, outputs, and functionality
- **Signal Comments**: Explain non-obvious signals
- **Critical Logic**: Detailed comments for complex arithmetic or state machines
- **State Information**: Clear indication of valid/invalid bits in pipeline registers

## Performance Analysis

### Instruction Throughput

**Best Case** (no hazards):
- One instruction per cycle after pipeline fills (4 cycle startup latency)
- CPI (Cycles Per Instruction) = 1.0 for hazard-free code

**Average Case** (typical data dependencies):
- Forwarding hides most RAW hazards
- Occasional stalls for memory load → immediate use dependencies
- CPI ≈ 1.1-1.2

**Worst Case** (heavy memory usage):
- Every load followed by dependent instruction
- Load latency = 1 cycle (memory operation in EX stage)
- CPI ≈ 1.5+

### Branch Penalty

- **Conditional Branches**: 1 cycle (decision in ID stage)
- **Unconditional Jump**: 1 cycle (early PC update)
- **Return (JR)**: 1 cycle (register value available)
- **Subroutine Call (CALL)**: 1 cycle (PC saved in R14)

## Extensions & Future Work

Possible enhancements to this processor design:

1. **Deeper Pipeline**: 7+ stages for higher clock frequency
2. **Out-of-Order Execution**: Dynamic scheduling for instruction-level parallelism
3. **Branch Prediction**: Hardware prediction for conditional branches
4. **Caching**: Instruction/data caches to reduce memory latency
5. **Multi-Issue**: Multiple instruction fetch and execution per cycle
6. **Floating Point**: FP arithmetic unit for extended ISA
7. **Superscalar**: Multiple execution units with complex hazard handling
8. **Vector Extensions**: SIMD operations for data parallelism


