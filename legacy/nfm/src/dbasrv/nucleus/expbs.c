/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_expand_backslash */
void dba_expand_backslash (char * instring, char * outstring)
{
  int ii, jj, len;

  if (!instring) return;

  len = strlen(instring);
  for (ii = 0, jj = 0; ii < len; ii++)
  {
    outstring[jj++] = instring[ii];
    if (instring[ii] == '\\')
    {
      outstring[jj++] = '\\';
    }
  } 
  outstring[jj] = '\0';
}
