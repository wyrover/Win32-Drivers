// 
//     detect_kernel_debugger.cpp
//
//     Detect Kernel Debugger in Ring 3, and similar way in Ring0
//
//     Original Author: http://resources.infosecinstitute.com/introduction-to-kernel-debugging-with-windbg/
//

#include <stdio.h>
#include <windows.h>
//#include <Winternl.h>

#define STATUS_SUCCESS    ((NTSTATUS)0L)

enum SYSTEM_INFORMATION_CLASS { SystemKernelDebuggerInformation = 35 };

typedef long NTSTATUS;

typedef NTSTATUS  (__stdcall *ZW_QUERY_SYSTEM_INFORMATION)(IN SYSTEM_INFORMATION_CLASS SystemInformationClass,
                                                           IN OUT PVOID SystemInformation,
                                                           IN ULONG SystemInformationLength,
                                                           OUT PULONG ReturnLength);

typedef struct _SYSTEM_KERNEL_DEBUGGER_INFORMATION
{
    BOOLEAN DebuggerEnabled;
    BOOLEAN DebuggerNotPresent;

} SYSTEM_KERNEL_DEBUGGER_INFORMATION, *PSYSTEM_KERNEL_DEBUGGER_INFORMATION;


 
int main( int argc, char* argv[] ) 
{
    HANDLE                               hProcess = GetCurrentProcess();
    ZW_QUERY_SYSTEM_INFORMATION          ZwQuerySystemInformation;
    SYSTEM_KERNEL_DEBUGGER_INFORMATION   Info;
    
    __asm  int 3;

    /* load the ntdll.dll */
    HMODULE hModule = LoadLibrary( L"ntdll.dll" );
    ZwQuerySystemInformation = (ZW_QUERY_SYSTEM_INFORMATION)GetProcAddress(hModule, "ZwQuerySystemInformation");
    
	if( NULL  == ZwQuerySystemInformation )
	{
        printf("Error: could not find the function ZwQuerySystemInformation in library ntdll.dll.");
        exit(-1);
    }

    printf("ZwQuerySystemInformation is located at 0x%08x in ntdll.dll.\n", (unsigned int)ZwQuerySystemInformation );
 
    if ( STATUS_SUCCESS == ZwQuerySystemInformation( SystemKernelDebuggerInformation, &Info, sizeof(Info), NULL )   ) 
	{
            if ( Info.DebuggerEnabled && !Info.DebuggerNotPresent )
			{
                printf("System debugger is present.");
            }
            else
			{
                printf("System debugger is not present.");
            }
    }
 
     /* wait */
    getchar();
 
     return 0;
}