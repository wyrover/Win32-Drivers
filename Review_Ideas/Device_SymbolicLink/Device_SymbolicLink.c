/*
	Device_SymbolicLink.c
	Device & SymbolicLink Create/Delete demonstration.
	
	Mighten Dai<mighten.dai@gmail.com>
	08:56 AM, June 07, 2014
*/
#include <ntddk.h>

#pragma  code_seg("PAGE")
wchar_t  dev_name[] = L"\\Device\\MyDDKDevice";
wchar_t  sym_name[] = L"\\??\\MyDDKSymbolName";

#pragma       code_seg("INIT")
VOID Unload(IN PDRIVER_OBJECT DriverObject)
{
	// Definition.
	NTSTATUS			ntStatus;
	UNICODE_STRING		usSymbolicLinkName;
	PDEVICE_OBJECT		pDeviceObjectTemp1 = NULL;
	PDEVICE_OBJECT		pDeviceObjectTemp2 = NULL;
	
	// Initialization.
	RtlInitUnicodeString( &usSymbolicLinkName, sym_name );

	KdPrint(( "[Unload]: Unloading SymbolicLink."));

	// Unloading SymbolicLink...
	ntStatus = IoDeleteSymbolicLink( &usSymbolicLinkName );

	if ( NT_SUCCESS( ntStatus ) )
	{
		KdPrint(( "  Success: IoDeleteSymbolicLink, ntStatus = %d", ntStatus ));
	}
	else
	{
		KdPrint(( "  Failure: IoDeleteSymbolicLink, ntStatus = %d", ntStatus ));
	}
	
	if ( DriverObject )
	{
		pDeviceObjectTemp1 = DriverObject->DeviceObject;
		
		while ( pDeviceObjectTemp1 )
		{
			pDeviceObjectTemp2 = pDeviceObjectTemp1;
			pDeviceObjectTemp1 = pDeviceObjectTemp1->NextDevice;
			
			//it returns VOID !!!!
			KdPrint(( "   Info: Unloading Device, handle = %#x", pDeviceObjectTemp2 ));
			IoDeleteDevice( pDeviceObjectTemp2 );
		}
	}
	
	KdPrint(( " Program was Terminated."));
	
	return ;
}

#pragma    code_seg("INIT")
NTSTATUS DriverEntry( IN PDRIVER_OBJECT DriverObject, IN PUNICODE_STRING RegistryPath )
{
	// Definition.
	NTSTATUS			ntStatus;
	PDEVICE_OBJECT		pDeviceObject;
	UNICODE_STRING		usDeviceName;
	UNICODE_STRING		usSymbolicLinkName;
	
	// Initialization.
	DriverObject->DriverUnload = Unload;
	RtlInitUnicodeString( &usSymbolicLinkName, sym_name );
	RtlInitUnicodeString( &usDeviceName,       dev_name );

	// IoCreateDevice
	ntStatus = IoCreateDevice(
			DriverObject,
			0,
			&usDeviceName,
			FILE_DEVICE_UNKNOWN,
			0,
			FALSE,
			&pDeviceObject
	);
	
	if ( !NT_SUCCESS( ntStatus ) )
	{
		KdPrint(( "Failure: IoCreateDevice, ntStatus = %d", ntStatus ));
		return ntStatus;
	}
	
	KdPrint(( "Success: IoCreateDevice, ntStatus = %d", ntStatus ));
	KdPrint(( "        pDeviceObject = %#x", pDeviceObject ));
	
	// IoCreateSymbolicLink
	ntStatus = IoCreateSymbolicLink( &usSymbolicLinkName, &usDeviceName );
	
	if ( !NT_SUCCESS( ntStatus ) )
	{
		KdPrint(( "Failure: IoCreateSymbolicLink, ntStatus = %#x"));
		IoDeleteDevice( pDeviceObject );
		return ntStatus;
	}

	KdPrint(( "Success: IoCreateSymbolicLink, ntStatus = %d", ntStatus ));
	KdPrint(( "        usSymbolicLinkName = %wZ", &usSymbolicLinkName  ));

	pDeviceObject->Flags &= ~DO_DEVICE_INITIALIZING;
	
	KdPrint( ( "------------------------------") );
	
	return ntStatus;
}
