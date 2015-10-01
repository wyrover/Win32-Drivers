//
//      G_L_ErrorString.h
//
//      ShowError Code to String     by App in Ring3 !!!
//
//      Original source: http://www.cnblogs.com/gamesun/archive/2013/06/10/3131255.html
//      Have some changes while making it a file.
//
///////////////////////////////////////////////////////////////////////////////////////////
//
//   Header file required:   windows.h
//
//   Sample of using this header:
//            if ( !uStatus )
//            {
//                ShowErrorInfoMsgBox( GetLastError() );
//            }
//

#pragma once

void ShowErrorInfoMsgBox( DWORD dwErrNo )
{ 
    // Retrieve the system error message for the last-error code
    LPVOID lpMsgBuf;
    
    FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER | 
                   FORMAT_MESSAGE_FROM_SYSTEM |
                   FORMAT_MESSAGE_IGNORE_INSERTS,
                   NULL,
                   dwErrNo,
                   MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                   (LPTSTR) &lpMsgBuf,
                   0, NULL );

    // Display the error message and exit the process
    MessageBox( NULL, (LPCTSTR)lpMsgBuf, TEXT("GetLastError Meanings."), MB_OK|MB_ICONSTOP );

    LocalFree(lpMsgBuf);
}