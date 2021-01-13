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
    EQUW nativePlus
    EQUW 3

    EQUB "-", 0, 0, 0
    EQUW nativeSub
    EQUW 3

    EQUB "/", 0, 0, 0
    EQUW nativeDiv
    EQUW 3

    EQUB "*", 0, 0, 0
    EQUW nativeMul
    EQUW 3

    EQUB "=", 0, 0, 0
    EQUW nativeEq
    EQUW 3

    EQUB "!=", 0, 0
    EQUW nativeNotEq
    EQUW 3

    EQUB "car", 0
    EQUW nativeCar
    EQUW 3

    EQUB "cdr", 0
    EQUW nativeCdr
    EQUW 3

    EQUB "cons"
    EQUW nativeCons
    EQUW 3

    EQUB "prn", 0
    EQUW nativePrn
    EQUW 3

    EQUB "gcd", 0
    EQUW nativeGcd
    EQUW 3

    EQUB "abs", 0
    EQUW nativeAbs
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
    JSR tail ; get value expr
    JSR head
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
    JSR head ; get name
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
    JSR head ; get pred
    JSR eval
    PULL env
    PULL exp
    JSR tail ; get (cons alt)
    LDA #0
    CMP ret
    BEQ primitiveIf_maybealt
.primitiveIf_eval
    JSR head
    JMP eval
.primitiveIf_maybealt
    CMP ret + 1
    BNE primitiveIf_eval
    JSR tail
    JMP primitiveIf_eval

ALIGN 4
.primitiveQuote ; (macro (value) (quote value))
    JSR head
    MOVE ret, exp
    RTS

ALIGN 4
.nativePlus ; (fn args (reduce + 0 args))
    LDA #0
    STA ret
    STA ret + 1
.nativePlus_loop
    LDA #0
    CMP exp
    BNE nativePlus_add
    CMP exp + 1 
    BEQ nativePlus_done
.nativePlus_add
    JSR headTmp
    LDY #1 ; ret += tmp
    LDA (tmp), Y
    CLC
    ADC ret
    STA ret
    INY
    LDA (tmp), Y
    ADC ret + 1
    STA ret + 1

    JSR tail
    JMP nativePlus_loop
.nativePlus_done
    MOVE tmp, ret
    JMP createNumber

ALIGN 4
.nativeSub
    JSR headTmp
    LDY #1 ; ret = [tmp]
    LDA (tmp), Y
    STA ret
    INY
    LDA (tmp), Y
    STA ret + 1
.nativeSub_loop
    JSR tail
    LDA #0
    CMP exp
    BNE nativeSub_cont
    CMP exp + 1
    BEQ nativeSub_done
.nativeSub_cont
    JSR headTmp
    LDA ret ; ret -= tmp
    LDY #1
    SEC
    SBC (tmp), Y
    STA ret
    LDA ret + 1
    INY
    SBC (tmp), Y
    STA ret + 1

    JMP nativeSub_loop
.nativeSub_done
    MOVE tmp, ret
    JMP createNumber

ALIGN 4
.nativeDiv
    JSR headTmp ; ret = numerator
    LDY #1
    LDA (tmp), Y
    STA ret
    INY
    LDA (tmp), Y
    STA ret + 1
    
    JSR tail ; tmp = denominator
    JSR head
    LDY #1
    LDA (exp), Y
    STA tmp
    INY
    LDA (exp), Y
    STA tmp + 1

    LDY #0
.nativeDiv_loop
    LDA ret
    SEC
    SBC tmp
    STA ret
    LDA ret + 1
    SBC tmp + 1
    STA ret + 1
    INY
    BCS nativeDiv_loop

    DEY
    STY tmp
    LDY #0
    STY tmp + 1
    JMP createNumber

ALIGN 4
.nativeMul
    JSR headTmp
    LDY #1
    LDA (tmp), Y
    STA ret
    INY
    LDA (tmp), Y
    STA ret + 1

    JSR tail
    JSR head
    LDY #1
    LDA (exp), Y
    STA tmp
    INY
    LDA (exp), Y
    STA tmp + 1

    LDA #0
    STA &82
    STA &83
    LDY #16
.nativeMul_loop
    LSR ret + 1
    ROR ret
    BCC nativeMul_shift

    LDA tmp
    CLC
    ADC &82
    STA &82
    LDA tmp + 1
    ADC &83
    STA &83
.nativeMul_shift
    LDA &83
    CMP #128
    ROR &83
    ROR &82
    ROR &81
    ROR &80

    DEY
    BNE nativeMul_loop

    LDA &80
    STA tmp
    LDA &81
    STA tmp + 1
    JMP createNumber

ALIGN 4
.nativeEq
    JSR headTmp
    MOVE ret, tmp
    JSR tail
    JSR headTmp
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
.nativeNotEq
    JSR headTmp
    MOVE ret, tmp
    JSR tail
    JSR headTmp
    LDY #1
    LDA (tmp), Y
    CMP (ret), Y
    BNE nativeNotEq_noteq
    INY
    LDA (tmp), Y
    CMP (ret), Y
    BNE nativeNotEq_noteq

    LDA #0
    STA ret
    STA ret + 1
    RTS
.nativeNotEq_noteq
    RTS

ALIGN 4
.nativeCar ; (fn (pair) (car pair))
    JSR head
    JSR headTmp
    MOVE ret, tmp
    RTS

ALIGN 4
.nativeCdr ; (fn (pair) (cdr pair))
    JSR head
    JSR tail
    MOVE ret, exp
    RTS

ALIGN 4
.nativeCons ; (fn (x y) (cons x y))
    JSR freeAlloc
    MOVE tmp, exp
    JSR head
    HEADSET ret, exp
    MOVE exp, tmp
    JSR tail
    JSR head
    TAILSET ret, exp
    RTS

ALIGN 4
.nativePrn ; (fn (v) (prn v))
    JSR head
    JSR print
    JSR osnewl
    LDA #0
    STA ret
    STA ret + 1
    RTS

ALIGN 4
.nativeGcd ; (fn (a b) (gcd a b))
    JSR headTmp ; ret = a
    LDY #1
    LDA (tmp), Y
    STA ret
    INY
    LDA (tmp), Y
    STA ret + 1

    JSR tail ; tmp = b
    JSR head
    LDY #1
    LDA (exp), Y
    STA tmp
    INY
    LDA (exp), Y
    STA tmp + 1
.nativeGcd_loop
    LDA ret ; ret = ret - tmp
    SEC
    SBC tmp
    STA ret
    BNE nativeGcd_notEq
    LDA ret + 1 ; could be eq
    SBC tmp + 1
    STA ret + 1
    BNE nativeGcd_notEq2
    JMP createNumber ; return tmp as number
.nativeGcd_notEq
    LDA ret + 1
    SBC tmp + 1
    STA ret + 1
.nativeGcd_notEq2
    BCS nativeGcd_loop
    LDA tmp
    PHA
    CLC
    ADC ret
    STA tmp
    LDA tmp + 1
    PHA
    ADC ret + 1
    STA tmp + 1
    PLA
    STA ret + 1
    PLA
    STA ret
    JMP nativeGcd_loop

ALIGN 4
.nativeAbs ; (fn abs (x) (abs x))
    JSR head
    LDY #2
    LDA (exp), Y
    BMI nativeAbs_invert
    MOVE ret, exp
    RTS
.nativeAbs_invert
    LDA #0
    DEY
    SEC
    SBC (exp), Y
    STA tmp
    LDA #0
    INY
    SBC (exp), Y
    STA tmp + 1
    JMP createNumber
