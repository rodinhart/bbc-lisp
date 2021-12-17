W_PUSH = 0 ; args
W_ADD  = 1 ; allocs
W_PRN  = 2
W_HALT = 3
W_JSR = 4 ; args
W_RTS = 5
W_OSASCI = 6
W_BEQ = 7 ; args
W_ISNIL = 8
W_DUP = 9
W_CDR = 10
W_JMP = 11 ; args
W_CAR = 12
W_DROP = 13
W_ROT = 14
W_NEWLINE = 15
W_INC = 16 ; allocs
W_CMP = 17
W_DEC = 18 ; allocs
W_SWAP = 19
W_BLO = 20
W_B = 21
W_BHS = 22
W_READ = 23

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
  EQUB LO(wordRot - 1)
  EQUB LO(wordNewline - 1)
  EQUB LO(wordInc - 1)
  EQUB LO(wordCmp - 1)
  EQUB LO(wordDec - 1)
  EQUB LO(wordSwap - 1)
  EQUB LO(wordBlo - 1)
  EQUB LO(wordB - 1)
  EQUB LO(wordBhs - 1)
  EQUB LO(wordRead - 1)
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
  EQUB HI(wordRot - 1)
  EQUB HI(wordNewline - 1)
  EQUB HI(wordInc - 1)
  EQUB HI(wordCmp - 1)
  EQUB HI(wordDec - 1)
  EQUB HI(wordSwap - 1)
  EQUB HI(wordBlo - 1)
  EQUB HI(wordB - 1)
  EQUB HI(wordBhs - 1)
  EQUB HI(wordRead - 1)
  
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
  JSR gcAlloc

  LDY #0
  LDA (tos), Y
  STA (tmp), Y
  INY
  LDA (tos), Y
  STA (tmp), Y
  INY
  LDA (tos), Y
  STA (tmp), Y
  INY
  LDA (tos), Y
  STA (tmp), Y
  INY
  LDA (tos), Y
  STA (tmp), Y

  PULL tos

  CLC
  LDY #0
  LDA (tos), Y
  ADC (tmp), Y
  STA (tmp), Y
  INY
  LDA (tos), Y
  ADC (tmp), Y
  STA (tmp), Y
  INY
  LDA (tos), Y
  ADC (tmp), Y
  STA (tmp), Y
  INY
  LDA (tos), Y
  ADC (tmp), Y
  STA (tmp), Y
  PUSH tmp

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

.wordIsNil
  PULL tos
  LDY #4
  LDA (tos), Y
  CMP #T_Nil
  PHP
  PLA
  STA tmp
  STA tmp + 1
  PUSH tmp
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

.wordRot
  LDA stack_low, X
  STA tmp
  LDA stack_high, X
  STA tmp + 1

  LDA stack_low + 2, X
  STA stack_low, X
  LDA stack_high + 2, X
  STA stack_high, X

  LDA stack_low + 1, X
  STA stack_low + 2, X
  LDA stack_high + 1, X
  STA stack_high + 2, X

  LDA tmp
  STA stack_low + 1, X
  LDA tmp + 1
  STA stack_high + 1, X

  JMP run_next1

.wordNewline
  JSR osnewl
  JMP run_next1

.wordInc
  PULL tos

  CLC
  LDY #0
  LDA (tos), Y
  ADC #1
  STA (tmp), Y

  INY
  LDA (tos), Y
  ADC #0
  STA (tmp), Y

  INY
  LDA (tos), Y
  ADC #0
  STA (tmp), Y

  INY
  LDA (tos), Y
  ADC #0
  STA (tmp), Y

  INY
  LDA #T_Int32
  STA (tmp), Y
  INY

  PUSH tmp
  JMP run_next1

.wordCmp
  PULL tos
  PULL tmp

  SEC
  LDY #0
  LDA (tmp), Y
  SBC (tos), Y
  INY
  LDA (tmp), Y
  SBC (tos), Y
  INY
  LDA (tmp), Y
  SBC (tos), Y
  INY
  LDA (tmp), Y
  SBC (tos), Y

  PHP
  PLA
  STA tmp
  STA tmp + 1
  PUSH tmp
  JMP run_next1

.wordDec
  PULL tos
  JSR gcAlloc

  SEC
  LDY #0
  LDA (tos), Y
  SBC #1
  STA (tmp), Y

  INY
  LDA (tos), Y
  SBC #0
  STA (tmp), Y

  INY
  LDA (tos), Y
  SBC #0
  STA (tmp), Y

  INY
  LDA (tos), Y
  SBC #0
  STA (tmp), Y

  INY
  LDA #T_Int32
  STA (tmp), Y
  INY

  PUSH tmp
  JMP run_next1

.wordSwap
  LDA stack_low, X
  STA tmp
  LDA stack_high, X
  STA tmp + 1

  LDA stack_low + 1, X
  STA stack_low, X
  LDA stack_high + 1, X
  STA stack_high, X

  LDA tmp
  STA stack_low + 1, X
  LDA tmp + 1
  STA stack_high + 1, X

  JMP run_next1

.wordBeq ; TODO: make more efficient
  PULL tos
  LDA tos
  PHA
  PLP
  BNE wordB_done
  JMP wordB

.wordBlo
  PULL tos
  LDA tos
  PHA
  PLP
  BCS wordB_done
  JMP wordB

.wordB
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
.wordB_done
  LDA #3
  JMP run_next

.wordBhs
  PULL tos
  LDA tos
  PHA
  PLP
  BCC wordB_done
  JMP wordB

.wordRead
  JSR read
  JMP run_next1