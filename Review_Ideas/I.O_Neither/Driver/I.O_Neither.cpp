//
//    I.O_Neither.cpp
//
//    Buffered I/O
//
//    Nov 01, 2007, Done by Zhang Fan
//    09:20 AM, Aug 25, 2015, Modified by Mighten Dai<mighten.dai@gmail.com>
//
#include "Driver.h"

#pragma  PAGEDCODE
const wchar_t  dev_name[] = L"\\Device\\MyDDKDevice";
const wchar_t  sym_name[] = L"\\??\\HelloDDK";

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

////////////////////////////////////////////////////////////////////////////
//        Name:   HelloDDKWrite
// Description:  Driver read data from user buffer, app now is writing data
//  Parameters: -> pDevObj:  FDO
//              ->    pIrp:  IRP
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
NTSTATUS HelloDDKWrite(IN PDEVICE_OBJECT pDevObj, IN PIRP pIrp )
{
    NTSTATUS               status        = STATUS_SUCCESS; 
    PIO_STACK_LOCATION     stack         = IoGetCurrentIrpStackLocation(pIrp);
    PDEVICE_EXTENSION      pDevExt       = (PDEVICE_EXTENSION)pDevObj->DeviceExtension;
    ULONG                  ulWriteLength = stack->Parameters.Write.Length;
    UCHAR                 *pBuffer       = (UCHAR *)pIrp->UserBuffer;

    KdPrint(("\n\n\n-----------------------------------------------------------\n"));
	KdPrint((" - IRP: %s found in Write Routine\n",  GetNameOfIRP(stack->MajorFunction) ));
    KdPrint(("Write Routine now is reading data from User buffer:\n"));
    KdPrint((" with user_address = 0x%08X\n", pIrp->UserBuffer ));

    __try
    {
        ProbeForRead( pIrp->UserBuffer, ulWriteLength, 4 );

        // This statement will not execute if an exception triggered at preceding statement.
        pIrp->IoStatus.Information = ulWriteLength;

        //   Fall through, to interact with Ring 3's App
    }
    __except(EXCEPTION_EXECUTE_HANDLER)
    {
        KdPrint((" *** Failed, this memory block cannot be Read.\n"));
        status = STATUS_UNSUCCESSFUL;
        pIrp->IoStatus.Information = 0;
        goto    HelloDDKWrite_internal_label_common_exit;
    }

    ///////////////////////////////////////////////////////////
    //     Interact with Win32 Application
    //   Set the buffer that is used for Application to Write.
    // --> If no exception was triggered, then fall through,
    //     go here, to display the data the user sent.
    KdPrint(("Write Routine Received data from user:\n"));
    
    for ( ULONG i = 0; i < ulWriteLength; ++i )
    {
        KdPrint(("       Buffer[%02d] = 0x%X\n", i, (UCHAR)pBuffer[i] ));
    }

///////////////////////////////////////////////////////////////////
//
//                   Internal label for common exit.
//
//  ---> If the memory in user buffer is not readable,
//        then "fly" here with set the error flag,
//            to complete this IRP.
//  ---> Whereas, Routine's read mission was done,
//            finding nothing to do then, go there to exit. 
//
HelloDDKWrite_internal_label_common_exit:
    pIrp->IoStatus.Status = status;
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );
    KdPrint(("-----------------------------------------------------------\n\n\n"));
    return status;
}

////////////////////////////////////////////////////////////////////////////
//        Name:   HelloDDKRead
// Description:  Driver write data to user buffer, app now is reading data
//  Parameters: -> pDevObj:  FDO
//              ->    pIrp:  IRP
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
NTSTATUS HelloDDKRead(IN PDEVICE_OBJECT pDevObj, IN PIRP pIrp ) 
{
    PDEVICE_EXTENSION pDevExt = (PDEVICE_EXTENSION)pDevObj->DeviceExtension;
    NTSTATUS status = STATUS_SUCCESS;

    PIO_STACK_LOCATION stack = IoGetCurrentIrpStackLocation(pIrp);
    ULONG ulReadLength = stack->Parameters.Read.Length;
    ULONG ulReadOffset = (ULONG)stack->Parameters.Read.ByteOffset.QuadPart;

    KdPrint(("\n\n\n-----------------------------------------------------------\n"));
	KdPrint((" - IRP: %s found in Read Routine\n",  GetNameOfIRP(stack->MajorFunction) ));
    KdPrint(("Read Routine now is Writing data to User buffer:\n"));
    KdPrint((" with user_address = 0x%08X\n", pIrp->UserBuffer ));

    __try
    {
        // User reads Driver, or rather, Driver write data to user buffer.
        //  Maybe now lower 2GB memory are switched away due to Page Mechanism,
        //     and user buffer's address corresponding to a not exist memory location.
        ProbeForWrite( pIrp->UserBuffer, ulReadLength, 4 );

        // This statement will not execute if an exception triggered at preceding statement.
        memset( pIrp->UserBuffer, 0xAA, ulReadLength ); 
        pIrp->IoStatus.Information = ulReadLength;
    }
    __except(EXCEPTION_EXECUTE_HANDLER)
    {
        KdPrint((" *** Failed, data cannot be written to user buffer.\n"));
        status = STATUS_UNSUCCESSFUL;
        pIrp->IoStatus.Information = 0;
    }

    pIrp->IoStatus.Status = status;
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );
    KdPrint(("-----------------------------------------------------------\n\n\n"));
    return status;
}

////////////////////////////////////////////////////////////////////////////
//        Name:   HelloDDKUnload
// Description: Uninstall Driver
//  Parameters: -> pDriverObject:  Object passed from I/O Manager
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
#pragma PAGEDCODE
VOID HelloDDKUnload ( IN PDRIVER_OBJECT pDriverObject)
{
    PDEVICE_OBJECT    pNextObj = pDriverObject->DeviceObject;

    while ( pNextObj != NULL )
    {
        PDEVICE_EXTENSION pDevExt = (PDEVICE_EXTENSION)pNextObj->DeviceExtension;
        UNICODE_STRING    pLinkName = pDevExt->ustrSymLinkName;

		if (pDevExt->buffer)
		{
			ExFreePool(pDevExt->buffer);
			pDevExt->buffer = NULL;
		}

        IoDeleteSymbolicLink(&pLinkName);

        pNextObj = pNextObj->NextDevice;
        IoDeleteDevice( pDevExt->pDevice );
    }
	
	KdPrint(("# Driver removed.\n"));
}

////////////////////////////////////////////////////////////////////////////
//        Name:   CreateDevice
// Description: Initialize Device.
//  Parameters: -> pDriverObject:  Object passed from I/O Manager
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
#pragma INITCODE
NTSTATUS CreateDevice ( IN PDRIVER_OBJECT    pDriverObject) 
{
    NTSTATUS status;
    PDEVICE_OBJECT pDevObj;
    PDEVICE_EXTENSION pDevExt;

    UNICODE_STRING devName;
    RtlInitUnicodeString(&devName, dev_name );

    status = IoCreateDevice( pDriverObject,
                        sizeof(DEVICE_EXTENSION),
                        &(UNICODE_STRING)devName,
                        FILE_DEVICE_UNKNOWN,
                        0, TRUE,
                        &pDevObj );
    if (!NT_SUCCESS(status))
        return status;

    pDevExt = (PDEVICE_EXTENSION)pDevObj->DeviceExtension;
    pDevExt->pDevice = pDevObj;
    pDevExt->ustrDeviceName = devName;

    pDevExt->buffer = (PUCHAR)ExAllocatePool(PagedPool,MAX_FILE_LENGTH);
    pDevExt->file_length = 0;

    UNICODE_STRING symLinkName;
    RtlInitUnicodeString(&symLinkName, sym_name );
    pDevExt->ustrSymLinkName = symLinkName;
    status = IoCreateSymbolicLink( &symLinkName, &devName );
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
NTSTATUS HelloDDKDispatchRoutin(IN PDEVICE_OBJECT pDevObj,
                                 IN PIRP pIrp) 
{
    PIO_STACK_LOCATION stack = IoGetCurrentIrpStackLocation(pIrp);
    
    
    if (stack->MajorFunction >= 28 )  // MAX IRP types
    {
        KdPrint((" - Unknown IRP 0x%02X in Dispatch Routine, processed by default.\n", GetNameOfIRP(stack->MajorFunction) ));
    }
    else
    {
        KdPrint((" - IRP: %s found in Dispatch Routine, processed by default.\n",  GetNameOfIRP(stack->MajorFunction) ));
    }

    NTSTATUS status = STATUS_SUCCESS;

    pIrp->IoStatus.Status = status;
    pIrp->IoStatus.Information = 0;
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );

    return status;
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

    KdPrint(("# Driver Initialized.\n"));
    return status;
}