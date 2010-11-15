/* Do not alter this SPC information: $Revision: 1.53.3.1 $ */

/*=======================================================================
    Melania M Stewart - Moved the comments and unused functions
                        to the bottom of this file. Major re-structure. 1996.April
  =======================================================================*/

  
#include "risver.h"
#include "rissetup.h"
#include "rissrvc.h"
#include "setupver.h"
#include "ingrbld.h"
#include "ingrreg.h"
#include <windows.h>
#include <stdlib.h>
#include <direct.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include "isdk.h"
#include "rmdefs.h" // for RMT_FAILURE and RMT_SUCCESS
#include "setupapi.h"
#include "msdetect.h"
#include "msregdb.h"

#define COMPONENT      "RIS"
#define IDNUMBER       "N/A"
#define VERSION        RIS_VERSION_STR
#define DESCRIPTION    "RIS shared component"
#define FUNCTION       SetupRIS
#define FUNCTION2      RegEdtRIS
#define cchMax         255
#define cchMaxReg      2048



/* if neither FOR_WIN32 nor FOR_WIN32S is defined in the make environment,
 * assume that setup will be performed for both.  If either or both are
 * set in the make environment then those settings will be honored.
 */
#ifndef FOR_WIN32
 #ifndef FOR_WIN32S
  #define FOR_WIN32
  #define FOR_WIN32S
 #endif
#endif

/* if both are defined, then also set FOR_BOTH
 */
#ifdef FOR_WIN32
 #ifdef FOR_WIN32S
  #define FOR_BOTH
 #endif
#endif

CHAR wrk[255];
BOOL RebootFlag = FALSE ;
extern wchar_t wcSep ;               /* 1995.05.01:Melania M Stewart:Globally declared in ingrbld.c */
static  wchar_t Tmp_wcSep = L'\0' ;  /* 1996.05.01:Melania M Stewart:Global variable used in ingrbld.c, if not defined
                                        the executable should provide a string called : IDS_PATHSEP,
                                        if not provided setup fails, we are setting while in RIS to backward-slash */


extern VOID AppendToSystemPath(CHAR *szNewPath, BOOL bAddQuotesOnNT,
	BOOL *pbRebootFlag);
static void RISCreateProgMan(LPTSTR szInstallPath);
static int RIS_DoSpecial(
	char *RISSharePath);
static BOOL RISShouldInstall(char *currver);
static void GetRISVersion (char *) ;
extern BOOL CheckRegIngrCommon (char *) ;
extern appendToRegValue (TCHAR *, TCHAR *);
extern parseVersion (LPTSTR, int[]) ;
static int compareVersions ( int vers[4], int xvers[4] );
extern void  Change_wcSep (int) ;
void GetMajorMinor(CHAR *, CHAR *) ;


/******************************************************************************

    SYNOPSIS

    extern VOID AppendToSystemPath(
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

        This function appends szNewPath to the system path if it is not
        already there.

    CHANGE HISTORY

        11-JUL-1996 afb    Initial creation by adapting part of FUNCTION
                           (SetupRIS), changing as little code as possible.
                           This function was needed to satisfy TR439601360 on
                           adding riscpp's path to the system path.  (Alan
                           Barksdale)

******************************************************************************/

extern VOID AppendToSystemPath(
	CHAR *szNewPath,
	BOOL bAddQuotesOnNT,
	BOOL *pbRebootFlag)
{
  CHAR szPathToAppend[cchMax]; /* path to add to end of PATH environment variable */
  CHAR szPath[cchMaxReg];      /* PATH environment variable   */
  CHAR szSubKey[cchMax];       /* registry key     */
  DWORD dwType;                /* registry value type   */
  char szAutoexec[cchMax];     /* 1995.08.10:Alan Barksdale:TR439503145 */
  LPSTR TmpStr = NULL ;
  char szAEFile[64];
  int i;
  int platform;
  DWORD ret;
  BOOL  value;
  
    sprintf(wrk, "%s,%d:AppendToSystemPath entered", __FILE__, __LINE__);
    WriteToLogFile(wrk);
    sprintf(wrk,
       "%s,%d:AppendToSystemPath:szNewPath = \"%s\", bAddQuotesOnNT = %d",
       __FILE__, __LINE__, szNewPath, bAddQuotesOnNT);
    WriteToLogFile(wrk);

    strcpy(szPathToAppend, szNewPath); // because this function may modify the string

    platform = ISDKGetPlatform();

    if ( platform != IS_CHICAGO )
    {
      StripSlash (szPathToAppend) ;

      if(bAddQuotesOnNT) {
         TmpStr = ISDKQuoteString (szPathToAppend) ;
         strcpy (szPathToAppend, TmpStr) ;
         free (TmpStr) ;
      }
            
      /* get PATH environment variable */
      lstrcpy ( szSubKey, "SYSTEM\\CurrentControlSet\\Control" );
      lstrcat ( szSubKey, "\\Session Manager\\Environment" );
      if ( GetRegKeyValueEx ( HKEY_LOCAL_MACHINE,
          szSubKey,
          "Path",
          (LPDWORD)&dwType,
          szPath,
          cchMaxReg ) != ERROR_SUCCESS )
          {
            WriteToLogFile("SYSTEM\\CurrentControlSet\\Control does not exist." );
            sprintf (szPath, "%s", szPathToAppend) ;
            CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
             szSubKey,
             "Path",
             REG_SZ,
             szPath,
             lstrlen(szPath) + 1 );
             WriteToLogFile("SYSTEM\\CurrentControlSet\\Control created." );
           }
          else
          {
            WriteToLogFile("SYSTEM\\CurrentControlSet\\Control exists." );
            ret = appendToRegValue (szPath, szPathToAppend) ;
            if (ret)
            {
                 WriteToLogFile ("Append path of shared dlls and utilities to System's Path.") ;
                 SetRegKeyValueEx ( HKEY_LOCAL_MACHINE,
                    szSubKey,
                    "Path",
                    dwType,
                    szPath, lstrlen(szPath) + 1 );
                 if (ret) *pbRebootFlag = TRUE ; /* only reboot if the dll path is added */
             }
             
          }
    }
    else
    {
      /* Windows 95 doesn't store its system-wide environment
      ** variables in the Registry.  It puts them in AUTOEXEC.BAT.
      ** (YECCH!)
      */
      /*
      ** get PATH environment variable value and make sure that "Share"
      ** directory is included
      */
      strcpy(szAutoexec,"C:\\AUTOEXEC.BAT");
      if (GetFileAttributes("C:\\AUTOEXEC.BAT") == 0xFFFFFFFF)
      {
         if (GetLastError() == ERROR_FILE_NOT_FOUND)
         {
            sprintf(wrk,"%s,%d:AppendToSystemPath:no AUTOEXEC.BAT, ISDKAppendToAEPath will create it",
               __FILE__,__LINE__);
            WriteToLogFile(wrk);
            szAutoexec[0] = '\0';
         }
      }

      AppendSlash (szPathToAppend) ;
      /* Melania M Stewart - Added check to test if autoexec.bat has changed */
      if (value = ISDKAppendToAEPathEx(&ret, szAutoexec, "C:\\AUTOEXEC.I9X",
         szPathToAppend))
      {
        if (ret) /* if path does not exist in autoexec.bat, append to it. Set Flag. */
        {
           /*
           ** Append succeeded.  Rename the original AUTOEXEC.BAT
           ** and move the new one in its place
           */
           for (i = 0; i < 1000; i++)
           {
             wsprintf(szAEFile, "C:\\AUTOEXEC.%03d", i);
             if (GetFileAttributes(szAEFile) == 0xFFFFFFFF)
             {
               if (GetLastError() == ERROR_FILE_NOT_FOUND)
               break;
             }
            }
            MoveFile("C:\\AUTOEXEC.BAT", szAEFile);
            MoveFile("C:\\AUTOEXEC.I9X", "C:\\AUTOEXEC.BAT");
            WriteToLogFile ("Path in autoexec has changed to add RIS dll path or RIS utilities path or riscpp path.") ;
            *pbRebootFlag = TRUE ;
        }
      }
      else
      {
        if (value == FALSE) {
            sprintf (wrk, "Fail to append <%s> to destination file c:\\autoexec.i9x",
                    szPathToAppend) ;
            WriteToLogFile (wrk) ;
        }
      }
    }

    sprintf(wrk, "%s,%d:AppendToSystemPath:*pbRebootFlag = %d", __FILE__,
       __LINE__, *pbRebootFlag);
    WriteToLogFile(wrk);
    sprintf(wrk,"%s,%d:AppendToSystemPath returns VOID", __FILE__, __LINE__);
    WriteToLogFile(wrk);
} // AppendToSystemPath

/* FUNCTION - does the following:
     STEP 0: 
     If a later version of shared component is installed. It returns. FUNCTION2 does
     the same thing at its STEP 0. Therefore, if a later version of the shared component
     is encountered FUNCTION (SetupRIS) and FUNCTION 2 (RegEdtRIS) leave the (later) shared
     component intact.
     
     STEP 1:
     Gets/Sets HLM\SOFTWARE\INTERGRAPH\Common value, which is the location of the shared components
     Create the above location if non-existant
     Adds above path and the location of the utilities to:
         NT - Registry : CurrentVersion\SesionManager\Enviroment
         WIN95 - autoexec.bat (if new, sets flag for re-boot)
     STEP 2:
    return values :
      0  -  if component exists for a later version.
      1  -  if component exist for a previous version
      2  -  if component does not exist
*/

//#define ALAN_CHANGE // 1996.07.12:Alan Barksdale:"ALAN_CHANGE" marks code that takes advantage of AppendToSystemPath.

int
FUNCTION ( VOID )
{
  CHAR szWinDir[cchMax];       /* windows directory      */
  CHAR szWinSysDir[MAX_PATH+1];  /* windows directory followed by system32\  */
  CHAR szWinDrive[2];	       /* windows drive        */
  CHAR szShare[cchMax];        /* Share path  */
  CHAR szShare1[cchMax];       /* Share path  */
  CHAR szShareB[cchMax];       /* Share path   */
#if !defined(ALAN_CHANGE)
  CHAR szPath[cchMaxReg];      /* PATH environment variable   */
#endif // #if !defined(ALAN_CHANGE)
  CHAR szSubKey[cchMax];       /* registry key     */
  DWORD dwType;                /* registry value type   */
  CHAR szSrcDir[cchMax];       /* source of files on delivery media   */
  int install; /* 0 if share is not to be installed  */
               /* 1 if share is to be installed      */
               /* 2 if share is new on this host     */
  CHAR szVersion[cchMax];      /* Component version    */
  int vers[4],xvers[4];        /* this version, existing version M.m.f.b */
  char szVers[cchMax];	       /* working string for version */
#if !defined(ALAN_CHANGE)
  char szAutoexec[cchMax];     /* 1995.08.10:Alan Barksdale:TR439503145 */
#endif // #if !defined(ALAN_CHANGE)
  LPSTR TmpStr = NULL ;
  char TmpString [64];
#ifdef FOR_WIN32S
  char szIniBuf[4*cchMax];
  char szAEFile[64];
  int i;
#endif /* FOR_WIN32S */
#ifdef FOR_WIN32
  int platform;
#if !defined(ALAN_CHANGE)
  DWORD ret, ret2 ;
  BOOL  value1, value2 ;
#endif // #if !defined(ALAN_CHANGE)
#endif /* FOR_WIN32 */
  
  
#ifndef CURRENTVERSION
    CHAR szMajMin[cchMax];   /* Major.Minor version string */
#endif /* !CURRENTVERSION */

    WriteToLogFile("FUNCTION entered");
    Change_wcSep (1) ;
#ifdef FOR_WIN32
    platform = ISDKGetPlatform();
#endif /* FOR_WIN32 */

    /* STEP 0 */
    if (RISShouldInstall(RIS_MAJ_MIN_STR) == FALSE)
        WriteToLogFile("FUNCTION: No later versions found, ok to install");
    else
    {
        WriteToLogFile("FUNCTION: A later version was found, do not install");
        sprintf(wrk,"%s,%d:FUNCTION returns 0",__FILE__,__LINE__);
        WriteToLogFile(wrk);
        Change_wcSep (0) ;
	return(0);
    }

    /* STEP 1    */
  GetWindowsDir( szWinDir, cchMax );
  szWinDrive[0] = szWinDir[0];
  szWinDrive[1] = 0;
  
#ifdef FOR_BOTH
  if (platform != IS_WIN32S) 
#endif /* FOR_BOTH */
#ifdef FOR_WIN32
  {
    CheckRegIngrCommon(szShare);
    sprintf (wrk, "%s,%d:FUNCTION szShare is \"%s\"", __FILE__,__LINE__,
        szShare) ;
    WriteToLogFile(wrk) ;
    /* create directory if necessary	*/
    lstrcpy ( szShareB, szShare );
    if ( ! DoesDirExist ( szShareB ) )
    {
        /* cmoVital because setup should fail if we can't create the dir   */
        WriteToLogFile ("Share dir doesn't exist. Create.") ;
        CreateDir ( szShareB, cmoVital );
    }
    else
    {
        sprintf (wrk, "Share Directory <%s> exists.", szShareB) ;
    }
    WriteToLogFile(wrk);
    GetRISVersion (szMajMin) ;
    sprintf (szShare1, "%s%s%s\\BIN", szShareB, COMPONENT, szMajMin) ;
    if ( ! DoesDirExist ( szShare1 ) )
    {
        /* cmoVital because setup should fail if we can't create the dir. If directory doesn't exist, it won't append to the autoexec.bat   */
        WriteToLogFile ("Utilities dir doesn't exist. Create.") ;
        CreateDir ( szShare1, cmoVital );
    }
    else
    {
        sprintf (wrk, "Utility Directory <%s> exists.", szShare1) ;
    }
/* 1996.03.01:Melania M Stewart - Added the bin directory the path */
#if defined(ALAN_CHANGE)
    AppendToSystemPath(szShareB, FALSE, &RebootFlag);
    AppendToSystemPath(szShare1, TRUE, &RebootFlag);
#else // if defined(ALAN_CHANGE) else
    if ( platform != IS_CHICAGO )
    {
      /* get PATH environment variable */

      TmpStr = ISDKQuoteString (szShare1) ;
      strcpy (szShare1, TmpStr) ;
      free (TmpStr) ;

      StripSlash (szShareB) ;
            
      lstrcpy ( szSubKey, "SYSTEM\\CurrentControlSet\\Control" );
      lstrcat ( szSubKey, "\\Session Manager\\Environment" );
      if ( GetRegKeyValueEx ( HKEY_LOCAL_MACHINE,
          szSubKey,
          "Path",
          (LPDWORD)&dwType,
          szPath,
          cchMaxReg ) != ERROR_SUCCESS )
          {
            WriteToLogFile("SYSTEM\\CurrentControlSet\\Control does not exist." );
            sprintf (szPath, "%s;%s", szShareB, szShare1) ;
            CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
             szSubKey,
             "Path",
             REG_SZ,
             szPath,
             lstrlen(szPath) + 1 );
             WriteToLogFile("SYSTEM\\CurrentControlSet\\Control created." );
           }
          else
          {
            WriteToLogFile("SYSTEM\\CurrentControlSet\\Control exists." );
            WriteToLogFile (szPath) ;
            ret = appendToRegValue (szPath, szShareB) ;
            ret2 = appendToRegValue (szPath, szShare1) ;
            if (ret || ret2)
            {
                 WriteToLogFile ("Append path of shared dlls and utilities to System's Path.") ;
                 SetRegKeyValueEx ( HKEY_LOCAL_MACHINE,
                    szSubKey,
                    "Path",
                    dwType,
                    szPath, lstrlen(szPath) + 1 );
                 if (ret) RebootFlag = TRUE ; /* only reboot if the dll path is added */
             }
             
          }
    }
    else
    {
      /* Windows 95 doesn't store its system-wide environment
      ** variables in the Registry.  It puts them in AUTOEXEC.BAT.
      ** (YECCH!)
      */
      /*
      ** get PATH environment variable value and make sure that "Share"
      ** directory is included
      */
      strcpy(szAutoexec,"C:\\AUTOEXEC.BAT");
      if (GetFileAttributes("C:\\AUTOEXEC.BAT") == 0xFFFFFFFF)
      {
         if (GetLastError() == ERROR_FILE_NOT_FOUND)
         {
            sprintf(wrk,"%s,%d:FUNCTION:no AUTOEXEC.BAT, ISDKAppendToAEPath will create it",
               __FILE__,__LINE__);
            WriteToLogFile(wrk);
            szAutoexec[0] = '\0';
         }
      }

      AppendSlash (szShareB) ;
      AppendSlash (szShare1) ;
      /* Melania M Stewart - Added check to test if autoexec.bat has changed */
      if ((value1 = ISDKAppendToAEPathEx(&ret, szAutoexec,
        "C:\\AUTOEXEC.I9X",
        szShareB)) &&
        (value2 = ISDKAppendToAEPathEx (&ret2, "C:\\AUTOEXEC.I9X",
        "C:\\AUTOEXEC.I9S",
        szShare1)))
      {
        DeleteFile ("C:\\AUTOEXEC.I9X") ;        
        if (ret || ret2) /* if either path do not exist in autoexec.bat, append to it. Set Flag. */
        {
           /*
           ** Append succeeded.  Rename the original AUTOEXEC.BAT
           ** and move the new one in its place
           */
           for (i = 0; i < 1000; i++)
           {
             wsprintf(szAEFile, "C:\\AUTOEXEC.%03d", i);
             if (GetFileAttributes(szAEFile) == 0xFFFFFFFF)
             {
               if (GetLastError() == ERROR_FILE_NOT_FOUND)
               break;
             }
            }
            MoveFile("C:\\AUTOEXEC.BAT", szAEFile);
            MoveFile("C:\\AUTOEXEC.I9S", "C:\\AUTOEXEC.BAT");
            WriteToLogFile ("Path in autoexec has changed to add RIS dll path or RIS utilities path.") ;
            RebootFlag = TRUE ;
        }
      }
      else
      {
        if (value1 == FALSE) {
            sprintf (wrk, "Fail to append <%s> to destination file c:\\autoexec.i9x",
                    szShareB) ;
            WriteToLogFile (wrk) ;
        }
        if (value2 == FALSE) {
            sprintf (wrk, "Fail to append <%s> to destination file c:\\autoexec.i9s",
                    szShare1) ;
            WriteToLogFile (wrk) ;
        }
      }
    }
#endif// if defined(ALAN_CHANGE) else
  }
#endif /* FOR_WIN32 */
#ifdef FOR_BOTH
  else 
#endif /* FOR_BOTH */
#ifdef FOR_WIN32S
  {
    /*
    ** Win32s doesn't support the whole set of Registry keys
    ** like NT and Win95 do.  In this case, we have to fall back
    ** to using an INI file to hold the information.
    **
    */
    
    /* determine default INGR share path */
    lstrcpy ( szShare, szWinDrive );
    lstrcat ( szShare, ":\\I9SHARE.32s" );
    WritePrivateProfileString("Common",
     "Common",
   szShare,
     "INGR.INI");
    
    /* create directory if necessary */
    lstrcpy ( szShareB, szShare );

    if ( ! DoesDirExist ( szShareB ) )
    {
      /* cmoVital because setup should fail if we can't create the dir */
      CreateDir ( szShareB, cmoVital );
    }
  
    /*
    ** get PATH environment variable value and make sure that "Share"
    ** directory is included
    */

    if (ISDKAppendToAEPath("C:\\AUTOEXEC.BAT",
       "C:\\AUTOEXEC.I9S",
       szShareB))
    {
      /*
      ** Append succeeded.  Rename the original AUTOEXEC.BAT
      ** and move the new one in its place
      */
      for (i = 0; i < 1000; i++)
      {
   wsprintf(szAEFile, "C:\\AUTOEXEC.%03d", i);
   if (GetFileAttributes(szAEFile) == 0xFFFFFFFF)
   {
     if (GetLastError() == ERROR_FILE_NOT_FOUND)
       break;
   }
      }
      MoveFile("C:\\AUTOEXEC.BAT", szAEFile);
      MoveFile("C:\\AUTOEXEC.I9S", "C:\\AUTOEXEC.BAT");
    }
  }
#endif /* FOR_WIN32S */

/* STEP 2    -
/* Access registry to determine,
        Install = 0 : If component is off a later version. (This should not happen,
                      because this should have been detected at STEP 0 and return then.
        Install = 1 : If component is of a previous version.
        Install = 2 : If component is not in the registry at all.
 */
 
  install = 0;
#ifdef FOR_BOTH
  if (platform != IS_WIN32S) 
#endif 
#ifdef FOR_WIN32
  {
    /*
    ** For NT and Win95 (Chicago), we use the Registry to hold
    ** configuration information for shared components.
    ** For Win32s, we will need to use INI files instead.
    */

    /* Define registry key for shared component */
    lstrcpy ( szSubKey, "SOFTWARE\\Intergraph" );
    lstrcat ( szSubKey, "\\" );
    lstrcat ( szSubKey, COMPONENT );
  
#ifdef CURRENTVERSION
    lstrcat ( szSubKey, "\\CurrentVersion" );
#else
    /* parse new version number */
    lstrcpy ( szVers, VERSION );
    parseVersion ( szVers, vers );
    sprintf ( szMajMin, "%02d.%02d", vers[0], vers[1] );
    lstrcat ( szSubKey, "\\" );
    lstrcat ( szSubKey, szMajMin );
#endif /* CURRENTVERSION */
    sprintf (wrk, "Check if key <%s> exists.", szSubKey) ;
    WriteToLogFile (wrk) ;
    if ( ! DoesRegKeyExistEx ( HKEY_LOCAL_MACHINE, szSubKey ) )
    {
      sprintf (wrk, "Registry key <%s> does not exist. Install = 2", szSubKey) ;
      WriteToLogFile(wrk);
      install = 2;
    }
    else
    {
      if ( GetRegKeyValueEx ( HKEY_LOCAL_MACHINE,
   szSubKey,
   "Version",
   (LPDWORD)&dwType,
   szVersion,
   cchMax ) != ERROR_SUCCESS )
      {
        WriteToLogFile("RISsetup: Registry key does exist." );
        install = 2;
      }
      else
      {
#ifdef CURRENTVERSION
   /* parse new version number */
        WriteToLogFile("RISsetup: Is CURRENTVERSION." );
        lstrcpy ( szVers, VERSION );
        parseVersion ( szVers, vers );
#endif /*CURRENTVERSION */
      
   /* parse existing version number */
       lstrcpy ( szVers, szVersion );
       parseVersion ( szVers, xvers );
      
       install = compareVersions ( vers, xvers );
      }
    }
  }

#endif /* FOR_WIN32 */
#ifdef FOR_BOTH
  else 
#endif /* FOR_BOTH */
#ifdef FOR_WIN32S

  {
    /*
    ** Once again, we use the INGR.INI file if we're running
    ** on Win32s.
    */
      
    /* Define INI key for shared component */
    lstrcpy ( szSubKey, COMPONENT );
      
#ifdef CURRENTVERSION
    lstrcat ( szSubKey, "\\CurrentVersion" );
#else
    /* parse new version number */
    lstrcpy ( szVers, VERSION );
    parseVersion ( szVers, vers );
    sprintf ( szMajMin, "%02d.%02d", vers[0], vers[1] );
    lstrcat ( szSubKey, "\\" );
    lstrcat ( szSubKey, szMajMin );
#endif /* CURRENTVERSION */
    
    if (GetPrivateProfileSection( szSubKey,
       szIniBuf,
     (4*cchMax),
    "INGR.INI" )  == 0 )
    {
      install = 2;
    }
    else
    {
      if ( GetPrivateProfileString( szSubKey,
      "Version",
      "",
      szVersion,
      cchMax,
       "INGR.INI" ) == 0 )
      {
   install = 2;
      }
      else
      {
#ifdef CURRENTVERSION
   /* parse new version number */
   lstrcpy ( szVers, VERSION );
   parseVersion ( szVers, vers );
#endif /* CURRENTVERSION */
       
   /* parse existing version number */
   lstrcpy ( szVers, szVersion );
   parseVersion ( szVers, xvers );
    install = compareVersions ( vers, xvers );
      }
    }
  }
#endif /* FOR_WIN32S */
      
  /* STEP 3    */
  /* If this component is to be installed use, for example:            */
  /*   AddSectionFilesToCopyList("Srock",STF_SRCDIR,IngrSharePath);    */
  /* to select the files to install.                                   */
  
  if ( install > 0 )
  {
    GetSymbolValue("STF_SRCDIR", szSrcDir, cchMax);
    AddSectionFilesToCopyList( COMPONENT, szSrcDir, szShare );
    if (ISDKMatchPlatform (ISm_CHICAGO)) sprintf (TmpString, "WIN95%s", COMPONENT) ;
    else sprintf (TmpString, "NT%s", COMPONENT) ;
    AddSectionFilesToCopyList(TmpString, szSrcDir,szShare);
    sprintf(wrk,"%s,%d:FUNCTION:szSrcDir = \"%s\"",__FILE__,__LINE__,szSrcDir);
    WriteToLogFile(wrk);
    GetSystemDirectory(szWinSysDir, MAX_PATH);
    sprintf(wrk,"%s,%d:FUNCTION:szWinSysDir = \"%s\"",__FILE__,__LINE__,szWinSysDir);
    WriteToLogFile(wrk);
    AddSectionFilesToCopyList( "SYS", szSrcDir, szWinSysDir );
  }
      
    if (install > 0)
    {
      if (!ISDKMatchPlatform (ISm_CHICAGO)) {
        WriteToLogFile ("RIS Tcp Service was removed") ;
        RISRemoveTcpServiceOnly();
      }
    }
  Change_wcSep (0) ;
  sprintf(wrk,"%s,%d:SetupRIS returns %d",__FILE__,__LINE__,install);
  WriteToLogFile(wrk);
  return  install;
} // FUNCTION

   

  /* FUNCTION 2 does:
     STEP 0: Does what the original template STEP 2 did. STEP 2 is commented out.
     If a later version of shared component is installed. It returns. FUNCTION2 does
     the same thing at its STEP 0. Therefore, if a later version of the shared component
     is encountered FUNCTION (SetupRIS) and FUNCTION 2 (RegEdtRIS) leave the (later) shared
     component intact.

     STEP 1:
        if action > 1 - Create Key RefList under RIS\<VERSION>
        if action > 0 - Add Key other information under key RIS\VERSION
                      - Start Service
                      - Add Program Group
        Append or add RefList information
   */
   
void
FUNCTION2 ( int action, CHAR *listEntry )
{
    CHAR szWinDir[cchMax];   /* windows directory      */
    CHAR szWinDrive[2];	       /* windows drive        */
    time_t installTime;
    CHAR szSubKey[cchMax];
    CHAR szTemp[cchMax];
    DWORD dwType;
    CHAR szRefList[cchMaxReg];
    TCHAR RISSharePath[cchMax];
    char maj_min[10] ;
#ifdef FOR_BOTH
  int platform;
#endif /* FOR_BOTH */
  
#ifndef CURRENTVERSION
  CHAR szMajMin[cchMax];   /* Major.Minor version string */
  CHAR szVers[cchMax];
  int vers[4];
#endif /* !CURRENTVERSION */

    sprintf(wrk,"%s,%d:begin FUNCTION2:action = %d, listEntry = \"%s\"",__FILE__,__LINE__,action,listEntry);
    WriteToLogFile(wrk);

    Change_wcSep (1) ;
    /* STEP 0 */
    if (RISShouldInstall(RIS_MAJ_MIN_STR) == FALSE)
        WriteToLogFile("FUNCTION2: No later versions found, ok to install");
    else
    {
	WriteToLogFile("FUNCTION2: A later version was found, do not install");
	sprintf(wrk,"%s,%d:FUNCTION2 returns VOID",__FILE__,__LINE__);
	WriteToLogFile(wrk);
        Change_wcSep (0) ;
	return;
    }

    /* STEP 1 */
  /* Find out what platform we're running on here. */
#ifdef FOR_BOTH
    platform = ISDKGetPlatform();
#endif /* FOR_BOTH */
  
    /* get windows directory & drive */
    GetWindowsDir( szWinDir, cchMax );
    szWinDrive[0] = szWinDir[0];
    szWinDrive[1] = 0;
  
#ifdef FOR_BOTH
    if (platform != IS_WIN32S)
#endif /* FOR_BOTH */
#ifdef FOR_WIN32
    {
        /* Define registry key for shared component */
        lstrcpy ( szSubKey, "SOFTWARE\\Intergraph" );
        lstrcat ( szSubKey, "\\" );
        lstrcat ( szSubKey, COMPONENT );
    
#ifdef CURRENTVERSION
        lstrcat ( szSubKey, "\\CurrentVersion" );
#else
        /* parse new version number */
        lstrcpy ( szVers, VERSION );
        parseVersion ( szVers, vers );
        wsprintf ( szMajMin, "%02d.%02d", vers[0], vers[1] );
        lstrcat ( szSubKey, "\\" );
        lstrcat ( szSubKey, szMajMin );
#endif /* CURRENTVERSION */

        sprintf (wrk, "action is <%d>", action) ;
        WriteToLogFile (wrk) ;
        if ( action > 0)
        {
            if ( action > 1 )
            {
                sprintf (wrk, "Creating Register Key <%s>", szSubKey) ;
                WriteToLogFile (wrk) ;
                CreateRegKeyEx ( HKEY_LOCAL_MACHINE, szSubKey );
                lstrcpy ( szTemp, "" );
                WriteToLogFile ("Creating Register Key Value RefList") ;
                CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
                    szSubKey,
                    "RefList",
                    REG_SZ,
                    szTemp,
                    lstrlen(szTemp) + 1 );
            } // if ( action > 1 )
	
        time(&installTime);
        CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
            szSubKey,
            "InstallDate",
            REG_DWORD,
            (LPBYTE)&installTime,
            sizeof(time_t) );
      
        lstrcpy ( szTemp, "Application" );
        CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
            szSubKey,
            "SoftwareType",
            REG_SZ,
            szTemp,
            lstrlen(szTemp) + 1 );
      
       lstrcpy ( szTemp, DESCRIPTION );
       CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
           szSubKey,
           "Description",
           REG_SZ,
           szTemp,
           lstrlen(szTemp) + 1 );
      
        lstrcpy ( szTemp, RELDATE );
        CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
           szSubKey,
           "RelDate",
           REG_SZ,
           szTemp,
           lstrlen(szTemp) + 1 );
      
        lstrcpy ( szTemp, VERSION );
        CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
            szSubKey,
            "Version",
            REG_SZ,
            szTemp,
            lstrlen(szTemp) + 1 );
      
        lstrcpy ( szTemp, IDNUMBER );
        CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
            szSubKey,
            "IDNumber",
            REG_SZ,
            szTemp,
            lstrlen(szTemp) + 1 );
      
        WriteToLogFile ("Get Intergraph\\Common") ;
        CheckRegIngrCommon(RISSharePath) ;
        AppendSlash (RISSharePath) ;
        strcat (RISSharePath, COMPONENT) ;
        GetMajorMinor (VERSION, maj_min) ;
        strcat (RISSharePath, maj_min) ;
        AppendSlash (RISSharePath) ;
        CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
            szSubKey,
            "PathName",
            REG_SZ,
            RISSharePath,
            lstrlen(RISSharePath) + 1 );
    
        RIS_DoSpecial(RISSharePath);
    } // if ( action > 0)
    /* get RefList value */
    
    if ( GetRegKeyValueEx ( HKEY_LOCAL_MACHINE,
   szSubKey,
   "RefList",
   (LPDWORD)&dwType,
   szRefList,
   cchMaxReg ) != ERROR_SUCCESS )
    {
      lstrcpy ( szRefList, listEntry );
      CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
       szSubKey,
       "RefList",
       REG_SZ,
       szRefList,
       lstrlen(szRefList) + 1 );
    }
    else
    {
      if ( appendToRegValue ( szRefList, listEntry ) != 0 )
      {
           SetRegKeyValueEx ( HKEY_LOCAL_MACHINE,
               szSubKey,
               "RefList",
               dwType,
               szRefList,
               lstrlen(szRefList) + 1 );
      }
    }
  }
#endif /* FOR_WIN32 */
#ifdef FOR_BOTH
  else
#endif /* FOR_BOTH */
#ifdef FOR_WIN32S
  {
    /*
    ** We're installing on Win32s, which doesn't support all of
    ** the registry branches that NT or Win '95 do.
    **
    ** So we must use an INI file instead.  We have chosen
    ** \WINDOWS\INGR.INI as the place that holds all this.
    */
    
    /* Define INI section name for shared component */
    lstrcpy ( szSubKey, COMPONENT );
    
#ifdef CURRENTVERSION
    lstrcat ( szSubKey, "\\CurrentVersion" );
#else
    /* parse new version number */
    lstrcpy ( szVers, VERSION );
    parseVersion ( szVers, vers );
    wsprintf ( szMajMin, "%02d.%02d", vers[0], vers[1] );
    lstrcat ( szSubKey, "\\" );
    lstrcat ( szSubKey, szMajMin );
#endif /* CURRENTVERSION */
    
    if ( action > 0 )
    {
      if ( action > 1 )
      {
   WritePrivateProfileString( szSubKey, 
   "RefList",
     "",
     "INGR.INI");
      } // if ( action > 1 )
    
      time(&installTime);

      wsprintf(szTemp, "%u", installTime);
      WritePrivateProfileString( szSubKey,
   "InstallDate",
   szTemp,
   "INGR.INI");
    
      lstrcpy ( szTemp, "Application" );
      WritePrivateProfileString ( szSubKey,
      "SoftwareType",
      szTemp,
   "INGR.INI" );
    
      lstrcpy ( szTemp, DESCRIPTION );
      WritePrivateProfileString ( szSubKey,
    "Description",
    szTemp,
       "INGR.INI");
    
      lstrcpy ( szTemp, RELDATE );
      WritePrivateProfileString ( szSubKey,
    "RelDate",
    szTemp,
       "INGR.INI");
    
      lstrcpy( szTemp, VERSION);
      WritePrivateProfileString ( szSubKey,
    "Version",
    szTemp,
    "INGR.INI");
    
      lstrcpy ( szTemp, IDNUMBER );
      WritePrivateProfileString ( szSubKey,
    "IDNumber",
    szTemp,
    "INGR.INI");
    
      lstrcpy ( szTemp, szWinDrive );
      lstrcat ( szTemp, ":" );
      lstrcat ( szTemp, PATHNAME );
      lstrcat ( szTemp, "\\") ;
      WritePrivateProfileString ( szSubKey,
    "PathName",
    szTemp,
    "INGR.INI");
    } // if ( action > 0 )
    
    /* get RefList value */
    
    if ( GetPrivateProfileString ( szSubKey,
   "RefList",
     "",
     szRefList,
     cchMaxReg,
     "INGR.INI" ) == 0)
    {
      lstrcpy ( szRefList, listEntry );
      WritePrivateProfileString ( szSubKey,
    "RefList",
    szRefList,
    "INGR.INI");
    }
    else
    {
      if ( appendToRegValue ( szRefList, listEntry ) != 0 )
      {
   WritePrivateProfileString ( szSubKey,
      "RefList",
      szRefList,
      "INGR.INI");
      }
    }
  }
#endif /* FOR_WIN32S */
  Change_wcSep (0) ;
  sprintf(wrk,"%s,%d:FUNCTION2 returns VOID",__FILE__,__LINE__);
  WriteToLogFile(wrk);
  return;
}




static void RISCreateProgMan(LPTSTR szInstallPath)
{
    TCHAR   cmd[255];
    TCHAR   other[255];
    int     platform;
    int     i ;
    char    TmpDir [cchMax] ;
    char    szShare [cchMax];
    
#define NumberOfExecutables  5
#define NumberOfRunExecutables  7 
#define NumberOf95Exec          11 //12 // 1996.08.09:Alan Barksdale:TR439601698:The manifest.txt file indicates that risupgrd is not delivered on Win95.
    
    char *Executables [NumberOfExecutables] = {
                            "RISINTOP.EXE",
                            "RISUPGRD.EXE",
                            "RISGUI.EXE",
                            "RISMGR.EXE",
                            "RISBATCH.EXE"} ;
                            
    char *Description1 [NumberOfExecutables] = {
                            "Configure RIS Version",
                            "Upgrade RIS",
                            "RIS Interactive",
                            "RIS Schema Manager",
                            "RIS Batch" } ;
    
    char *RunExecutables[NumberOfRunExecutables] = {
                            "RISLOD.EXE",
                            "RISUNLOD.EXE",
                            "RISRECRD.EXE",
                            "RISPLBCK.EXE",
                            "RISCLNSR.EXE",
                            "RISDCODE.EXE",
                            "RISDTYPE.EXE" } ;
                            
    char *RunKeyword [NumberOfRunExecutables] = {
                            "LOD",
                            "UNLOD",
                            "RECRD",
                            "PLBCK",
                            "CLNSR",
                            "DCODE",
                            "DTYPE"} ;                            
                            
    char *Description2 [NumberOfRunExecutables] = {
                            "RIS Loader",
                            "RIS Unloader",
                            "RIS Record",
                            "RIS Playback",
                            "RIS Clean Server",
                            "RIS Decode",
                            "RIS Data Types" } ;


    char *Win95Exec [NumberOf95Exec] = { "RISINTOP.EXE",
//                            "RISUPGRD.EXE", // 1996.08.09:Alan Barksdale:TR439601698:The manifest.txt file indicates that risupgrd is not delivered on Win95.
                            "RISGUI.EXE",
                            "RISMGR.EXE",
                            "RISBATCH.EXE",
                            "RISLOD.EXE",
                            "RISUNLOD.EXE",
                            "RISRECRD.EXE",
                            "RISPLBCK.EXE",
                            "RISCLNSR.EXE",
                            "RISDCODE.EXE",
                            "RISDTYPE.EXE" } ;
                            

    char *Win95Desc [NumberOf95Exec] = {
                            "Configure RIS Version",
//                            "Upgrade RIS", // 1996.08.09:Alan Barksdale:TR439601698:The manifest.txt file indicates that risupgrd is not delivered on Win95.
                            "RIS Interactive",
                            "RIS Schema Manager",
                            "RIS Batch",
                            "RIS Loader",
                            "RIS Unloader",
                            "RIS Record",
                            "RIS Playback",
                            "RIS Clean Server",
                            "RIS Decode",
                            "RIS Data Types" } ;
                        
    char *Win95Icon [NumberOf95Exec] = {
                            "",
//                            "12", // 1996.08.09:Alan Barksdale:TR439601698:The manifest.txt file indicates that risupgrd is not delivered on Win95.
                            "",
                            "",
                            "1",
                            "6",
                            "10",
                            "9",
                            "8",
                            "2",
                            "3",
                            "4" } ;


/* place holder */
    CheckRegIngrCommon(szShare);
           
    strcpy (TmpDir, szInstallPath) ;                            
    AppendSlash (szInstallPath) ;
    
    platform = ISDKGetPlatform();

    WriteToLogFile("Create Program Items for Share Component");
    CreateProgmanGroup(RISPROGGROUP, "", cmoNone);


    sprintf(cmd, "%sREADME.TXT", szInstallPath);
    ISTPProgmanItem(RISPROGGROUP, TRUE, "README.TXT", cmd, "",cmoOverwrite, NULL);

    if ( platform == IS_CHICAGO )
    {
        WriteToLogFile ("Win95 detected.") ;
            sprintf(cmd, "%sCONFIG\\ENGLISH\\HELP\\RISSQL.HLP",szInstallPath);
            ISTPProgmanItem(RISPROGGROUP,TRUE, "RIS SQL Reference", cmd, "", cmoOverwrite, NULL);

  	    sprintf(cmd, "%sCONFIG\\ENGLISH\\HELP\\RISUTL.HLP",szInstallPath);
            ISTPProgmanItem(RISPROGGROUP, TRUE, "RIS Utilities Reference", cmd, "", cmoOverwrite, NULL);

            
            for (i=0; i<NumberOf95Exec ; i++)
	    {
                sprintf(cmd, "%sBIN\\%s", szInstallPath, Win95Exec[i]);
                if (strcmp (Win95Icon[i], ""))
                    sprintf(other, "%sLIB\\RISICON.DLL,%s", szInstallPath, Win95Icon[i]);
                else strcpy (other, "") ;
                sprintf (wrk, "other <%s> : cmd <%s>", other, cmd) ;
                WriteToLogFile (wrk) ;
                ISTPProgmanItem (RISPROGGROUP, TRUE, Win95Desc[i], cmd, other,cmoOverwrite, NULL);
                ISTPRegisterAppPath (cmd) ;
                ISTPAddRegisterAppPath (cmd, szShare);
            }
    }
    else //WINNT
    {
        WriteToLogFile ("NT was detected.") ;
            {
                LPTSTR args[2];
                
                args[0] = cmd ;
                args[1] = NULL;
  	        sprintf(cmd, "%sCONFIG\\ENGLISH\\HELP\\RISSQL.HLP",szInstallPath);
  	    
	        ISTPProgmanItem(RISPROGGROUP, TRUE, "RIS SQL Reference", "WINHLP32.EXE", "", cmoOverwrite, args);

     	        sprintf(cmd, "%sCONFIG\\ENGLISH\\HELP\\RISUTL.HLP",szInstallPath);
	        ISTPProgmanItem(RISPROGGROUP, TRUE, "RIS Utilities Reference", "WINHLP32.EXE", "", cmoOverwrite, args);
	    }

            for (i=0; i<NumberOfExecutables; i++)
            {	   
                sprintf (cmd, "%sBIN\\%s", szInstallPath, Executables[i]) ;
                ISTPProgmanItem (RISPROGGROUP, TRUE, Description1[i], cmd,
                             "", cmoOverwrite, NULL);
                if ( ISDKMatchPlatform (ISm_NT40) ) {
                    sprintf (wrk, "adding <%s> to AppPath (Share path appended).", cmd) ;
                    WriteToLogFile (wrk) ;
                    ISTPRegisterAppPath (cmd) ;
                    ISTPAddRegisterAppPath (cmd, szShare);
                }
            }
           
            {
                LPTSTR args[2];
              
                for (i=0; i<NumberOfRunExecutables; i++)
                {
                    sprintf (cmd, "%sBIN\\RISRUN.EXE", szInstallPath) ;
                    sprintf (other,"%sBIN\\%s", szInstallPath, RunExecutables[i]) ;
                    args[0] = RunKeyword[i];
                    args[1] = NULL;
                    WriteToLogFile (other) ;
                    ISTPProgmanItem (RISPROGGROUP, TRUE, Description2[i], cmd,
                             other, cmoOverwrite, args);
                    if ( ISDKMatchPlatform (ISm_NT40) ) {
                        ISTPRegisterAppPath (other) ;
                        ISTPAddRegisterAppPath (other, szShare);
                        sprintf (wrk, "adding <%s> to AppPath (Share path appended).", cmd) ;
                        WriteToLogFile (wrk) ;
                    }
                }
            }
	}
        if ( ISDKMatchPlatform (ISm_NT40) ) {
            ISTPRegisterAppPath (SzCatStr (szInstallPath, "BIN\\RISRUN.EXE" )) ;
            sprintf (wrk, "adding <%s> to AppPath (Share path appended).", cmd) ;
            WriteToLogFile (wrk) ;
        }
	strcpy (szInstallPath, TmpDir) ;
}


static int RIS_DoSpecial(
	char *RISSharePath)
{
    auto int iReturnValue = RMT_SUCCESS;

    if (!ISDKMatchPlatform (ISm_CHICAGO)) {    
        if ((iReturnValue = RISInstallTcpService()) != RMT_SUCCESS)
            WriteToLogFile ("Unable to install RIS Tcp Service") ;
        else
            WriteToLogFile ("RIS Tcp Service was installed successfully.") ;
    }
    sprintf (wrk, "Creating RISCreateProgMan for Shared Path <%s>", RISSharePath) ;
    WriteToLogFile (wrk) ;
    RISCreateProgMan(RISSharePath);

    return(iReturnValue);
}

//
// RISShouldInstall - returns TRUE if a later Runtime product installed
//

static BOOL RISShouldInstall(char *currver)
{
	HKEY	hKey2;
	LONG	lRetVal;
	DWORD	cchClass, dwNumSubKeys, cchMaxSubKey, cchMaxClass,
		cValues, cchMaxValName, cbMaxValData, cbSecurityDescriptor;
	LONG	lResult;
	TCHAR	szClass[128];
	FILETIME ftLastWrite;
	DWORD	i;
	TCHAR	szSubKey[MAX_PATH+1];
	DWORD	SubKeySz;
	int cv,cv1,cv2;
	int tmp;
	char wrk[255];

	sscanf(currver,"%d.%d",&cv1,&cv2);
	cv = cv1*100 + cv2;

	if (lRetVal = RegOpenKeyEx(HKEY_LOCAL_MACHINE, "SOFTWARE\\Intergraph\\RIS", 0, KEY_READ, &hKey2) != ERROR_SUCCESS)
	{
	    WriteToLogFile ("Unable to open key SOFTWARE\\Intergraph\\RIS") ;
            return(FALSE);
	}

	cchClass=128;
	if ((lResult = RegQueryInfoKey(hKey2, szClass, &cchClass,
		NULL, &dwNumSubKeys, &cchMaxSubKey, &cchMaxClass,
		&cValues, &cchMaxValName, &cbMaxValData,
		&cbSecurityDescriptor, &ftLastWrite)) != ERROR_SUCCESS)
	{
	    WriteToLogFile ("Unable to get information for key SOFTWARE\\Intergraph\\RIS") ;
            RegCloseKey(hKey2);
	    return(FALSE);
	}

	if (dwNumSubKeys)
	{

		for (i = 0; i < dwNumSubKeys; i++)
		{
			szSubKey[0] = '\0';
			SubKeySz = MAX_PATH + 1;
			if ((lResult = RegEnumKeyEx(hKey2, i, szSubKey, &SubKeySz,
				0, NULL, NULL, &ftLastWrite)) == ERROR_SUCCESS)
			{
				sscanf(szSubKey,"%d.%d",&cv1,&cv2);
				tmp = cv1*100 + cv2;
				if (tmp > cv)
				{
					sprintf (wrk,"A later version %d already installed, trying to install version %d, do not install",tmp,cv);
					WriteToLogFile(wrk);
                                        RegCloseKey(hKey2);
					return(TRUE);
				}
			}
		} /* for */
	}	/* if */
        RegCloseKey(hKey2);
	return (FALSE);
}




void GetRISVersion(szMajMin)
    char *szMajMin ;
{
    CHAR szVers [cchMax] ;
    int vers[4] ;
    
    /* parse new version number */
    lstrcpy ( szVers, VERSION );
    parseVersion ( szVers, vers );
    wsprintf ( szMajMin, "%02d.%02d", vers[0], vers[1] );
}



void GetMajorMinor(
   CHAR *version,
   CHAR *maj_min)
{
    WCHAR *WString ;
    CHAR *SString ;
    int found_first ;
    int len ;
    int i ;
    
    WString = ISDKGetWideString (version) ;
    found_first = 0 ;
    len = wcslen (WString) ;
    for (i=0; i<(INT) len; i++)
    {
        if (found_first && (WString[i] == '.')) {
            WString[i] = '\0' ;
            break ;
        }
        if (WString[i] == '.') found_first = 1 ;
    }
    SString = ISDKGetMultiString (WString) ;
    strcpy (maj_min, SString) ;
    free (SString) ;
    free (WString) ;    
} 

/************************************************************************
  Configuration Instructions:

  The symbol COMPONENT is the name of your shared component.  It will
  be used to generate the registry key for your component.  It will
  also be used as an argument to "AddSectionFilesToCopyList()".  So
  you should also use this name with the "SECTION=" keyword in your
  layout file fragment.

  The symbol IDNUMBER contains the text that will appear in the
  registry as the "IDNumber" value.  By default it will have the
  text "N/A" as the D&L Cookbook specifies.

  The symbol PATHNAME contains the text that will appear in the
  registy as the "PathName" value.  By default it contains the
  text "\win32app\ingr\share" as the D&L Cookbooks specifies for
  shared components having only DLLs.  Otherwise it should 
  contain the subdirectory for your shared components files.
  (ie: "\win32app\ingr\share\foobar").

  The symbol RELDATE is the release date of your shared component.  It
  will appear in the registry as the "RelDate" value.

  The symbol VERSION is the version number of your shared component.
  It should be in the form M.m.f.b where M is the major version
  number, m is the minor version number, f is the bugfix number and
  b is the build number.  The first two fields are mandatory.
  This string will appear in the registry as the "Version" value.
  If the symbol CURRENTVERSION (see below) is not defined, the
  version number will also be used to generate the registry key
  for your shared component.

  The symbol DESCRIPTION will appear in the registry as the "Description"
  value.

  The symbol FUNCTION is the name of the setup function that will be
  called by container applications to AddFilesToCopyList for your component.
  Care must be taken to ensure that this is a unique name.  I suggest:
    Setup<COMPONENT> for the function name.

  int FUNCTION ( VOID );
  return is -1 if component was not installed because of error or
    because a later version already exists in the host
  return is 0 if component will not be installed because
    the local host was up to date
  return is 1 if component will be because
    the local host was not up to date
  return is 2 if component will be installed because
    the component was new to the local host

  The symbol FUNCTION2 is the name of the setup function that will be
  called by container applications to edit the registry for your component.
  Care must be taken to ensure that this is a unique name.  I suggest:
    RegEdt<COMPONENT> for the function name.

  void FUNCTION2 ( int action, CHAR *listEntry )

  listEntry is the RefList component that represents the calling application
    It should be constructed from the registry key for the application without
    the leading string "HKEY_LOCAL_MACHINE\\SOFTWARE\\Intergraph\\".  That is,
    it should be comprised of the <appName>\\[CurrentVersion|<MM.mm>].
  action is the return value from FUNCTION.
    if action is 2 
      - a new registry key will be created for COMPONENT,
      - registry values will be updated with the id of the 
   COMPONENT (version, description, release date, &etc)
      - RefList will be updated to include listEntry
    if action is 1
      - registry values will be updated with the id of the 
   COMPONENT (version, description, release date, &etc)
      - RefList will be updated to include listEntry
    if action is 0
      - RefList will be updated to include listEntry

  The symbol CURRENTVERSION, if set, will cause the registry entry for
  the shared component to be placed under the key:
    HKEY_LOCAL_MACHINE\SOFTWARE\Intergraph\<COMPONENT>\CurrentVersion
  If the symbol CURRENTVERSION is not set then the version field of
  the key will be the major version number followed by the minor 
  version number separated by a period:
    HKEY_LOCAL_MACHINE\SOFTWARE\Intergraph\<COMPONENT>\<MAJOR>.<MINOR>
  Do not define CURRENTVERSION if several versions of your shared
  component will be installed simultaneously.  Define CURRENTVERSION
  if newer versions of your shared component should always supercede
  older versions.  CURRENTVERSION is defined by default.

  The symbol FOR_WIN32, if set, will cause code to be generated to access
  the NT registry.  The symbol FOR_WIN32S, if set, will cause code to be
  generated to modify the INGR.INI file where appropriate.  If both are
  set then the code will sense the target environment and "do the right
  thing".

  If neither FOR_WIN32 nor FOR_WIN32S are defined in the make
  environment then both will be set automatically; if either one or both
  are defined in the make environement then those settings will be honored.
  So, if your product will be delivered only to NT & WINDOWS95 machines,
  set FOR_WIN32.  If your product will be delivered only to DOS/WINDOWS
  machines with WIN32S, then set FOR_WIN32S.  If your product will run in
  either environment, set both or neither.

************************************************************************/

#include "msshared.h"
#include "ingrext.h"

/* function to compare M.m.f.b fields of two separate version arrays   */
/* It will return 1 if the first version # array is greater than or    */
/* equal to the second.        */
/* ie: the first arg represents the available product number, the      */
/* second arg represents the installed version number. If the return   */
/* is 1 then the available product should be installed		       */
/* modified from function in msdfunc.c                                 */

static int compareVersions ( int vers[4], int xvers[4] )
{
  int install=1;
  int index;
   char wrk[80];


  /* is vers greater than xvers? */
  for ( index = 0; index < 4; index++ )
  {
    sprintf(wrk,"index = %d ver=%d xver = %d",index,vers[index],xvers[index]);
    WriteToLogFile(wrk );
    if ( xvers[index] > vers[index] )
    {
        install = 0;
        WriteToLogFile("xvers > vers" );
        break;
    }
    else if ( vers[index] > xvers[index] )
    {
        break;
    }
  }
    sprintf(wrk,"CompareVersion: returned install = %d : 0 - older version exists, 1 - any other",install);
    WriteToLogFile(wrk );
    return install;
}

extern void  Change_wcSep (flag)
    int flag ;   /* 0 - reset to its original value ; 1 - set to backward-slash */
{
    if (flag) {
        /* set to backward-slash */
        Tmp_wcSep = wcSep ;
        wcSep = L'\\' ;
    } else {
        wcSep = Tmp_wcSep ;
    }
    sprintf (wrk, "wcSep set to <%x>", wcSep) ;
    WriteToLogFile (wrk) ;   
}

