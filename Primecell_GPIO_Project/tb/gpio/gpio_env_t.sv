`include "uvm_macros.svh"
import uvm_pkg::*;
import gpio_component_pkg::*;

class gpio_env_t extends uvm_env;
`uvm_component_utils(gpio_env_t)
gpio_agent_t gpio_agent;
gpio_cov_coll_t gpio_cov_coll;
gpio_io_agent_t gpio_io_agent;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction : new

virtual function void build_phase(uvm_phase phase);
gpio_agent = gpio_agent_t::type_id::create("gpio_agent", this);
gpio_cov_coll = gpio_cov_coll_t::type_id::create("gpio_cov_coll", this);
gpio_io_agent = gpio_io_agent_t::type_id::create("gpio_io_agent", this);
endfunction : build_phase

virtual function void connect_phase(uvm_phase phase);
gpio_agent.gpio_monitor.gpio_port.connect(gpio_cov_coll.gpio_export);
gpio_io_agent.gpio_io_monitor.gpio_io_port.connect(gpio_cov_coll.gpio_io_export);
endfunction : connect_phase
endclass : gpio_env_t
