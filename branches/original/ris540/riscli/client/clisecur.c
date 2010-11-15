/************************************************************************\
*
*  MODULE:      SECURE.C
*
*  PURPOSE:     Connect to and use LsaLogonUser
*               and Impersonate Users where appropriate.
*
*  FUNCTIONS:   
*               SecureInit()   Init security routines.
*               SecureClose()  Close security routines.
*               char *  GetErrorString(VOID)
*               HANDLE  GetLogonToken(pszUser, pszDomain, pszPassw)
*               HANDLE  GetImpersonationToken(HANDLE hToken)
*               HANDLE  GetThreadHandle(DWORD PID, DWORD dwHandle)
*               BOOL    Impersonate(HANDLE hThread, HANDLE hToken)
*               BOOL    InternalCloseHandle(HANDLE h)
*        
*
*
*  COMMENTS:    
*
************************************************************************/


#include <stdio.h>
#include <string.h>
#include <malloc.h>

#include <windows.h>
#include <winnt.h>
#include "stuff.h"

#include "secure.h"

BOOL WINAPI _CRT_INIT(HINSTANCE, DWORD, LPVOID);

// The following #define, typedefs and prototypes are to get around the 
// redefinition problems when both windows.h and nt.h are included. 
// GetLastError and AllocateLocallyUniqueId are protyped in winbase.h 
// and windef.h which windows.h includes.

typedef int BOOL;
typedef unsigned long DWORD;

HANDLE  LsaHandle;              // Lsa authentication handle
ULONG   AuthenticationPackage;  // Authentication Package Value
char    chMsgBuffer[256];

#define FAIL_BUFF 5
HKEY hKeyRPCToken;

#define FAILURE_LIMIT 3
#define FORGIVE_TIME  (3600000) /* 1 hr */

/************************************************************************\
*
*  FUNCTION:    IsLogonPossible
*
*  INPUTS:      None
*
*  RETURNS:     None
*
*  GLOBAL VARS: dwFailureTick[] and iFail
*               
*
*  COMMENTS:    Primitive but hopefully effective method of preventing
*               dictionary attacks.
*         
*
\************************************************************************/
BOOL IsLogonPossible(PSTRING UserName)
{
    char    chMsg[256];
    HANDLE  hEventSource;
    LPTSTR  lpszStrings[1];
    DWORD   dwThisFailure = GetTickCount();
    DWORD   dwLastFailure = dwThisFailure;
    LONG    lErr;
    HKEY    hKeyAccount;
    DWORD   cFail = 0;
    DWORD   dwType;
    DWORD   dw = sizeof(DWORD);


    lErr = RegOpenKeyEx( hKeyRPCToken, UserName->Buffer, 0, 
                KEY_ALL_ACCESS, &hKeyAccount);

    if (lErr != ERROR_SUCCESS)
        {
        return(TRUE);
        }

    lErr = RegQueryValueEx( hKeyAccount, "Failures", NULL, &dwType,
            (LPBYTE) &cFail, &dw);
    dw = sizeof(DWORD);  /* 1996.01.16:Alan Barksdale:because may be reset by RegQueryValueEx */
    lErr = RegQueryValueEx( hKeyAccount, "Time", NULL, &dwType,
            (LPBYTE) &dwLastFailure, &dw);


    if (cFail <= FAILURE_LIMIT ||
        ((dwThisFailure - dwLastFailure) > FORGIVE_TIME))
        {
        RegCloseKey(hKeyAccount);
        return(TRUE);
        }


    cFail++;
    lErr = RegSetValueEx( hKeyAccount, "Failures", 0, REG_DWORD,
                (LPBYTE) &cFail, sizeof(DWORD));

    lErr = RegSetValueEx( hKeyAccount, "Time", 0, REG_DWORD,
                (LPBYTE) &dwThisFailure, sizeof(DWORD));

    RegCloseKey(hKeyAccount);

    /* Use event logging to log the error. */
    hEventSource = RegisterEventSource(NULL,
                            TEXT("Secure.DLL"));

    sprintf( chMsg, "Secure.DLL Logon Failure %d, Account %s",
                cFail, UserName->Buffer);

    lpszStrings[0] = chMsg;

    if (hEventSource != NULL)
        {
        ReportEvent(hEventSource, /* handle of event source */
            EVENTLOG_AUDIT_FAILURE,  /* event type */
            0,                    /* event category */
            0,                    /* event ID */
            NULL,                 /* current user's SID */
            1,                    /* strings in lpszStrings */
            0,                    /* no bytes of raw data */
            lpszStrings,          /* array of error strings */
            NULL);                /* no raw data */

        (VOID) DeregisterEventSource(hEventSource);
        }

}
/************************************************************************\
*
*  FUNCTION:    NoteLogonFailure
*
*  INPUTS:      None
*
*  RETURNS:     None
*
*  GLOBAL VARS: dwFailureTick[] and iFail
*               
*
*  COMMENTS:    Primitive but hopefully effective method of preventing
*               dictionary attacks.
*         
*
\************************************************************************/
void NoteLogonFailure(PSTRING UserName)
{
    char    chMsg[256];
    HANDLE  hEventSource;
    LPTSTR  lpszStrings[1];
    DWORD   dwThisFailure = GetTickCount();
    DWORD   dwLastFailure = dwThisFailure;
    LONG    lErr;
    HKEY    hKeyAccount;
    DWORD   dwStatus;
    DWORD   cFail = 0;
    DWORD   dwType;
    DWORD   dw = sizeof(DWORD);


    lErr = RegCreateKeyEx( hKeyRPCToken, UserName->Buffer, 0, "Class",
                REG_OPTION_VOLATILE, KEY_ALL_ACCESS, NULL, &hKeyAccount,
                &dwStatus);

    if (lErr != ERROR_SUCCESS)
        {
        /* MessageBox(NULL, "RegCreateKeyEx Failed", "NoteLogonFailure", MB_OK); */
        return;
        }

    if (dwStatus == REG_OPENED_EXISTING_KEY)
        {
        lErr = RegQueryValueEx( hKeyAccount, "Failures", NULL, &dwType,
                (LPBYTE) &cFail, &dw);
        dw = sizeof(DWORD);  /* 1996.01.16:Alan Barksdale:because may be reset by RegQueryValueEx */
        lErr = RegQueryValueEx( hKeyAccount, "Time", NULL, &dwType,
                (LPBYTE) &dwLastFailure, &dw);
        }

    cFail++;
    lErr = RegSetValueEx( hKeyAccount, "Failures", 0, REG_DWORD,
                (LPBYTE) &cFail, sizeof(DWORD));

    lErr = RegSetValueEx( hKeyAccount, "Time", 0, REG_DWORD,
                (LPBYTE) &dwThisFailure, sizeof(DWORD));

    RegCloseKey(hKeyAccount);

    if ((dwThisFailure - dwLastFailure) > 3600000)
        {
        RegDeleteKey(hKeyRPCToken, UserName->Buffer);
        return;
        }

    /* Use event logging to log the error. */
    hEventSource = RegisterEventSource(NULL,
                            TEXT("Secure.DLL"));

    sprintf( chMsg, "Secure.DLL Logon Failure %d, Account %s",
                cFail, UserName->Buffer);

    lpszStrings[0] = chMsg;

    if (hEventSource != NULL)
        {
        ReportEvent(hEventSource, /* handle of event source */
            EVENTLOG_AUDIT_FAILURE,  /* event type */
            0,                    /* event category */
            0,                    /* event ID */
            NULL,                 /* current user's SID */
            1,                    /* strings in lpszStrings */
            0,                    /* no bytes of raw data */
            lpszStrings,          /* array of error strings */
            NULL);                /* no raw data */

        (VOID) DeregisterEventSource(hEventSource);
        }

}
/************************************************************************\
*
*  FUNCTION:    GetErrorString
*
*  INPUTS:      None
*
*  RETURNS:     char * to error string on an error.
*
*  GLOBAL VARS: Returns address of chMsgBuffer
*               
*
*  COMMENTS:    
*
\************************************************************************/
char * GetErrorString()
{
    return(chMsgBuffer);
}

/************************************************************************\
*
*  FUNCTION:    InitializeAuthentication (Internal)
*
*  INPUTS:      None
*
*  RETURNS:     NTSTATUS
*
*
*  GLOBAL VARS: Sets LsaHandle and AuthenticationPackage
*
*  COMMENTS:    
*
\************************************************************************/

NTSTATUS InitializeAuthentication( )
{
    NTSTATUS Status;
    STRING LogonProcessName, PackageName;
    LSA_OPERATIONAL_MODE SecurityMode;

    /**/
    /* Hookup to the LSA and locate our authentication package. */
    /**/


    RtlInitString(&LogonProcessName, "MS_PortLab_JMH");

    Status = LsaRegisterLogonProcess(
                 &LogonProcessName,
                 &LsaHandle,
                 &SecurityMode
                 );


    if (!NT_SUCCESS(Status))
        {
        return(Status);
        }


    /**/
    /* Connect with the MSV1_0 authentication package */
    /**/
    RtlInitString(&PackageName, "MICROSOFT_AUTHENTICATION_PACKAGE_V1_0");

    Status = LsaLookupAuthenticationPackage (
                LsaHandle,
                &PackageName,
                &AuthenticationPackage
                );

    if (!NT_SUCCESS(Status))
        {
        CloseHandle(LsaHandle);
        return(Status);
        }

    return(0);
}




/***************************************************************************\
*   FUNCTION:   LogonUser (Internal)
*
*   PURPOSE:    Calls the Lsa to Obtain a Primary Token Token
*
*   INPUTS:     PSTRING values for UserName, Domain, and Password
*
*   RETURNS:    NTSTATUS, LogonToken
*
*
*  GLOBAL VARS: Uses LsaHandle and AuthenticationPackage
*
\***************************************************************************/
#ifdef DEBUG
void fpString( FILE *fp, LPSTR lpName, PSTRING pStr)
{
    fprintf( fp, "%s : (l = %d) %s\n", lpName, pStr->Length, pStr->Buffer);
    
}

void fpMem( FILE *fp, LPSTR lpName, LPSTR lpBuf, ULONG cb)
{
    int ii;
    int jj;
    char ch;

    fprintf( fp, "%s %lx\n", lpName, lpBuf);
    for (jj = 0; jj < cb; jj += 16)
        {
        for (ii = 0; ii < 16; ii+= 2)
            fprintf( fp, "%4x", 0x0000ffff & *((LPWORD)(&lpBuf[jj + ii])));
        fprintf( fp, "\t\t");
        for (ii = 0; ii < 16; ii++)
            {
            ch = lpBuf[jj + ii];
            ch = isprint(ch) ? ch : '.';/*itbokic 3/30 */
            fprintf( fp, "%c", ch);
            }
        fprintf( fp, "\n");
        }


}
#endif
NTSTATUS LogonUser( PSTRING UserName, PSTRING Domain, PSTRING Password,
                    PHANDLE pLogonToken)
{
    QUOTA_LIMITS Quotas;
    PMSV1_0_INTERACTIVE_PROFILE Profile;
    ULONG ProfileBufferLength = sizeof(Profile);
    NTSTATUS SubStatus;
	 /* OUT */

	 
    NTSTATUS Status;
    STRING OriginName;
    TOKEN_SOURCE SourceContext;
    LUID LogonId;
    PMSV1_0_INTERACTIVE_LOGON MsvAuthInfo;
    PVOID AuthInfoBuf;
    ULONG AuthInfoSize;
    PTOKEN_GROUPS TokenGroups = NULL;


    //
    // Initialize source context structure
    //

    strncpy(SourceContext.SourceName, "JohnHall", /*itbokic 3/30 */
                sizeof(SourceContext.SourceName));

    Status = NtAllocateLocallyUniqueId(&SourceContext.SourceIdentifier);

    if (!NT_SUCCESS(Status))
        {
		sprintf( chMsgBuffer, "failed to allocate locally unique id, status = 0x%lx", Status);
        return(Status);
        }


    //
    // Build the authentication information buffer
    //

    AuthInfoSize = sizeof(MSV1_0_INTERACTIVE_LOGON) +
        RtlAnsiStringToUnicodeSize(UserName) +
        RtlAnsiStringToUnicodeSize(Domain) +
        RtlAnsiStringToUnicodeSize(Password);

    MsvAuthInfo = AuthInfoBuf
                = malloc((AuthInfoSize < 4000) ? 4000 : AuthInfoSize);

    if (MsvAuthInfo == NULL)
        {
		sprintf( chMsgBuffer, "failed to allocate memory for authentication buffer");
        return(STATUS_NO_MEMORY);
        }

    //
    // This authentication buffer will be used for a logon attempt
    //

    MsvAuthInfo->MessageType = MsV1_0InteractiveLogon;


    //
    // Set logon origin
    //

    RtlInitString(&OriginName, "MS_Portlab_JMH");


    //
    // Copy the user name into the authentication buffer
    //

    MsvAuthInfo->UserName.MaximumLength =
                             (USHORT)RtlAnsiStringToUnicodeSize(UserName);

    MsvAuthInfo->UserName.Buffer = (PWSTR)(MsvAuthInfo + 1);
	 
    Status = RtlAnsiStringToUnicodeString(&MsvAuthInfo->UserName, UserName, FALSE);
	 
    if (!NT_SUCCESS(Status))
        {
		sprintf( chMsgBuffer, "failed to copy username to authentication buffer, status = 0x%lx", Status);
        free(AuthInfoBuf);
        return(Status);
        }

    //
    // Copy the domain name into the authentication buffer
    //

    MsvAuthInfo->LogonDomainName.MaximumLength =
                                 (USHORT)RtlAnsiStringToUnicodeSize(Domain);
											
    MsvAuthInfo->LogonDomainName.Length = MsvAuthInfo->LogonDomainName.MaximumLength;
	 
    MsvAuthInfo->LogonDomainName.Buffer = (PWSTR)
                                 ((PBYTE)(MsvAuthInfo->UserName.Buffer) +
                                 MsvAuthInfo->UserName.MaximumLength);

    Status = RtlAnsiStringToUnicodeString(&MsvAuthInfo->LogonDomainName, Domain, FALSE);

    if (!NT_SUCCESS(Status))
        {
		sprintf( chMsgBuffer, "failed to copy domain name to authentication buffer, status = 0x%lx", Status);
        free(AuthInfoBuf);
        return(Status);
        }

    //
    // Copy the password into the authentication buffer
    //

    MsvAuthInfo->Password.MaximumLength =
                                 (USHORT)RtlAnsiStringToUnicodeSize(Password);

    MsvAuthInfo->Password.Buffer = (PWSTR)
                                 ((PBYTE)(MsvAuthInfo->LogonDomainName.Buffer) +
                                 MsvAuthInfo->LogonDomainName.MaximumLength);

    Status = RtlAnsiStringToUnicodeString(&MsvAuthInfo->Password, Password, FALSE);

    if (!NT_SUCCESS(Status))
        {
		sprintf( chMsgBuffer, "failed to copy password to authentication buffer, status = 0x%lx", Status);
        free(AuthInfoBuf);
        return(Status);
        }

#ifdef DEBUG
{
    FILE *fp;

    fp = fopen( "secure.log", "a");
    fprintf( fp, "LsaHandle %lx\n", LsaHandle);
    fpString( fp, "OriginName", &OriginName);
    fprintf( fp, "Interactive\n");
    fprintf( fp, "AuthenticationPackage %ld\n", AuthenticationPackage);
    fprintf (fp, "MessageType %ld", MsvAuthInfo->MessageType);
    fpMem( fp, "AuthInfoBuf", AuthInfoBuf, AuthInfoSize);
    fprintf( fp, "Source Context Name (%s) Luid (%ld/%d)\n", SourceContext.SourceName,
                SourceContext.SourceIdentifier.LowPart,
                SourceContext.SourceIdentifier.HighPart);
    fclose(fp);
}

#endif

   Status = LsaLogonUser (
                 LsaHandle,
                 &OriginName,
                 Interactive,
                 AuthenticationPackage,
                 AuthInfoBuf,
                 AuthInfoSize,
                 TokenGroups,
                 &SourceContext,
                 &Profile,
                 &ProfileBufferLength,
                 &LogonId,
                 pLogonToken,
                 &Quotas,
                 &SubStatus
                 );

    LsaFreeReturnBuffer( Profile);

    if (!NT_SUCCESS(Status))
        {
		sprintf( chMsgBuffer, "LsaLogonUser failed , status = 0x%lx\n", Status);
        NoteLogonFailure(UserName);
        }

    //
    // Discard authentication buffer
    //

    free(AuthInfoBuf);

    return(Status);
}


/***************************************************************************\
*   FUNCTION:   GetForeignThreadHandle
*
*   PURPOSE:    Obtain thread handle from another process
*
*   INPUTS:     PID of foreign process and thread handle in that process
*
*   RETURNS:    hThread with IMPERSONATE access.
*
*
*  GLOBAL VARS: None.
*
\***************************************************************************/
HANDLE GetForeignThreadHandle( DWORD Pid, DWORD dwThread)
{
    HANDLE   hForeignProcess;
    HANDLE   hForeignThread;
    HANDLE   hOurProcess;
    BOOLEAN     bb;


    hOurProcess = GetCurrentProcess();

    hForeignProcess = OpenProcess(
            PROCESS_ALL_ACCESS,
            FALSE,
            Pid);

    if (hForeignProcess == NULL)
        {
        strcpy( chMsgBuffer, "Couldn't Open Foreign Process\n");
        return(NULL);
        }

    bb = DuplicateHandle(hForeignProcess,
            (HANDLE) dwThread,
            hOurProcess,
            &hForeignThread,
            THREAD_ALL_ACCESS,
            FALSE,
            0);

    CloseHandle(hForeignProcess);

    if (bb == FALSE)
        {
        strcpy( chMsgBuffer, "Couldn't Duplicate Handle of Foreign Thread\n");
        return(NULL);
        }
    else

    return(hForeignThread);

}
/***************************************************************************\
*   FUNCTION:   GetImpersonateToken
*
*   PURPOSE:    Obtain Impersonation Token
*
*   INPUTS:     Token
*
*   RETURNS:    Impersonation token hToken 
*
*
*  GLOBAL VARS: None.
*
\***************************************************************************/
HANDLE GetImpersonateToken( HANDLE hToken)
{
    NTSTATUS Status;
    OBJECT_ATTRIBUTES  ObjectAttributes;
    SECURITY_QUALITY_OF_SERVICE SecurityQualityOfService;
    HANDLE   hImpersonateToken;


    InitializeObjectAttributes(
                 &ObjectAttributes,
                 NULL,
                 0,
                 NULL,
                 NULL
                 );

    SecurityQualityOfService.Length = sizeof(SECURITY_QUALITY_OF_SERVICE);
    SecurityQualityOfService.ImpersonationLevel = SecurityImpersonation;
    SecurityQualityOfService.ContextTrackingMode = SECURITY_DYNAMIC_TRACKING;
    SecurityQualityOfService.EffectiveOnly = FALSE;

    ObjectAttributes.SecurityQualityOfService = &SecurityQualityOfService;

    Status = NtDuplicateToken( hToken,
                TOKEN_IMPERSONATE,
                &ObjectAttributes,
                FALSE,
                TokenImpersonation,
                &hImpersonateToken);

    if (! NT_SUCCESS(Status))
        {
        strcpy( chMsgBuffer, "NtDuplicateToken Failed\n");
        return(NULL);
        }
    else
        return(hImpersonateToken);

}

/***************************************************************************\
*   FUNCTION:   SetThreadImpersonation
*
*   PURPOSE:    Set hToken in hThread
*
*   INPUTS:     hThread with IMPERSONATE permission
*               hToken  an impersonation token
*
*   RETURNS:    NTSTATUS
*
*
*  GLOBAL VARS: None.
*
\***************************************************************************/
NTSTATUS SetThreadImpersonation( HANDLE hThread, HANDLE hToken)
{
    NTSTATUS Status;

    //
    // Set the impersonation token on this thread so we 'are' the user
    //

    Status = NtSetInformationThread( hThread,
                                     ThreadImpersonationToken,
                                     (PVOID)&hToken,
                                     sizeof(HANDLE)
                                   );

    return(Status);
}

/***************************************************************************\
*   FUNCTION:   SetProcessToken
*
*   PURPOSE:    Set hToken in hProcess
*
*   INPUTS:     hProcess, must have appropriate privilidge.
*               hThread   primary (first) thread in process.
*               hToken    primary token
*
*   RETURNS:    NTSTATUS
*
*  GLOBAL VARS: None.
*
*  SIDE EFFECT: hToken is closed and no longer available for use.
*
\***************************************************************************/
NTSTATUS SetProcessToken( HANDLE hProcess, HANDLE hThread, HANDLE hTokenIn)
{
    NTSTATUS Status, AdjustStatus;
    PROCESS_ACCESS_TOKEN PrimaryTokenInfo;
    BOOLEAN WasEnabled;
    OBJECT_ATTRIBUTES ObjectAttributes;
    HANDLE  hTokenToAssign;
    SECURITY_DESCRIPTOR SecurityDescriptor;
    DWORD dwRes;

    //
    // A primary token can only be assigned to one process.
    // Duplicate the logon token so we can assign one to the new
    // process.
    //

    InitializeObjectAttributes(
                 &ObjectAttributes,
                 NULL,
                 0,
                 NULL,
                 NULL
                 );

    Status = NtDuplicateToken(
                 hTokenIn, // Duplicate this token
                 0,                 // Same desired access
                 &ObjectAttributes,
                 FALSE,             // EffectiveOnly
                 TokenPrimary,      // TokenType
                 &hTokenToAssign     // Duplicate token handle stored here
                 );


    //
    // Give the process a NULL Dacl
    //
    dwRes = InitializeSecurityDescriptor( &SecurityDescriptor,
				SECURITY_DESCRIPTOR_REVISION);
    if (!dwRes)
	return -1;

    dwRes = SetSecurityDescriptorDacl(&SecurityDescriptor,
				TRUE,
				NULL,
				FALSE);
    if (!dwRes)
	return -1;

    if (!SetKernelObjectSecurity(hProcess,
			    DACL_SECURITY_INFORMATION,
			    &SecurityDescriptor))
	return -1;


    //
    // Enable the required privilege
    //

    Status = RtlAdjustPrivilege(SE_ASSIGNPRIMARYTOKEN_PRIVILEGE, TRUE,
                                FALSE, &WasEnabled);
    if (NT_SUCCESS(Status)) {

        PrimaryTokenInfo.Token  = hTokenToAssign;
        PrimaryTokenInfo.Thread = hThread;

        Status = NtSetInformationProcess(
                    hProcess,
                    ProcessAccessToken,
                    (PVOID)&PrimaryTokenInfo,
                    (ULONG)sizeof(PROCESS_ACCESS_TOKEN)
                    );
        //
        // Restore the privilege to its previous state
        //

        AdjustStatus = RtlAdjustPrivilege(SE_ASSIGNPRIMARYTOKEN_PRIVILEGE,
                                          WasEnabled, FALSE, &WasEnabled);
        if (NT_SUCCESS(Status)) {
            Status = AdjustStatus;
        }
    }
    //
    // We're finished with the token handle
    //

    CloseHandle(hTokenToAssign);


    return (Status);
}

/***************************************************************************\
*   FUNCTION:   GetLogonToken
*
*   PURPOSE:    Calls the Lsa to Obtain a Primary Logon Token
*
*   INPUTS:     PSTRING values for UserName, Domain, and Password
*
*   RETURNS:    LogonToken
*
*
*  GLOBAL VARS: Uses LsaHandle and AuthenticationPackage
*
\***************************************************************************/
HANDLE GetLogonToken( char *pszUser, char *pszDomain, char *pszPassword)
{
    NTSTATUS Status;
	STRING   UserName, Domain, Password;
    HANDLE   LogonToken;
    
    RtlInitString(&UserName, pszUser);
    RtlInitString(&Domain  , pszDomain);
    RtlInitString(&Password, pszPassword);

    Status = LogonUser(&UserName, &Domain, &Password, &LogonToken);

    if (!NT_SUCCESS(Status))
        {
        SetLastError(Status);
        return(NULL);
        }
    else
        return(LogonToken);

}


/*******************************************************************

    NAME:       ValidateUser

    SYNOPSIS:   Validate a given domain/user/password tuple.

    ENTRY:      pszDomainName - The user's domain (NULL = current).

                pszUserName - The user's name.

                pszPassword - The user's (plaintext) password.

                pfAsGuest - Will receive TRUE if the user was validated
                    with guest privileges.

    RETURNS:    HANDLE - An impersonation token, NULL if user cannot
                    be validated.


********************************************************************/
HANDLE GetNetLogonToken(CHAR * pszUserName,
                     CHAR * pszDomainName,
                     CHAR * pszPassword,
                     BOOL * pfAsGuest
                      )
{
    NTSTATUS                     ntStatus;
    NTSTATUS                     ntSubStatus;
    STRING                       OriginName;
    QUOTA_LIMITS                 Quotas;
    LUID                         LogonId;
    HANDLE                       hToken;
    PMSV1_0_LM20_LOGON_PROFILE   pProfile;
    ULONG                        cbProfile;
    PMSV1_0_LM20_LOGON           pInfo;
    ULONG                        cbInfo;
    CHAR                       * pszNextChar;
    UNICODE_STRING               DomainName;
    UNICODE_STRING               UserName;
    UNICODE_STRING               Workstation;
    STRING                       AsciiPassword;
    UNICODE_STRING               UnicodePassword;
    TOKEN_SOURCE SourceContext   = { "JohnHall" , {0, 0} };
    PTOKEN_GROUPS TokenGroups = NULL;


    //
    //  Put our buffers & token into known states.
    //

    pInfo    = NULL;
    pProfile = NULL;
    hToken   = NULL;


    //
    //  Initialize a number of strings.
    //

    RtlInitString( &OriginName,    "MS_PortLab_JMH" );
    RtlInitString( &AsciiPassword, pszPassword  );

    RtlInitUnicodeString( &DomainName,      NULL );
    RtlInitUnicodeString( &UserName,        NULL );
    RtlInitUnicodeString( &UnicodePassword, NULL );

    RtlInitUnicodeString( &Workstation, L"" );

    ntStatus = NtAllocateLocallyUniqueId(&SourceContext.SourceIdentifier);

    if (!NT_SUCCESS(ntStatus))
        {
		sprintf( chMsgBuffer, "failed to allocate locally unique id, status = 0x%lx", ntStatus);
        return(NULL);
        }




    if( !RtlCreateUnicodeStringFromAsciiz( &DomainName, pszDomainName ) ||
        !RtlCreateUnicodeStringFromAsciiz( &UserName, pszUserName )     ||
        !RtlCreateUnicodeStringFromAsciiz( &UnicodePassword, pszPassword ) )
    {
		sprintf( chMsgBuffer, "Memory alloc failed\n");
        ntStatus = STATUS_NO_MEMORY;
        goto Cleanup;
    }

    //
    //  The ASCII password is for downlevel compatability.
    //  It must always be uppercase.
    //

    RtlUpperString( &AsciiPassword, &AsciiPassword );

    //
    //  Calculate the size of the authentication buffer.  Note
    //  that all of the various strings must be within this
    //  single info buffer.
    //

    cbInfo = sizeof(MSV1_0_LM20_LOGON)
                     + DomainName.MaximumLength + 1
                     + UserName.MaximumLength + 1
                     + Workstation.MaximumLength + 1
                     + UnicodePassword.MaximumLength + 1
                     + AsciiPassword.MaximumLength;

    //
    //  Allocate the info buffer.
    //

    pInfo = (MSV1_0_LM20_LOGON *) malloc( cbInfo );

    if( pInfo == NULL )
    {
		sprintf( chMsgBuffer, "Memory alloc failed\n");
        ntStatus = STATUS_NO_MEMORY;
        goto Cleanup;
    }

    //
    //  Initialize the info buffer, packing the various
    //  strings into the buffer.
    //

    pszNextChar = (CHAR *)pInfo + sizeof(MSV1_0_LM20_LOGON);

    pInfo->MessageType = MsV1_0Lm20Logon;

    wcscpy( (WCHAR *)pszNextChar, DomainName.Buffer );
    pInfo->LogonDomainName.Length        = DomainName.Length;
    pInfo->LogonDomainName.MaximumLength = DomainName.MaximumLength;
    pInfo->LogonDomainName.Buffer        = (WCHAR *)pszNextChar;
    pszNextChar += DomainName.MaximumLength;

    wcscpy( (WCHAR *)pszNextChar, UserName.Buffer );
    pInfo->UserName.Length        = UserName.Length;
    pInfo->UserName.MaximumLength = UserName.MaximumLength;
    pInfo->UserName.Buffer        = (WCHAR *)pszNextChar;
    pszNextChar += UserName.MaximumLength;

    wcscpy( (WCHAR *)pszNextChar, Workstation.Buffer );
    pInfo->Workstation.Length        = Workstation.Length;
    pInfo->Workstation.MaximumLength = Workstation.MaximumLength;
    pInfo->Workstation.Buffer        = (WCHAR *)pszNextChar;
    pszNextChar += Workstation.MaximumLength;

    RtlZeroMemory( &pInfo->ChallengeToClient, MSV1_0_CHALLENGE_LENGTH );

    wcscpy( (WCHAR *)pszNextChar, UnicodePassword.Buffer );
    pInfo->CaseSensitiveChallengeResponse.Length        = UnicodePassword.Length;
    pInfo->CaseSensitiveChallengeResponse.MaximumLength = UnicodePassword.MaximumLength;
    pInfo->CaseSensitiveChallengeResponse.Buffer        = (PCHAR)pszNextChar;
    pszNextChar += UnicodePassword.MaximumLength;

    strcpy( pszNextChar, AsciiPassword.Buffer );
    pInfo->CaseInsensitiveChallengeResponse.Length        = AsciiPassword.Length;
    pInfo->CaseInsensitiveChallengeResponse.MaximumLength = AsciiPassword.MaximumLength;
    pInfo->CaseInsensitiveChallengeResponse.Buffer        = pszNextChar;
    pszNextChar += AsciiPassword.MaximumLength;

    pInfo->ParameterControl = CLEARTEXT_PASSWORD_ALLOWED;

    //
    //  Try to create the impersonation token.
    //
#ifdef DEBUG
{
    FILE *fp;

    fp = fopen( "secure.log", "a");
    fprintf( fp, "LsaHandle %lx\n", LsaHandle);
    fpString( fp, "OriginName", &OriginName);
    fprintf( fp, "Network\n");
    fprintf( fp, "AuthenticationPackage %ld\n", AuthenticationPackage);
    fpMem( fp, "pInfo", pInfo, cbInfo);
    fprintf( fp, "Source Context Name (%s) Luid (%ld/%d)\n", SourceContext.SourceName,
                SourceContext.SourceIdentifier.LowPart,
                SourceContext.SourceIdentifier.HighPart);
    fclose(fp);
}
#endif

    ntStatus = LsaLogonUser(LsaHandle,
                             &OriginName,
                             Network,
                             AuthenticationPackage,
                             pInfo,
                             cbInfo,
                             TokenGroups,
                             &SourceContext,
                             (PVOID *)&pProfile,
                             &cbProfile,
                             &LogonId,
                             &hToken,
                             &Quotas,
                             &ntSubStatus );

    RtlZeroMemory( (PVOID)UnicodePassword.Buffer, UnicodePassword.Length );
    RtlZeroMemory( (PVOID)AsciiPassword.Buffer,   AsciiPassword.Length   );

    if( !NT_SUCCESS(ntStatus) )
    {
        //
        //  Ensure hToken is NULLed on error.
        //

        hToken = NULL;

		sprintf( chMsgBuffer, "Logon Failure status = 0x%lx,0x%lx\n", ntStatus,
                    ntSubStatus);

        //
        //  MSV 1.0 uses STATUS_ACCOUNT_RESTRICTION to indicate SubStatus.
        //

        if( ntStatus == STATUS_ACCOUNT_RESTRICTION )
        {
            ntStatus = ntSubStatus;
        }

        goto Cleanup;
    }

    *pfAsGuest = !!( pProfile->UserFlags & LOGON_GUEST );

Cleanup:

    if( pProfile != NULL )
    {
        LsaFreeReturnBuffer( (PVOID)pProfile );
    }

    if( pInfo != NULL )
    {
        free( pInfo );
    }

    if( DomainName.Buffer != NULL )
    {
        RtlFreeUnicodeString( &DomainName );
    }

    if( UserName.Buffer != NULL )
    {
        RtlFreeUnicodeString( &UserName );
    }

    if( UnicodePassword.Buffer != NULL )
    {
        RtlFreeUnicodeString( &UnicodePassword );
    }

    return hToken;

}   // GetNetLogonToken



BOOL APIENTRY SecureInit()
{

    NTSTATUS Status;
    LONG lErr;
    DWORD dw;
    
    lErr = RegCreateKeyEx( HKEY_LOCAL_MACHINE,
            "Software\\Microsoft\\RPCToken", 0, "Class",
            REG_OPTION_VOLATILE, KEY_ALL_ACCESS, NULL, &hKeyRPCToken, &dw);

    Status = InitializeAuthentication( );

    if (!NT_SUCCESS(Status))
        {
        /* sprintf( chMsgBuffer, "InitializeAuthentication failed, status = 0x%lx", Status); */
        /* MessageBox( NULL,  chMsgBuffer, "John Service", MB_OK); */
        return(FALSE);
        }
    else
        {
        /* sprintf( chMsgBuffer, "Process = %d", GetCurrentProcessId()); */
        /* MessageBox( NULL,  chMsgBuffer, "John Service", MB_OK); */
        return(TRUE);
        }
}


BOOL APIENTRY SecureClose()
{

    CloseHandle(LsaHandle);
    RegCloseKey(hKeyRPCToken);
    return(TRUE);
}
    

