.eval_gc
    PUSH env
    JSR freeGC
    PULL env
    PULL exp
    JMP eval_gcdone
.eval
    PUSH exp
    JSR freeEnsure
    BCS eval_gc
    PULL exp
.eval_gcdone    
    JSR getType
    LDA eval_jumphigh, Y
    PHA
    LDA eval_jumplow, Y
    PHA
    RTS
.eval_jumplow
    EQUB LO(eval_nil - 1)
    EQUB LO(eval_cons - 1)
    EQUB LO(eval_nil - 1)
    EQUB LO(eval_nil - 1)
    EQUB LO(eval_nil - 1)
    EQUB LO(eval_symbol - 1)
    EQUB LO(eval_number - 1)
.eval_jumphigh
    EQUB HI(eval_nil - 1)
    EQUB HI(eval_cons - 1)
    EQUB HI(eval_nil - 1)
    EQUB HI(eval_nil - 1)
    EQUB HI(eval_nil - 1)
    EQUB HI(eval_symbol - 1)
    EQUB HI(eval_number - 1)

.eval_nil
.eval_number
    MOVE ret, exp
    RTS

.eval_symbol
    HEAD tmp, env

    LDY #0
    LDA (tmp), Y
    CMP (exp), Y
    BNE eval_symbol_next

    INY
    LDA (tmp), Y
    CMP (exp), Y
    BNE eval_symbol_next

    INY
    LDA (tmp), y
    CMP (exp), y
    BNE eval_symbol_next

    INY
    LDA (tmp), y
    CMP (exp), y
    BNE eval_symbol_next

    TAIL tmp, env
    HEAD ret, tmp
    RTS

.eval_symbol_next
    TAIL tmp, env
    TAIL env, tmp

    LDA #0
    CMP env
    BNE eval_symbol
    CMP env + 1
    BNE eval_symbol

    JSR osnewl
    JSR print
    BRK
    EQUB 0, "Unknown symbol", 0

    LDA #0 ; return nil
    STA ret
    STA ret + 1
    RTS

.eval_cons
    PUSH exp
    PUSH env
    JSR head
    JSR eval
    MOVE exp, ret
    JSR getType
    TYA
    PHA
    PULL env
    PULL exp
    JSR tail
    PLA
    CMP #3 ; macro
    BNE eval_cons_apply
    HEAD tmp, ret
    JMP (tmp)
    
.eval_cons_apply
    PHA
    PUSH ret
    JSR evalMap ; (+ 2 3 5)
    MOVE exp, ret
    PULL ret
    PLA
    CMP #4
    BNE eval_cons_proc
    HEAD tmp, ret
    JMP (tmp) ; (+ 2 3)

;; ((fn (x y) ...) a b)
;; exp = (3 4) env = (k1 v1 k2 v2) ret = (((x y) ...) . storedEnv)
.eval_cons_proc
    TAIL env, ret
    LDA env
    AND #&FC
    STA env
    
    HEAD ret, ret
    PUSH ret
    HEAD tmp, ret
.eval_cons_loop
    LDA #0
    CMP tmp
    BNE eval_cons_bind
    CMP tmp + 1
    BEQ evalProc_done
.eval_cons_bind
    JSR freeAlloc ; (_ . env)
    TAILSET ret, env
    MOVE env, ret

    HEAD ret, exp ; (3 . env)
    HEADSET env, ret
    JSR tail

    JSR freeAlloc ; (_ 3 . env)
    TAILSET ret, env
    MOVE env, ret

    HEAD ret, tmp ; (x 3 . env)
    HEADSET env, ret
    TAIL tmp, tmp

    JMP eval_cons_loop
.evalProc_done
    PULL exp
    JSR tail
    JSR head
    JMP eval

.evalMap ; (fn (exp) (if (nil? exp) nil (cons (eval (car exp)) (evalMap (cdr exp)))))
    LDA #0
    CMP exp
    BNE evalMap_map
    CMP exp + 1
    BNE evalMap_map
    STA ret
    STA ret + 1
    RTS
.evalMap_map
    PUSH exp
    PUSH env
    JSR head
    JSR eval
    PULL env
    PULL exp
    PUSH ret
    JSR tail
    JSR evalMap
    PUSH ret
    JSR freeAlloc
    PULL tmp
    TAILSET ret, tmp
    PULL tmp
    HEADSET ret, tmp
    RTS
