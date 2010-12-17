/* $Revision: 1.1 $ */
#include "dba.ext"
#include "script.def"

#if defined RIS4
#include "sql.h"
#include "rislimit.h"
#include "ris.prt"
#elif defined RIS5
#include "ris.h"
#include "rislimit.h"
#include "ris.prt"
#else
#include "sql.h"
#include "RISlimits.h"
#include "RISprototype.h"
#endif

#define VF (void (*)())

/*
    Function:	dba_register_dbnuc
    Author:	Tim A. Thompson
    Date:	06-DEC-92

    Revisions:
	2-26-93  -- Copied from dba_register_core.
*/

int dba_register_dbnuc()
{
  static int first_flag;
  int istat;

  if (first_flag)
    return SCRERR_SUCCESS;
  else
    first_flag = 1;

  /**********************/
  /*  Pseudo Registered Function:  DBA_ADD_QUERY  */
  /**********************/
  istat = dba_pseudo_reg_func ("dba_add_query", VF dba_s_add_query, 0);
  if (istat)
    return istat;

  /**********************/
  /*  Pseudo Registered Function:  DBA_GET_QUERY  */
  /**********************/
  istat = dba_pseudo_reg_func ("dba_get_query", VF dba_s_get_query, 0);
  if (istat)
    return istat;

  /**********************/
  /*  Pseudo Registered Function:  DBA_GET_CODE_TEXT  */
  /**********************/
  istat = dba_pseudo_reg_func ("dba_get_code_text", VF dba_s_get_code_number_text, DBA_GET_CODE_TEXT);
  if (istat)
    return istat;

  /**********************/
  /*  Pseudo Registered Function:  DBA_SELECT  */
  /**********************/
  istat = dba_pseudo_reg_func ("dba_select", VF dba_s_select, 0);
  if (istat)
    return istat;

  /**********************/
  /*  Pseudo Registered Function:  DBA_FETCH  */
  /**********************/
  istat = dba_pseudo_reg_func ("dba_fetch", VF dba_s_fetch, 0);
  if (istat)
    return istat;

  dba_reg_default_argnum_enforce_on ();

  /**********************/
  /*  Registered Function:  RISdatetime_to_ascii  */
  /**********************/
  istat = dba_reg_func_start ("RISdatetime_to_ascii", VF RISdatetime_to_ascii);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("date");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("buffer");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_buffered_expand (1000);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("format");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  RISascii_to_datetime  */
  /**********************/
  istat = dba_reg_func_start ("RISascii_to_datetime", VF RISascii_to_datetime);
  if (istat)
    return istat;
  istat = dba_reg_set_func_attr (SCR_CHAR, 0, 1, 1);
  istat = dba_reg_arg_start ("date");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("buffer");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("format");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  dba_reg_default_verbose_on (VERB_DBA_FUNCTIONS, 0L);

  /**********************/
  /*  Registered Function:  DBA_SETUP_CONVERT_INPUT  */
  /**********************/
  istat = dba_reg_func_start ("dba_setup_convert_input", VF dba_setup_convert_input);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("script_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_SETUP_CONVERT_OUTPUT  */
  /**********************/
  istat = dba_reg_func_start ("dba_setup_convert_output", VF dba_setup_convert_output);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("script_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_INITIALIZE_QUERY  */
  /**********************/
  istat = dba_register_function ("dba_initialize_query", VF dba_initialize_query);
  if (istat)
    return istat;

  /**********************/
  /*  Registered Function:  DBA_SET_SCHEMA_LIST  */
  /**********************/
  istat = dba_reg_func_start ("dba_set_schema_list", VF dba_set_schema_list);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema_list");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_SET_TABLE_LIST  */
  /**********************/
  istat = dba_reg_func_start ("dba_set_table_list", VF dba_set_table_list);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("list");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_ADD_TO_TABLE_LIST  */
  /**********************/
  istat = dba_reg_func_start ("dba_add_to_table_list", 
    VF dba_add_to_table_list);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_DELETE_FROM_TABLE_LIST  */
  /**********************/
  istat = dba_reg_func_start ("dba_delete_from_table_list", 
    VF dba_delete_from_table_list);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_SCHEMA_SELECT  */
  /**********************/
  istat = dba_reg_func_start ("dba_schema_select", VF dba_schema_select);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_TABLE_SELECT  */
  /**********************/
  istat = dba_reg_func_start ("dba_table_select", VF dba_table_select);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_INIT_TABLE_QUERY  */
  /**********************/
  istat = dba_reg_func_start ("dba_init_table_query", VF dba_init_table_query);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_SAVE_QUERY */
  /**********************/
  istat = dba_reg_func_start ("dba_save_query", VF dba_save_query);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("library");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("template");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("description");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("query_text");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_ADD_QUERY_STRING  */
  /**********************/
  istat = dba_reg_func_start ("dba_add_query_string", VF dba_add_query_string);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("logical");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("string");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_READ_SCHEMA  */
  /**********************/
  istat = dba_reg_func_start ("dba_read_schema", VF dba_read_schema);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("file");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_WRITE_SCHEMA  */
  /**********************/
  istat = dba_reg_func_start ("dba_write_schema", VF dba_write_schema);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("file");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_GET_CODE_NUMBER  */
  /**********************/
  istat = dba_reg_func_start ("dba_get_code_number", VF dba_get_code_number);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("column");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("code_number");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_LONG, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_output (1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("code_text");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_FLUSH_TABLE  */
  /**********************/
  istat = dba_reg_func_start ("dba_flush_table", VF dba_flush_table);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_FLUSH_CODELIST  */
  /**********************/
  istat = dba_reg_func_start ("dba_flush_codelist", VF dba_flush_codelist);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("column");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_FLUSH_SCHEMA  */
  /**********************/
  istat = dba_reg_func_start ("dba_flush_schema", VF dba_flush_schema);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_GET_SCHEMA_NAME_BY_NUMBER */
  /**********************/
  istat = dba_reg_func_start ("dba_get_schema_name_by_number", 
      VF dba_get_schema_name_by_number);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("number");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_buffered_expand (33);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_GET_SCHEMA_NUMBER_BY_NAME  */
  /**********************/
  istat = dba_reg_func_start ("dba_get_schema_number_by_name", 
    VF dba_get_schema_number_by_name);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("number");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_output (1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_GET_TABLE_NAME_BY_NUMBER */
  /**********************/
  istat = dba_reg_func_start ("dba_get_table_name_by_number", 
    VF dba_get_table_name_by_number);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("number");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_buffered_expand (33);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_GET_TABLE_NUMBER_BY_NAME  */
  /**********************/
  istat = dba_reg_func_start ("dba_get_table_number_by_name", 
    VF dba_get_table_number_by_name);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("number");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_output (1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_GET_COLUMN_NAME_BY_NUMBER */
  /**********************/
  istat = dba_reg_func_start ("dba_get_column_name_by_number", 
      VF dba_get_column_name_by_number);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("number");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("column");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_buffered_expand (33);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_GET_COLUMN_NUMBER_BY_NAME  */
  /**********************/
  istat = dba_reg_func_start ("dba_get_column_number_by_name", 
    VF dba_get_column_number_by_name);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("column");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("number");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_output (1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_CONVERT_DATE */
  /**********************/
  istat = dba_reg_func_start ("dba_convert_date", VF dba_convert_date);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("dest");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_buffered_expand (40);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("source");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();

  /**********************/
  /*  Registered Function:  DBA_SET_TABLE_NUMBER_BY_NAME  */
  /**********************/
  istat = dba_reg_func_start ("dba_set_table_number_by_name", 
    VF dba_get_table_number_by_name);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("number");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_SET_TABLE_ALIAS */
  /**********************/
  istat = dba_reg_func_start ("dba_set_table_alias", VF dba_set_table_alias);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (0, 0, 0, 0, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("table");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("alias");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  dba_reg_default_verbose_off ();

  /**********************/
  /*  Registered Function:  DBA_SQL  */
  /**********************/
  istat = dba_reg_func_start ("dba_sql", VF dba_sql);
  if (istat)
    return istat;
  istat = dba_reg_set_func_verbose (VERB_RIS_FUNCTIONS, 20);
  istat = dba_reg_arg_start ("command");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_REPORT_RIS_ERROR  */
  /**********************/
  istat = dba_reg_func_start ("dba_report_ris_error", VF dba_report_ris_error);
  if (istat)
    return istat;
  istat = dba_reg_set_func_verbose (VERB_RIS_FUNCTIONS, 0);
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_CLOSE_CURSOR  */
  /**********************/
  istat = dba_reg_func_start ("dba_close_cursor", VF dba_close_cursor);
  if (istat)
    return istat;
  istat = dba_reg_set_func_verbose (VERB_RIS_FUNCTIONS, 0);
  istat = dba_reg_arg_start ("cursor");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  dba_reg_default_argnum_enforce_off ();

  return SCRERR_SUCCESS;
}
