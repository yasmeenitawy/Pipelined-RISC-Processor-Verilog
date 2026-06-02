module ID_EXE(	
	input wire clk,
	input wire [3:0] Rd2In, output reg [3:0] Rd2Out, 
	input wire  RegWrIn, output reg RegWrOut,
	input wire [1:0] ALUOpIn, output reg [1:0] ALUOpOut,
	input wire MemRIn, output reg MemROut,
	input wire MemWIn, output reg MemWOut,
	input wire WBIn, output reg WBOut,
	input wire ALUSrc2_SignalIn, output reg ALUSrc2_SignalOut,
	input wire [31:0] ImmIn, output reg [31:0] ImmOut,  
	input wire [31:0] Bus1In, output reg [31:0] Bus1Out,
	input wire [31:0] Bus2In, output reg [31:0] Bus2Out,
	input wire LDW_SDW_C2_in, output reg LDW_SDW_C2_out
);		 

	always @ (posedge clk) begin
	
		Rd2Out <= Rd2In;
		RegWrOut <= RegWrIn;
		ALUOpOut <= ALUOpIn;
		MemROut <= MemRIn;
		MemWOut <= MemWIn;
		WBOut <= WBIn;
		ALUSrc2_SignalOut <= ALUSrc2_SignalIn;
		ImmOut <= ImmIn;
		Bus1Out <= Bus1In;
		Bus2Out <= Bus2In;
		LDW_SDW_C2_out <= LDW_SDW_C2_in;
	  
	end 


endmodule