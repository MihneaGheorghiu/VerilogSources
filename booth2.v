`timescale 1ns/1ns

module right_shift(acout, qrout, qout, acin, qrin, shift, loadac, loadqr, clear, clock);
   input [23 : 0] acin, qrin;
   input shift, loadac, loadqr, clear, clock;
   output [23 : 0] acout, qrout;
   output qout;
   reg [23 : 0] acout, qrout;
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
           //{acout, qrout, qout} = {acout, qrout, qout} >> 1;
           qout = qrout[0];
           qrout = {acout[0], qrout[22:1]};
           acout = {acout[22], acout[22:1]};
       end
   end
endmodule

module register(result, val, load, clear, clock);
    input [23 : 0] val;
    input load, clear, clock;
    output [23 : 0] result;
    reg [23 : 0] result;
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
   input [23 : 0] a, b;
   output [23 : 0] result;
   assign result = a + b;
endmodule
   
module negate(result, a);
    input [23 : 0] a;
    output [23 : 0] result;
    assign result = ~a + 1;
endmodule

module mux2to1(out1, in0, in1, sel);
    input [23 : 0] in0, in1;
    input sel;
    output [23 : 0] out1;
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
                counter = 5'd24;
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
    input [23 : 0] x, y;
    input clock, reset;
    output [47 : 0] result;
    
    wire [23 : 0] br, neg_br, term, ac, acout, qrout;
    wire brload, add_sel, shift, loadac, loadqr, clear, qout;
    
    register br_reg(br, y, brload, clear, clock);
    negate minus_br(neg_br, br);
    mux2to1 mux(term, br, neg_br, add_sel);
    sum add(ac, term, acout);
    right_shift acqr(acout, qrout, qout, ac, x, shift, loadac, loadqr, clear, clock);
    fsm state(qrout[0], qout, brload, add_sel, shift, loadac, loadqr, clear, reset, clock);
    
    assign result = {acout, qrout};
endmodule

module testbooth();
    reg [23 : 0] a, b;
    reg reset, clock;
    wire [47 : 0] prod;
    
    always begin
        #1 clock = !clock;
    end
    
    initial begin
        reset <= 1;
        clock <= 0;
        a <= -24'd7;
        b <= 24'd7;
        #1 reset <= 0;
    end
    
    booth m(prod, a, b, reset, clock);    
endmodule
    