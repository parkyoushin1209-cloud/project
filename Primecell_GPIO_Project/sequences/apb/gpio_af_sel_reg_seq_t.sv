import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_af_sel_reg_seq_t extends apb_base_seq_t;
  `uvm_object_utils(apb_af_sel_reg_seq_t)

  function new(string name  = "apb_af_sel_reg_seq_t");
super.new(name);
endfunction : new


virtual task body();
start_item(apb_tr);
  if(!apb_tr.randomize() with {
    apb_tr.addr[11:0] inside {[12'h420 : 12'h423]};
    apb_tr.addr[31:12] == 20'h00000;
     }) `uvm_error("RANDFAIL", "Failed in randomize")
finish_item(apb_tr);
endtask : body

endclass : apb_af_sel_reg_seq_t
