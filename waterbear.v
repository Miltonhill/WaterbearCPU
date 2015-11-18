/* 
 * P. Heinonen 2015
 * FPGA CPU
 *
 * compiler: 
 * Icarus Verilog 0.9.7
 * with GTKWave
 *
 */

module waterbear(
  input clk,
  input rst,
  output[7:0] PC);
  
  // Control Unit steps
  parameter fetch=2'b00;
  parameter decode=2'b01;
  parameter execute=2'b10;
  parameter store=2'b11;
  
  // Control Unit registers
  reg[1:0] current;
  reg[1:0] next;
  
  // mnemonics of opcodes
  parameter LDR = 4'b001;
  parameter STR = 4'b010;
  parameter ADD = 4'b011;
  parameter SUB = 4'b100;
  parameter EQU = 4'b101;
  parameter JMP = 4'b110;
  parameter HLT = 4'b111;
  
  // memory structure
  reg[15:0] PROGMEM[0:255]; // 16 bit wide 256 memory cells
  reg[5:0] DATAMEM[0:255];  // data memory
  reg[5:0] WORKMEM[0:255];  // work memory
  reg[5:0] R1;	 			      // accumulator
  
  // cpu core registers
  reg[15:0] IR;
  reg[7:0] PC;
  
  // instruction register
  reg[4:0] reserved = 5'b00000;
  reg[3:0] op_code;
  reg numbit;
  reg[5:0] operand;
  
  
  // initial cpu boot
  initial begin
    PC = 0;
    current=fetch;
    
    // memory initialization for testbench
    //PROGMEM[n] = {reserved, op_code, numbit, operand}
    // Sample program calculates equation: x=5+7;
    PROGMEM[0] = {reserved, LDR, 1'b1, 6'b000010}; //Load value 5 into R1, mcode: 00000 001 1 000010
    PROGMEM[1] = {reserved, STR, 1'b0, 6'b001101}; //Store value from R1 in memory addr 13
    PROGMEM[2] = {reserved, LDR, 1'b1, 6'b000101}; //Load value 7 into R1
    PROGMEM[3] = {reserved, STR, 1'b0, 6'b001110}; //Store value from R1 in memory addr 14
    PROGMEM[4] = {reserved, LDR, 1'b0, 6'b001101}; //Load value from memory addr 13 into R1
    PROGMEM[5] = {reserved, ADD, 1'b0, 6'b001110}; //Add value from memory addr 14 to R1
    PROGMEM[6] = {reserved, STR, 1'b0, 6'b000010}; //Store value from R1 into memory addr 15
    PROGMEM[7] = {reserved, HLT, 1'b0, 6'b000000}; //Stop execution
  end
  
  // clock cycles
  always @ (clk, rst) begin
    if(rst) begin
      current=fetch;
      PC=0;
    end
    else begin
      
      // Control Unit sequencer
      case(current)
        fetch: begin
          IR = PROGMEM[PC];
          PC = PC +1;
          next=decode;
        end
        
        decode: begin
          next=execute;
          
          op_code= IR[10:7];
          numbit=IR[6:6];
          operand=IR[5:0];
        end
        
        execute: begin
          // execute ALU instructions
          case(op_code)
            LDR: begin
              if(numbit==1) begin
                R1 = operand; // direct assign
              end else begin
                R1 = WORKMEM[operand]; // assign from address
              end
              next=store;
            end
            
            STR: begin
              WORKMEM[operand] = R1;
              next=store;
            end
            
            ADD: begin
              if(numbit==1) begin
                R1=R1+operand;
              end else begin
                R1=R1+WORKMEM[operand];
              end
              next=store;
            end
            
            HLT: begin
              next=execute; // continue loop
            end
            
            // the rest
            default: begin end
          endcase
        end // end of execute
        
        store: begin
          //DATAMEM[    =WORKMEM
          next=fetch;
        end
        
        default: begin end
      endcase
      
      current=next;
    end
  end
endmodule
