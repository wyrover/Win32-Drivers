//
//    MSR.cpp
//
//    Model Specific Register
//
//    Nov 01, 2007, Done by Zhang Fan
//    05:17 PM, Aug 25, 2015, Modified by Mighten Dai<mighten.dai@gmail.com>
//
#include "Driver.h"

typedef     unsigned int           DWORD;

#pragma    PAGEDCODE
const wchar_t  dev_name[] = L"\\Device\\MyDDKDevice";
const wchar_t  sym_name[] = L"\\??\\HelloDDK";

////////////////////////////////////////////////////////////////////////////
//    Constant definition of IOCTL ctl_codes.
//        Need support of Header File: NTDDK.h
//
//
//  #define CTL_CODE( DeviceType, Function, Method, Access ) (                 \
//        ((DeviceType) << 16) | ((Access) << 14) | ((Function) << 2) | (Method) \
//  )
//
const unsigned long  READ_MSR_REGISTER  = CTL_CODE( FILE_DEVICE_UNKNOWN,  0x800, METHOD_BUFFERED,   FILE_ANY_ACCESS );

////////////////////////////////////////////////////////////////////////////
//        Name:   GetNameOfIRP
// Description:  Get corresponding string when the IRP ID is given
// Description:  Get corresponding string when the IRP ID is given
//  Parameters: -> type: IRP ID
//      Return: character string's head address.
////////////////////////////////////////////////////////////////////////////
#pragma   PAGEDCODE
char   *GetNameOfIRP( ULONG type )
{
    static char* IRP[] = {
        "IRP_MJ_CREATE",
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






///////////////////////////////////////////////////////////////////////////////////
//                            D e b u g    C o d e s    (Begin)                  // 
///////////////////////////////////////////////////////////////////////////////////
#pragma    PAGEDCODE
//////////////////////////////////////////////
//    Function name:     do_dump_buffer
//    Parameter(s):      (unsigned char *)pBuffer, unsigned int length
//    return value:      0 indicate normally done. Otherwise abnormal.
int    do_dump_buffer(  unsigned char *pBuffer, unsigned int length )
{
	unsigned int    index;
	
	KdPrint(("Now dumping buffer with the given length as the byte order low to high.\n"));
	
	for ( index = 0; index < length; ++index )
	{
		KdPrint(("%02d indicate ----> 0x%02X", index, pBuffer[index] ));
	}
	
	return 0;
}

//////////////////////////////////////////////
//    Function name:     do_fill_buffer
//    Parameter(s):      (unsigned char *)pBuffer
//    return value:      0 indicate normally done. Otherwise abnormal.
int    do_fill_buffer(  unsigned char *pBuffer, unsigned int length )
{
	unsigned char model = 0x22;
	unsigned char  *p_target_char = (unsigned char *) pBuffer;
	
    for (unsigned int index = 0; index < length; ++index )
	{
		p_target_char[index] = model++;
	}
	return 0;
}
///////////////////////////////////////////////////////////////////////////////////
//                            D e b u g    C o d e s    (End)                    // 
///////////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////
//        Name:   HelloDDKDeviceIOControl
// Description:  Callee, controlled by Win32 DeviceIOControl
//  Parameters: -> pDevObj:  FDO
//              ->    pIrp:  IRP
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
#pragma     PAGEDCODE
NTSTATUS   HelloDDKDeviceIOControl(IN PDEVICE_OBJECT pDevObj, IN PIRP pIrp)
{
    PIO_STACK_LOCATION      stack = IoGetCurrentIrpStackLocation(pIrp);
    NTSTATUS   status     = STATUS_SUCCESS;
    ULONG      ctl_code   = stack->Parameters.DeviceIoControl.IoControlCode;

    ULONG      buffer_length_in   = stack->Parameters.DeviceIoControl.InputBufferLength;
    ULONG      buffer_length_out  = stack->Parameters.DeviceIoControl.OutputBufferLength;
	ULONG      test_INDEX;

	DWORD* InputBuffer  = (DWORD*)pIrp->AssociatedIrp.SystemBuffer;
    DWORD* OutputBuffer = (DWORD*)pIrp->AssociatedIrp.SystemBuffer;

    switch ( ctl_code )
    {   // process request
        case READ_MSR_REGISTER:
        {   //////////////////////////////////////////
            //     buffer manipulation.
			KdPrint(("Read Data.\n"));
			do_dump_buffer( (unsigned char *)InputBuffer, buffer_length_in );
			
			KdPrint(("Write Data.\n"));
			do_fill_buffer( (unsigned char *)OutputBuffer, buffer_length_out );
			
			KdPrint(("Test Data written.\n"));
			do_dump_buffer( (unsigned char *)OutputBuffer, buffer_length_out );
			
            pIrp->IoStatus.Information = buffer_length_out; // Bytes operated.
            break;
        }
    }

    // Complete IRP
    pIrp->IoStatus.Status = status;
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );
    return status;
}

////////////////////////////////////////////////////////////////////////////
//        Name:   HelloDDKUnload
// Description: Uninstall Driver
//  Parameters: -> pDriverObject:  Object passed from I/O Manager
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
#pragma     PAGEDCODE
VOID      HelloDDKUnload ( IN PDRIVER_OBJECT pDriverObject)
{
    PDEVICE_OBJECT    pNextObj = pDriverObject->DeviceObject;

    while ( pNextObj != NULL )
    {
        PDEVICE_EXTENSION     pDevExt =   (PDEVICE_EXTENSION)pNextObj->DeviceExtension;
        UNICODE_STRING        pLinkName = pDevExt->ustrSymLinkName;
        
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
#pragma     INITCODE
NTSTATUS     CreateDevice ( IN PDRIVER_OBJECT    pDriverObject) 
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

    pDevObj->Flags |= DO_DIRECT_IO;   // A little trick, but really don't care if it is Buffered I/O.
    pDevExt = (PDEVICE_EXTENSION)pDevObj->DeviceExtension;
    pDevExt->pDevice = pDevObj;
    pDevExt->ustrDeviceName = devName;

    pDevExt->buffer = (PUCHAR)ExAllocatePool(PagedPool,MAX_FILE_LENGTH);
    pDevExt->file_length = 0; // This file to be mimicked.

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
#pragma     PAGEDCODE
NTSTATUS HelloDDKDispatchRoutine(IN PDEVICE_OBJECT pDevObj, IN PIRP pIrp) 
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
extern "C" 
NTSTATUS      DriverEntry ( IN PDRIVER_OBJECT pDriverObject, IN PUNICODE_STRING pRegistryPath    )
{
    NTSTATUS status;

    pDriverObject->DriverUnload = HelloDDKUnload;
    pDriverObject->MajorFunction[IRP_MJ_READ] = 
    pDriverObject->MajorFunction[IRP_MJ_WRITE] = 
    pDriverObject->MajorFunction[IRP_MJ_CLEANUP] = 
    pDriverObject->MajorFunction[IRP_MJ_SET_INFORMATION] = 
    pDriverObject->MajorFunction[IRP_MJ_SHUTDOWN] = 
    pDriverObject->MajorFunction[IRP_MJ_SYSTEM_CONTROL] = 
    pDriverObject->MajorFunction[IRP_MJ_CREATE] = 
    pDriverObject->MajorFunction[IRP_MJ_CLOSE] = HelloDDKDispatchRoutine;

    pDriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = HelloDDKDeviceIOControl;

    status = CreateDevice(pDriverObject);

    KdPrint(("# Driver Initialized.\n"));
    return status;
}