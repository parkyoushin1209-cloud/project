# PL061 GPIO UVM Verification

## Project Overview

ARM PrimeCell PL061 GPIO를 대상으로 APB 기반 UVM 검증 환경을 구축하였다.

본 프로젝트에서는 GPIO Register 동작뿐만 아니라 APB Protocol,
GPIO Interrupt, Register Access Policy 및 Corner Case를 검증하였다.

### Main Objectives

- APB 기반 GPIO Register Read/Write 검증
- UVM RAL을 이용한 Register Abstraction 및 Prediction 검증
- Scoreboard를 이용한 DUT/RAL 상태 비교
- GPIO Interrupt 동작 검증
- SVA를 이용한 APB/GPIO Protocol 및 동작 검증
- Functional Coverage 및 RTL Coverage 수집

---

## Verification Environment

### APB UVC

APB Master Agent를 구성하여 DUT의 APB Slave Interface를 검증하였다.

- Sequencer
- Driver
- Monitor
- Transaction
- Coverage Collector
- APB Checker

### GPIO UVC

GPIO 외부 입력 및 출력 동작을 검증하기 위한 GPIO Agent를 구성하였으며 온-칩 신호를 나타내는 GPIO 계열과 외부와 연결된 pad 신호를 나타내는 GPIO I/O 계열 컴포넌트로 분리하였다.

- GPIO Driver
- GPIO Monitor
- GPIO I/O Agent
- GPIO I/O Monitor
- Virtual Interface

### Virtual Sequence

APB Sequence와 GPIO Sequence를 Virtual Sequence에서 제어하여
Register 설정과 GPIO 입력 변화를 연계한 시나리오를 구성하였다.

### Register Abstraction Layer

UVM RAL을 이용하여 PL061 Register Model을 구성하였다.

검증 대상 주요 Register:

- GPIODATA
- GPIODIR
- GPIOIS
- GPIOIBE
- GPIOIEV
- GPIOIE
- GPIORIS
- GPIOMIS
- GPIOIC
- GPIOAFSEL
- Peripheral ID
- PrimeCell ID

---

## Testbench Architecture

![Testbench Architecture](docs/tb_architecture.png)

Test는 Virtual Sequence를 통해 APB 및 GPIO Sequencer를 제어한다.

DUT에서 발생한 APB 및 GPIO transaction은 Monitor를 통해
Scoreboard와 Coverage Collector로 전달된다.

Scoreboard에서는 DUT의 실제 동작과 Register Model의 예상 상태를 비교하여
Register 및 GPIO 기능의 정상 동작 여부를 확인한다.

---

## Verification Features

### Register Access Verification

각 Register의 Access Policy에 따른 동작을 검증하였다.

- Read/Write
- Read Only
- Write Only
- Reserved Address
- Register Alias Address

Reserved Address 및 잘못된 Access에 대한 Corner Case도 별도의
Sequence를 통해 검증하였다.

### GPIO Interrupt Verification

GPIO 입력 변화에 따른 Interrupt Detection을 검증하였다.

- Rising Edge
- Falling Edge
- Both Edge
- High Level
- Low Level

Interrupt Status 및 Mask Register와 Interrupt Clear 동작을 연계하여
검증하였다.

### Corner Case Verification

일반적인 Register Read/Write뿐만 아니라 다음과 같은 Corner Case를
별도의 Sequence로 구성하였다.

- Reserved Address Access
- Read-only Register Write
- Write-only Register Read
- Interrupt Clear
- GPIO Alias Address
- 다양한 GPIO 입력 변화
- Register 설정과 GPIO 입력 변화의 조합

---

## Scoreboard

Scoreboard에서는 DUT의 Register 상태와 예상 Register 상태를 비교하였다.

특히 GPIO Interrupt 관련 Register의 경우 입력 변화, Interrupt Detection,
Clear 동작 및 Mask 조건을 고려하여 예상값을 계산하였다.

또한 Register별 Read/Write Access Count를 수집하여
검증 과정에서 각 Register와 Access Policy가 실제로 테스트되었는지 확인하였다.

---

## Assertion

SVA 기반 Checker를 이용하여 APB 및 GPIO 동작의 Protocol/Functional
조건을 검증하였다.

### APB Checker

- IDLE → SETUP
- SETUP → ACCESS
- ACCESS → IDLE
- Read/Write Access 조건
- APB Control Signal 관계

### GPIO Checker

GPIO 관련 Control 및 Interrupt 동작에 대한 Assertion을 구성하였다.

---

## Coverage

### Functional Coverage

Register 및 GPIO 기능이 실제 테스트되었는지 확인하기 위해
Functional Coverage를 구성하였다.

- Register Access Coverage
- Read/Write Coverage
- GPIO Interrupt Mode Coverage
- Corner Case Coverage

### RTL Coverage

RTL 내부 동작에 대해서도 FSM 및 Branch Coverage를 수집하였다.

- FSM State Transition Coverage
- Branch Coverage

---

## Debugging

검증 과정에서 DUT와 Scoreboard 간 mismatch가 발생한 경우 단순히 결과값만 비교하지 않고 SystemVerilog simulation scheduling을 분석하여 원인을 추적하였다.


특히 다음과 같은 방법을 사용하였다.

- `$display`와 `$strobe`를 이용한 NBA 이후 값 확인
- `always_ff` / `always_comb` 간 scheduling 분석
- DUT와 Scoreboard의 동일 simulation time 상태 비교
- Interrupt Status 및 Clear 조건 추적
- RAL Prediction과 DUT Register 상태 비교

이를 통해 DUT/Scoreboard timing mismatch의 원인을 분석하고 수정하였다.

---

## Result

# ==================================================================================
#                  [ APB Manual Coverage & Detailed Bin Hit Report ]                
# ==================================================================================
#  [1] cp_reg Bin Hits:
#    - GPIODATA(0x000-3FF) : 913 | GPIODIR(0x400-403) : 767 | GPIOIS(0x404-407)  : 762
#    - GPIOIBE(0x408-40B)  : 745 | GPIOIEV(0x40C-40F) : 778 | GPIOIE(0x410-413)   : 758
#    - GPIORIS(0x414-417)  : 785 | GPIOMIS(0x418-41B) : 788 | GPIOIC(0x41C-41F)   : 801
#    - GPIOAFSEL(0x420-423): 775 | RESERVED(0x424-FDF): 553 | PERIPHID(0xFE0-FEF) : 801
#    - PCELLID(0xFF0-FFF)  : 772
# ----------------------------------------------------------------------------------
#  [2] cp_masked_addr Bin Hits:
#    - ALL0: 771 | ALL1: 205 | UPPER_ON: 8 | LOWER_ON: 4 | ALT_1010: 5
#    - ALT_0101: 6 | OTHERS_LOW: 6642 | OTHERS_MID: 484 | OTHERS_HIGH: 1860
# ----------------------------------------------------------------------------------
#  [3] cp_kind & cp_data Bin Hits:
#    - WRITE: 4158 | READ: 5840
#    - DATA ALL0: 1258 | DATA ALL1: 240 | DATA ALT_TOGGLE/PATTERNS active hits
# ----------------------------------------------------------------------------------
#  [4] Cross Coverage Hits:
#    - REG_X_KIND Total Valid Hits (Excluding RO/WO invalid access):
#      Reg[ 0] -> WRITE Hits: 536, READ Hits: 377
#      Reg[ 1] -> WRITE Hits: 363, READ Hits: 404
#      Reg[ 2] -> WRITE Hits: 376, READ Hits: 386
#      Reg[ 3] -> WRITE Hits: 379, READ Hits: 366
#      Reg[ 4] -> WRITE Hits: 389, READ Hits: 389
#      Reg[ 5] -> WRITE Hits: 360, READ Hits: 398
#      Reg[ 6] -> WRITE Hits: 0, READ Hits: 784
#      Reg[ 7] -> WRITE Hits: 0, READ Hits: 787
#      Reg[ 8] -> WRITE Hits: 801, READ Hits: 0
#      Reg[ 9] -> WRITE Hits: 394, READ Hits: 381
#      Reg[10] -> WRITE Hits: 0, READ Hits: 0
#      Reg[11] -> WRITE Hits: 0, READ Hits: 799
#      Reg[12] -> WRITE Hits: 0, READ Hits: 769
#    - datareg_x_kind_x_data_x_mask (GPIODATA Complex Cross) Total Hits : 752
# ==================================================================================
# --- APB Individual Coverpoint Coverages ---
# cp_reg coverage     = 100.00%
# cp_masked_addr cov  = 100.00%
# cp_kind coverage    = 100.00%
# cp_data coverage    = 100.00%
# REG_X_KIND cross    = 95.00%
# UVM_INFO gpio_cov_coll_t.sv(139) @ 300025: uvm_test_top.gpio_system_env.gpio.gpio_cov_coll [DEBUG] report_phase entered!
# ==================================================================================
#                [ GPIO Manual Coverage & Bin Hit Report ]                          
# ==================================================================================
#  [1] cp_GPAFOUT Bin Hits (Manual Calculated):
#    - ALL0       : 638 | ALL1       : 395 | UPPER_ON   : 391
#    - LOWER_ON   : 396 | ALT_1010   : 357 | ALT_0101   : 390
#    - OTHERS_LOW : 2099 | OTHERS_MID : 3157 | OTHERS_HIGH: 2174
#    - ALL1_2_ALL0: 38 | ALL0_2_ALL1: 20 | ALT_TOGGLE : 31
#    -> Manual Hit Rate: 100.00% (12 / 12 bins)
# ----------------------------------------------------------------------------------
#  [2] cp_nGPAFEN Bin Hits (Manual Calculated):
#    - ALL0       : 32 | ALL1       : 1755 | UPPER_ON   : 138
#    - LOWER_ON   : 128 | ALT_1010   : 107 | ALT_0101   : 97
#    - OTHERS_LOW : 707 | OTHERS_MID : 2145 | OTHERS_HIGH: 4888
#    - ALL1_2_ALL0: 2 | ALL0_2_ALL1: 1 | ALT_TOGGLE : 1
#    -> Manual Hit Rate: 100.00% (12 / 12 bins)
# ==================================================================================
# --- GPIO Individual Coverpoint Coverages (Simulator Built-in) ---
# cp_GPAFOUT coverage = 100.00%
# cp_nGPAFEN coverage = 100.00%
# Register    Read Count    Write Count     Access attribute
# ============================================================================
# GPIODATA       377           536             RW
# GPIODIR        404           363             RW
# GPIOAFSEL      381           394             RW
# GPIOIS         386           376             RW
# GPIOIBE        366           378             RW
# GPIOIEV        389           389             RW
# GPIOIE         398           360             RW
# GPIORIS        784            1              RO
# GPIOMIS        787            1              RO
# GPIOIC          0            801             WO
# GPIOPERIPHID0  172            0              RO
# GPIOPERIPHID1  209            0              RO
# GPIOPERIPHID2  199            1              RO
# GPIOPERIPHID3  219            1              RO
# GPIOPCELLID0   173            0              RO
# GPIOPCELLID1   216            0              RO
# GPIOPCELLID2   180            2              RO
# GPIOPCELLID3   200            1              RO
# Reserved        0            553           Reserved
# Overall        5840          4157             
# intr_mismatch = 0,   read_mismatch = 0, io_mismatch = 0, core_mismatch=0
# ============================================================================



# ** Note: $finish    : /usr/share/questa/questasim/verilog_src/uvm-1.2/src/base/uvm_root.svh(517)
#    Time: 300025 ns  Iteration: 86  Instance: /tb_top
# ==================================================================================
#                  [ RTL Manual Coverage & Percentage Report ]                      
# ==================================================================================
#  [1] FSM State Transition Coverage : 60.00% (3 / 5 cases hit)
#    - IDLE->SETUP: 9998 | SETUP->ENABLE: 9998 | ENABLE->IDLE: 9997
#    - ENABLE->SETUP: 0 | IDLE->IDLE: 0
# ----------------------------------------------------------------------------------
#  [2] Branch / Condition Coverage   : 100.00% (10 / 10 branches hit)
#    - Write Op: 4158 | Read Op: 5840 | Rising: 31479 | Falling: 29392 | Both: 27687
# ==================================================================================

---

## Tools

- SystemVerilog
- UVM 1.2
- Questa
- EDA Playground
- UVM RAL
- SVA
