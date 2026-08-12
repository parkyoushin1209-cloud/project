import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_component_pkg::apb_sequencer_t;
import apb_transaction_pkg::*;
import gpio_reg_model_pkg::*;

class apb_base_seq_t extends uvm_sequence #(apb_transaction);
`uvm_object_utils(apb_base_seq_t)

`uvm_declare_p_sequencer(apb_sequencer_t)
apb_transaction apb_tr;  
gpio_reg_block_t regmodel;

function new(string name = "apb_base_seq_t");
super.new(name);
apb_tr = apb_transaction::type_id::create("apb_tr");
endfunction : new
  
 //  constraint valid_addr {(apb_tr.addr inside {[12'h414 : 12'h41B], [12'hFE0 : 12'hFFF]}) -> (apb_tr.kind == apb_transaction::READ) ;
//                         (apb_tr.addr inside {[12'h41C : 12'h41F]}) -> (apb_tr.kind == apb_transaction::WRITE); }
                       
virtual task pre_body();
if(p_sequencer.regmodel == null) `uvm_fatal("NOREGMODEL", {"regmodel must be set for: ", "apb_seq"})
else regmodel = p_sequencer.regmodel;

if(starting_phase != null) begin  
    `uvm_info("SEQUENCE", {"raise_objection : ", get_full_name()}, UVM_HIGH)
    starting_phase.raise_objection(this);
end
endtask : pre_body

virtual task post_body();
if(starting_phase != null) begin
  `uvm_info("SEQUENCE",{ "drop_objection : ", get_full_name()}, UVM_HIGH)
    starting_phase.drop_objection(this);
end
endtask : post_body


endclass : apb_base_seq_t
