# Generate an expmob1 unrolled verilog file
# Todo search for how to supplement command line argument to python

import argparse
from math import log2


def write_stage(N, i):
    preamble = f"""module stage{i}
  #(parameter N={N},
    parameter log2_N={int(log2(N))},
    parameter stage_number={i})

   (input wire [0:{N}-1]  inputs, 
    output wire [0:{N}-1]  outputs);

   // stage 0 has one block
   // localparam n_blocks  = 32'b1 << stage_number;
   // localparam n_elements_block = 32'b1 * ({N} / (2*n_blocks));
   //localparam start_index = 32'b0;

   // Butterfly"""

    unrolled_loop = "\n"
    
    #    localparam n_elements_block = 32'b1 * ({N} / (2*n_blocks));
    n_blocks = 1 << i # 32'b1 << stage_number;
    n_elements_block =  (N // (2*n_blocks))
    # after for
    # localparam start_index = (32'b1) *  k * (n_elements_block * 2);
    for k in range(n_blocks):
        start_index = k * (n_elements_block * 2);
        for j in range(n_elements_block):
            unrolled_loop += f"	     assign outputs[{start_index + j}] = inputs[{start_index + j}];\n"
            unrolled_loop += f"	     assign outputs[{start_index + j + n_elements_block}] = inputs[{start_index + j}] ^ inputs[{start_index + j + n_elements_block}];\n"


    end_text = f"\nendmodule // stage{i}\n\n"

    return preamble + unrolled_loop + end_text

def write_expmob1(N):
    preamble = f"""module expmob1 #(parameter N={N},
		parameter log2_N={int(log2(N))})
   (input wire [0:{N}-1] inputs,
    output wire [0:{N}-1] outputs);

   
    wire [0:N-1] middle [0:log2_N]; // Create log2(N) arrays each of size N
   
   // do stage 0 manually, other stages by a for loop
   stage0 #(.N(N), .log2_N(log2_N), .stage_number(0)) s0 (.inputs(inputs), .outputs(middle[0]));"""

    unrolled_loop = "\n"

    for n in range(1, int(log2(N))):
        unrolled_loop += f"   stage{n} #(.N(N), .log2_N(log2_N), .stage_number({n})) s{n} (.inputs(middle[{n}-1]), .outputs(middle[{n}]));\n"

    end_text  = "   assign outputs = middle[log2_N - 1];\n\n"
    end_text += "endmodule // expmob1"
        
    return preamble + unrolled_loop + end_text

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-N",
                        type=int,
                        help="Number of bits for expmob1")
    args = parser.parse_args()

    N = args.N

    text  = "\n".join(write_stage(N, i) for i in range(int(log2(N))))
    text += "\n" +  write_expmob1(N)
    
    with open("expmob1.v", "w") as f:
        f.write(text)
    
    

    
