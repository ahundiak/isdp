/* Do not alter this SPC information: $Revision: 1.2.28.1 $ */
/********************************************************************
Name:				gcortns.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Misc Gui Functions

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <string.h>
#include <stdio.h>
#include <mmsystem.h>
#include <malloc.h>
#include <memory.h>
#include <time.h>
#include <io.h>
#include <sys\types.h>
#include <sys\stat.h>
#include "gcortns.h"
#include "gco.h"
#include "resource.h"

#define gcortns_c
#include "gcortns.prt"
#include "gcodbg.prt"
#include "gcopsup.prt"
#include "gcoabout.prt"
#include "gcosbar.prt"

#define MAX_STRINGS 20
#define MAXSTRINGLEN 2048

#define  APPEND_SYMBOL		    '!'
#define  MAX_RESOURCE_STRING_LEN    255
#define  MAX_WVSPRINTF_OUTPUT	    2048

#define DLLNAME	"risres.dll"
/****************************************************************************
_CenterWindowOnScreen
****************************************************************************/
extern void _CenterWindowOnScreen(
	HWND hWnd)
{
// Used from a article in WindowsDos Magazine 12/94 by Scooper N. Orig
   POINT ptScreen;
   POINT ptWindow;
   POINT ptCenter;
   RECT  rcWnd;
   
   // get width and height of dialog
   GetWindowRect (hWnd, &rcWnd);
   ptWindow.x = rcWnd.right - rcWnd.left; 
   ptWindow.y = rcWnd.bottom - rcWnd.top;   
 
   // get width and height of screen
   ptScreen.x = GetSystemMetrics (SM_CXSCREEN);
   ptScreen.y = GetSystemMetrics (SM_CYSCREEN);
   // compute coordinate to center dialog
   ptCenter.x = (ptScreen.x - ptWindow.x) / 2;
   ptCenter.y = (ptScreen.y - ptWindow.y) / 2;
 
   // reposition window
   SetWindowPos (
      hWnd, NULL,
      ptCenter.x, ptCenter.y,		// reposition to
      0, 0,			  // do not resize
      SWP_NOSIZE | SWP_NOZORDER); 
}
 
/****************************************************************************
_GetVersionInfo
****************************************************************************/
extern void _GetVersionInfo(
	LPSTR szModule,
	int which,
	LPSTR value)
{
   LPSTR   lpVersion;	    
   DWORD   dwVerInfoSize;
   DWORD   dwVerHnd;
   UINT    uVersionLen;
   WORD    wRootLen;
   BOOL    bRetCode;
   char    szFullPath[256];
   char    szResult[256];
   char    szGetName[256];
   LPSTR   lpstrVffInfo;
   HANDLE  hMem;

   GetModuleFileName (GetModuleHandle(szModule), szFullPath, sizeof(szFullPath));

   dwVerInfoSize = GetFileVersionInfoSize(szFullPath, &dwVerHnd);
   if (dwVerInfoSize)
   {
      /* If we were able to get the information, process it:*/
      hMem = GlobalAlloc(GMEM_MOVEABLE, dwVerInfoSize);
      lpstrVffInfo  = GlobalLock(hMem);
      GetFileVersionInfo(szFullPath, dwVerHnd, dwVerInfoSize, lpstrVffInfo);
      lstrcpy(szGetName, "\\StringFileInfo\\040904E4\\");
      wRootLen = lstrlen(szGetName);

      /* Walk through the dialog items that we want to replace:*/
      switch (which)
      {
	 case VERSION_COMPANYNAME:
	    strcpy(szResult,"CompanyName");
	    break;
	 case VERSION_FILEDESCRIPTION:
	    strcpy(szResult,"FileDescription");
	    break;
	 case VERSION_FILEVERSION:
	    strcpy(szResult,"FileVersion");
	    break;
	 case VERSION_INTERNALNAME:
	    strcpy(szResult,"InternalName");
	    break;
	 case VERSION_LEGALCOPYRIGHT:
	    strcpy(szResult,"LegalCopyright");
	    break;
	 case VERSION_LEGALTRADEMARKS:
	    strcpy(szResult,"LegalTrademarks");
	    break;
	 case VERSION_PRODUCTNAME:
	    strcpy(szResult,"ProductName");
	    break;
	 case VERSION_PRODUCTVERSION:
	    strcpy(szResult,"ProductVersion");
	    break;
	 case VERSION_COMMENTS:
	    strcpy(szResult,"Comments");
	    break;
	 default:
	    strcpy(value, " ");
	    return;
      }

      lstrcat (szGetName, szResult);
      uVersionLen   = 0;
      lpVersion     = NULL;
      bRetCode	    =  VerQueryValue((LPVOID)lpstrVffInfo,
	 (LPSTR)szGetName,
	 (LPVOID)&lpVersion,
	 (UINT *)&uVersionLen);

      if ( bRetCode && uVersionLen && lpVersion)
      {
	 /* Replace dialog item text with version info*/
	 lstrcpy(szResult, lpVersion);
      }
      GlobalUnlock(hMem);
      GlobalFree(hMem);
   }

   strcpy(value, szResult);
}

/****************************************************************************
	FUNCTION: _CenterWindow (HWND, HWND)

	PURPOSE:  Center one window over another

	COMMENTS:

	Dialog boxes take on the screen position that they were designed at,
	which is not always appropriate. Centering the dialog over a particular
	window usually results in a better position.
****************************************************************************/
extern BOOL _CenterWindow(
	HWND hwndChild,
	HWND hwndParent)
{
// Used from the sample program fontiew

   RECT    rChild, rParent;
   int	   wChild, hChild, wParent, hParent;
   int	   wScreen, hScreen, xNew, yNew;
   HDC	   hdc;

   // Get the Height and Width of the child window
   GetWindowRect (hwndChild, &rChild);
   wChild = rChild.right - rChild.left;
   hChild = rChild.bottom - rChild.top;

   // Get the Height and Width of the parent window
   GetWindowRect (hwndParent, &rParent);
   wParent = rParent.right - rParent.left;
   hParent = rParent.bottom - rParent.top;

   // Get the display limits
   hdc = GetDC (hwndChild);
   wScreen = GetDeviceCaps (hdc, HORZRES);
   hScreen = GetDeviceCaps (hdc, VERTRES);
   ReleaseDC (hwndChild, hdc);

   // Calculate new X position, then adjust for screen
   xNew = rParent.left + ((wParent - wChild) /2);
   if (xNew < 0)
   {
      xNew = 0;
   }
   else if ((xNew+wChild) > wScreen)
   {
      xNew = wScreen - wChild;
   }

   // Calculate new Y position, then adjust for screen
   yNew = rParent.top  + ((hParent - hChild) /2);
   if (yNew < 0)
   {
      yNew = 0;
   }
   else if ((yNew+hChild) > hScreen)
   {
      yNew = hScreen - hChild;
   }

   // Set it, and return
   return SetWindowPos (hwndChild, NULL,
      xNew, yNew, 0, 0, SWP_NOSIZE | SWP_NOZORDER);
}

/****************************************************************************
_LoadResources
****************************************************************************/
extern HANDLE _LoadResources(
	char *title)
{
   HANDLE hLib = NULL;
	char			*envname;
   char mess[255];
	char pathname[_MAX_PATH];

   // load RIS Resource dll
	if ((envname = getenv("RISDEVDIR")) != NULL)
	{
		sprintf(pathname,"%s\\risutl\\lib\\nt\\%s",envname,DLLNAME);
	}
	else
	{
		strcpy(pathname,DLLNAME);
	}

   hLib = LoadLibrary(pathname);
   if (hLib)
      return (hLib);

	sprintf(mess,"%s failed to load",pathname);
	MessageBoxEx(NULL,mess,title,MB_OK | MB_TASKMODAL | MB_ICONSTOP,MAKELANGID(LANG_NEUTRAL,SUBLANG_DEFAULT));
	return (NULL);
}// _LoadResources

/****************************************************************************
   FUNCTION: GetResourceString
   PURPOSE:  Uses strings from stringtable whereever you want
   COMMENTS: 1st position ! to continue with next line
****************************************************************************/
extern LPSTR _GetResourceString(
	HINSTANCE hInst,
	UINT nID,
	...)
{
// Used from a article in MSJ 10/92 by Dave Edson
   static int WhichString =0;
   static char szLoadedString1[MAX_STRINGS][MAXSTRINGLEN];
   BOOL bKeepLoading;
   char *szLoadedString;
   char szLoadBuffer[MAXSTRINGLEN];
   int i;
   TCHAR    szFormat[255];
   va_list  va;

   szLoadedString = szLoadedString1[WhichString];
   WhichString++;
   if (WhichString == MAX_STRINGS)
      WhichString=0;

   szLoadedString[0]=0;

   do
   {
      bKeepLoading = FALSE;
      i = LoadString(hInst,nID,szFormat,MAXSTRINGLEN);
      if (i != 0)
      {
	 va_start(va, nID);
	 wvsprintf(szLoadBuffer, szFormat, va);
	 va_end(va);

	 if (*szLoadBuffer == '!')
	 {
	    bKeepLoading = TRUE;
	    nID++;
	    lstrcat(szLoadedString,szLoadBuffer+1);
	 }
	 else
	 {
	    lstrcat(szLoadedString, szLoadBuffer);
	 }
      }
      else
      {
	 strcpy(szLoadedString,"");
      }
   }
   while (bKeepLoading);

   return((LPSTR)szLoadedString);
}/* _GetResourceString */


/****************************************************************************
_InitProgram
****************************************************************************/
extern void _InitProgram(
	int argc,
	char **argv)
{
   int i;
   DWORD dwLang;


   for (i=0; i<argc; i++)
   {
      _DEBUG(PROG,2,"argc=%d argv=%s",i,(LPSTR)argv[i]);
   }

   dwLang = GetUserDefaultLangID();
   _DEBUG(PROG,2,"GetUserDefaultLangID: <%04x>",dwLang);

   _DEBUG(PROG,2,"SM_CXSCREEN= %d SM_CYSCREEN=%d",GetSystemMetrics(SM_CXSCREEN),GetSystemMetrics(SM_CYSCREEN));

}// _InitProgram


/****************************************************************************
_GetHomeDir
****************************************************************************/
extern char * _GetHomeDir(
	HANDLE hInstance)
{
   char szModuleName[66];
   char *ps;

   GetModuleFileName(hInstance, szModuleName, sizeof(szModuleName));
   ps = strrchr(szModuleName,'\\');
   *ps = '\0';
   return (szModuleName);
}/* _GetHomeDir */

/****************************************************************************
_MessageBox
****************************************************************************/
extern int _MessageBox(
	HWND	hWnd,
	HINSTANCE hInst,
	WORD   wType,
	int    nCaptionID,
	int    nTextID,
	...)
{
   char     szCaption [MAX_RESOURCE_STRING_LEN];
   char     szText [MAX_RESOURCE_STRING_LEN];
   HGLOBAL  hFormat	= NULL;
   LPSTR    lpFormat	= NULL;
   HGLOBAL  hOutput	= NULL;
   LPSTR    lpOutput	= NULL;
   BOOL     bContinue	= TRUE;
   LPLONG   lpParams	= (LPLONG) (&nTextID + 1);
   int	    Ret 	= 0;

/*
Taken from WindowsDos magizine, 12/93 by Moshe Rubin
*/
   /*
   *  Get the caption string.  If <nCaptionID> is
   *  non-zero, use as ID.  Otherwise, get string
   *  pointer from variable parameter list.
   */
   strcpy (szCaption, "");
   if (nCaptionID)
      LoadString (hInst, nCaptionID, szCaption,
		  MAXSTRINGLEN);
   else
      lstrcpy (szCaption, (LPSTR) *lpParams++);

   /* Allocate buffer to hold the string resource. */
   if ((hFormat = GlobalAlloc (GHND,
		     MAX_WVSPRINTF_OUTPUT)) == NULL)
      goto exit;
   if ((lpFormat = GlobalLock (hFormat)) == NULL)
      goto exit;

   /* Fill <lpFormat> with the full format string. */
   if (nTextID == 0)
      lstrcpy (lpFormat, (LPSTR) *lpParams++);
   else
      while (bContinue)
	 {
	    /*
	    *  Get the text string.  If <nCaptionID> is
	    *  is non-zero, use as ID.	Otherwise, get
	    *  string pointer from variable parameter
	    *  list.
	    */
	    if (LoadString (hInst, nTextID++,
			   szText, MAXSTRINGLEN) == 0)
	       break;

	    /* Don't overflow <lpFormat>. */
	    if ((lstrlen (lpFormat) + lstrlen (szText))
		     >= MAX_WVSPRINTF_OUTPUT)
	       break;

	    /* Concatenate the next resource string? */
	    bContinue = (szText [0] == APPEND_SYMBOL);
	    lstrcat (lpFormat, (bContinue ?
				szText + 1 : szText));
	 }

   /* Format string with variable parm list (if any) */
   if ((hOutput = GlobalAlloc (GHND,
		     MAX_WVSPRINTF_OUTPUT)) == NULL)
      goto exit;
   if ((lpOutput = GlobalLock(hOutput)) == NULL)
      goto exit;

   wvsprintf (lpOutput, lpFormat, (LPSTR)lpParams);

   /* Display the message box. */
   Ret = MessageBoxEx (hWnd,
		     lpOutput,
		     szCaption,
		     wType,MAKELANGID(LANG_NEUTRAL,SUBLANG_DEFAULT));

exit:
   if (lpFormat)     GlobalUnlock (hFormat);
   if (hFormat)      GlobalFree (hFormat);

   if (lpOutput)     GlobalUnlock (hOutput);
   if (hOutput)      GlobalFree (hOutput);

   return (Ret) ;
}

/******************************************************************************
	 _Delay
	 Pauses for x number of seconds
******************************************************************************/
extern void _Delay(
	int nNumSeconds)
{
/*
   struct tm *datetime;
   static LONG ltime;
   int	 hour;
   int	 minute;
   int	 sec;
   long lEndTime;
   long lStartTime;
   MSG aMsg;
	 
   if (_GetPlatform() != IS_WIN32S)
   {
      Sleep(nNumSeconds * 1000);
   }
   else
   {
      time(&ltime);
      datetime = localtime(&ltime);

      hour = datetime->tm_hour;
      minute = datetime->tm_min;
      sec = datetime->tm_sec;

      lEndTime = (hour * 1000) + (minute *100) + sec;
      _Debug(PROG,2,"Delay: Time is %02d:%02d:%02d",hour, minute,sec);
      lStartTime = lEndTime;

      while (lStartTime < lEndTime + nNumSeconds)
      {
	 if (PeekMessage(&aMsg,0,WM_NULL,WM_NULL,PM_REMOVE))
	    DispatchMessage(&aMsg);
	 time(&ltime);
	 datetime = localtime(&ltime);

	 hour = datetime->tm_hour;
	 minute = datetime->tm_min;
	 sec = datetime->tm_sec;

	 lStartTime = (hour * 1000) + (minute *100) + sec;
      }
      _Debug(PROG,2,"Delay: Time is %02d:%02d:%02d",hour, minute,sec);
   }
*/
	int i;

	for (i=0; i< (nNumSeconds * 1000); i++)
		_UpdateStatusBar("");
}/*_Delay */


/****************************************************************************
_GetPlatform
****************************************************************************/
extern int WINAPI _GetPlatform()
{
    DWORD    win_vers;
#if defined(WIN16)
   char i;
#endif

#if defined( WIN32 ) || defined( _WIN32 ) || ( __WIN32__ )
    /* program is being compiled for 32-bit */

    win_vers = GetVersion();
    if( ( win_vers & 0x80000000 ) == 0 )
    {
   /* this is real Windows NT */
      if (LOBYTE( LOWORD( win_vers ) ) ==3 &&
    HIBYTE( LOWORD( win_vers ) ) == 10)
      {
    return (IS_WIN32);
      }
      else
      {
    return(IS_DAYTONA);
      }
    }
    else
    {
   if( LOBYTE( LOWORD( win_vers ) ) < 4 )
   {
       /* this is Win32s running on 16-bit Windows 3.1,
     because the program is running in 32-bit mode it
     cannot easily determine the version of Win32s as
     that info comes from a 16-bit DLL - good innit.
     the program *could* work out the version, but it
     would require a 16-bit DLL to thunk to, and that
     just is not worth the effort. */
       return(IS_WIN32S);
   }
   else
   {
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
   /* Program is running on real 16-bit Windows 3.1x - here the program
      can find out which version, if any, of Win32s is available, and
      which particular build of Windows 3.1x this really is */

   /* data for Win32s */
   typedef    struct
   {
       BYTE    major;
       BYTE    minor;
       WORD    build;
       BOOL    debug;
   } WIN32SINFO, far *LPWIN32SINFO;

   /* data for Win32s */
   HANDLE   h_win32s; /* handle to Win32s library */
   FARPROC getwin32s_info; /* address of Win32s version function */
   WIN32SINFO  win32s_info;   /* the Win32s version information */
   char temp[ 1024 ]; /* filled with Win32s version - if any */

   /* data for build identity */
   HINSTANCE mod_handle; /* handle to Windows 3.1x USER module */
   char bld_id[ 256 ]; /* space for build identity */
   int bld_len; /* length of build identity string */

   SetErrorMode( SEM_NOOPENFILEERRORBOX ); /* disable "File Not Found" error box */

    /* this bit is a fiddle, but it is necessary because of Windows for
       Workgroups 3.11, which reports its version number via the
       GetVersion()
       interface as 3.10 (stupid thing). However, the build identity in
       Windows own USER module does contains the correct information, so 
       that is added. here. the program uses LoadLibrary so that it can get a
       module instance. this will increment the usage count so the
       library is later free'd to decrement it. */
   if( ( mod_handle = LoadLibrary( USER_EXE ) ) == NULL ||
       ( bld_len = LoadString( mod_handle, 516, bld_id, sizeof( bld_id) ) == 0 ) )
   {
       /* either the program did not get the instance handle or failed to get
     the string from the module, both of which are actually *very*
     unlikely indeed in the case of USER, but it is checked anyway! */
       lstrcpy( bld_id, "(Unknown!)" );
   }
   if( mod_handle != NULL )
   {
       /* it's a bit academic for USER, but the program does things properly
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
   
}/* _GetPlatform */


/****************************************************************************
_SetCtlFocus
****************************************************************************/
extern void _SetCtlFocus(
	HWND hwndDlg,
	UINT cid)
{
   SendMessage(hwndDlg,WM_NEXTDLGCTL,
      (WPARAM)GetDlgItem(hwndDlg,cid),TRUE);
}

/****************************************************************************
_RunUtility
****************************************************************************/
extern void _RunUtility(
	UINT nWhich)
{
   char * szNames[] = {
      "RISdcode",
      "RISclnsr",
      "RISdtype",
      "RISrecrd",
      "RISplbck",
      "RISunlod",
      "RISlod",
      "RISbatch",
      "RISgui",
      "RISmgr",
      };
   char szFile[_MAX_PATH];
   char szHomeDir[_MAX_PATH];
   WORD wStatus;

//   strcpy(szFile,szNames[nWhich - IDM_UTIL_DCODE -2]);
   strcpy(szHomeDir,_GetHomeDir(gco.hhInst));
   sprintf(szFile,"%s\\%s.exe",szHomeDir,szNames[nWhich - IDM_UTIL_DCODE -2]);
_DEBUG(PROG,2,"nWhich = %d file = <%s>",nWhich,szFile);
   wStatus = WinExec(szFile,SW_SHOWNORMAL);

   if (wStatus < 32)
   {
      //MessageBoxEx(NULL,_GetResourceString(gco.hhLib,IDS_UTIL_ERROR,szFile,wStatus),_GetResourceString(gco.hhLib,IDS_ERROR),MB_OK | MB_TASKMODAL | MB_ICONSTOP,MAKELANGID(LANG_NEUTRAL,SUBLANG_DEFAULT));
      _MessageBox (NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,IDS_ERROR,IDS_UTIL_ERROR,szFile,wStatus);
   }
}

/****************************************************************************
_RunHelp
****************************************************************************/
extern void _RunHelp(
	UINT nWhich,
	HWND hwnd,
	char *desc,
	char *caption,
	HICON hIcon)
{
	char			*envname;
	char pathname[_MAX_PATH];

	if ((envname = getenv("RISDEVDIR")) != NULL)
	{
		sprintf(pathname,"%s\\risutl\\config\\english\\help\\risutl.hlp",envname);
	}
	else
	{
		strcpy(pathname,"risutl.hlp");
	}

	
	switch (nWhich)
   {
      case IDM_HELP_PROGRAM:
	 if (!WinHelp(hwnd, pathname, HELP_PARTIALKEY, (DWORD)(LPSTR)caption))
	 {
	    MessageBox (GetFocus(),
	       _GetResourceString(gco.hhLib,IDS_HELP_FAIL),desc, MB_TASKMODAL|MB_OK|MB_ICONHAND);
	 }
	 break;

      case IDM_HELP_CONTENTS:
	 if (!WinHelp (hwnd, pathname, HELP_CONTENTS,0L))
	 {
	    MessageBox (GetFocus(),
	       _GetResourceString(gco.hhLib,IDS_HELP_FAIL),desc, MB_TASKMODAL|MB_OK|MB_ICONHAND);
	 }
	 break;

      case IDM_HELP_SEARCH:
	 if (!WinHelp(hwnd, pathname, HELP_PARTIALKEY, (DWORD)(LPSTR)""))
	 {
	    MessageBox (GetFocus(),
	       _GetResourceString(gco.hhLib,IDS_HELP_FAIL),desc, MB_TASKMODAL|MB_OK|MB_ICONHAND);
	 }
	 break;

      case IDM_HELP_USE:
	 if(!WinHelp(hwnd, (LPSTR)NULL, HELP_HELPONHELP, 0))
	 {
	    MessageBox (GetFocus(),
	       _GetResourceString(gco.hhLib,IDS_HELP_FAIL),desc, MB_SYSTEMMODAL|MB_OK|MB_ICONHAND);
	 }
	 break;

      case IDM_HELP_PRODUCT_SUPPORT:
	 DialogBox(gco.hhLib, MAKEINTRESOURCE(IDD_PRODSUP),hwnd, (DLGPROC)ProductSupport);
	 break;

      case IDM_HELP_ABOUT:
	 _DisplayAboutBox(hwnd,desc,caption,hIcon);
	 break;
   }
}

/****************************************************************************
_ParseCommandLine
****************************************************************************/
extern int _ParseCommandLine(
	HANDLE hInst,
	char *cline,
	char ***argv)
{
   char szModuleName[66];
   char wrk[255];
   char tokensep[]=" ";
   char *token;
   int i=0;
   int count =1;
   char **k;
   strcpy(wrk, cline);

   /* get the count */
   token = strtok(wrk,tokensep);

   while(token != NULL)
   {
      count++;
      token = strtok(NULL,tokensep);
   }

   k = (char **)malloc(count * sizeof(char *));
   for (i=0; i<count; i++)
      k[i] = (char *)malloc(80 * sizeof(char));

   /* insert program name */
   GetModuleFileName(hInst, szModuleName, sizeof(szModuleName));
   strcpy(k[0] , AnsiLower(szModuleName));

   /* insert values */
   strcpy(wrk, cline);
   token = strtok(wrk,tokensep);

   i=0;
   while(token != NULL)
   {
      i++;
      strcpy(k[i] , token);
      token = strtok(NULL,tokensep);
   }
   *argv = k;

   return(count);
}/* ParseCommandLine */


/****************************************************************************
_AddUtilityMenu
****************************************************************************/
extern void _AddUtilityMenu(
	HWND hwnd,
	int nPos)
{
   HMENU hUtils;
   HMENU hMain;

   hMain = GetMenu(hwnd);
   hUtils = LoadMenu(gco.hhLib,"RISutils");
   InsertMenu(hMain,nPos,MF_BYPOSITION | MF_POPUP,(UINT)hUtils,(LPSTR)_GetResourceString(gco.hhLib,IDS_UTILITIES));
}

/****************************************************************************
_AddHelpMenu
****************************************************************************/
extern void _AddHelpMenu(
	HWND hwnd)
{
   HMENU hHelp;
   HMENU hMain;

   hMain = GetMenu(hwnd);
   hHelp = LoadMenu(gco.hhLib,"RIShelp");
   AppendMenu(hMain,MF_POPUP,(UINT)hHelp,(LPSTR)_GetResourceString(gco.hhLib,IDS_HELP));
}

/****************************************************************************
_AddDebugMenu
****************************************************************************/
extern void _AddDebugMenu(
	HWND hwnd)
{
   HMENU hDebug;
   HMENU hMain;

   hMain = GetMenu(hwnd);
   hDebug = LoadMenu(gco.hhLib,"RISdebug");
   AppendMenu(hMain,MF_POPUP,(UINT)hDebug,(LPSTR)_GetResourceString(gco.hhLib,IDS_DEBUG));
}

/****************************************************************************
_SelectFile
****************************************************************************/
extern BOOL _SelectFile(
	HWND hwnd,
	char *filename,
	char *initialdir,
	char *pickedfile,
	char *title,
	char *szFilterSpec,
	int *index)
{
	char chReplace;
	int i;
	OPENFILENAME ofn;
	char szFileName[_MAX_PATH] = "";

	// correct szFilterSpec
	chReplace = szFilterSpec[strlen(szFilterSpec)-1];
_DEBUG(PROG,2,"chReplace = <%c>",chReplace);
	for (i=0; szFilterSpec[i] != '\0'; i++)
	{
		if (szFilterSpec[i] == chReplace)
			szFilterSpec[i] = '\0';
	}

	/* fill in non-variant fields of OPENFILENAME struct. */
	memset (&ofn,0,sizeof(OPENFILENAME));
	ofn.lStructSize			= sizeof(OPENFILENAME);
	ofn.hwndOwner				= hwnd;
	ofn.lpstrFilter			= szFilterSpec;
	ofn.nFilterIndex			= *index;
	ofn.lpstrFile				= szFileName;
	ofn.nMaxFile				= _MAX_PATH;
	ofn.lpstrInitialDir		= initialdir;
	ofn.lpstrFileTitle		= pickedfile;
	ofn.nMaxFileTitle			= _MAX_PATH;
	ofn.lpstrTitle				= title;

_DEBUG(PROG,2,"Starting SelectFile");

	/* Use standard open dialog */

	if (!GetOpenFileName ((LPOPENFILENAME)&ofn))
	{
     _DEBUG(PROG,2,"GetOpenFile Failed");
		return (FALSE);
	}

	strcpy(filename,ofn.lpstrFile);
	*index = ofn.nFilterIndex;

	strcpy(initialdir, ofn.lpstrFile);
	initialdir[ofn.nFileOffset -1] = '\0';
	return(TRUE);
}/* _SelectFile */

/****************************************************************************
_ReadFile2Control
****************************************************************************/
extern void _ReadFile2Control(
	HWND hDlgWnd,
	char *szFileName)
{
	int IOStatus;			    /* result of file i/o      */
	int hFile;                                /* file handle              */
	HANDLE hHourGlass=NULL;                        /* handle to hourglass cursor      */
	HANDLE hSaveCursor;                       /* current cursor handle      */
	char str[255];
	struct stat FileStatus;                   /* information from fstat()      */
	char *pEditBuffer;                         /* address of the edit buffer      */
	OFSTRUCT OfStruct;                        /* information from OpenFile()     */

	_Debug(PROG,2,"filename=<%s>",szFileName);
	// Open the file and get its handle
	hFile = OpenFile (szFileName, (LPOFSTRUCT)&OfStruct,OF_READ);
	if (hFile == HFILE_ERROR)
	{
		_Debug(PROG,2,"OpenFile Failed: %d",GetLastError());
		return;
	}

	// Allocate edit buffer to the size of the file + 1
	stat(szFileName, &FileStatus);
	pEditBuffer =	(char *)malloc(((int)FileStatus.st_size+1) * sizeof(char *));

	if (!pEditBuffer)
	{
		_Debug(PROG,2,"Not enough memory.");
		return;
	}
	hSaveCursor = SetCursor(hHourGlass);

	IOStatus = _lread(hFile, pEditBuffer, (unsigned int)FileStatus.st_size);
	_lclose(hFile);

	/* # bytes read must equal file size */
	if (IOStatus != (int)FileStatus.st_size)
	{
		_Debug(PROG,2,"iostatus=%d size=%d",IOStatus,(int)FileStatus.st_size);
		sprintf(str, "Error reading %s.", szFileName);
		SetCursor(hSaveCursor);      /* Remove the hourglass */
		_Debug(PROG,2,"%s",str);
	}
_Debug(PROG,2,"OK: iostatus=%d size=%d",IOStatus,(int)FileStatus.st_size);
_Debug(PROG,2,"text = <%s>",(char *)pEditBuffer);
	_Debug(PROG,2,"hDlgWwnd=%08X",hDlgWnd); 
	Edit_SetText(hDlgWnd, (char *)pEditBuffer);
	/* Set up a new buffer and window title */
	SetCursor(hSaveCursor);            /* restore the cursor */
    SetFocus(hDlgWnd);
	if (pEditBuffer)
		free(pEditBuffer);

}
/****************************************************************************
_WinError
Returns error string
Win32s returns just error number
****************************************************************************/
extern char *_WinError(
	ULONG errorcode)
{
	DWORD LanguageId;
	LPSTR SystemMessage = 0;
	LPVOID SystemMessageArray[1] = { &SystemMessage };
	HINSTANCE lib;
	char str[255];
	ULONG orgError;
	int i;

	orgError = errorcode;

	if (getenv("RISUTIL_ERROR_LANG") != NULL)
		LanguageId = MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US);
	else
		LanguageId = MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT);

	// Translate the System Error Code into a string.
	FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER,
		NULL,errorcode,LanguageId,(LPSTR) &SystemMessage,(DWORD)NULL,NULL);

	if (SystemMessage != 0)
	{
//		sprintf(str,"System error %%x translates to:%s", errorcode, SystemMessage);
//		sprintf(str,"Error: %ld %#x, %s", orgError,errorcode, SystemMessage);
		strcpy(str,_GetResourceString(gco.hhLib,IDS_WINERROR, orgError,errorcode, SystemMessage));
		i = strlen(str);
		str[i-2] = '\0';
	}
	else
	{
//		printf("No translation of %#x in system error table.\n\n", errorcode);
		lib = LoadLibrary("ntdll.dll");
		if (!lib)
		{
//			printf("%s - Sorry, could not load ntdll: %#x\n",argv[0],GetLastError());
			sprintf(str,"%ld",errorcode);
			return(str);
		}
		FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_HMODULE,
			lib,errorcode,LanguageId,(LPSTR) &SystemMessage,(DWORD)NULL,NULL);
		if (SystemMessage != 0)
		{
//			printf("NTDLL status message for %#x is:\n%s", errorcode, SystemMessage);
//			sprintf(str,"Error: %ld %#x, %s", orgError,errorcode, SystemMessage);
			strcpy(str,_GetResourceString(gco.hhLib,IDS_WINERROR, orgError,errorcode, SystemMessage));
			i = strlen(str);
			str[i-2] = '\0';
		}
		else
		{
//			printf("%s - Sorry, could not find message for %#x\n",argv[0],errorcode);
			sprintf(str,"%ld",errorcode);
		}
		FreeLibrary(lib);
	}
	return (str);
}

/****************************************************************************
_SaveFile
****************************************************************************/
extern BOOL _SaveFile(
	HWND hwnd,
	char *szFileName,
	char *initialdir,
	char *pickedfile,
	char *title,
	char *szFilterSpec,
	int *index)
{
	char chReplace;
	int i;
	OPENFILENAME ofn;
//	char szFileName[_MAX_PATH] = "";

	// correct szFilterSpec
	chReplace = szFilterSpec[strlen(szFilterSpec)-1];
_DEBUG(PROG,2,"chReplace = <%c> szfilename=<%s>",chReplace,szFileName);
	for (i=0; szFilterSpec[i] != '\0'; i++)
	{
		if (szFilterSpec[i] == chReplace)
			szFilterSpec[i] = '\0';
	}

	/* fill in non-variant fields of OPENFILENAME struct. */
	memset (&ofn,0,sizeof(OPENFILENAME));
	ofn.lStructSize			= sizeof(OPENFILENAME);
	ofn.hwndOwner				= hwnd;
	ofn.lpstrFilter			= szFilterSpec;
	ofn.nFilterIndex			= *index;
	ofn.lpstrFile				= szFileName;
	ofn.nMaxFile				= _MAX_PATH;
	ofn.lpstrInitialDir		= initialdir;
	ofn.lpstrFileTitle		= pickedfile;
	ofn.nMaxFileTitle			= _MAX_PATH;
	ofn.lpstrTitle				= title;

_DEBUG(PROG,2,"Starting SelectFile");

	/* Use standard open dialog */

	if (!GetSaveFileName ((LPOPENFILENAME)&ofn))
	{
     _DEBUG(PROG,2,"GetSaveFileName Failed");
		return (FALSE);
	}

	strcpy(szFileName,ofn.lpstrFile);
	*index = ofn.nFilterIndex;

	strcpy(initialdir, ofn.lpstrFile);
	initialdir[ofn.nFileOffset -1] = '\0';
	return(TRUE);
}/* _SaveFile */


/****************************************************************************
_ReadControl2File
****************************************************************************/
extern void _ReadControl2File(
	HWND hDlgWnd,
	char *szFileName)
{
	int IOStatus;			    /* result of file i/o      */
	int hFile;                                /* file handle              */
	HANDLE hHourGlass=NULL;                        /* handle to hourglass cursor      */
	HANDLE hSaveCursor;                       /* current cursor handle      */
	char str[255];
	char *pEditBuffer;                         /* address of the edit buffer      */
	OFSTRUCT OfStruct;                        /* information from OpenFile()     */
	int nLen;

	_Debug(PROG,2,"filename=<%s>",szFileName);
	// Open the file and get its handle
	hFile = OpenFile (szFileName, (LPOFSTRUCT)&OfStruct,OF_PROMPT | OF_CANCEL | OF_CREATE);
	if (hFile == HFILE_ERROR)
	{
		_Debug(PROG,2,"OpenFile Failed: %d",GetLastError());
		return;
	}

	// Allocate edit buffer to the size of the file + 1
	nLen = Edit_GetTextLength(hDlgWnd);
	_Debug(PROG,2,"Len = %d",nLen);
	pEditBuffer =	(char *)malloc(((int)nLen+1) * sizeof(char *));

	if (!pEditBuffer)
	{
		_Debug(PROG,2,"Not enough memory.");
		return;
	}
	hSaveCursor = SetCursor(hHourGlass);

	Edit_GetText(hDlgWnd, pEditBuffer, nLen);

	IOStatus = _lwrite(hFile, pEditBuffer, nLen);
	_lclose(hFile);

	/* # bytes read must equal file size */
	if (IOStatus != nLen)
	{
		_Debug(PROG,2,"iostatus=%d size=%d",IOStatus,nLen);
		sprintf(str, "Error reading %s.", szFileName);
		SetCursor(hSaveCursor);      /* Remove the hourglass */
		_Debug(PROG,2,"%s",str);
	}
_Debug(PROG,2,"OK: iostatus=%d size=%d",IOStatus,nLen);
_Debug(PROG,2,"text = <%s>",(char *)pEditBuffer);
	_Debug(PROG,2,"hDlgWwnd=%08X",hDlgWnd); 
	SetCursor(hSaveCursor);            /* restore the cursor */
	if (pEditBuffer)
		free(pEditBuffer);
}


/****************************************************************************
_ReadLB2File
****************************************************************************/
extern void _ReadLB2File(
	HWND hDlgWnd,
	char *szFileName)
{
	int IOStatus;			    /* result of file i/o      */
	int hFile;                                /* file handle              */
	HANDLE hHourGlass=NULL;                        /* handle to hourglass cursor      */
	HANDLE hSaveCursor;                       /* current cursor handle      */
	char str[255];
	OFSTRUCT OfStruct;                        /* information from OpenFile()     */
	int nLen;
	int count;
	int i;
	char wrk[4096];

	_Debug(PROG,2,"filename=<%s>",szFileName);
	_Debug(PROG,2,"hDlgWwnd=%08X",hDlgWnd);

	// Open the file and get its handle
	hFile = OpenFile (szFileName, (LPOFSTRUCT)&OfStruct,OF_PROMPT | OF_CANCEL | OF_CREATE);
	if (hFile == HFILE_ERROR)
	{
		_Debug(PROG,2,"OpenFile Failed: %d",GetLastError());
		return;
	}
	hSaveCursor = SetCursor(hHourGlass);

	count = 	ListBox_GetCount(hDlgWnd);
	_Debug(PROG,2,"LB count = %d",count);

	for (i=0; i<count; i++)
	{
		ListBox_GetText(hDlgWnd, i, wrk);
		nLen = strlen(wrk);
		IOStatus = _lwrite(hFile, wrk, nLen);
		_lwrite(hFile, "\r\n",2);

		/* # bytes read must equal file size */
		if (IOStatus != nLen)
		{
			_Debug(PROG,2,"iostatus=%d size=%d",IOStatus,nLen);
			sprintf(str, "Error reading %s.", szFileName);
			SetCursor(hSaveCursor);      /* Remove the hourglass */
			_Debug(PROG,2,"%s",str);
		}
		else
			_Debug(PROG,2,"iostatus=%d size=%d wrk=<%s>",IOStatus,nLen,wrk);
	}
	SetCursor(hSaveCursor);            /* restore the cursor */
	_lclose(hFile);
}



