import uvm_pkg::*;
`include "uvm_macros.svh"

module gpio_checker_t (

    input logic         PCLK,
    input logic         PRESETn,

    // APB
    input logic         PSEL,
    input logic         PENABLE,
    input logic         PWRITE,
    input logic [31:0]  PADDR,
    input logic [31:0]  PRDATA,
    input logic [31:0]  PWDATA,
  
    // GPIO
    input logic [7:0]   gpio_data,
    input logic [7:0]   gpio_ie,
    input logic [7:0]   gpio_mis,
    input logic [7:0]   gpio_ris,
    input logic [7:0]   gpio_ic,
    input logic [7:0]   gpio_iev,
    input logic [7:0]   gpio_ibe,
    input logic [7:0]   gpio_is,
    input logic [7:0]   gpio_af_sel,
    input logic [7:0]   nGPAFEN,
    input logic [7:0]   gpio_ic_reset_cond
);

default clocking @(posedge PCLK); endclocking
default disable iff (!PRESETn);

//----------------------------------------------------
// Sequence
//----------------------------------------------------

generate
    for(genvar i=0; i<8; i++) begin : GEN_SEQ

        sequence q_rising_edge;
            !gpio_ibe[i] && gpio_iev[i] && !gpio_is[i];
        endsequence

        sequence q_falling_edge;
            !gpio_ibe[i] && !gpio_iev[i] && !gpio_is[i];
        endsequence

        sequence q_both_edge;
            gpio_ibe[i] && !gpio_iev[i] && !gpio_is[i];
        endsequence

        sequence q_high_level;
            gpio_iev[i] && gpio_is[i];
        endsequence

        sequence q_low_level;
            !gpio_iev[i] && gpio_is[i];
        endsequence

        sequence q_SW_cntl_mode;
            !gpio_af_sel[i];
        endsequence

        sequence q_HW_cntl_mode;
            gpio_af_sel[i];
        endsequence

    end
endgenerate

sequence q_write_access;
    PSEL && PENABLE && PWRITE;
endsequence

sequence q_read_access;
    PSEL && PENABLE && !PWRITE;
endsequence

sequence q_data_reg_access;
   (PADDR[11:0] inside {[12'h00 : 12'h3FF]}) &&
   (PADDR[31:12] == 'h00000);
endsequence 
//----------------------------------------------------
// Property
//----------------------------------------------------

generate
    for(genvar i=0; i<8; i++) begin : GEN_PROP

        property p_zero_mask_no_data_update_when_write_access;
            q_write_access and !PADDR[i+2]
            |=> $stable(gpio_data[i]);
        endproperty

        ap_zero_mask_no_data_update_when_write_access :
            assert property (p_zero_mask_no_data_update_when_write_access)
            else $error("p_zero_mask_no_data_update_when_write_access assertion failed");


        property p_zero_mask_return_zero_when_read_access;
          q_read_access and !PADDR[i+2] and q_data_reg_access
            |=> !PRDATA[i];
        endproperty
         
        ap_zero_mask_return_zero_when_read_access :
            assert property (p_zero_mask_return_zero_when_read_access)
            else $error("p_zero_mask_return_zero_when_read_access assertion failed");


        property p_zero_ie_mask_no_mis_high;
            !gpio_ie[i]
            |-> !gpio_mis[i];
        endproperty
        
        ap_zero_ie_mask_no_mis_high :
            assert property (p_zero_ie_mask_no_mis_high)
            else $error("p_zero_ie_mask_no_mis_high assertion failed");


        property p_edge_intr_requires_clear;
           ((!gpio_iev[i] || !gpio_ibe[i]) && !gpio_is[i]) && gpio_mis[i]
          |-> gpio_ic_reset_cond[i]|=> ##[0:3](!gpio_ic_reset_cond[i] || !gpio_ris[i]);
        endproperty

        ap_edge_intr_requires_clear :
            assert property (p_edge_intr_requires_clear)
            else $error("p_edge_intr_requires_clear assertion failed");

    end
endgenerate

endmodule : gpio_checker_t




        

