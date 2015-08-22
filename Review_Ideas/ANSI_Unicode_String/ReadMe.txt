# ANSI_Unicode_String



>>>>>> Operation between ANSI & Unicode string <<<<<<

ExAllocatePool
RtlFreeUnicodeString

RtlInitAnsiString
RtlInitUnicodeString

RtlAnsiStringToUnicodeString
RtlUnicodeStringToAnsiString

RtlCopyUnicodeString
RtlAppendUnicodeToString
RtlCompareUnicodeString
RtlUnicodeStringToInteger
RtlIntegerToUnicodeString

RtlUpcaseUnicodeString
>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<

Note that, Even RtlDowncaseUnicodeString was exist on the Windows 7 Platform's 
    NTOSKRNL.EXE, but Compiling-error still occurred.
	
	ansi_unicode.c(83) : error C4013: 'RtlDowncaseUnicodeString' undefined; assuming extern returning int.