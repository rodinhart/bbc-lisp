.coreInit_return
    EQUW 0
    EQUW 0
.coreInit
    ADDR tmp, coreInit_return

    JSR coreInit_append
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
    BEQ coreInit_end
    JMP coreInit_loop
.coreInit_end
    LDA #0 ; terminate list
    LDY #2
    STA (tmp), Y
    INY
    STA (tmp), Y

    LDA coreInit_return + 2
    STA ret
    LDA coreInit_return + 3
    STA ret + 1
    RTS

.coreInit_append
    JSR freeAlloc
    TAILSET tmp, ret
    MOVE tmp, ret
    RTS

.coreInit_copy
    JSR coreInit_append
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

    EQUB 2, "fn", 0
    EQUW primitiveFn
    EQUW 2

    EQUB 2, "def"
    EQUW primitiveDef
    EQUW 2

    EQUB 2, "if", 0
    EQUW primitiveIf
    EQUW 2

    EQUB 2, "quo"
    EQUW primitiveQuote
    EQUW 2

    EQUB 2, "+", 0, 0
    EQUW native_plus
    EQUW 3

    EQUB 2, "car"
    EQUW native_car
    EQUW 3

    EQUB 2, "cdr"
    EQUW native_cdr
    EQUW 3

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
    STA tmp
    STA tmp + 1
.native_plus_loop
    LDA #0
    CMP exp
    BNE native_plus_add
    CMP exp + 1 
    BEQ native_plus_done
.native_plus_add
    HEAD ret, exp
    LDY #1
    LDA (ret), Y
    CLC
    ADC tmp
    STA tmp
    INY
    LDA (ret), Y
    ADC tmp + 1
    STA tmp + 1

    TAIL exp, exp
    JMP native_plus_loop
.native_plus_done
    JSR freeAlloc
    LDA #6
    LDY #0
    STA (ret), Y
    LDA tmp
    INY
    STA (ret), Y
    LDA tmp + 1
    INY
    STA (ret), Y
    RTS

ALIGN 4
.native_car ; (fn (pair) (car pair))
    HEAD tmp, exp
    HEAD ret, tmp
    RTS

ALIGN 4
.native_cdr ; (fn (pair) (cdr pair))
    HEAD tmp, exp
    TAIL ret, tmp
    RTS
