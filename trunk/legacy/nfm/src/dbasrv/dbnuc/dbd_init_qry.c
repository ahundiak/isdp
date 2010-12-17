/* $Revision: 1.1 $ */
#include "dba.ext"
extern int dba_error;

/*	Function:	dba_initialize_query
	Author:		Tim A. Thompson
	Date:		08-APR-91
*/

int dba_initialize_query ()
{
  dba_error = dba_init_find ();
  if (dba_error == 98) dba_error = 0;
  return (dba_error);
}
