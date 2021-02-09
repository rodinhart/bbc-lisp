\ http://localhost:8081/?disc1=retros.ssd&autoboot

osasci = &FFE3
osnewl = &FFE7
osword = &FFF1
osbyte = &FFF4

ORG &1908

.start
.api_poll
  JMP poll

.threads
  EQUB 0
.thread_idle
  EQUB 0

.poll
  STA thread_idle
  TAY
  PLA ; store thread state
  STA thread_lo, Y
  PLA
  STA thread_hi, Y

  LDA &80 ; store thread workspace
  STA workspace_lo, Y
  LDA &81
  STA workspace_hi, Y

.event_loop
  LDA #145 ; Get character from buffer
  LDX #0 ; keyboard buffer number
  JSR osbyte
  BCS idle
  CPY #'1'
  BEQ fork

.idle
  LDA threads
  BEQ event_loop

  LDY thread_idle
  INY
  CPY threads
  BCC idle_nowrap
  BEQ idle_nowrap
  LDY #1
.idle_nowrap
  LDA workspace_lo, Y ; restore workspace
  STA &80
  LDA workspace_hi, Y
  STA &81

  LDA thread_hi, Y ; restore state
  PHA
  LDA thread_lo, Y
  PHA
  TYA
  RTS ; return to thread

.fork
  LDY threads
  INY
  STY threads
  TYA
  JSR clock
  JMP event_loop

.s_header
  EQUB 12, 23, 1, 0, 0, 0, 0, 0, 0, 0, 0
  EQUB "RETR-OS", 13, 13, "1 Stopwatch", 13, 255
.exec
  LDY #0
  LDA s_header, Y
.header_loop
  JSR osasci
  INY
  LDA s_header, Y
  CMP #255
  BNE header_loop
  BEQ event_loop

.clock_buffer
  EQUB 0, 0, 0, 0, 0
.hex_table
  EQUS "0123456789ABCDEF"
.clock_id
  EQUB 0
.clock
  STA clock_id ; not relocatable
  LDA #1 ; Read system clock
  LDX #<clock_buffer
  LDY #>clock_buffer
  JSR osword
  LDA clock_buffer
  STA &80
  LDA clock_buffer + 1
  STA &81

  LDA clock_id
  JSR poll
.clock_loop
  STA clock_id ; not relocatable
  LDA #1 ; Read system clock
  LDX #<clock_buffer
  LDY #>clock_buffer
  JSR osword

  LDA #31
  JSR osasci
  LDA #0
  JSR osasci
  LDA clock_id
  ASL A
  ASL A
  CLC
  ADC clock_id
  JSR osasci

  LDA clock_buffer
  SEC
  SBC &80
  STA &72
  LDA clock_buffer + 1
  SBC &81
  STA &73
  JSR div100

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

  LDA clock_id
  JSR poll
  JMP clock_loop ; not relocatable

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

.end
.thread_lo
  EQUB 0, 0, 0, 0, 0
.thread_hi
  EQUB 0, 0, 0, 0, 0
.workspace_lo
  EQUB 0, 0, 0, 0, 0
.workspace_hi
  EQUB 0, 0, 0, 0, 0

SAVE "RETROS", start, end, exec
