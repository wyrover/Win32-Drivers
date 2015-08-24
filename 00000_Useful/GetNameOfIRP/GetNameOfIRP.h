//
//   GetNameOfIRP.h
//
//   Convert the IRP number to IRP char string.
//
//   *** This function ought to be located at PagedMemory or Non paged memory.
//         code_seg("INIT") will lose its data and crash when it is called.
//
//    08:18 PM, Aug 23, 2015, by Mighten Dai <mighten.dai@gmail.com>
//
#ifndef   MACRO_PROTECTION__INCLUDE__GetNameOfIRP_H__
#define   MACRO_PROTECTION__INCLUDE__GetNameOfIRP_H__

#pragma  code_seg("PAGE")
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
        "IRP_MJ_PNP"    };

	return IRP[type];
}
#endif    // #ifndef MACRO_PROTECTION__INCLUDE__GetNameOfIRP_H__