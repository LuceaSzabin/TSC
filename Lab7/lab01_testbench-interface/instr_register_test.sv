/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/
 
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
`include "First_test.sv"
module instr_register_test(tb_ifc.TEST lab2_if);

//initial begin
  initial begin
    //run();
    First_test fs;
    fs = new(lab2_if);
    //fs.lab2_if = lab2_if;
    fs.run();
  end

endmodule: instr_register_test
