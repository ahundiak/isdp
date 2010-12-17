/***********************************************************************
 *  shareapp.c from setupsdk modified for RIS                          *
 *                                                                     *
 *  Author: Melania M Stewart  Jan-1996                                *
 *  CHANGE HISTORY:                                                    *
 *  7/17/96:Supraja Gaini: Changes in fuction Do_Workstation_Setup() to*
 *  make the RISDP HELP icon on the delivery node point to the correct *
 *  help files location on the admin node.                             *
 *                                                                     *
 ***********************************************************************/
#include <windows.h>
#include <stdlib.h>
#include <direct.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

#include "setupapi.h"
#include "msdetect.h"
#include "msregdb.h"
#include "msshared.h"
#include "ingrstf.h"
#include "isdk.h"

#include "cui.h"
#include "risdlog.h"
#include "cuirsc.h"
#include "ingrbld.h"
#include "ingrext.h"
#include "ingrreg.h"
#include "ingrmdl.h"
#include "ingrw95.h"
#include "dirops.h"
#include "ris.h"
#include "shareapp.h"

#include "rissetup.h"
#include "risver.h"
#include "risdpcom.h"

extern wchar_t wcSep;

extern HANDLE hUI_DLL;
extern CHAR  szUI_DLL[];

extern DWORD messageLen;

extern TCHAR szInstallPath[];
extern TCHAR szSrcDir[];
extern TCHAR szWinDrive[];

extern LPSTR szProdIndexes[];
extern LPSTR szProdName;
extern LPSTR szProdDesc;
extern LPSTR szProdID;
extern LPSTR szProdVer;
extern LPSTR szProdRelDate;
extern LPSTR szProdType;
extern LPSTR szProdMode;

extern LPSTR szSystemDir;
extern LPSTR szWindowsDir;

extern CHAR wrk[];
extern CHAR RemoveExec [];
//
// Prototype your shared component setup functions here
//
// extern INT Shamrock_Setup(VOID);
// extern VOID Shamrock_Registry(INT action, LPSTR entryName);


VOID Admin_AskQuit()
{
	CHAR rgchT[16];
	
	while (TRUE)
	{
		// Start the dialog box
		UIStartDlg(szUI_DLL,
			   DLG_ADMIN_ASKQUIT,
			   "FQuitDlgProc",
			   DLG_APPHELP,
			   "FHelpDlgProc",
			   (LPSTR)rgchT,
			   15);
		
		// Interpret result code
		switch ((WORD)(rgchT[0]+rgchT[1]))
		{
		default:
			continue;
			
		case IDC_QUITEXIT:
			UIPopAll();
			EndSetupToolkit();
			exit(0);
			
		case IDC_CANCEL:
		case IDC_QUITCONTINUE:
			break;
		}
		
		UIPop(1);
		return;
	}
}


VOID Admin_TooBig()
{
	CHAR rgchT[16];
	
	UIStartDlg(szUI_DLL,
		   DLG_ADMIN_TOOBIG,
		   "FInfo0DlgProc",
		   0,
		   "",
		   (LPSTR)rgchT,
		   15);
	
	UIPop(1);
	return;
}


VOID Admin_GetDownloadDir()
{
	CHAR rgchT[16];
	CHAR sz[cchMax];
	CHAR szPath[cchMax];
	
        sprintf (wrk, "Entering Admin_GetDownloadDir <%s>", szInstallPath) ;
        WriteToLogFile (wrk) ;
	lstrcpy(sz, szInstallPath);
	
	while (TRUE)
	{
		lstrcpy (szPath, sz);
		StripSlash (szPath);
		SetSymbolValue("DirName", szPath);

		UIStartDlg(szUI_DLL,
			   DLG_ADMIN_DESTPATH,
			   "FDirDlgProc",
			   DLG_APPHELP,
			   "FHelpDlgProc",
			   (LPSTR)rgchT,
			   15);
		
		switch ((WORD)(rgchT[0]+rgchT[1]))
		{
		default:
			continue;

		case IDC_PATHEXIT:
			Admin_AskQuit();
			continue;
		
		case IDC_PATHCANCEL:
		case IDC_BACK:
			break;

		case IDC_CHANGEDIR:
			if (!GetCustomDirectory(szPath, sz, cchMax)) {
				continue;
			}

			/* Otherwise, fall through to verification below */
		
		case IDC_CONTINUE:
			if (!ValidateDirectory(sz, "GENERIC.EXE")) {
				continue;
			}
		}
		break;
	}

	UIPop(1);
	lstrcpy(szInstallPath, sz);
	AppendSlash(szInstallPath);
}


VOID AdminWelcomeDialog()
{
	CHAR rgchT[16];
	
	while (TRUE)
	{
		UIStartDlg(szUI_DLL,
			   DLG_ADMIN_WELCOME,
			   "FInfoDlgProc",
			   DLG_APPHELP,
			   "FHelpDlgProc",
			   (LPSTR)rgchT,
			   15);
		switch ((WORD)(rgchT[0]+rgchT[1]))
		{
		case IDC_CANCEL:
		case IDC_TYPEEXIT:
			Admin_AskQuit();
			continue;
			
		default:
			continue;
			
		case IDC_CONTINUE:
			break;
		}
		
		UIPop(1);
		return;
	}
}

VOID Do_Admin_Setup()
{
	INT		contFlag = 0;
	CHAR	rgchT[16];

	WriteToLogFile ("Starting Admin Setup") ;
	// Display welcome dialog box indicating that
	// "admin" setup is being performed, and what
	// that means.

	AdminWelcomeDialog();    
	
	// Get customer registration information.

        WriteToLogFile ("Getting customer registration information.") ;
	IngrGetRegInfo(szProdIndexes);
	
	contFlag = 0;
	while (!contFlag) {

		// Get name of directory where product should
		// be downloaded.

                WriteToLogFile ("Admin_GetDownloadDIr") ;
		Admin_GetDownloadDir();

		// I18N NOTE!
		// "SINGLE BINARY" NOTE!
		//
		// Installing a product for shared use on
		// an application server opens many cans of
		// worms.
		//
		// For example, you may be installing an app
		// on an NT server that will actually be run
		// by a group of Windows 3.1 workstations using
		// Win32s.
		//
		// Or the language setting on the server may not
		// match the setting on the client workstations.
		// (This is admittedly a small chance.)
		// 
		// DO NOT MAKE BLIND ASSUMPTIONS ABOUT WHICH
		// FILES ARE TO BE LOADED BASED ON THE CONFIGURATION
		// OF THE SERVER.
		//
		// If there is any chance for situations like this
		// where the server does not match the "client"
		// workstation configuration,
		//
		// ASK THE USER WHAT OUGHT TO BE INSTALLED.

		// if (!DoesDirExist(szInstallPath))
		// 	CreateDir(szInstallPath, cmoVital);
		// OpenLogFile(SzCatStr(szInstallPath, "INSTALL.LOG"), 0);
		
		// Build Copy List
		// In "admin" mode, this includes the normal
		// product files, the files for the Setup procedure,
		// and the Shared Component files.
		//
		// NOTE:  Shared Component files are loaded into
		//        the same directory as the rest of the
		//        product files -- NOT into the
		//        \win32app\ingr\shared directory.  AND
		//        information about the components are
		//        NOT added to the registry.  So DO NOT
		//        use the component template functions here;
		//        add the files to the copy list manually.
		//
        	//
	        // Read in the INF file that describes the structure
        	// of the files.
	        //
                sprintf (wrk, "Start AddSection szSrcDir <%s> szInstallPath <%s>", szSrcDir, szInstallPath) ;
                WriteToLogFile (wrk) ;        
        	ReadInfFile(SzCatStr(szSrcDir, "risdp.inf"));
		AddSectionFilesToCopyList("Files", szSrcDir, szInstallPath);
		AddSectionFilesToCopyList("AppFiles", szSrcDir,szInstallPath);
		AddSectionFilesToCopyList("OptFiles1", szSrcDir, szInstallPath);
		AddSectionFilesToCopyList("OptFiles2", szSrcDir, szInstallPath);
		AddSectionFilesToCopyList("OptFiles3", szSrcDir, szInstallPath);
		AddSectionFilesToCopyList("RISPack", szSrcDir, szInstallPath);
		AddSectionFilesToCopyList("SYS", szSrcDir, szInstallPath);
		
		//  Add the files for all the shared components.
		//  For an "ADMIN" setup, you DO NOT want to call
		//  the "component setup" functions.  Just bring
		//  the files down.

                /*** TR#439503097- Add the remove executable to the ADMIN directory ***/		
                AddSectionFilesToCopyList("RmvFiles", szSrcDir, szInstallPath);

		// AddSectionFilesToCopyList("Shamrock", szSrcDir,
		//        SzCatStr(szInstallPath, "SHARED"));
               AddSectionFilesToCopyList("RIS", szSrcDir, szInstallPath);
               AddSectionFilesToCopyList("NTRIS", szSrcDir, szInstallPath);
               AddSectionFilesToCopyList("WIN95RIS", szSrcDir, szInstallPath);
		
		// Files for Setup on workstations.
		// Includes a special INF file that refers to
		// files with UNCOMPRESSED names, and has only
		// one "disk" (instead of multiple floppies).

		AddSectionFilesToCopyList("WSetup", szSrcDir, szInstallPath);
		
		// Check for sufficient disk space to download files.
		// If we do not have enough, we need to tell the admin
		// and let them choose a different directory.

		if (GetCopyListCost(EXTRACOSTS, ALLNEEDS, "")) {
			Admin_TooBig();
		}
		else
			contFlag = 1;
	}
	
	// Copy the product files down to the specified directory

	CopyFilesInCopyList();
	
	// Brand the product executable with the registration data
	// above (so users running it directly from the shared drive
	// get a "valid" startup box and "about..." box).
	
	// IngrStampRegInfo("Files", "StampFile", szInstallPath);
	BrandRISFile("bin\\riscpp.exe");
	
	// That is it!  Display a message telling the admin that the
	// product has been downloaded.  Users who want to run
	// the product by connecting to a shared drive need to
	// run "setup /n" to get the app configured on their system.
	
	UIStartDlg(szUI_DLL,
		   DLG_EXIT_ADMIN_SUCCESS,
		   "FInfoDlgProc",
		   0,
		   NULL,
		   (LPSTR)rgchT,
		   15);

	// CloseLogFile();
}


VOID WS_AskQuit()
{
        CHAR rgchT[16];
	
	while (TRUE)
	{
		// Start the dialog box
		UIStartDlg(szUI_DLL,
			   DLG_WS_ASKQUIT,
			   "FQuitDlgProc",
			   DLG_APPHELP,
			   "FHelpDlgProc",
			   (LPSTR)rgchT,
			   15);
		
		// Interpret result code
		switch ((WORD)(rgchT[0]+rgchT[1]))
		{
		default:
			continue;
			
		case IDC_QUITEXIT:
			UIPopAll();
			EndSetupToolkit();
			exit(0);
			
		case IDC_CANCEL:
		case IDC_QUITCONTINUE:
			break;
		}
		
		UIPop(1);
		return;
	}
}

VOID WS_TooBig()
{
	CHAR rcghT[16];
	
	UIStartDlg(szUI_DLL,
		   DLG_WS_TOOBIG,
		   "FInfo0DlgProc",
		   0,
		   "",
		   (LPSTR)rcghT,
		   15);
	
	UIStartDlg(szUI_DLL,
		   DLG_EXIT_WS_FAILURE,
		   "FInfo0DlgProc",
		   0,
		   "",
		   (LPSTR)rcghT,
		   15);
	
	UIPopAll();
	EndSetupToolkit();
	exit(0);
}

VOID WSWelcomeDialog()
{
	CHAR rgchT[16];
	
	while (TRUE)
	{
		UIStartDlg(szUI_DLL,
			   DLG_WS_WELCOME,
			   "FInfoDlgProc",
			   DLG_APPHELP,
			   "FHelpDlgProc",
			   (LPSTR)rgchT,
			   15);
		
		switch ((WORD)(rgchT[0]+rgchT[1]))
		{
		case IDC_CANCEL:
		case IDC_TYPEEXIT:
			WS_AskQuit();
			continue;
			
		default:
			continue;
			
		case IDC_CONTINUE:
			break;
		}
		
		UIPop(1);
		return;
	}
}

VOID Do_Workstation_Setup()
{
    CHAR    rgchT[16];
    LPSTR   szPMTitle = NULL;
    LPSTR   szPMLabel = NULL;
    LPSTR   cmdstr = NULL;
    INT	    action = 0;
    DWORD   dwPlatform;
    IngrRegStruct regvalues;
	
        WriteToLogFile  ("Starting WorkStation Install") ;
	dwPlatform = ISDKGetPlatform();
	
	//
	// Read in the INF file that describes the structure
	// of the files.
	//
	ReadInfFile(SzCatStr(szSrcDir, "risdp.inf"));

	// Welcome the workstation user.  Tell him/her that this
	// procedure will configure the workstation to run this
	// application from the server's shared drive.

	WSWelcomeDialog();
	
	//wsprintf(szTmpDir, "%c:\\temp", szWinDrive[0]);
	//if (!DoesDirExist(szTmpDir))
	//	wsprintf(szTmpDir, "%c:\\", szWinDrive[0]);
	//OpenLogFile(SzCatStr(szTmpDir, "INSTALL.LOG"), 0);
	
	// Build the copy list.
	// No files need to be copied to the workstation EXCEPT the
	// shared component files.  Call each component's "template"
	// function that checks the registry and adds its files to
	// the copy list.
	
	// action = Shamrock_Setup();
	WriteToLogFile ("Calling SetupRIS") ;
	action = SetupRIS() ;
	
	// Make sure there's enough space on the "windows" drive
	// for the files that are to be copied.  If there isn't
	// enough space, we're rather stuck.  They'll have to remove
	// some files in order to continue.

	if (GetCopyListCost(EXTRACOSTS, ALLNEEDS, ""))
		WS_TooBig();
	
	// Copy the shared component files to the workstation.
	// If *All* the shared component functions returned zero
	// (which means that none of them added anything to the
	// Copy List), *don't* call CopyFilesInCopyList(), because
	// it comes back with an error if the Copy List is empty.
	
/* TR#439503097-action > 0 if the share component files will be downloaded,
   but the remove executable will always have to come down
    if (action > 0) { */
                AddSectionFilesToCopyList("RmvFiles", szSrcDir, szSystemDir);
		CopyFilesInCopyList();
/* 	} */
	
	// Run the shared component "template" functions that configure
	// the registry for each installed component.
	
	// Shamrock_Registry(action, "TestSetup");
        WriteToLogFile ("Calling RegEdtRIS()") ;
        RegEdtRIS (action, RISDP_LIST_STR) ;
	
        // Configure the registry to hold the information about this product.
        // Note that we add a new value in the registry called "InstallMode"
        // which is set to "Workstation", indicating that this product is
        // NOT loaded on the local system.  Also note that since we
        // don't really have "szInstallPath" set to anything in a Workstation
        // setup, we use "szSrcDir" to indicate the location of the product.

        WriteToLogFile ("Updating Registry") ;
        ZeroMemory (&regvalues, sizeof(regvalues));

        regvalues.Description = szProdDesc;
        regvalues.InstallMode = WORKSTATION_MODE;
        regvalues.IDNumber = szProdID;
        regvalues.PathName = szSrcDir;
        regvalues.RelDate = szProdRelDate;
        regvalues.SoftwareType = szProdType;
        regvalues.Version = RIS_VERSION_STR;
        regvalues.LocalPathName = szInstallPath;
        regvalues.TempDeliveryDir = szCurDir;

        // If szCurDir == szSrcDir, this delivery executable has not been
        // started via setup.exe.  Clear the temporary directory to prevent
        // any accidental removal of this directory.
        //
        // TempDeliveryDir should be taken out of the IngrRegStruct.  A
        // separate get/set API should be used.  MWM

        if ( ! lstrcmpi (szCurDir, szSrcDir)) {
            regvalues.TempDeliveryDir = "";
        } else {
            regvalues.TempDeliveryDir = szCurDir;
        }

        IngrSetRegKey (HKEY_LOCAL_MACHINE,
                   szProdName,
                   RIS_MAJ_MIN_STR,
                   &regvalues);
	
	// Create the Program Manager groups and icons for the product.
	// As above, use "szSrcDir" to indicate the directory path to
	// the product's executables.
	
    if ( ! (szPMTitle = ISDKLoadString (hUI_DLL,
                                        IDS_PM_TITLE)) ) SetupError (4);

    /* README.TXT */
    if ( (szPMLabel = ISDKLoadString (hUI_DLL,IDS_PM_README)) &&
        (cmdstr = ISDKStrCatN (2, szSrcDir, README_FILE)) ) {

        ISTPProgmanItem (szPMTitle, TRUE, szPMLabel, cmdstr,
                         "", cmoOverwrite, NULL);
        ISDKLOCALFREE (szPMLabel);
        ISDKFREE (cmdstr);
        
    } else {
        SetupError (4);
    }

    /* REMOVE.EXE will be uses for remove purposes in this example */
    
    if (szPMLabel = ISDKLoadString (hUI_DLL, IDS_PM_REMOVE)) {
        
        ISTPProgmanItem (szPMTitle, TRUE, szPMLabel, RemoveExec,
                         "", cmoOverwrite, NULL);
        ISDKLOCALFREE (szPMLabel);
        
    } else {
        SetupError (4);
    }
     

        /* Help for RISDP only */
    if ( ISDKMatchPlatform (ISm_CHICAGO | ISm_NT40) ) {
    
    	CHAR cmd [512] ;
        sprintf(cmd, "%sCONFIG\\ENGLISH\\HELP\\RISDP.HLP", szSrcDir);
        ISTPProgmanItem (szPMTitle, TRUE, RISDP_PROG_REF_STR, cmd,
                         "", cmoOverwrite, NULL);
        
     	}

    else {

	 CHAR cmd [512] ;
         sprintf(cmd, "WINHLP32.EXE %sCONFIG\\ENGLISH\\HELP\\RISDP.HLP", szSrcDir);
         ISTPProgmanItem (szPMTitle, TRUE, RISDP_PROG_REF_STR, cmd,
                          "", cmoOverwrite, NULL);
        }

#if defined (USED)
    if ( (szPMLabel = ISDKLoadString (hUI_DLL, IDS_PM_ITEM2)) &&
        (cmdstr = ISDKStrCatN (2, szSrcDir, ITEM2_FILE)) ) {
        
        ISTPProgmanItem (szPMTitle, TRUE, szPMLabel, cmdstr,
                         "", cmoOverwrite, NULL);
        ISDKLOCALFREE (szPMLabel);
        ISDKFREE (cmdstr);
        
    } else {
        SetupError (4);
    }

    if ( (szPMLabel = ISDKLoadString (hUI_DLL, IDS_PM_ITEM3)) &&
        (cmdstr = ISDKStrCatN (2, szSrcDir, ITEM3_FILE)) ) {
        
        ISTPProgmanItem (szPMTitle, TRUE, szPMLabel, cmdstr,
                         "", cmoOverwrite, NULL);
        ISDKLOCALFREE (szPMLabel);
        ISDKFREE (cmdstr);
        
    } else {
        SetupError (4);
    }
#endif
#if defined (USED)
    if ( ISDKMatchPlatform (ISm_CHICAGO | ISm_NT40) ) {

        // CHICAGO and NT40 NOTE
        //
        // If your product is being installed on Windows 95,
        // you may need to register additional info for
        // "Shell Extensions" if you provide :
        //
        //     additional "property menu" (right button)
        //      selections
        //
        //     drag-drop handlers
        //
        //     additional icon handlers for application
        //      "document" files.
        //
        // This information goes in HKEY_CLASSES_ROOT, and
        // is very similar to OLE 2.0 component registration.
        //
        // See MSDN 7/1994, Vol. 3, Issue 4, p.10:
        //  "Extending the Chicago Shell"
        //
        // This code places an item on the Start menu:
        //
        //    LPSTR cmdstr;
        //
        //    if ( (szPMLabel = ISDKLoadString (hUI_DLL, IDS_PM_ITEM1)) &&
        //         (cmdstr = ISDKStrCatN (2, szInstallPath, ITEM1_FILE)) ) {
        //
        //        ISTPProgmanItem ("..", TRUE, szPMLabel, cmdstr,
        //                         "", cmoOverwrite, NULL);
        //        ISDKLOCALFREE (szPMLabel);
        //        ISDKFREE (cmdstr);
        //
        //     }
        //
        // Windows95 per-application paths


        ISTPRegisterAppPath (SzCatStr (szSrcDir, ITEM1_FILE));

        // If we deliver a shared component, use this segment to add the 
        // share path to the registered exe.

        {
          DWORD mask = 0;
          LPTSTR sharepath = NULL;

          if ( (sharepath = INGRGetShareDir (&mask)) ) {

            ISTPAddRegisterAppPath (SzCatStr (szSrcDir, ITEM1_FILE),
                                    sharepath);
            ISDKFREE (sharepath);
          }
        }

        ** Chicago and NT 4.0 applications store their remove information in
        ** the registry under an "Uninstall" key.  The application creates a
        ** key in the "Uninstall" key, and then stores two values in this key:
        **
        **    DisplayName - the string displayed in the Uninstall menu
        **    UninstallString - the command line executed by Uninstall.
        **
        ** This information is used by the Add/Remove program in the
        ** Control Panel.
        **
        ** Regardless of platform, we will store the information in a normal
        ** program item as part of our program group.
        */

        ISTPRegisterUninstall (PRODUCTNAME,
                               szPMTitle,
                               SzCatStr (szSrcDir, ITEM6_FILE));

    }
#endif
    // Write an optional remove.bat in installation directory.  This
    // points to the executable loaded in the administrator's directory and
    // allows the user to run remove.exe without knowing the location of
    // remove.exe

    //{
    //    LPCTSTR batfilename;
    //    LPCTSTR args[3];
    // 
    //    args[0] = "@cd \\\r\n";
    //    args[1] = ISDKStrCatN (3,
    //                           "@",
    //                           szSrcDir,
    //                           "remove.exe\r\n");
    //    args[2] = NULL;
    //
    //    batfilename = ISDKStrCatN (2, szInstallPath, "remove.bat");
    //
    //    if ( args[1] && batfilename ) INGRWriteFile (batfilename,
    //                                                 args);
    //
    //    ISDKTSTFREE (args[1]);
    //    ISDKTSTFREE (batfilename);
    //}

	// In some cases (RIS, to name one important example), services
	// must be installed on the workstation.  Do this here.
	
	// That is it!  We are done.  Tell the workstation user that the
	// system has been configured to run this application from the
	// network drive, and warn them that they should always make
	// sure they mount the shared directory on the same drive.
	
	UIStartDlg(szUI_DLL,
		   DLG_EXIT_WS_SUCCESS,
		   "FInfoDlgProc",
		   0,
		   NULL,
		   (LPSTR)rgchT,
		   15);

        //CloseLogFile();
}



    
