.eval_gc
  PUSH exp
  PUSH env
  JSR freeGC
  PULL env
  PULL exp
  JMP eval_gcdone
.eval
  LDA frc + 1
  BEQ eval_gc
.eval_gcdone    
  JSR getType
  LDA eval_jumphigh, Y
  PHA
  LDA eval_jumplow, Y
  PHA
  RTS
.eval_jumplow
  EQUB LO(evalNil - 1)
  EQUB LO(evalCons - 1)
  EQUB LO(evalNil - 1)
  EQUB LO(evalNil - 1)
  EQUB LO(evalNil - 1)
  EQUB LO(evalSymbol - 1)
  EQUB LO(evalNumber - 1)
.eval_jumphigh
  EQUB HI(evalNil - 1)
  EQUB HI(evalCons - 1)
  EQUB HI(evalNil - 1)
  EQUB HI(evalNil - 1)
  EQUB HI(evalNil - 1)
  EQUB HI(evalSymbol - 1)
  EQUB HI(evalNumber - 1)

.evalNil
.evalNumber
  MOVE ret, exp
  RTS

.evalSymbol
  HEAD tmp, env

  LDY #0
  LDA (tmp), Y
  CMP (exp), Y
  BNE evalSymbol_next

  INY
  LDA (tmp), Y
  CMP (exp), Y
  BNE evalSymbol_next

  INY
  LDA (tmp), y
  CMP (exp), y
  BNE evalSymbol_next

  INY
  LDA (tmp), y
  CMP (exp), y
  BNE evalSymbol_next

  TAIL tmp, env
  HEAD ret, tmp
  RTS

.evalSymbol_next
  TAIL tmp, env
  TAIL env, tmp

  LDA env
  ORA env + 1
  BNE evalSymbol

  JSR osnewl
  JSR print
  BRK
  EQUB 0, "Unknown symbol", 0

  LDA #0 ; return nil
  STA ret
  STA ret + 1
  RTS

.evalCons
  PUSH exp
  PUSH env
  HEAD exp, exp
  JSR eval
  MOVE exp, ret
  JSR getType
  TYA
  PHA
  PULL env
  PULL exp
  TAIL exp, exp
  PLA
  CMP #3 ; macro
  BNE evalCons_apply
  HEAD tmp, ret
  JMP (tmp)
  
.evalCons_apply
  PHA
  PUSH ret
  JSR evalMap ; (+ 2 3 5)
  MOVE exp, ret
  PULL ret
  PLA
  CMP #4
  BNE evalCons_proc
  HEAD tmp, ret ; native
  JMP (tmp) ; (+ 2 3)

;; ((fn (x y) ...) a b)
;; exp = (3 4) env = (k1 v1 k2 v2) ret = (((x y) ...) . storedEnv)
.evalCons_proc
  TAIL env, ret
  LDA env
  AND #&FC
  STA env
  
  HEAD ret, ret
  PUSH ret
  HEAD tmp, ret
.evalCons_loop
  LDA #0
  CMP tmp
  BNE evalCons_bind
  CMP tmp + 1
  BEQ evalProc_done
.evalCons_bind
  JSR freeAlloc ; (_ . env)
  TAILSET ret, env
  MOVE env, ret

  HEAD ret, exp ; (3 . env)
  HEADSET env, ret
  TAIL exp, exp

  JSR freeAlloc ; (_ 3 . env)
  TAILSET ret, env
  MOVE env, ret

  HEAD ret, tmp ; (x 3 . env)
  HEADSET env, ret
  TAIL tmp, tmp

  JMP evalCons_loop
.evalProc_done
  PULL exp
  TAIL exp, exp
  HEAD exp, exp
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
  HEAD exp, exp
  JSR eval
  PULL env
  PULL exp
  PUSH ret
  TAIL exp, exp
  JSR evalMap
  PUSH ret
  JSR freeAlloc
  PULL tmp
  TAILSET ret, tmp
  PULL tmp
  HEADSET ret, tmp
  RTS
