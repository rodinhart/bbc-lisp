\ symb 0  Symbol
\ nil0 1  NIL
\ 1234 2  Int32
\ xxyy 3  Cons
\ LLAA 4  Array

T_Sym = 0
T_Nil = 1
T_Int32 = 2
T_Cons = 3
T_Array = 4

MACRO Array len, addr
  EQUW len, addr
  EQUB T_Array
ENDMACRO

MACRO Int32 n
  EQUD n
  EQUB T_Int32
ENDMACRO

.NIL
  EQUB "nil", 0, T_Nil
