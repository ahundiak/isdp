#include "dba.ext"

extern int dba_use_server_flag;

/* Function:	dba_exit_dbnuc */
int dba_exit_dbnuc ()
{
  dba_clear_schema_list ();
  dba_free_dbnuc ();
  
  if (!dba_use_server_flag)
    RISterminate ();

  return (0);
}
