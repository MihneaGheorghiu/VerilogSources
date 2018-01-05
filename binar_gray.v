`timescale 1ns / 1ps
module binar_gray(b,g);
input [3:0] b;
output [3:0] g;
assign g[3]=b[3];
assign g[2]=b[3]^b[2];
assign g[1]=b[1]^b[2];
assign g[0]=b[0]^b[1];
endmodule

module test_gray;
reg [3:0] b;
wire [3:0] g;

	initial begin
	    b =4'b111;
	end
	
    binar_gray conv(b, g);
endmodule
