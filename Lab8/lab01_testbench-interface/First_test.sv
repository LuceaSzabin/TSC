class First_test;

	  int numberOfTransactions = 100;
	  int errorCount;
    virtual tb_ifc.TEST lab2_if;
    
    covergroup my_func_coverage;
      coverpoint lab2_if.cb.operand_a {
        bins op_a_values_pos[] = {[1:15]};
        bins op_a_zero = {0};
        bins op_a_values_neg[] = {[-15:-1]};
      }
      coverpoint lab2_if.cb.operand_b {
        bins op_a_values_pos[] = {[0:15]};
      }
      coverpoint lab2_if.cb.opcode {
        bins op_a_values_pos[] = {[0:7]};
      }
    endgroup

    function new(virtual tb_ifc.TEST lab_if);
        lab2_if = lab_if;
        my_func_coverage = new();
		    this.errorCount = 0;
    endfunction


    task run();
	  // Get the number of transactions
	  if (!$value$plusargs("Number of transactions=%0d", numberOfTransactions)) begin
		numberOfTransactions = 50;
	  end
		
      $display("\n\n***********************************************************");
      $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
      $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
      $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
      $display(    "***********************************************************");

      $display("First header");
    
      $display("\nReseting the instruction register...");
      lab2_if.cb.write_pointer <= 5'h00;         // initialize write pointer
      lab2_if.cb.read_pointer  <= 5'h1F;         // initialize read pointer
      lab2_if.cb.load_en       <= 1'b0;          // initialize load control line
      lab2_if.cb.reset_n       <= 1'b0;          // assert reset_n (active low)
      repeat (2) @(posedge lab2_if.cb);     // hold in reset for 2 clock cycles
      lab2_if.cb.reset_n       <= 1'b1;          // deassert reset_n (active low)

      $display("\nWriting values to register stack...");
      @(posedge lab2_if.cb) lab2_if.cb.load_en <= 1'b1;  // enable writing to register

      repeat (numberOfTransactions) begin
        @(posedge lab2_if.cb) randomize_transaction;
        @(negedge lab2_if.cb) print_transaction;
        my_func_coverage.sample();
      end
      @(posedge lab2_if.cb) lab2_if.cb.load_en <= 1'b0;  // turn-off writing to register

      // read back and display same three register locations
      $display("\nReading back the same register locations written...");
      for (int i=0; i<numberOfTransactions; i++) begin
        // later labs will replace this loop with iterating through a
        // scoreboard to determine which addresses were written and
        // the expected values to be read back
        @(posedge lab2_if.cb) lab2_if.cb.read_pointer <= i;
        @(negedge lab2_if.cb) print_results;
      end

      @(posedge lab2_if.cb);
      $display("\n***********************************************************");
      $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
      $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
      $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
      $display(  "***********************************************************\n");
    
		// Error evaluation
	  if (this.errorCount == 0) begin
	    $display("Test passed");
	  end else if (this.errorCount > 0) begin
	    $display("Test not passed (%0d errors)", this.errorCount);
	  end
	  
	  $finish;
	endtask

    function void randomize_transaction;
      // A later lab will replace this function with SystemVerilog
      // constrained random values
      //
      // The stactic temp variable is required in order to write to fixed
      // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
      // write_pointer values in a later lab
      //
      static int temp = 0;
      lab2_if.cb.operand_a     <= $signed($urandom())%16;                 // between -15 and 15
      lab2_if.cb.operand_b     <= $unsigned($urandom())%16;            // between 0 and 15
      lab2_if.cb.opcode        <= opcode_t'($unsigned($urandom())%8);  // between 0 and 7, cast to opcode_t type
                                    // look in instr_register_pkg
      lab2_if.cb.write_pointer <= temp++;
    endfunction: randomize_transaction

    function void print_transaction;
      $display("Writing to register location %0d: ", lab2_if.cb.write_pointer);
      $display("  lab2_if.opcode = %0d (%s)", lab2_if.cb.opcode, lab2_if.cb.opcode.name);
      $display("  lab2_if.operand_a = %0d",   lab2_if.cb.operand_a);
      $display("  lab2_if.operand_b = %0d\n", lab2_if.cb.operand_b);
    endfunction: print_transaction

    function void print_results;
      $display("Read from register location %0d: ", lab2_if.cb.read_pointer);
      $display("  lab2_if.opcode = %0d (%s)", lab2_if.cb.instruction_word.opc, lab2_if.cb.instruction_word.opc.name);
      $display("  lab2_if.operand_a = %0d",   lab2_if.cb.instruction_word.op_a);
      $display("  lab2_if.operand_b = %0d", lab2_if.cb.instruction_word.op_b);
      $display("  lab2_if.result    = %0d\n", lab2_if.cb.instruction_word.result);
     case (lab2_if.cb.instruction_word.opc.name)
      "PASSA" : begin
        if (lab2_if.cb.instruction_word.result != lab2_if.cb.instruction_word.op_a) begin
          $error("PASSA operation error: Expected result = %0d Actual result = %0d\n", lab2_if.cb.instruction_word.op_a, lab2_if.cb.instruction_word.result);
          errorCount += 1;
        end
      end
      "PASSB" : begin
        if (lab2_if.cb.instruction_word.result != lab2_if.cb.instruction_word.op_b) begin
          $error("PASSB operation error: Expected result = %0d Actual result = %0d\n", lab2_if.cb.instruction_word.op_b, lab2_if.cb.instruction_word.result);
          errorCount += 1;
        end
      end
      "ADD" : begin
        if (lab2_if.cb.instruction_word.result != $signed(lab2_if.cb.instruction_word.op_a + lab2_if.cb.instruction_word.op_b)) begin
          $error("ADD operation error: Expected result = %0d Actual result = %0d\n", $signed(lab2_if.cb.instruction_word.op_a + lab2_if.cb.instruction_word.op_b), lab2_if.cb.instruction_word.result);
          errorCount += 1;
        end
      end
      "SUB" : begin
        if (lab2_if.cb.instruction_word.result != $signed(lab2_if.cb.instruction_word.op_a - lab2_if.cb.instruction_word.op_b)) begin
          $error("SUB operation error: Expected result = %0d Actual result = %0d\n", $signed(lab2_if.cb.instruction_word.op_a - lab2_if.cb.instruction_word.op_b), lab2_if.cb.instruction_word.result);
          errorCount += 1;
        end
      end
      "MULT" : begin
        if (lab2_if.cb.instruction_word.result != $signed(lab2_if.cb.instruction_word.op_a * lab2_if.cb.instruction_word.op_b)) begin
          $error("MULT operation error: Expected result = %0d Actual result = %0d\n", $signed(lab2_if.cb.instruction_word.op_a * lab2_if.cb.instruction_word.op_b), lab2_if.cb.instruction_word.result);
          errorCount += 1;
        end
      end
      "DIV" : begin
        if (lab2_if.cb.instruction_word.result != $signed(lab2_if.cb.instruction_word.op_a / lab2_if.cb.instruction_word.op_b)) begin
          $error("DIV operation error: Expected result = %0d Actual result = %0d\n", $signed(lab2_if.cb.instruction_word.op_a / lab2_if.cb.instruction_word.op_b), lab2_if.cb.instruction_word.result);
          errorCount += 1;
        end
      end
      "MOD" : begin
        if (lab2_if.cb.instruction_word.result != $signed(lab2_if.cb.instruction_word.op_a % lab2_if.cb.instruction_word.op_b)) begin
          $error("MOD operation error: Expected result = %0d Actual result = %0d\n", $signed(lab2_if.cb.instruction_word.op_a % lab2_if.cb.instruction_word.op_b), lab2_if.cb.instruction_word.result);
          errorCount += 1;
        end
      end
     endcase
    endfunction: print_results
  
 endclass
