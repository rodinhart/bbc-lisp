.print
    JSR getType
    LDA print_jumphigh, Y
    PHA
    LDA print_jumplow, Y
    PHA
    RTS
.print_jumplow
    EQUB LO(printNil - 1)
    EQUB LO(printCons - 1)
    EQUB LO(printProc - 1)
    EQUB LO(printMacro - 1)
    EQUB LO(printNative - 1)
    EQUB LO(printSymbol - 1)
    EQUB LO(printNumber - 1)
.print_jumphigh
    EQUB HI(printNil - 1)
    EQUB HI(printCons - 1)
    EQUB HI(printProc - 1)
    EQUB HI(printMacro - 1)
    EQUB HI(printNative - 1)
    EQUB HI(printSymbol - 1)
    EQUB HI(printNumber - 1)

.printNil
    ADDR exp, printNil_label
    JMP printString
.printNil_label
    EQUS "nil", 0

.printCons
    LDA #'('
    JSR osasci
    LDA #0
    PHA
.printCons_loop
    PLA
    JSR osasci
    LDA #' '
    PHA

    PUSH exp

    HEAD exp, exp
    JSR print

    PULL tmp
    TAIL exp, tmp

    NILL exp, printCons_loop

    PLA
    LDA #')'
    JSR osasci
    RTS

.printProc
    ADDR exp, printProc_label
    JMP printString
.printProc_label
    EQUS "[PROC]", 0

.printMacro
    ADDR exp, printMacro_label
    JMP printString
.printMacro_label
    EQUS "[MACRO]", 0

.printNative
    ADDR exp, printNative_label
    JMP printString
.printNative_label ; same as [PROC]?
    EQUS "[NAT]", 0

.printSymbol
    LDY #1
    LDA (exp), Y
    LSR A
    JSR osasci
    INY
    LDA (exp), Y
    LSR A
    JSR osasci
    INY
    LDA (exp), Y
    LSR A
    JSR osasci
    RTS

.printNumber
    LDY #1 ; transfer number to tmp
    LDA (exp), Y
    STA ret
    INY
    LDA (exp), Y
    STA ret + 1

    LDA #0
    STA printNumber_trailing

    LDA #LO(10000)
    STA tmp
    LDA #HI(10000)
    STA tmp + 1
    JSR printNumber_digit

    LDA #LO(1000)
    STA tmp
    LDA #HI(1000)
    STA tmp + 1
    JSR printNumber_digit

    LDA #LO(100)
    STA tmp
    LDA #HI(100)
    STA tmp + 1
    JSR printNumber_digit

    LDA #LO(10)
    STA tmp
    LDA #HI(10)
    STA tmp + 1
    JSR printNumber_digit

    LDA ret
    CLC
    ADC #'0'
    JSR osasci
    RTS
.printNumber_trailing
    EQUB 0
.printNumber_digit
    LDY #0
.printNumber_loop
    LDA ret
    SEC
    SBC tmp
    STA ret
    LDA ret + 1
    SBC tmp + 1
    STA ret + 1
    INY
    BCS printNumber_loop
    
    DEY
    LDA ret
    CLC
    ADC tmp
    STA ret
    LDA ret + 1
    ADC tmp + 1
    STA ret + 1

    TYA
    BEQ printNumber_trail

    CLC
    ADC #'0'
    JSR osasci
    LDA #'0'
    STA printNumber_trailing
    RTS
.printNumber_trail
    LDA printNumber_trailing
    JMP osasci
