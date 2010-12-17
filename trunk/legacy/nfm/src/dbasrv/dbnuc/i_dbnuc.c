/* $Revision: 1.15 $ */
#include "dba.ext"
#include "keys.def"
#include "ris.h"

ris_text dba_textcol;

extern char *dba_schema_list, *dba_timestamp_format, *dba_mslink, 
  *dba_table_order;
extern int dba_db_numbers, dba_autocommit, dba_code_sort, dba_optimize,
  dba_no_mscatalog;

/* Function:	dba_init_dbnuc */
int dba_init_dbnuc ()
{
  char *char_ptr, *getenv();
  int status;

  char_ptr = getenv ("DBA_AUTOCOMMIT");
  if (char_ptr) dba_autocommit = 1;

  char_ptr = getenv ("DBA_CODE_SORT");
  if (char_ptr) dba_code_sort = 1;

  char_ptr = getenv ("DBA_OPTIMIZE");
  if (char_ptr) dba_optimize = 1;

  char_ptr = getenv ("DBA_DB_NUMBERS");
  if (char_ptr) dba_db_numbers = 1;

  char_ptr = getenv ("DBA_NO_MSCATALOG");
  if (char_ptr) dba_no_mscatalog = 1;
  
  dba_timestamp_format = dba_getenv ("DBA_TIMESTAMP_FORMAT");
  if (dba_timestamp_format[0] == 0)
    strcpy (dba_timestamp_format, "yyyy-mm-dd:hh:nn:ss");

  dba_table_order = dba_getenv ("DBA_TABLE_ORDER");

  dba_mslink = dba_getenv ("DBA_MSLINK");
  if (dba_mslink[0] == 0) strcpy (dba_mslink, "mslink");

  char_ptr = getenv ("DBA_CONVERT_INPUT");
  if (char_ptr) dba_setup_convert_input (char_ptr);

  char_ptr = getenv ("DBA_CONVERT_OUTPUT");
  if (char_ptr) dba_setup_convert_output (char_ptr);

  dba_set_schema_list (dba_schema_list);

  dba_register_service (DBA_RPT_RIS_ERR, dba_report_ris_error);
  dba_register_service (DBA_PARSE_ATT, dba_parse_att);
  dba_register_service (DBA_ATTACH_DB, dba_attach_db);
  dba_register_service (DBA_LOAD_FIND, dba_load_find);
  dba_register_service (DBA_LOAD_RELATIONS, dba_load_relations);
  dba_register_service (DBA_PARSE_ENT, dba_parse_ent);
  dba_register_service (DBA_EXIT_DBNUC, dba_exit_dbnuc);

  memset (&dba_textcol, 0, sizeof (ris_text));
  dba_textcol.filename = "";
  dba_textcol.file_used = 0;

  status = dba_register_dbnuc ();
  return (status);
}
