/* $Revision: 1.1 $ */

#include "dba.ext"
#if defined RIS4
#include "sql.h"
#else
#include "ris.h"
#endif

#if defined __WIN32__
int dba_net_sql_code;
extern int dba_use_server_flag;
#endif

/* Function:	dba_get_sqlcode */
int dba_get_sqlcode ()
{
#if defined __WIN32__
  if (dba_use_server_flag) return(dba_net_sql_code);   
#endif
  return (SQLCODE);
}
