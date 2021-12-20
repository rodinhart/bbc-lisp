MACRO ADDR reg, address
  LDA #LO(address)
  STA reg
  LDA #HI(address)
  STA reg + 1
ENDMACRO

MACRO CAR reg, pair
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

MACRO CDR reg, pair
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

MACRO PULL reg
  LDA stack_low, X
  STA reg
  LDA stack_high, X
  STA reg + 1
  INX
ENDMACRO

MACRO PUSH reg
  DEX
  LDA reg
  STA stack_low, X
  LDA reg + 1
  STA stack_high, X
ENDMACRO
