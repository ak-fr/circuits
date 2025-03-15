/// Implementation of expmob2 using the description found in
/// "Compact Circuits for Efficient Mobius Transform" 
///  by Subhadeep Banik and Francesco Regazzoni
/// This circuit is clocked 
/// Note: For larger circuits adjust the size of n_blocks, and n_elements_block


// Test bench in hdlbits website
module top_module ();
   localparam N = 16;
   localparam log2_N = 4;
   // bit index number 0
   reg [0:N-1] a;
   reg [0:N-1] Ma;
   reg	       clk = 0;
   
   initial begin 
      $display("N = %0d, log2(N) = %0d", N, log2_N);
   end
   

   // Instantiate mobius and call the instance M
   expmob2 #(.N(N), .log2_N(log2_N))
   M
     (.clk(clk), .inputs(a), .outputs(Ma));
   

   initial begin // 
      a = 'b1100_0000_0000_0000;
      //a = 'b1111_0000_0010_1010;
      // delay of 100 time units
      //#100 a = 'b1111_0000_0000_0000;
      //#100 a = 'b0000_0000_0000_0000;
      // Wait sufficiently enough time
      // #10000000  $display("Time: %0t | a = %b | Ma = %b", $time, a, Ma);
      #1000 $stop; // end of simulation after 1000 units of time
   end

   // Whenever a change of a or Ma occur display both values with the time
   initial begin 
      $monitor("Time: %0t | a = %b | Ma = %b", $time, a, Ma);
   end


   // Also update the clock each time unit
   always #1 clk = ~clk;
endmodule



// Permute module
module Permute #(parameter N=32) (input wire [0:N-1]  inputs,
				  output wire [0:N-1] outputs);
   genvar i;
   generate
      for (i = 0; i < (N>>1);  i = i + 1) begin

	 assign outputs[2*i] = inputs[i];
	 assign outputs[2*i + 1] = inputs[i + (N>>1)];
/* -----\/----- EXCLUDED -----\/-----
	 always @(*) begin
            $display("Permute: T = %0t, N = %0d, inputs[%0d] = %0b, outputs[%0d] = %0b, inputs[%0d] = %0b, outputs[%0d] = %0b", 
                     $time, N , i, inputs[i], 2*i,  outputs[2*i], 2*i + 1, inputs[2*i+1], i + (N>>1), outputs[i + (N>>1)]);
	 end
 -----/\----- EXCLUDED -----/\----- */
      end
   endgenerate 
endmodule // Permute


// First stage butterfly
module Butterfly
  #(parameter N=32)
   (input wire [0:N-1]  inputs,
     output wire [0:N-1] outputs);
   
   genvar i;
   generate
      for (i = 0; i < (N>>1);  i = i + 1) begin
	 assign outputs[i] = inputs[i];
	 assign outputs[i + (N>>1)] = inputs[i + (N>>1)] ^ inputs[i];
      end
   endgenerate
   

endmodule // Butterfly


module Round
  #(parameter N=32)
   (input wire [0:N-1]  inputs,
     output wire [0:N-1] outputs);

   wire [0:N-1] middle;
   Butterfly #(.N(N)) Bn (.inputs(inputs), .outputs(middle));
   Permute   #(.N(N)) Pn (.inputs(middle), .outputs(outputs));
   
endmodule // Round






module expmob2
  #(parameter N=32, parameter log2_N=5)
   (input clk,
     input wire [0:N-1]	 inputs,
     output wire [0:N-1] outputs);

   reg [0:N-1] mem_inputs;
   reg [0:N-1] mem_outputs;

   integer     n = 1;
   reg [0:0]   init = 0;
   // integer ncycles = 0; 

   // For each clock cyle execute one layer of mobius
   Round #(.N(N)) R (.inputs(mem_inputs), .outputs(mem_outputs));
   assign outputs = mem_outputs; // the outputs are


   
   // Count the number of rounds, not sure how to end the module
   always @(posedge clk) begin
      // ncycles = ncycles + 1;
      if (~init) begin    // Copy the input only once
	 mem_inputs <= inputs;
	 init = 1;
      end

      else if ( (n < log2_N)  && init  ) begin
         n = n + 1;
         mem_inputs <= mem_outputs;
      end  // end if-else  

   end // end always
   

   /* -----\/----- EXCLUDED -----\/-----
    always @(*) begin 
    $display("T = %0t, N = %0d, log2(N) = %0d, Stage = %0d | inputs = %0b | mem_inputs = %0b, mem_outputs = %0b", $time, N, log2_N, n, inputs, mem_inputs, mem_outputs);
   end
    -----/\----- EXCLUDED -----/\----- */
   
   
endmodule // expmob2

