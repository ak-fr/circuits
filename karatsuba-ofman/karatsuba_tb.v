

module top_module ();
   localparam N = 8;
   // bit index number 0
   reg [N-1:0] a;
   reg [N-1:0] b;
   reg [2*N - 1:0] ab;
   
   
   initial begin 
      $display("N = %0d", N);
   end

   // Instantiate expmob1 and call the instance M
   karatsuba #(.N(N)) mul (.A(a), .B(b), .C(ab));
   
   initial begin // 
      a = 'b1100100;
      b = 'b1001011;
      
      // delay of 100 time units
      //#100 a = 'b1111_0000_0000_0000;
      //#100 a = 'b0000_0000_0000_0000;
      // Wait sufficiently enough time
      #10  $display("Time: %0t | a = %d | b = %d | a*b = %d",  $time, a, b, ab);
      #100 $stop; // end of simulation after 1000 units of time
   end

   // Whenever a change of a or Ma occur display both values with the time
   initial begin 
      $monitor("Time: %0t | a = %d | b = %d | a*b = %d",  $time, a, b, ab);
   end


endmodule

// Compute C := A*B
module karatsuba
  #(parameter N=16) // N has to be a power of 2
   ( input wire [N-1:0]	   A,
     input wire [N-1:0]	   B,
     output wire [2*N-1:0] C);


   // compute karatsuba recursively	
   generate
      if (N == 1)  // base case
	begin
	   // The output is just the and of the two bits
	   assign C = A&B;
	end

      else // recurse with all the complications 
	begin
	   localparam N_half = N>>1;
	   
	   wire [ (N/2) - 1 : 0] A_l;
	   wire [ (N/2) - 1 : 0] A_h;
	   wire [ (N/2) - 1 : 0] B_l;
	   wire [ (N/2) - 1 : 0] B_h;
	   
	   assign A_l = A[N/2 - 1 : 0];
	   assign A_h = A[ N  - 1 : N/2];
	   assign B_l = B[N/2 - 1 : 0];
	   assign B_h = B[ N  - 1 : N/2];
	   
	   // N/2 + 1 bits for the difference, the extra bit is for the sign
       wire [ (N/2) : 0] A_m; // := A_l - A_h
       wire [ (N/2) : 0] B_m; // := B_h - B_l
       wire [ (N/2) : 0] abs_A_m; // := |A_l - A_h|
       wire [ (N/2) : 0] abs_B_m; // := |B_h - B_l|
	   assign A_m = A_l - A_h;
	   assign B_m = B_h - B_l;
	   
        
	   wire  sign_A_m;
	   wire  sign_B_m;
	   wire  sign;   
       assign sign_A_m = A_m[N/2];
       assign sign_B_m = B_m[N/2];
       assign abs_A_m = (1 - 2*sign_A_m)*A_m;
       assign abs_B_m = (1 - 2*sign_B_m)*B_m;

        // 1 - 2*sign = -1 if  (A_m*B_m) < 0, otherwise 1
	   assign sign = sign_A_m ^ sign_B_m;

	   // P3 :=  A_h * B_h
	   wire [N-1:0] P3; // :=  A_h * B_h
	   karatsuba #(.N(N/2)) Ah_Bh (.A(A_h), .B(B_h), .C(P3));
	   
	   wire [N-1:0]	P2; // :=  A_l*B_l
	   karatsuba #(.N(N/2)) Al_Bl (.A(A_l), .B(B_l), .C(P2));
	   
	   // (A_l - A_h)(B_h - B_l)  = A_m[N/2-1:0] * B_m[N/2-1:0]
	   //  without the sign bit
	   wire [N-1:0]	P1;
	   karatsuba #(.N(N/2)) Am_Bm (.A(abs_A_m[N/2 - 1 : 0]), 
                                   .B(abs_B_m[N/2 - 1 : 0]),
                                   .C(P1));


	always @(*) begin 
        if (^C !== 1'bx) begin
            $display("Recurse: N=%0d | A=%d, B=%d | A_l=0b%b, A_h=0b%b | B_l=0b%b , B_h=0b%b | A_m=0b%b , B_m=0b%b , sign=%b| P1=%0d , P2=%0d , P3=%d | C = %0d", 
                    N, A, B, A_l, A_h, B_l, B_h, A_m, B_m, sign, P1, P2, P3, (1<<N) * P3 + (1 << (N/2))*(P3 + P2 + (1-2*sign)*P1) + P2);
       	end // if
    end // always
	   // (A_l - A_h)(B_h - B_l) + A_h*B_h + A_l*B_l
	   // (1 - 2*sign) = -1 if P1 shoulde be < 0
	   assign C = (1<<N) * P3 
		    + (1 << (N/2))*(P3 + P2 + (1-2*sign)*P1)
		    + P2;
	   
	end
   endgenerate
endmodule // karatsuba


