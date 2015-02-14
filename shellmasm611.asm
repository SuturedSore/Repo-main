cseg segment
assume cs:cseg, ds:cseg, es:cseg, ss:cseg
org 100h

begin_shell:
call check_video
mov ah,9
mov dx,offset mes
int 21h
call main_proc
int 20h
include main.asm
include display.asm
include files.asm
include keyboard.asm
include messages.asm
;more asms go here
cseg ends
begin_shell endp
