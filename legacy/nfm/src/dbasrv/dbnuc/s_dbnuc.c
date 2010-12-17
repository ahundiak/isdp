/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

/* Function:	dba_setup_dbnuc */
void dba_setup_dbnuc ()
{
  dba_register_init (INIT_DBNUC, dba_init_dbnuc);
}
