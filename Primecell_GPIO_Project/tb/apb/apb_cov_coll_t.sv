`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_transaction_pkg::*;

class apb_cov_coll_t extends uvm_component;
  `uvm_component_utils(apb_cov_coll_t)

  uvm_analysis_imp #(apb_transaction, apb_cov_coll_t) apb_export;
  apb_transaction apb_tr;
   
  int unsigned reg_hits[13];          // cp_reg (13개)
  int unsigned masked_addr_hits[11];  // cp_masked_addr (11개)
  int unsigned kind_hits[2];          // cp_kind (WRITE, READ)
  int unsigned data_hits[10];         // cp_data (10개 패턴)
  
  // 크로스 분석용 카운터 배열
  int unsigned reg_x_kind_hits[13][2]; // cp_reg(13) x cp_kind(2)
  int unsigned datareg_complex_hits;   // datareg_x_kind_x_data_x_mask 크로스 대체 카운터

  bit coverage_enable;
  covergroup apb_cov_group;
   cp_reg : coverpoint apb_tr.addr[11:0] {
    bins GPIODATA  =  {['h000 : 'h3FF]};
    bins GPIODIR   =  {['h400 : 'h403]};
    bins GPIOIS    =  {['h404 : 'h407]};
    bins GPIOIBE   =  {['h408 : 'h40B]};
    bins GPIOIEV   =  {['h40C : 'h40F]};
    bins GPIOIE    =  {['h410 : 'h413]};
    bins GPIORIS   =  {['h414 : 'h417]};
    bins GPIOMIS   =  {['h418 : 'h41B]};
    bins GPIOIC    =  {['h41C : 'h41F]};
    bins GPIOAFSEL =  {['h420 : 'h423]};
    bins RESERVED  =  {['h424 : 'hFDF]};
    bins PERIPHID  =  {['hFE0 : 'hFEF]};
    bins PCELLID   =  {['hFF0 : 'hFFF]};
   }
   cp_masked_addr : coverpoint apb_tr.addr[9:2]{
    bins ALL0      = {'b0000_0000};
    bins ALL1      = {'b1111_1111};
    bins UPPER_ON  = {'b1111_0000};
    bins LOWER_ON  = {'b0000_1111};
    bins ALT_1010  = {'b1010_1010};
    bins ALT_0101  = {'b0101_0101};
    bins OTHERS_LOW  = {['h01 : 'h54]} with (item != 'h0F);
    bins OTHERS_MID  = {['h56 : 'hA9]} with (!(item inside {'hA5, 'h5A}));
    bins OTHERS_HIGH = {['hAB : 'hFE]} with (item != 'hF0);
    bins ALL0_TO_ALL1 = ('b0000_0000 => 'b1111_1111);
    bins ALL1_TO_ALL0 = ('b1111_1111 => 'b0000_0000);
   }
   cp_kind : coverpoint apb_tr.kind{
    bins WRITE = {apb_transaction::WRITE};
    bins READ  = {apb_transaction::READ};
   }
   cp_data : coverpoint apb_tr.data{
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
   REG_X_KIND : cross cp_reg, cp_kind{
    bins W_GPIODATA  = binsof(cp_reg.GPIODATA)  && binsof(cp_kind.WRITE);
    bins R_GPIODATA  = binsof(cp_reg.GPIODATA)  && binsof(cp_kind.READ);
    bins W_GPIODIR   = binsof(cp_reg.GPIODIR)   && binsof(cp_kind.WRITE);
    bins R_GPIODIR   = binsof(cp_reg.GPIODIR)   && binsof(cp_kind.READ);
    bins W_GPIOIS    = binsof(cp_reg.GPIOIS)    && binsof(cp_kind.WRITE);
    bins R_GPIOIS    = binsof(cp_reg.GPIOIS)    && binsof(cp_kind.READ);
    bins W_GPIOIBE   = binsof(cp_reg.GPIOIBE)   && binsof(cp_kind.WRITE);
    bins R_GPIOIBE   = binsof(cp_reg.GPIOIBE)   && binsof(cp_kind.READ);
    bins W_GPIOIEV   = binsof(cp_reg.GPIOIEV)   && binsof(cp_kind.WRITE);
    bins R_GPIOIEV   = binsof(cp_reg.GPIOIEV)   && binsof(cp_kind.READ);
    bins W_GPIOIE    = binsof(cp_reg.GPIOIE)    && binsof(cp_kind.WRITE);
    bins R_GPIOIE    = binsof(cp_reg.GPIOIE)    && binsof(cp_kind.READ);
    bins R_GPIORIS   = binsof(cp_reg.GPIORIS)   && binsof(cp_kind.READ);
    bins R_GPIOMIS   = binsof(cp_reg.GPIOMIS)   && binsof(cp_kind.READ);
    bins W_GPIOIC    = binsof(cp_reg.GPIOIC)    && binsof(cp_kind.WRITE);
    bins W_GPIOAFSEL = binsof(cp_reg.GPIOAFSEL) && binsof(cp_kind.WRITE);
    bins R_GPIOAFSEL = binsof(cp_reg.GPIOAFSEL) && binsof(cp_kind.READ);

  // Read-Only 및 Unmapped 레지스터는 Write를 ignore/illegal 처리
    ignore_bins W_RO_REGS = (binsof(cp_reg.PERIPHID) || binsof(cp_reg.PCELLID) || binsof(cp_reg.RESERVED) || binsof(cp_reg.GPIOMIS) || binsof(cp_reg.GPIORIS)) 
                           && binsof(cp_kind.WRITE);
    ignore_bins R_WO_REG  = binsof(cp_reg.GPIOIC) && binsof(cp_kind.READ); 
    ignore_bins R_GPIOIC    = binsof(cp_reg.GPIOIC)    && binsof(cp_kind.READ);
   }
  
   datareg_x_kind_x_data_x_mask : cross cp_reg, cp_masked_addr, cp_kind, cp_data{
    ignore_bins IGNORE = !binsof(cp_reg.GPIODATA);
    
   }
  endgroup : apb_cov_group

  function new(string name, uvm_component parent);
    super.new(name, parent);
    apb_export = new("apb_export", this);
    void'(uvm_config_int::get(null,"*", "coverage_enable", coverage_enable));
    if(coverage_enable) apb_cov_group = new();
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  endfunction : build_phase

  virtual function void write(apb_transaction tr);
  int reg_idx, kind_idx, mask_idx, data_idx;
    bit is_write, is_read;

    if(coverage_enable) begin
      $cast(apb_tr, tr);

      // --- [1] cp_reg 인덱스 판별 ---
      if      (apb_tr.addr[11:0] >= 'h000 && apb_tr.addr[11:0] <= 'h3FF)       reg_idx = 0;
      else if (apb_tr.addr[11:0] >= 'h400 && apb_tr.addr[11:0] <= 'h403)       reg_idx = 1;
      else if (apb_tr.addr[11:0] >= 'h404 && apb_tr.addr[11:0] <= 'h407)       reg_idx = 2;
      else if (apb_tr.addr[11:0] >= 'h408 && apb_tr.addr[11:0] <= 'h40B)       reg_idx = 3;
      else if (apb_tr.addr[11:0] >= 'h40C && apb_tr.addr[11:0] <= 'h40F)       reg_idx = 4;
      else if (apb_tr.addr[11:0] >= 'h410 && apb_tr.addr[11:0] <= 'h413)       reg_idx = 5;
      else if (apb_tr.addr[11:0] >= 'h414 && apb_tr.addr[11:0] <= 'h417)       reg_idx = 6;
      else if (apb_tr.addr[11:0] >= 'h418 && apb_tr.addr[11:0] <= 'h41B)       reg_idx = 7;
      else if (apb_tr.addr[11:0] >= 'h41C && apb_tr.addr[11:0] <= 'h41F)       reg_idx = 8;
      else if (apb_tr.addr[11:0] >= 'h420 && apb_tr.addr[11:0] <= 'h423)       reg_idx = 9;
      else if (apb_tr.addr[11:0] >= 'h424 && apb_tr.addr[11:0] <= 'hFDF)       reg_idx = 10;
      else if (apb_tr.addr[11:0] >= 'hFE0 && apb_tr.addr[11:0] <= 'hFEF)       reg_idx = 11;
      else if (apb_tr.addr[11:0] >= 'hFF0 && apb_tr.addr[11:0] <= 'hFFF)       reg_idx = 12;
      else reg_idx = -1;

      if (reg_idx >= 0) reg_hits[reg_idx]++;

      // --- [2] cp_kind 인덱스 판별 ---
      is_write = (apb_tr.kind == apb_transaction::WRITE);
      is_read  = (apb_tr.kind == apb_transaction::READ);
      kind_idx = is_write ? 0 : (is_read ? 1 : -1);

      if (kind_idx >= 0) kind_hits[kind_idx]++;

      // --- [3] cp_masked_addr 인덱스 판별 ---
      case (apb_tr.addr[9:2])
        'b0000_0000: mask_idx = 0;
        'b1111_1111: mask_idx = 1;
        'b1111_0000: mask_idx = 2;
        'b0000_1111: mask_idx = 3;
        'b1010_1010: mask_idx = 4;
        'b0101_0101: mask_idx = 5;
        default: begin
          if (apb_tr.addr[9:2] >= 'h01 && apb_tr.addr[9:2] <= 'h54 && apb_tr.addr[9:2] != 'h0F) 
            mask_idx = 6;
          else if (apb_tr.addr[9:2] >= 'h56 && apb_tr.addr[9:2] <= 'hA9 && apb_tr.addr[9:2] != 'hA5 && apb_tr.addr[9:2] != 'h5A) 
            mask_idx = 7;
          else if (apb_tr.addr[9:2] >= 'hAB && apb_tr.addr[9:2] <= 'hFE && apb_tr.addr[9:2] != 'hF0) 
            mask_idx = 8;
          else mask_idx = -1;
        end
      endcase
      // 천이(Transition) 패턴 예시 매칭
      // (ALL0_TO_ALL1 또는 ALL1_TO_ALL0는 이전 상태를 기억해야 하므로 단순화 처리 생략 가능)
      if (mask_idx >= 0) masked_addr_hits[mask_idx]++;

      // --- [4] cp_data 인덱스 판별 ---
      case (apb_tr.data)
        'b0000_0000: data_idx = 0;
        'b1111_1111: data_idx = 1;
        'b1111_0000: data_idx = 2;
        'b0000_1111: data_idx = 3;
        'b1010_1010: data_idx = 4;
        'b0101_0101: data_idx = 5;
        default: begin
          if (apb_tr.data >= 'h01 && apb_tr.data <= 'h54 && apb_tr.data != 'h0F) 
            data_idx = 6;
          else if (apb_tr.data >= 'h56 && apb_tr.data <= 'hA9 && apb_tr.data != 'hA5 && apb_tr.data != 'h5A) 
            data_idx = 7;
          else if (apb_tr.data >= 'hAB && apb_tr.data <= 'hFE && apb_tr.data != 'hF0) 
            data_idx = 8;
          else data_idx = -1;
        end
      endcase
      if (data_idx >= 0) data_hits[data_idx]++;

      // --- [5] Cross 1: REG_X_KIND 처리 (ignore 조건 포함) ---
      if (reg_idx >= 0 && kind_idx >= 0) begin
        // Read-Only 레지스터에 대한 Write 무시 (ignore_bins 규칙)
        bit is_ro_reg = (reg_idx == 7 || reg_idx == 6 || reg_idx == 10 || reg_idx == 11 || reg_idx == 12); // GPIOMIS, GPIORIS, RESERVED, PERIPHID, PCELLID
        // Write-Only 레지스터에 대한 Read 무시
        bit is_wo_reg = (reg_idx == 8); // GPIOIC

        if (!((is_ro_reg && is_write) || (is_wo_reg && is_read))) begin
          reg_x_kind_hits[reg_idx][kind_idx]++;
        end
      end

      // --- [6] Cross 2: datareg_x_kind_x_data_x_mask 처리 ---
      // GPIODATA(reg_idx == 0) 영역일 때만 카운트
      if (reg_idx == 0 && mask_idx >= 0 && data_idx >= 0 && kind_idx >= 0) begin
        datareg_complex_hits++;
      end

    end
    if(coverage_enable) apb_cov_group.sample();
  endfunction : write
  
  virtual function void report_phase(uvm_phase phase);
  if(coverage_enable && apb_cov_group != null) begin
     $display("==================================================================================");
      $display("                 [ APB Manual Coverage & Detailed Bin Hit Report ]                ");
      $display("==================================================================================");
      $display(" [1] cp_reg Bin Hits:");
      $display("   - GPIODATA(0x000-3FF) : %0d | GPIODIR(0x400-403) : %0d | GPIOIS(0x404-407)  : %0d", reg_hits[0], reg_hits[1], reg_hits[2]);
      $display("   - GPIOIBE(0x408-40B)  : %0d | GPIOIEV(0x40C-40F) : %0d | GPIOIE(0x410-413)   : %0d", reg_hits[3], reg_hits[4], reg_hits[5]);
      $display("   - GPIORIS(0x414-417)  : %0d | GPIOMIS(0x418-41B) : %0d | GPIOIC(0x41C-41F)   : %0d", reg_hits[6], reg_hits[7], reg_hits[8]);
      $display("   - GPIOAFSEL(0x420-423): %0d | RESERVED(0x424-FDF): %0d | PERIPHID(0xFE0-FEF) : %0d", reg_hits[9], reg_hits[10], reg_hits[11]);
      $display("   - PCELLID(0xFF0-FFF)  : %0d", reg_hits[12]);
      
      $display("----------------------------------------------------------------------------------");
      $display(" [2] cp_masked_addr Bin Hits:");
      $display("   - ALL0: %0d | ALL1: %0d | UPPER_ON: %0d | LOWER_ON: %0d | ALT_1010: %0d", masked_addr_hits[0], masked_addr_hits[1], masked_addr_hits[2], masked_addr_hits[3], masked_addr_hits[4]);
      $display("   - ALT_0101: %0d | OTHERS_LOW: %0d | OTHERS_MID: %0d | OTHERS_HIGH: %0d", masked_addr_hits[5], masked_addr_hits[6], masked_addr_hits[7], masked_addr_hits[8]);

      $display("----------------------------------------------------------------------------------");
      $display(" [3] cp_kind & cp_data Bin Hits:");
      $display("   - WRITE: %0d | READ: %0d", kind_hits[0], kind_hits[1]);
      $display("   - DATA ALL0: %0d | DATA ALL1: %0d | DATA ALT_TOGGLE/PATTERNS active hits", data_hits[0], data_hits[1]);

      $display("----------------------------------------------------------------------------------");
      $display(" [4] Cross Coverage Hits:");
      $display("   - REG_X_KIND Total Valid Hits (Excluding RO/WO invalid access):");
      for(int i=0; i<13; i++) begin
        $display("     Reg[%02d] -> WRITE Hits: %0d, READ Hits: %0d", i, reg_x_kind_hits[i][0], reg_x_kind_hits[i][1]);
      end
      $display("   - datareg_x_kind_x_data_x_mask (GPIODATA Complex Cross) Total Hits : %0d", datareg_complex_hits);
      $display("==================================================================================");
      $display("--- APB Individual Coverpoint Coverages ---");
      $display("cp_reg coverage     = %.2f%%", apb_cov_group.cp_reg.get_coverage());
      $display("cp_masked_addr cov  = %.2f%%", apb_cov_group.cp_masked_addr.get_coverage());
      $display("cp_kind coverage    = %.2f%%", apb_cov_group.cp_kind.get_coverage());
      $display("cp_data coverage    = %.2f%%", apb_cov_group.cp_data.get_coverage());
      $display("REG_X_KIND cross    = %.2f%%", apb_cov_group.REG_X_KIND.get_coverage());
  end
  endfunction : report_phase
endclass : apb_cov_coll_t
