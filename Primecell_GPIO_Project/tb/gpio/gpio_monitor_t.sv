`include "uvm_macros.svh"
import uvm_pkg::*;
import gpio_transaction_pkg::*;

class gpio_monitor_t extends uvm_monitor;
`uvm_component_utils(gpio_monitor_t)

virtual gpio_core_if gpio_core_vif;
bit checks_enable, coverage_enable;
uvm_analysis_port #(gpio_transaction) gpio_port;
gpio_transaction gpio_tr;

function new(string name, uvm_component parent);
super.new(name, parent);
gpio_port = new("gpio_port", this);
endfunction : new

extern virtual function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
endclass : gpio_monitor_t


function void gpio_monitor_t::build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(virtual gpio_core_if)::get(this, "", "gpio_core_vif", gpio_core_vif))
`uvm_error("NOVIR", {"virtual interface must be set for:", get_full_name(), ".vif"})
void'(uvm_config_int::get(this, "", "checks_enable", checks_enable));
void'(uvm_config_int::get(this, "", "coverage_enable", coverage_enable));
endfunction : build_phase

  
task gpio_monitor_t::run_phase(uvm_phase phase);
super.run_phase(phase);
gpio_tr = gpio_transaction::type_id::create("gpio_tr");

forever begin

    fork : monitor_thread

    begin
        @(negedge gpio_core_vif.PRESETn);
        `uvm_info("RESET", "Reset signal asserted", UVM_LOW)
        
    end 

    forever begin
    @(posedge gpio_core_vif.WRITE_EN);
    gpio_tr.nGPAFEN = gpio_core_vif.mon_cb.nGPAFEN;
    gpio_tr.GPAFOUT = gpio_core_vif.mon_cb.GPAFOUT;
  @(gpio_core_vif.mon_cb);
  @(gpio_core_vif.mon_cb);
    gpio_tr.GPAFIN   = gpio_core_vif.mon_cb.GPAFIN;
    gpio_tr.GPIOMIS  = gpio_core_vif.mon_cb.GPIOMIS;
    gpio_tr.GPIOINTR = gpio_core_vif.mon_cb.GPIOINTR;
    gpio_port.write(gpio_tr);
//$display("@time:%0t : MON : GPAFOUT:%h(%8b), GPAFIN:%h(%8b), nGPAFEN:%h(%8b), GPIOMIS:%h(%8b), GPIOINTR:%b", $time, gpio_tr.GPAFOUT, gpio_tr.GPAFOUT, gpio_tr.GPAFIN, gpio_tr.GPAFIN, gpio_tr.nGPAFEN, gpio_tr.nGPAFEN, gpio_tr.GPIOMIS, gpio_tr.GPIOMIS, gpio_tr.GPIOINTR);
    end 

    join_any

  disable monitor_thread;
  
  @(posedge gpio_core_vif.PRESETn);
end
endtask : run_phase
