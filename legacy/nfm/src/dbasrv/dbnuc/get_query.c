/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"

extern char *dba_errtxt;

/* Function:	dba_get_query */
int dba_get_query (schema, table, query)
char *schema, *table, **query;
{
  int status, fence=0, got_where=0;
  struct dba_ent *tent=0;
  static char *s1_ptr;
  static unsigned long s1_size=0;

  *query = 0;

  if (!s1_size) { s1_size = 100;  s1_ptr = dba_dmalloc (s1_size, DM_STATIC); }

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  fence = dba_inq_fence_exists();

  s1_ptr[0] = 0;
  status = dba_build_where (tent, &got_where, fence, 1, &s1_ptr, &s1_size, 0);
  if (status) return (status);

  *query = s1_ptr;

  return (0);
}
