#include "sql.h"
static short RIScpp_stmt_id0 = -1;
static short RIScpp_stmt_id1 = -1;

#line 1 "SQLg_fmax.rc"
#include "machine.h"
/***************************************************************************
*				SQLget_max_filenum				   *
*									   *
*	Get the maximum value of n_itemno				   *
***************************************************************************/
#include "SQL.h"
#include "MEMstruct.h"
/* #include "SQLsizedef.h"   RIS3.0 has a problem */

long SQLget_max_filenum(cat_name , num_rows)
	char *cat_name;
	long *num_rows ;
{
	char *fname="SQLget_max_filenum";

#line 16 "SQLg_fmax.rc"

long status,  i;

#line 17 "SQLg_fmax.rc"

char sql_str[1084];

#line 18 "SQLg_fmax.rc"

char n_name[96];

#line 19 "SQLg_fmax.rc"

char n_nfmname[96];

#line 20 "SQLg_fmax.rc"

long num_of_rows;

#line 21 "SQLg_fmax.rc"

sqlda out_desc;

#line 23 "SQLg_fmax.rc"


	long SQLget_n_name();
	_SQLdebug((fname,"Entry\t>>\ncatalog name %s num_rows address %x\n",cat_name,num_rows));
	strcpy(n_nfmname,"n_fileno");
	if((status=SQLget_n_name(cat_name,n_nfmname,n_name))!=SQL_S_SUCCESS)
	{
		_SQLdebug((fname,"Cannot get n_name for %s\n",n_nfmname));
		_SQLdebug((fname,"Using %s for %s\n",n_nfmname,n_nfmname));
		strcpy(n_name,n_nfmname);
	}
	sprintf(sql_str,"SELECT max(%s) from f_%s",n_name,cat_name);
{RISint_prepare(&RIScpp_stmt_id0,sql_str,1,0);
}

#line 36 "SQLg_fmax.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_PREPARE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
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

#line 56 "SQLg_fmax.rc"

           return (status);
        }

        out_desc.sqld = 0;
        out_desc.sqln = 0;
        out_desc.sqlvar = 0;
{RISint_describe(RIScpp_stmt_id0,&out_desc,1);
}

#line 63 "SQLg_fmax.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DESCRIBE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
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

#line 83 "SQLg_fmax.rc"

           return (status);
        }
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 86 "SQLg_fmax.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DECLARE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
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

#line 106 "SQLg_fmax.rc"

           return (status);
        }

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
}

#line 110 "SQLg_fmax.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_CURSOR,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
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

#line 130 "SQLg_fmax.rc"

           return (status);
        }

	out_desc.sqlvar = (struct sqlvar *)calloc(out_desc.sqld,sizeof(sqlvar));
	out_desc.sqln = out_desc.sqld ;
{RISint_describe(RIScpp_stmt_id0,&out_desc,1);
}

#line 136 "SQLg_fmax.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DESCRIBE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,
				"SQL QRY : Prepare Failed : status = <0x%.8x>\n", status));
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

#line 156 "SQLg_fmax.rc"

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

#line 167 "SQLg_fmax.rc"
	
       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_FETCH,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
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

#line 188 "SQLg_fmax.rc"

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

#line 199 "SQLg_fmax.rc"

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 200 "SQLg_fmax.rc"

	*num_rows = * ( int *) out_desc.sqlvar[0].sqldata ;
	_SQLdebug((fname,"Successful : Number of rows <%d> \n", *num_rows ));
		free(out_desc.sqlvar);
		for(i=0;i < out_desc.sqld;i++)
		{
			free(out_desc.sqlvar[i].sqldata);
			free(out_desc.sqlvar[i].sqlind);
		}
	return(SQL_S_SUCCESS);	
}


long SQLget_n_name(cat_name , n_nfmname,n_name)
	

#line 215 "SQLg_fmax.rc"

char * cat_name,  * n_nfmname,  * n_name;

#line 217 "SQLg_fmax.rc"

{
	char *fname="SQLget_n_name";

#line 220 "SQLg_fmax.rc"

long status,  i;

#line 221 "SQLg_fmax.rc"

char sql_str[1024];

#line 222 "SQLg_fmax.rc"

sqlda out_desc;

#line 224 "SQLg_fmax.rc"


	_SQLdebug((fname,"Entry\t>>\ncatalog name %s n_nfmname %s n_name %s\n",cat_name,n_nfmname,n_name));
	sprintf(sql_str, "SELECT  n_name from nfmattributes where n_tableno in (SELECT n_tableno from nfmtables where n_tablename='%s' or n_tablename = 'f_%s') AND n_nfmname = '%s' ",cat_name,cat_name,n_nfmname);

{RISint_prepare(&RIScpp_stmt_id1,sql_str,1,0);
}

#line 231 "SQLg_fmax.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_PREPARE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
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

#line 251 "SQLg_fmax.rc"

           return (status);
        }

        out_desc.sqld = 0;
        out_desc.sqln = 0;
        out_desc.sqlvar = 0;
{RISint_describe(RIScpp_stmt_id1,&out_desc,1);
}

#line 258 "SQLg_fmax.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DESCRIBE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
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

#line 278 "SQLg_fmax.rc"

           return (status);
        }
/* declare for statement id requires no work just return success */
SQLCODE = RIS_SUCCESS;

#line 281 "SQLg_fmax.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DECLARE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
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

#line 301 "SQLg_fmax.rc"

           return (status);
        }

{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
}

#line 305 "SQLg_fmax.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_CURSOR,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
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

#line 325 "SQLg_fmax.rc"

           return (status);
        }

	out_desc.sqlvar = (struct sqlvar *)calloc(out_desc.sqld,sizeof(sqlvar));
	out_desc.sqln = out_desc.sqld ;
{RISint_describe(RIScpp_stmt_id1,&out_desc,1);
}

#line 331 "SQLg_fmax.rc"

       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_DESCRIBE,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n", status));
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

#line 350 "SQLg_fmax.rc"

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

#line 361 "SQLg_fmax.rc"
	
       if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQLerror (SQL_E_FETCH,
                       risca -> sqlerrd [1], SQLCODE);
              _SQLdebug ((fname,"SQL QRY : Prepare Failed : status = <0x%.8x>\n",
              status));
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

#line 382 "SQLg_fmax.rc"

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

#line 393 "SQLg_fmax.rc"

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 394 "SQLg_fmax.rc"

	strcpy(n_name,(char *) out_desc.sqlvar[0].sqldata);
	_SQLdebug((fname,"Successful : n_name <%s> for n_nfmname <%s>\n", n_name,n_nfmname ));
		free(out_desc.sqlvar);
		for(i=0;i < out_desc.sqld;i++)
		{
			free(out_desc.sqlvar[i].sqldata);
			free(out_desc.sqlvar[i].sqlind);
		}
	return(SQL_S_SUCCESS);	
}
