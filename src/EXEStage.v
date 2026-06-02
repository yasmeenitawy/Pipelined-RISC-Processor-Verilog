module EXEStage (
    input wire clk,
    input wire [31:0] Imm,
    input wire [31:0] Bus1, // value from the forwarded mux
    input wire [31:0] Bus2,	// value from the forwarded mux
    input wire ALUSrc2_signal,
	input wire [1:0] ALUOp,
	input wire LDW_SDW_C2,
    output reg [31:0] ALUOut 
); 

	wire signed [31:0] ALUSrc1, ALUSrc2;

    wire [31:0] imm_mux;
	
	assign ALUSrc1 = Bus1 ;
	
	assign imm_mux = (LDW_SDW_C2 == 0) ? Imm :
					 Imm + 1;

    assign ALUSrc2 = (ALUSrc2_signal == 0) ? Bus2 :
					  imm_mux;

    ALU alu (
        .ALUSrc1(ALUSrc1),
        .ALUSrc2(ALUSrc2),
        .ALUOut(ALUOut),
        .ALUOp(ALUOp)
    );	  
	

endmodule