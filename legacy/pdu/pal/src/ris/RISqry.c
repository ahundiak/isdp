#include "ris.h"
static short RIScpp_stmt_id0 = -1;
extern char  *malloc(), *calloc() ;
int   RISqry_no_output (  ris_query,  err_code )
char   *ris_query;
int   *err_code ;
{

int i;

char * sql_stmt2;

char buffer[100];

sqlda in_desc;

sqlda out_desc;

char * err_ptr;


	/*
	**	create the sql statement (for illustration only...
	**	a real dynamic would have been passed in).
	*/

	sql_stmt2 = ris_query;
	
	/* define exception handlers */
	


	

	/* prepare a dynamic SQL statement */
	
{RISint_prepare(&RIScpp_stmt_id0,sql_stmt2,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	in_desc.sqld = 0;
	in_desc.sqln = 0;
	in_desc.sqlvar = 0;
	
	/* see if there are any input parameters */
	
{RISint_describe(RIScpp_stmt_id0,&in_desc,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	if ( in_desc.sqld )
	{
		/* allocate input buffers for any input parameters */

		in_desc.sqlvar = (sqlvar*) calloc ( in_desc.sqld,
                                                    sizeof(sqlvar) );
		in_desc.sqln = in_desc.sqld;
	
		/* get information about the input parameters */
	
{RISint_describe(RIScpp_stmt_id0,&in_desc,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		for ( i = 0; i < in_desc.sqld; ++i )
		{
			/* get a value for the input parameter */
			printf ( "Enter a value for input parameter #%d\n", i );
	
			gets ( buffer );

			/* set up the program address, 
                                             and (optional) indicator */

			in_desc.sqlvar[i].sqldata = calloc ( 1,
                                                     in_desc.sqlvar[i].sqllen );
	
			/* if no string was entered, assume null value wanted */

			if ( buffer[0] == '\0' )
			{
				*in_desc.sqlvar[i].sqldata = '\0';
				in_desc.sqlvar[i].sqlnull = 1;
				in_desc.sqlvar[i].sqlind = (long*) calloc( 1, 
                                                            sizeof(int) );
				*in_desc.sqlvar[i].sqlind = -1;
			}
			else
			{
				in_desc.sqlvar[i].sqlnull = 0;
				switch ( in_desc.sqlvar[i].sqltype )
				{
					case CHARACTER:
						strncpy ( in_desc.sqlvar[i].sqldata, 
                                                    buffer, in_desc.sqlvar[i].sqllen );
						break;

					case SMALLINT:
						sscanf ( buffer, "%hd", 
                                                   in_desc.sqlvar[i].sqldata );
						break;

					case INTEGER:
						sscanf ( buffer, "%d", 
                                                   in_desc.sqlvar[i].sqldata );
						break;

					case REAL:
						sscanf ( buffer, "%f",
                                                   in_desc.sqlvar[i].sqldata );
						break;

					case DOUBLE:
						sscanf ( buffer, "%lf", 
                                                    in_desc.sqlvar[i].sqldata );
						break;
					case DECIMAL:
						sscanf ( buffer, "%lf", 
                                                    in_desc.sqlvar[i].sqldata );
						break;

					default:
						/* printf ( "Invalid data type found\n" ); */
						/*strcpy ( err_str, "error: Invalid data type found\n" );*/
                                                *err_code = -1 ;
						/* exit (); */
                                                return ( -1 );
				}
			}
		}
	}

	/*
	**	if the statement is not a SELECT statement (sqld == 0),
	**		execute the statement.
	**	else
	**		declare a cursor for, open, and 
        **              fetch from the statement.
	*/
	
	out_desc.sqld = 0;
	out_desc.sqln = 0;
	out_desc.sqlvar = 0;

	/* get the count of output columns */

{RISint_describe(RIScpp_stmt_id0,&out_desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	/* non-SELECT statements will have sqld == 0 (no result columns) */

	if (out_desc.sqld == 0)
	{
{RISint_execute(&RIScpp_stmt_id0,0,&in_desc,7,1,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	
         	/* 	printf ( "\nDone\n" );
		 exit(); */
                return ( 0 );
	}
	


not_found:

	/* exit (); */
        return ( 0 );
	

error:

RISint_report_error(0,&err_ptr);

	/* puts ( err_ptr ); 
        strcpy ( err_str, err_ptr ); */
        *err_code = risca -> sqlcode ;
	/* exit (); */
        return ( -3 );
}
