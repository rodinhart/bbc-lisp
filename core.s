.coreInit
    LDA #0
    STA tmp
    STA tmp + 1

    JSR coreInit_prepend
    LDA #0
    LDY #0
    STA (tmp), Y
    INY
    STA (tmp), Y

    LDX #0
    JSR coreInit_copy
.coreInit_loop
    JSR coreInit_copy
    JSR coreInit_copy

    LDA coreKvs, X
    BEQ coreInit_end ; this check is not legit against lo byte of native routine
    JMP coreInit_loop
.coreInit_end
    MOVE ret, tmp
    RTS

.coreInit_prepend
    JSR freeAlloc
    TAILSET ret, tmp
    MOVE tmp, ret
    RTS

.coreInit_copy
    JSR coreInit_prepend
    JSR freeAlloc
    HEADSET tmp, ret
    LDA coreKvs, X
    INX
    LDY #0
    STA (ret), Y
    LDA coreKvs, X
    INX
    INY
    STA (ret), Y
    LDA coreKvs, X
    INX
    INY
    STA (ret), Y
    LDA coreKvs, X
    INX
    INY
    STA (ret), Y
    RTS

.coreKvs
    EQUB 2, "nil"

    EQUW primitiveFn
    EQUW 2
    EQUB 2, "fn", 0

    EQUW primitiveDef
    EQUW 2
    EQUB 2, "def"

    EQUW primitiveIf
    EQUW 2
    EQUB 2, "if", 0

    EQUW primitiveQuote
    EQUW 2
    EQUB 2, "quo"

    EQUW native_plus
    EQUW 3
    EQUB 2, "+", 0, 0

    EQUB 0

ALIGN 4
.primitiveFn ; (macro (names body) (fn names body))
    JSR freeAlloc
    HEADSET ret, exp
    TAILSET ret, env
    LDA #1
    LDY #2
    ORA (ret), Y
    STA (ret), Y
    RTS

ALIGN 4
.primitiveDef ; (macro (name value) (def name value))
    PUSH exp
    PUSH env
    TAIL exp, exp
    HEAD exp, exp
    JSR eval
    PULL env
    PULL exp
.primitiveDef_seek
    TAIL env, env
    LDY #2
    LDA #0
    CMP (env), Y
    BNE primitiveDef_seek
    INY
    CMP (env), Y
    BNE primitiveDef_seek

    MOVE tmp, ret
    JSR freeAlloc
    HEAD exp, exp
    HEADSET ret, exp
    TAILSET env, ret
    MOVE env, ret

    JSR freeAlloc
    HEADSET ret, tmp
    TAILSET env, ret
    LDA #0
    LDY #2
    STA (ret), Y
    INY
    STA (ret), Y
    TAIL ret, ret
    RTS ; return name

ALIGN 4
.primitiveIf ; (macro (pred cons alt) (if pred cons alt))
    PUSH exp
    PUSH env
    HEAD exp, exp ; get pred
    JSR eval
    PULL env
    PULL exp
    TAIL exp, exp ; get (cons alt)
    LDA #0
    CMP ret
    BEQ primitiveIf_maybealt
.primitiveIf_eval
    HEAD exp, exp
    JMP eval
.primitiveIf_maybealt
    CMP ret + 1
    BNE primitiveIf_eval
    TAIL exp, exp
    JMP primitiveIf_eval

ALIGN 4
.primitiveQuote ; (macro (value) (quote value))
    HEAD ret, exp
    RTS

ALIGN 4
.native_plus ; (fn args (reduce + 0 args))
    LDA #0
    PHA
.native_plus_loop
    LDA #0
    CMP exp
    BNE native_plus_add
    CMP exp + 1 
    BEQ native_plus_done
.native_plus_add
    HEAD tmp, exp
    PLA
    LDY #1 
    CLC
    ADC (tmp), Y
    PHA
    TAIL exp, exp
    JMP native_plus_loop
.native_plus_done
    JSR freeAlloc
    LDA #6
    LDY #0
    STA (ret), Y
    PLA
    LDY #1
    STA (ret), Y
    RTS
