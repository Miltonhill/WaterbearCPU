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
  // Classic RISC type pipeline 
  // without MEM stage
  parameter IF=2'b00;
  parameter ID=2'b01;
  parameter EX=2'b10;
  parameter WB=2'b11;
  
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
  reg[15:0] MEM[0:255];      // Main Memory - 16 bit wide 256 memory cells
  reg[5:0]  WORKMEM[0:127];  // ALU intermediate register
  reg[5:0]  DESTMEM[0:127];  // destination register
  reg[5:0]  R1;              // accumulator
  reg[7:0]  PC;              // program counter
  
  reg[7:0]  MAR;             // Memory Address register
  reg[15:0] MDR;             // Memory Data/Buffer Register
  reg[15:0] CIR;             // Current Instruction Register
  
  
  // instruction set structure
  reg[4:0]  reserved = 5'b00000;
  reg[3:0]  op_code  = 0;
  reg       numbit   = 0;
  reg[5:0]  operand  = 0;
  
  
  // initial cpu boot
  initial begin

    // initialize memory and registers
    init_regs();
    
    
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
    /*MEM[0] = {reserved, LDR, 1'b1, 6'b000101}; //Load value 5 into R1, mcode: 00000 001 1 000010
    MEM[1] = {reserved, STR, 1'b0, 6'b001101}; //Store value from R1 in memory addr 13
    MEM[2] = {reserved, LDR, 1'b1, 6'b000111}; //Load value 7 into R1
    MEM[3] = {reserved, STR, 1'b0, 6'b001110}; //Store value from R1 in memory addr 14
    MEM[4] = {reserved, LDR, 1'b0, 6'b001101}; //Load value from memory addr 13 into R1
    MEM[5] = {reserved, ADD, 1'b0, 6'b001110}; //Add value from memory addr 14 to R1
    MEM[6] = {reserved, STR, 1'b0, 6'b000010}; //Store value from R1 into memory addr 15
    MEM[7] = {reserved, HLT, 1'b0, 6'b000000}; //Stop execution
    */
    MEM[0] = {reserved, LDR, 1'b1, 6'b000101}; //set count value to 5
    MEM[1] = {reserved, STR, 1'b0, 6'b001111}; //store count value to address 15
    MEM[2] = {reserved, LDR, 1'b1, 6'b000000}; //initialize count to zero
    MEM[3] = {reserved, EQU, 1'b0, 6'b001111}; //check if count is complete, if yes skip next
    MEM[4] = {reserved, JMP, 1'b1, 6'b000110}; //set PC to 6
    MEM[5] = {reserved, HLT, 1'b0, 6'b000000}; //stop program
    MEM[6] = {reserved, ADD, 1'b1, 6'b000001}; //increment counter in accumulator
    MEM[7] = {reserved, JMP, 1'b1, 6'b000011}; //set PC to 3
  end
  
  // clock cycles
  always @ (clk, rst) begin
    if(rst) begin
      init_regs();
    end
    else begin
      
      // Control Unit Finite state machine
      case(control_unit_current)
        IF: begin
          MAR = PC;
          PC = PC +1;
          MDR = MEM[MAR];
          CIR = MDR;
          control_unit_next=ID;
        end
        
        ID: begin
          control_unit_next=EX;
          InstructionDecoder(CIR, op_code, numbit, operand);
        end
        
        EX: begin
          // execute ALU instructions
          case(op_code)
            LDR: begin
              if(numbit==1) begin
                R1 = operand; // direct assign
              end else begin
                R1 = WORKMEM[operand]; // assign from address
              end
              control_unit_next=WB;
            end
            
            STR: begin
              WORKMEM[operand] = R1;
              control_unit_next=WB;
            end
            
            ADD: begin
              if(numbit==1) begin
                R1=R1+operand;
              end else begin
                R1=R1+WORKMEM[operand];
              end
              control_unit_next=WB;
            end
            
            JMP : begin
              PC=operand;
              control_unit_next=WB;
            end
            
            EQU: begin
              if(R1 == WORKMEM[operand]) begin
                PC=PC+1;
              end
              control_unit_next=WB;
            end
                
            HLT: begin
              control_unit_next=EX; // continue loop
            end
            
            default: begin end
          endcase
        end // end of execute ALU instructions
        
        WB: begin
          // Loop is synthesizable:
          // http://www.lcdm-eng.com/papers/snug13_SNUG-SV-2013_Synthesizable-SystemVerilog_paper.pdf
          for (i=0; i<127; i=i+1 ) begin
            DESTMEM[i] <= WORKMEM[i];
          end
          
          control_unit_next=IF;
        end
        
        default: begin end
      endcase
      
      control_unit_current=control_unit_next;
    end
  end

  // task to initialize registers and memory
  task init_regs;
  begin
    PC                    = 0;
    R1                    = 0;
    MDR                   = 0;
    MAR                   = 0;
    CIR                   = 0;
    //WORKMEM             = 0; //{0,128'h80};
    //DESTMEM             = 0; //{0,128'h80};
    control_unit_current  = IF;
    numbit                = 0;
    operand               = 0;
    op_code               = 0;
    reserved              = 0;
  end
  endtask

  // in execute, Control Unit
  task InstructionDecoder;
    input[15:0] CIR;
    output[3:0] op_code;
    output numbit;
    output[5:0] operand;
    begin
      op_code= CIR[10:7];
      numbit=CIR[6:6];
      operand=CIR[5:0];
    end
  endtask
    
endmodule


// For the test 4 core test
module multicore(
  input clk,
  input rst,
  output[7:0] PC);
  
  waterbear core1(clk, reset, PC);
  waterbear core2(clk, reset, PC);
  waterbear core3(clk, reset, PC);
  waterbear core4(clk, reset, PC);
  
endmodule
