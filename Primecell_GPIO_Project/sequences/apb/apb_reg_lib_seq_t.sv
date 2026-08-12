import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_transaction_pkg::*;
import apb_sequence_pkg::*;

class apb_reg_lib_seq_t extends uvm_sequence_library#(apb_transaction);
`uvm_object_utils(apb_reg_lib_seq_t)
`uvm_sequence_library_utils(apb_reg_lib_seq_t)

function new(string name = "apb_reg_lib_seq_t");
super.new(name);
min_random_count = 1000;
max_random_count = 1000;
add_typewide_sequence(apb_af_sel_reg_seq_t::type_id::get());
add_typewide_sequence(apb_data_reg_seq_t::type_id::get());
add_typewide_sequence(apb_dir_reg_seq_t::type_id::get());
add_typewide_sequence(apb_ibe_reg_seq_t::type_id::get());
add_typewide_sequence(apb_ic_reg_seq_t::type_id::get());
add_typewide_sequence(apb_ie_reg_seq_t::type_id::get());
add_typewide_sequence(apb_iev_reg_seq_t::type_id::get());
add_typewide_sequence(apb_is_reg_seq_t::type_id::get());
add_typewide_sequence(apb_mis_reg_seq_t::type_id::get());
add_typewide_sequence(apb_pcellid_reg_seq_t::type_id::get());
add_typewide_sequence(apb_periphid_reg_seq_t::type_id::get());
add_typewide_sequence(apb_ris_reg_seq_t::type_id::get());
add_typewide_sequence(apb_seq_t::type_id::get());
init_sequence_library();
endfunction : new

endclass : apb_reg_lib_seq_t

