module Datapath (
		// FPGA
		input wire clockCPU, clockMem,
		input wire reset,
		input  wire[4:0] regin,
		output reg [31:0] PCView,
		output reg [31:0] Instr,
		output reg [31:0] regout,
		
		//Controle 
		output [31:0] iInst,
		
		input oRegWrite,
		input oALUSrcA,
		input [1:0] oALUSrcB,
		input oMemRead,
		input oMemWrite,
		input oMemtoReg,
		input oIoD,
		input oIRWrite,
		input oPCWrite,
		input oPCWriteCond,
		input oALUOp,
		input oPCSource,
		input oWritePCBack
	);
	
// Instanciação
reg 	[31:0] PC, PCBack, IR, MDR, A, B, ALUOut;

assign iInst = IR;
assign Instr = IR;
assign PCView = PCBack;

initial
begin
	PC			<= 32'h0040_0000;
	PCBack 	<= 32'h0040_0000;
	IR			<= 32'd00;
	ALUOut	<= 32'd00;
	MDR 		<= 32'd00;
	A 			<= 32'd00;
	B 			<= 32'd00;
end

wire [ 4:0] wRs1			= IR[19:15];
wire [ 4:0] wRs2			= IR[24:20];
wire [ 4:0] wRd			= IR[11:7];
wire [ 2:0] wFunct3		= IR[14:12];

// Memoria

wire [31:0] wMemLoad;

MemoryInterface MEMORIA(
	.iAdress(wMemAddress[9:0]),
	.iCLK(clockMem),
	.iMemWrite(oMemWrite),
	.iMemRead(oMemRead),
	.iWriteData(B),
	.oReadData(wMemLoad)
);
  
//Banco de registradores

wire [31:0] wRead1, wRead2;

BancoReg REGISTRADORES (
		.iCLK(clockCPU),
		.iRST(reset),
		.iRegWrite(oRegWrite),
		.iReadReg1(wRs1),
		.iReadReg2(wRs2),
		.iWriteReg(wRd),
		.iWriteData(wRegWrite),
		.iRegDispSelect(regin),
		.oReadData1(wRead1),
		.oReadData2(wRead2),
		.oRegDisp(regout)
);

//Gerador de imediato

wire [31:0] wImmediate;

ImmGen IMMGEN (
		.iInstrucao(IR),
		.oImm(wImmediate)
);

// ULA

wire [31:0] wALUResult;
wire wZero;

ULA ALU (
		.iControl(oALUOp),
		.iA(wOrigAULA),
		.iB(wOrigBULA),
		.oResult(wALUResult),
		.oZero(wZero)
);

// Multiplexadores

wire [31:0] wOrigAULA;

always @(*)
begin
	case (oALUSrcA)
		1'b0: wOrigAULA <= PC;
		1'b1: wOrigAULA <= A;
	endcase
end

wire [31:0] wOrigBULA;

always @(*)
begin
	case (oALUSrcB)
		2'b00: wOrigBULA <= B;
		2'b01: wOrigBULA <= 32'h00000004;
		2'b10: wOrigBULA <= wImmediate;
	endcase
end

wire [31:0] wRegWrite;

always @(*)
begin
	case (oMemtoReg)
		1'b0: wRegWrite <= ALUOut;
		1'b1: wRegWrite <= MDR;
	endcase
end

wire [31:0] wiPC;

always @(*)
begin
	case (oPCSource)
		1'b0:	wiPC <= wALUResult;
		1'b1:	wiPC <= ALUOut; 
	endcase
end

wire [31:0] wMemAddress;

always @(*)
begin
	case (oIoD)
		1'b0:	wMemAddress <= PC;
		1'b1: wMemAddress <= ALUOut; 
	endcase
end

// A Cada ciclo de clock
always @(posedge clockCPU or posedge reset)
begin
	if(reset)
		begin
			PC			<= 32'h0040_0000;
			PCBack 	<= 32'h0040_0000;
			IR			<= 32'd00;
			ALUOut	<= 32'd00;
			MDR 		<= 32'd00;
			A 			<= 32'd00;
			B 			<= 32'd00;
		end
	else
		begin
			ALUOut	<= wALUResult;
			A			<= wRead1;
			B			<= wRead2;
			MDR		<= wMemLoad;
			
			if (oIRWrite)
				IR	<= wMemLoad;
			
			if (oWritePCBack)
				PCBack <= PC;	
				
			if (oPCWrite || wZero & oPCWriteCond)
				PC	<= wiPC;	

		end
end
endmodule