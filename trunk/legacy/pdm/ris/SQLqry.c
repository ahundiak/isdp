#include "ris.h"
static short RIScpp_stmt_id0 = -1;
#include "SQL.h"

/* #define SQL 8  this was done when we went from GH to Apogee */
 extern struct SQLglobal_st SQLglobal ;

/* long   PDMSQLquery_count = 0;*/

 char   *malloc (), *calloc ();

 long  PDMSQLquery (sql_str, list, size)

char * sql_str;

    MEMptr   *list;
    long     size;
    {
       static char *fname = "PDMSQLquery" ;

long status;

long i,  x,  NEW_LIST;

sqlda out_desc;

char data_type[30],  data[30];

char * str,  * data1;

char * * format;

datetime * ptr;

char column_name[50];

       char message [100];
       char datax [128];
         long   daa;
       
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

/*
       PDMSQLquery_count = PDMSQLquery_count + 1;
*/
/*       _SQLdebug ((fname, "SQL QUERY NO = <%d>\n", PDMSQLquery_count)); */

       _SQLdebug ((fname, "Qry  Str  = <%s> : List Addr = <%d> : Size = <%d>\n", 
	sql_str, *list, size));

       /* prepare a dynamic SQL statement */
	
{RISint_prepare(&RIScpp_stmt_id0,sql_str,1,0);
}

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

/*           ERRload_struct (SQL, status, NULL); */
           return (status);
        }

       /*
       **	if the statement is a SELECT statement (sqld != 0),
       **		declare a cursor for, open, and fetch from the statement.
       */

       out_desc.sqld = 0;
       out_desc.sqln = 0;
       out_desc.sqlvar = 0;

       /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id0,&out_desc,1);
}

       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             status = SQLerror (SQL_E_DESCRIBE, 
                      risca -> sqlerrd [1], SQLCODE); 
             _SQLdebug ((fname, "Describe Failed : status = <0x%.8x>\n",
             status));
           }
          else                       
           {
/*             status = SQLerror (SQL_I_NO_ROWS_FOUND,
                      risca -> sqlerrd [1], SQLCODE); */
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

/*          ERRload_struct (SQL, status, NULL); */
          return (status);
        }

       /* non-SELECT statements will have sqld == 0 (no result columns) */

       if (out_desc.sqld == 0)
        {
          status = SQLerror (SQL_E_NOT_QUERY, 0 , 0);
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

          _SQLdebug ((fname, "Not A Query Statement : status = <0x%.8x>\n",
          status));
/*          ERRload_struct (SQL, status, NULL); */
          return (status);
        }

       if (! (*list))
        {
          status = MEMopen (list, size);
          if (status != MEM_S_SUCCESS)
           {
/*              status = SQLerror (SQL_E_MEM, 0, status); */
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

              _SQLdebug ((fname, "MEM Open Failed : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
           }

          NEW_LIST = 1;
        }
       else
        {
           status = MEMbuild_array (*list);
           if (status != MEM_S_SUCCESS)
            {
/*              status = SQLerror (SQL_E_MEM, 0, status); */
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
            }
           
           NEW_LIST = 0;

           format = (char **) (*list) -> format_ptr;
        }

       out_desc.sqlvar = (sqlvar *) calloc (out_desc.sqld, sizeof (sqlvar));
       if (! out_desc.sqlvar)
        {
/*          status = SQLerror (SQL_E_MALLOC, 0, 0); */
	  status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

          if (NEW_LIST) MEMclose (list);
          _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Calloc failed");
          return (status);
        }

       out_desc.sqln = out_desc.sqld;

{RISint_describe(RIScpp_stmt_id0,&out_desc,1);
}

       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             if (NEW_LIST) MEMclose (list);
             status = SQLerror (SQL_E_DESCRIBE,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Describe Failed : status = <0x%.8x>\n",
             status));
           }
          else
           {
/*             status = SQLerror (SQL_I_NO_ROWS_FOUND,
                      risca -> sqlerrd [1], SQLCODE); */
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

          free (out_desc.sqlvar);
/*          ERRload_struct (SQL, status, NULL); */
          return (status);
        }
           
       for (i = 0; i < out_desc.sqld; ++i)
        {
          out_desc.sqlvar [i].sqldata =
                 calloc (1, out_desc.sqlvar [i].sqllen);
          if (! out_desc.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc.sqlvar [x].sqlind);

/*             status = SQLerror (SQL_E_MALLOC, 0, 0); */
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

             if (NEW_LIST) MEMclose (list);
             free (out_desc.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc.sqlvar [x].sqlind);

/*              status = SQLerror (SQL_E_MALLOC, 0, 0); */
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

              if (NEW_LIST) MEMclose (list);
              free (out_desc.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc.sqld)
           {
/*             status = SQLerror (SQL_E_NO_FORMAT_MISMATCH, 0, 0); */
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc.sqld; ++x)
                free (out_desc.sqlvar [x].sqldata);

             for (x = 0; x < out_desc.sqld; ++x)
                free (out_desc.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

             if (NEW_LIST) MEMclose (list);
             free (out_desc.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }

       for (i = 0; i < out_desc.sqld; ++i)
        {
           memset (data_type, 0, 29);

           switch (out_desc.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc.sqlvar[i].sqllen);
                break;

              case INTEGER   :
                strcpy (data_type, "integer");
                break;

              case SMALLINT  :
                strcpy (data_type, "smallint");
                break;

              case DOUBLE    :
                strcpy (data_type, "double");
                break;

              case REAL      :
                strcpy (data_type, "real");
                break;

              case DECIMAL   :
                strcpy (data_type, "decimal");
                break;

              case DATETIME   :
                strcpy (data_type, "timestamp");
                break;

              default :
/*                status = SQLerror (SQL_E_DATA_TYPE, 0, 0); */
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc.sqld; ++x)
                   free (out_desc.sqlvar [x].sqldata);

                for (x = 0; x < out_desc.sqld; ++x)
                   free (out_desc.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

                if (NEW_LIST) MEMclose (list);
                free (out_desc.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	          strncpy (column_name, out_desc.sqlvar [i].sqlname.sqlnamec,
				       out_desc.sqlvar [i].sqlname.sqlnamel) ;
		      column_name [out_desc.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
/*                 status = SQLerror (SQL_E_MEM, 0, status); */
                 for (x = 0; x < out_desc.sqld; ++x)
                   free (out_desc.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc.sqld; ++x)
                   free (out_desc.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.8x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
/*                 status = SQLerror (SQL_E_FORMAT_MISMATCH, 0, 0); */

		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc.sqld; ++x)
                   free (out_desc.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc.sqld; ++x)
                   free (out_desc.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             if (NEW_LIST) MEMclose (list);
             status = SQLerror (SQL_E_DECLARE,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Declare Failed : status = <0x%.8x>\n",
             status));
           }
          else
           {
/*             status = SQLerror (SQL_I_NO_ROWS_FOUND,
                      risca -> sqlerrd [1], SQLCODE); */
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc.sqld; ++x)
            free (out_desc.sqlvar [x].sqldata);

          for (x = 0; x < out_desc.sqld; ++x)
            free (out_desc.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

          free (out_desc.sqlvar);
/*          ERRload_struct (SQL, status, NULL); */
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
}

       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             if (NEW_LIST) MEMclose (list);
             status = SQLerror (SQL_E_CURSOR,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Open Cursors Failed : status = <0x%.8x>\n",
             status));
           }
          else
           {
/*             status = SQLerror (SQL_I_NO_ROWS_FOUND,
                      risca -> sqlerrd [1], SQLCODE); */
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc.sqld; ++x)
            free (out_desc.sqlvar [x].sqldata);

          for (x = 0; x < out_desc.sqld; ++x)
            free (out_desc.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

          free (out_desc.sqlvar);
/*          ERRload_struct (SQL, status, NULL); */
          return (status);
        }

{RISint_fetch(RIScpp_stmt_id0,0,&out_desc,0,7);
}

       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             if (NEW_LIST) MEMclose (list);
             status = SQLerror (SQL_E_FETCH,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Fetch Cursors Failed : status = <0x%.8x>\n",
             status));
           }
          else
           {
/*             status = SQLerror (SQL_I_NO_ROWS_FOUND,
                      risca -> sqlerrd [1], SQLCODE); */
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc.sqld; ++x)
            free (out_desc.sqlvar [x].sqldata);

          for (x = 0; x < out_desc.sqld; ++x)
            free (out_desc.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}


          free (out_desc.sqlvar); 
/*          ERRload_struct (SQL, status, NULL); */
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
/*          status = SQLerror (SQL_E_MALLOC, 0, 0); */
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc.sqld; ++x)
            free (out_desc.sqlvar [x].sqldata);

          for (x = 0; x < out_desc.sqld; ++x)
            free (out_desc.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

          if (NEW_LIST) MEMclose (list);
          free (out_desc.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          return (status);
        }

       while (SQLCODE != END_OF_DATA)            
        {
          str [0] = 0;

          for (i = 0; i < out_desc.sqld; ++i)
           {
             /*     TO Debug RIS    */
             /*
 
             _SQLdebug ((fname, "sqln      = <%d> : sqld = <%d> : sqldata = <%s> : sqlind = <%d> : sqltype = <%d> : sql null = <%d> : sqlnlen = <%d> : sqlscale = <%d>\n", 
	out_desc.sqln, out_desc.sqld, out_desc.sqlvar[i].sqldata,
	out_desc.sqlvar[i].sqlind, out_desc.sqlvar[i].sqltype,
	out_desc.sqlvar[i].sqlnull,out_desc.sqlvar[i].sqllen,
        out_desc.sqlvar[i].sqlscale)) ;	

             _SQLdebug ((fname, "sqlnamel = <%d> : sqlnamex = <%s>\n",
                       out_desc.sqlvar[i].sqlname.sqlnamel,
                       out_desc.sqlvar[i].sqlname.sqlnamec)) ;
             */

             if (*out_desc.sqlvar [i].sqlind < 0)
              {
/*
                _SQLdebug ((fname, "NULL DATA : <%s>\n", ""));
*/
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
/*                     status = SQLerror (SQL_E_MALLOC, 0, 0); */
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc.sqld; ++x)
                       free (out_desc.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc.sqld; ++x)
                       free (out_desc.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
                     return (status);
                   }
                  memset (data1, 0,  out_desc.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc.sqlvar[i].sqllen, 
                  out_desc.sqlvar[i].sqllen, out_desc.sqlvar [i].sqldata);
/*
                  _SQLdebug ((fname, "CHAR DATA : <%s>\n", data1));
*/
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc.sqlvar [i].sqldata);
/*
                  _SQLdebug ((fname, "INT  DATA : <%s>\n", data));
*/
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc.sqlvar [i].sqldata);
/*
                  _SQLdebug ((fname, "SINT DATA : <%s>\n", data));
*/
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :

                  for (daa=0;daa<=126;daa++) datax[daa]='\0';
                  sprintf (datax, "%-*.*s", out_desc.sqlvar[i].sqllen, 
                  out_desc.sqlvar[i].sqllen, out_desc.sqlvar [i].sqldata);
                  sprintf (data, "%.15lg", 
                           *(double *) out_desc.sqlvar [i].sqldata);
                  _PDMdebug ("datax", "%s\n", datax);

                  _PDMdebug ("val", "%g\n", out_desc.sqlvar[i].sqldata);
                  _PDMdebug ("val", "%ld\n", out_desc.sqlvar[i].sqldata);
                  _PDMdebug ("val", "%lf\n", out_desc.sqlvar[i].sqldata);
                  _PDMdebug ("val", "%f\n", out_desc.sqlvar[i].sqldata);
                  _PDMdebug ("val", "%e\n", out_desc.sqlvar[i].sqldata);
                  _SQLdebug ((fname, "DOUB DATA : <%s>\n", data));

                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%f", 
                           *(float *) out_desc.sqlvar [i].sqldata);
/*
                  _SQLdebug ((fname, "REAL DATA : <%s>\n", data));
*/
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
/*                  sprintf (data, "%f", * (float *) out_desc.sqlvar [i].sqldata);

                  sprintf (data, "%d", *(int *)
                           out_desc.sqlvar [i].sqldata);
*/
                  strcat (str, out_desc.sqlvar[i].sqldata);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
	          sprintf (message, "RISdatetime_to_ascii : error %ld",
			   status);
	          ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
	          return (SQL_E_MESSAGE) ;
               }

/*                   _SQLdebug ((fname, "TIMESTAMP : <%s>\n", data)); */

                  strcat (str, data);
                  strcat (str, "\1");
	          break ;
/*
                case DATETIME :
                  sprintf (data, "%d", *(int *)
                           out_desc.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;
*/
                default :
/*                  status = SQLerror (SQL_E_DATA_TYPE, 0, 0); */
	          status = SQL_E_DATA_TYPE ;
                  for (x = 0; x < out_desc.sqld; ++x)
                    free (out_desc.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc.sqld; ++x)
                    free (out_desc.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
/*             status = SQLerror (SQL_E_MEM, 0, status); */
             for (x = 0; x < out_desc.sqld; ++x)
               free (out_desc.sqlvar [x].sqldata);

             for (x = 0; x < out_desc.sqld; ++x)
               free (out_desc.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
           }

{RISint_fetch(RIScpp_stmt_id0,0,&out_desc,0,7);
}

          if (SQLCODE && (SQLCODE != END_OF_DATA))
           {
             if (SQLCODE != END_OF_DATA)
              {
                if (NEW_LIST) MEMclose (list);
                status = SQLerror (SQL_E_FETCH,
                         risca -> sqlerrd [1], SQLCODE);
                _SQLdebug ((fname, "Fetch Cursors : status = <0x%.8x>\n",
                status));
              }
             else
              {
/*                status = SQLerror (SQL_I_NO_ROWS_FOUND,
                         risca -> sqlerrd [1], SQLCODE); */
		status = SQL_I_NO_ROWS_FOUND ;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc.sqld; ++x)
               free (out_desc.sqlvar [x].sqldata);

             for (x = 0; x < out_desc.sqld; ++x)
               free (out_desc.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

             free (str);

             free (out_desc.sqlvar);
/*             ERRload_struct (SQL, status, NULL); */
             return (status);
           }
        }

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             if (NEW_LIST) MEMclose (list);
             status = SQLerror (SQL_E_CLOSE,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Close Cursors : status = <0x%.8x>\n",
             status));
           }
          else
           {
/*             status = SQLerror (SQL_I_NO_ROWS_FOUND,
                      risca -> sqlerrd [1], SQLCODE); */
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc.sqld; ++x)
            free (out_desc.sqlvar [x].sqldata);

          for (x = 0; x < out_desc.sqld; ++x)
            free (out_desc.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

          free (str);

          free (out_desc.sqlvar);
/*          ERRload_struct (SQL, status, NULL); */
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc.sqld; ++i)
        {
          free (out_desc.sqlvar [i].sqldata);
          free (out_desc.sqlvar [i].sqlind);
        }

       free (out_desc.sqlvar);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             if (NEW_LIST) MEMclose (list);
             status = SQLerror (SQL_E_CLEAR,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Clear Statement : status = <0x%.8x>\n",
             status));
           }
          else
           {
/*             status = SQLerror (SQL_I_NO_ROWS_FOUND,
                      risca -> sqlerrd [1], SQLCODE); */
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

/*          ERRload_struct (SQL, status, NULL); */
          return (status);
        }

       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       return (SQL_S_SUCCESS);
    }
