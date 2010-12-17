#include "ris.h"
static short RIScpp_stmt_id0 = -1;

#line 1 "r_prep_sql.rc"
/* $Revision: 1.1 $ */
#include "dba.ext"

extern char *dba_errtxt;

/* Function:	dba_ris_prepare_sql */
int dba_ris_prepare_sql (sqlptr)

#line 8 "r_prep_sql.rc"

char * sqlptr;

#line 10 "r_prep_sql.rc"

{
  if (!sqlptr) return (0);

{RISint_prepare(&RIScpp_stmt_id0,sqlptr,1,0);
}

#line 14 "r_prep_sql.rc"

  if (dba_get_sqlcode() != RIS_SUCCESS)
    { dba_sqlerr ();  return (99); }

  return (0);
}
