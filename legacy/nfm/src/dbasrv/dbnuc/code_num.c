/* $Revision: 1.1 $ */
#include "dba.ext"
extern char *dba_errtxt;

/* Function:	dba_get_code_number */
int dba_get_code_number (schema, table, column, code_number, code_text)
char *schema, *table, *column, *code_text;
long *code_number;
{
  int status;
  struct dba_ent *tent=0;

  dba_errtxt[0] = 0;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  status = dba_find_codenum (code_number, tent->schema, tent->entnam, column, 
    code_text);
  if (status) return (status);

  return (0);
}
