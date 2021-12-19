\ http://localhost:8081/?disc1=forth.ssd&autoboot

\ OS
osasci = &FFE3
osnewl = &FFE7

\ registers
tmp = &70
tos = &72
pc = &74
adr = &76
env = &78
read_cursor = &7F

INCLUDE "macros.s"

ORG &1908
.start

INCLUDE "types.s"
INCLUDE "gc.s"
INCLUDE "native.s"
INCLUDE "read.s"
INCLUDE "words.s"
INCLUDE "lib.s"  

.exec
  ; init stacks
  LDX #0
  STX return_ptr

  ; init heap
  LDA #LO(heap_start)
  STA heap_ptr
  LDA #HI(heap_start)
  STA heap_ptr + 1

  ; init env
  LDA #LO(NIL)
  STA env
  LDA #HI(NIL)
  STA env + 1
 
  ; main
  ADDR tmp, text
  PUSH tmp
  ADDR pc, code
  JMP run

.text
  EQUB "zc", 0
.sym_z
  EQUB "z", 0, 0, 0, T_Sym
.code
  EQUB W_PUSH : EQUW sym_z : EQUB W_PUSH : EQUW data_42 : EQUB W_SET
  EQUB W_PUSH : EQUW text : EQUB W_READ, W_COMPILE, W_JSR, W_PRN, W_HALT
.data_42
  Int32 42

.end
.stack_ptr
  EQUB 0
.return_ptr
  EQUB 0
.heap_ptr
  EQUW 0
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
