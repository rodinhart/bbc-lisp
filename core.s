.coreInit_return
    EQUW 0
    EQUW 0
.coreInit
    ADDR env, coreInit_return
    ADDR exp, coreKvs

    JSR coreInit_symbol
    JSR coreInit_append
    LDA #0
    LDY #0
    STA (env), Y
    INY
    STA (env), Y

.coreInit_loop
    LDA #8
    CLC
    ADC exp
    STA exp
    LDA #0
    ADC exp + 1
    STA exp + 1

    LDY #0
    LDA (exp), Y
    BEQ coreInit_done

    JSR coreInit_symbol
    JSR coreInit_copy

    JMP coreInit_loop
.coreInit_done
    LDA #0 ; terminate list
    LDY #2
    STA (env), Y
    INY
    STA (env), Y

    LDA coreInit_return + 2
    STA ret
    LDA coreInit_return + 3
    STA ret + 1
    RTS

.coreInit_append
    JSR freeAlloc
    TAILSET env, ret
    MOVE env, ret
    RTS

.coreInit_symbol
    JSR coreInit_append
    JSR createSymbol
    HEADSET env, ret
    RTS

.coreInit_copy
    JSR coreInit_append
    JSR freeAlloc
    HEADSET env, ret

    LDY #4
    LDA (exp), Y
    LDY #0
    STA (ret), Y

    LDY #5
    LDA (exp), Y
    LDY #1
    STA (ret), Y

    LDY #6
    LDA (exp), Y
    LDY #2
    STA (ret), Y

    LDY #7
    LDA (exp), Y
    LDY #3
    STA (ret), Y

    RTS

.coreKvs
    EQUB "nil", 0
    EQUW 0
    EQUW 0

    EQUB "fn", 0, 0
    EQUW primitiveFn
    EQUW 2

    EQUB "def", 0
    EQUW primitiveDef
    EQUW 2

    EQUB "if", 0, 0
    EQUW primitiveIf
    EQUW 2

    EQUB "quot"
    EQUW primitiveQuote
    EQUW 2

    EQUB "+", 0, 0, 0
    EQUW native_plus
    EQUW 3

    EQUB "-", 0, 0, 0
    EQUW nativeSub
    EQUW 3

    EQUB "=", 0, 0, 0
    EQUW nativeEq
    EQUW 3

    EQUB "car", 0
    EQUW native_car
    EQUW 3

    EQUB "cdr", 0
    EQUW native_cdr
    EQUW 3

    EQUB "cons"
    EQUW native_cons
    EQUW 3

    EQUB "prn", 0
    EQUW native_prn
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

    MOVE ret, exp
    RTS

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
    LDY #1 ; tmp += ret
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
    JMP createNumber

ALIGN 4
.nativeSub
    HEAD ret, exp
    LDY #1 ; tmp = ret
    LDA (ret), Y
    STA tmp
    INY
    LDA (ret), Y
    STA tmp + 1
.nativeSub_loop
    TAIL exp, exp
    LDA #0
    CMP exp
    BNE nativeSub_cont
    CMP exp + 1
    BEQ nativeSub_done
.nativeSub_cont
    HEAD ret, exp
    LDA tmp ; tmp = tmp - ret
    LDY #1
    SEC
    SBC (ret), Y
    STA tmp
    LDA tmp + 1
    INY
    SBC (ret), Y
    STA tmp + 1

    JMP nativeSub_loop
.nativeSub_done
    JMP createNumber

ALIGN 4
.nativeEq
    HEAD tmp, exp
    TAIL exp, exp
    HEAD ret, exp
    LDY #1
    LDA (tmp), Y
    CMP (ret), Y
    BNE nativeEq_noteq
    INY
    LDA (tmp), Y
    CMP (ret), Y
    BNE nativeEq_noteq

    RTS
.nativeEq_noteq
    LDA #0
    STA ret
    STA ret + 1
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

ALIGN 4
.native_cons ; (fn (x y) (cons x y))
    JSR freeAlloc
    HEAD tmp, exp
    HEADSET ret, tmp
    TAIL tmp, exp
    HEAD exp, tmp
    TAILSET ret, exp
    RTS

ALIGN 4
.native_prn ; (fn (v) (prn v))
    HEAD exp, exp
    JSR print
    JSR osnewl
    LDA #0
    STA ret
    STA ret + 1
    RTS