.model small
.186
.stack 100h
.data
com db 'comands.com',0
discr db ?
buffer db 0BAh DUP(?)
len dw $-buffer
vivodBuffer db 255 DUP("$")
byteNum dw 0h
segNum dw ?
segSrt db 00h ,'ES','SS','FS','GS','CS','DS'
segSet db 00h, 26h, 36h, 64h, 65h, 2Eh, 3Eh
oneb_opcode db 00h, 0ACh, 0ADh, 77h, 73h, 72h, 76h, 0E3h, 74h, 7Fh, 7Dh, 7Ch, 7Eh, 75h, 71h, 7Bh, 79h, 70h, 7Ah, 78h
twob_opcode db 00h, 0B3h, 0BAh, 87h, 83h, 82h, 86h, 84h, 8Fh, 8Dh, 8Ch, 8Eh, 83h, 85h, 8Fh, 81h, 8Bh, 89h, 80h, 8Ah, 88h
.code
start:
    mov ax, @data
    mov ds,ax
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
    mov cx, 5;//////////////////////////////////MUST BE 19
    mov al, [buffer+si]
    call onebOpcode
twobCheck endp

onebOpcode proc
    mov si,cx
    cmp al, [oneb_opcode+si]
    je onebopcode_to_buffer
    loop onebOpcode
onebOpcode endp

twobOpcode proc
    mov si,cx
    cmp al, [twob_opcode+si]
    je twobopcode_to_buffer
    loop twobOpcode
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
    
onebopcode_to_buffer:
    ret
twobopcode_to_buffer:    
    ret

endOfProg:    
    mov ah, 4ch
    int 21h
end start