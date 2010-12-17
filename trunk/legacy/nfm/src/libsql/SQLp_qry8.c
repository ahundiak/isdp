#include "sql.h"
static short RIScpp_stmt_id0 = -1;

#line 1 "SQLp_qry8.rc"
#include "machine.h"
#include "SQL.h"

 extern long   SQLquery_count;
 extern struct SQLglobal_st SQLglobal ;

 long SQLfix_qry_prep_8 ()
   {
     static char *fname= "SQLfix_qry_prep_8" ;

#line 10 "SQLp_qry8.rc"

long status;

#line 11 "SQLp_qry8.rc"

char sql_str[400];

#line 13 "SQLp_qry8.rc"


     sprintf (sql_str, 
     "SELECT %s %s FROM %s WHERE %s=? AND %s=? AND %s AND %s",
     "b.n_userno,d.n_logonsuccess,d.n_logonfailure,",
     "d.n_notify,d.n_transitionname", 
     "NFMACCESS a,NFMACLUSERS b,NFMACLS c, NFMTRANSITIONS d", 
     "d.n_commandno ", "b.n_userno ",
     "a.n_transitionno=d.n_transitionno AND c.n_workflowno=d.n_workflowno",
     "c.n_aclno=b.n_aclno AND a.n_classno=b.n_classno");
     
     _SQLdebug ((fname, "Sql Str = <%s>\n", sql_str));

{RISint_prepare(&RIScpp_stmt_id0,sql_str,1,0);
}

#line 26 "SQLp_qry8.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_PREPARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Prepare Failed : <0x%.8x>\n", status));
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 31 "SQLp_qry8.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }
         
     _SQLdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     SQL_S_SUCCESS));
     return (SQL_S_SUCCESS);
   }

   long SQLfix_qry_res_8 (cmd_no,user_no,u_out,
		          log_f,log_s,notify,trans_name)

#line 43 "SQLp_qry8.rc"

int cmd_no;

#line 44 "SQLp_qry8.rc"

int user_no;

#line 45 "SQLp_qry8.rc"

int * u_out;

#line 46 "SQLp_qry8.rc"

char * log_f;

#line 47 "SQLp_qry8.rc"

char * log_s;

#line 48 "SQLp_qry8.rc"

char * notify;

#line 49 "SQLp_qry8.rc"

char * trans_name;

#line 51 "SQLp_qry8.rc"

   {
     static char *fname = "SQLfix_qry_res_8" ;

#line 54 "SQLp_qry8.rc"

long status;

#line 55 "SQLp_qry8.rc"

int t_user_no;

#line 56 "SQLp_qry8.rc"

long ind1;

#line 57 "SQLp_qry8.rc"

long ind2;

#line 58 "SQLp_qry8.rc"

long ind3;

#line 59 "SQLp_qry8.rc"

long ind4;

#line 60 "SQLp_qry8.rc"

long ind5;

#line 61 "SQLp_qry8.rc"

char t_log_s[5];

#line 62 "SQLp_qry8.rc"

char t_log_f[5];

#line 63 "SQLp_qry8.rc"

char t_notify[5];

#line 64 "SQLp_qry8.rc"

char t_transname[30];

#line 66 "SQLp_qry8.rc"

     char sql_str [512] ;

     SQLquery_count = SQLquery_count + 1;
/*     _SQLdebug ((fname, "SQL QUERY NO = <%d>\n", SQLquery_count)); */

/*    _SQLdebug ((fname, "Command No = <%d> : User No = <%d>\n",  
	cmd_no, user_no)); */
     
   if (! SQLglobal.prep[8]) 
   {
	status = SQLfix_qry_prep_8 () ;
        if (status != SQL_S_SUCCESS)
        {
           _SQLdebug ((fname, "Failure : status = <0x%.8x>\n", status));
	   return (status) ;
        }
	SQLglobal.prep[8] = 1 ;
   }

     sprintf (sql_str,
     "SELECT %s %s FROM %s WHERE %s=%d AND %s=%d AND %s AND %s",
     "b.n_userno,d.n_logonsuccess,d.n_logonfailure,",
     "d.n_notify,d.n_transitionname",
     "NFMACCESS a,NFMACLUSERS b,NFMACLS c, NFMTRANSITIONS d",
     "d.n_commandno ", cmd_no, "b.n_userno ", user_no,
     "a.n_transitionno=d.n_transitionno AND c.n_workflowno=d.n_workflowno",
     "c.n_aclno=b.n_aclno AND a.n_classno=b.n_classno");

     _SQLdebug ((fname, "Fix Qry 8 : %s\n", sql_str)) ;

/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 97 "SQLp_qry8.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_DECLARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Declare Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 102 "SQLp_qry8.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }

{{
	static sqlvar in_sqlvar[2] = {
		{0,0,4,0,4,0,{0,""}},
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda in_sqlda = {2,2,in_sqlvar};
	in_sqlvar[1].sqldata = (char *)&user_no;
	in_sqlvar[0].sqldata = (char *)&cmd_no;
RISint_execute(&RIScpp_stmt_id0,0,&in_sqlda,7,1,0);
}
}

#line 107 "SQLp_qry8.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_OPEN, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Open Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 112 "SQLp_qry8.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }

{{
	static sqlvar out_sqlvar[5] = {
		{0,0,4,1,4,0,{0,""}},
		{0,0,1,1,5,0,{0,""}},
		{0,0,1,1,5,0,{0,""}},
		{0,0,1,1,5,0,{0,""}},
		{0,0,1,1,30,0,{0,""}}
	};
	static sqlda out_sqlda = {5,5,out_sqlvar};
	out_sqlvar[4].sqldata = t_transname;
	out_sqlvar[4].sqlind = &ind5;
	out_sqlvar[3].sqldata = t_notify;
	out_sqlvar[3].sqlind = &ind4;
	out_sqlvar[2].sqldata = t_log_f;
	out_sqlvar[2].sqlind = &ind3;
	out_sqlvar[1].sqldata = t_log_s;
	out_sqlvar[1].sqlind = &ind2;
	out_sqlvar[0].sqldata = (char *)&t_user_no;
	out_sqlvar[0].sqlind = &ind1;
RISint_fetch(RIScpp_stmt_id0,0,&out_sqlda,0,7);
}
}

#line 118 "SQLp_qry8.rc"

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
           _SQLdebug ((fname, "No Rows Found : <0x%.8x>\n", status));
         }

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 133 "SQLp_qry8.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
     }
       
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 138 "SQLp_qry8.rc"

    if (SQLCODE)
     {
       status = SQLerror (SQL_E_CLOSE, risca -> sqlerrd [2], SQLCODE);
       _SQLdebug ((fname, "Close Failed : <0x%.8x>\n", status));
       ERRload_struct (SQL, status, NULL);
       return (status);
     }

    if (ind1 < 0)  
    {
	  *u_out = 0;
    }
    else 
    {
            *u_out = t_user_no;
    }
    if(ind2 < 0)
    {
	  log_s[0] = 0;
    }
    else
    {
          strcpy(log_s,t_log_s);
    }
    if(ind3 < 0)
    {
	  log_f[0] = 0;
    }
    else 
    {
	  strcpy(log_f,t_log_f);
    }
    if(ind4 < 0)
    {
	  notify[0] = 0;
    }
    else
    {
	    strcpy(notify,t_notify);

    }
    if(ind5 < 0)
    {
	  trans_name[0] = 0;
    }
    else
    {
         strcpy(trans_name,t_transname);
    }
    _SQLdebug ((fname, "User No = <%d> : Logon Success = <%s> : Logon Failure = <%s> : Notify = <%s> : Transition Name = <%s> : SUCCESSFUL\n", 
	t_user_no, t_log_s, t_log_f, t_notify, t_transname));

    return (SQL_S_SUCCESS);
  }

SQLp_free_8()
{
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 196 "SQLp_qry8.rc"

}
