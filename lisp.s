\ http://localhost:8081/?disc1=lisp.ssd&autoboot

;; make all label verbNoun_sublabel
;; macro for init cells?
;; ZERO exp ?
;; cons macro?
;; use zero page for temp stuff (like read number)
;; add tests
;; add *
;; refactor symbol decoding (unknown & print)

oswrch = &FFEE
osasci = &FFE3
osnewl = &FFE7

ret = &70
exp = &72
env = &74
tmp = &76
frl = &78

INCLUDE "macros.s"

ORG &2000

.start
    JSR freeInit

    JSR coreInit
    LDX #0 ; init stack
    PUSH ret

    ADDR sourceReg, source
.loop
    JSR osnewl
    JSR freeReport
    MOVE exp, sourceReg
    JSR read
    TYA
    CLC
    ADC sourceReg
    STA sourceReg
    LDA #0
    ADC sourceReg + 1
    STA sourceReg + 1

    MOVE exp, ret
     ;PUSH exp
     ;JSR print
     ;JSR osnewl
     ;PULL exp

    PEEK env
    JSR eval
    
    MOVE exp, ret
    JSR print
    JSR osnewl

    JSR freeGC

    MOVE exp, sourceReg
    LDY #0
    LDA #0
    CMP (exp), Y
    BNE loop

    RTS
.sourceReg
    EQUW 0
.source
    INCBIN "core.clj"
    EQUB 0

    INCLUDE "core.s"
    INCLUDE "eval.s"
    INCLUDE "gc.s"
    INCLUDE "print.s"
    INCLUDE "read.s"
    INCLUDE "types.s"
    INCLUDE "util.s"
.end

    ALIGN &100
.stack_low
    SKIP 256
.stack_high
    SKIP 256
.heap_start
    SKIP 128 * 32
.heap_end
.tests
    ADDR exp, test_symbol
    JSR read
    LDA #&42
    LDY #0
    CMP (ret), Y
    BNE test_throw

    LDA #&C2
    INY
    CMP (ret), Y
    BNE test_throw

    LDA #&C5
    INY
    CMP (ret), Y
    BNE test_throw

    LDA #&C7
    INY
    CMP (ret), Y
    BNE test_throw

    RTS
.test_throw
    BRK
    EQUB 0, "Test failed", 0
.test_symbol
    EQUB "abcd", 0
.tests_end

SAVE "Lisp", start, end
SAVE "Tests", start, tests_end, tests
