`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_transaction_pkg::*;

class apb_monitor_t extends uvm_monitor;
`uvm_component_utils(apb_monitor_t)

virtual apb_if apb_vif;
uvm_analysis_port #(apb_transaction) apb_port;
bit checks_enable, coverage_enable;
apb_transaction apb_tr;

function new(string name, uvm_component parent);
super.new(name, parent);
apb_port = new("apb_port", this);
endfunction : new

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif))
`uvm_error("NOVIF", {"virtual interface must be set for ", get_full_name(), ".vif"})
void'(uvm_config_int::get(this, "", "checks_enable", checks_enable));
void'(uvm_config_int::get(this, "", "coverage_enable", coverage_enable));
endfunction : build_phase

virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
  apb_tr = apb_transaction::type_id::create("apb_tr");
    forever begin

        fork : monitor_thread
      
      begin
      @(negedge apb_vif.PRESETn)
      `uvm_info("RESET", "Reset signal asserted", UVM_LOW)
      end 

      forever begin
      @(posedge apb_vif.mon_cb.PSEL);
      @(posedge apb_vif.mon_cb.PENABLE);
     
      @(apb_vif.mon_cb);
     // $display("@time:%0t, APB_MON:PRDATA=%h", $time, apb_vif.mon_cb.PRDATA);
          if(apb_vif.mon_cb.PWRITE == 1) begin
            apb_tr.data = apb_vif.mon_cb.PWDATA;
            apb_tr.kind = apb_transaction::WRITE;
          end else begin 
            apb_tr.data = apb_vif.mon_cb.PRDATA;
            apb_tr.kind = apb_transaction::READ;
          end

          apb_tr.addr  = apb_vif.mon_cb.PADDR;
  // $display("time:%0t ,MON: apb_tr : data=%h, addr=%h, kind=%s\n", $time, apb_tr.data, apb_tr.addr, apb_tr.kind.name());
          apb_port.write(apb_tr);
    end
    join_any

    disable monitor_thread;
     
      @(posedge apb_vif.PRESETn);


    end
endtask : run_phase
endclass : apb_monitor_t
