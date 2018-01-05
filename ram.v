`timescale 1ns/1ns

module ram(cs1, cs2, rd, wr, addr, mag, clk);
    input cs1, cs2, rd, wr, clk;
    input [6 : 0] addr;
    inout [7 : 0] mag;
    reg [7 : 0] memory [0 : 128];
    reg [7 : 0] memreg;
    
    assign mag = (cs1 && !cs2 && rd) ? memreg : 8'bzzzzzzzz;
    
    always @(posedge clk) begin
        if (!rd && wr) begin
            memory[addr] = mag;
        end
    end
    
    always @(addr or rd or wr) begin
        if (rd) begin
            memreg = memory[addr];
        end
    end
endmodule

module testram();
    reg clk;
    reg cs1, cs2, rd, wr;
    reg [6 : 0] addr;
    wire [7 : 0] mag;
    reg [7 : 0] memreg;
    
    assign mag = (cs1 && !cs2 && !rd && wr) ? memreg : 8'bzzzzzzzz;
    
    initial begin 
       clk = 0;
       cs1 = 1;
       cs2 = 0;
       rd = 0;
       wr = 0;
       addr = 0;
    end
    
    always begin
        #1 clk = !clk;
    end
    
    initial begin
        addr = 7'd10; // scrie 170 la 10
        memreg = 8'b10101010;
        rd = 0;
        wr = 1;
        
        #2 addr = 7'd20; //scrie 255 la 20
        memreg = 8'b11111111;
        rd = 0;
        wr = 1;
        
        #2 addr = 7'd10; //citeste de la 10
        rd = 1;
        wr = 0;
        
        #2 addr = 7'd20; //citeste de la 20
        rd = 1;
        wr = 0;
    end
    
    ram R(cs1, cs2, rd, wr, addr, mag, clk);
endmodule
