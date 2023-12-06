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
			 FUNCT7_SUB = 7'b0100000,
			 
			 FETCH_STATE = 6'd00,
			 DECODE_STATE = 6'd01,
			 LWSW_STATE = 6'd02,
			 LW1_STATE = 6'd03,
			 LW2_STATE = 6'd04,
			 SW_STATE = 6'd05,
			 RTYPE_STATE = 6'd06,
			 RTYPE2_STATE = 6'd07,
			 BRANCH_STATE = 6'd08,
			 JUMP_STATE = 6'd09,
			 RIMMTYPE_STATE = 6'd10;
			 
			 
module Controle (
	iInst,
	iClk,
	iRst,
	oRegWrite,
	oALUSrcA,
	oALUSrcB,
	oMemRead,
	oMemWrite,
	oMemtoReg,
	oIoD,
	oIRWrite,
	oPCWrite,
	oPCWriteCond,
	oALUOp,
	oPCSource
	);

	input [31:0] iInst;
	input iClk, iRst;
	 
	output oRegWrite;
	output oALUSrcA;
	output [1:0] oALUSrcB;
	output oMemRead;
	output oMemWrite;
	output oMemtoReg;
	output oIoD;
	output oIRWrite;
	output oPCWrite;
	output oPCWriteCond;
	output oALUOp;
	output oPCSource;
	
	wire [6:0] Opcode = iInst[6:0];
	wire [2:0] funct3 = iInst[14:12];
	wire [6:0] funct7 = iInst[31:25];
	
	reg [5:0] state;
	wire [5:0] nextState;
	
	reg [3:0] contador;
	
	initial
		begin
			state <= FETCH_STATE;
			contador <= 4'd0;
		end
	
	always @(posedge iClk or posedge iRst)
		begin
			if (iRst)
				begin
					state <= FETCH_STATE;
					contador <= 4'd0;
				end
			else
				begin
					state <= nextState;
				end
		end
		
		always @(*)
			case (state)
				
				FETCH_STATE: 
					begin
						oRegWrite <= 1'b0;
						oALUSrcA <= 1'b0;
						oALUSrcB <= 2'b01;
						oMemRead <= 1'b1;
						oMemWrite <= 1'b0;
						oMemtoReg <= 1'b0;
						oIoD <= 1'b0;
						oIRWrite <= 1'b1;
						oPCWrite <= 1'b1;
						oPCWriteCond <= 1'b0;
						oALUOp <= 2'b00;
						oPCSource <= 1'b0;
						
						nextState <= DECODE_STATE;
					end
				
				DECODE_STATE:
					begin
						oRegWrite <= 1'b0;
						oALUSrcA <= 1'b0;
						oALUSrcB <= 2'b10;
						oMemRead <= 1'b0;
						oMemWrite <= 1'b0;
						oMemtoReg <= 1'b0;
						oIoD <= 1'b0;
						oIRWrite <= 1'b0;
						oPCWrite <= 1'b0;
						oPCWriteCond <= 1'b0;
						oALUOp <= 2'b00;
						oPCSource <= 1'b0;
						
						case (Opcode)
						
							OP_LOAD,
							OP_STORE: nextState <= LWSW_STATE;
							OP_B: nextState <= BRANCH_STATE;
							OP_JAL: nextState <= JUMP_STATE;
							OP_R: nextState <= RTYPE_STATE;
							OP_R_IMM: nextState <= RIMMTYPE_STATE;
							
						endcase
					end
			
				LWSW_STATE:
					begin
						oRegWrite <= 1'b0;
						oALUSrcA <= 1'b1;
						oALUSrcB <= 2'b10;
						oMemRead <= 1'b0;
						oMemWrite <= 1'b0;
						oMemtoReg <= 1'b0;
						oIoD <= 1'b0;
						oIRWrite <= 1'b0;
						oPCWrite <= 1'b0;
						oPCWriteCond <= 1'b0;
						oALUOp <= 2'b00;
						oPCSource <= 1'b0;
						
						case (Opcode)
							OP_LOAD: nextState <= LW1_STATE;
							OP_STORE: nextState <= SW_STATE;
						endcase
					end
			
			  RTYPE_STATE:
					begin
						oRegWrite <= 1'b0;
						oALUSrcA <= 1'b1;
						oALUSrcB <= 2'b00;
						oMemRead <= 1'b0;
						oMemWrite <= 1'b0;
						oMemtoReg <= 1'b0;
						oIoD <= 1'b0;
						oIRWrite <= 1'b0;
						oPCWrite <= 1'b0;
						oPCWriteCond <= 1'b0;
						oALUOp <= 2'b10;
						oPCSource <= 1'b0;
						
						nextState <= RTYPE2_STATE;
					end
				
				LW1_STATE:
					begin
						oRegWrite <= 1'b0;
						oALUSrcA <= 1'b1;
						oALUSrcB <= 2'b00;
						oMemRead <= 1'b1;
						oMemWrite <= 1'b0;
						oMemtoReg <= 1'b0;
						oIoD <= 1'b1;
						oIRWrite <= 1'b0;
						oPCWrite <= 1'b0;
						oPCWriteCond <= 1'b0;
						oALUOp <= 2'b00;
						oPCSource <= 1'b0;
						
						nextState <= LW2_STATE;
					end
				
				LW2_STATE: 
					begin
						oRegWrite <= 1'b1;
						oALUSrcA <= 1'b1;
						oALUSrcB <= 2'b00;
						oMemRead <= 1'b0;
						oMemWrite <= 1'b0;
						oMemtoReg <= 1'b1;
						oIoD <= 1'b0;
						oIRWrite <= 1'b0;
						oPCWrite <= 1'b0;
						oPCWriteCond <= 1'b0;
						oALUOp <= 2'b00;
						oPCSource <= 1'b0;
						
						nextState <= FETCH_STATE;
					end
				
				SW_STATE:
					begin
						oRegWrite <= 1'b0;
						oALUSrcA <= 1'b1;
						oALUSrcB <= 2'b00;
						oMemRead <= 1'b0;
						oMemWrite <= 1'b1;
						oMemtoReg <= 1'b0;
						oIoD <= 1'b1;
						oIRWrite <= 1'b0;
						oPCWrite <= 1'b0;
						oPCWriteCond <= 1'b0;
						oALUOp <= 2'b00;
						oPCSource <= 1'b0;
						
						nextState <= FETCH_STATE;
					end
					
			
				BRANCH_STATE:
					begin
						oRegWrite <= 1'b0;
						oALUSrcA <= 1'b1;
						oALUSrcB <= 2'b00;
						oMemRead <= 1'b0;
						oMemWrite <= 1'b0;
						oMemtoReg <= 1'b0;
						oIoD <= 1'b0;
						oIRWrite <= 1'b0;
						oPCWrite <= 1'b0;
						oPCWriteCond <= 1'b1;
						oALUOp <= 2'b01;
						oPCSource <= 1'b1;
						
						nextState <= FETCH_STATE;
						
					end
				
				RIMMTYPE_STATE:
					begin
						oRegWrite <= 1'b0;
						oALUSrcA <= 1'b1;
						oALUSrcB <= 2'b10;
						oMemRead <= 1'b0;
						oMemWrite <= 1'b0;
						oMemtoReg <= 1'b0;
						oIoD <= 1'b0;
						oIRWrite <= 1'b0;
						oPCWrite <= 1'b0;
						oPCWriteCond <= 1'b0;
						oALUOp <= 2'b10;
						oPCSource <= 1'b0;
						
						nextState <= RTYPE2_STATE;
					end
				
				RTYPE2_STATE:
					begin
						oRegWrite <= 1'b1;
						oALUSrcA <= 1'b1;
						oALUSrcB <= 2'b00;
						oMemRead <= 1'b0;
						oMemWrite <= 1'b0;
						oMemtoReg <= 1'b0;
						oIoD <= 1'b0;
						oIRWrite <= 1'b0;
						oPCWrite <= 1'b0;
						oPCWriteCond <= 1'b0;
						oALUOp <= 2'b10;
						oPCSource <= 1'b0;
						
						nextState <= FETCH_STATE;
					end
				
			  JUMP_STATE:
				  begin
						oRegWrite <= 1'b1;
						oALUSrcA <= 1'b1;
						oALUSrcB <= 2'b00;
						oMemRead <= 1'b0;
						oMemWrite <= 1'b0;
						oMemtoReg <= 1'b0;
						oIoD <= 1'b0;
						oIRWrite <= 1'b0;
						oPCWrite <= 1'b1;
						oPCWriteCond <= 1'b0;
						oALUOp <= 2'b10;
						oPCSource <= 1'b1;
						
						nextState <= FETCH_STATE;
				  end
				
			endcase
endmodule