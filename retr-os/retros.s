\ http://localhost:8081/?disc1=retros.ssd&autoboot

osfile = &FFDD
osasci = &FFE3
osnewl = &FFE7
osword = &FFF1
osbyte = &FFF4

ORG &1908

.start
.api_poll
  JMP poll
.api_pushpc
  PLA
  TAX
  PLA
  TAY

  TXA
  CLC
  ADC #3
  TAX
  TYA
  ADC #0
  TAY
  
  TYA
  PHA
  TXA
  PHA

  TXA
  SEC
  SBC #3
  TAX
  TYA
  SBC #0
  TAY
  
  TYA
  PHA
  TXA
  PHA
  RTS

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
  LDA #&FF ; Load the named file + cat info
  LDX #<file
  LDY #>file
  JSR osfile

  LDY threads
  INY
  STY threads
  TYA
  JSR free
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

.file
  EQUW file_name
  EQUW free, 0
  EQUD 0
  EQUD 0
  EQUD 0
.file_name
  EQUB "!STOPW", 13

.end
.thread_lo
  EQUB 0, 0, 0, 0, 0
.thread_hi
  EQUB 0, 0, 0, 0, 0
.workspace_lo
  EQUB 0, 0, 0, 0, 0
.workspace_hi
  EQUB 0, 0, 0, 0, 0
.free

SAVE "RETROS", start, end, exec

ORG &0
.start_stopwatch
INCLUDE "retr-os/stopwatch.s"
.end_stopwatch
SAVE "!STOPW", start_stopwatch, end_stopwatch
