import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_component_pkg::apb_sequencer_t;


class vsequencer_t extends uvm_sequencer;
`uvm_component_utils(vsequencer_t)

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction : new

gpio_sequencer_t gpio_sequencer;
apb_sequencer_t apb_sequencer;

endclass : vsequencer_t
