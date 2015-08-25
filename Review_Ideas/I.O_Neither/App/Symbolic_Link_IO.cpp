//
//    Symbolic_Link_IO.cpp
//
//    1> Read 10 bytes from Symbolic Link \\.\HelloDDK
//    2> Write 10 bytes of repeating 0xBB into \\.\HelloDDK
//
#include <windows.h>
#include <stdio.h>

UCHAR buffer[10];
ULONG ulOperated;
HANDLE hDevice;
BOOL bRet;

int   do_read_device( )
{
	hDevice = CreateFile( L"\\\\.\\HelloDDK",
					GENERIC_READ | GENERIC_WRITE,
					0,		// share mode none
					NULL,	// no security
					OPEN_EXISTING,
					FILE_ATTRIBUTE_NORMAL,
					NULL );		// no template

	if (hDevice == INVALID_HANDLE_VALUE)
	{
		printf("Failed to obtain file handle to device: "
			"%s with Win32 error code: %d\n",
			"MyWDMDevice", GetLastError() );
		return -1;
	}

	printf( "\n\n   Read file, by buffer address = 0x%08X, length = 0xA\n", buffer );
	bRet = ReadFile( hDevice, buffer, 10, &ulOperated, NULL );

	if (bRet)
	{
		printf("Read %d bytes:",ulOperated );

		for (int i=0; i<(int)ulOperated; i++)
		{
			printf("0x%02X ",buffer[i]);
		}

		printf("\n");
	}
	else
	{
		return -2;
	}

	CloseHandle(hDevice);

	return 0;
}

int    do_write_device()
{
	hDevice = CreateFile( L"\\\\.\\HelloDDK",
					GENERIC_READ | GENERIC_WRITE,
					0,		// share mode none
					NULL,	// no security
					OPEN_EXISTING,
					FILE_ATTRIBUTE_NORMAL,
					NULL );		// no template

	if ( INVALID_HANDLE_VALUE == hDevice )
	{
		printf("Failed to obtain file handle to device: "
			"%s with Win32 error code: %d\n",
			"MyWDMDevice", GetLastError() );
		return -1;
	}

	printf( "\n\n   Write file,   buffer address = 0x%08X, length = 0xA\n", buffer );
	memset( buffer, 0xBB, 10 );
	bRet = WriteFile( hDevice, buffer, 10, &ulOperated, NULL);

	if ( bRet )
	{
		printf( "%d bytes Written to Device.\n", ulOperated );
	}
	else
	{
		printf("Invalid process of WriteFile\n");
	}

	return 0;
}
int main()
{

	if  ( do_read_device() )
	{
		printf( "   Read device ----> Fatal Error, stop\n");
	}

	if( do_write_device() )
	{
		printf( "   Write device ---> Fatal Error, stop\n");
	}

	getchar();
	getchar();

	return 0;
}