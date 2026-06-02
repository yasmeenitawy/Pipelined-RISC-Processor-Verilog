module MEM_WB(
	input wire clk,
	input wire [3:0] Rd4In, output reg [3:0] Rd4Out,
	input wire RegWrIn, output reg RegWrOut,
	input wire [31:0] WBDataIn, output reg [31:0] WBDataOut
);


	always @(posedge clk) begin
	
		Rd4Out <= Rd4In;
		RegWrOut <= RegWrIn;
		WBDataOut <= WBDataIn;
	
	end

endmodule