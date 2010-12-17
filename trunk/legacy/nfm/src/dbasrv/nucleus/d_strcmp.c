/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_strcmp */
int dba_strcmp (str1, str2)
char *str1, *str2;
{
  if (!str1 && !str2) return (0);
  if (!str1) return (-1);
  if (!str2) return (1);

  return (strcmp (str1, str2));
}
