MACRO ADDR reg, address
  LDA #LO(address)
  STA reg
  LDA #HI(address)
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
  LDA reg
  STA stack_low, X
  LDA reg + 1
  STA stack_high, X
ENDMACRO
