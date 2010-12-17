#include "sql.h"
static short RIScpp_stmt_id0 = -1;
static short RIScpp_stmt_id1 = -1;

#line 1 "SQLg_num_r.rc"
#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "SQLerrordef.h"
#include "MSGstruct.h"
#include "DEBUG.h"
#include "ERR.h"




/***************************************************************************
*				SQLget_max_record_num			   *
*									   *
*	Get the maximum value of indicated attribute in the given table	   *
***************************************************************************/

long SQLget_max_record_num(table_name ,attr_name, max_num)
	char *table_name,*attr_name;
	long *max_num ;
{
	char *fname="SQLget_max_record_num";

#line 23 "SQLg_num_r.rc"

long status,  i;

#line 24 "SQLg_num_r.rc"

char sql_str[1024];

#line 25 "SQLg_num_r.rc"

long num_of_rows;

#line 26 "SQLg_num_r.rc"

sqlda out_desc;

#line 28 "SQLg_num_r.rc"


	long SQLget_n_name();
	_SQLdebug((fname,"Entry\t>>\ntable_name %s attribute name <%s> maximum number address %x\n",table_name,attr_name,max_num));
	sprintf(sql_str,"SELECT max(%s) from %s",attr_name,table_name);
{RISint_prepare(&RIScpp_stmt_id0,sql_str,1,0);
}

#line 34 "SQLg_num_r.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_PREPARE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 55 "SQLg_num_r.rc"

           return (status);
        }

        out_desc.sqld = 0;
        out_desc.sqln = 0;
        out_desc.sqlvar = 0;
{RISint_describe(RIScpp_stmt_id0,&out_desc,1);
}

#line 62 "SQLg_num_r.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DESCRIBE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 83 "SQLg_num_r.rc"

           return (status);
        }
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 86 "SQLg_num_r.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DECLARE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 107 "SQLg_num_r.rc"

           return (status);
        }

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
}

#line 111 "SQLg_num_r.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_CURSOR,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 132 "SQLg_num_r.rc"

           return (status);
        }

	out_desc.sqlvar = (sqlvar *)calloc(out_desc.sqld,sizeof(sqlvar));
	out_desc.sqln = out_desc.sqld ;
{RISint_describe(RIScpp_stmt_id0,&out_desc,1);
}

#line 138 "SQLg_num_r.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DESCRIBE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n", status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 158 "SQLg_num_r.rc"

	   free(out_desc.sqlvar);
           return (status);
        }

	for(i=0;i < out_desc.sqld;i++)
	{
		out_desc.sqlvar[i].sqldata=(char *)calloc(1,out_desc.sqlvar[i].sqllen);
		out_desc.sqlvar[i].sqlind =(long *) calloc ( 1, sizeof(long));
	}

{RISint_fetch(RIScpp_stmt_id0,0,&out_desc,0,7);
}

#line 169 "SQLg_num_r.rc"
	
       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_FETCH,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
	

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 191 "SQLg_num_r.rc"

		free(out_desc.sqlvar);
		for(i=0;i < out_desc.sqld;i++)
		{
			free(out_desc.sqlvar[i].sqldata);
			free(out_desc.sqlvar[i].sqlind);
		}
           return (status);
        }

	i=0;
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 202 "SQLg_num_r.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 203 "SQLg_num_r.rc"

	*max_num = * ( int *) out_desc.sqlvar[0].sqldata ;
	_SQLdebug((fname,"Successful : Number of rows <%d> \n", *max_num ));
		free(out_desc.sqlvar);
		for(i=0;i < out_desc.sqld;i++)
		{
			free(out_desc.sqlvar[i].sqldata);
			free(out_desc.sqlvar[i].sqlind);
		}
	return(SQL_S_SUCCESS);	
}





/***************************************************************************
*				SQLget_min_record_num			   *
*									   *
*	Get the minimum value of indicated attribute in the given table	   *
***************************************************************************/

long SQLget_min_record_num(table_name ,attr_name, min_num)
	char *table_name,*attr_name;
	long *min_num ;
{
	char *fname="SQLget_min_record_num";

#line 230 "SQLg_num_r.rc"

long status,  i;

#line 231 "SQLg_num_r.rc"

char sql_str[1024];

#line 232 "SQLg_num_r.rc"

long num_of_rows;

#line 233 "SQLg_num_r.rc"

sqlda out_desc;

#line 235 "SQLg_num_r.rc"


	_SQLdebug((fname,"Entry\t>>\ntable_name %s attribute name <%s> minimum number address %x\n",table_name,attr_name,min_num));
	sprintf(sql_str,"SELECT min(%s) from %s",attr_name,table_name);
{RISint_prepare(&RIScpp_stmt_id1,sql_str,1,0);
}

#line 240 "SQLg_num_r.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_PREPARE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 261 "SQLg_num_r.rc"

           return (status);
        }

        out_desc.sqld = 0;
        out_desc.sqln = 0;
        out_desc.sqlvar = 0;
{RISint_describe(RIScpp_stmt_id1,&out_desc,1);
}

#line 268 "SQLg_num_r.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DESCRIBE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 289 "SQLg_num_r.rc"

           return (status);
        }
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 292 "SQLg_num_r.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DECLARE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 313 "SQLg_num_r.rc"

           return (status);
        }

{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
}

#line 317 "SQLg_num_r.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_CURSOR,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 338 "SQLg_num_r.rc"

           return (status);
        }

	out_desc.sqlvar = (sqlvar *)calloc(out_desc.sqld,sizeof(sqlvar));
	out_desc.sqln = out_desc.sqld ;
{RISint_describe(RIScpp_stmt_id1,&out_desc,1);
}

#line 344 "SQLg_num_r.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DESCRIBE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n", status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 364 "SQLg_num_r.rc"

	   free(out_desc.sqlvar);
           return (status);
        }

	for(i=0;i < out_desc.sqld;i++)
	{
		out_desc.sqlvar[i].sqldata=(char *)calloc(1,out_desc.sqlvar[i].sqllen);
		out_desc.sqlvar[i].sqlind =(long *) calloc ( 1, sizeof(long));
	}

{RISint_fetch(RIScpp_stmt_id1,0,&out_desc,0,7);
}

#line 375 "SQLg_num_r.rc"
	
       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_FETCH,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
           else
           {
              status = SQLerror (SQL_I_NO_ROWS_FOUND,
                       risca -> sqlerrd [1], SQLCODE); 
              status = SQL_I_NO_ROWS_FOUND ;
              _SQLdebug ((fname,"SQL QRY : No Rows Found : status = <0x%.8x>\n",
              status));
              ERRload_struct (SQL, status, NULL) ;
            }
	

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 397 "SQLg_num_r.rc"

		free(out_desc.sqlvar);
		for(i=0;i < out_desc.sqld;i++)
		{
			free(out_desc.sqlvar[i].sqldata);
			free(out_desc.sqlvar[i].sqlind);
		}
           return (status);
        }

	i=0;
{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 408 "SQLg_num_r.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 409 "SQLg_num_r.rc"

	*min_num = * ( int *) out_desc.sqlvar[0].sqldata ;
	_SQLdebug((fname,"Successful : Number of rows <%d> \n", *min_num ));
		free(out_desc.sqlvar);
		for(i=0;i < out_desc.sqld;i++)
		{
			free(out_desc.sqlvar[i].sqldata);
			free(out_desc.sqlvar[i].sqlind);
		}
	return(SQL_S_SUCCESS);	
}


