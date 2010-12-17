#include "ris.h"
static short RIScpp_stmt_id0 = -1;
static short RIScpp_stmt_id1 = -1;
static short RIScpp_stmt_id2 = -1;
static short RIScpp_stmt_id3 = -1;
#include	<string.h>
#include	<stdio.h>
#include        "MRPstr.h"
#include        "MRPmessage.h"
#include        "PDMproto.h"
#include        "PDMris_fnpro.h"

/*
Sample Program 1 - Static SQL statements
========================================
*/

extern int PDMdebug_on;
extern char PDM_DEBUG_FILE[];
extern  int MRPstrcpy();
extern struct 	MRPvar        *mrpvar;

struct rMRPattr
   {
    char	*name;
    char	*datatype;
    char	*nulls;
   } *rmrpattr;

struct rMRPcolumn_info
   {
    char	*colname;
    char	*datatype;
    int		maxlen;
    char	**char_values;
    int		*int_values;
   };

int rMRPattr_columno;
int col_total;
int values_total;
int rMRPf_tableno;
int rMRPtableno;
int rMRPv_tableno;

int rMRPrs_free_values ( column_info, number_of_rows, number_of_cols )
   struct rMRPcolumn_info	*column_info; /* array of character strings */
   int				number_of_rows; /* number of rows to free */
   int				number_of_cols; /* number of columns to free */

/******************************************************************************

Doc:	MRPfree_list

Abstract:
	Frees memory allocated for character strings in an array.
	
Algorithm:
	.bp
		1.	For each row and column entry, check to see if the address is NULL.
		2.	If it isn't NULL, free the memory.
		3.	If not the last row and column, go back to step 1.
	.ep
Return Status:
	PDM_S_SUCCESS	-	Successful completion
Caveats:

History:
	9/18/90	-	Documentation date
*****************************************************************************/

   {
   int				status = MRP_S_Success, row, col;
   extern int			PDMdebug_on;
    
   PDMdebug("In the MRPfree list function");
   
     for ( col = 0; col < number_of_cols; ++col )
       {
        if ( column_info[col].char_values != NULL )
	   {
           for ( row = 0; row < number_of_rows; ++row )
             if ( column_info[col].char_values[row] != NULL )
       	      free ( column_info[col].char_values[row] );
	   free ( column_info[col].char_values);
	      column_info[col].char_values = NULL;
           }
        else if ( column_info[col].int_values != NULL )
	   {
	   free ( column_info[col].int_values);
	      column_info[col].int_values = NULL;
           }

       }
    return (status);
   }

/*int MRPrs_clist( cat_total )
 int  *cat_total;
{
 struct MRPcatlist        *mrpcatlist = NULL;
                static char *fname = "MRPrs_clist";
	exec sql begin declare section;
		long status;
		int new_total;
		int  i;
		char sql_stmt[100];
		char nfmcatname[20];
		int  nfmcatno;
		long nameind;
		long numberind;
		char *err_ptr;
	exec sql end declare section;

	exec sql whenever sqlerror goto :error;
	exec sql whenever not found goto :not_found;


	_PDMdebug(fname,"name %s", mrpvar->name);
	strcpy(sql_stmt, "");

	i = 0;
	new_total = 0;
	exec sql select count(*) into :new_total  from nfmcatalogs;
	MRPfree_cat_list (*cat_total);
	mrpvar->cat_list = NULL;
	*cat_total = new_total;
	_PDMdebug(fname,"total = %d", *cat_total);

	if ( mrpcatlist == NULL )
	{
	 PDMdebug("malloc mrpcatlist");
           mrpcatlist = (struct MRPcatlist *) malloc( new_total * sizeof(struct MRPcatlist) );
	 if (mrpcatlist == NULL)
	 PDMdebug("Could not malloc mrpcatlist");
        }
*/

	/* select all rows from the table */
/*
	exec sql declare c1 cursor for
		select n_catalogname, n_catalogno  from nfmcatalogs;
*/

	/* assign a value to be used in the SQL statement */
/*
	exec sql open c1;

	PDMdebug("table nfmcatalogs:");

	nameind = 0;
	numberind = 0;
	strcpy(nfmcatname,"");
	nfmcatno = 0;

	for (;;)
	{
		exec sql fetch c1 into :nfmcatname:nameind, :nfmcatno:numberind;

		if (nameind < 0) {PDMdebug("nfmncatame: <null>");}
		else _PDMdebug(fname,"name: %s", nfmcatname);
		mrpcatlist[i].catalog = NULL;
	  	MRPstrcpy2( &mrpcatlist[i].catalog, nfmcatname );

		if (numberind < 0) {PDMdebug("nfmcatno: <null>");}
		else _PDMdebug(fname,"name: %d", nfmcatno);
		mrpcatlist[i].catalogno = nfmcatno;
		mrpcatlist[i].flag = 0;
		++i;

	nameind = 0;
	numberind = 0;
	strcpy(nfmcatname,"");
	nfmcatno = 0;
	}

not_found:
	exec sql whenever not found continue;
	PDMdebug("No more data");
        if ( mrpcatlist != NULL )
	   status = MRP_S_Success;
	else
	   status = MRP_I_NoCatsFound;
	mrpvar->cat_list = mrpcatlist;
	return(status);

error:
	exec sql whenever sqlerror continue;
	if ( PDMdebug_on )
	  {
	  exec sql report error into :err_ptr;
	  puts(err_ptr);
	  }
	status = MRP_E_NoCatInfo;
	return(status);
}
*/

int MRPrs_get_catno()
{
                static char *fname = "MRPrs_get_catno";

long status;

char sql_stmt[200];

int nfmcatno;

long numberind;

char * err_ptr;






	PDMdebug("MRPrs_get_catno");
	status = MRP_S_Success;
	_PDMdebug(fname,"name %s", mrpvar->name);
	strcpy(sql_stmt, "");


	sprintf(sql_stmt,"select n_tableno from nfmtables where n_tablename = \'%s\'",
		mrpvar->catalog);

        _PDMdebug(fname,"sql_stmt = %s", sql_stmt);

{RISint_prepare(&RIScpp_stmt_id0,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	PDMdebug("table nfmcatalogs:");

	mrpvar->catno = 0;
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
RISint_fetch(RIScpp_stmt_id0,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug("nfmcatno: <null>");}
		else
                  {
		  _PDMdebug(fname,"nfmcatno: %d", nfmcatno);
		  mrpvar->catno = nfmcatno;
		  }

	numberind = 0;
	nfmcatno = 0;
	}

not_found:

	PDMdebug("No more data\n");
	if ( mrpvar->catno != 0 )
	  status = MRP_S_Success;
	else
	  status = MRP_E_NoCatMatch;
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
	  }
	status = MRP_E_NoCatMatch;
	return(status);
}

int MRPrs_mk_elect_cat()
{
                static char *fname = "MRPrs_get_catno";

long status;

char sql_stmt[300];

int max_no;

char * err_ptr;





	PDMdebug("MRPrs_mk_elect_cat");

	_PDMdebug(fname,"name %s", mrpvar->name);
	strcpy(sql_stmt, "");

	max_no = 0;
{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&max_no;
{	static short RIScpp_static_stmt = -1;
RISint_select(&RIScpp_static_stmt,0,"select all max(all n_tableno ) from nfmtables ",0,&out_sqlda,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	++max_no;
	sprintf(sql_stmt,"insert into nfmtables (n_tableno, n_tablename, 		n_tabletype ) values (%d, \'electronics\', \'catalog\')",
		max_no);
        _PDMdebug(fname,"sql_stmt = %s", sql_stmt);

{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	strcpy(sql_stmt, "");
	mrpvar->catno = max_no;
	rMRPtableno = max_no;
	++max_no;
	sprintf(sql_stmt,"insert into nfmtables (n_tableno, n_tablename, 		n_tabletype ) values (%d, \'f_electronics\', \'f_catalog\')",
		max_no);
        _PDMdebug(fname,"sql_stmt = %s", sql_stmt);

{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	strcpy(sql_stmt, "");
	rMRPf_tableno = max_no;
	++max_no;
	sprintf(sql_stmt,"insert into nfmtables (n_tableno, n_tablename, 		n_tabletype ) values (%d, \'pdmsv_electronics\', \'pdmviews\')",
		max_no);
        _PDMdebug(fname,"sql_stmt = %s", sql_stmt);

{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	strcpy(sql_stmt, "");
	rMRPv_tableno = max_no;
        status = rMRPrs_in_nfmcat();
	status = rMRPrs_get_nfmattrs_pdmcat();
        status = MRP_S_Success;
	return(status);

not_found:

	PDMdebug("No more data\n");
	if ( mrpvar->catno != 0 )
	  status = MRP_S_Success;
	else
	  status = MRP_E_NoCatMatch;
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
	  }
	status = MRP_E_NoCatMatch;
	return(status);
}

int rMRPrs_in_nfmcat()
{
                static char *fname = "rMRPrs_in_nfmcat";

long status;

char sql_stmt[500];

int max_no;

char time_attr[10];

char date_attr[10];

char * err_ptr;





	PDMdebug("rMRPrs_in_nfmcat");

	_PDMdebug(fname,"name %s", mrpvar->name);
	strcpy(sql_stmt, "");
	strcpy(time_attr, "");
	strcpy(date_attr, "");

	max_no = mrpvar->catno;
	_PDMdebug(fname,"MAX NO = %d", max_no );
	MRPget_time ( time_attr );
	MRPget_date ( date_attr );
	sprintf(sql_stmt,"insert into nfmcatalogs 		(n_catalogno, n_catalogname, n_catalogdesc, n_stateno, 		n_aclno, n_application, n_type, n_creator, n_creationdate, 		n_creationtime ) 		values 		(%d, \'electronics\', \'electronics catalog\', 10, 3, 		\'PDM\', \'C\', 		\'nfmadmin\', \'%s\', \'%s\')",
		max_no, date_attr, time_attr);
        _PDMdebug(fname,"sql_stmt = %s", sql_stmt);

{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	strcpy(sql_stmt, "");
        status = rMRPrs_mk_cat_tab(1, "electronics");
        status = rMRPrs_mk_cat_tab(2, "f_electronics");
        status = rMRPrs_mk_cat_tab(3, "pdmsv_electronics");

not_found:

	PDMdebug("No more data\n");
	if ( mrpvar->catno != 0 )
	  status = MRP_S_Success;
	else
	  status = MRP_E_NoCatMatch;
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
	  }
	status = MRP_E_NoCatMatch;
	return(status);
}

int rMRPrs_mk_cat_tab( catlst, catalog )
 int  catlst;
 char *catalog;
{

 struct rMRPattr   *rmrpattr = NULL;
                static char *fname = "rMRPrs_mk_cat_tab";

long status;

int i;

int nfmcatno;

int rattr_tot;

char sql_stmt[300];

char nfmattrname[20];

char nfmnull[2];

char nfmattrdat[15];

long atnameind;

long nullind;

long dataind;

char * err_ptr;


     PDMdebug("MRPrs_mk_cat_tab");



        rattr_tot = 0;

	_PDMdebug(fname,"name %s", mrpvar->name );
	strcpy(sql_stmt, "");

	switch ( catlst )
         {
          case 1:

	  /* select all rows from the table */
{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&nfmcatno;
{	static short RIScpp_static_stmt = -1;
RISint_select(&RIScpp_static_stmt,0,"select all n_tableno  from nfmtables  where n_tablename  = 'pdmcatalog0'",0,&out_sqlda,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	   _PDMdebug(fname,"n_tableno = %d", nfmcatno);
           break;

	   case 2:
{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&nfmcatno;
{	static short RIScpp_static_stmt = -1;
RISint_select(&RIScpp_static_stmt,0,"select all n_tableno  from nfmtables  where n_tablename  = 'f_catalog'",0,&out_sqlda,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	   _PDMdebug(fname,"n_tableno = %d", nfmcatno);
           break;

	   case 3:
{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&nfmcatno;
{	static short RIScpp_static_stmt = -1;
RISint_select(&RIScpp_static_stmt,0,"select all n_tableno  from nfmtables  where n_tablename  = 'pdmviews'",0,&out_sqlda,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	   _PDMdebug(fname,"n_tableno = %d", nfmcatno);
           break;
	  }

	i = 0;
{RISint_prepare(&RIScpp_stmt_id1,"select all n_name , n_null , n_datatype  from nfmattributes  where n_tableno  = ?",1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	/* assign a value to be used in the SQL statement */

{{
	static sqlvar in_sqlvar[1] = {
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda in_sqlda = {1,1,in_sqlvar};
	in_sqlvar[0].sqldata = (char *)&nfmcatno;
RISint_execute(&RIScpp_stmt_id1,0,&in_sqlda,7,1,0);
}
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	PDMdebug("table nfmattributes:");

	atnameind = 0;
	nullind = 0;
	dataind = 0;
	strcpy(nfmattrname, "");
	strcpy(nfmnull, "");
	strcpy(nfmattrdat, "");
	rattr_tot = 0;
	rmrpattr = NULL;
	for (;;)
	   {
{{
	static sqlvar out_sqlvar[3] = {
		{0,0,1,1,20,0,{0,""}},
		{0,0,1,1,2,0,{0,""}},
		{0,0,1,1,15,0,{0,""}}
	};
	static sqlda out_sqlda = {3,3,out_sqlvar};
	out_sqlvar[2].sqldata = nfmattrdat;
	out_sqlvar[2].sqlind = &dataind;
	out_sqlvar[1].sqldata = nfmnull;
	out_sqlvar[1].sqlind = &nullind;
	out_sqlvar[0].sqldata = nfmattrname;
	out_sqlvar[0].sqlind = &atnameind;
RISint_fetch(RIScpp_stmt_id1,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

		++rattr_tot;
                if ( rmrpattr != NULL )
		  {
		  PDMdebug("REALLOC rmrpattr");
		  rmrpattr = (struct rMRPattr *) realloc( rmrpattr,
		      ((rattr_tot) * sizeof(struct rMRPattr) ));
		  }
		else
		  {
		  PDMdebug("MALLOC rmrpattr");
		  rmrpattr = (struct rMRPattr *) malloc
			((rattr_tot) * sizeof(struct rMRPattr) );
		  }
		rmrpattr[i].name = NULL;
		rmrpattr[i].nulls = NULL;
		rmrpattr[i].datatype = NULL;

		if (atnameind < 0) {PDMdebug("*** nfmattrname: <null>");}
		else
		   {
 		   _PDMdebug(fname,"*** name: %s", nfmattrname);
	  	   MRPstrcpy( &rmrpattr[i].name, nfmattrname );
		   }

		if (nullind < 0) {PDMdebug("nfmnull: <null>");}
		else
		   {
		   _PDMdebug(fname,"nfmnull: %s", nfmnull);
	  	   MRPstrcpy( &rmrpattr[i].nulls, "Y" );
                   }

		if (dataind < 0) {PDMdebug("nfmattrdat: <null>");}
		else
		   {
		   _PDMdebug(fname,"data: %s", nfmattrdat);
		   MRPstrcpy( &rmrpattr[i].datatype, nfmattrdat );
		   }
		++i;
	   atnameind = 0;
	   nullind = 0;
	   dataind = 0;
	   strcpy(nfmattrname,"");
	   strcpy(nfmnull,"");
	   strcpy(nfmattrdat,"");
	 }

not_found:

	PDMdebug("No more data\n");
       if(rattr_tot != 0)
       {
	for ( i = 0; i < rattr_tot; ++i )
	   if ( i == 0 )
	       status = rMRPrs_create_tab( catalog, rmrpattr[i] );
	   else
	       status = rMRPrs_alter_tab ( catalog, rmrpattr[i] );
	 status = MRP_S_Success;
	return(status);
        }
	status = MRP_E_RisAttr;
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
	  }
	status = MRP_E_RisAttr;
	return(status);
}

int rMRPrs_create_tab( catalog, rmrpattr )
  char  *catalog;
  struct rMRPattr rmrpattr; 
{
                static char *fname = "rMRPrs_create_tab";

long status;

char sql_stmt[200];

char * err_ptr;





	PDMdebug("rMRPrs_create_tab");

	status = MRP_S_Success;
	_PDMdebug(fname,"name %s", mrpvar->name);
	strcpy(sql_stmt, "");

	sprintf(sql_stmt,"create table %s ( %s %s )",
		catalog, rmrpattr.name, rmrpattr.datatype);
        _PDMdebug(fname,"sql_stmt = %s", sql_stmt);

{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	status = MRP_S_Success;
	strcpy(sql_stmt, "");

not_found:

	PDMdebug("No more data\n");
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
	  }
	status = MRP_E_NoCatMatch;
	return(status);
}

int rMRPrs_alter_tab( catalog, rmrpattr )
  char  *catalog;
  struct rMRPattr rmrpattr; 
{
                static char *fname = "rMRPrs_alter_tab";

long status;

char sql_stmt[200];

char * err_ptr;





	PDMdebug("rMRPrs_alter_tab");

	status = MRP_S_Success;
	_PDMdebug(fname,"name %s", mrpvar->name);
	strcpy(sql_stmt, "");

	sprintf(sql_stmt,"alter table %s add %s %s",
		catalog, rmrpattr.name, rmrpattr.datatype);
        _PDMdebug(fname,"sql_stmt = %s", sql_stmt);

{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	status = MRP_S_Success;
	strcpy(sql_stmt, "");

not_found:

	PDMdebug("No more data\n");
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
	  }
	status = MRP_E_NoCatMatch;
	return(status);
}


int rMRPrs_get_nfmattrs_pdmcat()
{
 struct rMRPcolumn_info   *rmrpcolumn_info;
                static char *fname = "rMRPrs_get_nfmattrs_pdmcat";

char sql_stmt[200];

long status;

char nfmcolname[20];

long nameind;

char nfmdata[10];

long dataind;

int nfmmaxlen;

long numberind;

char * err_ptr;





	PDMdebug("rMRPrs_get_nfmattrs_pdmcat");

	_PDMdebug(fname,"name %s", mrpvar->name);

	strcpy(sql_stmt, "");

	/* select nfmattributes rows from the riscolumns table  */

{RISint_prepare(&RIScpp_stmt_id2,"select all column_name , data_type , char_max_length  from riscolumns  where table_name  = 'nfmattributes'",1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id2,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	PDMdebug("table riscolumns:");

	nameind = 0;
	dataind = 0;
	numberind = 0;
	strcpy(nfmcolname,"");
	strcpy(nfmdata,"");
	nfmmaxlen = 0;

        rmrpcolumn_info = NULL;
	col_total = 0;
	for (;;)
	{
{{
	static sqlvar out_sqlvar[3] = {
		{0,0,1,1,20,0,{0,""}},
		{0,0,1,1,10,0,{0,""}},
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {3,3,out_sqlvar};
	out_sqlvar[2].sqldata = (char *)&nfmmaxlen;
	out_sqlvar[2].sqlind = &numberind;
	out_sqlvar[1].sqldata = nfmdata;
	out_sqlvar[1].sqlind = &dataind;
	out_sqlvar[0].sqldata = nfmcolname;
	out_sqlvar[0].sqlind = &nameind;
RISint_fetch(RIScpp_stmt_id2,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if ( col_total == 0 ) 
		  {
	          PDMdebug("malloc rmrpcolumn_info");
		  rmrpcolumn_info = (struct rMRPcolumn_info *) malloc ((col_total+1) * sizeof(struct rMRPcolumn_info) );
	          }
		else
		  {
	          _PDMdebug(fname,"realloc rmrpcolumn_info col_total = %d", col_total);
		  rmrpcolumn_info = (struct rMRPcolumn_info *) realloc ( rmrpcolumn_info,
			((col_total+1)* sizeof(struct rMRPcolumn_info) ));
		  }
		if ( rmrpcolumn_info == NULL )
		  PDMdebug("Could Not Malloc rMRPcolumn_info");

		rmrpcolumn_info[col_total].colname = NULL;
		if (nameind < 0) {PDMdebug("nfmncolname: <null>");}
		else
		   {
		   _PDMdebug(fname,"colname: %s", nfmcolname);
	  	   MRPstrcpy( &rmrpcolumn_info[col_total].colname, nfmcolname );
		   }


		rmrpcolumn_info[col_total].datatype = NULL;
		if (dataind < 0) {PDMdebug("nfmncolname: <null>");}
		else
		   {
		   _PDMdebug(fname,"datatype: %s", nfmdata);
	  	   MRPstrcpy( &rmrpcolumn_info[col_total].datatype, nfmdata );
		   }

		rmrpcolumn_info[col_total].maxlen = 0;
		if (numberind < 0) {PDMdebug("nfmmaxlen: <null>");}
		else
		   {
		   _PDMdebug(fname,"maxlen: %d", nfmmaxlen);
		   rmrpcolumn_info[col_total].maxlen = nfmmaxlen;
		   }

		rmrpcolumn_info[col_total].int_values = NULL;
		rmrpcolumn_info[col_total].char_values = NULL;
		++col_total;

	nameind = 0;
	numberind = 0;
	dataind = 0;
	strcpy(nfmcolname,"");
	strcpy(nfmdata,"");
	nfmmaxlen = 0;
	}

not_found:

	PDMdebug("No more data\n");
	status = MRP_S_Success;
	rMRPrs_fill_nfmattr_values(1, rmrpcolumn_info);
	rMRPrs_fill_nfmattr_rows(rmrpcolumn_info);
	rMRPrs_fill_nfmattr_values(2, rmrpcolumn_info);
	rMRPrs_fill_nfmattr_rows(rmrpcolumn_info);
	rMRPrs_fill_nfmattr_values(3, rmrpcolumn_info);
	rMRPrs_fill_nfmattr_rows(rmrpcolumn_info);
	rmrpcolumn_info = NULL;
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
	  }
	status = MRP_E_NoCatMatch;
	return(status);
}

int rMRPrs_fill_nfmattr_values( cattype, rmrpcolumn_info )
 int	cattype;
 struct rMRPcolumn_info   *rmrpcolumn_info;
{
                static char *fname = "rMRPrs_fill_nfmattrs_values";

long status;

int i;

int j;

char cattmp[30];

char sql_stmt[400];

int val_total;

int int_value;

int max_attrno;

char char_value[51];

int tableno;

int new_tableno;

long charind;

long intind;

char * err_ptr;





	PDMdebug("rMRPrs_fill_nfmattr_values");
	_PDMdebug(fname,"name %s", mrpvar->name);
	strcpy(sql_stmt, "");

	max_attrno = 0;
{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&max_attrno;
{	static short RIScpp_static_stmt = -1;
RISint_select(&RIScpp_static_stmt,0,"select all max(all n_attrno ) from nfmattributes ",0,&out_sqlda,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	_PDMdebug(fname,"max_attrno = %d", max_attrno);

	if ( mrpvar->catalog != NULL )
	  strcpy(cattmp, mrpvar->catalog);
	if ( cattype == 1 )
	  {
	  MRPstrcpy( &mrpvar->catalog, "pdmcatalog0");
	  new_tableno = rMRPtableno;
	  }
	else if ( cattype == 2 )
	  {
	  MRPstrcpy( &mrpvar->catalog, "f_catalog");
	  new_tableno = rMRPf_tableno;
	  }
	else
	  {
	  MRPstrcpy( &mrpvar->catalog, "pdmviews");
	  new_tableno = rMRPv_tableno;
	  }
        MRPrs_get_catno();
	tableno = mrpvar->catno;
	val_total = 0;
{
	static sqlvar in_sqlvar[1] = {
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda in_sqlda = {1,1,in_sqlvar};
	static sqlvar out_sqlvar[1] = {
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&val_total;
{	static short RIScpp_static_stmt = -1;
	in_sqlvar[0].sqldata = (char *)&tableno;
RISint_select(&RIScpp_static_stmt,0,"select all count(*) from nfmattributes  where n_tableno  = ?",&in_sqlda,&out_sqlda,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	_PDMdebug(fname,"tableno = %d, val_total = %d", tableno, val_total); 
	values_total = val_total;

        charind = 0;
	intind = 0;
	strcpy(char_value, "");
	int_value = 0;
	_PDMdebug(fname,"col_total = %d", col_total);
        for ( i = 0; i < col_total; ++i )
          {
	  if ( strcmp ( rmrpcolumn_info[i].colname, "n_attrno" ) == 0 )
	    /* malloc  and insert values */
	    {
	    for ( j = 0; j < values_total; ++j )
	      {
	        if ( j == 0 )
		  {
	          _PDMdebug(fname,"malloc rmrpcolumn_info[%d].int_values", i);
                  rmrpcolumn_info[i].int_values = (int *) malloc( values_total * sizeof(int) );
	          if ( rmrpcolumn_info[i].int_values == NULL )
	          PDMdebug("Could not malloc rmrpcolumn_info[i].int_values");
		  }
		rmrpcolumn_info[i].int_values[j] = ++max_attrno;
		}
	     rMRPattr_columno = i;
	    }

	  else if ( strcmp ( rmrpcolumn_info[i].colname, "n_tableno" ) == 0 )
	    for ( j = 0; j < values_total; ++j )
	      {
	      if ( j == 0 )
	        {
	         _PDMdebug(fname,"malloc rmrpcolumn_info[%d].int_values", i);
                 rmrpcolumn_info[i].int_values = (int *) malloc( values_total * sizeof(int) );
	         if ( rmrpcolumn_info[i].int_values == NULL )
	         PDMdebug("Could not malloc rmrpcolumn_info[i].int_values");
	         }
	       rmrpcolumn_info[i].int_values[j] = new_tableno;
	       }

	  else
	    {

	     sprintf(sql_stmt,"select %s from nfmattributes where 		  n_tableno = %d", rmrpcolumn_info[i].colname, tableno);
             _PDMdebug(fname,"sql_stmt = %s", sql_stmt);

{RISint_prepare(&RIScpp_stmt_id3,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	     /* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id3,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	     if ( strcmp( rmrpcolumn_info[i].datatype, "int" ) == 0 )
		{ 
	          _PDMdebug(fname,"malloc rmrpcolumn_info[%d].int_values", i);
                  rmrpcolumn_info[i].int_values = (int *) malloc( values_total * sizeof(int) );
	          if ( rmrpcolumn_info[i].int_values == NULL )
	          PDMdebug("Could not malloc rmrpcolumn_info[i].int_values");
	          for ( j = 0; j < values_total; ++j )
	          {
		   rmrpcolumn_info[i].int_values[j] = 0;
{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&int_value;
	out_sqlvar[0].sqlind = &intind;
RISint_fetch(RIScpp_stmt_id3,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

		   if ( intind < 0 )
		     {PDMdebug("int_value: <null>");}
		   else
		     {
		     _PDMdebug(fname,"int_value = %d", int_value);
		     rmrpcolumn_info[i].int_values[j] = int_value;
/*		     printf("rmrpcolumn_info[%d].int_values[%d] = %d\n", i, j, rmrpcolumn_info[i].int_values[j]); */
		     }
	           strcpy(char_value, "");
	           int_value = 0;
                   charind = 0;
	           intind = 0;
	           strcpy(sql_stmt, "");
	           }
		}
	      else
		{
	          _PDMdebug(fname,"malloc rmrpcolumn_info[%d].char_values", i);
                  rmrpcolumn_info[i].char_values = (char **) malloc( values_total * sizeof(char *) );
	          if ( rmrpcolumn_info[i].char_values == NULL )
	          PDMdebug("Could not malloc rmrpcolumn_info[i].char_values");
	          for ( j = 0; j < values_total; ++j )
	            {
		    rmrpcolumn_info[i].char_values[j] = NULL;
{{
	static sqlvar out_sqlvar[1] = {
		{0,0,1,1,51,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = char_value;
	out_sqlvar[0].sqlind = &charind;
RISint_fetch(RIScpp_stmt_id3,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

		    if ( charind < 0 )
		       {PDMdebug("char_value: <null>");}
		    else
		       {
		       if ( rmrpcolumn_info[i].maxlen == 1 )
			 char_value[1] = '\0';
		       _PDMdebug(fname,"char_value = %s", char_value);
		       MRPstrcpy(&(rmrpcolumn_info[i].char_values[j]), char_value);
/*		       if ( rmrpcolumn_info[i].char_values[j] != NULL )
		          printf("rmrpcolumn_info[%d].char_values[%d] = %s\n", i, j, rmrpcolumn_info[i].char_values[j]);
		       else
		          printf("rmrpcolumn_info[%d].char_values[%d] = <NULL>\n", i, j); */
		       }
	      	    strcpy(char_value, "");
	            int_value = 0;
                    charind = 0;
	            intind = 0;
	            strcpy(sql_stmt, "");
	  	    } /* end of for char row loop */
		 } /* end of else in datatype check */
         } /* end of else in type of attr check */
	} /* end of for column loop */

not_found:

	PDMdebug("No more data\n");
	status = MRP_S_Success;
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
	  }
	status = MRP_E_NoCatMatch;
	return(status);
}

int rMRPrs_fill_nfmattr_rows(rmrpcolumn_info)
 struct rMRPcolumn_info   *rmrpcolumn_info;
{
                static char *fname = "rMRPrs_fill_nfmattrs_rows";

long status;

int i;

int j;

char sql_stmt[400];

char * err_ptr;






	PDMdebug("rMRPrs_fill_nfmattr_rows");
	_PDMdebug(fname,"name %s", mrpvar->name);
	strcpy(sql_stmt, "");

	for ( j = 0; j < values_total; ++j )
	  {
	   sprintf(sql_stmt,"insert into nfmattributes ( %s ) values ( %d )",
	      rmrpcolumn_info[rMRPattr_columno].colname, rmrpcolumn_info[rMRPattr_columno].int_values[j] );
	   _PDMdebug(fname,"sql_stmt = %s", sql_stmt);
{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	   strcpy(sql_stmt, "");
	  }

	for ( j = 0; j < values_total; ++j )
          {

	  /* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id3,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


          for ( i = 0; i < col_total; ++i )
	      {
	      if ((( strcmp( rmrpcolumn_info[i].datatype, "int" ) == 0 ) &&
		   ( rmrpcolumn_info[i].int_values != NULL)) &&
		   ( rmrpcolumn_info[i].int_values[j] != NULL ))
		{ 
		if ( i != rMRPattr_columno )
		  {
		  _PDMdebug (fname, "i = %d", i);
		  _PDMdebug (fname, "j = %d", j);
	          sprintf( sql_stmt,"update nfmattributes set %s = %d 		    where n_attrno = %d",
		    rmrpcolumn_info[i].colname, rmrpcolumn_info[i].int_values[j],
		    rmrpcolumn_info[rMRPattr_columno].int_values[j] );
		  _PDMdebug(fname,"sql_stmt = %s", sql_stmt);
{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

		  }
		strcpy(sql_stmt, "");
	        }
	      else if ((( rmrpcolumn_info[i].char_values != NULL ) && 
		       ( rmrpcolumn_info[i].char_values[j] != NULL)) &&
			( strcmp( rmrpcolumn_info[i].char_values[j], "") != 0 ))
		{
		if ( i != rMRPattr_columno )
		  {
		  _PDMdebug (fname, "i = %d", i);
		  _PDMdebug (fname, "j = %d", j);
	          sprintf( sql_stmt,"update nfmattributes set %s = \'%s\' 		    where n_attrno = %d",
		    rmrpcolumn_info[i].colname, rmrpcolumn_info[i].char_values[j],
		    rmrpcolumn_info[rMRPattr_columno].int_values[j] );
		  _PDMdebug(fname,"sql_stmt = %s", sql_stmt);
{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

		  }
		strcpy(sql_stmt, "");
	  	}
	  _PDMdebug(fname,"DONE WITH ONE ROW i = %d   j= %d", i, j);
	  }
	  _PDMdebug(fname,"2 DONE WITH ONE ROW i = %d   j= %d", i, j);
        status = MRP_S_Success;
        }
	PDMdebug("BEFORE FREE");
/*	rMRPrs_free_values( rmrpcolumn_info, values_total, col_total ); */

not_found:

	PDMdebug("No more data\n");
	status = MRP_S_Success;
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
	  }
	status = MRP_E_NoCatMatch;
	return(status);
}

