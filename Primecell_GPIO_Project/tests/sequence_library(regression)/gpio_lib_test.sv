`include "uvm_macros.svh"
import uvm_pkg::*;


import virtual_sequence_pkg::*;
import apb_sequence_pkg::*;
import gpio_sequence_pkg::*;

class gpio_lib_test extends gpio_base_test;
`uvm_component_utils(gpio_lib_test)

v_reg_lib_seq_t v_reg_lib_seq;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction : new

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction : build_phase

  
virtual task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);

  repeat(1000) begin 
  v_reg_lib_seq = v_reg_lib_seq_t::type_id::create("v_reg_lib_seq");
  v_reg_lib_seq.start(gpio_system_env.vsequencer);
  end
phase.drop_objection(this);
endtask : run_phase

      
endclass : gpio_lib_test
