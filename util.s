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

.printDecimal_buffer
    EQUS "   "
.printDecimal ; print A
    LDY #0
    STY printDecimal_buffer
    STY printDecimal_buffer + 1
    STY printDecimal_buffer + 2
.printDecimal_loop
    CMP #10
    BCC printDecimal_next
    SBC #10
    INY
    JMP printDecimal_loop
.printDecimal_next
    PHA
    LDA printDecimal_buffer + 1
    STA printDecimal_buffer + 2
    LDA printDecimal_buffer
    STA printDecimal_buffer + 1
    PLA
    CLC
    ADC print_0
    STA printDecimal_buffer
    TYA
    LDY #0

    CMP #0
    BNE printDecimal_loop
.printDecimal_print
    LDA printDecimal_buffer
    JSR osasci
    LDA printDecimal_buffer + 1
    JSR osasci
    LDA printDecimal_buffer + 2
    JSR osasci
    RTS

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