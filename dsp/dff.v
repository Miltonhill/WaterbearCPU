module dff(clk,rst,d,q);// sub module d flipflop
input clk,rst;
input [7:0]d;
output [7:0]q;
reg [7:0]q;
always@(posedge clk)
begin
if(rst==1)
begin
q=0;
end
else
begin
q=d;
end
end

endmodule
