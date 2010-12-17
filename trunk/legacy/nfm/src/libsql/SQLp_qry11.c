#include "sql.h"
static short RIScpp_stmt_id0 = -1;

#line 1 "SQLp_qry11.rc"
#include "machine.h"
#include "SQL.h"

 extern long   SQLquery_count;
 extern struct SQLglobal_st SQLglobal ;

 long SQLfix_qry_prep_11 ()
   {
     static char *fname = "SQLfix_qry_prep_11";

#line 10 "SQLp_qry11.rc"

long status;

#line 11 "SQLp_qry11.rc"

char sql_str[112];

#line 13 "SQLp_qry11.rc"


     sprintf (sql_str, 
     "SELECT %s FROM NFMPROJECTS WHERE %s=? ",
     "n_projectno ", "n_projectname");
     
     _SQLdebug ((fname, "Sql Str = <%s>\n", sql_str));

{RISint_prepare(&RIScpp_stmt_id0,sql_str,1,0);
}

#line 21 "SQLp_qry11.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_PREPARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Prepare Failed : <0x%.8x>\n", status));
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 26 "SQLp_qry11.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }
         
     _SQLdebug ((fname, "SUCCESSFUL\n")) ;
     return (SQL_S_SUCCESS);
   }

   long SQLfix_qry_res_11 (project,projno)

#line 36 "SQLp_qry11.rc"

char * project;

#line 37 "SQLp_qry11.rc"

int * projno;

#line 39 "SQLp_qry11.rc"

   {
     static char *fname = "SQLfix_qry_res_11" ;

#line 42 "SQLp_qry11.rc"

long status;

#line 43 "SQLp_qry11.rc"

int t_projno;

#line 44 "SQLp_qry11.rc"

long ind1;

#line 46 "SQLp_qry11.rc"

     char sql_str [200] ;

     SQLquery_count = SQLquery_count + 1;
/*     _SQLdebug ((fname, "SQL QUERY NO = <%d>\n", SQLquery_count)); */

/*    _SQLdebug ((fname, "Project = <%s>  ", project)); */
     
   if (! SQLglobal.prep[11]) 
   {
	status = SQLfix_qry_prep_11 () ;
        if (status != SQL_S_SUCCESS)
        {
           _SQLdebug ((fname, "Failure : status = <0x%.8x>\n", status));
	   return (status) ;
        }
	SQLglobal.prep[11] = 1 ;
   }
     sprintf (sql_str,
     "SELECT %s FROM NFMPROJECTS WHERE %s= '%s' ",
     "n_projectno ", "n_projectname", project);

     _SQLdebug ((fname, "Fix Qry 11 : %s\n", sql_str)) ;
 
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 70 "SQLp_qry11.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_DECLARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Declare Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 75 "SQLp_qry11.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }

{{
	static sqlvar in_sqlvar[1] = {
		{0,0,1,0,0,0,{0,""}}
	};
	static sqlda in_sqlda = {1,1,in_sqlvar};
	in_sqlvar[0].sqldata = project;
	in_sqlvar[0].sqllen = strlen(project);
RISint_execute(&RIScpp_stmt_id0,0,&in_sqlda,7,1,0);
}
}

#line 80 "SQLp_qry11.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_OPEN, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Open Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 85 "SQLp_qry11.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }

{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&t_projno;
	out_sqlvar[0].sqlind = &ind1;
RISint_fetch(RIScpp_stmt_id0,0,&out_sqlda,0,7);
}
}

#line 90 "SQLp_qry11.rc"

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

#line 105 "SQLp_qry11.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
     }
       
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 110 "SQLp_qry11.rc"

    if (SQLCODE)
     {
       status = SQLerror (SQL_E_CLOSE, risca -> sqlerrd [2], SQLCODE);
       _SQLdebug ((fname, "Close Failed : <0x%.8x>\n", status));
       ERRload_struct (SQL, status, NULL);
       return (status);
     }


    if (ind1 < 0)  
    {
	  *projno = 0;
    }
    else 
    {
            *projno = t_projno;
    }

    _SQLdebug ((fname, "Project No = <%d> : SUCCESSFUL\n", t_projno));

    return (SQL_S_SUCCESS);
  }

SQLp_free_11()
{
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 136 "SQLp_qry11.rc"

}
