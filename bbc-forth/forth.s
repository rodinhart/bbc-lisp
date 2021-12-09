\ http://localhost:8081/?disc1=forth.ssd&autoboot

\ top of stack kept in memory (direct pointer access)?
\ internalize symbols for speed?


\ OS
osasci = &FFE3
osnewl = &FFE7

\ registers
tmp = &70
tos = &72
pc = &74

INCLUDE "bbc-forth/macros.s"

ORG &1908
.start

INCLUDE "bbc-forth/types.s"
INCLUDE "bbc-forth/native.s"
INCLUDE "bbc-forth/words.s"

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
  LDX #0 ; init stacks
  STX return_ptr
 
  ; push data
  ADDR tmp, data
  PUSH tmp

  ; load code
  ADDR pc, code
  JMP run

.data
  EQUW data_s, data_next: EQUB T_Cons
.data_next
  EQUW data_n, NIL: EQUB T_Cons
.data_s
  EQUB "inc", 0, T_Sym
.data_n
  Int32 640

.code
  EQUB W_PRN, W_HALT

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

SAVE "Forth", start, end, exec
