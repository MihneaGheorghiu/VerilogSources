`timescale 1ns/1ns

module addexp(ea, eb, er);
    input [7 : 0] ea, eb;
    output [7 : 0] er;
    
    assign er = ea + eb - 127;
endmodule

module calcsemn(s1, s2, s);
    input s1, s2;
    output s;
    assign s = s1 ^ s2;
endmodule

module normalise(mantisa, exponent, clk, reset, nmantisa, nexponent);
   input [7 : 0] exponent;
   input [47 : 0] mantisa;
   input reset, clk;
   output [7 : 0] nexponent;
   output [47 : 0] nmantisa;
   reg [7 : 0] nexponent;
   reg [47 : 0] nmantisa;
   
   always @(posedge reset) begin
       nexponent = exponent;
       nmantisa = mantisa;
   end
   
   always @(posedge clk) begin
      if ((nmantisa != 0) && (nexponent != 0) && (nmantisa[45] == 0)) begin
         nmantisa = nmantisa << 1;
         nexponent = nexponent - 1;
      end
   end
endmodule
   

module divceas(clkin, clk1, clk2, clk3);
    input clkin;
    output clk1, clk2, clk3;
    reg clk1, clk2, clk3;
    reg [7 : 0] count;
    
    initial begin
        count = 0;
    end
    
    always @(clkin) begin
        count = count + 1;
        clk1 = (count == 5)?1:0;
        clk2 = (count == 3)?1:0;
        clk3 = (count == 1)?1:0;
        count = count % 154;
    end
endmodule

module mantisareg(in1, out1, load);
    input [22 : 0] in1;
    input load;
    output [22 : 0] out1;
    reg [22 : 0] out1;
    always @(posedge load) begin
        out1 = in1;
    end
endmodule

module exponentreg(in1, out1, load);
    input [7 : 0] in1;
    input load;
    output [7 : 0] out1;
    reg [7 : 0] out1;
    always @(posedge load) begin
        out1 = in1;
    end
endmodule

module semnreg(in1, out1, load);
    input in1;
    input load;
    output out1;
    reg out1;
    always @(posedge load) begin
        out1 = in1;
    end
endmodule

module prodmantisareg(in1, out1, load);
    input [47 : 0] in1;
    input load;
    output [47 : 0] out1;
    reg [47 : 0] out1;
    always @(posedge load) begin
        out1 = in1;
    end
endmodule


module floatmult(a, b, rez, clk);
    input [31 : 0] a, b;
    output [31 : 0] rez;
    input clk;
    wire [22 : 0] am, bm, q; //mantise
    wire [47 : 0] m, n, qq;
    wire [7 : 0] ae, be, p, r, t; // exponenti
    wire as, bs, rs; //semne
    wire clk1, clk2, clk3; // 3 ceasuri
    
    assign q = qq[47 : 23];
    semnreg 
       S1(a[31], as, clk1),
       S2(b[31], bs, clk1),
       SREZ(rs, rez[31], clk3);
       
    exponentreg
       E1(a[30:23], ae, clk1),
       E2(b[30:23], be, clk1),
       E(p, r, clk2),
       EREZ(t, rez[30:23], clk3); 
       
    mantisareg
       M1(a[22:0], am, clk1),
       M2(b[22:0], bm, clk1),
       //M(m[45 : 23], n[45 : 23], clk2),
       //MM(m[22 : 0], n[22 : 0], clk2),
       MREZ(q, rez[22:0], clk3);
       
    prodmantisareg
       M(m, n, clk2);
       
    calcsemn CS(as, bs, rs);
    addexp CE(ae, be, p);
    booth CM(m, {1'b0, am}, {1'b0,bm}, clk1, clk);
    normalise NM(n, r, clk, clk2, qq, t); 
    divceas DC(clk, clk1, clk2, clk3);    
endmodule

module testmult();
    reg [31 : 0] a, b;
    reg clock;
    wire [31 : 0] prod;
    
    always begin
        #1 clock = !clock;
    end
    
    initial begin
        clock <= 0;
        a <= {1'b0, 8'd127, 1'b1, 22'd0};
        b <= {1'b0, 8'd127, 2'b11, 21'd0};
        #154 
        a <= {1'b0, 8'd127, 1'b1, 22'd0};
        b <= {1'b0, 8'd127, 1'b1, 22'd0};

    end
    
    floatmult m(a, b, prod, clock);    
endmodule