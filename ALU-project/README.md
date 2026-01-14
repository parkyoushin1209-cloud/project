ASMD 차트를 기반으로 FSM 컨트롤러와 데이터패스를 분리하여 설계한 멀티사이클 ALU 구현 프로젝트

프로젝트 개요
본 프로젝트는 ASMD(Algorithmic State Machine with Data path) 차트를 활용하여 멀티사이클 ALU (Arithmetic Logic Unit) 를 설계한 것이다.
ALU는 FSM 기반 컨트롤러를 통해 제어되며, 산술 연산과 논리 연산 기능을 수행한다.
ASMD 차트를 기반으로 상태 전이와 각 상태에서 수행되는 데이터패스 동작을 정의하고, 이를 Verilog HDL로 구현함으로써 컨트롤러와 데이터패스를 명확히 분리한 구조를 갖는다.

ALU Control	기능
f0: Addition (덧셈)
f1:	Subtraction (뺄셈, 2의 보수 방식)
f2:	Multiplication (Shift-and-Add 방식)
f3:	Bitwise AND
f4:	Bitwise OR
f5:	Bitwise XOR

프로젝트 진행 과정
1. ASMD 차트 작성
각 연산을 상태(State)의 흐름으로 표현하고, 상태 전이 조건과 상태별 레지스터 동작 및 필요한 제어 신호를 정의하였다.
이를 통해 FSM 컨트롤러 설계의 기반을 마련하였다.

2. 탑 모듈 작성 (ALU_top)
ALU_top 모듈은 컨트롤러 모듈과 데이터패스 모듈을 인스턴스화하며, 두 모듈 간의 신호를 연결하는 상위 래퍼(Wrapper) 역할을 수행한다.

3. 컨트롤러 모듈 작성 (ALU_controller)
ALU_controller는 ASMD 차트를 기반으로 한 FSM으로 구성되어 있으며, 각 상태에서 필요한 제어 신호를 생성하여 데이터패스가 올바른 연산을 수행할 수 있도록 제어한다.

4. 데이터패스 모듈 작성 (ALU_datapath)
ALU_datapath는 컨트롤러로부터 전달받은 제어 신호에 따라 레지스터 연산, 산술 연산, 논리 연산을 수행하며 결과 및 플래그를 생성한다.

5. 테스트벤치 작성 (tb_alu)
tb_alu 모듈은 다음과 같은 역할을 수행한다.
클럭 펄스 생성
입력 데이터 및 ALU 제어 신호 인가
연산 결과 및 상태 플래그(N, Z, C, V) 출력
여러 연산을 순차적으로 테스트하여 설계의 정상 동작을 확인 가능하다.

6. 시뮬레이션 및 GTKWave 확인
시뮬레이션 결과를 2진수 및 10진수 형태로 출력하여 각 산술 연산의 결과와 bitwise 연산의 동작이 올바른지 확인하였다.
또한 GTKWave를 통해 내부 신호의 파형을 확인하였으며, 관련 파형 이미지를 첨부하였다.




