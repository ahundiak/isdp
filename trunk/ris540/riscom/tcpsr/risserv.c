/* Do not alter this SPC information: $Revision: 1.2.3.1 $ */
/*
**	NAME:							risserv.c
**	AUTHORS:						Grace Oliver
**	CREATION DATE:					7/93
**	ABSTRACT:		This is an RIS tcp/ip network daemon service
**					controller.
**
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <process.h>
/*
**	DEFINES
*/
/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define risserv_c
#include "risserv.prt"

/*
**	VARIABLES
*/

// this event is signalled when the
//  worker thread ends
//
HANDLE                  hServDoneEvent = NULL;
SERVICE_STATUS          ssStatus;       // current status of the service

SERVICE_STATUS_HANDLE   sshStatusHandle;
DWORD                   dwGlobalErr;
DWORD                   TID = 0;
HANDLE                  threadHandle = NULL;

//  declare the service threads:
//
extern VOID    service_main(DWORD dwArgc, LPTSTR *lpszArgv);
extern VOID    service_ctrl(DWORD dwCtrlCode);
static BOOL    ReportStatusToSCMgr(DWORD dwCurrentState,
                            DWORD dwWin32ExitCode,
                            DWORD dwCheckPoint,
                            DWORD dwWaitHint);
extern VOID    main_thread(VOID *notUsed);
static VOID    StopRIStcpsrService(LPTSTR lpszMsg);


/*
** return values for ISDKGetPlatform()
*/

#define IS_UNDEFINED    0          /* unknown    */
#define IS_NT31         1          /* WinNT 3.1  */
#define IS_DAYTONA      2          /* WinNT 3.5  */
#define IS_CHICAGO      3          /* Win95      */
#define IS_WIN32S       4          /* Win32s     */
#define IS_DAYTONA_351  5          /* WinNT 3.51 */
#define IS_NT40         6          /* WinNT 4.0  */


/****************************************************************************/
/*
**	FUNCTIONS
*/

/****************************************************************************/

//  main() --
//      all main does is call StartServiceCtrlDispatcher
//      to register the main service thread.  When the
//      API returns, the service has stopped, so exit.
//
//	For RIS development environment: RIStcpsrService must be
//		started with parameter string to indicate RISDIR c:\risdir
//

extern VOID main()
{
    SERVICE_TABLE_ENTRY dispatchTable[] = {
        { TEXT("RIStcpsrService"),
		  (LPSERVICE_MAIN_FUNCTION)service_main },
        { NULL, NULL }
    };

    if (!StartServiceCtrlDispatcher(dispatchTable)) {
        StopRIStcpsrService("StartServiceCtrlDispatcher failed.");
    }
}



//  service_main() --
//      this function takes care of actually starting the service,
//      informing the service controller at each step along the way.
//      After launching the worker thread, it waits on the event
//      that the worker thread will signal at its termination.
//
extern VOID service_main(
	 DWORD dwArgc,
	 LPTSTR *lpszArgv)
{
    DWORD                   dwWait;

    // register our service control handler:
    //
    sshStatusHandle = RegisterServiceCtrlHandler(
                                    TEXT("RIStcpsrService"),
                                    (LPHANDLER_FUNCTION)service_ctrl);

    if (!sshStatusHandle)
        goto cleanup;

    // SERVICE_STATUS members that don't change in example
    //
    ssStatus.dwServiceType = SERVICE_WIN32_OWN_PROCESS;
    ssStatus.dwServiceSpecificExitCode = 0;


    // report the status to Service Control Manager.
    //
    if (!ReportStatusToSCMgr(
        SERVICE_START_PENDING, // service state
        NO_ERROR,              // exit code
        1,                     // checkpoint
        3000))                 // wait hint
        goto cleanup;

    // create the event object. The control handler function signals
    // this event when it receives the "stop" control code.
    //
    hServDoneEvent = CreateEvent(
        NULL,    // no security attributes
        TRUE,    // manual reset event
        FALSE,   // not-signalled
        NULL);   // no name

    if (hServDoneEvent == (HANDLE)NULL)
        goto cleanup;

    // report the status to the service control manager.
    //
    if (!ReportStatusToSCMgr(
        SERVICE_START_PENDING, // service state
        NO_ERROR,              // exit code
        2,                     // checkpoint
        3000))                 // wait hint
        goto cleanup;

    // start the thread that performs the work of the service.
    //
    threadHandle = CreateThread(
                    NULL,       /* security attributes */
                    0,          /* stack size: 		   */
                                /* 0 means inherit parent's stack size */
                    (LPTHREAD_START_ROUTINE)main_thread,
                    NULL,       /* argument to thread */
                    0,          /* thread creation flags */
                    &TID);      /* pointer to thread ID */

    if (!threadHandle)
        goto cleanup;

                    
    // report the status to the service control manager.
    //
    if (!ReportStatusToSCMgr(
        SERVICE_RUNNING, // service state
        NO_ERROR,        // exit code
        0,               // checkpoint
        0))              // wait hint
        goto cleanup;

    // wait indefinitely until hServDoneEvent is signaled.
    //
    dwWait = WaitForSingleObject(
        hServDoneEvent,  // event object
        INFINITE);       // wait indefinitely

cleanup:

    if (hServDoneEvent != NULL)
        CloseHandle(hServDoneEvent);


    // try to report the stopped status to the service control manager.
    //
    if (sshStatusHandle != 0)
        (VOID)ReportStatusToSCMgr(
                            SERVICE_STOPPED,
                            dwGlobalErr,
                            0,
                            0);

    // When SERVICE MAIN FUNCTION returns in a single service
    // process, the StartServiceCtrlDispatcher function in
    // the main thread returns, terminating the process.
    //
    return;
}



//  service_ctrl() --
//      this function is called by the Service Controller whenever
//      someone calls ControlService in reference to our service.
//
extern VOID service_ctrl(
	DWORD dwCtrlCode)
{
    DWORD  dwState = SERVICE_RUNNING;

    // Handle the requested control code.
    //
    switch(dwCtrlCode) {

        // Pause the service if it is running.
        //
        case SERVICE_CONTROL_PAUSE:

            if (ssStatus.dwCurrentState == SERVICE_RUNNING) {
                SuspendThread(threadHandle);
                dwState = SERVICE_PAUSED;
            }
            break;

        // Resume the paused service.
        //
        case SERVICE_CONTROL_CONTINUE:

            if (ssStatus.dwCurrentState == SERVICE_PAUSED) {
                ResumeThread(threadHandle);
                dwState = SERVICE_RUNNING;
            }
            break;

        // Stop the service.
        //
        case SERVICE_CONTROL_STOP:

            dwState = SERVICE_STOP_PENDING;

            // Report the status, specifying the checkpoint and waithint,
            //  before setting the termination event.
            //
            ReportStatusToSCMgr(
                    SERVICE_STOP_PENDING, // current state
                    NO_ERROR,             // exit code
                    1,                    // checkpoint
                    3000);                // waithint

            SetEvent(hServDoneEvent);
            return;

        // Update the service status.
        //
        case SERVICE_CONTROL_INTERROGATE:
            break;

        // invalid control code
        //
        default:
            break;

    }

    // send a status response.
    //
    ReportStatusToSCMgr(dwState, NO_ERROR, 0, 0);
}






// utility functions...



// ReportStatusToSCMgr() --
//      This function is called by the ServMainFunc() and
//      ServCtrlHandler() functions to update the service's status
//      to the service control manager.
//
static BOOL ReportStatusToSCMgr(
                    DWORD dwCurrentState,
                    DWORD dwWin32ExitCode,
                    DWORD dwCheckPoint,
                    DWORD dwWaitHint)
{
    BOOL fResult;

    // Disable control requests until the service is started.
    //
    if (dwCurrentState == SERVICE_START_PENDING)
        ssStatus.dwControlsAccepted = 0;
    else
        ssStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP |
            SERVICE_ACCEPT_PAUSE_CONTINUE;

    // These SERVICE_STATUS members are set from parameters.
    //
    ssStatus.dwCurrentState = dwCurrentState;
    ssStatus.dwWin32ExitCode = dwWin32ExitCode;
    ssStatus.dwCheckPoint = dwCheckPoint;

    ssStatus.dwWaitHint = dwWaitHint;

    // Report the status of the service to the service control manager.
    //
    if (!(fResult = SetServiceStatus(
                sshStatusHandle,    // service reference handle
                &ssStatus))) {      // SERVICE_STATUS structure

        // If an error occurs, stop the service.
        //
        StopRIStcpsrService("SetServiceStatus");
    }
    return fResult;
}



// The StopRIStcpsrService function can be used by any thread to report 
//  an error, or stop the service.
//
static VOID StopRIStcpsrService(
	LPTSTR lpszMsg)
{
    CHAR    chMsg[256];
    HANDLE  hEventSource;
    LPTSTR  lpszStrings[2];
    DWORD   platform ;
    
    dwGlobalErr = GetLastError();

    platform = ISDKGetPlatform() ;
    
    /* TR#439601569 - Ignore this error on NT3.5 and NT3.5, the problem seems to be in the OS, because
       the problem is not seen on NT4.0. The code is a cut-and-paste from the samples
       program. */
    if ((dwGlobalErr == 1) && (platform == IS_DAYTONA || platform == IS_DAYTONA_351)) {
        return ;
    }
    
    // Use event logging to log the error.
    //
    hEventSource = RegisterEventSource(NULL,
                            TEXT("RIStcpsrService"));

    sprintf(chMsg, "RIStcpsrService error: %d", dwGlobalErr);
    lpszStrings[0] = chMsg;
    lpszStrings[1] = lpszMsg;

    if (hEventSource != NULL) {
        ReportEvent(hEventSource, // handle of event source
            EVENTLOG_ERROR_TYPE,  // event type
            0,                    // event category
            0,                    // event ID
            NULL,                 // current user's SID
            2,                    // strings in lpszStrings
            0,                    // no bytes of raw data
            lpszStrings,          // array of error strings
            NULL);                // no raw data

        (VOID) DeregisterEventSource(hEventSource);
    }

    // Set a termination event to stop SERVICE MAIN FUNCTION.
    //
    SetEvent(hServDoneEvent);
}

/*****************************************************************************

    SYNOPSIS

        INT ISDKGetPlatform

    PARAMETERS

        NAME          ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both
        ----          -------------------------------------------------------


    RETURN VALUE

	IS_NT31		   Program is running on Windows NT 3.1
	IS_DAYTONA	   Program is running on Windows NT 3.5 (Daytona)
    IS_DAYTONA_351 Program is running on Windows NT 3.51 (Daytona)
    IS_NT40        Program is running on Windows NT 4.0 (Shell Update Release)
	IS_CHICAGO	   Program is running on Windows 95 (Chicago)
	IS_WIN32S	   Program is running on Windows 3.1 with Win32s

	IS_WIN31       Program is running on Windows 3.1
	IS_WIN31_WOW   Program is running on Windows NT Win16 subsystem (WOW)
	IS_WIN31_CHI   Program is running on Windows 95 Win16 subsystem


    DESCRIPTION

        This function checks various information returned by GetVersion()
	to determine what platform you're running on.

    CHANGE HISTORY

        09/29/94    SCW		Initial version
        			(adapted from code written by RIS)

******************************************************************************/

static INT ISDKGetPlatform(
    )
{
    DWORD    win_vers;
    
#if defined(WIN16)
    char i;
#endif
    
#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__)
    /* program is being compiled for 32-bit */
    
    win_vers = GetVersion();
    if ( (win_vers & 0x80000000) == 0 ) {
	
        /* this is real Windows NT */

        if ( LOBYTE(LOWORD(win_vers)) == 3 ) {
            
            if ( HIBYTE(LOWORD(win_vers)) == 10 ) {

                return (IS_NT31);
            
            } else if ( HIBYTE(LOWORD(win_vers)) == 50 ) {

                return (IS_DAYTONA);

            } else /* if ( HIBYTE(LOWORD(win_vers)) ==  51 ) */ {

                return (IS_DAYTONA_351);

            }

        } else if ( LOBYTE(LOWORD(win_vers)) == 4 ) {

            /* if ( LOBYTE(LOWORD(win_vers)) == 0 ) { */

            return (IS_NT40);

        }
  
	} else {

	    if ( LOBYTE(LOWORD(win_vers)) < 4 ) {
		
		    /* this is Win32s running on 16-bit Windows 3.1,
		       because the program is running in 32-bit mode it
		       cannot easily determine the version of Win32s as
		       that info comes from a 16-bit DLL - good innit.
		       the program *could* work out the version, but it
		       would require a 16-bit DLL to thunk to, and that
		       just is not worth the effort. */

		    return(IS_WIN32S);

		} else {
		    
            /* this is Chicago - Windows 4.x */
		    
            return(IS_CHICAGO);
		}
	}

    /* end of 32-bit Windows code */
    
#else
    
    /* start of 16-bit Windows code */
    DWORD    win_flags;
    
    win_vers = GetVersion();
    win_flags = GetWinFlags();
    if( win_flags & WF_WINNT )
	{
	    /* Program is running on Windows NT using the
	       16-bit Windows on Windows emulation */
	    return(IS_WIN31_WOW);
	}
    else
	{
	    /* Program is running on real 16-bit Windows 3.1x - here,
	       the program can find out which version, if any, of Win32s
	       is available, and which particular build of Windows 3.1x
	       this really is */
	    
	    /* data for Win32s */
	    typedef    struct
		{
		    BYTE    major;
		    BYTE    minor;
		    WORD    build;
		    BOOL    debug;
		} WIN32SINFO, far *LPWIN32SINFO;
	    
	    /* data for Win32s */
	    HANDLE  h_win32s;		/* handle to Win32s library */
	    FARPROC getwin32s_info;	/* address of Win32s version function */
	    WIN32SINFO  win32s_info;	/* the Win32s version information */
	    char temp[ 1024 ];		 /* filled with Win32s version - if any */
	    
	    /* data for build identity */
	    HINSTANCE mod_handle; /* handle to Windows 3.1x USER module */
	    char bld_id[ 256 ]; /* space for build identity */
	    int bld_len; /* length of build identity string */
	    
	    /*disable "File Not Found" error box */
	    SetErrorMode( SEM_NOOPENFILEERRORBOX ); 
	    
	    /* this bit is a fiddle, but it is necessary because of Windows
	       for Workgroups 3.11, which reports its version number via the 
	       GetVersion() interface as 3.10 (stupid thing). However, the
	       build identity in Windows own USER module does contains the
	       correct information, so that is added.  The program uses
	       LoadLibrary so it can get a module instance.  This wil
	       increment the usage count, so the library is later free'd
	       to decrement it. */

	    if( ( mod_handle = LoadLibrary( USER_EXE ) ) == NULL ||
		(bld_len=LoadString(mod_handle,516,bld_id,sizeof(bld_id))== 0))
		{
            /* either the program did not get the instance handle or failed to
               get the string from the module, both of which are actually
	       *very* unlikely in the case of USER, but check anyway! */
            lstrcpy( bld_id, "(Unknown!)" );
        }
	    if( mod_handle != NULL )
		{
            /* it's a bit academic for USER, but the program does this properly
               and frees the library, thus decrementing the usage count */
            FreeLibrary( mod_handle );
        }
    
    /* now find out what (if any) version of Win32s is available */
    h_win32s = LoadLibrary( W32SYS_DLL ); /* try and load Win32s library */
    if( h_win32s > HINSTANCE_ERROR )
        {
            /* library loaded so get address of info function */
            getwin32s_info = GetProcAddress( h_win32s, "GETWIN32SINFO" );
            if( getwin32s_info )
		{
		    /* Win32s Version 1.1 or later installed */
		    if( !(*getwin32s_info)((LPWIN32SINFO)&win32s_info))
			{
			    wsprintf( temp, "Win32s Version %d.%d Build %d\n",
				      win32s_info.major,
				      win32s_info.minor,
				      win32s_info.build );
			}
		    else
			{
			    wsprintf( temp, "???" );
			}
		}
            else
		{
		    /* if no function then Win32s is version 1.0 */
		    wsprintf( temp, "Win32s version 1.0\n");
		}
            FreeLibrary( h_win32s );
        }
    else
        {
            /* no Win32s library */
        }
    i = bld_id[0];
    if (i =='4')
	return(IS_WIN31_CHI);
    else
	return(IS_WIN31);
}
/* end of 16-bit code */

#endif

}/* GetPlatform */


