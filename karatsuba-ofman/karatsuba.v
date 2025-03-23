// Multiplication of two unsigned integers A and B using Karatsuba method.
// A and B are both of length 2^n bits, this makes the recursion less painful.
// ---------------------------------------------------------------------------
// A = 2^m X_h + X_l, B = 2^m Y_h + Y_l, m = n/2
// A*B = 2^n (X_h * Y_h) + 2^m (X_h * Y_l + X_l * Y_l)  + X_l*Y_l
// P3 :=  X_h * Y_h
// P2 :=  X_l*Y_l
// P1 := (X_l - X_h)(Y_h - Y_l)
// P0 := (X_h * Y_l + X_l * Y_l)
//     = (X_l - X_h)(Y_h - Y_l) + X_h*Y_h + X_l*Y_l
//     = P1 + P2 + P3
// A*B = 2^n P3 + 2^m P0  + P2
// This version avoids overflow but requirs recording the sign of P1
// ---------------------------------------------------------------------------

