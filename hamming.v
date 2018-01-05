`timescale 1ns / 1ps

module hamming_code(inMsg, outMsg);
	input [31 : 0] inMsg;
	output [37 : 0] outMsg;
	wire [37 : 0] tempMsg;
	
	assign tempMsg[2] = inMsg[0];
	assign tempMsg[6 : 4] = inMsg[3 : 1];
	assign tempMsg[14 : 8] = inMsg[10 : 4];
	assign tempMsg[30 : 16] = inMsg[25 : 11];
	assign tempMsg[37 : 32] = inMsg[31 : 26];
	
	assign outMsg = tempMsg;
	
	assign outMsg[ 0] = ^(tempMsg & 38'b01010101010101010101010101010101010100);
	assign outMsg[ 1] = ^(tempMsg & 38'b10011001100110011001100110011001100100);
	assign outMsg[ 3] = ^(tempMsg & 38'b11100001111000011110000111100001110000);
	assign outMsg[ 7] = ^(tempMsg & 38'b00000001111111100000000111111100000000);
	assign outMsg[15] = ^(tempMsg & 38'b00000001111111111111110000000000000000);
	assign outMsg[31] = ^(tempMsg & 38'b11111100000000000000000000000000000000);
	//assign outMsg[32] = 0;
endmodule
