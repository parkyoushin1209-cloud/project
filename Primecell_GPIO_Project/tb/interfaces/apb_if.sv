`include "uvm_macros.svh"
import uvm_pkg::*;

interface apb_if(input logic PCLK, PRESETn);
  
    // APB2
    logic                   PSEL;
    logic                   PENABLE;
    logic                   PWRITE;
  logic [31:0]              PADDR;
  logic [31:0]              PRDATA;
  logic [31:0]              PWDATA; 

    // APB3
    logic                   PREADY;
    logic                   PSLVERR;

    // APB4
    logic [2:0]              PPROT;
    logic [3:0] PSTRB;

    // APB5
    logic                    PNSE;
    logic                    PWAKEUP;

    // ABP5 parity check signal
  logic [3:0] PADDRCHK;
    logic                    PCTRLCHK;
    logic                    PSELCHK;
    logic                    PENABLECHK;
  logic [3:0] PWDATACHK;
    logic                    PSTRBCHK;
    logic                    PREADYCHK;
  logic [3:0] PRDATACHK;
    logic                    PSLVERRCHK;
    logic                    PWAKEUPCHK;
    
    clocking drv_cb @(posedge PCLK); // 마스터
    default input #1step output #0;
    input PREADY, PSLVERR, PRDATA;
    output PSEL, PENABLE, PWRITE, PADDR, PWDATA, PPROT, PSTRB, PNSE, PWAKEUP;  
    endclocking : drv_cb

    clocking mon_cb @(posedge PCLK); // 패시브
    default input #1step;
    input PSEL, PWDATA, PWRITE, PADDR, PENABLE;
    input PRDATA, PSLVERR;
    endclocking : mon_cb

    
    modport DUT(input PSEL, PWDATA, PWRITE, PADDR, PCLK, PRESETn,
                output PRDATA, PSLVERR, PREADY);
  
endinterface : apb_if
    
