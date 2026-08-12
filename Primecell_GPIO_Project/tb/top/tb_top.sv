`include "uvm_macros.svh"
import uvm_pkg::*;

import gpio_test_pkg::*;

module tb_top;

parameter string runner_cfg = "";
reset_if reset_if_inst();
  
logic PCLK = 0;
bit coverage_enable = 1, checks_enable;
  
  apb_if apb_if_inst(PCLK, reset_if_inst.PRESETn);
gpio_io_if gpio_io_if_inst(PCLK, reset_if_inst.PRESETn);
gpio_core_if gpio_core_if_inst(PCLK, reset_if_inst.PRESETn);

GPIO gpio_dut( .PRESETn(reset_if_inst.PRESETn),
               .PADDR(apb_if_inst.PADDR[11:0]),
               .PCLK(PCLK),
               .PENABLE(apb_if_inst.PENABLE), 
               .PRDATA(apb_if_inst.PRDATA[7:0]),
               .PSEL(apb_if_inst.PSEL),
               .PWDATA(apb_if_inst.PWDATA[7:0]),
               .PWRITE(apb_if_inst.PWRITE),
               .nGPEN(gpio_io_if_inst.nGPEN[7:0]),
               .GPOUT(gpio_io_if_inst.GPOUT[7:0]),
               .GPIN(gpio_io_if_inst.GPIN[7:0]),
               .XP(gpio_io_if_inst.XP[7:0]),
               .nGPAFEN(gpio_core_if_inst.nGPAFEN[7:0]),
               .GPAFOUT(gpio_core_if_inst.GPAFOUT[7:0]),
               .GPAFIN(gpio_core_if_inst.GPAFIN[7:0]),
               .GPIOMIS(gpio_core_if_inst.GPIOMIS[7:0]),
               .GPIOINTR(gpio_core_if_inst.GPIOINTR)
);

bind gpio_dut gpio_checker_t gpio_checker(.*);
bind gpio_dut apb_checker_t apb_checker(.*);
  
initial forever #5ns PCLK = !PCLK;

initial begin
  $assertoff(0, tb_top.gpio_dut.gpio_checker);
  $assertoff(0, tb_top.gpio_dut.apb_checker);
  
  repeat(5) @(posedge PCLK);
  reset_if_inst.PRESETn = 0;
  repeat(5) @(posedge PCLK);
  reset_if_inst.PRESETn = 1;
  $asserton(0, tb_top.gpio_dut.gpio_checker);
  $asserton(0, tb_top.gpio_dut.apb_checker);
  `uvm_info("START", "PRESETn signal is deasserted", UVM_LOW)
  
end
  
initial begin
  uvm_config_int::set(null, "*", "coverage_enable", coverage_enable);
  uvm_config_int::set(null, "*", "checks_enable", checks_enable);
  uvm_config_db #(virtual reset_if)::set(null, "*", "reset_vif", reset_if_inst);
  uvm_config_db #(virtual apb_if)::set(null, "*", "apb_vif", apb_if_inst);
  uvm_config_db #(virtual gpio_core_if)::set(null, "*", "gpio_core_vif", gpio_core_if_inst);
  uvm_config_db #(virtual gpio_io_if)::set(null, "*", "gpio_io_vif", gpio_io_if_inst);
  run_test("gpio_lib_test");
end


endmodule : tb_top
