#include "sql.h"
static short RIScpp_stmt_id0 = -1;

#line 1 "SQLstmt_VAR.rc"
#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         To execute a dynamic SQL statement.              *
*                                                                   *
* Arguements       long SQLstmt (str)                               *
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
*                   Developed by : Choudhary A Yarlagadda           *
*                   Date         : December 01 1987                 *
*                                                                   *
*                                                                   *
*********************************************************************
********************************************************************/

#include "SQL.h"

 long SQLstmt_count = 0;

 long SQLstmt_lock_filter (sql_str)

#line 38 "SQLstmt_VAR.rc"

char * sql_str;

#line 40 "SQLstmt_VAR.rc"

    {
       static char *fname = "SQLstmt_lock_filter";

#line 43 "SQLstmt_VAR.rc"

long status;

#line 44 "SQLstmt_VAR.rc"

sqlda out_desc;

#line 46 "SQLstmt_VAR.rc"


       SQLstmt_count = SQLstmt_count + 1;

       _SQLdebug ((fname, "SQL STMT : <%s>\n", sql_str));

       /* prepare a dynamic SQL statement */

{RISint_prepare(&RIScpp_stmt_id0,sql_str,1,0);
}

#line 54 "SQLstmt_VAR.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_PREPARE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname, "Prepare Failed : status = <0x%.8x>\n",
               status));
            }
           else
            {
/*              status = SQLerror (SQL_I_NO_ROWS_FOUND, 
                        risca -> sqlerrd [1], SQLCODE); */
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
              status));
	      ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 74 "SQLstmt_VAR.rc"

/*           ERRload_struct (SQL, status, NULL); */
           return (status);
        }
 
        /*
        **	if the statement is not a SELECT statement (sqld == 0),
        **		execute the statement.
        */
	
       out_desc.sqld = 0;
       out_desc.sqln = 0;
       out_desc.sqlvar = 0;

       /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id0,&out_desc,1);
}

#line 90 "SQLstmt_VAR.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DESCRIBE, risca -> sqlerrd [1],
                       SQLCODE);
              _SQLdebug ((fname, "Describe Failed : status = <0x%.8x>\n",
              status));
            }
           else
            {
/*              status = SQLerror (SQL_I_NO_ROWS_FOUND, 
                       risca -> sqlerrd [1], SQLCODE); */
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Row Found : status = <0x%.8x>\n",
              status));
	      ERRload_struct (SQL, status, NULL) ;
	      
            }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 111 "SQLstmt_VAR.rc"

/*           ERRload_struct (SQL, status, NULL); */
           return (status);
        }

       /* non-SELECT statements will have sqld == 0 (no result columns) */

       if (out_desc.sqld != 0)
        {
          status = SQLerror (SQL_E_NOT_STMT, 0, 0);
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 121 "SQLstmt_VAR.rc"

          _SQLdebug ((fname, "Not A SQL Statement : status = <0x%.8x>\n",
          status));
/*          ERRload_struct (SQL, status, NULL); */
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
}

#line 128 "SQLstmt_VAR.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_EXECUTE, risca -> sqlerrd [1],
                       SQLCODE); 
              _SQLdebug ((fname, "Execute Failed : status = <0x%.8x>\n",
              status));
            }
           else
            {
/*              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); */
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Row Found : status = <0x%.8x>\n",
              status));
	      ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 148 "SQLstmt_VAR.rc"

/*          ERRload_struct (SQL, status, NULL); */
          return (status);
        }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 153 "SQLstmt_VAR.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_CLEAR,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname, "Clear Failed : status = <0x%.8x>\n",
              status));
            }
           else
            {
/*              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); */
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Row Found : status = <0x%.8x>\n",
              status));
	      ERRload_struct (SQL, status, NULL) ;
            }
          return (status);
        }

       _SQLdebug ((fname, "SUCCESSFUL\n")) ;
       return (SQL_S_SUCCESS);
    }
