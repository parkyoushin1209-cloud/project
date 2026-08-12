import uvm_pkg::*;
`include "uvm_macros.svh"
import gpio_component_pkg::*;

class gpio_base_test extends uvm_test;
  `uvm_component_utils(gpio_base_test)
  
  gpio_system_env_t gpio_system_env;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    gpio_system_env = gpio_system_env_t::type_id::create("gpio_system_env", this);
  endfunction : build_phase
  
  virtual function void phase_ready_to_end(uvm_phase phase);
    if(phase.get_name() == "run") begin
      if(gpio_system_env != null && gpio_system_env.gpio_scoreboard != null) begin
        if(!gpio_system_env.gpio_scoreboard.is_q_empty()) begin
          `uvm_info("TEST", "Scoreboard queues are not empty waiting for comparison to finish", UVM_LOW)
          phase.raise_objection(this);
          
          fork
            begin
              while (!gpio_system_env.gpio_scoreboard.is_q_empty()) begin
                    #1ns;
              end
              #15ns;
              phase.drop_objection(this);
            end
          join_none
        end
      end
    end
  endfunction : phase_ready_to_end
  
  
endclass : gpio_base_test
