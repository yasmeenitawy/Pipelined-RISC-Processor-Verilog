module tb_DataPath();	
	
	reg clk; // input
	
	// *************************************** OUTPUTS *************************************************
	
	wire [31:0] instruction_IF, instruction_ID;
	wire [31:0] PC_IF, PC_ID;

	wire [1:0] PCSrc;
	wire [31:0] BranchJump_TA, JR_TA; 
	
	wire [1:0] ALUOp_ID, ALUOp_EXE;
	wire RegWr_ID, RegWr_EXE, RegWr_MEM, RegWr_WB;
	wire MemR_ID, MemR_EXE, MemR_MEM;
	wire MemW_ID, MemW_EXE, MemW_MEM; 
	wire WB_ID, WB_EXE, WB_MEM;
	wire ALUSrc2_signal_ID, ALUSrc2_signal_EXE;
	wire Destination_ID;
	wire Source2_ID;
	wire LDW_SDW_Active_ID, LDW_SDW_C2_ID, LDW_SDW_C2_EXE;	
	wire ExOp_ID;
	wire J_ID;
	
	wire R14WE;
	wire [1:0] ForwardA, ForwardB;	
	wire [31:0] WBData_MEM, WBData_WB, ALUOut_EXE, ALUOut_MEM, MemoryOut; // ALUOut_MEM is the address of the memory
	
	wire [12:0] controlsignals;

	wire [1:0] comp_res;
	wire [3:0] Rs1, Rs2, Rd, Rd2, Rd3, Rd4;
	wire [5:0] opcode;
	wire [31:0] Bus1_ID, Bus1_EXE, Bus2_ID, Bus2_EXE, Bus2_MEM, imm_ID, imm_EXE; // Bus2_MEM is DataIn
	wire kill;
	wire stall;   
	
	wire [31:0] CurrentPC, New_PC_Plus_1_ID;
	
	wire [31:0] num_executed_instructions, num_lw, num_sw, num_alu, num_control, num_cycles, num_stall; 
	
	
	    wire [31:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
    wire [31:0] reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15;
    
    // Assign register values to wires for waveform visibility
    assign reg0 = uut.id_stage.reg_file.registers[0];
    assign reg1 = uut.id_stage.reg_file.registers[1];
    assign reg2 = uut.id_stage.reg_file.registers[2];
    assign reg3 = uut.id_stage.reg_file.registers[3];
    assign reg4 = uut.id_stage.reg_file.registers[4];
    assign reg5 = uut.id_stage.reg_file.registers[5];
    assign reg6 = uut.id_stage.reg_file.registers[6];
    assign reg7 = uut.id_stage.reg_file.registers[7];
    assign reg8 = uut.id_stage.reg_file.registers[8];
    assign reg9 = uut.id_stage.reg_file.registers[9];
    assign reg10 = uut.id_stage.reg_file.registers[10];
    assign reg11 = uut.id_stage.reg_file.registers[11];
    assign reg12 = uut.id_stage.reg_file.registers[12];
    assign reg13 = uut.id_stage.reg_file.registers[13];
    assign reg14 = uut.id_stage.reg_file.registers[14];
    assign reg15 = uut.id_stage.reg_file.registers[15];
    
    // Memory monitoring wires (optional)
    wire [31:0] mem0, mem1, mem2, mem3, mem4, mem5, mem6, mem7, mem8, mem9, mem10, mem11, mem12, mem13, mem14, mem15, mem16;
    assign mem0 = uut.mem_stage.data_memory.memory[0];
    assign mem1 = uut.mem_stage.data_memory.memory[1];
    assign mem2 = uut.mem_stage.data_memory.memory[2];
    assign mem3 = uut.mem_stage.data_memory.memory[3];
    assign mem4 = uut.mem_stage.data_memory.memory[4];
    assign mem5 = uut.mem_stage.data_memory.memory[5];
    assign mem6 = uut.mem_stage.data_memory.memory[6];
    assign mem7 = uut.mem_stage.data_memory.memory[7];
    assign mem8 = uut.mem_stage.data_memory.memory[8];
    assign mem9 = uut.mem_stage.data_memory.memory[9];
	assign mem10 = uut.mem_stage.data_memory.memory[10];
    assign mem11 = uut.mem_stage.data_memory.memory[11];
    assign mem12 = uut.mem_stage.data_memory.memory[12];
    assign mem13 = uut.mem_stage.data_memory.memory[13];
    assign mem14 = uut.mem_stage.data_memory.memory[14];
    assign mem15 = uut.mem_stage.data_memory.memory[15];
    assign mem16 = uut.mem_stage.data_memory.memory[16];
    
	
	
	// instance from the data path module
	DataPath uut(
	.clk(clk), .instruction_IF(instruction_IF), .instruction_ID(instruction_ID), .PC_IF(PC_IF),	 
	.PC_ID(PC_ID), .PCSrc(PCSrc), .BranchJump_TA(BranchJump_TA), .JR_TA(JR_TA),
	.ALUOp_ID(ALUOp_ID), .ALUOp_EXE(ALUOp_EXE), .RegWr_ID(RegWr_ID), .RegWr_EXE(RegWr_EXE), .RegWr_MEM(RegWr_MEM), .RegWr_WB(RegWr_WB),
	.MemR_ID(MemR_ID), .MemR_EXE(MemR_EXE), .MemR_MEM(MemR_MEM), .MemW_ID(MemW_ID), .MemW_EXE(MemW_EXE), .MemW_MEM(MemW_MEM),
	.WB_ID(WB_ID), .WB_EXE(WB_EXE), .WB_MEM(WB_MEM),
	.ALUSrc2_signal_ID(ALUSrc2_signal_ID), .ALUSrc2_signal_EXE(ALUSrc2_signal_EXE),	.Destination_ID(Destination_ID),
	.Source2_ID(Source2_ID), .LDW_SDW_Active_ID(LDW_SDW_Active_ID), .LDW_SDW_C2_ID(LDW_SDW_C2_ID), .LDW_SDW_C2_EXE(LDW_SDW_C2_EXE), .ExOp_ID(ExOp_ID), .J_ID(J_ID), .R14WE(R14WE), .ForwardA(ForwardA),
	.ForwardB(ForwardB), .WBData_MEM(WBData_MEM), .WBData_WB(WBData_WB), .ALUOut_EXE(ALUOut_EXE), .ALUOut_MEM(ALUOut_MEM), .MemoryOut(MemoryOut),
	.controlsignals(controlsignals), .comp_res(comp_res), .Rs1(Rs1), .Rs2(Rs2), .Rd(Rd), .Rd2(Rd2), .Rd3(Rd3), .Rd4(Rd4), .opcode(opcode),
	.CurrentPC(CurrentPC), .New_PC_Plus_1_ID(New_PC_Plus_1_ID), .stall(stall), .kill(kill),
    .Bus1_ID(Bus1_ID), .Bus1_EXE(Bus1_EXE), .Bus2_ID(Bus2_ID), .Bus2_EXE(Bus2_EXE), .Bus2_MEM(Bus2_MEM), .imm_ID(imm_ID), .imm_EXE(imm_EXE),
	.num_executed_instructions(num_executed_instructions), .num_lw(num_lw), .num_sw(num_sw), .num_alu(num_alu), .num_control(num_control), 
    .num_cycles(num_cycles), .num_stall(num_stall)
	);
	
	// generating the clock
	initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
	
	// VCD dump for waveform viewing
	initial begin
        $dumpfile("datapath_simulation.vcd");
        $dumpvars(0, tb_DataPath);
	end		
	

	// results of performance registers
	initial begin
        #500 
		$display("=== PERFORMANCE STATISTICS ===");
		$display("Total number of executed instructions: %0d", num_executed_instructions + 1);
		$display("Total number of load instructions: %0d", num_lw);
		$display("Total number of store instructions: %0d", num_sw);
		$display("Total number of alu instructions: %0d", num_alu);
		$display("Total number of control instructions: %0d", num_control);
		$display("Total number of stall cycles: %0d", num_stall);
		$display("Total number of cycles: %0d", num_cycles);
		$display("===============================");
		$finish;
    end

endmodule
