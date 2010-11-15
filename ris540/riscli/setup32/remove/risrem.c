/* Do not alter this SPC information: $Revision: 1.40.3.1 $ */
/*******************************************************************************

    FILE

	risrem.c 

    DESCRIPTION

	This file contains code for the remove executables for NT
	products. These products include:

	    RIS Shared Component

	1996.04.09:Alan Barksdale:Based on Setup SDK 02.03.01.02.

    FUNCTIONS

	OpenRemoveLogFile
	CloseRemoveLogFile
	WriteToRemoveLogFile

        removeFromRegValue
	RegRemoveRIS
	RegRemoveRISEx
        RISDeleteAppPath
        RISDeleteAppPaths
        RemoveRISSHARE
	RemoveRIS
	RemoveRISEx

*******************************************************************************/
#include <stdio.h>
#include <windows.h>
#include <winuser.h>
#include <windowsx.h>
#include <commdlg.h>
#include <dlgs.h>   
#include <assert.h>   

#include "isdk.h"
#include "ddeprog.h"
#include "ingrrmv.h"
#include "ingrw95.h"
#include "rmlib.h"
#include "ingrbld.h" // for cchMax
#include "reglib.h"
#include "cuirsc.h"

#include "risver.h"
#include "ingrreg.h"
#include "risrem.h"
#include "rissrvc.h" // for RISService
#include "risdebug.h" // for STRING()

#define COMPONENT "RIS"
//#define VERSION RIS_VERSION_STR

#ifdef WIN32
#	define FOR_WIN32
#endif

static FILE *fRemoveLogFile = NULL;
static char wrk[cchMax];

static int removeFromRegValue ( CHAR *szValue, CHAR *szSubstring );

static LONG RISDeleteAppPath(PTCHAR pathname, HWND hwndowner, LPCTSTR title,
	LPCTSTR application);
static LONG RISDeleteAppPaths(PTCHAR pathname, HWND hwndowner, LPCTSTR title);
static LONG RemoveRISSHARE(HWND hwndowner, LPTSTR title, LPTSTR version_string,
	PVOID *appdata, BOOLEAN delete_tmp_dir, BOOLEAN ask_delete,
	PINT remove);

static VOID OpenRemoveLogFile(VOID);

//*************************************************************************
static VOID OpenRemoveLogFile(VOID)
//	LPSTR szFile)
{
	CHAR szTempDir[cchMax];
	CHAR szWinDrive[cchMax]; /* Windows drive */
	CHAR szLogFile[cchMax];
	static BOOLEAN bCalledBefore = FALSE; // because the log file may have been closed during a run to handle the fact that parts of the remove code are called by the install code
        CHAR   *tempdirp ;

	if(NULL == fRemoveLogFile) {

           /*
           ** Melania M Stewart - TR# 439601782
            * Place risrem.log on location pointed by TEMP 
            * otherwise, place on the SystemDirectory (ex. c:)
           */
           strcpy (szTempDir, "") ;
           if( (tempdirp = getenv("TEMP")) )
           {
            if ( ISDKDirFilesExist (tempdirp, 
                                    '\\',
                                    NULL,
                                    NULL) ) 
                {
                    lstrcpy(szTempDir, tempdirp);
                }
           }
       
           if (!strlen (szTempDir))
           {
               GetWindowsDirectory(szWinDrive, cchMax);
               szWinDrive[1] = '\0';
               sprintf(szTempDir, "%s:", szWinDrive);
           }
       
           sprintf(szLogFile, "%s\\risrem.log", szTempDir);

		if(bCalledBefore) {
			fRemoveLogFile = fopen(szLogFile, "a+");
		} else {
			fRemoveLogFile = fopen(szLogFile, "w");
			bCalledBefore = TRUE;
		}
	}

	sprintf(wrk,
		"OpenRemoveLogFile:%s for RIS %s was compiled on %s, %s.",
		__FILE__, RIS_VERSION_STR, __DATE__, __TIME__);
	WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
} // OpenRemoveLogFile


//*************************************************************************
// 1996.05.10:Alan Barksdale:Ensuring that the remove log file is closed after
//	the setup executables are ended is complicated the install code's
//	calling parts of the remove code.  Therefore, I'll close the remove log
//	file in several places.
extern VOID CloseRemoveLogFile(VOID)
{
	WriteToRemoveLogFile(__FILE__, __LINE__, "CloseRemoveLogFile");
	if (NULL != fRemoveLogFile) {
		fclose(fRemoveLogFile);
		fRemoveLogFile = NULL;
	}
}


//*************************************************************************
extern VOID WriteToRemoveLogFile(
	LPSTR szFileName,
	int iLineNumber,
	LPSTR szStr)
{
//	static BOOLEAN bNeedToOpenRemoveLogFile = TRUE;
//	char szOutput[cchMax];

	if(NULL == fRemoveLogFile) {
		OpenRemoveLogFile();
	}

//	if(bNeedToOpenRemoveLogFile) {
//		bNeedToOpenRemoveLogFile = FALSE;
//		OpenRemoveLogFile();
//	}

//	sprintf(szOutput, "%s,%d:%s", szFileName, iLineNumber, szStr);
//	WriteToLogFile(szOutput);

	if(NULL != fRemoveLogFile) {
		fprintf(fRemoveLogFile, "%s,%d:%s\n", szFileName, iLineNumber,
			szStr);
		fflush(fRemoveLogFile);
	}
} // WriteToRemoveLogFile


// 1996.02.22:Alan Barksdale:modified from csource\template.c in Setup SDK 2.3.0.0
/* function to search for a string in a multi-valued registry entry     */
/* returns 0 if szSubstring was the last and only component of szValue  */
/*           or if szValue was already a zero-length string             */
/* returns 1 if szSubstring was deleted from szValue, or if it was      */
/*           not a component of szSubString                             */

static int
removeFromRegValue ( CHAR *szValue,
                     CHAR *szSubstring
		     )

{
  WCHAR wszTemp1[cchMaxReg];
  WCHAR wszTemp2[cchMaxReg];
  LPWSTR wszSubstring;
  int indexLast, index, initial_length;
  
  WriteToRemoveLogFile(__FILE__, __LINE__, "Starting removeFromRegValue");
  sprintf(wrk, "removeFromRegValue:szValue = \"%s\", szSubstring = \"%s\"",
    szValue, szSubstring);
  WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

  wszSubstring = malloc((lstrlen(szSubstring) + 1) * sizeof(WCHAR));
  mbstowcs( wszSubstring, szSubstring, lstrlen(szSubstring) + 1);
  mbstowcs( wszTemp1, szValue, lstrlen(szValue) + 1);
  wszTemp2[0] = L'\0';  

  /* search for szSubstring in szValue - break szValue into substrings  */
  /* (delimited by ";") and compare each one in turn to szSubstring     */
  /* if it does not match, then copy it to szTemp2                      */
  
  indexLast = 0;
  initial_length = (int)wcslen(wszTemp1);
  for ( index = 0; index < initial_length; index++ )
  {
    if ( wszTemp1[index] == L';' )
    {
      wszTemp1[index] = L'\0';
      if ( _wcsicmp ( &wszTemp1[indexLast], wszSubstring ) != 0 )
      {
        if ( wcslen ( wszTemp2 ) != 0 ) wcscat ( wszTemp2, L";" );
        wcscat ( wszTemp2, &wszTemp1[indexLast] );
      }
      indexLast = index + 1;
    }
  }
  
  /* copy the last component if necessary */
  if ( _wcsicmp ( &wszTemp1[indexLast], wszSubstring ) != 0 )
  {
    if ( wcslen ( wszTemp2 ) != 0 ) wcscat ( wszTemp2, L";" );
    wcscat ( wszTemp2, &wszTemp1[indexLast] );
  }
  
  /* copy output string to szValue */
  wcstombs( szValue, wszTemp2, wcslen(wszTemp2) + 1 );
  
  free(wszSubstring);

  /* return 0 if RefList is now empty */
  if ( lstrlen ( szValue ) == 0 )
  {
    WriteToRemoveLogFile(__FILE__, __LINE__, "removeFromRegValue returns 0");
    return 0;
  }
  else
  {
    WriteToRemoveLogFile(__FILE__, __LINE__, "removeFromRegValue returns 1");
    return 1;
  }
}


// 1996.02.02:Alan Barksdale:modified from csource\template.c in Setup SDK
//	2.3.0.0.
/* This function removes the application's entry from the RefList field    */
/* in the RIS Shared Component registry key. If the RefList field is empty */
/* it deletes the registry key and returns 1. It returns a 0 otherwise.    */
// int
// FUNCTION3 ( CHAR *listEntry)
extern INT RegRemoveRISEx(
   LPTSTR version_string,
   CHAR *listEntry)
{
  CHAR szShare[cchMaxReg];  /* Share path                          */
  CHAR szSubKey[cchMaxReg]; /* registry key                        */
  int remove_flag=0;         /* if true, then RefList is empty and  */
			     /* COMPONENT can be removed            */
  CHAR szRefList[cchMaxReg];
  
#ifndef COMPILESETUP
  int status;
#else
  DWORD dwType;
#endif /* !COMPILESETUP */
  
#ifdef FOR_BOTH
  int platform;
#endif /* FOR_BOTH */

  WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RegRemoveRISEx");
  sprintf(wrk,"RegRemoveRISEx:version_string = \"%s\", listEntry = \"%s\"",
	STRING(version_string), STRING(listEntry));
  WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
  
#ifdef FOR_BOTH
  platform = ISDKGetPlatform();
#endif /* FOR_BOTH */
  
#ifdef FOR_BOTH
  if (platform != IS_WIN32S) 
#endif /* FOR_BOTH */
#ifdef FOR_WIN32
  {
    /*
    ** determine share path, first from registry.
    */
    
#ifndef COMPILESETUP
    status = RGQueryRegStringValue (INTERGRAPH_KEY, COMMON_VALUE, szShare);
    if (status)
#else
      if ( GetRegKeyValueEx (HKEY_LOCAL_MACHINE,
                             INTERGRAPH_KEY,
                             COMMON_VALUE,
                             (LPDWORD)&dwType,
                             szShare,
                             cchMaxReg ) != ERROR_SUCCESS )
#endif /* !COMPILESETUP */
      {
        WriteToRemoveLogFile(__FILE__, __LINE__, "RegRemoveRISEx:couldn't get COMMON_VALUE");
        sprintf(wrk,"RegRemoveRISEx returns %d", remove_flag);
        WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
        CloseRemoveLogFile();
        return remove_flag;
      }
    
    
    /* parse new version number */
    lstrcpy ( szSubKey, INTERGRAPH_KEY );
    lstrcat ( szSubKey, "\\" );
    lstrcat ( szSubKey, COMPONENT );
    
#ifdef CURRENTVERSION
    lstrcat ( szSubKey, "\\CurrentVersion" );
#else
    lstrcat ( szSubKey, "\\" );
    lstrcat ( szSubKey, VERSIONSTRING_MACRO(version_string) );
#endif /* CURRENTVERSION */
    
#ifndef COMPILESETUP
    status = RGQueryRegStringValue(szSubKey, "RefList", szRefList);
    if (!status)
#else
      if ( GetRegKeyValueEx (HKEY_LOCAL_MACHINE,
                             szSubKey,
                             REFLIST_VALUE,
                             (LPDWORD)&dwType,
                             szRefList,
                             cchMaxReg ) == ERROR_SUCCESS )
#endif /* !COMPILESETUP */
      {
        if (!removeFromRegValue ( szRefList, listEntry ))
        {
          remove_flag = 1;
        }
#ifndef COMPILESETUP
        RGChangeRegStringValue ( szSubKey, REFLIST_VALUE, szRefList);
#else
        SetRegKeyValueEx (HKEY_LOCAL_MACHINE,
                          szSubKey,
                          REFLIST_VALUE,
                          dwType,
                          szRefList,
                          lstrlen(szRefList) + 1 );
#endif /* !COMPILESETUP */
      }
  }
#endif /* FOR_WIN32 */
#ifdef FOR_BOTH
  else
#endif /* FOR_BOTH */
#ifdef FOR_WIN32S
  {
    /*
    ** determine share path, first from registry.
    */
    if ( GetPrivateProfileString (COMMON_SECTION,
                                  COMMON_VALUE,
                                  "",
                                  szShare,
                                  cchMaxReg,
                                  INI_FILE) == 0 )
    {
      WriteToRemoveLogFile(__FILE__, __LINE__, "RegRemoveRISEx:couldn't get COMMON_VALUE");
      sprintf(wrk,"RegRemoveRISEx returns %d", remove_flag);
      WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
      CloseRemoveLogFile();
      return remove_flag;
    }
    
    /* parse new version number */
    lstrcpy ( szSubKey, COMPONENT );
    
#ifdef CURRENTVERSION
    lstrcat ( szSubKey, "\\CurrentVersion" );
#else
    lstrcat ( szSubKey, "\\" );
    lstrcat ( szSubKey, VERSIONSTRING_MACRO(version_string) );
#endif /* CURRENTVERSION */
      
    if ( GetPrivateProfileString (szSubKey,
                                  REFLIST_VALUE,
                                  "",
                                  szRefList,
                                  cchMaxReg,
                                  INI_FILE ) == 0)
    {
      if (!removeFromRegValue ( szRefList, listEntry ))
      {
          remove_flag = 1;
      }
      WritePrivateProfileString (szSubKey,
                                 REFLIST_VALUE,
                                 szRefList,
                                 INI_FILE);
    }
  }
#endif /* FOR_WIN32S */
  sprintf(wrk,"RegRemoveRISEx returns %d", remove_flag);
  WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
  CloseRemoveLogFile();
  return remove_flag;
}

// 1996.03.14:Alan Barksdale:The remInstance parameter is there for upward
//	compatibility.
extern INT RegRemoveRIS(
   HINSTANCE remInstance,
   CHAR *listEntry)
{
  int remove_flag;	/* if true, then RefList is empty and  */
			/* COMPONENT can be removed            */

  WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RegRemoveRIS");

  remove_flag = RegRemoveRISEx(VERSIONSTRING, listEntry);
  
  sprintf(wrk,"RegRemoveRIS returns %d", remove_flag);
  WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
  CloseRemoveLogFile();
  return remove_flag;
}

// 1996.02.07:Alan Barksdale:The peculiar indentation comes from the fact that
//	function is modified from part of RemoveSetupSDK csource\rmprod.c in
//	Setup SDK 02.03.00.00.
static LONG RISDeleteAppPath(
	PTCHAR pathname,
	HWND hwndowner,
	LPCTSTR title,
	LPCTSTR application)
{
    LONG return_status = RMV_CONTINUE;   /* default return value */

          LPTSTR exename = NULL;

          WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RISDeleteAppPath");
          sprintf(wrk, "RISDeleteAppPath:pathname = \"%s\", application = \"%s\"",
             pathname, application);
          WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

          if ( (exename = ISDKStrCatN (5, 
                                       pathname, 
                                       TEXT("\\"),
                                       "bin",
                                       TEXT("\\"),
                                       application)) ) {
              sprintf(wrk, "RISDeleteAppPath:exename = \"%s\"", exename);
              WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
              return_status = RMVDeleteAppPath (hwndowner,
                                       title,
                                       exename);
              ISDKFREE (exename);
          }

          sprintf(wrk,"RISDeleteAppPath returns %d", return_status);
          WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
          return return_status;
}

// 1996.02.07:Alan Barksdale
static LONG RISDeleteAppPaths(
	PTCHAR pathname,
	HWND hwndowner,
	LPCTSTR title)
{
	LONG return_status = RMV_CONTINUE;   /* default return value */

	WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RISDeleteAppPaths");

        if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISBATCH.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISCLNSR.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISDCODE.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISDTYPE.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISGUI.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISINTOP.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISLOD.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISMGR.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISPLBCK.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISRECRD.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISRUN.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISUNLOD.EXE"))) {
        	goto end;
	} else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISCPP.EXE"))) {
        	goto end;
	} else if (!ISDKMatchPlatform(ISm_CHICAGO)) { // 1996.08.09:Alan Barksdale:TR439601698:The manifest.txt file indicates that risupgrd and RLICLIST are not delivered on Win95.
		if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RISUPGRD.EXE"))) {
        		goto end;
		}
	        else if(RMV_CONTINUE != (return_status = RISDeleteAppPath(pathname, hwndowner, title, "RLICLIST.EXE"))) {
			goto end;
		}
	}

	end:

	sprintf(wrk,"RISDeleteAppPaths returns %d", return_status);
	WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
	return return_status;
}


// 1996.02.06:Alan Barksdale:This function is modified from csource\rmprod.c in
//	Setup SDK 02.03.00.00.

// 1996.03.07:Alan Barksdale:I don't include parms because the file should be
//	kept if it's present.  Only for RISCLI are install.log and remove.bat
//	included.
static TCHAR *UnexpectedFiles[] = { 
                                    //".", "d",
                                    NULL
                                  };
static TCHAR *StandaloneFiles0504[] = { 
                                    "..\\i9risu.dll", "f", // 1996.05.15:TR439601118:Alan Barksdale:because this version of the UMS DLL is used only by RIS
                                    "32ssetup.txt", "f",
                                    "bin", "d",  // 1995.08.13:Alan Barksdale:TR439503162
                                    "config", "d", 
                                    "install.log", "f",
                                    "lib", "d",
                                    "manifest.txt", "f",
                                    "readme.txt", "f",
                                    "remove.bat", "f",
                                    NULL 
                                  };
// 1996.03.29:TR439503973:Alan Barksdale:made after looking at old remove code from Pinnacle and SPC
static TCHAR *StandaloneFiles0503[] = { 
                                    "..\\i9risu.dll", "f", // 1996.05.15:TR439601118:Alan Barksdale:because this version of the UMS DLL is used only by RIS
                                    "32ssetup.txt", "f",
                                    "appinfo.txt", "f",
                                    "bin", "d", // 1995.08.13:Alan Barksdale:TR439503162
                                    "config", "d", 
                                    "lib", "d",
                                    "manifest.txt", "f",
                                    "readme.txt", "f",
                                    NULL 
                                  };
static TCHAR *StandaloneFiles0502[] = { 
                                    "bin", "d",
                                    "config", "d", 
                                    "install.log", "f",
                                    "lib", "d",
                                    "manifest.ris", "f",
                                    "readme.ris", "f",
                                    NULL 
                                  };
static TCHAR *StandaloneFiles0501[] = { 
                                    "bin", "d",
                                    "config", "d", 
                                    "install.log", "f",
                                    "lib", "d",
                                    "manifest.ris", "f",
                                    "readme.ris", "f",
                                    NULL 
                                  };
static TCHAR *StandaloneFiles0500[] = { 
                                    "bin", "d",
                                    "config", "d", 
                                    "install.log", "f",
                                    "lib", "d",
                                    "manifest.ris", "f",
                                    "readme.ris", "f",
                                    NULL 
                                  };
static TCHAR *StandaloneFiles0403[] = { 
                                    "bin", "d",
                                    "config", "d", 
                                    "lib", "d",
                                    NULL 
                                  };
/* 1996.02.07:Alan Barksdale:I talked with Rick Kramer after receiving a
	question from Karen Tice.  The RIS shared component historically
	doesn't use an InstallMode registry value.
static TCHAR *WorkstationFiles[] = { NULL };
*/

/******************************************************************************

    SYNOPSIS

    LONG RemoveRISSHARE (HWND hwndowner,
                      LPTSTR title,
                      LPTSTR version_string,
                      PVOID *appdata,
                      BOOLEAN delete_tmp_dir,
                      BOOLEAN ask_delete,
                      PINT remove)


    PARAMETERS

        NAME           ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----           --------------------------------------------------------

        hwndowner      I - handle of owner window for message boxes
        title          I - title to display on message boxes
        version_string I - string of version, e.g., "05.04", of product to
                           delete; if NULL, will assume current version; if not
                           current version, will cause deletion of everything
                           under and including the directory in the PathName
                           registry value
        appdata        I - for a shared component, this is the list entry to
                           remove from the component's reference list; 
                           otherwise, not used 
        delete_tmp_dir I - if TRUE, try to delete the installation executable's
                           temporary directory; if FALSE, don't
        ask_delete     I - if TRUE, ask the end user whether to delete empty
                           directories
        remove         O - for a shared component, this value is TRUE if 
                           the reference list is empty and the component is 
                           removed, and the value is FALSE if the reference
                           list is not empty and the component is not removed;
                           otherwise, not used

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()

    DESCRIPTION

        This is the driver function to remove the SETUPSDK product.

    CHANGE HISTORY

        10-SEP-1994 mwm    Initial creation
        10-MAR-1995 mwm    Set reboot default to NO; change SetCurrentDir
                           error message to display RootPath, not drive
        05-APR-1995 mwm    remove generic.exe check from registry key
        08-FEB-1996 afb    Adapted for RIS shared component.
        14-MAR-1996 afb    At Melania Stewart's request, added the
                           version_string parameter to assist in installation.
        16-APR-1996 afb    Added delete_tmp_dir so that the installation
                           process wouldn't try to delete a directory it was
                           still using.
        16-MAY-1996 afb    Added ask_delete for TR439601110 and TR439601111 on
                           the user's being presented with a box asking him
                           whether to delete a product direcetory during
                           installation of a RIS producut on top of itself.

******************************************************************************/


// LONG RemoveSetupSDK (HWND hwndowner,
static LONG RemoveRISSHARE(HWND hwndowner,
                  LPTSTR title,
                  LPTSTR version_string,
                  PVOID *appdata,
                  BOOLEAN delete_tmp_dir,
                  BOOLEAN ask_delete,
                  PINT remove)

{
    BOOL done;

    DWORD dirs;
    DWORD files;
    // 1996.03.05:AlanBarksdale:DWORD i;
    DWORD keys;
    DWORD values;

    INT platform;
    INT stat;                               

    LONG return_status = RMV_CONTINUE;   /* default return value */

    LPTSTR addr = NULL;                  /* temp var for ISDKGetFullPathName */
    LPTSTR ptr = NULL;                   /* temp var for registry value name */
    LPTSTR systemDir = NULL;
    LPTSTR tmpdir = NULL;

    PTCHAR filename = NULL;
    PTCHAR installmode = NULL;
    PTCHAR pathname = NULL;
    PTCHAR prodno = NULL;

    TCHAR **filelist = NULL;

    /*
    ** The LPCTSTR args[] array is used extensively for messages throughout 
    ** this program.  Currently, its array size is determined by the number 
    ** of program items, the largest group of items loaded at one time.
    */

    LPCTSTR args[5];    

    char full_versionstring_key[cchMax];

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RemoveRISSHARE");
    assert(strlen(VERSIONSTRING) == strlen(VERSIONSTRING_MACRO(version_string)));

    /*
    ** If I'm a shared component, the first thing I have to do is determine
    ** if I am going to be removed.  I'll call FUNCTION3() in the shareapp.c
    ** with appdata as input (the reference list component that represents
    ** the calling application) to make this determination.  This function
    ** returns FALSE if the component is not to be removed.
    **
    ** if ( ! (*remove = FUNCTION3 ( (CHAR)*appdata) ) ) goto end;
    **
    ** If I'm a shared component, I'll check to see if the registry entry
    ** and default directory for shared components needs to be removed.
    **
    ** 
    ** RMVComponentCleanup (hwndowner, title);
    */

    WriteToRemoveLogFile(__FILE__, __LINE__, // 1996.04.29:Alan Barksdale:TR43900766
        "RemoveRISSHARE:Stop and delete the current RIS TCP service and then start a new TCP service if there's a higher version on the machine.");
    RISRemoveTcpService(); // 1996.02.08:Alan Barksdale

    /*
    ** The rest of this function is devoted to the removal of the Setup 
    ** Toolkit.  Make changes as required for your application/component.
    **
    ** Query the product registry key to find out where this product is
    ** delivered.  First, look at the InstallMode value.  If this is a
    ** workstation install, the product's root path is stored in the 
    ** LocalPathName value.  If this is a standalone install, the product's
    ** root path is stored in the Pathname value.  If we can't retrieve
    ** a registry value, force a return (could be an administrator install.)
    */

    /* replace these functions with a INGRQueryRegValue type function */
    /* there should be a matching INGRSetRegValue function */

    /* determine installation type */

    platform = ISDKGetPlatform();
    systemDir = ISDKGetDirectory (SYSTEM_DIR);

    /*
    ** "installmode" must be set before we can check its value.  If its value
    ** is not what we expect, don't set the ptr value but set an error code.
    ** In this manner, both installmode and ptr must be set to continue.
    */

    /* 1996.02.07:Alan Barksdale:vvv I talked with Rick Kramer after receiving a
	question from Karen Tice.  The RIS shared component historically
	doesn't use an InstallMode registry value.
    if ( (installmode = INGRGetRegValue (PRODUCTNAME,
                                         VERSIONSTRING_MACRO(version_string),
                                         INSTALLMODE_VALUE)) ) {
        if ( strcmpi (installmode, STANDALONE_MODE) == 0 ) {
    1996.02.07:Alan Barksdale:^^^ */
            ptr = PATHNAME_VALUE;
            if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.04") ) {
                filelist = StandaloneFiles0504;
            } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.03") ) {
                filelist = StandaloneFiles0503;
            } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.02") ) {
                filelist = StandaloneFiles0502;
            } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.01") ) {
                filelist = StandaloneFiles0501;
            } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.00") ) {
                filelist = StandaloneFiles0500;
            } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "04.03") ) {
                filelist = StandaloneFiles0403;
            } else {
                filelist = UnexpectedFiles;
                sprintf(wrk,
                    "RISRemoveRISSHARE:version_string \"%s\" unexpected; therefore will delete none of the contents of the product directory",
                    STRING(VERSIONSTRING_MACRO(version_string)));
                WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
            }
    /* 1996.02.07:Alan Barksdale:vvv RIS shared component doesn't use an InstallMode registry value.
        } else if ( strcmpi (installmode, WORKSTATION_MODE) == 0 ) {
            ptr = LOCALPATHNAME_VALUE;
            filelist = WorkstationFiles;
        } else {
            SetLastError (ERROR_INVALID_PARAMETER);
        }
    }

    strcpy(full_versionstring_key, HKEY_LOCAL "\\" PRODUCTNAME_KEY "\\");
    strcat(full_versionstring_key, VERSIONSTRING_MACRO(version_string));
    sprintf(wrk, "RISRemoveRISSHARE:full_versionstring_key = \"%s\"",
        full_versionstring_key);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

    if ( ! installmode || ! ptr ) {
        WriteToRemoveLogFile(__FILE__, __LINE__,
            "RISRemoveRISSHARE:install mode registry path error");

        IF_SILENTMODE_END(RMV_ABORT);

        if ( ISDKMatchPlatform (ISm_NT31        |  
                                ISm_DAYTONA     |
                                ISm_DAYTONA_351 |
                                ISm_CHICAGO     |
                                ISm_NT40) ) {
                    
            args[0] = ISDKStrCatN (3,
                                   TEXT(full_versionstring_key),
                                   TEXT("\\"),
                                   INSTALLMODE_VALUE);

        } else if ( platform == IS_WIN32S ) {

            args[0] = ISDKStrCatN (5,
                                   INGRGetIngrIniName(),
                                   "\\",
                                   INI_SECTION,
                                   "\\",
                                   INSTALLMODE_VALUE);
        }

        args[1] = ISDKLastErrorText (RMVGetLangId(),
                                     RMVGetMessageLen());
        
        ISDKStringIdBox (hwndowner,
                         RMVGetResourceDll(),
                         args,
                         REGISTRY_PATH_ERROR,
                         RMVGetLangId(),
                         title,
                         RMVGetMessageLen(),
                         MB_ICONSTOP);

        UpdateWindow (hwndowner);
            
        if (args[0]) free ((PVOID)args[0]);
        if (args[1]) LocalFree ((HLOCAL)args[1]);
            
        WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
        return_status = RMV_ABORT;
        goto end;

    }
    1996.02.07:Alan Barksdale:^^^ */

    if ( ! (pathname = INGRGetRegValue (PRODUCTNAME,
                                        VERSIONSTRING_MACRO(version_string),
                                        ptr)) ) {
        WriteToRemoveLogFile(__FILE__, __LINE__,
            "RISRemoveRISSHARE:path name registry path error");

        IF_SILENTMODE_END(RMV_ABORT);

        if ( ISDKMatchPlatform (ISm_NT31        |
                                ISm_DAYTONA     |
                                ISm_DAYTONA_351 |
                                ISm_CHICAGO     |
                                ISm_NT40 ) ) {
                    
            args[0] = ISDKStrCatN (3,
                                   TEXT(full_versionstring_key),
                                   TEXT("\\"),
                                   PATHNAME_VALUE);

        } else if ( platform == IS_WIN32S ) {

            args[0] = ISDKStrCatN (5,
                                   INGRGetIngrIniName(),
                                   "\\",
                                   INI_SECTION,
                                   "\\",
                                   PATHNAME_VALUE);
        }

        args[1] = ISDKLastErrorText (RMVGetLangId(),
                                     RMVGetMessageLen());
        
        ISDKStringIdBox (hwndowner,
                         RMVGetResourceDll(),
                         args,
                         REGISTRY_PATH_ERROR,
                         RMVGetLangId(),
                         title,
                         RMVGetMessageLen(),
                         MB_ICONSTOP);

        UpdateWindow (hwndowner);
            
        if (args[0]) free ((PVOID)args[0]);
        if (args[1]) LocalFree ((HLOCAL)args[1]);
            
        WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
        return_status = RMV_ABORT;
        goto end;

    }
    sprintf(wrk,"RemoveRISSHARE:pathname = \"%s\"", pathname);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

    if ( ! (prodno = INGRGetRegValue (PRODUCTNAME,
                                      VERSIONSTRING_MACRO(version_string),
                                      IDNUMBER_VALUE)) ) {

        done = FALSE;
        while ( ! done ) {

            SILENTMODE_BREAK;

            if ( ISDKMatchPlatform (ISm_NT31        |
                                    ISm_DAYTONA     |
                                    ISm_DAYTONA_351 |
                                    ISm_CHICAGO     |
                                    ISm_NT40) ) {
                    
                args[0] = ISDKStrCatN (3,
                                       TEXT(full_versionstring_key),
                                       TEXT("\\"),
                                       IDNUMBER_VALUE);

            } else if ( platform == IS_WIN32S ) {
    
                args[0] = ISDKStrCatN (5,
                                       INGRGetIngrIniName(),
                                       "\\",
                                       INI_SECTION,
                                       "\\",
                                       IDNUMBER_VALUE);
            }

            args[1] = ISDKLastErrorText (RMVGetLangId(),
                                         RMVGetMessageLen());
        
            stat = ISDKStringIdBox (hwndowner,
                             RMVGetResourceDll(),
                             args,
                             REGISTRY_PATH_ERROR,
                             RMVGetLangId(),
                             title,
                             RMVGetMessageLen(),
                            MB_ICONEXCLAMATION | MB_ABORTRETRYIGNORE);

            UpdateWindow (hwndowner);

            if (args[0]) free ((PVOID)args[0]);
            if (args[1]) LocalFree ((HLOCAL)args[1]);
                        
            if ( stat == IDIGNORE ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_IGNORE;
                done = TRUE;
            } else if ( stat == IDABORT ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_ABORT;
                goto end;
            } else if ( stat == 0 ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_SYSERR;
                goto end;
            }
        }
    }
    sprintf(wrk,"RemoveRISSHARE:prodno = \"%s\"", prodno);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

    if(delete_tmp_dir) {
        /*
        ** Thank you Windows 95.  Since we can't guarantee the setup program 
        ** cleaned up after itself, use this little bit of code to the delete
        ** the temporary directory (stored during setup).  Make sure a something
        ** exists in the value, or the delete will be performed on the current
        ** directory.
        */
        /* 1996.02.01:Alan Barksdale:If I understood Mike Metheny correctly,
           this code is a kludge to handle the fast machines where the attempt
           during installation to delete the temporary installation directory
           might fail because the machine had not yet released all the files in
           that directory. */

        if ( (tmpdir = INGRGetRegValue (PRODUCTNAME,
                                        VERSIONSTRING_MACRO(version_string),
                                        TEMPDELIVERYDIR_VALUE)) && *tmpdir ) {

            if ( ISDKDirFilesExist (tmpdir, 
                                    RMVGetPathSeparator(),
                                    NULL,
                                    NULL) ) { 

                stat = RMVDeleteDirectory (hwndowner, 
                                           title, 
                                           tmpdir);
                if ( stat == RMV_IGNORE ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                    return_status = stat;
                } else if ( stat == RMV_ABORT ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                    return_status = stat;
                    goto end;
                } else if ( stat == RMV_SYSERR ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                    return_status = stat;
                    goto end;
                }
            
            }

            ISDKFREE (tmpdir);
        }
        WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE");
    } // if(delete_tmp_dir)

    /*
    ** Time to begin.  Check to see if the root path points to a valid 
    ** directory.  If the directory is valid, we perform the required file 
    ** manipulations.  If the directory is not valid, indicate the error and 
    ** let the user determine whether to proceed.  Note:  all file handling 
    ** functions do not consider a file/path not found to be an error via the 
    ** macro GETLASTERROR_CHECK() with the appropriate error code.
    */

    if ( ! ISDKDirFilesExist (pathname, 
                              RMVGetPathSeparator(),
                              NULL,
                              NULL) ) { 

        done = FALSE;
        while ( ! done ) {

            SILENTMODE_BREAK;

            args[0] = pathname;
            args[1] = ISDKLastErrorText (RMVGetLangId(),
                                         RMVGetMessageLen());
            
            stat = ISDKStringIdBox (hwndowner,
                                    RMVGetResourceDll(),
                                    args,
                                    ROOT_DIRECTORY_ERROR,
                                    RMVGetLangId(),
                                    title,
                                    RMVGetMessageLen(),
                                    MB_ICONEXCLAMATION | MB_ABORTRETRYIGNORE);

            UpdateWindow (hwndowner);

            if (args[1]) LocalFree ((HLOCAL)args[1]);
    
            if ( stat == IDIGNORE ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_IGNORE;
                done = TRUE;
            } else if ( stat == IDABORT ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_ABORT;
                goto end;
            } else if ( stat == 0 ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_SYSERR;
                goto end;
            }
        }
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE");

    /*
    ** First thing we'll do is move our current directory to our RootPath.  
    ** This will allow us to generate our full path names to our remove.exe
    ** and resource dll.  Since we now mark these files to be deleted on
    ** reboot, this process is allowed since our current directory is not
    ** deleted. (Not really good, but we don't know if we created the 
    ** directory or loaded into an existing directory, among other things.)
    */
    
    done = FALSE;
    while ( ! done ) {

        if ( ! SetCurrentDirectory ("\\") ) {

            SILENTMODE_BREAK;

            args[0] = "\\";
            args[1] = ISDKLastErrorText (RMVGetLangId(),
                                         RMVGetMessageLen());

            stat = ISDKStringIdBox (hwndowner,
                                    RMVGetResourceDll(),
                                    args,
                                    CHANGE_DIRECTORY_ERROR,
                                    RMVGetLangId(),
                                    title,
                                    RMVGetMessageLen(),
                                    MB_ICONEXCLAMATION | MB_ABORTRETRYIGNORE);

            UpdateWindow (hwndowner);

            if (args[1]) LocalFree ((HLOCAL)args[1]);

            if ( stat == IDIGNORE ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_IGNORE;
                done = TRUE;
            } else if ( stat == IDABORT ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_ABORT;
                goto end;
            } else if ( stat == 0 ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_SYSERR;
                goto end;
            }
        } else {
            done = TRUE;    /* directory successfully moved */
        }
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE");

    /*
    ** Delete our known product list.  If we are successful, only our
    ** remove.exe and our resource dll should be left in the root product 
    ** directory from the files we delivered.  Do not continue the remove 
    ** process if we receive any sort of error indication from this operation.
    ** Display an error message allowing the user the option to retry or
    ** exit the remove process.
    */

    done = FALSE;
    while ( ! done ) {

        stat = RMVDeleteProductFiles (hwndowner, 
                                      title, 
                                      filelist, 
                                      pathname);

        if ( (stat == RMV_ABORT) || (stat == RMV_SYSERR) ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
            return_status = stat;
            goto end;
        } else if ( stat == RMV_IGNORE ) {
            
            SILENTMODE_BREAK;

            stat = ISDKStringIdBox (hwndowner,
                                    RMVGetResourceDll(),
                                    args,
                                    PRODUCT_DELETE_ERROR,
                                    RMVGetLangId(),
                                    title,
                                    RMVGetMessageLen(),
                                    MB_ICONEXCLAMATION | MB_ABORTRETRYIGNORE);

            UpdateWindow (hwndowner);

            if ( stat == IDIGNORE ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_IGNORE;
                done = TRUE;
            } else if ( stat == IDABORT ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_ABORT;
                goto end;
            } else if ( stat == 0 ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                return_status = RMV_SYSERR;
                goto end;
            }

        } else {
            done = TRUE;
        }
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE");

    if ( stat == RMV_CONTINUE && (! RMVGetSilentMode ()) ) {

        /* 
        ** Look at our installation directory to see if it's clean.  If there
        ** are files left in this directory, ask the user to delete this 
        ** directory.  If there are files in this directory or we are running
        ** in silent mode, do not even ask to delete it.  This test should
        ** only work in the case of a workstation remove.
        */

        if ( ISDKDirFilesExist (pathname, 
                                RMVGetPathSeparator(),
                                &dirs,
                                &files) && ! dirs && ! files ) {

            if(ask_delete) {
                args[0] = pathname;
            
                stat = ISDKStringIdBox (hwndowner,
                                        RMVGetResourceDll(),
                                        args,
                                        ROOTPATH_CLEAN,
                                        RMVGetLangId(),
                                        title,
                                        RMVGetMessageLen(),
                                        MB_ICONEXCLAMATION | MB_YESNO );
            
                UpdateWindow (hwndowner);
            }
            
            if ( !ask_delete || stat == IDYES ) {
                
                stat = RMVDeleteDirectory (hwndowner, 
                                           title, 
                                           pathname);
                if ( stat == RMV_IGNORE ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                    return_status = stat;
                } else if ( stat == RMV_ABORT ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                    return_status = stat;
                    goto end;
                } else if ( stat == RMV_SYSERR ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                    return_status = stat;
                    goto end;
                }
                
            }
        }
    } else if ( stat == RMV_IGNORE ) {
        WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
        return_status = RMV_IGNORE;
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE");

    /* 
    ** Now we try to delete the program groups. Since we
    ** don't do error checking here, we delete any icon we may create on 
    ** install since we don't track the type of installation (yet).
    */


    {
      char szProgramGroup[sizeof(RISPROGGROUP)]; // 1996.03.26:Alan Barksdale:to handle deleting old versions
      char *szVersion;
/* 1996.02.22:Alan Barksdale:vvv:Am using RISPROGGROUP instead of IDS_PM_TITLE
	because of special case of shared component.
      LPCTSTR group = NULL;

      if ( ! (group = ISDKLoadString (RMVGetResourceDll(), IDS_PM_TITLE)) ) {

          /@ to be replaced with ResourceError() @/

          LPCTSTR args[1];

          args[0] = ISDKLastErrorText (GetUserDefaultLangID(), 
                                       RMVMESSAGELEN);

          ISDKStringIdBox (GetActiveWindow(),
                           NULL,
                           args,
                           RESOURCE_STRING_ERROR,
                           GetUserDefaultLangID(),
                           NULL,
                           RMVMESSAGELEN,
                           MB_ICONSTOP);

          ISDKTSTLOCALFREE (args[0]);

          WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:goto end");
          goto end;
      }
1996.02.22:Alan Barksdale:^^^ */

      strcpy(szProgramGroup, RISPROGGROUP);
      szVersion = szProgramGroup + strlen(szProgramGroup) - strlen(VERSIONSTRING);
      strcpy(szVersion, VERSIONSTRING_MACRO(version_string));
    
      stat = RMVDeleteProgramGroup (GetActiveWindow(),
                                    NULL,
                                    szProgramGroup, //RISPROGGROUP, //group,
                                    COMMON_PROGRAM_GROUP);

/* 1996.02.22:Alan Barksdale:vvv:Am using RISPROGGROUP instead of IDS_PM_TITLE
      ISDKLOCALFREE (group);
1996.02.22:Alan Barksdale:^^^ */

      if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
          WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
          return_status = stat;
          goto end;
      } else if ( stat == RMV_IGNORE ) {
          WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
          return_status = RMV_IGNORE;
      }
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE");
  
    /*
    ** Now its time to clean up our registry info.  Recursively delete the
    ** version string key.  If this is successful, look at the product name
    ** key in the registry.  If this key is clean, delete it; otherwise, leave
    ** it alone since some other verison may be installed.  Errors from here
    ** on offer no retry logic and you're on your own.  Once we delete our
    ** PATHNAME_VALUE, remove.exe will not function.
    */
    
    stat = RMVDeleteIngrRegistry (hwndowner,
                                  title,
                                  HKEY_LOCAL_MACHINE,
                                  PRODUCTNAME, 
                                  VERSIONSTRING_MACRO(version_string));
        
    if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
        WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
        return_status = stat;
        goto end;
    } else if ( stat == RMV_IGNORE ) {
        WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
        return_status = RMV_IGNORE;
    } else if ( ISDKKeyValuesExist (HKEY_LOCAL_MACHINE,
                                    INTERGRAPH_KEY,
                                    RMVGetPathSeparator(),
                                    &keys,
                                    &values) && ! keys) {

        stat = RMVDeleteRegistry (hwndowner,
                                  title,
                                  HKEY_LOCAL_MACHINE,
                                  SOFTWARE_KEY,
                                  INTERGRAPH);
        if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
            return_status = stat;
            goto end;
        } else if ( stat == RMV_IGNORE ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
            return_status = RMV_IGNORE;
        }
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE");

    if ( ISDKMatchPlatform (ISm_CHICAGO | ISm_NT40) ) {

        /*
        ** If we're on Chicago or NT 4.0, we've placed some information in 
        ** the Uninstall key so have to remove it.
        */  

        stat = RMVDeleteRegistry (hwndowner,
                                  title,
                                  HKEY_LOCAL_MACHINE,
                                  UNINSTALL_KEY,
                                  PRODUCTNAME);
        
        if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
            return_status = stat;
        } else if ( stat == RMV_IGNORE ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
            return_status = RMV_IGNORE;
        }

        /*
        ** This code will delete an item placed in the Start Menu 
        **
        ** if ( (args[0] = ISDKLoadString (RMVGetResourceDll(), 
        **                                 IDS_PM_ITEM1)) ) {
        **     args[1] = NULL;
        **     stat = RMVDeleteProgramItems (hwndowner,
        **                                   title,
        **                                   "..",
        **                                   args,
        **                                   COMMON_PROGRAM_GROUP);
        **      
        **     ISDKLOCALFREE (args[0]);
        ** }
        */
    
        /* 
        ** If we're on Chicago/NT40, we have to clean up any per-application
        ** paths
        */


        /* 1996.02.07:Alan Barksdale:vvv Using special function because of quantity.
        {
          LPTSTR exename = NULL;

          if ( (exename = ISDKStrCatN (2, 
                                       pathname, 
                                       "generic.exe")) ) {
              stat = RMVDeleteAppPath (hwndowner,
                                       title,
                                       exename);
              ISDKFREE (exename);

              if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
                  WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                  return_status = stat;
                  goto end;
              } else if ( stat == RMV_IGNORE ) {
                  WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                  return_status = RMV_IGNORE;
              }
          }
        }
        1996.02.07:Alan Barksdale:^^^vvv */
        stat = RISDeleteAppPaths(pathname, hwndowner, title);
        if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
            return_status = stat;
            goto end;
        } else if ( stat == RMV_IGNORE ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
            return_status = RMV_IGNORE;
        }
        /* 1996.02.05:Alan Barksdale:^^^ */
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE");


    /* 1996.03.05:Alan Barksdale:vvv Unused; see riscli\setup32\rmprod\rmprod.c.
    /@ 
    ** Mark our files for delete if this is a standalone installation.  
    ** If we are successful, reboot the machine.
    @/

    if ( strcmpi (installmode, STANDALONE_MODE) == 0 ) {

        TCHAR *MoveFileList[4] = { NULL, NULL, NULL, NULL };
        MoveFileList[0] = ISDKStrCatN (2, 
                                       systemDir, 
                                       "rm000014.exe");
        MoveFileList[1] = ISDKStrCatN (2, 
                                       systemDir, 
                                       "rm000014.dl1");

        for ( i = 0; 
              i < sizeof (MoveFileList) / sizeof (*MoveFileList);
              i++) {

            sprintf(wrk,"RemoveRISSHARE:MoveFileList[%d] = \"%s\"", i,
                MoveFileList[i]);
            WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
            if ( MoveFileList[i] ) {
                stat = RMVMoveFileDelete (hwndowner,
                                          title,
                                          MoveFileList[i]);
                
                free (MoveFileList[i]);
                
                if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                    return_status = stat;
                    goto end;
                } else if ( stat == RMV_IGNORE ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE:return_status set");
                    return_status = RMV_IGNORE;
                }
            }
        }
    }

    /@ post remove function @/

    
    if ( RMVGetReboot() && ! RMVGetSilentMode () ) {

        stat = ISDKStringIdBox (hwndowner,
                                RMVGetResourceDll(),
                                NULL,
                                REMOVE_REBOOT,
                                RMVGetLangId(),
                                title,
                                RMVGetMessageLen(),
                                MB_ICONEXCLAMATION | 
                                MB_YESNO | MB_DEFBUTTON2);
        
        UpdateWindow (hwndowner);
            
        if ( stat == IDYES ) RMVExitWindows (EWX_REBOOT);

    }
    1996.03.05:Alan Barksdale:^^^ */
        
  end:
    WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISSHARE");

    /*
    ** If we are running batch (silent) mode, we need to log a success or
    ** failure.  Anything other than RMV_CONTINUE is considered to be an
    ** error.
    */

    if ( RMVGetSilentMode() ) {   
        if ( return_status == RMV_CONTINUE ) {
            done = TRUE;
        } else {
            done = FALSE;
        }   

        INGRLogResult (REMOVE,
                       done,
                       PRODUCTNAME,
                       prodno,
                       pathname,
                       0);
    }

    ISDKTSTFREE (systemDir);
    ISDKTSTFREE (pathname);
    ISDKTSTFREE (prodno); 
    ISDKTSTFREE (filename);

    sprintf(wrk,"RemoveRISSHARE returns %d", return_status);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    return return_status;
}

// 1996.03.14:Alan Barksdale
extern void RemoveRISEx ( 
        LPTSTR version_string,
        BOOLEAN delete_tmp_dir,
        BOOLEAN ask_delete,
	int remove_flag)
{
	WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RemoveRISEx");
	sprintf(wrk, "RemoveRISEx:version_string = \"%s\", remove_flag = %d",
		STRING(version_string), remove_flag);
	WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

	if(remove_flag)
	{
		RemoveRISSHARE(NULL, RMVGetTitle(), version_string, NULL,
			delete_tmp_dir, ask_delete, NULL);
	}

	WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRISEx returns void");
	CloseRemoveLogFile();
}

/* Applications must call RegRemoveRIS first and pass in the return */
// 1996.02.08:Alan Barksdale:The remInstance parameter is there for upward
//	compatibility.
extern void RemoveRIS ( 
	HINSTANCE remInstance,
	int remove_flag)
{
	WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RemoveRIS");
	sprintf(wrk, "RemoveRIS:remove_flag = %d", remove_flag);
	WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

	RemoveRISEx(VERSIONSTRING, TRUE, TRUE, remove_flag);

	WriteToRemoveLogFile(__FILE__, __LINE__, "RemoveRIS returns void");
	CloseRemoveLogFile();
}
