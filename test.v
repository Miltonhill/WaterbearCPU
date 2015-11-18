module test ();
  reg clk, rst;
  wire [7:0] pc;
  waterbear mycpu (
   	clk, reset, pc
  );
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, test);
  end
  
  initial begin
    clk = 1;
    rst = 1;
    #1 rst = 0;
    #130 rst = 0;
    $stop;
  end
  
  always clk = #1 ~clk;
 endmodule
