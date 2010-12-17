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

#line 1 "SQLqry2-10.rc"
#include "machine.h"
#include "SQL.h"

 extern struct SQLglobal_st SQLglobal ;

 extern long SQLquery_count;
 extern int  SQLcursor[41];
 extern long SQLcursor_count[41];


#line 10 "SQLqry2-10.rc"

sqlda out_desc_2;

#line 11 "SQLqry2-10.rc"

sqlda out_desc_3;

#line 12 "SQLqry2-10.rc"

sqlda out_desc_4;

#line 13 "SQLqry2-10.rc"

sqlda out_desc_5;

#line 14 "SQLqry2-10.rc"

sqlda out_desc_6;

#line 15 "SQLqry2-10.rc"

sqlda out_desc_7;

#line 16 "SQLqry2-10.rc"

sqlda out_desc_8;

#line 17 "SQLqry2-10.rc"

sqlda out_desc_9;

#line 18 "SQLqry2-10.rc"

sqlda out_desc_10;

#line 20 "SQLqry2-10.rc"


 char   *malloc (), *calloc ();

/*  This query routine was developed to be used with large query buffers
 *  where only portions of the data are to be returned. Cursor 2 is used
 *  for display items (full listing).
 */

 long  SQLquery_cursor2 (sql_str2, list, size, rows)

#line 30 "SQLqry2-10.rc"

char * sql_str2;

#line 32 "SQLqry2-10.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor2" ;

#line 41 "SQLqry2-10.rc"

long status;

#line 42 "SQLqry2-10.rc"

long i;

#line 43 "SQLqry2-10.rc"

long x;

#line 44 "SQLqry2-10.rc"

long NEW_LIST;

#line 45 "SQLqry2-10.rc"

long fetch_count;

#line 46 "SQLqry2-10.rc"

char data_type[30];

#line 47 "SQLqry2-10.rc"

char data[30];

#line 48 "SQLqry2-10.rc"

char * str;

#line 49 "SQLqry2-10.rc"

char * data1;

#line 50 "SQLqry2-10.rc"

char * * format;

#line 51 "SQLqry2-10.rc"

datetime * ptr;

#line 52 "SQLqry2-10.rc"

char column_name[50];

#line 54 "SQLqry2-10.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str2, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{
    if( SQLcursor[2] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[2] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt2" ));
{RISint_prepare(&RIScpp_stmt_id0,sql_str2,1,0);
}

#line 73 "SQLqry2-10.rc"

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

#line 91 "SQLqry2-10.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_2.sqld = 0;
       out_desc_2.sqln = 0;
       out_desc_2.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id0,&out_desc_2,1);
}

#line 106 "SQLqry2-10.rc"

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

#line 124 "SQLqry2-10.rc"

           return (status);
        }
    } /* if( !SQLcursor[2] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 135 "SQLqry2-10.rc"

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

#line 148 "SQLqry2-10.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[2] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_2" ));
        out_desc_2.sqlvar = (sqlvar *)calloc(out_desc_2.sqld, sizeof (sqlvar));
        if (! out_desc_2.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 166 "SQLqry2-10.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_2.sqln = out_desc_2.sqld;

{RISint_describe(RIScpp_stmt_id0,&out_desc_2,1);
}

#line 175 "SQLqry2-10.rc"

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

#line 194 "SQLqry2-10.rc"

        free (out_desc_2.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_2.sqld; ++i)
        {
          out_desc_2.sqlvar [i].sqldata =
                 calloc (1, out_desc_2.sqlvar [i].sqllen);
          if (! out_desc_2.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_2.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_2.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 208 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_2.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_2.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_2.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_2.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_2.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 223 "SQLqry2-10.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_2.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_2.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_2.sqld; ++x)
                free (out_desc_2.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_2.sqld; ++x)
                free (out_desc_2.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 245 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_2.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[2] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_2.sqld ));
       for (i = 0; i < out_desc_2.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_2.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_2.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_2.sqld; ++x)
                   free (out_desc_2.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_2.sqld; ++x)
                   free (out_desc_2.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 303 "SQLqry2-10.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_2.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_2.sqlvar [i].sqlname.sqlnamec,
		       out_desc_2.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_2.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_2.sqld; ++x)
                   free (out_desc_2.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_2.sqld; ++x)
                   free (out_desc_2.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 326 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_2.sqlvar);
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

                 for (x = 0; x < out_desc_2.sqld; ++x)
                   free (out_desc_2.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_2.sqld; ++x)
                   free (out_desc_2.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 346 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_2.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 _SQLdebug ((fname, "Buffer format <%s>  Data type <%s>\n", 
				format [i],  data_type ));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[2] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 362 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 387 "SQLqry2-10.rc"

          free (out_desc_2.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
}

#line 392 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 418 "SQLqry2-10.rc"

          free (out_desc_2.sqlvar);
          return (status);
        }
    SQLcursor[2] = 1;

    } /* end if( !SQLcursor[2] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[2] != 0 )
    {
        for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 440 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 441 "SQLqry2-10.rc"


        free (out_desc_2.sqlvar); 
    }
    SQLcursor[2] = 0;
    SQLcursor_count[2] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}
{RISint_fetch(RIScpp_stmt_id0,0,&out_desc_2,0,7);
}

#line 452 "SQLqry2-10.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs2 (First time)" ));
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
	     if( (SQLcursor[2]) && ( SQLcursor_count[2] > 0 ) )
		status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 480 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 481 "SQLqry2-10.rc"


          free (out_desc_2.sqlvar); 
          SQLcursor[2] = 0;
          SQLcursor_count[2] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 499 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 500 "SQLqry2-10.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_2.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[2] = 0;
          SQLcursor_count[2] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[2];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_2.sqld; ++i)
           {
             if (*out_desc_2.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_2.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_2.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_2.sqld; ++x)
                       free (out_desc_2.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_2.sqld; ++x)
                       free (out_desc_2.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 541 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 542 "SQLqry2-10.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_2.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[2] = 0;
	             SQLcursor_count[2] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_2.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_2.sqlvar[i].sqllen, 
                  out_desc_2.sqlvar[i].sqllen, out_desc_2.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_2.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_2.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_2.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_2.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_2.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
 	          ptr  = (datetime *) out_desc_2.sqlvar [i].sqldata ;
	
	          status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	          if (status != RIS_SUCCESS)
                  {
                     for (x = 0; x < out_desc_2.sqld; ++x)
                       free (out_desc_2.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_2.sqld; ++x)
                       free (out_desc_2.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 610 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 611 "SQLqry2-10.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_2.sqlvar);
   	             SQLcursor[2] = 0;
     	             SQLcursor_count[2] = 0;
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
                  for (x = 0; x < out_desc_2.sqld; ++x)
                    free (out_desc_2.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_2.sqld; ++x)
                    free (out_desc_2.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 634 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 635 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_2.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[2] = 0;
	          SQLcursor_count[2] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_2.sqld; ++x)
               free (out_desc_2.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_2.sqld; ++x)
               free (out_desc_2.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 657 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 658 "SQLqry2-10.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_2.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[2] = 0;
              SQLcursor_count[2] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id0,0,&out_desc_2,0,7);
}

#line 671 "SQLqry2-10.rc"

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
                if( SQLcursor[2] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_2.sqld; ++x)
               free (out_desc_2.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_2.sqld; ++x)
               free (out_desc_2.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 699 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 700 "SQLqry2-10.rc"

             free (str);

             free (out_desc_2.sqlvar);
             SQLcursor[2] = 0;
             SQLcursor_count[2] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[2];
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

#line 722 "SQLqry2-10.rc"

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

	  
          for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_2.sqld; ++x)
            free (out_desc_2.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 748 "SQLqry2-10.rc"

          free (str);

          free (out_desc_2.sqlvar);
          SQLcursor[2] = 0;
          SQLcursor_count[2] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_2.sqld; ++i)
        {
          free (out_desc_2.sqlvar [i].sqldata);
          free (out_desc_2.sqlvar [i].sqlind);
        }

       free (out_desc_2.sqlvar);

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 767 "SQLqry2-10.rc"

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
          SQLcursor[2] = 0;
	  SQLcursor_count[2] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[2] = 0;
       SQLcursor_count[2] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor3 (sql_str3, list, size, rows)

#line 799 "SQLqry2-10.rc"

char * sql_str3;

#line 801 "SQLqry2-10.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor3" ;

#line 810 "SQLqry2-10.rc"

long status;

#line 811 "SQLqry2-10.rc"

long i;

#line 812 "SQLqry2-10.rc"

long x;

#line 813 "SQLqry2-10.rc"

long NEW_LIST;

#line 814 "SQLqry2-10.rc"

long fetch_count;

#line 815 "SQLqry2-10.rc"

char data_type[30];

#line 816 "SQLqry2-10.rc"

char data[30];

#line 817 "SQLqry2-10.rc"

char * str;

#line 818 "SQLqry2-10.rc"

char * data1;

#line 819 "SQLqry2-10.rc"

char * * format;

#line 820 "SQLqry2-10.rc"

datetime * ptr;

#line 821 "SQLqry2-10.rc"

char column_name[50];

#line 823 "SQLqry2-10.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str3, size, rows));

if( rows > 0 )
{   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
	
    if( SQLcursor[3] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[3] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt3" ));
{RISint_prepare(&RIScpp_stmt_id1,sql_str3,1,0);
}

#line 843 "SQLqry2-10.rc"

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

#line 861 "SQLqry2-10.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_3.sqld = 0;
       out_desc_3.sqln = 0;
       out_desc_3.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id1,&out_desc_3,1);
}

#line 876 "SQLqry2-10.rc"

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

#line 894 "SQLqry2-10.rc"

           return (status);
        }
    } /* if( !SQLcursor[3] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 905 "SQLqry2-10.rc"

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

#line 918 "SQLqry2-10.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[3] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_3" ));
        out_desc_3.sqlvar = (sqlvar *)calloc(out_desc_3.sqld, sizeof (sqlvar));
        if (! out_desc_3.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 936 "SQLqry2-10.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_3.sqln = out_desc_3.sqld;

{RISint_describe(RIScpp_stmt_id1,&out_desc_3,1);
}

#line 945 "SQLqry2-10.rc"

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

#line 964 "SQLqry2-10.rc"

        free (out_desc_3.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_3.sqld; ++i)
        {
          out_desc_3.sqlvar [i].sqldata =
                 calloc (1, out_desc_3.sqlvar [i].sqllen);
          if (! out_desc_3.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_3.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_3.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 978 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_3.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_3.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_3.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_3.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_3.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 993 "SQLqry2-10.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_3.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_3.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_3.sqld; ++x)
                free (out_desc_3.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_3.sqld; ++x)
                free (out_desc_3.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1015 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_3.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[3] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_3.sqld ));
       for (i = 0; i < out_desc_3.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_3.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_3.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_3.sqld; ++x)
                   free (out_desc_3.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_3.sqld; ++x)
                   free (out_desc_3.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1073 "SQLqry2-10.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_3.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_3.sqlvar [i].sqlname.sqlnamec,
		       out_desc_3.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_3.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_3.sqld; ++x)
                   free (out_desc_3.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_3.sqld; ++x)
                   free (out_desc_3.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1096 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_3.sqlvar);
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

                 for (x = 0; x < out_desc_3.sqld; ++x)
                   free (out_desc_3.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_3.sqld; ++x)
                   free (out_desc_3.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1116 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_3.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[3] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 1130 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1155 "SQLqry2-10.rc"

          free (out_desc_3.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
}

#line 1160 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1186 "SQLqry2-10.rc"

          free (out_desc_3.sqlvar);
          return (status);
        }
    SQLcursor[3] = 1;

    } /* end if( !SQLcursor[3] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[3] != 0 )
    {
        for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqlind);

        _SQLdebug(( fname,   "%s\n",   "Closing Cursor 3" ));

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1210 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1211 "SQLqry2-10.rc"


        free (out_desc_3.sqlvar); 
    }
    SQLcursor[3] = 0;
    SQLcursor_count[3] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id1,0,&out_desc_3,0,7);
}

#line 1223 "SQLqry2-10.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs3 (First time)" ));
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
             if( SQLcursor[3] && ( SQLcursor_count[3] > 0 ) )
                status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqlind);

            _SQLdebug(( fname,   "%s\n",   "Closing Cursor 3" ));

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1253 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1254 "SQLqry2-10.rc"


          free (out_desc_3.sqlvar); 
          SQLcursor[3] = 0;
          SQLcursor_count[3] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqlind);

            _SQLdebug(( fname,   "%s\n",   "Closing Cursor 3" ));

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1274 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1275 "SQLqry2-10.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_3.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[3] = 0;
          SQLcursor_count[3] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[3];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_3.sqld; ++i)
           {
             if (*out_desc_3.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_3.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_3.sqlvar[i].sqllen + 3);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_3.sqld; ++x)
                       free (out_desc_3.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_3.sqld; ++x)
                       free (out_desc_3.sqlvar [x].sqlind);

            _SQLdebug(( fname,   "%s\n",   "Closing Cursor 3" ));

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1318 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1319 "SQLqry2-10.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_3.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[3] = 0;
	             SQLcursor_count[3] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_3.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_3.sqlvar[i].sqllen, 
                  out_desc_3.sqlvar[i].sqllen, out_desc_3.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_3.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_3.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_3.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_3.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_3.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_3.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_3.sqld; ++x)
                    free (out_desc_3.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_3.sqld; ++x)
                    free (out_desc_3.sqlvar [x].sqlind);

            _SQLdebug(( fname,   "%s\n",   "Closing Cursor 3" ));

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1389 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1390 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_3.sqlvar);
 	          SQLcursor[3] = 0;
  	          SQLcursor_count[3] = 0;
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
                  for (x = 0; x < out_desc_3.sqld; ++x)
                    free (out_desc_3.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_3.sqld; ++x)
                    free (out_desc_3.sqlvar [x].sqlind);

	            _SQLdebug(( fname,   "%s\n",   "Closing Cursor 3" ));

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1415 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1416 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_3.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[3] = 0;
	          SQLcursor_count[3] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_3.sqld; ++x)
               free (out_desc_3.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_3.sqld; ++x)
               free (out_desc_3.sqlvar [x].sqlind);
              _SQLdebug(( fname,   "%s\n",   "Closing Cursor 3" ));
{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1438 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1439 "SQLqry2-10.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_3.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[3] = 0;
              SQLcursor_count[3] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id1,0,&out_desc_3,0,7);
}

#line 1452 "SQLqry2-10.rc"

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
                if( SQLcursor[3] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_3.sqld; ++x)
               free (out_desc_3.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_3.sqld; ++x)
               free (out_desc_3.sqlvar [x].sqlind);

             _SQLdebug(( fname,  "%s\n",  "Closing Cursor 3" ));

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1482 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1483 "SQLqry2-10.rc"

             free (str);

             free (out_desc_3.sqlvar);
             SQLcursor[3] = 0;
             SQLcursor_count[3] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[3];
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
       _SQLdebug(( fname, "%s\n", "Closing Cursor 3" ));

{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 1505 "SQLqry2-10.rc"

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

	  
          for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_3.sqld; ++x)
            free (out_desc_3.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1531 "SQLqry2-10.rc"

          free (str);

          free (out_desc_3.sqlvar);
          SQLcursor[3] = 0;
          SQLcursor_count[3] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_3.sqld; ++i)
        {
          free (out_desc_3.sqlvar [i].sqldata);
          free (out_desc_3.sqlvar [i].sqlind);
        }

       free (out_desc_3.sqlvar);

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 1550 "SQLqry2-10.rc"

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
          SQLcursor[3] = 0;
	  SQLcursor_count[3] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[3] = 0;
       SQLcursor_count[3] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor4 (sql_str4, list, size, rows)

#line 1583 "SQLqry2-10.rc"

char * sql_str4;

#line 1585 "SQLqry2-10.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor4" ;

#line 1594 "SQLqry2-10.rc"

long status;

#line 1595 "SQLqry2-10.rc"

long i;

#line 1596 "SQLqry2-10.rc"

long x;

#line 1597 "SQLqry2-10.rc"

long NEW_LIST;

#line 1598 "SQLqry2-10.rc"

long fetch_count;

#line 1599 "SQLqry2-10.rc"

char data_type[30];

#line 1600 "SQLqry2-10.rc"

char data[30];

#line 1601 "SQLqry2-10.rc"

char * str;

#line 1602 "SQLqry2-10.rc"

char * data1;

#line 1603 "SQLqry2-10.rc"

char * * format;

#line 1604 "SQLqry2-10.rc"

datetime * ptr;

#line 1605 "SQLqry2-10.rc"

char column_name[50];

#line 1607 "SQLqry2-10.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str4, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
	
if( rows > 0 )
{
    if( SQLcursor[4] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[4] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt4" ));
{RISint_prepare(&RIScpp_stmt_id2,sql_str4,1,0);
}

#line 1627 "SQLqry2-10.rc"

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

#line 1645 "SQLqry2-10.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_4.sqld = 0;
       out_desc_4.sqln = 0;
       out_desc_4.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id2,&out_desc_4,1);
}

#line 1660 "SQLqry2-10.rc"

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

#line 1678 "SQLqry2-10.rc"

           return (status);
        }
    } /* if( !SQLcursor[4] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1689 "SQLqry2-10.rc"

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

#line 1702 "SQLqry2-10.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[4] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_4" ));
        out_desc_4.sqlvar = (sqlvar *)calloc(out_desc_4.sqld, sizeof (sqlvar));
        if (! out_desc_4.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1720 "SQLqry2-10.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_4.sqln = out_desc_4.sqld;

{RISint_describe(RIScpp_stmt_id2,&out_desc_4,1);
}

#line 1729 "SQLqry2-10.rc"

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

#line 1748 "SQLqry2-10.rc"

        free (out_desc_4.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_4.sqld; ++i)
        {
          out_desc_4.sqlvar [i].sqldata =
                 calloc (1, out_desc_4.sqlvar [i].sqllen);
          if (! out_desc_4.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_4.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_4.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1762 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_4.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_4.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_4.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_4.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_4.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1777 "SQLqry2-10.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_4.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_4.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_4.sqld; ++x)
                free (out_desc_4.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_4.sqld; ++x)
                free (out_desc_4.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1799 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_4.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[4] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_4.sqld ));
       for (i = 0; i < out_desc_4.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_4.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_4.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_4.sqld; ++x)
                   free (out_desc_4.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_4.sqld; ++x)
                   free (out_desc_4.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1857 "SQLqry2-10.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_4.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_4.sqlvar [i].sqlname.sqlnamec,
		       out_desc_4.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_4.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_4.sqld; ++x)
                   free (out_desc_4.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_4.sqld; ++x)
                   free (out_desc_4.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1880 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_4.sqlvar);
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

                 for (x = 0; x < out_desc_4.sqld; ++x)
                   free (out_desc_4.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_4.sqld; ++x)
                   free (out_desc_4.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1900 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_4.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[4] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 1914 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1939 "SQLqry2-10.rc"

          free (out_desc_4.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id2,0,0,7,1,0);
}

#line 1944 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1970 "SQLqry2-10.rc"

          free (out_desc_4.sqlvar);
          return (status);
        }
    SQLcursor[4] = 1;

    } /* end if( !SQLcursor[4] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[4] != 0 )
    {
        for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqlind);
       _SQLdebug(( fname, "%s\n", "Closing Cursor 4" ));
{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 1992 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 1993 "SQLqry2-10.rc"


        free (out_desc_4.sqlvar); 
    }
    SQLcursor[4] = 0;
    SQLcursor_count[4] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id2,0,&out_desc_4,0,7);
}

#line 2005 "SQLqry2-10.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs4 (First time)" ));
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
             if( SQLcursor[4] && ( SQLcursor_count[4] > 0 ))
                status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqlind);
       _SQLdebug(( fname, "%s\n", "Closing Cursor 4" ));
{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2033 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2034 "SQLqry2-10.rc"


          free (out_desc_4.sqlvar); 
          SQLcursor[4] = 0;
          SQLcursor_count[4] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqlind);
       _SQLdebug(( fname, "%s\n", "Closing Cursor 4" ));
{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2052 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2053 "SQLqry2-10.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_4.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[4] = 0;
          SQLcursor_count[4] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[4];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_4.sqld; ++i)
           {
             if (*out_desc_4.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_4.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_4.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_4.sqld; ++x)
                       free (out_desc_4.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_4.sqld; ++x)
                       free (out_desc_4.sqlvar [x].sqlind);
       _SQLdebug(( fname, "%s\n", "Closing Cursor 4" ));
{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2094 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2095 "SQLqry2-10.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_4.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[4] = 0;
	             SQLcursor_count[4] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_4.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_4.sqlvar[i].sqllen, 
                  out_desc_4.sqlvar[i].sqllen, out_desc_4.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_4.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_4.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_4.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_4.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_4.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_4.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_4.sqld; ++x)
                    free (out_desc_4.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_4.sqld; ++x)
                    free (out_desc_4.sqlvar [x].sqlind);
       _SQLdebug(( fname, "%s\n", "Closing Cursor 4" ));
{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2163 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2164 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_4.sqlvar);
 	          SQLcursor[4] = 0;
  	          SQLcursor_count[4] = 0;
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
                  for (x = 0; x < out_desc_4.sqld; ++x)
                    free (out_desc_4.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_4.sqld; ++x)
                    free (out_desc_4.sqlvar [x].sqlind);
       _SQLdebug(( fname, "%s\n", "Closing Cursor 4" ));
{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2187 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2188 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_4.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[4] = 0;
	          SQLcursor_count[4] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_4.sqld; ++x)
               free (out_desc_4.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_4.sqld; ++x)
               free (out_desc_4.sqlvar [x].sqlind);
       _SQLdebug(( fname, "%s\n", "Closing Cursor 4" ));
{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2210 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2211 "SQLqry2-10.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_4.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[4] = 0;
              SQLcursor_count[4] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id2,0,&out_desc_4,0,7);
}

#line 2224 "SQLqry2-10.rc"

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
                if( SQLcursor[4] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_4.sqld; ++x)
               free (out_desc_4.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_4.sqld; ++x)
               free (out_desc_4.sqlvar [x].sqlind);
       _SQLdebug(( fname, "%s\n", "Closing Cursor 4" ));
{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2252 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2253 "SQLqry2-10.rc"

             free (str);

             free (out_desc_4.sqlvar);
             SQLcursor[4] = 0;
             SQLcursor_count[4] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[4];
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
       _SQLdebug(( fname, "%s\n", "Closing Cursor 4" ));

{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 2275 "SQLqry2-10.rc"

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

	  
          for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_4.sqld; ++x)
            free (out_desc_4.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2301 "SQLqry2-10.rc"

          free (str);

          free (out_desc_4.sqlvar);
          SQLcursor[4] = 0;
          SQLcursor_count[4] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_4.sqld; ++i)
        {
          free (out_desc_4.sqlvar [i].sqldata);
          free (out_desc_4.sqlvar [i].sqlind);
        }

       free (out_desc_4.sqlvar);

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 2320 "SQLqry2-10.rc"

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
          SQLcursor[4] = 0;
	  SQLcursor_count[4] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[4] = 0;
       SQLcursor_count[4] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor5 (sql_str5, list, size, rows)

#line 2353 "SQLqry2-10.rc"

char * sql_str5;

#line 2355 "SQLqry2-10.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor5" ;

#line 2364 "SQLqry2-10.rc"

long status;

#line 2365 "SQLqry2-10.rc"

long i;

#line 2366 "SQLqry2-10.rc"

long x;

#line 2367 "SQLqry2-10.rc"

long NEW_LIST;

#line 2368 "SQLqry2-10.rc"

long fetch_count;

#line 2369 "SQLqry2-10.rc"

char data_type[30];

#line 2370 "SQLqry2-10.rc"

char data[30];

#line 2371 "SQLqry2-10.rc"

char * str;

#line 2372 "SQLqry2-10.rc"

char * data1;

#line 2373 "SQLqry2-10.rc"

char * * format;

#line 2374 "SQLqry2-10.rc"

datetime * ptr;

#line 2375 "SQLqry2-10.rc"

char column_name[50];

#line 2377 "SQLqry2-10.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str5, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[5] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[5] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt5" ));
{RISint_prepare(&RIScpp_stmt_id3,sql_str5,1,0);
}

#line 2396 "SQLqry2-10.rc"

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

#line 2414 "SQLqry2-10.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_5.sqld = 0;
       out_desc_5.sqln = 0;
       out_desc_5.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id3,&out_desc_5,1);
}

#line 2429 "SQLqry2-10.rc"

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

#line 2447 "SQLqry2-10.rc"

           return (status);
        }
    } /* if( !SQLcursor[5] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2458 "SQLqry2-10.rc"

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

#line 2471 "SQLqry2-10.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[5] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_5" ));
        out_desc_5.sqlvar = (sqlvar *)calloc(out_desc_5.sqld, sizeof (sqlvar));
        if (! out_desc_5.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2489 "SQLqry2-10.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_5.sqln = out_desc_5.sqld;

{RISint_describe(RIScpp_stmt_id3,&out_desc_5,1);
}

#line 2498 "SQLqry2-10.rc"

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

#line 2517 "SQLqry2-10.rc"

        free (out_desc_5.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_5.sqld; ++i)
        {
          out_desc_5.sqlvar [i].sqldata =
                 calloc (1, out_desc_5.sqlvar [i].sqllen);
          if (! out_desc_5.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_5.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_5.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2531 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_5.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_5.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_5.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_5.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_5.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2546 "SQLqry2-10.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_5.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_5.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_5.sqld; ++x)
                free (out_desc_5.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_5.sqld; ++x)
                free (out_desc_5.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2568 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_5.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[5] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_5.sqld ));
       for (i = 0; i < out_desc_5.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_5.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_5.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_5.sqld; ++x)
                   free (out_desc_5.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_5.sqld; ++x)
                   free (out_desc_5.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2626 "SQLqry2-10.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_5.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_5.sqlvar [i].sqlname.sqlnamec,
		       out_desc_5.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_5.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_5.sqld; ++x)
                   free (out_desc_5.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_5.sqld; ++x)
                   free (out_desc_5.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2649 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_5.sqlvar);
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

                 for (x = 0; x < out_desc_5.sqld; ++x)
                   free (out_desc_5.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_5.sqld; ++x)
                   free (out_desc_5.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2669 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_5.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[5] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 2683 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2708 "SQLqry2-10.rc"

          free (out_desc_5.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id3,0,0,7,1,0);
}

#line 2713 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2739 "SQLqry2-10.rc"

          free (out_desc_5.sqlvar);
          return (status);
        }
    SQLcursor[5] = 1;

    } /* end if( !SQLcursor[5] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[5] != 0 )
    {
        for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2761 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2762 "SQLqry2-10.rc"


        free (out_desc_5.sqlvar); 
    }
    SQLcursor[5] = 0;
    SQLcursor_count[5] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id3,0,&out_desc_5,0,7);
}

#line 2774 "SQLqry2-10.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs5 (First time)" ));
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
             if( SQLcursor[5] && ( SQLcursor_count[5] > 0 ) )
                status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2802 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2803 "SQLqry2-10.rc"


          free (out_desc_5.sqlvar); 
          SQLcursor[5] = 0;
          SQLcursor_count[5] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2821 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2822 "SQLqry2-10.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_5.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[5] = 0;
          SQLcursor_count[5] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[5];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_5.sqld; ++i)
           {
             if (*out_desc_5.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_5.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_5.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_5.sqld; ++x)
                       free (out_desc_5.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_5.sqld; ++x)
                       free (out_desc_5.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2863 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2864 "SQLqry2-10.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_5.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[5] = 0;
	             SQLcursor_count[5] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_5.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_5.sqlvar[i].sqllen, 
                  out_desc_5.sqlvar[i].sqllen, out_desc_5.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_5.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_5.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_5.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_5.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_5.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_5.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_5.sqld; ++x)
                    free (out_desc_5.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_5.sqld; ++x)
                    free (out_desc_5.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2932 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2933 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_5.sqlvar);
 	          SQLcursor[5] = 0;
  	          SQLcursor_count[5] = 0;
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
                  for (x = 0; x < out_desc_5.sqld; ++x)
                    free (out_desc_5.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_5.sqld; ++x)
                    free (out_desc_5.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2956 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2957 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_5.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[5] = 0;
	          SQLcursor_count[5] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_5.sqld; ++x)
               free (out_desc_5.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_5.sqld; ++x)
               free (out_desc_5.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 2979 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 2980 "SQLqry2-10.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_5.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[5] = 0;
              SQLcursor_count[5] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id3,0,&out_desc_5,0,7);
}

#line 2993 "SQLqry2-10.rc"

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
                if( SQLcursor[5] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_5.sqld; ++x)
               free (out_desc_5.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_5.sqld; ++x)
               free (out_desc_5.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 3021 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3022 "SQLqry2-10.rc"

             free (str);

             free (out_desc_5.sqlvar);
             SQLcursor[5] = 0;
             SQLcursor_count[5] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[5];
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

#line 3044 "SQLqry2-10.rc"

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

	  
          for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_5.sqld; ++x)
            free (out_desc_5.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3070 "SQLqry2-10.rc"

          free (str);

          free (out_desc_5.sqlvar);
          SQLcursor[5] = 0;
          SQLcursor_count[5] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_5.sqld; ++i)
        {
          free (out_desc_5.sqlvar [i].sqldata);
          free (out_desc_5.sqlvar [i].sqlind);
        }

       free (out_desc_5.sqlvar);

{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 3089 "SQLqry2-10.rc"

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
          SQLcursor[5] = 0;
	  SQLcursor_count[5] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[5] = 0;
       SQLcursor_count[5] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor6 (sql_str6, list, size, rows)

#line 3121 "SQLqry2-10.rc"

char * sql_str6;

#line 3123 "SQLqry2-10.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor6" ;

#line 3132 "SQLqry2-10.rc"

long status;

#line 3133 "SQLqry2-10.rc"

long i;

#line 3134 "SQLqry2-10.rc"

long x;

#line 3135 "SQLqry2-10.rc"

long NEW_LIST;

#line 3136 "SQLqry2-10.rc"

long fetch_count;

#line 3137 "SQLqry2-10.rc"

char data_type[30];

#line 3138 "SQLqry2-10.rc"

char data[30];

#line 3139 "SQLqry2-10.rc"

char * str;

#line 3140 "SQLqry2-10.rc"

char * data1;

#line 3141 "SQLqry2-10.rc"

char * * format;

#line 3142 "SQLqry2-10.rc"

datetime * ptr;

#line 3143 "SQLqry2-10.rc"

char column_name[50];

#line 3145 "SQLqry2-10.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str6, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[6] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[6] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt6" ));
{RISint_prepare(&RIScpp_stmt_id4,sql_str6,1,0);
}

#line 3164 "SQLqry2-10.rc"

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

#line 3182 "SQLqry2-10.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_6.sqld = 0;
       out_desc_6.sqln = 0;
       out_desc_6.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id4,&out_desc_6,1);
}

#line 3197 "SQLqry2-10.rc"

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

#line 3215 "SQLqry2-10.rc"

           return (status);
        }
    } /* if( !SQLcursor[6] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3226 "SQLqry2-10.rc"

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

#line 3239 "SQLqry2-10.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[6] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_6" ));
        out_desc_6.sqlvar = (sqlvar *)calloc(out_desc_6.sqld, sizeof (sqlvar));
        if (! out_desc_6.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3257 "SQLqry2-10.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_6.sqln = out_desc_6.sqld;

{RISint_describe(RIScpp_stmt_id4,&out_desc_6,1);
}

#line 3266 "SQLqry2-10.rc"

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

#line 3285 "SQLqry2-10.rc"

        free (out_desc_6.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_6.sqld; ++i)
        {
          out_desc_6.sqlvar [i].sqldata =
                 calloc (1, out_desc_6.sqlvar [i].sqllen);
          if (! out_desc_6.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_6.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_6.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3299 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_6.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_6.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_6.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_6.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_6.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3314 "SQLqry2-10.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_6.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_6.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_6.sqld; ++x)
                free (out_desc_6.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_6.sqld; ++x)
                free (out_desc_6.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3336 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_6.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[6] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_6.sqld ));
       for (i = 0; i < out_desc_6.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_6.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_6.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_6.sqld; ++x)
                   free (out_desc_6.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_6.sqld; ++x)
                   free (out_desc_6.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3394 "SQLqry2-10.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_6.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_6.sqlvar [i].sqlname.sqlnamec,
		       out_desc_6.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_6.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_6.sqld; ++x)
                   free (out_desc_6.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_6.sqld; ++x)
                   free (out_desc_6.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3417 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_6.sqlvar);
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

                 for (x = 0; x < out_desc_6.sqld; ++x)
                   free (out_desc_6.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_6.sqld; ++x)
                   free (out_desc_6.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3437 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_6.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[6] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 3451 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3476 "SQLqry2-10.rc"

          free (out_desc_6.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id4,0,0,7,1,0);
}

#line 3481 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3507 "SQLqry2-10.rc"

          free (out_desc_6.sqlvar);
          return (status);
        }
    SQLcursor[6] = 1;

    } /* end if( !SQLcursor[6] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[6] != 0 )
    {
        for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3529 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3530 "SQLqry2-10.rc"


        free (out_desc_6.sqlvar); 
    }     
    SQLcursor[6] = 0;
    SQLcursor_count[6] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id4,0,&out_desc_6,0,7);
}

#line 3542 "SQLqry2-10.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs6 (First time)" ));
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
             if( SQLcursor[6] && ( SQLcursor_count[6] > 0 ) )
                status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3570 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3571 "SQLqry2-10.rc"


          free (out_desc_6.sqlvar); 
          SQLcursor[6] = 0;
          SQLcursor_count[6] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3589 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3590 "SQLqry2-10.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_6.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[6] = 0;
          SQLcursor_count[6] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[6];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_6.sqld; ++i)
           {
             if (*out_desc_6.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_6.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_6.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_6.sqld; ++x)
                       free (out_desc_6.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_6.sqld; ++x)
                       free (out_desc_6.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3631 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3632 "SQLqry2-10.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_6.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[6] = 0;
	             SQLcursor_count[6] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_6.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_6.sqlvar[i].sqllen, 
                  out_desc_6.sqlvar[i].sqllen, out_desc_6.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_6.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_6.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_6.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_6.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_6.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_6.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_6.sqld; ++x)
                    free (out_desc_6.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_6.sqld; ++x)
                    free (out_desc_6.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3700 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3701 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_6.sqlvar);
 	          SQLcursor[6] = 0;
  	          SQLcursor_count[6] = 0;
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
                  for (x = 0; x < out_desc_6.sqld; ++x)
                    free (out_desc_6.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_6.sqld; ++x)
                    free (out_desc_6.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3724 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3725 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_6.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[6] = 0;
	          SQLcursor_count[6] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_6.sqld; ++x)
               free (out_desc_6.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_6.sqld; ++x)
               free (out_desc_6.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3747 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3748 "SQLqry2-10.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_6.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[6] = 0;
              SQLcursor_count[6] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id4,0,&out_desc_6,0,7);
}

#line 3761 "SQLqry2-10.rc"

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
                if( SQLcursor[6] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_6.sqld; ++x)
               free (out_desc_6.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_6.sqld; ++x)
               free (out_desc_6.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 3789 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3790 "SQLqry2-10.rc"

             free (str);

             free (out_desc_6.sqlvar);
             SQLcursor[6] = 0;
             SQLcursor_count[6] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[6];
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

#line 3812 "SQLqry2-10.rc"

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

	  
          for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_6.sqld; ++x)
            free (out_desc_6.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3838 "SQLqry2-10.rc"

          free (str);

          free (out_desc_6.sqlvar);
          SQLcursor[6] = 0;
          SQLcursor_count[6] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_6.sqld; ++i)
        {
          free (out_desc_6.sqlvar [i].sqldata);
          free (out_desc_6.sqlvar [i].sqlind);
        }

       free (out_desc_6.sqlvar);

{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 3857 "SQLqry2-10.rc"

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
          SQLcursor[6] = 0;
	  SQLcursor_count[6] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[6] = 0;
       SQLcursor_count[6] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor7 (sql_str7, list, size, rows)

#line 3889 "SQLqry2-10.rc"

char * sql_str7;

#line 3891 "SQLqry2-10.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor7" ;

#line 3900 "SQLqry2-10.rc"

long status;

#line 3901 "SQLqry2-10.rc"

long i;

#line 3902 "SQLqry2-10.rc"

long x;

#line 3903 "SQLqry2-10.rc"

long NEW_LIST;

#line 3904 "SQLqry2-10.rc"

long fetch_count;

#line 3905 "SQLqry2-10.rc"

char data_type[30];

#line 3906 "SQLqry2-10.rc"

char data[30];

#line 3907 "SQLqry2-10.rc"

char * str;

#line 3908 "SQLqry2-10.rc"

char * data1;

#line 3909 "SQLqry2-10.rc"

char * * format;

#line 3910 "SQLqry2-10.rc"

datetime * ptr;

#line 3911 "SQLqry2-10.rc"

char column_name[50];

#line 3913 "SQLqry2-10.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str7, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[7] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[7] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt7" ));
{RISint_prepare(&RIScpp_stmt_id5,sql_str7,1,0);
}

#line 3932 "SQLqry2-10.rc"

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

#line 3950 "SQLqry2-10.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_7.sqld = 0;
       out_desc_7.sqln = 0;
       out_desc_7.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id5,&out_desc_7,1);
}

#line 3965 "SQLqry2-10.rc"

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

#line 3983 "SQLqry2-10.rc"

           return (status);
        }
    } /* if( !SQLcursor[7] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 3994 "SQLqry2-10.rc"

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

#line 4007 "SQLqry2-10.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[7] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_7" ));
        out_desc_7.sqlvar = (sqlvar *)calloc(out_desc_7.sqld, sizeof (sqlvar));
        if (! out_desc_7.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4025 "SQLqry2-10.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_7.sqln = out_desc_7.sqld;

{RISint_describe(RIScpp_stmt_id5,&out_desc_7,1);
}

#line 4034 "SQLqry2-10.rc"

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

#line 4053 "SQLqry2-10.rc"

        free (out_desc_7.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_7.sqld; ++i)
        {
          out_desc_7.sqlvar [i].sqldata =
                 calloc (1, out_desc_7.sqlvar [i].sqllen);
          if (! out_desc_7.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_7.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_7.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4067 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_7.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_7.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_7.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_7.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_7.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4082 "SQLqry2-10.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_7.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_7.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_7.sqld; ++x)
                free (out_desc_7.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_7.sqld; ++x)
                free (out_desc_7.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4104 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_7.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[7] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_7.sqld ));
       for (i = 0; i < out_desc_7.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_7.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_7.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_7.sqld; ++x)
                   free (out_desc_7.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_7.sqld; ++x)
                   free (out_desc_7.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4162 "SQLqry2-10.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_7.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_7.sqlvar [i].sqlname.sqlnamec,
		       out_desc_7.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_7.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_7.sqld; ++x)
                   free (out_desc_7.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_7.sqld; ++x)
                   free (out_desc_7.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4185 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_7.sqlvar);
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

                 for (x = 0; x < out_desc_7.sqld; ++x)
                   free (out_desc_7.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_7.sqld; ++x)
                   free (out_desc_7.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4205 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_7.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[7] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 4219 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4244 "SQLqry2-10.rc"

          free (out_desc_7.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id5,0,0,7,1,0);
}

#line 4249 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4275 "SQLqry2-10.rc"

          free (out_desc_7.sqlvar);
          return (status);
        }
    SQLcursor[7] = 1;

    } /* end if( !SQLcursor[7] ) */
}

/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[7] != 0 )
    {
        for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4298 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4299 "SQLqry2-10.rc"


        free (out_desc_7.sqlvar); 
    }
    SQLcursor[7] = 0;
    SQLcursor_count[7] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id5,0,&out_desc_7,0,7);
}

#line 4311 "SQLqry2-10.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs7 (First time)" ));
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
             if( SQLcursor[7] && ( SQLcursor_count[7] > 0 ))
                status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4339 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4340 "SQLqry2-10.rc"


          free (out_desc_7.sqlvar); 
          SQLcursor[7] = 0;
          SQLcursor_count[7] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4358 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4359 "SQLqry2-10.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_7.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[7] = 0;
          SQLcursor_count[7] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[7];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_7.sqld; ++i)
           {
             if (*out_desc_7.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_7.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_7.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_7.sqld; ++x)
                       free (out_desc_7.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_7.sqld; ++x)
                       free (out_desc_7.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4400 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4401 "SQLqry2-10.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_7.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[7] = 0;
	             SQLcursor_count[7] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_7.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_7.sqlvar[i].sqllen, 
                  out_desc_7.sqlvar[i].sqllen, out_desc_7.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_7.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_7.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_7.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_7.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_7.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_7.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_7.sqld; ++x)
                    free (out_desc_7.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_7.sqld; ++x)
                    free (out_desc_7.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4469 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4470 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_7.sqlvar);
 	          SQLcursor[7] = 0;
  	          SQLcursor_count[7] = 0;
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
                  for (x = 0; x < out_desc_7.sqld; ++x)
                    free (out_desc_7.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_7.sqld; ++x)
                    free (out_desc_7.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4493 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4494 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_7.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[7] = 0;
	          SQLcursor_count[7] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_7.sqld; ++x)
               free (out_desc_7.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_7.sqld; ++x)
               free (out_desc_7.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4516 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4517 "SQLqry2-10.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_7.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[7] = 0;
              SQLcursor_count[7] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id5,0,&out_desc_7,0,7);
}

#line 4530 "SQLqry2-10.rc"

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
                if( SQLcursor[7] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_7.sqld; ++x)
               free (out_desc_7.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_7.sqld; ++x)
               free (out_desc_7.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 4558 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4559 "SQLqry2-10.rc"

             free (str);

             free (out_desc_7.sqlvar);
             SQLcursor[7] = 0;
             SQLcursor_count[7] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[7];
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

#line 4581 "SQLqry2-10.rc"

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

	  
          for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_7.sqld; ++x)
            free (out_desc_7.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4607 "SQLqry2-10.rc"

          free (str);

          free (out_desc_7.sqlvar);
          SQLcursor[7] = 0;
          SQLcursor_count[7] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_7.sqld; ++i)
        {
          free (out_desc_7.sqlvar [i].sqldata);
          free (out_desc_7.sqlvar [i].sqlind);
        }

       free (out_desc_7.sqlvar);

{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 4626 "SQLqry2-10.rc"

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
          SQLcursor[7] = 0;
	  SQLcursor_count[7] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[7] = 0;
       SQLcursor_count[7] = 0;
       return (SQL_I_NO_MORE_DATA);
    }


 long  SQLquery_cursor8 (sql_str8, list, size, rows)

#line 4659 "SQLqry2-10.rc"

char * sql_str8;

#line 4661 "SQLqry2-10.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor8" ;

#line 4670 "SQLqry2-10.rc"

long status;

#line 4671 "SQLqry2-10.rc"

long i;

#line 4672 "SQLqry2-10.rc"

long x;

#line 4673 "SQLqry2-10.rc"

long NEW_LIST;

#line 4674 "SQLqry2-10.rc"

long fetch_count;

#line 4675 "SQLqry2-10.rc"

char data_type[30];

#line 4676 "SQLqry2-10.rc"

char data[30];

#line 4677 "SQLqry2-10.rc"

char * str;

#line 4678 "SQLqry2-10.rc"

char * data1;

#line 4679 "SQLqry2-10.rc"

char * * format;

#line 4680 "SQLqry2-10.rc"

datetime * ptr;

#line 4681 "SQLqry2-10.rc"

char column_name[50];

#line 4683 "SQLqry2-10.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str8, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[8] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[8] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt8" ));
{RISint_prepare(&RIScpp_stmt_id6,sql_str8,1,0);
}

#line 4702 "SQLqry2-10.rc"

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

#line 4720 "SQLqry2-10.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_8.sqld = 0;
       out_desc_8.sqln = 0;
       out_desc_8.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id6,&out_desc_8,1);
}

#line 4735 "SQLqry2-10.rc"

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

#line 4753 "SQLqry2-10.rc"

           return (status);
        }
    } /* if( !SQLcursor[8] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4764 "SQLqry2-10.rc"

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

#line 4777 "SQLqry2-10.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[8] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_8" ));
        out_desc_8.sqlvar = (sqlvar *)calloc(out_desc_8.sqld, sizeof (sqlvar));
        if (! out_desc_8.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4795 "SQLqry2-10.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_8.sqln = out_desc_8.sqld;

{RISint_describe(RIScpp_stmt_id6,&out_desc_8,1);
}

#line 4804 "SQLqry2-10.rc"

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

#line 4823 "SQLqry2-10.rc"

        free (out_desc_8.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_8.sqld; ++i)
        {
          out_desc_8.sqlvar [i].sqldata =
                 calloc (1, out_desc_8.sqlvar [i].sqllen);
          if (! out_desc_8.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_8.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_8.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4837 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_8.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_8.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_8.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_8.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_8.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4852 "SQLqry2-10.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_8.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_8.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_8.sqld; ++x)
                free (out_desc_8.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_8.sqld; ++x)
                free (out_desc_8.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4874 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_8.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[8] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_8.sqld ));
       for (i = 0; i < out_desc_8.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_8.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_8.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_8.sqld; ++x)
                   free (out_desc_8.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_8.sqld; ++x)
                   free (out_desc_8.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4932 "SQLqry2-10.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_8.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_8.sqlvar [i].sqlname.sqlnamec,
		       out_desc_8.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_8.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_8.sqld; ++x)
                   free (out_desc_8.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_8.sqld; ++x)
                   free (out_desc_8.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4955 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_8.sqlvar);
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

                 for (x = 0; x < out_desc_8.sqld; ++x)
                   free (out_desc_8.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_8.sqld; ++x)
                   free (out_desc_8.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 4975 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_8.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[8] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 4989 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5014 "SQLqry2-10.rc"

          free (out_desc_8.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id6,0,0,7,1,0);
}

#line 5019 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5045 "SQLqry2-10.rc"

          free (out_desc_8.sqlvar);
          return (status);
        }
    SQLcursor[8] = 1;

    } /* end if( !SQLcursor[8] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[8] != 0 )
    {
        for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5067 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5068 "SQLqry2-10.rc"


        free (out_desc_8.sqlvar); 
    }
    SQLcursor[8] = 0;
    SQLcursor_count[8] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id6,0,&out_desc_8,0,7);
}

#line 5080 "SQLqry2-10.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs8 (First time)" ));
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
             if( SQLcursor[8] && ( SQLcursor_count[8] > 0 ) )
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5108 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5109 "SQLqry2-10.rc"


          free (out_desc_8.sqlvar); 
          SQLcursor[8] = 0;
          SQLcursor_count[8] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5127 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5128 "SQLqry2-10.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_8.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[8] = 0;
          SQLcursor_count[8] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[8];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_8.sqld; ++i)
           {
             if (*out_desc_8.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_8.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_8.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_8.sqld; ++x)
                       free (out_desc_8.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_8.sqld; ++x)
                       free (out_desc_8.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5169 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5170 "SQLqry2-10.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_8.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[8] = 0;
	             SQLcursor_count[8] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_8.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_8.sqlvar[i].sqllen, 
                  out_desc_8.sqlvar[i].sqllen, out_desc_8.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_8.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_8.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_8.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_8.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_8.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_8.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_8.sqld; ++x)
                    free (out_desc_8.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_8.sqld; ++x)
                    free (out_desc_8.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5238 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5239 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_8.sqlvar);
 	          SQLcursor[8] = 0;
  	          SQLcursor_count[8] = 0;
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
                  for (x = 0; x < out_desc_8.sqld; ++x)
                    free (out_desc_8.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_8.sqld; ++x)
                    free (out_desc_8.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5262 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5263 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_8.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[8] = 0;
	          SQLcursor_count[8] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_8.sqld; ++x)
               free (out_desc_8.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_8.sqld; ++x)
               free (out_desc_8.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5285 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5286 "SQLqry2-10.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_8.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[8] = 0;
              SQLcursor_count[8] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id6,0,&out_desc_8,0,7);
}

#line 5299 "SQLqry2-10.rc"

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
                if( SQLcursor[8] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_8.sqld; ++x)
               free (out_desc_8.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_8.sqld; ++x)
               free (out_desc_8.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 5327 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5328 "SQLqry2-10.rc"

             free (str);

             free (out_desc_8.sqlvar);
             SQLcursor[8] = 0;
             SQLcursor_count[8] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[8];
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

#line 5350 "SQLqry2-10.rc"

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

	  
          for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_8.sqld; ++x)
            free (out_desc_8.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5376 "SQLqry2-10.rc"

          free (str);

          free (out_desc_8.sqlvar);
          SQLcursor[8] = 0;
          SQLcursor_count[8] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_8.sqld; ++i)
        {
          free (out_desc_8.sqlvar [i].sqldata);
          free (out_desc_8.sqlvar [i].sqlind);
        }

       free (out_desc_8.sqlvar);

{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 5395 "SQLqry2-10.rc"

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
          SQLcursor[8] = 0;
	  SQLcursor_count[8] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[8] = 0;
       SQLcursor_count[8] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor9 (sql_str9, list, size, rows)

#line 5427 "SQLqry2-10.rc"

char * sql_str9;

#line 5429 "SQLqry2-10.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor9" ;

#line 5438 "SQLqry2-10.rc"

long status;

#line 5439 "SQLqry2-10.rc"

long i;

#line 5440 "SQLqry2-10.rc"

long x;

#line 5441 "SQLqry2-10.rc"

long NEW_LIST;

#line 5442 "SQLqry2-10.rc"

long fetch_count;

#line 5443 "SQLqry2-10.rc"

char data_type[30];

#line 5444 "SQLqry2-10.rc"

char data[30];

#line 5445 "SQLqry2-10.rc"

char * str;

#line 5446 "SQLqry2-10.rc"

char * data1;

#line 5447 "SQLqry2-10.rc"

char * * format;

#line 5448 "SQLqry2-10.rc"

datetime * ptr;

#line 5449 "SQLqry2-10.rc"

char column_name[50];

#line 5451 "SQLqry2-10.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str9, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
if( rows > 0 )
{	
    if( SQLcursor[9] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[9] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt9" ));
{RISint_prepare(&RIScpp_stmt_id7,sql_str9,1,0);
}

#line 5470 "SQLqry2-10.rc"

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

#line 5488 "SQLqry2-10.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_9.sqld = 0;
       out_desc_9.sqln = 0;
       out_desc_9.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id7,&out_desc_9,1);
}

#line 5503 "SQLqry2-10.rc"

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

#line 5521 "SQLqry2-10.rc"

           return (status);
        }
    } /* if( !SQLcursor[9] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5532 "SQLqry2-10.rc"

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

#line 5545 "SQLqry2-10.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[9] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_9" ));
        out_desc_9.sqlvar = (sqlvar *)calloc(out_desc_9.sqld, sizeof (sqlvar));
        if (! out_desc_9.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5563 "SQLqry2-10.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_9.sqln = out_desc_9.sqld;

{RISint_describe(RIScpp_stmt_id7,&out_desc_9,1);
}

#line 5572 "SQLqry2-10.rc"

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

#line 5591 "SQLqry2-10.rc"

        free (out_desc_9.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_9.sqld; ++i)
        {
          out_desc_9.sqlvar [i].sqldata =
                 calloc (1, out_desc_9.sqlvar [i].sqllen);
          if (! out_desc_9.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_9.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_9.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5605 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_9.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_9.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_9.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_9.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_9.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5620 "SQLqry2-10.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_9.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_9.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_9.sqld; ++x)
                free (out_desc_9.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_9.sqld; ++x)
                free (out_desc_9.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5642 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_9.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[9] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_9.sqld ));
       for (i = 0; i < out_desc_9.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_9.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_9.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_9.sqld; ++x)
                   free (out_desc_9.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_9.sqld; ++x)
                   free (out_desc_9.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5700 "SQLqry2-10.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_9.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_9.sqlvar [i].sqlname.sqlnamec,
		       out_desc_9.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_9.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_9.sqld; ++x)
                   free (out_desc_9.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_9.sqld; ++x)
                   free (out_desc_9.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5723 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_9.sqlvar);
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

                 for (x = 0; x < out_desc_9.sqld; ++x)
                   free (out_desc_9.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_9.sqld; ++x)
                   free (out_desc_9.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5743 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_9.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[9] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 5757 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5782 "SQLqry2-10.rc"

          free (out_desc_9.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id7,0,0,7,1,0);
}

#line 5787 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5813 "SQLqry2-10.rc"

          free (out_desc_9.sqlvar);
          return (status);
        }
    SQLcursor[9] = 1;

    } /* end if( !SQLcursor[9] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[9] != 0 )
    {
        for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5835 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5836 "SQLqry2-10.rc"


        free (out_desc_9.sqlvar); 
    }
    SQLcursor[9] = 0;
    SQLcursor_count[9] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id7,0,&out_desc_9,0,7);
}

#line 5848 "SQLqry2-10.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs9 (First time)" ));
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
             if( SQLcursor[9] && ( SQLcursor_count[9] > 0 ) )
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5876 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5877 "SQLqry2-10.rc"


          free (out_desc_9.sqlvar); 
          SQLcursor[9] = 0;
          SQLcursor_count[9] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5895 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5896 "SQLqry2-10.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_9.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[9] = 0;
          SQLcursor_count[9] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[9];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_9.sqld; ++i)
           {
             if (*out_desc_9.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_9.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_9.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_9.sqld; ++x)
                       free (out_desc_9.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_9.sqld; ++x)
                       free (out_desc_9.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 5937 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 5938 "SQLqry2-10.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_9.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[9] = 0;
	             SQLcursor_count[9] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_9.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_9.sqlvar[i].sqllen, 
                  out_desc_9.sqlvar[i].sqllen, out_desc_9.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_9.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_9.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_9.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_9.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_9.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_9.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_9.sqld; ++x)
                    free (out_desc_9.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_9.sqld; ++x)
                    free (out_desc_9.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6006 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6007 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_9.sqlvar);
 	          SQLcursor[9] = 0;
  	          SQLcursor_count[9] = 0;
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
                  for (x = 0; x < out_desc_9.sqld; ++x)
                    free (out_desc_9.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_9.sqld; ++x)
                    free (out_desc_9.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6030 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6031 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_9.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[9] = 0;
	          SQLcursor_count[9] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_9.sqld; ++x)
               free (out_desc_9.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_9.sqld; ++x)
               free (out_desc_9.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6053 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6054 "SQLqry2-10.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_9.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[9] = 0;
              SQLcursor_count[9] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id7,0,&out_desc_9,0,7);
}

#line 6067 "SQLqry2-10.rc"

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
                if( SQLcursor[9] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_9.sqld; ++x)
               free (out_desc_9.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_9.sqld; ++x)
               free (out_desc_9.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 6095 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6096 "SQLqry2-10.rc"

             free (str);

             free (out_desc_9.sqlvar);
             SQLcursor[9] = 0;
             SQLcursor_count[9] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[9];
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

#line 6118 "SQLqry2-10.rc"

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

	  
          for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_9.sqld; ++x)
            free (out_desc_9.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6144 "SQLqry2-10.rc"

          free (str);

          free (out_desc_9.sqlvar);
          SQLcursor[9] = 0;
          SQLcursor_count[9] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_9.sqld; ++i)
        {
          free (out_desc_9.sqlvar [i].sqldata);
          free (out_desc_9.sqlvar [i].sqlind);
        }

       free (out_desc_9.sqlvar);

{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 6163 "SQLqry2-10.rc"

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
          SQLcursor[9] = 0;
	  SQLcursor_count[9] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[9] = 0;
       SQLcursor_count[9] = 0;
       return (SQL_I_NO_MORE_DATA);
    }

 long  SQLquery_cursor10 (sql_str10, list, size, rows)

#line 6195 "SQLqry2-10.rc"

char * sql_str10;

#line 6197 "SQLqry2-10.rc"

    MEMptr   *list;
    long     size;
    long     rows;	/* i  - number of rows of data to fetch 
		   	    0 - stop fetching and clean up
			    n - fetch this many rows
			 */
    {
       static char *fname = "SQLquery_cursor10" ;

#line 6206 "SQLqry2-10.rc"

long status;

#line 6207 "SQLqry2-10.rc"

long i;

#line 6208 "SQLqry2-10.rc"

long x;

#line 6209 "SQLqry2-10.rc"

long NEW_LIST;

#line 6210 "SQLqry2-10.rc"

long fetch_count;

#line 6211 "SQLqry2-10.rc"

char data_type[30];

#line 6212 "SQLqry2-10.rc"

char data[30];

#line 6213 "SQLqry2-10.rc"

char * str;

#line 6214 "SQLqry2-10.rc"

char * data1;

#line 6215 "SQLqry2-10.rc"

char * * format;

#line 6216 "SQLqry2-10.rc"

datetime * ptr;

#line 6217 "SQLqry2-10.rc"

char column_name[50];

#line 6219 "SQLqry2-10.rc"

       char message [100];
       
    SQLquery_count += 1;

    _SQLdebug ((fname, "Qry  Str  = <%s> : Size = <%d>\n : Rows = <%d>\n", 
	sql_str10, size, rows));
   
    /* prepare a dynamic SQL statement but only if this is the first
     * time through. 
     */
	
if( rows > 0 )
{
    if( SQLcursor[10] )
	_SQLdebug(( fname, "%s\n", "Cursor already prepared" ));

    if( !SQLcursor[10] )
    {
	_SQLdebug(( fname, "%s\n", "Preparing stmt10" ));
{RISint_prepare(&RIScpp_stmt_id8,sql_str10,1,0);
}

#line 6239 "SQLqry2-10.rc"

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

#line 6257 "SQLqry2-10.rc"

           return (status);
       }

    /*
     **	if the statement is a SELECT statement (sqld != 0),
     **	declare a cursor for, open, and fetch from the statement.
     */

       out_desc_10.sqld = 0;
       out_desc_10.sqln = 0;
       out_desc_10.sqlvar = 0;

    /* get the count of output columns */

{RISint_describe(RIScpp_stmt_id8,&out_desc_10,1);
}

#line 6272 "SQLqry2-10.rc"

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

#line 6290 "SQLqry2-10.rc"

           return (status);
        }
    } /* if( !SQLcursor[10] ) */

    if (! (*list))
    {
        _SQLdebug(( fname, "%s\n", "Opening buffer" ));
        status = MEMopen (list, size);
        if (status != MEM_S_SUCCESS)
        {
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6301 "SQLqry2-10.rc"

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

#line 6314 "SQLqry2-10.rc"

              _SQLdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
              status));
              return (SQL_E_MEM);
         }
       
         NEW_LIST = 0;

         format = (char **) (*list) -> format_ptr;
      }

    if( !SQLcursor[10] )
    {
        _SQLdebug(( fname, "%s\n", "Calloc space for out_desc_10" ));
        out_desc_10.sqlvar = (sqlvar *)calloc(out_desc_10.sqld, sizeof (sqlvar));
        if (! out_desc_10.sqlvar)
        {
  	    status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6332 "SQLqry2-10.rc"

            if (NEW_LIST) MEMclose (list);
            _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n", status));
            ERRload_struct (SQL, status, "%s", "Calloc failed");
            return (status);
        }

        out_desc_10.sqln = out_desc_10.sqld;

{RISint_describe(RIScpp_stmt_id8,&out_desc_10,1);
}

#line 6341 "SQLqry2-10.rc"

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

#line 6360 "SQLqry2-10.rc"

        free (out_desc_10.sqlvar);
        return (status);
        }
           
       for (i = 0; i < out_desc_10.sqld; ++i)
        {
          out_desc_10.sqlvar [i].sqldata =
                 calloc (1, out_desc_10.sqlvar [i].sqllen);
          if (! out_desc_10.sqlvar [i].sqldata)
           {
             for (x = 0; x < i; ++x) free (out_desc_10.sqlvar [x].sqldata);
             for (x = 0; x < i; ++x) free (out_desc_10.sqlvar [x].sqlind);
	     status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6374 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_10.sqlvar);
             _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, "%s", "Calloc failed");
             return (status);
           }

          out_desc_10.sqlvar [i].sqlind = (long *) calloc (1, sizeof (long));
          if (! out_desc_10.sqlvar [i].sqlind)
           {
              for (x = 0; x <= i; ++x) free (out_desc_10.sqlvar [x].sqldata);
              for (x = 0; x < i; ++x)  free (out_desc_10.sqlvar [x].sqlind);
	      status = SQL_E_MALLOC ;
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6389 "SQLqry2-10.rc"

              if (NEW_LIST) MEMclose (list);
              free (out_desc_10.sqlvar);
              _SQLdebug ((fname, "Calloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, "%s", "Calloc failed");
              return (status); 
            }
        }

       if (! NEW_LIST)
        {
          if ((*list) -> columns != out_desc_10.sqld)
           {
	     status = SQL_E_NO_FORMAT_MISMATCH ;

             for (x = 0; x < out_desc_10.sqld; ++x)
                free (out_desc_10.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_10.sqld; ++x)
                free (out_desc_10.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6411 "SQLqry2-10.rc"

             if (NEW_LIST) MEMclose (list);
             free (out_desc_10.sqlvar);
             _SQLdebug ((fname, "No Columns Mismatch : status = <0x%.8x>\n",
             status));
             ERRload_struct (SQL, status, NULL);
             return (status);
           }
        }
    } /* end if( !SQLcursor[10] ) */

/*  We have to open and reformat the MEMbuffer for each call */

	_SQLdebug(( fname, "Number of columns <%d>\n", out_desc_10.sqld ));
       for (i = 0; i < out_desc_10.sqld; ++i)
        {
           memset (data_type, 0, 29);
           switch (out_desc_10.sqlvar [i].sqltype)
            {
              case CHARACTER :
                sprintf (data_type, "char(%d)",
                         out_desc_10.sqlvar[i].sqllen);
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
                for (x = 0; x < out_desc_10.sqld; ++x)
                   free (out_desc_10.sqlvar [x].sqldata);

                for (x = 0; x < out_desc_10.sqld; ++x)
                   free (out_desc_10.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6469 "SQLqry2-10.rc"

                if (NEW_LIST) MEMclose (list);
                free (out_desc_10.sqlvar);
                _SQLdebug ((fname, "No Such Data Type : status = <0x%.8x>\n",
                status));
                ERRload_struct (SQL, status, "%s", "Invalid data type");
                return (status);
            }

           if (NEW_LIST)
            {
	        strncpy (column_name, out_desc_10.sqlvar [i].sqlname.sqlnamec,
		       out_desc_10.sqlvar [i].sqlname.sqlnamel) ;
		       column_name[out_desc_10.sqlvar[i].sqlname.sqlnamel] = 0 ;
              status = MEMwrite_format (*list, column_name, data_type);
              if (status != MEM_S_SUCCESS)
               {
                 for (x = 0; x < out_desc_10.sqld; ++x)
                   free (out_desc_10.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_10.sqld; ++x)
                   free (out_desc_10.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6492 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_10.sqlvar);
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

                 for (x = 0; x < out_desc_10.sqld; ++x)
                   free (out_desc_10.sqlvar [x].sqldata);

                 for (x = 0; x < out_desc_10.sqld; ++x)
                   free (out_desc_10.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6512 "SQLqry2-10.rc"

                 if (NEW_LIST) MEMclose (list);
                 free (out_desc_10.sqlvar);
                 _SQLdebug ((fname, "Fmt Match Failed : status = <0x%.8x>\n",
                 status));
                 ERRload_struct (SQL, status, NULL);
                 return (status);
               }
            }
        }

    if( !SQLcursor[10] )
    {
       _SQLdebug(( fname, "%s\n", "Declare cursor" ));
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 6526 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6551 "SQLqry2-10.rc"

          free (out_desc_10.sqlvar);
          return (status);
        }

{RISint_execute(&RIScpp_stmt_id8,0,0,7,1,0);
}

#line 6556 "SQLqry2-10.rc"

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

          for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6582 "SQLqry2-10.rc"

          free (out_desc_10.sqlvar);
          return (status);
        }
    SQLcursor[10] = 1;

    } /* end if( !SQLcursor[10] ) */
}
/*  If rows == 0, this is the signal to close the cursor and clean up.
 *  The RIS preprocessor would not allow these closing statements until
 *  now; otherwise, this would have been executed first.
 */
else if( rows == 0 )
{
    if( SQLcursor[10] != 0 )
    {
        for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqldata);

        for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6604 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6605 "SQLqry2-10.rc"


        free (out_desc_10.sqlvar); 
    }
    SQLcursor[10] = 0;
    SQLcursor_count[10] = 0;
	
    _SQLdebug(( fname, "%s\n", "Closing out partial query" ));

    return( SQL_S_SUCCESS );
}

{RISint_fetch(RIScpp_stmt_id8,0,&out_desc_10,0,7);
}

#line 6617 "SQLqry2-10.rc"

       _SQLdebug(( fname, "%s\n", "Fetch curs10 (First time)" ));
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
             if( SQLcursor[10] && ( SQLcursor_count[10] > 0 ))
                 status = SQL_I_NO_MORE_DATA;
             _SQLdebug ((fname,  "No Rows Found : status = <0x%.8x>\n",
             status));
	     ERRload_struct (SQL, status, NULL) ;
           }

          for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6645 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6646 "SQLqry2-10.rc"


          free (out_desc_10.sqlvar); 
          SQLcursor[10] = 0;
          SQLcursor_count[10] = 0;
          return (status);
        }

       str = (char *) malloc ((*list) -> row_size + 100);
       if (! str)
        {
	  status = SQL_E_MALLOC ;
          for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6664 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6665 "SQLqry2-10.rc"

          if (NEW_LIST) MEMclose (list);
          free (out_desc_10.sqlvar);
          _SQLdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct (SQL, status, "%s", "Malloc failed");
          SQLcursor[10] = 0;
          SQLcursor_count[10] = 0;
          return (status);
        }

       fetch_count = 1;
       ++SQLcursor_count[10];

       while (SQLCODE != END_OF_DATA )            
       {
	  _SQLdebug(( fname, "Fetch_count <%d>\n", fetch_count ));
          str [0] = 0;

          for (i = 0; i < out_desc_10.sqld; ++i)
           {
             if (*out_desc_10.sqlvar [i].sqlind < 0)
              {
                strcat (str, "\1");
                continue;
              }

             memset (data, 0, 29);

             switch (out_desc_10.sqlvar [i].sqltype)
              {
                case CHARACTER :
                  data1 = (char *) malloc (out_desc_10.sqlvar[i].sqllen + 2);
                  if (! data1)
                   {
		     status = SQL_E_MALLOC ;
                     for (x = 0; x < out_desc_10.sqld; ++x)
                       free (out_desc_10.sqlvar [x].sqldata);
  
                     for (x = 0; x < out_desc_10.sqld; ++x)
                       free (out_desc_10.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6706 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6707 "SQLqry2-10.rc"

                     free (str);
                     if (NEW_LIST) MEMclose (list);
                     free (out_desc_10.sqlvar);
                     _SQLdebug ((fname, "Malloc : status = <0x%.8x>\n",
                     status));
                     ERRload_struct (SQL, status, "%s", "Malloc failed");
	             SQLcursor[10] = 0;
	             SQLcursor_count[10] = 0;
                     return (status);
                   }
                  memset (data1, 0,  out_desc_10.sqlvar[i].sqllen + 1);

                  sprintf (data1, "%-*.*s", out_desc_10.sqlvar[i].sqllen, 
                  out_desc_10.sqlvar[i].sqllen, out_desc_10.sqlvar [i].sqldata);
                  strcat (str, data1);
                  strcat (str, "\1");
                  free (data1);
                  break;

                case INTEGER :
                  sprintf (data, "%d", *(int *)
                           out_desc_10.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case SMALLINT :
                  sprintf (data, "%hd", 
                           *(short *) out_desc_10.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DOUBLE :
                  sprintf (data, "%lf", 
                           *(double *) out_desc_10.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case REAL :
                  sprintf (data, "%lG", 
                           *(float *) out_desc_10.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

                case DECIMAL :
                  sprintf (data, "%d", *(int *)
                           out_desc_10.sqlvar [i].sqldata);
                  strcat (str, data);
                  strcat (str, "\1");
                  break;

	        case DATETIME :
	        ptr  = (datetime *) out_desc_10.sqlvar [i].sqldata ;
	
	        status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;	
	        if (status != RIS_SUCCESS)
               {
                  for (x = 0; x < out_desc_10.sqld; ++x)
                    free (out_desc_10.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_10.sqld; ++x)
                    free (out_desc_10.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6775 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6776 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_10.sqlvar);
 	          SQLcursor[10] = 0;
  	          SQLcursor_count[10] = 0;
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
                  for (x = 0; x < out_desc_10.sqld; ++x)
                    free (out_desc_10.sqlvar [x].sqldata);
  
                  for (x = 0; x < out_desc_10.sqld; ++x)
                    free (out_desc_10.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6799 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6800 "SQLqry2-10.rc"

                  free (str);
                  if (NEW_LIST) MEMclose (list);
                  free (out_desc_10.sqlvar);
                  _SQLdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",
                  status));
                  ERRload_struct (SQL, status, "%s", "Invalid data type");
 	          SQLcursor[10] = 0;
	          SQLcursor_count[10] = 0;
                  return (status);
              }
           }

          status = MEMwrite (*list, str);
          if (status != MEM_S_SUCCESS)
           {
             for (x = 0; x < out_desc_10.sqld; ++x)
               free (out_desc_10.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_10.sqld; ++x)
               free (out_desc_10.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6822 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6823 "SQLqry2-10.rc"

              free (str);
              if (NEW_LIST) MEMclose (list);
              free (out_desc_10.sqlvar);
              _SQLdebug ((fname, "MEM Write Failed: status = <0x%.8x>\n",
    	          status));
              SQLcursor[10] = 0;
              SQLcursor_count[10] = 0;
              return (SQL_E_MEM);
           }

	if( fetch_count < rows )
	{ 
{RISint_fetch(RIScpp_stmt_id8,0,&out_desc_10,0,7);
}

#line 6836 "SQLqry2-10.rc"

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
                if( SQLcursor[10] )
                    status = SQL_I_NO_MORE_DATA;
                _SQLdebug ((fname, "No Rows Found : status = <0x%.8x>\n",
                status));
		ERRload_struct (SQL, status, NULL) ;
              }

             for (x = 0; x < out_desc_10.sqld; ++x)
               free (out_desc_10.sqlvar [x].sqldata);

             for (x = 0; x < out_desc_10.sqld; ++x)
               free (out_desc_10.sqlvar [x].sqlind);

{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 6864 "SQLqry2-10.rc"

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6865 "SQLqry2-10.rc"

             free (str);

             free (out_desc_10.sqlvar);
             SQLcursor[10] = 0;
             SQLcursor_count[10] = 0;
             return (status);
           }
 	 ++fetch_count;
	 ++SQLcursor_count[10];
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

#line 6887 "SQLqry2-10.rc"

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

	  
          for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqldata);

          for (x = 0; x < out_desc_10.sqld; ++x)
            free (out_desc_10.sqlvar [x].sqlind);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6913 "SQLqry2-10.rc"

          free (str);

          free (out_desc_10.sqlvar);
          SQLcursor[10] = 0;
          SQLcursor_count[10] = 0;
          return (status); 
        }

       free (str);

       for (i = 0; i < out_desc_10.sqld; ++i)
        {
          free (out_desc_10.sqlvar [i].sqldata);
          free (out_desc_10.sqlvar [i].sqlind);
        }

       free (out_desc_10.sqlvar);

{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 6932 "SQLqry2-10.rc"

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
          SQLcursor[10] = 0;
	  SQLcursor_count[10] = 0;
          return (status);
        }


       _SQLdebug ((fname, "SUCCESSFUL : number of rows = <%ld>\n", 	
	(*list)->rows)) ;		
       SQLcursor[10] = 0;
       SQLcursor_count[10] = 0;
       return (SQL_I_NO_MORE_DATA);
    }
