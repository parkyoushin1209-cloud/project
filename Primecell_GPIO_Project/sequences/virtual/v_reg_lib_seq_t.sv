`include "uvm_macros.svh"
import uvm_pkg::*;
import virtual_sequence_pkg::*;
import apb_transaction_pkg::*;
import gpio_transaction_pkg::*;
import apb_sequence_pkg::*;
import gpio_sequence_pkg::*;

class v_reg_lib_seq_t extends base_vseq;
`uvm_object_utils(v_reg_lib_seq_t)

  apb_reg_lib_seq_t apb_reg_lib_seq;
  gpio_reg_lib_seq_t gpio_reg_lib_seq;
  
  function new(string name = "v_reg_lib_seq_t");
super.new(name);
endfunction : new

  
virtual task body();
  `uvm_info("VSEQ", "virtual sequence body start", UVM_HIGH)
  if(p_sequencer.apb_sequencer == null || p_sequencer.gpio_sequencer == null) `uvm_fatal("NO_SEQR", "p_sequencer setting error")
        apb_reg_lib_seq = apb_reg_lib_seq_t::type_id::create("apb_reg_lib_seq");
        apb_reg_lib_seq.min_random_count = 1000;
        apb_reg_lib_seq.max_random_count = 1000;
        apb_reg_lib_seq.starting_phase = starting_phase;
        apb_reg_lib_seq.selection_mode = UVM_SEQ_LIB_RAND;
        
        gpio_reg_lib_seq = gpio_reg_lib_seq_t::type_id::create("gpio_reg_lib_seq");
        gpio_reg_lib_seq.min_random_count = 1000;
        gpio_reg_lib_seq.max_random_count = 1000;
        gpio_reg_lib_seq.starting_phase = starting_phase;
        gpio_reg_lib_seq.selection_mode = UVM_SEQ_LIB_RAND;
  fork
    apb_reg_lib_seq.start(p_sequencer.apb_sequencer );
    gpio_reg_lib_seq.start(p_sequencer.gpio_sequencer);
  join

endtask : body


endclass : v_reg_lib_seq_t
