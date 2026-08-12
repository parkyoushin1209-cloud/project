`include "uvm_macros.svh"
import uvm_pkg::*;
import gpio_transaction_pkg::*;

`uvm_analysis_imp_decl(_gpio_cov)
`uvm_analysis_imp_decl(_gpio_io_cov)

class gpio_cov_coll_t extends uvm_component;
`uvm_component_utils(gpio_cov_coll_t)

bit coverage_enable;
uvm_analysis_imp_gpio_cov #(gpio_transaction, gpio_cov_coll_t) gpio_export;
uvm_analysis_imp_gpio_io_cov #(gpio_io_transaction, gpio_cov_coll_t) gpio_io_export;
gpio_transaction gpio_tr;
gpio_io_transaction gpio_io_tr;

int unsigned gpafout_hits[12];
int unsigned ngafen_hits[12];

bit [7:0] prev_gpafout;
bit [7:0] prev_ngafen;
bit       has_prev_gpafout = 0;
bit       has_prev_ngafen  = 0;

covergroup gpio_cov_group;
   cp_GPAFOUT : coverpoint gpio_tr.GPAFOUT{
    bins ALL0      = {'b0000_0000};
    bins ALL1      = {'b1111_1111};
    bins UPPER_ON  = {'b1111_0000};
    bins LOWER_ON  = {'b0000_1111};
    bins ALT_1010  = {'b1010_1010};
    bins ALT_0101  = {'b0101_0101};
    bins OTHERS_LOW  = {['h01 : 'h54]} with (item != 'h0F);
    bins OTHERS_MID  = {['h56 : 'hA9]} with (!(item inside {'hA5, 'h5A}));
    bins OTHERS_HIGH = {['hAB : 'hFE]} with (item != 'hF0);
    bins ALL1_2_ALL0 =  ('b1111_1111 => 'b0000_0000);
    bins ALL0_2_ALL1 =  ('b0000_0000 => 'b1111_1111);
    bins ALT_TOGGLE  =  ('b1010_1010 => 'b0101_0101), ('b0101_0101 => 'b1010_1010);
   }
   cp_nGPAFEN : coverpoint gpio_tr.nGPAFEN{
    bins ALL0      = {'b0000_0000};
    bins ALL1      = {'b1111_1111};
    bins UPPER_ON  = {'b1111_0000};
    bins LOWER_ON  = {'b0000_1111};
    bins ALT_1010  = {'b1010_1010};
    bins ALT_0101  = {'b0101_0101};
    bins OTHERS_LOW  = {['h01 : 'h54]} with (item != 'h0F);
    bins OTHERS_MID  = {['h56 : 'hA9]} with (!(item inside {'hA5, 'h5A}));
    bins OTHERS_HIGH = {['hAB : 'hFE]} with (item != 'hF0);
    bins ALL1_2_ALL0 =  ('b1111_1111 => 'b0000_0000);
    bins ALL0_2_ALL1 =  ('b0000_0000 => 'b1111_1111);
    bins ALT_TOGGLE  =  ('b1010_1010 => 'b0101_0101), ('b0101_0101 => 'b1010_1010);
   }
endgroup : gpio_cov_group

covergroup gpio_io_cov_group;
  coverpoint gpio_io_tr.GPIN;
endgroup : gpio_io_cov_group

function new(string name, uvm_component parent);
  super.new(name, parent);
  gpio_export = new("gpio_export", this);
  gpio_io_export = new("gpio_io_export", this);
  void'(uvm_config_int::get(this,"", "coverage_enable", coverage_enable));
  if(coverage_enable) begin
    gpio_cov_group = new();
    gpio_io_cov_group = new();
  end
endfunction : new

virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

virtual function void write_gpio_cov(gpio_transaction tr);
  if(coverage_enable) begin
    $cast(gpio_tr, tr);
    gpio_cov_group.sample();
    
    // [핵심 수정] 트랜잭션이 들어올 때마다 수동 패턴 평가 함수 호출!
    evaluate_pattern(gpio_tr.GPAFOUT, gpafout_hits, prev_gpafout, has_prev_gpafout);
    evaluate_pattern(gpio_tr.nGPAFEN, ngafen_hits, prev_ngafen, has_prev_ngafen);
  end
endfunction : write_gpio_cov

virtual function void write_gpio_io_cov(gpio_io_transaction tr);
  if(coverage_enable) begin
    $cast(gpio_io_tr, tr);
    gpio_io_cov_group.sample();
  end
endfunction : write_gpio_io_cov

function void evaluate_pattern(bit [7:0] val, ref int unsigned hits_arr[12], ref bit [7:0] prev_val, ref bit has_prev);
    int pat_idx = -1;

    // 기본 값 패턴 매칭
    case (val)
      'b0000_0000: pat_idx = 0;
      'b1111_1111: pat_idx = 1;
      'b1111_0000: pat_idx = 2;
      'b0000_1111: pat_idx = 3;
      'b1010_1010: pat_idx = 4;
      'b0101_0101: pat_idx = 5;
      default: begin
        if (val >= 'h01 && val <= 'h54 && val != 'h0F) 
          pat_idx = 6;
        else if (val >= 'h56 && val <= 'hA9 && !(val inside {'hA5, 'h5A})) 
          pat_idx = 7;
        else if (val >= 'hAB && val <= 'hFE && val != 'hF0) 
          pat_idx = 8;
      end
    endcase

    if (pat_idx >= 0) hits_arr[pat_idx]++;

    // 천이(Transition) 패턴 매칭
    if (has_prev) begin
      if (prev_val == 'b1111_1111 && val == 'b0000_0000) 
        hits_arr[9]++;  // ALL1_2_ALL0
      else if (prev_val == 'b0000_0000 && val == 'b1111_1111) 
        hits_arr[10]++; // ALL0_2_ALL1
      
      if ((prev_val == 'b1010_1010 && val == 'b0101_0101) || 
          (prev_val == 'b0101_0101 && val == 'b1010_1010)) 
        hits_arr[11]++; // ALT_TOGGLE
    end

    prev_val = val;
    has_prev = 1;
endfunction : evaluate_pattern

virtual function void report_phase(uvm_phase phase);
  int gpafout_hit_bins = 0;
  int ngafen_hit_bins  = 0;
  real gpafout_pct     = 0.0;
  real ngafen_pct      = 0.0;

  super.report_phase(phase);
  `uvm_info("DEBUG", "report_phase entered!", UVM_LOW);
  
  if(coverage_enable) begin
    // 히트된 빈 개수 계산 (총 12개 중 몇 개가 hit 되었는지)
    for(int i = 0; i < 12; i++) begin
      if (gpafout_hits[i] > 0) gpafout_hit_bins++;
      if (ngafen_hits[i] > 0)  ngafen_hit_bins++;
    end

    gpafout_pct = (real'(gpafout_hit_bins) / 12.0) * 100.0;
    ngafen_pct  = (real'(ngafen_hit_bins) / 12.0) * 100.0;

    $display("==================================================================================");
    $display("               [ GPIO Manual Coverage & Bin Hit Report ]                          ");
    $display("==================================================================================");
    $display(" [1] cp_GPAFOUT Bin Hits (Manual Calculated):");
    $display("   - ALL0       : %0d | ALL1       : %0d | UPPER_ON   : %0d", gpafout_hits[0], gpafout_hits[1], gpafout_hits[2]);
    $display("   - LOWER_ON   : %0d | ALT_1010   : %0d | ALT_0101   : %0d", gpafout_hits[3], gpafout_hits[4], gpafout_hits[5]);
    $display("   - OTHERS_LOW : %0d | OTHERS_MID : %0d | OTHERS_HIGH: %0d", gpafout_hits[6], gpafout_hits[7], gpafout_hits[8]);
    $display("   - ALL1_2_ALL0: %0d | ALL0_2_ALL1: %0d | ALT_TOGGLE : %0d", gpafout_hits[9], gpafout_hits[10], gpafout_hits[11]);
    $display("   -> Manual Hit Rate: %.2f%% (%0d / 12 bins)", gpafout_pct, gpafout_hit_bins);
    
    $display("----------------------------------------------------------------------------------");
    $display(" [2] cp_nGPAFEN Bin Hits (Manual Calculated):");
    $display("   - ALL0       : %0d | ALL1       : %0d | UPPER_ON   : %0d", ngafen_hits[0], ngafen_hits[1], ngafen_hits[2]);
    $display("   - LOWER_ON   : %0d | ALT_1010   : %0d | ALT_0101   : %0d", ngafen_hits[3], ngafen_hits[4], ngafen_hits[5]);
    $display("   - OTHERS_LOW : %0d | OTHERS_MID : %0d | OTHERS_HIGH: %0d", ngafen_hits[6], ngafen_hits[7], ngafen_hits[8]);
    $display("   - ALL1_2_ALL0: %0d | ALL0_2_ALL1: %0d | ALT_TOGGLE : %0d", ngafen_hits[9], ngafen_hits[10], ngafen_hits[11]);
    $display("   -> Manual Hit Rate: %.2f%% (%0d / 12 bins)", ngafen_pct, ngafen_hit_bins);
    $display("==================================================================================");
    $display("--- GPIO Individual Coverpoint Coverages (Simulator Built-in) ---");
    $display("cp_GPAFOUT coverage = %.2f%%", gpio_cov_group.cp_GPAFOUT.get_coverage());
    $display("cp_nGPAFEN coverage = %.2f%%", gpio_cov_group.cp_nGPAFEN.get_coverage());
  end
endfunction : report_phase

endclass : gpio_cov_coll_t

