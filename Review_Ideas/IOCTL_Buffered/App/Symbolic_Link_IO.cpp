//
//    Dev_IOCTL_Bidirectionally.cpp
//
//    Using bidirectally I/O Control with Driver.
//
//       Begin:            Nov 01, 2007, by Fan Zhang
//    Modified:  11:10 AM, Aug 27, 2015, by Mighten Dai<mighten.dai@gmail.com>
// 
#include <windows.h>
#include <stdio.h>
#include <winioctl.h>

const wchar_t        sym_name[] = L"\\\\.\\HelloDDK";
const unsigned long  IOCTL__FILE_UNKNOWN_BUFFERED___ANY_ACCESS  = CTL_CODE( FILE_DEVICE_UNKNOWN,  0x800, METHOD_BUFFERED,   FILE_ANY_ACCESS );

int main()
{
    DWORD   dwOutput;
    UCHAR   InputBuffer[10];
    UCHAR   OutputBuffer[10];
    HANDLE  hDevice = CreateFile(   sym_name,
                                    GENERIC_READ | GENERIC_WRITE,
                                    0,       // share mode none
                                    NULL,    // no security
                                    OPEN_EXISTING,
                                    FILE_ATTRIBUTE_NORMAL,
                                    NULL );  // no template

    if (hDevice == INVALID_HANDLE_VALUE)
    {
        printf( "Failed to obtain file handle to SymbolicLink: %s with Win32 error code: %d\n", sym_name, GetLastError( ) );
        return 1;
    }

    //////////////////////////////////////////////////////////////////////
    // Set the input buffer to be ready for interaction with Driver
    memset( InputBuffer, 0xBB, 10 );
	printf("InputBuffer size = 10 set.\n");

        
    if ( DeviceIoControl(   hDevice,
                            IOCTL__FILE_UNKNOWN_BUFFERED___ANY_ACCESS, // Bidirectionally
                            InputBuffer, 10,
                            OutputBuffer, 10,
                            &dwOutput, NULL)
    )
    {
        printf("Arrival of data from Driver %s\n", sym_name );
        printf("Output buffer:%d bytes\n\t\t",dwOutput);
        for ( DWORD i = 0; i< dwOutput; i++ )
        {
            printf("%02X ",OutputBuffer[i]);
        }
        putchar('\n');
    }

    
    CloseHandle( hDevice );

    printf("Demonstration over.\n"
           "Press Enter key to exit.\n"    );

	getchar();
	getchar();

    return 0;
}