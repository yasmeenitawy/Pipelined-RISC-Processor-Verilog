module DataMemory (
    input wire clk,
    input wire MemW,
    input wire MemR,
    input wire [31:0] Address,
    input wire [31:0] DataIn,
    output reg [31:0] MemoryOut,
);

  reg [31:0] memory [0:65535]; // 2^16
    
    initial begin	
		memory[0] <= 32'd0;
		memory[1] <= 32'd1;
        memory[2] <= 32'd2;
        memory[3] <= 32'd3; 
		memory[4] <= 32'd4;
		memory[5] <= 32'd5;
		memory[6] <= 32'h0006;
		memory[7] <= 32'd7;	  
		memory[8] <= 32'd8;
		memory[9] <= 32'd9;
		memory[10] <= 32'd10; 
		memory[11] <= 32'd11;
		memory[12] <= 32'd12;
		memory[13] <= 32'd13;
		memory[14] <= 32'd14;	  
		memory[15] <= 32'd15;
		memory[16] <= 32'd16;
		memory[17] <= 32'd17;
		
    end

    always @(posedge clk) begin
	   #1
        if (MemW) begin  
			memory[Address] = DataIn[31:0];
        end
    end	
	
	
	always @(posedge clk) begin
		 #1	
 	 	if (MemR)	
     		begin
            MemoryOut =  memory[Address];
    	end
		
    end		  
	
endmodule	