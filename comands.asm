.model tiny
.386
.code
org 100h   
start:



db 73h,00h ;JAE or JNB or JNC
db 72h,00h ;JB or JC or JNAE
db 76h,00h ;JBE or JNA
db 0E3h,00h ;JCXZ or JECXZ
db 74h,00h ;JE or JZ
db 7Fh,00h ;JG or JNLE
db 7Dh,00h ;JGE or JNL
db 7Ch,00h ;JL or JNGE
db 7Eh,00h ;JLE or JNG
db 75h,00h ;JNE or JNZ
db 71h,00h ;JNO
db 7Bh,00h ;JNP or JPO
db 79h,00h ;JNS
db 70h,00h ;JO
db 7Ah,00h ;JP or JPE
db 78h,00h ;JS
db 77h,00h ;JA or JNBE  






lodsb
lodsw
lodsd
;////////////////////////////// btr r16,imm8
btr ax,1
btr bx,1
btr cx,1
btr dx,1
btr bp,1
btr si,1
btr di,1
btr sp,1
;////////////////////////////// btr 32,imm8
btr eax,1
btr ebx,1
btr ecx,1
btr edx,1
btr ebp,1
btr esi,1
btr edi,1
btr esp,1
;////////////////////////////// btr r16,r16
btr ax,bx
btr bx,bx
btr cx,bx
btr dx,bx
btr bp,bx
btr si,bx
btr di,bx
btr sp,bx
;////////////////////////////// btr r32,r32
btr eax,ebx
btr ebx,ebx
btr ecx,ebx
btr edx,ebx
btr ebp,ebx
btr esi,ebx
btr edi,ebx
btr esp,ebx
;////////////////////////////// btr m16,r16
btr [si],cx
btr [si],cx
btr [si],cx
btr [si],cx
btr [si],cx
btr [si],cx
btr [si],cx
btr [si],cx
;////////////////////////////// btr m32,r32
;////////////////////////////// btr m16,imm6
;////////////////////////////// btr m32,imm6

;////////////////////////////// short jcc 
end start