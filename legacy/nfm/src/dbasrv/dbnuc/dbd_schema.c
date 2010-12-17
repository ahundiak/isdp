/* $Revision: 1.1 $ */
#include "dba.ext"

int dba_schema_selected;
extern int dba_mnunum;
extern Form dba_form[];

/* Function:  dba_schema_select
   Author:    Tim A. Thompson
   Date:      22-APR-91 (Date moved from dba_s_schema_select)
*/

int dba_schema_select (schema)
char *schema;
{
  int status;

  dba_schema_selected = dba_mnunum;
  status = dba_attach_db (schema, 1);
  dba_schema_selected = 0;
  if (status) return (status);
  
  return (0);
}
