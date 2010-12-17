/* $Revision: 1.8 $ */
#include "dba.ext"
#include "cursor.def"

#if defined RIS4
#include "sql.h"
#include "rislimit.h"
#elif defined RIS5
#include "ris.h"
#include "ris_err.h"
#include "rislimit.h"
#else
#include "sql.h"
#include "RISerror.h"
#include "RISlimits.h"
#endif

extern char *dba_errtxt, *dba_mslink;
extern int dba_append_msg;

/* Function:	dba_key_columns

Description: 	locates the key columns for the specified entity

Author: 	Brian Potter
*/
int dba_key_columns (schema, ent_ptr)
char *schema;
struct dba_ent *ent_ptr;
{
  char sqltxt[400];
  char *char_ptr, key_columns[RIS_MAX_CHAR_STRING_SIZE + 1], 
    key_column[RISMAX], index_name[RISMAX], previous_index[RISMAX];
  int status, old_append_msg, first=1;
  struct dba_att *tatt;

  old_append_msg = dba_append_msg;
  dba_append_msg = 0;
  status = dba_set_att_ptr (ent_ptr, ent_ptr->entnam, dba_mslink, &tatt, 1, 0);
  dba_append_msg = old_append_msg;
  if (!status)
    { tatt->key = 1;
    ent_ptr->num_keys = 1;
    ent_ptr->key_rec = tatt->abyt + 2;
    return (0); }

  sprintf (sqltxt,
    "select key_columns from %s.mscatalog where tablename = '%s'",
    schema, ent_ptr->entnam);
  status = dba_select (DBA_C1, NP, sqltxt);
  if (status != RIS_SUCCESS) goto no_mscat_key;
  status = dba_fetch (DBA_C1, NP, key_columns, NP); 
  if (status == END_OF_DATA) goto no_mscat_key;
  if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }
  status = dba_close_cursor (DBA_C1);
  if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }

  char_ptr = key_columns;
  while (dba_parse_string (&char_ptr, key_column, ' ', 1))
    { dba_errtxt[0] = 0;
    status = dba_set_att_ptr (ent_ptr, ent_ptr->entnam, key_column, &tatt, 1,0);
    if (status) 
      { dba_add_error (dba_errtxt);  continue; }
    tatt->key = 1;
    ++ent_ptr->num_keys;
    ent_ptr->key_rec += tatt->abyt + 2; }
  if (ent_ptr->num_keys) return (0);

no_mscat_key:
  sprintf (sqltxt,
#if defined RIS5
    "select ris5indexes.index_name, column_name \
from %s.ris5indexes, ris5index_columns where ris5indexes.table_name = '%s' \
and index_type = 'U' and ris5indexes.index_name = ris5index_columns.index_name",
#else
    "select risindexes.index_name, column_name \
from %s.risindexes, risindex_columns where risindexes.table_name = '%s' \
and index_type = 'U' and risindexes.index_name = risindex_columns.index_name",
#endif
    schema, ent_ptr->entnam);

select:
  status = dba_select (DBA_C1, NP, sqltxt);
#if defined RIS5
  if (first
      && (status == RIS_E_UNKNOWN_RELATION
      || status == RIS_E_CANT_ACCESS_V5_DICT_OBJECT)) {
    first = 0;
    sprintf (sqltxt,
      "select risindexes.index_name, column_name \
from %s.risindexes, risindex_columns where risindexes.table_name = '%s' \
and index_type = 'U' and risindexes.index_name = risindex_columns.index_name",
      schema, ent_ptr->entnam);
      goto select;
    }
#endif
  if (status != RIS_SUCCESS) return (0);

  for (;;) 
    { status = dba_fetch (DBA_C1, NP, index_name, NP, key_column, NP);
    if (status == END_OF_DATA) break;
    if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }
    if (strlen (previous_index) && strcmp (previous_index, index_name)
      && ent_ptr->num_keys) break;
    strcpy (previous_index, index_name);
    status = dba_set_att_ptr (ent_ptr, ent_ptr->entnam, key_column, &tatt, 1,0);
    if (status) {
      dba_add_error (dba_errtxt);
      continue;
    }
    if (tatt->atyp == ATT_DATE || tatt->atyp == ATT_RIS_TEXT)
      continue;
      
    tatt->key = 1;
    ++ent_ptr->num_keys;
    ent_ptr->key_rec += tatt->abyt + 2; }
  status = dba_close_cursor (DBA_C1);
  if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }

  return (0);
}
