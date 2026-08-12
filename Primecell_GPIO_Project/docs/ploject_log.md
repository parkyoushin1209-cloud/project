# Project Progress Log

## Phase 1 - PRIMECELL GPIO SPEC 분석 검증 계획 수랍
Arm Developer에서 제공하는 PRIMECELL GPIO(PL061) spec을 분석 후 
- 각 레지스터, 신호 별 주요 특징을 파악
- PL061의 동작을 파악
- 위의 내용을 정리한 노트를 기반으로 TB 환경 구성 및 주요 검증 사항 추출
  
## Phase 2  - APB UVC
PL061에 나와 있는 APB 프로토콜 관련 내용을 바탕으로 다음의 코들들을 작성함
- APB transaction을 정의
- APB driver/monitor를 구현
- APB protocol checker를 작성

## Phase  - GPIO UVC

- GPIO transaction 정의
- GPIO input/output interface 구성
- GPIO monitor 구현

## Phase 3 - Register Model
spec에 제공된 레지스터 별 offset 및 주소 공간 크기등을 반영해
- PL061 Register Model 작성
- Register access policy 정의
- RAL prediction 연동
+ RAL prediction 방식의 경우 GPIODATA 레지스터에 대한 Alias 기능을 구현하기 위한 방법을 모색한 끝에 매우 많은 수의 콜백 등록은 많은 오버헤드를
초래할 수 있다는 점을 고려해 아닌 암묵적 예측을 사용함

## Phase 4 - Scoreboard
스코어보드에서 직접 암묵적 예측 및 예상 값 생성을 진행하도록 설계함
- Register reference model 구현
- DUT/RAL 비교
- Interrupt 상태 계산

## Phase 5 - Interrupt Verification
열거형 타입 변수를 사용해 인터럽트 감지 로직을 표현했으며 추가적인 변수를 사용해 소프트웨어 및 에지 반응형 인터럽트인 경우 인터럽트 리셋 로직을 반영할 수 있도록 함
- Rising/Falling/Both Edge
- High/Low level
- GPIOIC clear 동작

## Phase 6 - Corner Case

- Reserved access
- RO/WO access
- Alias address
- Interrupt clear

## Phase 7 - Debugging

- DUT/Scoreboard mismatch 발생
- simulation scheduling 분석
- NBA timing 확인
- `$display` / `$strobe` 비교
- 원인 수정
