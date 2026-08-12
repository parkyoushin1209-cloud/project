import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_pcellid_reg_seq_t extends apb_base_seq_t;
  `uvm_object_utils(apb_pcellid_reg_seq_t)

  function new(string name  = "apb_pcellid_reg_seq_t");
super.new(name);
endfunction : new


virtual task body();
start_item(apb_tr);
  if(!apb_tr.randomize() with {
    apb_tr.addr[11:0] inside {
      [12'hFF0 : 12'hFF3], 
      [12'hFF4 : 12'hFF7], 
      [12'hFF8 : 12'hFFB],
      [12'hFFC : 12'hFFF]};
    apb_tr.addr[31:12] == 20'h00000;
     }) `uvm_error("RANDFAIL", "Failed in randomize")
finish_item(apb_tr);
endtask : body

endclass : apb_pcellid_reg_seq_t
