.model small
.386
.stack 100h
.data
com db 'comands.com',0
filename db "vivod.txt", 0
discr dw ?
buffer db 0D8h DUP(?)
len dw $-buffer
comBuffer db 5 DUP("$"), 09h, 248 DUP (" "), 0ah
byteNum dw 0h
segNum dw ?
segSrt db 00h ,'ES','SS','FS','GS','CS','DS'
segSet db 00h, 26h, 36h, 64h, 65h, 2Eh, 3Eh
oneb_opcodeStr db '00000', 'LODSB', 'LODSW', 'LODSD', 'JA   ', 'JAE  ', 'JB   ', 'JBE  ', 'JCXZ ', 'JE   ', 'JG   ', 'JGE  ', 'JL   ', 'JLE  ',  'JNE  ', 'JNO  ', 'JNP  ', 'JNS  ', 'JO   ', 'JP   ', 'JS   '
oneb_opcode db 00h, 0ACh, 0ADh, 77h, 73h, 72h, 76h, 0E3h, 74h, 7Fh, 7Dh, 7Ch, 7Eh, 75h, 71h, 7Bh, 79h, 70h, 7Ah, 78h
twob_opcodeStr db '00000', 'BTR  ', 'JA   ', 'JAE  ', 'JB   ', 'JBE  ', 'JE   ',  'JG   ', 'JGE  ', 'JL   ', 'JLE  ', 'JNB  ', 'JNE  ', 'JNLE ', 'JNO  ', 'JNP  ', 'JNS  ', 'JO   ', 'JPE  ', 'JS   '
twob_opcode db 00h, 0B3h, 0BAh, 87h, 83h, 82h, 86h, 84h, 8Fh, 8Dh, 8Ch, 8Eh, 83h, 85h, 8Fh, 81h, 8Bh, 89h, 80h, 8Ah, 88h
.code
start:
    mov ax, @data
    mov ds, ax
    mov es, ax

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
    
    mov     ah, 3ch
    mov     cx, 0
    mov     dx, offset filename
    int     21h
    mov     [discr], ax

main:
    mov bp, len
    cmp byteNum, bp
    je EXIT
    mov bp, 0111h
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
    mov cx, 19d
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
    mov cx, 20d
    call twobOpcode

check_LODS:
    cmp si, 2
    je is_LODSW
    cmp si, 1
    je is_LODSB
    add bp, 1000h
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
    mov di, si
    cmp di, 1
    je twobopcode_to_buffer
    dec si
    cmp di, 2
    jne prepTwoBJmp
    jmp twobopcode_to_buffer
prepTwoBJmp:
    add bp, 1000h
    jmp twobopcode_to_buffer
onebopcode_to_buffer:
    inc si
    mov cx, 5
    imul si, 5
    lea si, [oneb_opcodeStr+si]
    lea di, [comBuffer]
    rep movsb
    cmp bp, 1000h
    jnb oneBAddressJmpPrep
    mov dx, 5
    mov bp, 0
    jmp writeVivod
    
twobopcode_to_buffer:    
    mov cx, 5
    imul si, 5
    lea si, [twob_opcodeStr+si]
    lea di, [comBuffer]
    rep movsb
    cmp bp, 1000h
    jnb twoBaddress
    inc byteNum
    jmp main;cont

oneBAddressJmpPrep:    
    inc byteNum
    mov si, byteNum
    mov al, [buffer+si]
oneBAddressJmp:
    cmp al, 10d
    jb  oneDigit
    cmp al, 100d
    jb  twoDigit
    cmp al, 127d
    jbe threeDigit
    jmp negativeOneB
oneDigit:
    aam
    add al, 30h
    mov [comBuffer+7], al
    mov dx, 8
    mov bp, 2
    jmp writeVivod
twoDigit:
    aam
    add ax, 3030h
    mov [comBuffer+8], al
    mov [comBuffer+7], ah
    mov dx, 9
    mov bp, 3
    jmp writeVivod
threeDigit:
    aam
    add al, 30h
    mov [comBuffer+9], al
    mov al, ah
    aam
    add ax, 3030h
    mov [comBuffer+8], al
    mov [comBuffer+7], ah
    mov dx, 10
    mov bp, 4
    jmp writeVivod

twoBaddress:
    inc byteNum
    mov si, byteNum
    mov ax, word ptr [buffer+si]
    ;cmp ah, 0Fh
    ;jne not0fTwoB
    ;mov ah, 0
not0fTwoB:
    ;mov dl, ah
    ;mov ah, al
    ;mov al, dl
    cmp ax, -32768d
    je  MaxNeg
    ;cmp ah, 0
    ;je  oneBAddressJmp
    cmp ax, 0
    jns threeDigitTwoB
MaxNeg:
    inc ax
    neg ax
    inc ax
    mov [comBuffer+6], '-'
threeDigitTwoB:
    cmp ax, 1000d
    jae fourDigitTwoB
    mov cx, 3
    mov bx, 10
    mov si, 9
loop1:    
    xor dx,dx
    div bx
    add dl, 30h 
    mov [comBuffer+si], dl
    dec si
    loop loop1
    mov dx, 10
    mov bp, 4
    jmp writeVivod
fourDigitTwoB:
    cmp ax, 10000d
    jae fiveDigitTwoB
    mov cx, 4
    mov bx, 10
    mov si, 10
loop2:
    xor dx,dx
    div bx
    add dl, 30h
    mov [comBuffer+si], dl
    dec si
    loop loop2
    mov dx, 11
    mov bp, 5
    jmp writeVivod 
fiveDigitTwoB:
    mov cx, 5
    mov bx, 10
    mov si, 11
loop3:
    xor dx,dx
    div bx
    add dl, 30h
    mov [comBuffer+si], dl
    dec si
    loop loop3
    mov dx, 12
    mov bp, 6
    jmp writeVivod  
writeVivod:
    inc     byteNum
    mov     cx, dx
    mov     ah, 040h
    mov     bx, [discr]
    lea     dx, comBuffer
    int     21h
    mov     ah, 040h
    lea     dx, [comBuffer+254]
    mov     bx, [discr]
    mov     cx, 1d
    int     21h
    cmp     bp, 0
    je      main
    mov     cx, bp
clear:
    mov     si, cx
    mov     [comBuffer+5+si], 20h
    loop    clear
    jmp     main

negativeOneB:
    neg ax
    cmp ax, 128d
    je  threeDigit
    mov [comBuffer+6], '-'
    jmp oneBAddressJmp

endOfProg:
    inc byteNum
    jmp main;delete it  
EXIT:
    mov ax, 3E00h
    mov bx, discr
    int 21h  
    mov ah, 4ch
    int 21h
end start