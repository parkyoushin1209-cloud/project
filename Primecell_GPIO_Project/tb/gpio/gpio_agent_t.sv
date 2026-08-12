`include "uvm_macros.svh"
import uvm_pkg::*;
import gpio_component_pkg::*;

class gpio_agent_t extends uvm_agent;
`uvm_component_utils(gpio_agent_t)

uvm_active_passive_enum is_active = UVM_ACTIVE;
gpio_monitor_t gpio_monitor;
gpio_driver_t gpio_driver;
gpio_sequencer_t gpio_sequencer;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction : new

virtual function void build_phase(uvm_phase phase);
void'(uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active));
super.build_phase(phase);
    gpio_monitor = gpio_monitor_t::type_id::create("gpio_monitor", this);
if(is_active == UVM_ACTIVE) begin
    gpio_driver = gpio_driver_t::type_id::create("gpio_driver", this);
    gpio_sequencer = gpio_sequencer_t::type_id::create("gpio_sequencer", this);
end
endfunction : build_phase

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
if(is_active == UVM_ACTIVE) begin
    gpio_driver.seq_item_port.connect(gpio_sequencer.seq_item_export);
end
endfunction : connect_phase

  
virtual function uvm_sequencer_base get_sequencer();
return gpio_sequencer;
endfunction : get_sequencer

endclass : gpio_agent_t
