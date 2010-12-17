/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

/* Function:	dba_setup_nfm */
void dba_setup_nfm ()
{
  dba_register_init (INIT_NFM, dba_init_nfm);
  dba_setup_script ();
}
