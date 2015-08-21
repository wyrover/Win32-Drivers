/*
//  SEH.cpp
//
//  Demonstrate the usage of 
//     -> __try{}__except{}
//     -> __try{}__finally{}
//
//  **** I have no idea how to test  __try(...) __except(EXCEPTION_CONTINUE_SEARCH) {...}
//                                   __try(...) __except(EXCEPTION_CONTINUE_EXECUTION) {...}
//                                    For later addition.
//  **** The SEH mechanism was implemented by OS rather than VS compiler.
//              See the extension folder for further message.
//
//   This folder is designed for both cmd line and VS IDE compilation.
//
//   Begin:  10:52 AM, Aug 21, 2015, by Mighten Dai<mighten.dai@gmail.com>
*/
#include <ntddk.h>	

///////////////////////////////////////////////////////////////////////////
/////////
/////////   Test  __try(...) __except(EXCEPTION_CONTINUE_EXECUTION) {...}
/////////
///////int   ProbeReading_redo( void )
///////{
///////	unsigned int  pointer = 0x80000000;
///////
///////	KdPrint(("Enter ProbeReading_redo( ) routine "));
///////
///////	__try
///////	{
///////		KdPrint(("     Enter __try block"));
///////		
///////		KdPrint(("     Leave __try block"));
///////	}
///////	__except( EXCEPTION_CONTINUE_EXECUTION )
///////	{
///////		KdPrint(("     Enter __except block"));
///////		pointer -= 0x200;
///////		KdPrint(("       Decrease by 512Bytes, or 0x200"));
///////		KdPrint(("     Leave __except block"));
///////		KdPrint(("     Restarting the preceding code.."));
///////	}
///////
///////	KdPrint(("The readable address = 0x%X", pointer ) );
///////	
///////	KdPrint(("Leave ProbeReading_redo( ) routine "));
///////	return STATUS_SUCCESS;
///////}


////////////////////////////////////////////////////////////////////
//
//   test  __try(...) __except(EXCEPTION_EXECUTE_HANDLER) {...}
//         __try(...) __finally {...}
//
int    test_read( void )
{
	VOID   *pointer = (void *)0x80000000;

	KdPrint(("Enter test_read( ) routine "));
	
	__try
	{
		KdPrint(("     Enter __try block"));
		ProbeForRead( pointer, 1, 4); // Throw an exception, due to ProbeForRead, read NULL, 1 byte, DWORD-alignment.
		KdPrint(("     Leave __try block"));
	}
	__except( EXCEPTION_EXECUTE_HANDLER ) // Once the handler is done, the program will never cause the preceding instruction's being restarted.
	{
		KdPrint(("     Enter __except block"));
		KdPrint(("     Leave __except block"));
	}

	__try
	{
		return 0;
	}
	__finally
	{
		KdPrint(("Leave test_read( ) routine "));
	}
	
	return 0;
}

////////////////////////////////////////////////////////////////////
//
//
NTSTATUS DriverEntry( IN PDRIVER_OBJECT DriverObject, IN PUNICODE_STRING RegistryPath )
{
	KdPrint(("Begin Demonstration"));
	
	//  #1
	KdPrint( ("#1: Probe for reading NULL pointer") );
	test_read();

	// #2
	KdPrint( ("#2: Test readable address below 0x80000000"));
//	ProbeReading_redo();
	
	KdPrint(("End   Demonstration"));

	return STATUS_SUCCESS;
}