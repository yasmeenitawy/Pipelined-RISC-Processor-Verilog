module IDStage(
	input wire clk,
	input wire [12:0] controlsignals,
	input wire [1:0] ForwardA, ForwardB,
	input wire [31:0] instruction, PC, NextPC,
	input wire [3:0] DestinationRegister_WB, //RD4  
	input wire [31:0] ALUOut, MemoryOut, WBData, // this is the forwarded data
	//input wire [31:0] R14bus, R15bus,
	input wire R14WE, RegWr_WB, kill, stall,
		
	output reg [1:0] ALUOp,
	output reg RegWr,MemR, MemW, WB, Destination, Source2, LDW_SDW_Active, LDW_SDW_C2, ALUSrc2, ExOp, J,
	output reg [3:0] Rs1, Rs2, Rd,
	output reg [31:0] Bus1, Bus2, // output from forward mux
	output reg [31:0] imm,
	output reg [1:0] comp_res,
	output reg [31:0] BranchJump_TA, JR_TA,
	output reg [5:0] opcode,
	output reg [31:0] num_lw, num_sw, num_alu, num_control, num_executed_instructions
); 	

	
	wire [31:0] Data1, Data2; // output from reg file 
	wire [31:0] extended_imm ;
	
	wire [3:0] RD_mux_out;
	
	
	reg [31:0] numlw, numsw, numalu, numcontrol, numexc ;
	
	
	initial begin
		numlw = 0; num_lw = 0 ;
		numalu = 0 ; num_sw = 0 ;
		numsw = 0 ;	 num_alu = 0 ;
		numcontrol = 0 ;  num_control = 0 ;	   
		numexc = 0 ; num_executed_instructions = 0;
		
	end
	

	assign ALUOp = controlsignals[12:11] ;
	assign RegWr = controlsignals[10] ;
	assign MemR = controlsignals[9] ;
	assign MemW = controlsignals[8] ;
	assign WB = controlsignals[7] ;
	assign ALUSrc2 = controlsignals[6] ;
	assign Destination = controlsignals[5] ;
	assign Source2 = controlsignals[4] ;
	assign ExOp = controlsignals[3] ; 
	assign LDW_SDW_C2 = controlsignals[2];
	assign LDW_SDW_Active = controlsignals[1];
	assign J = controlsignals[0] ;
	
	assign RD_mux_out = (Destination == 0) ? instruction[25:22] :
						(Destination == 1) ? instruction[25:22] + 1 :
						4'b0;

	assign Rs1 = instruction[21:18];
	
	assign Rs2 = (Source2 == 0) ? instruction[17:14] : 
				 (Source2 == 1) ? RD_mux_out :
				 4'b0;
	
	assign Rd = RD_mux_out;
	
	
	assign opcode = instruction[31:26] ;
	 
	
	reg [31:0] prev_instruction;  
	

	initial begin
	    prev_instruction = 32'b0;
	end		   
	
	always @(posedge clk) begin 
		if (instruction !== 32'bx && instruction != 32'b0) begin

			if(instruction != prev_instruction && stall == 0) begin 
							
			numexc <= numexc + 1 ; num_executed_instructions <= numexc + 1 ; end	
			
			if (instruction == prev_instruction && stall == 0) begin
    			numexc <= numexc + 1;
    			num_executed_instructions <= numexc + 1;
			end

			
			case (opcode) 
				6'b000000: if (stall == 0) begin numalu <= numalu + 1 ; num_alu <= numalu + 1 ; end 
				6'b000001: if (stall == 0) begin numalu <= numalu + 1 ; num_alu <= numalu + 1 ; end
				6'b000010: if (stall == 0) begin numalu <= numalu + 1 ; num_alu <= numalu + 1 ; end 
				6'b000011: if (stall == 0) begin numalu <= numalu + 1 ; num_alu <= numalu + 1 ; end 
				6'b000100: if (stall == 0) begin numalu <= numalu + 1 ; num_alu <= numalu + 1 ; end
				6'b000101: if (stall == 0) begin numalu <= numalu + 1 ; num_alu <= numalu + 1 ; end	
				6'b000110: if (stall == 0) begin numlw <= numlw + 1 ; num_lw <= numlw + 1 ; end
				6'b000111: if (stall == 0) begin numsw <= numsw + 1 ; num_sw <= numsw + 1 ; end
				6'b001000: if (stall == 0) begin numlw <= numlw + 1 ; num_lw <= numlw + 1 ; end
				6'b001001: if (stall == 0) begin numsw <= numsw + 1 ; num_sw <= numsw + 1 ; end
				6'b001010: begin numcontrol <= numcontrol + 1 ; num_control <= numcontrol + 1 ; end
				6'b001011: begin numcontrol <= numcontrol + 1 ; num_control <= numcontrol + 1 ; end
				6'b001100: begin numcontrol <= numcontrol + 1 ; num_control <= numcontrol + 1 ; end
				6'b001101: begin numcontrol <= numcontrol + 1 ; num_control <= numcontrol + 1 ; end
				6'b001110: begin numcontrol <= numcontrol + 1 ; num_control <= numcontrol + 1 ; end
				6'b001111: begin numcontrol <= numcontrol + 1 ; num_control <= numcontrol + 1 ; end
			endcase		
		end		  
		prev_instruction <= instruction;
	end
	
	
	Extender extend(
		.in(instruction[13:0]),
        .ExtOp(ExOp),
        .out(extended_imm)
	);
	

	RegisterFile reg_file(
        .clk(clk),
        .Rs1(Rs1),
        .Rs2(Rs2),
        .Rd(DestinationRegister_WB),
        .RegWr(RegWr_WB), 
        .WBbus(WBData),	
		.R14WE(R14WE),
    	.R14bus(NextPC),
		.R15bus(PC),
        .Bus1(Data1),
        .Bus2(Data2)
    );
	
	assign  BranchJump_TA = extended_imm + PC - 1  ;
	assign  JR_TA = instruction[21:18] ;
    assign  imm = extended_imm;	

	 mux_4 #(.LENGTH(32)) mux_ForwardA (
	    .in1(Data1),
	    .in2(ALUOut),
	    .in3(MemoryOut),
	    .in4(WBData),
	    .sel(ForwardA),
	    .out(Bus1)
	  );
	  
	  mux_4 #(.LENGTH(32)) mux_ForwardB (
	    .in1(Data2),
	    .in2(ALUOut),
	    .in3(MemoryOut),
	    .in4(WBData),
	    .sel(ForwardB),
	    .out(Bus2)
	  );
	  
	   Compare comp (
        .A(Bus1),
        .B(32'b0),
        .comp_res(comp_res)
    ); 
	
endmodule  	
