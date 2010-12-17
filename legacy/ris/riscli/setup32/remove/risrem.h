/* Do not alter this SPC information: $Revision: 1.13.3.1 $ */
#include <windows.h>

/*
  Applications must set remInstance to the instance of their program
*/ 
HINSTANCE remInstance;

/* This function removes the application's entry from the RefList field    */
/* in the RIS Shared Component registry key. If the RefList field is empty */
/* it deletes the registry key and returns 1. It returns a 0 otherwise.    */
extern INT RegRemoveRIS (HINSTANCE remInstance, CHAR *listEntry);
extern INT RegRemoveRISEx(LPTSTR version_string, CHAR *listEntry);

/* Applications must call RegRemoveRIS first and pass in the return	*/
/* value as the argument to this function.				*/
extern VOID RemoveRIS (HINSTANCE remInstance, INT remove_flag);
extern void RemoveRISEx ( LPTSTR version_string, BOOLEAN delete_tmp_dir,
	BOOLEAN ask_delete, int remove_flag);

extern VOID CloseRemoveLogFile(VOID);
extern VOID WriteToRemoveLogFile(LPSTR szFileName,int iLineNumber,LPSTR szStr);
