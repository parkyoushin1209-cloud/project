`include "uvm_macros.svh"
import uvm_pkg::*;

interface gpio_io_if(input logic PCLK, PRESETn);

  logic[7:0] nGPEN;
  logic[7:0] GPOUT;
  logic[7:0] GPIN;
  tri[7:0] XP;


  clocking mon_cb @(posedge PCLK);
default input #1step;
input GPIN, GPOUT, nGPEN, XP;
endclocking : mon_cb

modport DUT(output GPIN, GPOUT, nGPEN, XP);

endinterface : gpio_io_if
