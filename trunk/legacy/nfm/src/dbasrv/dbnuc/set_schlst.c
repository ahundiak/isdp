/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"

extern char *dba_schema_list;

/* Function:	dba_set_schema_list 

Description: 	builds a schema list from the specified string

Author: 	Brian Potter
*/
int dba_set_schema_list (text_ptr)
char *text_ptr;
{
  char schema[RISMAX], *list_ptr=0;

  dba_clear_schema_list ();

  if (text_ptr && strlen (text_ptr)) 
    list_ptr = (char *) dba_dstrdup (text_ptr, DM_GLOBAL);

  if (dba_schema_list) {
    dba_dfree (dba_schema_list);
    dba_schema_list = 0;
  }
  if (list_ptr) 
    dba_schema_list = (char *) dba_dstrdup (list_ptr, DM_GLOBAL);
  else
    return (0);

  list_ptr = dba_schema_list;
  while (dba_parse_string (&list_ptr, schema, ' ', 1)) {
    dba_add_schema (schema);
  }
  return (0);
}
