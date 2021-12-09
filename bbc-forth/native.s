.printInt32
  LDA stack_low, X
  STA tos
  LDA stack_high, X
  STA tos + 1

  LDY #0
  LDA (tos), Y
  PHA
  INY
  LDA (tos), Y
  STA tos + 1
  PLA
  STA tos

  LDA #0
  STA printInt32_trailing

  LDA #LO(10000)
  STA tmp
  LDA #HI(10000)
  STA tmp + 1
  JSR printInt32_digit

  LDA #LO(1000)
  STA tmp
  LDA #HI(1000)
  STA tmp + 1
  JSR printInt32_digit

  LDA #LO(100)
  STA tmp
  LDA #HI(100)
  STA tmp + 1
  JSR printInt32_digit

  LDA #LO(10)
  STA tmp
  LDA #HI(10)
  STA tmp + 1
  JSR printInt32_digit

  LDA tos
  CLC
  ADC #'0'
  JSR osasci

  INX
  RTS
.printInt32_trailing
  EQUB 0
.printInt32_digit
  LDY #0
.printInt32_loop
  LDA tos
  SEC
  SBC tmp
  STA tos
  LDA tos + 1
  SBC tmp + 1
  STA tos + 1
  INY
  BCS printInt32_loop
  
  DEY
  LDA tos
  CLC
  ADC tmp
  STA tos
  LDA tos + 1
  ADC tmp + 1
  STA tos + 1

  TYA
  BEQ printInt32_trail

  CLC
  ADC #'0'
  JSR osasci
  LDA #'0'
  STA printInt32_trailing
  RTS
.printInt32_trail
  LDA printInt32_trailing
  JMP osasci


.printSymbol
  PULL tmp

  LDY #0
.printSymbol_loop
  LDA (tmp), Y
  BEQ printSymbol_end
  JSR osasci
  INY
  JMP printSymbol_loop
.printSymbol_end
  RTS
