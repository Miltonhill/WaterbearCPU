/* 
 * P. Heinonen 2015
 * FPGA CPU
 *
 * compiler: 
 * Icarus Verilog 0.9.7
 * with GTKWave
 *
 */
`timescale 1ns/10ps
module waterbear(
  input clk,
  input rst,
  output[7:0] PC);
  
  // Control Unit steps
  parameter fetch=2'b00;
  parameter decode=2'b01;
  parameter execute=2'b10;
  parameter store=2'b11;
  
  // index for memcopy in store step
  integer i;
  
  // Control Unit registers
  reg[1:0]  control_unit_current;
  reg[1:0]  control_unit_next;
  
  // mnemonics of opcodes
  parameter LDR = 4'b001;    // load
  parameter STR = 4'b010;    // store
  parameter ADD = 4'b011;    // add
  parameter SUB = 4'b100;    // substract
  parameter EQU = 4'b101;    // compare equal
  parameter JMP = 4'b110;    // jump
  parameter HLT = 4'b111;    // halt
  
  // memory structure
  reg[15:0] RAM[0:255];      // 16 bit wide 256 memory cells
  reg[5:0]  WORKMEM[0:127];  // ALU intermediate register
  reg[5:0]  DESTMEM[0:127];  // destination register
  reg[5:0]  R1;              // accumulator
  reg[15:0] IR;              // instruction register
  reg[7:0]  PC;              // program counter
  
  // instruction set structure
  reg[4:0]  reserved = 5'b00000;
  reg[3:0]  op_code;
  reg       numbit;
  reg[5:0]  operand;
  
  
  // initial cpu boot
  initial begin
    PC = 0;
    R1=0;
    control_unit_current=fetch;
    
    /*
      RAM memory layout contains 256 memorycells which are 16-bit wide
      to store instruction set.
      
                              ------5--------4--------1--------6------
        INSTRUCTION SET       |          |        |        |         |
        STRUCTURE             | RESERVED | OPCODE | NUMBIT | OPERAND |
                              |          |        |        |         |
                              ----------------------------------------
    */
    
    // memory initialization for testbench
    // Sample program calculates equation: x=5+7;
    RAM[0] = {reserved, LDR, 1'b1, 6'b000101}; //Load value 5 into R1, mcode: 00000 001 1 000010
    RAM[1] = {reserved, STR, 1'b0, 6'b001101}; //Store value from R1 in memory addr 13
    RAM[2] = {reserved, LDR, 1'b1, 6'b000111}; //Load value 7 into R1
    RAM[3] = {reserved, STR, 1'b0, 6'b001110}; //Store value from R1 in memory addr 14
    RAM[4] = {reserved, LDR, 1'b0, 6'b001101}; //Load value from memory addr 13 into R1
    RAM[5] = {reserved, ADD, 1'b0, 6'b001110}; //Add value from memory addr 14 to R1
    RAM[6] = {reserved, STR, 1'b0, 6'b000010}; //Store value from R1 into memory addr 15
    RAM[7] = {reserved, HLT, 1'b0, 6'b000000}; //Stop execution
  end
  
  // clock cycles
  always @ (clk, rst) begin
    if(rst) begin
      control_unit_current=fetch;
      PC=0;
    end
    else begin
      
      // Control Unit Finite state machine
      case(control_unit_current)
        fetch: begin
          IR = RAM[PC];
          PC = PC +1;
          control_unit_next=decode;
        end
        
        decode: begin
          control_unit_next=execute;
          
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
              control_unit_next=store;
            end
            
            STR: begin
              WORKMEM[operand] = R1;
              control_unit_next=store;
            end
            
            ADD: begin
              if(numbit==1) begin
                R1=R1+operand;
              end else begin
                R1=R1+WORKMEM[operand];
              end
              control_unit_next=store;
            end
            
            HLT: begin
              control_unit_next=execute; // continue loop
            end
            
            
            default: begin end
          endcase
        end // end of execute
        
        store: begin
          // Loop is synthesizable:
          // http://www.lcdm-eng.com/papers/snug13_SNUG-SV-2013_Synthesizable-SystemVerilog_paper.pdf
          for (i=0; i<127; i=i+1 ) begin
            DESTMEM[i] <= WORKMEM[i];
          end
          
          control_unit_next=fetch;
        end
        
        default: begin end
      endcase
      
      control_unit_current=control_unit_next;
    end
  end
endmodule
