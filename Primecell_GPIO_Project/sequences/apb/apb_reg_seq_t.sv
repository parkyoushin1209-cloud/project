import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_reg_seq_t extends apb_base_seq_t;
  `uvm_object_utils(apb_reg_seq_t)

  function new(string name  = "apb_reg_seq_t");
super.new(name);
endfunction : new


virtual task body();
start_item(apb_tr);
  if(!apb_tr.randomize() with {
    apb_tr.addr[11:0] inside {
      [12'h000 : 12'h3FF], 
      [12'h400 : 12'h403], 
      [12'h404 : 12'h407], 
      [12'h408 : 12'h40B], 
      [12'h40C : 12'h40F],
      [12'h410 : 12'h413],
      [12'h414 : 12'h417],
      [12'h418 : 12'h41B],
      [12'h41C : 12'h41F],
      [12'h420 : 12'h423],
      [12'hFE0 : 12'hFE3], 
      [12'hFE4 : 12'hFE7], 
      [12'hFE8 : 12'hFEB], 
      [12'hFEC : 12'hFEF],
      [12'hFF0 : 12'hFF3], 
      [12'hFF4 : 12'hFF7], 
      [12'hFF8 : 12'hFFB],
      [12'hFFC : 12'hFFF]};
    apb_tr.addr[31:12] == 20'h00000;
     }) `uvm_error("RANDFAIL", "Failed in randomize")
  $display("@time=%t addr=%h", $time, apb_tr.addr[31:0]);
finish_item(apb_tr);
endtask : body

endclass : apb_reg_seq_t
