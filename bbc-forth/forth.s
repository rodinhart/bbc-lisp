\ http://localhost:8081/?disc1=forth.ssd&autoboot

\ add mutates?!?


\ OS
osasci = &FFE3
osnewl = &FFE7

\ registers
tmp = &70
tos = &72
pc = &74

INCLUDE "macros.s"

ORG &1940
.start

INCLUDE "types.s"
INCLUDE "gc.s"
INCLUDE "native.s"
INCLUDE "words.s"

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
  

.exec
  ; init stacks
  LDX #0
  STX return_ptr

  ; init heap
  LDA #LO(heap_start)
  STA heap_ptr
  LDA #HI(heap_start)
  STA heap_ptr + 1
 
  ; load code
  ADDR pc, code
  JMP run

.data_zero
  Int32 0
.data_2
  Int32 2
.data_15
  Int32 16
.code
  EQUB W_PUSH: EQUW data_zero
.code_loop
  EQUB W_DUP, W_PUSH: EQUW fib : EQUB W_JSR, W_PRN, W_NEWLINE
  EQUB W_INC
  EQUB W_DUP, W_PUSH : EQUW data_15 : EQUB W_CMP, W_BLO : EQUW code_loop - code_done
.code_done
  EQUB W_DROP, W_HALT
.fib
  EQUB W_DUP, W_PUSH : EQUW data_2 : EQUB W_CMP, W_BLO : EQUW fib_base - fib_recurse
.fib_recurse
  EQUB W_DEC, W_DUP, W_PUSH : EQUW fib : EQUB W_JSR
  EQUB W_SWAP, W_DEC, W_PUSH : EQUW fib : EQUB W_JSR
  EQUB W_ADD
.fib_base
  EQUB W_RTS

.end
.stack_ptr
  EQUB 0
.return_ptr
  EQUB 0
.heap_ptr
  EQUW heap_start
ALIGN &100
.stack_low
  SKIP 256
.stack_high
  SKIP 256
.return_low
  SKIP 256
.return_high
  SKIP 256
.heap_start
  SKIPTO &7000
.heap_end

SAVE "Forth", start, end, exec
