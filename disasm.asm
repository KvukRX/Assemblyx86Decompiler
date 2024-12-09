.model small
.386
.stack 100h
.data
com db 'comands.com',0
discr db ?
buffer db 0BAh DUP(?)
len dw $-buffer
comBuffer db 5 DUP("$"), 09h
regBuffer db 255 DUP(?)
byteNum dw 0h
segNum dw ?
segSrt db 00h ,'ES','SS','FS','GS','CS','DS'
segSet db 00h, 26h, 36h, 64h, 65h, 2Eh, 3Eh
oneb_opcodeStr db '00000', 'LODSB', 'LODSW', 'LODSD', 'JA   ', 'JAE  ', 'JB   ', 'JBE  ', 'JCXZ ', 'JE   ', 'JG   ', 'JGE  ', 'JL   ', 'JLE  ',  'JNE  ', 'JNO  ', 'JNP  ', 'JNS  ', 'JO   ', 'JP   ', 'JS   '
oneb_opcode db 00h, 0ACh, 0ADh, 77h, 73h, 72h, 76h, 0E3h, 74h, 7Fh, 7Dh, 7Ch, 7Eh, 75h, 71h, 7Bh, 79h, 70h, 7Ah, 78h
twob_opcodeStr db '0000', 'BTR ', 'JA  ', 'JAE ', 'JB  ', 'JBE ', 'JE  ',  'JG  ', 'JGE ', 'JL  ', 'JLE ', 'JNB ', 'JNE ', 'JNLE', 'JNO ', 'JNP ' , 'JNS ', 'JO  ', 'JPE ', 'JS  '
twob_opcode db 00h, 0B3h, 0BAh, 87h, 83h, 82h, 86h, 84h, 8Fh, 8Dh, 8Ch, 8Eh, 83h, 85h, 8Fh, 81h, 8Bh, 89h, 80h, 8Ah, 88h
.code
start:
    mov ax, @data
    mov ds, ax
    mov es, ax
    mov bp, 0111h

    mov ax,3D00h
    lea dx, com
    int 21h

    mov bx, ax
    mov ax,3F00h
    mov cx, len
    lea dx, buffer
    int 21h

    mov ax, 3E00h
    int 21h

main:
    call operSize
    mov cx, 6
    mov si, byteNum
    mov al, [buffer+si]
    call segm
    call addr
    call twobCheck  
    jmp endOfProg
cont:
    
    
operSize proc
    mov si, byteNum
    cmp [buffer+si], 66h
    je equal
    sub bp,1h
    ret
operSize endp

segm proc
    mov si,cx
    cmp al, [segSet+si]
    je equalSeg
    loop segm
    sub bp,10h
    ret
segm endp

addr proc
    mov si, byteNum
    cmp [buffer+si], 67h
    je equal
    sub bp, 100h
    ret
addr endp

twobCheck proc
    mov si, byteNum
    cmp [buffer+si], 0Fh
    je equalTwob
    mov cx, 19;//////////////////////////////////MUST BE 19
    mov al, [buffer+si]
    call onebOpcode
    ret
twobCheck endp

onebOpcode proc
    mov si,cx
    cmp al, [oneb_opcode+si]
    je check_LODS
    loop onebOpcode
    ret
onebOpcode endp

twobOpcode proc
    mov si,cx
    cmp al, [twob_opcode+si]
    je check_BTR
    loop twobOpcode
    ret
twobOpcode endp

equal:
    inc byteNum
    ret

equalSeg:
    inc byteNum
    mov segNum, si
    ret

equalTwob:
    inc byteNum
    mov si, byteNum
    mov al, [buffer+si]
    mov cx, 20
    call twobOpcode

check_LODS:
    cmp si, 2
    je is_LODSW
    cmp si, 1
    je is_LODSB
    jmp onebopcode_to_buffer
is_LODSB:
    dec si
    jmp onebopcode_to_buffer
is_LODSW:
    bt bp, 0
    jc onebopcode_to_buffer
    dec si
    jmp onebopcode_to_buffer

check_BTR:
    cmp si, 1
    je twobopcode_to_buffer
    cmp si, 2
    jne twobopcode_to_buffer
    dec si
    jmp twobopcode_to_buffer

onebopcode_to_buffer:
    inc si
    mov cx, 5
    imul si, 5
    lea si, [oneb_opcodeStr+si]
    lea di, [comBuffer]
    rep movsb
    jmp cont
    
twobopcode_to_buffer:    
    mov cx, 4
    shl si, 2
    lea si, [twob_opcodeStr+si]
    lea di, [comBuffer]
    rep movsb
    jmp cont

    
writeVivod proc
    jmp endOfProg
writeVivod endp
    
endOfProg:    
    mov ah, 4ch
    int 21h
end start