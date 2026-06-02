module IFStage (
    input wire clk,
    input kill, stall,
    input wire [1:0] PCSrc,
    input wire [31:0] BranchJump_TA, JR_TA, 
    output reg [31:0] CurrentPC, New_PC, Instruction,
    output reg [31:0] num_stall
);

    reg [31:0] PC;
    wire [31:0] instruction_wire; 
    reg [31:0] num_inst, numstall;
    reg [31:0] next_PC;  // Added to help with PC calculation

    InstructionMemory instruction(
        .clk(clk),
        .Address(PC),
        .stall(stall),
        .instruction(instruction_wire)
    );

    mux_2 #(.LENGTH(32)) mux_kill (
        .in1(instruction_wire),
        .in2(32'b0),
        .sel(kill),
        .out(Instruction)
    );

    // Calculate next PC combinationally
    always @(*) begin
        case (PCSrc)
            2'b00: next_PC = PC + 32'b1;        // Normal increment
            2'b01: next_PC = BranchJump_TA;      // Branch or jump
            2'b10: next_PC = JR_TA;              // Jump register  
            2'b11: next_PC = PC;                 // Hold PC (stall/freeze)
            default: next_PC = PC + 32'b1;
        endcase
    end

    always @(posedge clk) begin
        if (!stall) begin 
            // Update CurrentPC to reflect the PC of the instruction being fetched
            CurrentPC <= PC;
            
            // Update PC for next cycle
            PC <= next_PC;
            
            // New_PC shows what PC will be next cycle
            New_PC <= next_PC;
        end
        else begin
            // During stall, maintain current values
            // PC and CurrentPC don't change
            New_PC <= PC; // Show that PC will remain the same
        end

        // Instruction counting (only count valid, non-killed instructions)
        if (Instruction !== 32'bx && Instruction != 32'b0 && !kill) begin
            num_inst <= num_inst + 1;
        end

        // Stall counting
        if (stall == 1) begin
            numstall <= numstall + 1;
            num_stall <= numstall + 1;
        end
    end

    initial begin
        num_inst   = 32'b0;
        numstall   = 32'b0;
        num_stall  = 32'b0;
        PC         = 32'b0;
        New_PC     = 32'b0;
        CurrentPC  = 32'b0;
        next_PC    = 32'b0;
    end

endmodule