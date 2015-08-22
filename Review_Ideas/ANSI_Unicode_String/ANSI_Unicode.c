/*
	ANSI_Unicode.c
	Kernel mode ANSI/Unicode string

	Mighten Dai<mighten.dai@gmail.com>
	01:14 PM, June 06, 2014
*/
#include <ntddk.h>

#define		BUFFER_SIZE		256

VOID Unload(IN PDRIVER_OBJECT DriverObject)
{
}

BOOLEAN	compare( UNICODE_STRING *p_us1, UNICODE_STRING *p_us2, BOOLEAN CaseInSensitive )
{
	return (BOOLEAN) RtlCompareUnicodeString( p_us1, p_us2, CaseInSensitive );
}



NTSTATUS DriverEntry( IN PDRIVER_OBJECT DriverObject, IN PUNICODE_STRING RegistryPath )
{
	NTSTATUS		nsAppendStatus;
	UNICODE_STRING	usSrc;
	UNICODE_STRING	usDes;
	UNICODE_STRING  usInteger;
	ULONG    ulInteger;
	STRING   anString;

	KdPrint(("Demonstration Begin"));
	RtlInitUnicodeString( &usSrc, L"Hello, the kernel mode string need copied.");
	KdPrint(( "Source: %wZ", &usSrc ));
	
	// Applying the PagePool	//	what will be returned if it fail to allocate ?	
	usDes.Buffer = ( PWSTR ) ExAllocatePool( PagedPool, BUFFER_SIZE ); // crash if not allocate.
	usDes.MaximumLength = BUFFER_SIZE;

	//   # 1 Copy string
	// Copying string from source to Destination
	RtlCopyUnicodeString( &usDes, &usSrc );
	KdPrint(( "#1 Copy:  Dest..: %wZ", &usDes ));

	//  #2 Append
	nsAppendStatus = RtlAppendUnicodeToString( &usDes, L"|||Oh, I was appended..." );
	KdPrint(( "#1 Append: %wZ", &usDes ));

	if ( STATUS_BUFFER_TOO_SMALL == nsAppendStatus )
	{
			KdPrint(("! Error: Driver requires a larger Buffer !"));
	}
	
	//  #3  Compare
	// Compare two Driver's Unicode string.
	if ( 0 == compare( &usDes, &usSrc, FALSE ) )
	{
		KdPrint(( "#3 Compare: These are same Unicode string without caps verify."));
	}
	else if ( 0 == compare( &usDes, &usSrc, TRUE) )
	{
		KdPrint(( "#3 Compare: These are same Unicode string with caps verify."));
	}
	else
	{
		KdPrint(("#3 Compare: These are different strings actually."));
	}

	// #4  Convert from Unicode string to Integer
	RtlInitUnicodeString( &usInteger, L"12345");
	RtlUnicodeStringToInteger( &usInteger, 10, &ulInteger );
	KdPrint(("#4 Convert: %wZ => %u\n", &usInteger, ulInteger));
	RtlIntegerToUnicodeString( 10240, 10, &usDes );
	KdPrint(("   Convert: 10240 => %wZ\n", &usDes ));

	// #5  Upper-case all the characters.
	KdPrint(("#5 Upper-case all the characters" ));
	KdPrint(("   Before: %wZ", &usSrc ));
	RtlUpcaseUnicodeString( &usDes, &usSrc, FALSE );  // FALSE = Not auto-allocate memory space.
	KdPrint(("   After: %wZ", &usDes ));
//	KdPrint(("#5 Down-case  all the characters" ));
//	KdPrint(("   Before: %wZ", &usSrc ));
//	RtlDowncaseUnicodeString(&usDes, &usSrc, FALSE);
//	KdPrint(("   After: %wZ", &usDes ));

	// #6  Convert between ANSI_string & Unicode String.
	KdPrint(("#6 Initialize the ANSI string." ));
	RtlInitAnsiString( &anString, "ANSI target string.                                       " );
	KdPrint(("   Before ANSI = %Z", &anString ));
	KdPrint(("   Before ANSI = %wZ", &usDes ));
	RtlAnsiStringToUnicodeString( &usDes, &anString, FALSE );// FALSE indicate there is necessity to allocate for Destination.
	KdPrint(("   After ANSI to Unicode" ));
	KdPrint(("      Get Unicode = %wZ", &usDes ));
	KdPrint(("   After Unicode to ANSI" ));
	RtlUnicodeStringToAnsiString( &anString, &usSrc, FALSE );
	KdPrint(("      Get ANSI = %Z", &anString ));
	
	
	// Release the PagePool
	RtlFreeUnicodeString( &usDes );

	DriverObject->DriverUnload = Unload;

	KdPrint(("Demonstration Over"));
	return STATUS_SUCCESS;
}