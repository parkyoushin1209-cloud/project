`include "uvm_macros.svh"
import uvm_pkg::*;

interface gpio_core_if(input logic PCLK, PRESETn);
  logic[7:0] GPIOMIS;
  logic      GPIOINTR;
  logic[7:0] nGPAFEN = 8'b1111_1111;
  logic[7:0] GPAFOUT;
  logic[7:0] GPAFIN;
bit              WRITE_EN;

clocking drv_cb @(posedge PCLK);
default input #1step output #0;
output nGPAFEN, GPAFOUT;
input GPAFIN, GPIOMIS, GPIOINTR;
endclocking : drv_cb

clocking mon_cb @(posedge PCLK);
default input #1step;
input nGPAFEN, GPAFOUT, GPAFIN, GPIOMIS, GPIOINTR;
endclocking : mon_cb


endinterface : gpio_core_if
