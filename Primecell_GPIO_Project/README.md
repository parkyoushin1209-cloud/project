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

GPIO 외부 입력 및 출력 동작을 검증하기 위한 GPIO Agent를 구성하였다.

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

검증 과정에서 DUT와 Scoreboard 간 mismatch가 발생한 경우
단순히 결과값만 비교하지 않고 SystemVerilog simulation scheduling을
분석하여 원인을 추적하였다.

특히 다음과 같은 방법을 사용하였다.

- `$display`와 `$strobe`를 이용한 NBA 이후 값 확인
- `always_ff` / `always_comb` 간 scheduling 분석
- DUT와 Scoreboard의 동일 simulation time 상태 비교
- Interrupt Status 및 Clear 조건 추적
- RAL Prediction과 DUT Register 상태 비교

이를 통해 DUT/Scoreboard timing mismatch의 원인을 분석하고 수정하였다.

---

## Result

| Category | Result |
|---|---|
| Register Verification | PASS |
| APB Protocol Assertion | PASS |
| GPIO Functional Verification | PASS |
| Interrupt Verification | PASS |
| Corner Case Verification | PASS |
| Functional Coverage | XX% |
| FSM Coverage | XX% |
| Branch Coverage | XX% |

---

## Tools

- SystemVerilog
- UVM 1.2
- Questa
- EDA Playground
- UVM RAL
- SVA
