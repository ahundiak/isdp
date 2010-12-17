#include "ris.h"
static short RIScpp_stmt_id0 = -1;
static short RIScpp_stmt_id1 = -1;
#include	<string.h>
#include	<stdio.h>
#include	<math.h>
#include        "MRPstr.h"
#include        "MRPintdef.h"
#include        "MRPmessage.h"
#include        "PDMproto.h"
#include        "PDMris_fnpro.h"

/*
Sample Program 1 - Static SQL statements
========================================
*/

extern int PDMdebug_on;
extern int MRPlevel;
extern  int MRPstrcpy();
extern struct 	MRPvar        *mrpvar;

int PSUrs_get_pitemno( p_itemno )
 int  *p_itemno;
{
                static char *fname = "PSUrs_get_pitemno";

long status;

int i;

char sql_stmt[300];

int pitemno;

long pitemind;

char * err_ptr;





/*	if (mrpvar->name != NULL)
	  {
	_PDMdebug(fname,"name %s", mrpvar->name);
	sprintf(sql_stmt,"default schema %s.%s", mrpvar->name, mrpvar->passwd);
	exec sql execute immediate :sql_stmt;
*/	strcpy(sql_stmt, "");

	i = 0;

        PDMdebug("MRPrs_items- get pitemno");
	/**** Itemno checks ****/
        sprintf(sql_stmt, "select n_itemno from %s where p_partnum = \'%s\'and p_revision = \'%s\'",
	        mrpvar->catalog, mrpvar->partid, mrpvar->revision);
	_PDMdebug(fname,"%s", sql_stmt);
{RISint_prepare(&RIScpp_stmt_id0,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	
        pitemno = 0;
	for (;;)
	{
{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&pitemno;
	out_sqlvar[0].sqlind = &pitemind;
RISint_fetch(RIScpp_stmt_id0,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

		if (pitemind < 0)
		   {PDMdebug("pitemno: <null>");}
		else 
		   {
		    _PDMdebug(fname,"pitemno: %d", pitemno);
		    *p_itemno = pitemno;
		   }
        }


/*          }
	else
           status = MRP_E_NotLogin;
	return(status); */

not_found:

	PDMdebug("No more data\n");
        if ( pitemno > 0 )
	  status = MRP_S_Success;
	else
	  status = MRP_I_NoPartMatch;
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
	  }
	status = MRP_E_RisPartItem;
	return(status);
}

int PSUrs_get_bomname( pitemno, bomname )
 int   pitemno;
 char  *bomname;
{
                static char *fname = "PSUrs_get_bomname";

long status;

int i;

int catno;

char sql_stmt[300];

char pbomname[21];

long bomind;

char * err_ptr;





/*	if (mrpvar->name != NULL)
	  {
	_PDMdebug(fname,"name %s", mrpvar->name);
	sprintf(sql_stmt,"default schema %s.%s", mrpvar->name, mrpvar->passwd);
	exec sql execute immediate :sql_stmt;
*/	strcpy(sql_stmt, "");

        PDMdebug("MRPrs_items- get mbomname");
	i = 0;
	catno = mrpvar->catno;
	sprintf(sql_stmt, "select p_bomname from pdmboms where p_catalogno = %d and p_partno = %d", mrpvar->catno, pitemno);
	_PDMdebug(fname,"%s", sql_stmt); 

{RISint_prepare(&RIScpp_stmt_id1,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	
	bomind = 0;
	strcpy(pbomname, NULLSTR);
	for (;;)
	  {
{{
	static sqlvar out_sqlvar[1] = {
		{0,0,1,1,21,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = pbomname;
	out_sqlvar[0].sqlind = &bomind;
RISint_fetch(RIScpp_stmt_id1,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

		if (bomind < 0)
		   {PDMdebug("pbomname: <null>");}
		else 
		   {
		    _PDMdebug(fname,"bomname: %s", pbomname);
		    strcpy(bomname, pbomname);
		   }
          }


/*          }
	else
          status = MRP_E_NotLogin;
	return(status); */

not_found:

	PDMdebug("No more data\n");
	if ( strcmp(bomname, "") != 0 )
	   {
	   bomname[0] = 'b';
	   bomname[1] = 'o';
	   bomname[2] = 'm';
	   status = MRP_S_Success;
	   }
	else
	   status = MRP_E_NoPDMBOM;
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
	  }
	status = MRP_E_RisBOMName;
	return(status);
}

