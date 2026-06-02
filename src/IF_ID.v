module IF_ID(
    input wire clk, stall,
    input wire [31:0] PCIn, nextPCIn, IRIn, 
    output reg [31:0] IROut, PCOut, nextPCOut
);

    always @ (posedge clk) begin
        if (!stall) begin
            IROut <= IRIn;
            PCOut <= PCIn;
            nextPCOut <= nextPCIn; 
        end			  
    end  

    initial begin
        IROut      = 32'b0;
        PCOut      = 32'b0;
        nextPCOut  = 32'b0;
    end

endmodule
