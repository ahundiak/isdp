/* $Revision: 1.1 $ */
#include "dba.ext"
extern char *dba_errtxt;

/* Function:	dba_check_max14

Description:	checks the passed-in filespec to verify that the name
		does not exceed 14 characters

Author:         Brian Potter
*/
int dba_check_max14 (char_ptr)
char *char_ptr;
{
  int count, num;

/*
  for (count=strlen (char_ptr), num=0; count; --count, ++num)
    if (char_ptr[count-1] == '/') break;
  if (num > 14)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_MAX14, NP,0,NP,NP));
    return (99); }
*/    

  return (0);
}
