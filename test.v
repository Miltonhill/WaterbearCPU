// runtest: 
// iverilog test.v waterbear.v -o cpusim
// vpp cpusim
// gtkwave &
`timescale 1ns/10ps
module test ();
  reg clk, rst;
  wire [7:0] pc;
  waterbear cores (
    clk, reset, pc
  );
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, test);
  end
  
  //always #5 clk = ~clk;
  
  initial begin
    clk = 1;
    rst = 0;
    #1 rst = 0;
    #1300 rst = 0;
    $finish;
  end
  
  always clk = #1 ~clk;
 endmodule