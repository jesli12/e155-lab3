-L work
-reflib pmi_work
-reflib ovi_ice40up


"C:/Users/jesli/Documents/GitHub/e155-lab3/fpga/e155_lab3_jl/source/impl_1/lab3top_jl.sv" 
"C:/Users/jesli/Documents/GitHub/e155-lab3/fpga/e155_lab3_jl/source/impl_1/scanner.sv" 
"C:/Users/jesli/Documents/GitHub/e155-lab3/fpga/e155_lab3_jl/source/impl_1/sev_seg.sv" 
"C:/Users/jesli/Documents/GitHub/e155-lab3/fpga/e155_lab3_jl/source/impl_1/counter.sv" 
"C:/Users/jesli/Documents/GitHub/e155-lab3/fpga/e155_lab3_jl/source/impl_1/sync.sv" 
"C:/Users/jesli/Documents/GitHub/e155-lab3/fpga/e155_lab3_jl/source/impl_1/keypress_fsm.sv" 
"C:/Users/jesli/Documents/GitHub/e155-lab3/fpga/e155_lab3_jl/source/impl_1/keypress.sv" 
"C:/Users/jesli/Documents/GitHub/e155-lab3/fpga/e155_lab3_jl/source/impl_1/debounce_fsm.sv" 
"C:/Users/jesli/Documents/GitHub/e155-lab3/fpga/e155_lab3_jl/source/impl_1/dual_display.sv" 
"C:/Users/jesli/Documents/GitHub/e155-lab3/fpga/e155_lab3_jl/source/impl_1/keypress_tb.sv" 
-sv
-optionset VOPTDEBUG
+noacc+pmi_work.*
+noacc+ovi_ice40up.*

-vopt.options
  -suppress vopt-7033
-end

-gui
-top keypress_tb
-vsim.options
  -suppress vsim-7033,vsim-8630,3009,3389
-end

-do "view wave"
-do "add wave /*"
-do "run 100 ns"
