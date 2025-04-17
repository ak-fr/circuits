###############################################################################
# Created by write_sdc
###############################################################################
current_design expmob1
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 25.0000 
set_clock_uncertainty 0.2500 clk
set_input_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {inputs[0]}]
set_input_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {inputs[1]}]
set_input_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {inputs[2]}]
set_input_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {inputs[3]}]
set_input_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {inputs[4]}]
set_input_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {inputs[5]}]
set_input_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {inputs[6]}]
set_input_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {inputs[7]}]
set_output_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {outputs[0]}]
set_output_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {outputs[1]}]
set_output_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {outputs[2]}]
set_output_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {outputs[3]}]
set_output_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {outputs[4]}]
set_output_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {outputs[5]}]
set_output_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {outputs[6]}]
set_output_delay 5.0000 -clock [get_clocks {clk}] -add_delay [get_ports {outputs[7]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {outputs[0]}]
set_load -pin_load 0.0334 [get_ports {outputs[1]}]
set_load -pin_load 0.0334 [get_ports {outputs[2]}]
set_load -pin_load 0.0334 [get_ports {outputs[3]}]
set_load -pin_load 0.0334 [get_ports {outputs[4]}]
set_load -pin_load 0.0334 [get_ports {outputs[5]}]
set_load -pin_load 0.0334 [get_ports {outputs[6]}]
set_load -pin_load 0.0334 [get_ports {outputs[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {inputs[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {inputs[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {inputs[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {inputs[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {inputs[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {inputs[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {inputs[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {inputs[7]}]
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_capacitance 0.2000 [current_design]
set_max_fanout 10.0000 [current_design]
