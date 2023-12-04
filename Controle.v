parameter OP_R = 7'b0110011,
			 OP_B = 7'b1100011,
			 OP_LOAD = 7'b0000011,
			 OP_STORE = 7'b0100011,
			 OP_JAL = 7'b1101111,
			 OP_R_IMM = 7'b0010011,
			 
			 FUNCT3_ADD	= 3'b000,
			 FUNCT3_SUB	= 3'b000,
			 FUNCT3_SLT	= 3'b010,
			 FUNCT3_OR	= 3'b110,
			 FUNCT3_AND	= 3'b111,
			 FUNCT3_ADDI = 3'b001,
			 FUNCT3_ANDI = 3'b111,
			 FUNCT3_ORI = 3'b100,
			 FUNCT3_XORI = 3'b010,
			 
			 FUNCT7_ADD	= 7'b0000000,
			 FUNCT7_SUB = 7'b0100000;


module Controle(
	iClk,
	iInst,
	
	//Output right
	oOrigPC,
	oALUOp,
	oOrigAULA,
	oOrigBULA,
	oWritePCB,
	oRegWrite,
	oMemTwoReg,
	
	//Output left
	oWritePCCond,
	oWritePC,
	oLoudD,
	oMemWrite,
	oMemRead,
	oWriteIR,

);

	input wire iClk;

	input [31:0] iInst;
	
	wire [6:0] Opcode = iInst[6:0];
	wire [2:0] funct3 = iInst[14:12];
	wire [6:0] funct7 = iInst[31:25];
	
	
	//Output right
	output [1:0] oOrigPC;
	output [1:0] oALUOp;
	output [1:0} oOrigAULA;
	output [1:0] oOrigBULA;
	output oWritePCB;
	output oRegWrite;
	output [2:0] oMemTwoReg;
	
	//Output left
	output oWritePCCond;
	output oWritePC;
	output oLoudD;
	output oMemWrite;
	output oMemRead;
	output oWriteIR;
	
	//Registrador de estados
	reg [3:0] state;
	
	//Cod state
	parameter state_zero = 4'b0000,
				state_one = 4'b0001,
				state_two = 4'b0010,
				state_three = 4'b0011,
				state_four = 4'b0100,
				state_five = 4'b0101,
				state_six = 4'b0110,
				state_saven = 4'b0111,
				state_eight = 4'b1000,
				state_nine = 4'b1001,
				
	//start machine 
	initial begin 
		state <= state_zero;
		
		//Output right
		oOrigPC <= 1'b0;
		oALUOp <= 2'b00;
		oOrigAULA <= 2'b10;
		oOrigBULA <= 2'b01;
		oWritePCB;
			//oRegWrite;
			//oMemTwoReg;
		
		
		//Output left
			//oWritePCCond;
		oWritePC;
		oLoudD <= 1'b0;
			//oMemWrite;
		oMemRead;
		oWriteIR;
		
	end
	
	
	//Define next state
	always @(posedge iClk) begin
		case(state)
			
			state_zero: begin 
				state <= state_one;
			end
			
			
			state_one: begin 
				
				case(Opcode)
					OP_R:begin
						state <= state_six;
					end
					
					OP_B: begin
						state <= state_eight;
					end
					
					OP_LOAD: begin
						state <= state_two;
					end
					
					OP_STORE: begin
						state <= state_two;
					end
					
					OP_JAL: begin
						state <= state_nine;
					end
					
					OP_R_IMM: begin
					
					end
				endcase
			end 
			
			
			state_two: begin 
				case(Opcode)
					OP_LOAD: begin
						state <= state_three;
					end
					
					OP_STORE: begin
						state <= state_five;
					end
				endcase
			end
			
			
			state_three: begin
				state <= state_four;
			end
			
			
			state_four: begin
				state <= state_zero;
			end
			
			
			state_five: begin
				state <= state_zero;
			end
			
			
			state_six: begin 
				state <= state_seven;
			end
			
			
			state_saven: begin
				state <= state_zero;
			end
			
			
			state_eight:begin
				state <= state_zero;
			end
			
			
			state_nine:begin
				state <= state_zero;
			end
		
		endcase
	end
	
	//Define output for each state
	always @(posedge iClk) begin
		case(state)
			//state_zero: begin 	
			//end
			
			
			state_one: begin 
				//Output right
				//oOrigPC = 1'b;
				oALUOp = 2'b00;
				oOrigAULA = 2'b00;
				oOrigBULA = 2'b11;
				//oWritePCB;
				//oRegWrite;
				//oMemTwoReg;
				//Output left
				//oWritePCCond;
				//oWritePC;
				//oLoudD <= 1'b0;
				//oMemWrite;
				//oMemRead;
				//oWriteIR;
	
				
			end 
			
			
			state_two: begin 
				//Output right
				//oOrigPC <= 1'b;
				oALUOp = 2'b00;
				oOrigAULA = 2'b01;
				oOrigBULA = 2'b10;
				//oWritePCB;
				//oRegWrite;
				//oMemTwoReg;
				//Output left
				//oWritePCCond;
				//oWritePC;
				//oLoudD <= 1'b0;
				//oMemWrite;
				//oMemRead;
				//oWriteIR;
	
				
			end
			
			
			state_three: begin
				//Output right
				//oOrigPC <= 1'b;
				//oALUOp <= 2'b00;
				//oOrigAULA <= 2'b00;
				//oOrigBULA <= 2'b11;
				//oWritePCB;
				//oRegWrite;
				//oMemTwoReg;
				//Output left
				//oWritePCCond;
				//oWritePC;
				oLoudD = 1'b1;
				//oMemWrite;
				oMemRead = 1'b0;
				//oWriteIR;
	
				
			end
			
			
			state_four: begin
				//Output right
				//oOrigPC = 1'b;
				//oALUOp = 2'b00;
				//oOrigAULA = 2'b00;
				//oOrigBULA = 2'b11;
				//oWritePCB;
				//oRegWrite;
				oMemTwoReg = 1'b10;
				//Output left
				//oWritePCCond;
				//oWritePC;
				//oLoudD <= 1'b0;
				//oMemWrite;
				oMemRead = 1'b0;
				//oWriteIR;
	
			
			end
			
			
			state_five: begin
				//Output right
				//oOrigPC = 1'b;
				//oALUOp = 2'b00;
				//oOrigAULA = 2'b00;
				//oOrigBULA = 2'b11;
				//oWritePCB;
				//oRegWrite;
				//oMemTwoReg = 1'b10;
				//Output left
				//oWritePCCond;
				//oWritePC;
				oLoudD = 1'b1;
				oMemWrite = 1'b0;
				//oMemRead = 1'b0;
				//oWriteIR;
				
			end
			
			
			state_six: begin 
				//Output right
				//oOrigPC = 1'b;
				oALUOp = 2'b10;
				oOrigAULA = 2'b01;
				oOrigBULA = 2'b00;
				//oWritePCB;
				//oRegWrite;
				//oMemTwoReg = 1'b10;
				//Output left
				//oWritePCCond;
				//oWritePC;
				//oLoudD <= 1'b0;
				//oMemWrite;
				//oMemRead = 1'b0;
				//oWriteIR;
				
			end
			
			
			state_saven: begin
				//Output right
				//oOrigPC = 1'b;
				//oALUOp = 2'b00;
				//oOrigAULA = 2'b00;
				//oOrigBULA = 2'b11;
				//oWritePCB;
				oRegWrite = 1'b0;
				oMemTwoReg = 2'b00;
				//Output left
				//oWritePCCond;
				//oWritePC;
				//oLoudD <= 1'b0;
				//oMemWrite;
				//oMemRead = 1'b0;
				//oWriteIR;
				
			end
			
			
			state_eight:begin
				//Output right
				oOrigPC = 1'b1;
				oALUOp = 2'b01;
				oOrigAULA = 2'b01;
				oOrigBULA = 2'b00;
				//oWritePCB;
				//oRegWrite;
				oMemTwoReg = 1'b10;
				//Output left
				oWritePCCond = 1'b0;
				//oWritePC;
				//oLoudD <= 1'b0;
				//oMemWrite;
				//oMemRead = 1'b0;
				//oWriteIR;
				
			end
			
			
			state_nine:begin
				//Output right
				oOrigPC = 1'b1;
				//oALUOp = 2'b00;
				//oOrigAULA = 2'b00;
				//oOrigBULA = 2'b11;
				//oWritePCB;
				oRegWrite = 1'b0;
				oMemTwoReg = 1'b01;
				//Output left
				//oWritePCCond;
				oWritePC = 1'b0;
				//oLoudD <= 1'b0;
				//oMemWrite;
				oMemRead = 1'b0;
				//oWriteIR;
				
			end
		
		endcase
	end

endmodule 