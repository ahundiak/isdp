/* $Revision: 1.1 $ */
#include "dba.ext"

#if defined RIS5
#include "ris.h"
#else
#include "sql.h"
#endif

/*
    Function:	dba_get_desc_index
    Author:	Tim A. Thompson
    Date:	15-JAN-91

    Description:	Returns index into sqlvar array of column name or
			desc->sqld if not found, one past end of array

    Revisions:
	11-18-93 -- Was calling strcmp instead of strncmp.
*/

int dba_get_desc_index (name, desc)
char *name;
sqlda *desc;
{
  int j, len;

  len = strlen (name);
  for (j=0; j<desc->sqld; ++j)
    if (desc->sqlvar[j].sqlname.sqlnamel == len &&
        !strncmp(name, desc->sqlvar[j].sqlname.sqlnamec, len))
      break;
  return (j);
}
