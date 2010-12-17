#include "sql.h"

#line 1 "SQLexec_imm.rc"
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
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples         status = MEMopen (&list, 512);                   *
*                                                                   *
* Also See                                                          *
*                                                                   *
* History                                                           *
*                   Date         : December 11 90                   *
*                                                                   *
*                                                                   *
*********************************************************************
********************************************************************/

#include "SQL.h"

 long SQLexec_imm (sql_str)

#line 35 "SQLexec_imm.rc"

char * sql_str;

#line 37 "SQLexec_imm.rc"

    {
       static char *fname = "SQLexec_imm" ;

#line 40 "SQLexec_imm.rc"

long status;

#line 41 "SQLexec_imm.rc"

sqlda out_desc;

#line 43 "SQLexec_imm.rc"


       _SQLdebug ((fname, "SQL STMT : <%s>\n", sql_str));

{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_str,0,7,0,0);
}

#line 47 "SQLexec_imm.rc"

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


