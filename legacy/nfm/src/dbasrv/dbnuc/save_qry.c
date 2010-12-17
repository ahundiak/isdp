/* $Revision: 1.1 $ */
#include "dba.ext"

extern char *dba_lib;

/* Function:	dba_save_query */
int dba_save_query (library, template, description, schema, table, query_text)
char *library, *template, *description, *schema, *table, *query_text;		
{
  char text[100];
  int status;
  struct dba_library *lib_ptr;
  struct dba_ent *tent=0;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  if (!library) library = dba_lib;

  status = dba_write_template (library, template, QUERY, 1, 1, &lib_ptr);
  if (status) return (status);

  sprintf (text, "Template_Type %d", QUERY);
  dba_put_record (lib_ptr, text, 0);
  sprintf (text, "Template_Name %s", template);
  dba_put_record (lib_ptr, text, 0);
  sprintf (text, "Template_Description '%s'", dba_tic_to_code (description));
  dba_put_record (lib_ptr, text, 0);

  sprintf (text, "Object_Entity %d.%s.", tent->schema, tent->entnam);
  dba_put_record (lib_ptr, text, 0);
  dba_put_record (lib_ptr, query_text, 0);

  dba_put_end (lib_ptr, (void *)0, 0);
  dba_lib_close (lib_ptr);

  return (0);
}
