import uvm_pkg::*;
`include "uvm_macros.svh"
import gpio_component_pkg::vsequencer_t;

class base_vseq extends uvm_sequence;

 function new(string name = "base_vseq");
 super.new(name);
 endfunction : new

`uvm_object_utils(base_vseq)
`uvm_declare_p_sequencer(vsequencer_t)

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

endclass : base_vseq
