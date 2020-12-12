.free_heap
    EQUW heap_start
.free_size
    EQUB (heap_end - heap_start) DIV 32

.freeAlloc
    LDA #0
    CMP frl
    BNE freeAlloc_notnil
    CMP frl + 1
    BEQ freeAlloc_outofmemory
.freeAlloc_notnil
    MOVE ret, frl
    TAIL frl, ret
    LDA #0
    LDY #0
    STA (ret), Y
    INY
    STA (ret), Y
    INY
    STA (ret), Y
    INY
    STA (ret), Y
    RTS
.freeAlloc_outofmemory
    BRK
    EQUB 0, "Out of memory", 0

.freeCollect
    TXA
    PHA
    LDA #0
    STA frl
    STA frl + 1
    MOVE tmp, free_heap
    LDX free_size
.freeCollect_loop
    LDY #0
    LDA (tmp), Y
    BIT freeMark_mask
    BNE freeCollect_skip

    TAILSET tmp, frl
    MOVE frl, tmp
.freeCollect_next
    LDA #32
    CLC
    ADC tmp
    STA tmp
    LDA #0
    ADC tmp + 1
    STA tmp + 1
    DEX
    BNE freeCollect_loop
    PLA
    TAX
    RTS
.freeCollect_skip
    AND #&FE ; clear mark
    STA (tmp), Y
    JMP freeCollect_next

.freeGC_sp
    EQUB 0
.freeGC
    STX freeGC_sp
.freeGC_loop
    LDY freeGC_sp
    BEQ freeGC_end
    LDA stack_low, Y
    STA exp
    LDA stack_high, Y
    STA exp + 1
    JSR freeMark

    LDY freeGC_sp
    INY
    STY freeGC_sp
    JMP freeGC_loop
.freeGC_end
    JMP freeCollect

.freeInit
    LDY #0
    MOVE exp, free_heap
    LDX free_size
.freeInit_loop
    LDA #0 ; clear marked
    STA (exp), Y
    LDA #32
    CLC
    ADC exp
    STA exp
    LDA #0
    ADC exp + 1
    STA exp + 1
    DEX
    BNE freeInit_loop

    JMP freeCollect

.freeMark_mask
    EQUB 1
.freeMark
    LDA #0
    CMP exp
    BNE freeMark_notnil
    CMP exp + 1
    BNE freeMark_notnil
    RTS
.freeMark_notnil
    LDY #0
    LDA (exp), Y
    BIT freeMark_mask
    BNE freeMark_done

    JSR getType
    LDA freeMark_jumphigh, Y
    PHA
    LDA freeMark_jumplow, Y
    PHA
.freeMark_done
    RTS
.freeMark_jumplow ; perhaps jump table is overkill here
    EQUB LO(freeMark_done - 1)
    EQUB LO(freeMark_cons - 1)
    EQUB LO(freeMark_proc - 1)
    EQUB LO(freeMark_mark - 1)
    EQUB LO(freeMark_mark - 1)
    EQUB LO(freeMark_mark - 1)
    EQUB LO(freeMark_mark - 1)
.freeMark_jumphigh
    EQUB HI(freeMark_done - 1)
    EQUB HI(freeMark_cons - 1)
    EQUB HI(freeMark_proc - 1)
    EQUB HI(freeMark_mark - 1)
    EQUB HI(freeMark_mark - 1)
    EQUB HI(freeMark_mark - 1)
    EQUB HI(freeMark_mark - 1)

.freeMark_cons
    PUSH exp
    HEAD tmp, exp
    LDY #0
    LDA #1
    ORA (exp), Y
    STA (exp), Y
    MOVE exp, tmp
    JSR freeMark
    PULL tmp
    TAIL exp, tmp
    JMP freeMark

.freeMark_proc
    PUSH exp
    HEAD tmp, exp
    LDY #0
    LDA #1
    ORA (exp), Y
    STA (exp), Y
    MOVE exp, tmp
    JSR freeMark
    PULL tmp
    TAIL exp, tmp
    LDA exp
    AND #&FC
    STA exp
    JMP freeMark

.freeMark_mark
    LDY #0
    LDA #1
    ORA (exp), Y
    STA (exp), Y
    RTS

.freeReport
    ADDR exp, freeReport_label
    JSR printString
    MOVE exp, frl
    JSR freeCount
    JSR printDecimal

    LDA #',' ; print stack
    JSR osasci
    LDA #' '
    JSR osasci
    TXA
    JSR printDecimal

    JSR osnewl
    RTS
.freeReport_label
    EQUS "Free ", 0

.freeCount_res
    EQUB 0
.freeCount ; A = count(exp)
    LDA #0
    STA freeCount_res
.freeCount_loop
    LDA #0
    CMP exp
    BNE freeCount_next
    CMP exp + 1
    BNE freeCount_next
    LDA freeCount_res
    RTS
.freeCount_next
    INC freeCount_res
    TAIL exp, exp
    JMP freeCount_loop