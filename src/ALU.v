module ALU(
    input wire [31:0] ALUSrc1,
    input wire [31:0] ALUSrc2,
    input wire [1:0] ALUOp,
    output reg [31:0] ALUOut
);
    // ALU operation codes
    parameter ALU_OP_OR  = 2'b00;
    parameter ALU_OP_ADD = 2'b01;
    parameter ALU_OP_SUB = 2'b10;
    parameter ALU_OP_CMP = 2'b11;
    
    // Internal signals for flag computation
    reg zero, carry, overflow, negative;
    reg [32:0] temp_result;  // Extra bit for carry detection
    
    always @(*) begin
        // Initialize flags
        zero = 1'b0;
        carry = 1'b0;
        overflow = 1'b0;
        negative = 1'b0;
        
        case (ALUOp)
            ALU_OP_OR: begin
                ALUOut = ALUSrc1 | ALUSrc2;
                zero = (ALUOut == 32'b0);
            end
            
            ALU_OP_ADD: begin
                temp_result = {1'b0, ALUSrc1} + {1'b0, ALUSrc2};
                ALUOut = temp_result[31:0];
                zero = (ALUOut == 32'b0);
                carry = temp_result[32];
                overflow = (ALUSrc1[31] == ALUSrc2[31]) && (ALUOut[31] != ALUSrc1[31]);
                negative = ALUOut[31];
            end
            
            ALU_OP_SUB: begin
                temp_result = {1'b0, ALUSrc1} - {1'b0, ALUSrc2};
                ALUOut = temp_result[31:0];
                zero = (ALUOut == 32'b0);
                carry = ~temp_result[32];  // Borrow occurred
                overflow = (ALUSrc1[31] != ALUSrc2[31]) && (ALUOut[31] != ALUSrc1[31]);
                negative = ALUOut[31];
            end
            
            ALU_OP_CMP: begin
                // Perform subtraction to set flags
                temp_result = {1'b0, ALUSrc1} - {1'b0, ALUSrc2};
                zero = (temp_result[31:0] == 32'b0);
                carry = ~temp_result[32];  // Borrow occurred
                overflow = (ALUSrc1[31] != ALUSrc2[31]) && (temp_result[31] != ALUSrc1[31]);
                negative = temp_result[31];
                
                // Set ALUOut based on flags
                if (zero) begin
                    ALUOut = 32'd0;  // ALUSrc1 == ALUSrc2
                end else if (negative ^ overflow) begin
                    ALUOut = -32'd1; // ALUSrc1 < ALUSrc2 (signed comparison)
                end else begin
                    ALUOut = 32'd1;  // ALUSrc1 > ALUSrc2
                end
            end
            
            default: begin
                ALUOut = 32'b0;
                zero = 1'b1;
            end
        endcase
    end
endmodule