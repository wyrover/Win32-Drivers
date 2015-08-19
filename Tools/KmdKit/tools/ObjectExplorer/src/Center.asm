
CenterOnWindow proto :HWND, :HWND
CenterOnScreen proto hwnd:HWND

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.code

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CenterOnWindow proc hwndTop:HWND, hwndBot:HWND

LOCAL	rcBot:RECT
LOCAL	rcTop:RECT
LOCAL	x:DWORD
LOCAL	y:DWORD

	invoke GetWindowRect, hwndBot, addr rcBot
	.if eax
		invoke GetWindowRect, hwndTop, addr rcTop
		.if eax
			mov	eax, rcBot.right				;center horizontally
			sub	eax, rcBot.left
			sub	eax, rcTop.right
			add	eax, rcTop.left
			sar	eax, 1
			add	eax, rcBot.left
			.if (sign?)							; off screen at left
				xor eax, eax
			.endif
			mov	x, eax

			invoke GetSystemMetrics, SM_CXFULLSCREEN
			sub	eax, rcTop.right
			add	eax, rcTop.left
			.if (eax < x)					; off screen at right
				mov x, eax
			.endif

			mov	eax, rcBot.bottom						; center vertically
			sub	eax, rcBot.top
			sub	eax, rcTop.bottom
			add	eax, rcTop.top
			sar	eax, 1
			add	eax, rcBot.top
			.if (sign?)		; off screen at top
				xor eax, eax
			.endif
			mov y, eax


			invoke SystemParametersInfo, SPI_GETWORKAREA, 0, addr rcBot, 0
			mov eax, rcBot.bottom
			sub eax, rcBot.top

;			invoke GetSystemMetrics, SM_CYSCREEN
;			invoke GetSystemMetrics, SM_CYFULLSCREEN
			sub eax, rcTop.bottom
			add eax, rcTop.top
			.if (eax < y)
				mov y, eax
			.endif

			invoke SetWindowPos, hwndTop, NULL, x, y, 0, 0, SWP_NOSIZE + SWP_NOZORDER
		.endif
	.endif

	ret

CenterOnWindow endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CenterOnScreen proc hwnd:HWND

option PROLOGUE:NONE
option EPILOGUE:NONE

	mov	eax,[esp+4]	; hwnd
	push 0			; bRepaint
	sub	esp, sizeof RECT
	mov	edx, esp
	push eax		; hwnd

	push SM_CXSCREEN
	push SM_CYSCREEN

	push edx		; pRECT
	push eax		; hwnd
	call GetWindowRect

	mov	eax,[4][esp].RECT.top
	mov	edx,[4][esp].RECT.left
	sub	[4][esp].RECT.bottom,eax
	sub	[4][esp].RECT.right,edx

	call GetSystemMetrics
	sub	eax,[8][esp].RECT.bottom
	shr	eax,1
	mov	[8][esp].RECT.top,eax

	call GetSystemMetrics
	sub	eax,[4][esp].RECT.right
	shr	eax,1
	mov	[4][esp].RECT.left,eax

	call MoveWindow

	ret (sizeof DWORD)

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

CenterOnScreen endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::