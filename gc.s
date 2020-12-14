.free_heap
    EQUW heap_start

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
    LDA #0
    STA frl
    STA frl + 1
    MOVE tmp, free_heap
.freeCollect_loop
    LDY #0
    LDA (tmp), Y
    BIT freeMark_mask
    BNE freeCollect_skip

    TAILSET tmp, frl
    MOVE frl, tmp
.freeCollect_next
    LDA #32 ; advance tmp to the next cell
    CLC
    ADC tmp
    STA tmp
    LDA #0
    ADC tmp + 1
    STA tmp + 1

    LDA tmp ; compare with end of heap
    SEC
    SBC #LO(heap_end)
    LDA tmp + 1
    SBC #HI(heap_end)
    BCC freeCollect_loop

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
    MOVE exp, free_heap ; change to tmp?
.freeInit_loop
    LDA #0 ; clear marked
    STA (exp), Y

    LDA #32 ; advance exp to next cell
    CLC
    ADC exp
    STA exp
    LDA #0
    ADC exp + 1
    STA exp + 1

    LDA exp
    SEC
    SBC #LO(heap_end)
    LDA exp + 1
    SBC #HI(heap_end)
    BCC freeInit_loop

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
     MOVE exp, ret
     JSR printDecimal

    LDA #',' ; print stack
    JSR osasci
    LDA #' '
    JSR osasci
    TXA
    JSR printByte

    JSR osnewl
    RTS
.freeReport_label
    EQUS "Free ", 0

.freeCount ; ret = count(exp)
    LDA #0
    STA ret
    STA ret + 1
.freeCount_loop
    LDA #0
    CMP exp
    BNE freeCount_next
    CMP exp + 1
    BNE freeCount_next

    RTS
.freeCount_next
    LDA #1
    CLC
    ADC ret
    STA ret
    LDA #0
    ADC ret + 1
    STA ret + 1

    TAIL exp, exp
    JMP freeCount_loop
