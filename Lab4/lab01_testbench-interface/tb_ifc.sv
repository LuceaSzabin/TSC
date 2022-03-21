/***********************************************************************
 * A SystemVerilog testbench for an instruction register; This file
 * contains the interface to connect the testbench to the design
 **********************************************************************/
interface tb_ifc (input logic clk);
  //timeunit 1ns/1ns;

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  // ADD CODE TO DECLARE THE INTERFACE SIGNALS
  clocking cb @(posedge clk);
	  input logic          load_en;
	  input logic          reset_n;
	  input opcode_t       opcode;
	  input operand_t      operand_a, operand_b;
	  input address_t      write_pointer, read_pointer;
	  output instruction_t  instruction_word;
  endclocking
  
  modport TEST (clocking cb);

endinterface: tb_ifc

