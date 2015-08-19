; Written by Four-F

.code

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ReportLastError proc

	option PROLOGUE:NONE
	option EPILOGUE:NONE

	.const
	szCaption			db "ErrorShow",0
	szNotFoundMessage	db "Sorry. Error number not found.", 0

	.code

	pushfd
	pushad

	sub esp, 800h

	invoke GetLastError
	mov ecx, esp
	invoke FormatMessage, FORMAT_MESSAGE_FROM_SYSTEM, NULL, eax, \
					SUBLANG_DEFAULT SHL 10 + LANG_NEUTRAL, ecx, 800h, NULL
	.if eax != 0
		mov ecx, esp
		invoke MessageBox, NULL, ecx, addr szCaption, MB_OK
	.else
		invoke MessageBox, NULL, addr szNotFoundMessage, addr szCaption, MB_OK
	.endif
 
	add esp, 800h

	popad
	popfd
    
	option PROLOGUE:PROLOGUEDEF
	option EPILOGUE:EPILOGUEDEF

	ret

ReportLastError endp
