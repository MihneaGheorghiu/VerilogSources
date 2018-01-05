`timescale 1ns / 1ps
module inmultire(a,b,rez,clk,load,gata);
parameter n=4,n1=8;
input [n-1:0] a,b;
input clk,load;
output [n1-1:0] rez;
output gata;
reg [n-1:0] regA;
reg [n-1:0] regB;           
reg [n-1:0] regQ;           
reg Qn1,gata;         
reg [n-1:0] count;          
reg advance;             

always @(posedge clk)
 begin
 if(load)
    begin
     regA=0;
     regB=a;
     regQ=b;
     Qn1=0;
     gata=0;
     count=n;
     advance=0;
    end
  else if (!gata) 
   
	case({advance,regQ[0],Qn1})
    3'b010: begin               
          	 regA=regA+~regB+1;
				 advance=1;
				end
    3'b001: begin              
             regA=regA+regB;
             advance=1;
				end
    default: begin                
				  {regA,regQ,Qn1}=({regA,regQ,Qn1}>>1);
				  regA[3]=regA[2];
				  advance=0;
				  count=count-1;
				  if(count==0)
				    gata=1;
				 end
   endcase
 end
  assign rez={regA,regQ};        
endmodule

module test;
parameter n=4,n1=8;
reg [n-1:0] a,b;
reg clk,load;
wire [n1-1:0] rez;
wire gata;
initial begin
		a = 3;
		b = -4;
		clk = 0;
		load = 0;

		#10 load=1;
		#10 load=0;
		
	end
always begin
        #1 clk = !clk;
    end
    inmultire booth (a,b,rez,clk, load,gata);
endmodule


