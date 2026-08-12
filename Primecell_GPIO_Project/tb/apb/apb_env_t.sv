`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_component_pkg::*;

class apb_env_t extends uvm_env;
`uvm_component_utils(apb_env_t)
apb_agent_t apb_agent;
apb_cov_coll_t apb_cov_coll;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction : new

virtual function void build_phase(uvm_phase phase);
apb_agent = apb_agent_t::type_id::create("apb_agent", this);
apb_cov_coll = apb_cov_coll_t::type_id::create("apb_cov_coll", this);
endfunction : build_phase
  
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
apb_agent.apb_monitor.apb_port.connect(apb_cov_coll.apb_export);
endfunction : connect_phase
  
endclass : apb_env_t
