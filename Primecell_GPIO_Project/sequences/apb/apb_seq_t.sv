import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_seq_t extends apb_base_seq_t;
`uvm_object_utils(apb_seq_t)

function new(string name  = "apb_seq_t");
super.new(name);
endfunction : new

virtual task body();
  `uvm_info("SEQ", "apb_sequence body start", UVM_HIGH)
start_item(apb_tr);
  if(!apb_tr.randomize() with {apb_tr.kind == apb_transaction::WRITE;}) `uvm_error("RANDFAIL", "Failed in randomize")
finish_item(apb_tr);
  `uvm_info("SEQ", "apb_sequence body end", UVM_HIGH)
endtask : body

endclass : apb_seq_t
