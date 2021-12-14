.gcAlloc
  LDA heap_ptr + 1
  CMP #HI(heap_end)
  BCC gcAlloc_ok
  LDA heap_ptr
  CMP #LO(heap_end)
  BCC gcAlloc_ok

  LDA #LO(heap_start)
  STA heap_ptr
  LDA #HI(heap_start)
  STA heap_ptr + 1
.gcAlloc_ok
  CLC
  LDA heap_ptr
  STA tmp
   STA &76
  ADC #5
  STA heap_ptr
  LDA heap_ptr + 1
  STA tmp + 1
   STA &77
  ADC #0
  STA heap_ptr + 1
  RTS
