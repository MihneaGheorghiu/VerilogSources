`timescale 1ns / 1ps
module hamming_decode(inMsg, outMsg);
	input [37 : 0] inMsg;
	wire [37 : 0] tempMsg;
	wire [5 : 0] errPos;
	output [31 : 0] outMsg;
	
	
	assign errPos[0] = ^(inMsg & 38'b01010101010101010101010101010101010101);
	assign errPos[1] = ^(inMsg & 38'b10011001100110011001100110011001100110);
	assign errPos[2] = ^(inMsg & 38'b11100001111000011110000111100001111000);
	assign errPos[3] = ^(inMsg & 38'b00000001111111100000000111111110000000);
	assign errPos[4] = ^(inMsg & 38'b00000001111111111111111000000000000000);
	assign errPos[5] = ^(inMsg & 38'b11111110000000000000000000000000000000);
	
	assign tempMsg = (errPos == 0) ? (inMsg) : (inMsg ^ (1 << (errPos - 1)));
	
	assign outMsg[0] = tempMsg[2];
	assign outMsg[3 : 1] = tempMsg[6 : 4];
	assign outMsg[10 : 4] = tempMsg[14 : 8];
	assign outMsg[25 : 11] = tempMsg[30 : 16];
	assign outMsg[31 : 26] = tempMsg[37 : 32];

endmodule