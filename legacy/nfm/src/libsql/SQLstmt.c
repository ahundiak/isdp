#include "sql.h"

#line 1 "SQLstmt.rc"
#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         To execute a dynamic SQL statement.              *
*                                                                   *
* Arguements       long SQLexec_imm (str)                           *
*                    char   str;                                    *
*                                                                   *
* Algorithm        This routine takes the input statement and then  *
*                  does a 
*                                                                   *
* Return Status     MEM_S_SUCCESS : Success.                        *
*                   MEM_E_MALLOC  : Failure.                        *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *

* Also See                                                          *
*                                                                   *
* History  : Date 01-31-92 exec_imm should be faster than a prepared*
*            declared stmt                                          *
*                                                                   *
*********************************************************************
********************************************************************/

#include "SQL.h"

 long SQLstmt (sql_str)

#line 31 "SQLstmt.rc"

char * sql_str;

#line 33 "SQLstmt.rc"

    {
       static char *fname = "SQLexec_imm" ;

#line 36 "SQLstmt.rc"

long status;

#line 37 "SQLstmt.rc"

sqlda out_desc;

#line 39 "SQLstmt.rc"


       _SQLdebug ((fname, "SQL STMT : <%s>\n", sql_str));

{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_str,0,7,0,0);
}

#line 43 "SQLstmt.rc"

       if (SQLCODE)
       {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_EXECUTE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname, "Execute Failed : status = <0x%.8x>\n",
               status));	
            }
           else
            {
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
	_SQLdebug ((fname, "status <0x%.8x>\n", status)) ;
	return (status) ;
       }

       _SQLdebug ((fname, "SUCCESSFUL\n")) ;
       return (SQL_S_SUCCESS);
    }


