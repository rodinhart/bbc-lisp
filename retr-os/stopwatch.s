clock_buffer = &74

.clock
  PHA ; push process id
  LDA #1 ; Read system clock
  LDX #<clock_buffer
  LDY #>clock_buffer
  JSR osword
  LDA clock_buffer
  STA &80
  LDA clock_buffer + 1
  STA &81

  PLA ; pop process id
  JSR poll
.clock_loop
  PHA
  LDA #1 ; Read system clock
  LDX #<clock_buffer
  LDY #>clock_buffer
  JSR osword

  LDA #31
  JSR osasci
  LDA #0
  JSR osasci
  PLA
  PHA
  ASL A
  ASL A
  ; CLC
  ; ADC clock_id
  JSR osasci

  LDA clock_buffer
  SEC
  SBC &80
  STA &72
  LDA clock_buffer + 1
  SBC &81
  STA &73

  JSR api_pushpc
  CLV
  BVC div100

  LDA &70
  LSR A
  LSR A
  LSR A
  LSR A
  TAY
  LDA hex_table, Y
  JSR osasci

  LDA &70
  AND #&F
  TAY
  LDA hex_table, Y
  JSR osasci

  PLA
  JSR poll
  CLV
  BVC clock_loop

.hex_table
  EQUS "0123456789ABCDEF"
.clock_id
  EQUB 0

.div100 ; &70-&71 <- &72-73 / 10
  LDA #0
  STA &70
  STA &71
.div100_loop
  LDA &72
  SEC
  SBC #100
  STA &72
  LDA &73
  SBC #0
  STA &73
  BCC div100_done

  LDA &70
  ADC #0
  STA &70
  LDA &71
  ADC #0
  STA &71
  JMP div100_loop
.div100_done
  RTS
