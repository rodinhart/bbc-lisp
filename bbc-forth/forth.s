\ http://localhost:8081/?disc1=forth.ssd&autoboot

\ OS
osasci = &FFE3
osnewl = &FFE7

\ registers
tmp = &70
tos = &72
pc = &74
adr = &76
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
 
  ; main
  ADDR tmp, text
  PUSH tmp
  ADDR pc, code
  JMP run

.text
  EQUB "(+ 3 4)", 0
.code
  EQUB W_READ, W_PRN, W_HALT

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
