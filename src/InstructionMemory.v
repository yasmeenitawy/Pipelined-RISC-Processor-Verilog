module InstructionMemory(
    input wire clk,
    input wire stall,
    input wire [31:0] Address, // Word-aligned address (32-bit)
    output reg [31:0] instruction
);

    // 1K-word instruction memory (32-bit words)
    reg [31:0] instMemory [0:65535];
    
    // Instruction format: | Opcode6 | Rd4 | Rs4 | Rt4 | Imm14 |
    always @(posedge clk) begin
        if (!stall)
            instruction <= instMemory[Address];
    end

    initial begin
        // Initialize memory with test programs
        
        // Test 1: Basic ALU operations
		
        /*instMemory[0] = {6'd1, 4'd1, 4'd2, 4'd3, 14'd0};  // ADD R1, R2, R3
        instMemory[1] = {6'd2, 4'd4, 4'd1, 4'd3, 14'd0};  // SUB R4, R1, R3
        instMemory[2] = {6'd0, 4'd5, 4'd1, 4'd2, 14'd0};  // OR R5, R1, R2
        instMemory[3] = {6'd3, 4'd6, 4'd1, 4'd2, 14'd0};  // CMP R6, R1, R2
		*/
        
        // Test 2: Immediate operations
		
        /*instMemory[0] = {6'd4, 4'd7, 4'd1, 4'd0, 14'h3FFF};  // ORI R7, R1, 0x3FFF
        instMemory[1] = {6'd5, 4'd8, 4'd1, 4'd0, 14'd100};     // ADDI R8, R1, 100
		*/
        
        // Test 3: Memory operations 
		
		//instMemory[0] = {6'd6, 4'd2, 4'd5, 4'd0, 14'd3};  // LW R2, 3(R5)
		//instMemory[1] = {6'd7, 4'd3, 4'd2, 4'd0, 14'd5};  // SW R3, 5(R2)
        
        // Test 4: Double-word operations (LDW/SDW)
        //instMemory[0] = {6'd8, 4'd2, 4'd1, 4'd0, 14'd12};      // LDW R2, 12(R1) (even reg)
        //instMemory[1] = {6'd9, 4'd4, 4'd1, 4'd0, 14'd16};      // SDW R4, 16(R1) (even reg)
        
        // Test 5: Control flow
        /*instMemory[0] = {6'd10, 4'd0, 4'd1, 4'd0, 14'd10};    // BZ R1, +10	
		instMemory[1] = {6'd2, 4'd5, 4'd1, 4'd3, 14'd0};	// SUB R5, R1, R3 
		instMemory[2] = {6'd11, 4'd0, 4'd1, 4'd0, 14'd8};    // BG R1, +10
		instMemory[3] = {6'd2, 4'd6, 4'd1, 4'd4, 14'd0};	// SUB R6, R1, R4
		instMemory[11] = {6'd2, 4'd7, 4'd1, 4'd3, 14'd0};	// SUB R7, R1, R3

		
        
    end
endmodule
