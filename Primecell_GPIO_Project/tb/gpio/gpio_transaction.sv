`include "uvm_macros.svh"
import uvm_pkg::*;


class gpio_transaction extends uvm_sequence_item ;
//마스터가 구동할 신호
  rand logic[7 : 0] nGPAFEN;
  rand logic[7 : 0] GPAFOUT;

//슬레이브가 관찰할 신호
  logic[7 : 0]      GPAFIN;
  logic[7 : 0]      GPIOMIS;
  logic             GPIOINTR;



`uvm_object_utils_begin(gpio_transaction)
  `uvm_field_int(nGPAFEN, UVM_DEFAULT)
  `uvm_field_int(GPAFOUT, UVM_DEFAULT)
  `uvm_field_int(GPAFIN, UVM_DEFAULT)
  `uvm_field_int(GPIOMIS, UVM_DEFAULT)
  `uvm_field_int(GPIOINTR, UVM_DEFAULT)
`uvm_object_utils_end

  constraint nGPAFEN_dist { nGPAFEN dist{
    8'h00 := 35,
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
  
  constraint GPAFOUT_dist { GPAFOUT dist{
    8'h00 := 25,
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
  
function new(string name = "gpio_transaction");
super.new(name);
endfunction : new

endclass : gpio_transaction
