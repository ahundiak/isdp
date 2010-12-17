// 1996.04.23:Alan Barksdale:This file contains functions used for the RIS
//	TCP/IP service by both installation and remove code.

#include <stdio.h>
#include <windows.h>
#include "ingrbld.h" // for cchMax
#include "reglib.h"
#include "srvctl.h" // for InstallService
#include "isdk.h"
#include "ingrreg.h"
#if defined(REMOVAL_VERSION)
#	include "risrem.h"
#else
#	include "setupapi.h"
#	include "msregdb.h"
#	include "ingrbld.h"
#endif
#include "rmdefs.h" // for RMT_FAILURE and RMT_SUCCESS

#include "risver.h"
#include "rissrvc.h"
#include "risdebug.h" // for STRING()

#define RIS_REMOVE_SERVICE      0
#define RIS_INSTALL_SERVICE     1
#define RIS_REMOVE_SERVICE_ONLY 3

#define RIS_TCPSR_SERVICE			"RIStcpsrService"
#define RIS_TCPSR_SERVICE_EXECUTABLE_PATH	"\\BIN\\RISTCPSR.EXE"

static char wrk[cchMax];

static BOOLEAN GetServiceExecutableAndWhetherNeedToInstallNewerVersion(
	CHAR *cur_path);
static int GetTcpServicePath(TCHAR *szRIStcp_path);
static LONG InstallServiceWithQuotedPath(SC_HANDLE schSCManager,
	LPCTSTR serviceName, LPCTSTR serviceExe, DWORD startUpType);
static DWORD RemoveServiceAndWaitForCompletion(SC_HANDLE schSCManager,
	LPTSTR service_name);
static int RISService(LPTSTR service_path, LPTSTR service_name, INT flag);
static VOID WriteToLog(LPSTR szFileName, int iLineNumber, LPSTR szStr);

// 1996.05.01:Alan Barksdale:Added at Melania Stewart's request.
static VOID WriteToLog(
	LPSTR szFileName,
	int iLineNumber,
	LPSTR szStr)
{
#	if defined(REMOVAL_VERSION)
		WriteToRemoveLogFile(szFileName, iLineNumber, szStr);
#	else
		char szOutput[cchMax];

		sprintf(szOutput, "%s,%d:%s", szFileName, iLineNumber, szStr);
		WriteToLogFile(szOutput);
#	endif
}

// 1996.04.23:Alan Barksdale:Modified this function provided by Melania Stewart
//	so that it could be used for both installation and removal without
//	adding another library requirement for risrem.lib.  Apparently, a
//	return value of TRUE means that the function created a new key, and
//	FALSE means it didn't.
extern BOOL CheckRegIngrCommon(IngrSharePath)
    char *IngrSharePath ;
{
#if !defined(REMOVAL_VERSION)
    DWORD dwType;
#endif // #if !defined(REMOVAL_VERSION)
    CHAR szWinDrive[cchMax]; /* Windows drive */

    WriteToLog(__FILE__, __LINE__, "Starting CheckRegIngrCommon");
    
    /* check/create "SOFTWARE\Intergraph" key in registry */
#if defined(REMOVAL_VERSION) // assuming INTERGRAPH_KEY\COMMON_VALUE present
    GetWindowsDirectory(szWinDrive, cchMax); // so users of risrem.lib won't have to link with additonal libraries
#else
    GetWindowsDir(szWinDrive, cchMax);
#endif
    szWinDrive[1] = '\0';

#if defined(REMOVAL_VERSION) // assuming INTERGRAPH_KEY\COMMON_VALUE present
    if (ISDKMatchPlatform (ISm_DAYTONA)) {
        sprintf ( IngrSharePath, "%s:%s\\", szWinDrive, INGR_SHARE_DIR) ;
    } else {
        RGQueryRegStringValue (INTERGRAPH_KEY, COMMON_VALUE, IngrSharePath);
  	lstrcat(IngrSharePath, "\\");
    }
    WriteToLog(__FILE__, __LINE__, "CheckRegIngrCommon returns FALSE");
    return FALSE ;
#else
    if ( ! DoesRegKeyExistEx ( HKEY_LOCAL_MACHINE, INTERGRAPH_KEY ) )
    {
        CreateRegKeyEx ( HKEY_LOCAL_MACHINE, INTERGRAPH_KEY );
    }
    else
    {
        if ( GetRegKeyValueEx ( HKEY_LOCAL_MACHINE,
            INTERGRAPH_KEY,
            COMMON_VALUE,
            (LPDWORD)&dwType,
            IngrSharePath,
            cchMaxReg ) == ERROR_SUCCESS ) {
                AppendSlash (IngrSharePath) ;
                if (ISDKMatchPlatform (ISm_DAYTONA)) {
                    sprintf ( IngrSharePath, "%s:%s\\", szWinDrive, INGR_SHARE_DIR) ;
                    WriteToLog(__FILE__, __LINE__,
                        "CheckRegIngrCommon returns FALSE");
                    return FALSE ;
                }
                if (FValidDir (IngrSharePath))
                {
                    WriteToLog(__FILE__, __LINE__,
                        "CheckRegIngrCommon returns FALSE");
                    return FALSE ;
                }
            } 
    }
    
    sprintf (IngrSharePath, "%s:", szWinDrive) ;
    if (ISDKMatchPlatform (ISm_DAYTONA)) 
        lstrcat ( IngrSharePath, INGR_SHARE_DIR );
    else lstrcat ( IngrSharePath, PH2_INGR_SHARE_DIR );
    AppendSlash (IngrSharePath) ;
    CreateRegKeyValueEx ( HKEY_LOCAL_MACHINE,
        INTERGRAPH_KEY,
        COMMON_VALUE,
        REG_SZ,
        IngrSharePath,
        lstrlen(IngrSharePath) + 1 );

    WriteToLog(__FILE__, __LINE__, "CheckRegIngrCommon returns TRUE");
    return TRUE ;
#endif // else not defined(REMOVAL_VERSION)
}

// Alan Barksdale:Slightly modified this function.
static BOOLEAN GetServiceExecutableAndWhetherNeedToInstallNewerVersion(
   CHAR *cur_path)
{
   TCHAR	prod_version[20];
   CHAR		szKey[MAX_PATH + 1];
   TCHAR	szFullSubKey[MAX_PATH + 1];
   TCHAR	szSubKey[MAX_PATH + 1];
   CHAR		latest_path[MAX_PATH + 1];
   CHAR		prod_dir[MAX_PATH + 1];
   LONG		lResult;
   auto HKEY	hKey = NULL;
   TCHAR	szClass[128];
   DWORD	cchClass, dwNumSubKeys, cchMaxSubKey, cchMaxClass,
		cValues, cchMaxValName, cbMaxValData, cbSecurityDescriptor,
		i, SubKeySz;
   FILETIME	ftLastWrite;
   int		prod_maj, x_maj=0;
   int		prod_min, x_min=0;
   int		prod_rel, x_rel=0;
   int		prod_seq, x_seq=0;
   int		vscount, max_vscount, x_vscount;
   BOOLEAN	changed = FALSE;

   WriteToLog(__FILE__, __LINE__,
      "Starting GetServiceExecutableAndWhetherNeedToInstallNewerVersion");

   sscanf(RIS_VERSION_STR, "%d.%d.%d.%d", &prod_maj, &prod_min, &prod_rel,
      &prod_seq);
   vscount = prod_maj*1000 + prod_min*100 + prod_rel*10 + prod_seq;
   max_vscount = vscount;
   lstrcpy(latest_path, cur_path);

   strcpy(szKey, "SOFTWARE\\Intergraph\\RIS");
   if ((lResult = RegOpenKeyEx(HKEY_LOCAL_MACHINE, szKey, 0, KEY_READ,
		  &hKey)) != ERROR_SUCCESS)
   {
      sprintf(wrk,
         "GetServiceExecutableAndWhetherNeedToInstallNewerVersion returns %d",
         changed);
      WriteToLog(__FILE__, __LINE__, wrk);
      return changed;
   }

   cchClass=128;
   if ((lResult = RegQueryInfoKey(hKey, szClass, &cchClass,
		  NULL, &dwNumSubKeys, &cchMaxSubKey, &cchMaxClass,
		  &cValues, &cchMaxValName, &cbMaxValData,
		  &cbSecurityDescriptor, &ftLastWrite)) != ERROR_SUCCESS)
   {
      sprintf(wrk,
         "GetServiceExecutableAndWhetherNeedToInstallNewerVersion returns %d",
         changed);
      WriteToLog(__FILE__, __LINE__, wrk);
      return changed;
   }

   if (dwNumSubKeys)
   {
      for (i = 0; i < dwNumSubKeys; i++)
      {
	 SubKeySz = MAX_PATH+1;
	 if ((lResult = RegEnumKeyEx(hKey, i, szSubKey, &SubKeySz,
	    0, NULL, NULL, &ftLastWrite)) == ERROR_SUCCESS)
	 {
	    sprintf(szFullSubKey, "%s\\%s", szKey, szSubKey);
	    if(RGQueryRegStringValue(szFullSubKey,"Version",prod_version))
	    {
	       continue;
	    }

	    sscanf( prod_version, "%d.%d.%d.%d", &x_maj, &x_min, &x_rel,
	       &x_seq);
	    x_vscount = x_maj*1000 + x_min*100 + x_rel*10 + x_seq;

	    if(RGQueryRegStringValue(szFullSubKey,"PathName",prod_dir))
	    {
	       continue;
	    }

	    if (x_vscount > max_vscount)
	    {
	       lstrcpy(latest_path, prod_dir);
	       lstrcat(latest_path, RIS_TCPSR_SERVICE_EXECUTABLE_PATH);
	       max_vscount = x_vscount;
	       changed = TRUE;
	    }
	 } /* if */
      } /* for */
   } /* if (dwNumSubKeys) */
   lstrcpy(cur_path, latest_path);

   if(hKey) {
      RegCloseKey(hKey);
   }

   sprintf(wrk,
      "GetServiceExecutableAndWhetherNeedToInstallNewerVersion returns %d",
      changed);
   WriteToLog(__FILE__, __LINE__, wrk);
   return changed;
} // GetServiceExecutableAndWhetherNeedToInstallNewerVersion

// 1996.04.03:TR439600764:Alan Barksdale:created because occasionally
//	InstallService would fail because the service was still marked as
//	deleted
static DWORD RemoveServiceAndWaitForCompletion(
	SC_HANDLE schSCManager,
	LPTSTR service_name)
{
	auto DWORD dwReturnValue = NO_ERROR;
	auto DWORD dwLastError = NO_ERROR;
	auto SC_HANDLE schService = NULL;
	SERVICE_STATUS ssServiceStatus;
	auto DWORD dwOldCheckPoint = 0;

	WriteToLog(__FILE__, __LINE__,
		"Starting RemoveServiceAndWaitForCompletion");

	if(NULL == (schService = OpenService(schSCManager, service_name,
		SERVICE_ALL_ACCESS))) {
		dwLastError = GetLastError();
		sprintf(wrk,
			"RemoveServiceAndWaitForCompletion:OpenService dwLastError = %lu",
			dwLastError);
                WriteToLog(__FILE__, __LINE__, wrk);
		if(ERROR_SERVICE_DOES_NOT_EXIST != dwLastError) {
			dwReturnValue = dwLastError;
		}
		return(dwReturnValue);
	} else {
   		WriteToLog(__FILE__, __LINE__,
			"RemoveServiceAndWaitForCompletion:good OpenService call");
	}

	if(FALSE == ControlService(schService,
		SERVICE_CONTROL_STOP, &ssServiceStatus)) {
		dwLastError = GetLastError();
		sprintf(wrk,
			"RemoveServiceAndWaitForCompletion:ControlService dwLastError = %lu",
			dwLastError);
                WriteToLog(__FILE__, __LINE__, wrk);
		if(ERROR_SERVICE_DOES_NOT_EXIST != dwLastError &&
			ERROR_SERVICE_NOT_ACTIVE != dwLastError) {
			dwReturnValue = dwLastError;
		}
	} else {
		sprintf(wrk,
			"RemoveServiceAndWaitForCompletion:ControlService's dwControlsAccepted = %#x, dwWaitHint = %ld, dwCheckPoint = %ld",
			ssServiceStatus.dwControlsAccepted,
			ssServiceStatus.dwWaitHint,
			ssServiceStatus.dwCheckPoint);
   		WriteToLog(__FILE__, __LINE__, wrk);

		while(ssServiceStatus.dwWaitHint > 0) {
			dwOldCheckPoint = ssServiceStatus.dwCheckPoint;
			Sleep(ssServiceStatus.dwWaitHint);
			if(FALSE == ControlService(schService,
				SERVICE_CONTROL_INTERROGATE,
				&ssServiceStatus)) {
				dwLastError = GetLastError();
				sprintf(wrk,
					"RemoveServiceAndWaitForCompletion:ControlService dwLastError = %lu",
					dwLastError);
   				WriteToLog(__FILE__, __LINE__, wrk);
				if(ERROR_SERVICE_DOES_NOT_EXIST != dwLastError
					&& ERROR_SERVICE_NOT_ACTIVE !=
					dwLastError) {
					dwReturnValue = dwLastError;
				}
				break;
			} else if(ssServiceStatus.dwCheckPoint <=
				dwOldCheckPoint) {
				sprintf(wrk,
					"RemoveServiceAndWaitForCompletion:ControlService's dwControlsAccepted = %#x, dwWaitHint = %ld, dwCheckPoint = %ld",
					ssServiceStatus.dwControlsAccepted,
					ssServiceStatus.dwWaitHint,
					ssServiceStatus.dwCheckPoint);
   				WriteToLog(__FILE__, __LINE__, wrk);
				break;
			} else {
				sprintf(wrk,
					"RemoveServiceAndWaitForCompletion:ControlService's dwControlsAccepted = %#x, dwWaitHint = %ld, dwCheckPoint = %ld",
					ssServiceStatus.dwControlsAccepted,
					ssServiceStatus.dwWaitHint,
					ssServiceStatus.dwCheckPoint);
   				WriteToLog(__FILE__, __LINE__, wrk);
			}
		} // while
	} // else good ControlService call

	if(FALSE == DeleteService(schService)) {
		dwLastError = GetLastError();
		sprintf(wrk,
			"RemoveServiceAndWaitForCompletion:DeleteService dwLastError = %lu",
			dwLastError);
   		WriteToLog(__FILE__, __LINE__, wrk);
		if(ERROR_SERVICE_DOES_NOT_EXIST != dwLastError) {
			dwReturnValue = dwLastError;
		}
	} else {
   		WriteToLog(__FILE__, __LINE__,
			"RemoveServiceAndWaitForCompletion:good DeleteService call");
	}

	if(FALSE == CloseServiceHandle(schService)) {
		dwLastError = GetLastError();
		sprintf(wrk,
			"RemoveServiceAndWaitForCompletion:CloseServiceHandle dwLastError = %lu",
			dwLastError);
   		WriteToLog(__FILE__, __LINE__, wrk);
		if(ERROR_SERVICE_DOES_NOT_EXIST != dwLastError) {
			dwReturnValue = dwLastError;
		}
	} else {
   		WriteToLog(__FILE__, __LINE__, "RemoveServiceAndWaitForCompletion:good CloseServiceHandle call");
	}

	sprintf(wrk, "RemoveServiceAndWaitForCompletion returns %lu",
		dwReturnValue);
   	WriteToLog(__FILE__, __LINE__, wrk);
	return(dwReturnValue);
} // RemoveServiceAndWaitForCompletion


/*****************************************************************************

    SYNOPSIS 

        LONG InstallServiceWithQuotedPath
        (
            SC_HANDLE schSCManager,
            LPCTSTR serviceName, 
            LPCTSTR serviceExe, 
            DWORD startUpType
        )
        
    PARAMETERS

        NAME            ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----            --------------------------------------------------------

        schSCManager    (I)     Handle of service control manager database
        serviceName     (I)     Address of name of service to start
        serviceExe      (I)     Path to a binary file
        startUpType     (I)     When to start the service
        
    RETURN VALUE

        RMT_SUCCESS   0
        RMT_FAILURE   1
        
    DESCRIPTION

        The function creates a service object and adds it to the specified
        service control manager database.  It encloses the path of the service
	with quotes if the path contains space characters.
        
    CHANGE HISTORY

        1996.07.22	afb	Created using the outside of InstallService
				from the Setup SDK 2.3.1 remove\srvctl.c
				because on some machines, the RIS TCP service
				would not start if its registry value for
				HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RIStcpsrService\ImagePath
				surrounded by quotes.  (TR439601599)  (Alan
				Barksdale)

******************************************************************************/

static LONG InstallServiceWithQuotedPath
(
    SC_HANDLE schSCManager,
    LPCTSTR serviceName, 
    LPCTSTR serviceExe, 
    DWORD startUpType
)
{
	LPSTR	szQuotedServiceExe = NULL;
	LONG	status = RMT_SUCCESS;
    
	WriteToLog(__FILE__, __LINE__, "Starting InstallServiceWithQuotedPath");

	if(szQuotedServiceExe = ISDKQuoteString(serviceExe)) {
		status = InstallService(schSCManager, serviceName,
			szQuotedServiceExe, startUpType);
		ISDKFREE(szQuotedServiceExe);
	} else {
		status = RMT_FAILURE;
	}
    
	sprintf(wrk, "InstallServiceWithQuotedPath returns %d", status);
   	WriteToLog(__FILE__, __LINE__, wrk);
	return(status);
} // InstallServiceWithQuotedPath


static int RISService(
	LPTSTR service_path,
	LPTSTR service_name,
	INT flag)
{
	auto DWORD iReturnValue = RMT_SUCCESS;
	SC_HANDLE schSCManager;

	WriteToLog(__FILE__, __LINE__, "Starting RISService");
	sprintf(wrk,
		"RISService:service_path = <%s>, service_name = <%s>, flag = %d",
		STRING(service_path), STRING(service_name), flag);
   	WriteToLog(__FILE__, __LINE__, wrk);

	if(NULL == (schSCManager = OpenSCManager(
		NULL,	// machine (NULL == local)
		NULL,	// database (NULL == default)
		SC_MANAGER_ALL_ACCESS	// access required
	))) {
		sprintf(wrk, "RISService:OpenSCManager GetLastError = %lu",
			GetLastError());
   		WriteToLog(__FILE__, __LINE__, wrk);
		iReturnValue = RMT_FAILURE;
		sprintf(wrk, "RISService returns %d", iReturnValue);
   		WriteToLog(__FILE__, __LINE__, wrk);
		return(iReturnValue);
	}

	if(flag == RIS_REMOVE_SERVICE) {
		if(NO_ERROR == RemoveServiceAndWaitForCompletion(schSCManager,
			service_name)) {
			if(GetServiceExecutableAndWhetherNeedToInstallNewerVersion(
				service_path)) {
				sprintf(wrk,
					"RISService:about to call InstallServiceWithQuotedPath(%#x, <%s>, <%s>, %#x)",
					schSCManager, service_name,
					service_path, SERVICE_AUTO_START);
   				WriteToLog(__FILE__, __LINE__, wrk);
				iReturnValue = InstallServiceWithQuotedPath(schSCManager,
					service_name, service_path, SERVICE_AUTO_START);
			}
		} else {
			iReturnValue = RMT_FAILURE;
		}
	} else if (flag == RIS_INSTALL_SERVICE) {
		if(NO_ERROR == RemoveServiceAndWaitForCompletion(schSCManager,
			service_name)) {
			GetServiceExecutableAndWhetherNeedToInstallNewerVersion(
				service_path);
			sprintf(wrk,
				"RISService:about to call InstallServiceWithQuotedPath(%#x, <%s>, <%s>, %#x)",
				schSCManager, service_name, service_path,
				SERVICE_AUTO_START);
   			WriteToLog(__FILE__, __LINE__, wrk);
			iReturnValue = InstallServiceWithQuotedPath(schSCManager,
				service_name, service_path, SERVICE_AUTO_START);
		} else {
			iReturnValue = RMT_FAILURE;
		}
	} else if (flag == RIS_REMOVE_SERVICE_ONLY) {
		if(NO_ERROR != RemoveServiceAndWaitForCompletion(schSCManager,
			service_name)) {
			iReturnValue = RMT_FAILURE;
		}
	} else {
		sprintf(wrk, "RISService:bad flag %d passed to RISService",
			flag);
   		WriteToLog(__FILE__, __LINE__, wrk);
		iReturnValue = RMT_FAILURE;
	}

	if(FALSE == CloseServiceHandle(schSCManager)) { // FALSE means error
		sprintf(wrk, "RISService:CloseServiceHandle GetLastError = %lu",
			GetLastError());
   		WriteToLog(__FILE__, __LINE__, wrk);
	}

	sprintf(wrk, "RISService returns %d", iReturnValue);
   	WriteToLog(__FILE__, __LINE__, wrk);
	return(iReturnValue);
} // RISService

// 1996.04.18:Alan Barksdale:Much modified from FUNCTION3 in csource\template.c
//	in Setup SDK 2.3.0.0.
static int GetTcpServicePath(
  TCHAR *szRIStcp_path) /* RIS tcpsr path */
{
  auto DWORD iReturnValue = RMT_SUCCESS;
  CHAR szShare[cchMaxReg];  /* share path */

  WriteToLog(__FILE__, __LINE__, "Starting GetTcpServicePath");
  
  CheckRegIngrCommon(szShare) ;
  lstrcpy(szRIStcp_path, szShare);
  lstrcat(szRIStcp_path, RISCOMPONENT);
  lstrcat(szRIStcp_path, RIS_TCPSR_SERVICE_EXECUTABLE_PATH);
  sprintf(wrk, "GetTcpServicePath:szRIStcp_path = <%s>, lstrlen(szRIStcp_path) = %d",
    szRIStcp_path, lstrlen(szRIStcp_path));
  WriteToLog(__FILE__, __LINE__, wrk);

  sprintf(wrk, "GetTcpServicePath returns %d", iReturnValue);
  WriteToLog(__FILE__, __LINE__, wrk);
  return(iReturnValue);
} // GetTcpServicePath

// 1996.04.18:Alan Barksdale: From our inherited code, it appears this is
//	supposed to stop and delete the current RIS TCP service and then to
//	start a new TCP service.
extern int RISInstallTcpService(void)
{
	auto DWORD iReturnValue = RMT_SUCCESS;
	TCHAR szRIStcp_path[cchMax]; /* RIS tcpsr path */
  
	WriteToLog(__FILE__, __LINE__, "Starting RISInstallTcpService");
  
	if(RMT_SUCCESS == GetTcpServicePath(szRIStcp_path)) {
		iReturnValue = RISService(szRIStcp_path, RIS_TCPSR_SERVICE,
			RIS_INSTALL_SERVICE);
	}

	sprintf(wrk, "RISInstallTcpService returns %d", iReturnValue);
   	WriteToLog(__FILE__, __LINE__, wrk);
	return(iReturnValue);
} // RISInstallTcpService

// 1996.04.18:Alan Barksdale:From our inherited code, it appears this is
//	supposed to stop and delete the current RIS TCP service and then to
//	start a new TCP service if there's a higher version on the machine.
extern int RISRemoveTcpService(void)
{
	auto DWORD iReturnValue = RMT_SUCCESS;
	TCHAR szRIStcp_path[cchMax]; /* RIS tcpsr path */
  
	WriteToLog(__FILE__, __LINE__, "Starting RISRemoveTcpService");
  
	if(RMT_SUCCESS == GetTcpServicePath(szRIStcp_path)) {
		iReturnValue = RISService(szRIStcp_path, RIS_TCPSR_SERVICE,
		RIS_REMOVE_SERVICE);
	}

	sprintf(wrk, "RISRemoveTcpService returns %d", iReturnValue);
   	WriteToLog(__FILE__, __LINE__, wrk);
	return(iReturnValue);
} // RISRemoveTcpService

// 1996.04.18:Alan Barksdale:From our inherited code, it appears this is
//	supposed to stop and delete the current RIS TCP service.
extern int RISRemoveTcpServiceOnly(void)
{
	auto DWORD iReturnValue = RMT_SUCCESS;

	WriteToLog(__FILE__, __LINE__, "Starting RISRemoveTcpServiceOnly");
 
	iReturnValue = RISService(NULL, RIS_TCPSR_SERVICE,
		RIS_REMOVE_SERVICE_ONLY);

	sprintf(wrk, "RISRemoveTcpServiceOnly returns %d", iReturnValue);
   	WriteToLog(__FILE__, __LINE__, wrk);
	return(iReturnValue);
} // RISRemoveTcpServiceOnly
