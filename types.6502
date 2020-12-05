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
    AND getType_mask
    CLC
    ADC getType_consbase
    TAY
    RTS ; return 1 = Cons, 2 = Proc, 3 = Macro, 4 = Native
.getType_notcons
    LSR A
    LSR A
    AND getType_mask
    CLC
    ADC getType_primbase
    TAY
    RTS ; return 5 = Symbol, 6 = Number
.getType_testcons
    EQUB 2
.getType_mask
    EQUB 3
.getType_consbase
    EQUB 1
.getType_primbase
    EQUB 5
