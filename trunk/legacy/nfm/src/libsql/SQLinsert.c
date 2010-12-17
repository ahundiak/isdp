#include "sql.h"
static short RIScpp_stmt_id0 = -1;

#line 1 "SQLinsert.rc"
#include "machine.h"
#include "MEMstruct.h"
#include "SQL.h"

 char   *malloc (), *calloc ();

 /*
	Function for multiple inserts.
	sql_str should be INSERT INTO table (a,b,c,d) VALUES(?,?,?,?)
	bufr should be built and should contain the data to be inserted	
	the order of the data should correspond 
 */

 long  SQLmultiple_insert(sql_str, list)

#line 15 "SQLinsert.rc"

char * sql_str;

#line 17 "SQLinsert.rc"

    MEMptr   list;
    {
       static char *fname = "SQLmultiple_insert" ;

#line 21 "SQLinsert.rc"

long status;

#line 22 "SQLinsert.rc"

long i,  x,  k,  nx;

#line 23 "SQLinsert.rc"

sqlda in_desc;

#line 24 "SQLinsert.rc"

sqlda out_desc;

#line 25 "SQLinsert.rc"

char * * format,  * * data;

#line 27 "SQLinsert.rc"

       
/*
       RIS  DEBUG FLAGS TURNED ON

       RISbuf_debug = 1;
       RIScom_debug = 1;
       DD_debug     = 1;
       RIStrn_debug = 1;

       RIS  DEBUG FLAGS TURNED OFF

       RISbuf_debug = 0;
       RIScom_debug = 0;
       DD_debug     = 0;
       RIStrn_debug = 0;
*/

       _SQLdebug ((fname, "Qry  Str  = <%s>  ", sql_str));
       _SQLdebug ((fname, "List Addr = <%d>  ", list  ));

	if(!list->rows)
	{
 	 _SQLdebug ((fname, "SUCCESSFUL No rows to Insert:status = <0x%.8x>\n", 
	 SQL_S_SUCCESS));
         return (SQL_S_SUCCESS);
        }

	data = (char **) list->data_ptr;
	format = (char **) list->format_ptr;

       /* prepare a dynamic SQL statement */

{RISint_prepare(&RIScpp_stmt_id0,sql_str,1,0);
}

#line 60 "SQLinsert.rc"

       if (SQLCODE)
        {
              status = SQLerror (SQL_E_PREPARE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname, "Prepare Failed : status = <0x%.8x>\n",
              status));

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 68 "SQLinsert.rc"

           ERRload_struct (SQL, status, NULL);
           return (status);
        }

       in_desc.sqld = 0;
       in_desc.sqln = 0;
       in_desc.sqlvar = 0;

       /* get the count of input columns */

{RISint_describe(RIScpp_stmt_id0,&in_desc,0);
}

#line 79 "SQLinsert.rc"

       if (SQLCODE)
        {
             status = SQLerror (SQL_E_DESCRIBE,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Describe Failed : status = <0x%.8x>\n",
             status));
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 86 "SQLinsert.rc"

          ERRload_struct (SQL, status, NULL);
          return (status);
        }

       if (in_desc.sqld != list->columns)
        {
          status = SQLerror (SQL_E_DESCRIBE,
                      risca -> sqlerrd [1], SQLCODE);
          _SQLdebug ((fname, "Input Mismatch : status = <0x%.8x>\n",
          status));
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 97 "SQLinsert.rc"

          ERRload_struct (SQL, status, NULL);
          return (status);
        }

       in_desc.sqlvar = (sqlvar *) calloc (in_desc.sqld, sizeof (sqlvar));
       if (! in_desc.sqlvar)
        {
          status = SQLerror (SQL_E_MALLOC, 0, 0);
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 106 "SQLinsert.rc"

          _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Calloc failed");
          return (status);
        }
       in_desc.sqln = in_desc.sqld;

{RISint_describe(RIScpp_stmt_id0,&in_desc,0);
}

#line 113 "SQLinsert.rc"

       if (SQLCODE)
        {
          status = SQLerror (SQL_E_DESCRIBE,
                      risca -> sqlerrd [1], SQLCODE);
          _SQLdebug ((fname, "Describe Failed : status = <0x%.8x>\n",
             status));
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 120 "SQLinsert.rc"

          free (in_desc.sqlvar);
          ERRload_struct (SQL, status, NULL);
          return (status);
        }           

       for (i = 0; i < in_desc.sqld; ++i)
        {
           in_desc.sqlvar [i].sqldata =  calloc (1, in_desc.sqlvar [i].sqllen);
           if (! in_desc.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (in_desc.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (in_desc.sqlvar [x].sqlind);

             status = SQLerror (SQL_E_MALLOC, 0, 0);
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 135 "SQLinsert.rc"

             free (in_desc.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          in_desc.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! in_desc.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (in_desc.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (in_desc.sqlvar [x].sqlind);

              status = SQLerror (SQL_E_MALLOC, 0, 0);
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 150 "SQLinsert.rc"

              free (in_desc.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }


     for(k = 0; k < list->rows ; k++)
     {
       nx = list->columns * k;

       for (i = 0; i < in_desc.sqld; ++i)
       {
           if(!strlen(data[nx+i]))
           {
		strcpy(in_desc.sqlvar[i].sqldata,"");
		*in_desc.sqlvar[i].sqlind = -1;
		in_desc.sqlvar[i].sqlnull = 1;
	   }
	   else
	   {
		strcpy(in_desc.sqlvar[i].sqldata,"");
		*in_desc.sqlvar[i].sqlind = 0;
		in_desc.sqlvar[i].sqlnull = 0;

           switch (in_desc.sqlvar [i].sqltype)
            {
              case CHARACTER :

                strncpy (in_desc.sqlvar[i].sqldata,data[nx+i],
			 in_desc.sqlvar[i].sqllen);
                break;

              case INTEGER   :
                sscanf (data[nx+i],"%d", (int *)in_desc.sqlvar[i].sqldata);
                break;

              case SMALLINT  :
                sscanf (data[nx+i],"%hd", (int *)in_desc.sqlvar[i].sqldata);
                break;

              case DOUBLE    :
                sscanf (data[nx+i],"%lf", (double *)in_desc.sqlvar[i].sqldata);
                break;

              case REAL      :
                sscanf (data[nx+i],"%f", (float *)in_desc.sqlvar[i].sqldata);
                break;

              case DECIMAL   :
                strncpy (in_desc.sqlvar[i].sqldata,data[nx+i],
			 in_desc.sqlvar[i].sqllen);
                break;

              case DATETIME   :
                strncpy (in_desc.sqlvar[i].sqldata,data[nx+i],
			 in_desc.sqlvar[i].sqllen);
                break;

              default :
                status = SQLerror (SQL_E_DATA_TYPE, 0, 0);
                for (x = 0; x < in_desc.sqld; ++x)
                   free (in_desc.sqlvar [x].sqldata);

                for (x = 0; x < in_desc.sqld; ++x)
                   free (in_desc.sqlvar [x].sqlind);
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 219 "SQLinsert.rc"

                free (in_desc.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            } /* end of switch */
	   } 
       }	/* for (i = 0; i < in_desc.sqld; ++i) */

{RISint_execute(&RIScpp_stmt_id0,0,&in_desc,7,1,0);
}

#line 229 "SQLinsert.rc"

       if (SQLCODE)
        {
          status = SQLerror (SQL_E_EXECUTE,
                      risca -> sqlerrd [1], SQLCODE);
          _SQLdebug ((fname, "Execute Failed : status = <0x%.8x>\n",
             status));
          for (x = 0; x < in_desc.sqld; ++x)
              free (in_desc.sqlvar [x].sqldata);
          for (x = 0; x < in_desc.sqld; ++x)
              free (in_desc.sqlvar [x].sqlind);
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 240 "SQLinsert.rc"

          free (in_desc.sqlvar);
          ERRload_struct (SQL, status, NULL);
          return (status);
        }
     }	/* for(k = 0; k < list->rows ; k++) */

          for (x = 0; x < in_desc.sqld; ++x)
              free (in_desc.sqlvar [x].sqldata);

          for (x = 0; x < in_desc.sqld; ++x)
              free (in_desc.sqlvar [x].sqlind);
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 252 "SQLinsert.rc"

          free (in_desc.sqlvar);

    _SQLdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", SQL_S_SUCCESS));
    return (SQL_S_SUCCESS);
    }
