; DONE: Make MOD a macro
; DONE: numToAscii
; TODO: Fizz the buzz

%macro print 2 
   ; print msg %1 of length %2
   MOV  ECX, %1
   MOV  EDX, %2
   MOV  EAX, 4
   MOV  EBX, 1
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
   rem resb 1 ; remainder of mod
   n resw 1
   printWord resw 1

section .data       
    lb db 0xA, 0xD
    fizzNum db 2
    buzzNum db 3
    fizzMsg db 'fizz' ;, 0xA, 0xD
    buzzMsg db 'buzz' ;, 0xA, 0xD
    len equ $ - buzzMsg

_start:
    MOV ECX, 9 ; set number of loops
    MOV EAX, 1 ; hold characaters for the numbers

    CALL fizzbuzz

    MOV EAX, 1
    INT 0x80
    HLT

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

   ;MOV [a], EAX
   ;MOV [b], EBX
   ;MOV [c], ECX
   ;MOV [d], EDX
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

fizzbuzz:
   ;MOV [num], EAX ; move only higher byte of EAX
   MOV [c], ECX
   MOV [a], EAX 
   modByte [a], [fizzNum], [rem]
   CMP byte [rem], 0
   JE fizz
   modByte [a], [buzzNum], [rem]
   CMP byte [rem], 0
   JE buzz

   MOV EAX, [a]
   CMP EAX, 10
   JL oneDigit
   CALL numToAscii
   MOV [n], CH
   MOV [rem], CL
   JMP numPrint

   numPrint:
      print n, 1
      print rem, 1
      JMP cont

   oneDigit:
      ADD EAX, 0x30
      MOV [printWord], EAX
      print printWord, 1
      JMP cont 

   cont:
      CALL linebreak
      MOV EAX, [a]
      INC EAX
      MOV [a], EAX
      MOV ECX, [c]
      DEC ECX
      MOV [c], ECX
      CMP ECX, 0 
      JGE fizzbuzz 
      RET
   fizz:
      print fizzMsg, len
      modByte [a], [buzzNum], [rem]
      CMP byte [rem], 0
      JE buzz
      JMP cont
   buzz:
      print buzzMsg, len
      JMP cont
