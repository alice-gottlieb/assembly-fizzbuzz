; DONE: Make MOD a macro
; DONE: numToAscii
; DONE: Fizz the buzz

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
    fizzNum db 5
    buzzNum db 3
    fizzMsg db 'fizz'
    buzzMsg db 'buzz'
    len equ $ - buzzMsg

_start:
    MOV ECX, 98 ; set number of loops
    MOV EAX, 1 ; number to print each iteration when no fizz or buzz

    CALL fizzbuzz

    MOV EAX, 1
    INT 0x80
    HLT

    ; Extra tests if you comment out the HLT above
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

   MOV [n], AL

   CMP AL, 10
   JL Low
   CMP AL, 100
   JL Mid
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
     modByte [n], 10, CL ; put ones digit in CL
     ADD CL, 0x30 ; convert CL to ascii
     MOV CH, AL ; quotient from the IDIV in modByte is at AL, this is the tens place
     ADD CH, 0x30
     RET
   Low:
     MOV CL, [n]
     ADD CL, 0x30
     RET

fizzbuzz:
   MOV [c], ECX ; save registers
   MOV [a], EAX 
   modByte [a], [fizzNum], [rem] ; rem = a mod fizzNum
   CMP byte [rem], 0
   JE fizz ; print fizz if (a mod fizzNum) == 0
   modByte [a], [buzzNum], [rem] ; check buzz
   CMP byte [rem], 0
   JE buzz

   MOV EAX, [a]
   CMP EAX, 10 ; check number of decimal digits in EAX
   JL oneDigit
   CALL numToAscii ; convert EAX to 2-digit decimal ascii
   MOV [n], CH ; tens place
   MOV [rem], CL ; ones place
   JMP numPrint

   numPrint:
      ; print tens place then ones place
      print n, 1
      print rem, 1
      JMP cont

   oneDigit:
      ADD EAX, 0x30 ; convert EAX to ascii
      MOV [printWord], EAX
      print printWord, 1
      JMP cont 

   cont:
      CALL linebreak
      MOV EAX, [a] ; recall original value for EAX
      INC EAX
      MOV [a], EAX
      MOV ECX, [c] ; recall original value for ECX
      DEC ECX ; loop counter
      MOV [c], ECX
      CMP ECX, 0 ; break loop if ECX reaches 0
      JG fizzbuzz 
      RET
   fizz:
      print fizzMsg, len
      ; check buzz
      modByte [a], [buzzNum], [rem]
      CMP byte [rem], 0
      JE buzz
      JMP cont
   buzz:
      print buzzMsg, len
      ; no need to check fizz
      JMP cont
