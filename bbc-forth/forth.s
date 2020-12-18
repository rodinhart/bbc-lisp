\ http://localhost:8081/?disc1=forth.ssd&autoboot

;; Move loop address to non-data stack?

osasci = &FFE3
osnewl = &FFE7

pc = &70
tmp = &72
ctrl = &8F

ORG &1908

.start
  LDX #255 ; init stack
  STX ctrl ; init control stack

  LDA #LO(code) ; init program counter
  STA pc
  LDA #HI(code)
  STA pc + 1

.loop
  LDY #0 ; fetch bytecode
  LDA (pc), Y
  STA tmp
  INY
  LDA (pc), Y
  STA tmp + 1

  JSR advance

  LDA #HI(loop - 1) ; indirect jump, return to loop
  PHA
  LDA #LO(loop - 1)
  PHA
  JMP (tmp)

.advance ; use Y in chunks of 128 instructions
  LDA #2
  CLC
  ADC pc
  STA pc
  LDA #0
  ADC pc + 1
  STA pc + 1
  RTS  

.code
  EQUW Push, 1, Push, 1
  EQUW Push, 20, Loop

  EQUW Rot, Dup, Print, Push
  EQUS " ", 0
  EQUW PrintString
  EQUW Rot, Swap, Over, Add, Rot

  EQUW Dec, Dup, Push, 0, NotEq, While
  EQUW Drop, Drop, Drop
  EQUW Halt

;; words

.Add
  LDA stack_low, X
  CLC
  ADC stack_low - 1, X
  STA stack_low - 1, X
  LDA stack_high, X
  ADC stack_high - 1, X
  STA stack_high - 1, X
  DEX
  RTS

.Dec
  LDA stack_low, X
  SEC
  SBC #1
  STA stack_low, X
  LDA stack_high, X
  SBC #0
  STA stack_high, X
  RTS

.Dup
  INX
  LDA stack_low - 1, X
  STA stack_low, X
  LDA stack_high - 1, X
  STA stack_high, X
  RTS

.Drop
  DEX
  RTS

.Eq
  LDA stack_low, X
  CMP stack_low - 1, X
  BNE Eq_false
  LDA stack_high, X
  CMP stack_high - 1, X
  BNE Eq_false
  
  DEX
  LDA #&FF
  STA stack_low , X
  STA stack_high, X
  RTS
.Eq_false
  DEX
  LDA #0
  STA stack_low, X
  STA stack_high, X
  RTS

.Halt
  CPX #255
  BNE stackError

  PLA
  PLA
  JMP osnewl
.stackError
  BRK
  EQUB 0, "Stack pointer not 0", 0

.Loop
  DEC ctrl
  LDY ctrl
  LDA pc
  STA ctrl_low, Y
  LDA pc + 1
  STA ctrl_high, Y
  RTS

.NewL
  JMP osnewl

.Not
  LDA stack_low, X
  EOR #&FF
  STA stack_low, X
  LDA stack_high, X
  EOR #&FF
  STA stack_high, X
  RTS

.NotEq
  JSR Eq
  JMP Not

.Over
  INX
  LDA stack_low - 2, X
  STA stack_low, X
  LDA stack_high - 2, X
  STA stack_high, X
  RTS

.Print
  JSR printDecimal
  DEX
  RTS

.PrintString
  LDA stack_low, X
  JSR osasci
  LDA stack_high, X
  DEX
  JMP osasci

.Push
  INX
  LDY #0
  LDA (pc), Y
  STA stack_low, X
  INY
  LDA (pc), Y
  STA stack_high, X

  JMP advance

.Rot
  LDA stack_low - 2, X
  PHA
  LDA stack_low - 1, X
  STA stack_low - 2, X
  LDA stack_low, X
  STA stack_low - 1, X
  PLA
  STA stack_low, X

  LDA stack_high - 2, X
  PHA
  LDA stack_high - 1, X
  STA stack_high - 2, X
  LDA stack_high , X
  STA stack_high - 1, X
  PLA
  STA stack_high, X

  RTS

.Swap
  LDA stack_low, X
  PHA
  LDA stack_low - 1, X
  STA stack_low, X
  PLA
  STA stack_low - 1, X

  LDA stack_high, X
  PHA
  LDA stack_high - 1, X
  STA stack_high, X
  PLA
  STA stack_high - 1, X

  RTS

.While
  LDA stack_low, X
  BEQ While_false
  DEX
.While_true
  LDY ctrl
  LDA ctrl_low, Y
  STA pc
  LDA ctrl_high, Y
  STA pc + 1
  RTS
.While_false
  DEX
  INC ctrl
  RTS

;; libs

.printDecimal
  LDA #0
  STA printDecimal_trailing

  LDA #LO(10000)
  STA tmp
  LDA #HI(10000)
  STA tmp + 1
  JSR printDecimal_digit

  LDA #LO(1000)
  STA tmp
  LDA #HI(1000)
  STA tmp + 1
  JSR printDecimal_digit

  LDA #LO(100)
  STA tmp
  LDA #HI(100)
  STA tmp + 1
  JSR printDecimal_digit

  LDA #LO(10)
  STA tmp
  LDA #HI(10)
  STA tmp + 1
  JSR printDecimal_digit

  LDA stack_low, X
  CLC
  ADC #'0'
  JSR osasci
  RTS
.printDecimal_trailing
  EQUB 0
.printDecimal_digit
  LDY #0
.printDecimal_loop
  LDA stack_low, X
  SEC
  SBC tmp
  STA stack_low, X ; could use ZP tmp var
  LDA stack_high, X
  SBC tmp + 1
  STA stack_high, X
  INY
  BCS printDecimal_loop
  
  DEY
  LDA stack_low, X
  CLC
  ADC tmp
  STA stack_low, X
  LDA stack_high, X
  ADC tmp + 1
  STA stack_high, X

  TYA
  BEQ printDecimal_trail

  CLC
  ADC #'0'
  JSR osasci
  LDA #'0'
  STA printDecimal_trailing
  RTS
.printDecimal_trail
  LDA printDecimal_trailing
  JMP osasci

.end
ALIGN &100
.stack_low
  SKIP 256
.stack_high
  SKIP 256
.ctrl_low
  SKIP 256
.ctrl_high

SAVE "Forth", start, end
