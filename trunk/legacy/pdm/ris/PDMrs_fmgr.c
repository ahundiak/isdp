#include "ris.h"
static short RIScpp_stmt_id0 = -1;
static short RIScpp_stmt_id1 = -1;
static short RIScpp_stmt_id2 = -1;
#include	<string.h>
#include	<stdio.h>
#include "MEMstruct.h"
#include "SQLerrordef.h"
#include "MSGstruct.h"
#include "DEBUG.h"
#include "ERR.h" 
#include "PDUris_incl.h" 
#include "PDMproto.h" 
#include "PDMris_fnpro.h" 

extern MSGptr SQLmsg_ptr;
extern int    PDMdebug_on;


int PDMris_get_fmgr(catno,partno,sano,move_date,move_time,p_ref2,p_partnum )
 int	catno;
 int	partno;
 int	sano;
 char   *move_date;
 char   *move_time;
 int    *p_ref2;
 int    *p_partnum;

{
        char fname[250] ;

long status;

char sql_stmt[500];

char mv_date[25];

char mv_time[25];

int ref;

int partnum;

long nind;

char * err_ptr;






        PDMdebug("ENTER: PDMris_get_fmgr\n");
        sql_stmt[0]=0;
	strcpy(sql_stmt, "");


	sprintf(sql_stmt,"select pdmwsfiles.p_mdate,pdmwsfiles.p_mtime, pdmfmgr.p_ref2, pdmwsparts.p_partnum from pdmfmgr,pdmwsfiles,pdmwsparts where pdmwsparts.p_partnum = pdmfmgr.p_partnum and pdmwsparts.p_partnum = pdmwsfiles.p_fileno and pdmfmgr.p_sano = %d and pdmwsparts.p_catalogno = %d and pdmwsparts.p_partno = %d",sano,catno,partno);
        PDMdebug(sql_stmt);
{RISint_prepare(&RIScpp_stmt_id0,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */


{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	*p_ref2 = 0;
	nind = 0;

{{
	static sqlvar out_sqlvar[4] = {
		{0,0,1,1,25,0,{0,""}},
		{0,0,1,1,25,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {4,4,out_sqlvar};
	out_sqlvar[3].sqldata = (char *)&partnum;
	out_sqlvar[3].sqlind = &nind;
	out_sqlvar[2].sqldata = (char *)&ref;
	out_sqlvar[2].sqlind = &nind;
	out_sqlvar[1].sqldata = mv_time;
	out_sqlvar[1].sqlind = &nind;
	out_sqlvar[0].sqldata = mv_date;
	out_sqlvar[0].sqlind = &nind;
RISint_fetch(RIScpp_stmt_id0,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (nind < 0) {PDMdebug("p_ref2: <null>");}
		else
                  {
		  _PDMdebug(fname,"p_mdate: %s", mv_date);
		  _PDMdebug(fname,"p_mtime: %s", mv_time);
		  _PDMdebug(fname,"p_ref2: %d", ref);
                  strcpy(move_date,mv_date);
                  strcpy(move_time,mv_time);
                  *p_ref2=ref;
                  *p_partnum=partnum;
		  }

	  status = SQL_S_SUCCESS;
        PDMdebug("EXIT: PDMris_get_fmgr\n");
	  return(status);

not_found:

	_PDMdebug(fname,"No more data\n");
	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug("EXIT: PDMris_get_fmgr\n");
	return(status);

error:
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
         _PDMdebug(fname, "RIS Error Msg : <%s>\n",risca->sqlerrm.sqlerrmc);
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
        PDMdebug("EXIT: PDMris_get_fmgr with error\n");
	return(status);
}

int PDMris_find_references(p_partnum,n_sano,p_ref1,p_ref2 )
 int p_partnum;
 int	n_sano;
 int    *p_ref1;
 int    *p_ref2;

{
        char fname[250];

long status;

char sql_stmt[250];

int ref1;

int ref2;

long nind;

char * err_ptr;






	strcpy(sql_stmt, "");


	sprintf(sql_stmt,"select p_ref1, p_ref2 from pdmfmgr where p_partnum = %d and p_sano = %d",p_partnum,n_sano);
        PDMdebug(sql_stmt);
{RISint_prepare(&RIScpp_stmt_id1,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        if(SQLCODE > 0)
        {
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */


{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	*p_ref2 = 0;
	*p_ref1 = 0;
	nind = 0;

{{
	static sqlvar out_sqlvar[2] = {
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {2,2,out_sqlvar};
	out_sqlvar[1].sqldata = (char *)&ref2;
	out_sqlvar[1].sqlind = &nind;
	out_sqlvar[0].sqldata = (char *)&ref1;
	out_sqlvar[0].sqlind = &nind;
RISint_fetch(RIScpp_stmt_id1,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (nind < 0) {PDMdebug("p_ref2: <null>");}
		else
                  {
		  _PDMdebug(fname,"p_ref1: %d", ref1);
		  _PDMdebug(fname,"p_ref2: %d", ref2);
                  *p_ref1=ref1;
                  *p_ref2=ref2;
		  }

	status = SQL_S_SUCCESS;
        }
	else
        {
	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
         _PDMdebug(fname, "RIS Error Msg : <%s>\n",risca->sqlerrm.sqlerrmc);
          }
           status = SQL_E_PREPARE;
	return(status);
        }
{RISint_close(RIScpp_stmt_id1, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        return(status);

not_found:

	_PDMdebug(fname,"No more data\n");
	  status = SQL_I_NO_ROWS_FOUND;
{RISint_close(RIScpp_stmt_id1, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return(status);

error:
RISint_report_error(0,&err_ptr);

	  puts(err_ptr);
         _PDMdebug(fname, "RIS Error Msg : <%s>\n",risca->sqlerrm.sqlerrmc);
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
     else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
{RISint_close(RIScpp_stmt_id1, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return(status);
}





int PDMris_get_sano( saname, sano )
 char	*saname;
 int	*sano;
{
        static char  *fname = "PDMris_get_sano";

long status;

char sql_stmt[100];

int sa_no;

long numberind;

char * err_ptr;





        PDMdebug("ENTER: PDMris_get_sano\n");
	strcpy(sql_stmt, "");


	sprintf(sql_stmt,
         "select n_sano from nfmstoragearea where n_saname = \'%s\'",
		saname);

        PDMdebug( sql_stmt);

{RISint_prepare(&RIScpp_stmt_id2,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id2,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	*sano = 0;
	numberind = 0;
	sa_no = 0;

{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&sa_no;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id2,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug("sa_no: <null>");}
		else
                  {
		  _PDMdebug(fname,"sa_no: %d\n",sa_no);
		  *sano = sa_no;
		  }

	  status = SQL_S_SUCCESS;
        PDMdebug("EXIT: PDMris_get_sano - data found\n");
{RISint_close(RIScpp_stmt_id2, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return(status);

not_found:

	PDMdebug("No more data\n");
	  status = SQL_I_NO_ROWS_FOUND;
        PDMdebug("EXIT: PDMris_get_sano - No rows found\n");
{RISint_close(RIScpp_stmt_id2, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return(status);

error:
RISint_report_error(0,&err_ptr);

	  _PDMdebug(fname,"%s\n",err_ptr);
         _SQLdebug ((fname, "RIS Error Msg : <%s>\n",risca->sqlerrm.sqlerrmc));
        if (risca -> sqlcode == RIS_E_DUPLICATE_VALUE)
            status = SQL_E_DUPLICATE_VALUE ;
    else if (risca -> sqlcode == RIS_E_TABVIEW_ALREADY_EXISTS)
            status = SQL_E_TABLE_EXISTS ;
     else if (risca -> sqlcode == RIS_E_DUP_ATTR_NAME)
            status = SQL_E_DUP_ATTR_NAME ;
     else
	status = SQL_E_EXECUTE;
{RISint_close(RIScpp_stmt_id2, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        PDMdebug("EXIT: PDMris_get_sano with error\n");
	return(status);
}

