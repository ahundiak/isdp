/* $Revision: 1.1 $ */
/* Function:	dba_get_autocommit */

int dba_get_autocommit()
{
  int autocommit;

  RISget_autocommit_mode(&autocommit);
  return (autocommit);
}
