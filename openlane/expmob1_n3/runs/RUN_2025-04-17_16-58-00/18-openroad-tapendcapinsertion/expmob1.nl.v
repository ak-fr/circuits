module expmob1 (inputs,
    outputs);
 input [0:7] inputs;
 output [0:7] outputs;

 wire _00_;
 wire _01_;
 wire _02_;
 wire _03_;
 wire _04_;

 sky130_fd_sc_hd__xor2_2 _05_ (.A(inputs[4]),
    .B(inputs[0]),
    .X(outputs[4]));
 sky130_fd_sc_hd__xor2_2 _06_ (.A(inputs[6]),
    .B(inputs[2]),
    .X(_00_));
 sky130_fd_sc_hd__xor2_2 _07_ (.A(outputs[4]),
    .B(_00_),
    .X(outputs[6]));
 sky130_fd_sc_hd__xor2_2 _08_ (.A(inputs[0]),
    .B(inputs[2]),
    .X(outputs[2]));
 sky130_fd_sc_hd__xnor2_2 _09_ (.A(inputs[5]),
    .B(inputs[1]),
    .Y(_01_));
 sky130_fd_sc_hd__xnor2_2 _10_ (.A(outputs[4]),
    .B(_01_),
    .Y(outputs[5]));
 sky130_fd_sc_hd__xor2_2 _11_ (.A(inputs[7]),
    .B(inputs[3]),
    .X(_02_));
 sky130_fd_sc_hd__xnor2_2 _12_ (.A(_00_),
    .B(_02_),
    .Y(_03_));
 sky130_fd_sc_hd__xnor2_2 _13_ (.A(outputs[5]),
    .B(_03_),
    .Y(outputs[7]));
 sky130_fd_sc_hd__xnor2_2 _14_ (.A(inputs[1]),
    .B(inputs[3]),
    .Y(_04_));
 sky130_fd_sc_hd__xnor2_2 _15_ (.A(outputs[2]),
    .B(_04_),
    .Y(outputs[3]));
 sky130_fd_sc_hd__xor2_2 _16_ (.A(inputs[0]),
    .B(inputs[1]),
    .X(outputs[1]));
 sky130_fd_sc_hd__buf_2 _17_ (.A(inputs[0]),
    .X(outputs[0]));
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Right_0 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Right_1 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Right_2 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Right_3 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Right_4 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Right_5 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Right_6 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Left_7 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Left_8 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Left_9 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Left_10 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Left_11 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Left_12 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Left_13 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_14 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_15 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_16 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_17 ();
endmodule
