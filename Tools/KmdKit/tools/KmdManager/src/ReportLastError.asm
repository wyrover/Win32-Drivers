.code

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ReportLastError proc

LOCAL lpBuffer:LPVOID
LOCAL dwErrorId:DWORD
LOCAL dwLanguageId:DWORD

.data
szCaption db "ErrorShow",0
szNotFoundMessage db "Sorry. Error number not found.", 0

.code

    pushfd
    pushad
    
    xor eax, eax
    mov lpBuffer, eax                   ; исп lpBuffer как флаг
         
    mov dwLanguageId, SUBLANG_DEFAULT
    shl dwLanguageId, 10
    add dwLanguageId, LANG_NEUTRAL               ; MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT) User default language

    invoke GetLastError
    mov dwErrorId, eax
    
    invoke FormatMessage, FORMAT_MESSAGE_FROM_SYSTEM + FORMAT_MESSAGE_ALLOCATE_BUFFER, \
                          NULL, dwErrorId, dwLanguageId, addr lpBuffer, 0, NULL

    .if eax!=0
        invoke LocalLock, lpBuffer
        invoke MessageBox, NULL, lpBuffer, addr szCaption, MB_OK
        invoke LocalFree, lpBuffer
    .else
        invoke MessageBox, NULL, addr szNotFoundMessage, addr szCaption, MB_OK
    .endif
    
    popad
    popfd
    
    ret

ReportLastError endp