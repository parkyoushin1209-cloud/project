`include "uvm_macros.svh"
import uvm_pkg::*;
import gpio_transaction_pkg::*;
import gpio_component_pkg::gpio_sequencer_t;
import gpio_reg_model_pkg::*;

class gpio_base_seq_t extends uvm_sequence #(gpio_transaction);
`uvm_object_utils(gpio_base_seq_t)

`uvm_declare_p_sequencer(gpio_sequencer_t)

gpio_transaction gpio_tr;
logic[7:0] cur_gpioafsel;

function new(string name = "gpio_base_seq_t");
super.new(name);
gpio_tr = gpio_transaction::type_id::create("gpio_tr");
endfunction : new


  virtual task pre_start();
    if(p_sequencer.regmodel == null) `uvm_fatal("NOREGMODEL", {"regmodel must be set for: ", "gpio_seq"})
    cur_gpioafsel = p_sequencer.regmodel.GPIOAFSEL.get();
  endtask : pre_start
  
virtual task pre_body();

if(starting_phase != null) begin
    `uvm_info("SEQUENCE", {"raise_objection : ", get_full_name()}, UVM_HIGH)
    starting_phase.raise_objection(this);
end
  
endtask : pre_body


  
virtual task post_body();
if(starting_phase != null) begin
  `uvm_info("SEQUENCE", {"drop_objection : ", get_full_name()}, UVM_HIGH)
    starting_phase.drop_objection(this);
end
endtask : post_body


endclass : gpio_base_seq_t
