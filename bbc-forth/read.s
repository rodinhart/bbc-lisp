.readList_proxy
  JMP readList
.read
  PULL adr
  LDY #0
  STY read_cursor
.readAny
  JSR readWS
   LDY read_cursor ; already have char in A ?
   LDA (adr), Y
  CMP #'('
  BEQ readList_proxy
  CMP #'0'
  BCC readSymbol
  CMP #':'
  BCS readSymbol

.readNumber
  LDA #0
  STA tos
  STA tos + 1
.readNumber_loop
  ; x10
  LDA tos ; x2
  ASL A
  STA tmp
  LDA tos + 1
  ROL A
  STA tmp + 1
  ASL tmp ; x4
  ROL tmp + 1
  CLC ; x4 + 1
  LDA tmp
  ADC tos
  STA tos
  LDA tmp + 1
  ADC tos + 1
  STA tos + 1
  ASL tos ; (x4 + 1)x2
  ROL tos + 1

   LDY read_cursor ; add digit to tos
  LDA (adr), Y
  SEC
  SBC #'0'
  CLC
  ADC tos
  STA tos
  LDA #0
  ADC tos + 1
  STA tos + 1

  INC read_cursor
   LDY read_cursor ; INY?
  LDA (adr), Y
  CMP #'0'
  BCC readNumber_done
  CMP #':'
  BCC readNumber_loop
.readNumber_done
  LDA tos
  LDY #0
  STA (hea), Y
  LDA tos + 1
  INY
  STA (hea), Y
  LDA #0
  INY
  STA (hea), Y
  INY
  STA (hea), Y
  LDA #T_Int32
  INY
  STA (hea), Y
  INY
  PUSH hea
  JSR gcApply
  RTS

.readSymbol
  LDA #0
  LDY #0
  STA (hea), Y
  INY
  STA (hea), Y
  INY
  STA (hea), Y
  INY
  STA (hea), Y
  INY
  STA (hea), Y
.readSymbol_loop
  LDY read_cursor
  LDA (adr), Y
  CMP #33
  BCC readSymbol_done
  CMP #')'
  BEQ readSymbol_done
  PHA
  LDY #4
  LDA (hea), Y
  TAY
  PLA
  STA (hea), Y
  INY
  TYA
  LDY #4
  STA (hea), Y
  INC read_cursor
  JMP readSymbol_loop
.readSymbol_done
  LDA #T_Sym
  LDY #4
  STA (hea), Y
  INY
  PUSH hea
  JSR gcApply
  RTS


.readList
  INC read_cursor ; skip (
  LDA #LO(NIL)
  LDY #2
  STA (hea), Y
  LDA #HI(NIL)
  INY
  STA (hea), Y
  PUSH hea
  LDA hea
  STA tmp
  LDA hea + 1
  STA tmp + 1
  LDY #5
  JSR gcApply
.readList_loop
  JSR readWS
   LDY read_cursor
   LDA (adr), Y
   CMP #')'
   BEQ readList_done

   PUSH tmp ; push hea?
   JSR readAny
   LDA #T_Cons
   LDY #4
   STA (hea), Y
   LDA #HI(NIL)
   DEY
   STA (hea), Y
   LDA #LO(NIL)
   DEY
   STA (hea), Y
   PULL tos ; set head
   LDA tos + 1
   DEY
   STA (hea), Y
   LDA tos
   DEY
   STA (hea), Y

   PULL tos
   LDA hea
   LDY #2
   STA (tos), Y
   LDA hea + 1
   INY
   STA (tos), Y
   LDA hea
   STA tmp
   LDA hea + 1
   STA tmp + 1
   LDY #5
   JSR gcApply
   JMP readList_loop
.readList_done
  INC read_cursor ; skip )
  PULL tmp
  LDY #2
  LDA (tmp), Y
  STA tos
  INY
  LDA (tmp), Y
  STA tos + 1
  PUSH tos
  RTS


.readWS
  LDY read_cursor
  LDA (adr), Y
  BEQ readWS_eof
  CMP #33
  BCC readWS_next ; BLO
  RTS
.readWS_next
  INC read_cursor
  BCC readWS ; B
.readWS_eof
  BRK
  EQUB 0, "Unexpected end of file", 0