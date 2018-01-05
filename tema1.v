`timescale 1ns/1ns



module shiftare(acout, qrout, qout, acin, qrin, shift, loadac, loadqr, clear, clock);
   input [22 : 0] acin, qrin;
   input shift, loadac, loadqr, clear, clock;
   output [22 : 0] acout, qrout;
   output qout;
   reg [22 : 0] acout, qrout;
   reg qout;
   
   always @(posedge clock) begin
       if (clear) begin
           qout = 0;
           acout = 0;
           qrout = 0;
       end
       if (loadac) begin
           acout = acin;
       end
       if (loadqr) begin
           qrout = qrin;
           qout = 0;
       end 
       if (shift) begin
          
           qout = qrout[0];
           qrout = {acout[0], qrout[22:1]};
           acout = {acout[22], acout[22:1]};
       end
   end
endmodule

module register(result, val, load, clear, clock);
    input [22 : 0] val;
    input load, clear, clock;
    output [22 : 0] result;
    reg [22 : 0] result;
    always @(posedge clock) begin
        if (clear) begin
            result = 0;
        end
        if (load) begin
            result = val;
        end
    end
endmodule

module sum(result, a, b);
   input [22 : 0] a, b;
   output [22 : 0] result;
   assign result = a + b;
endmodule
   
module negare(result, a);
    input [22 : 0] a;
    output [22 : 0] result;
    assign result = ~a + 1;
endmodule

module mux2to1(out1, in0, in1, sel);
    input [22 : 0] in0, in1;
    input sel;
    output [22 : 0] out1;
    assign out1 = sel?in1:in0;
endmodule

module fsm(qn, qnn, brload, add_sel, shift, loadac, loadqr, clear, reset, clock);
    input qn, qnn, reset, clock;
    output brload, add_sel, shift, loadac, loadqr, clear;
    reg brload, add_sel, shift, loadac, loadqr, clear;
    reg [3 : 0] state, nstate;
    reg [4 : 0] counter;
    
    always @(posedge clock) begin
       state = nstate;
    end
    
    always @(posedge reset) begin
        nstate = 4'd0;
    end
    
    always @(state) begin
        case (state)
            4'd0 : begin
                counter = 5'd23;
                clear = 1;
                brload = 1;
                add_sel = 0;
                shift = 0;
                loadac = 0;
                loadqr = 1;
                nstate = 4'd1;
            end
            4'd1 : begin
                clear = 0;
                brload = 0;
                add_sel = 0;
                shift = 0;
                loadac = 0;
                loadqr = 0;
                nstate = 4'd6;
            end
            
            4'd6 : begin
                clear = 0;
                brload = 0;
                add_sel = 0;
                shift = 0;
                loadac = 0;
                loadqr = 0;
                if (qn) begin
                    if (qnn) begin
                        nstate = 4'd4;
                    end else begin
                        nstate = 4'd2;
                    end
                end else begin
                    if (qnn) begin
                        nstate = 4'd3;
                    end else begin
                        nstate = 4'd4;
                    end
                end
            end
            
            4'd2 : begin
                clear = 0;
                brload = 0;
                add_sel = 1;
                shift = 0;
                loadac = 1;
                loadqr = 0;
                nstate = 4'd4;
            end
            4'd3 : begin
                clear = 0;
                brload = 0;
                add_sel = 0;
                shift = 0;
                loadac = 1;
                loadqr = 0;
                nstate = 4'd4;
            end
            
            4'd4 : begin
                clear = 0;
                brload = 0;
                add_sel = 0;
                shift = 1;
                loadac = 0;
                loadqr = 0;
                counter = counter - 1;
                if (counter == 0) begin
                    nstate = 4'd5;
                end else begin
                    nstate = 4'd1;
                end 
            end
            
            4'd5 : begin
                clear = 0;
                brload = 0;
                add_sel = 0;
                shift = 0;
                loadac = 0;
                loadqr = 0;
                nstate = 4'd5;
            end
        endcase
    end
endmodule

module booth(result, x, y, reset, clock);
    input [22 : 0] x, y;
    input clock, reset;
    output [45 : 0] result;
    
    wire [22 : 0] br, neg_br, term, ac, acout, qrout;
    wire brload, add_sel, shift, loadac, loadqr, clear, qout;
    
    register br_reg(br, y, brload, clear, clock);
    negare minus_br(neg_br, br);
    mux2to1 mux(term, br, neg_br, add_sel);
    sum add(ac, term, acout);
    shiftare acqr(acout, qrout, qout, ac, x, shift, loadac, loadqr, clear, clock);
    fsm state(qrout[0], qout, brload, add_sel, shift, loadac, loadqr, clear, reset, clock);
    
    assign result = {acout, qrout};
endmodule


    
    booth m(prod, a, b, reset, clock);    
endmodule
    
module addexp(ea, eb, er);
    input [7 : 0] ea, eb;
    output [7 : 0] er;
    
    assign er = ea + eb - 127;
endmodule

module getsemn(s1, s2, s);
    input s1, s2;
    output s;
    assign s = s1 ^ s2;
endmodule

module normalizare(mantisa, exponent, clk, reset, nmantisa, nexponent);
   input [7 : 0] exponent;
   input [45 : 0] mantisa;
   input reset, clk;
   output [7 : 0] nexponent;
   output [45 : 0] nmantisa;
   reg [7 : 0] nexponent;
   reg [45 : 0] nmantisa;
   
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
        count = count % 152;
    end
endmodule

module reg_mantisa(in1, out1, load);
    input [22 : 0] in1;
    input load;
    output [22 : 0] out1;
    reg [22 : 0] out1;
    always @(posedge load) begin
        out1 = in1;
    end
endmodule

module reg_exp(in1, out1, load);
    input [7 : 0] in1;
    input load;
    output [7 : 0] out1;
    reg [7 : 0] out1;
    always @(posedge load) begin
        out1 = in1;
    end
endmodule

module reg_semn(in1, out1, load);
    input in1;
    input load;
    output out1;
    reg out1;
    always @(posedge load) begin
        out1 = in1;
    end
endmodule

module inmultire(a, b, rez, clk);
    input [31 : 0] a, b;
    output [31 : 0] rez;
    input clk;
    wire [22 : 0] am, bm, q; 
    wire [45 : 0] m, n, qq;
    wire [7 : 0] ae, be, p, r, t; 
    wire as, bs, rs; 
    wire clk1, clk2, clk3; 
    
    assign q = qq[45 : 23];
    reg_semn 
       S1(a[31], as, clk1),
       S2(b[31], bs, clk1),
       SREZ(rs, rez[31], clk3);
       
    reg_exp
       E1(a[30:23], ae, clk1),
       E2(b[30:23], be, clk1),
       E(p, r, clk2),
       EREZ(t, rez[30:23], clk3); 
       
    reg_mantisa
       M1(a[22:0], am, clk1),
       M2(b[22:0], bm, clk1),
       M(m[45 : 23], n[45 : 23], clk2),
       MM(m[22 : 0], n[22 : 0], clk2),
       MREZ(q, rez[22:0], clk3);
       
    getsemn CS(as, bs, rs);
    addexp CE(ae, be, p);
    booth CM(m, am, bm, clk1, clk);
    normalizare NM(n, r, clk, clk2, qq, t); 
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
        a <= {1'b0, 8'd129, 23'd15};
        b <= {1'b0, 8'd130, 23'd51};
    end
    
    inmultire m(a, b, prod, clock);    
endmodule