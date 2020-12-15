.readList_proxy
    JMP readList
.read ; ret = read(exp)
    LDY #0
    STY read_cursor
.readToken
    JSR readWS
    LDY read_cursor
    LDA (exp), Y
    CMP #'('
    BEQ readList_proxy
    CMP #'0'
    BCC readSymbol
    CMP #':'
    BCS readSymbol

    LDA #0 ; clear buffer
    STA tmp
    STA tmp + 1
.readNumber_loop
    ; x10
    LDA tmp ; x2
    ASL A
    STA ret
    LDA tmp + 1
    ROL A
    STA ret + 1
    ASL ret ; x4
    ROL ret + 1
    LDA ret ; x4 + 1
    CLC
    ADC tmp
    STA tmp
    LDA ret + 1
    ADC tmp + 1
    STA tmp + 1
    ASL tmp ; (x4 + 1)x2
    ROL tmp + 1

    LDY read_cursor ; add digit to tmp
    LDA (exp), Y
    SEC
    SBC #'0'
    CLC
    ADC tmp
    STA tmp
    LDA #0
    ADC tmp + 1
    STA tmp + 1

    INC read_cursor
    LDY read_cursor
    LDA (exp), Y
    CMP #'0'
    BCC readNumber_end
    CMP #':'
    BCC readNumber_loop
.readNumber_end
    JSR createNumber
    LDY read_cursor
    RTS

.readSymbol
    ADDR tmp, readSymbol_buffer
    LDY #0
    STY readSymbol_buffer + 4
.readSymbol_loop
    LDY read_cursor
    LDA (exp), Y
    CMP #33
    BCC readSymbol_end
    CMP #')'
    BEQ readSymbol_end
    INC read_cursor
    
    LDY readSymbol_buffer + 4
    CPY #4
    BEQ readSymbol_loop
    STA (tmp), Y
    INY
    STY readSymbol_buffer + 4
    BNE readSymbol_loop
.readSymbol_end
    LDY readSymbol_buffer + 4
    CPY #4
    BEQ readSymbol_create
    LDA #0
    STA (tmp), Y
    INC readSymbol_buffer + 4
    JMP readSymbol_end
.readSymbol_create
    PUSH exp
    MOVE exp, tmp
    JSR createSymbol
    PULL exp
    LDY read_cursor
    RTS
.readSymbol_buffer
    EQUB "    ", 0

.readWS
    LDY read_cursor
    LDA (exp), Y
    BEQ readWS_end
    CMP #33
    BCS readWS_end
    INC read_cursor
    BCC readWS
.readWS_end
    CMP #0
    BEQ readWS_endoffile
    RTS
.readWS_endoffile
    BRK
    EQUB 0, "Unexpected end of file", 0

.readList
    INC read_cursor ; skip '('
    JSR freeAlloc
    PUSH ret
.readList_loop
    JSR readWS
    LDY read_cursor
    LDA (exp), Y
    CMP #')'
    BEQ readList_end

    PUSH ret
    JSR readToken
    MOVE tmp, ret
    JSR freeAlloc
    HEADSET ret, tmp
    MOVE tmp, ret
    PULL ret
    TAILSET ret, tmp
    MOVE ret, tmp
    JMP readList_loop
.readList_end
    INC read_cursor ; skip ')'
    PULL tmp
    TAIL ret, tmp
    LDY read_cursor
    RTS
