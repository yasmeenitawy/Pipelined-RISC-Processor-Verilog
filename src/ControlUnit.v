module MainControlUnit(
	input wire [5:0] opcode,
	input wire stall, 
	input wire clk, /////////////////////////////////////
	output reg [12:0] ControlSignals
);		

	reg state ;  //0=first cycle, 1=second cycle

	initial begin
    		state = 1'b0;  // Assume first cycle at power-up
	end


	always @(*) begin    
		
		// ControlSignals <= ALUOP(2) RegWr(1)  MemR(1) MemW(1) WB(1) ALUSrc2(1) Destination(1) Source2(1) ExtOp(1) LSDW_C2(1) LSDW_ACTIVE(1) J(1)
		if (stall == 0) begin

			case (opcode)	  
				6'b000000:	ControlSignals <= {2'b00, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, 1'b0, 1'b0, 1'bx} ;  
				6'b000001:	ControlSignals <= {2'b01, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, 1'b0, 1'b0, 1'bx} ;  
				6'b000010:	ControlSignals <= {2'b10, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, 1'b0, 1'b0, 1'bx} ;  
				6'b000011:	ControlSignals <= {2'b11, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, 1'b0, 1'b0, 1'bx} ;  
				6'b000100:	ControlSignals <= {2'b00, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'bx, 1'b0, 1'b0, 1'b0, 1'bx} ;  
				6'b000101:	ControlSignals <= {2'b01, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'bx, 1'b1, 1'b0, 1'b0, 1'bx} ;  
				6'b000110:	ControlSignals <= {2'b01, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'bx, 1'b1, 1'b0, 1'b0, 1'bx} ;    						
				6'b000111: 	ControlSignals <= {2'b01, 1'b0, 1'b0, 1'b1, 1'bx, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'bx} ;
				// ldw
				6'b001000: begin
					if (state) begin
						ControlSignals <= {2'b01, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'bx, 1'b1, 1'b1, 1'b1, 1'bx} ;
					end else begin
					ControlSignals <= {2'b01, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'bx, 1'b1, 1'b1, 1'b1, 1'bx} ;
					end	 
				end
			
			// sdw
				6'b001001: begin
					if (state) begin
						ControlSignals <= {2'b01, 1'b0, 1'b0, 1'b1, 1'bx, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'bx} ;
					end else begin
					ControlSignals <= {2'b01, 1'b0, 1'b0, 1'b1, 1'bx, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'bx} ;
					end	 
				end

				6'b001010:	ControlSignals <= {2'bxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'bx} ;  // BZ  
				6'b001011:	ControlSignals <= {2'bxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'bx} ;  // BGZ   
				6'b001100:	ControlSignals <= {2'bxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'bx} ;  // BLZ
				6'b001101:	ControlSignals <= {2'bxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'bx, 1'b0, 1'b0, 1'b1} ;  // JR	
				6'b001110:	ControlSignals <= {2'bxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1} ;  // J
				6'b001111:	ControlSignals <= {2'bxx, 1'b0, 1'b0, 1'b0, 1'bx, 1'bx, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1} ;  // CLL
				default:  ControlSignals <= 13'b0 ;	 	
			endcase	
		end
		else begin ControlSignals <= 13'b0 ; end
	
	end	
	
	// State machine advances ONLY when not stalled
    always @(posedge clk) begin
        if (!stall) begin
            case (opcode)
                6'b001000, 6'b001001: state <= ~state; // Toggle state each cycle
                default: state <= 1'b0;
            endcase
        end
    end

endmodule  


module PCControlUnit(
	input wire [5:0] opcode,
	input wire [1:0] comp_res,
	input wire J,
	input wire LDW_SDW_Active,
	input wire LDW_SDW_C2,
	input wire [3:0] Rd,
	output reg Kill,
	output reg [1:0] PCSrc,
	output reg R14WE
); 

	initial begin
		PCSrc = 0 ;
	 	Kill = 0 ;
		R14WE = 0;
	end	 
	
	wire is_ldw_sdw = (opcode == 6'b001000 || opcode == 6'b001001);
    wire odd_register = Rd[0]; // LSB=1 ? odd reg number

	always @(*) begin   
		
		if (is_ldw_sdw && odd_register) begin
            Kill    = 1'b1;   // Force NOP to decode
            PCSrc   = 2'b11;  // Exception handler address
        end
		
	else if (LDW_SDW_Active && !LDW_SDW_C2) begin
            PCSrc   = 2'b11;   // Freeze PC
        end
		
		else begin
		
		// ControlSignals <= Kill(1) PCSrc(2) R14WE(1) 
		
		if (opcode == 6'b000000) begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end    
		else if (opcode == 6'b000001) begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end
		else if (opcode == 6'b000010) begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end
		else if (opcode == 6'b000011) begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end
		else if (opcode == 6'b000100) begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end
		else if (opcode == 6'b000101) begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end
		else if (opcode == 6'b000110) begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end 
		else if (opcode == 6'b000111) begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end
		// ldw
		// sdw	
		else if (opcode == 6'b001010 && comp_res != 2'b01) begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end // BZ (Branch not taken)
		else if (opcode == 6'b001010 && comp_res == 2'b01) begin Kill <= 1'b1; PCSrc <= 2'b01; R14WE <= 1'b0; end // BZ (Branch taken)
		else if (opcode == 6'b001011 && comp_res != 2'b10) begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end // BGZ (Branch not taken)
		else if (opcode == 6'b001011 && comp_res == 2'b10) begin Kill <= 1'b1; PCSrc <= 2'b01; R14WE <= 1'b0; end // BGZ (Branch taken)
		else if (opcode == 6'b001100 && comp_res != 2'b11) begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end // BLZ (Branch not taken)
		else if (opcode == 6'b001100 && comp_res == 2'b11) begin Kill <= 1'b1; PCSrc <= 2'b01; R14WE <= 1'b0; end // BLZ (Branch taken)
		
		
		else if (opcode == 6'b001101 && J == 1'b1) begin Kill <= 1'b1; PCSrc <= 2'b10; R14WE <= 1'b0; end // JR
		else if (opcode == 6'b001110 && J == 1'b1) begin Kill <= 1'b1; PCSrc <= 2'b01; R14WE <= 1'b0; end // Jmp
		else if (opcode == 6'b001111 && J == 1'b1) begin Kill <= 1'b1; PCSrc <= 2'b01; R14WE <= 1'b1; end // Call
	
		else begin Kill <= 1'b0; PCSrc <= 2'b00; R14WE <= 1'b0; end // default
		
		end
	end	  

endmodule


module ForwordingControlUnit(
	input wire [3:0] RS1, RS2, RD2, RD3, RD4,
	input wire Ex_MemR, Ex_RegWr, Mem_RegWr, WB_RegWr,
	output reg [1:0] ForwardA, ForwardB, 
	output reg stall
); 

	initial begin 
		stall = 0 ;
		ForwardA = 0 ;
		ForwardB = 0 ;
		
	end

	always @(*) begin
	
		if (RS1 != 0 && RS1 == RD2 && Ex_RegWr == 1) 
			ForwardA = 1 ;
		else if (RS1 != 0 && RS1 == RD3 && Mem_RegWr == 1)
			ForwardA = 2 ;
		else if (RS1 != 0 && RS1 == RD4 && WB_RegWr == 1)
			ForwardA = 3 ;
		else
			ForwardA = 0 ;	
			
			
			
		if (RS2 != 0 && RS2 == RD2 && Ex_RegWr == 1) 
			ForwardB = 1 ;
		else if (RS2 != 0 && RS2 == RD3 && Mem_RegWr == 1)
			ForwardB = 2 ;
		else if (RS2 != 0 && RS2 == RD4 && WB_RegWr == 1)
			ForwardB = 3 ;
		else
			ForwardB = 0 ; 
			
		
		if (Ex_MemR == 1 && (ForwardA == 1 || ForwardB == 1))	 
			stall = 1 ;
		else
			stall = 0 ;	 
				
	end
	

endmodule



