.compile
  PULL tos
  DEX
  LDY #4
  LDA (tos), Y

  TAY
  LDA wordCompile_high, Y
  PHA
  LDA wordCompile_low, Y
  PHA
  RTS
.wordCompile_low
  EQUB LO(wordCompile_symbol - 1)
  EQUB LO(wordCompile_nil - 1)
  EQUB LO(wordCompile_int32 - 1)
  EQUB LO(wordCompile_cons - 1)
.wordCompile_high
  EQUB HI(wordCompile_symbol - 1)
  EQUB HI(wordCompile_nil - 1)
  EQUB HI(wordCompile_int32 - 1)
  EQUB HI(wordCompile_cons - 1)

.wordCompile_symbol
  PULL tos
  LDA #W_PUSH
  LDY #0
  STA (tmp), Y
  LDA tos
  INY
  STA (tmp), Y
  LDA tos + 1
  INY
  STA (tmp), Y
  LDA #W_GET
  INY
  STA (tmp), Y
  LDA #W_RTS
  INY
  STA (tmp), Y
  PUSH tmp
  INY
  JSR gcApply
  RTS


.wordCompile_nil
.wordCompile_int32
  PULL tos
  LDA #W_PUSH
  LDY #0
  STA (tmp), Y
  LDA tos
  INY
  STA (tmp), Y
  LDA tos + 1
  INY
  STA (tmp), Y
  LDA #W_RTS
  INY
  STA (tmp), Y
  PUSH tmp
  INY
  JSR gcApply
  RTS

.wordCompile_cons
  PULL tos
  CDR tos, tos ; ignore +/op for now
  CAR tmp, tos
  LDA #W_PUSH
  LDY #0
  STA (hea), Y
  LDA tmp
  INY
  STA (hea), Y
  LDA tmp + 1
  INY
  STA (hea), Y

  CDR tos, tos
  CAR tmp, tos
  LDA #W_PUSH
  LDY #3
  STA (hea), Y
  LDA tmp
  INY
  STA (hea), Y
  LDA tmp + 1
  INY
  STA (hea), Y

  LDA #W_ADD
  INY
  STA (hea), Y

  LDA #W_RTS
  INY
  STA (hea), Y
  
  PUSH hea
  INY
  JSR gcApply
  RTS