.getType ; Y = getType(exp)
    ; nil?
    LDY #0
    CPY exp
    BNE getType_notnil
    CPY exp + 1
    BNE getType_notnil
    RTS ; return 0
.getType_notnil
    LDA (exp), Y
    LSR A
    LSR A
    BCS getType_notcons
    LDY #2
    LDA (exp), Y
    AND #3
    TAY
    INY
    RTS ; return 1 = Cons, 2 = Proc, 3 = Macro, 4 = Native
.getType_notcons
    AND #3
    CLC
    ADC #5
    TAY
    RTS ; return 5 = Symbol, 6 = Number

.createNumber ; ret = createNumber(tmp = 65535)
    JSR freeAlloc
    LDA #6
    LDY #0
    STA (ret), Y

    LDA tmp ; store low byte
    INY
    STA (ret), Y

    LDA tmp + 1 ; store high byte
    INY
    STA (ret), Y

    RTS

.createSymbol ; ret = createSymbol(exp = "abcd")
    JSR freeAlloc
    LDA #2
    LDY #0
    STA (ret), Y

    LDA (exp), Y ; first char
    ASL A
    INY
    STA (ret), Y

    LDA (exp), Y ; second char
    ASL A
    INY
    STA (ret), Y

    LDA (exp), Y ; third char
    ASL A
    INY
    STA (ret), Y

    LDA (exp), Y ; fourth char
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
