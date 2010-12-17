#include "ris.h"
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
static short RIScpp_stmt_id10 = -1;
static short RIScpp_stmt_id11 = -1;
static short RIScpp_stmt_id12 = -1;
static short RIScpp_stmt_id13 = -1;
static short RIScpp_stmt_id14 = -1;
#include	<string.h>
#include	<stdio.h>
#include        "MEMstruct.h"
#include        "PDUerror.h"
#include        "DEBUG.h"
#include        "PDUris_incl.h"
#include        "SQLerrordef.h"
#include        "SQLstruct.h"
#include        "NFMerrordef.h"
#include        "PDMproto.h"
#include        "PDMris_fnpro.h"

extern int	PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern PDMpart_ptr    PDMpart;
extern PDMchild_ptr    PDMchild;
extern struct SQLglobal_st SQLglobal ;
extern char  *malloc (), *calloc () ;
extern MEMptr catno_type;

/* ALR 8/16/93  Move this declaration global so that it can be used by
   the pdmRisQuery API.
*/


sqlda query_out_desc;


/* All these functions are written to avoid the SQLlayer of NFM - KUMAR */

int PDMris_get_catno ( catalog, catno )
 char	*catalog;
 int	*catno;
{
        static char  *fname = "PDMris_get_catno";
        char **data= NULL, sql_stmt[512], mem_str[120];
        int    i = 0, nxi = 0;
        long  status = SQL_S_SUCCESS;
        MEMptr  bufr = NULL;

        _PDMdebug (fname, "ENTER:\n");
        *catno = -1;
	sql_stmt[0] = '\0';
         if (catno_type != NULL)
         {
           status = MEMbuild_array (catno_type);
            if (status != MEM_S_SUCCESS)
             {
               _PDMdebug (fname, "MEMbuild_array failed status %s\n", status);
             }
            if (status == MEM_S_SUCCESS)
            {
              data = (char **) catno_type->data_ptr;
               for (i=0; i < catno_type->rows; i++)
                {
                  nxi = i * catno_type->columns;
                  if (!strcmp (data[nxi], catalog)) 
                      {
                      *catno = atoi (data[nxi+1]);
             _PDMdebug (fname, "Catno for catalog %s is %d\n", catalog, *catno);
             _PDMdebug (fname, "EXIT: - data found\n");
	              return (SQL_S_SUCCESS);
                       }
                }
             }
         }

        if (*catno == -1)
        {
	sprintf (sql_stmt, "select n_catalogno, n_type from nfmcatalogs where n_catalogname = \'%s\'", catalog);

        _PDMdebug (fname, "%s\n", sql_stmt);

          status = SQLquery (sql_stmt, &bufr, 512);
          if (status != SQL_S_SUCCESS)
            {
               _PDMdebug (fname, "SQLstmt failed status %s\n", sql_stmt);
               return (status);
             }
           
         status = MEMbuild_array (bufr);
          if (status != MEM_S_SUCCESS)
           {
               _PDMdebug (fname, "MEMbuild_array failed status %d\n", status);
               return (status);
           }
          data = (char **) bufr->data_ptr;

         *catno = atoi (data[0]);
         }

         if (catno_type == NULL)
          {

/*..... Growreg prob ...
            MEMopen (&catno_type);
         ......*/
           _PDMdebug (fname, "Cache not created; Creating Cache....\n");
            status = MEMopen (&catno_type, 1024);
            if (status != MEM_S_SUCCESS) {
               _PDMdebug (fname, "MEMopen failed status %d\n", status);
               MEMclose (&bufr);
              _PDMdebug (fname, "EXIT: - data found\n");
	        return (SQL_S_SUCCESS);
              }
             status = MEMwrite_format (catno_type, "n_catalogname", "char(20)");
             if (status == MEM_S_SUCCESS)
             status = MEMwrite_format (catno_type, "n_catalogno", "integer");
             if (status == MEM_S_SUCCESS)
             status = MEMwrite_format (catno_type, "n_type", "char(5)");
             if (status != MEM_S_SUCCESS)
              {
               _PDMdebug (fname, "MEMwrite_format failed status %d\n", status);
               MEMclose (&bufr);
               MEMclose (&catno_type);
              _PDMdebug (fname, "EXIT: - data found\n");
	         return (SQL_S_SUCCESS);
               }
           }
          if ( *catno != -1)
           {
            mem_str[0] = '\0';
            sprintf (mem_str, "%s\1%d\1%s\1", catalog, *catno, data[1]);
             status = MEMwrite (catno_type, mem_str);
             if (status != MEM_S_SUCCESS)
              {
               _PDMdebug (fname, "MEMwrite failed status %d\n", status);
               MEMclose (&bufr);
               MEMclose (&catno_type);
              _PDMdebug (fname, "EXIT: - data found\n");
	         return (SQL_S_SUCCESS);
               }
           _PDMdebug (fname, "Updated Cache....\n");
           }

          MEMclose (&bufr);
	  status = SQL_S_SUCCESS;
        _PDMdebug (fname, "EXIT: - data found\n");
	return (status);

}


int PDMris_get_projectno ( project, projectno )
 char	*project;
 int	*projectno;
{
        static char  *fname = "PDMris_get_projectno";

long status;

char sql_stmt[100];

int nfmprojectno;

long numberind;

char * err_ptr;





        PDMdebug ("ENTER: PDMris_get_projectno\n");
	strcpy (sql_stmt, "");


	sprintf (sql_stmt, "select n_projectno from nfmprojects where n_projectname = \'%s\'", 
		project);

        PDMdebug ( sql_stmt);

{RISint_prepare(&RIScpp_stmt_id0,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	*projectno = 0;
	numberind = 0;
	nfmprojectno = 0;

{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&nfmprojectno;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id0,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug ("nfmprojectno: <null>");}
		else
                  {
		  PDMdebug ("nfmprojectno: ");
		  *projectno = nfmprojectno;
		  }


not_found:

	PDMdebug ("No more data\n");
	if ( *projectno != 0 )
          {
	  status = SQL_S_SUCCESS;
        PDMdebug ("EXIT: PDMris_get_projectno - Data found\n");
          }
	else
          {
	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug ("EXIT: PDMris_get_projectno - No rows found\n");
          }
{RISint_close(RIScpp_stmt_id0, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
        PDMdebug ("EXIT: PDMris_get_projectno with error\n");
{RISint_close(RIScpp_stmt_id0, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);
}


int PDMris_get_catname
 (
 int	catno, 
 char	*catalog, 
 char	*type
 )
{
        static char  *fname = "PDMris_get_catname";

long status;

char sql_stmt[100];

char nfmcatname[20];

char ty[5];

long numberind;

long typeid;

char * err_ptr;




        _PDMdebug (fname, "ENTER:\n");
	strcpy (sql_stmt, "");
	sprintf (sql_stmt, "select n_catalogname, n_type from nfmcatalogs where n_catalogno = %d", catno);
        _PDMdebug (fname, "%s\n", sql_stmt);
{RISint_prepare(&RIScpp_stmt_id1,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

	/* assign a value to be used in the SQL statement */
{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	strcpy (catalog, ""); 
	numberind = 0; typeid = 0;
{{
	static sqlvar out_sqlvar[2] = {
		{0,0,1,1,20,0,{0,""}},
		{0,0,1,1,5,0,{0,""}}
	};
	static sqlda out_sqlda = {2,2,out_sqlvar};
	out_sqlvar[1].sqldata = ty;
	out_sqlvar[1].sqlind = &typeid;
	out_sqlvar[0].sqldata = nfmcatname;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id1,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	if (typeid < 0 || numberind < 0){PDMdebug ("typeid: <null>");}
	else
           {
           _PDMdebug (fname, "cat_name %s\n", nfmcatname);
           _PDMdebug (fname, "cat_type %s\n", ty);
            strcpy (catalog, nfmcatname); 
            strcpy (type, ty); 
       	    }
not_found:

	if ( strlen (catalog ))
         {
	  status = SQL_S_SUCCESS;
        PDMdebug ("EXIT: PDMris_get_catname - Data found\n");
         }
	else
          {
	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug ("EXIT: PDMris_get_catname - No rows found\n");
          }
{RISint_close(RIScpp_stmt_id1, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
        PDMdebug ("EXIT: PDMris_get_catname with error\n");
{RISint_close(RIScpp_stmt_id1, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);
}

int PDMload_catno ( catalog )
 char	*catalog;
{
        static char  *fname = "PDMload_catno";

long status;

char sql_stmt[100];

int nfmcatno;

long numberind;

char * err_ptr;





        PDMdebug ("ENTER: PDMload_catno\n");
	status = PDM_S_SUCCESS;
	strcpy (sql_stmt, "");


	sprintf (sql_stmt, "select n_catalogno  from nfmcatalogs where n_catalogname = \'%s\'", catalog);

        PDMdebug ( sql_stmt);
{RISint_prepare(&RIScpp_stmt_id2,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id2,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	PDMpart.n_catalogno = 0;
	numberind = 0;
	nfmcatno = 0;

{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&nfmcatno;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id2,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug ("nfmcatno: <null>");}
		else
                  {
		  PDMpart.n_catalogno = nfmcatno;
		  }


if ( PDMpart.n_catalogno != 0 )
          status = SQL_S_SUCCESS;
        PDMdebug ("EXIT: PDMload_catno - Data found\n");
{RISint_close(RIScpp_stmt_id2, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        return (status);

not_found:

{RISint_close(RIScpp_stmt_id2, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	PDMdebug ("No more data\n");
	if ( PDMpart.n_catalogno != 0 )
	  status = SQL_S_SUCCESS;
	else
	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug ("EXIT: PDMload_catno - No rows found\n");
	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
{RISint_close(RIScpp_stmt_id2, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
        PDMdebug ("EXIT: PDMload_catno with error\n");
	return (status);
}

int PDMload_fcatno ( catalog )
 char	*catalog;
{
        static char *fname = "PDMload_fcatno";

long status;

char sql_stmt[100];

int f_nfmcatno;

long numberind;

char * err_ptr;





        PDMdebug ("ENTER: PDMload_fcatno\n");
	strcpy (sql_stmt, "");


	sprintf (sql_stmt, "select n_catalogno into :nfmcatno:numberind from nfmcatalogs where n_catalogname = \'f_%s\'", catalog);

{RISint_prepare(&RIScpp_stmt_id3,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id3,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	PDMpart.f_catalogno = 0;
	numberind = 0;
	f_nfmcatno = 0;

	for (;;)
	{
{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&f_nfmcatno;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id3,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug ("f_nfmcatno: <null>");}
		else
                  {
		  PDMpart.f_catalogno = f_nfmcatno;
		  }

	numberind = 0;
	f_nfmcatno = 0;
	}

not_found:

{RISint_close(RIScpp_stmt_id3, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	PDMdebug ("No more data\n");
	if ( PDMpart.f_catalogno != 0 )
	  status = SQL_S_SUCCESS;
	else
	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug ("EXIT: PDMload_fcatno - No rows found\n");
	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
{RISint_close(RIScpp_stmt_id3, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
        PDMdebug ("EXIT: PDMload_fcatno with error\n");
	return (status);
}

int PDMris_maxrow_no ( table, attr_name, maxrow )
char *table;
char *attr_name;
int  *maxrow;
{
        static char *fname = "PDMris_maxrow_no";

long status;

char sql_stmt[100];

int rowno;

long numberind;

char * err_ptr;





        PDMdebug ("ENTER: PDMris_maxrow_no\n");
	strcpy (sql_stmt, "");


	sprintf (sql_stmt, "select max (%s) from %s ", attr_name, table);

{RISint_prepare(&RIScpp_stmt_id4,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id4,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	numberind = 0;
        *maxrow = 0;

	for (;;)
	{
{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&rowno;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id4,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug ("rowno: <null>");}
		else
                  {
		  *maxrow = rowno;
		  }

	numberind = 0;
	rowno = 0;
	}

not_found:

{RISint_close(RIScpp_stmt_id4, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	PDMdebug ("No more data\n");
	 *maxrow = 0; 
	  status = SQL_S_SUCCESS;
        PDMdebug ("EXIT: PDMris_max_rowno - No rows found\n");
	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
{RISint_close(RIScpp_stmt_id4, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
        PDMdebug ("EXIT: PDMris_maxrowno with error\n");
	return (status);
}
int PDMris_get_pitemno ( p_itemno, catalog, partid, revision )
 int  *p_itemno;
 char *catalog;
 char *partid;
 char *revision;
{
        static char *fname = "PDMris_get_pitemno";

long status;

char sql_stmt[300];

int pitemno;

long pitemind;

char * err_ptr;





        PDMdebug ("ENTER: PDMris_get_pitemno\n");
	strcpy (sql_stmt, "");


	/**** Itemno checks ****/
        sprintf (sql_stmt, "select n_itemno from %s where n_itemname = \'%s\'and n_itemrev = \'%s\'", 
	        catalog, partid, revision);
	PDMdebug (sql_stmt);
{RISint_prepare(&RIScpp_stmt_id5,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id5,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	
        pitemno = 0;
{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&pitemno;
	out_sqlvar[0].sqlind = &pitemind;
RISint_fetch(RIScpp_stmt_id5,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

		if (pitemind < 0)
		   {PDMdebug ("pitemno: <null>");}
		else 
		   {
                     sql_stmt[0]=0;
                    sprintf (sql_stmt, "p_itemno = %d\n", pitemno);
		    PDMdebug (sql_stmt);
		    *p_itemno = pitemno;
		   }

           status = SQL_S_SUCCESS;
{RISint_close(RIScpp_stmt_id5, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


        PDMdebug ("EXIT: PDMris_get_pitemno - Data found\n");
	return (status);



not_found:

	PDMdebug ("No more data\n");
	  status = SQL_I_NO_ROWS_FOUND;
{RISint_close(RIScpp_stmt_id5, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        PDMdebug ("EXIT: PDMris_get_pitemno - No rows found\n");
	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
{RISint_close(RIScpp_stmt_id5, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        PDMdebug ("EXIT: PDMris_get_pitemno with error\n");
	return (status);
}

int PDMris_get_tableno ( catalog, catno )
 char	*catalog;
 int	*catno;
{
        static char *fname = "PDMris_get_tableno";

long status;

char sql_stmt[100];

int nfmcatno;

long numberind;

char * err_ptr;






        PDMdebug ("ENTER: PDMris_get_tableno\n");
	strcpy (sql_stmt, "");


	sprintf (sql_stmt, "select n_tableno from nfmtables where n_tablename = \'%s\'", 
		catalog);

        PDMdebug ( sql_stmt);

{RISint_prepare(&RIScpp_stmt_id6,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id6,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	*catno = 0;
	numberind = 0;
	nfmcatno = 0;

	for (;;)
	{
{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&nfmcatno;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id6,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug ("nfmcatno: <null>");}
		else
                  {
		  PDMdebug ("nfmcatno: ");
		  *catno = nfmcatno;
		  }

	numberind = 0;
	nfmcatno = 0;
	}

not_found:

	PDMdebug ("No more data\n");
	if ( *catno != 0 )
	  status = SQL_S_SUCCESS;
	else
	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug ("EXIT: PDMris_get_tableno - No rows found\n");
{RISint_close(RIScpp_stmt_id6, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
{RISint_close(RIScpp_stmt_id6, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        PDMdebug ("EXIT: PDMris_get_tableno with error\n");
	return (status);
}

int PDMris_max_childno ( p_catno, p_itemno, level, p_pchildno, p_childno )
 int	p_catno;
 int	p_itemno;
 int	level;
 int	p_pchildno;
 int	*p_childno;
{
        static char  *fname = "PDMris_max_childno";

long status;

char sql_stmt[256];

int childno;

long numberind;

char * err_ptr;





        PDMdebug ("ENTER: PDMris_max_childno\n");
	strcpy (sql_stmt, "");
sprintf (sql_stmt, "SELECT MAX (p_childno) FROM PDMCIT WHERE p_acatalogno = '%d' AND p_apartno = '%d' AND p_level = %d AND p_pchildno = %d", p_catno, p_itemno, level, p_pchildno);

        PDMdebug ( sql_stmt);

{RISint_prepare(&RIScpp_stmt_id7,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id7,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	*p_childno = 0;
	numberind = 0;
	childno = 0;

{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&childno;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id7,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug ("childno: <null>");}
		else
                  {
		  _PDMdebug ("Childno: ", "%d\n", childno);
		  *p_childno = childno;
	         status = SQL_S_SUCCESS;
        PDMdebug ("EXIT: PDMris_max_childno - data found\n");
	return (status);
      
		  }


not_found:

	PDMdebug ("No more data\n");
	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug ("EXIT: PDMris_max_childno - No rows found\n");
{RISint_close(RIScpp_stmt_id7, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
        PDMdebug ("EXIT: PDMris_max_childno with error\n");
{RISint_close(RIScpp_stmt_id7, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);


}


int PDMris_max_tempchildno (p_catno, p_itemno, level, p_pchildno, 
                                     temp_table, p_childno )
 int	p_catno;
 int	p_itemno;
 int	level;
 int	p_pchildno;
 char   *temp_table;
 int	*p_childno;
{
        static char  *fname = "PDMris_max_tempchildno";

long status;

char sql_stmt[256];

int childno;

long numberind;

char * err_ptr;





        PDMdebug ("ENTER: PDMris_max_tempchildno\n");
	strcpy (sql_stmt, "");
sprintf (sql_stmt, "SELECT MAX (p_childno) FROM %s WHERE p_acatalogno = '%d' AND p_apartno = '%d' AND p_level = %d AND p_pchildno = %d", temp_table, p_catno, p_itemno, level, p_pchildno);

        PDMdebug ( sql_stmt);

{RISint_prepare(&RIScpp_stmt_id8,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id8,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	*p_childno = 0;
	numberind = 0;
	childno = 0;

{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&childno;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id8,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug ("childno: <null>");}
		else
                  {
		  _PDMdebug ("Childno: ", "%d\n", childno);
		  *p_childno = childno;
	         status = SQL_S_SUCCESS;
        PDMdebug ("EXIT: PDMris_max_tempchildno - data found\n");
	return (status);
      
		  }


not_found:

	PDMdebug ("No more data\n");
	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug ("EXIT: PDMris_max_tempchildno - No rows found\n");
{RISint_close(RIScpp_stmt_id8, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
        PDMdebug ("EXIT: PDMris_max_tempchildno with error\n");
{RISint_close(RIScpp_stmt_id8, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);
}


int PDMget_assembly_ind ( catalog, itemname, itemrev, n_setindicator )
 char	*catalog;
 char	 *n_setindicator;
{
        static char  *fname = "PDMget_assembly_ind";

long status;

char sql_stmt[200];

char p_ass[2];

long numberind;

char * err_ptr;





        PDMdebug ("ENTER: PDMget_assembly_ind\n");
         sql_stmt[0]=0;
	sprintf (sql_stmt, "select n_setindicator from %s where n_itemname = '%s' AND n_itemrev = '%s' ", catalog, itemname, itemrev);

        PDMdebug ( sql_stmt);

{RISint_prepare(&RIScpp_stmt_id9,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id9,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	numberind = 0;
	n_setindicator[0]=0;

{{
	static sqlvar out_sqlvar[1] = {
		{0,0,1,1,2,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = p_ass;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id9,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug ("n_setindicator: <null>");}
		else
                  {
		  _PDMdebug (fname, "n_setindicator: %s\n", p_ass);
                  strcpy (n_setindicator, p_ass);
		  }

{RISint_close(RIScpp_stmt_id9, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	  status = SQL_S_SUCCESS;
        PDMdebug ("EXIT: PDMget_assembly_ind - Data found\n");
	return (status);

not_found:
{RISint_close(RIScpp_stmt_id9, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug ("EXIT: PDMris_get_catno - No rows found\n");
	return (status);

error:
{RISint_close(RIScpp_stmt_id9, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
        PDMdebug ("EXIT: PDMris_get_catno with error\n");
	return (status);
}


int PDMris_get_userno ( user, userno )
 char	*user;
 int	*userno;
{
        static char  *fname = "PDMris_get_userno";

long status;

char sql_stmt[100];

int nfmcatno;

long numberind;

char * err_ptr;





        PDMdebug ("ENTER: PDMris_get_userno\n");
	strcpy (sql_stmt, "");


	sprintf (sql_stmt, "select n_userno from nfmusers where n_username = \'%s\'", user);

        PDMdebug ( sql_stmt);

{RISint_prepare(&RIScpp_stmt_id10,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id10,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	*userno = 0;
	numberind = 0;
	nfmcatno = 0;

{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&nfmcatno;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id10,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug ("nfmcatno: <null>");}
		else
                  {
		  _PDMdebug (fname, "userno: %d\n", nfmcatno);
		  *userno = nfmcatno;
		  }

	  status = SQL_S_SUCCESS;
{RISint_close(RIScpp_stmt_id10, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        PDMdebug ("EXIT: PDMris_get_userno - data found\n");
	return (status);

not_found:

	PDMdebug ("No more data\n");
	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug ("EXIT: PDMris_get_userno - No rows found\n");
{RISint_close(RIScpp_stmt_id10, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
        PDMdebug ("EXIT: PDMris_get_userno with error\n");
{RISint_close(RIScpp_stmt_id10, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);
}

int PDMris_get_catnodesc ( catno , catalog, catdesc)
 int	catno;
 char	*catalog;
 char	*catdesc;
{
        static char  *fname = "PDMris_get_catnodesc";

long status;

char sql_stmt[100];

char cat[20];

char catdes[40];

long numberind;

long descind;

char * err_ptr;





        PDMdebug ("ENTER: PDMris_get_catnodesc\n");
	strcpy (sql_stmt, "");


	sprintf (sql_stmt, "select n_catalogname, n_catalogdesc from nfmcatalogs where n_catalogno = %d", catno);

        PDMdebug ( sql_stmt);

{RISint_prepare(&RIScpp_stmt_id11,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id11,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	numberind = 0;

{{
	static sqlvar out_sqlvar[2] = {
		{0,0,1,1,20,0,{0,""}},
		{0,0,1,1,40,0,{0,""}}
	};
	static sqlda out_sqlda = {2,2,out_sqlvar};
	out_sqlvar[1].sqldata = catdes;
	out_sqlvar[1].sqlind = &descind;
	out_sqlvar[0].sqldata = cat;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id11,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug ("cat: <null>");}
		else
                  {
		  _PDMdebug (fname, "cat: %s\n", cat);
		  _PDMdebug (fname, "catdesc: %s\n", catdes);
                  strcpy (catalog, cat);
                  strcpy (catdesc, catdes);
		  }

	  status = SQL_S_SUCCESS;
        PDMdebug ("EXIT: PDMris_get_catnodesc - data found\n");
{RISint_close(RIScpp_stmt_id11, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);

not_found:

	PDMdebug ("No more data\n");
	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug ("EXIT: PDMris_get_catnodesc - No rows found\n");
{RISint_close(RIScpp_stmt_id11, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
        PDMdebug ("EXIT: PDMris_get_catnodesc with error\n");
{RISint_close(RIScpp_stmt_id11, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return (status);
}

/* 09/09/92 Kumar - This function was written as a API for ppl
programmers. SQLquery is not used because it needs the
knowledge of MEMsub-system, where as the ppl programmers
are aware only standard C datatypes. Moreover this
function is more efficient than SQLquery of NFM in
memory usage*/

/* ALR  8/19/93   Added parameter to know what char to use as a  
   delimeter. The api's will use a control character as the delimeter.
   The delimeter for each piece of data is a ~ character for ppl. This was
   done so that the users could strtok for this character. But, 
   a ~ could be used as data in the database and is not a good
   delimeter. The apis will use a control character as the
   delimeter because our pdmoRisQuery can parse for a control character
   and the user will not have to worry with it. We could not change
   the function because other functions that use the ppl depend on
   a ~ being the delimeter. Therefore, two different delimeters
   will be used depending on the func_flag.
*/ 

long   PDMquery ( ris_query, rows, out_arr, err_code, delim_flag )
char   *ris_query;
int    *rows;
char   **out_arr;
int    *err_code;
char    delim_flag;
{

int i,  count,  extra;

int fetch_over;

int size;

int allocated_size;

int used_size;

char * sql_stmt40;

datetime * ptr;

char * err_ptr;

char ext_buf[10];

        char     data[30], delim_str[10], del_char[2];
        long status = PDM_S_SUCCESS;
        char  *fname = "PDMris_query";

        _PDMdebug (fname, "Enter:\n");
        /* allocate 2 K bytes to output array, initially */
        count = 0 ;
        *out_arr        =  (char *) malloc ( 2048 );
        allocated_size =  2048;
        used_size      =  0;

        _PDMdebug (fname, "ris_query:%s\n", ris_query);
	sql_stmt40 =  ris_query ;

/* ALR  8/19/93  Moved this here because can't do at end of function.
   This pointer is needed by the API's. Free here in case it isn't
   freed  by the PPL's that use it */
	
        if (query_out_desc.sqlvar)
          free (query_out_desc.sqlvar);
        query_out_desc.sqlvar = NULL;

        sprintf (del_char, "%c\0", delim_flag);
 
	/* define exception handlers */
	


	

	/* prepare a dynamic SQL statement */
	
{RISint_prepare(&RIScpp_stmt_id12,sql_stmt40,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


        if (SQLCODE)
        {
           if (SQLCODE != END_OF_DATA)
            {
              status = SQL_E_PREPARE;
              _PDMdebug (fname, "Prepare Failed : status = <0x%.8x>\n", 
              SQL_E_PREPARE);
            }
           else
            {
              status = SQL_I_NO_ROWS_FOUND ;
              _PDMdebug (fname, "No Rows Found : status = <0x%.8x>\n", 
              status);
            }

{RISint_clear(&RIScpp_stmt_id12, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

           return (status);
        }


	/*
	**	if the statement is not a SELECT statement (sqld == 0), 
	**		execute the statement.
	**	else
	**		declare a cursor for, open, and 
        **              fetch from the statement.
	*/
	
	query_out_desc.sqld = 0;
	query_out_desc.sqln = 0;
	query_out_desc.sqlvar = 0;

	/* get the count of output columns */

{RISint_describe(RIScpp_stmt_id12,&query_out_desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



       if (query_out_desc.sqld == 0)
        {
{RISint_clear(&RIScpp_stmt_id12, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

          _PDMdebug (fname, "Not A Query Statement : status = <0x%.8x>\n", 
          SQL_E_NOT_QUERY);
          return (SQL_E_NOT_QUERY);
        }

	/* open the SELECT statement */

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

{RISint_execute(&RIScpp_stmt_id12,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	/*
	**	allocate a sqlvar struct for each column and call describe
	**	again to get information about each result column.
	*/

	query_out_desc.sqlvar = (sqlvar*) calloc ( query_out_desc.sqld, sizeof (sqlvar) );
	query_out_desc.sqln = query_out_desc.sqld;
{RISint_describe(RIScpp_stmt_id12,&query_out_desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	/* allocate buffers for each result column */
	for ( i = 0; i < query_out_desc.sqld; ++i )
	{
/* TR# 139526407. 20/Jul/95 - raj. Allocate for an extra byte.	*/
/*		query_out_desc.sqlvar[i].sqldata = calloc ( 1,query_out_desc.sqlvar[i].sqllen ); */
		query_out_desc.sqlvar[i].sqldata = calloc ( 1,(query_out_desc.sqlvar[i].sqllen + 1));
		query_out_desc.sqlvar[i].sqlind = (long*) calloc ( 1, sizeof (long) );
		query_out_desc.sqlvar[i].sqlnull = 1;
	}
	
	
        strcpy ( *out_arr, "" );
        count = 0;                       /* count of rows fetched */
        fetch_over = 0;                  /* fetch termination flag */

	for ( ; ; )
	{
		/* fetch a row of output */

{RISint_fetch(RIScpp_stmt_id12,0,&query_out_desc,0,7);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	
                /* allocate memory for the output array, if required */

                size = 0;
		for ( i = 0; i < query_out_desc.sqld; ++i )
                {
                     size = size + query_out_desc.sqlvar[i].sqllen 
                                 + 5    /* for Null or nul  */
                                 +1;    /* for final '\0'  */
                }
                used_size = used_size + size;

                if ( used_size >= allocated_size )
                {
                    allocated_size = allocated_size + 1024;
                   (*out_arr) = (char *) realloc ( (char *) (*out_arr),allocated_size); 
                    if (*out_arr == NULL)
                       {
{RISint_close(RIScpp_stmt_id12, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

{RISint_clear(&RIScpp_stmt_id12, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

                         if (query_out_desc.sqlvar)
                           free (query_out_desc.sqlvar);
                          _PDMdebug (fname, "Realloc failed \n","");
                          return (SQL_E_MALLOC);
                       }
                }
	
		/* print all columns */

		for ( i = 0; i < query_out_desc.sqld; ++i )
		{
			/* Print column name */
	
			_PDMdebug (fname, "%-20.20s:\n", 
                                query_out_desc.sqlvar[i].sqlname.sqlnamec ); 
	
			/* Check if value is NULL */
	
			if ( *query_out_desc.sqlvar[i].sqlind < 0 )
			{
				/* NULL data */
                                sprintf (delim_str, "nil%s\0", del_char);
                                strcat ( *out_arr, delim_str );
				continue;
			}
			
			/* Determine data type */

			switch ( query_out_desc.sqlvar[i].sqltype )
			{

                        case DATETIME :

                         ptr  = (datetime *) query_out_desc.sqlvar [i].sqldata ;
                         status = RISdatetime_to_ascii (ptr, data, 
                                          SQLglobal.ris_print_format) ;
                         if (status != RIS_SUCCESS)
                         {
                       _PDMdebug (fname, "RISdatetime_to_ascii : error %ld", 
                           status);
                         return (SQL_E_MESSAGE) ;
                           }
                           strcat ( *out_arr, data );
                           strcat ( *out_arr, del_char);
			break;

	        	case CHARACTER:
					_PDMdebug (fname, "char : %s\n", 
                                                query_out_desc.sqlvar[i].sqldata );
                                        strcat ( *out_arr, 
                                                 query_out_desc.sqlvar[i].sqldata );
                                        strcat ( *out_arr, del_char);
                              
                            _PDMdebug(fname,"size of out_arr %d \n",strlen(*out_arr));
					break;

				case INTEGER:
                                        extra = * (int *)query_out_desc.sqlvar[i].sqldata ;
               
     			_PDMdebug (fname, "integer %d\n", extra); 
                                        sprintf (ext_buf, "%d", extra);
                                        strcat ( *out_arr, 
                                                 ext_buf );
                                        strcat ( *out_arr, del_char );
                            _PDMdebug(fname,"size of out_arr %d \n",strlen(*out_arr));
					break;

				case SMALLINT:	
                                        sprintf (ext_buf, " %hd ", 
                                       * (short*)query_out_desc.sqlvar[i].sqldata);
			     _PDMdebug (fname, "smallint : %hd  %s\n", 
                                       * (short*)query_out_desc.sqlvar[i].sqldata, 
                                                ext_buf ); 
                                        strcat ( *out_arr, ext_buf );
                                        strcat ( *out_arr, del_char );
					break;

				case DOUBLE:
                                        sprintf (ext_buf, " %lf ", 
                                      * (double*)query_out_desc.sqlvar[i].sqldata );
				        _PDMdebug (fname, "double : %lf %s\n", 
                                      * (double*)query_out_desc.sqlvar[i].sqldata, 
                                                ext_buf );
                                        strcat ( *out_arr, ext_buf);
                                        strcat ( *out_arr, del_char );
					break;

				case DECIMAL:
					_PDMdebug (fname, "decimal: %lf\n  %s", 
                                      * (double*)query_out_desc.sqlvar[i].sqldata, 
                                                query_out_desc.sqlvar[i].sqldata );
                                        strcat ( *out_arr, 
                                                 query_out_desc.sqlvar[i].sqldata );
                                        strcat ( *out_arr, del_char );
					break;

				case REAL:
                                        sprintf (ext_buf, " %f ", 
                                       * (float*)query_out_desc.sqlvar[i].sqldata );
					_PDMdebug (fname, "real: %f\n  %s", 
                                       * (float*)query_out_desc.sqlvar[i].sqldata, 
                                                ext_buf); 
                                        strcat ( *out_arr, ext_buf);
                                        strcat ( *out_arr, del_char);
					break;

				default:
				_PDMdebug (fname, "error: unknown out_type" ); 
{RISint_clear(&RIScpp_stmt_id12, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* ALR  8/16/93 This can not be freed if it will be used in the API.
   Let the API free the pointer to the struct and the PPL's free the
   pointer to the struct 
                              if (query_out_desc.sqlvar)
                               free (query_out_desc.sqlvar);
*/
                                 *err_code = - 3 ;
				return (SQL_E_DATA_TYPE);
			}
		}

                /* If rows required equals count, terminate fetch */

                count ++;
                if ( *rows == count )
                {
                     fetch_over = 1;
                     break;
                }
	}
        if ( fetch_over )
        {
        	*rows = count;
        }

        return ( SQL_S_SUCCESS );


not_found:

           if (count == 0)
           {
          status = SQL_I_NO_ROWS_FOUND ;
        _PDMdebug (fname, "No Rows Found : status = <0x%.8x>\n", status);
            }
            else
            {
          status = SQL_S_SUCCESS ;
        _PDMdebug (fname, "Exit : Successful status = <0x%.8x>\n", status);
            }

	*rows = count;
        return (status);
	

error:

RISint_report_error(0,&err_ptr);

        _PDMdebug (fname, "error code: %d\n", risca -> sqlcode ); 
        *err_code = risca -> sqlcode ;
          _PDMdebug (fname, "Error: %s\n", err_ptr );   
          _PDMdebug (fname, "Exit: \n");   
          return (SQL_E_NOT_QUERY);
}

int PDMris_stmt ( sql, err_code )
char *sql;
int  *err_code;
 {
        static char *fname = "PDMris_stmt";

long status;

char * sql_stmt;

char * err_ptr;





        PDMdebug ("ENTER: PDMris_stmt\n");

        sql_stmt = sql;
/*
        sql_stmt = (char *) malloc (sizeof (sql) +1);
        memset (sql_stmt, NULL, (sizeof (sql)+1));

        sql_stmt[0]=0;
        sprintf (sql_stmt, sql);
       
*/

{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	status = SQL_S_SUCCESS;
        PDMdebug ("EXIT: PDMris_stmt\n");
	return (status);

not_found:

	PDMdebug ("No more data\n");
        PDMdebug ("EXIT: PDMris_stmt- not found\n");
	return (PDM_E_TABLE_NOT_FOUND);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
	  }
        *err_code = risca -> sqlcode ;
	status = PDM_E_SQL_STMT;
        PDMdebug ("EXIT: PDMris_stmt - SQL error\n");
	return (status);
}


int PDMget_catno_type
 (
 char	*catalog, 
 int    *catno, 
 char	*type
)
{
        static char  *fname = "PDMget_catno_type";

long status;

char sql_stmt[100];

char ty[5];

int ctno;

long numberind;

long catid;

char * err_ptr;

        char  **data = NULL;
        char mem_str[120];
        int  i, nxi;




        _PDMdebug (fname, "ENTER:\n");
         *catno = -1;
         status = SQL_S_SUCCESS;

	strcpy (sql_stmt, "");
       /* Support added for checking caching cat info */
        if (catno_type != NULL) {
           status = MEMbuild_array (catno_type);
            if (status != MEM_S_SUCCESS) {
               _PDMdebug (fname, "MEMbuild_array failed status %s\n", status);
             }
            if (status == MEM_S_SUCCESS) {
              data = (char **) catno_type->data_ptr;
              for (i=0; i < catno_type->rows; i++) {
                  nxi = i * catno_type->columns;
                  if (!strcmp (data[nxi], catalog)) {
                    *catno = atoi (data[nxi+1]);

            /* added support for catalog type. This fn should return
               both catno and type. MaC 110593 */
                     type[0] = '\0';
                     strcpy (type, data[nxi+2]);

                      _PDMdebug (fname, 
                            "Catno for catalog %s is %d and type [%s]\n", 
                                               catalog, *catno, type);
                      _PDMdebug (fname, "EXIT: - data found\n");
                      return (SQL_S_SUCCESS);
                       }
                }
             }
         }

       if (*catno == -1) {
         sprintf (sql_stmt, 
           "SELECT n_catalogno, n_type FROM  nfmcatalogs  WHERE n_catalogname = '%s'", catalog);
        _PDMdebug (fname, "%s\n", sql_stmt);
{RISint_prepare(&RIScpp_stmt_id13,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */
{RISint_execute(&RIScpp_stmt_id13,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	numberind = 0;
	catid = 0;
{{
	static sqlvar out_sqlvar[2] = {
		{0,0,4,1,4,0,{0,""}},
		{0,0,1,1,5,0,{0,""}}
	};
	static sqlda out_sqlda = {2,2,out_sqlvar};
	out_sqlvar[1].sqldata = ty;
	out_sqlvar[1].sqlind = &numberind;
	out_sqlvar[0].sqldata = (char *)&ctno;
	out_sqlvar[0].sqlind = &catid;
RISint_fetch(RIScpp_stmt_id13,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	if (catid < 0 || numberind < 0) {PDMdebug ("catid: <null>");}
		else
                  {
		  _PDMdebug (fname, "type: %s\n", ty);
		  _PDMdebug (fname, "no: %d\n", ctno);
		  strcpy (type, ty);
                  *catno = ctno;
		  }

{RISint_close(RIScpp_stmt_id13, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	  status = SQL_S_SUCCESS;
        PDMdebug ("PDMget_catno_type - data found\n");
        _PDMdebug (fname, "Updating Cache....\n");
        }

         if (catno_type == NULL)
          {
/*..... Growreg prob ...
            MEMopen (&catno_type);
         ......*/

           _PDMdebug (fname, "Cache not created; Creating Cache....\n");
            status = MEMopen (&catno_type, 1024);
            if (status != MEM_S_SUCCESS) {
               _PDMdebug (fname, "MEMopen failed status %d\n", status);
               _PDMdebug (fname, "EXIT: - data found\n");
	       return (SQL_S_SUCCESS);
              }
             status = MEMwrite_format (catno_type, "n_catalogname", "char(20)");
             if (status == MEM_S_SUCCESS)
             status = MEMwrite_format (catno_type, "n_catalogno", "integer");
             if (status == MEM_S_SUCCESS)
             status = MEMwrite_format (catno_type, "n_type", "char(5)");
             if (status != MEM_S_SUCCESS)
              {
               _PDMdebug (fname, "MEMwrite failed status %d\n", status);
               MEMclose (&catno_type);
              _PDMdebug (fname, "EXIT: - data found\n");
	         return (SQL_S_SUCCESS);
               }
           }
          if ( *catno != -1)
           {
            mem_str[0] = '\0';
            sprintf (mem_str, "%s\1%d\1%s\1", catalog, *catno, ty);
             status = MEMwrite (catno_type, mem_str);
             if (status != MEM_S_SUCCESS)
              {
               _PDMdebug (fname, "MEMwrite failed status %d\n", status);
               MEMclose (&catno_type);
              _PDMdebug (fname, "EXIT: - data found\n");
	         return (SQL_S_SUCCESS);
               }
           _PDMdebug (fname, "Updated Cache....\n");
           }

        PDMdebug ("EXIT: PDMget_catno_type - data found\n");
          return (SQL_S_SUCCESS);
not_found:

	PDMdebug ("No more data\n");
	  status = SQL_I_NO_ROWS_FOUND;
{RISint_close(RIScpp_stmt_id13, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        PDMdebug ("EXIT: PDMget_catno_type - No rows found\n");
	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
         _SQLdebug ( (fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
{RISint_close(RIScpp_stmt_id13, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        PDMdebug ("EXIT: PDMget_catno_type with error\n");
	return (status);
}


int PDMquery_stateno
 (
 char	*catalog, 
 char	*part, 
 char	*rev, 
 char	*statename
)
{
        static char  *fname = "PDMquery_stateno";

long status;

char sql_stmt[100];

char ty[41];

long numberind;

char * err_ptr;





        _PDMdebug (fname, "ENTER:\n");
	strcpy (sql_stmt, "");
sprintf (sql_stmt, "SELECT t2.n_statename FROM %s t1 , nfmstates t2 WHERE t1.n_itemname = '%s' AND t1.n_itemrev = '%s' AND t2.n_stateno = t1.n_stateno", catalog, part, rev);
        _PDMdebug (fname, "%s\n", sql_stmt);
{RISint_prepare(&RIScpp_stmt_id14,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */
{RISint_execute(&RIScpp_stmt_id14,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	numberind = 0;
{{
	static sqlvar out_sqlvar[1] = {
		{0,0,1,1,41,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = ty;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id14,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	if ( numberind < 0) {PDMdebug ("state: <null>");}
		else
                  {
		  _PDMdebug (fname, "state: %s\n", ty);
		  strcpy (statename, ty);
		  }

{RISint_close(RIScpp_stmt_id14, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	  status = SQL_S_SUCCESS;
        PDMdebug ("EXIT: PDMquery_stateno - data found\n");
	return (status);

not_found:

	PDMdebug ("No more data\n");
	  status = SQL_I_NO_ROWS_FOUND;
{RISint_close(RIScpp_stmt_id14, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        PDMdebug ("EXIT: PDMquery_stateno - No rows found\n");
	return (status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug (fname, "%s\n", err_ptr);
         _SQLdebug ((fname, "RIS Error Msg : <%s>\n", risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
{RISint_close(RIScpp_stmt_id14, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        PDMdebug ("EXIT: PDMquery_stateno with error\n");
	return (status);
}
