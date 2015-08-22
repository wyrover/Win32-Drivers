//
//   File.cpp
//
//   The usage of file inside Driver.
//
//   History:
//     Nov 01, 2007,           begin           by Zhang Fan
//     03:00 PM, Aug 22, 2015, modified        by Mighten Dai<mighten.dai@gmail.com>
//
#include "Driver.h"

const wchar_t    path[] = L"\\??\\C:\\1.log";
//  "\\??\\C:\\1.log" is the same as "\\Device\\HarddiskVolume1\\1.LOG"

#pragma INITCODE
VOID CreateFileTest() 
{
    OBJECT_ATTRIBUTES    objectAttributes;
    IO_STATUS_BLOCK      iostatus;
    HANDLE               hfile;
    UNICODE_STRING       logFileUnicodeString;

    // Destination
    RtlInitUnicodeString( &logFileUnicodeString, path );


    InitializeObjectAttributes(&objectAttributes, 
                            &logFileUnicodeString,
                            OBJ_CASE_INSENSITIVE, 
                            NULL, 
                            NULL );

    NTSTATUS ntStatus = ZwCreateFile( &hfile, 
                            GENERIC_WRITE,
                            &objectAttributes, 
                            &iostatus, 
                            NULL,
                            FILE_ATTRIBUTE_NORMAL, 
                            FILE_SHARE_READ,
                            FILE_OPEN_IF, // Create, even if exist.
                            FILE_SYNCHRONOUS_IO_NONALERT, 
                            NULL, 
                            0 );

    if ( NT_SUCCESS(ntStatus) )
    {
        KdPrint(("Create file successfully!\n"));
    }else
    {
        KdPrint(("Create file  unsuccessfully!\n"));
    }

    // file ops
    //.......

    ZwClose(hfile);
}


#pragma INITCODE
VOID OpenFileTest2() 
{
    OBJECT_ATTRIBUTES objectAttributes;
    IO_STATUS_BLOCK iostatus;
    HANDLE hfile;
    UNICODE_STRING logFileUnicodeString;

    RtlInitUnicodeString( &logFileUnicodeString, path );

    InitializeObjectAttributes(&objectAttributes, 
                            &logFileUnicodeString,
                            OBJ_CASE_INSENSITIVE, 
                            NULL, 
                            NULL );

    NTSTATUS ntStatus = ZwOpenFile( &hfile, 
                            GENERIC_ALL,
                            &objectAttributes, 
                            &iostatus, 
                            FILE_SHARE_READ|FILE_SHARE_WRITE,
                            FILE_SYNCHRONOUS_IO_NONALERT);
    if ( NT_SUCCESS(ntStatus))
    {
        KdPrint(("Create file successfully!\n"));
    }else
    {
        KdPrint(("Create file  unsuccessfully!\n"));
    }

    // File ops
    //.......

    ZwClose(hfile);
}


#pragma INITCODE
VOID OpenFileTest1() 
{
    OBJECT_ATTRIBUTES objectAttributes;
    IO_STATUS_BLOCK iostatus;
    HANDLE hfile;
    UNICODE_STRING logFileUnicodeString;

    RtlInitUnicodeString( &logFileUnicodeString, path );

    InitializeObjectAttributes(&objectAttributes,
                            &logFileUnicodeString,
                            OBJ_CASE_INSENSITIVE, //Remain insensitive to case map 
                            NULL, 
                            NULL );

    NTSTATUS ntStatus = ZwCreateFile( &hfile, 
                            GENERIC_READ,
                            &objectAttributes, 
                            &iostatus, 
                            NULL,
                            FILE_ATTRIBUTE_NORMAL, 
                            FILE_SHARE_WRITE,
                            FILE_OPEN, // If not exist, return error.
                            FILE_SYNCHRONOUS_IO_NONALERT, 
                            NULL, 
                            0 );
    if ( NT_SUCCESS(ntStatus))
    {
        KdPrint(("Open file successfully!\n"));
    }else
    {
        KdPrint(("Open file  unsuccessfully!\n"));
    }

    //
    ZwClose(hfile);
}


#pragma INITCODE
VOID FileAttributeTest() 
{
    OBJECT_ATTRIBUTES   objectAttributes;
    IO_STATUS_BLOCK     iostatus;
    HANDLE              hfile;
    UNICODE_STRING      logFileUnicodeString;

    RtlInitUnicodeString( &logFileUnicodeString, path );

    InitializeObjectAttributes(&objectAttributes,
                            &logFileUnicodeString,
                            OBJ_CASE_INSENSITIVE,  //Remain insensitive to case map 
                            NULL, 
                            NULL );

    NTSTATUS ntStatus = ZwCreateFile( &hfile, 
                            GENERIC_READ,
                            &objectAttributes, 
                            &iostatus, 
                            NULL,
                            FILE_ATTRIBUTE_NORMAL, 
                            0,
                            FILE_OPEN, // return error when file is not exist
                            FILE_SYNCHRONOUS_IO_NONALERT, 
                            NULL, 
                            0 );
    if (NT_SUCCESS(ntStatus))
    {
        KdPrint(("open file successfully.\n"));
    }

    FILE_STANDARD_INFORMATION fsi;

	// Get file length
    ntStatus = ZwQueryInformationFile(hfile,
                                    &iostatus,
                                    &fsi,
                                    sizeof(FILE_STANDARD_INFORMATION),
                                    FileStandardInformation);
    if (NT_SUCCESS(ntStatus))
    {
        KdPrint(("file length:%u\n",fsi.EndOfFile.QuadPart));
    }
    
    // Modify current file pointer.
    FILE_POSITION_INFORMATION fpi;
    fpi.CurrentByteOffset.QuadPart = 100i64;
    ntStatus = ZwSetInformationFile(hfile,
                                &iostatus,
                                &fpi,
                                sizeof(FILE_POSITION_INFORMATION),
                                FilePositionInformation);
    if (NT_SUCCESS(ntStatus))
    {
        KdPrint(("update the file pointer successfully.\n"));
    }

    ZwClose(hfile);
}


#pragma INITCODE
VOID WriteFileTest() 
{
    OBJECT_ATTRIBUTES objectAttributes;
    IO_STATUS_BLOCK iostatus;
    HANDLE hfile;
    UNICODE_STRING logFileUnicodeString;

    RtlInitUnicodeString( &logFileUnicodeString, path );

    InitializeObjectAttributes(&objectAttributes,
                            &logFileUnicodeString,
                            OBJ_CASE_INSENSITIVE, //Remain insensitive to case map 
                            NULL, 
                            NULL );

    NTSTATUS ntStatus = ZwCreateFile( &hfile, 
                            GENERIC_WRITE,
                            &objectAttributes, 
                            &iostatus, 
                            NULL,
                            FILE_ATTRIBUTE_NORMAL, 
                            FILE_SHARE_WRITE,
                            FILE_OPEN_IF, // Create even if the file is exist
							
                            FILE_SYNCHRONOUS_IO_NONALERT, 
                            NULL, 
                            0 );
#define BUFFER_SIZE 1024
    PUCHAR pBuffer = (PUCHAR)ExAllocatePool(PagedPool,BUFFER_SIZE);

    RtlFillMemory(pBuffer,BUFFER_SIZE,0xAA);

    KdPrint(("The program will write %d bytes\n",BUFFER_SIZE));

    ZwWriteFile(hfile,NULL,NULL,NULL,&iostatus,pBuffer,BUFFER_SIZE,NULL,NULL);
    KdPrint(("The program really wrote %d bytes\n",iostatus.Information));

    RtlFillMemory(pBuffer,BUFFER_SIZE,0xBB);

    KdPrint(("The program will append %d bytes\n",BUFFER_SIZE));

    LARGE_INTEGER number;
    number.QuadPart = 1024i64; //Set file pointer.

    ZwWriteFile(hfile,NULL,NULL,NULL,&iostatus,pBuffer,BUFFER_SIZE,&number,NULL);
    KdPrint(("The program really appended %d bytes\n",iostatus.Information));

    ZwClose(hfile);

    ExFreePool(pBuffer);
}
#pragma INITCODE
VOID ReadFileTest() 
{
    OBJECT_ATTRIBUTES objectAttributes;
    IO_STATUS_BLOCK iostatus;
    HANDLE hfile;
    UNICODE_STRING logFileUnicodeString;


    RtlInitUnicodeString( &logFileUnicodeString, path );

    InitializeObjectAttributes(&objectAttributes,
                            &logFileUnicodeString,
                            OBJ_CASE_INSENSITIVE, //Remain insensitive to case map 
                            NULL, 
                            NULL );

    NTSTATUS ntStatus = ZwCreateFile( &hfile, 
                            GENERIC_READ,
                            &objectAttributes, 
                            &iostatus, 
                            NULL,
                            FILE_ATTRIBUTE_NORMAL, 
                            FILE_SHARE_READ,
                            FILE_OPEN, // Create even if the file is exist
                            FILE_SYNCHRONOUS_IO_NONALERT, 
                            NULL, 
                            0 );

    if (!NT_SUCCESS(ntStatus))
    {
        KdPrint(("The file is not exist!\n"));
        return;
    }

    FILE_STANDARD_INFORMATION fsi;
    
	// Get file length.
    ntStatus = ZwQueryInformationFile(hfile,
                                    &iostatus,
                                    &fsi,
                                    sizeof(FILE_STANDARD_INFORMATION),
                                    FileStandardInformation);

    KdPrint(("The program want to read %d bytes\n",fsi.EndOfFile.QuadPart));

    // Buffer
     PUCHAR pBuffer = (PUCHAR)ExAllocatePool(PagedPool,
                                (LONG)fsi.EndOfFile.QuadPart);

    ZwReadFile(hfile,NULL,
                NULL,NULL,
                &iostatus,
                pBuffer,
                (LONG)fsi.EndOfFile.QuadPart,
                NULL,NULL);
    KdPrint(("The program really read %d bytes\n",iostatus.Information));

    ZwClose(hfile);
    ExFreePool(pBuffer);
}
#pragma INITCODE
VOID FileTest() 
{
    CreateFileTest();

    OpenFileTest1();
//  OpenFileTest2(); // Option 2

    FileAttributeTest();

    // Write/Append
    WriteFileTest();

    ReadFileTest();

}

#pragma INITCODE
extern "C" NTSTATUS DriverEntry (
            IN PDRIVER_OBJECT pDriverObject,
            IN PUNICODE_STRING pRegistryPath    ) 
{
    NTSTATUS status;
    KdPrint(("Enter DriverEntry\n"));

    pDriverObject->DriverUnload = HelloDDKUnload;
    pDriverObject->MajorFunction[IRP_MJ_CREATE] = HelloDDKDispatchRoutine;
    pDriverObject->MajorFunction[IRP_MJ_CLOSE] = HelloDDKDispatchRoutine;
    pDriverObject->MajorFunction[IRP_MJ_WRITE] = HelloDDKDispatchRoutine;
    pDriverObject->MajorFunction[IRP_MJ_READ] = HelloDDKDispatchRoutine;

    status = CreateDevice(pDriverObject);

    FileTest();

    KdPrint(("DriverEntry end\n"));
    return status;
}

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

    pDevObj->Flags |= DO_BUFFERED_IO;
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

#pragma PAGEDCODE
VOID HelloDDKUnload (IN PDRIVER_OBJECT pDriverObject) 
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

#pragma PAGEDCODE
NTSTATUS HelloDDKDispatchRoutine(IN PDEVICE_OBJECT pDevObj,
                                 IN PIRP pIrp) 
{
    KdPrint(("Enter HelloDDKDispatchRoutine\n"));
    NTSTATUS status = STATUS_SUCCESS;

    pIrp->IoStatus.Status = status;
    pIrp->IoStatus.Information = 0;
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );
    KdPrint(("Leave HelloDDKDispatchRoutine\n"));
    return status;
}