`include "uvm_macros.svh"
import uvm_pkg::*;
import gpio_transaction_pkg::*;

class gpio_driver_t extends uvm_driver #(gpio_transaction);
`uvm_component_utils(gpio_driver_t)

virtual gpio_core_if gpio_core_vif;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction : new

extern virtual function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
extern virtual protected task get_and_drive();
extern virtual protected task drive_transfer(gpio_transaction gpio_tr);
extern virtual protected task driver_reset();
endclass : gpio_driver_t

function void gpio_driver_t::build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(virtual gpio_core_if)::get(this, "", "gpio_core_vif", gpio_core_vif))
`uvm_error("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"})

endfunction : build_phase

task gpio_driver_t::run_phase(uvm_phase phase);
fork 
get_and_drive();
join
endtask : run_phase

task gpio_driver_t::get_and_drive();
forever begin
    fork
         
        @(negedge gpio_core_vif.PRESETn) begin
        driver_reset();
        end

        forever begin
          seq_item_port.get_next_item(req);
          drive_transfer(req);
          seq_item_port.item_done();
        end
    join_any

    disable fork;

    

      @(posedge gpio_core_vif.PRESETn);
end
endtask : get_and_drive

task gpio_driver_t::drive_transfer(gpio_transaction gpio_tr);

  gpio_core_vif.WRITE_EN <= 0;
@(gpio_core_vif.drv_cb);
  

@(gpio_core_vif.drv_cb);

  gpio_core_vif.drv_cb.nGPAFEN <= gpio_tr.nGPAFEN;
  gpio_core_vif.drv_cb.GPAFOUT <= gpio_tr.GPAFOUT;
@(gpio_core_vif.drv_cb);
gpio_core_vif.WRITE_EN                      <= 1;

endtask : drive_transfer

task gpio_driver_t::driver_reset();
`uvm_info("RESET", "reset signal asserted", UVM_HIGH)

if(req != null) begin
        this.end_tr(req);            
        seq_item_port.item_done();
        req = null;
end



gpio_core_vif.WRITE_EN      = 0;
gpio_core_vif.nGPAFEN       = 8'b1111_1111;
gpio_core_vif.GPIOMIS       = 0;
gpio_core_vif.GPIOINTR      = 0;
gpio_core_vif.GPAFOUT       = 0;
gpio_core_vif.GPAFIN        = 0;


endtask : driver_reset
