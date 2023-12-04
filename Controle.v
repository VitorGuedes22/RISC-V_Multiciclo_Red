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
			 
			 
			//Cod state
			STATE_ZERO = 4'b0000,
			STATE_ONE = 4'b0001,
			STATE_TWO = 4'b0010,
			STATE_THREE = 4'b0011,
			STATE_FOUR = 4'b0100,
			STATE_FIVE = 4'b0101,
			STATE_SIX = 4'b0110,
			STATE_SEVEN = 4'b0111,
			STATE_EIGHT = 4'b1000,
			STATE_NINE = 4'b1001,
			STATE_TEN = 4'b1010;


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
	
				
	//start machine 
	initial begin 
		state <= STATE_ZERO;
		
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
			
			STATE_ZERO: begin 
				state <= STATE_ONE;
			end
			
			
			STATE_ONE: begin 
				
				case(Opcode)
					OP_R:begin
						state <= STATE_SIX;
					end
					
					OP_B: begin
						state <= STATE_EIGHT;
					end
					
					OP_LOAD: begin
						state <= STATE_TWO;
					end
					
					OP_STORE: begin
						state <= STATE_TWO;
					end
					
					OP_JAL: begin
						state <= STATE_NINE;
					end
					
					OP_R_IMM: begin
						state <= STATE_SEVEN;
					end
				endcase
			end 
			
			
			STATE_TWO: begin 
				case(Opcode)
					OP_LOAD: begin
						state <= STATE_THREE;
					end
					
					OP_STORE: begin
						state <= STATE_FIVE;
					end
				endcase
			end
			
			
			STATE_THREE: begin
				state <= STATE_FOUR;
			end
			
			
			STATE_FOUR: begin
				state <= STATE_ZERO;
			end
			
			
			STATE_FIVE: begin
				state <= STATE_ZERO;
			end
			
			
			STATE_SIX: begin 
				state <= STATE_ZERO;
			end
			
			
			state_saven: begin
				state <= STATE_ZERO;
			end
			
			
			STATE_EIGHT:begin
				state <= STATE_ZERO;
			end
			
			
			STATE_NINE:begin
				state <= STATE_ZERO;
			end
		
		
			STATE_TEN: begin
				state <= STATE_SEVEN;
			end
		endcase
	end
	
	
	//Define output for each state
	always @(posedge iClk) begin
		case(state)
			//state_zero: begin 	
			//end
			
			
			STATE_ONE: begin 
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
			
			
			STATE_TWO: begin 
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
			
			
			STATE_THREE: begin
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
			
			
			STATE_FOUR: begin
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
			
			
			STATE_FIVE: begin
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
			
			
			STATE_SIX: begin 
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
			
			
			STATE_EIGHT:begin
				//Output right
				oOrigPC = 1'b1;
				oALUOp = 2'b01;
				oOrigAULA = 2'b01;
				oOrigBULA = 2'b00;
				//oWritePCB;
				//oRegWrite;
				oMemTwoReg = 2'b10;
				//Output left
				oWritePCCond = 1'b0;
				//oWritePC;
				//oLoudD <= 1'b0;
				//oMemWrite;
				//oMemRead = 1'b0;
				//oWriteIR;
				
			end
			
			
			STATE_NINE:begin
				//Output right
				oOrigPC = 1'b1;
				//oALUOp = 2'b00;
				//oOrigAULA = 2'b00;
				//oOrigBULA = 2'b11;
				//oWritePCB;
				oRegWrite = 1'b0;
				oMemTwoReg =2'b01;
				//Output left
				//oWritePCCond;
				oWritePC = 1'b0;
				//oLoudD <= 1'b0;
				//oMemWrite;
				oMemRead = 1'b0;
				//oWriteIR;
				
			end
			
			
			STATE_TEN: begin
				//Output right
				//oOrigPC = 1'b;
				oALUOp = 2'b10;
				oOrigAULA = 2'b01;
				oOrigBULA = 2'10;
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
		
		endcase
	end

endmodule 