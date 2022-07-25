section .text
    global _start

section .data       
    msg db 'Hello, world!', 0xa  ;string to be printed
    len equ $ - msg     ;length of the string
    numMsg db '1', 0xA
    lenNum equ $ - numMsg

; section .bss
   ;num resb 1

_start:
    MOV ECX, 5 ; set number of loops
    MOV EAX, '1' ; hold characaters for the numbers

    CALL looper 
    CALL helloWorldTest
    
    MOV EAX, 1 ; sys_exit
    INT 0x80

helloWorldTest:
    ;XOR EDX, EDX
    ;XOR EAX, EAX
    ;XOR EBX, EBX
    ;XOR ECX, ECX
    MOV  edx, len   ;message length
    MOV  ecx, msg     ;message to write       
    MOV  ebx,1       ;file descriptor (stdout)
    MOV  eax,4       ;system call number (sys_write)
    INT  0x80        ;call kernel
    RET
    
looper:
   MOV EDX, lenNum
   MOV EBX, 1
   PUSH ECX
   MOV ECX, numMsg
   MOV EAX, 4 ; sys_write command
   INT 0x80 ; print

   POP ECX ; retrieve old ECX value
   ; MOV EAX, numMsg
   ; INC EAX
   ; MOV numMsg, EAX
   RET
   ; LOOP looper
