---
title: Waterbear
description: Generic four stage pipeline FPGA CPU
author: P. Heinonen
tags: test, FPGA, Verilog, CPU
colors: light yellow
created:  2015 Nov 18
modified: 2011 Nov 21

---

Waterbear
=========

## Generic four stage pipeline FPGA CPU

Waterbear is very basic CPU for testing and studying CPU internals, common 
architecture, pipelining, optimization and testing FPGA capability and features.

Pipeline is not complete but Waterbear perform one stage on each clock cycle. Stages are:

    parameter IF=2'b00;  // Instruction FETCH
    parameter ID=2'b01;  // Instruction DECODE
    parameter EX=2'b10;  // Execute in ALU
    parameter WB=2'b11;  // Writeback to memory

<img src="http://blog.shamess.info/wp-content/uploads/2008/12/fetch-execute-cycle.png" width=250px</img>  


  

Waterbear uses custom made Instruction set:

                              +----------+--------+--------+---------+
        INSTRUCTION SET       |          |        |        |         |
        STRUCTURE             | RESERVED | OPCODE | NUMBIT | OPERAND |
                              |          |        |        |         |
                              +----------+--------+--------+---------+
                                 15-11      10-7      6        5-0  


Seven opcodes are currently supported with mnemonics:

    parameter LDR = 4'b001;    // load
    parameter STR = 4'b010;    // store
    parameter ADD = 4'b011;    // add
    parameter SUB = 4'b100;    // substract
    parameter EQU = 4'b101;    // compare equal
    parameter JMP = 4'b110;    // jump
    parameter HLT = 4'b111;    // halt

    Example assembly code: LDR 1 5 loads valur 5 into register
    and it is decoded to: 00000 001 1 000010

When Waterbear CPU starts in simulation it executes sample program which calculates equation: x=5+7:

    MEM[0] = {reserved, LDR, 1'b1, 6'b000101}; //Load value 5 into R1
    MEM[1] = {reserved, STR, 1'b0, 6'b001101}; //Store value from R1 in memaddr 13
    MEM[2] = {reserved, LDR, 1'b1, 6'b000111}; //Load value 7 into R1
    MEM[3] = {reserved, STR, 1'b0, 6'b001110}; //Store value from R1 in memaddr 14
    MEM[4] = {reserved, LDR, 1'b0, 6'b001101}; //Load value from memory addr 13 into R1
    MEM[5] = {reserved, ADD, 1'b0, 6'b001110}; //Add value from memory addr 14 to R1
    MEM[6] = {reserved, STR, 1'b0, 6'b000010}; //Store value from R1 into memaddr 15
    MEM[7] = {reserved, HLT, 1'b0, 6'b000000}; //Stop execution

    Program is stored in Main Memory. Memory contains 256 memorycells 
    which are each 16-bit wide.

Sample program Time diagram with signals:

![Timeline](https://raw.githubusercontent.com/Miltonhill/WaterbearCPU/master/tests/cpu.png)

At diagram can be seen that R1 register final value is 0xC which is output of sample program x=5+7.



