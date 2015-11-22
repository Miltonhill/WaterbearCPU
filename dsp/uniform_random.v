`include "constants.h"
`include "discipline.h"
// To generate random integer numbers that are evenly distributed
// Uniform-Distributed Random-Bit Generator
module Uniform_Random(in, out);
 input in;
 output out;
 electrical in, out;
 parameter integer start_range = -2.5;
 integer seed, end_range;
 real ran_num;
 analog begin
 @(initial_step) begin
 seed = 2;
 end_range = 2.5;
 end
 ran_num = $dist_uniform(seed, start_range, end_range);
 V(out) <+ V(in)+ran_num;
 end
endmodule
