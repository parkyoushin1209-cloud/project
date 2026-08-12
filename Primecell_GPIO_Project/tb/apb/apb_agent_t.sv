`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_component_pkg::*;

class apb_agent_t extends uvm_agent;
  `uvm_component_utils(apb_agent_t)

apb_driver_t apb_driver;
apb_monitor_t apb_monitor;
apb_sequencer_t apb_sequencer;
uvm_active_passive_enum is_active = UVM_ACTIVE;

  
function new(string name, uvm_component parent);
super.new(name, parent);
endfunction : new

virtual function void build_phase(uvm_phase phase);
void'(uvm_config_db#(uvm_active_passive_enum)::get(this, "","is_active", is_active));

super.build_phase(phase);
apb_monitor = apb_monitor_t::type_id::create("apb_monitor", this);

if(is_active == UVM_ACTIVE) begin
apb_driver = apb_driver_t::type_id::create("apb_driver", this);
apb_sequencer = apb_sequencer_t::type_id::create("apb_sequencer", this);
end
endfunction : build_phase

virtual function void connect_phase(uvm_phase phase);
if(is_active == UVM_ACTIVE) begin
apb_driver.seq_item_port.connect(apb_sequencer.seq_item_export);
end
endfunction : connect_phase

virtual function uvm_sequencer_base get_sequencer();
return apb_sequencer;
endfunction : get_sequencer

endclass : apb_agent_t
