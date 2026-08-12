`include "uvm_macros.svh"
import uvm_pkg::*;
import gpio_transaction_pkg::*;


class gpio_io_monitor_t extends uvm_monitor;
`uvm_component_utils(gpio_io_monitor_t)

virtual gpio_io_if gpio_io_vif;
uvm_analysis_port #(gpio_io_transaction) gpio_io_port;
gpio_io_transaction gpio_io_tr;

function new(string name, uvm_component parent);
super.new(name, parent);
gpio_io_port = new("gpio_io_port", this);
endfunction : new

extern virtual function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
endclass : gpio_io_monitor_t


function void gpio_io_monitor_t::build_phase(uvm_phase phase);
super.build_phase(phase);
  if(!uvm_config_db#(virtual gpio_io_if)::get(this, "", "gpio_io_vif", gpio_io_vif))
    `uvm_error("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"})
    
endfunction : build_phase

    
task gpio_io_monitor_t::run_phase(uvm_phase phase);
super.run_phase(phase);
forever begin
    fork : monitor_thread

    begin
    @(negedge gpio_io_vif.PRESETn) 
    `uvm_info("RESET", "Reset signal asserted", UVM_LOW)
    end

    forever begin
  @(gpio_io_vif.mon_cb); 
  gpio_io_tr = gpio_io_transaction::type_id::create("gpio_io_tr");
 // $display("time:%0t, gpio_io_vif : nGPEN=%8b, GPOUT=%8b, GPIN=%8b, XP=%8b", $time, gpio_io_vif.nGPEN, gpio_io_vif.GPOUT, gpio_io_vif.GPIN, gpio_io_vif.XP); 
    gpio_io_tr.nGPEN = gpio_io_vif.mon_cb.nGPEN;
    gpio_io_tr.GPOUT = gpio_io_vif.mon_cb.GPOUT;
    gpio_io_tr.GPIN  = gpio_io_vif.mon_cb.GPIN;
    gpio_io_tr.XP    = gpio_io_vif.mon_cb.XP;
 // $display("@time:%t MON gpio_io_tr : nGPEN=%8b, GPOUT=%8b, GPIN=%8b, XP=%8b",$time,  gpio_io_tr.nGPEN, gpio_io_tr.GPOUT, gpio_io_tr.GPIN, gpio_io_tr.XP);
  gpio_io_port.write(gpio_io_tr);
  `uvm_info("MON", "finish gpio_io_write", UVM_HIGH)
    end

    join_any
    
    disable monitor_thread;
  
  @(posedge gpio_io_vif.PRESETn);
end
endtask : run_phase
