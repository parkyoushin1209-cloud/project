`include "uvm_macros.svh"
import uvm_pkg::*;
import gpio_component_pkg::*;
import apb_component_pkg::*;
import gpio_reg_model_pkg::*;


class gpio_system_env_t extends uvm_env;
`uvm_component_utils(gpio_system_env_t)

apb_env_t apb;
gpio_env_t gpio;
gpio_scoreboard_t gpio_scoreboard;
gpio_reg_block_t regmodel;
vsequencer_t vsequencer;
virtual reset_if reset_vif;

  
function new(string name, uvm_component parent);
super.new(name, parent);
endfunction : new

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
  apb = apb_env_t::type_id::create("apb", this);
  gpio = gpio_env_t::type_id::create("gpio", this);
  regmodel = gpio_reg_block_t::type_id::create("regmodel");
  regmodel.build();
  regmodel.set_hdl_path_root("tb_top.gpio_dut");
  regmodel.lock_model();
  regmodel.default_map.set_auto_predict(0);
  uvm_config_db #(gpio_reg_block_t)::set(null, "*", "regmodel", regmodel);
  gpio_scoreboard = gpio_scoreboard_t::type_id::create("gpio_scoreboard", this);
  vsequencer = vsequencer_t::type_id::create("vsequencer", this);
  if(!uvm_config_db#(virtual reset_if)::get(this, "", "reset_vif", reset_vif))
     `uvm_error("NOVIF", {"virtual interface must be set for", get_full_name(), ".vif"})
endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    regmodel.reset();
  
  
    
  endfunction : end_of_elaboration_phase

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
apb.apb_agent.apb_monitor.apb_port.connect(gpio_scoreboard.apb_export);
gpio.gpio_agent.gpio_monitor.gpio_port.connect(gpio_scoreboard.gpio_export);
gpio.gpio_io_agent.gpio_io_monitor.gpio_io_port.connect(gpio_scoreboard.gpio_io_export);
vsequencer.apb_sequencer = apb.apb_agent.apb_sequencer;
vsequencer.gpio_sequencer = gpio.gpio_agent.gpio_sequencer;
endfunction : connect_phase

virtual function void get_sequencer(ref sqr_aggregator_t sqrs);
  sqrs.add(apb.apb_agent.get_sequencer(), "control", "control");
  sqrs.add(gpio.gpio_agent.get_sequencer(), "data", "data");
endfunction : get_sequencer
  
virtual task run_phase(uvm_phase phase);
  fork
    monitor_reset();
  join
endtask : run_phase
     
virtual task monitor_reset();
   forever begin
     @(negedge reset_vif.PRESETn);
       `uvm_info("ENV", "env reset start...", UVM_LOW)
         
       regmodel.reset();
     $display("   gpio_data  = %h (%8b) | gpio_dir   = %h (%8b)", regmodel.GPIODATA.get(),  regmodel.GPIODATA.get(),  regmodel.GPIODIR.get(),  regmodel.GPIODIR.get());
     $display("   gpio_is    = %h (%8b) | gpio_ibe   = %h (%8b)", regmodel.GPIOIS.get(),    regmodel.GPIOIS.get(),    regmodel.GPIOIBE.get(),  regmodel.GPIOIS.get());
     $display("   gpio_iev   = %h (%8b) | gpio_ie    = %h (%8b)", regmodel.GPIOIEV.get(),   regmodel.GPIOIEV.get(),   regmodel.GPIOIE.get(),   regmodel.GPIOIE.get());
     $display("   gpio_ris   = %h (%8b) | gpio_mis   = %h (%8b)", regmodel.GPIORIS.get(),   regmodel.GPIORIS.get(),   regmodel.GPIOMIS.get(),  regmodel.GPIOMIS.get());
     $display("   gpio_ic    = %h (%8b) | gpio_afsel = %h (%8b)", regmodel.GPIOIC.get(),    regmodel.GPIOIC.get(),  regmodel.GPIOAFSEL.get(), regmodel.GPIOAFSEL.get());
   end
  wait(reset_vif.PRESETn);
endtask : monitor_reset
endclass : gpio_system_env_t
