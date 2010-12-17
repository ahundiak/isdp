/* $Revision: 1.1 $ */
#include "dba.ext"

extern char *dba_timestamp_format, *dba_mslink, *dba_table_order;

/* Function:	dba_free_dbnuc */
int dba_free_dbnuc ()
{
  dba_dfree (dba_timestamp_format);
  dba_dfree (dba_table_order);
  dba_dfree (dba_mslink);

  return (0);
}
