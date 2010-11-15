/****************************************************************************************
 *         Modified example.c from setupsdk csource directory                           *         
 *         Melania M Stewart Jan-1996                                                   *        
 ****************************************************************************************/ 
#include <windows.h>
#include <stdlib.h>
#include <direct.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include <locale.h>

#include "setupapi.h"
#include "msdetect.h"
#include "msregdb.h"
#include "msshared.h"
#include "ingrext.h"
#include "isdk.h"
#include "dirops.h"

#include "cui.h"
#include "risdlog.h"
#include "cuirsc.h"
#include "ingrbld.h"
#include "ingrreg.h" 
#include "ingrrmv.h" 
#include "ingrstf.h"
#include "ingrw95.h"
#include "shareapp.h"
/************* RIS HEADER FILES **********************************/
#include "ris.h"
#include "risver.h"
#include "rissetup.h"   /* delivered with shared component */
#include "setupver.h"
#if defined (RISAPP) || defined (RISSRV)
#include "rmprod.h"
#endif
#if defined (RISCLI) || defined (RISAPP)
#include "risdpcom.h"   /* macros common with remove */
#endif
#if defined (RISSRV)
#include "defines.h"
#endif
#if defined (RISCLI)
extern LPTSTR GetLocalString (HMODULE hMod, UINT uID, LPTSTR szResult, int cbResult);
#endif


#if defined(RISAPP)
	static VOID AppendPathBinToSystemPath(CHAR *szNewPath,
		BOOL bAddQuotesOnNT, BOOL *pbRebootFlag);
	extern VOID AppendToSystemPath(CHAR *szNewPath, BOOL bAddQuotesOnNT,
		BOOL *pbRebootFlag);
	extern void  Change_wcSep (int) ;
#endif // #if defined(RISAPP)
static  LPSTR FormatValue (LONGLONG, LPSTR);
static  VOID  BuildLists (VOID);
static  VOID  BuildCopyList (VOID);
static  VOID  BuildCopyListForSizing (VOID);
static void AddShareComponent (char *szSrcDir, char *szInstallPath) ;
static  VOID  BuildBillboardList (VOID);
static  VOID  Install (VOID);
static  VOID  WelcomeDialog (VOID);
static  VOID  InstallTypeDialog (VOID);
static  VOID  TooBig (VOID);
static  INT   FInstallPathDialog (VOID);
static  VOID  HandleOptFiles (INT);
static  INT   CustInstDialog (VOID);
static  VOID  AddOptFilesToCopyList (INT , INT );
static  VOID  RecalcOptFiles (INT);
static  VOID  RecalcPath (VOID);
static  VOID  SetDriveStatus (VOID);
static  VOID  RunBatchMode (VOID);
static  long  RISValidateDirectory (char *);
static  long  RISValidateThisVersion ();
static  long  RISValidateVersions( BOOLEAN );
extern  void  RISRemoveProduct (HWND, LPTSTR, LPTSTR, PVOID *, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, PINT) ;
static  BOOL  ConfirmDeleteDir(INT) ;
extern  BOOL  GetFullSubKeyFromPath(HKEY,LPTSTR,LPTSTR,LPTSTR) ;
extern  BOOL  APIENTRY FRemoveProgManGroupEx(LPSTR, BOOL, INT);
extern  void GetMajorMinor(CHAR *, CHAR *) ;
#if defined(risinfds) || defined(risinfns)
static  VOID  UpdateInformixServerReg () ;
#endif
static void ReBoot(HINSTANCE hInstance);
extern  BOOL RebootFlag ;
static VOID RISSetupError (char *, int, char *) ;
static VOID RISSetupWarning (char *, int, char *) ;
#if defined (RISCLI)
#define RIS_ID "c"
#define INF_FILE "risshare.inf"
#define LOG_FILE "risshare.log"
#endif
#if defined (RISSRV)
#define RIS_ID "s"
#define INF_FILE "risds.inf"
#define LOG_FILE "risds.log"
#endif
#if defined (RISAPP)
#define RIS_ID "a"
#define INF_FILE "risdp.inf"
#define LOG_FILE "risdp.log"
#endif

#define OPTION_ITEMS    5       // # of Option check items on CUSTINST form
#define NUM_DRIVES      26      // # of possible drive id letters on system

#define NUM_INDEXES     1
#define INDEX_LEN       6

#define SETUPMESSAGELEN 60

HANDLE hUI_DLL;
CHAR szUI_DLL[cchMax];
LPSTR szProdIndexes[NUM_INDEXES+1];     // Add another entry for empty string
LPSTR szProdName = NULL;
LPSTR szProdDesc = NULL;
LPSTR szProdID = NULL;
LPSTR szProdVer = NULL;
LPSTR szProdRelDate = NULL;
LPSTR szProdType = NULL;
LPSTR szProdMode = NULL;

LPTSTR szSystemDir = NULL;
LPTSTR szWindowsDir = NULL;

BOOL   batchMode;
DWORD  messageLen;
INT    installType;

PCHAR  CmdLine = NULL;
PCHAR  IniFile = NULL;

LPSTR  szTitle = NULL;
CHAR   szValue[cchMax];
TCHAR  szInstallPath[cchMax];
TCHAR  szSrcDir[cchMax];
TCHAR  szWinDrive[8];

//If more Option button items are added to CUSTINST form,
//add additional OptxOpt variables here.
LPSTR OptCur, Opt1Opt, Opt2Opt, Opt3Opt, Opt4Opt, RISPack ;
CHAR wrk[255]; 
CHAR  TempDir[cchMax];        // temp dir for log and appinfo.txt file
CHAR LogFile[cchMax];
CHAR RemoveExec [cchMax];
#if defined (RISAPP) || defined (RISSRV)
static INT RMVResourceInit = 0 ;
static INT RemoveDirectoryFlag = 0 ;
static CHAR VersionToBeDeleted [20] = "" ;
static CHAR RefListToBeDeleted [50] = "" ;
#endif

/* *********************************************************************
   Function:        FormatValue
   
   Purpose:         Format a DWORDLONG (64-bit) value into a string
                    representing its value in the appropriate "scale".
   
   Arguments:       value       Value to be represented
                        szResult        buffer to hold result

   Return Value:    pointer to result buffer

   08-JAN-1996      mwm - load strings from dll, recognize negative numbers
********************************************************************* */

LPSTR FormatValue(LONGLONG value, LPSTR szResult)
{
    LONGLONG orMag;
    LPSTR szSuffix = NULL;
    double fScaledValue;
    double multiplier;

    if (value < 0) {
        value = -value;
        multiplier = -1.0;
    } else {
        multiplier = 1.0;
    }

    if (value < 1048576 ) {

        orMag = 1024;
        szSuffix = ISDKLoadString (hUI_DLL, IDS_KILOBYTE);

    } else if (value < 1073741824) {

        orMag = 1048576;
        szSuffix = ISDKLoadString (hUI_DLL, IDS_MEGABYTE);

    } else {

        orMag = 1073741824;
        szSuffix = ISDKLoadString (hUI_DLL, IDS_GIGABYTE);

    }

    fScaledValue = (double)((LONGLONG)value / (orMag * multiplier));
    sprintf(szResult, "%.2f %s", fScaledValue, szSuffix);

    if (szSuffix) ISDKLOCALFREE (szSuffix);
    return(szResult);
}

/* *********************************************************************
   Function:  BuildLists

   Purpose:  Quick function to build the copy list and billboard list

   Arguments:  none

   Return Value:  none

   Side Effects:  Global copy list and billboard list get built by the
   functions this routine invokes.
   ********************************************************************* */
VOID BuildLists ()
{
        int iCursorSav = ShowWaitCursor ();
        WriteToLogFile ("BuildLists: BuildCopyList") ;
        BuildCopyList ();
        BuildBillboardList ();
        
        RestoreCursor (iCursorSav);
}



/* *********************************************************************
   Function:  BuildCopyList
   
   Purpose:  Build the copy list for the files to be installed.  For
   "minimal" or "full" installations, this is easy.  For
   "custom" installations, we need to get info stored by the
   "CUSTINST" dialog box.  The "AddOptFilesToCopyList" function
   does this for us.
   
   Arguments:  none
   
   Return Value:  none
   
   Side Effects:  Global copy list is modified
   ********************************************************************* */
VOID BuildCopyList ()
{
    
    ClearCopyList ();
#if defined (RISAPP)
   switch (installType)
   {
      case itCompact:
        AddSectionFilesToCopyList("Files", szSrcDir, szInstallPath);
        AddSectionFilesToCopyList("AppFiles", szSrcDir, szInstallPath);
      break;
      
      case itTypical:
        AddSectionFilesToCopyList("Files", szSrcDir, szInstallPath);
        AddSectionFilesToCopyList("AppFiles", szSrcDir, szInstallPath);
  
        // OptFiles1 -- Forms related files.
        AddSectionFilesToCopyList("OptFiles1", szSrcDir,szInstallPath);
  
        // OptFiles2 -- Loader/Unloader related files.
        AddSectionFilesToCopyList("OptFiles2", szSrcDir,szInstallPath);
  
        // OptFiles3 -- Samples files. RISDP CustInst
        AddSectionFilesToCopyList("OptFiles3", szSrcDir,szInstallPath);
  
        // RISPack -- RIS Packaging files. RISDP CustInst
        AddSectionFilesToCopyList("RISPack", szSrcDir,szInstallPath);
      break;
      
      case itCustom:
    // Do not add SHARE RIS STUFF TO RISDP path
        AddOptFilesToCopyList(APPFILES,0);
        AddOptFilesToCopyList(OPTFILES1,0);
        AddOptFilesToCopyList(OPTFILES2,0);
        AddOptFilesToCopyList(OPTFILES3,0);
        AddOptFilesToCopyList(RISPACK,0);
        break;
   }

#endif

#if defined (RISSRV)    
        switch (installType)
        {
            case itTypical:
                AddSectionFilesToCopyList("Files", szSrcDir, szInstallPath);
                AddSectionFilesToCopyList("AppFiles", szSrcDir, szInstallPath);
                sprintf(wrk,"%s,%d:BuildCopyList AddSectionFilesToCopyList",__FILE__,__LINE__);
                WriteToLogFile(wrk);
            break;
                
            case itCompact:
            break;
                
            case itCustom:
            break;
        }
#endif
   sprintf(wrk,"%s,%d:BuildCopyList returns VOID",__FILE__,__LINE__);
   WriteToLogFile(wrk);

    // If you place your remove executable and dll's in a "RmvFiles" section,
    // this call will copy them to the system directory on the target machine.
    // When copying to the system directory, we suggest renaming the files
    // rmPRODUCTINDEX.exe, rmPRODUCTINDEX.dl[1,2,...].
    //
    AddSectionFilesToCopyList("RmvFiles", szSrcDir, szSystemDir);


    // If you need to do a platform dependent copy, here is some example code 
    // to perform this operation (this also delivers the files the to SYSTEM
    // directory on the target machine using the szSystemDir global:
    // 
    //    NTFILES is the file section delivered on NT35, NT351, or W95
    //    W32SFILES is the file section delivered on Win32s 
    //
    // platform = ISDKGetPlatform();
    //
    // switch (installType) {
    //   case itTypical:
    //
    //     if ( (platform == IS_DAYTONA) || 
    //          (platform == IS_DAYTONA_351) ||
    //          (platform == IS_CHICAGO) ) {
    //         AddSectionFilesToCopyList("NTFILES", 
    //                                   szSrcDir, 
    //                                   szSystemDir);
    //     } else if ( platform == IS_WIN32S ) {
    //         AddSectionFilesToCopyList("W32SFILES", 
    //                                    szSrcDir, 
    //                                    szSystemDir);
    //     }
    //     break;  


}



/* *********************************************************************
   Function:  BuildBillboardList
   
   Purpose:   Set up the "billboard list" -- a series of non-interactive
   dialog boxes to be displayed as CopyFilesInCopyList does its
   thing.  Often used to hype new features, cajole the user
   to mail in his registration card, etc.
   
   Arguments:  none
   
   Return Value:  none
   
   Side Effects:  Global billboard list is modified
   ********************************************************************* */
VOID BuildBillboardList ()
{
        // Add four dialog boxes to the billboard list.
        // Set each one to be displayed for 5 seconds
        // (FModelessDlgProc * must * be used to display the
        // billboards)
        AddToBillboardList (szUI_DLL, DLG_BILLBOARD1, "FModelessDlgProc", 5);
        AddToBillboardList (szUI_DLL, DLG_BILLBOARD2, "FModelessDlgProc", 5);
        AddToBillboardList (szUI_DLL, DLG_BILLBOARD3, "FModelessDlgProc", 5);
#if defined (USED)
        AddToBillboardList (szUI_DLL, DLG_BILLBOARD4, "FModelessDlgProc", 5);
#endif
        // Set the (x, y) of the top left corner of the Copy Gauge
        // so it does not block our view of the billboards
        SetCopyGaugePosition (155, 130);
}




#if defined(RISAPP)


/******************************************************************************

    SYNOPSIS

    static VOID AppendPathBinToSystemPath(
	              CHAR *szNewPath,
                      BOOL bAddQuotesOnNT,
                      BOOL *pbRebootFlag)


    PARAMETERS

        NAME           ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----           --------------------------------------------------------

        szNewPath      I   - path of directory to add to system path (PATH
                             environment variable)
        bAddQuotesOnNT I   - If true, add quotes around the new path if it
                             contains spaces and if the platform is not
                             Windows NT.  Apparently because of the vagaries of
                             Microsoft, paths for executables on Windows NT
                             must have the quotes while paths for DLL's must
                             not have the quotes.
	pbRebootFlag   I/O - flag set to TRUE if the machine should be rebooted
                             so that the new PATH will take effect

    RETURN VALUE

        VOID

    DESCRIPTION

        This function appends "bin" or "\bin" as needed to szNewPath and then
        appends the combined path to the system path if it is not already
        there.

    CHANGE HISTORY

        12-JUL-1996 afb    Initial creation.  This function was needed to
                           satisfy TR439601360 on adding riscpp's path to the
                           system path.  (Alan Barksdale)

******************************************************************************/

static VOID AppendPathBinToSystemPath(
	CHAR *szNewPath,
	BOOL bAddQuotesOnNT,
	BOOL *pbRebootFlag)
{
	CHAR szPathToAppend[cchMax];	/* path to add to end of PATH
					environment variable */
  
	sprintf(wrk, "%s,%d:AppendPathBinToSystemPath entered", __FILE__,
		__LINE__);
	WriteToLogFile(wrk);

	strcpy(szPathToAppend, szNewPath); // because this function modifies the string
	AppendSlash(szPathToAppend);
	strcat(szPathToAppend, "bin");
	AppendToSystemPath(szPathToAppend, bAddQuotesOnNT, pbRebootFlag);

	sprintf(wrk,"%s,%d:AppendPathBinToSystemPath returns VOID", __FILE__,
		__LINE__);
	WriteToLogFile(wrk);
} // AppendPathBinToSystemPath


#endif // #if defined(RISAPP)




/* *********************************************************************
   Function:  Install
   
   Purpose:  Actually copies the product files from media, and stamps
   an executable with registration info
   
   Arguments:  none
   
   Return Value:  none
   
   Side Effects:  none

   02-DEC-1994  mwm  added ITEM6 as remove, including Chicago Uninstall

   ********************************************************************* */
VOID Install ()
{
#if defined (USED)
        CHAR rgchT1[16], rgchT2[16];
#endif
        LPSTR szPMTitle = NULL;
        LPSTR szPMLabel = NULL;
#if defined (USED)
        LPSTR cmdstr;
#endif
        INT status ;
#if defined (USED)
        INT iCursorSav;
#endif
#if defined (RISSRV) || defined (RISAPP)
        IngrRegStruct regvalues;
        CHAR cmdstr[cchMax];
#endif
        DWORD   dwPlatform;


       sprintf(wrk,"%s,%d:begin Install",__FILE__,__LINE__);
       WriteToLogFile(wrk);
       
        // Determine what platform we are running on.
        dwPlatform = ISDKGetPlatform();
        
        // Shared Component: Program groups and registry
        status = SetupRIS() ;
        if (status == -1)
        {
            WriteToLogFile ("SetupRIS() return -1") ;
            SetupError(STFERR) ;
        }

        /* RISCLI is being loaded as product, add the RmvFiles to the list */
#if defined (RISCLI)
        AddSectionFilesToCopyList("RmvFiles", szSrcDir, szSystemDir);
#endif
        CopyFilesInCopyList ();
        
        
        // Now it is time to do all of the things that you are supposed to
        // do when you install a new application.
        
        // Display a "billboard" to the user while configuration is
        // occurring, and change the cursor to "hourglass".
#if defined (USED)
        UIStartDlg (szUI_DLL,
                    DLG_REGBOARD,
                    "FModelessDlgProc",
                    0,
                    NULL,
                    (LPSTR) rgchT1,
                    16);
        iCursorSav = ShowWaitCursor ();
        GetListItem (CHECKSTATES, APPFILES, rgchT1, 15);
        GetListItem (CHECKSTATES, OPTFILES3, rgchT2, 15);
#endif

        // The steps below might fail if you don not load the files
        // that they are acting on.  So examine the Checkstates which
        // we have been maintaining even when the CUSTINST form is not
        // used to see if we need to do these things. 
        
        // Brings in docs
        
        // Stamp the Registration information into a program executable
        // This function accepts the name of a SECTION ("AppFiles" in this
        // case), and a REFERENCE KEY that has been assigned to the file
        // you want to stamp (this reference key gets assigned when you
        // run DSKLAYT).
        //
        // You may stamp several files in your product if you wish, but
        // each must have its own unique "reference" key and you must
        // call IngrStampRegInfo() separately for each file.  (The
        // action of looking up a particular section/key always stops
        // at the first match found.)
#if defined (USED)
        if (lstrcmp (rgchT1, "ON") == 0)
                IngrStampRegInfo ("Files", "StampFile", szInstallPath);
#endif
#if defined (RISAPP)
        BrandRISFile ("bin\\riscpp.exe") ;

	Change_wcSep(1);
	AppendPathBinToSystemPath(szInstallPath, TRUE, &RebootFlag);
	Change_wcSep(0);
#endif

#if defined (RISSRV)
        BrandRISFile (DS_EXEFILE) ;
#endif


        // This code is provided as an example of how one might install and
        // stamp a kernel driver.The SetupSDK kernel resource message file
        // is appended to the install directory name before the stamp function
        // is called.  The stamp function requires wide characters; therefore,
        // the install path is first converted since this example is not wide
        // character enabled.  Note that no length checking is performed
        // to prevent overwriting beyond the allocated space.  The actual copy
        // of the file would be done in the function CopyFilesInCopyList.
        //
        // wchar_t kevaldll[_MAX_PATH + 1];     /* full path target for the */
        //                                      /* message resource file name */
        //
        // mbstowcs (kevaldll,                  /* convert path to wide char */
        //           szInstallPath,             /* install directory path */
        //           lstrlen (szInstallPath) + 1);      /* include NULL in conversion */
        //
        // wcscat (kevaldll,                    /* append file name, assume trailing '\' */
        //         L"kevalmsg.dll");            /* wide char resource file name */
        //
        // IngrStampDriverRegInfo (L"MyDriver", /* wide char driver name */
        //                         kevaldll,    /* message resource file */
        //                         NULL);       /* registry security atttibutes */
        

        // CHICAGO NOTE:
        // At this point, your setup program can create new
        // Program Manager items (and groups) for the application that
        // you have just installed. Use the CreateProgmanGroup() and
        // CreateProgmanItem() functions to accomplish this.
        //
        // On Windows 95, you should put a SINGLE item for your product
        // on the Start menu.  Do *NOT* make a submenu off of the start menu.
        // (Don not blame us, blame Microsoft.  It is their pronouncement.)
        // You can do this by using CreateProgmanItem() with a group name
        // of ".."

        // I18N NOTE
        // For localized versions of your product, you will want to make sure
        // that the name of your Program Manager group and the Icon names you
        // use are translated to the target language.We extract these strings
        // from the localized resource DLL.
        //

        // create program items
        
    if ( ! (szPMTitle = ISDKLoadString (hUI_DLL, 
                                        IDS_PM_TITLE)) ) RISSetupError (__FILE__,__LINE__, "szPMTitle is bad");
#if defined (RISAPP) || defined (RISSRV)
            /* README.TXT program item */
            if (szPMLabel = ISDKLoadString (hUI_DLL,IDS_PM_README)) {
            sprintf(cmdstr, "%s%s", szInstallPath, README_FILE);
            ISTPProgmanItem (szPMTitle, TRUE, szPMLabel, cmdstr,
                             "", cmoOverwrite, NULL);
            ISDKLOCALFREE (szPMLabel);
        } else {
            SetupError (4);
        }

            /* REMOVE.EXE program item */
            
        if (szPMLabel = ISDKLoadString (hUI_DLL, IDS_PM_REMOVE)) {
        ISTPProgmanItem (szPMTitle, TRUE, szPMLabel, RemoveExec,
                "", cmoOverwrite, NULL);
        ISDKLOCALFREE (szPMLabel);

        } else {
            SetupError (4);
        }
#endif

#if defined(risinfds) 
        if (szPMLabel = ISDKLoadString (hUI_DLL, IDS_IFXDS_REG_UTL)) {
        sprintf(cmdstr, "%sbin\\infdsreg.exe", szInstallPath);
        ISTPProgmanItem (szPMTitle, TRUE, szPMLabel, cmdstr,
                "", cmoOverwrite, NULL);
        ISDKLOCALFREE (szPMLabel);
        } else {
            SetupError (4);
        }
#endif

#if defined(risinfns)
        if (szPMLabel = ISDKLoadString (hUI_DLL, IDS_IFXNS_REG_UTL)) {
        sprintf(cmdstr, "%sbin\\infnsreg.exe", szInstallPath);
        ISTPProgmanItem (szPMTitle, TRUE, szPMLabel, cmdstr,
                "", cmoOverwrite, NULL);
        ISDKLOCALFREE (szPMLabel);
        } else {
            SetupError (4);
        }
#endif

        if ( ISDKMatchPlatform (ISm_DAYTONA     |
                                ISm_DAYTONA_351))
        {           
#if defined (RISAPP)        
        /* Help for RISDP only */
        
        sprintf(cmdstr, "WINHLP32.EXE %sCONFIG\\ENGLISH\\HELP\\RISDP.HLP", szInstallPath);
        ISTPProgmanItem (szPMTitle, TRUE, RISDP_PROG_REF_STR, cmdstr,
                            "", cmoOverwrite, NULL);
#endif


#if defined (USED)
/* WATCH cmdstr is a pointer here LPSTR cmdstr */
                if ( (lstrcmpi (rgchT1, "ON") == 0) ) {

                        if ( (szPMLabel = ISDKLoadString (hUI_DLL, IDS_PM_ITEM2)) &&
                 (cmdstr = ISDKStrCatN (2, szInstallPath, ITEM2_FILE)) ) {

                ISTPProgmanItem (szPMTitle, TRUE, szPMLabel, cmdstr,
                                 "", cmoOverwrite, NULL);
                ISDKLOCALFREE (szPMLabel);
                ISDKFREE (cmdstr);
                
            } else {
                SetupError (4);
            }
        }

                if ( lstrcmpi (rgchT2, "ON") == 0 ) {

                        if ( (szPMLabel = ISDKLoadString (hUI_DLL, IDS_PM_ITEM3)) &&
                 (cmdstr = ISDKStrCatN (2, szInstallPath, ITEM3_FILE)) ) {

                ISTPProgmanItem (szPMTitle, TRUE, szPMLabel, cmdstr,
                                 "", cmoOverwrite, NULL);
                ISDKLOCALFREE (szPMLabel);
                ISDKFREE (cmdstr);

            } else {
                SetupError (4);
            }
                }
#endif
        }
    // Here is an example of using command line argumentd and a working
    // directory.
    //
    // CHAR *szArgs[3];
    //
    // szArgs[0] = "one"; szArgs[1] = "two"; szArgs[2] = NULL;
    // lstrcpy (szCommand, "c:\\program files\\setupsdk\\generic2.exe");
    // lstrcpy (szOther, "c:\\program files\\setupsdk\\pras.ico"
    //                    ",,,,"
    //                    "c:\\program files\\setupsdk");
    //
    // ISTPProgmanItem (szPMTitle, 1, szPMLabel, szCommand,
    //                  szOther, cmoOverwrite, szArgs);

    if ( ISDKMatchPlatform (ISm_CHICAGO | ISm_NT40) ) {
        // CHICAGO and NT40 NOTE
        //
        // If your product is being installed on Windows 95 / NT 4.0,
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

#if defined (USED)
        LPSTR cmdstr;

            if ( ! (szPMLabel = ISDKLoadString (hUI_DLL, IDS_PM_README)) &&
                 (cmdstr = ISDKStrCatN (2, szInstallPath, README_FILE)) ) {

            ISTPProgmanItem ("..", TRUE, szPMLabel, cmdstr,
                             "", cmoOverwrite, NULL);
            ISDKLOCALFREE (szPMLabel);
            ISDKFREE (cmdstr);

        } else {
            SetupError (4);
        }
#endif

#if defined (RISAPP)        
        // Let's register this program also.
        sprintf (wrk, "Registering the riscpp executable") ;
        WriteToLogFile (wrk) ;
        ISTPRegisterAppPath (SzCatStr (szInstallPath, "bin\\RISCPP.EXE"));
        /* Help for RISDP only */
        WriteToLogFile ("help for risdp") ;
        sprintf(cmdstr, "%sCONFIG\\ENGLISH\\HELP\\RISDP.HLP", szInstallPath);
        ISTPProgmanItem (szPMTitle, TRUE, RISDP_PROG_REF_STR, cmdstr,
                             "", cmoOverwrite, NULL);
#endif

#if defined USED
        // If we deliver a shared component, use this segment to add the
        // share path to the registered exe
        {
          DWORD mask = 0;
          LPTSTR sharepath = NULL;

          if ( (sharepath = INGRGetShareDir (&mask)) ) {
          
            ISTPAddRegisterAppPath (SzCatStr (szInstallPath, README_FILE),
                                    sharepath);
            ISDKFREE (sharepath);
          }
        }
#endif
        
        ISDKLOCALFREE (szPMLabel);

        /*
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

        ISTPRegisterUninstall (szProdName,
                               szPMTitle,
                               RemoveExec);
    }



    WriteToLogFile ("Freeing szPMTitle") ;
    ISDKLOCALFREE (szPMTitle) ;
    
#if defined (RISSRV)
      RegEdtRIS(status,DS_LIST_STR);
#elif defined (RISAPP)
      RegEdtRIS(status,RISDP_LIST_STR);
#endif

#if defined (RISSRV) || defined (RISAPP)        
    WriteToLogFile("Updating Registry");
    ZeroMemory (&regvalues, sizeof(regvalues));

    regvalues.Description = szProdDesc;
    regvalues.InstallMode = STANDALONE_MODE,
    regvalues.IDNumber = szProdID;
    regvalues.PathName = szInstallPath;
    regvalues.RelDate = szProdRelDate;
    regvalues.SoftwareType = szProdType;
    regvalues.Version = RIS_VERSION_STR;
    
    sprintf(wrk,"%s,%d:RIS_VERSION_STR <%s> product name <%s>",__FILE__,__LINE__, RIS_VERSION_STR, szProdName);
    WriteToLogFile(wrk);
    
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
#endif
#if defined (RISCLI)
    {
        DWORD dwType ;
    
        RegEdtRIS(status,RISCLI_LIST_STR);

    // Get InstallPath of RIS Share (which is already installed)
        GetRegKeyValueEx(HKEY_LOCAL_MACHINE, REGISTRY, "PathName", 
            &dwType, szInstallPath, cchMax);

    // Add Remove ProgmanItem
        ISTPProgmanItem (RISPROGGROUP, TRUE, RISSHARE_REMOVE_STR,
            RemoveExec, "", cmoOverwrite, NULL);
    }
#endif

#if defined(risinfds) || defined(risinfns)
        UpdateInformixServerReg () ;
#endif

        // If there are any other configuration steps you need to perform,
        // you should do them here.
        
                // If you make any changes to system environment variables, this
        // is a good way to "resync" everybody.
        
        
        if (batchMode)
        {
                //
                // For manufacturing audit of pre-loaded software
                // indicate a successful installation.
                //
                // Note that since CopyFilesInCopyList CLEARS the Copy List
                // when its finished, we need to rebuild it in order for
                // the function to be able to <compute how much has been
                // copied to the disk.
                //

                CHAR szInstallPath2 [cchMax] ;
                lstrcpy (szInstallPath2, szInstallPath);
                szInstallPath[3] = 0;
                BuildCopyList ();
                IngrLogInstallResult (TRUE,
                                      szProdName,
                                      szProdID,
                                      szInstallPath2);
                ClearCopyList ();
                lstrcpy (szInstallPath, szInstallPath2) ;
        }
#if defined (USED)
        RestoreCursor (iCursorSav);
#endif
        UIPop (1);
       sprintf(wrk,"%s,%d:Install returns VOID",__FILE__,__LINE__);
       WriteToLogFile(wrk);
}



/* *********************************************************************
   Function:  WelcomeDialog
   
   Purpose:  Provide a cheery "hello" to the user installing the product.
   
   Arguments:  none
   
   Return Value:  none
   
   Side Effects:  none
   ********************************************************************* */
VOID WelcomeDialog ()
{
        CHAR rgchT[16];
        
        while (TRUE)
        {
                UIStartDlg (szUI_DLL,
                            DLG_WELCOME,
                            "FInfoDlgProc",
                            DLG_APPHELP,
                            "FHelpDlgProc",
                            (LPSTR) rgchT,
                            sizeof (rgchT) -1 );
                
                switch ((WORD) (rgchT[0] + rgchT[1]))
                {
                case IDC_CANCEL:
                case IDC_TYPEEXIT:
                        AskQuit ();
                        continue;
                        
                default:
                        continue;
                        
                case IDC_CONTINUE:
                        break;
                }
                
                UIPop (1);
                return;
        }
}



/* *********************************************************************
   Function:  InstallTypeDialog
   
   Purpose:  Let the user tell us what type of installation (minimal,
   full, custom) to perform, using a radioButton dialog box.
   
   Arguments:  None
   
   Return Value:  None
   
   Side Effects:  global variable "installType" is set in this routine
   ********************************************************************* */

VOID InstallTypeDialog ()
{
        CHAR rgchT[16];
        
        while (TRUE)
        {
                SetSymbolValue ("RadioDefault", OptCur);
                UIStartDlg (szUI_DLL,
                            DLG_OPTIONS,
                            "FRadioDlgProc",
                            DLG_APPHELP,
                            "FHelpDlgProc",
                            (LPSTR) rgchT,
                            sizeof (rgchT) -1 );
                
                switch ((WORD) (rgchT[0] + rgchT[1]))
                {
                case IDC_CANCEL:
                case IDC_TYPEEXIT:
                        AskQuit ();
                        continue;
                        
                default:
                        continue;
                        
                case IDC_CONTINUE:
                        GetSymbolValue ("ButtonChecked", rgchT, sizeof (rgchT) -1 );
                        switch (*rgchT)
                        {
                        case '1':
                                installType = itTypical;
                                OptCur = "1";
                                break;
                        case '2':
                                installType = itCompact;
                                OptCur = "2";
                                break;
                        case '3':
                                installType = itCustom;
                                OptCur = "3";
                                break;
                        }
                        break;
                }
                UIPop (1);
                return;
        }
}



/* *********************************************************************
   Function:  TooBig
   
   Purpose:  Customer's selections will not fit in disk space available.
   Put up a dialog box informing him of this fact
   
   Arguments:  None
   
   Return Value:  None
   
   Side Effects:  None
   ********************************************************************* */
VOID TooBig ()
{
        char rcghT[16];
        
        while (TRUE)
        {
                UIStartDlg (szUI_DLL,
                            DLG_TOOBIG,
                            "FInfo0DlgProc",
                            0,
                            "",
                            (LPSTR) rcghT,
                            sizeof (rcghT) -1);
                
                if ((WORD) (rcghT[0] + rcghT[1]) == IDC_REACTIVATE)
                {
                        RecalcPath ();
                        SetDriveStatus ();
                }
                else
                        break;
        }
        UIPop (1);
        return;
}



/* *********************************************************************
   Function:  FInstallPathDialog
   
   Purpose:   Display the path where the product will be installed;
                get confirmation.
   
   Arguments:  None
   
   Return Value:   BACK = Go back and get installation type
   other =  continue
   
   Side Effects:   The section of the Custom Installation form that
   lists the install path will be updated with the
   user's selection from this dialog box.
   ********************************************************************* */
INT FInstallPathDialog ()
{
        CHAR rgchT[16];
        INT fRet;
        CHAR sz[cchMax];
        CHAR szPath[cchMax], szTemp[cchMax];
        
        lstrcpy (sz, szInstallPath);
        
        while (TRUE)
        {
                lstrcpy (szPath, sz);

                StripSlash (szPath);
                SetSymbolValue ("DirName", szPath);

                UIStartDlg (szUI_DLL,
                            DLG_DESTPATH,
                            "FDirDlgProc",
                            DLG_APPHELP,
                            "FHelpDlgProc",
                            (LPSTR) rgchT,
                            sizeof (rgchT) -1 );
                
                switch ((WORD) (rgchT[0] + rgchT[1]))
                {
                default:
                        continue;
                        
                case IDC_PATHEXIT:
                        AskQuit ();
                        continue;
                        
                case IDC_PATHCANCEL:
                case IDC_BACK:
                        fRet = BACK;
                        break;
                        
                case IDC_CHANGEDIR:
                        GetCustomDirectory(szPath, sz, cchMax);
                        continue;

                case IDC_CONTINUE:
#if defined (RISAPP) || defined (RISSRV)
                        if (!RISValidateDirectory(sz)) {
                            WriteToLogFile ("Continue") ;
                                continue;
                        }
                        else
                        {
                                fRet = FALSE;   // stop looping

                        }
#else
                        fRet = FALSE ;
#endif
                }
                break;
        }
        
        UIPop (1);
        lstrcpy (szInstallPath, sz);
        AppendSlash (szInstallPath);
        
        // Directory path field on CUSTINST dialog is about 170
        // pixels wide, which is room for about 40 characters.
        // If the directory path is longer than that, it needs
        // to be shortened for display on the dialog.
        
        lstrcpy (szTemp, szInstallPath);
        ISDKChopDir(szTemp, 40);
        ReplaceListItem (DRIVETEXT, 7, szTemp);

        RecalcPath ();
        
        return fRet;
}


/* *********************************************************************
   Function:    HandleOptFiles
   
   Purpose:     If the user selects the "Options..." button for optional
   feature set 1 or 2, this routine puts up a dialog box
   with radio buttons allowing them to specify options.
   
   Arguments:   OptSet -  set to 1 or 2 to indicate which feature set
   you're working with
   
   Return Value:  None
   
   Side Effects:  The Opt1Opt or Opt2Opt global variable will be set
   according to the value of OptSet, and the selection
   made by the user.
   ********************************************************************* */
VOID HandleOptFiles (INT OptSet)
{
        LPSTR Cur;
        CHAR szNewOpt[16];
        CHAR rgchT[16];
        
        if (OptSet == 1)
                Cur = Opt1Opt;
        else if (OptSet == 2)
                Cur = Opt2Opt;
        else if (OptSet == 3)
                Cur = Opt3Opt;
        else if (OptSet == 4)
                Cur = Opt4Opt;
        else if (OptSet == 5)
                Cur = RISPack;
        
        SetSymbolValue ("RadioDefault", Cur);
        
        while (TRUE)
        {
                UIStartDlg (szUI_DLL,
                            DLG_FILEOPTS,
                            "FRadioDlgProc",
                            DLG_APPHELP,
                            "FHelpDlgProc",
                            (LPSTR) rgchT,
                            sizeof (rgchT) -1 );
                
                switch ((WORD) (rgchT[0] + rgchT[1]))
                {
                case IDC_REACTIVATE:
                        RecalcPath ();
                        SetDriveStatus ();
                        continue;
                case IDC_TYPEEXIT:
                        AskQuit ();
                        continue;
                case IDC_CONTINUE:
                        UIPop (1);
                        GetSymbolValue ("ButtonChecked", szNewOpt, sizeof (szNewOpt) -1 );
                        if (lstrcmp (szNewOpt, Cur))
                        {
                                *Cur = szNewOpt[0];
                                if (OptSet == 1)
                                        RecalcOptFiles (OPTFILES1);
                                else if (OptSet == 2)
                                        RecalcOptFiles (OPTFILES2);
                                else if (OptSet == 3)
                                    RecalcOptFiles(OPTFILES3);
                                else if (OptSet == 4) {
                                    RecalcOptFiles(RISPACK);
                                }
                                SetDriveStatus ();
                        }
                        return;
                        break;
                default:
                        UIPop (1);
                        return;
                        break;
                }
        }
}



/* *********************************************************************
   Function:  CustInstDialog
   
   Purpose:  Run the "Custom Installation" dialog box
   
   Arguments:  None
   
   Return Value:  FALSE = Stop looping
   TRUE = Continue looping
   BACK = Go back and re-select Installation type
   
   Side Effects:  Status of checkboxes is used later in AddOptFilesToCopyList
   ********************************************************************* */
INT CustInstDialog ()
{
        CHAR rgchT[16];
        CHAR szNewDir[cchMax], szTemp[cchMax];
        CHAR szbig[16];
        INT bigflag, i, selection_made;
        
        while (TRUE)
        {
        CustDlg:
                UIStartDlg (szUI_DLL,
                            DLG_CUSTINST,
                            "FCustInstDlgProc",
                            DLG_APPHELP,
                            "FHelpDlgProc",
                            (LPSTR) rgchT,
                            sizeof (rgchT) -1 );
                
                if (lstrcmp (rgchT, "CONTINUE") == 0)
                {
                        // See if no options have been selected.
                        selection_made = 0;
                        for (i = 1; i <= OPTION_ITEMS; i++)
                        {
                                GetListItem (CHECKSTATES, i, szbig, 15);
                                if (lstrcmpi (szbig, "ON") == 0)
                                        selection_made++;
                        }
                        if (!selection_made)
                        {
                                while (TRUE)
                                {
                                        UIStartDlg (szUI_DLL,
                                                    DLG_NOCUST,
                                                    "FInfoDlgProc",
                                                    0,
                                                    NULL,
                                                    (LPSTR) rgchT,
                                                    15);
                                        
                                        UIPop (1);
                                        if (lstrcmp (rgchT, "CONTINUE") == 0)
                                        {
                                                goto CustDlg;
                                        }
                                        if (lstrcmp (rgchT, "EXIT") == 0)
                                        {
                                                AskQuit ();
                                                continue;
                                        }
                                }
                        }
                        
                        // See if there is insufficient disk
                        // space to load the selected Options

                        for (i = 1, bigflag = 0;
                             (i <= OPTION_ITEMS) && (bigflag == 0);
                             i++)
                        {
                                GetListItem (BIGLIST, i, szbig, 15);
                                if (szbig[0])
                                        bigflag = 1;
                        }

                        if (bigflag)
                                TooBig ();
                        else
                        {
                                UIPop (1);
                                break;
                        }
                }
                else if (lstrcmp (rgchT, "PATH") == 0)
                {
                        if (GetCustomDirectory(szInstallPath, szNewDir, cchMax))
                        {
                                if (ValidateDirectory(szNewDir, "GENERIC.EXE")) {
                                        lstrcpy (szInstallPath, szNewDir);
                                        AppendSlash (szInstallPath);

                                        lstrcpy (szTemp, szInstallPath);
                                        ISDKChopDir(szTemp, 40);
                                        ReplaceListItem (DRIVETEXT, 7, szTemp);
                                }
                                RecalcPath ();
                                SetDriveStatus ();
                        }
                }
                else if (lstrcmp (rgchT, "CHK1") == 0)
                {
                        RecalcOptFiles (APPFILES);
                        SetDriveStatus ();
                }
                else if (lstrcmp (rgchT, "CHK2") == 0)
                {
                        RecalcOptFiles (OPTFILES1);
                        SetDriveStatus ();
                }
                else if (lstrcmp (rgchT, "CHK3") == 0)
                {
                        RecalcOptFiles (OPTFILES2);
                        SetDriveStatus ();
                }
                else if (lstrcmp (rgchT, "CHK4") == 0)
                {
                        RecalcOptFiles (OPTFILES3);
                        SetDriveStatus ();
                }
                else if (strcmp(rgchT, "CHK5") == 0) 
                {
                        RecalcOptFiles(RISPACK);
                        SetDriveStatus();
                }
                else if (lstrcmp (rgchT, "BTN2") == 0)
                {
                        HandleOptFiles (1);
                }
                else if (lstrcmp (rgchT, "BTN3") == 0)
                {
                        HandleOptFiles (2);
                }
                else if (lstrcmp (rgchT, "BTN4") == 0)
                {
                        HandleOptFiles (3);
                }
                else if (lstrcmp (rgchT, "EXIT") == 0)
                {
                        AskQuit ();
                }
        }
        //
        // If we have gotten this far, then we can stop looping.
        //
        return (FALSE);
}

/*************************************************************************
** Purpose:
**     Adds the specified option files to the copy list.
** Arguments:
**     ftype%  - type of files to add, one of the following:
**             APPFILES, OPTFILES1, OPTFILES2
** Returns:
**     none.
*************************************************************************/
VOID AddOptFilesToCopyList (INT ftype, INT fshare_ris)
{
        CHAR rcghT[16];
        CHAR szLocSrcDir[cchMax];
        
#if defined (RISAPP)
   GetListItem (CHECKSTATES, ftype, rcghT, 15);
   if (lstrcmp (rcghT, "ON") == 0)
   {
      GetSymbolValue ("STF_SRCDIR", szLocSrcDir, cchMax);
      switch (ftype)
      {
      case APPFILES:
        AddSectionFilesToCopyList("Files", szSrcDir, szInstallPath);
        AddSectionFilesToCopyList("AppFiles", szSrcDir,szInstallPath);
        // Add share stuff for disk space calculation only
        if (fshare_ris)
        {
            AddShareComponent (szSrcDir, szInstallPath) ;
        }
    break;
    
      case OPTFILES1:
//    Typically, this would choose either the file with reference key "1"
//    or "2" in this section of the .INF file.  For this example, we'll
//    still install everything.  But a typical invocation would be:    
// AddSectionKeyFileToCopyList("OptFiles1", Opt1Opt, szSrcDir,
//  SzCatStr(szInstallPath, "CSOURCE"));
      AddSectionFilesToCopyList("OptFiles1", szSrcDir,szInstallPath);
    break;
    
      case OPTFILES2:
//    Typically, this would choose either the file with reference key "1"
//    or "2" in this section of the .INF file.  For this example, we'll
//    still install everything.  But a typical invocation would be:    
// AddSectionKeyFileToCopyList("OptFiles2", Opt2Opt, szSrcDir,
//  SzCatStr(szInstallPath, "GENERIC.SRC"));
      AddSectionFilesToCopyList("OptFiles2", szSrcDir,szInstallPath);
    break;
    
      case OPTFILES3:
// RISDP CustInst -- Hitesh
//    Typically, this would choose either the file with reference key "1"
//    or "2" in this section of the .INF file.  For this example, we'll
//    still install everything.  But a typical invocation would be:    
// AddSectionKeyFileToCopyList("OptFiles3", Opt3Opt, szSrcDir,
//  SzCatStr(szInstallPath, "GENERIC.SRC"));
      AddSectionFilesToCopyList("OptFiles3", szSrcDir,szInstallPath);
    break;

      case RISPACK:
  // RISDP CustInst -- Hitesh
  //   Typically, this would choose either the file with reference key "1"
  //   or "2" in this section of the .INF file.  For this example, we'll
  //   still install everything.  But a typical invocation would be:   
  //   AddSectionKeyFileToCopyList("OptFiles3", Opt3Opt, szSrcDir,
  //  SzCatStr(szInstallPath, "GENERIC.SRC"));
   AddSectionFilesToCopyList("RISPack", szSrcDir,szInstallPath);
   break;
      }
      szLocSrcDir[0] = 0;
   }
#else
        GetListItem (CHECKSTATES, ftype, rcghT, 15);
        if (lstrcmp (rcghT, "ON") == 0)
        {
                GetSymbolValue ("STF_SRCDIR", szLocSrcDir, cchMax);
                switch (ftype)
                {
                case APPFILES:
                        break;
                        
                case OPTFILES1:
                        break;
                        
                case OPTFILES2:
                        break;
                        
                case OPTFILES3:
                        break;
                        
                }
                szLocSrcDir[0] = 0;
        }
#endif  
}


/**
** Purpose:
**     Recalculates disk space for the given option files and sets
**     the status info symbol "StatusItemsText".
** Arguments:
**     ftype - type of files to add, one of the following:
**             APPFILES, OPTFILES1, OPTFILES2, OPTFILES3
** Returns:
**     none.
*************************************************************************/
VOID RecalcOptFiles (INT ftype)
{
        CHAR rcghT[16];
        CHAR text[32];
        LPSTR ListSym;
        LONG cost;
        LONGLONG StillNeed;
        INT i, ndrive, fExtra = 0;
        INT CursorSave = ShowWaitCursor ();
        
        ClearCopyList ();
#if defined (RISAPP)
        AddOptFilesToCopyList (ftype,1);
#else
        AddOptFilesToCopyList (ftype, 0);
#endif
        
        fExtra = 0;
        switch (ftype)
        {
        case APPFILES:
                ListSym = APPNEEDS;
                GetListItem (CHECKSTATES, APPFILES, rcghT, 15);
                /****
                if (lstrcmp (rcghT, "ON") == 0)
                {
                        / * Add extra cost to Windows drive for ini/progman, etc. * /
                        // I18N NOTE
                        // The i18n group has "blessed" this method for deriving
                        // the ordinal number of a drive (by subtracting 'A' from
                        // it.  You may use this method safely.
                        CharUpper (szWinDrive);
                        ndrive = szWinDrive[0] - TEXT ('A') + 1;
                        ReplaceListItem (EXTRACOSTS, ndrive, "10240");
                        fExtra = 1;
                }
                ****/
                break;
        case OPTFILES1:
                ListSym = OPT1NEEDS;
                break;
        case OPTFILES2:
                ListSym = OPT2NEEDS;
                break;
        case OPTFILES3:
                ListSym = OPT3NEEDS;
                break;
        case RISPACK:
               ListSym = RISPACKNEEDS;
               break;
        }
        
        StillNeed = GetCopyListCost (EXTRACOSTS, ListSym, "");
        
        cost = 0;
        for (i = 1; i <= NUM_DRIVES; i++)
        {
                GetListItem (ListSym, i, rcghT, sizeof (rcghT) -1);
                cost += atol (rcghT);
        }
        
        wsprintf (text, "%d KB", cost / 1024);
        ReplaceListItem (STATUSTEXT, ftype, (LPSTR) text);
        
        if (StillNeed > 0)
                ReplaceListItem (BIGLIST, ftype, "YES");
        else
                ReplaceListItem (BIGLIST, ftype, "");
        
        if (fExtra)
                ReplaceListItem (EXTRACOSTS, ndrive, "0");
        
        RestoreCursor (CursorSave);
        ListSym = "";
}


/**
** Purpose:
**     Recalculates disk space and sets option status info according
**     to the current destination path.
** Arguments:
**     none.
** Returns:
**     none.
*************************************************************************/
VOID RecalcPath ()
{
        int CursorSave = ShowWaitCursor ();
        
        RecalcOptFiles (APPFILES);
        RecalcOptFiles (OPTFILES1);
        RecalcOptFiles (OPTFILES2);
        RecalcOptFiles (OPTFILES3);
        RecalcOptFiles (RISPACK);
        RestoreCursor (CursorSave);
}


/**
** Purpose:
**     Sets drive status info according to latest disk space calcs.
** Arguments:
**     none.
** Returns:
**     none.
*************************************************************************/
VOID SetDriveStatus ()
{
        CHAR szDrive[8];
        CHAR text[32];
        int ndrive;
        LONG cost;
        //
        // GetFreeSpaceForDrive() has been updated to return
        // an unsigned 64-bit int (DWORDLONG).
        //
        DWORDLONG dlFree;

        
        szDrive[0] = szInstallPath[0];
        szDrive[1] = 0;
        
        // I18N NOTE
        // The i18n group has "blessed" this method for deriving
        // the ordinal number of a drive (by subtracting 'A' from
        // it.  You may use this method safely.
        CharUpper (szDrive);
        ndrive = szDrive[0] - TEXT ('A') + 1;
        
        cost = 0;
        GetListItem (APPNEEDS, ndrive, text, 31);
        cost += atol (text);
        GetListItem (OPT1NEEDS, ndrive, text, 31);
        cost += atol (text);
        GetListItem (OPT2NEEDS, ndrive, text, 31);
        cost += atol (text);
        GetListItem (OPT3NEEDS, ndrive, text, 31);
        cost += atol (text);
        GetListItem(RISPACKNEEDS, ndrive, text, 31);
        cost += atol(text);
        
        
        dlFree = GetFreeSpaceForDrive (szDrive);
        
        wsprintf (text, "%s:", szDrive);
        ReplaceListItem (DRIVETEXT, 1, text);
        wsprintf (text, "%d KB", cost / 1024);
        ReplaceListItem (DRIVETEXT, 2, text);
        FormatValue(dlFree, text);
        ReplaceListItem (DRIVETEXT, 3, text);
        
        if (szDrive[0] == szWinDrive[0])
        {
                ReplaceListItem (DRIVETEXT, 4, "");
                ReplaceListItem (DRIVETEXT, 5, "");
                ReplaceListItem (DRIVETEXT, 6, "");
        }
        else
        {
                // I18N NOTE
                // The i18n group has "blessed" this method for deriving
                // the ordinal number of a drive (by subtracting 'A' from
                // it.  You may use this method safely.
                CharUpper (szWinDrive);
                ndrive = szWinDrive[0] - TEXT ('A') + 1;
                cost = 0;
                GetListItem (APPNEEDS, ndrive, text, 31);
                cost += atol (text);
                GetListItem (OPT1NEEDS, ndrive, text, 31);
                cost += atol (text);
                GetListItem (OPT2NEEDS, ndrive, text, 31);
                cost += atol (text);
                GetListItem (OPT3NEEDS, ndrive, text, 31);
                cost += atol (text);
                GetListItem(RISPACKNEEDS, ndrive, text, 31);
                cost += atol(text);

                
                if (cost == 0)
                {
                        ReplaceListItem (DRIVETEXT, 4, "");
                        ReplaceListItem (DRIVETEXT, 5, "");
                        ReplaceListItem (DRIVETEXT, 6, "");
                }
                else
                {
                        dlFree = GetFreeSpaceForDrive (szWinDrive);
                        wsprintf (text, "%s:", szWinDrive);
                        ReplaceListItem (DRIVETEXT, 4, text);
                        FormatValue (cost, text);
                        ReplaceListItem (DRIVETEXT, 5, text);                   
                        FormatValue(dlFree, text);
                        ReplaceListItem (DRIVETEXT, 6, text);
                }
        }
}


/* **************************************************************** *
   Function:      RunBatchMode
   
   Purpose:       The customer has supplied a settings file that
                  contains configuration information for the
                  installation.  Extract the necessary information
                  from the file -- if any required fields are missing,
                  we may still have to prompt for information...
   
   Arguments:     none
   
   Return Value:  none
   
   Side Effects:  Various globals will be modified based on the
                  settings, as BuildLists() and other functions will
                  use these globals to determine just what gets installed:
   
                  installType
                  szInstallPath
                  OptCur
                  Opt1Opt
                  Opt2Opt
                  the "CheckItemsState" list

   30-JAN-95 mwm  modified default download directory for NT 3.1 system to
                  drive:\ProgramF
   * **************************************************************** */
VOID RunBatchMode ()
{
        INT valueOK = 0;
        INT mfgInstall;
        INT oldMode;
        DWORD   dwPlatform;

        if (! DoesFileExist (IniFile, femExists)) {
            sprintf (wrk, "File <%s> was not found : The current working directory for setup was set to <%s>",
                    IniFile, szCurDir) ;
            RISSetupError (__FILE__, __LINE__, wrk) ;
        }
        
        WriteToLogFile ("Entering RunBatchMode") ;
        dwPlatform = ISDKGetPlatform();

        WriteToLogFile ("Setting silent mode") ;
        oldMode = SetSilentMode (1);

        //Get registration data from the user
        if (DoesIniSectionExist (IniFile, "Registration"))
        {
            sprintf (wrk, "Found Registration Section in INI file <%s>", IniFile) ;
            WriteToLogFile (wrk) ;
            GetIniKeyString (IniFile, "Registration",
                                 "name", szValue, cchMax);
                
            if (lstrcmpi(szValue, "Licensed to Intergraph Corporation") == 0)
            {
                WriteToLogFile ("Licensed to Intergraph Corporation : Manufacturing load") ;
                mfgInstall = 1;
                        
                        //
                        // Now see if it it is "allowed" to be doing a
                        // Manufacturing load
                        //
                if (!ValidMfgLoad ())
                        RISSetupError (__FILE__, __LINE__, "Not allowed to do a Manufacturing load");
            }
            else {
                mfgInstall = 0;
                WriteToLogFile ("not Licensed to Intergraph Corporation") ;
            }
                
            SetSymbolValue ("NameOut", szValue);
                
            GetIniKeyString (IniFile, "Registration",
                                 "organization", szValue, cchMax);
            SetSymbolValue ("OrgOut", szValue);
                        
            GetIniKeyString (IniFile, "Registration",
                                 "serial", szValue, cchMax);
                
        
                //
                // Verify serial number if we are not in Mfg.
                //
            if (!mfgInstall && !VerifySerial (szValue))
            {
                        //
                        // ERROR.Do not let them continue.
                        //
                        RISSetupError (__FILE__,__LINE__, "Serial Number didn't verify");
            }
            else {
                 WriteToLogFile ("Serial Number verified correctly") ;
                 SetSymbolValue ("SerOut", szValue);
            }
        }
        else
        {
                //
                // There was no registration information in the file.
                // This is an error.
                //
                sprintf (wrk, "There was no registration information in file <%s>", IniFile) ;
                RISSetupError(__FILE__,__LINE__, wrk);
        }

        valueOK = 0;

        // Get the destination directory from the settings file...

        if (GetIniKeyString (IniFile,
                             "Standard",
                             "DestPath",
                             szValue,
                             cchMax))
        {
            sprintf (wrk, "Destination Directory <%s>", szValue) ;
            WriteToLogFile (wrk) ;
            valueOK = 1;
                //
                // Do all the same checking as FInstallPathDialog...
                // Since Manufacturing says you cannot have any user interaction
                // at all in a "batch" installation, you should just fall
                // back to using the default value if something is wrong with
                // the one in the settings file.
                //
                if (lstrlen (szValue) == 0) valueOK = 0;
        
            if (!FValidDir (szValue) || !IsDirWritable (szValue)) valueOK = 0;
                
            lstrcpy (szInstallPath, szValue);
            AppendSlash (szInstallPath);
                
            if (lstrcmpi (szInstallPath, szSrcDir) == 0) valueOK = 0;
        }
        
        if (!valueOK)
        {
            WriteToLogFile ("No valid path given. Plug in the default value") ;
                //
                // There was no valid path given.
                // Plug in the default value again.
                //
        // 30-JAN-1995 mwm  NT 3.1 directory change

                if (dwPlatform == IS_DAYTONA || 
            dwPlatform == IS_DAYTONA_351 ||
            dwPlatform == IS_CHICAGO) {

                        wsprintf (szInstallPath,
                      PH2_INGR_PROD_DIR_FMT,
                      szWinDrive[0],
                      szProdName);

        } else {

                        // Win32s / NT 3.1 FAT does not support long file names
                        // so we must use an 8.3 name.  This name is TBD
                        // from Microsoft.

                        wsprintf (szInstallPath,
                      PH2_W32S_PROD_DIR_FMT,
                      szWinDrive[0],
                      szProdName);
                }
        }

        valueOK = 0;    /* RISSRV always does a typical installation. Installtype is ignored. */
#if defined (RISAPP)    
        // Determine what kind of installation is to be performed.
        if (GetIniKeyString (IniFile,
                         "Standard",
                         "InstallType",
                         szValue,
                         cchMax))
        {
            sprintf (wrk, "Got type of installation <%s>", szValue) ;
            WriteToLogFile (wrk) ;
            if (lstrcmpi (szValue, "typical") == 0)
            {
                installType = itTypical;
                OptCur = "1";
                valueOK = 1;
            }
            else if (lstrcmpi (szValue, "compact") == 0)
            {
                installType = itCompact;
                OptCur = "2";
                valueOK = 1;
            }
            else if (lstrcmpi (szValue, "custom") == 0)
            {
                installType = itCustom;
                OptCur = "3";
                valueOK = 1;
            }
        }
#endif

        // If no valid value was obtained, fall back to a "default"
        // behavior of performing a "Typical" installation.

        if (!valueOK)
        {
            WriteToLogFile("Option was not valid. Default is typical") ;
            installType = itTypical;
            OptCur = "1";
        }

        // 3. If "Custom" installation was chosen, get the info
        // about what features the user wants.
        if (installType == itCustom)
        {
            WriteToLogFile ("Custom installation was chosen.") ;
                if (DoesIniSectionExist (IniFile, "Options"))
                {
                        WriteToLogFile ("Options section exists") ;
/* Melania M Stewart - AppFiles should always be installed */                        
#if defined (USED)                        
                        GetIniKeyString (IniFile,
                                         "Options",
                                         "AppFiles",
                                         szValue,
                                         cchMax);
                        sprintf (wrk, "AppFiles is <%s>", szValue) ;
                        WriteToLogFile (wrk) ;
                        if (lstrcmpi (szValue, "yes") == 0)
                                //Turn on the "check box" item in the list for Install
                                //to use later
                                ReplaceListItem (CHECKSTATES, APPFILES, "ON");
                        else
                                ReplaceListItem (CHECKSTATES, APPFILES, "OFF");
                        RecalcOptFiles (APPFILES);
#endif                        
                        ReplaceListItem (CHECKSTATES, APPFILES, "ON");
                        RecalcOptFiles (APPFILES);
                        GetIniKeyString (IniFile,
                                         "Options",
                                         "OptFiles1",
                                         szValue,
                                         cchMax);
                        sprintf (wrk, "AppFiles1 is <%s>", szValue) ;
                        WriteToLogFile (wrk) ;
                        if (lstrcmpi (szValue, "yes") == 0)
                                ReplaceListItem (CHECKSTATES, OPTFILES1, "ON");
                        else
                                ReplaceListItem (CHECKSTATES, OPTFILES1, "OFF");
                        RecalcOptFiles (OPTFILES1);
                        
                        GetIniKeyString (IniFile,
                                         "Options",
                                         "OptFiles2",
                                         szValue,
                                         cchMax);
                        sprintf (wrk, "OptFiles2 is <%s>", szValue) ;
                        WriteToLogFile (wrk) ;
                        if (lstrcmpi (szValue, "yes") == 0)
                                ReplaceListItem (CHECKSTATES, OPTFILES2, "ON");
                        else
                                ReplaceListItem (CHECKSTATES, OPTFILES2, "OFF");
                        RecalcOptFiles (OPTFILES2);
                        
                        GetIniKeyString (IniFile,
                                         "Options",
                                         "OptFiles3",
                                         szValue,
                                         cchMax);
                        sprintf (wrk, "OptFiles3 is <%s>", szValue) ;
                        WriteToLogFile (wrk) ;
                        if (lstrcmpi (szValue, "yes") == 0)
                                ReplaceListItem (CHECKSTATES, OPTFILES3, "ON");
                        else
                                ReplaceListItem (CHECKSTATES, OPTFILES3, "OFF");
                        RecalcOptFiles (OPTFILES3);

                        GetIniKeyString (IniFile,
                                         "Options",
                                         "RISPack",
                                         szValue,
                                         cchMax);
                        sprintf (wrk, "RISPack is <%s>", szValue) ;
                        WriteToLogFile (wrk) ;
                        if (lstrcmpi (szValue, "yes") == 0)
                                ReplaceListItem (CHECKSTATES, RISPACK, "ON");
                        else
                                ReplaceListItem (CHECKSTATES, RISPACK, "OFF");
                        RecalcOptFiles (RISPACK);
                }
                else
                {
                        WriteToLogFile ("Nothing is checked in options.") ;
                        //
                        // Same deal here.If something was wrong with the
                        // specific settings the customer gave, you should
                        // fall back to a "default" behavior and maintain
                        // "hands-off" operation.
                        //
                        
                        // Since all the CHECKSTATES were already turned ON,
                        // that is the "default" we will use here.
                }
        }
        
        // At this point, we should have all the information we need to do
        // the dirty deed...
}


/* *********************************************************************
   Function:      WinMain
   
   Purpose:       The main program body.  Initializes the Setup Toolkit
                  and runs each dialog procedure, then installs the files.
   
   Arguments:     hInstance -  handle to this application instance
                  hPrevInstance - handle to prior application instance if
                                  running more than one instance
                  szCmdLineArgs - string containing command line arguments
                  nCmdShow - show program window as normal size or icon?
   
   Return Value:  0
   
   Side Effects:  Installs your program.  What other kinds of side
                  effects did you have in mind?

   30-JAN-95 mwm  added >0 check in InitSetupToolkit function to force an
                  exit on an error return; modified default download directory
                  for NT 3.1 system to drive:\ProgramF
   ********************************************************************* */

INT PASCAL WinMain (HINSTANCE hInstance,
                    HINSTANCE hPrevInstance,
                    LPSTR szCmdLineArgs,
                    INT nCmdShow)
{
#if !defined (RISCLI)
    INT littleloop, bigloop;
#endif
    INT i, stat;
    CHAR szMode[16];
    CHAR szTemp[cchMax];
    HICON hIcon = NULL;
    LPSTR szAbout1 = NULL;
    LPSTR szAbout2 = NULL;
#if !defined (RISCLI)
    LONG lNeededSpace;
#endif
#if defined (USED)
    CHAR rgchT[16];
#endif
    BOOL rscerror = FALSE;
    LPSTR fmt;
    char *tempdirp ;
#if defined (RISAPP) || defined (RISSRV)
    CHAR TmpString [MAX_PATH+1] ;
    INT     flag ;
#endif
    
    // GetFreeSpaceForDrive() has been updated to use 64-bit
    // integers (because of high-capacity NTFS drives)
#if !defined (RISCLI)
    DWORDLONG dlFreeSpace;
#endif
    LANGID iLANGID;
#if defined (USED)
    LANGID tLANGID;
#endif
    LCID iLCID;
    DWORD dwPlatform;
    UINT emode;


    setlocale(LC_ALL, "");
    dwPlatform = ISDKGetPlatform();

    szSystemDir = ISDKGetDirectory (SYSTEM_DIR);
    szWindowsDir = ISDKGetDirectory (WINDOWS_DIR) ;

#if defined (RISCLI)
    sprintf (RemoveExec, "%srm%02d%02dsc.exe", szSystemDir, RIS_version_maj, RIS_version_min) ;
#else
    sprintf (RemoveExec, "%srm%s.exe", szSystemDir, PRODINDEX) ;
#endif
    
    // See if /h: flag was given on command line.  Call GetCommandLine()
    // to retrieve the entire command line for IngrParseCmdLineEx() only.
    // The WinMain() lpszLine argument is not consistent when it contains
    // blanks.  Note:  IngrParseCmdLine() is still supported using the
    // existing szCmdLineArgs from WinMain(); however, no checks are made 
    // for memory overwrites into the return arguments.

    batchMode = IngrParseCmdLineEx (GetCommandLine(),
                                    &CmdLine,
                                    &IniFile);

    if ( ! CmdLine ) CmdLine = "";
    if ( ! IniFile ) IniFile = "";

    // Now we can do the "standard" initialization with the
    // remaining parts of the command line.
		    		    
    if (InitSetupToolkit (CmdLine) > 0) {
    
        // I18N NOTE
        // We begin our internationalization logic here.
        //
        // First, detect the current locale and language id

        iLCID = GetUserDefaultLCID();
        iLANGID = LANGIDFROMLCID(iLCID);

        // Build the name of a localized UI DLL file.  The
        // dialog boxes for the Setup program (which must
        // be translated for localization) and the string
        // string information are combined into the same
        // externalized in a DLL.  If the language id specific
        // dll does not exist, try a primary language id only
        // dll name.  If this fails, try a unique name. 

        if ( dwPlatform == IS_WIN32S ) {
            emode = SetErrorMode(SEM_NOOPENFILEERRORBOX);
        }

        wsprintf (szUI_DLL, "ui%04x%s.dll", iLANGID, RIS_ID);
/* Different languages should have different localized dlls. RIS doesn't */
#if defined RISCLI
        strcpy(szUI_DLL, "ui0409c.dll");
#elif defined RISAPP
        strcpy(szUI_DLL, "ui0409a.dll");
#else
        strcpy(szUI_DLL, "ui0409s.dll");
#endif        
        if ( ! (hUI_DLL = LoadLibrary (szUI_DLL)) ) {
            TCHAR tmpUI_DLL[cchMax];
            iLANGID = MAKELANGID (PRIMARYLANGID (iLANGID), SUBLANG_NEUTRAL);
            wsprintf (tmpUI_DLL, "ui%04x%s.dll", iLANGID, RIS_ID);
            if ( (hUI_DLL = LoadLibrary (tmpUI_DLL)) ) {
                strcpy (szUI_DLL, tmpUI_DLL);
            }
        }

        // set the icon to display when window is collapsed

        hIcon = LoadIcon (hUI_DLL, MAKEINTRESOURCE(IDI_SETUP));

        SetClassLong (GetActiveWindow(),
                      GCL_HICON,
                      (LONG) hIcon);

        if ( dwPlatform == IS_WIN32S ) SetErrorMode (emode);
        

        // Unfortunately, the dialog interface requires the dialogs and the
        // associated processing functions to be located in the same dll.
        // If we are unsuccessful at loading the resource dll, all dialogs
        // will not function.  We must check for this legacy situation.
        if ( ! hUI_DLL ) {

            LPCTSTR args[2];

            args[0] = szUI_DLL;
            args[1] = ISDKLastErrorText (iLANGID, SETUPMESSAGELEN);
            ISDKStringIdBox (GetActiveWindow(),
                             hUI_DLL,
                             args,
                             RESOURCE_DLL_ERROR,
                             iLANGID,
                             szTitle,
                             SETUPMESSAGELEN,
                             MB_ICONSTOP);

            ISDKTSTLOCALFREE (args[1]);

            EndSetupToolkit();
            exit(0);
        }

        // I18N NOTE
        //
        // Now, fetch all of the "static" info about the product.  If the
        // dll failed to load, the string information will be pulled from the
        // executable.  By design, string information is compiled into this
        // executable and the resource dll.
        //
        // For localization, the "title" of the Setup window, as well
        // as the text of the "about" box, need to be translated to
        // the target language.
        
        
        if ( ! (szProdName    = ISDKLoadString (hUI_DLL, IDS_PRODNAME)) ||
             ! (szProdDesc    = ISDKLoadString (hUI_DLL, IDS_PRODDESC)) ||
             ! (szProdID      = ISDKLoadString (hUI_DLL, IDS_PRODID)) ||
             ! (szProdRelDate = ISDKLoadString (hUI_DLL, IDS_PRODRELDATE)) ||
             ! (szProdVer      = ISDKLoadString (hUI_DLL, IDS_PRODVER)) ||
             ! (szTitle        = ISDKLoadString (hUI_DLL, IDS_TITLE)) ||
             ! (szProdType    = ISDKLoadString (hUI_DLL, IDS_PRODTYPE)) ||
             ! (szAbout1      = ISDKLoadString (hUI_DLL, IDS_ABOUT1)) ||
             ! (szAbout2      = ISDKLoadString (hUI_DLL, IDS_ABOUT2)) ) {
            rscerror = TRUE;

        } else {

          // Since we seem to have our resource dll, go ahead and set
          // the logo to be used for the background of the Setup
          // "frame" (backdrop) window, and the title for the window.
          // The "About" box for the Setup procedure is found under the
          // "system menu" (upper left) of the frame window.

          SetBitmap (szUI_DLL, IDB_INGR);
          SetTitle (szTitle);
          SetAbout(szAbout1, szAbout2);

        }
        // Get the name of the drive where Windows (or Windows NT)
        // is installed, and store it in szWinDrive.
        GetWindowsDir (szTemp, cchMax);
        szWinDrive[0] = szTemp[0];
        szWinDrive[1] = 0;

       /*
       ** Open Log File
       */
       strcpy (TempDir, "") ;
       if( (tempdirp = getenv("TEMP")) )
       {
          if (DoesDirExist(tempdirp))
          {
            lstrcpy(TempDir, tempdirp);
          }
       }
       
       if (!strlen (TempDir))
       {
            sprintf(TempDir, "%s:", szWinDrive);
       }
       
       sprintf(LogFile, "%s\\%s", TempDir, LOG_FILE);
       OpenLogFile(LogFile, 0);

        // You can plan your Setup program to accept serial
        // numbers with different "index" values, if you wish.
        // Use the "szProdIndexes" array to hold them, then
        // IngrGetRegInfo will process the array of indexes
        // when it validates the users serial number.
        //
        // Make the last value an empty string.
#if defined (RISSRV) || defined (RISAPP)
        for (i = 0; i < NUM_INDEXES; i++) {
            if ( ! (szProdIndexes[i] = ISDKLoadString (hUI_DLL,
                                                       IDS_PRODINDEX1 + i)) ) {
                rscerror = TRUE;
            }
            else {
                    lstrcpy (szProdIndexes[i], PRODINDEX) ;
            }
        }

        szProdIndexes[NUM_INDEXES] = malloc(INDEX_LEN + 1);
        *szProdIndexes[NUM_INDEXES] = '\0';
#endif
        // If your executable and/or dll is properly built, you should never
        // encounter a load string error.  However, we'll put this here just
        // in case.  Since we have a resouce dll, we'll use the standard
        // setup exit handlers.

        if ( rscerror ) {

            LPCTSTR args[1];
            
            args[0] = ISDKLastErrorText (iLANGID, SETUPMESSAGELEN);
            
            stat = ISDKStringIdBox (GetActiveWindow(),
                                    hUI_DLL,
                                    args,
                                    RESOURCE_STRING_ERROR,
                                    iLANGID,
                                    szTitle,
                                    SETUPMESSAGELEN,
                                    MB_ICONSTOP);
            
            ISDKTSTLOCALFREE (args[0]);
            SetupError (ERROR);
        } else {    // load message box length

            LPTSTR str = NULL;

            if ( (str = ISDKLoadString (hUI_DLL, IDS_MESSAGELEN)) ) {

                if ( ! sscanf (str, "%d", &messageLen) ) {
                    messageLen = SETUPMESSAGELEN;
                }

                ISDKLOCALFREE (str);

            } else {
                messageLen = SETUPMESSAGELEN;
            }
        
        }

        // Do I have ADMIN priv but not on W95 or W32s?

        if ( ! ISDKMatchPlatform (ISm_WIN32S | ISm_CHICAGO) ) {
            if ( ! ISDKCheckForAdministrator() ) {
                DlgInfo0(DLG_EXITPRIVFAILURE);
                SetupError(1);
            }
        }

        // IMPORTANT:  If you are going to use Registry functions,
        // you MUST perform this next step.
        
        FInitRegDb ();

        // Now read the information from the product INF file.
        // (the value of szCurDir is set by InitSetupToolkit())

        // The "source" directory is the directory where you started the
        // "SETUP.EXE" program.The Setup procedure considers this
        // the directory from which all the application files will
        // be copied.
        
        GetSymbolValue ("STF_SRCDIR", szSrcDir, cchMax);
        GetSymbolValue ("STF_MODE", szMode, sizeof (szMode) -1 );
        
        ReadInfFile (SzCatStr (szCurDir, INF_FILE));

        // Set the default destination directory for the product.
        // Your product would use
        //     szWinDrive:\ProgramF\productname (Win32s, NT 3.1)
        // or
        //     szWinDrive:\Program Files\productname (NT 3.5, Windows 95)
        //
        // 30-JAN-1995 mwm  NT 3.1 directory change

        if (lstrcmp (szMode, "ADMIN") == 0 ) {

            fmt = PH2_INGR_ADMIN_DIR_FMT;

         } else if ( ISDKMatchPlatform (ISm_CHICAGO |
                                       ISm_DAYTONA_351 |
                                       ISm_NT40) ) {
            fmt = PH2_INGR_PROD_DIR_FMT;

         } else if ( ISDKMatchPlatform (ISm_DAYTONA) ) {
            fmt = "%c:\\win32app\\ingr\\%s" ;
        } else {

            fmt = PH2_W32S_PROD_DIR_FMT;

        }
        wsprintf (szInstallPath, fmt, szWinDrive[0], szProdName);
#if defined (RISSRV) || defined (RISCLI)
        strcpy (szMode, "NORMAL") ;
#endif
        if (lstrcmp (szMode, "ADMIN") == 0) {

            // Admin mode setup -- copy files to a
            // directory to be shared with workstations
            // for execution (or installing)
#if defined (RISAPP)
            Do_Admin_Setup();
#endif

        } else if (lstrcmp (szMode, "NETWORK") == 0) {

            // Workstation mode setup -- configure
            // workstation to run application from
            // shared directory.
#if defined (RISAPP)
            Do_Workstation_Setup();
#endif

        } else {
            // Normal mode setup.
            
            // Initialize all the checkbox items in the CUSTINST dialog box
            // to be "ON" by default.
            for (i = 1; i <= OPTION_ITEMS; i++)
            {
                AddListItem (CHECKSTATES, "ON");
                AddListItem (STATUSTEXT, "");
            }
            
            //
            // Initialize the strings and labels used in the "Drive status"
            // portion of the CUSTINST dialog box
            //
            for (i = 1; i < 8; i++)
                AddListItem (DRIVETEXT, "");
            ReplaceListItem (DRIVETEXT, 7, szInstallPath);
            
            //
            // The BIGLIST list contains one entry per optional selection on
            // the CUSTINST form-- an entry will be set to "YES" if there is
            // insufficient disk space to load that option item
            //
            for (i = 1; i <= OPTION_ITEMS; i++)
                AddListItem (BIGLIST, "");
            
            //
            // Initialize a list of drives which will hold additional
            // "overhead" costs that might be associated with installing
            // the product on that drive
            //
            for (i = 1; i <= NUM_DRIVES; i++)
                AddListItem (EXTRACOSTS, "0");
            
            //
            // Set some default values for Option boxes.
            // OptCur specifies default for "Installation Type"
            // Option dialog, which is "1" (Basic Installation).
            // The others (Opt1Opt, Opt2Opt, etc.) are
            // constructed for the "Options..." form that might
            // be present for any of the checkboxes on the CustInst form.
            //
            OptCur  = "1"; /* Typical is the default installation setting */
            Opt1Opt = "1"; /* SQL     */
            Opt2Opt = "1"; /* FORMS   */
            Opt3Opt = "1"; /* LOD/ULD */
            Opt4Opt = "1"; /* SAMPLES */
            RISPack = "1"; /* Packing */

            //
            // This just makes sure that all the lists are initialized
            // to hold the current drive free space, etc.
            //
            RecalcPath ();
            SetDriveStatus ();
            
            //
            // Now the REAL stuff happens.If this is an interactive
            // installation, go and run all the dialog boxes that will
            // obtain the needed information from the user.
            // If the "/h:" option was specified, this is a non-interactive
            // installation.  Go and grab all of the settings out of
            // IniFile.
            //
            if (batchMode)
                RunBatchMode() ;
            else {
                WelcomeDialog ();
                
                //
                // IDEA:  Try looking in the Registry
                // for some information about a previously
                // installed copy of your product.
                //
                // If it is in there, go to the "branded"
                // executable and extract its username,
                // company name, and serial number.
                // 
                // If the "index" portion of the serial
                // number matches the index for this
                // product, you can now "prime" the
                // registration dialog by putting
                // these strings into the Symbols
                //  NameIn
                //  OrgIn
                //  SerIn
                //
                // NOTE that GetIngrRegInfo() must be called
                // with the "Product Index" information for
                // your application, generated by SRDB.
                //
#if defined (RISSRV) || defined (RISAPP)
                IngrGetRegInfo (szProdIndexes);
                bigloop = 1;
                while (bigloop)
                {
                    littleloop = 1;
                    while (littleloop)
                    {
                        littleloop = FInstallPathDialog ();
                        if (littleloop == BACK)
                        {
                            break;
                        }
                        RecalcPath ();
                        SetDriveStatus ();
                        
                        //
                        // Find out if the user wants a "minimum (compact)", "full(typical)",
                        // or "custom" installation.
                        //
                        installType = itTypical;
                        BuildCopyListForSizing ();
                        GetCopyListCost (ALLNEEDS, ALLCOSTS, "");
                        lNeededSpace = 0;
                        for (i = 1; i <= NUM_DRIVES; i++)
                        {
                            GetListItem (ALLCOSTS, i, szTemp, sizeof (szTemp));
                            lNeededSpace += atol (szTemp);
                        }
                        wsprintf (szTemp, "%ld KB", lNeededSpace / 1024);
                        SetSymbolValue ("Text1In", szTemp);
                        sprintf (wrk, "The Typical installation will use (Text1In) : <%s>", szTemp) ;
                        WriteToLogFile (wrk) ;
                        
                        ClearCopyList ();
                        installType = itCompact;
                        BuildCopyListForSizing ();
                        GetCopyListCost (ALLNEEDS, ALLCOSTS, "");
                        lNeededSpace = 0;
                        for (i = 1; i <= NUM_DRIVES; i++)
                        {
                            GetListItem (ALLCOSTS, i, szTemp, sizeof (szTemp));
                            lNeededSpace += atol (szTemp);
                        }
                        wsprintf (szTemp, "%ld KB", lNeededSpace / 1024);
                        SetSymbolValue ("Text2In", szTemp); 
                        sprintf (wrk, "The Compact installation will use: (Text2In) <%s>", szTemp) ;
                        WriteToLogFile (wrk) ;
                        
                        ClearCopyList ();
                        // Set the "path" and "free space" fields on
                        // the options form.
                        //

                        lstrcpy(szTemp, szInstallPath);
                        ISDKChopDir(szTemp, 36);
                        SetSymbolValue ("Text3In", szTemp);
                        sprintf (wrk, "Installation path (Text3In) <%s>", szTemp) ;
                        WriteToLogFile (wrk) ;
                        dlFreeSpace = GetFreeSpaceForDrive (szInstallPath);
                        FormatValue(dlFreeSpace, szTemp);
                        SetSymbolValue ("Text4In", szTemp);
                        sprintf (wrk, "(Space Available Text4In) <%s>", szTemp) ;
                        WriteToLogFile (wrk) ;
#if defined (RISSRV) || defined (RISCLI)
                        installType = itTypical ;
#else
                        InstallTypeDialog ();
#endif
                        if (installType == itCustom)
                        {
                            //
                            // Run the "CUSTINST" dialog to find out just
                            // what options the user wants.
                            //
                            bigloop = CustInstDialog ();
                            if (bigloop == BACK)
                                continue;
                        }
                        else
                        {
                            if (installType == itTypical)
                            {
                                //
                                // Change the CHECKSTATES to indicate that
                                // which items are going to be installed
                                // for a "typical" installation.  In our
                                // example here, we turn everything on.
                                // You may not want to do this.
                                //
                                for (i = 1; i <= OPTION_ITEMS; i++)
                                {
                                    ReplaceListItem (CHECKSTATES, i, "ON");
                                }
                            }
                            if (installType == itCompact)
                            {
                                //
                                // Change the CHECKSTATES to indicate that
                                // only the first item is going to be installed
                                //
                                ReplaceListItem (CHECKSTATES, 1, "ON");
                                for (i = 2; i <= OPTION_ITEMS; i++)
                                {
                                    ReplaceListItem (CHECKSTATES, i, "OFF");
                                }
                            }
                            RecalcPath ();

                            //
                            // See if we have enough disk space to install.
                            //
                            ClearCopyList ();
                            BuildCopyList ();
                            if (GetCopyListCost (EXTRACOSTS, ALLNEEDS, ""))
                            {
                                TooBig ();
                                littleloop = TRUE;
                                continue;
                            }
                        }
                        bigloop = FALSE;
                    }
                }
#endif
            }
            
            //
            // We start creating the log file here because it is the first
            // time we know that "szInstallPath" really has the location
            // of the product.Alternately, you could start creating your
            // log at the very beginning of the procedure, creating it in
            // C:\then moving it to "szInstallPath" after you have finished
            // doing all the logging you will do.
            //
            //if (!DoesDirExist (szInstallPath))
            //    CreateDir (szInstallPath, cmoVital);
            
            //
            // Now we have all of the info we need.  Go and build the Copy List
            // Go and build the Copy List
            // and then do the installation.
            //
#if defined (RISAPP) || defined (RISSRV)
            RISValidateThisVersion() ;
            if (RemoveDirectoryFlag) {
		sprintf (wrk, "%s,%d:Removing product with version <%s> : reflist <%s>", __FILE__, __LINE__,
                    VersionToBeDeleted, RefListToBeDeleted) ;
		WriteToLogFile (wrk) ;
                if (!RMVResourceInit) {
                    RMVResourceInitializeEx (hUI_DLL) ;
                    RMVResourceInit = 1 ;
                }
	        RISRemoveProduct ( NULL, szTitle, VersionToBeDeleted,  (PVOID) RefListToBeDeleted, TRUE, FALSE, FALSE, FALSE, &flag ) ;
            }
            BuildLists ();
#endif

            SetRestartDir (szInstallPath);
            Install ();
            
            // Write an optional remove.bat in installation directory.  This
            // points to the executable loaded in the system directory and
            // allows the user to run remove.exe without knowing the renamed
            // remove.exe
            sprintf (wrk, "Writing a remove.bat that points to the executable loaded in the system directory") ;
            WriteToLogFile (wrk) ;
              {
                LPCTSTR batfilename;
                LPCTSTR args[3];

                args[0] = "@cd \\\r\n";
                args[1] = ISDKStrCatN (3,
                                       "@",
                                       RemoveExec,
                                       "\r\n");
                args[2] = NULL;
            
                batfilename = ISDKStrCatN (2, szInstallPath, "remove.bat");
            
                sprintf (wrk, "writing file <%s>", batfilename) ;
                WriteToLogFile (wrk) ;
                if ( args[1] && batfilename ) INGRWriteFile (batfilename,
                                                             args);
            
                ISDKTSTFREE (args[1]);
                ISDKTSTFREE (batfilename);
             }


            //
            // Since the routines call SetupError to quit whenever there is a
            // serious problem, if we are here then everything must have gone
            // OK...
            //
            if (!batchMode)
            {
                     
#if defined(risinfds) || defined(risinfns)
                DlgInfo0(DLG_EXITSUCCESS_INF);
                UIPop (1);
#endif
                DlgInfo0(DLG_EXITSUCCESS);
                UIPop (1);
                DlgInfo0 (DLG_WRITEDOWNSER);
                UIPop (1);


                // If there are items in the "restart list", we need to
                // restart the system.  Notify the user.

                // If a reboot is involved, mark the local temporary files
                // for delete.  On NT platforms, we can include the temporary 
                // directory.  On W95 platforms, the temporary directory has
                // to be deleted at product runtime or product removal.

                if (!RestartListEmpty()) {

                    if (DlgInfo(DLG_REBOOT, 0, NULL) == IDC_CONTINUE) {

                        INGRLstFileDelete (szCurDir,
                                           SzCatStr(szSrcDir, "setup.lst"));
                           
                         if ( ISDKMatchPlatform (ISm_CHICAGO |
                                                ISm_DAYTONA |
                                                ISm_DAYTONA_351 |
                                                ISm_NT40) ) {
                            MoveFileEx (szCurDir,
                                        NULL,
                                        MOVEFILE_DELAY_UNTIL_REBOOT);
                            
                        }

                        ExitExecRestart();
                    }
                }
            } /* ! batchmode */
	    CloseLogFile  ();
	}

        // Notify all top-level windows that the system configuration
        // data in the environment section has changed.
        // Maybe users will not have to reboot now!

        SendMessage (HWND_TOPMOST,
                     WM_WININICHANGE,
                     0L,
                     (LPARAM)"Environment");

        // If you are doing Registry stuff and you called FInitRegDb()
        // you need to call this function also.
        
        TerminateRegDb ();

        StripSlash(szInstallPath) ;    

#if defined (RISAPP) || defined (RISSRV)        
        sprintf (TmpString, "%s\\risrem.log", TempDir) ;
        DeleteFile (TmpString) ;
#endif
        sprintf (TempDir, "%s\\install.log", szInstallPath) ;
        if (CopyFile (LogFile, TempDir, FALSE)) DeleteFile (LogFile) ;
        
	if ((!batchMode) && (RebootFlag)) {
		ReBoot(hInstance);
	} else {
		// Very Important ! Clean up after ourselves; otherwise, you
		// can not run another Setup program without restarting Windows...

		EndSetupToolkit ();
        
		// I18N NOTE
		// Also remember to free up our handle to the UI DLL.

		FreeLibrary (hUI_DLL);
	}
    }		  
    return (0) ;
}

#if defined (RISAPP) || defined (RISSRV)
static long RISValidateDirectory (CHAR *Directory)
{
    CHAR    szFullSubKey[cchMax];	 
    CHAR    szRefListEntry[cchMax];
    DWORD   dwType;
    CHAR    lpBuf[cchMax];
    CHAR    oldversion[cchMax];
    CHAR    maj_min [cchMax] ;
#if defined (RISSRV)
    int     i ;
    CHAR    *SString ;
    WCHAR   *WString ;
#endif
    
    sprintf (wrk, "Validate Directory <%s> against Prodkey <%s>", Directory, PRODKEY) ;
    WriteToLogFile (wrk) ;

    RemoveDirectoryFlag = 0 ;
    
    if (lstrlen (Directory) == 0)
    {
       BlankPathDialog ();
       return 0 ;
    }
    
    if (!FValidDir (Directory) || !IsDirWritable (Directory))
    {
       InvalidPathDialog ();
       return 0 ;
    }

    // If Product registry entry exists
    // 1. Remove old Product from RIS's RefList
    // 2. Remove old Product registry entry
    // then
    // 3. Remove old Product install path
    // 4. Remove old Product program group


    
    if (GetFullSubKeyFromPath(HKEY_LOCAL_MACHINE, Directory, PRODKEY,
			szFullSubKey))
    {
	sprintf (wrk, "Sub Key <%s> exists for version appended to path <%s>",
	    szFullSubKey, Directory) ;
	WriteToLogFile (wrk) ;
	GetRegKeyValueEx(HKEY_LOCAL_MACHINE, szFullSubKey,
				"Version", &dwType, lpBuf, cchMax);

        GetMajorMinor (lpBuf, maj_min) ;
        strcpy (lpBuf, maj_min) ;

	sprintf (wrk, "Version to be delete %s", lpBuf) ;
	WriteToLogFile (wrk) ;        
#if defined (RISAPP)				
	sprintf(szRefListEntry,"RISDP\\%s", lpBuf);
#else
        WString = ISDKGetWideString ( DS_LIST_STR ) ;
        for ( i = wcslen (WString) ; i >=0 ; i--)
        {
            if (WString [i] == '\\')
            {
                WString [i] = 0 ;
                break ;
            }
        }
        SString = ISDKGetMultiString (WString) ;                             
	sprintf(szRefListEntry,"%s\\%s", SString, lpBuf);
	free (SString) ;
	free (WString) ;
#endif
	lstrcpy(oldversion,lpBuf);
	sprintf(wrk,"Version found in SubKey <%s> was <%s>.", szFullSubKey, oldversion);
	WriteToLogFile(wrk);

//	if (GetListLength("OldVersion") == 0)
//	{
//		AddListItem("OldVersion", "");
//	}
//	ReplaceListItem("OldVersion", 1, oldversion);
//      sprintf (wrk, "Replaced List Item \"OldVersion\"-1 with <%s>", oldversion) ;
//      WriteToLogFile (wrk) ;
				
	if (DoesDirExist (Directory))
	{
            //
	    // If product exists, ask the user if it can be removed.
            //
            sprintf (wrk, "Directory Exists. Ask user if he/she wants the directory <%s> to be deleted",
                Directory) ;
            WriteToLogFile (wrk) ;
            if (batchMode || ConfirmDeleteDir(1)) // 1996.06.12:Alan Barksdale:TR43960123[3|4]
	    {
	        RemoveDirectoryFlag = 1 ;
	        strcpy (VersionToBeDeleted, lpBuf) ;
	        strcpy (RefListToBeDeleted, szRefListEntry) ;
	    }
            else return (0) ;
        }
    } 
    return (1) ;
}

/* *********************************************************************
   Function:  ConfirmDeleteDir

   Purpose:  1) The user entered a path in InstallPathDialog that
                already has the product installed in it.

                We need to see if the user wants to continue, after deleting
                the current version of the product, or go back and choose
                a different directory.

             OR

             2) The user entered a path in the InstallPathDialog, and the
                version of the product being loaded is identical to the one
                that exists on the machine.

                We need to see if the user wants to continue, after deleting
                the current version of the product.

   Arguments:  ChdirFlag set to 1 or 0 depending on scenario 1) or 2) above.

   Return Value:  TRUE =  Delete existing product
                  FALSE = Choose a different directory

   Side Effects:  none
   ********************************************************************* */
static BOOL ConfirmDeleteDir(INT ChdirFlag)
{
	CHAR rgchT[16];
	BOOL retval = -1;
    
	while (retval == -1)
	{
		if( ChdirFlag == 1 )
		{
			WriteToLogFile("Product exists in directory selected");
			UIStartDlg(szUI_DLL, DLG_DESTEXISTS, "FInfoDlgProc2", 0, NULL,
				(LPSTR)rgchT, 15);
		}
		else if( ChdirFlag == 2 )
		{
			WriteToLogFile("Directory selected already exists. It may be used by another process.");
			UIStartDlg(szUI_DLL, DLG_DESTEXISTS_DIR, "FInfoDlgProc", 0, NULL,
				(LPSTR)rgchT, 15);
		}
		else if ( ChdirFlag == 3 )
		{
			WriteToLogFile("Version of the product already installed");
			UIStartDlg(szUI_DLL, DLG_DESTEXISTS_VERSIONS, "FConfirmRemVerProc", 0, NULL,
				(LPSTR)rgchT, 15);
		}
		
		else if ( ChdirFlag == 4 )
		{
			WriteToLogFile("Directory selected exists. Are you sure you want to install at this location?");
			UIStartDlg(szUI_DLL, DLG_DESTEXISTS_DIR2, "FInfoDlgProc", 0, NULL,
				(LPSTR)rgchT, 15);
		}
		
		else
		{
			WriteToLogFile("Version of the product already installed");
			UIStartDlg(szUI_DLL, DLG_DESTEXISTS_NOCD, "FConfirmRemVerProc", 0, NULL,
				(LPSTR)rgchT, 15);
		}

		switch ((WORD)(rgchT[0]+rgchT[1]))
		{
			default:
				continue;
			case IDC_CANCEL:
			case IDC_TYPEEXIT:
				AskQuit();
				continue;
			case IDC_CONTINUE:
				retval = TRUE;
				break;
			case IDC_BACK:
			{
				if (ChdirFlag)
				{
					retval = FALSE;
					break;
				}
				else
				{
					continue;
				}
			}
		}
		UIPop(1);
		return retval;
	}
}


static long RISValidateThisVersion()
{
    CHAR        RefList [cchMax] ;
    HKEY        hKey ;
    LONG        lResult ;
    TCHAR       szClass[128];
    DWORD       cchClass, dwNumSubKeys, cchMaxSubKey, cchMaxClass,
		cValues, cchMaxValName, cbMaxValData, cbSecurityDescriptor;
    FILETIME    ftLastWrite;
    DWORD       i, cchName;
    INT         flag ;
    LPSTR       szTemp = NULL ;
    DWORD       NoOfVersions ;
    char        KeyVersion [100] ;
    
#if defined (RISAPP)
    strcpy (RefList, RISDP_LIST_STR) ;
#else
    strcpy (RefList, DS_LIST_STR) ;
#endif
    
    sprintf (wrk, "Check if product <%s> is already loaded", PRODKEY) ;
    WriteToLogFile(wrk);

    if (lResult = RegOpenKeyEx(HKEY_LOCAL_MACHINE, PRODKEY,
		0, KEY_READ, &hKey) != ERROR_SUCCESS)
    {
        sprintf (wrk, "Couldn't open registry key <%s>", PRODKEY) ;
        WriteToLogFile (wrk) ;
	return(FALSE);
    }

    //
    // First, see how many subkeys this key has.
    //
    cchClass=128;
    if ((lResult = RegQueryInfoKey(hKey, szClass, &cchClass, NULL, &dwNumSubKeys,
        &cchMaxSubKey, &cchMaxClass, &cValues, &cchMaxValName,
	&cbMaxValData, &cbSecurityDescriptor, &ftLastWrite)) != ERROR_SUCCESS)
    {
	RegCloseKey(hKey);
	WriteToLogFile("GetFullSubKeyFromPath: Failed to check how many keys exist.");
	return(FALSE);
    }
    
    sprintf (wrk, "Number of sub keys are <%d>, longest key is <%d>",
            dwNumSubKeys, cchMaxSubKey) ;
    WriteToLogFile (wrk) ;

    if (dwNumSubKeys)
    {
	WriteToLogFile("GetFullSubKeyFromPath: subkeys exist.");
	//
	// This key has subkeys; we'll need to enumerate them
	// and add each one into the SubKeyList.
	//
	// RegQueryInfoKey() has indicated what the maximum length
	// of a subkey name will be for this particular key
	// in "cchMaxSubKey", so we can allocate just what we
	// need to hold the names.
	//
        cchName = cchMaxSubKey ;
	for (i = dwNumSubKeys, NoOfVersions = 0; i > 0; i--)
	{
	    WriteToLogFile ("Getting next subkey") ;

            cchName = cchMaxSubKey + 1;
	    if ((lResult = RegEnumKeyEx(hKey, i - 1,
		KeyVersion, &cchName, NULL, NULL,
                NULL, &ftLastWrite)) >= ERROR_SUCCESS)
	    {
	        sprintf (wrk, "Comparing <%s> with <%s>", VersionToBeDeleted, KeyVersion) ;
	        WriteToLogFile (wrk) ;
	        if (strcmp (VersionToBeDeleted, KeyVersion)) {
                    sprintf (wrk, "Comparing <%s> with <%s>", KeyVersion, RIS_MAJ_MIN_STR) ;
                    WriteToLogFile (wrk) ;
                    if (strcmp (KeyVersion, RIS_MAJ_MIN_STR ) == 0) {
	                sprintf (wrk, "Delete product in key %s", KeyVersion) ;
			++NoOfVersions ;
			WriteToLogFile (wrk) ;
                        break ;
                    }
                }
            }
            else
            {
               RegCloseKey(hKey);
               return FALSE ;
            }
        }       

        /*
        ** Make list "OldVersion" and add to its first item as
        ** the already installed vesion num. The second item will
        ** the old path name. This will be used
        ** to display on the dialog FConfirmRemVerProc
        */
    	sprintf (wrk, "Number of Versions is %d", NoOfVersions) ;
        WriteToLogFile (wrk) ;        
	if (NoOfVersions) {    
            if (GetListLength("OldVersion") == 0)
            {
                AddListItem("OldVersion", "");
                AddListItem("OldVersion", "");
            } else {
                sprintf (wrk, "GetListLength failed : error %d", GetLastError()) ;
                WriteToLogFile (wrk) ;
            }

            if (NoOfVersions == 1)
            {
                if ((szTemp = ISDKLoadString (hUI_DLL, IDS_VERSION_WAS_FOUND)) == NULL) RISSetupError (__FILE__, __LINE__, "String was not found") ;
                ReplaceListItem("OldVersion", 1, szTemp);
                ISDKLOCALFREE (szTemp);
                ReplaceListItem("OldVersion", 2, KeyVersion);
            }
            else
            {
                if ((szTemp = ISDKLoadString (hUI_DLL, IDS_VERSIONS_DETECTED)) == NULL) RISSetupError (__FILE__, __LINE__, "String was not found") ;
                sprintf (wrk, "%s : %d", szTemp, dwNumSubKeys) ;
                ReplaceListItem("OldVersion", 1, wrk);
                ReplaceListItem("OldVersion", 2,"");
                ISDKLOCALFREE (szTemp);
            }
        
            if (batchMode || ConfirmDeleteDir(3)) // 1996.06.12:Alan Barksdale:TR43960123[3|4]
            {
                if (!RMVResourceInit) {
                    RMVResourceInitializeEx (hUI_DLL) ;
                    RMVResourceInit = 1 ;
                }
                RISRemoveProduct ( NULL, szTitle, KeyVersion, (PVOID *) RefList, TRUE, FALSE, FALSE, FALSE, &flag ) ;
            }
        } else {
            WriteToLogFile ("No versions to be purged.") ;
        }
    }
    RegCloseKey(hKey);
    return (TRUE) ;    
}


static long RISValidateVersions( ConsiderAllVersionFlag )
    BOOLEAN    ConsiderAllVersionFlag ;
{
    CHAR        RefList [cchMax] ;
    HKEY        hKey ;
    LONG        lResult ;
    TCHAR       szClass[128];
    DWORD       cchClass, dwNumSubKeys, cchMaxSubKey, cchMaxClass,
		cValues, cchMaxValName, cbMaxValData, cbSecurityDescriptor;
    FILETIME    ftLastWrite;
    DWORD       i, cchName;
    char        **ArrayOfKeys = NULL;
    INT         flag ;
    LPSTR       szTemp = NULL ;
    DWORD       NoOfVersions ;
    char        KeyVersion [100] ;
    
#if defined (RISAPP)
    strcpy (RefList, RISDP_LIST_STR) ;
#else
    strcpy (RefList, DS_LIST_STR) ;
#endif
    
    sprintf (wrk, "Check if product <%s> is already loaded", PRODKEY) ;
    WriteToLogFile(wrk);

    if (lResult = RegOpenKeyEx(HKEY_LOCAL_MACHINE, PRODKEY,
		0, KEY_READ, &hKey) != ERROR_SUCCESS)
    {
        sprintf (wrk, "Couldn't open registry key <%s>", PRODKEY) ;
        WriteToLogFile (wrk) ;
	return(FALSE);
    }

    //
    // First, see how many subkeys this key has.
    //
    cchClass=128;
    if ((lResult = RegQueryInfoKey(hKey, szClass, &cchClass, NULL, &dwNumSubKeys,
        &cchMaxSubKey, &cchMaxClass, &cValues, &cchMaxValName,
	&cbMaxValData, &cbSecurityDescriptor, &ftLastWrite)) != ERROR_SUCCESS)
    {
	RegCloseKey(hKey);
	WriteToLogFile("GetFullSubKeyFromPath: Failed to check how many keys exist.");
	return(FALSE);
    }
    
    sprintf (wrk, "Number of sub keys are <%d>, longest key is <%d>",
            dwNumSubKeys, cchMaxSubKey) ;
    WriteToLogFile (wrk) ;

    if (dwNumSubKeys)
    {
	WriteToLogFile("GetFullSubKeyFromPath: subkeys exist.");
	//
	// This key has subkeys; we'll need to enumerate them
	// and add each one into the SubKeyList.
	//
	// RegQueryInfoKey() has indicated what the maximum length
	// of a subkey name will be for this particular key
	// in "cchMaxSubKey", so we can allocate just what we
	// need to hold the names.
	//
        ArrayOfKeys = (char **) calloc (dwNumSubKeys, sizeof (char *)) ;
        for (i=0; i<dwNumSubKeys; i++) ArrayOfKeys[i] = calloc (cchMaxSubKey+1, sizeof(TCHAR)) ;
        cchName = cchMaxSubKey ;
	for (i = dwNumSubKeys, NoOfVersions = 0; i > 0; i--)
	{
	    WriteToLogFile ("Getting next subkey") ;

            cchName = cchMaxSubKey + 1;
	    if ((lResult = RegEnumKeyEx(hKey, i - 1,
		KeyVersion, &cchName, NULL, NULL,
                NULL, &ftLastWrite)) >= ERROR_SUCCESS)
	    {
	        sprintf (wrk, "Comparing <%s> with <%s>", VersionToBeDeleted, KeyVersion) ;
	        WriteToLogFile (wrk) ;
	        if (strcmp (VersionToBeDeleted, KeyVersion)) {
	            if (ConsiderAllVersionFlag)
        	            strcpy (ArrayOfKeys[NoOfVersions++], KeyVersion) ;
                    else {
                        sprintf (wrk, "Comparing <%s> with <%s>", KeyVersion, RIS_MAJ_MIN_STR) ;
                        WriteToLogFile (wrk) ;
                        if (strcmp (KeyVersion, RIS_MAJ_MIN_STR ) == 0) {
			    sprintf (wrk, "Delete product in key %s", KeyVersion) ;
			    WriteToLogFile (wrk) ;
                            strcpy (ArrayOfKeys[NoOfVersions++], KeyVersion) ;
                            break ;
                        }
                    }
                }
            }
            else
            {
               RegCloseKey(hKey);
               for (i=0; i<dwNumSubKeys; i++)
                    if (ArrayOfKeys[i]) free (ArrayOfKeys[i]) ;
               if (ArrayOfKeys)  free (ArrayOfKeys) ;
               return FALSE ;
            }
        }       

        /*
        ** Make list "OldVersion" and add to its first item as
        ** the already installed vesion num. The second item will
        ** the old path name. This will be used
        ** to display on the dialog FConfirmRemVerProc
        */
	if (NoOfVersions) {    
            if (GetListLength("OldVersion") == 0)
            {
                AddListItem("OldVersion", "");
                AddListItem("OldVersion", "");
            } else {
                sprintf (wrk, "GetListLength failed : error %d", GetLastError()) ;
                WriteToLogFile (wrk) ;
            }

            if (NoOfVersions == 1)
            {
                if ((szTemp = ISDKLoadString (hUI_DLL, IDS_VERSION_WAS_FOUND)) == NULL) RISSetupError (__FILE__, __LINE__, "String was not found") ;
                ReplaceListItem("OldVersion", 1, szTemp);
                ISDKLOCALFREE (szTemp);
                ReplaceListItem("OldVersion", 2, ArrayOfKeys[0]);
            }
            else
            {
                if ((szTemp = ISDKLoadString (hUI_DLL, IDS_VERSIONS_DETECTED)) == NULL) RISSetupError (__FILE__, __LINE__, "String was not found") ;
                sprintf (wrk, "%s : %d", szTemp, dwNumSubKeys) ;
                ReplaceListItem("OldVersion", 1, wrk);
                ReplaceListItem("OldVersion", 2,"");
                ISDKLOCALFREE (szTemp);
            }
        
    	    sprintf (wrk, "Number of Versions is %d", NoOfVersions) ;
            WriteToLogFile (wrk) ;        
            if (batchMode || ConfirmDeleteDir(3)) // 1996.06.12:Alan Barksdale:TR43960123[3|4]
            {
               for (i=0; i<NoOfVersions; i++)
               {
                    if (ArrayOfKeys[i]) {
                        sprintf (wrk, "%s,%d:Delete product version at position <%d> version <%s> reflist <%s>", __FILE__, __LINE__, i, ArrayOfKeys[i], RefList) ;
                        WriteToLogFile (wrk) ;
                        if (!RMVResourceInit) {
                            RMVResourceInitializeEx (hUI_DLL) ;
                            RMVResourceInit = 1 ;
                        }
                        RISRemoveProduct ( NULL, szTitle, ArrayOfKeys[i], (PVOID *) RefList, TRUE, FALSE, FALSE, FALSE, &flag ) ;
                    }
               }
            }
        } else {
            WriteToLogFile ("No versions to be purged.") ;
        }
    
        for (i=0; i<dwNumSubKeys; i++) if (ArrayOfKeys[i]) free (ArrayOfKeys[i]) ;
        if (ArrayOfKeys)  free (ArrayOfKeys) ;
    }

    RegCloseKey(hKey);
    return (TRUE) ;    
}

#endif


#if defined(risinfds) || defined(risinfns)
static VOID UpdateInformixServerReg ()
{
   // Update registry with Informix server information.
   // If the registry already does not have these keys, we will
   // try to create them here.		-Goverdhan 12/15
	
   char szKey[100], szKey2[100], szSubKey[100],serverliststring[200];
   char szFullSubKey[100], host[31], protocol[10], service[31], ValueName[20];
   TCHAR	szClass[128];
   HKEY	hKey2;
   LONG	lResult;
   DWORD	cchClass, dwNumSubKeys, cchMaxSubKey, cchMaxClass,
			cValues, cchMaxValName, cbMaxValData, cbSecurityDescriptor,
	        i, dwType, SubKeySz;
   FILETIME ftLastWrite;
   int server_count = 0;

#if defined(risinfds)
   sprintf(szKey,"Software\\Intergraph\\risinfds\\0%d.0%d\\Environment",RIS_version_maj,RIS_version_min);
#else
   sprintf(szKey,"Software\\Intergraph\\risinfns\\0%d.0%d\\Environment",RIS_version_maj,RIS_version_min);
#endif

   if (!DoesRegKeyExistEx(HKEY_LOCAL_MACHINE, szKey))
   {
	WriteToLogFile("Updating Registry for informix server");
	WriteToLogFile(szKey);
      	CreateRegKeyEx (HKEY_LOCAL_MACHINE, szKey);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"CLIENT_LOCALE",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"COLLCHAR",
       	REG_SZ,
       	"1",
       	2);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"CONRETRY",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"CONTIME",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"DB_LOCALE",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"DBANSIWARN",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"DBDATE",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"DBLANG",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"DBMONEY",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"DBNLS",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"DBPATH",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"DBTEMP",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"DBTIME",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"DELIMIDENT",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"INFORMIXDIR",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"INFORMIXSERVER",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"LANG",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"LC_COLLATE",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"LC_CTYPE",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"LC_MONETARY",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"LC_NUMERIC",
       	REG_SZ,
       	"",
       	1);
      
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE,
       	szKey,
       	"LC_TIME",
       	REG_SZ,
       	"",
       	1);
   }
   else
   {
	WriteToLogFile("Not updating Registry for informix server");
   }
   
#if defined(risinfds)
   sprintf(szKey,"Software\\Intergraph\\risinfds\\0%d.0%d\\Remote_DBServers",RIS_version_maj,RIS_version_min);
#else
   sprintf(szKey,"Software\\Intergraph\\risinfns\\0%d.0%d\\Remote_DBServers",RIS_version_maj,RIS_version_min);
#endif

   if (!DoesRegKeyExistEx(HKEY_LOCAL_MACHINE, szKey))
   {
	WriteToLogFile("Updating Registry for informix server");
	WriteToLogFile(szKey);
      	CreateRegKeyEx (HKEY_LOCAL_MACHINE, szKey);
      	CreateRegKeyValueEx (HKEY_LOCAL_MACHINE, szKey, "INFORMIXSERVERLIST", REG_SZ, "", 1);
   }
   else
   {
	WriteToLogFile("Not updating Registry for informix server");
   }
   
   /*
   ** We need to restore the server information in Registry from version 5.3. Need to
   ** move the keys from HKEY_LOCAL_MACHINE\Software\Informix\Remote_DBServers to 
   ** HKEY_LOCAL_MACHINE\Software\Intergraph\RISINFD(N)S\05.04\Remote_DBServers.
   **							-Goverdhan
   */
   strcpy(szKey, "Software\\Informix\\Remote_DBServers");
   WriteToLogFile("Opening Reg. key");
   WriteToLogFile(szKey);
   if ((lResult = RegOpenKeyEx(HKEY_LOCAL_MACHINE, szKey, 0, KEY_READ, &hKey2)) == ERROR_SUCCESS)
   {
	WriteToLogFile("Checking to see how many subkeys this key has");
	cchClass=128;
	if ((lResult = RegQueryInfoKey(hKey2, szClass, &cchClass,
					NULL, &dwNumSubKeys, &cchMaxSubKey, &cchMaxClass,
					&cValues, &cchMaxValName, &cbMaxValData,
					&cbSecurityDescriptor, &ftLastWrite)) == ERROR_SUCCESS)
	{
		if (dwNumSubKeys)
		{
			for (i = 0; i < dwNumSubKeys; i++)
			{
				SubKeySz = 31;
				if ((lResult = RegEnumKeyEx(hKey2, i, szSubKey, &SubKeySz,
					0, NULL, NULL, &ftLastWrite)) == ERROR_SUCCESS)
				{
					WriteToLogFile(szSubKey);
					WriteToLogFile("Getting the host value for this subkey");
					sprintf(szFullSubKey, "%s\\%s", szKey, szSubKey);
					if (GetRegKeyValueEx(HKEY_LOCAL_MACHINE,szFullSubKey,
						"HOST", &dwType, host, 31)!=ERROR_SUCCESS)
					{
						WriteToLogFile("could'nt get host. continuing...");
						continue;
					}
					WriteToLogFile("Getting the protocol value for this subkey");
					if (GetRegKeyValueEx(HKEY_LOCAL_MACHINE,szFullSubKey,
						"PROTOCOL", &dwType, protocol, 10)!=ERROR_SUCCESS)
					{
						WriteToLogFile("could'nt get protocol. continuing...");
						continue;
					}
					WriteToLogFile("Getting the service value for this subkey");
					if (GetRegKeyValueEx(HKEY_LOCAL_MACHINE,szFullSubKey,
						"SERVICE", &dwType, service, 31)!=ERROR_SUCCESS)
					{
						WriteToLogFile("could'nt get service. continuing...");
						continue;
					}
#if defined(risinfds)
					sprintf(szKey2,"Software\\Intergraph\\risinfds\\0%d.0%d\\Remote_DBServers\\%s",
							RIS_version_maj,RIS_version_min,szSubKey);
#else
					sprintf(szKey2,"Software\\Intergraph\\risinfns\\0%d.0%d\\Remote_DBServers\\%s",
							RIS_version_maj,RIS_version_min,szSubKey);
#endif
      					CreateRegKeyEx (HKEY_LOCAL_MACHINE, szKey2);
					
      					CreateRegKeyValueEx (HKEY_LOCAL_MACHINE, szKey2, "AskPassword", REG_SZ, "N", 2);
      					CreateRegKeyValueEx (HKEY_LOCAL_MACHINE, szKey2, "HOST", REG_SZ, host, strlen(host)+1);
      					CreateRegKeyValueEx (HKEY_LOCAL_MACHINE, szKey2, "PASS", REG_SZ, "", 1);
      					CreateRegKeyValueEx (HKEY_LOCAL_MACHINE, szKey2, "PROTOCOL", REG_SZ, protocol, strlen(protocol)+1);
      					CreateRegKeyValueEx (HKEY_LOCAL_MACHINE, szKey2, "SERVICE", REG_SZ, service, strlen(service)+1);
      					CreateRegKeyValueEx (HKEY_LOCAL_MACHINE, szKey2, "USER", REG_SZ, "", 1);

      					server_count++;
					if (server_count == 1)
						strcpy(serverliststring,szSubKey);
					else
						strcat(serverliststring,szSubKey);
					strcat(serverliststring,";");	
				}
			}
			if (server_count)
			{
#if defined(risinfds)
				sprintf(szKey,"Software\\Intergraph\\risinfds\\0%d.0%d\\Remote_DBServers", RIS_version_maj,RIS_version_min);
#else
				sprintf(szKey,"Software\\Intergraph\\risinfns\\0%d.0%d\\Remote_DBServers", RIS_version_maj,RIS_version_min);
#endif
				if (lResult = RegOpenKeyEx(HKEY_LOCAL_MACHINE, szKey, 0, KEY_WRITE, &hKey2) == ERROR_SUCCESS)
				{
					strcpy(ValueName,"INFORMIXSERVERLIST");
					RegSetValueEx(hKey2, (LPTSTR)ValueName, 0, REG_SZ, (LPTSTR)serverliststring, strlen(serverliststring)+1);
				}
				RegCloseKey(hKey2);
			}
		}
	}
   }
   else
   {
	WriteToLogFile("Unable to open Software\\Informix\\Remote_DBServers");
   }
}
#endif


VOID BrandRISFile(char *ExecutableName)
{
      CHAR brandfilepath[cchMax];

      WriteToLogFile("Branding file");

      StripSlash(szInstallPath);
      sprintf(brandfilepath,"%s\\%s", szInstallPath, ExecutableName);
      AppendSlash(szInstallPath);
      SetFileAttributes(brandfilepath, FILE_ATTRIBUTE_NORMAL);
      WriteToLogFile("Calling IngrStampRegInfo");
      IngrStampRegInfo("AppFiles", "StampFile", szInstallPath);
      WriteToLogFile("Done IngrStampRegInfo");
      SetFileAttributes(brandfilepath, FILE_ATTRIBUTE_READONLY | FILE_ATTRIBUTE_ARCHIVE);
}


/* *********************************************************************
   Function:  ReBoot
   ********************************************************************* */
static void ReBoot(
	HINSTANCE hInstance)
{
   CHAR rgchT[16];
   char szBuf[100];
	int i=0;   
	HANDLE hAccessToken;
	TOKEN_PRIVILEGES tpAccessTokenPrivilege;

   while (TRUE)
   {
      // Start the dialog box
      if ( ISDKMatchPlatform (ISm_CHICAGO)) {
      UIStartDlg (szUI_DLL, DLG_REBOOT_WIN95, "FQuitDlgProc", DLG_APPHELP,
       "FHelpDlgProc", (LPSTR) rgchT, 15);
      } else {
      UIStartDlg (szUI_DLL, DLG_REBOOT_NT40, "FQuitDlgProc", DLG_APPHELP,
       "FHelpDlgProc", (LPSTR) rgchT, 15);
      }
      
      // Interpret result code
      switch ((WORD) (rgchT[0] + rgchT[1]))
      {
        
      case IDC_QUITEXIT:
        UIPopAll ();
        EndSetupToolkit ();

	// 1996.06.26:Alan Barksdale:TR439601345:Added privilege code.
	if(ISDKMatchPlatform(ISm_NT31 | ISm_DAYTONA | ISm_DAYTONA_351 |
		ISm_NT40) ) {
		if(!OpenProcessToken(GetCurrentProcess(),
			TOKEN_ADJUST_PRIVILEGES, &hAccessToken)) {
			wsprintf(szBuf, "OpenProcessToken error:  %d",
				GetLastError ());
			MessageBox(NULL, szBuf, NULL, MB_OK);
		} else if(!LookupPrivilegeValue((LPSTR)NULL, SE_SHUTDOWN_NAME,
			&tpAccessTokenPrivilege.Privileges[0].Luid)) {
			wsprintf(szBuf, "LookupPrivilegeValue error:  %d",
				GetLastError ());
			MessageBox(NULL, szBuf, NULL, MB_OK);
		} else {
			tpAccessTokenPrivilege.PrivilegeCount = 1;
			tpAccessTokenPrivilege.Privileges[0].Attributes =
				SE_PRIVILEGE_ENABLED;
			if(!AdjustTokenPrivileges(hAccessToken, FALSE,
				&tpAccessTokenPrivilege, (DWORD)NULL,
				(PTOKEN_PRIVILEGES)NULL, (PDWORD)NULL)) {
				wsprintf(szBuf,
					"AdjustTokenPrivileges error:  %d",
					GetLastError ());
				MessageBox(NULL, szBuf, NULL, MB_OK);
			}
		}
	}

	// Shut down the system, and reboot the system.
	if(!ExitWindowsEx( EWX_REBOOT, 0 )) {
		wsprintf(szBuf, "ExitWindowsEx error:  %d", GetLastError ());
		MessageBox(NULL, szBuf, NULL, MB_OK);
	} else {
		Sleep(23000); // 1996.06.28:Alan Barksdale:so won't try anything else while waiting for reboot
	}
	// 1996.07.08:Alan Barksdale:
	/*
	From: 	Metheny, Mike (Michael W)
	Sent: 	Thursday, July 04, 1996 4:21 PM
	To: 	Barksdale, Alan F
	Subject: 	RE: Exiting Windows from Setup

	Alan,

	I've traced this into the MS code.  It appears NT4.0 sends messages
	differently enough that existing code is now being called where it
	wasn't being called before.  I've implemented a workaround in the
	setup code that hasn't failed yet, but it is timing dependent (meaning
	it probably will fail, especially on a faster machine).

	Try this:

	Move the CloseLogFile() call so it is called before any restart logic.
	Then, immediately after the call to ExitExecRestart() (or
	ExitWindowsEx(), whichever way you do it), call exit(0).  With luck,
	the delivery executable exits before the reboot message is sent to the
	delivery executable (actually, it is a query message to see if the
	delivery executable can stop, and the MS portion of the code says
	"no").  If this workaround still consistently fails, I will modify the
	MS code as a last resort.
   
	   -- Mike

	------------
	 Michael W. Metheny     
	 Intergraph Corporation, m/s GD3002  
	 Huntsville, AL  35894-0001
	 email:  mwmethen@ingr.com
	 voice:  (205) 730-3753  ||  fax:  (205) 730-3300                  
	------------
	*/
	exit(0);
        break;

      case IDC_CANCEL:
      case IDC_QUITCONTINUE:
        UIPop (1);
        return;

        default:
        continue;
      }
      
   }
}

/* *********************************************************************
   Function:    RISSetupError

   Purpose:     Writes last error and the line and file name to the log file.
   Setup procedure using a dialog box.  Then it terminates
   the procedure.

   Arguments:   file, line, comment

   Return Value:  none

   Side Effects:  Causes the setup procedure to exit.
   ********************************************************************* */
VOID RISSetupError (char *filename, int line, char *comment)
{
    char TmpWrk [cchMax];
    
    sprintf (TmpWrk, "%s:%d:Last Error Known to the system (using GetLastError()) was %d. Message <%s>", filename, line, GetLastError(), comment) ;
    WriteToLogFile (TmpWrk) ;
    
    SetupError(0) ;
}


/* *********************************************************************
   Function:    RISSetupWarning

   Purpose:     Writes last error and the line and file name to the log file.
   Setup procedure using a dialog box.  Does not terminates
   the procedure.

   Arguments:   file, line, comment

   Return Value:  none

   Side Effects: 
   ********************************************************************* */
VOID RISSetupWarning (char *filename, int line, char *comment)
{
    char TmpWrk [cchMax];
    
    sprintf (TmpWrk, "%s:%d:Last Error Known to the system (using GetLastError()) was %d. Message <%s>", filename, line, GetLastError(), comment) ;
    WriteToLogFile (TmpWrk) ;
    
}

static void AddShareComponent (char *szSrcDir, char *szInstallPath) {
    char TmpString [cchMax] ;
    
    AddSectionFilesToCopyList("RIS", szSrcDir, szInstallPath);
    if (ISDKMatchPlatform (ISm_CHICAGO)) sprintf (TmpString, "WIN95RIS") ;
    else sprintf (TmpString, "NTRIS") ;
    AddSectionFilesToCopyList("SYS", szSrcDir, szInstallPath);

}

/* *********************************************************************
   Function:  BuildCopyList
   
   Purpose:  Build the copy list for the files to be installed.  For
   "minimal" or "full" installations, this is easy.  For
   "custom" installations, we need to get info stored by the
   "CUSTINST" dialog box.  The "AddOptFilesToCopyList" function
   does this for us. Just used to calculate the size.
   
   Arguments:  none
   
   Return Value:  none
   
   Side Effects:  Global copy list is modified
   ********************************************************************* */
VOID BuildCopyListForSizing ()
{
    
    ClearCopyList ();
    sprintf(wrk,"%s,%d:begin BuildCopyList (itCompact).",__FILE__,__LINE__) ;
    WriteToLogFile(wrk);
#if defined (RISAPP)
   switch (installType)
   {
      case itCompact:
        AddSectionFilesToCopyList("Files", szSrcDir, szInstallPath);
        AddSectionFilesToCopyList("AppFiles", szSrcDir, szInstallPath);
        AddShareComponent (szSrcDir, szInstallPath) ;
      break;
      
      case itTypical:
        AddSectionFilesToCopyList("Files", szSrcDir, szInstallPath);
        AddSectionFilesToCopyList("AppFiles", szSrcDir, szInstallPath);
        AddShareComponent (szSrcDir, szInstallPath) ;
  
        // OptFiles1 -- Forms related files.
        AddSectionFilesToCopyList("OptFiles1", szSrcDir,szInstallPath);
  
        // OptFiles2 -- Loader/Unloader related files.
        AddSectionFilesToCopyList("OptFiles2", szSrcDir,szInstallPath);
  
        // OptFiles3 -- Samples files. RISDP CustInst
        AddSectionFilesToCopyList("OptFiles3", szSrcDir,szInstallPath);
  
        // RISPack -- RIS Packaging files. RISDP CustInst
        AddSectionFilesToCopyList("RISPack", szSrcDir,szInstallPath);
      break;
      
      case itCustom:
    // Do not add SHARE RIS STUFF TO RISDP path
        AddShareComponent (szSrcDir, szInstallPath) ;
        AddOptFilesToCopyList(APPFILES,0);
        AddOptFilesToCopyList(OPTFILES1,0);
        AddOptFilesToCopyList(OPTFILES2,0);
        AddOptFilesToCopyList(OPTFILES3,0);
        AddOptFilesToCopyList(RISPACK,0);
        AddShareComponent (szSrcDir, szInstallPath) ;
        break;
   }

#endif

#if defined (RISSRV)    
        switch (installType)
        {
            case itTypical:
                AddSectionFilesToCopyList("Files", szSrcDir, szInstallPath);
                AddSectionFilesToCopyList("AppFiles", szSrcDir, szInstallPath);
                sprintf(wrk,"%s,%d:BuildCopyList AddSectionFilesToCopyList",__FILE__,__LINE__);
                WriteToLogFile(wrk);
                AddShareComponent (szSrcDir, szInstallPath) ;
            break;
                
            case itCompact:
            break;
                
            case itCustom:
            break;
        }
#endif
   sprintf(wrk,"%s,%d:BuildCopyList returns VOID",__FILE__,__LINE__);
   WriteToLogFile(wrk);

    // If you place your remove executable and dll's in a "RmvFiles" section,
    // this call will copy them to the system directory on the target machine.
    // When copying to the system directory, we suggest renaming the files
    // rmPRODUCTINDEX.exe, rmPRODUCTINDEX.dl[1,2,...].
    //
    AddSectionFilesToCopyList("RmvFiles", szSrcDir, szSystemDir);


    // If you need to do a platform dependent copy, here is some example code 
    // to perform this operation (this also delivers the files the to SYSTEM
    // directory on the target machine using the szSystemDir global:
    // 
    //    NTFILES is the file section delivered on NT35, NT351, or W95
    //    W32SFILES is the file section delivered on Win32s 
    //
    // platform = ISDKGetPlatform();
    //
    // switch (installType) {
    //   case itTypical:
    //
    //     if ( (platform == IS_DAYTONA) || 
    //          (platform == IS_DAYTONA_351) ||
    //          (platform == IS_CHICAGO) ) {
    //         AddSectionFilesToCopyList("NTFILES", 
    //                                   szSrcDir, 
    //                                   szSystemDir);
    //     } else if ( platform == IS_WIN32S ) {
    //         AddSectionFilesToCopyList("W32SFILES", 
    //                                    szSrcDir, 
    //                                    szSystemDir);
    //     }
    //     break;  


}



