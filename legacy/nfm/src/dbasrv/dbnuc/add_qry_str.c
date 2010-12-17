/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"
extern char *dba_errtxt;

/* Function:	dba_add_query_string */
int dba_add_query_string (logical, schema, table, value)
char *logical, *schema, *table, *value;
{
  char and_or[4];
  int status;
  int (*func)();
  struct dba_ent *tent;
  struct dba_find *tfind;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  if (!tent->ffind) strcpy (and_or, "   ");
  else { strncpy (and_or, logical, 3);  and_or[3] = 0; }

  dba_malloc_find (&tfind, NP);
  tfind->text_lng = strlen (value) + 10;
  tfind->text = dba_drealloc (tfind->text, tfind->text_lng);

  sprintf (tfind->text, " %s %s", and_or, value);

  dba_add_find_ptr (&tent->ffind, &tent->lfind, tfind);
  func = dba_inq_service (DBA_PAINT_FIND);
  if (func) (*func) (tent);
  strcpy (dba_errtxt, dba_get_msg (DBA_M_FIND_ADDED, NP,0,NP,NP));

  return (0);
}
