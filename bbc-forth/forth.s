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
.run_jumphigh
  EQUB HI(wordPush - 1)
  EQUB HI(wordAdd - 1)
  EQUB HI(wordPrn - 1)
  EQUB HI(wordHalt - 1)
  EQUB HI(wordJsr - 1)
  EQUB HI(wordRts - 1)

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
  JSR printInt32
  JMP run_next1

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

.Add3
  EQUB W_ADD
  EQUB W_ADD
  EQUB W_RTS
.eleven
  Int32 263
.thirteen
  Int32 1124
.seventeen
  Int32 170
.code
  EQUB W_PUSH : EQUW eleven
  EQUB W_PUSH : EQUW thirteen
  EQUB W_PUSH : EQUW seventeen
  EQUB W_PUSH : EQUW Add3 : EQUB W_JSR ; TODO Array
  EQUB W_PRN
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

; (def printList (fn [x] (if (nil? x) nil (do (prn (fst x)) (printList (rest x))))))
; dup nil eq beq print_done dup fst prn rest jmp printList print_done: rts
.printList
  LDA #'('
  JSR osasci

.printList_loop
  LDA stack_low, X
  STA tos
  LDA stack_high, X
  STA tos + 1

  LDY #4
  LDA (tos), Y
  CMP #1
  BEQ printList_end

  DEX
  LDY #0
  LDA (tos), Y
  STA stack_low, X
  INY
  LDA (tos), Y
  STA stack_high, X
  JSR printInt32

  LDA #' '
  JSR osasci

  LDA stack_low, X
  STA tos
  LDA stack_high, X
  STA tos + 1

  LDY #2
  LDA (tos), Y
  STA stack_low, X
  INY
  LDA (tos), Y
  STA stack_high, X

  JMP printList_loop
.printList_end
  INX
  LDA #')'
  JMP osasci


.printSymbol
  LDA stack_low, X
  STA tmp
  LDA stack_high, X
  STA tmp + 1
  INX

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
  EQUW data_n, data_next: EQUB T_Cons
.data_next
  EQUW data_s, NIL: EQUB T_Cons
.data_n
  EQUD 640: EQUB T_Int32
.data_s
  EQUB "foo", 0, T_Sym

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
