#include "sql.h"
static short RIScpp_stmt_id0 = -1;

#line 1 "SQLp_qry12.rc"
#include "machine.h"
#include "SQL.h"

 extern long   SQLquery_count;
 extern struct SQLglobal_st SQLglobal ;

 long SQLfix_qry_prep_12 ()
   {
     static char *fname = "SQLfix_qry_prep_12" ;

#line 10 "SQLp_qry12.rc"

long status;

#line 11 "SQLp_qry12.rc"

char sql_str[122];

#line 13 "SQLp_qry12.rc"


     sprintf (sql_str, 
     "SELECT %s FROM NFMCATALOGS WHERE %s=? ",
     "n_catalogno ", "n_catalogname");
     
     _SQLdebug ((fname, "Sql Str = <%s>\n", sql_str));

{RISint_prepare(&RIScpp_stmt_id0,sql_str,1,0);
}

#line 21 "SQLp_qry12.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_PREPARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Prepare Failed : <0x%.8x>\n", status));
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 26 "SQLp_qry12.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }
         
     _SQLdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     SQL_S_SUCCESS));
     return (SQL_S_SUCCESS);
   }

   long SQLfix_qry_res_12 (catalog,catno)

#line 37 "SQLp_qry12.rc"

char * catalog;

#line 38 "SQLp_qry12.rc"

int * catno;

#line 40 "SQLp_qry12.rc"

   {
     static char *fname = "SQLfix_qry_res_12" ;

#line 43 "SQLp_qry12.rc"

long status;

#line 44 "SQLp_qry12.rc"

int t_catno;

#line 45 "SQLp_qry12.rc"

long ind1;

#line 47 "SQLp_qry12.rc"

     char sql_str [200] ;

     SQLquery_count = SQLquery_count + 1;
/*     _SQLdebug ((fname, "SQL QUERY NO = <%d>\n", SQLquery_count)); */

/*    _SQLdebug ((fname, "Catalog = <%s>  ", catalog)); */
     
   if (! SQLglobal.prep[12]) 
   {
	status = SQLfix_qry_prep_12 () ;
        if (status != SQL_S_SUCCESS)
        {
           _SQLdebug ((fname, "Failure : status = <0x%.8x>\n", status));
	   return (status) ;
        }
	SQLglobal.prep[12] = 1 ;
   }

     sprintf (sql_str,
     "SELECT %s FROM NFMCATALOGS WHERE %s='%s' ",
     "n_catalogno ", "n_catalogname", catalog);

    _SQLdebug ((fname, "Fix Qry 12 : %s\n", sql_str)) ;

/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 72 "SQLp_qry12.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_DECLARE, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Declare Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 77 "SQLp_qry12.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }

{{
	static sqlvar in_sqlvar[1] = {
		{0,0,1,0,0,0,{0,""}}
	};
	static sqlda in_sqlda = {1,1,in_sqlvar};
	in_sqlvar[0].sqldata = catalog;
	in_sqlvar[0].sqllen = strlen(catalog);
RISint_execute(&RIScpp_stmt_id0,0,&in_sqlda,7,1,0);
}
}

#line 82 "SQLp_qry12.rc"

     if (SQLCODE)
      {
        status = SQLerror (SQL_E_OPEN, risca -> sqlerrd [2], SQLCODE);
        _SQLdebug ((fname, "Open Failed : <0x%.8x>\n", status));
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 87 "SQLp_qry12.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
      }

{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&t_catno;
	out_sqlvar[0].sqlind = &ind1;
RISint_fetch(RIScpp_stmt_id0,0,&out_sqlda,0,7);
}
}

#line 92 "SQLp_qry12.rc"

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

#line 107 "SQLp_qry12.rc"

        ERRload_struct (SQL, status, NULL);
        return (status);
     }
       
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 112 "SQLp_qry12.rc"

    if (SQLCODE)
     {
       status = SQLerror (SQL_E_CLOSE, risca -> sqlerrd [2], SQLCODE);
       _SQLdebug ((fname, "Close Failed : <0x%.8x>\n", status));
       ERRload_struct (SQL, status, NULL);
       return (status);
     }

    if (ind1 < 0)  
    {
	  *catno = 0;
    }
    else 
    {
            *catno = t_catno;
    }

    _SQLdebug ((fname, "Catalog No = <%d>  : SUCCESSFUL ", t_catno));

    return (SQL_S_SUCCESS);
  }

SQLp_free_12()
{
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 137 "SQLp_qry12.rc"

}
