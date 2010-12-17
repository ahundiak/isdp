/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

/* Function:	dba_init_nfm */
int dba_init_nfm ()
{
  int status;

  dba_register_service (DBA_EXIT_NFM, dba_exit_nfm);
  dba_register_service (DBA_NFM_GET_MSG, dba_nfm_get_message);

  status = dba_register_nfm ();
  return (status);
}
