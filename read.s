.readList_proxy
    JMP readList
.read_cursor
    EQUB 0
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
    BCC readToken_notnumber
    CMP #':'
    BCS readToken_notnumber

    LDA #0 ; clear buffer
    STA readNumber_buffer
    STA readNumber_buffer + 1
    STA readNumber_buffer + 2
.readNumber_loop
    LDA readNumber_buffer
    ASL A
    ASL A
    ASL A
    ASL A
    STA readNumber_buffer
    LDY read_cursor
    LDA (exp), Y
    SEC
    SBC print_0
    ORA readNumber_buffer
    STA readNumber_buffer

    INC read_cursor
    LDY read_cursor
    LDA (exp), Y
    CMP #'0'
    BCC readNumber_end
    CMP #':'
    BCC readNumber_loop
.readNumber_end
    JSR freeAlloc
    LDA #6 ; refactor create_number
    LDY #0
    STA (ret), Y
    LDA readNumber_buffer
    INY
    STA (ret), Y
    LDA readNumber_buffer + 1
    INY
    STA (ret), Y
    LDA readNumber_buffer + 2
    INY
    STA (ret), Y
    LDY read_cursor
    RTS

.readNumber_buffer
    EQUB 0, 0, 0

.readToken_notnumber
    JSR freeAlloc
    LDA #2
    LDY #0
    STA (ret), Y

    ; read first char
    LDY read_cursor
    LDA (exp), Y
    LDY #1
    STA (ret), Y
    INC read_cursor

    ; read second char
    LDY read_cursor 
    LDA (exp), Y
    CMP #33
    BCC readSymbol_end
    CMP #')'
    BEQ readSymbol_end
    LDY #2
    STA (ret), Y
    INC read_cursor

    ; read third char
    LDY read_cursor 
    LDA (exp), Y
    CMP #33
    BCC readSymbol_end
    CMP #')'
    BEQ readSymbol_end
    LDY #3
    STA (ret), Y
    INC read_cursor

.readSymbol_end
    LDY read_cursor
    RTS

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
    LDY #2
    LDA (tmp), Y
    STA ret
    LDY #3
    LDA (tmp), Y
    STA ret + 1
    LDY read_cursor
    RTS
