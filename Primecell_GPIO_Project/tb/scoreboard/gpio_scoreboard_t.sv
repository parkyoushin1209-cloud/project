`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_transaction_pkg::*;
import gpio_transaction_pkg::*;
import gpio_reg_model_pkg::*;

`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_gpio)
`uvm_analysis_imp_decl(_gpio_io)

class gpio_scoreboard_t extends uvm_scoreboard;
  `uvm_component_utils(gpio_scoreboard_t)

apb_transaction apb_trans_queue[$];
gpio_transaction gpio_trans_queue[$];
gpio_io_transaction gpio_io_observed_queue[$];

uvm_analysis_imp_apb #(apb_transaction, gpio_scoreboard_t) apb_export;
uvm_analysis_imp_gpio #(gpio_transaction, gpio_scoreboard_t) gpio_export;
uvm_analysis_imp_gpio_io #(gpio_io_transaction, gpio_scoreboard_t) gpio_io_export;

virtual reset_if reset_vif;
  
gpio_reg_block_t regmodel;

//예측치 계산에 사용할 값들
logic[7:0] gpio_data;
  logic[7:0] gpio_dir ='h00;
  logic[7:0] gpio_afsel ='h00;
  logic[7:0] gpio_is ='h00;
  logic[7:0] gpio_ibe ='h00;
  logic[7:0] gpio_iev ='h00;
  logic[7:0] gpio_ie ='h00;
  logic[7:0] gpio_ris ='h00;
  logic[7:0] gpio_mis ='h00;
  logic[7:0] gpio_ic ='h00;
logic[7:0] gpio_periphid0 ='h61;
logic[7:0] gpio_periphid1 = 'h10;
logic[7:0] gpio_periphid2 = 'h04;
logic[7:0] gpio_periphid3 = 'h00;
logic[7:0] gpio_pcellid0 = 'h0d;
logic[7:0] gpio_pcellid1 = 'h0f;
logic[7:0] gpio_pcellid2 = 'h05;
logic[7:0] gpio_pcellid3 = 'hb1; 

logic[7:0] selected_bit; // 주소 마스크 처리용 8비트 logic
logic[7:0] value; // regmodel에 작성할 값
logic[7:0] prev, GPINSync2;  

int unsigned print_trigger = 0;
  
apb_transaction apb_tr;
gpio_transaction gpio_tr;
gpio_io_transaction gpio_io_tr_act;
string reg_sel = "";
  
int unsigned w_gpio_data_cnt, w_gpio_dir_cnt, w_gpio_afsel_cnt, w_gpio_is_cnt, w_gpio_ibe_cnt, w_gpio_iev_cnt, w_gpio_ie_cnt, w_gpio_ris_cnt, w_gpio_mis_cnt, w_gpio_ic_cnt;
int unsigned w_gpio_periphid0_cnt, w_gpio_periphid1_cnt, w_gpio_periphid2_cnt, w_gpio_periphid3_cnt, w_reserved_cnt;
int unsigned r_gpio_data_cnt, r_gpio_dir_cnt, r_gpio_afsel_cnt, r_gpio_is_cnt, r_gpio_ibe_cnt, r_gpio_iev_cnt, r_gpio_ie_cnt, r_gpio_ris_cnt, r_gpio_mis_cnt, r_gpio_ic_cnt;
int unsigned r_gpio_periphid0_cnt, r_gpio_periphid1_cnt, r_gpio_periphid2_cnt, r_gpio_periphid3_cnt, r_reserved_cnt;
int unsigned w_gpio_pcellid0_cnt, w_gpio_pcellid1_cnt, w_gpio_pcellid2_cnt, w_gpio_pcellid3_cnt;
int unsigned r_gpio_pcellid0_cnt, r_gpio_pcellid1_cnt, r_gpio_pcellid2_cnt, r_gpio_pcellid3_cnt;
int unsigned intr_mismatch, read_mismatch, io_mismatch, core_mismatch;
bit apb_receive_done, gpio_core_receive_done; 

  typedef enum bit[3:0] {IDLE, RISING, FALLING, BOTHEDGE, HIGH, LOW} intr_detection_logic_e;
intr_detection_logic_e intr_detec_logic[8];
logic[7:0] intr_event;
logic[7:0] ic_reset_cond;
logic[7:0] prev_GPIN, prev_nGPEN, prev_GPOUT;

function new(string name, uvm_component parent);
super.new(name, parent);
apb_export = new("apb_export", this);
gpio_export = new("gpio_export", this);
gpio_io_export = new("gpio_io_export", this);
endfunction : new

virtual function void build_phase(uvm_phase phase);
if(!uvm_config_db#(gpio_reg_block_t)::get(this, "", "regmodel", regmodel))
`uvm_fatal("NO_REGMODEL", "There is no regmodel")
  if(!uvm_config_db#(virtual reset_if)::get(this, "", "reset_vif", reset_vif))
     `uvm_error("NOVIF", {"virtual interface must be set for", get_full_name(), ".vif"})
endfunction : build_phase


virtual function void write_apb(apb_transaction apb_tr);
apb_trans_queue.push_back(apb_tr);
apb_receive_done = 1;
  
endfunction : write_apb

virtual function void write_gpio(gpio_transaction gpio_tr);
gpio_trans_queue.push_back(gpio_tr);
gpio_core_receive_done = 1;

 
endfunction : write_gpio

virtual function void write_gpio_io(gpio_io_transaction gpio_io_tr);

gpio_io_observed_queue.push_back(gpio_io_tr);

endfunction : write_gpio_io

   extern virtual task run_phase(uvm_phase phase);
   extern virtual function void compare_io_result(gpio_io_transaction exp);
   extern virtual function void update_cache();
   extern virtual function void predict();
   extern virtual function void expect_result(gpio_transaction act);
   extern virtual function void compare_core_result(gpio_transaction exp, gpio_transaction act);
   extern virtual function bit is_q_empty();
     extern virtual function void print_info(string arg = "");
   extern virtual function void scoreboard_reset();
   extern virtual function void report_phase(uvm_phase phase);
   extern virtual function void pre_calculate();
   extern virtual function void post_calculate();
    
endclass : gpio_scoreboard_t


function void gpio_scoreboard_t::pre_calculate();
for(int i = 0; i < 8; i++) begin
        if(!gpio_ibe[i] && gpio_iev[i] && !gpio_is[i]) intr_detec_logic[i] = RISING;
        else if(!gpio_ibe[i] && !gpio_iev[i] && !gpio_is[i]) intr_detec_logic[i] = FALLING;
        else if(gpio_ibe[i] && !gpio_iev[i] && !gpio_is[i]) intr_detec_logic[i] = BOTHEDGE;
        else if(gpio_iev[i] && gpio_is[i]) intr_detec_logic[i] = HIGH;
        else if(!gpio_iev[i] && gpio_is[i]) intr_detec_logic[i] = LOW;
        else intr_detec_logic[i] = IDLE; 

        case(intr_detec_logic[i]) 
           RISING : begin
           if(!prev[i] && GPINSync2[i]) intr_event[i] = 1;
           else intr_event[i] = 0;
           end

           FALLING : begin
           if(prev[i] && !GPINSync2[i]) intr_event[i] = 1;
           else intr_event[i] = 0;
           end

           BOTHEDGE : begin
           if(prev[i] ^ GPINSync2[i]) intr_event[i] = 1;
           else intr_event[i] = 0;
           end

           HIGH : begin
           if(GPINSync2[i]) intr_event[i] = 1;
           else intr_event[i] = 0;
           end
           
           LOW : begin
           if(~GPINSync2[i]) intr_event[i] = 1; 
           else intr_event[i] = 0;
           end

           IDLE : intr_event[i] = 0;
           default : intr_event[i] = 0;
        endcase
      if ((intr_detec_logic[i] == RISING  || intr_detec_logic[i] == FALLING || intr_detec_logic[i] == BOTHEDGE) && gpio_mis[i]) ic_reset_cond[i] = 1;
      else ic_reset_cond[i] = 0;
end
for(int i =0; i<8; i++)begin
prev_nGPEN[i] = (gpio_afsel[i] == 0) ? gpio_dir[i] : gpio_tr.nGPAFEN[i];
prev_GPOUT[i] = (gpio_afsel[i] == 0) ? gpio_data[i] : gpio_tr.GPAFOUT[i];
prev_GPIN[i] = (prev_nGPEN[i] == 0) ? prev_GPOUT[i] : 'bz;
end
prev = GPINSync2;
GPINSync2 = prev_GPIN;

  
endfunction : pre_calculate






function void gpio_scoreboard_t::predict();
this.apb_tr = apb_trans_queue.pop_front();
this.gpio_tr = gpio_trans_queue.pop_front();
  if(apb_tr.addr[11:0] inside {[12'h000 : 12'h3FF]}) begin

logic[7:0] selected_bit = apb_tr.addr[9:2];

case(apb_tr.kind) 
apb_transaction::WRITE : begin
  reg_sel = "gpiodata";
  for(int i = 0; i < 8 ; i++) begin

if(gpio_afsel[i]) begin // 하드웨어 제어 모드
if(selected_bit[i]) value[i] = gpio_tr.GPAFOUT[i]; // 1이면 GPAFOUT에서
else value[i] = gpio_data[i]; // 0이면 변화 없음
end 

else begin // 소프트웨어 제어 모드
if(selected_bit[i]) value[i] = apb_tr.data[i]; // 1이면 PRDATA에서
else value[i] = gpio_data[i]; // 0이면 변화 없음
end
  end
    void'(regmodel.GPIODATA.predict(value[7:0]));
    w_gpio_data_cnt++;

end
apb_transaction::READ : begin
  reg_sel = "gpiodata";
for(int i = 0; i < 8 ; i++) begin
if(!gpio_afsel[i]) begin // 소프트웨어 제어 모드
if(selected_bit[i]) value[i] = gpio_data[i]; // 1이면 GPAFOUT에서
else value[i] = 1'b0; // 0이면 변화 없음
end 

else begin // 하드웨어 제어 모드
if(selected_bit[i]) begin
if(gpio_dir[i]) value[i] = gpio_data[i];
  else value[i] = gpio_io_tr_act.GPIN[i];
end
else value[i] = 1'b0; // 0이면 0반환
end
end
r_gpio_data_cnt++;
end
endcase
end

else begin // GPIODATA 이외의 경우
  if(apb_tr.kind == apb_transaction::WRITE) begin // 쓰기 액세스
    value = apb_tr.data[7:0];
case(apb_tr.addr[11:0]) inside
  [12'h400 : 12'h403] : 
  begin 
    reg_sel = "gpiodir";
    void'(regmodel.GPIODIR.predict(value[7:0])); 
    w_gpio_dir_cnt++;
  end
  [12'h404 : 12'h407] :
  begin 
    reg_sel = "gpiois";
     void'(regmodel.GPIOIS.predict(value[7:0]));
     w_gpio_is_cnt++;
  end
  [12'h408 : 12'h40B] : 
  begin 
    reg_sel = "gpioibe";
    void'(regmodel.GPIOIBE.predict(value[7:0]));
    w_gpio_ibe_cnt++;
  end
  [12'h40C : 12'h40F] :
  begin
    reg_sel = "gpioiev";
    void'( regmodel.GPIOIEV.predict(value[7:0]));
    w_gpio_iev_cnt++;
  end
  [12'h410 : 12'h413] :
  begin
    reg_sel = "gpioie";
    void'(regmodel.GPIOIE.predict(value[7:0]));
    void'(regmodel.GPIOMIS.predict(value[7:0] & gpio_ris));
    w_gpio_ie_cnt++;
  end
  [12'h414 : 12'h417] : 
  begin 
    //`uvm_error("RO", "SCB: Incorrect access to a read-only address ") 
    w_gpio_ris_cnt++;
  end
[12'h418 : 12'h41B] : 
begin 
 // `uvm_error("RO", "SCB: Incorrect access to a read-only address ") 
  w_gpio_mis_cnt++;
end
  [12'h41C : 12'h41F] : 
  begin 
    reg_sel = "gpioic";
    void'(regmodel.GPIORIS.predict(gpio_ris & ~value[7:0]));
    gpio_ris = regmodel.GPIORIS.get();
    gpio_mis = gpio_ris & gpio_ie;
    void'(regmodel.GPIOMIS.predict(gpio_mis));
    w_gpio_ic_cnt++;
  end // GPIOIC
  [12'h420 : 12'h423] : 
  begin
    reg_sel = "gpioafsel";
    void'(regmodel.GPIOAFSEL.predict(value[7:0])); 
    w_gpio_afsel_cnt++;
  end
[12'hFE0 : 12'hFEF] : 
begin 
  //`uvm_error("RO", "SCB: Incorrect access to a read-only address ") 
  case(apb_tr.addr[11:0]) inside
    [12'hFE0 : 12'hFE3] : 
      begin 
        reg_sel ="gpioperiphid0";
        w_gpio_periphid0_cnt++;
      end
  [12'hFE4 : 12'hFE7] : 
    begin
      reg_sel ="gpioperiphid1";
      w_gpio_periphid1_cnt++;
    end
  [12'hFE8 : 12'hFEB] : 
    begin
      reg_sel ="gpioperiphid2";
      w_gpio_periphid2_cnt++;
    end
  [12'hFEC : 12'hFEF] : 
    begin
      reg_sel ="gpioperiphid3";
      w_gpio_periphid3_cnt++;
    end
  endcase
end
[12'hFF0 : 12'hFFF] : 
begin 
 // `uvm_error("RO", "SCB: Incorrect access to a read-only address ") 
 case(apb_tr.addr[11:0]) inside
  [12'hFF0 : 12'hFF3] : 
    begin
      reg_sel = "gpiopcellid0";
      w_gpio_pcellid0_cnt++;
    end
  [12'hFF4 : 12'hFF7] : 
    begin
      reg_sel = "gpiopcellid1";
      w_gpio_pcellid1_cnt++;
    end
  [12'hFF8 : 12'hFFB] : 
    begin
      reg_sel = "gpiopcellid2";
      w_gpio_pcellid2_cnt++;
    end
  [12'hFFC : 12'hFFF] : 
    begin
      reg_sel = "gpiopcellid3";
      w_gpio_pcellid3_cnt++;
    end
 endcase
end
default : 
begin
 // `uvm_error("RESERVED", "SCB: Incorrect access to a reserved address")
  reg_sel = "reserved";
  w_reserved_cnt++;
end
endcase 
end
  else if(apb_tr.kind == apb_transaction::READ) begin
case(apb_tr.addr[11:0]) inside
[12'h400 : 12'h403] : 
begin
  reg_sel = "gpiodir";
   value = regmodel.GPIODIR.get();
   r_gpio_dir_cnt++;
end
[12'h404 : 12'h407] : 
begin
  reg_sel = "gpiois";
  value = regmodel.GPIOIS.get();
  r_gpio_is_cnt++;
end
[12'h408 : 12'h40B] : 
begin
  reg_sel = "gpioibe";
   value = regmodel.GPIOIBE.get();
    r_gpio_ibe_cnt++;
end
[12'h40C : 12'h40F] : 
begin
  reg_sel = "gpioiev";
  value = regmodel.GPIOIEV.get();
  r_gpio_iev_cnt++;
end
[12'h410 : 12'h413] : 
begin
  reg_sel = "gpipie";
  value = regmodel.GPIOIE.get();
  r_gpio_ie_cnt++;
end
[12'h414 : 12'h417] : 
begin
  reg_sel = "gpioris";
  value = regmodel.GPIORIS.get();
  r_gpio_ris_cnt++;
end
[12'h418 : 12'h41B] : 
begin
  reg_sel = "gpiomis";
  value = regmodel.GPIOMIS.get();
  r_gpio_mis_cnt++;
end
[12'h41C : 12'h41F] : 
begin
  reg_sel = "gpioic";
  //`uvm_error("WO", "SCB: Incorrect access to a write-only address ")
  w_gpio_ic_cnt++;
end
[12'h420 : 12'h423] : 
begin
  reg_sel="gpioafsel";
  value = regmodel.GPIOAFSEL.get();
  r_gpio_afsel_cnt++;
end
[12'hFE0 : 12'hFE3] : 
begin
  reg_sel ="gpioperiphid0";
  value = regmodel.GPIOPERIPHID0.get();
  r_gpio_periphid0_cnt++;
end
[12'hFE4 : 12'hFE7] : 
begin
  reg_sel ="gpioperiphid1";
  value = regmodel.GPIOPERIPHID1.get();
  r_gpio_periphid1_cnt++;
end
[12'hFE8 : 12'hFEB] : 
begin
  reg_sel ="gpioperiphid2";
  value = regmodel.GPIOPERIPHID2.get();
  r_gpio_periphid2_cnt++;
end
[12'hFEC : 12'hFEF] : 
begin
  reg_sel ="gpioperiphid3";
  value = regmodel.GPIOPERIPHID3.get();
  r_gpio_periphid3_cnt++;
end
[12'hFF0 : 12'hFF3] : 
begin
  reg_sel ="gpiopcellid0";
  value = regmodel.GPIOPCELLID0.get();
  r_gpio_pcellid0_cnt++;
end
[12'hFF4 : 12'hFF7] : 
begin
  reg_sel ="gpiopcellid1";
  value = regmodel.GPIOPCELLID1.get();
  r_gpio_pcellid1_cnt++;
end
[12'hFF8 : 12'hFFB] : 
begin
  reg_sel ="gpiopcellid02";
  value = regmodel.GPIOPCELLID2.get();
  r_gpio_pcellid2_cnt++;
end
[12'hFFC : 12'hFFF] : 
begin
  reg_sel ="gpiopcellid3";
  value = regmodel.GPIOPCELLID3.get();
  r_gpio_pcellid3_cnt++;
end
default : 
begin 
  reg_sel = "reserved";
  //`uvm_error("RESERVED", "SCB: Incorrect access to a reserved address")
  r_reserved_cnt++;
end
endcase

end
end
    

update_cache();
if(apb_tr.kind == apb_transaction::READ) begin
if(apb_tr.data[7:0] === value[7:0]) `uvm_info("MATCH", $sformatf("\napb_tr.data=%8b \nexpected_data=%8b", apb_tr.data[7:0], value[7:0]), UVM_HIGH)
else begin `uvm_error("MISMATCH", $sformatf("SCB : READ : addr=%h, kind=%s====================================\napb_tr.PRDATA = %8b\n expected_PRDATA = %8b", apb_tr.addr[11:0],apb_tr.kind.name(), apb_tr.data[7:0], value[7:0]))
read_mismatch++;
end
end
pre_calculate();
post_calculate();

expect_result(gpio_tr);
endfunction : predict

      
function void gpio_scoreboard_t::post_calculate();
gpio_ris = regmodel.GPIORIS.get();
gpio_mis = regmodel.GPIOMIS.get();
  
for(int i = 0; i < 8; i++) begin
  if(intr_event[i]) gpio_ris[i] = 1;
  else              gpio_ris[i] = 0;
  if(ic_reset_cond[i]) begin
    gpio_ris[i] = 0;
  end
end
  
  
  gpio_ie = regmodel.GPIOIE.get();
  gpio_mis = gpio_ris & gpio_ie;
void'(regmodel.GPIORIS.predict(gpio_ris));
void'(regmodel.GPIOMIS.predict(gpio_mis));
  
  
  
  if(reg_sel == "gpioris") value = regmodel.GPIORIS.get();
  if(reg_sel == "gpiomis") value = regmodel.GPIOMIS.get();

endfunction : post_calculate



function void gpio_scoreboard_t::update_cache();
//RW
gpio_data = regmodel.GPIODATA.get();
gpio_dir = regmodel.GPIODIR.get();
gpio_afsel = regmodel.GPIOAFSEL.get();
gpio_is = regmodel.GPIOIS.get();
gpio_ibe = regmodel.GPIOIBE.get();
gpio_iev = regmodel.GPIOIEV.get();
gpio_ie = regmodel.GPIOIE.get();

//RO
gpio_ris = regmodel.GPIORIS.get();
gpio_mis = regmodel.GPIOMIS.get();
gpio_periphid0 = regmodel.GPIOPERIPHID0.get();
gpio_periphid1 = regmodel.GPIOPERIPHID1.get();
gpio_periphid2 = regmodel.GPIOPERIPHID2.get();
gpio_periphid3 = regmodel.GPIOPERIPHID3.get();
gpio_pcellid0 = regmodel.GPIOPCELLID0.get();
gpio_pcellid1 = regmodel.GPIOPCELLID1.get();
gpio_pcellid2 = regmodel.GPIOPCELLID2.get();
gpio_pcellid3 = regmodel.GPIOPCELLID3.get();
  
  
endfunction : update_cache


function void gpio_scoreboard_t::expect_result(gpio_transaction act);
  gpio_io_transaction gpio_io_tr = gpio_io_transaction::type_id::create("gpio_io_tr");
  gpio_transaction exp = gpio_transaction::type_id::create("exp");  
      

for(int i = 0; i < 8 ; i++) begin
  gpio_io_tr.nGPEN[i]   = (gpio_afsel[i] == 0) ? gpio_dir[i]  : act.nGPAFEN[i];
  gpio_io_tr.GPOUT[i]   = (gpio_afsel[i] == 0) ? gpio_data[i] : act.GPAFOUT[i]; 
  gpio_io_tr.XP[i]      = (gpio_io_tr.nGPEN[i] == 0) ? gpio_io_tr.GPOUT[i] : 'bz;
  gpio_io_tr.GPIN[i] = gpio_io_tr.XP[i];
  exp.GPAFIN[i] = (gpio_afsel[i] == 0) ? 'b0 : gpio_io_tr.GPIN[i];
end

  
compare_io_result(gpio_io_tr);

   exp.GPIOMIS = gpio_mis;
   
   exp.GPIOINTR = |exp.GPIOMIS;
      
    compare_core_result(exp, act);  
endfunction : expect_result

  
  
  
  
function void gpio_scoreboard_t::compare_io_result(gpio_io_transaction exp);
if(exp.nGPEN === gpio_io_tr_act.nGPEN && exp.GPOUT === gpio_io_tr_act.GPOUT && exp.XP === gpio_io_tr_act.XP && exp.GPIN === gpio_io_tr_act.GPIN) 
  `uvm_info("MATCH", $sformatf("@time:%0t SCB : match \n exp.nGPEN=%b, exp.GPOUT=%b, exp.XP=%b, exp.GPIN=%b \n act.nGPEN=%b, act.GPOUT=%b, act.XP=%b, act.GPIN=%b", $time, exp.nGPEN, exp.GPOUT, exp.XP, exp.GPIN, gpio_io_tr_act.nGPEN, gpio_io_tr_act.GPOUT, gpio_io_tr_act.XP, gpio_io_tr_act.GPIN), UVM_HIGH)
else  begin
 
  `uvm_error("MISMATCH", $sformatf("SCB : mismatch :addr=%h, kind=%s====================================\n exp.nGPEN=%b, exp.GPOUT=%b, exp.XP=%b, exp.GPIN=%b \n act.nGPEN=%b, act.GPOUT=%b, act.XP=%b, act.GPIN=%b",apb_tr.addr,apb_tr.kind.name(), exp.nGPEN, exp.GPOUT, exp.XP, exp.GPIN, gpio_io_tr_act.nGPEN, gpio_io_tr_act.GPOUT, gpio_io_tr_act.XP, gpio_io_tr_act.GPIN))
io_mismatch++;
end
endfunction : compare_io_result

function void gpio_scoreboard_t::compare_core_result(gpio_transaction exp, gpio_transaction act);
  if(exp.GPIOMIS === act.GPIOMIS && exp.GPIOINTR === act.GPIOINTR)
    `uvm_info("MATCH", $sformatf("SCB : interrupt : match \n exp.GPIOMIS=%b, exp.GPIOINTR=%b \n act.GPIOMIS=%b, act.GPIOINTR=%b",exp.GPIOMIS, exp.GPIOINTR, act.GPIOMIS, act.GPIOINTR), UVM_HIGH)
else begin

  `uvm_error("MISMATCH", $sformatf("SCB : interrupt : mismatch :addr=%h, kind=%s====================================\n exp.GPIOMIS=%b, exp.GPIOINTR=%b \n act.GPIOMIS=%b, act.GPIOINTR=%b",apb_tr.addr,apb_tr.kind.name(), exp.GPIOMIS, exp.GPIOINTR,  act.GPIOMIS, act.GPIOINTR))
  intr_mismatch++;
end
  if(exp.GPAFIN === act.GPAFIN) 
    `uvm_info("MATCH", $sformatf("SCB : core : match \n exp.GPAFIN=%8b act.GPAFIN=%8b", exp.GPAFIN, act.GPAFIN), UVM_HIGH)
    else begin
 
      `uvm_error("MISMATCH", $sformatf("SCB : core : match \n exp.GPAFIN=%8b act.GPAFIN=%8b", exp.GPAFIN, act.GPAFIN))
      core_mismatch++;
    end
endfunction : compare_core_result
  
     function void gpio_scoreboard_t::print_info(string arg="");
       if(arg != "") $display("< < < %s > > >", arg);
  $display("SCB:%s, @time:%0t, selected_bit=%8b, addr=%h--------------------------------------", apb_tr.kind.name(), $time, apb_tr.addr[9:2], apb_tr.addr[11:0]);
 $display("   gpio_data  = %h (%8b) | gpio_dir   = %h (%8b)", gpio_data,  gpio_data,  gpio_dir,  gpio_dir);
  $display("   gpio_is    = %h (%8b) | gpio_ibe   = %h (%8b)", gpio_is,    gpio_is,    gpio_ibe,  gpio_ibe);
  $display("   gpio_iev   = %h (%8b) | gpio_ie    = %h (%8b)", gpio_iev,   gpio_iev,   gpio_ie,   gpio_ie);
  $display("   gpio_ris   = %h (%8b) | gpio_mis   = %h (%8b)", gpio_ris,   gpio_ris,   gpio_mis,  gpio_mis);
  $display("   gpio_ic    = %h (%8b) | gpio_afsel = %h (%8b)", gpio_ic,    gpio_ic,    gpio_afsel,gpio_afsel);
 /* $display("   periphid0  = %h (%8b) | periphid1  = %h (%8b)", gpio_periphid0, gpio_periphid0, gpio_periphid1, gpio_periphid1);
      $display("   periphid2  = %h (%8b) | periphid3  = %h (%8b)", gpio_periphid2, gpio_periphid2, gpio_periphid3, gpio_periphid3);
  $display("   pcellid0   = %h (%8b) | pcellid1   = %h (%8b)", gpio_pcellid0,  gpio_pcellid0,  gpio_pcellid1,  gpio_pcellid1);
  $display("   pcellid2   = %h (%8b) | pcellid3   = %h (%8b)", gpio_pcellid2,  gpio_pcellid2,  gpio_pcellid3,  gpio_pcellid3);*/
  $display("   value      = %h (%8b) | reg_sel    = %s       ", value, value, reg_sel);  
    $display("--------------------------------------------------------------------------------");
endfunction : print_info
    
function bit gpio_scoreboard_t::is_q_empty();
    return (apb_trans_queue.size() == 0 &&
            gpio_trans_queue.size() == 0);
  endfunction : is_q_empty

task gpio_scoreboard_t::run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      fork : run_thread
        @(negedge reset_vif.PRESETn)
        scoreboard_reset();
          
        forever begin
            @(posedge apb_receive_done);
           
          
           gpio_io_tr_act = gpio_io_observed_queue.pop_back();
           gpio_io_observed_queue.delete();
         
          @(posedge gpio_core_receive_done);
          print_trigger++;
           apb_receive_done = 0;
           gpio_core_receive_done = 0;
           predict();
        end
     join_any
        
     disable run_thread;
          
      @(posedge reset_vif.PRESETn);
    end
endtask : run_phase
       
function void gpio_scoreboard_t::scoreboard_reset();
`uvm_info("SCB", "scoreboard reset start...", UVM_LOW)
  
apb_trans_queue.delete();
gpio_trans_queue.delete();
gpio_io_observed_queue.delete();

  regmodel.reset();

gpio_data = 'h00;
gpio_dir ='h00;
gpio_afsel ='h00;
gpio_is ='h00;
gpio_ibe ='h00;
gpio_iev ='h00;
gpio_ie ='h00;
gpio_ris ='h00;
gpio_mis ='h00;
gpio_ic ='h00;
gpio_periphid0 ='h61;
gpio_periphid1 = 'h10;
gpio_periphid2 = 'h04;
gpio_periphid3 = 'h00;
gpio_pcellid0 = 'h0d;
gpio_pcellid1 = 'h0f;
gpio_pcellid2 = 'h05;
gpio_pcellid3 = 'hb1; 

selected_bit = 'h00; 
value = 'h00;
GPINSync2 = 'h00;
prev = 'h00;
intr_event = 'h00;
ic_reset_cond = 'h00;

  for(int i = 0 ; i < 8 ; i++)
intr_detec_logic[i] = IDLE;

apb_receive_done = 0;
gpio_core_receive_done = 0;

  
w_gpio_data_cnt      = 0;
w_gpio_dir_cnt       = 0;
w_gpio_afsel_cnt     = 0;
w_gpio_is_cnt        = 0;
w_gpio_ibe_cnt       = 0;
w_gpio_iev_cnt       = 0;
w_gpio_ie_cnt        = 0;
w_gpio_ris_cnt       = 0;
w_gpio_mis_cnt       = 0;
w_gpio_ic_cnt        = 0;

w_gpio_periphid0_cnt = 0;
w_gpio_periphid1_cnt = 0;
w_gpio_periphid2_cnt = 0;
w_gpio_periphid3_cnt = 0;
w_gpio_pcellid0_cnt  = 0;
w_gpio_pcellid1_cnt  = 0;
w_gpio_pcellid2_cnt  = 0;
w_gpio_pcellid3_cnt  = 0;
w_reserved_cnt       = 0;

r_gpio_data_cnt      = 0;
r_gpio_dir_cnt       = 0;
r_gpio_afsel_cnt     = 0;
r_gpio_is_cnt        = 0;
r_gpio_ibe_cnt       = 0;
r_gpio_iev_cnt       = 0;
r_gpio_ie_cnt        = 0;
r_gpio_ris_cnt       = 0;
r_gpio_mis_cnt       = 0;
r_gpio_ic_cnt        = 0;

r_gpio_periphid0_cnt = 0;
r_gpio_periphid1_cnt = 0;
r_gpio_periphid2_cnt = 0;
r_gpio_periphid3_cnt = 0;
r_gpio_pcellid0_cnt  = 0;
r_gpio_pcellid1_cnt  = 0;
r_gpio_pcellid2_cnt  = 0;
r_gpio_pcellid3_cnt  = 0;
r_reserved_cnt       = 0;
  
intr_mismatch = 0;
read_mismatch = 0;
io_mismatch = 0;
core_mismatch = 0;
  
prev_GPIN = 'h00;
prev_nGPEN = 'h00;
prev_GPOUT = 'h00;
endfunction : scoreboard_reset
       
function void gpio_scoreboard_t::report_phase(uvm_phase phase);
int read_access_count = r_gpio_data_cnt+r_gpio_dir_cnt+r_gpio_afsel_cnt+r_gpio_is_cnt+r_gpio_ibe_cnt+r_gpio_iev_cnt+r_gpio_ie_cnt+r_gpio_ris_cnt+r_gpio_mis_cnt+r_gpio_ic_cnt+r_gpio_periphid0_cnt+r_gpio_periphid1_cnt+r_gpio_periphid2_cnt+r_gpio_periphid3_cnt+r_gpio_pcellid0_cnt+r_gpio_pcellid1_cnt+r_gpio_pcellid2_cnt+r_gpio_pcellid3_cnt+r_reserved_cnt;
int write_access_count = w_gpio_data_cnt+w_gpio_dir_cnt+w_gpio_afsel_cnt+w_gpio_is_cnt+w_gpio_ibe_cnt+w_gpio_iev_cnt+w_gpio_ie_cnt+w_gpio_ris_cnt+w_gpio_mis_cnt+w_gpio_ic_cnt+w_gpio_periphid0_cnt+w_gpio_periphid1_cnt+w_gpio_periphid2_cnt+w_gpio_periphid3_cnt+w_gpio_pcellid0_cnt+w_gpio_pcellid1_cnt+w_gpio_pcellid2_cnt+w_gpio_pcellid3_cnt+w_reserved_cnt;
  
$display("Register    Read Count    Write Count     Access attribute");
$display("============================================================================");
$display("GPIODATA       %0d           %0d             RW", r_gpio_data_cnt, w_gpio_data_cnt);
$display("GPIODIR        %0d           %0d             RW", r_gpio_dir_cnt, w_gpio_dir_cnt);
$display("GPIOAFSEL      %0d           %0d             RW", r_gpio_afsel_cnt, w_gpio_afsel_cnt);
$display("GPIOIS         %0d           %0d             RW", r_gpio_is_cnt, w_gpio_is_cnt);
$display("GPIOIBE        %0d           %0d             RW", r_gpio_ibe_cnt, w_gpio_ibe_cnt);
$display("GPIOIEV        %0d           %0d             RW", r_gpio_iev_cnt, w_gpio_iev_cnt);
$display("GPIOIE         %0d           %0d             RW", r_gpio_ie_cnt, w_gpio_ie_cnt);
$display("GPIORIS        %0d           %0d             RO", r_gpio_ris_cnt, w_gpio_ris_cnt);
$display("GPIOMIS        %0d           %0d             RO", r_gpio_mis_cnt, w_gpio_mis_cnt);
$display("GPIOIC         %0d           %0d             WO", r_gpio_ic_cnt, w_gpio_ic_cnt);
$display("GPIOPERIPHID0  %0d           %0d             RO", r_gpio_periphid0_cnt, w_gpio_periphid0_cnt);
$display("GPIOPERIPHID1  %0d           %0d             RO", r_gpio_periphid1_cnt, w_gpio_periphid1_cnt);
$display("GPIOPERIPHID2  %0d           %0d             RO", r_gpio_periphid2_cnt, w_gpio_periphid2_cnt);
$display("GPIOPERIPHID3  %0d           %0d             RO", r_gpio_periphid3_cnt, w_gpio_periphid3_cnt);
$display("GPIOPCELLID0   %0d           %0d             RO", r_gpio_pcellid0_cnt, w_gpio_pcellid0_cnt);
$display("GPIOPCELLID1   %0d           %0d             RO", r_gpio_pcellid1_cnt, w_gpio_pcellid1_cnt);
$display("GPIOPCELLID2   %0d           %0d             RO", r_gpio_pcellid2_cnt, w_gpio_pcellid2_cnt);
$display("GPIOPCELLID3   %0d           %0d             RO", r_gpio_pcellid3_cnt, w_gpio_pcellid3_cnt);
$display("Reserved       %0d           %0d             Reserved", r_reserved_cnt, w_reserved_cnt);
$display("Overall        %0d           %0d             ", read_access_count, write_access_count);
  $display("intr_mismatch = %0d,   read_mismatch = %0d, io_mismatch = %0d, core_mismatch=%0d", intr_mismatch, read_mismatch, io_mismatch, core_mismatch);
$display("============================================================================");
endfunction : report_phase
