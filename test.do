vlib best_library
#make this library

vlog test_ifblocks.v 
#compile this

vsim test_case_block
#simulate this module

log {/*}
#make a waveform from the previous simulation

force {in} 1
run 3ns

force {in} 0
run 3ns

