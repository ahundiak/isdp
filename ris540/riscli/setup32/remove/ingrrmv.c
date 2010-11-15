// 1996.05.15:Alan Barksdale:This file is the same as csource\ingrrmv.c from
// Setup SDK 2.3.1.2 except for some log writing function calls, a fix to 
// RMVResourceInitializeEx, and some hardcoded values added to
// RMVResourceInitializeEx and Defaults in case an executable linked with
// risrem.lib does not include information from Setup SDK's cuirsc.rc and/or
// doesn't call RMVResourceInitializeEx (TR439601094).

#include <stdio.h>
#include <windows.h>
#include <tchar.h>
#include <wchar.h>

#include "ddeprog.h"
#include "isdk.h"
#include "cuirsc.h"
#include "ingrreg.h"
#include "ingrw95.h"

#include "ingrrmv.h"

#include "risrem.h"
#include "ingrbld.h" // for cchMax


static struct rmv_defaults {

    LONG      ErrorMode;          // error to return with silent mode on
    BOOL      SilentMode;         // display message boxes
    BOOL      NeedReboot;         // files are marked for delete on next reboot

    WCHAR     PathSeparator;      // path separator for file names, usually "\"
    WCHAR     RegListSeparator;   // list separator for registry, usually ";"
    WCHAR     SwitchFlag1;        // command line argument switch, usually "/"
    WCHAR     SwitchFlag2;        // command line argument switch, usually "-"
    WCHAR     SilentSwitch;       // command line argument silent switch

    PTCHAR    Title;              // title to display

    LCID      LocaleId;           // locale identifier
    LANGID    LangId;             // language identifier

    HINSTANCE ResourceDll;        // handle to resource dll, or this process
    TCHAR     DllName[_MAX_PATH]; // this field is no longer used

    DWORD     MessageLen;         // message box width

} Defaults =	{
			RMV_ABORT,	// ErrorMode
			FALSE,		// SilentMode
			FALSE,		// NeedReboot
			L'\\',		// PathSeparator
			L';',		// RegListSeparator
			L'/',		// SwitchFlag1
			L'-',		// SwitchFlag2
			L's',		// SilentSwitch
			NULL,		// Title
			(LCID)NULL,	// LocaleId
			(LANGID)NULL,	// LangId
			NULL,		// ResourceDll
			"",		// DllName
			RMVMESSAGELEN	// MessageLen
		};

static char wrk[cchMax]; // 1996.01.26:Alan Barksdale:imitating Rick Kramer's debug code

VOID RMVResourceInitialize () 
{

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RMVResourceInitialize");
    RMVResourceInitializeEx (NULL);
    WriteToRemoveLogFile(__FILE__, __LINE__,
       "RMVResourceInitialize returns VOID");

}

VOID RMVResourceInitializeEx (HINSTANCE dll)
{
    LPTSTR dname = NULL;
    LPTSTR str = NULL;
    PCHAR pchr = NULL;

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RMVResourceInitializeEx");
    sprintf(wrk, "RMVResourceInitializeEx:dll = %#x", dll);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

    Defaults.ResourceDll = dll;  // 1996.04.16:Alan Barksdale:Mike Metheny says he'll put my fix into the next version of Setup SDK after 2.3.1.2.

    Defaults.ErrorMode = RMV_ABORT;
    Defaults.SilentMode = FALSE;
    Defaults.NeedReboot = FALSE;

    if ( ! (Defaults.LocaleId = GetUserDefaultLCID()) ) {
        Defaults.LocaleId = GetSystemDefaultLCID();
    }

    Defaults.LangId = LANGIDFROMLCID (Defaults.LocaleId);

    Defaults.Title = ISDKLoadString (Defaults.ResourceDll, IDS_TITLE);

    // 1996.05.14:Alan Barksdale:hardcoding several values in case executable linked with risrem.lib doesn't use cuirsc.rc

    if ( (pchr = ISDKLoadStringA (Defaults.ResourceDll, IDS_PATHSEP)) ) {
        mbtowc (&Defaults.PathSeparator, pchr, MB_CUR_MAX);
        LocalFree (pchr);
    } else {
        Defaults.PathSeparator = L'\\';
    }

    if ( (pchr = ISDKLoadStringA (Defaults.ResourceDll, IDS_REGLISTSEP)) ) {
        mbtowc (&Defaults.RegListSeparator, pchr, MB_CUR_MAX);
        LocalFree (pchr);
    } else {
        Defaults.RegListSeparator = L';';
    }

    if ( (pchr = ISDKLoadStringA (Defaults.ResourceDll, IDS_CMDSWITCH_1)) ) {
        mbtowc (&Defaults.SwitchFlag1, pchr, MB_CUR_MAX);
        LocalFree (pchr);
    } else {
        Defaults.SwitchFlag1 = L'/';
    }

    if ( (pchr = ISDKLoadStringA (Defaults.ResourceDll, IDS_CMDSWITCH_2)) ) {
        mbtowc (&Defaults.SwitchFlag2, pchr, MB_CUR_MAX);
        LocalFree (pchr);
    } else {
        Defaults.SwitchFlag2 = L'-';
    }

    if ( (pchr = ISDKLoadStringA (Defaults.ResourceDll, IDS_SILENTSWITCH)) ) {
        mbtowc (&Defaults.SilentSwitch, pchr, MB_CUR_MAX);
        LocalFree (pchr);
    } else {
        Defaults.SilentSwitch = L's';
    }

    if ( (str = ISDKLoadStringA (Defaults.ResourceDll, IDS_MESSAGELEN)) ) {

        if ( ! sscanf (str, "%d", &Defaults.MessageLen) ) {
            Defaults.MessageLen = RMVMESSAGELEN;
        }

        ISDKLOCALFREE (str);

    } else {
        Defaults.MessageLen = RMVMESSAGELEN;
    }
    
    WriteToRemoveLogFile(__FILE__, __LINE__,
        "RMVResourceInitializeEx returns VOID");
    CloseRemoveLogFile();
}


LONG RMVGetErrorMode ()
{
    return (Defaults.ErrorMode);
}


VOID RMVSetErrorMode (LONG mode)
{
    Defaults.ErrorMode = (mode == RMV_IGNORE ? RMV_IGNORE : RMV_ABORT);
}


BOOL RMVGetSilentMode ()
{
    return (Defaults.SilentMode);
}


VOID RMVSetSilentMode (BOOL flag)
{
    Defaults.SilentMode = flag;
}


BOOL RMVGetReboot ()
{
    return (Defaults.NeedReboot);
}


VOID RMVSetReboot (BOOL flag)
{
    Defaults.NeedReboot = flag;
}


PTCHAR RMVGetTitle ()
{
    if(Defaults.Title)
    {
       sprintf(wrk, "RMVGetTitle started and returns \"%s\"", Defaults.Title);
    } else {
       sprintf(wrk, "RMVGetTitle started and returns NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    return (Defaults.Title);
}


WCHAR RMVGetPathSeparator ()
{
    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RMVGetPathSeparator");
    sprintf(wrk, "RMVGetPathSeparator returns %#x", Defaults.PathSeparator);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    return (Defaults.PathSeparator);
}

WCHAR RMVGetRegListSeparator ()
{
    return (Defaults.RegListSeparator);
}


WCHAR RMVGetSwitchFlag1 ()
{
    return (Defaults.SwitchFlag1);
}


WCHAR RMVGetSwitchFlag2 ()
{
    return (Defaults.SwitchFlag2);
}


WCHAR RMVGetSilentSwitch ()
{
    return (Defaults.SilentSwitch);
}


LCID RMVGetLocaleId ()
{
    if ( ! (Defaults.LocaleId = GetUserDefaultLCID()) ) {
        Defaults.LocaleId = GetSystemDefaultLCID();
    }
    return (Defaults.LocaleId);
}


LANGID RMVGetLangId ()
{
    if(!Defaults.LangId) {
        Defaults.LangId = LANGIDFROMLCID (Defaults.LocaleId);
    }
    return (Defaults.LangId);
}


HINSTANCE RMVGetResourceDll ()
{
    return (Defaults.ResourceDll);
}


PTCHAR RMVGetResourceDllName ()      // this field no longer used
{
    return (&Defaults.DllName[0]);
}


DWORD RMVGetMessageLen ()
{
     return (Defaults.MessageLen);
}



/******************************************************************************

    SYNOPSIS

        LONG RMVDeleteFile (HWND hwndowner,
                            LPCTSTR title,
                            LPCTSTR file)

    PARAMETERS

        NAME          ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----          --------------------------------------------------------

        hwndowner     I - handle of owner window
        title         I - title to display on message boxes
        file          I - file to delete

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()

    DESCRIPTION

        This function deletes the input file.  

    CHANGE HISTORY

        10-MAR-1995    mwm    Initial creation

******************************************************************************/

LONG RMVDeleteFile (HWND hwndowner,
                    LPCTSTR title,
                    LPCTSTR file)

{

    BOOL done;

    LONG return_status;
    LONG stat;

    LPCTSTR args[4] = {NULL, NULL, NULL, NULL};

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RMVDeleteFile");
    if(title) {
        sprintf(wrk,"RMVDeleteFile:title = \"%s\"", title);
    } else {
        sprintf(wrk,"RMVDeleteFile:title = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    if(file) {
        sprintf(wrk,"RMVDeleteFile:file = \"%s\"", file);
    } else {
        sprintf(wrk,"RMVDeleteFile:file = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

    return_status = RMV_CONTINUE;
    WriteToRemoveLogFile(__FILE__, __LINE__,
        "RMVDeleteFile:return_status set");

    done = FALSE;
    while ( ! done ) {
        
        if ( ! ISDKDeleteFile (file, TRUE) ) {
            
            GETLASTERROR_BREAK(ERROR_PATH_NOT_FOUND);
            GETLASTERROR_BREAK(ERROR_FILE_NOT_FOUND);
            SILENTMODE_BREAK;
            
            args[0] = file;
            args[1] = ISDKLastErrorText (RMVGetLangId(),
                                         RMVMESSAGELEN);
            
            stat = ISDKStringIdBox (hwndowner,
                                    RMVGetResourceDll(),
                                    args,
                                    FILE_DELETE_ERROR,
                                    RMVGetLangId(),
                                    title,
                                    RMVMESSAGELEN,
                                    MB_ICONEXCLAMATION | MB_ABORTRETRYIGNORE);
            
            UpdateWindow (hwndowner);
            
            if ( args[1] ) LocalFree ((HLOCAL)args[1]);

            if ( stat == IDIGNORE ) {
                return_status = RMV_IGNORE;
                WriteToRemoveLogFile(__FILE__, __LINE__,
                    "RMVDeleteFile:return_status set");
                done = TRUE;
            } else if ( stat == IDABORT ) {
                return_status = RMV_ABORT;
                WriteToRemoveLogFile(__FILE__, __LINE__,
                    "RMVDeleteFile:return_status set");
                done = TRUE;
            } else if ( stat == 0 ) {
                sprintf(wrk, "RMVDeleteFile:GetLastError() = %ld",
                    GetLastError());
                WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
                return_status = RMV_SYSERR;
                WriteToRemoveLogFile(__FILE__, __LINE__,
                    "RMVDeleteFile:return_status set");
                done = TRUE;
            }
        } else {
            done = TRUE;  /* directory successfully deleted */
        }
    }

  end:
    sprintf(wrk, "RMVDeleteFile returns %d", return_status);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    return return_status;
}


/******************************************************************************

    SYNOPSIS

        LONG RMVDeleteDirectory (HWND hwndowner,
                                 LPCTSTR title,
                                 LPCTSTR dir)

    PARAMETERS

        NAME          ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----          --------------------------------------------------------

        hwndowner     I - handle of owner window
        title         I - title to display on message boxes
        dir           I - directory to delete

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()

    DESCRIPTION

        This function deletes all files and directories contained in the 
        specified directory, and then deletes the directory.

    CHANGE HISTORY

        10-OCT-1994    mwm    Initial creation

******************************************************************************/

LONG RMVDeleteDirectory (HWND hwndowner,
                         LPCTSTR title,
                         LPCTSTR dir)

{

    BOOL done;

    LONG return_status;
    LONG stat;

    LPCTSTR args[4] = {NULL, NULL, NULL, NULL};

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RMVDeleteDirectory");
    if(title) {
        sprintf(wrk,"RMVDeleteDirectory:title = \"%s\"", title);
    } else {
        sprintf(wrk,"RMVDeleteDirectory:title = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    if(dir) {
        sprintf(wrk,"RMVDeleteDirectory:dir = \"%s\"", dir);
    } else {
        sprintf(wrk,"RMVDeleteDirectory:dir = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

    return_status = RMV_CONTINUE;
    WriteToRemoveLogFile(__FILE__, __LINE__,
        "RMVDeleteDirectory:return_status set");

    done = FALSE;
    while ( ! done ) {
        
        if ( ! ISDKDeleteDirectory (dir, (TCHAR)RMVGetPathSeparator()) ) {
            
            GETLASTERROR_BREAK(ERROR_PATH_NOT_FOUND);
            SILENTMODE_BREAK;
            
            args[0] = dir;
            args[1] = ISDKLastErrorText (RMVGetLangId(),
                                         RMVMESSAGELEN);
            
            sprintf(wrk,"RMVDeleteDirectory:args[1] = \"%s\"", args[1]);
            WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
            stat = ISDKStringIdBox (hwndowner,
                                    RMVGetResourceDll(),
                                    args,
                                    DIRECTORY_DELETE_ERROR,
                                    RMVGetLangId(),
                                    title,
                                    RMVMESSAGELEN,
                                    MB_ICONEXCLAMATION | MB_ABORTRETRYIGNORE);
            
            UpdateWindow (hwndowner);
            
            if ( args[1] ) LocalFree ((HLOCAL)args[1]);
            
            if ( stat == IDIGNORE ) {
                return_status = RMV_IGNORE;
                WriteToRemoveLogFile(__FILE__, __LINE__,
                    "RMVDeleteDirectory:return_status set");
                done = TRUE;
            } else if ( stat == IDABORT ) {
                return_status = RMV_ABORT;
                WriteToRemoveLogFile(__FILE__, __LINE__,
                    "RMVDeleteDirectory:return_status set");
                done = TRUE;
            } else if ( stat == 0 ) {
                return_status = RMV_SYSERR;
                WriteToRemoveLogFile(__FILE__, __LINE__,
                    "RMVDeleteDirectory:return_status set");
                done = TRUE;
            }
        } else {
            done = TRUE;  /* directory successfully deleted */
        }
    }

  end:
    sprintf(wrk,"RMVDeleteDirectory returns %d", return_status);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    return return_status;
}



/******************************************************************************

    SYNOPSIS

        LONG RMVDeleteProductFiles (HWND hwndowner,
                                    LTCSTR title,
                                    PTCHAR *FilesDirList,
                                    PTCHAR ProductPath)

    PARAMETERS

        NAME          ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----          --------------------------------------------------------

        hwndowner     I - handle of owner window
        title         I - title to display on message boxes
        FilesDirList  I - List of files and directories to remove
        ProductPath   I - The base directory for the files and directories

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()

    DESCRIPTION

        This function deletes files and directories specified by the parameter
        list.  The ProductPath is prepended to the file and directory name to 
        form the complete path.  If the entry in the list is a directory, the
        directory contents are deleted first.  The directory is then removed. 

        The FilesDirList is an array of character string pointers.  A NULL 
        value terminates the list.  The array is composed of "pairs" of
        filename/directory name and the character string "f" or "d".  The "f"
        or "d" indicates filename or directory name respectively in the 
        preceding character string pointer.  

        TCHAR *FileDirList[] = { "dirname1",  "d",
                                 "dirname2",  "d",
                                 "filename1", "f",
                                 "filename2", "f",
                                 NULL };
                                 

    CHANGE HISTORY

        22/08/93    (jdb)    Initial Definition.
        10-MAR-1995 mwm      add RMVDeleteFile

******************************************************************************/

LONG RMVDeleteProductFiles (HWND hwndowner,
                            LPCTSTR title,
                            PTCHAR *FilesDirList,
                            PTCHAR ProductPath)
     
{
    INT     stat;

    LONG    return_status;

    PTCHAR   del_path = NULL;
    PTCHAR   root_path = NULL;
    
    /* 
    ** We use "return_status" as our return code and we set it's default value
    ** to RMV_CONTINUE.  We only reset this value if an error occurs.  When an
    ** error is encountered, the user is required to select a retry, ignore,
    ** or abort operation.  On aborts, this function immediately returns with 
    ** the RMV_ABORT return code.  On ignores, the function is allowed to 
    ** continue, but the return code is set to RMV_IGNORE.  Note:  the silent
    ** flag disables all user input, and, on encountering an error, the 
    ** return code is set to the global error mode.  The function then 
    ** continues or returns based on the status of the global error mode.
    */
    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RMVDeleteProductFiles");
    if(title) {
        sprintf(wrk,"RMVDeleteProductFiles:title = \"%s\"", title);
    } else {
        sprintf(wrk,"RMVDeleteProductFiles:title = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    if(ProductPath) {
        sprintf(wrk,"RMVDeleteProductFiles:ProductPath = \"%s\"", ProductPath);
    } else {
        sprintf(wrk,"RMVDeleteProductFiles:ProductPath = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

    return_status = RMV_CONTINUE;
    WriteToRemoveLogFile(__FILE__, __LINE__,
        "RMVDeleteProductFiles:return_status set");

    /*
    ** Make sure the product path is separator terminated.
    */

    if ( ! (root_path = ISDKAppendSeparator (ProductPath,
                                             RMVGetPathSeparator ())) ) {
        sprintf(wrk, "RMVDeleteProductFiles:GetLastError() = %ld",
            GetLastError());
        WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
        return_status = RMV_SYSERR;
        WriteToRemoveLogFile(__FILE__, __LINE__,
            "RMVDeleteProductFiles:return_status set");
        goto end;
    }

    /*
    ** For each filename/directory name in the FilesDirList, prepend the 
    ** ProductPath and call the appropriate delete function based on the
    ** type argument.
    */
        
    while ( *FilesDirList ) {

        if ( ! (del_path = ISDKStrCatN (2, root_path, *FilesDirList)) ) {
            sprintf(wrk, "RMVDeleteProductFiles:GetLastError() = %ld",
                GetLastError());
            WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
            return_status = RMV_SYSERR;
            WriteToRemoveLogFile(__FILE__, __LINE__,
                "RMVDeleteProductFiles:return_status set");
            goto end;
        }
        
        FilesDirList++;       /* determine file type */
        
        if ( ! _tcscmp (*FilesDirList, "d") ) {

            /*
            ** Call RMVDeleteDirectory on the directory path name. This is 
            ** necessary to make the directory empty before it can be removed.
            ** If the del_path path is a directory, all the directories and 
            ** files under it will be DELETED recursively.  We are only
            ** concerned with errors that occur within this call.  Return 
            ** immediately on error or abort, but allow the function to 
            ** continue on ignores, setting the return code.
            */

            stat = RMVDeleteDirectory (hwndowner, 
                                       title, 
                                       del_path);

        } else if ( ! _tcscmp (*FilesDirList, "f") ) {
            
            /*
            ** Call ISDKDeleteFile on the filename path. If the delete fails,
            ** notify the user of the error and allow the user to decide
            ** what to do.  Abort and ignore exit this loop, and retry
            ** continues the delete operation.
            */

            stat = RMVDeleteFile (hwndowner,
                                  title,
                                  del_path);

        }

        if ( stat == RMV_IGNORE ) {
            return_status = stat;
            WriteToRemoveLogFile(__FILE__, __LINE__,
                "RMVDeleteProductFiles:return_status set");
        } else if ( stat == RMV_ABORT ) {
            return_status = stat;
            WriteToRemoveLogFile(__FILE__, __LINE__,
                "RMVDeleteProductFiles:return_status set");
            goto end;
        } else if ( stat == RMV_SYSERR ) {
            sprintf(wrk, "RMVDeleteProductFiles:GetLastError() = %ld",
                GetLastError());
            WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
            return_status = stat;
            WriteToRemoveLogFile(__FILE__, __LINE__,
                "RMVDeleteProductFiles:return_status set");
            goto end;
        }
        
        FilesDirList++;
        free (del_path);
        del_path = NULL;
    }

  end:        

    if ( root_path ) free (root_path);
    if ( del_path ) free (del_path);

    sprintf(wrk,"RMVDeleteProductFiles returns %d", return_status);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    return return_status;
}    


/******************************************************************************

    SYNOPSIS

        LONG RMVDeleteRegistry (HWND hwndowner,
                                LPCTSTR title,
                                HKEY hKey,
                                LPTSTR KeyPath
                                LPTSTR KeyName)

    PARAMETERS

        NAME           ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----           --------------------------------------------------------

        hwndowner      I - handle of owner window
        title          I - title to display on message boxes
        hKey           I - currently open key or predefined reserved handle
        KeyPath        I - subkey path name as stored in registry
        KeyName        I - key name as stored in registry

        for example:  hKey = HKEY_LOCAL_MACHINE
                      KeyPath = "SOFTWARE\\Intergraph\\SETUPSDK"
                      KeyName = "02.00"

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()
                   
    DESCRIPTION

        This function deletes the KeyName registry key associated with the
        KeyPath registry key.  It provides the user interface wrapper to
        the ISDKDeleteRegKey() function which recursively deletes a registry
        key.

    CHANGE HISTORY

        10-OCT-1994    mwm    Initial creation

******************************************************************************/

LONG RMVDeleteRegistry (HWND hwndowner,
                        LPCTSTR title,
                        HKEY hKey,
                        LPCTSTR KeyPath,
                        LPCTSTR KeyName)
{
    BOOL done;

    INT stat;

    LPCTSTR args[4] = {NULL, NULL, NULL, NULL};
    LPCTSTR keyptr;

    LONG return_status = RMV_CONTINUE;

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RMVDeleteRegistry");
    if(title) {
        sprintf(wrk,"RMVDeleteRegistry:title = \"%s\"", title);
    } else {
        sprintf(wrk,"RMVDeleteRegistry:title = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    if(KeyPath) {
        sprintf(wrk,"RMVDeleteRegistry:KeyPath = \"%s\"", KeyPath);
    } else {
        sprintf(wrk,"RMVDeleteRegistry:KeyPath = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    if(KeyName) {
        sprintf(wrk,"RMVDeleteRegistry:KeyName = \"%s\"", KeyName);
    } else {
        sprintf(wrk,"RMVDeleteRegistry:KeyName = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

    switch ( (LONG)hKey ) {
      case (LONG)HKEY_LOCAL_MACHINE:
        keyptr = "HKEY_LOCAL_MACHINE";
        break;
        
      case (LONG)HKEY_CURRENT_USER:
        keyptr = "HKEY_CURRENT_USER";
        break;

      case (LONG)HKEY_CLASSES_ROOT:
        keyptr = "HKEY_CLASSES_ROOT";
        break;

      case (LONG)HKEY_USERS:
        keyptr = "HKEY_USERS";
        break;

      default:
        SetLastError (ERROR_INVALID_PARAMETER);
        return_status = RMV_IGNORE;
        WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteRegistry:return_status set");
        goto end;
    }

    done = FALSE;
    while ( ! done ) {

        if ( ! ISDKDeleteRegKey (hKey,
                                 KeyPath,
                                 KeyName,
                                 RMVGetPathSeparator()) ) {
            
            GETLASTERROR_BREAK(ERROR_FILE_NOT_FOUND);                
            SILENTMODE_BREAK;            
            
            args[0] = ISDKStrCatN (4,
                                   keyptr,
                                   TEXT("\\"),
                                   KeyPath,
                                   TEXT("\\"),
                                   KeyName);
            
            args[1] = ISDKLastErrorText (RMVGetLangId(),
                                         RMVMESSAGELEN);
            
            stat = ISDKStringIdBox (hwndowner,
                                    RMVGetResourceDll(),
                                    args,
                                    REGISTRY_DELETE_KEY_ERROR,
                                    RMVGetLangId(),
                                    title,
                                    RMVMESSAGELEN,
                                    MB_ICONEXCLAMATION | 
                                    MB_ABORTRETRYIGNORE);
            
            UpdateWindow (hwndowner);
            
            if ( args[0] ) free ((PVOID)args[0]);
            if ( args[1] ) LocalFree ((HLOCAL)args[1]);
            
            if ( stat == IDIGNORE ) {
                return_status = RMV_IGNORE;
                WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteRegistry:return_status set");
                done = TRUE;
            } else if ( stat == IDABORT ) {
                return_status = RMV_ABORT;
                WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteRegistry:return_status set");
                goto end;
            } else if ( stat == 0 ) {
                return_status = RMV_SYSERR;
                WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteRegistry:return_status set");
                goto end;
            }
        } else {
            done = TRUE;  
        }
    }

  end:
    sprintf(wrk,"RMVDeleteRegistry returns %d", return_status);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    return return_status;
}


/******************************************************************************

    SYNOPSIS

        LONG RMVDeleteIngrRegistry (HWND hwndowner,
                                    LPCTSTR title,
                                    HKEY hKey,
                                    LPTSTR ProdName,
                                    LPTSTR Version)

    PARAMETERS

        NAME           ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----           --------------------------------------------------------

        hwndowner      I - handle of owner window
        title          I - title to display on message boxes
        hKey           I - currently only HKEY_LOCAL_MACHINE
        KeyPath        I - product name as stored in registry
        KeyName        I - product version as stored in registry

        for example:  hKey = HKEY_LOCAL_MACHINE
                      KeyPath = "SetupSDK"
                      KeyName = "02.00"

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()
                   
    DESCRIPTION

        This function deletes the Intergraph registry key.  It provides the 
        user interface wrapper to the ISDKDeleteRegKey() function which 
        recursively deletes a registry key.

    CHANGE HISTORY

        10-OCT-1994    mwm    Initial creation

******************************************************************************/

LONG RMVDeleteIngrRegistry (HWND hwndowner,
                            LPCTSTR title,
                            HKEY hKey,
                            LPCTSTR ProductName,
                            LPCTSTR ProductVersion)

{
    BOOL done = FALSE;

    DWORD keys;
    DWORD platform;
    DWORD values;

    INT stat;

    LPCTSTR args[4] = { NULL, NULL, NULL };

    LPTSTR txtptr;
    LPTSTR IniName = NULL;
    LPTSTR KeyPath = NULL;
    LPTSTR PathName = NULL;
    LPTSTR ProdString = NULL;

    LONG return_status = RMV_CONTINUE;

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RMVDeleteIngrRegistry");
    if(title) {
        sprintf(wrk,"RMVDeleteIngrRegistry:title = \"%s\"", title);
    } else {
        sprintf(wrk,"RMVDeleteIngrRegistry:title = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    if(ProductName) {
        sprintf(wrk,"RMVDeleteIngrRegistry:ProductName = \"%s\"", ProductName);
    } else {
        sprintf(wrk,"RMVDeleteIngrRegistry:ProductName = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    if(ProductVersion) {
        sprintf(wrk,"RMVDeleteIngrRegistry:ProductVersion = \"%s\"", ProductVersion);
    } else {
        sprintf(wrk,"RMVDeleteIngrRegistry:ProductVersion = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

    platform = ISDKGetPlatform ();

    if ( ISDKMatchPlatform (ISm_NT31        |
                            ISm_DAYTONA     |
                            ISm_DAYTONA_351 |
                            ISm_CHICAGO     |
                            ISm_NT40) ) {

        if ( hKey != HKEY_LOCAL_MACHINE ) {
            SetLastError (ERROR_INVALID_PARAMETER);
            return_status = RMV_IGNORE;
            WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteIngrRegistry:return_status set");
            goto end;
        } else {
            txtptr = "HKEY_LOCAL_MACHINE";
        }

        if ( ! (KeyPath = ISDKStrCatN (3,
                                       INTERGRAPH_KEY,
                                       "\\",
                                       ProductName)) ) goto end;
        
        stat = RMVDeleteRegistry (hwndowner,
                                  title,
                                  hKey,
                                  KeyPath,
                                  ProductVersion );
        if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
            return_status = stat;
            WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteIngrRegistry:return_status set");
            goto end;
        } else if ( stat == RMV_IGNORE ) {
            return_status = RMV_IGNORE;
            WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteIngrRegistry:return_status set");
        } else if ( ISDKKeyValuesExist (hKey,
                                        KeyPath,
                                        RMVGetPathSeparator(),
                                        &keys,
                                        &values) && ! keys ) {
            
            stat = RMVDeleteRegistry (hwndowner,
                                      title,
                                      hKey,
                                      INTERGRAPH_KEY,
                                      ProductName);
            if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
                return_status = stat;
                WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteIngrRegistry:return_status set");
                goto end;
            } else if ( stat == RMV_IGNORE ) {
                return_status = RMV_IGNORE;
                WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteIngrRegistry:return_status set");
            }
        }

    } else if ( platform == IS_WIN32S ) {

        if ( (PathName = ISDKGetDirectory (WINDOWS_DIR)) &&
             (IniName = ISDKStrCatN (2, PathName, INI_FILE)) &&
             (ProdString = ISDKStrCatN (3, ProductName, 
                                        "\\", ProductVersion)) ) {

            done = FALSE;
            while ( ! done ) {

                if ( ! WritePrivateProfileString (ProdString,
                                                  NULL,
                                                  NULL,
                                                  IniName) ) {
                    
                    IF_SILENTMODE_END(RMV_ABORT);
                    
                    args[0] = ISDKStrCatN (5,
                                           IniName,
                                           "\\",
                                           ProdString,
                                           "\\"
                                           PATHNAME_VALUE);
                    args[1] = ISDKLastErrorText (RMVGetLangId(),
                                                 RMVMESSAGELEN);
                   
                    stat = ISDKStringIdBox (hwndowner,
                                            RMVGetResourceDll(),
                                            args,
                                            REGISTRY_DELETE_KEY_ERROR,
                                            RMVGetLangId(),
                                            title,
                                            RMVMESSAGELEN,
                                            MB_ICONEXCLAMATION |
                                            MB_ABORTRETRYIGNORE);

                    UpdateWindow (hwndowner);
                    
                    if (args[0]) free ((PVOID)args[0]);
                    if (args[1]) LocalFree ((HLOCAL)args[1]);

                    if ( stat == IDIGNORE ) {
                        return_status = RMV_IGNORE;
                        WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteIngrRegistry:return_status set");
                        done = TRUE;
                    } else if ( stat == IDABORT ) {
                        return_status = RMV_ABORT;
                        WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteIngrRegistry:return_status set");
                        goto end;
                    } else if ( stat == 0 ) {
                        return_status = RMV_SYSERR;
                        WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteIngrRegistry:return_status set");
                        goto end;
                    }
                } else {
                    done = TRUE;
                }
            }
        }
    }

  end:

    ISDKTSTFREE (IniName);
    ISDKTSTFREE (KeyPath);
    ISDKTSTFREE (PathName);
    ISDKTSTFREE (ProdString);

    sprintf(wrk,"RMVDeleteIngrRegistry returns %d", return_status);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    return return_status;
}


/******************************************************************************

    SYNOPSIS

        LONG RMVDeleteAppPath (HWND hwndowner,
                               LPCTSTR title,
                               LPCTSTR application)

    PARAMETERS

        NAME           ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----           --------------------------------------------------------

        hwndowner      I - handle of owner window
        title          I - title to display on message boxes
        application    I - full pathname of executable

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()
                   
    DESCRIPTION

        This function deletes the Microsoft per-application registry key
        for the given application on W95.

        HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths

    CHANGE HISTORY

        24-JUL-1995    mwm    Initial creation
        01-APR-1996    mwm    modify for platforms

******************************************************************************/

LONG RMVDeleteAppPath (HWND hwndowner,
                       LPCTSTR title,
                       LPCTSTR application)
{

    LONG stat = RMV_CONTINUE;

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RMVDeleteAppPath");
    if(title) {
        sprintf(wrk,"RMVDeleteAppPath:title = \"%s\"", title);
    } else {
        sprintf(wrk,"RMVDeleteAppPath:title = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    if(application) {
        sprintf(wrk,"RMVDeleteAppPath:application = \"%s\"", application);
    } else {
        sprintf(wrk,"RMVDeleteAppPath:application = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

    if ( ISDKMatchPlatform (ISm_CHICAGO | ISm_NT40) ) {    

        LPTSTR exe = NULL;
        LPTSTR name = NULL;
        
        if ( (name = ISDKGetFullPathName (application, &exe)) && exe ) {

            stat = RMVDeleteRegistry (hwndowner,
                                      title,
                                      HKEY_LOCAL_MACHINE,
                                      APPPATHS_KEY,
                                      exe);

        } else {

            stat = RMV_SYSERR;

        }

        ISDKTSTFREE (name);
    }
    
    sprintf(wrk, "RMVDeleteAppPath returns %d", stat);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    return (stat);
}


/******************************************************************************

    SYNOPSIS

        LONG RMVDeleteProgramGroup (HWND hwndowner,
                                    LPCTSTR title,
                                    LPCTSTR group,
                                    LONG type)

    PARAMETERS

        NAME          ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----          --------------------------------------------------------

        hwndowner     I - handle of owner window
        title         I - title to display on message boxes
        group         I - program group name to delete
        type          I - flag indicating common or personal program (only
                          COMMON_GROUP currently supported)

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()

    DESCRIPTION

        This function deletes a common program group.  It provides the user 
        interface wrapper to the DeleteProgamItem function().

    CHANGE HISTORY

        10-OCT-1994    mwm    Initial creation

******************************************************************************/

LONG RMVDeleteProgramGroup (HWND hwndowner,
                            LPCTSTR title,
                            LPCTSTR group,
                            LONG type)

{
    BOOL done = FALSE;

    INT stat;

    LPCTSTR args[3] = { NULL, NULL, NULL };

    LONG return_status = RMV_CONTINUE;

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RMVDeleteProgramGroup");
    if(title) {
        sprintf(wrk,"RMVDeleteProgramGroup:title = \"%s\"", title);
    } else {
        sprintf(wrk,"RMVDeleteProgramGroup:title = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    if(group) {
        sprintf(wrk,"RMVDeleteProgramGroup:group = \"%s\"", group);
    } else {
        sprintf(wrk,"RMVDeleteProgramGroup:group = NULL");
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

    while ( ! done ) {

        if ( ! DeleteGroup ((LPSTR)group) ) {

            SILENTMODE_BREAK;

            args[0] = group;

            stat = ISDKStringIdBox (hwndowner,
                                    RMVGetResourceDll(),
                                    args,
                                    COMMON_PROGRAM_GROUP_DELETE_ERROR,
                                    RMVGetLangId(),
                                    title,
                                    RMVMESSAGELEN,
                                    MB_ICONEXCLAMATION | MB_ABORTRETRYIGNORE);

            UpdateWindow (hwndowner);

            if ( stat == IDIGNORE ) {
                return_status = RMV_IGNORE;
                WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteProgramGroup:return_status set");
                done = TRUE;
            } else if ( stat == IDABORT ) {
                return_status = RMV_ABORT;
                WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteProgramGroup:return_status set");
                goto end;
            } else if ( stat == 0 ) {
                return_status = RMV_SYSERR;
                WriteToRemoveLogFile(__FILE__, __LINE__, "RMVDeleteProgramGroup:return_status set");
                goto end;
            }
        } else {
            done = TRUE;  
        }
    }

end:    
    sprintf(wrk, "RMVDeleteProgramGroup returns %d", return_status);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    return return_status;
}


/******************************************************************************

    SYNOPSIS

        LONG RMVDeleteProgramItems (HWND hwndowner,
                                    LPCTSTR title,
                                    LPCTSTR group,
                                    LPCTSTR *items,
                                    LONG type)

    PARAMETERS

        NAME          ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----          --------------------------------------------------------

        hwndowner     I - handle of owner window
        title         I - title to display on message boxes
        group         I - common program group name
        items         I - a NULL terminated list of program items to delete 
                          in common program group
        type          I - flag indicating common or personal program (only
                          COMMON_PROGRAM_GROUP currently supported)

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()

    DESCRIPTION

        This function deletes program items from a common program group.  It
        provides the user interface wrapper to the DeleteProgamItem function().

    CHANGE HISTORY

        10-OCT-1994    mwm    Initial creation

******************************************************************************/

LONG RMVDeleteProgramItems (HWND hwndowner,
                            LPCTSTR title,
                            LPCTSTR group,
                            LPCTSTR *items,
                            LONG type)

{
    INT stat;

    LPCTSTR args[4] = { NULL, NULL, NULL, NULL };

    LONG return_status = RMV_CONTINUE;

    while ( *items ) {

        if ( ! DeleteProgramItem ((LPSTR)group, (LPSTR)*items) ) {

            SILENTMODE_BREAK;

            args[0] = *items;
            args[1] = group;

            stat = ISDKStringIdBox (hwndowner,
                                    RMVGetResourceDll(),
                                    args,
                                    COMMON_PROGRAM_ITEM_DELETE_ERROR,
                                    RMVGetLangId(),
                                    title,
                                    RMVMESSAGELEN,
                                    MB_ICONEXCLAMATION | MB_ABORTRETRYIGNORE);

            UpdateWindow (hwndowner);
            

            if ( stat == IDIGNORE ) {
                return_status = RMV_IGNORE;
                items++;
            } else if ( stat == IDABORT ) {
                return_status = RMV_ABORT;
                goto end;
            } else if ( stat == 0 ) {
                return_status = RMV_SYSERR;
                goto end;
            }
        } else {
            items++;
        }
    }

end:    
    return return_status;
}


/******************************************************************************

    SYNOPSIS

        LONG RMVMoveFileDelete (HWND hwndowner,
                                LPCTSTR title,
                                LPCTSTR file)

    PARAMETERS

        NAME          ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----          --------------------------------------------------------

        hwndowner     I - handle of owner window
        title         I - title to display on message boxes
        files         I - a full filename to mark for file deletion during
                          next reboot 

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()

    DESCRIPTION

        This function marks the specified file for deletion upon the next 
        reboot of this machine.  Three different approaches are taken for 
        the three platforms supported:  Windows NT, Windows 95, and Win32s.

        Windows NT uses MoveFileEx() to mark the file for delete.  This 
        establishes a file list maintained in the registry for files to be
        deleted upon next reboot.

        Windows 95 uses the {windows directory}\WININIT.INI file to maintain
        the file list for deletion.  Files added in this manner apparently
        must conform to the 8.3 FAT file system naming convention to work.
      
        Win32s uses the old-fashioned way, using _mssetup.exe.  Good Luck.

    CHANGE HISTORY

        10-OCT-1994    mwm    Initial creation
        08-MAR-1995    mwm    added Windows 95 execution
        23-JAN-1996    mwm    added Win32s default branch (done = TRUE)

******************************************************************************/

LONG RMVMoveFileDelete (HWND hwndowner,
                        LPCTSTR title,
                        LPCTSTR file)

{
    BOOL done;

    INT stat;

    LONG return_status = RMV_CONTINUE;

    LPCTSTR args[4] = { NULL, NULL, NULL, NULL };

    done = FALSE;

    while ( ! done ) {

        if ( ISDKGetPlatform() != IS_WIN32S ) {

            if ( ! INGRMoveFileEx (file, NULL) ) {

                GETLASTERROR_BREAK(ERROR_FILE_NOT_FOUND);
                GETLASTERROR_BREAK(ERROR_PATH_NOT_FOUND);
                SILENTMODE_BREAK;
                
                args[0] = file;
                args[1] = ISDKLastErrorText (RMVGetLangId(),
                                             RMVMESSAGELEN);
                
                stat = ISDKStringIdBox (hwndowner,
                                        RMVGetResourceDll(),
                                        args,
                                        FILE_MOVENULL_ERROR,
                                        RMVGetLangId(),
                                        title,
                                        RMVMESSAGELEN,
                                        MB_ICONEXCLAMATION | 
                                        MB_ABORTRETRYIGNORE);
                
                UpdateWindow (hwndowner);
                
                if (args[1]) LocalFree ((HLOCAL)args[1]);
                
                if ( stat == IDIGNORE ) {
                    return_status = RMV_IGNORE;
                    done = TRUE;
                } else if ( stat == IDABORT ) {
                    return_status = RMV_ABORT;
                    goto end;
                } else if ( stat == 0 ) {
                    return_status = RMV_SYSERR;
                    goto end;
                }
                
            } else {
                RMVSetReboot(TRUE);
                done = TRUE;
            }
            
        } else {    /* default W32s condition */
            
            done = TRUE;
              
        }
    }

  end:

    return return_status;
}



/******************************************************************************

    SYNOPSIS

        LONG RMVDeleteDriverRegInfo (HWND hwndowner,
                                     LPCTSTR title,
                                     LPCTSTR drivername)

    PARAMETERS

        NAME          ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----          --------------------------------------------------------

        hwndowner     I - handle of owner window
        title         I - title to display on message boxes
        drivername    I - drivername as stored in registry

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()

    DESCRIPTION

        This function deletes the registry keys created by IngrStampDriverInfo
        for the driver identified by drivername.

    CHANGE HISTORY

        10-OCT-1994    mwm    Initial creation

******************************************************************************/

#define SYSTEMKEY    "SYSTEM\\CurrentControlSet\\Services"
#define EVENTLOGKEY   SYSTEMKEY "\\" "EventLog\\System"


LONG RMVDeleteDriverRegInfo (HWND hwndowner,
                             LPCTSTR title,
                             LPCTSTR drivername)
{
    LONG stat;
    LONG return_status;

    return_status = RMVDeleteRegistry (hwndowner,
                                       title,
                                       HKEY_LOCAL_MACHINE,
                                       SYSTEMKEY,
                                       drivername);

    if ( return_status == RMV_ABORT || return_status == RMV_SYSERR ) goto end;

    stat = RMVDeleteRegistry (hwndowner,
                              title,
                              HKEY_LOCAL_MACHINE,
                              EVENTLOGKEY,
                              drivername);

    if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
        return_status = stat;
    } else if ( stat == RMV_IGNORE ) {
        return_status = stat;
    }

  end:
    return return_status;
}


/******************************************************************************

    SYNOPSIS

        LONG RMVComponentCleanup (HWND hwndowner,
                                  LPCTSTR title)

    PARAMETERS

        NAME          ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----          --------------------------------------------------------

        hwndowner     I - handle of owner window
        title         I - title to display on message boxes

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()

    DESCRIPTION

        This function cleans up the shared component directory and environment.

    CHANGE HISTORY

        10-OCT-1994    mwm    Initial creation

******************************************************************************/

LONG RMVComponentCleanup (HWND hwndowner,
                          LPCTSTR title)

{
    BOOL update = FALSE;

    DWORD dircount;
    DWORD filecount;
    DWORD platform;
    DWORD ret;
    DWORD size;
    DWORD type;

    LPTSTR path = NULL;
    LPTSTR share = NULL;
    LPTSTR newpath = NULL;
    LPTSTR ptr = NULL;
    LPTSTR windrive = NULL;

    platform = ISDKGetPlatform();

    /*
    ** Determine the share directory for our environment. 
    */

    if ( ISDKMatchPlatform (ISm_NT31        |
                            ISm_DAYTONA     |
                            ISm_DAYTONA_351 |
                            ISm_CHICAGO     |
                            ISm_NT40) ) {

        share = ISDKQueryRegValue (HKEY_LOCAL_MACHINE,
                                   INTERGRAPH_KEY,
                                   COMMON_VALUE,
                                   &type,
                                   &size);

    } else if ( platform == IS_WIN32S ) {

        share = ISDKGetPrivateProfileStr (COMMON_SECTION,
                                          COMMON_VALUE,
                                          INI_FILE,
                                          &size);
    }

    /*
    ** Determine the path for our environment
    */
        
    if ( ISDKMatchPlatform (ISm_NT31        |
                            ISm_DAYTONA     |
                            ISm_DAYTONA_351 |
                            ISm_NT40) ) {

        path = ISDKQueryRegValue (HKEY_LOCAL_MACHINE,
                                  ENVIRONMENT_KEY,
                                  PATH_VALUE,
                                  &type,
                                  &size);

    } else if ( ISDKMatchPlatform (ISm_CHICAGO | ISm_WIN32S) ) {

        /* tbd */

    }

    if ( ! share ) {   

        /* 
        ** The share directory environment variable is not defined.  Remove
        ** the default share directory from the system and the path.
        */
        
        windrive = ISDKGetDirectory (WINDOWS_DIR);
        if (windrive) {
            windrive[2] = '\0';

            if ( platform == IS_WIN32S ) {
                ptr = PH2_W32S_SHARE_DIR;
            } else {
                ptr = PH2_INGR_SHARE_DIR;
            }

            if ( (share = ISDKStrCatN (2, windrive, ptr)) ) {

                if ( RMVDeleteDirectory (hwndowner, 
                                         title,
                                         share) == RMV_CONTINUE ) {
                    update = TRUE;
                }
            }
            free (windrive);
            windrive = NULL;
        }

    } else {

        /* 
        ** The share directory environment variable is defined.  Look in the
        ** directory to determine if any components exist.  If the directory 
        ** is empty, remove it from the system and the path.
        */

        ISDKDirFilesExist (share, (WCHAR)'\\', &dircount, &filecount);

        if ( ! dircount && ! filecount ) {

            if ( RMVDeleteDirectory (hwndowner,
                                     title,
                                     share) == RMV_CONTINUE ) {
                update = TRUE;
            }
        }
        
    }

    if ( path && update ) {

        /*
        ** We have our path and we have removed the shared component directory
        ** from the system.  We now need to remove the shared component path
        ** from the system's path, and we need to remove the "common" value
        ** from the registry.  First, the shared component path.
        */

        newpath = ISDKRemoveString (&ret,
                                    path,
                                    share,
                                    RMVGetRegListSeparator(),
                                    FALSE);

        if ( ret ) {

        if ( ISDKMatchPlatform (ISm_NT31        |
                                ISm_DAYTONA     |
                                ISm_DAYTONA_351 |
                                ISm_CHICAGO     |
                                ISm_NT40) ) {

                ISDKSetRegValue (HKEY_LOCAL_MACHINE,
                                 ENVIRONMENT_KEY,
                                 PATH_VALUE,
                                 newpath,
                                 type,
                                 strlen (newpath) + 1,
                                 KEY_ALL_ACCESS,
                                 NULL, 
                                 NULL);
                
            } else {
                
                /* tbd */
                
            }
        }

        /* Now, the shared component common value, regardless */
        
        if ( ISDKMatchPlatform (ISm_NT31        |
                                ISm_DAYTONA     |
                                ISm_DAYTONA_351 |
                                ISm_CHICAGO     |
                                ISm_NT40) ) {

            ISDKDeleteRegValue (HKEY_LOCAL_MACHINE,
                                INTERGRAPH_KEY, 
                                COMMON_VALUE);

        } else if ( platform == IS_WIN32S ) {
            
            WritePrivateProfileSection (COMMON_SECTION,
                                        COMMON_VALUE,
                                        ""
                                        INI_FILE);
        }
    }

    return RMV_CONTINUE;
}


/******************************************************************************

    SYNOPSIS

        LONG RMVExitWindows (UINT flag)

    PARAMETERS

        NAME          ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----          --------------------------------------------------------

        flag          I - shutdown operation (restricted to EWX_REBOOT on
                          Windows NT, Windows 95)

    RETURN VALUE

        RMV_CONTINUE - successful completion
        RMV_IGNORE   - an internal error occurred, user selected ignore, see 
                       GetLastError()
        RMV_ABORT    - an internal error occurred, user selected abort, see
                       GetLastError()
        RMV_SYSERR   - an internal error occured, see GetLastError()

    DESCRIPTION

        This function provides a wrapper to the ExitWindowEx() function

    CHANGE HISTORY

        17-FEB-1995    mwm    Initial creation

******************************************************************************/
        
LONG RMVExitWindows (UINT flag) {

    DWORD platform;

    platform = ISDKGetPlatform ();

    switch ( flag ) {
        
      case EWX_REBOOT:

        if ( ISDKMatchPlatform (ISm_NT31        |
                                ISm_DAYTONA     |
                                ISm_DAYTONA_351 |
                                ISm_NT40) ) {

            /*
            ** For NT, we just reboot the system.
            ** We must have SE_SHUTDOWN_NAME privilege to succeed.
            */

            HANDLE htkProc;
            TOKEN_PRIVILEGES PTable;

            OpenProcessToken(GetCurrentProcess(),
                             TOKEN_QUERY | TOKEN_ADJUST_PRIVILEGES,
                             &htkProc);

            PTable.PrivilegeCount = 1;
            LookupPrivilegeValue("", 
                                 SE_SHUTDOWN_NAME, 
                                 &PTable.Privileges[0].Luid);
            PTable.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
            
            AdjustTokenPrivileges(htkProc,
                                  FALSE, 
                                  &PTable, 
                                  0, 
                                  (PTOKEN_PRIVILEGES) NULL, 
                                  0);
            
            ExitWindowsEx (EWX_REBOOT, 0);

        } else if ( platform == IS_CHICAGO ) {

            ExitWindowsEx (EWX_REBOOT, 0);

        }
        break;
    }

    return (TRUE);
}




