`include "uvm_macros.svh"
import uvm_pkg::*;
import gpio_component_pkg::*;

class gpio_io_agent_t extends uvm_agent;
`uvm_component_utils(gpio_io_agent_t)

    gpio_io_monitor_t gpio_io_monitor;

    function new(string name, uvm_component parent);
    super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
      gpio_io_monitor = gpio_io_monitor_t::type_id::create("gpio_io_monitor", this);
    endfunction : build_phase

endclass : gpio_io_agent_t
