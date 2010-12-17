/* $Revision: 1.1 $ */
/* Function:	dld_dummy */

#include "stdio.h"

int dba_init_dloading ()
{
  return (0);
}

int dba_perform_dload ()
{
  fprintf (stderr, "This application was not linked with dload.o !!\n");
  fprintf (stderr, "dload.o must be linked in before dloading can be done !!\n");
  return (0);
}

void *dba_lookup_func_symbol () { return (0); }

void *dba_lookup_var_symbol () { return (0); }

int dba_dload_symbol_lookup () { return (0); }

