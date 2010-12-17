/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

/* Function:	dba_inq_process_script */
void dba_inq_process_script (script)
char *script;
{
  int (*func)();

  if (!script || !strlen (script)) return;

  func = (int (*)()) dba_inq_service (DBA_PROCESS_SCRIPT);
  if (func) 
    (*func) (script);
  else
    dba_add_error (dba_get_msg (DBA_E_NO_SCRIPT, NP,0,NP,NP));
}
