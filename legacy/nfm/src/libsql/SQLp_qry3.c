#include "sql.h"
static short RIScpp_stmt_id0 = -1;

#line 1 "SQLp_qry3.rc"
#include "machine.h"
#include "SQL.h"

 extern long   SQLquery_count;
 extern struct SQLglobal_st SQLglobal ;

 long SQLfix_qry_prep_3 ()
   {
     static char *fname = "SQLfix_qry_prep_3" ;

#line 10 "SQLp_qry3.rc"

long status;

#line 11 "SQLp_qry3.rc"

char sql_str[512];

#line 13 "SQLp_qry3.rc"


     sprintf (sql_str, "SELECT %s FROM %s WHERE %s = ? AND %s = ?",
     "n_tableno", "NFMTABLES", "n_tabletype", "n_tablename");
     
     _SQLdebug ((fname, "Sql Str = <%s>\n", sql_str));

{RISint_prepare(&RIScpp_stmt_id0,sql_str,1,0);
}

#line 20 "SQLp_qry3.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_PREPARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Prepare Failed : <0x%.8x>\n", status));
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 25 "SQLp_qry3.rc"

/*        ERRload_struct (SQL, status, NULL); */
        return (status);
      }
         
     _SQLdebug ((fname, "SUCCESSFUL\n")) ;
     return (SQL_S_SUCCESS);
   }

 long SQLfix_qry_res_3 (table_type, table_name, table_no)

#line 35 "SQLp_qry3.rc"

char * table_type;

#line 36 "SQLp_qry3.rc"

char * table_name;

#line 37 "SQLp_qry3.rc"

int * table_no;

#line 39 "SQLp_qry3.rc"

   {
     static char *fname = "SQLfix_qry_res_3" ;

#line 42 "SQLp_qry3.rc"

long status;

#line 43 "SQLp_qry3.rc"

int t_table_no;

#line 44 "SQLp_qry3.rc"

long ind1;

#line 46 "SQLp_qry3.rc"

     char sql_str [512] ;

     SQLquery_count = SQLquery_count + 1;
/*     _SQLdebug ((fname, "SQL QUERY NO = <%d>\n", SQLquery_count)); */

    *table_no = 0;

/*    _SQLdebug ((fname, "Tab Type = <%s> : Tab Name = <%s>\n", 
	table_type, table_name)); */
     
   if (! SQLglobal.prep[3]) 
   {
	status = SQLfix_qry_prep_3 () ;
        if (status != SQL_S_SUCCESS)
        {
           _SQLdebug ((fname, "Failure : status = <0x%.8x>\n", status));
	   return (status) ;
        }
	SQLglobal.prep[3] = 1 ;
   }

     sprintf (sql_str, "SELECT %s FROM %s WHERE %s = '%s' AND %s = '%s'",
     "n_tableno", "NFMTABLES", "n_tabletype", table_type,
      "n_tablename", table_name);

     _SQLdebug ((fname, "Fix Qry 3 : %s\n", sql_str)) ;

/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 74 "SQLp_qry3.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_DECLARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Declare Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 79 "SQLp_qry3.rc"

/*        ERRload_struct (SQL, status, NULL); */
        return (status);
      }

{{
	static sqlvar in_sqlvar[2] = {
		{0,0,1,0,0,0,{0,""}},
		{0,0,1,0,0,0,{0,""}}
	};
	static sqlda in_sqlda = {2,2,in_sqlvar};
	in_sqlvar[1].sqldata = table_name;
	in_sqlvar[1].sqllen = strlen(table_name);
	in_sqlvar[0].sqldata = table_type;
	in_sqlvar[0].sqllen = strlen(table_type);
RISint_execute(&RIScpp_stmt_id0,0,&in_sqlda,7,1,0);
}
}

#line 84 "SQLp_qry3.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_OPEN, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Open Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 89 "SQLp_qry3.rc"

/*        ERRload_struct (SQL, status, NULL); */
        return (status);
      }

{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&t_table_no;
	out_sqlvar[0].sqlind = &ind1;
RISint_fetch(RIScpp_stmt_id0,0,&out_sqlda,0,7);
}
}

#line 94 "SQLp_qry3.rc"

     if (SQLCODE)
      {
        if (SQLCODE != END_OF_DATA)
         {
           status = SQLerror (SQL_E_FETCH, risca -> sqlerrd [2], SQLCODE);
           _SQLdebug ((fname, "Fetch Failed : <0x%.8x>\n", status));
         }
        else
         {
/*           status = SQLerror (SQL_I_NO_ROWS_FOUND, 
                    risca -> sqlerrd [2], SQLCODE); */
	   status = SQL_I_NO_ROWS_FOUND ;
           _SQLdebug ((fname, "No Rows Found : <0x%.8x>\n", status));
	   ERRload_struct (SQL, status, NULL) ;
         }

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 111 "SQLp_qry3.rc"

/*        ERRload_struct (SQL, status, NULL); */
        return (status);
     }
       
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 116 "SQLp_qry3.rc"

    if (SQLCODE)
     {
       status = SQLerror (SQL_E_CLOSE, risca -> sqlerrd [2], SQLCODE);
       _SQLdebug ((fname, "Close Failed : <0x%.8x>\n", status));
/*       ERRload_struct (SQL, status, NULL); */
       return (status);
     }

    if (ind1 < 0)    *table_no = 0;
    else             *table_no = t_table_no;

    _SQLdebug ((fname, "Table No = <%d> : SUCCESSFUL\n", *table_no));

    return (SQL_S_SUCCESS);
  }

SQLp_free_3()
{
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 135 "SQLp_qry3.rc"

}
