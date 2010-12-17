#include "ris.h"
static short RIScpp_stmt_id0 = -1;
static short RIScpp_stmt_id1 = -1;
static short RIScpp_stmt_id2 = -1;
#include	<string.h>
#include	<stdio.h>
#include        "MRPstr.h"
#include        "rMRPstr.h"
#include        "MRPmacros.h"
#include        "MRPmessage.h"
#include        "dbadev.h"
#include	"MEMstruct.h"
#include	"MEMerrordef.h"
#include	"NFMerrordef.h"
#include	"PDUris_incl.h"
#include	"PDUerror.h"
#include	"PDMproto.h"
#include	"PDMris_fnpro.h"

/*
Sample Program 1 - Static SQL statements
========================================
*/

extern int PDMdebug_on;
extern  int MRPstrcpy();
extern struct 	MRPvar        *mrpvar;
extern char *errmsg;

int PSUrs_cre_rpt( psurpt, schemaname, schemapwd)
struct PSUrpt	*psurpt;
char		*schemaname;
char		*schemapwd;
{
       static char *fname = "PSUrs_cre_rpt";
	char schema[80];
        long status;

	_PDMdebug(fname,"PSUrs_cre_rpt\n");
	status = MRP_S_Success;
        sprintf(schema, "%s.%s", schemaname, schemapwd);
	status = PSUexe_rpt(psurpt, schema);
        return(status);

}


int PSUrs_load_rpt(psurpt)
struct PSUrpt	*psurpt;
{
       static char *fname = "PSUrs_load_rpt";
       long status;

	_PDMdebug(fname,"ENTER\n");

	status = MRP_S_Success;
	
	status = PSUrs_load_rptopt(psurpt);
	status = PSUrs_load_rptlst(psurpt);

	_PDMdebug(fname,"EXIT\n");
	return(status);
}


int PSUrs_cre_rtabs()
{
       static char *fname = "PSUrs_cre_rtabs";

long status;

char sql_stmt[200];

char * err_ptr;





	_PDMdebug(fname,"PSUrs_cre_rtabs\n");
	status = MRP_S_Success;
	strcpy(sql_stmt, "");

{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,"create table psurptopts (p_templateno int not null, p_table char( 30), p_templatename char( 20) not null, p_templatetype char( 2), p_description char( 50), p_output char( 50), p_title char( 50), p_subtotals int, p_totals int, p_width int, p_lines int, p_templib char( 20)) ",0,7,0,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,"create table psurptlist (p_templateno int not null, p_name char( 18) not null, p_header char( 30) not null, p_type int, p_start int, p_length int, p_decimal int, p_sort int, p_subtotal int, p_total int, p_justification int) ",0,7,0,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	status = MRP_S_Success;
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  _PDMdebug(fname,"%s/n",err_ptr);
	  }
	status = MRP_E_NoCatMatch;
	_PDMdebug(fname,"Exit\n");
	return(status);
}


int PSUrs_get_tempno( psurpt, tempno, tmptype )
 struct PSUrpt *psurpt;
 int *tempno;
 int tmptype;
{
       static char *fname = "PSUrs_get_tempno";

long status;

char sql_stmt[200];

int tmpno;

long numberind;

char * err_ptr;






	_PDMdebug(fname,"PSUrs_get_tempno\n");
	status = MRP_S_Success;
	strcpy(sql_stmt, "");

	*tempno = 0;
	tmpno = 0;
	if ( tmptype == 1 )
   sprintf( sql_stmt, "select p_templateno from psurptopts where p_templatename = '%s' AND p_templatetype = '%s'", psurpt->options.template_name, psurpt->templatetype);
	else
	   strcpy( sql_stmt, "select max(p_templateno) from psurptopts");
        _PDMdebug(fname,"sql_stmt = %s\n", sql_stmt);

{RISint_prepare(&RIScpp_stmt_id0,sql_stmt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);


	/* assign a value to be used in the SQL statement */

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	numberind = 0;
	tmpno = 0;

	for (;;)
	{
{{
	static sqlvar out_sqlvar[1] = {
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {1,1,out_sqlvar};
	out_sqlvar[0].sqldata = (char *)&tmpno;
	out_sqlvar[0].sqlind = &numberind;
RISint_fetch(RIScpp_stmt_id0,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (numberind < 0) {PDMdebug("tmpno: <null>\n");}
		else
                  {
		  _PDMdebug(fname,"tmpno: %d\n", tmpno);
		  *tempno = tmpno;
		  }

	numberind = 0;
	tmpno = 0;
	}
{RISint_close(RIScpp_stmt_id0, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	_PDMdebug(fname,"EXIT:\n");
	return(MRP_S_Success);

not_found:

	if ( *tempno != 0 )
	  status = MRP_S_Success;
	else
	  status = MRP_E_NoCatMatch;
{RISint_close(RIScpp_stmt_id0, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        _PDMdebug(fname,"Exit\n");
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  _PDMdebug(fname,"%s/n",err_ptr);
	  }
	status = MRP_E_NoCatMatch;
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

        _PDMdebug(fname,"Exit\n");
	return(status);
}

int PSUrs_update_rpt(psurpt)
struct PSUrpt *psurpt;
{
       static char *fname = "PSUrs_update_rpt";

long status;

int i;

int tempno;

char sql_stmt[2024];

char * err_ptr;





	_PDMdebug(fname,"Enter\n");
	strcpy(sql_stmt, "");

	tempno = 0;
	status = PSUrs_get_tempno( psurpt, &tempno, 1 );

	i = 0;
        if (tempno != 0)
        {
	if ( psurpt->templib != NULL )
        {
         sql_stmt[0]='\0';
	sprintf( sql_stmt,"update psurptopts set p_table = '%s',  p_templatename = '%s', p_templatetype = '%s', p_description = '%s', p_output = '%s', p_title = '%s', p_subtotals = %d, p_totals = %d, p_width = %d, p_lines = %d, p_templib = '%s' where p_templateno = %d", psurpt->options.table, psurpt->options.template_name, psurpt->templatetype, psurpt->options.description, psurpt->options.output, psurpt->options.title, psurpt->options.subtotals, psurpt->options.totals, psurpt->options.width, psurpt->options.lines, psurpt->templib, tempno );
	_PDMdebug(fname,"%s/n", sql_stmt);
        }
        else
        {
         sql_stmt[0]='\0';
	sprintf( sql_stmt,"update psurptopts set p_table = '%s', p_templatename = '%s', p_templatetype = '%s', p_description = '%s', p_output = '%s', p_title = '%s', p_subtotals = %d, p_totals = %d, p_width = %d, p_lines = %d where p_templateno = %d", psurpt->options.table, psurpt->options.template_name, psurpt->templatetype, psurpt->options.description, psurpt->options.output, psurpt->options.title, psurpt->options.subtotals, psurpt->options.totals, psurpt->options.width, psurpt->options.lines, tempno );
	_PDMdebug(fname,"%s/n", sql_stmt);
        }
{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	for (i = 0; i < psurpt->list_total; ++i)
         {
	 if ( psurpt->list[i].start !=0 )
         {
           sql_stmt[0]='\0';
	sprintf( sql_stmt,"update psurptlist set p_header = '%s', p_type = %d, p_start = %d, p_length = %d, p_decimal = %d, p_sort = %d, p_subtotal = %d, p_total = %d, p_justification = %d where p_templateno = %d and p_name = '%s'", psurpt->list[i].header, psurpt->list[i].type, psurpt->list[i].start, psurpt->list[i].length, psurpt->list[i].decimal, psurpt->list[i].sort, psurpt->list[i].subtotal, psurpt->list[i].total, psurpt->justification[i], tempno, psurpt->list[i].name);
	_PDMdebug(fname,"%s/n", sql_stmt);
        }
	 else
        {
         sql_stmt[0]='\0';
	sprintf(sql_stmt,"delete from psurptlist where p_name = '%s' and p_templateno = %d", psurpt->list[i].name, tempno);
	_PDMdebug(fname,"%s/n", sql_stmt);
        }
	
{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

uprptl: 
        PDMdebug("GOING to Insert\n");
        }
        }
	else
	   {
	   status = PSUrs_insert_rpt(psurpt);
	   }

	return(status);

not_found:

	if ( tempno == 0 )
	  PSUrs_insert_rpt(psurpt);
	else
	  {
          if ((psurpt != NULL) && ((i < psurpt->list_total ) && ( i > 0)))
	      {
	      status = PSUrs_insert_rptlst(psurpt, i, tempno);
	      goto uprptl;
	      }
	  else
	      status = MRP_S_Success;
	  }
        _PDMdebug(fname,"Exit\n");
	return(status);

error:

	if ( risca->sqlcode == RIS_E_UNKNOWN_RELATION )
	  {
	   PDMdebug("before call to PSUrs_cre_rtabs\n");
	   status = PSUrs_cre_rtabs();
	  }
	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  _PDMdebug(fname,"%s/n",err_ptr);
	  }
	status = MRP_E_NoCatMatch;
        _PDMdebug(fname,"Exit-ERROR\n");
	return(status);
}

int PSUrs_insert_rpt(psurpt)
struct PSUrpt *psurpt;
{
int	tmpno;
       static char *fname = "PSUrs_insert_rpt";

long status;

int i;

int tempno;

char sql_stmt[1024];

char * err_ptr;





	PDMdebug("PSUrs_insert_rpt:ENTER...\n");

	strcpy(sql_stmt, "");

	tempno = 0;
	_PDMdebug(fname,"tempno = %d", tempno);
	
	PSUrs_get_tempno( psurpt, &tmpno, 2);
	tempno = tmpno;
	status = MRP_S_Success;
	++tempno;
	_PDMdebug(fname,"tempno = %d\n", tempno);
	strcpy(sql_stmt, "");
        if ( psurpt->templib != NULL || !strcmp(psurpt->templib,""))
	sprintf(sql_stmt, "insert into psurptopts (p_templateno, p_table, p_templatename, p_templatetype, p_description,  p_title,  p_subtotals, p_totals, p_width, p_lines, p_templib ) values (%d, '%s', '%s', '%s', '%s', '%s', %d, %d, %d, %d, '%s')",
	    tempno,
	    psurpt->options.table,
	    psurpt->options.template_name,
	    psurpt->templatetype,
	    "PDM Report",
	    psurpt->options.title,
	    psurpt->options.subtotals,
	    psurpt->options.totals,
	    psurpt->options.width,
	    psurpt->options.lines,
	    psurpt->templib);
        else
	sprintf(sql_stmt, "insert into psurptopts (p_templateno, p_table, p_templatename, p_templatetype, p_description, p_title,  p_subtotals, p_totals, p_width, p_lines ) values (%d, '%s', '%s', '%s', '%s', '%s', %d, %d, %d, %d )",
	    tempno,
	    psurpt->options.table,
	    psurpt->options.template_name,
	    psurpt->templatetype,
	    "PDM Report",
	    psurpt->options.title,
	    psurpt->options.subtotals,
	    psurpt->options.totals,
	    psurpt->options.width,
	    psurpt->options.lines );
          _PDMdebug(fname,"SQLstmt: %s\n",sql_stmt);
{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	strcpy(sql_stmt, "");
        if ( psurpt->list != NULL )
	for (i = 0; i < psurpt->list_total; ++i)
        {
	if ( psurpt->list[i].start !=0 )
         {
	sprintf( sql_stmt,"insert into psurptlist (p_templateno, p_name, p_header, p_type, p_start, p_length, p_decimal, p_sort, p_subtotal,  p_total, p_justification ) values ( %d, '%s', '%s', %d, %d, %d, %d, %d, %d, %d, %d )",
	    tempno,
	    psurpt->list[i].name,
	    psurpt->list[i].header,
	    psurpt->list[i].type,
	    psurpt->list[i].start,
	    psurpt->list[i].length,
	    psurpt->list[i].decimal,
	    psurpt->list[i].sort,
	    psurpt->list[i].subtotal,
	    psurpt->list[i].total,
	    psurpt->justification[i] );
          _PDMdebug(fname,"SQLstmt: %s\n",sql_stmt);
{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        }
        }
	_PDMdebug(fname,":EXIT...\n");
	return(status);

not_found:

	PDMdebug("No more data\n");
	if ( tempno != 0 )
	  status = MRP_S_Success;
	PDMdebug("PSUrs_insert_rpt:NODATA...\n");
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  _PDMdebug(fname,"%s/n",err_ptr);
	  }
	if ( risca->sqlcode == RIS_E_UNKNOWN_RELATION )
	  {
	   PDMdebug("before call to PSUrs_cre_rtabs\n");
	   status = PSUrs_cre_rtabs();
	   PDMdebug("GOING to Insert\n");
	   status = PSUrs_insert_rpt(psurpt);
	  }
	status = MRP_E_NoCatMatch;
	PDMdebug("PSUrs_insert_rpt:ERROR...\n");
	return(status);
}

int PSUrs_insert_rptlst(psurpt, row, tempno)
struct PSUrpt *psurpt;
int row;
int tempno;
{
       static char *fname = "PSUrs_insert_rptlst";

long status;

char sql_stmt[500];

char * err_ptr;





	_PDMdebug(fname,"ENTER:\n");
	strcpy(sql_stmt, "");

	status = MRP_S_Success;


	if ( ( psurpt->list != NULL ) && ( psurpt->list[row].start !=0 ))
	sprintf( sql_stmt,"insert into psurptlist (p_templateno, p_name, 	    p_header, p_type, p_start, p_length, p_decimal, p_sort, p_subtotal, 	    p_total, p_justification ) values ( %d, \'%s\', \'%s\', %d, %d, %d, %d, %d, %d, %d, %d)",
	    tempno,
	    psurpt->list[row].name,
	    psurpt->list[row].header,
	    psurpt->list[row].type,
	    psurpt->list[row].start,
	    psurpt->list[row].length,
	    psurpt->list[row].decimal,
	    psurpt->list[row].sort,
	    psurpt->list[row].subtotal,
	    psurpt->list[row].total,
	    psurpt->justification[row] );
{static short RIScpp_exec_imm_stmt = -1;
RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,sql_stmt,0,7,0,0);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	_PDMdebug(fname,"EXIT:\n");
	return(status);

not_found:

	PDMdebug("No more data\n");
	if ( tempno != 0 )
	  status = MRP_S_Success;
	_PDMdebug(fname,"EXIT:\n");
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  _PDMdebug(fname,"%s/n",err_ptr);
	  }
	status = MRP_E_NoCatMatch;
	_PDMdebug(fname,"EXIT:-ERROR\n");
	return(status);
}

int PSUrs_load_rptlst( psurpt )
 struct PSUrpt *psurpt;
{
       static char *fname = "PSUrs_load_rptlst";
struct dba_default_list *rptlist = NULL;
       MEMptr tmp_bufr = NULL;
       char   sql_str[250];
       char   **tmp_data;
int *justification = NULL;

long status;

int new_total;

int i;

int tempno;

char sql_stmt[300];

char name[20];

long nameind;

char header[30];

long headerind;

int type;

long typeind;

int start;

long startind;

int length;

long lengthind;

int decimal;

long decimalind;

int sort;

long sortind;

int subtotal;

long subtotalind;

int total;

long totalind;

int justify;

long justind;

char * err_ptr;





	_PDMdebug(fname,"ENTER:\n");
	strcpy(sql_stmt, "");
	new_total = 0;
	tempno = 0;
	status = PSUrs_get_tempno( psurpt, &tempno, 1 );
        if (tempno != 0)
        {
       sprintf(sql_str,"SELECT p_templateno FROM psurptlist where p_templateno = %d \n",tempno);
         status = SQLquery(sql_str,&tmp_bufr,512);
           if(status != SQL_S_SUCCESS)
             {
              _PDMdebug(fname,"TEMPLATE has no info\n");
               return(status);
             }
            status = MEMbuild_array(tmp_bufr);
            if(status != MEM_S_SUCCESS)
             {
              _PDMdebug(fname,"TEMPLATE has no info\n");
               return(status);
             }
             tmp_data  = (char**) tmp_bufr->data_ptr;
             new_total = tmp_bufr->rows; 
             MEMclose(&tmp_bufr); 
        _PDMdebug(fname,"new_total = %d\n", new_total);

	psurpt->list_total = new_total;
        /*
	exec sql select count(*) into :new_total  from psurptlist
			where p_templateno = :tempno;
	psurpt->list_total = new_total;
	_PDMdebug(fname,"total = %d\n", psurpt->list_total);
         */

	if ( rptlist == NULL )
	{
           rptlist = (struct dba_default_list *) malloc( new_total * sizeof(struct dba_default_list) );
           justification = (int *) malloc( new_total * sizeof(int) );
           memset((char *)justification,0,(new_total * sizeof(int)));
	 if (rptlist == NULL)
	 _PDMdebug(fname,"Could not malloc rptlist\n");
        }


	/* select all rows from the table */

{RISint_prepare(&RIScpp_stmt_id1,"select all p_name , p_header , p_type , p_start , p_length , p_decimal , p_sort , p_subtotal , p_total , p_justification  from psurptlist  where p_templateno  = ? order by p_start  asc",1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}



	/* assign a value to be used in the SQL statement */

{{
	static sqlvar in_sqlvar[1] = {
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda in_sqlda = {1,1,in_sqlvar};
	in_sqlvar[0].sqldata = (char *)&tempno;
RISint_execute(&RIScpp_stmt_id1,0,&in_sqlda,7,1,0);
}
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	i = 0;
	for (;;)
	{
	nameind = 0;
	strcpy(header, "");
	headerind = 0;
	type = 0;
	typeind = 0;
	start = 0;
	startind = 0;
	length = 0;
	lengthind = 0;
	decimal = 0;
	decimalind = 0;
	sort = 0;
	sortind = 0;
	subtotal = 0;
	subtotalind = 0;
	total = 0;
	totalind = 0;
	justify = 0;
	justind = 0;

{{
	static sqlvar out_sqlvar[10] = {
		{0,0,1,1,20,0,{0,""}},
		{0,0,1,1,30,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}}
	};
	static sqlda out_sqlda = {10,10,out_sqlvar};
	out_sqlvar[9].sqldata = (char *)&justify;
	out_sqlvar[9].sqlind = &justind;
	out_sqlvar[8].sqldata = (char *)&total;
	out_sqlvar[8].sqlind = &totalind;
	out_sqlvar[7].sqldata = (char *)&subtotal;
	out_sqlvar[7].sqlind = &subtotalind;
	out_sqlvar[6].sqldata = (char *)&sort;
	out_sqlvar[6].sqlind = &sortind;
	out_sqlvar[5].sqldata = (char *)&decimal;
	out_sqlvar[5].sqlind = &decimalind;
	out_sqlvar[4].sqldata = (char *)&length;
	out_sqlvar[4].sqlind = &lengthind;
	out_sqlvar[3].sqldata = (char *)&start;
	out_sqlvar[3].sqlind = &startind;
	out_sqlvar[2].sqldata = (char *)&type;
	out_sqlvar[2].sqlind = &typeind;
	out_sqlvar[1].sqldata = header;
	out_sqlvar[1].sqlind = &headerind;
	out_sqlvar[0].sqldata = name;
	out_sqlvar[0].sqlind = &nameind;
RISint_fetch(RIScpp_stmt_id1,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


		if (nameind < 0) {PDMdebug("name: <null>\n");}
		else
		   { 
		   _PDMdebug(fname,"name: %s\n", name);
	  	   strcpy( rptlist[i].name, name );
		   }

		if (nameind < 0) {PDMdebug("nfmncatame: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"header: %s\n", header);
	  	   strcpy( rptlist[i].header, header );
		   }

		if (typeind < 0) {PDMdebug("type: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"type: %d\n", type);
		   rptlist[i].type = type;
		   }

		if (startind < 0) {PDMdebug("start: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"start: %d\n", start);
		   rptlist[i].start = start;
		   }

		if (lengthind < 0) {PDMdebug("length: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"length: %d\n", length);
		   rptlist[i].length = length;
		   }

		if (decimalind < 0) {PDMdebug("decimal: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"decimal: %d\n", decimal);
		   rptlist[i].decimal = decimal;
		   }

		if (sortind < 0) {PDMdebug("sort: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"sort: %d\n", sort);
		   rptlist[i].sort = sort;
		   }

		if (subtotalind < 0) {PDMdebug("subtotal: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"subtotal: %d\n", subtotal);
		   rptlist[i].subtotal = subtotal;
		   }

		if (totalind < 0) {PDMdebug("total: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"total: %d\n", total);
		   rptlist[i].total = total;
		   }

		if (justind < 0) {
                           PDMdebug("justify: <null>\n");
		          justification[i] = 1;
                                  }
		else
		   {
		   _PDMdebug(fname,"justify: %d\n", justify);
		   justification[i] = justify;
		   }

        ++i;
	}
	}
{RISint_close(RIScpp_stmt_id1, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	_PDMdebug(fname,"EXIT:\n");
	return(MRP_S_Success);

not_found:

	_PDMdebug(fname,"No more data\n");
        if ( rptlist != NULL )
	   {
	   status = MRP_S_Success;
	   psurpt->list = rptlist;
	   psurpt->justification = justification;
	   }
	else
	   status = MRP_I_NoCatsFound;
{RISint_close(RIScpp_stmt_id1, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	PDMdebug("EXIT: PSUrs_load_rptlist\n");
	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  _PDMdebug(fname,"%s/n",err_ptr);
	  }
	status = MRP_E_NoCatInfo;
{RISint_close(RIScpp_stmt_id1, 0, 7);
}

	_PDMdebug(fname,"EXIT:\n");
	return(status);
}

int PSUrs_load_rptopt( psurpt )
 struct PSUrpt *psurpt;
{
       static char *fname = "PSUrs_load_rptopt";
       MEMptr tmp_bufr = NULL;
       char   sql_str[250];
       char   **tmp_data;
struct dba_default_options *rptopt=NULL;

long status;

int new_total;

int tempno;

char sql_stmt[300];

long tableind;

long descriptionind;

long outputind;

char table[30];

char name[21];

long nameind;

char description[50];

char output[100];

char title[120];

long titleind;

char type[2];

long typeind;

int subtotals;

long subtotalind;

int totals;

long totalind;

int width;

long widthind;

int lines;

long lineind;

char templib[21];

long templibind;

char * err_ptr;






        _PDMdebug(fname,"ENTER\n");
	strcpy(sql_stmt, "");

	new_total = 0;
	tempno = 0;
	status = PSUrs_get_tempno( psurpt, &tempno, 1 );
	_PDMdebug(fname,"tempno = %d\n", tempno);
	strcpy(sql_stmt, "");
        if (tempno != 0)
        {
         /*
	exec sql select count(*) into :new_total  from psurptopts
			where p_templateno = :tempno;
          */
       sprintf(sql_str,"SELECT p_templateno FROM psurptopts where p_templateno = %d \n",tempno);
         status = SQLquery(sql_str,&tmp_bufr,512);
           if(status != SQL_S_SUCCESS)
             {
              _PDMdebug(fname,"TEMPLATE has no info\n");
               return(status);
             }
            status = MEMbuild_array(tmp_bufr);
            if(status != MEM_S_SUCCESS)
             {
              _PDMdebug(fname,"TEMPLATE has no info\n");
               return(status);
             }
             tmp_data  = (char**) tmp_bufr->data_ptr;
             /* new_total = atoi(tmp_data[0]); */
              new_total = tmp_bufr->rows ;
             MEMclose(&tmp_bufr); 
        _PDMdebug(fname,"new_total = %d\n", new_total);
	if ( rptopt == NULL )
	{
         rptopt = (struct dba_default_options *) malloc( new_total * sizeof(struct dba_default_options) );
	 if (rptopt == NULL)
	 _PDMdebug(fname,"Could not malloc rptopt\n");
        }


	/* select all rows from the table */

{RISint_prepare(&RIScpp_stmt_id2,"select all p_table , p_templatetype , p_description , p_templatename , p_output , p_title , p_subtotals , p_totals , p_width , p_lines , p_templib  from psurptopts  where p_templateno  = ?",1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	/* assign a value to be used in the SQL statement */
{{
	static sqlvar in_sqlvar[1] = {
		{0,0,4,0,4,0,{0,""}}
	};
	static sqlda in_sqlda = {1,1,in_sqlvar};
	in_sqlvar[0].sqldata = (char *)&tempno;
RISint_execute(&RIScpp_stmt_id2,0,&in_sqlda,7,1,0);
}
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	PDMdebug("table psurptopt:\n");

	tableind = 0;
	descriptionind = 0;
	outputind = 0;
	strcpy(table,"");
	strcpy(description, "");
	strcpy(name, "");
        nameind = 0;
	strcpy(output, "");
	strcpy(title, "");
	titleind = 0;
	strcpy(type, "");
	typeind = 0;
	subtotals = 0;
	subtotalind = 0;
	totals = 0;
	totalind = 0;
	width = 0;
	widthind = 0;
	lines = 0;
	lineind = 0;
	strcpy(templib, "");
	templibind = 0;

	for (;;)
	{
{{
	static sqlvar out_sqlvar[11] = {
		{0,0,1,1,30,0,{0,""}},
		{0,0,1,1,2,0,{0,""}},
		{0,0,1,1,50,0,{0,""}},
		{0,0,1,1,21,0,{0,""}},
		{0,0,1,1,100,0,{0,""}},
		{0,0,1,1,120,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,4,1,4,0,{0,""}},
		{0,0,1,1,21,0,{0,""}}
	};
	static sqlda out_sqlda = {11,11,out_sqlvar};
	out_sqlvar[10].sqldata = templib;
	out_sqlvar[10].sqlind = &templibind;
	out_sqlvar[9].sqldata = (char *)&lines;
	out_sqlvar[9].sqlind = &lineind;
	out_sqlvar[8].sqldata = (char *)&width;
	out_sqlvar[8].sqlind = &widthind;
	out_sqlvar[7].sqldata = (char *)&totals;
	out_sqlvar[7].sqlind = &totalind;
	out_sqlvar[6].sqldata = (char *)&subtotals;
	out_sqlvar[6].sqlind = &subtotalind;
	out_sqlvar[5].sqldata = title;
	out_sqlvar[5].sqlind = &titleind;
	out_sqlvar[4].sqldata = output;
	out_sqlvar[4].sqlind = &outputind;
	out_sqlvar[3].sqldata = name;
	out_sqlvar[3].sqlind = &nameind;
	out_sqlvar[2].sqldata = description;
	out_sqlvar[2].sqlind = &descriptionind;
	out_sqlvar[1].sqldata = type;
	out_sqlvar[1].sqlind = &typeind;
	out_sqlvar[0].sqldata = table;
	out_sqlvar[0].sqlind = &tableind;
RISint_fetch(RIScpp_stmt_id2,0,&out_sqlda,0,7);
}
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


	if (tableind < 0 && strcmp(table,"")) {PDMdebug("table: <null>\n");}
		else
		   { 
		   _PDMdebug(fname,"table: %s\n", table);
	  	   strcpy( rptopt->table, table );
		   }

	if (typeind < 0 && strcmp(type,"")) {PDMdebug("type: <null>\n");}
		else
		   { 
		   _PDMdebug(fname,"type: %s\n", type);
	  	   strcpy(psurpt->templatetype, type);
                   if(type[1] == 'F')
                     {
	             _PDMdebug(fname,"template type %s/n",type);
                      return(PDM_E_RIS_TEMPLATE);
                     }
		   }

		if (descriptionind < 0) {PDMdebug("description: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"description: %s\n", description);
	  	   strcpy( rptopt->description, description );
		   }

		if (nameind < 0) {
                   PDMdebug("templatename: <null>\n");
	  	   strcpy( rptopt->template_name, "" );
                    }
		else
		   {
		   _PDMdebug(fname,"name: %s\n", name);
	  	   strcpy( rptopt->template_name, name );
		   }

		if (outputind < 0) {
                       PDMdebug("output: <null>\n");
	  	       strcpy(rptopt->output, "");
                        }
		else
		   { 
		   _PDMdebug(fname,"output: %s\n", output);
	  	   strcpy( rptopt->output,  output);
		   }

		if (titleind < 0) {PDMdebug("title: <null>\n");}
		else
		   { 
		   _PDMdebug(fname,"title: %s\n", title);
	  	   strcpy( rptopt->title,  title);
		   }

		if (subtotalind < 0) {PDMdebug("subtotals: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"subtotals: %d\n", subtotals);
		   rptopt->subtotals = subtotals;
		   }

		if (totalind < 0) {PDMdebug("totals: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"totals: %d\n", totals);
		   rptopt->totals = totals;
		   }

		if (widthind < 0) {PDMdebug("width: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"width: %d\n", width);
		   rptopt->width = width;
		   }

		if (lineind < 0) {PDMdebug("lines: <null>\n");}
		else
		   {
		   _PDMdebug(fname,"lines: %d\n", lines);
		   rptopt->lines = lines;
		   }

		if ((templibind < 0) || (!strcmp(templib,"")))
                   {
                        psurpt->templib = (char *) malloc (2);
	  	        strcpy(psurpt->templib, "");
                     PDMdebug("templib: <null>\n");
                       }
		else
		   { 
		   _PDMdebug(fname,"templib: %s\n", templib);
	  	   MRPstrcpy(&psurpt->templib, templib);
		   }

	tableind = 0;
	descriptionind = 0;
	outputind = 0;
	strcpy(table,"");
	strcpy(description, "");
	strcpy(name, "");
        nameind = 0;
	strcpy(output, "");
	strcpy(title, "");
	titleind = 0;
	strcpy(type, "");
	typeind = 0;
	subtotals = 0;
	subtotalind = 0;
	totals = 0;
	totalind = 0;
	width = 0;
	widthind = 0;
	lines = 0;
	lineind = 0;
	strcpy(templib, "");
	templibind = 0;
        }
	}
{RISint_close(RIScpp_stmt_id2, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

        _PDMdebug(fname,"EXIT\n");
	return(MRP_S_Success);

not_found:

	PDMdebug("No more data\n");
        if ( rptopt != NULL )
	   {
	   status = MRP_S_Success;
	   psurpt->options = *rptopt;
	   }
	else
	   status = MRP_I_NoCatsFound;
{RISint_close(RIScpp_stmt_id2, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

	return(status);

error:

	if ( PDMdebug_on )
	  {
RISint_report_error(0,&err_ptr);

	  _PDMdebug(fname,"%s/n",err_ptr);
	  }
	status = MRP_E_NoCatInfo;
{RISint_close(RIScpp_stmt_id2, 0, 7);
}

        _PDMdebug(fname,"EXIT\n");
	return(status);
}


