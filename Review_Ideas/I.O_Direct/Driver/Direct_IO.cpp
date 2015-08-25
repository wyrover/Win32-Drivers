//
//  Driver.cpp
//  TestBench on Legacy VC6
//
//  History:
//     Begin:  Nov 01, 2007, by Zhang Fan
//     Change: 01:49 PM, Aug 24, 2015, by Mighten Dai <mighten.dai@gmail.com>
//
#include "Driver.h"

#pragma PAGEDCODE
wchar_t        dev_name[] = L"\\Device\\MyDDKDevice";
wchar_t   symbolic_name[] = L"\\??\\HelloDDK";

//////////////////////////////////////////////////////
//   Get IRP name.
//////////////////////////////////////////////////////
#pragma PAGEDCODE
char   *GetNameOfIRP( ULONG type )
{
    static char* IRP[] = 
    {   "IRP_MJ_CREATE",
        "IRP_MJ_CREATE_NAMED_PIPE",
        "IRP_MJ_CLOSE",
        "IRP_MJ_READ",
        "IRP_MJ_WRITE",
        "IRP_MJ_QUERY_INFORMATION",
        "IRP_MJ_SET_INFORMATION",
        "IRP_MJ_QUERY_EA",
        "IRP_MJ_SET_EA",
        "IRP_MJ_FLUSH_BUFFERS",
        "IRP_MJ_QUERY_VOLUME_INFORMATION",
        "IRP_MJ_SET_VOLUME_INFORMATION",
        "IRP_MJ_DIRECTORY_CONTROL",
        "IRP_MJ_FILE_SYSTEM_CONTROL",
        "IRP_MJ_DEVICE_CONTROL",
        "IRP_MJ_INTERNAL_DEVICE_CONTROL",
        "IRP_MJ_SHUTDOWN",
        "IRP_MJ_LOCK_CONTROL",
        "IRP_MJ_CLEANUP",
        "IRP_MJ_CREATE_MAILSLOT",
        "IRP_MJ_QUERY_SECURITY",
        "IRP_MJ_SET_SECURITY",
        "IRP_MJ_POWER",
        "IRP_MJ_SYSTEM_CONTROL",
        "IRP_MJ_DEVICE_CHANGE",
        "IRP_MJ_QUERY_QUOTA",
        "IRP_MJ_SET_QUOTA",
        "IRP_MJ_PNP" };

    return IRP[type];
}

//////////////////////////////////////////////////////////////////////////
//                    HelloDDKRead
//////////////////////////////////////////////////////////////////////////
#pragma PAGEDCODE
NTSTATUS HelloDDKRead(IN PDEVICE_OBJECT pDevObj, IN PIRP pIrp) 
{
    PDEVICE_EXTENSION    pDevExt = (PDEVICE_EXTENSION)pDevObj->DeviceExtension;
    NTSTATUS             status = STATUS_SUCCESS;
    PIO_STACK_LOCATION   stack = IoGetCurrentIrpStackLocation(pIrp);
    ULONG                ulReadLength = stack->Parameters.Read.Length;

    ULONG mdl_length  = MmGetMdlByteCount(pIrp->MdlAddress);
    PVOID mdl_address = MmGetMdlVirtualAddress(pIrp->MdlAddress);
    ULONG mdl_offset  = MmGetMdlByteOffset(pIrp->MdlAddress);

    KdPrint(("\t%s\n", GetNameOfIRP(stack->MajorFunction) ));
    KdPrint(("Enter HelloDDKRead\n"));
    KdPrint(("ulReadLength:%d\n",ulReadLength));

    KdPrint(("mdl_address:0X%08X\n",mdl_address));
    KdPrint(("mdl_length:%d\n",mdl_length));
    KdPrint(("mdl_offset:%d\n",mdl_offset));

    if (mdl_length!=ulReadLength)
    {
        // the length of MDL ought to be equal to the size read, or this ops is supposed to be marked  unsuccessful.
        pIrp->IoStatus.Information = 0;
        status = STATUS_UNSUCCESSFUL;
    }
	// Get the Map of MDL in Kernel Mode by using   MmGetSystemAddressForMdlSafe
    PVOID kernel_address = MmGetSystemAddressForMdlSafe(pIrp->MdlAddress,NormalPagePriority);
    KdPrint(("kernel_address:0x%08X\n",kernel_address));
    
	///////////////////////////////////////////////////////////
    //     Interact with Win32 Application
    //   Set the buffer that is used for Application to Write.
    memset( kernel_address, 0xAA, ulReadLength );
	
    pIrp->IoStatus.Information = ulReadLength;    // bytes operated    
    pIrp->IoStatus.Status = status;    
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );
    KdPrint(("Leave HelloDDKRead\n"));

    return status;
}

//////////////////////////////////////////////////////////////////////////
//                    HelloDDKWrite
//////////////////////////////////////////////////////////////////////////
#pragma PAGEDCODE
NTSTATUS HelloDDKWrite(IN PDEVICE_OBJECT pDevObj,
                                 IN PIRP pIrp) 
{
    NTSTATUS             status = STATUS_SUCCESS;
    PDEVICE_EXTENSION    pDevExt = (PDEVICE_EXTENSION)pDevObj->DeviceExtension;
    PIO_STACK_LOCATION   stack = IoGetCurrentIrpStackLocation(pIrp);
    ULONG                ulWriteLength = stack->Parameters.Write.Length;
    
    ULONG mdl_length  = MmGetMdlByteCount(pIrp->MdlAddress);
    PVOID mdl_address = MmGetMdlVirtualAddress(pIrp->MdlAddress);
    ULONG mdl_offset  = MmGetMdlByteOffset(pIrp->MdlAddress);
	
	// Get the Map of MDL in Kernel Mode by using   MmGetSystemAddressForMdlSafe
    PVOID   kernel_address = MmGetSystemAddressForMdlSafe( pIrp->MdlAddress, NormalPagePriority ); 
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//   !!! Caution !!!
	//   Even if it is the same effect with mdl_address ops,
	//     considering the the whole system's safety & stability, please use "MmGetSystemAddressForMdlSafe" additionally,
	//           rather than only use "MmGetMdlVirtualAddress" alone.
	//
	char    *pBuffer = (char *) kernel_address;

    KdPrint(("\t%s\n", GetNameOfIRP(stack->MajorFunction) ));
    KdPrint(("Enter HelloDDKWrite\n"));
    KdPrint(("ulWriteLength:%d\n",ulWriteLength));
    KdPrint(("mdl_address:0x%08X\n",mdl_address));
    KdPrint(("mdl_length:%d\n",mdl_length));
    KdPrint(("mdl_offset:%d\n",mdl_offset));

    if ( mdl_length != ulWriteLength)
    {
        // the length of MDL ought to be equal to the size read, or this ops is supposed to be marked  unsuccessful.
        pIrp->IoStatus.Information = 0;
        status = STATUS_UNSUCCESSFUL;
    }

	////////////////////////////////////////////////////////////////////////////////
	//     ----->  Hidden Bug
	//  Better to use    "kernel_address"   rather than use      "mdl_address"
    KdPrint(("kernel_address:0x%08X\n",kernel_address));

    ///////////////////////////////////////////////////////////
    //     Interact with Win32 Application
    //   Set the buffer that is used for Application to Write.
    KdPrint(("===== The Message Get from Application =====\n"));
    for ( ULONG i = 0; i < ulWriteLength; ++i )
    {
        KdPrint((" Buffer[%d] = 0x%02X\n", i, (UCHAR)pBuffer[i]  ));
    }
    KdPrint(("============================================\n"));

    pIrp->IoStatus.Information = ulWriteLength;    // bytes operated
    pIrp->IoStatus.Status = status;    
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );
    KdPrint(("Leave HelloDDKWrite\n"));

    return status;
}

////////////////////////////////////////////////////////////////////////////
//        Name:   CreateDevice
// Description: Initialize Device.
//  Parameters: -> pDriverObject:  Object passed from I/O Manager
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
#pragma INITCODE
NTSTATUS CreateDevice (
        IN PDRIVER_OBJECT    pDriverObject) 
{
    NTSTATUS status;
    PDEVICE_OBJECT pDevObj;
    PDEVICE_EXTENSION pDevExt;
    
    UNICODE_STRING devName;
    RtlInitUnicodeString( &devName, dev_name );
    
    status = IoCreateDevice( pDriverObject,
                        sizeof(DEVICE_EXTENSION),
                        &(UNICODE_STRING)devName,
                        FILE_DEVICE_UNKNOWN,
                        0, TRUE,
                        &pDevObj );
    if (!NT_SUCCESS(status))
        return status;

    pDevObj->Flags |= DO_DIRECT_IO;
    pDevExt = (PDEVICE_EXTENSION)pDevObj->DeviceExtension;
    pDevExt->pDevice = pDevObj;
    pDevExt->ustrDeviceName = devName;

    // Allocate the size of file imitated 
    pDevExt->buffer = (PUCHAR)ExAllocatePool( PagedPool, MAX_FILE_LENGTH );

    // set size.
    pDevExt->file_length = 0;

    UNICODE_STRING symLinkName;
    RtlInitUnicodeString(&symLinkName, symbolic_name );
    
	pDevExt->ustrSymLinkName = symLinkName;
    status = IoCreateSymbolicLink( &symLinkName,&devName );
    if (!NT_SUCCESS(status)) 
    {
        IoDeleteDevice( pDevObj );
        return status;
    }
    return STATUS_SUCCESS;
}

////////////////////////////////////////////////////////////////////////////
//        Name: HelloDDKDispatchRoutine
// Description: Deal with IRP(I/O Request Package)
//  Parameters: -> pDevObj:  FDO
//              ->    pIrp:  IRP
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
#pragma PAGEDCODE
NTSTATUS HelloDDKDispatchRoutin(IN PDEVICE_OBJECT pDevObj, IN PIRP pIrp ) 
{
    NTSTATUS status = STATUS_SUCCESS;
    KdPrint(("Enter HelloDDKDispatchRoutin\n"));

    PIO_STACK_LOCATION stack = IoGetCurrentIrpStackLocation(pIrp);

    if (stack->MajorFunction >= 28 )
    {
        KdPrint((" - Unknown IRP, major type %X\n", stack->MajorFunction ));
    }
    else
    {
        KdPrint(("\t%s\n", GetNameOfIRP(stack->MajorFunction) ));
    }

    pIrp->IoStatus.Status = status;
    pIrp->IoStatus.Information = 0;    // bytes operated.
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );

    KdPrint(("Leave HelloDDKDispatchRoutin\n"));

    return status;
}
////////////////////////////////////////////////////////////////////////////
//        Name:   HelloDDKUnload
// Description: Uninstall Driver
//  Parameters: -> pDriverObject:  Object passed from I/O Manager
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
#pragma PAGEDCODE
VOID HelloDDKUnload ( IN PDRIVER_OBJECT pDriverObject ) 
{
	PDEVICE_OBJECT	    pNextObj = pDriverObject->DeviceObject;
	KdPrint(("Enter DriverUnload\n"));

	while (pNextObj != NULL) 
	{
		PDEVICE_EXTENSION pDevExt = (PDEVICE_EXTENSION) pNextObj->DeviceExtension;

		if ( pDevExt->buffer )
		{
			ExFreePool( pDevExt->buffer );
			pDevExt->buffer = NULL;
		}

		UNICODE_STRING pLinkName = pDevExt->ustrSymLinkName;
		IoDeleteSymbolicLink(&pLinkName);
		pNextObj = pNextObj->NextDevice;
		IoDeleteDevice( pDevExt->pDevice );
	}
}

////////////////////////////////////////////////////////////////////////////
//        Name:   DriverEntry
// Description: Initialize Driver, locate & apply the hardware resource(s),
//                and also create the kernel object.
//  Parameters: -> pDriverObject:  Object passed from I/O Manager
//              -> pRegistryPath:  The Driver's path in Registry
//      Return: Driver's status.
//  *** NOTE that: Without extern "C", the compiler would trigger an LINK-time error.
////////////////////////////////////////////////////////////////////////////
#pragma INITCODE
extern "C" NTSTATUS DriverEntry (
            IN PDRIVER_OBJECT pDriverObject,
            IN PUNICODE_STRING pRegistryPath    ) 
{
    NTSTATUS status;
    KdPrint(("Enter DriverEntry\n"));

    pDriverObject->DriverUnload = HelloDDKUnload;
    pDriverObject->MajorFunction[IRP_MJ_READ] = HelloDDKRead;
    pDriverObject->MajorFunction[IRP_MJ_WRITE] = HelloDDKWrite;

    pDriverObject->MajorFunction[IRP_MJ_CLEANUP] = 
    pDriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = 
    pDriverObject->MajorFunction[IRP_MJ_SET_INFORMATION] = 
    pDriverObject->MajorFunction[IRP_MJ_SHUTDOWN] = 
    pDriverObject->MajorFunction[IRP_MJ_SYSTEM_CONTROL] = 
    pDriverObject->MajorFunction[IRP_MJ_CREATE] = 
    pDriverObject->MajorFunction[IRP_MJ_CLOSE] = HelloDDKDispatchRoutin;
    
    status = CreateDevice(pDriverObject);

    KdPrint(("Leave DriverEntry\n"));
    return status;
}