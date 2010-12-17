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

#line 1 "SQLqry31-40.rc"
#include "machine.h"
#include "SQL.h"

 extern struct SQLglobal_st SQLglobal ;

 extern long SQLquery_count;
 extern int  SQLcursor[41];
 extern long SQLcursor_count[41];


#line 10 "SQLqry31-40.rc"

sqlda out_desc_31;

#line 11 "SQLqry31-40.rc"

sqlda out_desc_32;

#line 12 "SQLqry31-40.rc"

sqlda out_desc_33;

#line 13 "SQLqry31-40.rc"

sqlda out_desc_34;

#line 14 "SQLqry31-40.rc"

sqlda out_desc_35;

#line 15 "SQLqry31-40.rc"

sqlda out_desc_36;

#line 16 "SQLqry31-40.rc"

sqlda out_desc_37;

#line 17 "SQLqry31-40.rc"

sqlda out_desc_38;

#line 18 "SQLqry31-40.rc"

sqlda out_desc_39;

#line 19 "SQLqry31-40.rc"

sqlda out_desc_40;

#line 21 "SQLqry31-40.rc"


 char   *malloc (), *calloc ();

/*  This query routine was developed to be used with large query buffers
 *  where only portions of the data are to be returned. Cursor 2 is used
 *  for display items (full listing).
 */

 long  SQLquery_cursor31 (sql_str31, list, size, rows)

#line 31 "SQLqry31-40.rc"

char * sql_str31;

#line 33 "SQLqry31-40.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor31" ;

#line 42 "SQLqry31-40.rc"

long status;

#line 43 "SQLqry31-40.rc"

long i;

#line 44 "SQLqry31-40.rc"

long x;

#line 45 "SQLqry31-40.rc"

long NEW_LIST;

#line 46 "SQLqry31-40.rc"

long fetch_count;

#line 47 "SQLqry31-40.rc"

char data_type[30];

#line 48 "SQLqry31-40.rc"

char data[30];

#line 49 "SQLqry31-40.rc"

char * str;

#line 50 "SQLqry31-40.rc"

char * data1;

#line 51 "SQLqry31-40.rc"

char * * format;

#line 52 "SQLqry31-40.rc"

datetime * ptr;

#line 53 "SQLqry31-40.rc"

char column_name[50];

#line 55 "SQLqry31-40.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str31, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[31] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[31] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt31" ));
{RISint_prepare(&RIScpp_stmt_id0,sql_str31,1,0);
}

#line 74 "SQLqry31-40.rc"

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

#line 92 "SQLqry31-40.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_31.sqld = 0;
       out_desc_31.sqln = 0;
       out_desc_31.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id0,&out_desc_31,1);
}

#line 107 "SQLqry31-40.rc"

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

#line 125 "SQLqry31-40.rc"

           return (status);
        }
    } /* if( !SQLcursor[31] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 136 "SQLqry31-40.rc"

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

#line 149 "SQLqry31-40.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[31] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_31" ));
        out_desc_31.sqlvar = (sqlvar *)calloc(out_desc_31.sqld, sizeof (sqlvar));
        if (! out_desc_31.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 167 "SQLqry31-40.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_31.sqln = out_desc_31.sqld;

{RISint_describe(RIScpp_stmt_id0,&out_desc_31,1);
}

#line 176 "SQLqry31-40.rc"

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

#line 195 "SQLqry31-40.rc"

        free (out_desc_31.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_31.sqld; ++i)
        {
          out_desc_31.sqlvar [i].sqldata =
                 calloc (1, out_desc_31.sqlvar [i].sqllen);
          if (! out_desc_31.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_31.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_31.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 209 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_31.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_31.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_31.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_31.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_31.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 224 "SQLqry31-40.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_31.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_31.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_31.sqld; ++x)
                free (out_desc_31.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_31.sqld; ++x)
                free (out_desc_31.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 246 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_31.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[31] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_31.sqld ));
       for (i = 0; i < out_desc_31.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_31.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_31.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_31.sqld; ++x)
                   free (out_desc_31.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_31.sqld; ++x)
                   free (out_desc_31.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 304 "SQLqry31-40.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_31.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_31.sqlvar [i].sqlname.sqlnamec,
		       out_desc_31.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_31.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_31.sqld; ++x)
                   free (out_desc_31.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_31.sqld; ++x)
                   free (out_desc_31.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 327 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_31.sqlvar);
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

                 for (x = 0; x < out_desc_31.sqld; ++x)
                   free (out_desc_31.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_31.sqld; ++x)
                   free (out_desc_31.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 347 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_31.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[31] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 361 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 386 "SQLqry31-40.rc"

          free (out_desc_31.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
}

#line 391 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 417 "SQLqry31-40.rc"

          free (out_desc_31.sqlvar);
          return (status);
        }
    SQLcursor[31] = 1;

    } /* end if( !SQLcursor[31] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[31] != 0 )
    {
        for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 439 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 440 "SQLqry31-40.rc"


        free (out_desc_31.sqlvar); 
     }
     SQLcursor[31] = 0;
     SQLcursor_count[31] = 0;
	
     _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

     return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id0,0,&out_desc_31,0,7);
}

#line 452 "SQLqry31-40.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs31 (First time)" ));
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
                if( SQLcursor[31] && ( SQLcursor_count[31] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 480 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 481 "SQLqry31-40.rc"


          free (out_desc_31.sqlvar); 
          SQLcursor[31] = 0;
          SQLcursor_count[31] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 499 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 500 "SQLqry31-40.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_31.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[31] = 0;
          SQLcursor_count[31] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[31];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_31.sqld; ++i)
           {
             if (*out_desc_31.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_31.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_31.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_31.sqld; ++x)
                       free (out_desc_31.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_31.sqld; ++x)
                       free (out_desc_31.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 541 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 542 "SQLqry31-40.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_31.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[31] = 0;
	             SQLcursor_count[31] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_31.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_31.sqlvar[i].sqllen, 
                  out_desc_31.sqlvar[i].sqllen, out_desc_31.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_31.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_31.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_31.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_31.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_31.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_31.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_31.sqld; ++x)
                    free (out_desc_31.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_31.sqld; ++x)
                    free (out_desc_31.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 610 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 611 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_31.sqlvar);
 	          SQLcursor[31] = 0;
  	          SQLcursor_count[31] = 0;
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
                  for (x = 0; x < out_desc_31.sqld; ++x)
                    free (out_desc_31.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_31.sqld; ++x)
                    free (out_desc_31.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 634 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 635 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_31.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[31] = 0;
	          SQLcursor_count[31] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_31.sqld; ++x)
               free (out_desc_31.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_31.sqld; ++x)
               free (out_desc_31.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 657 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 658 "SQLqry31-40.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_31.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[31] = 0;
              SQLcursor_count[31] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id0,0,&out_desc_31,0,7);
}

#line 671 "SQLqry31-40.rc"

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
                if( SQLcursor[31] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_31.sqld; ++x)
               free (out_desc_31.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_31.sqld; ++x)
               free (out_desc_31.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 699 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 700 "SQLqry31-40.rc"

             free (str);

             free (out_desc_31.sqlvar);
             SQLcursor[31] = 0;
             SQLcursor_count[31] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[31];
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

#line 722 "SQLqry31-40.rc"

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

	  
          for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_31.sqld; ++x)
            free (out_desc_31.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 748 "SQLqry31-40.rc"

          free (str);

          free (out_desc_31.sqlvar);
          SQLcursor[31] = 0;
          SQLcursor_count[31] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_31.sqld; ++i)
        {
          free (out_desc_31.sqlvar [i].sqldata);
          free (out_desc_31.sqlvar [i].sqlind);
        }

       free (out_desc_31.sqlvar);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 767 "SQLqry31-40.rc"

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
          SQLcursor[31] = 0;
	  SQLcursor_count[31] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[31] = 0;
       SQLcursor_count[31] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor32 (sql_str32, list, size, rows)

#line 799 "SQLqry31-40.rc"

char * sql_str32;

#line 801 "SQLqry31-40.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor32" ;

#line 810 "SQLqry31-40.rc"

long status;

#line 811 "SQLqry31-40.rc"

long i;

#line 812 "SQLqry31-40.rc"

long x;

#line 813 "SQLqry31-40.rc"

long NEW_LIST;

#line 814 "SQLqry31-40.rc"

long fetch_count;

#line 815 "SQLqry31-40.rc"

char data_type[30];

#line 816 "SQLqry31-40.rc"

char data[30];

#line 817 "SQLqry31-40.rc"

char * str;

#line 818 "SQLqry31-40.rc"

char * data1;

#line 819 "SQLqry31-40.rc"

char * * format;

#line 820 "SQLqry31-40.rc"

datetime * ptr;

#line 821 "SQLqry31-40.rc"

char column_name[50];

#line 823 "SQLqry31-40.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str32, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[32] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[32] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt32" ));
{RISint_prepare(&RIScpp_stmt_id1,sql_str32,1,0);
}

#line 842 "SQLqry31-40.rc"

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

#line 860 "SQLqry31-40.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_32.sqld = 0;
       out_desc_32.sqln = 0;
       out_desc_32.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id1,&out_desc_32,1);
}

#line 875 "SQLqry31-40.rc"

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

#line 893 "SQLqry31-40.rc"

           return (status);
        }
    } /* if( !SQLcursor[32] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 904 "SQLqry31-40.rc"

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

#line 917 "SQLqry31-40.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[32] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_32" ));
        out_desc_32.sqlvar = (sqlvar *)calloc(out_desc_32.sqld, sizeof (sqlvar));
        if (! out_desc_32.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 935 "SQLqry31-40.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_32.sqln = out_desc_32.sqld;

{RISint_describe(RIScpp_stmt_id1,&out_desc_32,1);
}

#line 944 "SQLqry31-40.rc"

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

#line 963 "SQLqry31-40.rc"

        free (out_desc_32.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_32.sqld; ++i)
        {
          out_desc_32.sqlvar [i].sqldata =
                 calloc (1, out_desc_32.sqlvar [i].sqllen);
          if (! out_desc_32.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_32.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_32.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 977 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_32.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_32.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_32.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_32.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_32.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 992 "SQLqry31-40.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_32.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_32.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_32.sqld; ++x)
                free (out_desc_32.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_32.sqld; ++x)
                free (out_desc_32.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1014 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_32.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[32] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_32.sqld ));
       for (i = 0; i < out_desc_32.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_32.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_32.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_32.sqld; ++x)
                   free (out_desc_32.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_32.sqld; ++x)
                   free (out_desc_32.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1072 "SQLqry31-40.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_32.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_32.sqlvar [i].sqlname.sqlnamec,
		       out_desc_32.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_32.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_32.sqld; ++x)
                   free (out_desc_32.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_32.sqld; ++x)
                   free (out_desc_32.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1095 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_32.sqlvar);
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

                 for (x = 0; x < out_desc_32.sqld; ++x)
                   free (out_desc_32.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_32.sqld; ++x)
                   free (out_desc_32.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1115 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_32.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[32] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 1129 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1154 "SQLqry31-40.rc"

          free (out_desc_32.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
}

#line 1159 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1185 "SQLqry31-40.rc"

          free (out_desc_32.sqlvar);
          return (status);
        }
    SQLcursor[32] = 1;

    } /* end if( !SQLcursor[32] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[32] != 0 )
    {
        for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1207 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1208 "SQLqry31-40.rc"


        free (out_desc_32.sqlvar); 
    }
    SQLcursor[32] = 0;
    SQLcursor_count[32] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id1,0,&out_desc_32,0,7);
}

#line 1220 "SQLqry31-40.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs32 (First time)" ));
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
                if( SQLcursor[32] && ( SQLcursor_count[32] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1248 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1249 "SQLqry31-40.rc"


          free (out_desc_32.sqlvar); 
          SQLcursor[32] = 0;
          SQLcursor_count[32] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1267 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1268 "SQLqry31-40.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_32.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[32] = 0;
          SQLcursor_count[32] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[32];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_32.sqld; ++i)
           {
             if (*out_desc_32.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_32.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_32.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_32.sqld; ++x)
                       free (out_desc_32.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_32.sqld; ++x)
                       free (out_desc_32.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1309 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1310 "SQLqry31-40.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_32.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[32] = 0;
	             SQLcursor_count[32] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_32.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_32.sqlvar[i].sqllen, 
                  out_desc_32.sqlvar[i].sqllen, out_desc_32.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_32.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_32.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_32.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_32.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_32.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_32.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_32.sqld; ++x)
                    free (out_desc_32.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_32.sqld; ++x)
                    free (out_desc_32.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1378 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1379 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_32.sqlvar);
 	          SQLcursor[32] = 0;
  	          SQLcursor_count[32] = 0;
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
                  for (x = 0; x < out_desc_32.sqld; ++x)
                    free (out_desc_32.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_32.sqld; ++x)
                    free (out_desc_32.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1402 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1403 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_32.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[32] = 0;
	          SQLcursor_count[32] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_32.sqld; ++x)
               free (out_desc_32.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_32.sqld; ++x)
               free (out_desc_32.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1425 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1426 "SQLqry31-40.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_32.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[32] = 0;
              SQLcursor_count[32] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id1,0,&out_desc_32,0,7);
}

#line 1439 "SQLqry31-40.rc"

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
                if( SQLcursor[32] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_32.sqld; ++x)
               free (out_desc_32.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_32.sqld; ++x)
               free (out_desc_32.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1467 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1468 "SQLqry31-40.rc"

             free (str);

             free (out_desc_32.sqlvar);
             SQLcursor[32] = 0;
             SQLcursor_count[32] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[32];
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

#line 1490 "SQLqry31-40.rc"

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

	  
          for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_32.sqld; ++x)
            free (out_desc_32.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1516 "SQLqry31-40.rc"

          free (str);

          free (out_desc_32.sqlvar);
          SQLcursor[32] = 0;
          SQLcursor_count[32] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_32.sqld; ++i)
        {
          free (out_desc_32.sqlvar [i].sqldata);
          free (out_desc_32.sqlvar [i].sqlind);
        }

       free (out_desc_32.sqlvar);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1535 "SQLqry31-40.rc"

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
          SQLcursor[32] = 0;
	  SQLcursor_count[32] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[32] = 0;
       SQLcursor_count[32] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor33 (sql_str33, list, size, rows)

#line 1568 "SQLqry31-40.rc"

char * sql_str33;

#line 1570 "SQLqry31-40.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor33" ;

#line 1579 "SQLqry31-40.rc"

long status;

#line 1580 "SQLqry31-40.rc"

long i;

#line 1581 "SQLqry31-40.rc"

long x;

#line 1582 "SQLqry31-40.rc"

long NEW_LIST;

#line 1583 "SQLqry31-40.rc"

long fetch_count;

#line 1584 "SQLqry31-40.rc"

char data_type[30];

#line 1585 "SQLqry31-40.rc"

char data[30];

#line 1586 "SQLqry31-40.rc"

char * str;

#line 1587 "SQLqry31-40.rc"

char * data1;

#line 1588 "SQLqry31-40.rc"

char * * format;

#line 1589 "SQLqry31-40.rc"

datetime * ptr;

#line 1590 "SQLqry31-40.rc"

char column_name[50];

#line 1592 "SQLqry31-40.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str33, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[33] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[33] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt33" ));
{RISint_prepare(&RIScpp_stmt_id2,sql_str33,1,0);
}

#line 1611 "SQLqry31-40.rc"

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

#line 1629 "SQLqry31-40.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_33.sqld = 0;
       out_desc_33.sqln = 0;
       out_desc_33.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id2,&out_desc_33,1);
}

#line 1644 "SQLqry31-40.rc"

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

#line 1662 "SQLqry31-40.rc"

           return (status);
        }
    } /* if( !SQLcursor[33] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1673 "SQLqry31-40.rc"

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

#line 1686 "SQLqry31-40.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[33] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_33" ));
        out_desc_33.sqlvar = (sqlvar *)calloc(out_desc_33.sqld, sizeof (sqlvar));
        if (! out_desc_33.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1704 "SQLqry31-40.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_33.sqln = out_desc_33.sqld;

{RISint_describe(RIScpp_stmt_id2,&out_desc_33,1);
}

#line 1713 "SQLqry31-40.rc"

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

#line 1732 "SQLqry31-40.rc"

        free (out_desc_33.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_33.sqld; ++i)
        {
          out_desc_33.sqlvar [i].sqldata =
                 calloc (1, out_desc_33.sqlvar [i].sqllen);
          if (! out_desc_33.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_33.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_33.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1746 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_33.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_33.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_33.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_33.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_33.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1761 "SQLqry31-40.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_33.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_33.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_33.sqld; ++x)
                free (out_desc_33.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_33.sqld; ++x)
                free (out_desc_33.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1783 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_33.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[33] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_33.sqld ));
       for (i = 0; i < out_desc_33.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_33.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_33.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_33.sqld; ++x)
                   free (out_desc_33.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_33.sqld; ++x)
                   free (out_desc_33.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1841 "SQLqry31-40.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_33.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_33.sqlvar [i].sqlname.sqlnamec,
		       out_desc_33.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_33.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_33.sqld; ++x)
                   free (out_desc_33.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_33.sqld; ++x)
                   free (out_desc_33.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1864 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_33.sqlvar);
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

                 for (x = 0; x < out_desc_33.sqld; ++x)
                   free (out_desc_33.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_33.sqld; ++x)
                   free (out_desc_33.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1884 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_33.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[33] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 1898 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1923 "SQLqry31-40.rc"

          free (out_desc_33.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id2,0,0,7,1,0);
}

#line 1928 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1954 "SQLqry31-40.rc"

          free (out_desc_33.sqlvar);
          return (status);
        }
    SQLcursor[33] = 1;

    } /* end if( !SQLcursor[33] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[33] != 0 )
    {
        for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 1976 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1977 "SQLqry31-40.rc"


        free (out_desc_33.sqlvar); 
    }
    SQLcursor[33] = 0;
    SQLcursor_count[33] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id2,0,&out_desc_33,0,7);
}

#line 1989 "SQLqry31-40.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs33 (First time)" ));
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
                if( SQLcursor[33] && ( SQLcursor_count[33] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2017 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2018 "SQLqry31-40.rc"


          free (out_desc_33.sqlvar); 
          SQLcursor[33] = 0;
          SQLcursor_count[33] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2036 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2037 "SQLqry31-40.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_33.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[33] = 0;
          SQLcursor_count[33] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[33];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_33.sqld; ++i)
           {
             if (*out_desc_33.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_33.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_33.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_33.sqld; ++x)
                       free (out_desc_33.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_33.sqld; ++x)
                       free (out_desc_33.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2078 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2079 "SQLqry31-40.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_33.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[33] = 0;
	             SQLcursor_count[33] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_33.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_33.sqlvar[i].sqllen, 
                  out_desc_33.sqlvar[i].sqllen, out_desc_33.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_33.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_33.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_33.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_33.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_33.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_33.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_33.sqld; ++x)
                    free (out_desc_33.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_33.sqld; ++x)
                    free (out_desc_33.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2147 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2148 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_33.sqlvar);
 	          SQLcursor[33] = 0;
  	          SQLcursor_count[33] = 0;
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
                  for (x = 0; x < out_desc_33.sqld; ++x)
                    free (out_desc_33.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_33.sqld; ++x)
                    free (out_desc_33.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2171 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2172 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_33.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[33] = 0;
	          SQLcursor_count[33] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_33.sqld; ++x)
               free (out_desc_33.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_33.sqld; ++x)
               free (out_desc_33.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2194 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2195 "SQLqry31-40.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_33.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[33] = 0;
              SQLcursor_count[33] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id2,0,&out_desc_33,0,7);
}

#line 2208 "SQLqry31-40.rc"

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
                if( SQLcursor[33] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_33.sqld; ++x)
               free (out_desc_33.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_33.sqld; ++x)
               free (out_desc_33.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2236 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2237 "SQLqry31-40.rc"

             free (str);

             free (out_desc_33.sqlvar);
             SQLcursor[33] = 0;
             SQLcursor_count[33] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[33];
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

#line 2259 "SQLqry31-40.rc"

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

	  
          for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_33.sqld; ++x)
            free (out_desc_33.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2285 "SQLqry31-40.rc"

          free (str);

          free (out_desc_33.sqlvar);
          SQLcursor[33] = 0;
          SQLcursor_count[33] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_33.sqld; ++i)
        {
          free (out_desc_33.sqlvar [i].sqldata);
          free (out_desc_33.sqlvar [i].sqlind);
        }

       free (out_desc_33.sqlvar);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2304 "SQLqry31-40.rc"

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
          SQLcursor[33] = 0;
	  SQLcursor_count[33] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[33] = 0;
       SQLcursor_count[33] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor34 (sql_str34, list, size, rows)

#line 2337 "SQLqry31-40.rc"

char * sql_str34;

#line 2339 "SQLqry31-40.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor34" ;

#line 2348 "SQLqry31-40.rc"

long status;

#line 2349 "SQLqry31-40.rc"

long i;

#line 2350 "SQLqry31-40.rc"

long x;

#line 2351 "SQLqry31-40.rc"

long NEW_LIST;

#line 2352 "SQLqry31-40.rc"

long fetch_count;

#line 2353 "SQLqry31-40.rc"

char data_type[30];

#line 2354 "SQLqry31-40.rc"

char data[30];

#line 2355 "SQLqry31-40.rc"

char * str;

#line 2356 "SQLqry31-40.rc"

char * data1;

#line 2357 "SQLqry31-40.rc"

char * * format;

#line 2358 "SQLqry31-40.rc"

datetime * ptr;

#line 2359 "SQLqry31-40.rc"

char column_name[50];

#line 2361 "SQLqry31-40.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str34, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[34] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[34] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt34" ));
{RISint_prepare(&RIScpp_stmt_id3,sql_str34,1,0);
}

#line 2380 "SQLqry31-40.rc"

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

#line 2398 "SQLqry31-40.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_34.sqld = 0;
       out_desc_34.sqln = 0;
       out_desc_34.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id3,&out_desc_34,1);
}

#line 2413 "SQLqry31-40.rc"

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

#line 2431 "SQLqry31-40.rc"

           return (status);
        }
    } /* if( !SQLcursor[34] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2442 "SQLqry31-40.rc"

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

#line 2455 "SQLqry31-40.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[34] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_34" ));
        out_desc_34.sqlvar = (sqlvar *)calloc(out_desc_34.sqld, sizeof (sqlvar));
        if (! out_desc_34.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2473 "SQLqry31-40.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_34.sqln = out_desc_34.sqld;

{RISint_describe(RIScpp_stmt_id3,&out_desc_34,1);
}

#line 2482 "SQLqry31-40.rc"

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

#line 2501 "SQLqry31-40.rc"

        free (out_desc_34.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_34.sqld; ++i)
        {
          out_desc_34.sqlvar [i].sqldata =
                 calloc (1, out_desc_34.sqlvar [i].sqllen);
          if (! out_desc_34.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_34.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_34.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2515 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_34.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_34.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_34.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_34.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_34.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2530 "SQLqry31-40.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_34.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_34.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_34.sqld; ++x)
                free (out_desc_34.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_34.sqld; ++x)
                free (out_desc_34.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2552 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_34.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[34] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_34.sqld ));
       for (i = 0; i < out_desc_34.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_34.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_34.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_34.sqld; ++x)
                   free (out_desc_34.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_34.sqld; ++x)
                   free (out_desc_34.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2610 "SQLqry31-40.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_34.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_34.sqlvar [i].sqlname.sqlnamec,
		       out_desc_34.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_34.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_34.sqld; ++x)
                   free (out_desc_34.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_34.sqld; ++x)
                   free (out_desc_34.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2633 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_34.sqlvar);
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

                 for (x = 0; x < out_desc_34.sqld; ++x)
                   free (out_desc_34.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_34.sqld; ++x)
                   free (out_desc_34.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2653 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_34.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[34] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 2667 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2692 "SQLqry31-40.rc"

          free (out_desc_34.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id3,0,0,7,1,0);
}

#line 2697 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2723 "SQLqry31-40.rc"

          free (out_desc_34.sqlvar);
          return (status);
        }
    SQLcursor[34] = 1;

    } /* end if( !SQLcursor[34] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[34] != 0 )
    {
        for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2745 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2746 "SQLqry31-40.rc"


        free (out_desc_34.sqlvar); 
    }
    SQLcursor[34] = 0;
    SQLcursor_count[34] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id3,0,&out_desc_34,0,7);
}

#line 2758 "SQLqry31-40.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs34 (First time)" ));
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
                if( SQLcursor[34] && ( SQLcursor_count[34] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2786 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2787 "SQLqry31-40.rc"


          free (out_desc_34.sqlvar); 
          SQLcursor[34] = 0;
          SQLcursor_count[34] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2805 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2806 "SQLqry31-40.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_34.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[34] = 0;
          SQLcursor_count[34] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[34];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_34.sqld; ++i)
           {
             if (*out_desc_34.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_34.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_34.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_34.sqld; ++x)
                       free (out_desc_34.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_34.sqld; ++x)
                       free (out_desc_34.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2847 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2848 "SQLqry31-40.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_34.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[34] = 0;
	             SQLcursor_count[34] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_34.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_34.sqlvar[i].sqllen, 
                  out_desc_34.sqlvar[i].sqllen, out_desc_34.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_34.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_34.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_34.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_34.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_34.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_34.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_34.sqld; ++x)
                    free (out_desc_34.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_34.sqld; ++x)
                    free (out_desc_34.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2916 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2917 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_34.sqlvar);
 	          SQLcursor[34] = 0;
  	          SQLcursor_count[34] = 0;
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
                  for (x = 0; x < out_desc_34.sqld; ++x)
                    free (out_desc_34.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_34.sqld; ++x)
                    free (out_desc_34.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2940 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2941 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_34.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[34] = 0;
	          SQLcursor_count[34] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_34.sqld; ++x)
               free (out_desc_34.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_34.sqld; ++x)
               free (out_desc_34.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2963 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2964 "SQLqry31-40.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_34.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[34] = 0;
              SQLcursor_count[34] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id3,0,&out_desc_34,0,7);
}

#line 2977 "SQLqry31-40.rc"

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
                if( SQLcursor[34] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_34.sqld; ++x)
               free (out_desc_34.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_34.sqld; ++x)
               free (out_desc_34.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 3005 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3006 "SQLqry31-40.rc"

             free (str);

             free (out_desc_34.sqlvar);
             SQLcursor[34] = 0;
             SQLcursor_count[34] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[34];
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

#line 3028 "SQLqry31-40.rc"

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

	  
          for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_34.sqld; ++x)
            free (out_desc_34.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3054 "SQLqry31-40.rc"

          free (str);

          free (out_desc_34.sqlvar);
          SQLcursor[34] = 0;
          SQLcursor_count[34] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_34.sqld; ++i)
        {
          free (out_desc_34.sqlvar [i].sqldata);
          free (out_desc_34.sqlvar [i].sqlind);
        }

       free (out_desc_34.sqlvar);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3073 "SQLqry31-40.rc"

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
          SQLcursor[34] = 0;
	  SQLcursor_count[34] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[34] = 0;
       SQLcursor_count[34] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor35 (sql_str35, list, size, rows)

#line 3105 "SQLqry31-40.rc"

char * sql_str35;

#line 3107 "SQLqry31-40.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor35" ;

#line 3116 "SQLqry31-40.rc"

long status;

#line 3117 "SQLqry31-40.rc"

long i;

#line 3118 "SQLqry31-40.rc"

long x;

#line 3119 "SQLqry31-40.rc"

long NEW_LIST;

#line 3120 "SQLqry31-40.rc"

long fetch_count;

#line 3121 "SQLqry31-40.rc"

char data_type[30];

#line 3122 "SQLqry31-40.rc"

char data[30];

#line 3123 "SQLqry31-40.rc"

char * str;

#line 3124 "SQLqry31-40.rc"

char * data1;

#line 3125 "SQLqry31-40.rc"

char * * format;

#line 3126 "SQLqry31-40.rc"

datetime * ptr;

#line 3127 "SQLqry31-40.rc"

char column_name[50];

#line 3129 "SQLqry31-40.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str35, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[35] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[35] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt35" ));
{RISint_prepare(&RIScpp_stmt_id4,sql_str35,1,0);
}

#line 3148 "SQLqry31-40.rc"

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

#line 3166 "SQLqry31-40.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_35.sqld = 0;
       out_desc_35.sqln = 0;
       out_desc_35.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id4,&out_desc_35,1);
}

#line 3181 "SQLqry31-40.rc"

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

#line 3199 "SQLqry31-40.rc"

           return (status);
        }
    } /* if( !SQLcursor[35] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3210 "SQLqry31-40.rc"

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

#line 3223 "SQLqry31-40.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[35] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_35" ));
        out_desc_35.sqlvar = (sqlvar *)calloc(out_desc_35.sqld, sizeof (sqlvar));
        if (! out_desc_35.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3241 "SQLqry31-40.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_35.sqln = out_desc_35.sqld;

{RISint_describe(RIScpp_stmt_id4,&out_desc_35,1);
}

#line 3250 "SQLqry31-40.rc"

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

#line 3269 "SQLqry31-40.rc"

        free (out_desc_35.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_35.sqld; ++i)
        {
          out_desc_35.sqlvar [i].sqldata =
                 calloc (1, out_desc_35.sqlvar [i].sqllen);
          if (! out_desc_35.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_35.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_35.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3283 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_35.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_35.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_35.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_35.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_35.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3298 "SQLqry31-40.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_35.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_35.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_35.sqld; ++x)
                free (out_desc_35.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_35.sqld; ++x)
                free (out_desc_35.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3320 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_35.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[35] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_35.sqld ));
       for (i = 0; i < out_desc_35.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_35.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_35.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_35.sqld; ++x)
                   free (out_desc_35.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_35.sqld; ++x)
                   free (out_desc_35.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3378 "SQLqry31-40.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_35.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_35.sqlvar [i].sqlname.sqlnamec,
		       out_desc_35.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_35.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_35.sqld; ++x)
                   free (out_desc_35.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_35.sqld; ++x)
                   free (out_desc_35.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3401 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_35.sqlvar);
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

                 for (x = 0; x < out_desc_35.sqld; ++x)
                   free (out_desc_35.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_35.sqld; ++x)
                   free (out_desc_35.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3421 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_35.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[35] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 3435 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3460 "SQLqry31-40.rc"

          free (out_desc_35.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id4,0,0,7,1,0);
}

#line 3465 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3491 "SQLqry31-40.rc"

          free (out_desc_35.sqlvar);
          return (status);
        }
    SQLcursor[35] = 1;

    } /* end if( !SQLcursor[35] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[35] != 0 )
    {
        for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3513 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3514 "SQLqry31-40.rc"


        free (out_desc_35.sqlvar); 
    }
    SQLcursor[35] = 0;
    SQLcursor_count[35] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id4,0,&out_desc_35,0,7);
}

#line 3526 "SQLqry31-40.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs35 (First time)" ));
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
                if( SQLcursor[35] && ( SQLcursor_count[35] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3554 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3555 "SQLqry31-40.rc"


          free (out_desc_35.sqlvar); 
          SQLcursor[35] = 0;
          SQLcursor_count[35] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3573 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3574 "SQLqry31-40.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_35.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[35] = 0;
          SQLcursor_count[35] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[35];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_35.sqld; ++i)
           {
             if (*out_desc_35.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_35.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_35.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_35.sqld; ++x)
                       free (out_desc_35.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_35.sqld; ++x)
                       free (out_desc_35.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3615 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3616 "SQLqry31-40.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_35.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[35] = 0;
	             SQLcursor_count[35] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_35.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_35.sqlvar[i].sqllen, 
                  out_desc_35.sqlvar[i].sqllen, out_desc_35.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_35.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_35.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_35.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_35.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_35.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_35.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_35.sqld; ++x)
                    free (out_desc_35.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_35.sqld; ++x)
                    free (out_desc_35.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3684 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3685 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_35.sqlvar);
 	          SQLcursor[35] = 0;
  	          SQLcursor_count[35] = 0;
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
                  for (x = 0; x < out_desc_35.sqld; ++x)
                    free (out_desc_35.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_35.sqld; ++x)
                    free (out_desc_35.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3708 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3709 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_35.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[35] = 0;
	          SQLcursor_count[35] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_35.sqld; ++x)
               free (out_desc_35.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_35.sqld; ++x)
               free (out_desc_35.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3731 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3732 "SQLqry31-40.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_35.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[35] = 0;
              SQLcursor_count[35] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id4,0,&out_desc_35,0,7);
}

#line 3745 "SQLqry31-40.rc"

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
                if( SQLcursor[35] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_35.sqld; ++x)
               free (out_desc_35.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_35.sqld; ++x)
               free (out_desc_35.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3773 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3774 "SQLqry31-40.rc"

             free (str);

             free (out_desc_35.sqlvar);
             SQLcursor[35] = 0;
             SQLcursor_count[35] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[35];
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

#line 3796 "SQLqry31-40.rc"

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

	  
          for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_35.sqld; ++x)
            free (out_desc_35.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3822 "SQLqry31-40.rc"

          free (str);

          free (out_desc_35.sqlvar);
          SQLcursor[35] = 0;
          SQLcursor_count[35] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_35.sqld; ++i)
        {
          free (out_desc_35.sqlvar [i].sqldata);
          free (out_desc_35.sqlvar [i].sqlind);
        }

       free (out_desc_35.sqlvar);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3841 "SQLqry31-40.rc"

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
          SQLcursor[35] = 0;
	  SQLcursor_count[35] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[35] = 0;
       SQLcursor_count[35] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor36 (sql_str36, list, size, rows)

#line 3874 "SQLqry31-40.rc"

char * sql_str36;

#line 3876 "SQLqry31-40.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor36" ;

#line 3885 "SQLqry31-40.rc"

long status;

#line 3886 "SQLqry31-40.rc"

long i;

#line 3887 "SQLqry31-40.rc"

long x;

#line 3888 "SQLqry31-40.rc"

long NEW_LIST;

#line 3889 "SQLqry31-40.rc"

long fetch_count;

#line 3890 "SQLqry31-40.rc"

char data_type[30];

#line 3891 "SQLqry31-40.rc"

char data[30];

#line 3892 "SQLqry31-40.rc"

char * str;

#line 3893 "SQLqry31-40.rc"

char * data1;

#line 3894 "SQLqry31-40.rc"

char * * format;

#line 3895 "SQLqry31-40.rc"

datetime * ptr;

#line 3896 "SQLqry31-40.rc"

char column_name[50];

#line 3898 "SQLqry31-40.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str36, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[36] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[36] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt36" ));
{RISint_prepare(&RIScpp_stmt_id5,sql_str36,1,0);
}

#line 3917 "SQLqry31-40.rc"

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

#line 3935 "SQLqry31-40.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_36.sqld = 0;
       out_desc_36.sqln = 0;
       out_desc_36.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id5,&out_desc_36,1);
}

#line 3950 "SQLqry31-40.rc"

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

#line 3968 "SQLqry31-40.rc"

           return (status);
        }
    } /* if( !SQLcursor[36] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 3979 "SQLqry31-40.rc"

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

#line 3992 "SQLqry31-40.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[36] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_36" ));
        out_desc_36.sqlvar = (sqlvar *)calloc(out_desc_36.sqld, sizeof (sqlvar));
        if (! out_desc_36.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4010 "SQLqry31-40.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_36.sqln = out_desc_36.sqld;

{RISint_describe(RIScpp_stmt_id5,&out_desc_36,1);
}

#line 4019 "SQLqry31-40.rc"

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

#line 4038 "SQLqry31-40.rc"

        free (out_desc_36.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_36.sqld; ++i)
        {
          out_desc_36.sqlvar [i].sqldata =
                 calloc (1, out_desc_36.sqlvar [i].sqllen);
          if (! out_desc_36.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_36.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_36.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4052 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_36.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_36.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_36.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_36.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_36.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4067 "SQLqry31-40.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_36.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_36.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_36.sqld; ++x)
                free (out_desc_36.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_36.sqld; ++x)
                free (out_desc_36.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4089 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_36.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[36] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_36.sqld ));
       for (i = 0; i < out_desc_36.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_36.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_36.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_36.sqld; ++x)
                   free (out_desc_36.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_36.sqld; ++x)
                   free (out_desc_36.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4147 "SQLqry31-40.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_36.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_36.sqlvar [i].sqlname.sqlnamec,
		       out_desc_36.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_36.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_36.sqld; ++x)
                   free (out_desc_36.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_36.sqld; ++x)
                   free (out_desc_36.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4170 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_36.sqlvar);
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

                 for (x = 0; x < out_desc_36.sqld; ++x)
                   free (out_desc_36.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_36.sqld; ++x)
                   free (out_desc_36.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4190 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_36.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[36] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 4204 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4229 "SQLqry31-40.rc"

          free (out_desc_36.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id5,0,0,7,1,0);
}

#line 4234 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4260 "SQLqry31-40.rc"

          free (out_desc_36.sqlvar);
          return (status);
        }
    SQLcursor[36] = 1;

    } /* end if( !SQLcursor[36] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[36] != 0 )
    {
        for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4282 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4283 "SQLqry31-40.rc"


        free (out_desc_36.sqlvar); 
    }
    SQLcursor[36] = 0;
    SQLcursor_count[36] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id5,0,&out_desc_36,0,7);
}

#line 4295 "SQLqry31-40.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs36 (First time)" ));
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
                if( SQLcursor[36] && ( SQLcursor_count[36] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4323 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4324 "SQLqry31-40.rc"


          free (out_desc_36.sqlvar); 
          SQLcursor[36] = 0;
          SQLcursor_count[36] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4342 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4343 "SQLqry31-40.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_36.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[36] = 0;
          SQLcursor_count[36] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[36];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_36.sqld; ++i)
           {
             if (*out_desc_36.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_36.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_36.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_36.sqld; ++x)
                       free (out_desc_36.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_36.sqld; ++x)
                       free (out_desc_36.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4384 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4385 "SQLqry31-40.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_36.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[36] = 0;
	             SQLcursor_count[36] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_36.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_36.sqlvar[i].sqllen, 
                  out_desc_36.sqlvar[i].sqllen, out_desc_36.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_36.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_36.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_36.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_36.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_36.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_36.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_36.sqld; ++x)
                    free (out_desc_36.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_36.sqld; ++x)
                    free (out_desc_36.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4453 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4454 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_36.sqlvar);
 	          SQLcursor[36] = 0;
  	          SQLcursor_count[36] = 0;
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
                  for (x = 0; x < out_desc_36.sqld; ++x)
                    free (out_desc_36.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_36.sqld; ++x)
                    free (out_desc_36.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4477 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4478 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_36.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[36] = 0;
	          SQLcursor_count[36] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_36.sqld; ++x)
               free (out_desc_36.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_36.sqld; ++x)
               free (out_desc_36.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4500 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4501 "SQLqry31-40.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_36.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[36] = 0;
              SQLcursor_count[36] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id5,0,&out_desc_36,0,7);
}

#line 4514 "SQLqry31-40.rc"

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
                if( SQLcursor[36] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_36.sqld; ++x)
               free (out_desc_36.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_36.sqld; ++x)
               free (out_desc_36.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4542 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4543 "SQLqry31-40.rc"

             free (str);

             free (out_desc_36.sqlvar);
             SQLcursor[36] = 0;
             SQLcursor_count[36] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[36];
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

#line 4565 "SQLqry31-40.rc"

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

	  
          for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_36.sqld; ++x)
            free (out_desc_36.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4591 "SQLqry31-40.rc"

          free (str);

          free (out_desc_36.sqlvar);
          SQLcursor[36] = 0;
          SQLcursor_count[36] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_36.sqld; ++i)
        {
          free (out_desc_36.sqlvar [i].sqldata);
          free (out_desc_36.sqlvar [i].sqlind);
        }

       free (out_desc_36.sqlvar);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4610 "SQLqry31-40.rc"

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
          SQLcursor[36] = 0;
	  SQLcursor_count[36] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[36] = 0;
       SQLcursor_count[36] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor37 (sql_str37, list, size, rows)

#line 4643 "SQLqry31-40.rc"

char * sql_str37;

#line 4645 "SQLqry31-40.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor37" ;

#line 4654 "SQLqry31-40.rc"

long status;

#line 4655 "SQLqry31-40.rc"

long i;

#line 4656 "SQLqry31-40.rc"

long x;

#line 4657 "SQLqry31-40.rc"

long NEW_LIST;

#line 4658 "SQLqry31-40.rc"

long fetch_count;

#line 4659 "SQLqry31-40.rc"

char data_type[30];

#line 4660 "SQLqry31-40.rc"

char data[30];

#line 4661 "SQLqry31-40.rc"

char * str;

#line 4662 "SQLqry31-40.rc"

char * data1;

#line 4663 "SQLqry31-40.rc"

char * * format;

#line 4664 "SQLqry31-40.rc"

datetime * ptr;

#line 4665 "SQLqry31-40.rc"

char column_name[50];

#line 4667 "SQLqry31-40.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str37, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[37] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[37] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt37" ));
{RISint_prepare(&RIScpp_stmt_id6,sql_str37,1,0);
}

#line 4686 "SQLqry31-40.rc"

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

#line 4704 "SQLqry31-40.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_37.sqld = 0;
       out_desc_37.sqln = 0;
       out_desc_37.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id6,&out_desc_37,1);
}

#line 4719 "SQLqry31-40.rc"

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

#line 4737 "SQLqry31-40.rc"

           return (status);
        }
    } /* if( !SQLcursor[37] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4748 "SQLqry31-40.rc"

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

#line 4761 "SQLqry31-40.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[37] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_37" ));
        out_desc_37.sqlvar = (sqlvar *)calloc(out_desc_37.sqld, sizeof (sqlvar));
        if (! out_desc_37.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4779 "SQLqry31-40.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_37.sqln = out_desc_37.sqld;

{RISint_describe(RIScpp_stmt_id6,&out_desc_37,1);
}

#line 4788 "SQLqry31-40.rc"

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

#line 4807 "SQLqry31-40.rc"

        free (out_desc_37.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_37.sqld; ++i)
        {
          out_desc_37.sqlvar [i].sqldata =
                 calloc (1, out_desc_37.sqlvar [i].sqllen);
          if (! out_desc_37.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_37.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_37.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4821 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_37.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_37.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_37.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_37.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_37.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4836 "SQLqry31-40.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_37.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_37.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_37.sqld; ++x)
                free (out_desc_37.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_37.sqld; ++x)
                free (out_desc_37.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4858 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_37.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[37] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_37.sqld ));
       for (i = 0; i < out_desc_37.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_37.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_37.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_37.sqld; ++x)
                   free (out_desc_37.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_37.sqld; ++x)
                   free (out_desc_37.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4916 "SQLqry31-40.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_37.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_37.sqlvar [i].sqlname.sqlnamec,
		       out_desc_37.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_37.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_37.sqld; ++x)
                   free (out_desc_37.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_37.sqld; ++x)
                   free (out_desc_37.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4939 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_37.sqlvar);
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

                 for (x = 0; x < out_desc_37.sqld; ++x)
                   free (out_desc_37.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_37.sqld; ++x)
                   free (out_desc_37.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4959 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_37.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[37] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 4973 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4998 "SQLqry31-40.rc"

          free (out_desc_37.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id6,0,0,7,1,0);
}

#line 5003 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5029 "SQLqry31-40.rc"

          free (out_desc_37.sqlvar);
          return (status);
        }
    SQLcursor[37] = 1;

    } /* end if( !SQLcursor[37] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[37] != 0 )
    {
        for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5051 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5052 "SQLqry31-40.rc"


        free (out_desc_37.sqlvar); 
    }
    SQLcursor[37] = 0;
    SQLcursor_count[37] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id6,0,&out_desc_37,0,7);
}

#line 5064 "SQLqry31-40.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs37 (First time)" ));
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
                if( SQLcursor[37] && ( SQLcursor_count[37] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5092 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5093 "SQLqry31-40.rc"


          free (out_desc_37.sqlvar); 
          SQLcursor[37] = 0;
          SQLcursor_count[37] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5111 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5112 "SQLqry31-40.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_37.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[37] = 0;
          SQLcursor_count[37] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[37];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_37.sqld; ++i)
           {
             if (*out_desc_37.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_37.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_37.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_37.sqld; ++x)
                       free (out_desc_37.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_37.sqld; ++x)
                       free (out_desc_37.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5153 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5154 "SQLqry31-40.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_37.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[37] = 0;
	             SQLcursor_count[37] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_37.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_37.sqlvar[i].sqllen, 
                  out_desc_37.sqlvar[i].sqllen, out_desc_37.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_37.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_37.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_37.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_37.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_37.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_37.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_37.sqld; ++x)
                    free (out_desc_37.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_37.sqld; ++x)
                    free (out_desc_37.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5222 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5223 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_37.sqlvar);
 	          SQLcursor[37] = 0;
  	          SQLcursor_count[37] = 0;
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
                  for (x = 0; x < out_desc_37.sqld; ++x)
                    free (out_desc_37.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_37.sqld; ++x)
                    free (out_desc_37.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5246 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5247 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_37.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[37] = 0;
	          SQLcursor_count[37] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_37.sqld; ++x)
               free (out_desc_37.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_37.sqld; ++x)
               free (out_desc_37.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5269 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5270 "SQLqry31-40.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_37.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[37] = 0;
              SQLcursor_count[37] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id6,0,&out_desc_37,0,7);
}

#line 5283 "SQLqry31-40.rc"

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
                if( SQLcursor[37] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_37.sqld; ++x)
               free (out_desc_37.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_37.sqld; ++x)
               free (out_desc_37.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5311 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5312 "SQLqry31-40.rc"

             free (str);

             free (out_desc_37.sqlvar);
             SQLcursor[37] = 0;
             SQLcursor_count[37] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[37];
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

#line 5334 "SQLqry31-40.rc"

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

	  
          for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_37.sqld; ++x)
            free (out_desc_37.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5360 "SQLqry31-40.rc"

          free (str);

          free (out_desc_37.sqlvar);
          SQLcursor[37] = 0;
          SQLcursor_count[37] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_37.sqld; ++i)
        {
          free (out_desc_37.sqlvar [i].sqldata);
          free (out_desc_37.sqlvar [i].sqlind);
        }

       free (out_desc_37.sqlvar);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5379 "SQLqry31-40.rc"

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
          SQLcursor[37] = 0;
	  SQLcursor_count[37] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[37] = 0;
       SQLcursor_count[37] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor38 (sql_str38, list, size, rows)

#line 5412 "SQLqry31-40.rc"

char * sql_str38;

#line 5414 "SQLqry31-40.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor38" ;

#line 5423 "SQLqry31-40.rc"

long status;

#line 5424 "SQLqry31-40.rc"

long i;

#line 5425 "SQLqry31-40.rc"

long x;

#line 5426 "SQLqry31-40.rc"

long NEW_LIST;

#line 5427 "SQLqry31-40.rc"

long fetch_count;

#line 5428 "SQLqry31-40.rc"

char data_type[30];

#line 5429 "SQLqry31-40.rc"

char data[30];

#line 5430 "SQLqry31-40.rc"

char * str;

#line 5431 "SQLqry31-40.rc"

char * data1;

#line 5432 "SQLqry31-40.rc"

char * * format;

#line 5433 "SQLqry31-40.rc"

datetime * ptr;

#line 5434 "SQLqry31-40.rc"

char column_name[50];

#line 5436 "SQLqry31-40.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str38, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[38] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[38] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt38" ));
{RISint_prepare(&RIScpp_stmt_id7,sql_str38,1,0);
}

#line 5455 "SQLqry31-40.rc"

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

#line 5473 "SQLqry31-40.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_38.sqld = 0;
       out_desc_38.sqln = 0;
       out_desc_38.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id7,&out_desc_38,1);
}

#line 5488 "SQLqry31-40.rc"

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

#line 5506 "SQLqry31-40.rc"

           return (status);
        }
    } /* if( !SQLcursor[38] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5517 "SQLqry31-40.rc"

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

#line 5530 "SQLqry31-40.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[38] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_38" ));
        out_desc_38.sqlvar = (sqlvar *)calloc(out_desc_38.sqld, sizeof (sqlvar));
        if (! out_desc_38.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5548 "SQLqry31-40.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_38.sqln = out_desc_38.sqld;

{RISint_describe(RIScpp_stmt_id7,&out_desc_38,1);
}

#line 5557 "SQLqry31-40.rc"

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

#line 5576 "SQLqry31-40.rc"

        free (out_desc_38.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_38.sqld; ++i)
        {
          out_desc_38.sqlvar [i].sqldata =
                 calloc (1, out_desc_38.sqlvar [i].sqllen);
          if (! out_desc_38.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_38.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_38.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5590 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_38.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_38.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_38.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_38.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_38.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5605 "SQLqry31-40.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_38.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_38.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_38.sqld; ++x)
                free (out_desc_38.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_38.sqld; ++x)
                free (out_desc_38.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5627 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_38.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[38] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_38.sqld ));
       for (i = 0; i < out_desc_38.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_38.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_38.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_38.sqld; ++x)
                   free (out_desc_38.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_38.sqld; ++x)
                   free (out_desc_38.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5685 "SQLqry31-40.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_38.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_38.sqlvar [i].sqlname.sqlnamec,
		       out_desc_38.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_38.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_38.sqld; ++x)
                   free (out_desc_38.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_38.sqld; ++x)
                   free (out_desc_38.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5708 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_38.sqlvar);
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

                 for (x = 0; x < out_desc_38.sqld; ++x)
                   free (out_desc_38.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_38.sqld; ++x)
                   free (out_desc_38.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5728 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_38.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[38] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 5742 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5767 "SQLqry31-40.rc"

          free (out_desc_38.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id7,0,0,7,1,0);
}

#line 5772 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5798 "SQLqry31-40.rc"

          free (out_desc_38.sqlvar);
          return (status);
        }
    SQLcursor[38] = 1;

    } /* end if( !SQLcursor[38] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[38] != 0 )
    {
        for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5820 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5821 "SQLqry31-40.rc"


        free (out_desc_38.sqlvar); 
    }
    SQLcursor[38] = 0;
    SQLcursor_count[38] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id7,0,&out_desc_38,0,7);
}

#line 5833 "SQLqry31-40.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs38 (First time)" ));
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
                if( SQLcursor[38] && ( SQLcursor_count[38] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5861 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5862 "SQLqry31-40.rc"


          free (out_desc_38.sqlvar); 
          SQLcursor[38] = 0;
          SQLcursor_count[38] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5880 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5881 "SQLqry31-40.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_38.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[38] = 0;
          SQLcursor_count[38] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[38];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_38.sqld; ++i)
           {
             if (*out_desc_38.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_38.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_38.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_38.sqld; ++x)
                       free (out_desc_38.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_38.sqld; ++x)
                       free (out_desc_38.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5922 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5923 "SQLqry31-40.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_38.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[38] = 0;
	             SQLcursor_count[38] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_38.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_38.sqlvar[i].sqllen, 
                  out_desc_38.sqlvar[i].sqllen, out_desc_38.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_38.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_38.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_38.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_38.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_38.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_38.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_38.sqld; ++x)
                    free (out_desc_38.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_38.sqld; ++x)
                    free (out_desc_38.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5991 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5992 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_38.sqlvar);
 	          SQLcursor[38] = 0;
  	          SQLcursor_count[38] = 0;
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
                  for (x = 0; x < out_desc_38.sqld; ++x)
                    free (out_desc_38.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_38.sqld; ++x)
                    free (out_desc_38.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6015 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6016 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_38.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[38] = 0;
	          SQLcursor_count[38] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_38.sqld; ++x)
               free (out_desc_38.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_38.sqld; ++x)
               free (out_desc_38.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6038 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6039 "SQLqry31-40.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_38.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[38] = 0;
              SQLcursor_count[38] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id7,0,&out_desc_38,0,7);
}

#line 6052 "SQLqry31-40.rc"

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
                if( SQLcursor[38] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_38.sqld; ++x)
               free (out_desc_38.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_38.sqld; ++x)
               free (out_desc_38.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6080 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6081 "SQLqry31-40.rc"

             free (str);

             free (out_desc_38.sqlvar);
             SQLcursor[38] = 0;
             SQLcursor_count[38] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[38];
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

#line 6103 "SQLqry31-40.rc"

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

	  
          for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_38.sqld; ++x)
            free (out_desc_38.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6129 "SQLqry31-40.rc"

          free (str);

          free (out_desc_38.sqlvar);
          SQLcursor[38] = 0;
          SQLcursor_count[38] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_38.sqld; ++i)
        {
          free (out_desc_38.sqlvar [i].sqldata);
          free (out_desc_38.sqlvar [i].sqlind);
        }

       free (out_desc_38.sqlvar);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6148 "SQLqry31-40.rc"

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
          SQLcursor[38] = 0;
	  SQLcursor_count[38] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[38] = 0;
       SQLcursor_count[38] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor39 (sql_str39, list, size, rows)

#line 6181 "SQLqry31-40.rc"

char * sql_str39;

#line 6183 "SQLqry31-40.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor39" ;

#line 6192 "SQLqry31-40.rc"

long status;

#line 6193 "SQLqry31-40.rc"

long i;

#line 6194 "SQLqry31-40.rc"

long x;

#line 6195 "SQLqry31-40.rc"

long NEW_LIST;

#line 6196 "SQLqry31-40.rc"

long fetch_count;

#line 6197 "SQLqry31-40.rc"

char data_type[30];

#line 6198 "SQLqry31-40.rc"

char data[30];

#line 6199 "SQLqry31-40.rc"

char * str;

#line 6200 "SQLqry31-40.rc"

char * data1;

#line 6201 "SQLqry31-40.rc"

char * * format;

#line 6202 "SQLqry31-40.rc"

datetime * ptr;

#line 6203 "SQLqry31-40.rc"

char column_name[50];

#line 6205 "SQLqry31-40.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str39, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[39] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[39] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt39" ));
{RISint_prepare(&RIScpp_stmt_id8,sql_str39,1,0);
}

#line 6224 "SQLqry31-40.rc"

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

#line 6242 "SQLqry31-40.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_39.sqld = 0;
       out_desc_39.sqln = 0;
       out_desc_39.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id8,&out_desc_39,1);
}

#line 6257 "SQLqry31-40.rc"

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

#line 6275 "SQLqry31-40.rc"

           return (status);
        }
    } /* if( !SQLcursor[39] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6286 "SQLqry31-40.rc"

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

#line 6299 "SQLqry31-40.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[39] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_39" ));
        out_desc_39.sqlvar = (sqlvar *)calloc(out_desc_39.sqld, sizeof (sqlvar));
        if (! out_desc_39.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6317 "SQLqry31-40.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_39.sqln = out_desc_39.sqld;

{RISint_describe(RIScpp_stmt_id8,&out_desc_39,1);
}

#line 6326 "SQLqry31-40.rc"

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

#line 6345 "SQLqry31-40.rc"

        free (out_desc_39.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_39.sqld; ++i)
        {
          out_desc_39.sqlvar [i].sqldata =
                 calloc (1, out_desc_39.sqlvar [i].sqllen);
          if (! out_desc_39.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_39.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_39.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6359 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_39.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_39.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_39.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_39.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_39.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6374 "SQLqry31-40.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_39.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_39.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_39.sqld; ++x)
                free (out_desc_39.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_39.sqld; ++x)
                free (out_desc_39.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6396 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_39.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[39] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_39.sqld ));
       for (i = 0; i < out_desc_39.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_39.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_39.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_39.sqld; ++x)
                   free (out_desc_39.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_39.sqld; ++x)
                   free (out_desc_39.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6454 "SQLqry31-40.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_39.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_39.sqlvar [i].sqlname.sqlnamec,
		       out_desc_39.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_39.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_39.sqld; ++x)
                   free (out_desc_39.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_39.sqld; ++x)
                   free (out_desc_39.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6477 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_39.sqlvar);
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

                 for (x = 0; x < out_desc_39.sqld; ++x)
                   free (out_desc_39.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_39.sqld; ++x)
                   free (out_desc_39.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6497 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_39.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[39] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 6511 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6536 "SQLqry31-40.rc"

          free (out_desc_39.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id8,0,0,7,1,0);
}

#line 6541 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6567 "SQLqry31-40.rc"

          free (out_desc_39.sqlvar);
          return (status);
        }
    SQLcursor[39] = 1;

    } /* end if( !SQLcursor[39] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[39] != 0 )
    {
        for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6589 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6590 "SQLqry31-40.rc"


        free (out_desc_39.sqlvar); 
    }
    SQLcursor[39] = 0;
    SQLcursor_count[39] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id8,0,&out_desc_39,0,7);
}

#line 6602 "SQLqry31-40.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs39 (First time)" ));
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
                if( SQLcursor[39] && ( SQLcursor_count[39] > 0 ) )
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6630 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6631 "SQLqry31-40.rc"


          free (out_desc_39.sqlvar); 
          SQLcursor[39] = 0;
          SQLcursor_count[39] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6649 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6650 "SQLqry31-40.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_39.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[39] = 0;
          SQLcursor_count[39] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[39];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_39.sqld; ++i)
           {
             if (*out_desc_39.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_39.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_39.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_39.sqld; ++x)
                       free (out_desc_39.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_39.sqld; ++x)
                       free (out_desc_39.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6691 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6692 "SQLqry31-40.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_39.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[39] = 0;
	             SQLcursor_count[39] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_39.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_39.sqlvar[i].sqllen, 
                  out_desc_39.sqlvar[i].sqllen, out_desc_39.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_39.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_39.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_39.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_39.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_39.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_39.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_39.sqld; ++x)
                    free (out_desc_39.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_39.sqld; ++x)
                    free (out_desc_39.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6760 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6761 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_39.sqlvar);
 	          SQLcursor[39] = 0;
  	          SQLcursor_count[39] = 0;
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
                  for (x = 0; x < out_desc_39.sqld; ++x)
                    free (out_desc_39.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_39.sqld; ++x)
                    free (out_desc_39.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6784 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6785 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_39.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[39] = 0;
	          SQLcursor_count[39] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_39.sqld; ++x)
               free (out_desc_39.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_39.sqld; ++x)
               free (out_desc_39.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6807 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6808 "SQLqry31-40.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_39.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[39] = 0;
              SQLcursor_count[39] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id8,0,&out_desc_39,0,7);
}

#line 6821 "SQLqry31-40.rc"

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
                if( SQLcursor[39] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_39.sqld; ++x)
               free (out_desc_39.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_39.sqld; ++x)
               free (out_desc_39.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6849 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6850 "SQLqry31-40.rc"

             free (str);

             free (out_desc_39.sqlvar);
             SQLcursor[39] = 0;
             SQLcursor_count[39] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[39];
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

#line 6872 "SQLqry31-40.rc"

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

	  
          for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_39.sqld; ++x)
            free (out_desc_39.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6898 "SQLqry31-40.rc"

          free (str);

          free (out_desc_39.sqlvar);
          SQLcursor[39] = 0;
          SQLcursor_count[39] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_39.sqld; ++i)
        {
          free (out_desc_39.sqlvar [i].sqldata);
          free (out_desc_39.sqlvar [i].sqlind);
        }

       free (out_desc_39.sqlvar);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6917 "SQLqry31-40.rc"

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
          SQLcursor[39] = 0;
	  SQLcursor_count[39] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[39] = 0;
       SQLcursor_count[39] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor40 (sql_str40, list, size, rows)

#line 6950 "SQLqry31-40.rc"

char * sql_str40;

#line 6952 "SQLqry31-40.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor40" ;

#line 6961 "SQLqry31-40.rc"

long status;

#line 6962 "SQLqry31-40.rc"

long i;

#line 6963 "SQLqry31-40.rc"

long x;

#line 6964 "SQLqry31-40.rc"

long NEW_LIST;

#line 6965 "SQLqry31-40.rc"

long fetch_count;

#line 6966 "SQLqry31-40.rc"

char data_type[30];

#line 6967 "SQLqry31-40.rc"

char data[30];

#line 6968 "SQLqry31-40.rc"

char * str;

#line 6969 "SQLqry31-40.rc"

char * data1;

#line 6970 "SQLqry31-40.rc"

char * * format;

#line 6971 "SQLqry31-40.rc"

datetime * ptr;

#line 6972 "SQLqry31-40.rc"

char column_name[50];

#line 6974 "SQLqry31-40.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str40, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[40] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[40] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt40" ));
{RISint_prepare(&RIScpp_stmt_id9,sql_str40,1,0);
}

#line 6993 "SQLqry31-40.rc"

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

#line 7011 "SQLqry31-40.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_40.sqld = 0;
       out_desc_40.sqln = 0;
       out_desc_40.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id9,&out_desc_40,1);
}

#line 7026 "SQLqry31-40.rc"

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

#line 7044 "SQLqry31-40.rc"

           return (status);
        }
    } /* if( !SQLcursor[40] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7055 "SQLqry31-40.rc"

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

#line 7068 "SQLqry31-40.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[40] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_40" ));
        out_desc_40.sqlvar = (sqlvar *)calloc(out_desc_40.sqld, sizeof (sqlvar));
        if (! out_desc_40.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7086 "SQLqry31-40.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_40.sqln = out_desc_40.sqld;

{RISint_describe(RIScpp_stmt_id9,&out_desc_40,1);
}

#line 7095 "SQLqry31-40.rc"

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

#line 7114 "SQLqry31-40.rc"

        free (out_desc_40.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_40.sqld; ++i)
        {
          out_desc_40.sqlvar [i].sqldata =
                 calloc (1, out_desc_40.sqlvar [i].sqllen);
          if (! out_desc_40.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_40.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_40.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7128 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_40.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_40.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_40.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_40.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_40.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7143 "SQLqry31-40.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_40.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_40.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_40.sqld; ++x)
                free (out_desc_40.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_40.sqld; ++x)
                free (out_desc_40.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7165 "SQLqry31-40.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_40.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[40] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_40.sqld ));
       for (i = 0; i < out_desc_40.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_40.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_40.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_40.sqld; ++x)
                   free (out_desc_40.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_40.sqld; ++x)
                   free (out_desc_40.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7223 "SQLqry31-40.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_40.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_40.sqlvar [i].sqlname.sqlnamec,
		       out_desc_40.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_40.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_40.sqld; ++x)
                   free (out_desc_40.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_40.sqld; ++x)
                   free (out_desc_40.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7246 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_40.sqlvar);
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

                 for (x = 0; x < out_desc_40.sqld; ++x)
                   free (out_desc_40.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_40.sqld; ++x)
                   free (out_desc_40.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7266 "SQLqry31-40.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_40.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[40] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 7280 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7305 "SQLqry31-40.rc"

          free (out_desc_40.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id9,0,0,7,1,0);
}

#line 7310 "SQLqry31-40.rc"

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

          for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7336 "SQLqry31-40.rc"

          free (out_desc_40.sqlvar);
          return (status);
        }
    SQLcursor[40] = 1;

    } /* end if( !SQLcursor[40] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[40] != 0 )
    {
        for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7358 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7359 "SQLqry31-40.rc"


        free (out_desc_40.sqlvar); 
    }
    SQLcursor[40] = 0;
    SQLcursor_count[40] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id9,0,&out_desc_40,0,7);
}

#line 7371 "SQLqry31-40.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs40 (First time)" ));
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
                if( SQLcursor[40] && ( SQLcursor_count[40] > 0 ))
                    status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7399 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7400 "SQLqry31-40.rc"


          free (out_desc_40.sqlvar); 
          SQLcursor[40] = 0;
          SQLcursor_count[40] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7418 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7419 "SQLqry31-40.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_40.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[40] = 0;
          SQLcursor_count[40] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[40];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_40.sqld; ++i)
           {
             if (*out_desc_40.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_40.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_40.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_40.sqld; ++x)
                       free (out_desc_40.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_40.sqld; ++x)
                       free (out_desc_40.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7460 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7461 "SQLqry31-40.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_40.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[40] = 0;
	             SQLcursor_count[40] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_40.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_40.sqlvar[i].sqllen, 
                  out_desc_40.sqlvar[i].sqllen, out_desc_40.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_40.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_40.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_40.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_40.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_40.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_40.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_40.sqld; ++x)
                    free (out_desc_40.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_40.sqld; ++x)
                    free (out_desc_40.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7529 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7530 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_40.sqlvar);
 	          SQLcursor[40] = 0;
  	          SQLcursor_count[40] = 0;
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
                  for (x = 0; x < out_desc_40.sqld; ++x)
                    free (out_desc_40.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_40.sqld; ++x)
                    free (out_desc_40.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7553 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7554 "SQLqry31-40.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_40.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[40] = 0;
	          SQLcursor_count[40] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_40.sqld; ++x)
               free (out_desc_40.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_40.sqld; ++x)
               free (out_desc_40.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7576 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7577 "SQLqry31-40.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_40.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[40] = 0;
              SQLcursor_count[40] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id9,0,&out_desc_40,0,7);
}

#line 7590 "SQLqry31-40.rc"

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
                if( SQLcursor[40] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_40.sqld; ++x)
               free (out_desc_40.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_40.sqld; ++x)
               free (out_desc_40.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 7618 "SQLqry31-40.rc"

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7619 "SQLqry31-40.rc"

             free (str);

             free (out_desc_40.sqlvar);
             SQLcursor[40] = 0;
             SQLcursor_count[40] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[40];
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

#line 7641 "SQLqry31-40.rc"

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

	  
          for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_40.sqld; ++x)
            free (out_desc_40.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7667 "SQLqry31-40.rc"

          free (str);

          free (out_desc_40.sqlvar);
          SQLcursor[40] = 0;
          SQLcursor_count[40] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_40.sqld; ++i)
        {
          free (out_desc_40.sqlvar [i].sqldata);
          free (out_desc_40.sqlvar [i].sqlind);
        }

       free (out_desc_40.sqlvar);

{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 7686 "SQLqry31-40.rc"

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
          SQLcursor[40] = 0;
	  SQLcursor_count[40] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[40] = 0;
       SQLcursor_count[40] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

