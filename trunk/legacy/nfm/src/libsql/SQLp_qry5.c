#include "sql.h"
static short RIScpp_stmt_id0 = -1;

#line 1 "SQLp_qry5.rc"
#include "machine.h"
#include "SQL.h"

 extern long   SQLquery_count;
 extern struct SQLglobal_st SQLglobal ;

 long SQLfix_qry_prep_5 ()
   {
     static char *fname = "SQLfix_qry_prep_5" ;

#line 10 "SQLp_qry5.rc"

long status;

#line 11 "SQLp_qry5.rc"

char sql_str[200];

#line 13 "SQLp_qry5.rc"


     sprintf (sql_str, 
     "SELECT %s FROM %s WHERE %s = ? AND %s = ? AND %s = ? AND %s",
     "b.n_userno", "NFMACCESS a,NFMACLUSERS b", 
      "a.n_transitionno ", "b.n_userno ",
      "b.n_aclno ", "a.n_classno = b.n_classno");
     
     _SQLdebug ((fname, "Sql Str = <%s>\n", sql_str)) ;

{RISint_prepare(&RIScpp_stmt_id0,sql_str,1,0);
}

#line 23 "SQLp_qry5.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_PREPARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Prepare Failed : <0x%.8x>\n", status));
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 28 "SQLp_qry5.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }
         
     _SQLdebug ((fname, "SUCCESSFUL\n")) ;
     return (SQL_S_SUCCESS);
   }

   long SQLfix_qry_res_5 (user_no,trans_no, acl_no,u_out)

#line 38 "SQLp_qry5.rc"

int user_no;

#line 39 "SQLp_qry5.rc"

int trans_no;

#line 40 "SQLp_qry5.rc"

int acl_no;

#line 41 "SQLp_qry5.rc"

int * u_out;

#line 43 "SQLp_qry5.rc"

   {
     static char *fname = "SQLfix_qry_res_5" ;

#line 46 "SQLp_qry5.rc"

long status;

#line 47 "SQLp_qry5.rc"

int t_user_no;

#line 48 "SQLp_qry5.rc"

long ind1;

#line 49 "SQLp_qry5.rc"

char sql_str[200];

#line 51 "SQLp_qry5.rc"


     SQLquery_count = SQLquery_count + 1;
/*     _SQLdebug ((fname, "SQL QUERY NO = <%d>\n", SQLquery_count)); */

/*    _SQLdebug ((fname, "Trans No = <%d> : User No = <%d> : ACL No = <%d>\n",
	 trans_no, user_no, acl_no)); */

   if (! SQLglobal.prep[5]) 
   {
	status = SQLfix_qry_prep_5 () ;
        if (status != SQL_S_SUCCESS)
        {
           _SQLdebug ((fname, "Failure : status = <0x%.8x>\n", status));
	   return (status) ;
        }
	SQLglobal.prep[5] = 1 ;
   }

    sprintf (sql_str,
     "SELECT %s FROM %s WHERE %s = %d AND %s = %d AND %s = %d AND %s",
     "b.n_userno", "NFMACCESS a,NFMACLUSERS b",
      "a.n_transitionno ", trans_no,
      "b.n_userno ", user_no,
      "b.n_aclno ", acl_no,
      "a.n_classno = b.n_classno");

     _SQLdebug ((fname, "Fix Qry 5 : %s\n", sql_str)) ;

/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 80 "SQLp_qry5.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_DECLARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Declare Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 85 "SQLp_qry5.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }

{{
	static sqlvar in_sqlvar[3] = {
		{0,0,4,0,4,0,{0,""}},
		{0,0,4,0,4,0,{0,""}},
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda in_sqlda = {3,3,in_sqlvar};
	in_sqlvar[2].sqldata = (char *)&acl_no;
	in_sqlvar[1].sqldata = (char *)&user_no;
	in_sqlvar[0].sqldata = (char *)&trans_no;
RISint_execute(&RIScpp_stmt_id0,0,&in_sqlda,7,1,0);
}
}

#line 90 "SQLp_qry5.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_OPEN, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Open Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 95 "SQLp_qry5.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }

{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&t_user_no;
	out_sqlvar[0].sqlind = &ind1;
RISint_fetch(RIScpp_stmt_id0,0,&out_sqlda,0,7);
}
}

#line 100 "SQLp_qry5.rc"

     if (SQLCODE)
      {
        if (SQLCODE != END_OF_DATA)
         {
           status = SQLerror (SQL_E_FETCH, risca -> sqlerrd [2], SQLCODE);
           _SQLdebug ((fname, "Fetch Failed : <0x%.8x>\n", status));
         }
        else
         {
           status = SQLerror (SQL_I_NO_ROWS_FOUND, 
                    risca -> sqlerrd [2], SQLCODE);
           _SQLdebug ((fname, "Rows Found : <0x%.8x>\n", status));
         }

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 115 "SQLp_qry5.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
     }
       
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 120 "SQLp_qry5.rc"

    if (SQLCODE)
     {
       status = SQLerror (SQL_E_CLOSE, risca -> sqlerrd [2], SQLCODE);
       _SQLdebug ((fname, "Close Failed : <0x%.8x>\n", status));
       ERRload_struct (SQL, status, NULL);
       return (status);
     }

    if (ind1 < 0)    *u_out = 0;
    else             *u_out = t_user_no;

    _SQLdebug ((fname, "User No = <%d>  : SUCCESSFUL\n", t_user_no));

    return (SQL_S_SUCCESS);
  }


SQLp_free_5()
{
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 140 "SQLp_qry5.rc"

}
