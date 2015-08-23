//
//    Buffered_IO.cpp
//
//    Buffered I/O
//
//    Nov 01, 2007, Done by Zhangfan
//    09:00 AM, Aug 23, 2015, Modified by Mighten Dai<mighten.dai@gmail.com>
//
//
#include "Driver.h"

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
    RtlInitUnicodeString(&devName,L"\\Device\\MyDDKDevice");
    
    status = IoCreateDevice( pDriverObject,
                             sizeof(DEVICE_EXTENSION),
                             &(UNICODE_STRING)devName,
                             FILE_DEVICE_UNKNOWN,
                             0, TRUE,
                             &pDevObj );
    if (!NT_SUCCESS(status))
        return status;

    pDevObj->Flags |= DO_BUFFERED_IO;   // Buffered I/O
    pDevExt = (PDEVICE_EXTENSION)pDevObj->DeviceExtension;
    pDevExt->pDevice = pDevObj;
    pDevExt->ustrDeviceName = devName;

    UNICODE_STRING symLinkName;
    RtlInitUnicodeString(&symLinkName,L"\\??\\HelloDDK");
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
//        Name:   HelloDDKUnload
// Description: Uninstall Driver
//  Parameters: -> pDriverObject:  Object passed from I/O Manager
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
#pragma PAGEDCODE
VOID HelloDDKUnload ( IN PDRIVER_OBJECT pDriverObject) 
{
    PDEVICE_OBJECT    pNextObj;
    KdPrint(("Enter DriverUnload\n"));
    pNextObj = pDriverObject->DeviceObject;
    while (pNextObj != NULL) 
    {
        PDEVICE_EXTENSION pDevExt = (PDEVICE_EXTENSION)
            pNextObj->DeviceExtension;

        UNICODE_STRING pLinkName = pDevExt->ustrSymLinkName;
        IoDeleteSymbolicLink(&pLinkName);
        pNextObj = pNextObj->NextDevice;
        IoDeleteDevice( pDevExt->pDevice );
    }
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
	
	KdPrint(("Enter HelloDDKDispatchRoutin\n"));
    
	if (stack->MajorFunction >= 28 )  // Max IRP types
    {
        KdPrint((" - Unknown IRP, major type %X\n", GetNameOfIRP(stack->MajorFunction) ));
    }
    else
    {
        KdPrint(("\t%s\n",  GetNameOfIRP(stack->MajorFunction) ));
    }


    NTSTATUS status = STATUS_SUCCESS;

    pIrp->IoStatus.Status = status;
    pIrp->IoStatus.Information = 0;
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );

    KdPrint(("Leave HelloDDKDispatchRoutin\n"));

    return status;
}

NTSTATUS HelloDDKRead(IN PDEVICE_OBJECT pDevObj,
                                 IN PIRP pIrp) 
{
    NTSTATUS status = STATUS_SUCCESS;
    PIO_STACK_LOCATION stack = IoGetCurrentIrpStackLocation(pIrp);
    ULONG ulReadLength = stack->Parameters.Read.Length;
    
	KdPrint(("\t%s\n",  GetNameOfIRP(stack->MajorFunction) ));
    KdPrint(("Enter HelloDDKRead\n"));

	KdPrint(( "\t# Kernel Mode Buffer address = 0x%X\n", pIrp->AssociatedIrp.SystemBuffer ));

    ///////////////////////////////////////////////////////////
	//     Interact with Win32 Application
	//   Set the buffer that is used for Application to Read.
    memset( pIrp->AssociatedIrp.SystemBuffer, 0xAA, ulReadLength );

	pIrp->IoStatus.Status = status;
    pIrp->IoStatus.Information = ulReadLength;    // bytes operated.
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );

    KdPrint(("Leave HelloDDKRead\n"));
    return status;
}


NTSTATUS HelloDDKWrite(IN PDEVICE_OBJECT pDevObj,
                                 IN PIRP pIrp) 
{
    PIO_STACK_LOCATION     stack   = IoGetCurrentIrpStackLocation( pIrp );
	UCHAR                 *pBuffer = (UCHAR *) pIrp->AssociatedIrp.SystemBuffer;
	ULONG                  ulWriteLength = stack->Parameters.Write.Length;
	NTSTATUS               status        = STATUS_SUCCESS;
		
	KdPrint(("\t%s\n",  GetNameOfIRP(stack->MajorFunction) ));
    KdPrint(("Enter HelloDDKWrite\n"));

	KdPrint(( "\t# Kernel Mode Buffer address = 0x%X\n", pIrp->AssociatedIrp.SystemBuffer ));
    ///////////////////////////////////////////////////////////
	//     Interact with Win32 Application
	//   Set the buffer that is used for Application to Write.
	KdPrint(("===== The Message Get from Application ====="));
	for ( int i = 0; i < ulWriteLength; ++i )
	{
		KdPrint((" Buffer[%d] = 0x%X\n", i, (UCHAR)pBuffer[i] ));
	}
	KdPrint(("============================================"));

	pIrp->IoStatus.Status = status;
    pIrp->IoStatus.Information = ulWriteLength;    // bytes operated.
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );

    KdPrint(("Leave HelloDDKWrite\n"));

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
