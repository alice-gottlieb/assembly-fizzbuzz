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

section .data       
    lb db 0xA, 0xD

_start:
    MOV ECX, 5 ; set number of loops
    MOV EAX, 35 ; hold characaters for the numbers

    CALL mod
    
    MOV EAX, 1 ; sys_exit
    INT 0x80
    HLT

linebreak:
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX

    MOV EAX, 4
    MOV EBX, 1
    MOV ECX, lb
    MOV EDX, 2
    INT 0x80
    
    POP EDX
    POP ECX
    POP EBX
    POP EAX

    RET

mod: ; takes ax mod bl and puts remaidner in res as a string
   MOV EAX, 1279 ; max is 1279, since that gives rem 128-1
   MOV EBX, 10 
   IDIV BL
   ADD	AH, 0x30
   MOV  [rem], AH

   MOV EDX, 1
   MOV ECX, rem
   MOV EBX, 1
   MOV EAX, 4
   INT 0x80

   CALL linebreak

   RET

 numToAscii: ; convert EAX to 4 bytes of ascii numerals
    MOV [a], EAX
    MOV [b], EBX
    MOV [c], ECX
    MOV [d], EDX

    MOV BL, 10
    DIV BL
    MOV ECX, 0
    MOV CH, AH
    ADD ECX, 0x30
    MOV EDX, 1
    MOV EBX, 1
    MOV EAX, 4
    INT 0x80

    MOV EAX, [a]
    MOV EBX, [b]
    MOV ECX, [c]
    MOV EDX, [d]
   
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
   ; MOV EAX, numMsg
   ; INC EAX
   ; MOV numMsg, EAX
   ; RET
   LOOP looper
   RET
