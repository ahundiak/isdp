/**********************************************************************

    FILE

        intrem.c

    DESCRIPTION


    AUTHOR                      Radha Shivakumar

    Date                         June 94

    FUNCTIONS

        InteropRemoveRIS
	InteropRemoveFiles
	InteropRegRemove
	Copyfiles
	Savefiles
        Doesfileexist
	RmtCenterWindow

	RISDeleteDirectory
	RISRemoveProductDirsAndFiles
        GetResourceString

***********************************************************************/

#include <stdio.h>
#include <ctype.h>
#include <windows.h>
#include <stdlib.h>
#include "ingrreg.h"
#include "reglib.h"
#include "rmlib.h"
#include "risrem.h"
#include "ddeprog.h"
#include "risver.h"
#include "ingrbld.h" // for cchMax
#include "interop.h"
#include "intstg.h"
#include "intrem.h"

#define MAX_STRINGS 10 // for GetResourceString
#define MAXSTRINGLEN 255 // for GetResourceString
static char wrk[cchMax];

static char interoptitle[MAX_PATH];
static HWND parent_window;
static HWND app_instance;

static char oldVer[MAX_PATH];

    // the copy box and save box values stored 
CHAR szFrom[MAX_PATH];
CHAR szTo[MAX_PATH];
CHAR SaveTo[MAX_PATH];
char from_path[MAX_PATH];
char to_path[MAX_PATH];

    // flags to set the right messages for each dialog box response
BOOL copy_flag = FALSE;
BOOL config_flag = FALSE;
BOOL remove_flag = FALSE;
BOOL save_flag = FALSE;
BOOL error_flag = FALSE;
BOOL oldver_found  = FALSE;
BOOL files_remaining = FALSE;

// This list defines the top level dirs and files installed by RIS
// The remove appends these name to the productpath for removal. This
// should END WITH NULL, Any additions to this list should be made before
// the NULL
char *FilesDirList[] =
{
	"bin\\remove.exe","f",
	"bin\\risgui.exe","f",
	"bin\\risbatch.exe","f",
	"bin\\riscli.exe","f",
	"bin\\risintop.exe","f",
	"bin\\risupgrd.exe","f",
	"bin\\risclnsr.exe","f",
	"bin\\risdcode.exe","f",
	"bin\\risdtype.exe","f",
	"bin\\rliclist.exe","f",
	"bin\\rislod.exe","f",
	"bin\\rismgr.exe","f",
	"bin\\risplbck.exe","f",
	"bin\\risrecrd.exe","f",
	"bin\\risrun.exe","f",
	"bin\\ristcpsr.exe","f",
	"bin\\risunlod.exe","f",
	"config", "d",
   "lib", "d",
   NULL
};

TCHAR ProductPath[cchMax];   /* RIS Share path      */ 

static void InteropRegRemove();
static BOOL InteropRemoveFiles (CHAR *Path);
static void Copyfiles( CHAR *From, CHAR *To);
static void Savefiles(char *From, char *To);


/**********************************************************************
	Function to see if the file exists 
**********************************************************************/
static BOOL Doesfileexist(char *path)
{
	FILE *fp = fopen(path, "r");
	
	if ( fp != NULL )
	{
	    fclose(fp);  
	    return(TRUE);
	}
	else { 
	    return(FALSE);
        }
}

/*********************************************************************/
/*
**      Purpose:
**              Information Dialog procedure.
**
**      Controls Recognized:
**              Pushbutton - CONFIG_CONT, CONFIG_CANCEL
**
**      Initialization Symbols:
**              none.
**
**      Termination Symbols:
**              "DLGEVENT" - one of the following, 
**				according to control event:
**                              event        value
**                              -------     -------
**                             CONFIG_CONT "Continue"
**                             CONFIG_CANCEL "Cancel"
**
**
**********************************************************************/
BOOL APIENTRY IInfoDlgProc(
	HWND hdlg, WORD wMsg,
	WORD wParam, LONG lParam)
{
        switch (wMsg)
        {
           case WM_INITDIALOG:
		 RmtCenterWindow (parent_window, hdlg);
                 SetFocus(hdlg);
                 break; 

           case WM_COMMAND:
              switch (wParam)
              {
                 case CONFIG_CONT:
                    config_flag = TRUE;
                    EndDialog(hdlg, 0);
                    InteropRegRemove(); 
		    break;

                 case CONFIG_CANCEL:
                    config_flag = FALSE;
                    EndDialog(hdlg, 0);
		    break;
                  
                 default: 
                    break;
              }
        }
	return(FALSE);
}



BOOL APIENTRY RemoveFilesDlgProc(
	HWND hdlg, WORD wMsg, 
	WORD wParam, LONG lParam)
{

        switch (wMsg)
        {
           case WM_INITDIALOG:
                 RmtCenterWindow (parent_window, hdlg);
		 SetDlgItemText(hdlg, OLDVERSION, (LPSTR)oldVer);
                 SetFocus(hdlg);
                 break;

           case WM_COMMAND:
              switch (wParam)
              {
                 case CONFIG_CONT:
                    EndDialog(hdlg, 0);
                    if (!RISRemoveProductDirsAndFiles(FilesDirList,
                                           ProductPath))
                           // removing the files was successful
		        remove_flag = TRUE;
                    else 
			remove_flag = FALSE;
		    break;
                 case CONFIG_CANCEL:
                    EndDialog(hdlg, 0);
	            remove_flag = FALSE;
		    break;
                 default:
                          break;
              }
        }
        return(FALSE);
}


/*******************************************************************/
/*
**      Purpose:
**              Information Edit/Copy procedure.
**
**      Controls Recognized:
**              Pushbutton - ID_RISYES, ID_RISNO
**
**      Initialization Symbols:
**              none.
**
**      Termination Symbols:
**              "DLGEVENT" - one of the following, 
**				according to control event:
**                              event     value
**                              -------   -------
**                              ID_RISYES   "YES"
**                              ID_RISNO    "NO"
**
**
********************************************************************/

BOOL APIENTRY CopyDlgProc(
	HWND hdlg, WORD wMsg, 
	WORD wParam, LONG lParam)
{
   switch (wMsg)
   {
     case WM_INITDIALOG:
        RmtCenterWindow(parent_window, hdlg);
        SetDlgItemText(hdlg, TODIR, (LPSTR)szTo);
        SetDlgItemText(hdlg, FROMDIR, (LPSTR)szFrom);
        /* mms - TR 439407352 */
        if (!strlen (szFrom))
        {
                if (SetFocus(GetDlgItem(hdlg, FROMDIR)) == NULL)
                {
                    /* mms - ignore error */
                }
                /* mms - In order for SetFocus() to work on FROMDIR, we need to return FALSE */
                return (FALSE) ;
        }
        return(TRUE);
 
     case WM_COMMAND:
        switch(wParam)
        {
          case ID_RISYES:
            GetDlgItemText(hdlg, FROMDIR, 
                          from_path, MAX_PATH);
            GetDlgItemText(hdlg, TODIR, 
			to_path, MAX_PATH);
            EndDialog(hdlg, 0);
	    if (save_flag)
		Savefiles(from_path, to_path);
            else
                Copyfiles(from_path, to_path);
            return (TRUE);
          case ID_RISNO:
             EndDialog(hdlg,0);
             copy_flag = FALSE;
             return(FALSE); 
         }     
         break;
      }

   return(FALSE);
}

/********************************************************************/

static void Copyfiles(char *From, char *To)
{
   CHAR str[MAX_PATH];
   CHAR copyFrom[MAX_PATH];
   CHAR copyTo[MAX_PATH];
   CHAR *last_dot = str;
   CHAR *last_slash = str;

   if (! Doesfileexist(From) )
   { // source file does not exist
     if (MessageBox(NULL,
	  GetResourceString(remInstance, IDS_SOURCE_MISSING),
	  GetResourceString(remInstance, IDS_CONFIG_ERROR),
               MB_OK || MB_ICONSTOP) == IDOK)
     {
       copy_flag = FALSE;
       lstrcpy(szFrom, "");
       DialogBox(app_instance, 
               MAKEINTRESOURCE(COPYBOX), 
               parent_window,
               (DLGPROC) CopyDlgProc); 
     }
   }
   else 
   {
   
         // Copy the files from source to destination
         // and fail if dest file exists...
       if (!CopyFile(From, To, TRUE))
       {
            copy_flag = FALSE;
	    save_flag = TRUE;
            lstrcpy(copyFrom, From);
            lstrcpy(copyTo, To);
            lstrcpy(szFrom, To);
	    memset(szTo, '\0', MAX_PATH);
	    last_slash =  strrchr(To, '\\');
	    if (last_slash != NULL)
	    {
	       last_dot = strrchr(last_slash, '.');
            }
            else
	    {
	       last_dot = strrchr(To, '.');
            }
	    if (last_dot)
                strncpy(szTo, To, strlen(To) - strlen(last_dot)); 
	    else 
                strcpy(szTo, To); 

	    lstrcat(szTo, ".V5");
            DialogBox(app_instance,
                    MAKEINTRESOURCE(SAVEBOX),
                    parent_window,
                    (DLGPROC) CopyDlgProc);
	    CopyFile(copyFrom, copyTo, FALSE);
       }
       else 
       {
	    save_flag = FALSE;
	    copy_flag = TRUE;
       }

   }
}


/********************************************************************/

static void Savefiles(char *SaveFrom, char *SaveTo)
{

         // Copy the files from source to destination
         // and fail if dest file exists...
       if (!CopyFile(SaveFrom, SaveTo, TRUE))
       {
 	   MessageBox(NULL,
	  	GetResourceString(remInstance, IDS_SAVE_FILE_EXIST),
	 	 GetResourceString(remInstance, IDS_CONFIG_ERROR),
               MB_OK || MB_ICONSTOP);
	   save_flag = TRUE;
	   lstrcpy(szFrom, SaveFrom);
	   lstrcpy(szTo, SaveTo);
           DialogBox(app_instance,
                    MAKEINTRESOURCE(SAVEBOX),
                    parent_window,
                    (DLGPROC) CopyDlgProc);
	
       }
       else 
       {
	  save_flag = FALSE;
	  copy_flag = TRUE;
       }
}


/******************************************************************************

    SYNOPSIS

	static VOID InteropToDirectory(
		CHAR *szOldPath,
		CHAR *szOldVersion,
		CHAR *szToDirectory)


    PARAMETERS
    
        NAME		ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----		--------------------------------------------------------

	szOldPath	(I)	old product's path from registry
	szOldVersion	(I)	old product's version number
	szToDirectory	(I)	new default directory for schemas and parms

    RETURN VALUE

        None.

    DESCRIPTION

	Fills in name of default directory to which to copy the schemas and
	parms files.

    CHANGE HISTORY

        1996.06.20	Alan Barksdale	Created in response to TR439601365.
                
******************************************************************************/

static VOID InteropToDirectory(
	CHAR *szOldPath,
	CHAR *szOldVersion,
	CHAR *szToDirectory)
{
	CHAR szShare[MAX_PATH];  /* share path from registry */

	WriteToRemoveLogFile(__FILE__, __LINE__, "Starting InteropToDirectory");

	if(RGQueryRegStringValue (INTERGRAPH_KEY, COMMON_VALUE, szShare)) {
		CHAR szOldComponent[MAX_PATH];

		lstrcpy(szToDirectory, szOldPath); // failure, so use next-best
		lstrcpy(szOldComponent, COMPONENT_OLD);
		lstrcat(szOldComponent, szOldVersion);
		lstrcpyn(szToDirectory, szOldPath,
			(lstrlen(szOldPath) - lstrlen(szOldComponent)));
	} else {
		lstrcpy(szToDirectory, szShare);
		if(lstrcmp("\\", szToDirectory + lstrlen(szToDirectory) - 1)) {
  			lstrcat(szToDirectory, "\\");
		}
	}
        lstrcat(szToDirectory, RISCOMPONENT);

	sprintf(wrk, "InteropToDirectory:szToDirectory = \"%s\"",
		szToDirectory);
	WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
	WriteToRemoveLogFile(__FILE__, __LINE__,
		"InteropToDirectory returns VOID");
} // InteropToDirectory

/********************************************************************/

static BOOL InteropRemoveFiles (
        CHAR *Path)
{
//        TCHAR RIStcp_path[cchMax];    /* RIS tcpsr path */ 
	BOOL return_value;
	BOOL schemas_copied = FALSE;
	BOOL parms_copied = FALSE;

	WriteToRemoveLogFile(__FILE__, __LINE__, "Starting InteropRemoveFiles");
	sprintf(wrk, "InteropRemoveFiles:Path = \"%s\"", Path);
	WriteToRemoveLogFile(__FILE__, __LINE__, wrk);

        /*
        ** Remove RIStcpsrService from the SERVICES
	** this is not required if used as a utility only...
	** but might be required if used as a part of setup...
        */
//       lstrcpy(RIStcp_path, Path);
//       lstrcat(RIStcp_path, "\\BIN\\RISTCPSR.EXE");
//       RISService(RIStcp_path, RIS_TCPSR_SERVICE, INSTALL_SERVICE);

        DialogBox(app_instance, 
               MAKEINTRESOURCE(CONFIG_REMOVE), 
               parent_window,
               (DLGPROC) RemoveFilesDlgProc); 

	   // Initialize the fields 
	memset(szFrom, '\0', MAX_PATH);
	memset(szTo, '\0', MAX_PATH);

	   //	Schema file copy done here            
        lstrcpy(szFrom, Path);
        lstrcat(szFrom, "\\schemas");
	InteropToDirectory(Path, oldVer, szTo);
	lstrcat(szTo, "\\schemas");
        if (! Doesfileexist(szFrom) )
        { // source file does not exist
            lstrcpy(szFrom, "");
            DialogBox(app_instance,
                    MAKEINTRESOURCE(COPYBOX),
                    parent_window,
                    (DLGPROC) CopyDlgProc);
        }
        else 
        {
             DialogBox(app_instance, 
                    MAKEINTRESOURCE(COPYBOX), 
                    parent_window,
                    (DLGPROC) CopyDlgProc); 
	}
	if (copy_flag)
	    schemas_copied = TRUE;  

	   // Initialize the fields 
	memset(szFrom, '\0', MAX_PATH);
	memset(szTo, '\0', MAX_PATH);

	   //	Parms file copy done here            
        lstrcpy(szFrom, Path);
        lstrcat(szFrom, "\\parms");
	InteropToDirectory(Path, oldVer, szTo);
        lstrcat(szTo, "\\parms");

        if (! Doesfileexist(szFrom) )
        { // source file does not exist
            copy_flag = FALSE;
            lstrcpy(szFrom, "");
            DialogBox(app_instance,
                    MAKEINTRESOURCE(COPYBOX),
                    parent_window,
                    (DLGPROC) CopyDlgProc);
        }
        else
        {
             DialogBox(app_instance,
                    MAKEINTRESOURCE(COPYBOX),
                    parent_window,
                    (DLGPROC) CopyDlgProc);
        }
	if (copy_flag)
	    parms_copied = TRUE;  

          // Delete the files and sub-directories if the copying of
          // the parms and schema files succeeds. 
          // Remove the Top Level directory if empty... will be empty
          // if the copy flag is true and no errors in removing the
          // files and dirs
	if (schemas_copied && parms_copied && remove_flag)
	{
	   if (!RISDeleteDirectory(Path, "*.*"))
	   {
               if (!RemoveTopLevelDir(Path))
		{
                 return_value = TRUE;
	        }
	       else 
		    return_value = FALSE;
	   }
	   else return_value = FALSE;
	}
	else 
	{
	   return_value = FALSE;
	}

	sprintf(wrk, "InteropRemoveFiles returns %d", return_value);
	WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
	return(return_value);
} // InteropRemoveFiles

/*********************************************************************/


extern void  InteropRemoveRIS(HWND in_parent, HWND in_instance)
{

    parent_window = in_parent;
    app_instance = in_instance;

       // Message box title 
     strncpy(interoptitle, 
		GetResourceString(remInstance, IDS_CONFIGURE_RIS),
		 MAX_PATH - 1);

       // Main Config RIS dialog box
     DialogBox(in_instance,
               MAKEINTRESOURCE(CONFIG_VERSION),
               parent_window,
               (DLGPROC) IInfoDlgProc);
     if (!config_flag || error_flag)
     {
       /*
       ** user canceled out of the config version dialog
       */
       MessageBox(NULL,
		GetResourceString(remInstance, IDS_NOT_CONFIG),
               interoptitle,
               MB_OK | MB_ICONINFORMATION);	
     }
}
/*****************************************************************************

    SYNOPSIS

        VOID RGGetOldVersion
        (
            HKEY    hkey,
            int index
            char    *latestVer
            char    *oldVer
        )

    PARAMETERS

        NAME            ACCESS/DESCRIPTION (ACCESS: I=input, O=output,I/O=both)
        ----            -------------------------------------------------------

        hkey            (I)     handle to key
        latestVer       (I)     the highest version string
        oldVer          (O)     the old version string
        index           (I)     the index of the next search

    RETURN VALUE
        0               Failure
        1               success
        2               NO_MORE_ITEMS
        3               success but not the right value

    DESCRIPTION



******************************************************************************/

int RGGetOldVersion
(
    HKEY    hkey,
    int     index,
    char    *latestVer,
    char    *oldVer
)
{
    char    curVersion[MAX_PATH];
    LONG    status;
    DWORD   size_buf;

	size_buf = sizeof(curVersion);
        status = RegEnumKeyEx(hkey, index, curVersion, &size_buf,
                        NULL, NULL, NULL, NULL);
        if (status != ERROR_SUCCESS)
        {
            if (status == ERROR_NO_MORE_ITEMS)
                return(2);
	    else 
            	return(0);
        }
        else
        {
            if ( (isdigit(curVersion[0])) &&
                            (strcmp(curVersion, latestVer)) < 0)
            {
                strcpy(oldVer, curVersion);
                return(1);
            }
	    else 
	       	return(3);
        }
}

/**********************************************************************/

static void InteropRegRemove()
{
        TCHAR szSubKey[cchMax];       /* registry key          */
        LONG    status = 0;           // success = 0  
        char    reg_key[cchMax];
        LONG    size = cchMax;
        TCHAR entry[20];
	int loop, ret, index;
	HKEY szKey;


	 // check for the RIS shared component registry entry
    sprintf(szSubKey, "%s", REG_RIS_SHARE_OLD); 
    if (RegOpenKeyEx(HKEY_LOCAL_MACHINE,szSubKey ,0,KEY_ALL_ACCESS, &szKey) 
				!= ERROR_SUCCESS)
    {
       MessageBox(NULL,
		GetResourceString(remInstance, IDS_ERROR_REGISTRY),
                interoptitle,
                 MB_OK | MB_ICONINFORMATION);
	error_flag = TRUE;
    }
    else
    {
     loop = 1;
     index = 0; 
     while (loop) 
     {
	strcpy(oldVer, "");
        ret = RGGetOldVersion(szKey, index, RIS_MAJOR_MINOR, oldVer);
	if (ret == 0)
	{
       	     MessageBox(NULL,
		GetResourceString(remInstance, IDS_ERROR_REGISTRY),
                interoptitle,
                 MB_OK | MB_ICONINFORMATION);
	     error_flag = TRUE;
	     loop = 0;
	}
	else if (ret == 3)
	     {
	         index++;
	     }
             else if (ret == 1)
	     {
		index = 0;
		// check for RIS shared component registry entry
		sprintf(szSubKey, "%s", REG_RIS_SHARE_OLD);
		strcat(szSubKey, "\\");
		strcat(szSubKey, oldVer);
	    	status = RGQueryRegStringValue(szSubKey, PATHNAME_VALUE, 
					ProductPath);
	        if (!status)
     		{ // registry entry found for older version
		  oldver_found = TRUE;
	           // Delete the \\Intergraph\\Software\\RIS\\Version subkey
       		    // and all its subkeys in the registry
         	  lstrcpy ( reg_key, REG_RIS_SHARE_OLD);
       		  status = RecursivelyDeleteSubKeys(reg_key,
        		oldVer);

       		    // The RegDeleteKey will fail if there are subkeys to 
          	    // the deleted key.
	          if (!status)
       		  {
            	     RegDeleteKey(HKEY_LOCAL_MACHINE, reg_key);
       		  }
              //  Delete all Program Items, and remove the Program Group.
      		  lstrcpy(entry, COMPONENT_OLD);
       		  lstrcat(entry, " ");
		  lstrcat(entry, oldVer);
   	         if (DeleteGroup(entry))
   	          {
   	            MessageBox (NULL, GetResourceString (remInstance, IDS_REMOVE_GROUP),
   	                interoptitle, MB_OK | MB_ICONINFORMATION) ;      
   	          }
   	          
               // Remove the RIS SC files  	
                  status = InteropRemoveFiles(ProductPath);
		  if (!status) 
			files_remaining = TRUE;

               } // else the registry entry is there
	    }
	    else
	        /* ret value is 2 (list of registry entries to be deleted 
		     has been exhausted */
	       loop = 0;
	 } /* end of while */
	 if (!oldver_found)
    	 {
      	     MessageBox(NULL,
		GetResourceString(remInstance, IDS_NOT_NECESSARY),
              	interoptitle, MB_OK | MB_ICONINFORMATION);
	 }
	 else
	 {
            if (files_remaining)
            {
              MessageBox(NULL,
               	GetResourceString(remInstance, IDS_LEFT_BEHIND),  
		interoptitle, MB_OK | MB_ICONINFORMATION);
            }
            // deleting the RIS SC files and copying the parms and
            // schemas was successful
            MessageBox(NULL,
		GetResourceString(remInstance, IDS_CONFIG_SUCCEED),
                interoptitle, MB_OK | MB_ICONINFORMATION);
	 } /* else old version found */
     }
}

// 1996.01.16:Alan Barksdale:Copied from remove\rmlib.c for Setup SDK 2.2.0.0
// because needed SetFileAttributes
LONG RISDeleteDirectory
(
    char    *directory,
    char    *pattern
)
{
    LONG    status  = RMT_SUCCESS;
    WIN32_FIND_DATA data;
    HANDLE  handle;
    char    new_path[256];
    char    del_path[256];

    WriteToRemoveLogFile(__FILE__,__LINE__,"Starting RISDeleteDirectory");
    sprintf(wrk,"RISDeleteDirectory:directory = \"%s\",pattern = \"%s\"",directory,pattern);
    WriteToRemoveLogFile(__FILE__,__LINE__,wrk);
    
    sprintf(new_path, "%s\\%s", directory, pattern);
    handle = FindFirstFile(new_path, &data);
    
    if (handle != INVALID_HANDLE_VALUE)
    {
        do
        {
            if (data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
            {
                if ((strcmp(data.cFileName,".")) &&
                            (strcmp(data.cFileName,"..")) )
                {            
                    sprintf(new_path,"%s\\%s", directory, data.cFileName);
                    status = RISDeleteDirectory(new_path, pattern);
                    RemoveTopLevelDir(new_path);
                }                    
            }
            else
            {
                sprintf(del_path,"%s\\%s",directory, data.cFileName);
                SetFileAttributes(del_path, FILE_ATTRIBUTE_NORMAL);
                if (!DeleteFile(del_path))
                {
                    // fprintf(stderr, "Failed to delete file %s, return status (0x%02x)\n",
                    //                     del_path, GetLastError());
                    status = RMT_FAILURE;                    
                }
            }
        }   while (FindNextFile(handle, &data));
        FindClose(handle);
     }
    else
    {
        // fprintf(stderr, "FindFirstFile failed for dir \"%s\", return status (0x%02x)\n", 
        //                            new_path, GetLastError());
        status = RMT_FAILURE;
    }

    sprintf(wrk,"RISDeleteDirectory returns %d",status);
    WriteToRemoveLogFile(__FILE__,__LINE__,wrk);
    return status;
}

// 1996.01.16:Alan Barksdale:Copied from remove\rmlib.c for Setup SDK 2.2.0.0
//	because needed SetFileAttributes
LONG  RISRemoveProductDirsAndFiles
(
    char    **FilesDirList,
    char    *ProductPath
)
{
    LONG    status = RMT_SUCCESS;
    BOOL    del_file_st;
    char    del_path[MAX_PATH];
    DWORD   dwLastError; // 1995.08.14:Alan Barksdale

    WriteToRemoveLogFile(__FILE__,__LINE__,"Starting RISRemoveProductDirsAndFiles");
    
    // For each dir/file in the FilesDirList Prepend the ProductPath and
    // then call RISDeleteDirectory. 
        
    while (*FilesDirList)
    {
        // Check to see if the ProductPath ends in a backslash.
            
        if (ProductPath[strlen(ProductPath)-1] == '\\')
        {
            sprintf(del_path,"%s%s", ProductPath, *FilesDirList);
        }
        else
        {
            sprintf(del_path,"%s\\%s", ProductPath, *FilesDirList);
        }
	sprintf(wrk,"RISRemoveProductDirsAndFiles:del_path = \"%s\"",del_path);
	WriteToRemoveLogFile(__FILE__,__LINE__,wrk);
        FilesDirList++;
        
        if (!strcmp(*FilesDirList, "d"))
        {
            WriteToRemoveLogFile(__FILE__,__LINE__,"RISRemoveProductDirsAndFiles:delete directory");
            // Call RISDeleteDirectory on the complete path name. This is 
            // necessary to make the directory empty before it can be removed.
            // If the del_path path is a directory, all the directories and 
            // files under it will be DELETED recursively.
            
            status = RISDeleteDirectory(del_path, "*.*");
            sprintf(wrk,"RISRemoveProductDirsAndFiles:RISDeleteDirectory status = %d",status);
            WriteToRemoveLogFile(__FILE__,__LINE__,wrk);
            
            // Now delete the non empty directory
            
            status = RemoveTopLevelDir(del_path);
            sprintf(wrk,"RISRemoveProductDirsAndFiles:RemoveTopLevelDir status = %d",status);
            WriteToRemoveLogFile(__FILE__,__LINE__,wrk);
        }
        else
        {
            WriteToRemoveLogFile(__FILE__,__LINE__,"RISRemoveProductDirsAndFiles:delete file");
            SetFileAttributes(del_path, FILE_ATTRIBUTE_NORMAL);
            del_file_st = DeleteFile(del_path);
            if (del_file_st)
            {
                status = RMT_SUCCESS;
            }
            else
            {
                dwLastError = GetLastError();
                sprintf(wrk,"RISRemoveProductDirsAndFiles:DeleteFile(\"%s\") returns failure, GetLastError returns %d",del_path,dwLastError);
                WriteToRemoveLogFile(__FILE__,__LINE__,wrk);
                status = RMT_FAILURE;
             }
        }
        FilesDirList++;
    }        

    sprintf(wrk,"RISRemoveProductDirsAndFiles returns %d",status);
    WriteToRemoveLogFile(__FILE__,__LINE__,wrk);
    return status;
}    

/****************************************************************************
   FUNCTION: GetResourceString
   PURPOSE:  Uses strings from stringtable whereever you want
   COMMENTS: 1st position ! to continue with next line
****************************************************************************/
// requires the calling program to set remInstance
char * GetResourceString (HINSTANCE hInstance, UINT nID, ...)
{
   static int WhichString =0;
   static char szLoadedString1[MAX_STRINGS][MAXSTRINGLEN];
   BOOL bKeepLoading;
   char *szLoadedString;
   char szLoadBuffer[MAXSTRINGLEN];
   int i;
   TCHAR    szFormat[255];
   va_list  va;

	WriteToRemoveLogFile(__FILE__,__LINE__,"Starting GetResourceString");

   szLoadedString = szLoadedString1[WhichString];
   WhichString++;
   if (WhichString == MAX_STRINGS)
      WhichString=0;

   szLoadedString[0]=0;

   do
   {
      bKeepLoading = FALSE;
      i = LoadString(hInstance,nID,szFormat,sizeof(szFormat));
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
         sprintf(wrk, "GetResourceString:LoadString failed with GetLastError = %ld", GetLastError());
         WriteToRemoveLogFile(__FILE__, __LINE__, wrk);
	 MessageBox(NULL,"LoadString failed.  Does your program have remInstance = YOUR INSTANCE ?","Error",MB_OK | MB_TASKMODAL | MB_ICONSTOP);
      }
   }
   while (bKeepLoading);

	sprintf(wrk,"GetResourceString returns \"%s\"",szLoadedString);
	WriteToRemoveLogFile(__FILE__,__LINE__,wrk);
   return((LPSTR)szLoadedString);
}/* RK_szLoadString */
