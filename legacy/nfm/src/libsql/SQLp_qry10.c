#include "sql.h"
static short RIScpp_stmt_id0 = -1;

#line 1 "SQLp_qry10.rc"
#include "machine.h"
#include "SQL.h"

 extern long   SQLquery_count;
 extern struct SQLglobal_st SQLglobal ;

 long SQLfix_qry_prep_10 ()
   {
     static char *fname = "SQLfix_qry_prep_10" ;

#line 10 "SQLp_qry10.rc"

long status;

#line 11 "SQLp_qry10.rc"

char sql_str[112];

#line 13 "SQLp_qry10.rc"


     sprintf (sql_str, 
     "SELECT %s FROM NFMPROJECTS WHERE %s=? ",
     "n_projectno,n_stateno,n_aclno ", "n_projectname");
     
     _SQLdebug ((fname, "Sql Str = <%s>\n", sql_str));

{RISint_prepare(&RIScpp_stmt_id0,sql_str,1,0);
}

#line 21 "SQLp_qry10.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_PREPARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Prepare Failed : <0x%.8x>\n", status));
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 26 "SQLp_qry10.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }
         
     _SQLdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     SQL_S_SUCCESS));
     return (SQL_S_SUCCESS);
   }

   long SQLfix_qry_res_10 (project,projno,stateno,aclno)

#line 37 "SQLp_qry10.rc"

char * project;

#line 38 "SQLp_qry10.rc"

int * projno;

#line 39 "SQLp_qry10.rc"

int * aclno;

#line 40 "SQLp_qry10.rc"

int * stateno;

#line 42 "SQLp_qry10.rc"

   {
     static char *fname = "SQLfix_qry_res_10" ;

#line 45 "SQLp_qry10.rc"

long status;

#line 46 "SQLp_qry10.rc"

int t_projno;

#line 47 "SQLp_qry10.rc"

int t_aclno;

#line 48 "SQLp_qry10.rc"

int t_stateno;

#line 49 "SQLp_qry10.rc"

long ind1;

#line 50 "SQLp_qry10.rc"

long ind2;

#line 51 "SQLp_qry10.rc"

long ind3;

#line 53 "SQLp_qry10.rc"

     char sql_str [200] ;

     SQLquery_count = SQLquery_count + 1;
/*     _SQLdebug ((fname, "SQL QUERY NO = <%d>\n", SQLquery_count)); */

/*    _SQLdebug ((fname, "Project = <%s>  ", project)); */
     
   if (! SQLglobal.prep[10]) 
   {
	status = SQLfix_qry_prep_10 () ;
        if (status != SQL_S_SUCCESS)
        {
           _SQLdebug ((fname, "Failure : status = <0x%.8x>\n", status));
	   return (status) ;
        }
	SQLglobal.prep[10] = 1 ;
   }

     sprintf (sql_str,
     "SELECT %s FROM NFMPROJECTS WHERE %s='%s' ",
     "n_projectno,n_stateno,n_aclno ", "n_projectname", project);
 
     _SQLdebug ((fname, "Fix Qry 10 : %s\n", sql_str)) ;

/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 78 "SQLp_qry10.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_DECLARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Declare Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 83 "SQLp_qry10.rc"

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

#line 88 "SQLp_qry10.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_OPEN, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Open Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 93 "SQLp_qry10.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }

{{
	static sqlvar out_sqlvar[3] = {
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {3,3,out_sqlvar};
	out_sqlvar[2].sqldata = (char *)&t_aclno;
	out_sqlvar[2].sqlind = &ind3;
	out_sqlvar[1].sqldata = (char *)&t_stateno;
	out_sqlvar[1].sqlind = &ind2;
	out_sqlvar[0].sqldata = (char *)&t_projno;
	out_sqlvar[0].sqlind = &ind1;
RISint_fetch(RIScpp_stmt_id0,0,&out_sqlda,0,7);
}
}

#line 99 "SQLp_qry10.rc"

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

#line 114 "SQLp_qry10.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
     }
       
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 119 "SQLp_qry10.rc"

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
    if(ind2 < 0)
    {
           *stateno = 0;
    }
    else
    {
           *stateno = t_stateno;
    }
    if(ind3 < 0)
    {
	   *aclno = 0;
    }
    else 
    {
	   *aclno = t_aclno;
    }

    _SQLdebug ((fname, "Project No = <%d>  : State No = <%d> : Acl No = <%d> : SUCCESSFUL\n", 
	t_projno, t_stateno, t_aclno));
    return (SQL_S_SUCCESS);
  }

SQLp_free_10()
{
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 160 "SQLp_qry10.rc"

}
