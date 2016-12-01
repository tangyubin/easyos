%include "protect_mode.inc"
org 0100h
	jmp LABEL_BEGIN

[SECTION .gdt]
LABEL_GDT:		Descriptor 0, 0, 0				; blank descriptor 
LABEL_DESC_CODE32:	Descriptor 0, SegCode32Len - 1, DA_C + DA_32	; code segment, 32 bits
LABEL_DESC_VIDEO:	Descriptor 0B8000h, 0ffffh, DA_DRW		; head address of vedio memory

GdtLen	equ $ - LABEL_GDT	; length of GDT
GdtPtr	dw GdtLen		; GDT bounds
	dd 0			; basic address

SelectorCode32	equ LABEL_DESC_CODE32 	- LABEL_GDT
SelectorVideo	equ LABEL_DESC_VIDEO	- LABEL_GDT

[SECTION .s16]
[BITS 16]
LABEL_BEGIN:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0100h

	; init the 32 bits code segment
	xor eax, eax
	mov ax, cs
	shl eax, 4
	add eax, LABEL_SEG_CODE32
	mov word [LABEL_DESC_CODE32 + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_CODE32 + 4], al
	mov byte [LABEL_DESC_CODE32 + 7], ah
	
	;ready for loading gdtr
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, LABEL_GDT
	mov dword [GdtPtr + 2], eax
	
	;load gdtr
	lgdt	[GdtPtr]
	
	;close interuption
	cli
	
	;open the address line A20
	in al, 92h
	or al, 00000010b
	out 92h, al

	;ready for switch to protect mode
	mov eax, cr0
	or eax, 1
	mov cr0, eax

	;break into protect mode
	jmp dword SelectorCode32:0	; through execute this instruction,SelectorCode32 will be loaded into cs, and jump to SelectorCode32:0

[SECTION .s32]	; 32 bits code segment, jump from real mode
[BITS 32]
LABEL_SEG_CODE32:
	mov ax, SelectorVideo
	mov gs, ax			;destination
	
	mov edi, (80 * 10 + 0) * 2	;the 10th row, the 0th column of screen
	mov ah,	0Ch			; 0000: black base color, 1100: read font
	mov al, 'P'
	mov [gs:edi], ax

	;stop here

	jmp $

SegCode32Len	equ $ - LABEL_SEG_CODE32 ;END of [SECTION .s32]
