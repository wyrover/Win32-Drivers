/*
	sysThread.c
	System thread creating demonstration.
	
	Mighten Dai<mighten.dai@gmail.com>
	June 08, 2014 15:08
*/
#include <ntddk.h>

static	KEVENT	s_event;

//////////////////////////////////////////////////
//		The module to make Sleep in Kernel easier.
//////////////////////////////////////////////////
#pragma   code_seg("PAGE")
VOID	MySleep( LONG msec )
{
#define		DELAY_ONE_MICROSECOND	(-10)
#define		DELAY_ONE_MILLISECOND	( DELAY_ONE_MICROSECOND * 1000 )

	LARGE_INTEGER	My_int;
	
	////////////////////////
	// Converting of time //
	////////////////////////
	My_int.QuadPart = DELAY_ONE_MILLISECOND;
	My_int.QuadPart *= msec;
	KeDelayExecutionThread( KernelMode, 0, &My_int );
}

#pragma   code_seg("PAGE")
VOID MyThread( IN PVOID pContext )
{
	PEPROCESS	EPROCESSPROTECT;
	PTSTR		ProcessName;

	KdPrint(( "Success: the new thread is running."));

	KdPrint((" I wanna get the information, by struct PRPROCESS"));
	
	EPROCESSPROTECT = IoGetCurrentProcess();
	
	// The details of struct PEPROCESS is now republic,
	//   if you wanna get ProcessName,
	//     Can only use this.
	ProcessName 	=  (PTSTR)((ULONG)EPROCESSPROTECT + 0x174 );
	
	KdPrint(("    Its address = %#x", EPROCESSPROTECT));
	KdPrint(("     Process Name = %s", ProcessName ));

	///////////////////////////////
	// Sleeping in the kernle.....
	///////////////////////////////
	KdPrint((" Starting Sleeping in Kernel for 5 seconds..."));
	
	MySleep(1000*5);

	// Set false, notify main thread to exit.
	KdPrint(( "Now, sub-thread over, starting KeSetEvent..."));
	KeSetEvent( &s_event, 0, TRUE );
		
	KdPrint(( "Terminating this thread."));

	// Thread cannot stop by return,
	// MUST PsTerminateSystemThread !!!
	PsTerminateSystemThread(0);
}

#pragma code_seg("INIT")
VOID Unload(IN PDRIVER_OBJECT DriverObject)
{
}

#pragma code_seg("INIT")
NTSTATUS DriverEntry( IN PDRIVER_OBJECT DriverObject, IN PUNICODE_STRING RegistryPath )
{
	// Definition.
	HANDLE		hMyThread;
	
	// Initialization.
	DriverObject->DriverUnload = Unload;

	//////////////////////////////
	// Creating a new thread.  ///
	//////////////////////////////
	KdPrint(("Doing: PsCreateSystemThread  Creating the new thread."));
	
	PsCreateSystemThread(
		&hMyThread,
		0,
		NULL,
		NULL, // System Thread.
		NULL,
		MyThread,
		NULL
		);
		
	KdPrint(("Doing: KeInitializeEvent  Initizlizing the event."));
	KeInitializeEvent( &s_event, SynchronizationEvent, FALSE);
		
	KdPrint(("Doing: KeWaitForSingleObject, waiting for the end. " ));
	
	// Because we initialized the Event is true,
	// unless it was set False, won't stop waiting.
	KeWaitForSingleObject( &s_event, Executive, KernelMode, 0, 0);

	// The following statement is used to tell the debugger:
	// Sub-thread has exit, KeWaitForSingleObject over.
	KdPrint(("Doing: KeWaitForSingleObject, Sub-thread has exit, KeWaitForSingleObject over. " ));

	return STATUS_SUCCESS;
}
