// 1996.01.31:Alan Barksdale:This file is modified from csource\rmprod.c in
//	Setup SDK 02.03.00.00.
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <winnt.h>
#include <tchar.h>
#include <assert.h>

#include "isdk.h"
#include "ddeprog.h"
#include "ingrreg.h"
#include "cuirsc.h"

#include "ingrrmv.h"
#include "ingrw95.h"

/* add your include file for your product's read-only resource file */

//#include "product.h"

#include "rmlib.h"
#include "ingrbld.h" // for cchMax
#include "reglib.h"

#include "risrem.h"
#include "risver.h"
#if defined(RISCLI)
	// not used
#elif defined(RISAPP)
#	include "setupver.h" // for PRODINDEX
#elif defined(RISSRV)
#	include "defines.h"
#else
#	error Either RISAPP or RISCLI or RISSRV should be defined at this point in rmprod.c.
#endif
#include "rmprod.h"
#include "risdlog.h" // for DELETE_MARK
#include "risdebug.h" // for STRING()

#if defined(RISSRV)
#	if !defined(risdb2ds) && !defined(risingds) && !defined(risinfds) && !defined(risinfns) && !defined(rismsfds) && !defined(risorads) && !defined(risorans) && !defined(rissybds)
#		error RISSRV is defined at this point in rmprod.c; therefore, one of risdb2ds, risingds, risinfds, risinfns, rismsfds, risorads, risorans, or rissybds should be defined.
#	endif
#endif

static char wrk[cchMax]; // 1996.01.26:Alan Barksdale:imitating Rick Kramer's debug code


/******************************************************************************

    SYNOPSIS

    static VOID DeleteRemoveExecutable(HWND hwndowner,
                      LPTSTR title,
                      LPTSTR pathname,
                      PBOOLEAN pbDeletedRemoveExecutable,
                      PBOOLEAN pbGotoEnd,
                      PLONG pl_return_status)


    PARAMETERS

        NAME           ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----           --------------------------------------------------------

        hwndowner      I - handle of owner window for message boxes
        title          I - title to display on message boxes
        pathname       I - path of directory of remove executable
        pbDeletedRemoveExecutable O - whether remove executable was deleted
        pbGotoEnd      O - whether to goto end:
        pl_return_status I/O - return status of function

    RETURN VALUE

        VOID

    DESCRIPTION

        This function tries to delete the remove executable.  This only should
        be possible if RemoveProduct is called by something other than the
        remove executable.

    CHANGE HISTORY

        25-MAR-1996 afb    Initial creation at Melania Stewart's request.
                           (Alan Barksdale)

******************************************************************************/

static VOID DeleteRemoveExecutable(HWND hwndowner,
                  LPTSTR title,
                  LPTSTR pathname,
                  PBOOLEAN pbDeletedRemoveExecutable,
                  PBOOLEAN pbGotoEnd,
                  PLONG pl_return_status)

{
    BOOL done;
    static TCHAR *RemoveExecutableFile[] = { 
#if defined(RISCLI)
                                             "rm" RIS_VERSION_MAJ_STR RIS_VERSION_MIN_STR "sc.exe", "f",
#elif defined(RISAPP) || defined(RISSRV)
                                             "rm" PRODINDEX ".exe", "f",
#endif
                                             NULL
                                           };
    INT stat;                               
    TCHAR **filelist = NULL;
    LPCTSTR args[5];    

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting DeleteRemoveExecutable");

    *pbDeletedRemoveExecutable = FALSE;
    *pbGotoEnd = FALSE;

    filelist = RemoveExecutableFile;

    done = FALSE;
    while ( ! done ) {

        sprintf(wrk,
            "DeleteRemoveExecutable:call RMVDeleteProductFiles with title = \"%s\" and pathname = \"%s\"",
            title, pathname);
        WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
        stat = RMVDeleteProductFiles (hwndowner, 
                                      title, 
                                      filelist, 
                                      pathname);

        if ( (stat == RMV_ABORT) || (stat == RMV_SYSERR) ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "DeleteRemoveExecutable:pl_return_status set");
            *pl_return_status = stat;
            *pbGotoEnd = TRUE;
            goto end;
        } else if ( stat == RMV_IGNORE ) {

            // SILENTMODE_BREAK
            if ( RMVGetSilentMode() ) {
                *pl_return_status = RMVGetErrorMode();
                if ( *pl_return_status == RMV_IGNORE ) {
                    break;
                } else {
                    *pbGotoEnd = TRUE;
                    goto end;
                }
            }

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
                WriteToRemoveLogFile(__FILE__, __LINE__, "DeleteRemoveExecutable:pl_return_status set");
                *pl_return_status = RMV_IGNORE;
                done = TRUE;
            } else if ( stat == IDABORT ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "DeleteRemoveExecutable:pl_return_status set");
                *pl_return_status = RMV_ABORT;
                *pbGotoEnd = TRUE;
                goto end;
            } else if ( stat == 0 ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "DeleteRemoveExecutable:pl_return_status set");
                *pl_return_status = RMV_SYSERR;
                *pbGotoEnd = TRUE;
                goto end;
            }

        } else {
            *pbDeletedRemoveExecutable = TRUE;
            done = TRUE;
        }
    }

  end:
    sprintf(wrk,
        "DeleteRemoveExecutable:*pbDeletedRemoveExecutable = %d, *pbGotoEnd = %d, *pl_return_status = %d",
        *pbDeletedRemoveExecutable, *pbGotoEnd, *pl_return_status);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    WriteToRemoveLogFile(__FILE__, __LINE__,
        "DeleteRemoveExecutable returns VOID");
} // DeleteRemoveExecutable


/******************************************************************************

    SYNOPSIS

    static BOOLEAN UserWantsDeleteMark(HWND hwndowner,
                      LPTSTR title)


    PARAMETERS

        NAME           ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----           --------------------------------------------------------

        hwndowner      I - handle of owner window for message boxes
        title          I - title to display on message boxes

    RETURN VALUE

        TRUE  - user responded affirmatively
        FALSE - user didn't respond affirmatively 

    DESCRIPTION

        This function determines whether the user wants to mark the remove
        executable file in the system directory to be deleted at the next
        machine reboot.  If silent mode is in effect, it returns no.

    CHANGE HISTORY

        07-MAR-1996 afb    Initial creation.  (Alan Barksdale)

******************************************************************************/

static BOOLEAN UserWantsDeleteMark(HWND hwndowner,
                  LPTSTR title)

{
    INT stat;                               

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting UserWantsDeleteMark");

    if ( RMVGetSilentMode () ) {
        WriteToRemoveLogFile(__FILE__, __LINE__, "UserWantsDeleteMark returns FALSE");
        return(FALSE);
    } else {
        stat = ISDKStringIdBox (hwndowner,
                                RMVGetResourceDll(),
                                NULL,
                                DELETE_MARK,
                                RMVGetLangId(),
                                title,
                                RMVGetMessageLen(),
                                MB_ICONEXCLAMATION | 
                                MB_YESNO | MB_DEFBUTTON2);
    
        UpdateWindow (hwndowner);
    
        if ( stat == IDYES ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "UserWantsDeleteMark returns TRUE");
            return(TRUE);
        } else {
            WriteToRemoveLogFile(__FILE__, __LINE__, "UserWantsDeleteMark returns FALSE");
            return(FALSE);
        }
    }
} // UserWantsDeleteMark


/*
**  This character string array defines the root product directory for the
**  SetupSDK product, listing the delivered files into the root product 
**  directory and all the subdirectories off of the root product directory.  
**  This character string array is passed to the RemoveProductDirsAndFiles() 
**  function to delete the files and subdirectories listed.
**
**  This list does not contain our remove process or its resource dll.  These
**  two files will be dynamically added to a "file to delete on reboot" list 
**  once our installation path is determined.
*/

// This list defines the top level dirs and files installed by the product
// other than RISCLI.  The remove appends these name to the product path for
// removal. This should END WITH NULL, any additions to this list should be
// made before the NULL.
static TCHAR *UnexpectedFiles[] = { 
                                    //".", "d",
                                    NULL
                                  };
#if defined(RISCLI)
// static TCHAR *StandaloneFiles[] = { NULL };
// static TCHAR *WorkstationFiles[] = { NULL };
#elif defined(RISAPP)
static TCHAR *StandaloneFiles0504[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "fixes.txt", "f", // 1996.08.09:Alan Barksdale:TR43961715
                                    "include", "d",
                                    "install.log", "f",
                                    "lib", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "remove.bat", "f",
                                    "samples", "d",
                                    "shared", "d",
                                    NULL
                                  };
// 1996.03.29:TR439503973:Alan Barksdale:made after looking at old remove code from Pinnacle and SPC
static TCHAR *StandaloneFiles0503[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "include", "d",
                                    "lib", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "samples", "d",
                                    "shared", "d",
                                    NULL
                                  };
static TCHAR *StandaloneFiles0502[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "deliv", "d",
                                    "include", "d",
                                    "install.log", "f",
                                    "lib", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    "samples", "d",
                                    "shared", "d",
                                    NULL
                                  };
static TCHAR *StandaloneFiles0501[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "deliv", "d",
                                    "include", "d",
                                    "install.log", "f",
                                    "lib", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    "samples", "d",
                                    "shared", "d",
                                    NULL
                                  };
static TCHAR *StandaloneFiles0500[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "deliv", "d",
                                    "include", "d",
                                    "lib", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    "samples", "d",
                                    "shared", "d",
                                    NULL
                                  };
static TCHAR *StandaloneFiles0403[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "deliv", "d",
                                    "include", "d",
                                    "lib", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    "samples", "d",
                                    "shared", "d",
                                    NULL
                                  };
static TCHAR *WorkstationFiles0504[] = { NULL };
static TCHAR *WorkstationFiles0503[] = { NULL };
static TCHAR *WorkstationFiles0502[] = { NULL };
static TCHAR *WorkstationFiles0501[] = { NULL };
static TCHAR *WorkstationFiles0500[] = { NULL };
static TCHAR *WorkstationFiles0403[] = { NULL };
#elif defined(RISSRV)
static TCHAR *StandaloneFiles0504[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "fixes.txt", "f", // 1996.08.09:Alan Barksdale:TR43961715
                                    "install.log", "f",
                                    "manifest.txt", "f",
#if defined(risinfds) || defined(risinfns)
                                    "msg", "d",
#endif
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "remove.bat", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
static TCHAR *StandaloneFiles0503[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "manifest.txt", "f",
#if defined(risinfds) || defined(risinfns)
                                    "msg", "d", // in 531, not in 530, but won't hurt
#endif
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
static TCHAR *StandaloneFiles0502[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
static TCHAR *StandaloneFiles0501[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
static TCHAR *StandaloneFiles0500[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
static TCHAR *StandaloneFiles0403[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
// 1996.02.07:Alan Barksdale:WorkstationFiles apparently should be the same as
//	StandaloneFiles for RIS data servers based on the previous RIS remove
//	code.
static TCHAR *WorkstationFiles0504[] = {
                                    "bin", "d",
                                    "config", "d",
                                    "fixes.txt", "f", // 1996.08.09:Alan Barksdale:TR43961715
                                    "install.log", "f",
                                    "manifest.txt", "f",
#if defined(risinfds) || defined(risinfns)
                                    "msg", "d",
#endif
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "remove.bat", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
static TCHAR *WorkstationFiles0503[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "manifest.txt", "f",
#if defined(risinfds) || defined(risinfns)
                                    "msg", "d", // in 531, not in 530, but won't hurt
#endif
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
static TCHAR *WorkstationFiles0502[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
static TCHAR *WorkstationFiles0501[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
static TCHAR *WorkstationFiles0500[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
static TCHAR *WorkstationFiles0403[] = { 
                                    "bin", "d",
                                    "config", "d",
                                    "manifest.txt", "f",
                                    "prod.ini", "f",
                                    "readme.txt", "f",
                                    "settings.ini", "f",
                                    NULL
                                  };
#endif // #elif defined(RISSRV)

/******************************************************************************

    SYNOPSIS

    LONG RISRemoveProduct (HWND hwndowner,
                      LPTSTR title,
                      LPTSTR version_string,
                      PVOID *appdata,
                      BOOLEAN delete_removal,
                      BOOLEAN delete_mark,
                      BOOLEAN delete_tmp_dir,
                      BOOLEAN ask_delete,
                      PINT remove)


    PARAMETERS

        NAME           ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----           --------------------------------------------------------

        hwndowner      I - handle of owner window for message boxes
        title          I - title to display on message boxes
        version_string I - string of version, e.g., "05.04", of product to
                           delete; if NULL will assume current version; if not
                           current version, will cause deletion of everything
                           under and including the directory in the PathName
                           registry value
        appdata        I - for a shared component, this is the list entry to
                           remove from the component's reference list; 
                           otherwise, not used 
        delete_removal I - if TRUE, try to delete the removal executable
        delete_mark    I - if TRUE, mark the removal executable to be deleted
                           at the next reboot and display dialog box asking the
                           user whether to reboot; if FALSE, don't
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
        06-MAR-1996 afb    At Melania Stewart's request, added delete_mark
                           flag so that the installation code, which calls this
                           function when the user installs the same version of
                           the product on top of itself, would not present the
                           user with the reboot question dialog and would not
                           mark the removal executable to be deleted on the
                           next reboot.
        13-MAR-1996 afb    At Melania Stewart's request, added the
                           version_string parameter to assist in installation.
        25-MAR-1996 afb    Added delete_removal as a result of a request from 
                           Melania Stewart.
        16-APR-1996 afb    Added delete_tmp_dir so that the installation
                           process wouldn't try to delete a directory it was
                           still using.
        16-MAY-1996 afb    Added ask_delete for TR439601110 and TR439601111 on
                           the user's being presented with a box asking him
                           whether to delete a product direcetory during
                           installation of a RIS producut on top of itself.
        03-JUL-1996 afb    TR439601255 fix.  See below.

******************************************************************************/


// LONG RemoveSetupSDK (HWND hwndowner,
extern LONG RISRemoveProduct(HWND hwndowner,
                  LPTSTR title,
                  LPTSTR version_string,
                  PVOID *appdata,
                  BOOLEAN delete_removal,
                  BOOLEAN delete_mark,
                  BOOLEAN delete_tmp_dir,
                  BOOLEAN ask_delete,
                  PINT remove)

{
    BOOL done;

#if !defined(RISCLI)
    DWORD dirs;
    DWORD files;
#endif // #if !defined(RISCLI)
    DWORD i;
#if !defined(RISCLI)
    DWORD keys;
    DWORD values;

    INT platform;
#endif // #if !defined(RISCLI)
    INT stat;                               

    LONG return_status = RMV_CONTINUE;   /* default return value */

#if !defined(RISCLI)
    LPTSTR addr = NULL;                  /* temp var for ISDKGetFullPathName */
    LPTSTR ptr = NULL;                   /* temp var for registry value name */
#endif // #if !defined(RISCLI)
    LPTSTR systemDir = NULL;
#if !defined(RISCLI)
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
#endif // #if !defined(RISCLI)
    char product_list_value[cchMax];

    BOOLEAN bDeletedRemoveExecutable = FALSE;
    BOOLEAN bGotoEnd = FALSE;

    WriteToRemoveLogFile(__FILE__, __LINE__, "Starting RISRemoveProduct");
    sprintf(wrk,
        "RISRemoveProduct:title = \"%s\", version_string = \"%s\", delete_removal = %d, delete_mark = %d, delete_tmp_dir = %d, ask_delete = %d",
        STRING(title), STRING(version_string), delete_removal, delete_mark,
        delete_tmp_dir, ask_delete);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    assert(strlen(VERSIONSTRING) == strlen(VERSIONSTRING_MACRO(version_string))); // sanity check

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

    strcpy(product_list_value, PRODUCTNAME "\\");
    strcat(product_list_value, VERSIONSTRING_MACRO(version_string));
    RemoveRISEx(VERSIONSTRING_MACRO(version_string), delete_tmp_dir,
        ask_delete, RegRemoveRISEx(VERSIONSTRING_MACRO(version_string),
        product_list_value));

#if !defined(RISCLI)


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
#endif // #if !defined(RISCLI)
    systemDir = ISDKGetDirectory (SYSTEM_DIR);
#if !defined(RISCLI)

    /*
    ** "installmode" must be set before we can check its value.  If its value
    ** is not what we expect, don't set the ptr value but set an error code.
    ** In this manner, both installmode and ptr must be set to continue.
    */

    // 1996.07.02:Alan Barksdale:TR439601255:It appears that before RIS 5.3.0,
    // RIS servers did not use the registry value InstallMode.
#if defined(RISSRV)
    if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.02") ||
        !strcmp(VERSIONSTRING_MACRO(version_string), "05.01") ||
        !strcmp(VERSIONSTRING_MACRO(version_string), "05.00") ||
        !strcmp(VERSIONSTRING_MACRO(version_string), "04.03") ) {
        ptr = PATHNAME_VALUE;
        if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.02") ) {
            filelist = StandaloneFiles0502;
        } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.01") ) {
            filelist = StandaloneFiles0501;
        } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.00") ) {
            filelist = StandaloneFiles0500;
        } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "04.03") ) {
            filelist = StandaloneFiles0403;
        }
    } else {
#endif
        if ( (installmode = INGRGetRegValue (PRODUCTNAME,
                                             VERSIONSTRING_MACRO(version_string),
                                             INSTALLMODE_VALUE)) ) {
            if ( strcmpi (installmode, STANDALONE_MODE) == 0 ) {
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
                        "RISRemoveProduct:version_string \"%s\" unexpected; therefore will delete none of the contents of the standalone product directory",
                        STRING(VERSIONSTRING_MACRO(version_string)));
                    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
                }
            } else if ( strcmpi (installmode, WORKSTATION_MODE) == 0 ) {
                ptr = LOCALPATHNAME_VALUE;
                if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.04") ) {
                    filelist = WorkstationFiles0504;
                } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.03") ) {
                    filelist = WorkstationFiles0503;
                } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.02") ) {
                    filelist = WorkstationFiles0502;
                } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.01") ) {
                    filelist = WorkstationFiles0501;
                } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "05.00") ) {
                    filelist = WorkstationFiles0500;
                } else if( !strcmp(VERSIONSTRING_MACRO(version_string), "04.03") ) {
                    filelist = WorkstationFiles0403;
                } else {
                    filelist = UnexpectedFiles;
                    sprintf(wrk,
                        "RISRemoveProduct:version_string \"%s\" unexpected; therefore will delete none of the contents of the workstation product directory",
                        STRING(VERSIONSTRING_MACRO(version_string)));
                    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
                }
            } else {
                SetLastError (ERROR_INVALID_PARAMETER);
            }
        }

        strcpy(full_versionstring_key, HKEY_LOCAL "\\" PRODUCTNAME_KEY "\\");
        strcat(full_versionstring_key, VERSIONSTRING_MACRO(version_string));
        sprintf(wrk, "RISRemoveProduct:full_versionstring_key = \"%s\"",
            full_versionstring_key);
        WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

        if ( ! installmode || ! ptr ) {
            WriteToRemoveLogFile(__FILE__, __LINE__,
                "RISRemoveProduct:install mode registry path error");

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
            
            WriteToRemoveLogFile(__FILE__, __LINE__,
                "RISRemoveProduct:return_status set");
            return_status = RMV_ABORT;
            goto end;

        }
        sprintf(wrk, "RISRemoveProduct:installmode = \"%s\"", installmode);
        WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
#if defined(RISSRV)
    } // else RISSRV and before 05.03
#endif

    if ( ! (pathname = INGRGetRegValue (PRODUCTNAME,
                                        VERSIONSTRING_MACRO(version_string),
                                        ptr)) ) {
        WriteToRemoveLogFile(__FILE__, __LINE__,
            "RISRemoveProduct:path name registry path error");

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
            
        WriteToRemoveLogFile(__FILE__, __LINE__,
            "RISRemoveProduct:return_status set");
        return_status = RMV_ABORT;
        goto end;

    }
    sprintf(wrk,"RISRemoveProduct:pathname = \"%s\"", pathname);
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
                WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                return_status = RMV_IGNORE;
                done = TRUE;
            } else if ( stat == IDABORT ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                return_status = RMV_ABORT;
                goto end;
            } else if ( stat == 0 ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                return_status = RMV_SYSERR;
                goto end;
            }
        }
    }
    sprintf(wrk,"RISRemoveProduct:prodno = \"%s\"", prodno);
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
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                    return_status = stat;
                } else if ( stat == RMV_ABORT ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                    return_status = stat;
                    goto end;
                } else if ( stat == RMV_SYSERR ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                    return_status = stat;
                    goto end;
                }
            
            }

            ISDKFREE (tmpdir);
        }
        WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct");
    } // if(delete_tmp_dir)

    /*
    ** Time to begin.  Check to see if the root path points to a valid 
    ** directory.  If the directory is valid, we perform the required file 
    ** manipulations.  If the directory is not valid, indicate the error and 
    ** let the user determine whether to proceed.  Note:  all file handling 
    ** functions do not consider a file/path not found to be an error via the 
    ** macro GETLASTERROR_CHECK() with the appropriate error code.
    */

#if defined(RISAPP) // 1996.07.24:Alan Barksdale:TR439503097:We deliver nothing to the LocalPathName directory in a "workstation" delivery.
    if ( strcmpi (installmode, STANDALONE_MODE) == 0 ) {
#endif // #if defined(RISAPP)
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
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                    return_status = RMV_IGNORE;
                    done = TRUE;
                } else if ( stat == IDABORT ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                    return_status = RMV_ABORT;
                    goto end;
                } else if ( stat == 0 ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                    return_status = RMV_SYSERR;
                    goto end;
                }
            }
        }
        WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct");
#if defined(RISAPP) // 1996.07.24:Alan Barksdale:TR439503097:We deliver nothing to the LocalPathName directory in a "workstation" delivery.
    } // if in workstation mode, i.e., product delivered from administrative delivery
#endif // #if defined(RISAPP)

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
                WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                return_status = RMV_IGNORE;
                done = TRUE;
            } else if ( stat == IDABORT ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                return_status = RMV_ABORT;
                goto end;
            } else if ( stat == 0 ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                return_status = RMV_SYSERR;
                goto end;
            }
        } else {
            done = TRUE;    /* directory successfully moved */
        }
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct");

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

        sprintf(wrk,
            "RISRemoveProduct:call RMVDeleteProductFiles with title = \"%s\" and pathname = \"%s\"",
            title, pathname);
        WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
        stat = RMVDeleteProductFiles (hwndowner, 
                                      title, 
                                      filelist, 
                                      pathname);

        if ( (stat == RMV_ABORT) || (stat == RMV_SYSERR) ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
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
                WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                return_status = RMV_IGNORE;
                done = TRUE;
            } else if ( stat == IDABORT ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                return_status = RMV_ABORT;
                goto end;
            } else if ( stat == 0 ) {
                WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                return_status = RMV_SYSERR;
                goto end;
            }

        } else {
            done = TRUE;
        }
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct");

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
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                    return_status = stat;
                } else if ( stat == RMV_ABORT ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                    return_status = stat;
                    goto end;
                } else if ( stat == RMV_SYSERR ) {
                    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                    return_status = stat;
                    goto end;
                }
                
            }
        }
    } else if ( stat == RMV_IGNORE ) {
        WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
        return_status = RMV_IGNORE;
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct");

    /* 
    ** Now we try to delete the program groups. Since we
    ** don't do error checking here, we delete any icon we may create on 
    ** install since we don't track the type of installation (yet).
    */


    {
      char szProgramGroup[cchMax]; // 1996.03.26:Alan Barksdale:to handle deleting old versions
      char *szVersion;
      LPCTSTR group = NULL;

      if ( ! (group = ISDKLoadString (RMVGetResourceDll(), IDS_PM_TITLE)) ) {

          /* to be replaced with ResourceError() */

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

          WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:goto end");
          goto end;
      }

      strcpy(szProgramGroup, group);
      szVersion = szProgramGroup + strlen(szProgramGroup) - strlen(VERSIONSTRING);
      strcpy(szVersion, VERSIONSTRING_MACRO(version_string));
    
      stat = RMVDeleteProgramGroup (GetActiveWindow(),
                                    NULL,
                                    szProgramGroup, //group,
                                    COMMON_PROGRAM_GROUP);

      ISDKLOCALFREE (group);

      if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
          WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
          return_status = stat;
          goto end;
      } else if ( stat == RMV_IGNORE ) {
          WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
          return_status = RMV_IGNORE;
      }
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct");
  
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
        WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
        return_status = stat;
        goto end;
    } else if ( stat == RMV_IGNORE ) {
        WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
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
            WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
            return_status = stat;
            goto end;
        } else if ( stat == RMV_IGNORE ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
            return_status = RMV_IGNORE;
        }
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct");

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
            WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
            return_status = stat;
        } else if ( stat == RMV_IGNORE ) {
            WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
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


        /* 1996.02.05:Alan Barksdale:vvv Think these are only used with
		utilities in shared component.
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
                  WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                  return_status = stat;
                  goto end;
              } else if ( stat == RMV_IGNORE ) {
                  WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                  return_status = RMV_IGNORE;
              }
          }
        }
        1996.02.05:Alan Barksdale:^^^ */
    }
    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct");
#endif // #if !defined(RISCLI)

    // 1996.07.02:Alan Barksdale:Remove executables were named and located
    // differently before RIS 5.4.  This function will only be called by
    // a RIS 5.4 or later setup.  Hence, if the version passed to this
    // function is before 5.4, it's being called to remove an old version
    // during installation and doesn't need to handle the remove
    // executable specially.  Done for TR439601255.
    if( strcmp(VERSIONSTRING_MACRO(version_string), "05.03") &&
        strcmp(VERSIONSTRING_MACRO(version_string), "05.02") &&
        strcmp(VERSIONSTRING_MACRO(version_string), "05.01") &&
        strcmp(VERSIONSTRING_MACRO(version_string), "05.00") &&
        strcmp(VERSIONSTRING_MACRO(version_string), "04.03") ) {

        if(delete_removal) {
            DeleteRemoveExecutable(hwndowner, title, systemDir,
                &bDeletedRemoveExecutable, &bGotoEnd, &return_status);
            if(bGotoEnd) {
                goto end;
            }
        }

        if(!bDeletedRemoveExecutable && delete_mark) {
            /* 
            ** Mark our files for delete if this is a standalone installation.  
            ** If we are successful, reboot the machine.
            */

#if defined(RISCLI)
            if ( UserWantsDeleteMark(hwndowner, title) ) {
#elif defined(RISAPP) || defined(RISSRV)
            // 1996.07.24:Alan Barksdale:TR439503097:Commenting out "standalone" condition because we're delivering the remove executable in "workstation" deliveries.
            if ( /* strcmpi (installmode, STANDALONE_MODE) == 0 && */
                UserWantsDeleteMark(hwndowner, title) ) {
#endif

                //TCHAR *MoveFileList[4] = { NULL, NULL, NULL, NULL };
                TCHAR *MoveFileList[1] = { NULL };
                MoveFileList[0] = ISDKStrCatN (2, 
                                               systemDir, 
#if defined(RISCLI)
                                               "rm" RIS_VERSION_MAJ_STR RIS_VERSION_MIN_STR "sc.exe");
#elif defined(RISAPP) || defined(RISSRV)
                                               "rm" PRODINDEX ".exe");
#endif
                //                               "rm000014.exe");
                //MoveFileList[1] = ISDKStrCatN (2, 
                //                               systemDir, 
                //                               "rm000014.dl1");

                for ( i = 0; 
                      i < sizeof (MoveFileList) / sizeof (*MoveFileList);
                      i++) {

                    sprintf(wrk,"RemoveProduct:MoveFileList[%d] = \"%s\"", i,
                        MoveFileList[i]);
                    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
                    if ( MoveFileList[i] ) {
                        stat = RMVMoveFileDelete (hwndowner,
                                                  title,
                                                  MoveFileList[i]);
                
                        free (MoveFileList[i]);
                
                        if ( stat == RMV_ABORT || stat == RMV_SYSERR ) {
                            WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                            return_status = stat;
                            goto end;
                        } else if ( stat == RMV_IGNORE ) {
                            WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct:return_status set");
                            return_status = RMV_IGNORE;
                        }
                    }
                }
            }
            WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct");

            /* post remove function */

    
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
            WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct");
        } // if(!bDeletedRemoveExecutable && delete_mark)
    } // if RIS version before 5.4

  end:
    WriteToRemoveLogFile(__FILE__, __LINE__, "RISRemoveProduct");

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
#if defined(RISCLI)
                       "RISCLI",
                       "N/A product number",
                       "N/A path name",
#elif defined(RISAPP) || defined(RISSRV)
                       PRODUCTNAME,
                       prodno,
                       pathname,
#endif
                       0);
    }

    ISDKTSTFREE (systemDir);
#if !defined(RISCLI)
    ISDKTSTFREE (pathname);
    ISDKTSTFREE (prodno); 
    ISDKTSTFREE (filename);
#endif // #if !defined(RISCLI)

    sprintf(wrk,"RISRemoveProduct returns %d", return_status);
    WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
    CloseRemoveLogFile();
    return return_status;
}


