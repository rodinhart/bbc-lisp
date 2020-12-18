\ http://localhost:8081/?disc1=forth.ssd&autoboot

osasci = &FFE3
osnewl = &FFE7

pc = &70
tmp = &72

ORG &1908

.start
  LDX #0 ; init stack

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
  EQUW Push, 5
  EQUW Loop
  EQUW Over, Print, NewL
  EQUW Swap, Dec, Swap, Over, Push, 0, NotEq
  EQUW While
  EQUW Drop
  EQUW Halt

;; words

.Add
  DEX
  LDA stack_low, X
  CLC
  ADC stack_low - 1, X
  STA stack_low - 1, X
  LDA stack_high, X
  ADC stack_high - 1, X
  STA stack_high - 1, X
  RTS

.Dec
  LDA stack_low - 1, X
  SEC
  SBC #1
  STA stack_low - 1, X
  LDA stack_high - 1, X
  SBC #0
  STA stack_high - 1, X
  RTS

.Dup
  LDA stack_low -1, X
  STA stack_low, X
  LDA stack_high -1, X
  STA stack_high, X
  INX
  RTS

.Drop
  DEX
  RTS

.Eq
  DEX
  LDA stack_low, X
  CMP stack_low - 1, X
  BNE Eq_false
  LDA stack_high, X
  CMP stack_high - 1, X
  BNE Eq_false
  
  LDA #&FF
  STA stack_low - 1, X
  STA stack_high - 1, X
  RTS
.Eq_false
  LDA #0
  STA stack_low - 1, X
  STA stack_high - 1, X
  RTS

.Halt
  TXA
  BNE stackError

  PLA
  PLA
  JMP osnewl
.stackError
  BRK
  EQUB 0, "Stack pointer not 0", 0

.Loop
  LDA pc
  STA stack_low, X
  LDA pc + 1
  STA stack_high, X
  INX
  RTS

.NewL
  JMP osnewl

.Not
  LDA stack_low - 1, X
  EOR #&FF
  STA stack_low - 1, X
  LDA stack_high - 1, X
  EOR #&FF
  STA stack_high - 1, X
  RTS

.NotEq
  JSR Eq
  JMP Not

.Over
  LDA stack_low - 2, X
  STA stack_low, X
  LDA stack_high - 2, X
  STA stack_high, X
  INX
  RTS

.Print
  DEX
  JMP printDecimal

.Push
  LDY #0
  LDA (pc), Y
  STA stack_low, X
  INY
  LDA (pc), Y
  STA stack_high, X
  INX

  JMP advance

.Swap
  LDA stack_low - 1, X
  PHA
  LDA stack_low - 2, X
  STA stack_low - 1, X
  PLA
  STA stack_low - 2, X

  LDA stack_high - 1, X
  PHA
  LDA stack_high - 2, X
  STA stack_high - 1, X
  PLA
  STA stack_high - 2, X

  RTS

.While
  DEX
  LDA stack_low, X
  BEQ While_false
  LDA stack_low - 1, X
  STA pc
  LDA stack_high - 1, X
  STA pc + 1
  RTS
.While_false
  DEX
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

SAVE "Forth", start, end
