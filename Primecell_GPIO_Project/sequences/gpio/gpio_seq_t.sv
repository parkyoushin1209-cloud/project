import uvm_pkg::*;
`include "uvm_macros.svh"

class gpio_seq_t extends gpio_base_seq_t;
`uvm_object_utils(gpio_seq_t)

function new(string name = "gpio_seq_t");
super.new(name);
endfunction : new

virtual task body();
  `uvm_info("SEQ", "gpio_sequence body start", UVM_HIGH)
start_item(gpio_tr);
  if(!gpio_tr.randomize() with { foreach(cur_gpioafsel[i]) { if(cur_gpioafsel[i] == 1'b0){gpio_tr.nGPAFEN[i] == 1'b1;}}} ) `uvm_error("RANDFAIL", "Failed in randomize")
finish_item(gpio_tr);
  `uvm_info("SEQ", "gpio_sequence body end", UVM_HIGH)
endtask : body

endclass : gpio_seq_t
