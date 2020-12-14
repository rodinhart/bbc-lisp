.getType ; exp => Y
    ; nil?
    LDY #0
    CPY exp
    BNE getType_notnil
    CPY exp + 1
    BNE getType_notnil
    RTS ; return 0
.getType_notnil
    LDA (exp), Y
    BIT getType_testcons
    BNE getType_notcons
    LDY #2
    LDA (exp), Y
    AND #3
    TAY
    INY
    RTS ; return 1 = Cons, 2 = Proc, 3 = Macro, 4 = Native
.getType_notcons ; A is 2 or 6
    LSR A
    LSR A
    AND #3
    TAY
    INY
    INY
    INY
    INY
    INY
    RTS ; return 5 = Symbol, 6 = Number
.getType_testcons ; put in zero page
    EQUB 2

.createSymbol ; ret = createSymbol(exp = "abcd")
    JSR freeAlloc
    LDA #2
    LDY #0
    STA (ret), Y

    LDA (exp), Y
    ASL A
    INY
    STA (ret), Y

    LDA (exp), Y
    ASL A
    INY
    STA (ret), Y

    LDA (exp), Y
    ASL A
    INY
    STA (ret), Y

    LDA (exp), Y
    ASL A
    STA tmp

    ASL tmp
    LDA #0
    LDY #3
    ADC (ret), Y
    STA (ret), Y

    ASL tmp
    LDA #0
    DEY
    ADC (ret), Y
    STA (ret), Y

    ASL tmp
    LDA #0
    DEY
    ADC (ret), Y
    STA (ret), Y

    LDA tmp
    DEY
    ORA (ret), Y
    STA (ret), Y

    RTS
