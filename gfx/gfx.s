\ http://localhost:8081/?disc1=gfx.ssd&autoboot

osasci = &FFE3
osnewl = &FFE7
osbyte = &FFF4

rotx = &70
roty = &71
tmpx = &73
tmpy = &74
tmpz = &75

ORG &1908

.start

.vertices_x
  EQUB -50,  50,  50, -50, -50,  50,  50, -50
.vertices_y
  EQUB -50, -50, -50, -50,  50,  50,  50,  50
.vertices_z
  EQUB -50, -50,  50,  50, -50, -50,  50,  50
N = vertices_y - vertices_x

.surfaces_0
  EQUB 0, 1, 5, 4
.surfaces_1
  EQUB 1, 5, 4, 0
.surfaces_2
  EQUB 2, 6, 7, 3
.surfaces_3
  EQUB 3, 2, 6, 7
S = surfaces_1 - surfaces_0

.run
  LDA #22 ; mode 4
  JSR osasci
  LDA #4
  JSR osasci

  ;; VDU 23,1,0;0;0;0;
  LDA #23
  JSR osasci
  LDA #1
  JSR osasci
  LDA #0
  JSR osasci
  LDA #0
  JSR osasci
  LDA #0
  JSR osasci
  LDA #0
  JSR osasci
  LDA #0
  JSR osasci
  LDA #0
  JSR osasci
  LDA #0
  JSR osasci
  LDA #0
  JSR osasci
  LDA #0
  JSR osasci

  LDA #0
  STA rotx

.frame_loop
  LDX #N - 1
.project_loop
  ;; rot x
  LDA vertices_z, X
  STA &8E
  LDY rotx
  LDA sine, Y
  STA &8F
  JSR mul8
  ASL &8C
  ROL &8D
  LDA &8D
  STA tmpy

  LDA vertices_y, X
  STA &8E
  LDY rotx
  LDA cosine, Y
  STA &8F
  JSR mul8
  ASL &8C
  ROL &8D
  LDA &8D
  SEC
  SBC tmpy
  STA tmpy

  LDA vertices_y, X
  STA &8E
  LDY rotx
  LDA sine, Y
  STA &8F
  JSR mul8
  ASL &8C
  ROL &8D
  LDA &8D
  STA tmpz

  LDA vertices_z, X
  STA &8E
  LDY rotx
  LDA cosine, Y
  STA &8F
  JSR mul8
  ASL &8C
  ROL &8D
  LDA &8D
  CLC
  ADC tmpz
  STA tmpz

  LDA tmpy
  CLC
  ADC #100
  TAY
  LDA div, Y
   
  PHA
  STA &8E
  LDA vertices_x, X
  STA &8F
  JSR umul8

  LDA &8D
  CMP #128
  ROR &8D ;x64
  ROR &8C
  LDA &8D
  CMP #128
  ROR &8D
  ROR &8C

  LDA &8C
  CLC
  ADC #128
  STA coords_x, X

  PLA
  STA &8E
  LDA tmpz
  STA &8F
  JSR umul8

  LDA &8D
  CMP #128
  ROR &8D ; x64
  ROR &8C
  LDA &8D
  CMP #128
  ROR &8D
  ROR &8C
  
  LDA &8C
  CLC
  ADC #128
  STA coords_y, X

  DEX
  BMI project_done
  JMP project_loop

.project_done
  LDX #S - 1
.draw_loop
  TXA
  PHA

  LDY surfaces_0, X
  LDA coords_x, Y
  TAX
  LDA coords_y, Y
  TAY
  LDA #4
  JSR plot

  PLA
  PHA
  TAX
  LDY surfaces_1, X
  LDA coords_x, Y
  TAX
  LDA coords_y, Y
  TAY
  LDA #5
  JSR plot

  PLA
  PHA
  TAX
  LDY surfaces_2, X
  LDA coords_x, Y
  TAX
  LDA coords_y, Y
  TAY
  LDA #5
  JSR plot

  PLA
  PHA
  TAX
  LDY surfaces_3, X
  LDA coords_x, Y
  TAX
  LDA coords_y, Y
  TAY
  LDA #5
  JSR plot

  PLA
  PHA
  TAX
  LDY surfaces_0, X
  LDA coords_x, Y
  TAX
  LDA coords_y, Y
  TAY
  LDA #5
  JSR plot

  PLA
  TAX
  DEX
  BPL draw_loop

  INC rotx

  LDA #19
  JSR osbyte

  LDA #12
  JSR osasci
  JMP frame_loop

  RTS

.div
  EQUB 0
FOR n, 1, 255
  EQUB LO(256 / n)
NEXT

.plot
  PHA
  LDA #25
  JSR osasci
  PLA
  JSR osasci

  LDA #0
  STA &8F
  STA &8E
  TXA
  ASL A
  ROL &8F
  ASL A
  ROL &8F
  JSR osasci
  LDA &8F
  JSR osasci

  TYA
  ASL A
  ROL &8E
  ASL A
  ROL &8E
  JSR osasci
  LDA &8E
  JMP osasci

.sine
FOR a, 0, 255
  EQUB 127 * SIN(2 * PI * a / 256)
NEXT

.cosine
FOR a, 0, 255
  EQUB 127 * COS(2 * PI * a / 256)
NEXT

.mul8
  LDA &8E
  BPL umul8
  LDA #0
  SEC
  SBC &8E
  STA &8E
  LDA #0
  SEC
  SBC &8F
  STA &8F
.umul8 \ &8C-&8D = &8E * &8F
  LDA #0
  STA &8D
  LDY #8
.umul8_loop
  LSR &8E
  BCC umul8_shift

  LDA &8F
  CLC
  ADC &8D
  STA &8D
.umul8_shift
  LDA &8D
  CMP #128
  ROR &8D
  ROR &8C

  DEY
  BNE umul8_loop
  RTS

.printDecimal
  PHA
  LSR A
  LSR A
  LSR A
  LSR A
  STY &8F
  TAY
  LDA printDecimal_lookup, Y
  JSR osasci
  PLA
  PHA
  AND #&F
  TAY
  LDA printDecimal_lookup, Y
  LDY &8F
  JSR osasci
  LDA #' '
  JSR osasci
  PLA
  RTS
.printDecimal_lookup
  EQUS "0123456789ABCDEF"

.end
.coords
  EQUB 0
.coords_x
  SKIP N
.coords_y
  SKIP N


SAVE "Gfx", start, end, run
