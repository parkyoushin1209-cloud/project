import uvm_pkg::*;
`include "uvm_macros.svh"

class sqr_aggregator_t extends uvm_object;
`uvm_object_utils(sqr_aggregator_t)

typedef uvm_sequencer_base sqr_q_t[$];

local uvm_sequencer_base sqr_table[string];
local uvm_sequencer_base name_table[string];
local sqr_q_t kind_table[string];

function new(string name = "sqr_aggregator_t");
super.new(name);
endfunction : new

virtual function void add(uvm_sequencer_base sqr, string name, string kind);
sqr_q_t q;
string path = sqr.get_full_name();
sqr_table[path] = sqr;

if(kind != "") begin
    if(kind_table.exists(kind))
      q = kind_table[kind];
    q.push_back(sqr);
    kind_table[kind] = q;
end

if(name != "") begin
    if(name_table.exists(name))
      `uvm_info("SQR_AGGREGATOR", $sformatf("replacing sequencer with name %s", name), UVM_NONE)
    name_table[name] = sqr;
end
endfunction : add

virtual function uvm_sequencer_base lookup_name(string name);
  if(name_table.exists(name)) return name_table[name];
  else return null;
endfunction : lookup_name

virtual function uvm_sequencer_base lookup_path(string path);
  if(sqr_table.exists(path)) return sqr_table[path];
  else return null;
endfunction : lookup_path

virtual function sqr_q_t lookup_kind(string kind);
if(kind_table.exists(kind)) return kind_table[kind];
else return null;
endfunction : lookup_kind
  
virtual function void clear();
sqr_table.delete();
name_table.delete();
foreach(kind_table[kind]) kind_table[kind].delete();
endfunction : clear
  
endclass : sqr_aggregator_t
