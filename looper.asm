section .text
    global _start

section .bss
   num resb 1 ; byte to store num

section .data       
    msg db 'Hello, world!', 0xa  ;string to be printed
    len equ $ - msg     ;length of the string
    numMsg db '1'
    lenNum equ $ - numMsg
    lb db 0xA, 0xD

_start:
    MOV ECX, 5 ; set number of loops
    MOV EAX, 0x30 ; hold characaters for the numbers

    CALL looper 
    CALL helloWorldTest
    
    MOV EAX, 1 ; sys_exit
    INT 0x80

helloWorldTest:
    MOV  edx, len   ;message length
    MOV  ecx, msg     ;message to write       
    MOV  ebx,1       ;file descriptor (stdout)
    MOV  eax,4       ;system call number (sys_write)
    INT  0x80        ;call kernel
    RET

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
