/// Implementation of expmob1 using the description found in
/// "Compact Circuits for Efficient Mobius Transform" 
///  by Subhadeep Banik and Francesco Regazzoni
/// Note: For larger circuits adjust the size of n_blocks, and n_elements_block

/// One stage
module stage 
  #(parameter N=256,
    parameter log2_N=8,
    parameter stage_number=0)

   (input wire [0:N-1]  inputs, 
    output wire [0:N-1]	outputs);

   // stage 0 has one block
   localparam n_blocks  = 32'b1 << stage_number;
   localparam n_elements_block = 32'b1 * (N / (2*n_blocks));
   //localparam start_index = 32'b0;
   //$display("Stage %0d | Block %0d out of %0d | j = %0d | start_index = %0d", stage_number, k, n_blocks, j, start_index);

   // Butterfly
   genvar k;
   genvar j;
   generate
     for ( k = 0; k < n_blocks; k = k + 1) begin
	 localparam start_index = (32'b1) *  k * (n_elements_block * 2);
	 
	   for (j = 0; j < n_elements_block; j = j +1) begin

	     assign outputs[start_index + j] = inputs[start_index + j];
	     assign outputs[start_index + j + n_elements_block] = inputs[start_index + j] ^ inputs[start_index + j + n_elements_block];
/* -----\/----- EXCLUDED -----\/-----
           // Printing intermediate values for debugging
           always @(*) begin 
               if (^outputs !== 1'bx) begin  // skip printing unkown values
                $display("N = %0d, log2(N) = %0d, Stage %0d | Block %0d out of %0d | idx1 = %0d, idx2 = %0d, output = %0b = %0b ⊕ %0b, inp = %0b ",
				         N, log2_N, stage_number, k, n_blocks, start_index + j,  start_index + j + n_elements_block,// j, start_index, start_index + j + n_elements_block
					     outputs[start_index + j + n_elements_block],
					     inputs[start_index + j], inputs[start_index + j + n_elements_block],
					     inputs);
              end // if
           end // always @(*)
 -----/\----- EXCLUDED -----/\----- */
       end // for j
     end // for k
   endgenerate //
endmodule // stage


// 
module expmob1 #(parameter N=256,
		parameter log2_N=8)
   (input wire [0:N-1]	inputs,
    output wire [0:N-1]	outputs);

   
    wire [0:N-1] middle [0:log2_N]; // Create log2(N) arrays each of size N
/* -----\/----- EXCLUDED -----\/-----
   
   initial begin 
      $display("N = %0d, log2(N) = %0d", N, log2_N);
   end
 -----/\----- EXCLUDED -----/\----- */
   
   // do stage 0 manually, other stages by a for loop
   stage #(.N(N), .log2_N(log2_N), .stage_number(0)) s0 (.inputs(inputs), .outputs(middle[0]));

    
    
   genvar n;
   generate
      // Generate log2_N stages, and connect the output of each stage to the
      // to the inputs of the next stage, i.e. stage0 -> stage1 -> ... -> stage_{log2_N-1}
       for (n = 1; n < log2_N; n = n +1) begin
	  stage #(.N(N), .log2_N(log2_N), .stage_number(n)) si (.inputs(middle[n-1]), .outputs(middle[n]));
/* -----\/----- EXCLUDED -----\/-----
          always @(*) begin 
             $display("time = %0d, stage = %0d", $time, n);
          end // always
 -----/\----- EXCLUDED -----/\----- */
       end
   endgenerate
   
   // copy the outputs of the last stage to the output wires
   genvar i;
   generate
      for (i = 0; i < N; i = i + 1) begin
	 assign outputs[i] = middle[log2_N - 1][i];
      end
   endgenerate

endmodule // expmob1


