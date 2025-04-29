module stage0
  #(parameter N=16,
    parameter log2_N=4,
    parameter stage_number=0)

   (input wire [0:16-1]  inputs, 
    output wire [0:16-1]  outputs);

   // stage 0 has one block
   // localparam n_blocks  = 32'b1 << stage_number;
   // localparam n_elements_block = 32'b1 * (16 / (2*n_blocks));
   //localparam start_index = 32'b0;

   // Butterfly
	     assign outputs[0] = inputs[0];
	     assign outputs[8] = inputs[0] ^ inputs[8];
	     assign outputs[1] = inputs[1];
	     assign outputs[9] = inputs[1] ^ inputs[9];
	     assign outputs[2] = inputs[2];
	     assign outputs[10] = inputs[2] ^ inputs[10];
	     assign outputs[3] = inputs[3];
	     assign outputs[11] = inputs[3] ^ inputs[11];
	     assign outputs[4] = inputs[4];
	     assign outputs[12] = inputs[4] ^ inputs[12];
	     assign outputs[5] = inputs[5];
	     assign outputs[13] = inputs[5] ^ inputs[13];
	     assign outputs[6] = inputs[6];
	     assign outputs[14] = inputs[6] ^ inputs[14];
	     assign outputs[7] = inputs[7];
	     assign outputs[15] = inputs[7] ^ inputs[15];

endmodule // stage0


module stage1
  #(parameter N=16,
    parameter log2_N=4,
    parameter stage_number=1)

   (input wire [0:16-1]  inputs, 
    output wire [0:16-1]  outputs);

   // stage 0 has one block
   // localparam n_blocks  = 32'b1 << stage_number;
   // localparam n_elements_block = 32'b1 * (16 / (2*n_blocks));
   //localparam start_index = 32'b0;

   // Butterfly
	     assign outputs[0] = inputs[0];
	     assign outputs[4] = inputs[0] ^ inputs[4];
	     assign outputs[1] = inputs[1];
	     assign outputs[5] = inputs[1] ^ inputs[5];
	     assign outputs[2] = inputs[2];
	     assign outputs[6] = inputs[2] ^ inputs[6];
	     assign outputs[3] = inputs[3];
	     assign outputs[7] = inputs[3] ^ inputs[7];
	     assign outputs[8] = inputs[8];
	     assign outputs[12] = inputs[8] ^ inputs[12];
	     assign outputs[9] = inputs[9];
	     assign outputs[13] = inputs[9] ^ inputs[13];
	     assign outputs[10] = inputs[10];
	     assign outputs[14] = inputs[10] ^ inputs[14];
	     assign outputs[11] = inputs[11];
	     assign outputs[15] = inputs[11] ^ inputs[15];

endmodule // stage1


module stage2
  #(parameter N=16,
    parameter log2_N=4,
    parameter stage_number=2)

   (input wire [0:16-1]  inputs, 
    output wire [0:16-1]  outputs);

   // stage 0 has one block
   // localparam n_blocks  = 32'b1 << stage_number;
   // localparam n_elements_block = 32'b1 * (16 / (2*n_blocks));
   //localparam start_index = 32'b0;

   // Butterfly
	     assign outputs[0] = inputs[0];
	     assign outputs[2] = inputs[0] ^ inputs[2];
	     assign outputs[1] = inputs[1];
	     assign outputs[3] = inputs[1] ^ inputs[3];
	     assign outputs[4] = inputs[4];
	     assign outputs[6] = inputs[4] ^ inputs[6];
	     assign outputs[5] = inputs[5];
	     assign outputs[7] = inputs[5] ^ inputs[7];
	     assign outputs[8] = inputs[8];
	     assign outputs[10] = inputs[8] ^ inputs[10];
	     assign outputs[9] = inputs[9];
	     assign outputs[11] = inputs[9] ^ inputs[11];
	     assign outputs[12] = inputs[12];
	     assign outputs[14] = inputs[12] ^ inputs[14];
	     assign outputs[13] = inputs[13];
	     assign outputs[15] = inputs[13] ^ inputs[15];

endmodule // stage2


module stage3
  #(parameter N=16,
    parameter log2_N=4,
    parameter stage_number=3)

   (input wire [0:16-1]  inputs, 
    output wire [0:16-1]  outputs);

   // stage 0 has one block
   // localparam n_blocks  = 32'b1 << stage_number;
   // localparam n_elements_block = 32'b1 * (16 / (2*n_blocks));
   //localparam start_index = 32'b0;

   // Butterfly
	     assign outputs[0] = inputs[0];
	     assign outputs[1] = inputs[0] ^ inputs[1];
	     assign outputs[2] = inputs[2];
	     assign outputs[3] = inputs[2] ^ inputs[3];
	     assign outputs[4] = inputs[4];
	     assign outputs[5] = inputs[4] ^ inputs[5];
	     assign outputs[6] = inputs[6];
	     assign outputs[7] = inputs[6] ^ inputs[7];
	     assign outputs[8] = inputs[8];
	     assign outputs[9] = inputs[8] ^ inputs[9];
	     assign outputs[10] = inputs[10];
	     assign outputs[11] = inputs[10] ^ inputs[11];
	     assign outputs[12] = inputs[12];
	     assign outputs[13] = inputs[12] ^ inputs[13];
	     assign outputs[14] = inputs[14];
	     assign outputs[15] = inputs[14] ^ inputs[15];

endmodule // stage3


module expmob1 #(parameter N=16,
		parameter log2_N=4)
   (input wire [0:16-1] inputs,
    output wire [0:16-1] outputs);

   
    wire [0:N-1] middle [0:log2_N]; // Create log2(N) arrays each of size N
   
   // do stage 0 manually, other stages by a for loop
   stage0 #(.N(N), .log2_N(log2_N), .stage_number(0)) s0 (.inputs(inputs), .outputs(middle[0]));
   stage1 #(.N(N), .log2_N(log2_N), .stage_number(1)) s1 (.inputs(middle[1-1]), .outputs(middle[1]));
   stage2 #(.N(N), .log2_N(log2_N), .stage_number(2)) s2 (.inputs(middle[2-1]), .outputs(middle[2]));
   stage3 #(.N(N), .log2_N(log2_N), .stage_number(3)) s3 (.inputs(middle[3-1]), .outputs(middle[3]));
   assign outputs = middle[log2_N - 1];

endmodule // expmob1