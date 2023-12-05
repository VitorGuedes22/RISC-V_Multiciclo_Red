module MemoryInterface(
	iAdress,
	iCLK,
	iMemWrite,
	iMemRead,
	iWriteData,
	oReadData;

);

	 input wire [31:0] iAdress,
    input wire iCLK,
    input wire iMemRead,
    input wire iMemWrite,
    input wire [31:0] iWriteData,
    output reg [31:0] oReadData;
	 
	always @(posedge iCLK) begin 
		//Memoria de dados
		if(iAdress[28]) begin 
			
			ram_data MEMORYDATA(
				.address(iAdress[9:0]),
				.clock(iCLK),
				.data(iWriteData),
				.rden(iMemRead),
				.wren(iMemWrite),
				.q(oReadData)
				);
						
				
		
		end
		
		//Memoria de instrucao
		else
			rom_isnt MEMORYINST(
				.address(iAdress[9:0]),
				.clock(iCLK),
				.data(iWriteData),
				.rden(iMemRead),
				.q(oReadData)
				);
	
	end
	
	
endmodule