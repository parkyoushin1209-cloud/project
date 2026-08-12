`include "uvm_macros.svh"
import uvm_pkg::*;


class apb_transaction extends uvm_sequence_item;

  typedef enum bit[1:0] {READ, WRITE} kind_e;
  rand logic[31:0] addr;
  rand logic[31:0] data;
  rand kind_e      kind;

// rand logic[SEL_NUM-1:0]    PSEL;
//logic                      PSLVERR;

`uvm_object_utils_begin(apb_transaction)
`uvm_field_int(addr, UVM_DEFAULT)
`uvm_field_int(data, UVM_DEFAULT)
`uvm_field_enum(kind_e, kind,  UVM_DEFAULT)
//`uvm_field_int(PSEL, UVM_DEFAULT)
//`uvm_field_int(PSLVERR, UVM_DEFAULT)
`uvm_object_utils_end
  
  constraint data_dist { data dist{
    8'h00 := 15,
    8'h0F := 15,
    8'h55 := 15,
    8'hAA := 15,
    8'hF0 := 15,
    8'hFF := 15,

    [8'h01 : 8'h0E] :/ 40,
    [8'h10 : 8'h54] :/ 40,

    [8'h56 : 8'h59] :/ 40,
    [8'h5B : 8'hA4] :/ 40,
    [8'hA6 : 8'hA9] :/ 40,

    [8'hAB : 8'hEF] :/ 40,
    [8'hF1 : 8'hFE] :/ 40
    };
  }
  
  
function new(string name = "apb_transaction");
super.new(name);
endfunction : new

 constraint valid_addr {(addr inside {[12'h414 : 12'h41B], [12'hFE0 : 12'hFFF]}) -> (kind == apb_transaction::READ) ;
                    (addr inside {[12'h41C : 12'h41F]}) -> (kind == apb_transaction::WRITE); }
endclass : apb_transaction
