`timescale 1ns / 1ns

module automat(bani, cola, rest, reset, clk);
    parameter m0  = 2'b00;
    parameter m5  = 2'b01;
    parameter b10 = 2'b10;
    parameter b50 = 2'b11;
 
    parameter S0 = 5'b00000;
    parameter S1 = 5'b00001;
    parameter S2 = 5'b00010;
    parameter S3 = 5'b00011;
    parameter S4 = 5'b00100;
    parameter S5 = 5'b00101;
    parameter S6 = 5'b00110;
    parameter S7 = 5'b00111;
    parameter S8 = 5'b01000;
    parameter S9 = 5'b01001;
    parameter S10 = 5'b01010;
    parameter S11 = 5'b01011;
    parameter S12 = 5'b01100;
    parameter S13 = 5'b01101;
    parameter S14 = 5'b01110;
    parameter S15 = 5'b01111;
    parameter S16 = 5'b10000;

    input [1:0] bani;
    input reset, clk;
	 
	 output cola;
	 output [1:0] rest;
	 reg cola;
    reg [1:0] rest;
	 
	 reg [5:0] state, nextstate;
	 
	 initial begin 
	     state = S0;
		  nextstate = S0;
		  rest = m0;
		  cola = 0;
    end
	 
	 always @(posedge clk)
	     state = nextstate;
		  
    always @ (state)
	     case(state)
		      S0, S1, S2, S3 : begin
				    rest = m0;
					 cola = 0;
				end
				S4, S5, S6, S7, S8, S9 : begin
				    rest = m0;
					 cola = 1;
				end
				S13, S15, S16 : begin
				    rest = m5;
					 cola = 0;
				end
				S10, S11, S12, S14 : begin
				    rest = b10;
					 cola = 0;
				end
    endcase
		  
    always @(state or reset or clk or bani)
	     if (reset)
		      nextstate = S0;
		  else
            case (state)
				    S0 : begin
					     case(bani) 
						      m5  : nextstate = S1;
								b10 : nextstate = S2;
								b50 : nextstate = S6;
						  endcase
					 end
					 S1 : begin
					     case (bani) 
						      m5  : nextstate = S2;
								b10 : nextstate = S3;
								b50 : nextstate = S7;
						  endcase
					 end
					 S2 : begin
					     case(bani) 
						      m5  : nextstate = S3;
								b10 : nextstate = S4;
								b50 : nextstate = S8;
						  endcase
					 end
					 S3 : begin
					     case(bani) 
						      m5  : nextstate = S4;
								b10 : nextstate = S5;
								b50 : nextstate = S9;
						  endcase
					 end
					 S4 : nextstate = S0;
					 S5 : nextstate = S16;
					 S6 : nextstate = S12;
					 S7 : nextstate = S13;
					 S8 : nextstate = S14;
					 S9 : nextstate = S15;
					 S10 : nextstate = S0;
					 S11 : nextstate = S10;
					 S12 : nextstate = S11;
					 S13 : nextstate = S12;
					 S14 : nextstate = S12;
					 S15 : nextstate = S14;
					 S16 : nextstate = S0;
				    default : 
					     nextstate = S0;
		      endcase
		  

endmodule

module test;
    reg clock, reset;
    reg [1:0] bani;
    wire [1:0] rest;
    
    initial begin
        clock = 0;
        reset = 0;
        bani = 0;
        
         #2 bani = 2'b01;
         #1 bani = 2'b00;
         #12 bani=2'b10;
         #1 bani = 2'b00;
         #5 bani= 2'b11;
        #20;
    end
    
    always begin
        #1 clock = !clock;
    end
    automat ceck (bani, cola, rest, reset, clock);
endmodule
