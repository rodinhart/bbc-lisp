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
hea = &7A
read_cursor = &7F

INCLUDE "macros.s"

ORG &1908
.start

INCLUDE "types.s"
INCLUDE "gc.s"
INCLUDE "native.s"
INCLUDE "words.s"
INCLUDE "lib.s"  

.exec
  ; init stacks
  LDX #0
  STX return_ptr

  ; init heap
  LDA #LO(heap_start)
  STA hea
  LDA #HI(heap_start)
  STA hea + 1

  ; init env
  LDA #LO(core)
  STA env
  LDA #HI(core)
  STA env + 1
 
  ; main
  ADDR pc, code
  JMP run

.core
  EQUW core_plus, core2
.core2
  EQUW core_plus2, core3
.core3
  EQUW core_minus, core4
.core4
  EQUW core_minus2, NIL
.core_plus
  EQUB "+", 0, 0, 0, T_Sym
.core_plus2
  EQUB W_ADD, W_RTS
.core_minus
  EQUB "-", 0, 0, 0, T_Sym
.core_minus2
  EQUB W_SUB, W_RTS

.text
  EQUB "(+ (+ 3 5) (- 11 7))", 0
.code
  EQUB W_PUSH : EQUW text
  EQUB W_READ, W_COMPILE, W_JSR, W_PRN, W_HALT

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
.heap_start
  SKIPTO &7000
.heap_end

SAVE "Forth", start, end, exec
