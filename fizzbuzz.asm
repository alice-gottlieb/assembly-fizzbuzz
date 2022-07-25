; DONE: Make MOD a macro
; TODO: asciiToNumbers
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

%macro numToAscii 2
   ; convert %1 to 4 ascii bytes
   ; save to 4 bytes of memory at [%2]
   print "M", 1
   MOV byte [%2], 0
   CMP byte [%1], 10
   JL Low
   CMP byte [%1], 100
   JL Mid
   CMP word [%1], 1000
   JL Lar
   JGE XL
   XL:
      modByte %1, 1000, [%2+8]
      MOV [%2], AL
      modByte [%2+8], 100, [%2+16]
      MOV [%2+8], AL
      modByte [%2+16], 10, [%2+24]
      MOV [%2+16], AL
      RET
   Lar:
      modByte %1, 100, [%2+16]
      MOV [%2+8], AL
      modByte [%2+16], 10, [%2+24]
      MOV [%2+16], AL
      RET
   Mid:
      modByte %1, 10, [%2+24] 
      MOV [%2+16], AL ; quotient from the IDIV in modByte is at AL
      RET
   Low:
      MOV AL, %1
      ADD AL, 0x30
      MOV [%2+24], AL
      RET
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
    print rem, 1
    CALL linebreak

    ;print ascii, 4
    numToAscii 9, ascii 
    print ascii, 4
    CALL linebreak
      
    MOV EAX, 1 ; sys_exit
    INT 0x80
    HLT

linebreak:
    print lb, 2
    RET
    MOV EAX, 4
    MOV EBX, 1
    MOV ECX, lb
    MOV EDX, 2
    INT 0x80

    RET

;numToAscii: ; convert EAX to 4 bytes of ascii numerals
;   MOV [a], EAX
;   MOV [b], EBX
;   MOV [c], ECX
;   MOV [d], EDX
;
;    MOV BL, 10
;    DIV BL
;    MOV ECX, 0
;    MOV CH, AH
;    ADD ECX, 0x30
;    MOV EDX, 1
;    MOV EBX, 1
;    MOV EAX, 4
;    INT 0x80
;
;    MOV EAX, [a]
;    MOV EBX, [b]
;    MOV ECX, [c]
;    MOV EDX, [d]
   
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
