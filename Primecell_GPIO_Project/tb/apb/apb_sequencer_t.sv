`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_transaction_pkg::*;
import gpio_reg_model_pkg::*;

class apb_sequencer_t extends uvm_sequencer #(apb_transaction);
`uvm_component_utils(apb_sequencer_t)

gpio_reg_block_t regmodel;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction : new

virtual function void build_phase(uvm_phase phase);
if(!uvm_config_db#(gpio_reg_block_t)::get(this,"", "regmodel", regmodel))
`uvm_error("NO_REGMODEL", {"regmodel must be set for :", get_full_name()})
endfunction : build_phase

endclass : apb_sequencer_t
