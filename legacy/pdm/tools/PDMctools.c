#include	<stdio.h>
#include	"SQLerrordef.h"
#include	"MEMerrordef.h"
#include	"NFMerrordef.h"
#include	"PDMdbs_err.h"
#include	"MEMstruct.h"
#include	"PDMproto.h"
#include	"PDUerror.h"
#include	"SQLstruct.h"

static		long		status;
static		char		s[1024];
extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];

/* this decl added to support query of db error message MaC 051593 */
extern struct SQLglobal_st	SQLglobal;

int PDMquery_cit_members(user_id,catalog,part,rev,
						level,attr_bufr,ret_bufr)
long	user_id;
char	*catalog;
char	*part;
char	*rev;
int		level;
MEMptr	*attr_bufr;
MEMptr	*ret_bufr;
{
	long	n_pcatalogno;
	long	n_pitemno;
	char	temp_table[30];
	char	sql_str[1024];
	char	n_catalogname[20];
	char	n_itemname[30];
	char	n_itemrev[30];
	char	**data;
	int		i,nxi;
	MEMptr	temp_bufr = NULL;

	PDMdebug("ENTER:PDMquery_cit_members\n");
/* APOGEE START */
sprintf (s, "Added for ACC: user_id = %d and level = %d\n",
             user_id, level);
PDMdebug (s);
/* APOGEE END */

	status = PDMquery_catalog_partnos(catalog,part,rev,
			 &n_pcatalogno,&n_pitemno);
	if(status != PDM_S_SUCCESS)
	{
		return(status);
	}
	sprintf(sql_str,"%s %s %d %s %d ",
	"SELECT n_ccatalogno,n_citemno,n_citno FROM nfmsetcit ",
	"WHERE n_pcatalogno = ",n_pcatalogno,
	"AND n_pitemno = ",n_pitemno);
	status = SQLquery(sql_str,&temp_bufr,1024);
	if(status != SQL_S_SUCCESS)
	{
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			status = PDMopen_set_buffer(ret_bufr);
			MEMopen(attr_bufr,512);
			return(PDM_S_SUCCESS);
		}
     status = _PDMget_db_error (status);
		return(status);
	}
	status = MEMbuild_array(temp_bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&temp_bufr);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;

	PDMgen_bomtable_name(temp_table);

	sprintf(sql_str,"%s %s %s %s %s",
	"CREATE TABLE ",temp_table,
	"(n_catalogno integer,n_itemno integer ,",
	"n_catalogname char(20), n_itemname char(30),",
	"n_itemrev char(30),n_citno integer)");
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&temp_bufr);
		return(PDM_E_SQL_QUERY);
	}
		
	for(i=0;i<temp_bufr->rows;i++)
	{
		nxi = i * temp_bufr->columns;
		sprintf(s,"VALUES(%s,%s,'','','',%d)",data[nxi+0],
		data[nxi+1],atol(data[nxi+2]));
		sprintf(sql_str,"%s %s %s %s %s ",
		"INSERT INTO ",temp_table,
		"(n_catalogno,n_itemno,n_catalogname,",
		"n_itemname,n_itemrev,n_citno)",
		s);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			MEMclose(&temp_bufr);
			sprintf(sql_str,"DROP TABLE %s ",temp_table);
			SQLstmt(sql_str);
			return(PDM_E_SQL_STMT);
		}
	}	
	MEMclose(&temp_bufr);
	
	sprintf(sql_str,"SELECT DISTINCT n_catalogno FROM %s",
	temp_table);
	status = SQLquery(sql_str,&temp_bufr,1024);
	if(status != SQL_S_SUCCESS)
	{
			sprintf(sql_str,"DROP TABLE %s ",temp_table);
			SQLstmt(sql_str);
     status = _PDMget_db_error (status);
	                return(status);
	}
	status = MEMbuild_array(temp_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(sql_str,"DROP TABLE %s ",temp_table);
		SQLstmt(sql_str);
		MEMclose(&temp_bufr);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	for(i=0;i<temp_bufr->rows;i++)
	{
		PDMget_catalog_name(atol(data[i]),n_catalogname);
		sprintf(sql_str,"%s %s %s '%s' %s %d",
		"UPDATE ", temp_table,"SET n_catalogname = ",
		n_catalogname,
		"WHERE n_catalogno = ",atol(data[i]));
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(sql_str,"DROP TABLE %s ",temp_table);
			SQLstmt(sql_str);
			MEMclose(&temp_bufr);
			return(PDM_E_SQL_STMT);
		}
	}
	MEMclose(&temp_bufr);

	sprintf(sql_str,"SELECT DISTINCT n_itemno,n_catalogname FROM %s",
	temp_table);
	status = SQLquery(sql_str,&temp_bufr,1024);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(sql_str,"DROP TABLE %s ",temp_table);
		SQLstmt(sql_str);
     status = _PDMget_db_error (status);
	        return(status);
	}
	status = MEMbuild_array(temp_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(sql_str,"DROP TABLE %s ",temp_table);
		SQLstmt(sql_str);
		MEMclose(&temp_bufr);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	for(i=0;i<temp_bufr->rows;i++)
	{
		nxi = i * temp_bufr->columns;
		PDMget_itemname(atol(data[nxi+0]),data[nxi+1],
		n_itemname,n_itemrev);
		sprintf(sql_str,"%s %s %s '%s' %s '%s' %s %d %s '%s'",
		"UPDATE ", temp_table,
		"SET n_itemname = ",n_itemname,
		",n_itemrev = ",n_itemrev,
		"WHERE n_itemno= ",atol(data[nxi+0]),
		" AND n_catalogname = ",data[nxi+1]);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(sql_str,"DROP TABLE %s ",temp_table);
			SQLstmt(sql_str);
			MEMclose(&temp_bufr);
			return(PDM_E_SQL_STMT);
		}
	}
	MEMclose(&temp_bufr);
	status = PDMopen_set_buffer(ret_bufr);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(sql_str,"DROP TABLE %s ",temp_table);
		SQLstmt(sql_str);
		return(status);
	}
	sprintf(sql_str,"%s %s ",
	"SELECT n_catalogname,n_itemname,n_itemrev,n_citno FROM ",
	temp_table);
	status = SQLquery(sql_str,&temp_bufr,1024);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(sql_str,"DROP TABLE %s ",temp_table);
		SQLstmt(sql_str);
     status = _PDMget_db_error (status);
	        return(status);
	}
	status = MEMbuild_array(temp_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(sql_str,"DROP TABLE %s ",temp_table);
		SQLstmt(sql_str);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	for(i=0;i<temp_bufr->rows;i++)
	{
		nxi = i * temp_bufr->columns;
		sprintf(s,"\1%s\1%s\1%s\1%s\1\1\1\1\1\1",
		data[nxi+3],data[nxi+0],data[nxi+1],data[nxi+2]);
		status = MEMwrite(*ret_bufr,s);
		if(status != MEM_S_SUCCESS)
		{
			sprintf(sql_str,"DROP TABLE %s ",temp_table);
			SQLstmt(sql_str);
			return(PDM_E_WRITE_ROW);
		}
	}
    MEMopen(attr_bufr,512);
	sprintf(sql_str,"DROP TABLE %s",temp_table);
	SQLstmt(sql_str);
	if(PDMdebug_on)
	{
		MEMprint_buffer("set bufr in PDMquery_cit_members",
		*ret_bufr,PDM_DEBUG_FILE);
	}
	PDMdebug("EXIT:PDMquery_cit_members\n");
	return(PDM_S_SUCCESS);
}

int PDMget_catalog_name(no,name)
long	no;
char	*name;
{
	char	sql_str[512];
	MEMptr	bufr = NULL;
	char	**data;

        sql_str[0] = '\0';
	sprintf(sql_str,"%s %s %d",
	"SELECT n_catalogname FROM nfmcatalogs ",
	"WHERE n_catalogno = ",no);
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS) {
     status = _PDMget_db_error (status);
	        return(status);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(name,data[0]);
        MEMclose (&bufr);
	return(PDM_S_SUCCESS);
}

int	PDMget_itemname(no,catalog,itemnum,itemrev)
long	no;
char	*catalog;
char	*itemnum;
char	*itemrev;
{
	char	sql_str[512];
	MEMptr	bufr = NULL;
	char	**data;

        sql_str[0] = '\0';
	sprintf(sql_str,"%s %s %s %d",
	"SELECT n_itemname,n_itemrev FROM ",catalog,
	"WHERE n_itemno = ",no);	
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
     status = _PDMget_db_error (status);
	        return(status);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(itemnum,data[0]);
	strcpy(itemrev,data[1]);
	MEMclose(&bufr);
	return(PDM_S_SUCCESS);
}

int	  PDMopen_set_buffer(ret_bufr)
MEMptr	*ret_bufr;
{
	MEMptr		data_bufr = NULL;

	MEMopen(&data_bufr,1024);
	MEMwrite_format(data_bufr,"n_level","integer");
	MEMwrite_format(data_bufr,"n_citno","integer");
	MEMwrite_format(data_bufr,"n_catalogname","char(20)");
	MEMwrite_format(data_bufr,"n_itemname","char(30)");
	MEMwrite_format(data_bufr,"n_itemrev","char(30)");
	MEMwrite_format(data_bufr,"n_type","char(1)");
	MEMwrite_format(data_bufr,"n_archiveno","integer");
	MEMwrite_format(data_bufr,"n_archiveflag","char(1)");
	MEMwrite_format(data_bufr,"n_setindicator","char(1)");
	MEMwrite_format(data_bufr,"n_status","char(2)");
	MEMwrite_format(data_bufr,"n_status","char(10)");
	*ret_bufr = data_bufr;
	return(PDM_S_SUCCESS);
}

int PDMcount_cit_attachments(p_citno,count)
int     p_citno;
int     *count;
{
	char	sql_str[1024];
/* APOGEE START */
/*
	char	**data;
*/
/* APOGEE END */
	MEMptr	temp_bufr = NULL;

	PDMdebug("ENTER:PDMcount_cit_attachments\n");
        sql_str[0] = '\0';
	sprintf(sql_str,"%s %s %d %s '%s' ",
	"SELECT p_citno , p_attached  FROM pdmcit ",
	"WHERE p_citno = ",p_citno,
	"AND p_attached = ","Y");
	status = SQLquery(sql_str,&temp_bufr,512);
	if(status != SQL_S_SUCCESS)
	{
		if(status == SQL_I_NO_ROWS_FOUND)
		{
                        *count = 0;
			return(PDM_S_SUCCESS);
		}
     status = _PDMget_db_error (status);
	        return(status);
	}
	status = MEMbuild_array(temp_bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&temp_bufr);
		return(PDM_E_BUILD_ARRAY);
	}
        *count = temp_bufr->rows;
	MEMclose(&temp_bufr);
	
	PDMdebug("EXIT:PDMcount_cit_attachments\n");
	return(PDM_S_SUCCESS);

}

int PDMcount_bom_attachments(p_type,bom_name,n_catalogname,
                             n_itemname,n_itemrev,p_level,count)
char    *bom_name;
char    *n_catalogname ;
char    *n_itemname;
char    *n_itemrev;
int     p_level;
int     *count;
int     p_type;

{
	char	sql_str[1024];
/* APOGEE START */
/*
	char	**data;
*/
/* APOGEE END */
	MEMptr	temp_bufr = NULL;

	PDMdebug("ENTER:PDMcount_bom_attachments\n");

        if(p_type == 7) {
        sql_str[0] = '\0';
	sprintf(sql_str,"%s %s %s '%s' %s '%s' %s '%s' %s '%s' %s %d",
	"SELECT  n_itemname  FROM  ",bom_name,
	"WHERE n_catalogname = ",n_catalogname,
	"AND n_itemname = ",n_itemname,
	"AND n_itemrev = ",n_itemrev,
	"AND p_attached = ","Y",
	"AND p_level = ",p_level);
        }
        else {
	sprintf(sql_str,"%s %s %s '%s' %s '%s' %s '%s' %s '%s'",
	"SELECT  n_itemname  FROM  ",bom_name,
	"WHERE n_catalogname = ",n_catalogname,
	"AND n_itemname = ",n_itemname,
	"AND n_itemrev = ",n_itemrev,
	"AND p_attached = ","Y");
        }
        
	status = SQLquery(sql_str,&temp_bufr,512);
	if(status != SQL_S_SUCCESS)
	{
		if(status == SQL_I_NO_ROWS_FOUND)
		{
                        *count = 0;
			return(PDM_S_SUCCESS);
		}
     status = _PDMget_db_error (status);
	        return(status);
	}
	status = MEMbuild_array(temp_bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&temp_bufr);
		return(PDM_E_BUILD_ARRAY);
	}
        *count = temp_bufr->rows;
	MEMclose(&temp_bufr);
	
	PDMdebug("EXIT:PDMcount_bom_attachments\n");
	return(PDM_S_SUCCESS);

}

int	PDMget_itemname_filever (no, catalog, itemnum, 
                                  itemrev, filenum, filever)
long	no;
char	*catalog;
char	*itemnum;
char	*itemrev;
int	*filenum;
int	*filever;
{
	char	*fn = "PDMget_itemname_filever";
	char	sql_str[512];
	MEMptr	bufr = NULL;
	char	**data;

        sql_str[0] = '\0';
	sprintf(sql_str,
"SELECT %s.n_itemname, %s.n_itemrev, f_%s.n_filenum, f_%s.n_fileversion \
FROM %s, f_%s\
WHERE %s.n_itemno = f_%s.n_itemnum\
AND %s.n_itemno = %d",
catalog, catalog, catalog, catalog, catalog, catalog,
catalog, catalog, catalog, no);	
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS) {
          _PDMdebug (fn, "SQLquery failed %d\n", status);
     status = _PDMget_db_error (status);
	        return(status);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn, "SQLquery failed %d\n", status);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
_PDMdebug (fn, "itemnum[%s] itemrev[%s] filenum[%s] and filever[%s]\n",
  data[0], data[1], data[2], data[3]);
	strcpy(itemnum,data[0]);
	strcpy(itemrev,data[1]);
	*filenum = atol (data[2]);
	*filever = atol (data[3]);
	MEMclose(&bufr);
	return(PDM_S_SUCCESS);
}

int	PDMget_max_filever (no, catalog, filever)
long	no;
char	*catalog;
int	*filever;
{
	char	*fn = "PDMget_max_filever";
	char	sql_str[512];
	MEMptr	bufr = NULL;
	char	**data;

        sql_str[0] = '\0';
	sprintf(sql_str,
"SELECT MAX ( n_fileversion)  FROM f_%s WHERE n_itemnum = %d",
catalog, no);	
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS) {
          _PDMdebug (fn, "SQLquery failed %d\n", status);
     status = _PDMget_db_error (status);
	        return(status);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn, "SQLquery failed %d\n", status);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
_PDMdebug (fn, "filever[%s]\n", data[0]);
	/* *filenum = atol (data[2]); */
	*filever = atol (data[0]);
	MEMclose(&bufr);
	return(PDM_S_SUCCESS);
}

int	PDMget_filenum (no, catalog, filename, filenum)
long	no;
char	*catalog, *filename;
int	*filenum;
{
	char	*fn = "PDMget_itemname_filever";
	char	sql_str[512];
	MEMptr	bufr = NULL;
	char	**data;

        sql_str[0] = '\0';
	sprintf(sql_str,
"SELECT n_filenum FROM f_%s WHERE n_itemnum = %d AND n_cofilename = '%s'",
catalog, no, filename);	
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS) {
          _PDMdebug (fn, "SQLquery failed %d\n", status);
     status = _PDMget_db_error (status);
	        return(status);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn, "SQLquery failed %d\n", status);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
_PDMdebug (fn, "filenum[%s]\n", data[0]);
	*filenum = atol (data[0]);
       /* *filever = atol (data[0]); */
	MEMclose(&bufr);
	return(PDM_S_SUCCESS);
}

int	PDMget_projectno (project_name, project_no)
int	*project_no;
char	*project_name;
{
	char	*fn = "PDMget_projectno";
	char	sql_str[512];
	MEMptr	bufr = NULL;
	char	**data;

        sql_str[0] = '\0';
	sprintf(sql_str,
	"SELECT n_projectno FROM NFMPROJECTS WHERE n_projectname = '%s'",
              project_name);	
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS) {
     status = _PDMget_db_error (status);
	        return(status);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMbuild_array failed %d\n", status);
		return(PDM_E_BUILD_ARRAY);
	}

	data = (char **) bufr->data_ptr;
        _PDMdebug (fn, "project_no [%s] \n", data [0]);
	*project_no = atol ( data[0]);
	MEMclose(&bufr);
	return(PDM_S_SUCCESS);
}


int	PDMget_max_filever_fname (no, catalog, filenum, filever)
int	no, filenum;
char	*catalog;
int	*filever;
{
	char	*fn = "PDMget_max_filever_fname";
	char	sql_str[512];
	MEMptr	bufr = NULL;
	char	**data;

        sql_str[0] = '\0';
	sprintf(sql_str,
"SELECT MAX ( n_fileversion) FROM f_%s WHERE n_itemnum = %d AND n_filenum = %d",
catalog, no, filenum);	
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS) {
          _PDMdebug (fn, "SQLquery failed %d\n", status);
     status = _PDMget_db_error (status);
	        return(status);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn, "SQLquery failed %d\n", status);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
_PDMdebug (fn, "filever[%s]\n", data[0]);
	/* *filenum = atol (data[2]); */
	*filever = atol (data[0]);
	MEMclose(&bufr);
	return(PDM_S_SUCCESS);
}

/*
Commented out as this func was called in PDMpart_f.c which
is included making PDMinit image. This function is added
to tools/PDMpart_f.c. MaC 052493...


int	_PDMget_db_error (status2)
int	status2;
{
	char	*fn = "_PDMget_db_error";
	int	errorno = 0;
	int	errorno1 = 0;
	int	status1 = 0;

        errorno = (SQLglobal.DBerror_no >> 16);
        errorno1 = SQLglobal.DBerror_no;
        _PDMdebug (fn, "sql_global_error = %d \n", SQLglobal.DBerror_no);
        _PDMdebug ("Printing SQLglobal struct", "\nris_print_format[%s]\n", 
         SQLglobal.ris_print_format); 
        _PDMdebug ("Printing SQLglobal struct", "\nDBerrorno[%d]\n", 
         SQLglobal.DBerror_no);
        _PDMdebug ("Printing SQLglobal struct", "\nDBerror_msg[%s]\n", 
         SQLglobal.DBerror_msg); 
        _PDMdebug ("Printing SQLglobal struct", "\ndb_type[%c]\n", 
         SQLglobal.db_type);

        _PDMdebug (fn, "errorno [%d]\n", errorno);
        _PDMdebug (fn, "errorno1 [%d]\n", errorno1);

        if ( (errorno == 107) || (errorno == 113) 
                 || (errorno == 233) || (errorno == 271) ) {
           status1 = PDM_I_TABLE_LOCKED;
          }
         else {
          if (status2 == SQL_E_MESSAGE) status1 = PDM_E_SQL_QUERY;
          else  status1 = status2;
          }

	return(status1);
}
*/

