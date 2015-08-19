TVITEMW STRUCT
	_mask			DWORD	?	; UINT
	hItem			DWORD	?	; HTREEITEM
	state			DWORD	?	; UINT
	stateMask		DWORD	?	; UINT
	pszText			DWORD	?	; LPWSTR
	cchTextMax		SDWORD	?	; int
	iImage			SDWORD	?	; int
	iSelectedImage	SDWORD	?	; int
	cChildren		SDWORD	?	; int
	lParam			DWORD	?	; LPARAM
TVITEMW ENDS
LPTVITEMW typedef PTR TVITEMW

TV_ITEMW textequ <TVITEMW>

TVITEMEXW STRUCT
	_mask			DWORD	?	; UINT
	hItem			DWORD	?	; HTREEITEM
	state			DWORD	?	; UINT
	stateMask		DWORD	?	; UINT
	pszText			DWORD	?	; LPWSTR
	cchTextMax		SDWORD	?	; int
	iImage			SDWORD	?	; int
	iSelectedImage	SDWORD	?	; int
	cChildren		SDWORD	?	; int
	lParam			DWORD	?	; LPARAM
	iIntegral		SDWORD	?	; int
TVITEMEXW ENDS
LPTVITEMEXW typedef PTR TVITEMEXW

TVINSERTSTRUCTW STRUCT
	hParent			DWORD	?		; HTREEITEM
	hInsertAfter	DWORD	?		; HTREEITEM
	union
		itemex		TVITEMEXW	<>
		item		TV_ITEMW	<>
	ends
TVINSERTSTRUCTW ENDS
LPTVINSERTSTRUCTW typedef PTR TVINSERTSTRUCTW

TV_INSERTSTRUCTW textequ <TVINSERTSTRUCTW>




LVITEMW STRUCT
	_mask		DWORD	?	; UINT
	iItem		SDWORD	?	; int
	iSubItem	SDWORD	?	; int
	state		DWORD	?	; UINT
	stateMask	DWORD	?	; UINT
	pszText		DWORD	?	; LPWSTR
	cchTextMax	SDWORD	?	; int
	iImage		SDWORD	?	; int
	lParam		DWORD	?	; LPARAM
	iIndent		SDWORD	?	; int
LVITEMW ENDS
LPLVITEMW typedef PTR LVITEMW

LV_ITEMW textequ <LVITEMW>
