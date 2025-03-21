// compute (a >>> k) when the number of bits N = 2^n

module top_module();
   localparam N = 32;
   localparam log2_N = 5;
   reg [0:N-1] a;
   reg [0:N-1] rot_a;
    reg [0:log2_N - 1] k;
   

   initial begin
      $display("N=%0d, log2(N)=%0d", N, log2_N);
   end
   
   rot #(.N(N), .log2_N(log2_N))  ROT
     (.bits(a), .k(k), .rotated_bits(rot_a));


   initial begin
      k = 4;
      a = 'b1000_0000_0000_0000_1000_0000_0000_0000;
      #100 $stop;

   end

   initial begin
      $monitor("Time: %0t | a = %b | rot(a, %0d) = %b", $time, a, k, rot_a);
   end
endmodule // top_module

   


/// One stage
module stage 
  #(parameter N=32,
    parameter log2_N=5,
    parameter stage_number=0)

   (input wire [0:N-1]	inputs,
    input wire mux_sel,
    output wire [0:N-1]	outputs);

   // stage 0 has one block
   localparam n_blocks  = 32'b1 << stage_number;
   // localparam n_elements_block = 32'b1 * (N / (2*n_blocks));
    localparam stage_shift  = 32'b1 * (N / (2*n_blocks) ); //32'b1 << stage_number;

   //localparam start_index = 32'b0;
   //$display("Stage %0d | Block %0d out of %0d | j = %0d | start_index = %0d", stage_number, k, n_blocks, j, start_index);


   // Indexing is simpler than butterfly, just use modulo log2_N!
/* -----\/----- EXCLUDED -----\/-----
   // Butterfly
   genvar k;
   generate
     for ( k = 0; k < N; k = k + 1) begin
         assign outputs[k] = mux_sel ? inputs[(k - stage_shift)%N] :  inputs[k] ;
           // Printing intermediate values for debugging

           always @(*) begin 
               if (^outputs !== 1'bx) begin  // skip printing unkown values
                 $display("N = %0d, log2(N) = %0d, Stage %0d | shift = %0d | mux_sel = %b | inp[%0d] = %b, inp[%0d] = %b, out[%0d] = %b", 
                          N, log2_N, stage_number, stage_shift, mux_sel, 
                          k,   inputs[k],
			  (k - stage_shift)%N, inputs[(k - stage_shift)%N],
			  k, outputs[k]);

              end // if
           end // always @(*)

     end // for k
   endgenerate //
 -----/\----- EXCLUDED -----/\----- */
endmodule // stage


// 
module rot #(parameter N=16,
		parameter log2_N=4)
   (input wire [0 : N-1 ] bits,
    input wire [0 : log2_N-1 ] k,
    output wire [0:N-1]	rotated_bits);

   
    wire [0:N-1] middle [0:log2_N]; // Create log2(N) arrays each of size N
   
   initial begin 
       $display("Inside rot: N = %0d, log2(N) = %0d, mux_sel = %b", N, log2_N, k[0]);
   end
   
   // do stage 0 manually, other stages by a for loop
    stage #(.N(N), .log2_N(log2_N), .stage_number(0)) s0 (.inputs(bits), .mux_sel(k[0]), .outputs(middle[0]));

    
    
   genvar n;
   generate
      // Generate log2_N stages, and connect the output of each stage to the
      // to the inputs of the next stage, i.e. stage0 -> stage1 -> ... -> stage_{log2_N-1}
       for (n = 1; n < log2_N; n = n +1) begin
           stage #(.N(N), .log2_N(log2_N), .stage_number(n)) si (.inputs(middle[n-1]), .mux_sel(k[n]), .outputs(middle[n]));
          always @(*) begin 
              $display("time = %0d, stage = %0d, mux_sel=%0d", $time, n, k[n]);
          end // always
       end
   endgenerate
   
   // copy the outputs of the last stage to the output wires
   //assign rotated_bits = middle[log2_N - 1];
   
   genvar i;
   generate
      for (i = 0; i < N; i = i + 1) begin
	 assign rotated_bits[i] = middle[log2_N - 1][i];
      end
   endgenerate

endmodule // rot


