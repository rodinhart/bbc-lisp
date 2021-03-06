MACRO ADDR reg, address
  LDA #LO(address)
  STA reg
  LDA #HI(address)
  STA reg + 1
ENDMACRO

MACRO HEAD reg, pair
IF reg != pair
  LDY #0
  LDA (pair), Y
  STA reg
  INY
  LDA (pair), Y
  STA reg + 1  ; 11 bytes
ELSE
  LDY #0
  LDA (pair), Y
  PHA
  INY
  LDA (pair), Y
  STA reg + 1
  PLA
  STA reg ; 13 bytes
ENDIF
ENDMACRO

MACRO HEADSET pair, reg
  LDA reg
  LDY #0
  STA (pair), Y
  LDA reg + 1
  INY
  STA (pair), Y
ENDMACRO

MACRO MOVE target, source
  LDA source
  STA target
  LDA source + 1
  STA target + 1
ENDMACRO

MACRO NILL reg, altlabel
  LDA reg
  ORA reg + 1
  BNE altlabel
ENDMACRO

MACRO PEEK reg
  LDA stack_low, X
  STA reg
  LDA stack_high, X
  STA reg + 1
ENDMACRO

MACRO PULL reg
  LDA stack_low, X
  STA reg
  LDA stack_high, X
  STA reg + 1
  INX
ENDMACRO

MACRO PUSH reg
  DEX
   ;BNE ok
   ;JMP stackOverflow
   ;.ok
  LDA reg
  STA stack_low, X
  LDA reg + 1
  STA stack_high, X
ENDMACRO

MACRO TAIL reg, pair
IF reg != pair
  LDY #2
  LDA (pair), Y
  STA reg
  INY
  LDA (pair), Y
  STA reg + 1 ; 11 bytes
ELSE
  LDY #2
  LDA (pair), Y
  PHA
  INY
  LDA (pair), Y
  STA reg + 1
  PLA
  STA reg ; 13 bytes
ENDIF
ENDMACRO

MACRO TAILSET pair, reg
  LDA reg
  LDY #2
  STA (pair), Y
  LDA reg + 1
  INY
  STA (pair), Y
ENDMACRO
