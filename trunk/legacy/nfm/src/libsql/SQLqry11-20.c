#include "sql.h"
static short RIScpp_stmt_id0 = -1;
static short RIScpp_stmt_id1 = -1;
static short RIScpp_stmt_id2 = -1;
static short RIScpp_stmt_id3 = -1;
static short RIScpp_stmt_id4 = -1;
static short RIScpp_stmt_id5 = -1;
static short RIScpp_stmt_id6 = -1;
static short RIScpp_stmt_id7 = -1;
static short RIScpp_stmt_id8 = -1;
static short RIScpp_stmt_id9 = -1;

#line 1 "SQLqry11-20.rc"
#include "machine.h"
#include "SQL.h"

 extern struct SQLglobal_st SQLglobal ;

 extern long SQLquery_count;
 int  SQLcursor[41] = {0};
 long SQLcursor_count[41] = {0};


#line 10 "SQLqry11-20.rc"

sqlda out_desc_11;

#line 11 "SQLqry11-20.rc"

sqlda out_desc_12;

#line 12 "SQLqry11-20.rc"

sqlda out_desc_13;

#line 13 "SQLqry11-20.rc"

sqlda out_desc_14;

#line 14 "SQLqry11-20.rc"

sqlda out_desc_15;

#line 15 "SQLqry11-20.rc"

sqlda out_desc_16;

#line 16 "SQLqry11-20.rc"

sqlda out_desc_17;

#line 17 "SQLqry11-20.rc"

sqlda out_desc_18;

#line 18 "SQLqry11-20.rc"

sqlda out_desc_19;

#line 19 "SQLqry11-20.rc"

sqlda out_desc_20;

#line 21 "SQLqry11-20.rc"


 char   *malloc (), *calloc ();

/*  This query routine was developed to be used with large query buffers
 *  where only portions of the data are to be returned. Cursor 2 is used
 *  for display items (full listing).
 */

 long  SQLquery_cursor11 (sql_str11, list, size, rows)

#line 31 "SQLqry11-20.rc"

char * sql_str11;

#line 33 "SQLqry11-20.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor11" ;

#line 42 "SQLqry11-20.rc"

long status;

#line 43 "SQLqry11-20.rc"

long i;

#line 44 "SQLqry11-20.rc"

long x;

#line 45 "SQLqry11-20.rc"

long NEW_LIST;

#line 46 "SQLqry11-20.rc"

long fetch_count;

#line 47 "SQLqry11-20.rc"

char data_type[30];

#line 48 "SQLqry11-20.rc"

char data[30];

#line 49 "SQLqry11-20.rc"

char * str;

#line 50 "SQLqry11-20.rc"

char * data1;

#line 51 "SQLqry11-20.rc"

char * * format;

#line 52 "SQLqry11-20.rc"

datetime * ptr;

#line 53 "SQLqry11-20.rc"

char column_name[50];

#line 55 "SQLqry11-20.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str11, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[11] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[11] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt11" ));
{RISint_prepare(&RIScpp_stmt_id0,sql_str11,1,0);
}

#line 74 "SQLqry11-20.rc"

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
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
 	             status));
	      ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 92 "SQLqry11-20.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_11.sqld = 0;
       out_desc_11.sqln = 0;
       out_desc_11.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id0,&out_desc_11,1);
}

#line 107 "SQLqry11-20.rc"

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
	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
	       ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 125 "SQLqry11-20.rc"

           return (status);
        }
    } /* if( !SQLcursor[11] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 136 "SQLqry11-20.rc"

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
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 149 "SQLqry11-20.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[11] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_11" ));
        out_desc_11.sqlvar = (sqlvar *)calloc(out_desc_11.sqld, sizeof (sqlvar));
        if (! out_desc_11.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 167 "SQLqry11-20.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_11.sqln = out_desc_11.sqld;

{RISint_describe(RIScpp_stmt_id0,&out_desc_11,1);
}

#line 176 "SQLqry11-20.rc"

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
  	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
  	       ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 195 "SQLqry11-20.rc"

        free (out_desc_11.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_11.sqld; ++i)
        {
          out_desc_11.sqlvar [i].sqldata =
                 calloc (1, out_desc_11.sqlvar [i].sqllen);
          if (! out_desc_11.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_11.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_11.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 209 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_11.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_11.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_11.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_11.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_11.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 224 "SQLqry11-20.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_11.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_11.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_11.sqld; ++x)
                free (out_desc_11.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_11.sqld; ++x)
                free (out_desc_11.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 246 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_11.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[11] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_11.sqld ));
       for (i = 0; i < out_desc_11.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_11.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_11.sqlvar[i].sqllen);
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
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
				status ));	
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc_11.sqld; ++x)
                   free (out_desc_11.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_11.sqld; ++x)
                   free (out_desc_11.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 304 "SQLqry11-20.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_11.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_11.sqlvar [i].sqlname.sqlnamec,
		       out_desc_11.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_11.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_11.sqld; ++x)
                   free (out_desc_11.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_11.sqld; ++x)
                   free (out_desc_11.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 327 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_11.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.8x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc_11.sqld; ++x)
                   free (out_desc_11.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_11.sqld; ++x)
                   free (out_desc_11.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 347 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_11.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[11] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 361 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 386 "SQLqry11-20.rc"

          free (out_desc_11.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
}

#line 391 "SQLqry11-20.rc"

        _SQLdebug(( fname, "%s\n", "Open cursor" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 417 "SQLqry11-20.rc"

          free (out_desc_11.sqlvar);
          return (status);
        }
    SQLcursor[11] = 1;

    } /* end if( !SQLcursor[11] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[11] != 0 )
    {
        for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 439 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 440 "SQLqry11-20.rc"


        free (out_desc_11.sqlvar); 
    }
    SQLcursor[11] = 0;
    SQLcursor_count[11] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id0,0,&out_desc_11,0,7);
}

#line 452 "SQLqry11-20.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs11 (First time)" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             if( SQLcursor[11] && ( SQLcursor_count[11] > 0 ) )
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 480 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 481 "SQLqry11-20.rc"


          free (out_desc_11.sqlvar); 
          SQLcursor[11] = 0;
          SQLcursor_count[11] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 499 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 500 "SQLqry11-20.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_11.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[11] = 0;
          SQLcursor_count[11] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[11];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_11.sqld; ++i)
           {
             if (*out_desc_11.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_11.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_11.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_11.sqld; ++x)
                       free (out_desc_11.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_11.sqld; ++x)
                       free (out_desc_11.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 541 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 542 "SQLqry11-20.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_11.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[11] = 0;
	             SQLcursor_count[11] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_11.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_11.sqlvar[i].sqllen, 
                  out_desc_11.sqlvar[i].sqllen, out_desc_11.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_11.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_11.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_11.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_11.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_11.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_11.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_11.sqld; ++x)
                    free (out_desc_11.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_11.sqld; ++x)
                    free (out_desc_11.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 610 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 611 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_11.sqlvar);
 	          SQLcursor[11] = 0;
  	          SQLcursor_count[11] = 0;
	          sprintf (message, "RISdatetime_to_ascii : error %ld",
			   status);
	          ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
	          return (SQL_E_MESSAGE) ;
               }
                  strcat (str, data);
                  strcat (str, "\1");
		break;

                default :
	          status = SQL_E_DATA_TYPE ;
                  for (x = 0; x < out_desc_11.sqld; ++x)
                    free (out_desc_11.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_11.sqld; ++x)
                    free (out_desc_11.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 634 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 635 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_11.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[11] = 0;
	          SQLcursor_count[11] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_11.sqld; ++x)
               free (out_desc_11.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_11.sqld; ++x)
               free (out_desc_11.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 657 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 658 "SQLqry11-20.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_11.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[11] = 0;
              SQLcursor_count[11] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id0,0,&out_desc_11,0,7);
}

#line 671 "SQLqry11-20.rc"

          _SQLdebug(( fname, "%s\n", "Fetch in loop" ));
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
                status = SQL_I_NO_ROWS_FOUND;
                if( SQLcursor[11] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_11.sqld; ++x)
               free (out_desc_11.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_11.sqld; ++x)
               free (out_desc_11.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 699 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 700 "SQLqry11-20.rc"

             free (str);

             free (out_desc_11.sqlvar);
             SQLcursor[11] = 0;
             SQLcursor_count[11] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[11];
	 } /*  end if( fetch_count < rows ) */
	 else
	 {
	     _SQLdebug(( fname, "Fetch_count <%d> :  Requested Rows <%d>\n",
			 fetch_count, rows ));	
	     _SQLdebug(( fname, "%s\n", "Reached Requested Row # before End of Data " ));
	     free( str );
	     return (SQL_S_SUCCESS);
	 }
        }
       _SQLdebug(( fname, "%s\n", "Closing Cursor" ));

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 722 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

	  
          for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_11.sqld; ++x)
            free (out_desc_11.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 748 "SQLqry11-20.rc"

          free (str);

          free (out_desc_11.sqlvar);
          SQLcursor[11] = 0;
          SQLcursor_count[11] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_11.sqld; ++i)
        {
          free (out_desc_11.sqlvar [i].sqldata);
          free (out_desc_11.sqlvar [i].sqlind);
        }

       free (out_desc_11.sqlvar);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 767 "SQLqry11-20.rc"

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
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }
          SQLcursor[11] = 0;
	  SQLcursor_count[11] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[11] = 0;
       SQLcursor_count[11] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor12 (sql_str12, list, size, rows)

#line 800 "SQLqry11-20.rc"

char * sql_str12;

#line 802 "SQLqry11-20.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor12" ;

#line 811 "SQLqry11-20.rc"

long status;

#line 812 "SQLqry11-20.rc"

long i;

#line 813 "SQLqry11-20.rc"

long x;

#line 814 "SQLqry11-20.rc"

long NEW_LIST;

#line 815 "SQLqry11-20.rc"

long fetch_count;

#line 816 "SQLqry11-20.rc"

char data_type[30];

#line 817 "SQLqry11-20.rc"

char data[30];

#line 818 "SQLqry11-20.rc"

char * str;

#line 819 "SQLqry11-20.rc"

char * data1;

#line 820 "SQLqry11-20.rc"

char * * format;

#line 821 "SQLqry11-20.rc"

datetime * ptr;

#line 822 "SQLqry11-20.rc"

char column_name[50];

#line 824 "SQLqry11-20.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str12, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[12] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[12] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt12" ));
{RISint_prepare(&RIScpp_stmt_id1,sql_str12,1,0);
}

#line 843 "SQLqry11-20.rc"

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
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
 	             status));
	      ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 861 "SQLqry11-20.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_12.sqld = 0;
       out_desc_12.sqln = 0;
       out_desc_12.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id1,&out_desc_12,1);
}

#line 876 "SQLqry11-20.rc"

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
	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
	       ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 894 "SQLqry11-20.rc"

           return (status);
        }
    } /* if( !SQLcursor[12] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 905 "SQLqry11-20.rc"

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
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 918 "SQLqry11-20.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[12] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_12" ));
        out_desc_12.sqlvar = (sqlvar *)calloc(out_desc_12.sqld, sizeof (sqlvar));
        if (! out_desc_12.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 936 "SQLqry11-20.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_12.sqln = out_desc_12.sqld;

{RISint_describe(RIScpp_stmt_id1,&out_desc_12,1);
}

#line 945 "SQLqry11-20.rc"

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
  	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
  	       ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 964 "SQLqry11-20.rc"

        free (out_desc_12.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_12.sqld; ++i)
        {
          out_desc_12.sqlvar [i].sqldata =
                 calloc (1, out_desc_12.sqlvar [i].sqllen);
          if (! out_desc_12.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_12.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_12.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 978 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_12.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_12.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_12.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_12.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_12.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 993 "SQLqry11-20.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_12.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_12.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_12.sqld; ++x)
                free (out_desc_12.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_12.sqld; ++x)
                free (out_desc_12.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1015 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_12.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[12] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_12.sqld ));
       for (i = 0; i < out_desc_12.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_12.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_12.sqlvar[i].sqllen);
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
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
				status ));	
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc_12.sqld; ++x)
                   free (out_desc_12.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_12.sqld; ++x)
                   free (out_desc_12.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1073 "SQLqry11-20.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_12.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_12.sqlvar [i].sqlname.sqlnamec,
		       out_desc_12.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_12.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_12.sqld; ++x)
                   free (out_desc_12.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_12.sqld; ++x)
                   free (out_desc_12.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1096 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_12.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.8x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc_12.sqld; ++x)
                   free (out_desc_12.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_12.sqld; ++x)
                   free (out_desc_12.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1116 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_12.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[12] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 1130 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1155 "SQLqry11-20.rc"

          free (out_desc_12.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
}

#line 1160 "SQLqry11-20.rc"

        _SQLdebug(( fname, "%s\n", "Open cursor" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1186 "SQLqry11-20.rc"

          free (out_desc_12.sqlvar);
          return (status);
        }
    SQLcursor[12] = 1;

    } /* end if( !SQLcursor[12] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[12] != 0 )
    {
        for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1208 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1209 "SQLqry11-20.rc"


        free (out_desc_12.sqlvar); 
    }
    SQLcursor[12] = 0;
    SQLcursor_count[12] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id1,0,&out_desc_12,0,7);
}

#line 1221 "SQLqry11-20.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs12 (First time)" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             if( SQLcursor[12] && ( SQLcursor_count[12] > 0 ) )
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1249 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1250 "SQLqry11-20.rc"


          free (out_desc_12.sqlvar); 
          SQLcursor[12] = 0;
          SQLcursor_count[12] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1268 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1269 "SQLqry11-20.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_12.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[12] = 0;
          SQLcursor_count[12] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[12];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_12.sqld; ++i)
           {
             if (*out_desc_12.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_12.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_12.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_12.sqld; ++x)
                       free (out_desc_12.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_12.sqld; ++x)
                       free (out_desc_12.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1310 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1311 "SQLqry11-20.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_12.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[12] = 0;
	             SQLcursor_count[12] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_12.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_12.sqlvar[i].sqllen, 
                  out_desc_12.sqlvar[i].sqllen, out_desc_12.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_12.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_12.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_12.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_12.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_12.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_12.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_12.sqld; ++x)
                    free (out_desc_12.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_12.sqld; ++x)
                    free (out_desc_12.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1379 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1380 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_12.sqlvar);
 	          SQLcursor[12] = 0;
  	          SQLcursor_count[12] = 0;
	          sprintf (message, "RISdatetime_to_ascii : error %ld",
			   status);
	          ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
	          return (SQL_E_MESSAGE) ;
               }
                  strcat (str, data);
                  strcat (str, "\1");
		break;

                default :
	          status = SQL_E_DATA_TYPE ;
                  for (x = 0; x < out_desc_12.sqld; ++x)
                    free (out_desc_12.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_12.sqld; ++x)
                    free (out_desc_12.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1403 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1404 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_12.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[12] = 0;
	          SQLcursor_count[12] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_12.sqld; ++x)
               free (out_desc_12.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_12.sqld; ++x)
               free (out_desc_12.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1426 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1427 "SQLqry11-20.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_12.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[12] = 0;
              SQLcursor_count[12] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id1,0,&out_desc_12,0,7);
}

#line 1440 "SQLqry11-20.rc"

          _SQLdebug(( fname, "%s\n", "Fetch in loop" ));
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
                status = SQL_I_NO_ROWS_FOUND;
                if( SQLcursor[12] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_12.sqld; ++x)
               free (out_desc_12.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_12.sqld; ++x)
               free (out_desc_12.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1468 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1469 "SQLqry11-20.rc"

             free (str);

             free (out_desc_12.sqlvar);
             SQLcursor[12] = 0;
             SQLcursor_count[12] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[12];
	 } /*  end if( fetch_count < rows ) */
	 else
	 {
	     _SQLdebug(( fname, "Fetch_count <%d> :  Requested Rows <%d>\n",
			 fetch_count, rows ));	
	     _SQLdebug(( fname, "%s\n", "Reached Requested Row # before End of Data " ));
	     free( str );
	     return (SQL_S_SUCCESS);
	 }
        }
       _SQLdebug(( fname, "%s\n", "Closing Cursor" ));

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1491 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

	  
          for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_12.sqld; ++x)
            free (out_desc_12.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1517 "SQLqry11-20.rc"

          free (str);

          free (out_desc_12.sqlvar);
          SQLcursor[12] = 0;
          SQLcursor_count[12] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_12.sqld; ++i)
        {
          free (out_desc_12.sqlvar [i].sqldata);
          free (out_desc_12.sqlvar [i].sqlind);
        }

       free (out_desc_12.sqlvar);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1536 "SQLqry11-20.rc"

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
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }
          SQLcursor[12] = 0;
	  SQLcursor_count[12] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[12] = 0;
       SQLcursor_count[12] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor13 (sql_str13, list, size, rows)

#line 1568 "SQLqry11-20.rc"

char * sql_str13;

#line 1570 "SQLqry11-20.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor13" ;

#line 1579 "SQLqry11-20.rc"

long status;

#line 1580 "SQLqry11-20.rc"

long i;

#line 1581 "SQLqry11-20.rc"

long x;

#line 1582 "SQLqry11-20.rc"

long NEW_LIST;

#line 1583 "SQLqry11-20.rc"

long fetch_count;

#line 1584 "SQLqry11-20.rc"

char data_type[30];

#line 1585 "SQLqry11-20.rc"

char data[30];

#line 1586 "SQLqry11-20.rc"

char * str;

#line 1587 "SQLqry11-20.rc"

char * data1;

#line 1588 "SQLqry11-20.rc"

char * * format;

#line 1589 "SQLqry11-20.rc"

datetime * ptr;

#line 1590 "SQLqry11-20.rc"

char column_name[50];

#line 1592 "SQLqry11-20.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str13, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[13] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[13] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt13" ));
{RISint_prepare(&RIScpp_stmt_id2,sql_str13,1,0);
}

#line 1611 "SQLqry11-20.rc"

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
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
 	             status));
	      ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1629 "SQLqry11-20.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_13.sqld = 0;
       out_desc_13.sqln = 0;
       out_desc_13.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id2,&out_desc_13,1);
}

#line 1644 "SQLqry11-20.rc"

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
	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
	       ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1662 "SQLqry11-20.rc"

           return (status);
        }
    } /* if( !SQLcursor[13] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1673 "SQLqry11-20.rc"

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
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1686 "SQLqry11-20.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[13] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_13" ));
        out_desc_13.sqlvar = (sqlvar *)calloc(out_desc_13.sqld, sizeof (sqlvar));
        if (! out_desc_13.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1704 "SQLqry11-20.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_13.sqln = out_desc_13.sqld;

{RISint_describe(RIScpp_stmt_id2,&out_desc_13,1);
}

#line 1713 "SQLqry11-20.rc"

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
  	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
  	       ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1732 "SQLqry11-20.rc"

        free (out_desc_13.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_13.sqld; ++i)
        {
          out_desc_13.sqlvar [i].sqldata =
                 calloc (1, out_desc_13.sqlvar [i].sqllen);
          if (! out_desc_13.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_13.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_13.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1746 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_13.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_13.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_13.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_13.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_13.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1761 "SQLqry11-20.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_13.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_13.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_13.sqld; ++x)
                free (out_desc_13.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_13.sqld; ++x)
                free (out_desc_13.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1783 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_13.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[13] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_13.sqld ));
       for (i = 0; i < out_desc_13.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_13.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_13.sqlvar[i].sqllen);
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
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
				status ));	
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc_13.sqld; ++x)
                   free (out_desc_13.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_13.sqld; ++x)
                   free (out_desc_13.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1841 "SQLqry11-20.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_13.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_13.sqlvar [i].sqlname.sqlnamec,
		       out_desc_13.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_13.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_13.sqld; ++x)
                   free (out_desc_13.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_13.sqld; ++x)
                   free (out_desc_13.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1864 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_13.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.8x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc_13.sqld; ++x)
                   free (out_desc_13.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_13.sqld; ++x)
                   free (out_desc_13.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1884 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_13.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[13] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 1898 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1923 "SQLqry11-20.rc"

          free (out_desc_13.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id2,0,0,7,1,0);
}

#line 1928 "SQLqry11-20.rc"

        _SQLdebug(( fname, "%s\n", "Open cursor" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1954 "SQLqry11-20.rc"

          free (out_desc_13.sqlvar);
          return (status);
        }
    SQLcursor[13] = 1;

    } /* end if( !SQLcursor[13] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[13] != 0 )
    {
        for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 1976 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1977 "SQLqry11-20.rc"


        free (out_desc_13.sqlvar); 
    }
    SQLcursor[13] = 0;
    SQLcursor_count[13] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id2,0,&out_desc_13,0,7);
}

#line 1989 "SQLqry11-20.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs13 (First time)" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             if( SQLcursor[13] && ( SQLcursor_count[13] > 0 ) )
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2017 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2018 "SQLqry11-20.rc"


          free (out_desc_13.sqlvar); 
          SQLcursor[13] = 0;
          SQLcursor_count[13] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2036 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2037 "SQLqry11-20.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_13.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[13] = 0;
          SQLcursor_count[13] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[13];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_13.sqld; ++i)
           {
             if (*out_desc_13.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_13.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_13.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_13.sqld; ++x)
                       free (out_desc_13.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_13.sqld; ++x)
                       free (out_desc_13.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2078 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2079 "SQLqry11-20.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_13.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[13] = 0;
	             SQLcursor_count[13] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_13.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_13.sqlvar[i].sqllen, 
                  out_desc_13.sqlvar[i].sqllen, out_desc_13.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_13.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_13.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_13.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_13.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_13.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_13.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_13.sqld; ++x)
                    free (out_desc_13.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_13.sqld; ++x)
                    free (out_desc_13.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2147 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2148 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_13.sqlvar);
 	          SQLcursor[13] = 0;
  	          SQLcursor_count[13] = 0;
	          sprintf (message, "RISdatetime_to_ascii : error %ld",
			   status);
	          ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
	          return (SQL_E_MESSAGE) ;
               }
                  strcat (str, data);
                  strcat (str, "\1");
		break;

                default :
	          status = SQL_E_DATA_TYPE ;
                  for (x = 0; x < out_desc_13.sqld; ++x)
                    free (out_desc_13.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_13.sqld; ++x)
                    free (out_desc_13.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2171 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2172 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_13.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[13] = 0;
	          SQLcursor_count[13] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_13.sqld; ++x)
               free (out_desc_13.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_13.sqld; ++x)
               free (out_desc_13.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2194 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2195 "SQLqry11-20.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_13.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[13] = 0;
              SQLcursor_count[13] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id2,0,&out_desc_13,0,7);
}

#line 2208 "SQLqry11-20.rc"

          _SQLdebug(( fname, "%s\n", "Fetch in loop" ));
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
                status = SQL_I_NO_ROWS_FOUND;
                if( SQLcursor[13] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_13.sqld; ++x)
               free (out_desc_13.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_13.sqld; ++x)
               free (out_desc_13.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2236 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2237 "SQLqry11-20.rc"

             free (str);

             free (out_desc_13.sqlvar);
             SQLcursor[13] = 0;
             SQLcursor_count[13] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[13];
	 } /*  end if( fetch_count < rows ) */
	 else
	 {
	     _SQLdebug(( fname, "Fetch_count <%d> :  Requested Rows <%d>\n",
			 fetch_count, rows ));	
	     _SQLdebug(( fname, "%s\n", "Reached Requested Row # before End of Data " ));
	     free( str );
	     return (SQL_S_SUCCESS);
	 }
        }
       _SQLdebug(( fname, "%s\n", "Closing Cursor" ));

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2259 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

	  
          for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_13.sqld; ++x)
            free (out_desc_13.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2285 "SQLqry11-20.rc"

          free (str);

          free (out_desc_13.sqlvar);
          SQLcursor[13] = 0;
          SQLcursor_count[13] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_13.sqld; ++i)
        {
          free (out_desc_13.sqlvar [i].sqldata);
          free (out_desc_13.sqlvar [i].sqlind);
        }

       free (out_desc_13.sqlvar);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2304 "SQLqry11-20.rc"

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
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }
          SQLcursor[13] = 0;
	  SQLcursor_count[13] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[13] = 0;
       SQLcursor_count[13] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor14 (sql_str14, list, size, rows)

#line 2337 "SQLqry11-20.rc"

char * sql_str14;

#line 2339 "SQLqry11-20.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor14" ;

#line 2348 "SQLqry11-20.rc"

long status;

#line 2349 "SQLqry11-20.rc"

long i;

#line 2350 "SQLqry11-20.rc"

long x;

#line 2351 "SQLqry11-20.rc"

long NEW_LIST;

#line 2352 "SQLqry11-20.rc"

long fetch_count;

#line 2353 "SQLqry11-20.rc"

char data_type[30];

#line 2354 "SQLqry11-20.rc"

char data[30];

#line 2355 "SQLqry11-20.rc"

char * str;

#line 2356 "SQLqry11-20.rc"

char * data1;

#line 2357 "SQLqry11-20.rc"

char * * format;

#line 2358 "SQLqry11-20.rc"

datetime * ptr;

#line 2359 "SQLqry11-20.rc"

char column_name[50];

#line 2361 "SQLqry11-20.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str14, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[14] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[14] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt14" ));
{RISint_prepare(&RIScpp_stmt_id3,sql_str14,1,0);
}

#line 2380 "SQLqry11-20.rc"

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
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
 	             status));
	      ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2398 "SQLqry11-20.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_14.sqld = 0;
       out_desc_14.sqln = 0;
       out_desc_14.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id3,&out_desc_14,1);
}

#line 2413 "SQLqry11-20.rc"

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
	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
	       ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2431 "SQLqry11-20.rc"

           return (status);
        }
    } /* if( !SQLcursor[14] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2442 "SQLqry11-20.rc"

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
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2455 "SQLqry11-20.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[14] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_14" ));
        out_desc_14.sqlvar = (sqlvar *)calloc(out_desc_14.sqld, sizeof (sqlvar));
        if (! out_desc_14.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2473 "SQLqry11-20.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_14.sqln = out_desc_14.sqld;

{RISint_describe(RIScpp_stmt_id3,&out_desc_14,1);
}

#line 2482 "SQLqry11-20.rc"

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
  	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
  	       ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2501 "SQLqry11-20.rc"

        free (out_desc_14.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_14.sqld; ++i)
        {
          out_desc_14.sqlvar [i].sqldata =
                 calloc (1, out_desc_14.sqlvar [i].sqllen);
          if (! out_desc_14.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_14.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_14.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2515 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_14.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_14.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_14.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_14.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_14.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2530 "SQLqry11-20.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_14.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_14.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_14.sqld; ++x)
                free (out_desc_14.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_14.sqld; ++x)
                free (out_desc_14.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2552 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_14.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[14] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_14.sqld ));
       for (i = 0; i < out_desc_14.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_14.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_14.sqlvar[i].sqllen);
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
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
				status ));	
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc_14.sqld; ++x)
                   free (out_desc_14.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_14.sqld; ++x)
                   free (out_desc_14.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2610 "SQLqry11-20.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_14.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_14.sqlvar [i].sqlname.sqlnamec,
		       out_desc_14.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_14.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_14.sqld; ++x)
                   free (out_desc_14.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_14.sqld; ++x)
                   free (out_desc_14.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2633 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_14.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.8x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc_14.sqld; ++x)
                   free (out_desc_14.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_14.sqld; ++x)
                   free (out_desc_14.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2653 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_14.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[14] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 2667 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2692 "SQLqry11-20.rc"

          free (out_desc_14.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id3,0,0,7,1,0);
}

#line 2697 "SQLqry11-20.rc"

        _SQLdebug(( fname, "%s\n", "Open cursor" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2723 "SQLqry11-20.rc"

          free (out_desc_14.sqlvar);
          return (status);
        }
    SQLcursor[14] = 1;

    } /* end if( !SQLcursor[14] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[14] != 0 )
    {
        for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2745 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2746 "SQLqry11-20.rc"


        free (out_desc_14.sqlvar); 
    }
    SQLcursor[14] = 0;
    SQLcursor_count[14] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id3,0,&out_desc_14,0,7);
}

#line 2758 "SQLqry11-20.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs14 (First time)" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             if( SQLcursor[14] && ( SQLcursor_count[14] > 0 ))
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2786 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2787 "SQLqry11-20.rc"


          free (out_desc_14.sqlvar); 
          SQLcursor[14] = 0;
          SQLcursor_count[14] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2805 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2806 "SQLqry11-20.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_14.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[14] = 0;
          SQLcursor_count[14] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[14];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_14.sqld; ++i)
           {
             if (*out_desc_14.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_14.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_14.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_14.sqld; ++x)
                       free (out_desc_14.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_14.sqld; ++x)
                       free (out_desc_14.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2847 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2848 "SQLqry11-20.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_14.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[14] = 0;
	             SQLcursor_count[14] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_14.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_14.sqlvar[i].sqllen, 
                  out_desc_14.sqlvar[i].sqllen, out_desc_14.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_14.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_14.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_14.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_14.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_14.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_14.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_14.sqld; ++x)
                    free (out_desc_14.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_14.sqld; ++x)
                    free (out_desc_14.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2916 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2917 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_14.sqlvar);
 	          SQLcursor[14] = 0;
  	          SQLcursor_count[14] = 0;
	          sprintf (message, "RISdatetime_to_ascii : error %ld",
			   status);
	          ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
	          return (SQL_E_MESSAGE) ;
               }
                  strcat (str, data);
                  strcat (str, "\1");
		break;

                default :
	          status = SQL_E_DATA_TYPE ;
                  for (x = 0; x < out_desc_14.sqld; ++x)
                    free (out_desc_14.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_14.sqld; ++x)
                    free (out_desc_14.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2940 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2941 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_14.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[14] = 0;
	          SQLcursor_count[14] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_14.sqld; ++x)
               free (out_desc_14.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_14.sqld; ++x)
               free (out_desc_14.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2963 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2964 "SQLqry11-20.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_14.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[14] = 0;
              SQLcursor_count[14] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id3,0,&out_desc_14,0,7);
}

#line 2977 "SQLqry11-20.rc"

          _SQLdebug(( fname, "%s\n", "Fetch in loop" ));
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
                status = SQL_I_NO_ROWS_FOUND;
                if( SQLcursor[14] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_14.sqld; ++x)
               free (out_desc_14.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_14.sqld; ++x)
               free (out_desc_14.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 3005 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3006 "SQLqry11-20.rc"

             free (str);

             free (out_desc_14.sqlvar);
             SQLcursor[14] = 0;
             SQLcursor_count[14] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[14];
	 } /*  end if( fetch_count < rows ) */
	 else
	 {
	     _SQLdebug(( fname, "Fetch_count <%d> :  Requested Rows <%d>\n",
			 fetch_count, rows ));	
	     _SQLdebug(( fname, "%s\n", "Reached Requested Row # before End of Data " ));
	     free( str );
	     return (SQL_S_SUCCESS);
	 }
        }
       _SQLdebug(( fname, "%s\n", "Closing Cursor" ));

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 3028 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

	  
          for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_14.sqld; ++x)
            free (out_desc_14.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3054 "SQLqry11-20.rc"

          free (str);

          free (out_desc_14.sqlvar);
          SQLcursor[14] = 0;
          SQLcursor_count[14] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_14.sqld; ++i)
        {
          free (out_desc_14.sqlvar [i].sqldata);
          free (out_desc_14.sqlvar [i].sqlind);
        }

       free (out_desc_14.sqlvar);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3073 "SQLqry11-20.rc"

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
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }
          SQLcursor[14] = 0;
	  SQLcursor_count[14] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[14] = 0;
       SQLcursor_count[14] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor15 (sql_str15, list, size, rows)

#line 3106 "SQLqry11-20.rc"

char * sql_str15;

#line 3108 "SQLqry11-20.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor15" ;

#line 3117 "SQLqry11-20.rc"

long status;

#line 3118 "SQLqry11-20.rc"

long i;

#line 3119 "SQLqry11-20.rc"

long x;

#line 3120 "SQLqry11-20.rc"

long NEW_LIST;

#line 3121 "SQLqry11-20.rc"

long fetch_count;

#line 3122 "SQLqry11-20.rc"

char data_type[30];

#line 3123 "SQLqry11-20.rc"

char data[30];

#line 3124 "SQLqry11-20.rc"

char * str;

#line 3125 "SQLqry11-20.rc"

char * data1;

#line 3126 "SQLqry11-20.rc"

char * * format;

#line 3127 "SQLqry11-20.rc"

datetime * ptr;

#line 3128 "SQLqry11-20.rc"

char column_name[50];

#line 3130 "SQLqry11-20.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str15, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[15] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[15] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt15" ));
{RISint_prepare(&RIScpp_stmt_id4,sql_str15,1,0);
}

#line 3149 "SQLqry11-20.rc"

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
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
 	             status));
	      ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3167 "SQLqry11-20.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_15.sqld = 0;
       out_desc_15.sqln = 0;
       out_desc_15.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id4,&out_desc_15,1);
}

#line 3182 "SQLqry11-20.rc"

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
	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
	       ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3200 "SQLqry11-20.rc"

           return (status);
        }
    } /* if( !SQLcursor[15] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3211 "SQLqry11-20.rc"

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
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3224 "SQLqry11-20.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[15] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_15" ));
        out_desc_15.sqlvar = (sqlvar *)calloc(out_desc_15.sqld, sizeof (sqlvar));
        if (! out_desc_15.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3242 "SQLqry11-20.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_15.sqln = out_desc_15.sqld;

{RISint_describe(RIScpp_stmt_id4,&out_desc_15,1);
}

#line 3251 "SQLqry11-20.rc"

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
  	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
  	       ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3270 "SQLqry11-20.rc"

        free (out_desc_15.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_15.sqld; ++i)
        {
          out_desc_15.sqlvar [i].sqldata =
                 calloc (1, out_desc_15.sqlvar [i].sqllen);
          if (! out_desc_15.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_15.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_15.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3284 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_15.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_15.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_15.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_15.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_15.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3299 "SQLqry11-20.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_15.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_15.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_15.sqld; ++x)
                free (out_desc_15.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_15.sqld; ++x)
                free (out_desc_15.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3321 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_15.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[15] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_15.sqld ));
       for (i = 0; i < out_desc_15.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_15.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_15.sqlvar[i].sqllen);
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
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
				status ));	
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc_15.sqld; ++x)
                   free (out_desc_15.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_15.sqld; ++x)
                   free (out_desc_15.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3379 "SQLqry11-20.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_15.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_15.sqlvar [i].sqlname.sqlnamec,
		       out_desc_15.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_15.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_15.sqld; ++x)
                   free (out_desc_15.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_15.sqld; ++x)
                   free (out_desc_15.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3402 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_15.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.8x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc_15.sqld; ++x)
                   free (out_desc_15.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_15.sqld; ++x)
                   free (out_desc_15.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3422 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_15.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[15] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 3436 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3461 "SQLqry11-20.rc"

          free (out_desc_15.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id4,0,0,7,1,0);
}

#line 3466 "SQLqry11-20.rc"

        _SQLdebug(( fname, "%s\n", "Open cursor" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3492 "SQLqry11-20.rc"

          free (out_desc_15.sqlvar);
          return (status);
        }
    SQLcursor[15] = 1;

    } /* end if( !SQLcursor[15] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[15] != 0 )
    {
        for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3514 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3515 "SQLqry11-20.rc"


        free (out_desc_15.sqlvar); 
     }
     SQLcursor[15] = 0;
     SQLcursor_count[15] = 0;
	
     _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

     return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id4,0,&out_desc_15,0,7);
}

#line 3527 "SQLqry11-20.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs15 (First time)" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             if( SQLcursor[15] && ( SQLcursor_count[15] > 0 ) )
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3555 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3556 "SQLqry11-20.rc"


          free (out_desc_15.sqlvar); 
          SQLcursor[15] = 0;
          SQLcursor_count[15] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3574 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3575 "SQLqry11-20.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_15.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[15] = 0;
          SQLcursor_count[15] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[15];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_15.sqld; ++i)
           {
             if (*out_desc_15.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_15.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_15.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_15.sqld; ++x)
                       free (out_desc_15.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_15.sqld; ++x)
                       free (out_desc_15.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3616 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3617 "SQLqry11-20.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_15.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[15] = 0;
	             SQLcursor_count[15] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_15.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_15.sqlvar[i].sqllen, 
                  out_desc_15.sqlvar[i].sqllen, out_desc_15.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_15.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_15.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_15.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_15.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_15.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_15.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_15.sqld; ++x)
                    free (out_desc_15.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_15.sqld; ++x)
                    free (out_desc_15.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3685 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3686 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_15.sqlvar);
 	          SQLcursor[15] = 0;
  	          SQLcursor_count[15] = 0;
	          sprintf (message, "RISdatetime_to_ascii : error %ld",
			   status);
	          ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
	          return (SQL_E_MESSAGE) ;
               }
                  strcat (str, data);
                  strcat (str, "\1");
		break;

                default :
	          status = SQL_E_DATA_TYPE ;
                  for (x = 0; x < out_desc_15.sqld; ++x)
                    free (out_desc_15.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_15.sqld; ++x)
                    free (out_desc_15.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3709 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3710 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_15.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[15] = 0;
	          SQLcursor_count[15] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_15.sqld; ++x)
               free (out_desc_15.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_15.sqld; ++x)
               free (out_desc_15.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3732 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3733 "SQLqry11-20.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_15.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[15] = 0;
              SQLcursor_count[15] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id4,0,&out_desc_15,0,7);
}

#line 3746 "SQLqry11-20.rc"

          _SQLdebug(( fname, "%s\n", "Fetch in loop" ));
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
                status = SQL_I_NO_ROWS_FOUND;
                if( SQLcursor[15] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_15.sqld; ++x)
               free (out_desc_15.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_15.sqld; ++x)
               free (out_desc_15.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3774 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3775 "SQLqry11-20.rc"

             free (str);

             free (out_desc_15.sqlvar);
             SQLcursor[15] = 0;
             SQLcursor_count[15] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[15];
	 } /*  end if( fetch_count < rows ) */
	 else
	 {
	     _SQLdebug(( fname, "Fetch_count <%d> :  Requested Rows <%d>\n",
			 fetch_count, rows ));	
	     _SQLdebug(( fname, "%s\n", "Reached Requested Row # before End of Data " ));
	     free( str );
	     return (SQL_S_SUCCESS);
	 }
        }
       _SQLdebug(( fname, "%s\n", "Closing Cursor" ));

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3797 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

	  
          for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_15.sqld; ++x)
            free (out_desc_15.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3823 "SQLqry11-20.rc"

          free (str);

          free (out_desc_15.sqlvar);
          SQLcursor[15] = 0;
          SQLcursor_count[15] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_15.sqld; ++i)
        {
          free (out_desc_15.sqlvar [i].sqldata);
          free (out_desc_15.sqlvar [i].sqlind);
        }

       free (out_desc_15.sqlvar);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3842 "SQLqry11-20.rc"

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
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }
          SQLcursor[15] = 0;
	  SQLcursor_count[15] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[15] = 0;
       SQLcursor_count[15] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor16 (sql_str16, list, size, rows)

#line 3874 "SQLqry11-20.rc"

char * sql_str16;

#line 3876 "SQLqry11-20.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor16" ;

#line 3885 "SQLqry11-20.rc"

long status;

#line 3886 "SQLqry11-20.rc"

long i;

#line 3887 "SQLqry11-20.rc"

long x;

#line 3888 "SQLqry11-20.rc"

long NEW_LIST;

#line 3889 "SQLqry11-20.rc"

long fetch_count;

#line 3890 "SQLqry11-20.rc"

char data_type[30];

#line 3891 "SQLqry11-20.rc"

char data[30];

#line 3892 "SQLqry11-20.rc"

char * str;

#line 3893 "SQLqry11-20.rc"

char * data1;

#line 3894 "SQLqry11-20.rc"

char * * format;

#line 3895 "SQLqry11-20.rc"

datetime * ptr;

#line 3896 "SQLqry11-20.rc"

char column_name[50];

#line 3898 "SQLqry11-20.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str16, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[16] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[16] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt16" ));
{RISint_prepare(&RIScpp_stmt_id5,sql_str16,1,0);
}

#line 3917 "SQLqry11-20.rc"

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
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
 	             status));
	      ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 3935 "SQLqry11-20.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_16.sqld = 0;
       out_desc_16.sqln = 0;
       out_desc_16.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id5,&out_desc_16,1);
}

#line 3950 "SQLqry11-20.rc"

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
	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
	       ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 3968 "SQLqry11-20.rc"

           return (status);
        }
    } /* if( !SQLcursor[16] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 3979 "SQLqry11-20.rc"

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
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 3992 "SQLqry11-20.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[16] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_16" ));
        out_desc_16.sqlvar = (sqlvar *)calloc(out_desc_16.sqld, sizeof (sqlvar));
        if (! out_desc_16.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4010 "SQLqry11-20.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_16.sqln = out_desc_16.sqld;

{RISint_describe(RIScpp_stmt_id5,&out_desc_16,1);
}

#line 4019 "SQLqry11-20.rc"

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
  	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
  	       ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4038 "SQLqry11-20.rc"

        free (out_desc_16.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_16.sqld; ++i)
        {
          out_desc_16.sqlvar [i].sqldata =
                 calloc (1, out_desc_16.sqlvar [i].sqllen);
          if (! out_desc_16.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_16.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_16.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4052 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_16.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_16.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_16.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_16.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_16.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4067 "SQLqry11-20.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_16.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_16.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_16.sqld; ++x)
                free (out_desc_16.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_16.sqld; ++x)
                free (out_desc_16.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4089 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_16.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[16] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_16.sqld ));
       for (i = 0; i < out_desc_16.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_16.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_16.sqlvar[i].sqllen);
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
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
				status ));	
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc_16.sqld; ++x)
                   free (out_desc_16.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_16.sqld; ++x)
                   free (out_desc_16.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4147 "SQLqry11-20.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_16.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_16.sqlvar [i].sqlname.sqlnamec,
		       out_desc_16.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_16.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_16.sqld; ++x)
                   free (out_desc_16.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_16.sqld; ++x)
                   free (out_desc_16.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4170 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_16.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.8x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc_16.sqld; ++x)
                   free (out_desc_16.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_16.sqld; ++x)
                   free (out_desc_16.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4190 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_16.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[16] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 4204 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4229 "SQLqry11-20.rc"

          free (out_desc_16.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id5,0,0,7,1,0);
}

#line 4234 "SQLqry11-20.rc"

        _SQLdebug(( fname, "%s\n", "Open cursor" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4260 "SQLqry11-20.rc"

          free (out_desc_16.sqlvar);
          return (status);
        }
    SQLcursor[16] = 1;

    } /* end if( !SQLcursor[16] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[16] != 0 )
    {
        for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4282 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4283 "SQLqry11-20.rc"


        free (out_desc_16.sqlvar); 
    }
    SQLcursor[16] = 0;
    SQLcursor_count[16] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id5,0,&out_desc_16,0,7);
}

#line 4295 "SQLqry11-20.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs16 (First time)" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             if( SQLcursor[16] && ( SQLcursor_count[16] > 0 ) )
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4323 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4324 "SQLqry11-20.rc"


          free (out_desc_16.sqlvar); 
          SQLcursor[16] = 0;
          SQLcursor_count[16] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4342 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4343 "SQLqry11-20.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_16.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[16] = 0;
          SQLcursor_count[16] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[16];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_16.sqld; ++i)
           {
             if (*out_desc_16.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_16.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_16.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_16.sqld; ++x)
                       free (out_desc_16.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_16.sqld; ++x)
                       free (out_desc_16.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4384 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4385 "SQLqry11-20.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_16.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[16] = 0;
	             SQLcursor_count[16] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_16.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_16.sqlvar[i].sqllen, 
                  out_desc_16.sqlvar[i].sqllen, out_desc_16.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_16.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_16.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_16.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_16.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_16.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_16.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_16.sqld; ++x)
                    free (out_desc_16.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_16.sqld; ++x)
                    free (out_desc_16.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4453 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4454 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_16.sqlvar);
 	          SQLcursor[16] = 0;
  	          SQLcursor_count[16] = 0;
	          sprintf (message, "RISdatetime_to_ascii : error %ld",
			   status);
	          ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
	          return (SQL_E_MESSAGE) ;
               }
                  strcat (str, data);
                  strcat (str, "\1");
		break;

                default :
	          status = SQL_E_DATA_TYPE ;
                  for (x = 0; x < out_desc_16.sqld; ++x)
                    free (out_desc_16.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_16.sqld; ++x)
                    free (out_desc_16.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4477 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4478 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_16.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[16] = 0;
	          SQLcursor_count[16] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_16.sqld; ++x)
               free (out_desc_16.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_16.sqld; ++x)
               free (out_desc_16.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4500 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4501 "SQLqry11-20.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_16.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[16] = 0;
              SQLcursor_count[16] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id5,0,&out_desc_16,0,7);
}

#line 4514 "SQLqry11-20.rc"

          _SQLdebug(( fname, "%s\n", "Fetch in loop" ));
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
                status = SQL_I_NO_ROWS_FOUND;
                if( SQLcursor[16] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_16.sqld; ++x)
               free (out_desc_16.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_16.sqld; ++x)
               free (out_desc_16.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4542 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4543 "SQLqry11-20.rc"

             free (str);

             free (out_desc_16.sqlvar);
             SQLcursor[16] = 0;
             SQLcursor_count[16] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[16];
	 } /*  end if( fetch_count < rows ) */
	 else
	 {
	     _SQLdebug(( fname, "Fetch_count <%d> :  Requested Rows <%d>\n",
			 fetch_count, rows ));	
	     _SQLdebug(( fname, "%s\n", "Reached Requested Row # before End of Data " ));
	     free( str );
	     return (SQL_S_SUCCESS);
	 }
        }
       _SQLdebug(( fname, "%s\n", "Closing Cursor" ));

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4565 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

	  
          for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_16.sqld; ++x)
            free (out_desc_16.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4591 "SQLqry11-20.rc"

          free (str);

          free (out_desc_16.sqlvar);
          SQLcursor[16] = 0;
          SQLcursor_count[16] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_16.sqld; ++i)
        {
          free (out_desc_16.sqlvar [i].sqldata);
          free (out_desc_16.sqlvar [i].sqlind);
        }

       free (out_desc_16.sqlvar);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4610 "SQLqry11-20.rc"

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
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }
          SQLcursor[16] = 0;
	  SQLcursor_count[16] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[16] = 0;
       SQLcursor_count[16] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor17 (sql_str17, list, size, rows)

#line 4643 "SQLqry11-20.rc"

char * sql_str17;

#line 4645 "SQLqry11-20.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor17" ;

#line 4654 "SQLqry11-20.rc"

long status;

#line 4655 "SQLqry11-20.rc"

long i;

#line 4656 "SQLqry11-20.rc"

long x;

#line 4657 "SQLqry11-20.rc"

long NEW_LIST;

#line 4658 "SQLqry11-20.rc"

long fetch_count;

#line 4659 "SQLqry11-20.rc"

char data_type[30];

#line 4660 "SQLqry11-20.rc"

char data[30];

#line 4661 "SQLqry11-20.rc"

char * str;

#line 4662 "SQLqry11-20.rc"

char * data1;

#line 4663 "SQLqry11-20.rc"

char * * format;

#line 4664 "SQLqry11-20.rc"

datetime * ptr;

#line 4665 "SQLqry11-20.rc"

char column_name[50];

#line 4667 "SQLqry11-20.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str17, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[17] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[17] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt17" ));
{RISint_prepare(&RIScpp_stmt_id6,sql_str17,1,0);
}

#line 4686 "SQLqry11-20.rc"

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
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
 	             status));
	      ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4704 "SQLqry11-20.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_17.sqld = 0;
       out_desc_17.sqln = 0;
       out_desc_17.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id6,&out_desc_17,1);
}

#line 4719 "SQLqry11-20.rc"

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
	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
	       ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4737 "SQLqry11-20.rc"

           return (status);
        }
    } /* if( !SQLcursor[17] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4748 "SQLqry11-20.rc"

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
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4761 "SQLqry11-20.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[17] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_17" ));
        out_desc_17.sqlvar = (sqlvar *)calloc(out_desc_17.sqld, sizeof (sqlvar));
        if (! out_desc_17.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4779 "SQLqry11-20.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_17.sqln = out_desc_17.sqld;

{RISint_describe(RIScpp_stmt_id6,&out_desc_17,1);
}

#line 4788 "SQLqry11-20.rc"

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
  	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
  	       ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4807 "SQLqry11-20.rc"

        free (out_desc_17.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_17.sqld; ++i)
        {
          out_desc_17.sqlvar [i].sqldata =
                 calloc (1, out_desc_17.sqlvar [i].sqllen);
          if (! out_desc_17.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_17.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_17.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4821 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_17.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_17.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_17.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_17.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_17.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4836 "SQLqry11-20.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_17.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_17.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_17.sqld; ++x)
                free (out_desc_17.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_17.sqld; ++x)
                free (out_desc_17.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4858 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_17.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[17] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_17.sqld ));
       for (i = 0; i < out_desc_17.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_17.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_17.sqlvar[i].sqllen);
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
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
				status ));	
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc_17.sqld; ++x)
                   free (out_desc_17.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_17.sqld; ++x)
                   free (out_desc_17.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4916 "SQLqry11-20.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_17.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_17.sqlvar [i].sqlname.sqlnamec,
		       out_desc_17.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_17.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_17.sqld; ++x)
                   free (out_desc_17.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_17.sqld; ++x)
                   free (out_desc_17.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4939 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_17.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.8x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc_17.sqld; ++x)
                   free (out_desc_17.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_17.sqld; ++x)
                   free (out_desc_17.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4959 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_17.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[17] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 4973 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4998 "SQLqry11-20.rc"

          free (out_desc_17.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id6,0,0,7,1,0);
}

#line 5003 "SQLqry11-20.rc"

        _SQLdebug(( fname, "%s\n", "Open cursor" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5029 "SQLqry11-20.rc"

          free (out_desc_17.sqlvar);
          return (status);
        }
    SQLcursor[17] = 1;

    } /* end if( !SQLcursor[17] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[17] != 0 )
    {
        for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5051 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5052 "SQLqry11-20.rc"


        free (out_desc_17.sqlvar); 
    }
    SQLcursor[17] = 0;
    SQLcursor_count[17] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id6,0,&out_desc_17,0,7);
}

#line 5064 "SQLqry11-20.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs17 (First time)" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             if( SQLcursor[17] && ( SQLcursor_count[17] > 0 ) )
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5092 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5093 "SQLqry11-20.rc"


          free (out_desc_17.sqlvar); 
          SQLcursor[17] = 0;
          SQLcursor_count[17] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5111 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5112 "SQLqry11-20.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_17.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[17] = 0;
          SQLcursor_count[17] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[17];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_17.sqld; ++i)
           {
             if (*out_desc_17.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_17.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_17.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_17.sqld; ++x)
                       free (out_desc_17.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_17.sqld; ++x)
                       free (out_desc_17.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5153 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5154 "SQLqry11-20.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_17.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[17] = 0;
	             SQLcursor_count[17] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_17.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_17.sqlvar[i].sqllen, 
                  out_desc_17.sqlvar[i].sqllen, out_desc_17.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_17.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_17.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_17.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_17.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_17.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_17.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_17.sqld; ++x)
                    free (out_desc_17.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_17.sqld; ++x)
                    free (out_desc_17.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5222 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5223 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_17.sqlvar);
 	          SQLcursor[17] = 0;
  	          SQLcursor_count[17] = 0;
	          sprintf (message, "RISdatetime_to_ascii : error %ld",
			   status);
	          ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
	          return (SQL_E_MESSAGE) ;
               }
                  strcat (str, data);
                  strcat (str, "\1");
		break;

                default :
	          status = SQL_E_DATA_TYPE ;
                  for (x = 0; x < out_desc_17.sqld; ++x)
                    free (out_desc_17.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_17.sqld; ++x)
                    free (out_desc_17.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5246 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5247 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_17.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[17] = 0;
	          SQLcursor_count[17] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_17.sqld; ++x)
               free (out_desc_17.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_17.sqld; ++x)
               free (out_desc_17.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5269 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5270 "SQLqry11-20.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_17.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[17] = 0;
              SQLcursor_count[17] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id6,0,&out_desc_17,0,7);
}

#line 5283 "SQLqry11-20.rc"

          _SQLdebug(( fname, "%s\n", "Fetch in loop" ));
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
                status = SQL_I_NO_ROWS_FOUND;
                if( SQLcursor[17] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_17.sqld; ++x)
               free (out_desc_17.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_17.sqld; ++x)
               free (out_desc_17.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5311 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5312 "SQLqry11-20.rc"

             free (str);

             free (out_desc_17.sqlvar);
             SQLcursor[17] = 0;
             SQLcursor_count[17] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[17];
	 } /*  end if( fetch_count < rows ) */
	 else
	 {
	     _SQLdebug(( fname, "Fetch_count <%d> :  Requested Rows <%d>\n",
			 fetch_count, rows ));	
	     _SQLdebug(( fname, "%s\n", "Reached Requested Row # before End of Data " ));
	     free( str );
	     return (SQL_S_SUCCESS);
	 }
        }
       _SQLdebug(( fname, "%s\n", "Closing Cursor" ));

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5334 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

	  
          for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_17.sqld; ++x)
            free (out_desc_17.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5360 "SQLqry11-20.rc"

          free (str);

          free (out_desc_17.sqlvar);
          SQLcursor[17] = 0;
          SQLcursor_count[17] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_17.sqld; ++i)
        {
          free (out_desc_17.sqlvar [i].sqldata);
          free (out_desc_17.sqlvar [i].sqlind);
        }

       free (out_desc_17.sqlvar);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5379 "SQLqry11-20.rc"

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
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }
          SQLcursor[17] = 0;
	  SQLcursor_count[17] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[17] = 0;
       SQLcursor_count[17] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor18 (sql_str18, list, size, rows)

#line 5412 "SQLqry11-20.rc"

char * sql_str18;

#line 5414 "SQLqry11-20.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor18" ;

#line 5423 "SQLqry11-20.rc"

long status;

#line 5424 "SQLqry11-20.rc"

long i;

#line 5425 "SQLqry11-20.rc"

long x;

#line 5426 "SQLqry11-20.rc"

long NEW_LIST;

#line 5427 "SQLqry11-20.rc"

long fetch_count;

#line 5428 "SQLqry11-20.rc"

char data_type[30];

#line 5429 "SQLqry11-20.rc"

char data[30];

#line 5430 "SQLqry11-20.rc"

char * str;

#line 5431 "SQLqry11-20.rc"

char * data1;

#line 5432 "SQLqry11-20.rc"

char * * format;

#line 5433 "SQLqry11-20.rc"

datetime * ptr;

#line 5434 "SQLqry11-20.rc"

char column_name[50];

#line 5436 "SQLqry11-20.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str18, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[18] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[18] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt18" ));
{RISint_prepare(&RIScpp_stmt_id7,sql_str18,1,0);
}

#line 5455 "SQLqry11-20.rc"

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
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
 	             status));
	      ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5473 "SQLqry11-20.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_18.sqld = 0;
       out_desc_18.sqln = 0;
       out_desc_18.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id7,&out_desc_18,1);
}

#line 5488 "SQLqry11-20.rc"

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
	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
	       ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5506 "SQLqry11-20.rc"

           return (status);
        }
    } /* if( !SQLcursor[18] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5517 "SQLqry11-20.rc"

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
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5530 "SQLqry11-20.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[18] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_18" ));
        out_desc_18.sqlvar = (sqlvar *)calloc(out_desc_18.sqld, sizeof (sqlvar));
        if (! out_desc_18.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5548 "SQLqry11-20.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_18.sqln = out_desc_18.sqld;

{RISint_describe(RIScpp_stmt_id7,&out_desc_18,1);
}

#line 5557 "SQLqry11-20.rc"

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
  	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
  	       ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5576 "SQLqry11-20.rc"

        free (out_desc_18.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_18.sqld; ++i)
        {
          out_desc_18.sqlvar [i].sqldata =
                 calloc (1, out_desc_18.sqlvar [i].sqllen);
          if (! out_desc_18.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_18.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_18.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5590 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_18.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_18.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_18.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_18.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_18.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5605 "SQLqry11-20.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_18.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_18.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_18.sqld; ++x)
                free (out_desc_18.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_18.sqld; ++x)
                free (out_desc_18.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5627 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_18.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[18] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_18.sqld ));
       for (i = 0; i < out_desc_18.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_18.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_18.sqlvar[i].sqllen);
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
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
				status ));	
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc_18.sqld; ++x)
                   free (out_desc_18.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_18.sqld; ++x)
                   free (out_desc_18.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5685 "SQLqry11-20.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_18.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_18.sqlvar [i].sqlname.sqlnamec,
		       out_desc_18.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_18.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_18.sqld; ++x)
                   free (out_desc_18.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_18.sqld; ++x)
                   free (out_desc_18.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5708 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_18.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.8x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc_18.sqld; ++x)
                   free (out_desc_18.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_18.sqld; ++x)
                   free (out_desc_18.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5728 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_18.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[18] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 5742 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5767 "SQLqry11-20.rc"

          free (out_desc_18.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id7,0,0,7,1,0);
}

#line 5772 "SQLqry11-20.rc"

        _SQLdebug(( fname, "%s\n", "Open cursor" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5798 "SQLqry11-20.rc"

          free (out_desc_18.sqlvar);
          return (status);
        }
    SQLcursor[18] = 1;

    } /* end if( !SQLcursor[18] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[18] != 0 )
    {
        for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5820 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5821 "SQLqry11-20.rc"


        free (out_desc_18.sqlvar); 
    }
    SQLcursor[18] = 0;
    SQLcursor_count[18] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id7,0,&out_desc_18,0,7);
}

#line 5833 "SQLqry11-20.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs18 (First time)" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             if( SQLcursor[18] && ( SQLcursor_count[18] > 0 ) )
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5861 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5862 "SQLqry11-20.rc"


          free (out_desc_18.sqlvar); 
          SQLcursor[18] = 0;
          SQLcursor_count[18] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5880 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5881 "SQLqry11-20.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_18.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[18] = 0;
          SQLcursor_count[18] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[18];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_18.sqld; ++i)
           {
             if (*out_desc_18.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_18.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_18.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_18.sqld; ++x)
                       free (out_desc_18.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_18.sqld; ++x)
                       free (out_desc_18.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5922 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5923 "SQLqry11-20.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_18.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[18] = 0;
	             SQLcursor_count[18] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_18.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_18.sqlvar[i].sqllen, 
                  out_desc_18.sqlvar[i].sqllen, out_desc_18.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_18.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_18.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_18.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_18.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_18.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_18.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_18.sqld; ++x)
                    free (out_desc_18.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_18.sqld; ++x)
                    free (out_desc_18.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5991 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5992 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_18.sqlvar);
 	          SQLcursor[18] = 0;
  	          SQLcursor_count[18] = 0;
	          sprintf (message, "RISdatetime_to_ascii : error %ld",
			   status);
	          ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
	          return (SQL_E_MESSAGE) ;
               }
                  strcat (str, data);
                  strcat (str, "\1");
		break;

                default :
	          status = SQL_E_DATA_TYPE ;
                  for (x = 0; x < out_desc_18.sqld; ++x)
                    free (out_desc_18.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_18.sqld; ++x)
                    free (out_desc_18.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6015 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6016 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_18.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[18] = 0;
	          SQLcursor_count[18] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_18.sqld; ++x)
               free (out_desc_18.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_18.sqld; ++x)
               free (out_desc_18.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6038 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6039 "SQLqry11-20.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_18.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[18] = 0;
              SQLcursor_count[18] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id7,0,&out_desc_18,0,7);
}

#line 6052 "SQLqry11-20.rc"

          _SQLdebug(( fname, "%s\n", "Fetch in loop" ));
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
                status = SQL_I_NO_ROWS_FOUND;
                if( SQLcursor[18] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_18.sqld; ++x)
               free (out_desc_18.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_18.sqld; ++x)
               free (out_desc_18.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6080 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6081 "SQLqry11-20.rc"

             free (str);

             free (out_desc_18.sqlvar);
             SQLcursor[18] = 0;
             SQLcursor_count[18] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[18];
	 } /*  end if( fetch_count < rows ) */
	 else
	 {
	     _SQLdebug(( fname, "Fetch_count <%d> :  Requested Rows <%d>\n",
			 fetch_count, rows ));	
	     _SQLdebug(( fname, "%s\n", "Reached Requested Row # before End of Data " ));
	     free( str );
	     return (SQL_S_SUCCESS);
	 }
        }
       _SQLdebug(( fname, "%s\n", "Closing Cursor" ));

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6103 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

	  
          for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_18.sqld; ++x)
            free (out_desc_18.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6129 "SQLqry11-20.rc"

          free (str);

          free (out_desc_18.sqlvar);
          SQLcursor[18] = 0;
          SQLcursor_count[18] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_18.sqld; ++i)
        {
          free (out_desc_18.sqlvar [i].sqldata);
          free (out_desc_18.sqlvar [i].sqlind);
        }

       free (out_desc_18.sqlvar);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6148 "SQLqry11-20.rc"

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
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }
          SQLcursor[18] = 0;
	  SQLcursor_count[18] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[18] = 0;
       SQLcursor_count[18] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor19 (sql_str19, list, size, rows)

#line 6181 "SQLqry11-20.rc"

char * sql_str19;

#line 6183 "SQLqry11-20.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor19" ;

#line 6192 "SQLqry11-20.rc"

long status;

#line 6193 "SQLqry11-20.rc"

long i;

#line 6194 "SQLqry11-20.rc"

long x;

#line 6195 "SQLqry11-20.rc"

long NEW_LIST;

#line 6196 "SQLqry11-20.rc"

long fetch_count;

#line 6197 "SQLqry11-20.rc"

char data_type[30];

#line 6198 "SQLqry11-20.rc"

char data[30];

#line 6199 "SQLqry11-20.rc"

char * str;

#line 6200 "SQLqry11-20.rc"

char * data1;

#line 6201 "SQLqry11-20.rc"

char * * format;

#line 6202 "SQLqry11-20.rc"

datetime * ptr;

#line 6203 "SQLqry11-20.rc"

char column_name[50];

#line 6205 "SQLqry11-20.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str19, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[19] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[19] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt19" ));
{RISint_prepare(&RIScpp_stmt_id8,sql_str19,1,0);
}

#line 6224 "SQLqry11-20.rc"

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
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
 	             status));
	      ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6242 "SQLqry11-20.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_19.sqld = 0;
       out_desc_19.sqln = 0;
       out_desc_19.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id8,&out_desc_19,1);
}

#line 6257 "SQLqry11-20.rc"

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
	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
	       ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6275 "SQLqry11-20.rc"

           return (status);
        }
    } /* if( !SQLcursor[19] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6286 "SQLqry11-20.rc"

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
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6299 "SQLqry11-20.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[19] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_19" ));
        out_desc_19.sqlvar = (sqlvar *)calloc(out_desc_19.sqld, sizeof (sqlvar));
        if (! out_desc_19.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6317 "SQLqry11-20.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_19.sqln = out_desc_19.sqld;

{RISint_describe(RIScpp_stmt_id8,&out_desc_19,1);
}

#line 6326 "SQLqry11-20.rc"

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
  	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
  	       ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6345 "SQLqry11-20.rc"

        free (out_desc_19.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_19.sqld; ++i)
        {
          out_desc_19.sqlvar [i].sqldata =
                 calloc (1, out_desc_19.sqlvar [i].sqllen);
          if (! out_desc_19.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_19.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_19.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6359 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_19.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_19.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_19.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_19.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_19.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6374 "SQLqry11-20.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_19.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_19.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_19.sqld; ++x)
                free (out_desc_19.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_19.sqld; ++x)
                free (out_desc_19.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6396 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_19.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[19] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_19.sqld ));
       for (i = 0; i < out_desc_19.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_19.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_19.sqlvar[i].sqllen);
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
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
				status ));	
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc_19.sqld; ++x)
                   free (out_desc_19.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_19.sqld; ++x)
                   free (out_desc_19.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6454 "SQLqry11-20.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_19.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_19.sqlvar [i].sqlname.sqlnamec,
		       out_desc_19.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_19.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_19.sqld; ++x)
                   free (out_desc_19.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_19.sqld; ++x)
                   free (out_desc_19.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6477 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_19.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.8x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc_19.sqld; ++x)
                   free (out_desc_19.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_19.sqld; ++x)
                   free (out_desc_19.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6497 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_19.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[19] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 6511 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6536 "SQLqry11-20.rc"

          free (out_desc_19.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id8,0,0,7,1,0);
}

#line 6541 "SQLqry11-20.rc"

        _SQLdebug(( fname, "%s\n", "Open cursor" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6567 "SQLqry11-20.rc"

          free (out_desc_19.sqlvar);
          return (status);
        }
    SQLcursor[19] = 1;

    } /* end if( !SQLcursor[19] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[19] != 0 )
    {
        for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6589 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6590 "SQLqry11-20.rc"


        free (out_desc_19.sqlvar); 
    }
    SQLcursor[19] = 0;
    SQLcursor_count[19] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id8,0,&out_desc_19,0,7);
}

#line 6602 "SQLqry11-20.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs19 (First time)" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             if( SQLcursor[19] && ( SQLcursor_count[19] > 0 ) )
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6630 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6631 "SQLqry11-20.rc"


          free (out_desc_19.sqlvar); 
          SQLcursor[19] = 0;
          SQLcursor_count[19] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6649 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6650 "SQLqry11-20.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_19.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[19] = 0;
          SQLcursor_count[19] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[19];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_19.sqld; ++i)
           {
             if (*out_desc_19.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_19.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_19.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_19.sqld; ++x)
                       free (out_desc_19.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_19.sqld; ++x)
                       free (out_desc_19.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6691 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6692 "SQLqry11-20.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_19.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[19] = 0;
	             SQLcursor_count[19] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_19.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_19.sqlvar[i].sqllen, 
                  out_desc_19.sqlvar[i].sqllen, out_desc_19.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_19.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_19.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_19.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_19.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_19.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_19.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_19.sqld; ++x)
                    free (out_desc_19.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_19.sqld; ++x)
                    free (out_desc_19.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6760 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6761 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_19.sqlvar);
 	          SQLcursor[19] = 0;
  	          SQLcursor_count[19] = 0;
	          sprintf (message, "RISdatetime_to_ascii : error %ld",
			   status);
	          ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
	          return (SQL_E_MESSAGE) ;
               }
                  strcat (str, data);
                  strcat (str, "\1");
		break;

                default :
	          status = SQL_E_DATA_TYPE ;
                  for (x = 0; x < out_desc_19.sqld; ++x)
                    free (out_desc_19.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_19.sqld; ++x)
                    free (out_desc_19.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6784 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6785 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_19.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[19] = 0;
	          SQLcursor_count[19] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_19.sqld; ++x)
               free (out_desc_19.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_19.sqld; ++x)
               free (out_desc_19.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6807 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6808 "SQLqry11-20.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_19.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[19] = 0;
              SQLcursor_count[19] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id8,0,&out_desc_19,0,7);
}

#line 6821 "SQLqry11-20.rc"

          _SQLdebug(( fname, "%s\n", "Fetch in loop" ));
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
                status = SQL_I_NO_ROWS_FOUND;
                if( SQLcursor[19] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_19.sqld; ++x)
               free (out_desc_19.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_19.sqld; ++x)
               free (out_desc_19.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6849 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6850 "SQLqry11-20.rc"

             free (str);

             free (out_desc_19.sqlvar);
             SQLcursor[19] = 0;
             SQLcursor_count[19] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[19];
	 } /*  end if( fetch_count < rows ) */
	 else
	 {
	     _SQLdebug(( fname, "Fetch_count <%d> :  Requested Rows <%d>\n",
			 fetch_count, rows ));	
	     _SQLdebug(( fname, "%s\n", "Reached Requested Row # before End of Data " ));
	     free( str );
	     return (SQL_S_SUCCESS);
	 }
        }
       _SQLdebug(( fname, "%s\n", "Closing Cursor" ));

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6872 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

	  
          for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_19.sqld; ++x)
            free (out_desc_19.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6898 "SQLqry11-20.rc"

          free (str);

          free (out_desc_19.sqlvar);
          SQLcursor[19] = 0;
          SQLcursor_count[19] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_19.sqld; ++i)
        {
          free (out_desc_19.sqlvar [i].sqldata);
          free (out_desc_19.sqlvar [i].sqlind);
        }

       free (out_desc_19.sqlvar);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6917 "SQLqry11-20.rc"

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
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }
          SQLcursor[19] = 0;
	  SQLcursor_count[19] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[19] = 0;
       SQLcursor_count[19] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor20 (sql_str20, list, size, rows)

#line 6950 "SQLqry11-20.rc"

char * sql_str20;

#line 6952 "SQLqry11-20.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor20" ;

#line 6961 "SQLqry11-20.rc"

long status;

#line 6962 "SQLqry11-20.rc"

long i;

#line 6963 "SQLqry11-20.rc"

long x;

#line 6964 "SQLqry11-20.rc"

long NEW_LIST;

#line 6965 "SQLqry11-20.rc"

long fetch_count;

#line 6966 "SQLqry11-20.rc"

char data_type[30];

#line 6967 "SQLqry11-20.rc"

char data[30];

#line 6968 "SQLqry11-20.rc"

char * str;

#line 6969 "SQLqry11-20.rc"

char * data1;

#line 6970 "SQLqry11-20.rc"

char * * format;

#line 6971 "SQLqry11-20.rc"

datetime * ptr;

#line 6972 "SQLqry11-20.rc"

char column_name[50];

#line 6974 "SQLqry11-20.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str20, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[20] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[20] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt20" ));
{RISint_prepare(&RIScpp_stmt_id9,sql_str20,1,0);
}

#line 6993 "SQLqry11-20.rc"

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
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
 	             status));
	      ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7011 "SQLqry11-20.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_20.sqld = 0;
       out_desc_20.sqln = 0;
       out_desc_20.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id9,&out_desc_20,1);
}

#line 7026 "SQLqry11-20.rc"

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
	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
	       ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7044 "SQLqry11-20.rc"

           return (status);
        }
    } /* if( !SQLcursor[20] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7055 "SQLqry11-20.rc"

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
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7068 "SQLqry11-20.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[20] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_20" ));
        out_desc_20.sqlvar = (sqlvar *)calloc(out_desc_20.sqld, sizeof (sqlvar));
        if (! out_desc_20.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7086 "SQLqry11-20.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_20.sqln = out_desc_20.sqld;

{RISint_describe(RIScpp_stmt_id9,&out_desc_20,1);
}

#line 7095 "SQLqry11-20.rc"

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
  	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
	             status));
  	       ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7114 "SQLqry11-20.rc"

        free (out_desc_20.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_20.sqld; ++i)
        {
          out_desc_20.sqlvar [i].sqldata =
                 calloc (1, out_desc_20.sqlvar [i].sqllen);
          if (! out_desc_20.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_20.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_20.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7128 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_20.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_20.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_20.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_20.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_20.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7143 "SQLqry11-20.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_20.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_20.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_20.sqld; ++x)
                free (out_desc_20.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_20.sqld; ++x)
                free (out_desc_20.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7165 "SQLqry11-20.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_20.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[20] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_20.sqld ));
       for (i = 0; i < out_desc_20.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_20.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_20.sqlvar[i].sqllen);
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
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
				status ));	
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc_20.sqld; ++x)
                   free (out_desc_20.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_20.sqld; ++x)
                   free (out_desc_20.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7223 "SQLqry11-20.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_20.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_20.sqlvar [i].sqlname.sqlnamec,
		       out_desc_20.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_20.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_20.sqld; ++x)
                   free (out_desc_20.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_20.sqld; ++x)
                   free (out_desc_20.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7246 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_20.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.8x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc_20.sqld; ++x)
                   free (out_desc_20.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_20.sqld; ++x)
                   free (out_desc_20.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7266 "SQLqry11-20.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_20.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[20] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 7280 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7305 "SQLqry11-20.rc"

          free (out_desc_20.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id9,0,0,7,1,0);
}

#line 7310 "SQLqry11-20.rc"

        _SQLdebug(( fname, "%s\n", "Open cursor" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7336 "SQLqry11-20.rc"

          free (out_desc_20.sqlvar);
          return (status);
        }
    SQLcursor[20] = 1;

    } /* end if( !SQLcursor[20] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[20] != 0 )
    {
        for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7358 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7359 "SQLqry11-20.rc"


        free (out_desc_20.sqlvar); 
    }
    SQLcursor[20] = 0;
    SQLcursor_count[20] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id9,0,&out_desc_20,0,7);
}

#line 7371 "SQLqry11-20.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs20 (First time)" ));
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
	     status = SQL_I_NO_ROWS_FOUND ;
             if( SQLcursor[20] && ( SQLcursor_count[20] > 0 ) )
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7399 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7400 "SQLqry11-20.rc"


          free (out_desc_20.sqlvar); 
          SQLcursor[20] = 0;
          SQLcursor_count[20] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7418 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7419 "SQLqry11-20.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_20.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[20] = 0;
          SQLcursor_count[20] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[20];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_20.sqld; ++i)
           {
             if (*out_desc_20.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_20.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_20.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_20.sqld; ++x)
                       free (out_desc_20.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_20.sqld; ++x)
                       free (out_desc_20.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7460 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7461 "SQLqry11-20.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_20.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[20] = 0;
	             SQLcursor_count[20] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_20.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_20.sqlvar[i].sqllen, 
                  out_desc_20.sqlvar[i].sqllen, out_desc_20.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_20.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_20.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_20.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_20.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_20.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_20.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_20.sqld; ++x)
                    free (out_desc_20.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_20.sqld; ++x)
                    free (out_desc_20.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7529 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7530 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_20.sqlvar);
 	          SQLcursor[20] = 0;
  	          SQLcursor_count[20] = 0;
	          sprintf (message, "RISdatetime_to_ascii : error %ld",
			   status);
	          ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
	          return (SQL_E_MESSAGE) ;
               }
                  strcat (str, data);
                  strcat (str, "\1");
		break;

                default :
	          status = SQL_E_DATA_TYPE ;
                  for (x = 0; x < out_desc_20.sqld; ++x)
                    free (out_desc_20.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_20.sqld; ++x)
                    free (out_desc_20.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7553 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7554 "SQLqry11-20.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_20.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[20] = 0;
	          SQLcursor_count[20] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_20.sqld; ++x)
               free (out_desc_20.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_20.sqld; ++x)
               free (out_desc_20.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7576 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7577 "SQLqry11-20.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_20.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[20] = 0;
              SQLcursor_count[20] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id9,0,&out_desc_20,0,7);
}

#line 7590 "SQLqry11-20.rc"

          _SQLdebug(( fname, "%s\n", "Fetch in loop" ));
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
                status = SQL_I_NO_ROWS_FOUND;
                if( SQLcursor[20] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_20.sqld; ++x)
               free (out_desc_20.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_20.sqld; ++x)
               free (out_desc_20.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7618 "SQLqry11-20.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7619 "SQLqry11-20.rc"

             free (str);

             free (out_desc_20.sqlvar);
             SQLcursor[20] = 0;
             SQLcursor_count[20] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[20];
	 } /*  end if( fetch_count < rows ) */
	 else
	 {
	     _SQLdebug(( fname, "Fetch_count <%d> :  Requested Rows <%d>\n",
			 fetch_count, rows ));	
	     _SQLdebug(( fname, "%s\n", "Reached Requested Row # before End of Data " ));
	     free( str );
	     return (SQL_S_SUCCESS);
	 }
        }
       _SQLdebug(( fname, "%s\n", "Closing Cursor" ));

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7641 "SQLqry11-20.rc"

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
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

	  
          for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_20.sqld; ++x)
            free (out_desc_20.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7667 "SQLqry11-20.rc"

          free (str);

          free (out_desc_20.sqlvar);
          SQLcursor[20] = 0;
          SQLcursor_count[20] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_20.sqld; ++i)
        {
          free (out_desc_20.sqlvar [i].sqldata);
          free (out_desc_20.sqlvar [i].sqlind);
        }

       free (out_desc_20.sqlvar);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7686 "SQLqry11-20.rc"

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
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }
          SQLcursor[20] = 0;
	  SQLcursor_count[20] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[20] = 0;
       SQLcursor_count[20] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

