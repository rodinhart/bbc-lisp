.print_0
    EQUB '0'
    EQUB 15
.printByte
    PHA
    LSR A
    LSR A
    LSR A
    LSR A
    CMP #10
    BCC printByte_dec
    CLC
    ADC #6 ; use lookup?
.printByte_dec
    ADC print_0
    JSR osasci
    PLA
    AND print_0 + 1
    CMP #10
    BCC printByte_second
    CLC
    ADC #6
.printByte_second
    CLC
    ADC print_0
    JSR osasci
    RTS

.printDecimal ; print exp
    LDA #0
    STA printDecimal_trailing

    LDA #LO(10000)
    STA tmp
    LDA #HI(10000)
    STA tmp + 1
    JSR printDecimal_digit

    LDA #LO(1000)
    STA tmp
    LDA #HI(1000)
    STA tmp + 1
    JSR printDecimal_digit

    LDA #LO(100)
    STA tmp
    LDA #HI(100)
    STA tmp + 1
    JSR printDecimal_digit

    LDA #LO(10)
    STA tmp
    LDA #HI(10)
    STA tmp + 1
    JSR printDecimal_digit

    LDA ret
    CLC
    ADC #'0'
    JSR osasci
    RTS
.printDecimal_trailing
    EQUB 0
.printDecimal_digit
    LDY #0
.printDecimal_loop
    LDA ret
    SEC
    SBC tmp
    STA ret
    LDA ret + 1
    SBC tmp + 1
    STA ret + 1
    INY
    BCS printDecimal_loop
    
    DEY
    LDA ret
    CLC
    ADC tmp
    STA ret
    LDA ret + 1
    ADC tmp + 1
    STA ret + 1

    TYA
    BEQ printDecimal_trail

    CLC
    ADC #'0'
    JSR osasci
    LDA #'0'
    STA printDecimal_trailing
    RTS
.printDecimal_trail
    LDA printDecimal_trailing
    JMP osasci


.printString ; exp = "hello world"
    LDY #0
.printString_loop
    LDA (exp), Y
    BEQ printString_end
    JSR osasci
    INY
    JMP printString_loop
.printString_end
    RTS