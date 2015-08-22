//
//      Downcase_Unicode_String.h
//
//    This routine is used for driver,
//
//   **** to keep all of the English characters down-case in a memory
//             ensured by last calling hierarchy.
//
//   **** any behavior such as using invalid address can immediately
//           result in BSOD( Blue Screen Of Death )
//
//                     Aug 22, 2015, written by Mighten Dai
//
#ifndef    MACRO_PROTECTION__INCLUDE__Downcase_Unicode_String_h__
#define    MACRO_PROTECTION__INCLUDE__Downcase_Unicode_String_h__

NTSTATUS    DowncaseUnicodeString( PUNICODE_STRING pDes, PUNICODE_STRING pSrc )
{
    int       index = 0;
    const int limit = ( pSrc->Length) / 2 ; // UNICODE String Counted by bytes.

    USHORT *pusSrc = (USHORT *) pSrc->Buffer;
    USHORT *pusDes = (USHORT *) pDes->Buffer;    

    for ( ; index < limit; ++index )
    {
         USHORT temp =  pusSrc[index];

        if ( temp >= 65 && temp <= 90 )
        {
            temp |= 0x20;
        }

		pusDes[index] = temp;
    }

    return  STATUS_SUCCESS;
}

#endif // #ifndef    MACRO_PROTECTION__INCLUDE__Downcase_Unicode_String_h__