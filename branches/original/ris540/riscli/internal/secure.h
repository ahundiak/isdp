/* Do not alter this SPC information: $Revision: 1.2.53.1 $ */
/*
   This was received from Microsoft for use with secure.c (now clisecur.c)
*/

#ifndef NTSTATUS
typedef LONG NTSTATUS;
#define NT_SUCCESS(Status) ((NTSTATUS)(Status) >= 0)
#endif


BOOL APIENTRY SecureInit(VOID);
BOOL APIENTRY SecureClose(VOID);
char * GetErrorString(VOID);
HANDLE GetForeignThreadHandle( DWORD Pid, DWORD dwThread);
HANDLE GetImpersonateToken( HANDLE hToken);
NTSTATUS SetThreadImpersonation( HANDLE hThread, HANDLE hToken);
HANDLE GetLogonToken( char *pszUser, char *pszDomain, char *pszPassword);
HANDLE GetNetLogonToken( CHAR * pszDomainName, CHAR * pszUserName,
		     CHAR * pszPassword, BOOL * pfAsGuest);
NTSTATUS SetProcessToken( HANDLE hProcess, HANDLE hThread, HANDLE hToken);

