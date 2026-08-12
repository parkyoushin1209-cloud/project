import uvm_pkg::*;
`include "uvm_macros.svh"
import gpio_transaction_pkg::*;
import gpio_sequence_pkg::*;

class gpio_reg_lib_seq_t extends uvm_sequence_library#(gpio_transaction);
`uvm_object_utils(gpio_reg_lib_seq_t)
`uvm_sequence_library_utils(gpio_reg_lib_seq_t)

function new(string name = "gpio_reg_lib_seq_t");
super.new(name);
min_random_count  = 1000;
max_random_count  = 1000;
add_typewide_sequence(gpio_seq_t::type_id::get());
init_sequence_library();
endfunction : new

endclass : gpio_reg_lib_seq_t
