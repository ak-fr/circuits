// Multiplication of two unsigned integers A and B using Karatsuba method.
// A and B are both of length 2^n bits, this makes the recursion less painful.
// ---------------------------------------------------------------------------
// A = 2^m A_h + A_l, B = 2^m B_h + B_l, m = n/2
// A*B = 2^n (A_h * B_h) + 2^m (A_h * B_l + A_l * B_l)  + A_l*B_l
// P3 :=  A_h * B_h
// P2 :=  A_l*B_l
// P1 := |A_l - A_h|*|B_h - B_l|
// s  :=  sign((A_l - A_h)*(B_h - B_l))
// (A_h * B_l + A_l * B_l)
//     = (A_l - A_h)(B_h - B_l) + A_h*B_h + A_l*B_l
//     = s*P1 + P2 + P3
// For convenience let's call
//  A_m := A_l - A_h
//  B_m := B_h - B_l
// A*B = 2^n P3 + 2^m (P1 + P2 + P3)  + P2
// This version avoids overflow but requirs recording the sign of P1
// ---------------------------------------------------------------------------

// Compute C := A*B
module karatsuba
  #(parameter N=2048) // N has to be a power of 2
   (input wire [N-1:0] A,
    input wire [N-1:0] B,
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
	   wire	 sign_B_m;
           wire	 sign;   
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

	   /* -----\/----- EXCLUDED -----\/-----

	    always @(*) begin 
            if (^C !== 1'bx) begin
            $display("Recurse: N=%0d | A=%d, B=%d | A_l=0b%b, A_h=0b%b | B_l=0b%b , B_h=0b%b | A_m=0b%b , B_m=0b%b , sign=%b| P1=%0d , P2=%0d , P3=%d | C = %0d", 
            N, A, B, A_l, A_h, B_l, B_h, A_m, B_m, sign, P1, P2, P3, (1<<N) * P3 + (1 << (N/2))*(P3 + P2 + (1-2*sign)*P1) + P2);
       	end // if
    end // always
	    -----/\----- EXCLUDED -----/\----- */
	   // (A_l - A_h)(B_h - B_l) + A_h*B_h + A_l*B_l
	   // (1 - 2*sign) = -1 if P1 shoulde be < 0
	   assign C = (1<<N) * P3 
        	    + (1 << (N/2))*(P3 + P2 + (1-2*sign)*P1)
		    + P2;
	   
	end
   endgenerate
endmodule // karatsuba
