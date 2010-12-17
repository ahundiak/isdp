/* Do not alter this SPC information: $Revision: 1.2.3.1 $ */
#ifndef STF_LITE
#include <windows.h>
#ifdef WIN32
#include <malloc.h>
#endif
#include <stdio.h>
#include "setupapi.h"
#include "msregdb.h"
#include "ris.h"


#ifdef WIN16
typedef LONG (APIENTRY *LPFNRCLK)(LONG);
typedef LONG (APIENTRY *LPFNRCRK)(LONG, LPSTR, LPSTR);
typedef LONG (APIENTRY *LPFNRDLK)(LONG, LPSTR);
typedef LONG (APIENTRY *LPFNROPK)(LONG, LPSTR, LPSTR);
typedef LONG (APIENTRY *LPFNRQRV)(LONG, LPSTR, LPSTR, LPSTR);
typedef LONG (APIENTRY *LPFNRSTV)(LONG, LPSTR, LONG, LPSTR, LONG);

LPFNRCLK lpfnRegCloseKey;
LPFNRCRK lpfnRegCreateKey;
LPFNRDLK lpfnRegDeleteKey;
LPFNROPK lpfnRegOpenKey;
LPFNRQRV lpfnRegQueryValue;
LPFNRSTV lpfnRegSetValue;
#endif

#ifdef WIN32
typedef LONG (APIENTRY *LPFNRCLK)(HKEY);
typedef LONG (APIENTRY *LPFNRCRK)(HKEY, LPCTSTR, PHKEY);
typedef LONG (APIENTRY *LPFNRDLK)(HKEY, LPCTSTR);
typedef LONG (APIENTRY *LPFNROPK)(HKEY, LPCTSTR, PHKEY);
typedef LONG (APIENTRY *LPFNRQRV)(HKEY, LPCTSTR, LPTSTR, PLONG);
typedef LONG (APIENTRY *LPFNRSTV)(HKEY, LPCTSTR, DWORD, LPTSTR, DWORD);
typedef LONG (APIENTRY *LPFNRCRKe)(HKEY, LPCTSTR, DWORD, LPTSTR, DWORD,
	    REGSAM, LPSECURITY_ATTRIBUTES, PHKEY, LPDWORD);
typedef LONG (APIENTRY *LPFNROPKe)(HKEY, LPCTSTR, DWORD, REGSAM, PHKEY);
typedef LONG (APIENTRY *LPFNRQRVe)(HKEY, LPTSTR, LPDWORD, LPDWORD, LPBYTE, LPDWORD);
typedef LONG (APIENTRY *LPFNRSTVe)(HKEY, LPCTSTR, DWORD, DWORD, LPBYTE, DWORD);
typedef LONG (APIENTRY *LPFNREK)(HKEY, DWORD, LPTSTR, LPDWORD);
typedef LONG (APIENTRY *LPFNRQIK)(HKEY, LPTSTR, LPDWORD, LPDWORD, LPDWORD,
      LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, PFILETIME);

LPFNRCLK lpfnRegCloseKey;
LPFNRCRK lpfnRegCreateKey;
LPFNRDLK lpfnRegDeleteKey;
LPFNROPK lpfnRegOpenKey;
LPFNRQRV lpfnRegQueryValue;
LPFNRSTV lpfnRegSetValue;
LPFNRCRKe lpfnRegCreateKeyEx;
LPFNROPKe lpfnRegOpenKeyEx;
LPFNRQRVe lpfnRegQueryValueEx;
LPFNRSTVe lpfnRegSetValueEx;
LPFNREK lpfnRegEnumKey;
LPFNRQIK lpfnRegQueryInfoKey;
#endif

extern BOOL GetFullSubKeyFromPath(
	HKEY hKey,
	LPTSTR szPath,
	LPTSTR szKey,
	LPTSTR szFullSubKey)
{
	TCHAR szClass[128];
	HKEY hKey2;
	LONG lResult;
	DWORD cchClass, dwNumSubKeys, cchMaxSubKey, cchMaxClass,
		cValues, cchMaxValName, cbMaxValData, cbSecurityDescriptor;
	DWORD i, cchName;
	FILETIME ftLastWrite;
	DWORD ret_val;
	DWORD dwType;
	LPTSTR szSubKey;
	LPTSTR tmpsubkey[255];
	char wrk[255];
        int len, t ;
	CHAR TmpString [255] ;

	WriteToLogFile("Starting GetFullSubKeyFromPath");

	sprintf(wrk,"path = [%s]",szPath);
	WriteToLogFile(wrk);
        len = strlen (szPath) ;
        
	for (t=0; t<len; t++) szPath[t] = tolower (szPath[t]) ;

	sprintf(wrk, "prodkey= [%s]",szKey);
	WriteToLogFile(wrk);


	if ((lResult = (*lpfnRegOpenKeyEx)(hKey, szKey,
		0, KEY_READ, &hKey2)) > ERROR_SUCCESS)
	{
		WriteToLogFile("GetFullSubKeyFromPath: Couldnt open registry key.");
		return(FALSE);
	}

	//
	// First, see how many subkeys this key has.
	//
	cchClass=128;
	if ((lResult = (*lpfnRegQueryInfoKey)(hKey2, szClass, &cchClass, NULL, &dwNumSubKeys, 
		&cchMaxSubKey, &cchMaxClass, &cValues, &cchMaxValName,
		&cbMaxValData, &cbSecurityDescriptor, &ftLastWrite)) != ERROR_SUCCESS)
	{
		(*lpfnRegCloseKey)(hKey2);
		WriteToLogFile("GetFullSubKeyFromPath: Failed to check how many keys exist.");
		return(FALSE);
	}

	if (dwNumSubKeys)
	{
		sprintf (wrk, "GetFullSubKeyFromPath: subkeys <%d> exist. ",
				dwNumSubKeys) ;
		WriteToLogFile(wrk);
		//
		// This key has subkeys; we'll need to enumerate them
		// and add each one into the SubKeyList.
		//
		// RegQueryInfoKey() has indicated what the maximum length
		// of a subkey name will be for this particular key
		// in "cchMaxSubKey", so we can allocate just what we
		// need to hold the names.
		//
		szSubKey = (LPTSTR)malloc((cchMaxSubKey+1) * sizeof(TCHAR));

		for (i = dwNumSubKeys; i > 0; i--)
		{
			cchName = cchMaxSubKey;
			if ((lResult = (*lpfnRegEnumKey)(hKey2, i - 1,
				szSubKey, &cchName)) == ERROR_SUCCESS)
			{
				WriteToLogFile("GetFullSubKeyFromPath: Getting PathName for this subkey.");
				//
				// Get the PathName value for this subkey.
				//
				wsprintf((char *)tmpsubkey, "%s\\%s", szKey, szSubKey);
				ret_val = GetRegKeyValueEx(HKEY_LOCAL_MACHINE,
					(const char *)tmpsubkey, "Pathname", &dwType,
					TmpString,255);
				if (ret_val != ERROR_SUCCESS)
				{
					WriteToLogFile("GetFullSubKeyFromPath: Failed to get PathName for this subkey !!");
					return(FALSE);
				}
				len = strlen (TmpString) ;
                                for (t=0; t<len; t++) {
                                    TmpString[t] = tolower(TmpString[t]) ;
                                }
				sprintf(wrk,"look for fullsubkey= [%s]",
					TmpString);
				WriteToLogFile(wrk);
				if (strcmp(TmpString, szPath) == 0)
				{
					WriteToLogFile("GetFullSubKeyFromPath: PathName matches returning TRUE");
					lstrcpy(szFullSubKey, (const char *)tmpsubkey);
					sprintf(wrk, "(TRUE) fullsubkey= [%s]",szFullSubKey);
					WriteToLogFile(wrk);
                                	(*lpfnRegCloseKey)(hKey2);
					return(TRUE);
				}
			}
		}// for i
	}// if (dwNumSubKeys)
	(*lpfnRegCloseKey)(hKey2);
	WriteToLogFile("GetFullSubKeyFromPath: returning FALSE");
	return(FALSE);
}

extern BOOL FindMatchingVer(
   HKEY hKey,
   LPTSTR szKey)
{
    LONG lResult;
    HKEY hKey2;

    if ((lResult = (*lpfnRegOpenKeyEx)(hKey, szKey,
	    0, KEY_READ, &hKey2)) > ERROR_SUCCESS)
   {
      return(FALSE);
   }
   else
   {
      (*lpfnRegCloseKey)(hKey2);
      return(TRUE);
   }
}



#endif	/* !STF_LITE */
