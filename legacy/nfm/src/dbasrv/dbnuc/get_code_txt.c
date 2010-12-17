/* $Revision: 1.1 $ */
#include "dba.ext"
extern char *dba_errtxt;

/* Function:	dba_get_code_text */
int dba_get_code_text (schema, table, column, code_number, code_text)
char *schema, *table, *column, *code_text;
long code_number;
{
  int status;
  int alen=0;
  struct dba_ent *tent=0;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  status = dba_find_codeval (code_number, tent->schema, tent->entnam, column, 
    code_text, &alen);
  if (status) return (status);

  return (0);
}
