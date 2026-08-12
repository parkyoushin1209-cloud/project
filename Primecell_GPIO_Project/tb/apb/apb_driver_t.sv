`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_transaction_pkg::*;


class apb_driver_t extends uvm_driver #(apb_transaction);
`uvm_component_utils(apb_driver_t)

virtual apb_if apb_vif;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction : new

extern virtual function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
extern virtual protected task get_and_drive();
extern virtual protected task drive_transfer(apb_transaction apb_tr);
extern virtual protected task driver_reset();
endclass : apb_driver_t

function void apb_driver_t::build_phase(uvm_phase phase);
if(!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif))
`uvm_error("NOVIF", {"virtual interface must be set for ", get_full_name(), ".vif"})
endfunction : build_phase

task apb_driver_t::run_phase(uvm_phase phase);
fork
    get_and_drive();
join
endtask : run_phase

task apb_driver_t::get_and_drive();
forever begin

  fork
      
      @(negedge apb_vif.PRESETn)
      driver_reset();
      

      forever begin
        seq_item_port.get_next_item(req);
        drive_transfer(req);
        `uvm_info("DRV", "sequence_drive_finish", UVM_HIGH)
        seq_item_port.item_done();
      end
  join_any

   disable fork;

     @(posedge apb_vif.PRESETn);
end
endtask : get_and_drive

task apb_driver_t::drive_transfer(apb_transaction apb_tr);

@(apb_vif.drv_cb);
// setup
apb_vif.drv_cb.PADDR <= apb_tr.addr;
  if(apb_tr.kind == apb_transaction::WRITE) begin
apb_vif.drv_cb.PWRITE <= 1;
apb_vif.drv_cb.PWDATA <= apb_tr.data;
end else begin
  apb_vif.drv_cb.PWRITE <= 0;
end
apb_vif.drv_cb.PSEL <= 1;

@(apb_vif.drv_cb);
  //enable(access)
apb_vif.drv_cb.PENABLE <= 1;

  @(apb_vif.drv_cb);
apb_vif.drv_cb.PSEL <= 0;
apb_vif.drv_cb.PENABLE <= 0;

endtask : drive_transfer

task apb_driver_t::driver_reset();
  
`uvm_info("RESET", "reset signal asserted", UVM_LOW)

if(req != null) begin
    this.end_tr(req);
    seq_item_port.item_done();
    req = null;
end

apb_vif.PSEL = 0;
apb_vif.PENABLE = 0;
apb_vif.PWRITE = 0;
apb_vif.PADDR = 0;
apb_vif.PWDATA = 0;
apb_vif.PRDATA = 0;
endtask : driver_reset

