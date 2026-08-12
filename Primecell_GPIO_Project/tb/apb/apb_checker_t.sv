import uvm_pkg::*;
`include "uvm_macros.svh"

module apb_checker_t(

    input logic        PRESETn,
    input logic        PCLK,

    input logic        PSEL,
    input logic        PENABLE,
    input logic        PWRITE,

    input logic [31:0] PADDR,
    input logic [31:0] PWDATA,
    input logic [31:0] PRDATA
);

default clocking @(posedge PCLK); endclocking
default disable iff(!PRESETn);

// Sequence=============================================================

sequence q_idle_phase;
    !PSEL && !PENABLE;
endsequence

sequence q_setup_phase;
    $rose(PSEL) && !PENABLE;
endsequence

sequence q_access_phase;
    PSEL && PENABLE;
endsequence

sequence q_write_access;
    PSEL && PENABLE && PWRITE;
endsequence

sequence q_read_access;
    PSEL && PENABLE && !PWRITE;
endsequence

// Property===============================================================

property p_idle_to_setup;
    q_idle_phase |=> q_setup_phase;
endproperty

property p_setup_to_access;
    q_setup_phase |=> q_access_phase;
endproperty

property p_setup_to_access_condition;
    q_setup_phase |=>
        (($stable(PADDR) &&
          $stable(PWRITE) &&
          $stable(PWDATA) &&
          $stable(PSEL))
         until_with
         q_access_phase);
endproperty

property p_access_to_idle;
    q_access_phase |=> q_idle_phase;
endproperty

property p_psel_asserted_during_access;
    q_access_phase |-> PSEL;
endproperty

ap_psel_asserted_during_access :
    assert property (p_psel_asserted_during_access)
    else $error("p_psel_asserted_during_access assertion failed");

ap_idle_to_setup :
    assert property (p_idle_to_setup)
    else $error("p_idle_to_setup assertion failed");

ap_setup_to_access :
    assert property (p_setup_to_access)
    else $error("p_setup_to_access assertion failed");

ap_setup_to_access_condition :
    assert property (p_setup_to_access_condition)
    else $error("p_setup_to_access_condition assertion failed");

ap_access_to_idle :
    assert property (p_access_to_idle)
    else $error("p_access_to_idle assertion failed");


endmodule : apb_checker_t
