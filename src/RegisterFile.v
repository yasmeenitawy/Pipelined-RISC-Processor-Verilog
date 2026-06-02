module RegisterFile(
    input wire clk,
    input wire [3:0] Rs1, Rs2, Rd,
    input wire RegWr,
    input wire [31:0] WBbus,

    input wire R14WE,
    input wire [31:0] R14bus,
    input wire [31:0] R15bus,

    output reg [31:0] Bus1, Bus2
);
    reg [31:0] registers [0:15];

    always @(*) begin
        if (RegWr) begin
            registers[Rd] <= WBbus;
        end
        registers[15] <= R15bus;
		Bus1 = registers[Rs1];
        Bus2 = registers[Rs2];
    end
	always @(posedge clk) begin
	        if (R14WE) begin
            registers[14] <= R14bus;
        end
		end


    initial begin
        registers[0] = 32'h0000;
        registers[1] = 32'h0001;
        registers[2] = 32'h0002;
        registers[3] = 32'h0003;
        registers[4] = 32'h0004;
        registers[5] = 32'h0005;
        registers[6] = 32'h0006;
        registers[7] = 32'h0007;
        registers[8] = 32'h0008;
        registers[9] = 32'h0009;
        registers[10] = 32'h000A;
        registers[11] = 32'h000B;
        registers[12] = 32'h000C;
        registers[13] = 32'h000D;
        registers[14] = 32'h000E;
        registers[15] = 32'h000F;
    end
endmodule
