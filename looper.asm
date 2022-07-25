section .text
    global _start

_start:
    MOV ECX, 5 ; set number of loops
    CALL l2
    INT 1   ; print EAX

l2:
   MOV EAX, ECX
   INT 1
   LOOP l2
