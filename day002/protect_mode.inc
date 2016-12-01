; Descriptor
; usage: Descriptor Base, Limit, Attr
;	Base: dd
; 	Limit: dd(lower 20 bits available)
;	Attr: dw (lower 4 bits of higher byte are always 0)

%macro Descriptor 3
	dw %2 & 0FFFFh		; 2 bytes
	dw %1 & 0FFFFh		; sector base address (2 bytes)
	db (%1 >> 16) & 0FFh	; sector base address (1 bytes)
	dw ((%2 >> 8) & 0F00h) | (%3 & 0F0FFh)
	db (%1 >> 24) & 0FFh
%endmacro;	total 8 bytes
