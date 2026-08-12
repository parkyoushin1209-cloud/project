`include "uvm_macros.svh"
import uvm_pkg::*;


class gpio_io_transaction extends uvm_sequence_item;
//마스터가 구동할 신호
  logic[7:0] nGPEN;
  logic[7:0] GPOUT;
  logic[7:0] GPIN;
  logic[7:0] XP;


`uvm_object_utils_begin(gpio_io_transaction)
`uvm_field_int(nGPEN, UVM_DEFAULT)
`uvm_field_int(GPOUT, UVM_DEFAULT)
`uvm_field_int(GPIN, UVM_DEFAULT)
`uvm_field_int(XP, UVM_DEFAULT)
`uvm_object_utils_end

function new(string name = "gpio_io_transaction");
super.new(name);
endfunction : new

endclass : gpio_io_transaction
