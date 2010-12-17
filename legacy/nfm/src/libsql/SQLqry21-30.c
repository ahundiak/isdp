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

#line 1 "SQLqry21-30.rc"
#include "machine.h"
#include "SQL.h"

 extern struct SQLglobal_st SQLglobal ;

 extern long SQLquery_count;
 extern int  SQLcursor[41];
 extern long SQLcursor_count[41];


#line 10 "SQLqry21-30.rc"

sqlda out_desc_21;

#line 11 "SQLqry21-30.rc"

sqlda out_desc_22;

#line 12 "SQLqry21-30.rc"

sqlda out_desc_23;

#line 13 "SQLqry21-30.rc"

sqlda out_desc_24;

#line 14 "SQLqry21-30.rc"

sqlda out_desc_25;

#line 15 "SQLqry21-30.rc"

sqlda out_desc_26;

#line 16 "SQLqry21-30.rc"

sqlda out_desc_27;

#line 17 "SQLqry21-30.rc"

sqlda out_desc_28;

#line 18 "SQLqry21-30.rc"

sqlda out_desc_29;

#line 19 "SQLqry21-30.rc"

sqlda out_desc_30;

#line 21 "SQLqry21-30.rc"


 char   *malloc (), *calloc ();

/*  This query routine was developed to be used with large query buffers
 *  where only portions of the data are to be returned. Cursor 2 is used
 *  for display items (full listing).
 */

 long  SQLquery_cursor21 (sql_str21, list, size, rows)

#line 31 "SQLqry21-30.rc"

char * sql_str21;

#line 33 "SQLqry21-30.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor21" ;

#line 42 "SQLqry21-30.rc"

long status;

#line 43 "SQLqry21-30.rc"

long i;

#line 44 "SQLqry21-30.rc"

long x;

#line 45 "SQLqry21-30.rc"

long NEW_LIST;

#line 46 "SQLqry21-30.rc"

long fetch_count;

#line 47 "SQLqry21-30.rc"

char data_type[30];

#line 48 "SQLqry21-30.rc"

char data[30];

#line 49 "SQLqry21-30.rc"

char * str;

#line 50 "SQLqry21-30.rc"

char * data1;

#line 51 "SQLqry21-30.rc"

char * * format;

#line 52 "SQLqry21-30.rc"

datetime * ptr;

#line 53 "SQLqry21-30.rc"

char column_name[50];

#line 55 "SQLqry21-30.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str21, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[21] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[21] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt21" ));
{RISint_prepare(&RIScpp_stmt_id0,sql_str21,1,0);
}

#line 74 "SQLqry21-30.rc"

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

#line 92 "SQLqry21-30.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_21.sqld = 0;
       out_desc_21.sqln = 0;
       out_desc_21.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id0,&out_desc_21,1);
}

#line 107 "SQLqry21-30.rc"

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

#line 125 "SQLqry21-30.rc"

           return (status);
        }
    } /* if( !SQLcursor[21] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 136 "SQLqry21-30.rc"

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

#line 149 "SQLqry21-30.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[21] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_21" ));
        out_desc_21.sqlvar = (sqlvar *)calloc(out_desc_21.sqld, sizeof (sqlvar));
        if (! out_desc_21.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 167 "SQLqry21-30.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_21.sqln = out_desc_21.sqld;

{RISint_describe(RIScpp_stmt_id0,&out_desc_21,1);
}

#line 176 "SQLqry21-30.rc"

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

#line 195 "SQLqry21-30.rc"

        free (out_desc_21.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_21.sqld; ++i)
        {
          out_desc_21.sqlvar [i].sqldata =
                 calloc (1, out_desc_21.sqlvar [i].sqllen);
          if (! out_desc_21.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_21.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_21.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 209 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_21.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_21.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_21.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_21.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_21.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 224 "SQLqry21-30.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_21.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_21.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_21.sqld; ++x)
                free (out_desc_21.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_21.sqld; ++x)
                free (out_desc_21.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 246 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_21.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[21] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_21.sqld ));
       for (i = 0; i < out_desc_21.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_21.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_21.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_21.sqld; ++x)
                   free (out_desc_21.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_21.sqld; ++x)
                   free (out_desc_21.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 304 "SQLqry21-30.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_21.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_21.sqlvar [i].sqlname.sqlnamec,
		       out_desc_21.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_21.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_21.sqld; ++x)
                   free (out_desc_21.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_21.sqld; ++x)
                   free (out_desc_21.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 327 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_21.sqlvar);
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

                 for (x = 0; x < out_desc_21.sqld; ++x)
                   free (out_desc_21.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_21.sqld; ++x)
                   free (out_desc_21.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 347 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_21.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[21] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 361 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 386 "SQLqry21-30.rc"

          free (out_desc_21.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
}

#line 391 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 417 "SQLqry21-30.rc"

          free (out_desc_21.sqlvar);
          return (status);
        }
    SQLcursor[21] = 1;

    } /* end if( !SQLcursor[21] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[21] != 0 )
    {
        for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 439 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 440 "SQLqry21-30.rc"


        free (out_desc_21.sqlvar); 
    }
    SQLcursor[21] = 0;
    SQLcursor_count[21] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id0,0,&out_desc_21,0,7);
}

#line 452 "SQLqry21-30.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs21 (First time)" ));
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
                if( SQLcursor[21] && ( SQLcursor_count[21] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 480 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 481 "SQLqry21-30.rc"


          free (out_desc_21.sqlvar); 
          SQLcursor[21] = 0;
          SQLcursor_count[21] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 499 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 500 "SQLqry21-30.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_21.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[21] = 0;
          SQLcursor_count[21] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[21];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_21.sqld; ++i)
           {
             if (*out_desc_21.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_21.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_21.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_21.sqld; ++x)
                       free (out_desc_21.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_21.sqld; ++x)
                       free (out_desc_21.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 541 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 542 "SQLqry21-30.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_21.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[21] = 0;
	             SQLcursor_count[21] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_21.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_21.sqlvar[i].sqllen, 
                  out_desc_21.sqlvar[i].sqllen, out_desc_21.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_21.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_21.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_21.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_21.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_21.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_21.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_21.sqld; ++x)
                    free (out_desc_21.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_21.sqld; ++x)
                    free (out_desc_21.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 610 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 611 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_21.sqlvar);
 	          SQLcursor[21] = 0;
  	          SQLcursor_count[21] = 0;
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
                  for (x = 0; x < out_desc_21.sqld; ++x)
                    free (out_desc_21.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_21.sqld; ++x)
                    free (out_desc_21.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 634 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 635 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_21.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[21] = 0;
	          SQLcursor_count[21] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_21.sqld; ++x)
               free (out_desc_21.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_21.sqld; ++x)
               free (out_desc_21.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 657 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 658 "SQLqry21-30.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_21.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[21] = 0;
              SQLcursor_count[21] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id0,0,&out_desc_21,0,7);
}

#line 671 "SQLqry21-30.rc"

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
                if( SQLcursor[21] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_21.sqld; ++x)
               free (out_desc_21.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_21.sqld; ++x)
               free (out_desc_21.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 699 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 700 "SQLqry21-30.rc"

             free (str);

             free (out_desc_21.sqlvar);
             SQLcursor[21] = 0;
             SQLcursor_count[21] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[21];
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

#line 722 "SQLqry21-30.rc"

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

	  
          for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_21.sqld; ++x)
            free (out_desc_21.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 748 "SQLqry21-30.rc"

          free (str);

          free (out_desc_21.sqlvar);
          SQLcursor[21] = 0;
          SQLcursor_count[21] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_21.sqld; ++i)
        {
          free (out_desc_21.sqlvar [i].sqldata);
          free (out_desc_21.sqlvar [i].sqlind);
        }

       free (out_desc_21.sqlvar);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 767 "SQLqry21-30.rc"

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
          SQLcursor[21] = 0;
	  SQLcursor_count[21] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[21] = 0;
       SQLcursor_count[21] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor22 (sql_str22, list, size, rows)

#line 800 "SQLqry21-30.rc"

char * sql_str22;

#line 802 "SQLqry21-30.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor22" ;

#line 811 "SQLqry21-30.rc"

long status;

#line 812 "SQLqry21-30.rc"

long i;

#line 813 "SQLqry21-30.rc"

long x;

#line 814 "SQLqry21-30.rc"

long NEW_LIST;

#line 815 "SQLqry21-30.rc"

long fetch_count;

#line 816 "SQLqry21-30.rc"

char data_type[30];

#line 817 "SQLqry21-30.rc"

char data[30];

#line 818 "SQLqry21-30.rc"

char * str;

#line 819 "SQLqry21-30.rc"

char * data1;

#line 820 "SQLqry21-30.rc"

char * * format;

#line 821 "SQLqry21-30.rc"

datetime * ptr;

#line 822 "SQLqry21-30.rc"

char column_name[50];

#line 824 "SQLqry21-30.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str22, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[22] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[22] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt22" ));
{RISint_prepare(&RIScpp_stmt_id1,sql_str22,1,0);
}

#line 843 "SQLqry21-30.rc"

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

#line 861 "SQLqry21-30.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_22.sqld = 0;
       out_desc_22.sqln = 0;
       out_desc_22.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id1,&out_desc_22,1);
}

#line 876 "SQLqry21-30.rc"

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

#line 894 "SQLqry21-30.rc"

           return (status);
        }
    } /* if( !SQLcursor[22] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 905 "SQLqry21-30.rc"

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

#line 918 "SQLqry21-30.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[22] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_22" ));
        out_desc_22.sqlvar = (sqlvar *)calloc(out_desc_22.sqld, sizeof (sqlvar));
        if (! out_desc_22.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 936 "SQLqry21-30.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_22.sqln = out_desc_22.sqld;

{RISint_describe(RIScpp_stmt_id1,&out_desc_22,1);
}

#line 945 "SQLqry21-30.rc"

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

#line 964 "SQLqry21-30.rc"

        free (out_desc_22.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_22.sqld; ++i)
        {
          out_desc_22.sqlvar [i].sqldata =
                 calloc (1, out_desc_22.sqlvar [i].sqllen);
          if (! out_desc_22.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_22.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_22.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 978 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_22.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_22.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_22.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_22.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_22.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 993 "SQLqry21-30.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_22.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_22.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_22.sqld; ++x)
                free (out_desc_22.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_22.sqld; ++x)
                free (out_desc_22.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1015 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_22.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[22] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_22.sqld ));
       for (i = 0; i < out_desc_22.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_22.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_22.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_22.sqld; ++x)
                   free (out_desc_22.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_22.sqld; ++x)
                   free (out_desc_22.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1073 "SQLqry21-30.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_22.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_22.sqlvar [i].sqlname.sqlnamec,
		       out_desc_22.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_22.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_22.sqld; ++x)
                   free (out_desc_22.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_22.sqld; ++x)
                   free (out_desc_22.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1096 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_22.sqlvar);
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

                 for (x = 0; x < out_desc_22.sqld; ++x)
                   free (out_desc_22.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_22.sqld; ++x)
                   free (out_desc_22.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1116 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_22.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[22] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 1130 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1155 "SQLqry21-30.rc"

          free (out_desc_22.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
}

#line 1160 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1186 "SQLqry21-30.rc"

          free (out_desc_22.sqlvar);
          return (status);
        }
    SQLcursor[22] = 1;

    } /* end if( !SQLcursor[22] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[22] != 0 )
    {
        for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1208 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1209 "SQLqry21-30.rc"


        free (out_desc_22.sqlvar); 
    }
    SQLcursor[22] = 0;
    SQLcursor_count[22] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id1,0,&out_desc_22,0,7);
}

#line 1221 "SQLqry21-30.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs22 (First time)" ));
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
                if( SQLcursor[22] && ( SQLcursor_count[22] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1249 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1250 "SQLqry21-30.rc"


          free (out_desc_22.sqlvar); 
          SQLcursor[22] = 0;
          SQLcursor_count[22] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1268 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1269 "SQLqry21-30.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_22.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[22] = 0;
          SQLcursor_count[22] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[22];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_22.sqld; ++i)
           {
             if (*out_desc_22.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_22.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_22.sqlvar[i].sqllen + 22);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_22.sqld; ++x)
                       free (out_desc_22.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_22.sqld; ++x)
                       free (out_desc_22.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1310 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1311 "SQLqry21-30.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_22.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[22] = 0;
	             SQLcursor_count[22] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_22.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_22.sqlvar[i].sqllen, 
                  out_desc_22.sqlvar[i].sqllen, out_desc_22.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_22.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_22.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_22.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_22.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_22.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_22.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_22.sqld; ++x)
                    free (out_desc_22.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_22.sqld; ++x)
                    free (out_desc_22.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1379 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1380 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_22.sqlvar);
 	          SQLcursor[22] = 0;
  	          SQLcursor_count[22] = 0;
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
                  for (x = 0; x < out_desc_22.sqld; ++x)
                    free (out_desc_22.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_22.sqld; ++x)
                    free (out_desc_22.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1403 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1404 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_22.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[22] = 0;
	          SQLcursor_count[22] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_22.sqld; ++x)
               free (out_desc_22.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_22.sqld; ++x)
               free (out_desc_22.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1426 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1427 "SQLqry21-30.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_22.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[22] = 0;
              SQLcursor_count[22] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id1,0,&out_desc_22,0,7);
}

#line 1440 "SQLqry21-30.rc"

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
                if( SQLcursor[23] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_22.sqld; ++x)
               free (out_desc_22.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_22.sqld; ++x)
               free (out_desc_22.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1468 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1469 "SQLqry21-30.rc"

             free (str);

             free (out_desc_22.sqlvar);
             SQLcursor[22] = 0;
             SQLcursor_count[22] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[22];
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

#line 1491 "SQLqry21-30.rc"

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

	  
          for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_22.sqld; ++x)
            free (out_desc_22.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1517 "SQLqry21-30.rc"

          free (str);

          free (out_desc_22.sqlvar);
          SQLcursor[22] = 0;
          SQLcursor_count[22] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_22.sqld; ++i)
        {
          free (out_desc_22.sqlvar [i].sqldata);
          free (out_desc_22.sqlvar [i].sqlind);
        }

       free (out_desc_22.sqlvar);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1536 "SQLqry21-30.rc"

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
          SQLcursor[22] = 0;
	  SQLcursor_count[22] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[22] = 0;
       SQLcursor_count[22] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor23 (sql_str23, list, size, rows)

#line 1569 "SQLqry21-30.rc"

char * sql_str23;

#line 1571 "SQLqry21-30.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor23" ;

#line 1580 "SQLqry21-30.rc"

long status;

#line 1581 "SQLqry21-30.rc"

long i;

#line 1582 "SQLqry21-30.rc"

long x;

#line 1583 "SQLqry21-30.rc"

long NEW_LIST;

#line 1584 "SQLqry21-30.rc"

long fetch_count;

#line 1585 "SQLqry21-30.rc"

char data_type[30];

#line 1586 "SQLqry21-30.rc"

char data[30];

#line 1587 "SQLqry21-30.rc"

char * str;

#line 1588 "SQLqry21-30.rc"

char * data1;

#line 1589 "SQLqry21-30.rc"

char * * format;

#line 1590 "SQLqry21-30.rc"

datetime * ptr;

#line 1591 "SQLqry21-30.rc"

char column_name[50];

#line 1593 "SQLqry21-30.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str23, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[23] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[23] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt23" ));
{RISint_prepare(&RIScpp_stmt_id2,sql_str23,1,0);
}

#line 1612 "SQLqry21-30.rc"

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

#line 1630 "SQLqry21-30.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_23.sqld = 0;
       out_desc_23.sqln = 0;
       out_desc_23.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id2,&out_desc_23,1);
}

#line 1645 "SQLqry21-30.rc"

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

#line 1663 "SQLqry21-30.rc"

           return (status);
        }
    } /* if( !SQLcursor[23] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1674 "SQLqry21-30.rc"

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

#line 1687 "SQLqry21-30.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[23] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_23" ));
        out_desc_23.sqlvar = (sqlvar *)calloc(out_desc_23.sqld, sizeof (sqlvar));
        if (! out_desc_23.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1705 "SQLqry21-30.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_23.sqln = out_desc_23.sqld;

{RISint_describe(RIScpp_stmt_id2,&out_desc_23,1);
}

#line 1714 "SQLqry21-30.rc"

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

#line 1733 "SQLqry21-30.rc"

        free (out_desc_23.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_23.sqld; ++i)
        {
          out_desc_23.sqlvar [i].sqldata =
                 calloc (1, out_desc_23.sqlvar [i].sqllen);
          if (! out_desc_23.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_23.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_23.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1747 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_23.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_23.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_23.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_23.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_23.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1762 "SQLqry21-30.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_23.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_23.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_23.sqld; ++x)
                free (out_desc_23.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_23.sqld; ++x)
                free (out_desc_23.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1784 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_23.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[23] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_23.sqld ));
       for (i = 0; i < out_desc_23.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_23.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_23.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_23.sqld; ++x)
                   free (out_desc_23.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_23.sqld; ++x)
                   free (out_desc_23.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1842 "SQLqry21-30.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_23.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_23.sqlvar [i].sqlname.sqlnamec,
		       out_desc_23.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_23.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_23.sqld; ++x)
                   free (out_desc_23.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_23.sqld; ++x)
                   free (out_desc_23.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1865 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_23.sqlvar);
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

                 for (x = 0; x < out_desc_23.sqld; ++x)
                   free (out_desc_23.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_23.sqld; ++x)
                   free (out_desc_23.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1885 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_23.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[23] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 1899 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1924 "SQLqry21-30.rc"

          free (out_desc_23.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id2,0,0,7,1,0);
}

#line 1929 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1955 "SQLqry21-30.rc"

          free (out_desc_23.sqlvar);
          return (status);
        }
    SQLcursor[23] = 1;

    } /* end if( !SQLcursor[23] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[23] != 0 )
    {
        for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 1977 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1978 "SQLqry21-30.rc"


        free (out_desc_23.sqlvar); 
    }
    SQLcursor[23] = 0;
    SQLcursor_count[23] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));
    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id2,0,&out_desc_23,0,7);
}

#line 1989 "SQLqry21-30.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs23 (First time)" ));
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
                if( SQLcursor[23] && ( SQLcursor_count[23] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2017 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2018 "SQLqry21-30.rc"


          free (out_desc_23.sqlvar); 
          SQLcursor[23] = 0;
          SQLcursor_count[23] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2036 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2037 "SQLqry21-30.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_23.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[23] = 0;
          SQLcursor_count[23] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[23];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_23.sqld; ++i)
           {
             if (*out_desc_23.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_23.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_23.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_23.sqld; ++x)
                       free (out_desc_23.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_23.sqld; ++x)
                       free (out_desc_23.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2078 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2079 "SQLqry21-30.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_23.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[23] = 0;
	             SQLcursor_count[23] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_23.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_23.sqlvar[i].sqllen, 
                  out_desc_23.sqlvar[i].sqllen, out_desc_23.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_23.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_23.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_23.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_23.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_23.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_23.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_23.sqld; ++x)
                    free (out_desc_23.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_23.sqld; ++x)
                    free (out_desc_23.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2147 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2148 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_23.sqlvar);
 	          SQLcursor[23] = 0;
  	          SQLcursor_count[23] = 0;
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
                  for (x = 0; x < out_desc_23.sqld; ++x)
                    free (out_desc_23.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_23.sqld; ++x)
                    free (out_desc_23.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2171 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2172 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_23.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[23] = 0;
	          SQLcursor_count[23] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_23.sqld; ++x)
               free (out_desc_23.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_23.sqld; ++x)
               free (out_desc_23.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2194 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2195 "SQLqry21-30.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_23.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[23] = 0;
              SQLcursor_count[23] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id2,0,&out_desc_23,0,7);
}

#line 2208 "SQLqry21-30.rc"

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
                if( SQLcursor[23] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_23.sqld; ++x)
               free (out_desc_23.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_23.sqld; ++x)
               free (out_desc_23.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2236 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2237 "SQLqry21-30.rc"

             free (str);

             free (out_desc_23.sqlvar);
             SQLcursor[23] = 0;
             SQLcursor_count[23] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[23];
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

#line 2259 "SQLqry21-30.rc"

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

	  
          for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_23.sqld; ++x)
            free (out_desc_23.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2285 "SQLqry21-30.rc"

          free (str);

          free (out_desc_23.sqlvar);
          SQLcursor[23] = 0;
          SQLcursor_count[23] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_23.sqld; ++i)
        {
          free (out_desc_23.sqlvar [i].sqldata);
          free (out_desc_23.sqlvar [i].sqlind);
        }

       free (out_desc_23.sqlvar);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2304 "SQLqry21-30.rc"

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
          SQLcursor[23] = 0;
	  SQLcursor_count[23] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[23] = 0;
       SQLcursor_count[23] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor24 (sql_str24, list, size, rows)

#line 2337 "SQLqry21-30.rc"

char * sql_str24;

#line 2339 "SQLqry21-30.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor24" ;

#line 2348 "SQLqry21-30.rc"

long status;

#line 2349 "SQLqry21-30.rc"

long i;

#line 2350 "SQLqry21-30.rc"

long x;

#line 2351 "SQLqry21-30.rc"

long NEW_LIST;

#line 2352 "SQLqry21-30.rc"

long fetch_count;

#line 2353 "SQLqry21-30.rc"

char data_type[30];

#line 2354 "SQLqry21-30.rc"

char data[30];

#line 2355 "SQLqry21-30.rc"

char * str;

#line 2356 "SQLqry21-30.rc"

char * data1;

#line 2357 "SQLqry21-30.rc"

char * * format;

#line 2358 "SQLqry21-30.rc"

datetime * ptr;

#line 2359 "SQLqry21-30.rc"

char column_name[50];

#line 2361 "SQLqry21-30.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str24, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[24] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[24] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt24" ));
{RISint_prepare(&RIScpp_stmt_id3,sql_str24,1,0);
}

#line 2380 "SQLqry21-30.rc"

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

#line 2398 "SQLqry21-30.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_24.sqld = 0;
       out_desc_24.sqln = 0;
       out_desc_24.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id3,&out_desc_24,1);
}

#line 2413 "SQLqry21-30.rc"

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

#line 2431 "SQLqry21-30.rc"

           return (status);
        }
    } /* if( !SQLcursor[24] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2442 "SQLqry21-30.rc"

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

#line 2455 "SQLqry21-30.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[24] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_24" ));
        out_desc_24.sqlvar = (sqlvar *)calloc(out_desc_24.sqld, sizeof (sqlvar));
        if (! out_desc_24.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2473 "SQLqry21-30.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_24.sqln = out_desc_24.sqld;

{RISint_describe(RIScpp_stmt_id3,&out_desc_24,1);
}

#line 2482 "SQLqry21-30.rc"

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

#line 2501 "SQLqry21-30.rc"

        free (out_desc_24.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_24.sqld; ++i)
        {
          out_desc_24.sqlvar [i].sqldata =
                 calloc (1, out_desc_24.sqlvar [i].sqllen);
          if (! out_desc_24.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_24.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_24.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2515 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_24.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_24.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_24.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_24.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_24.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2530 "SQLqry21-30.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_24.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_24.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_24.sqld; ++x)
                free (out_desc_24.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_24.sqld; ++x)
                free (out_desc_24.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2552 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_24.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[24] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_24.sqld ));
       for (i = 0; i < out_desc_24.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_24.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_24.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_24.sqld; ++x)
                   free (out_desc_24.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_24.sqld; ++x)
                   free (out_desc_24.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2610 "SQLqry21-30.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_24.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_24.sqlvar [i].sqlname.sqlnamec,
		       out_desc_24.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_24.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_24.sqld; ++x)
                   free (out_desc_24.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_24.sqld; ++x)
                   free (out_desc_24.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2633 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_24.sqlvar);
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

                 for (x = 0; x < out_desc_24.sqld; ++x)
                   free (out_desc_24.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_24.sqld; ++x)
                   free (out_desc_24.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2653 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_24.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[24] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 2667 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2692 "SQLqry21-30.rc"

          free (out_desc_24.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id3,0,0,7,1,0);
}

#line 2697 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2723 "SQLqry21-30.rc"

          free (out_desc_24.sqlvar);
          return (status);
        }
    SQLcursor[24] = 1;

    } /* end if( !SQLcursor[24] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[24] != 0 )
    {
        for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2745 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2746 "SQLqry21-30.rc"


        free (out_desc_24.sqlvar); 
    }
    SQLcursor[24] = 0;
    SQLcursor_count[24] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id3,0,&out_desc_24,0,7);
}

#line 2758 "SQLqry21-30.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs24 (First time)" ));
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
                if( SQLcursor[24] && ( SQLcursor_count[24] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2786 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2787 "SQLqry21-30.rc"


          free (out_desc_24.sqlvar); 
          SQLcursor[24] = 0;
          SQLcursor_count[24] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2805 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2806 "SQLqry21-30.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_24.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[24] = 0;
          SQLcursor_count[24] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[24];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_24.sqld; ++i)
           {
             if (*out_desc_24.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_24.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_24.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_24.sqld; ++x)
                       free (out_desc_24.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_24.sqld; ++x)
                       free (out_desc_24.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2847 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2848 "SQLqry21-30.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_24.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[24] = 0;
	             SQLcursor_count[24] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_24.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_24.sqlvar[i].sqllen, 
                  out_desc_24.sqlvar[i].sqllen, out_desc_24.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_24.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_24.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_24.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_24.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_24.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_24.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_24.sqld; ++x)
                    free (out_desc_24.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_24.sqld; ++x)
                    free (out_desc_24.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2916 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2917 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_24.sqlvar);
 	          SQLcursor[24] = 0;
  	          SQLcursor_count[24] = 0;
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
                  for (x = 0; x < out_desc_24.sqld; ++x)
                    free (out_desc_24.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_24.sqld; ++x)
                    free (out_desc_24.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2940 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2941 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_24.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[24] = 0;
	          SQLcursor_count[24] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_24.sqld; ++x)
               free (out_desc_24.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_24.sqld; ++x)
               free (out_desc_24.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2963 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2964 "SQLqry21-30.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_24.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[24] = 0;
              SQLcursor_count[24] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id3,0,&out_desc_24,0,7);
}

#line 2977 "SQLqry21-30.rc"

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
                if( SQLcursor[24] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_24.sqld; ++x)
               free (out_desc_24.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_24.sqld; ++x)
               free (out_desc_24.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 3005 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3006 "SQLqry21-30.rc"

             free (str);

             free (out_desc_24.sqlvar);
             SQLcursor[24] = 0;
             SQLcursor_count[24] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[24];
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

#line 3028 "SQLqry21-30.rc"

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

	  
          for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_24.sqld; ++x)
            free (out_desc_24.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3054 "SQLqry21-30.rc"

          free (str);

          free (out_desc_24.sqlvar);
          SQLcursor[24] = 0;
          SQLcursor_count[24] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_24.sqld; ++i)
        {
          free (out_desc_24.sqlvar [i].sqldata);
          free (out_desc_24.sqlvar [i].sqlind);
        }

       free (out_desc_24.sqlvar);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3073 "SQLqry21-30.rc"

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
          SQLcursor[24] = 0;
	  SQLcursor_count[24] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[24] = 0;
       SQLcursor_count[24] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor25 (sql_str25, list, size, rows)

#line 3105 "SQLqry21-30.rc"

char * sql_str25;

#line 3107 "SQLqry21-30.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor25" ;

#line 3116 "SQLqry21-30.rc"

long status;

#line 3117 "SQLqry21-30.rc"

long i;

#line 3118 "SQLqry21-30.rc"

long x;

#line 3119 "SQLqry21-30.rc"

long NEW_LIST;

#line 3120 "SQLqry21-30.rc"

long fetch_count;

#line 3121 "SQLqry21-30.rc"

char data_type[30];

#line 3122 "SQLqry21-30.rc"

char data[30];

#line 3123 "SQLqry21-30.rc"

char * str;

#line 3124 "SQLqry21-30.rc"

char * data1;

#line 3125 "SQLqry21-30.rc"

char * * format;

#line 3126 "SQLqry21-30.rc"

datetime * ptr;

#line 3127 "SQLqry21-30.rc"

char column_name[50];

#line 3129 "SQLqry21-30.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str25, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[25] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[25] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt25" ));
{RISint_prepare(&RIScpp_stmt_id4,sql_str25,1,0);
}

#line 3148 "SQLqry21-30.rc"

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

#line 3166 "SQLqry21-30.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_25.sqld = 0;
       out_desc_25.sqln = 0;
       out_desc_25.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id4,&out_desc_25,1);
}

#line 3181 "SQLqry21-30.rc"

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

#line 3199 "SQLqry21-30.rc"

           return (status);
        }
    } /* if( !SQLcursor[25] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3210 "SQLqry21-30.rc"

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

#line 3223 "SQLqry21-30.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[25] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_25" ));
        out_desc_25.sqlvar = (sqlvar *)calloc(out_desc_25.sqld, sizeof (sqlvar));
        if (! out_desc_25.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3241 "SQLqry21-30.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_25.sqln = out_desc_25.sqld;

{RISint_describe(RIScpp_stmt_id4,&out_desc_25,1);
}

#line 3250 "SQLqry21-30.rc"

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

#line 3269 "SQLqry21-30.rc"

        free (out_desc_25.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_25.sqld; ++i)
        {
          out_desc_25.sqlvar [i].sqldata =
                 calloc (1, out_desc_25.sqlvar [i].sqllen);
          if (! out_desc_25.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_25.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_25.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3283 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_25.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_25.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_25.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_25.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_25.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3298 "SQLqry21-30.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_25.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_25.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_25.sqld; ++x)
                free (out_desc_25.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_25.sqld; ++x)
                free (out_desc_25.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3320 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_25.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[25] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_25.sqld ));
       for (i = 0; i < out_desc_25.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_25.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_25.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_25.sqld; ++x)
                   free (out_desc_25.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_25.sqld; ++x)
                   free (out_desc_25.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3378 "SQLqry21-30.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_25.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_25.sqlvar [i].sqlname.sqlnamec,
		       out_desc_25.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_25.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_25.sqld; ++x)
                   free (out_desc_25.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_25.sqld; ++x)
                   free (out_desc_25.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3401 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_25.sqlvar);
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

                 for (x = 0; x < out_desc_25.sqld; ++x)
                   free (out_desc_25.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_25.sqld; ++x)
                   free (out_desc_25.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3421 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_25.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[25] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 3435 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3460 "SQLqry21-30.rc"

          free (out_desc_25.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id4,0,0,7,1,0);
}

#line 3465 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3491 "SQLqry21-30.rc"

          free (out_desc_25.sqlvar);
          return (status);
        }
    SQLcursor[25] = 1;

    } /* end if( !SQLcursor[25] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[25] != 0 )
    {
        for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3513 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3514 "SQLqry21-30.rc"


        free (out_desc_25.sqlvar); 
    }
    SQLcursor[25] = 0;
    SQLcursor_count[25] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id4,0,&out_desc_25,0,7);
}

#line 3526 "SQLqry21-30.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs25 (First time)" ));
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
                if( SQLcursor[25] && ( SQLcursor_count[25] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3554 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3555 "SQLqry21-30.rc"


          free (out_desc_25.sqlvar); 
          SQLcursor[25] = 0;
          SQLcursor_count[25] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3573 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3574 "SQLqry21-30.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_25.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[25] = 0;
          SQLcursor_count[25] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[25];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_25.sqld; ++i)
           {
             if (*out_desc_25.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_25.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_25.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_25.sqld; ++x)
                       free (out_desc_25.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_25.sqld; ++x)
                       free (out_desc_25.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3615 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3616 "SQLqry21-30.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_25.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[25] = 0;
	             SQLcursor_count[25] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_25.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_25.sqlvar[i].sqllen, 
                  out_desc_25.sqlvar[i].sqllen, out_desc_25.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_25.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_25.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_25.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_25.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_25.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_25.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_25.sqld; ++x)
                    free (out_desc_25.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_25.sqld; ++x)
                    free (out_desc_25.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3684 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3685 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_25.sqlvar);
 	          SQLcursor[25] = 0;
  	          SQLcursor_count[25] = 0;
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
                  for (x = 0; x < out_desc_25.sqld; ++x)
                    free (out_desc_25.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_25.sqld; ++x)
                    free (out_desc_25.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3708 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3709 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_25.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[25] = 0;
	          SQLcursor_count[25] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_25.sqld; ++x)
               free (out_desc_25.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_25.sqld; ++x)
               free (out_desc_25.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3731 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3732 "SQLqry21-30.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_25.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[25] = 0;
              SQLcursor_count[25] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id4,0,&out_desc_25,0,7);
}

#line 3745 "SQLqry21-30.rc"

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
                if( SQLcursor[25] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_25.sqld; ++x)
               free (out_desc_25.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_25.sqld; ++x)
               free (out_desc_25.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3773 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3774 "SQLqry21-30.rc"

             free (str);

             free (out_desc_25.sqlvar);
             SQLcursor[25] = 0;
             SQLcursor_count[25] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[25];
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

#line 3796 "SQLqry21-30.rc"

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

	  
          for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_25.sqld; ++x)
            free (out_desc_25.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3822 "SQLqry21-30.rc"

          free (str);

          free (out_desc_25.sqlvar);
          SQLcursor[25] = 0;
          SQLcursor_count[25] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_25.sqld; ++i)
        {
          free (out_desc_25.sqlvar [i].sqldata);
          free (out_desc_25.sqlvar [i].sqlind);
        }

       free (out_desc_25.sqlvar);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3841 "SQLqry21-30.rc"

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
          SQLcursor[25] = 0;
	  SQLcursor_count[25] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[25] = 0;
       SQLcursor_count[25] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor26 (sql_str26, list, size, rows)

#line 3873 "SQLqry21-30.rc"

char * sql_str26;

#line 3875 "SQLqry21-30.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor26" ;

#line 3884 "SQLqry21-30.rc"

long status;

#line 3885 "SQLqry21-30.rc"

long i;

#line 3886 "SQLqry21-30.rc"

long x;

#line 3887 "SQLqry21-30.rc"

long NEW_LIST;

#line 3888 "SQLqry21-30.rc"

long fetch_count;

#line 3889 "SQLqry21-30.rc"

char data_type[30];

#line 3890 "SQLqry21-30.rc"

char data[30];

#line 3891 "SQLqry21-30.rc"

char * str;

#line 3892 "SQLqry21-30.rc"

char * data1;

#line 3893 "SQLqry21-30.rc"

char * * format;

#line 3894 "SQLqry21-30.rc"

datetime * ptr;

#line 3895 "SQLqry21-30.rc"

char column_name[50];

#line 3897 "SQLqry21-30.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str26, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[26] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[26] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt26" ));
{RISint_prepare(&RIScpp_stmt_id5,sql_str26,1,0);
}

#line 3916 "SQLqry21-30.rc"

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

#line 3934 "SQLqry21-30.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_26.sqld = 0;
       out_desc_26.sqln = 0;
       out_desc_26.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id5,&out_desc_26,1);
}

#line 3949 "SQLqry21-30.rc"

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

#line 3967 "SQLqry21-30.rc"

           return (status);
        }
    } /* if( !SQLcursor[26] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 3978 "SQLqry21-30.rc"

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

#line 3991 "SQLqry21-30.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[26] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_26" ));
        out_desc_26.sqlvar = (sqlvar *)calloc(out_desc_26.sqld, sizeof (sqlvar));
        if (! out_desc_26.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4009 "SQLqry21-30.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_26.sqln = out_desc_26.sqld;

{RISint_describe(RIScpp_stmt_id5,&out_desc_26,1);
}

#line 4018 "SQLqry21-30.rc"

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

#line 4037 "SQLqry21-30.rc"

        free (out_desc_26.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_26.sqld; ++i)
        {
          out_desc_26.sqlvar [i].sqldata =
                 calloc (1, out_desc_26.sqlvar [i].sqllen);
          if (! out_desc_26.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_26.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_26.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4051 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_26.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_26.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_26.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_26.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_26.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4066 "SQLqry21-30.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_26.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_26.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_26.sqld; ++x)
                free (out_desc_26.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_26.sqld; ++x)
                free (out_desc_26.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4088 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_26.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[26] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_26.sqld ));
       for (i = 0; i < out_desc_26.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_26.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_26.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_26.sqld; ++x)
                   free (out_desc_26.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_26.sqld; ++x)
                   free (out_desc_26.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4146 "SQLqry21-30.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_26.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_26.sqlvar [i].sqlname.sqlnamec,
		       out_desc_26.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_26.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_26.sqld; ++x)
                   free (out_desc_26.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_26.sqld; ++x)
                   free (out_desc_26.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4169 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_26.sqlvar);
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

                 for (x = 0; x < out_desc_26.sqld; ++x)
                   free (out_desc_26.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_26.sqld; ++x)
                   free (out_desc_26.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4189 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_26.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[26] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 4203 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4228 "SQLqry21-30.rc"

          free (out_desc_26.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id5,0,0,7,1,0);
}

#line 4233 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4259 "SQLqry21-30.rc"

          free (out_desc_26.sqlvar);
          return (status);
        }
    SQLcursor[26] = 1;

    } /* end if( !SQLcursor[26] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[26] != 0 )
    {
        for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4281 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4282 "SQLqry21-30.rc"


        free (out_desc_26.sqlvar); 
    }
    SQLcursor[26] = 0;
    SQLcursor_count[26] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id5,0,&out_desc_26,0,7);
}

#line 4294 "SQLqry21-30.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs26 (First time)" ));
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
                if( SQLcursor[26] && ( SQLcursor_count[26] > 0 ) )
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4322 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4323 "SQLqry21-30.rc"


          free (out_desc_26.sqlvar); 
          SQLcursor[26] = 0;
          SQLcursor_count[26] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4341 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4342 "SQLqry21-30.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_26.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[26] = 0;
          SQLcursor_count[26] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[26];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_26.sqld; ++i)
           {
             if (*out_desc_26.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_26.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_26.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_26.sqld; ++x)
                       free (out_desc_26.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_26.sqld; ++x)
                       free (out_desc_26.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4383 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4384 "SQLqry21-30.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_26.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[26] = 0;
	             SQLcursor_count[26] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_26.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_26.sqlvar[i].sqllen, 
                  out_desc_26.sqlvar[i].sqllen, out_desc_26.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_26.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_26.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_26.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_26.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_26.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_26.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_26.sqld; ++x)
                    free (out_desc_26.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_26.sqld; ++x)
                    free (out_desc_26.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4452 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4453 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_26.sqlvar);
 	          SQLcursor[26] = 0;
  	          SQLcursor_count[26] = 0;
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
                  for (x = 0; x < out_desc_26.sqld; ++x)
                    free (out_desc_26.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_26.sqld; ++x)
                    free (out_desc_26.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4476 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4477 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_26.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[26] = 0;
	          SQLcursor_count[26] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_26.sqld; ++x)
               free (out_desc_26.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_26.sqld; ++x)
               free (out_desc_26.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4499 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4500 "SQLqry21-30.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_26.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[26] = 0;
              SQLcursor_count[26] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id5,0,&out_desc_26,0,7);
}

#line 4513 "SQLqry21-30.rc"

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
                if( SQLcursor[26] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_26.sqld; ++x)
               free (out_desc_26.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_26.sqld; ++x)
               free (out_desc_26.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4541 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4542 "SQLqry21-30.rc"

             free (str);

             free (out_desc_26.sqlvar);
             SQLcursor[26] = 0;
             SQLcursor_count[26] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[26];
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

#line 4564 "SQLqry21-30.rc"

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

	  
          for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_26.sqld; ++x)
            free (out_desc_26.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4590 "SQLqry21-30.rc"

          free (str);

          free (out_desc_26.sqlvar);
          SQLcursor[26] = 0;
          SQLcursor_count[26] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_26.sqld; ++i)
        {
          free (out_desc_26.sqlvar [i].sqldata);
          free (out_desc_26.sqlvar [i].sqlind);
        }

       free (out_desc_26.sqlvar);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4609 "SQLqry21-30.rc"

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
          SQLcursor[26] = 0;
	  SQLcursor_count[26] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[26] = 0;
       SQLcursor_count[26] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor27 (sql_str27, list, size, rows)

#line 4642 "SQLqry21-30.rc"

char * sql_str27;

#line 4644 "SQLqry21-30.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor27" ;

#line 4653 "SQLqry21-30.rc"

long status;

#line 4654 "SQLqry21-30.rc"

long i;

#line 4655 "SQLqry21-30.rc"

long x;

#line 4656 "SQLqry21-30.rc"

long NEW_LIST;

#line 4657 "SQLqry21-30.rc"

long fetch_count;

#line 4658 "SQLqry21-30.rc"

char data_type[30];

#line 4659 "SQLqry21-30.rc"

char data[30];

#line 4660 "SQLqry21-30.rc"

char * str;

#line 4661 "SQLqry21-30.rc"

char * data1;

#line 4662 "SQLqry21-30.rc"

char * * format;

#line 4663 "SQLqry21-30.rc"

datetime * ptr;

#line 4664 "SQLqry21-30.rc"

char column_name[50];

#line 4666 "SQLqry21-30.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str27, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[27] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[27] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt27" ));
{RISint_prepare(&RIScpp_stmt_id6,sql_str27,1,0);
}

#line 4685 "SQLqry21-30.rc"

        if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
           {
              status = SQLerror (SQL_E_PREPARE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname, "Prepare Failed : status = <0x%.27x>\n",
	              status));
           }
           else                       
           {
	      status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname, "No Rows Found : status = <0x%.27x>\n",
 	             status));
	      ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4703 "SQLqry21-30.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_27.sqld = 0;
       out_desc_27.sqln = 0;
       out_desc_27.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id6,&out_desc_27,1);
}

#line 4718 "SQLqry21-30.rc"

       if (SQLCODE)
       {
           if (SQLCODE != END_OF_DATA)
           { 
               status = SQLerror (SQL_E_DESCRIBE, 
                      risca -> sqlerrd [1], SQLCODE); 
               _SQLdebug ((fname, "Describe Failed : status = <0x%.27x>\n",
	              status));
           }
           else                       
           {
	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.27x>\n",
	             status));
	       ERRload_struct (SQL, status, NULL) ;
           }

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4736 "SQLqry21-30.rc"

           return (status);
        }
    } /* if( !SQLcursor[27] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4747 "SQLqry21-30.rc"

            _SQLdebug ((fname, "MEM Open Failed : status = <0x%.27x>\n",
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

#line 4760 "SQLqry21-30.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.27x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[27] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_27" ));
        out_desc_27.sqlvar = (sqlvar *)calloc(out_desc_27.sqld, sizeof (sqlvar));
        if (! out_desc_27.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4778 "SQLqry21-30.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.27x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_27.sqln = out_desc_27.sqld;

{RISint_describe(RIScpp_stmt_id6,&out_desc_27,1);
}

#line 4787 "SQLqry21-30.rc"

        if (SQLCODE)
        {
            if (SQLCODE != END_OF_DATA)
            {
               if (NEW_LIST) MEMclose (list);
               status = SQLerror (SQL_E_DESCRIBE,
                      risca -> sqlerrd [1], SQLCODE);
               _SQLdebug ((fname, "Describe Failed : status = <0x%.27x>\n",
            	  status));
            }
            else
            {
  	       status = SQL_I_NO_ROWS_FOUND ;
               _SQLdebug ((fname, "No Rows Found : status = <0x%.27x>\n",
	             status));
  	       ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4806 "SQLqry21-30.rc"

        free (out_desc_27.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_27.sqld; ++i)
        {
          out_desc_27.sqlvar [i].sqldata =
                 calloc (1, out_desc_27.sqlvar [i].sqllen);
          if (! out_desc_27.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_27.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_27.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4820 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_27.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.27x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_27.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_27.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_27.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_27.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4835 "SQLqry21-30.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_27.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.27x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_27.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_27.sqld; ++x)
                free (out_desc_27.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_27.sqld; ++x)
                free (out_desc_27.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4857 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_27.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.27x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[27] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_27.sqld ));
       for (i = 0; i < out_desc_27.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_27.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_27.sqlvar[i].sqllen);
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
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.27x>\n",
				status ));	
	        status = SQL_E_DATA_TYPE ;
                for (x = 0; x < out_desc_27.sqld; ++x)
                   free (out_desc_27.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_27.sqld; ++x)
                   free (out_desc_27.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4915 "SQLqry21-30.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_27.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.27x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_27.sqlvar [i].sqlname.sqlnamec,
		       out_desc_27.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_27.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_27.sqld; ++x)
                   free (out_desc_27.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_27.sqld; ++x)
                   free (out_desc_27.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4938 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_27.sqlvar);
                 _SQLdebug ((fname, "Wr For Failed : status = <0x%.27x>\n",
                 status));
                 return (SQL_E_MEM);
               }
            }
           else
            {
              if (strcmp (format [i], data_type))
               {
		 status = SQL_E_FORMAT_MISMATCH ;

                 for (x = 0; x < out_desc_27.sqld; ++x)
                   free (out_desc_27.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_27.sqld; ++x)
                   free (out_desc_27.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4958 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_27.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.27x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[27] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 4972 "SQLqry21-30.rc"

       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             if (NEW_LIST) MEMclose (list);
             status = SQLerror (SQL_E_DECLARE,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Declare Failed : status = <0x%.27x>\n",
             status));
           }
          else
           {
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.27x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4997 "SQLqry21-30.rc"

          free (out_desc_27.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id6,0,0,7,1,0);
}

#line 5002 "SQLqry21-30.rc"

        _SQLdebug(( fname, "%s\n", "Open cursor" ));
       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             if (NEW_LIST) MEMclose (list);
             status = SQLerror (SQL_E_CURSOR,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Open Cursors Failed : status = <0x%.27x>\n",
             status));
           }
          else
           {
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.27x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5028 "SQLqry21-30.rc"

          free (out_desc_27.sqlvar);
          return (status);
        }
    SQLcursor[27] = 1;

    } /* end if( !SQLcursor[27] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[27] != 0 )
    {
        for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5050 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5051 "SQLqry21-30.rc"


        free (out_desc_27.sqlvar); 
    }
    SQLcursor[27] = 0;
    SQLcursor_count[27] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id6,0,&out_desc_27,0,7);
}

#line 5063 "SQLqry21-30.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs27 (First time)" ));
       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             if (NEW_LIST) MEMclose (list);
             status = SQLerror (SQL_E_FETCH,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Fetch Cursors Failed : status = <0x%.27x>\n",
             status));
           }
          else
           {
	     status = SQL_I_NO_ROWS_FOUND ;
                if( SQLcursor[27] && ( SQLcursor_count[27] > 0 ) )
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.27x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5091 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5092 "SQLqry21-30.rc"


          free (out_desc_27.sqlvar); 
          SQLcursor[27] = 0;
          SQLcursor_count[27] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5110 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5111 "SQLqry21-30.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_27.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.27x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[27] = 0;
          SQLcursor_count[27] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[27];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_27.sqld; ++i)
           {
             if (*out_desc_27.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_27.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_27.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_27.sqld; ++x)
                       free (out_desc_27.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_27.sqld; ++x)
                       free (out_desc_27.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5152 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5153 "SQLqry21-30.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_27.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.27x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[27] = 0;
	             SQLcursor_count[27] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_27.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_27.sqlvar[i].sqllen, 
                  out_desc_27.sqlvar[i].sqllen, out_desc_27.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_27.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_27.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_27.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_27.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_27.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_27.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_27.sqld; ++x)
                    free (out_desc_27.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_27.sqld; ++x)
                    free (out_desc_27.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5221 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5222 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_27.sqlvar);
 	          SQLcursor[27] = 0;
  	          SQLcursor_count[27] = 0;
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
                  for (x = 0; x < out_desc_27.sqld; ++x)
                    free (out_desc_27.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_27.sqld; ++x)
                    free (out_desc_27.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5245 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5246 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_27.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.27x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[27] = 0;
	          SQLcursor_count[27] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_27.sqld; ++x)
               free (out_desc_27.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_27.sqld; ++x)
               free (out_desc_27.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5268 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5269 "SQLqry21-30.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_27.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.27x>\n",
    	          status));
              SQLcursor[27] = 0;
              SQLcursor_count[27] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id6,0,&out_desc_27,0,7);
}

#line 5282 "SQLqry21-30.rc"

          _SQLdebug(( fname, "%s\n", "Fetch in loop" ));
          if (SQLCODE && (SQLCODE != END_OF_DATA))
           {
             if (SQLCODE != END_OF_DATA)
              {
                if (NEW_LIST) MEMclose (list);
                status = SQLerror (SQL_E_FETCH,
                         risca -> sqlerrd [1], SQLCODE);
                _SQLdebug ((fname, "Fetch Cursors : status = <0x%.27x>\n",
                status));
              }
             else
              {
                status = SQL_I_NO_ROWS_FOUND;
                if( SQLcursor[27] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.27x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_27.sqld; ++x)
               free (out_desc_27.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_27.sqld; ++x)
               free (out_desc_27.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5310 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5311 "SQLqry21-30.rc"

             free (str);

             free (out_desc_27.sqlvar);
             SQLcursor[27] = 0;
             SQLcursor_count[27] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[27];
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

#line 5333 "SQLqry21-30.rc"

       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             if (NEW_LIST) MEMclose (list);
             status = SQLerror (SQL_E_CLOSE,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Close Cursors : status = <0x%.27x>\n",
             status));
           }
          else
           {
	     status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.27x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

	  
          for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_27.sqld; ++x)
            free (out_desc_27.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5359 "SQLqry21-30.rc"

          free (str);

          free (out_desc_27.sqlvar);
          SQLcursor[27] = 0;
          SQLcursor_count[27] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_27.sqld; ++i)
        {
          free (out_desc_27.sqlvar [i].sqldata);
          free (out_desc_27.sqlvar [i].sqlind);
        }

       free (out_desc_27.sqlvar);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5378 "SQLqry21-30.rc"

       if (SQLCODE)
        {
          if (SQLCODE != END_OF_DATA)
           {
             if (NEW_LIST) MEMclose (list);
             status = SQLerror (SQL_E_CLEAR,
                      risca -> sqlerrd [1], SQLCODE);
             _SQLdebug ((fname, "Clear Statement : status = <0x%.27x>\n",
             status));
           }
          else
           {
             status = SQL_I_NO_ROWS_FOUND ;
             _SQLdebug ((fname, "No Rows Found : status = <0x%.27x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }
          SQLcursor[27] = 0;
	  SQLcursor_count[27] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[27] = 0;
       SQLcursor_count[27] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor28 (sql_str28, list, size, rows)

#line 5410 "SQLqry21-30.rc"

char * sql_str28;

#line 5412 "SQLqry21-30.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor28" ;

#line 5421 "SQLqry21-30.rc"

long status;

#line 5422 "SQLqry21-30.rc"

long i;

#line 5423 "SQLqry21-30.rc"

long x;

#line 5424 "SQLqry21-30.rc"

long NEW_LIST;

#line 5425 "SQLqry21-30.rc"

long fetch_count;

#line 5426 "SQLqry21-30.rc"

char data_type[30];

#line 5427 "SQLqry21-30.rc"

char data[30];

#line 5428 "SQLqry21-30.rc"

char * str;

#line 5429 "SQLqry21-30.rc"

char * data1;

#line 5430 "SQLqry21-30.rc"

char * * format;

#line 5431 "SQLqry21-30.rc"

datetime * ptr;

#line 5432 "SQLqry21-30.rc"

char column_name[50];

#line 5434 "SQLqry21-30.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str28, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[28] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[28] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt28" ));
{RISint_prepare(&RIScpp_stmt_id7,sql_str28,1,0);
}

#line 5453 "SQLqry21-30.rc"

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

#line 5471 "SQLqry21-30.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_28.sqld = 0;
       out_desc_28.sqln = 0;
       out_desc_28.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id7,&out_desc_28,1);
}

#line 5486 "SQLqry21-30.rc"

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

#line 5504 "SQLqry21-30.rc"

           return (status);
        }
    } /* if( !SQLcursor[28] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5515 "SQLqry21-30.rc"

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

#line 5528 "SQLqry21-30.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[28] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_28" ));
        out_desc_28.sqlvar = (sqlvar *)calloc(out_desc_28.sqld, sizeof (sqlvar));
        if (! out_desc_28.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5546 "SQLqry21-30.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_28.sqln = out_desc_28.sqld;

{RISint_describe(RIScpp_stmt_id7,&out_desc_28,1);
}

#line 5555 "SQLqry21-30.rc"

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

#line 5574 "SQLqry21-30.rc"

        free (out_desc_28.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_28.sqld; ++i)
        {
          out_desc_28.sqlvar [i].sqldata =
                 calloc (1, out_desc_28.sqlvar [i].sqllen);
          if (! out_desc_28.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_28.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_28.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5588 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_28.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_28.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_28.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_28.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_28.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5603 "SQLqry21-30.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_28.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_28.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_28.sqld; ++x)
                free (out_desc_28.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_28.sqld; ++x)
                free (out_desc_28.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5625 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_28.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[28] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_28.sqld ));
       for (i = 0; i < out_desc_28.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_28.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_28.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_28.sqld; ++x)
                   free (out_desc_28.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_28.sqld; ++x)
                   free (out_desc_28.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5683 "SQLqry21-30.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_28.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_28.sqlvar [i].sqlname.sqlnamec,
		       out_desc_28.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_28.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_28.sqld; ++x)
                   free (out_desc_28.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_28.sqld; ++x)
                   free (out_desc_28.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5706 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_28.sqlvar);
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

                 for (x = 0; x < out_desc_28.sqld; ++x)
                   free (out_desc_28.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_28.sqld; ++x)
                   free (out_desc_28.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5726 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_28.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[28] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 5740 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5765 "SQLqry21-30.rc"

          free (out_desc_28.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id7,0,0,7,1,0);
}

#line 5770 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5796 "SQLqry21-30.rc"

          free (out_desc_28.sqlvar);
          return (status);
        }
    SQLcursor[28] = 1;

    } /* end if( !SQLcursor[28] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[28] != 0 )
    {
        for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5818 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5819 "SQLqry21-30.rc"


        free (out_desc_28.sqlvar); 
    }
    SQLcursor[28] = 0;
    SQLcursor_count[28] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));
    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id7,0,&out_desc_28,0,7);
}

#line 5830 "SQLqry21-30.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs28 (First time)" ));
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
                if( SQLcursor[28] && ( SQLcursor_count[28] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5858 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5859 "SQLqry21-30.rc"


          free (out_desc_28.sqlvar); 
          SQLcursor[28] = 0;
          SQLcursor_count[28] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5877 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5878 "SQLqry21-30.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_28.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[28] = 0;
          SQLcursor_count[28] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[28];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_28.sqld; ++i)
           {
             if (*out_desc_28.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_28.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_28.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_28.sqld; ++x)
                       free (out_desc_28.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_28.sqld; ++x)
                       free (out_desc_28.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5919 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5920 "SQLqry21-30.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_28.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[28] = 0;
	             SQLcursor_count[28] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_28.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_28.sqlvar[i].sqllen, 
                  out_desc_28.sqlvar[i].sqllen, out_desc_28.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_28.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_28.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_28.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_28.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_28.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_28.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_28.sqld; ++x)
                    free (out_desc_28.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_28.sqld; ++x)
                    free (out_desc_28.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5988 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5989 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_28.sqlvar);
 	          SQLcursor[28] = 0;
  	          SQLcursor_count[28] = 0;
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
                  for (x = 0; x < out_desc_28.sqld; ++x)
                    free (out_desc_28.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_28.sqld; ++x)
                    free (out_desc_28.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6012 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6013 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_28.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[28] = 0;
	          SQLcursor_count[28] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_28.sqld; ++x)
               free (out_desc_28.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_28.sqld; ++x)
               free (out_desc_28.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6035 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6036 "SQLqry21-30.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_28.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[28] = 0;
              SQLcursor_count[28] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id7,0,&out_desc_28,0,7);
}

#line 6049 "SQLqry21-30.rc"

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
                if( SQLcursor[28] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_28.sqld; ++x)
               free (out_desc_28.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_28.sqld; ++x)
               free (out_desc_28.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6077 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6078 "SQLqry21-30.rc"

             free (str);

             free (out_desc_28.sqlvar);
             SQLcursor[28] = 0;
             SQLcursor_count[28] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[28];
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

#line 6100 "SQLqry21-30.rc"

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

	  
          for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_28.sqld; ++x)
            free (out_desc_28.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6126 "SQLqry21-30.rc"

          free (str);

          free (out_desc_28.sqlvar);
          SQLcursor[28] = 0;
          SQLcursor_count[28] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_28.sqld; ++i)
        {
          free (out_desc_28.sqlvar [i].sqldata);
          free (out_desc_28.sqlvar [i].sqlind);
        }

       free (out_desc_28.sqlvar);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6145 "SQLqry21-30.rc"

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
          SQLcursor[28] = 0;
	  SQLcursor_count[28] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[28] = 0;
       SQLcursor_count[28] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor29 (sql_str29, list, size, rows)

#line 6177 "SQLqry21-30.rc"

char * sql_str29;

#line 6179 "SQLqry21-30.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor29" ;

#line 6188 "SQLqry21-30.rc"

long status;

#line 6189 "SQLqry21-30.rc"

long i;

#line 6190 "SQLqry21-30.rc"

long x;

#line 6191 "SQLqry21-30.rc"

long NEW_LIST;

#line 6192 "SQLqry21-30.rc"

long fetch_count;

#line 6193 "SQLqry21-30.rc"

char data_type[30];

#line 6194 "SQLqry21-30.rc"

char data[30];

#line 6195 "SQLqry21-30.rc"

char * str;

#line 6196 "SQLqry21-30.rc"

char * data1;

#line 6197 "SQLqry21-30.rc"

char * * format;

#line 6198 "SQLqry21-30.rc"

datetime * ptr;

#line 6199 "SQLqry21-30.rc"

char column_name[50];

#line 6201 "SQLqry21-30.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str29, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[29] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[29] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt29" ));
{RISint_prepare(&RIScpp_stmt_id8,sql_str29,1,0);
}

#line 6220 "SQLqry21-30.rc"

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

#line 6238 "SQLqry21-30.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_29.sqld = 0;
       out_desc_29.sqln = 0;
       out_desc_29.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id8,&out_desc_29,1);
}

#line 6253 "SQLqry21-30.rc"

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

#line 6271 "SQLqry21-30.rc"

           return (status);
        }
    } /* if( !SQLcursor[29] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6282 "SQLqry21-30.rc"

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

#line 6295 "SQLqry21-30.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[29] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_29" ));
        out_desc_29.sqlvar = (sqlvar *)calloc(out_desc_29.sqld, sizeof (sqlvar));
        if (! out_desc_29.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6313 "SQLqry21-30.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_29.sqln = out_desc_29.sqld;

{RISint_describe(RIScpp_stmt_id8,&out_desc_29,1);
}

#line 6322 "SQLqry21-30.rc"

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

#line 6341 "SQLqry21-30.rc"

        free (out_desc_29.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_29.sqld; ++i)
        {
          out_desc_29.sqlvar [i].sqldata =
                 calloc (1, out_desc_29.sqlvar [i].sqllen);
          if (! out_desc_29.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_29.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_29.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6355 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_29.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_29.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_29.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_29.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_29.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6370 "SQLqry21-30.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_29.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_29.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_29.sqld; ++x)
                free (out_desc_29.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_29.sqld; ++x)
                free (out_desc_29.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6392 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_29.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[29] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_29.sqld ));
       for (i = 0; i < out_desc_29.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_29.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_29.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_29.sqld; ++x)
                   free (out_desc_29.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_29.sqld; ++x)
                   free (out_desc_29.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6450 "SQLqry21-30.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_29.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_29.sqlvar [i].sqlname.sqlnamec,
		       out_desc_29.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_29.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_29.sqld; ++x)
                   free (out_desc_29.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_29.sqld; ++x)
                   free (out_desc_29.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6473 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_29.sqlvar);
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

                 for (x = 0; x < out_desc_29.sqld; ++x)
                   free (out_desc_29.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_29.sqld; ++x)
                   free (out_desc_29.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6493 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_29.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[29] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 6507 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6532 "SQLqry21-30.rc"

          free (out_desc_29.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id8,0,0,7,1,0);
}

#line 6537 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6563 "SQLqry21-30.rc"

          free (out_desc_29.sqlvar);
          return (status);
        }
    SQLcursor[29] = 1;

    } /* end if( !SQLcursor[29] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[29] != 0 )
    {
        for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6585 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6586 "SQLqry21-30.rc"


        free (out_desc_29.sqlvar); 
    }
    SQLcursor[29] = 0;
    SQLcursor_count[29] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id8,0,&out_desc_29,0,7);
}

#line 6598 "SQLqry21-30.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs29 (First time)" ));
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
                if( SQLcursor[29] && ( SQLcursor_count[29] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6626 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6627 "SQLqry21-30.rc"


          free (out_desc_29.sqlvar); 
          SQLcursor[29] = 0;
          SQLcursor_count[29] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6645 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6646 "SQLqry21-30.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_29.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[29] = 0;
          SQLcursor_count[29] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[29];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_29.sqld; ++i)
           {
             if (*out_desc_29.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_29.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_29.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_29.sqld; ++x)
                       free (out_desc_29.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_29.sqld; ++x)
                       free (out_desc_29.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6687 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6688 "SQLqry21-30.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_29.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[29] = 0;
	             SQLcursor_count[29] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_29.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_29.sqlvar[i].sqllen, 
                  out_desc_29.sqlvar[i].sqllen, out_desc_29.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_29.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_29.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_29.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_29.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_29.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_29.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_29.sqld; ++x)
                    free (out_desc_29.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_29.sqld; ++x)
                    free (out_desc_29.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6756 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6757 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_29.sqlvar);
 	          SQLcursor[29] = 0;
  	          SQLcursor_count[29] = 0;
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
                  for (x = 0; x < out_desc_29.sqld; ++x)
                    free (out_desc_29.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_29.sqld; ++x)
                    free (out_desc_29.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6780 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6781 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_29.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[29] = 0;
	          SQLcursor_count[29] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_29.sqld; ++x)
               free (out_desc_29.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_29.sqld; ++x)
               free (out_desc_29.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6803 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6804 "SQLqry21-30.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_29.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[29] = 0;
              SQLcursor_count[29] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id8,0,&out_desc_29,0,7);
}

#line 6817 "SQLqry21-30.rc"

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
                if( SQLcursor[29] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_29.sqld; ++x)
               free (out_desc_29.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_29.sqld; ++x)
               free (out_desc_29.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6845 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6846 "SQLqry21-30.rc"

             free (str);

             free (out_desc_29.sqlvar);
             SQLcursor[29] = 0;
             SQLcursor_count[29] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[29];
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

#line 6868 "SQLqry21-30.rc"

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

	  
          for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_29.sqld; ++x)
            free (out_desc_29.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6894 "SQLqry21-30.rc"

          free (str);

          free (out_desc_29.sqlvar);
          SQLcursor[29] = 0;
          SQLcursor_count[29] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_29.sqld; ++i)
        {
          free (out_desc_29.sqlvar [i].sqldata);
          free (out_desc_29.sqlvar [i].sqlind);
        }

       free (out_desc_29.sqlvar);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6913 "SQLqry21-30.rc"

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
          SQLcursor[29] = 0;
	  SQLcursor_count[29] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[29] = 0;
       SQLcursor_count[29] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor30 (sql_str30, list, size, rows)

#line 6945 "SQLqry21-30.rc"

char * sql_str30;

#line 6947 "SQLqry21-30.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor30" ;

#line 6956 "SQLqry21-30.rc"

long status;

#line 6957 "SQLqry21-30.rc"

long i;

#line 6958 "SQLqry21-30.rc"

long x;

#line 6959 "SQLqry21-30.rc"

long NEW_LIST;

#line 6960 "SQLqry21-30.rc"

long fetch_count;

#line 6961 "SQLqry21-30.rc"

char data_type[30];

#line 6962 "SQLqry21-30.rc"

char data[30];

#line 6963 "SQLqry21-30.rc"

char * str;

#line 6964 "SQLqry21-30.rc"

char * data1;

#line 6965 "SQLqry21-30.rc"

char * * format;

#line 6966 "SQLqry21-30.rc"

datetime * ptr;

#line 6967 "SQLqry21-30.rc"

char column_name[50];

#line 6969 "SQLqry21-30.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str30, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[30] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[30] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt30" ));
{RISint_prepare(&RIScpp_stmt_id9,sql_str30,1,0);
}

#line 6988 "SQLqry21-30.rc"

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

#line 7006 "SQLqry21-30.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_30.sqld = 0;
       out_desc_30.sqln = 0;
       out_desc_30.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id9,&out_desc_30,1);
}

#line 7021 "SQLqry21-30.rc"

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

#line 7039 "SQLqry21-30.rc"

           return (status);
        }
    } /* if( !SQLcursor[30] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7050 "SQLqry21-30.rc"

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

#line 7063 "SQLqry21-30.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[30] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_30" ));
        out_desc_30.sqlvar = (sqlvar *)calloc(out_desc_30.sqld, sizeof (sqlvar));
        if (! out_desc_30.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7081 "SQLqry21-30.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_30.sqln = out_desc_30.sqld;

{RISint_describe(RIScpp_stmt_id9,&out_desc_30,1);
}

#line 7090 "SQLqry21-30.rc"

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

#line 7109 "SQLqry21-30.rc"

        free (out_desc_30.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_30.sqld; ++i)
        {
          out_desc_30.sqlvar [i].sqldata =
                 calloc (1, out_desc_30.sqlvar [i].sqllen);
          if (! out_desc_30.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_30.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_30.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7123 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_30.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_30.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_30.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_30.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_30.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7138 "SQLqry21-30.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_30.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_30.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_30.sqld; ++x)
                free (out_desc_30.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_30.sqld; ++x)
                free (out_desc_30.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7160 "SQLqry21-30.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_30.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[30] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_30.sqld ));
       for (i = 0; i < out_desc_30.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_30.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_30.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_30.sqld; ++x)
                   free (out_desc_30.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_30.sqld; ++x)
                   free (out_desc_30.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7218 "SQLqry21-30.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_30.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_30.sqlvar [i].sqlname.sqlnamec,
		       out_desc_30.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_30.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_30.sqld; ++x)
                   free (out_desc_30.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_30.sqld; ++x)
                   free (out_desc_30.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7241 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_30.sqlvar);
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

                 for (x = 0; x < out_desc_30.sqld; ++x)
                   free (out_desc_30.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_30.sqld; ++x)
                   free (out_desc_30.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7261 "SQLqry21-30.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_30.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[30] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 7275 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7300 "SQLqry21-30.rc"

          free (out_desc_30.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id9,0,0,7,1,0);
}

#line 7305 "SQLqry21-30.rc"

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

          for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7331 "SQLqry21-30.rc"

          free (out_desc_30.sqlvar);
          return (status);
        }
    SQLcursor[30] = 1;

    } /* end if( !SQLcursor[30] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[30] != 0 )
    {
        for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7353 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7354 "SQLqry21-30.rc"


        free (out_desc_30.sqlvar); 
    }
    SQLcursor[30] = 0;
    SQLcursor_count[30] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id9,0,&out_desc_30,0,7);
}

#line 7366 "SQLqry21-30.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs30 (First time)" ));
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
                if( SQLcursor[30] && ( SQLcursor_count[30] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7394 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7395 "SQLqry21-30.rc"


          free (out_desc_30.sqlvar); 
          SQLcursor[30] = 0;
          SQLcursor_count[30] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7413 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7414 "SQLqry21-30.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_30.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[30] = 0;
          SQLcursor_count[30] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[30];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_30.sqld; ++i)
           {
             if (*out_desc_30.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_30.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_30.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_30.sqld; ++x)
                       free (out_desc_30.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_30.sqld; ++x)
                       free (out_desc_30.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7455 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7456 "SQLqry21-30.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_30.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[30] = 0;
	             SQLcursor_count[30] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_30.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_30.sqlvar[i].sqllen, 
                  out_desc_30.sqlvar[i].sqllen, out_desc_30.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_30.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_30.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_30.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_30.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_30.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_30.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_30.sqld; ++x)
                    free (out_desc_30.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_30.sqld; ++x)
                    free (out_desc_30.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7524 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7525 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_30.sqlvar);
 	          SQLcursor[30] = 0;
  	          SQLcursor_count[30] = 0;
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
                  for (x = 0; x < out_desc_30.sqld; ++x)
                    free (out_desc_30.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_30.sqld; ++x)
                    free (out_desc_30.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7548 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7549 "SQLqry21-30.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_30.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[30] = 0;
	          SQLcursor_count[30] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_30.sqld; ++x)
               free (out_desc_30.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_30.sqld; ++x)
               free (out_desc_30.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7571 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7572 "SQLqry21-30.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_30.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[30] = 0;
              SQLcursor_count[30] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id9,0,&out_desc_30,0,7);
}

#line 7585 "SQLqry21-30.rc"

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
                if( SQLcursor[30] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_30.sqld; ++x)
               free (out_desc_30.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_30.sqld; ++x)
               free (out_desc_30.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7613 "SQLqry21-30.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7614 "SQLqry21-30.rc"

             free (str);

             free (out_desc_30.sqlvar);
             SQLcursor[30] = 0;
             SQLcursor_count[30] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[30];
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

#line 7636 "SQLqry21-30.rc"

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

	  
          for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_30.sqld; ++x)
            free (out_desc_30.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7662 "SQLqry21-30.rc"

          free (str);

          free (out_desc_30.sqlvar);
          SQLcursor[30] = 0;
          SQLcursor_count[30] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_30.sqld; ++i)
        {
          free (out_desc_30.sqlvar [i].sqldata);
          free (out_desc_30.sqlvar [i].sqlind);
        }

       free (out_desc_30.sqlvar);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7681 "SQLqry21-30.rc"

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
          SQLcursor[30] = 0;
	  SQLcursor_count[30] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[30] = 0;
       SQLcursor_count[30] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

