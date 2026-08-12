`include "uvm_macros.svh"
import uvm_pkg::*;
import virtual_sequence_pkg::*;
import apb_transaction_pkg::*;
import gpio_transaction_pkg::*;
import apb_sequence_pkg::*;
import gpio_sequence_pkg::*;

class vsequence_t extends base_vseq;
`uvm_object_utils(vsequence_t)

  apb_reg_seq_t apb_reg_seq;
  gpio_seq_t gpio_seq;
  
  function new(string name = "vsequence_t");
super.new(name);
endfunction : new

virtual task body();
  `uvm_info("VSEQ", "virtual sequence body start", UVM_HIGH)
  if(p_sequencer.apb_sequencer == null || p_sequencer.gpio_sequencer == null) `uvm_fatal("NO_SEQR", "p_sequencer setting error")
  
  
    apb_reg_seq = apb_reg_seq_t::type_id::create("apb_reg_seq");
  apb_reg_seq.starting_phase = starting_phase;
  gpio_seq = gpio_seq_t::type_id::create("gpio_seq");
  gpio_seq.starting_phase = starting_phase;
  
fork 
  apb_reg_seq.start(p_sequencer.apb_sequencer);
  gpio_seq.start(p_sequencer.gpio_sequencer);
join
  `uvm_info("VSEQ", "virtual sequence body end", UVM_HIGH)
endtask : body

endclass : vsequence_t

