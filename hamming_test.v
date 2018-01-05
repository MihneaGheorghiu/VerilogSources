`timescale 1ns / 1ps
module test();

	reg [31 : 0] in1;
	wire [37 : 0] trans, temp;
	wire [31 : 0] out1;

	initial begin
		in1 = 32'd2345;
		#2 in1 = 32'd892;
	end
	
	hamming_code HC(in1, trans);
	hamming_decode HD(temp, out1);
	assign temp = trans ^ (1 << 7);
	
endmodule
