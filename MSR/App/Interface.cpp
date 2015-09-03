//
//    Interface.cpp
//
//    Ring 3 Interface.
//
//       Begin:            Nov 01, 2007, by Fan Zhang
//    Modified:  05:33 PM, Aug 28, 2015, by Mighten Dai<mighten.dai@gmail.com>
// 
//         Intel Microprocessors recommended !!!!!
//      Reference Book: Intel(R) 64 and IA-32 Architecture Developer's Manual 
//
#include <windows.h>
#include <stdio.h>
#include <winioctl.h>

#include "G_L_ErrorString.h" // convert Error ID of GetLastError to Error String.

const wchar_t        sym_name[] = L"\\\\.\\HelloDDK";
const unsigned long  READ_MSR_REGISTER  = CTL_CODE( FILE_DEVICE_UNKNOWN,  0x800, METHOD_BUFFERED,   FILE_ANY_ACCESS );

int main()
{
    DWORD   dwOutput;
    DWORD   dwMsrAddress;
    DWORD   OutputBuffer[2];
    ULONG   ulStatus;

    HANDLE  hDevice = CreateFile(   sym_name,
                                    GENERIC_READ | GENERIC_WRITE,
                                    0,       // share mode none
                                    NULL,    // no security
                                    OPEN_EXISTING,
                                    FILE_ATTRIBUTE_NORMAL,
                                    NULL );  // no template

    if (hDevice == INVALID_HANDLE_VALUE)
    {
		DWORD        ErrorID = GetLastError();
        printf( "Failed to obtain file handle to SymbolicLink: %s with Win32 error code: %d\n", sym_name, ErrorID );
		ShowErrorInfoMsgBox( ErrorID );
        getchar();
        getchar();
        return -1;
    }

    //////////////////////////////////////////////////////////////////////
    // Set the input buffer to be ready for interaction with Driver
	printf("Please input an index of MSR:" );
    scanf( "%d", &dwMsrAddress );

    ulStatus = DeviceIoControl( hDevice, READ_MSR_REGISTER,
                                &dwMsrAddress, 4, // Input  buffer and length
                                OutputBuffer,  8, // Output buffer and length
                                &dwOutput, NULL   );
    if ( !ulStatus )
    {
		DWORD   ErrorID = GetLastError();
        printf("Device I/O failed, error ID = 0x%08X.\n", ErrorID );
		ShowErrorInfoMsgBox( ErrorID );
        getchar();
        getchar();
		return  -2;
    }

	if ( !dwOutput )
    {
		DWORD   ErrorID = GetLastError();
        printf("Error: Read 0 bytes, error ID = 0x%08X.\n", ErrorID );
		ShowErrorInfoMsgBox( ErrorID );
        getchar();
        getchar();
		return -3;
    }

	/////////////////////////////////////////
    //    here is the data showing
    printf("The arrival of data from MSR address 0x%08X.\n", dwMsrAddress );
	printf("            High DWORD = 0x%08X\n", OutputBuffer[0] );
	printf("            Low  DWORD = 0x%08X\n", OutputBuffer[1] );

    ////////////////////////////////////////
    CloseHandle( hDevice );
    getchar();
    getchar();
    return 0;
}