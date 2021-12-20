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
  STA (hea), Y
  LDA tos
  INY
  STA (hea), Y
  LDA tos + 1
  INY
  STA (hea), Y
  LDA #W_GET
  INY
  STA (hea), Y
  INY
  JSR gcApply
  RTS


.wordCompile_nil
.wordCompile_int32
  PULL tos
  LDA #W_PUSH
  LDY #0
  STA (hea), Y
  LDA tos
  INY
  STA (hea), Y
  LDA tos + 1
  INY
  STA (hea), Y
  INY
  JSR gcApply
  RTS

.wordCompile_cons ; e.g. (+ x y)
  PULL tos
  CDR tos, tos ; ignore +/op for now

  PUSH tos ; remember (x y)
  CAR tmp, tos ; compile x
  PUSH tmp
  JSR compile

  PULL tos
  CDR tos, tos
  CAR tmp, tos ; compile y
  PUSH tmp
  JSR compile

  LDA #W_ADD
  LDY #0
  STA (hea), Y
  
  INY
  JSR gcApply
  RTS
