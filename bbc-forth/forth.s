\ http://localhost:8081/?disc1=forth.ssd&autoboot

\ top of stack kept in memory (direct pointer access)?
\ internalize symbols for speed?

osasci = &FFE3
osnewl = &FFE7

\ symb 0  Symbol
\ nil0 1  NIL
\ 1234 2  Int32
\ xxyy 3  Cons
\ LLAA 4  Array

tmp = &70
tos = &72
pc = &74

T_Sym = 0
T_Nil = 1
T_Int32 = 2
T_Cons = 3
T_Array = 4

MACRO ADDR reg, address
  LDA #LO(address)
  STA reg
  LDA #HI(address)
  STA reg + 1
ENDMACRO

MACRO Array len, addr
  EQUW len, addr
  EQUB T_Array
ENDMACRO

MACRO Int32 n
  EQUD n
  EQUB T_Int32
ENDMACRO

MACRO PULL reg
  LDA stack_low, X
  STA reg
  LDA stack_high, X
  STA reg + 1
  INX
ENDMACRO

MACRO PUSH reg
  DEX
  LDA reg
  STA stack_low, X
  LDA reg + 1
  STA stack_high, X
ENDMACRO

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

ORG &1908

.start
  LDX #0 ; init stacks
  STX return_ptr
 
  DEX
  LDA #LO(data)
  STA stack_low, X
  LDA #HI(data)
  STA stack_high, X

  ; JSR printList

  ADDR pc, code
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
  PULL tos
  LDY #0
  LDA (tos), Y
  JSR osasci
  INY
  LDA (tos), Y
  JSR osasci
  INY
  LDA (tos), Y
  JSR osasci
  INY
  LDA (tos), Y
  JSR osasci

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


.code
  EQUB W_PRN, W_HALT
  EQUB W_PUSH : EQUW printList : EQUB W_JSR
  EQUB W_HALT

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


.printList
  EQUB W_PUSH : EQUW '(' : EQUB W_OSASCI
.printList_loop
  EQUB W_DUP, W_ISNIL, W_BEQ : EQUW 17

  EQUB W_DUP, W_CAR, W_PRN
  EQUB W_CDR
  EQUB W_DUP, W_ISNIL, W_BEQ : EQUW 4
  EQUB W_PUSH : EQUW ' ' : EQUB W_OSASCI
  EQUB W_PUSH : EQUW printList_loop : EQUB W_JMP

  EQUB W_PUSH : EQUW ')' : EQUB W_OSASCI
  EQUB W_DROP, W_RTS

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

.NIL
  EQUB "nil", 0, T_Nil
.data
  EQUW data_s, data_next: EQUB T_Cons
.data_next
  EQUW data_n, NIL: EQUB T_Cons
.data_s
  EQUB "inc", 0, T_Sym
.data_n
  Int32 640

.end
.stack_ptr
  EQUB 0
.return_ptr
  EQUB 0
ALIGN &100
.stack_low
  SKIP 256
.stack_high
  SKIP 256
.return_low
  SKIP 256
.return_high
  SKIP 256

SAVE "Forth", start, end
