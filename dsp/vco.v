/*
 * Voltage Controlled Oscillator
 */
 
`include "constants.h"
`include "discipline.h"
`define PI 3.141592653589793284686433832795028841971
module VCO(vin,vout);
 input vin;
 output vout;
 electrical vin, vout;
parameter real vout_center_level = 0;
 parameter real vout_amp=5;
 parameter real center_freq=10000000; //when vin @DC
in rad/s
eq;
p/2)
phi));
parameter real Hz_volt_gain=8000000;
 real Wc; //actual center frequency
 real phi; //phi=Wc*t
 real delt_phi;
 real inst_freq;
 integer CycleCount;
analog begin
 @(initial_step) begin
 Wc=2*`PI*center_fr
end
 phi=Wc*$abstime;
 CycleCount=phi/(2*`PI);
 phi=phi-(CycleCount*2*`PI);
 delt_phi=2*`PI*idt(V(vin),0)*Hz_volt_gain;
 V(vout) <+ (vout_center_level + (vout_am
 *sin(phi+delt_
 inst_freq=center_freq+V(vin)*Hz_volt_gain; //update frequency

 $bound_step(0.04/inst_freq);
end
endmodule
