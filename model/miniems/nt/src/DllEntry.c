#include <windows.h>
#include "PWminimum.h"

extern PWresult omRuntimeInit();

BOOL WINAPI DllMain
(
   HINSTANCE hinstDLL, 
   DWORD fdwReason,
   LPVOID lpReserved
)
{
   int bSts = TRUE;
   PWresult result = 1;

   switch (fdwReason)
   {
      case DLL_PROCESS_ATTACH:   // a process is loading the Dll

	     result = omRuntimeInit();
	     if (!((result) & 1))
		    bSts = FALSE;

	  break;
   }

   return bSts;
}
  

