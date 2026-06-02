module DataPath(  
	
	input clk,
	
	output reg [31:0] instruction_IF, instruction_ID, // instruction in fetch and decode stages
	output reg [31:0] PC_IF, PC_ID, // pc in fetch and decode stages

	output reg [1:0] PCSrc,
	output reg [31:0] BranchJump_TA, JR_TA,
	
	
	output reg [1:0] ALUOp_ID, ALUOp_EXE,
	output reg RegWr_ID, RegWr_EXE, RegWr_MEM, RegWr_WB,
	output reg MemR_ID, MemR_EXE, MemR_MEM,
	output reg MemW_ID, MemW_EXE, MemW_MEM,
	output reg WB_ID, WB_EXE, WB_MEM,
	output reg ALUSrc2_signal_ID, ALUSrc2_signal_EXE,
	output reg Destination_ID ,
	output reg Source2_ID,
	output reg LDW_SDW_Active_ID, LDW_SDW_C2_ID, LDW_SDW_C2_EXE,
	output reg ExOp_ID ,
	output reg J_ID,
	
	output reg R14WE,
	output reg [1:0] ForwardA, ForwardB,
	output reg [31:0] WBData_MEM, WBData_WB, ALUOut_EXE, ALUOut_MEM, MemoryOut, // ALUOut_MEM is the address of the memory
	
	output reg [12:0] controlsignals ,

	output reg [1:0] comp_res,
	output reg [3:0] Rs1, Rs2, Rd, Rd2, Rd3, Rd4,
	output reg [5:0] opcode,
	output reg [31:0] Bus1_ID, Bus1_EXE, Bus2_ID, Bus2_EXE, Bus2_MEM, imm_ID, imm_EXE, // Bus2_MEM is DataIn
	output reg kill ,
	output reg stall ,   
	
	output reg [31:0] CurrentPC, New_PC_Plus_1_ID ,
	
	output reg [31:0] num_executed_instructions, num_lw, num_sw, num_alu, num_control, num_cycles, num_stall
	
);

	
	assign num_cycles = num_executed_instructions + 1 + num_stall + 4 ;
		
	// Control unit to generate control signals
	MainControlUnit control(
		.opcode(opcode),
		.stall(stall),
		.clk(clk),
		.ControlSignals(controlsignals)
	); 
	
	// PC control unit to choose the next pc 
	PCControlUnit control_pc(
		.opcode(opcode),
		.comp_res(comp_res),
		.J(J_ID),
		.LDW_SDW_Active(LDW_SDW_Active_ID),
		.LDW_SDW_C2(LDW_SDW_C2_ID),
		.Rd(Rd),
		.Kill(kill),
		.PCSrc(PCSrc),
		.R14WE(R14WE)
	); 
	
	// to generate forwad signals and stall 
	ForwordingControlUnit forwardingUnit (
        .RS1(Rs1), 
        .RS2(Rs2), 
        .RD2(Rd2), 
        .RD3(Rd3), 
        .RD4(Rd4),
        .Ex_MemR(MemR_EXE),
        .Ex_RegWr(RegWr_EXE),
        .Mem_RegWr(RegWr_MEM),
        .WB_RegWr(RegWr_WB),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB),
        .stall(stall)
    ); 		 
	
	// Fetch stage
	IFStage stage1(
		.clk(clk), 
		.PCSrc(PCSrc),		   
		.BranchJump_TA(BranchJump_TA),
		.JR_TA(JR_TA), 
		.stall(stall),
		.kill(kill), 
		
		.num_stall(num_stall),
		.CurrentPC(CurrentPC),
		.New_PC(PC_IF),
		.Instruction(instruction_IF)
	);
		
	
	// buffers form IF -> ID
	IF_ID I_D(
		.clk(clk), .stall(stall), 
		.PCIn(PC_IF), .PCOut(PC_ID),
		.nextPCIn(PC_IF+1), .nextPCOut(New_PC_Plus_1_ID),
		.IRIn(instruction_IF), .IROut(instruction_ID)
	);
	
	// Decode Stage
	IDStage id_stage(
		.clk(clk),
		.controlsignals(controlsignals),
	    .ForwardA(ForwardA),
	    .ForwardB(ForwardB),
		.instruction(instruction_ID),
	    .PC(PC_ID),	
		.NextPC(New_PC_Plus_1_ID),
	    .WBData(WBData_WB),
	    .DestinationRegister_WB(Rd4),
	    .ALUOut(ALUOut_EXE),
	    .MemoryOut(WBData_MEM),
	    .R14WE(R14WE),
		.RegWr_WB(RegWr_WB),
		.kill(kill),
		.stall(stall),

		.ALUOp(ALUOp_ID),
	    .RegWr(RegWr_ID),
	    .MemR(MemR_ID),
		.MemW(MemW_ID),
	    .WB(WB_ID),
	    .Destination(Destination_ID),
	    .Source2(Source2_ID),
	    .ALUSrc2(ALUSrc2_signal_ID),
		.ExOp(ExOp_ID),
         .comp_res(comp_res),
	    .J(J_ID),
	    .Rs1(Rs1),
	    .Rs2(Rs2),
	    .Rd(Rd),
	    .Bus1(Bus1_ID),
	    .Bus2(Bus2_ID),
	    .imm(imm_ID),
	    .LDW_SDW_Active(LDW_SDW_Active_ID),
		.LDW_SDW_C2(LDW_SDW_C2_ID),
	    .BranchJump_TA(BranchJump_TA),
	    .JR_TA(JR_TA),
		.opcode(opcode),
		.num_lw(num_lw),
		.num_sw(num_sw),
		.num_alu(num_alu),
		.num_control(num_control),	 
		.num_executed_instructions(num_executed_instructions)
	);
	
	// Buffers from ID -> EXE
	ID_EXE id_exe (
        .clk(clk),
        .Rd2In(Rd), .Rd2Out(Rd2),
        .RegWrIn(RegWr_ID), .RegWrOut(RegWr_EXE),
        .ALUOpIn(ALUOp_ID), .ALUOpOut(ALUOp_EXE),
        .MemRIn(MemR_ID), .MemROut(MemR_EXE),
        .MemWIn(MemW_ID), .MemWOut(MemW_EXE),
        .WBIn(WB_ID), .WBOut(WB_EXE),
        .ALUSrc2_SignalIn(ALUSrc2_signal_ID), .ALUSrc2_SignalOut(ALUSrc2_signal_EXE),
        .ImmIn(imm_ID), .ImmOut(imm_EXE),
        .Bus1In(Bus1_ID), .Bus1Out(Bus1_EXE),
        .Bus2In(Bus2_ID), .Bus2Out(Bus2_EXE),
		.LDW_SDW_C2_in(LDW_SDW_C2_ID), .LDW_SDW_C2_out(LDW_SDW_C2_EXE)
    );
	
	// Execute stage
	EXEStage exe_stage (
        .clk(clk),
        .Imm(imm_EXE),
        .Bus1(Bus1_EXE),
        .Bus2(Bus2_EXE), 
		.LDW_SDW_C2(LDW_SDW_C2_EXE),
        .ALUSrc2_signal(ALUSrc2_signal_EXE),
        .ALUOut(ALUOut_EXE),
		.ALUOp(ALUOp_EXE)
    );
	
	// Buffers from EXE -> MEM
	EXE_MEM exe_mem (
        .clk(clk),
        .Rd3In(Rd2), .Rd3Out(Rd3),
        .RegWrIn(RegWr_EXE), .RegWrOut(RegWr_MEM),
        .MemRIn(MemR_EXE), .MemROut(MemR_MEM),
        .MemWIn(MemW_EXE), .MemWOut(MemW_MEM),
        .WBIn(WB_EXE), .WBOut(WB_MEM),
        .DataInIn(Bus2_EXE), .DataInOut(Bus2_MEM),
        .ALUOutIn(ALUOut_EXE), .ALUOutOut(ALUOut_MEM)
    ); 
	
	// MEM stage
	MEMStage mem_stage (
        .clk(clk),
        .Address(ALUOut_MEM),       
        .DataIn(Bus2_MEM), 
        .MemR(MemR_MEM),   
        .MemW(MemW_MEM),       
        .WB(WB_MEM),              
        .MemoryOut(MemoryOut), 
		
        .WBData(WBData_MEM)         
    );	
	
	// Buffers MEM -> WB
	MEM_WB mem_wb (
        .clk(clk),
        .Rd4In(Rd3), .Rd4Out(Rd4),
        .RegWrIn(RegWr_MEM), .RegWrOut(RegWr_WB),
		
        .WBDataIn(WBData_MEM), .WBDataOut(WBData_WB)
    );	 
	

endmodule 


