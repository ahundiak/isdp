/* $Revision: 1.1 $ */
#include "dba.ext"

extern char *dba_script_fldval, *dba_schema_list, *dba_raster, *dba_mem_ptr, 
  *dba_stext, *dba_fldval, *dba_lib, *dba_lib_list, *dba_delcond,
  *dba_datbas, *dba_error_log;
extern union dba_mixed *dba_value;

/* Function:	dba_free_globals */
int dba_free_globals ()
{
  dba_dfree (dba_stext);
  dba_dfree (dba_value);
  dba_dfree (dba_mem_ptr);
  dba_dfree (dba_fldval);
  dba_dfree (dba_script_fldval);
  dba_dfree (dba_delcond);
  dba_dfree (dba_lib);
  dba_dfree (dba_lib_list);
  dba_dfree (dba_raster);
  dba_dfree (dba_error_log);
  dba_dfree (dba_schema_list);
  dba_dfree (dba_datbas);

  return (0);
}
