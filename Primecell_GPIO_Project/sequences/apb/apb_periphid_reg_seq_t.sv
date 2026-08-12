import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_periphid_reg_seq_t extends apb_base_seq_t;
  `uvm_object_utils(apb_periphid_reg_seq_t)

  function new(string name  = "apb_periphid_reg_seq_t");
super.new(name);
endfunction : new


virtual task body();
start_item(apb_tr);
  if(!apb_tr.randomize() with {
    apb_tr.addr[11:0] inside {
      [12'hFE0 : 12'hFE3], 
      [12'hFE4 : 12'hFE7], 
      [12'hFE8 : 12'hFEB],
      [12'hFEC : 12'hFEF]};
    apb_tr.addr[31:12] == 20'h00000;
     }) `uvm_error("RANDFAIL", "Failed in randomize")
finish_item(apb_tr);
endtask : body

endclass : apb_periphid_reg_seq_t
