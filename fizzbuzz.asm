; DONE: Make MOD a macro
; DONE: numToAscii
; TODO: Fizz the buzz

%macro print 2 
   ; print msg %1 of length %2
   MOV  EAX, 4
   MOV  EBX, 1
   MOV  ECX, %1
   MOV  EDX, %2
   INT  0x80
%endmacro


%macro modByte 3
   ; Take %1 mod %2, send result to %3
   ; %1 and %2 should be bytes
   ; %3 should be given as a memory address, e.g. [var]
   MOV EAX, %1
   MOV EBX, %2
   IDIV BL
   MOV %3, AH 
%endmacro

section .text
    global _start
    
section .bss
   num resb 1 ; byte to store num
   a resb 4 ; 4 bytes for EAX while being operated on by numToAscii
   b resb 4 
   c resb 4 
   d resb 4 
   ascii resb 4
   rem resb 1 ; remainder of mod
   n resw 1

section .data       
    lb db 0xA, 0xD

_start:
    MOV ECX, 5 ; set number of loops
    MOV EAX, 35 ; hold characaters for the numbers

    modByte 78, 10, [rem]
    MOV AH, [rem]
    ADD AH, 0x30
    MOV [rem], AH
    print rem, 1
    CALL linebreak

    ;print ascii, 4
    MOV AL, 95
    MOV ECX, 0
    CALL numToAscii 
    MOV [n], CH
    MOV [rem], CL
    print n, 1
    print rem, 1
    CALL linebreak
      
    MOV EAX, 1 ; sys_exit
    INT 0x80
    HLT

linebreak:
    print lb, 2
    RET

numToAscii: 
   ; convert AL to 3 ascii bytes
   ; save to ECX
   ; Tens plae - CH
   ; Ones place - CL

   MOV [a], EAX
   MOV [b], EBX
   MOV [c], ECX
   MOV [d], EDX
   MOV [n], AL

   CMP AL, 10
   JL Low
   CMP AL, 100
   JL Mid
   ;JGE Lar
   ;Lar:
   ;   modByte n, 100, CH
   ;   MOV CL, AL
   ;   ADD CL, 0x30
   ;   modByte CH, 10, [ECX+24] 
   ;   MOV CH, AL
   ;   ADD CH, 0x30
   ;   ADD byte [ECX+24], 0x30
   ;   RET
   Mid:
     modByte [n], 10, CL 
     ADD CL, 0x30
     MOV CH, AL ; quotient from the IDIV in modByte is at AL
     ADD CH, 0x30
     RET
   Low:
     MOV CL, [n]
     ADD CL, 0x30
     RET

looper:
   MOV [num], EAX ; move only higher byte of EAX
   MOV EDX, 1
   MOV EBX, 1
   PUSH ECX
   MOV ECX, num ; move only 1 byte from num into ECX
   MOV EAX, 4 ; sys_write command
   INT 0x80 ; print
   CALL linebreak
   
   MOV EAX, [num]
   SUB EAX, 0x30
   INC EAX
   ADD EAX, 0x30
   POP ECX ; retrieve old ECX value
   LOOP looper
   RET
