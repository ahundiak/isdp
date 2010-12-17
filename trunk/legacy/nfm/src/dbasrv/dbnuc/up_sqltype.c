/* $Revision: 1.1 $ */
#include "dba.ext"

#if defined RIS5
#include "ris.h"
#else
#include "sql.h"
#endif

/* Function:	dba_upgrade_sqltype */
int dba_upgrade_sqltype (sqlvar_ptr)
sqlvar *sqlvar_ptr;
{
  switch (sqlvar_ptr->sqltype)
    { case 4: case 5:
      sqlvar_ptr->sqltype = sqlvar_ptr->sqllen = 4;
      break;
    case 3: case 7: case 8:
      sqlvar_ptr->sqltype = sqlvar_ptr->sqllen = 8;
      break; }

  return (0);
}
