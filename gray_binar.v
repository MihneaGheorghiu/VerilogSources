`timescale 1ns / 1ps

module gray_binar(g,b);
input [3:0] g;
output [3:0] b;
assign b[3]=g[3];
assign b[2]=b[3]^g[2];
assign b[1]=b[2]^g[1];
assign b[0]=b[1]^g[0];
endmodule

module test_gray2;
reg [3:0] g;
wire [3:0] b;

	initial begin
	    g =4'b111;
	end
	
    gray_binar conv(g, b);
endmodule
