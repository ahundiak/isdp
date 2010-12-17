/* $Revision: 1.1 $ */
extern int dba_abort_flag;

/*	Function:	dba_abort
	Author:		Tim A. Thompson
	Date:		08-APR-91
*/

dba_abort ()
{
  dba_abort_flag = 1;
  return (0);
}
