// main module FIR
module filterfir(clk,rst,x,dataout);
input [7:0]x;
input clk,rst;
output [9:0]dataout;
wire [7:0]d1,d2,d3;
wire [7:0]m1,m2,m3,m4,m5;
wire [7:0]d11,d12,d13,d14;
parameter h0=3'b101;
parameter h1=3'b100;
parameter h2=3'b011;
parameter h3=3'b010;
parameter h4=3'b001;
assign m1=x>>h0;
dff u2(clk,rst,x,d11);
assign m2=d11>>h1;
assign d1=m1+m2;
dff u4(clk,rst,d11,d12);
assign m3=d12>>h2;
assign d2=d1+m3;
dff u6(clk,rst,d12,d13);
assign m4=d13>>h3;
assign d3=d2+m4;
dff u8(clk,rst,d13,d14);
assign m5=d14>>h4;
assign dataout=d3+m5;
endmodule
