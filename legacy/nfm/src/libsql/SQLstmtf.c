#include "machine.h"
#include "SQL.h"

 extern struct SQLglobal_st SQLglobal ;

 long   NFM_SQL_LOCK = 0;

 long SQLstmt_VAR (sql_str)
char     *sql_str;
{
  char     *fname = "SQLstmt_VAR" ;
  long     i;
  long     status;
  
  _SQLdebug ((fname, "ENTER\n")) ;
  NFM_SQL_LOCK = 0;
  
  status = SQLstmt_lock_filter (sql_str);
  
  if (SQLglobal.db_type == 'X')
    {
      i = 0;
      
      while (((SQLglobal.DBerror_no >> 16) == 107) ||
	     ((SQLglobal.DBerror_no >> 16) == 113) ||
	     ((SQLglobal.DBerror_no >> 16) == 134) ||
	     ((SQLglobal.DBerror_no >> 16) == 144) ||
	     ((SQLglobal.DBerror_no & 0x0000ffff) == 243) ||
	     ((SQLglobal.DBerror_no & 0x0000ffff) == 244) ||
	     ((SQLglobal.DBerror_no & 0x0000ffff) == 245) ||
	     ((SQLglobal.DBerror_no & 0x0000ffff) == 246))
	{
	  SQLglobal.DBerror_no = 0;
	  
	  _SQLdebug ((fname, "Retry No = <%d>\n", i));
	  
	  sleep (2);
	  status = SQLstmt_lock_filter (sql_str);
	  
	  i = i + 1;
	  
	  if (i == 60) break;
	}
    }       
  
  if ((SQLglobal.db_type == 'X') &&
      (((SQLglobal.DBerror_no >> 16) == 107) ||
       ((SQLglobal.DBerror_no >> 16) == 113) ||
       ((SQLglobal.DBerror_no >> 16) == 134) ||
       ((SQLglobal.DBerror_no >> 16) == 144) ||
       ((SQLglobal.DBerror_no >> 16) == 143) ||
       ((SQLglobal.DBerror_no >> 16) == 154) ||
       ((SQLglobal.DBerror_no & 0x0000ffff) == 243) ||
       ((SQLglobal.DBerror_no & 0x0000ffff) == 244) ||
       ((SQLglobal.DBerror_no & 0x0000ffff) == 245) ||
       ((SQLglobal.DBerror_no & 0x0000ffff) == 246)))
    {
      NFM_SQL_LOCK = 1;
    }
  
  _SQLdebug ((fname, "SUCCESSFUL\n")) ;
  return (status);     
}  






