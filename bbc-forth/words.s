W_PUSH = 0
W_ADD  = 1
W_PRN  = 2
W_HALT = 3
W_JSR = 4
W_RTS = 5
W_OSASCI = 6
W_BEQ = 7
W_ISNIL = 8
W_DUP = 9
W_CDR = 10
W_JMP = 11
W_CAR = 12
W_DROP = 13

.run
  LDY #0
  LDA (pc), Y

  TAY
  LDA run_jumphigh, Y
  PHA
  LDA run_jumplow, Y
  PHA
  RTS

.run_next1
  LDA #1
.run_next
  CLC
  ADC pc
  STA pc
  LDA #0
  ADC pc + 1
  STA pc + 1
  JMP run
.run_done
  RTS

.run_jumplow
  EQUB LO(wordPush - 1)
  EQUB LO(wordAdd - 1)
  EQUB LO(wordPrn - 1)
  EQUB LO(wordHalt - 1)
  EQUB LO(wordJsr - 1)
  EQUB LO(wordRts - 1)
  EQUB LO(wordOsasci - 1)
  EQUB LO(wordBeq - 1)
  EQUB LO(wordIsNil - 1)
  EQUB LO(wordDup - 1)
  EQUB LO(wordCdr - 1)
  EQUB LO(wordJmp - 1)
  EQUB LO(wordCar - 1)
  EQUB LO(wordDrop - 1)
.run_jumphigh
  EQUB HI(wordPush - 1)
  EQUB HI(wordAdd - 1)
  EQUB HI(wordPrn - 1)
  EQUB HI(wordHalt - 1)
  EQUB HI(wordJsr - 1)
  EQUB HI(wordRts - 1)
  EQUB HI(wordOsasci - 1)
  EQUB HI(wordBeq - 1)
  EQUB HI(wordIsNil - 1)
  EQUB HI(wordDup - 1)
  EQUB HI(wordCdr - 1)
  EQUB HI(wordJmp - 1)
  EQUB HI(wordCar - 1)
  EQUB HI(wordDrop - 1)
  
.wordPush
  DEX
  LDY #1
  LDA (pc), Y
  STA stack_low, X
  INY
  LDA (pc), Y
  STA stack_high, X

  LDA #3
  JMP run_next

.wordAdd
  PULL tos
  PULL tmp
  CLC
  LDY #0
  LDA (tmp), Y
  ADC (tos), Y
  STA (tos), Y
  INY
  LDA (tmp), Y
  ADC (tos), Y
  STA (tos), Y
  INY
  LDA (tmp), Y
  ADC (tos), Y
  STA (tos), Y
  INY
  LDA (tmp), Y
  ADC (tos), Y
  STA (tos), Y
  PUSH tos

  JMP run_next1

.wordPrn
  PULL tos ; TODO: implement PEEK
  DEX ; not needed?
  LDY #4
  LDA (tos), Y

  TAY
  LDA wordPrn_high, Y
  PHA
  LDA wordPrn_low, Y
  PHA
  RTS
.wordPrn_low
  EQUB LO(wordPrn_symbol - 1)
  EQUB LO(wordPrn_nil - 1)
  EQUB LO(wordPrn_int32 - 1)
  EQUB LO(wordPrn_cons - 1)
.wordPrn_high
  EQUB HI(wordPrn_symbol - 1)
  EQUB HI(wordPrn_nil - 1)
  EQUB HI(wordPrn_int32 - 1)
  EQUB HI(wordPrn_cons - 1)

.wordPrn_symbol
.wordPrn_nil
  JSR printSymbol
  JMP run_next1

.wordPrn_int32
  JSR printInt32
  JMP run_next1

.wordPrn_cons
  ADDR tmp, printList
  PUSH tmp
  JMP wordJsr


.wordHalt
  JMP run_done

.wordJsr
  STX stack_ptr
  LDX return_ptr
  DEX ; PUSH_ALT
  LDA pc
  STA return_low, X
  LDA pc + 1
  STA return_high, X

  STX return_ptr
  LDX stack_ptr

  PULL pc

  LDA #0
  JMP run_next

.wordRts
  STX stack_ptr
  LDX return_ptr

  LDA return_low, X ; PULL_ALT
  STA pc
  LDA return_high, X
  STA pc + 1
  INX

  STX return_ptr
  LDX stack_ptr
  JMP run_next1

.wordOsasci ; TODO: make more efficient
  PULL tos
  LDA tos
  JSR osasci
  JMP run_next1

.wordBeq ; TODO: make more efficient
  PULL tos
  LDA tos
  BNE wordBeq_done
  LDA tos + 1
  BNE wordBeq_done

  CLC
  LDY #2
  LDA (pc), Y
  PHA
  DEY
  LDA (pc), Y
  ADC pc
  STA pc
  PLA
  ADC pc + 1
  STA pc + 1
.wordBeq_done
  LDA #3
  JMP run_next

.wordIsNil
  PULL tos
  SEC
  LDA tos
  SBC #LO(NIL)
  STA tos
  LDA tos + 1
  SBC #HI(NIL)
  STA tos + 1
  PUSH tos
  JMP run_next1

.wordDup ; TODO: make more efficient
  PULL tos
  PUSH tos
  PUSH tos
  JMP run_next1

.wordCdr
  PULL tos
  LDY #2
  LDA (tos), Y
  STA tmp
  INY
  LDA (tos), Y
  STA tmp + 1
  PUSH tmp
  JMP run_next1

.wordJmp
  PULL pc
  LDA #0
  JMP run_next

.wordCar
  PULL tos
  LDY #0
  LDA (tos), Y
  STA tmp
  INY
  LDA (tos), Y
  STA tmp + 1
  PUSH tmp
  JMP run_next1

.wordDrop
  INX
  JMP run_next1
