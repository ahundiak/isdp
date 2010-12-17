/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"

/* Function:	dba_ustrcmp */
int dba_ustrcmp (str1, str2)
char *str1, *str2;
{
  char *s1, *s2;
  int status;

  s1 = dba_dstrdup (str1, DM_TMP);
  s2 = dba_dstrdup (str2, DM_TMP);
  dba_upper (s1);
  dba_upper (s2);
  
  status = strcmp (s1, s2);
  dba_dfree (s1);
  dba_dfree (s2);
  return (status);
}
