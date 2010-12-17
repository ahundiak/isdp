#include <time.h>
#include <stdio.h>
#define		UNIX	1
#if VMS
#include <types.h>
#include <stat.h>
#endif
#if UNIX
#include <sys/types.h>
#include <sys/stat.h>
#endif

#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "NFMerrordef.h"
#include "NETerrordef.h"
#include "PDMproto.h"

#define MAX_BUFFER_SIZE 16384
#define NOT !
#define	TRUE	1
#define FALSE	0

extern long sqlstatus;
extern int	PDMdebug_on;
extern char PDM_DEBUG_FILE[];
static	long   status;
static  char   s[1024];


int	 PDMget_attribute_no(n_tableno,n_name,n_attrno)
int  n_tableno;
char *n_name;
int	 *n_attrno;
{
	char	sql_str[512];
	MEMptr	bufr = NULL;
	char	**data;

	PDMdebug("ENTER:PDMget_attribute_no\n");
        sql_str [0] = '\0';
	sprintf(sql_str,"%s %s %d %s '%s'",
	"SELECT n_attrno FROM nfmattributes ",
	"WHERE n_tableno = ",n_tableno,
	"AND n_name = ",n_name);
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
			MEMclose(&bufr);
			switch(status)
			{
 				case SQL_I_NO_ROWS_FOUND :
					 PDMdebug("Attribute Found \n");
					 return(PDM_I_ATTR_NOT_FOUND);
				default:
status = _PDMget_db_error (status);
					return(status);
			}			
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMbuild_array failed status %d\n",
		status);PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	*n_attrno = atol(data[0]);	
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMget_attribute_no\n");
	return(PDM_S_SUCCESS);
}

int	 PDMget_attribute_name(n_tableno,n_attrno,n_name)
int  n_tableno;
char *n_name;
int	 *n_attrno;
{
	char	sql_str[512];
	MEMptr	bufr = NULL;
	char	**data;

	PDMdebug("ENTER:PDMget_attribute_name\n");
        sql_str [0] = '\0';
	sprintf(sql_str,"%s %s %d %s %d",
	"SELECT n_name FROM nfmattributes ",
	"WHERE n_tableno = ",n_tableno,
	"AND n_attrno = ",n_attrno);
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
			MEMclose(&bufr);
			switch(status)
			{
 				case SQL_I_NO_ROWS_FOUND :
					 PDMdebug("Attribute Found \n");
					 return(PDM_I_ATTR_NOT_FOUND);
				default:
status = _PDMget_db_error (status);
					return(status);
			}			
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMbuild_array failed status %d\n",
		status);PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(n_name,data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMget_attribute_name\n");
	return(PDM_S_SUCCESS);
}

int	PDMget_table_no(n_tablename,n_tabletype,n_tableno)
char		*n_tablename;
char		*n_tabletype;
int			*n_tableno;
{
	char		**data;
	char		sql_str[1024];
	MEMptr		bufr = NULL;

	PDMdebug("ENTER PDMget_table_no\n");

        sql_str [0] = '\0';
	sprintf(sql_str,"%s %s '%s' %s '%s'",
	"SELECT n_tableno FROM nfmtables ",
	"WHERE n_tablename = ",n_tablename,
	"AND n_tabletype = ",n_tabletype);
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			return(PDM_E_TABLE_NOT_FOUND);
		}
		MEMclose(&bufr);
		sprintf(s,"SQLquery failed status %d\n",status);
		PDMdebug(s);
status = _PDMget_db_error (status);
		return(status);
	}	
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		MEMclose(&bufr);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	*n_tableno = atoi(data[0]); MEMclose(&bufr);
	PDMdebug("EXIT PDMget_table_no\n");
	return(PDM_S_SUCCESS);
}

int PDMi_get_nname(n_nfmname,n_tableno,n_name)
char	*n_nfmname;
char	*n_tableno;
char	*n_name;
{
	char		**data;
	char		sql_str[1024];
	MEMptr		bufr = NULL;

	PDMdebug("ENTER PDMi_get_nname\n");

        sql_str [0] = '\0';
	sprintf(sql_str,"%s %s %s %s '%s'",
	"SELECT n_name FROM nfmattributes ",
	"WHERE n_tableno = ",n_tableno,
	"AND n_nfmname = ",n_nfmname);
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			sprintf(s,"<%d:%s> entry not in nfmattributes\n",
			atoi(n_tableno),n_nfmname); PDMdebug(s);
			return(PDM_I_ATTR_NOT_FOUND);
		}
		sprintf(s,"SQLquery failed status %d\n",status);
		PDMdebug(s);
status = _PDMget_db_error (status);
		return(status);
	}	
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		MEMclose(&bufr);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(n_name,data[0]);
    MEMclose(&bufr);
	PDMdebug("EXIT PDMi_get_nname\n");
	return(PDM_S_SUCCESS);
}

int	PDMi_maxrow_no(table,attr_name,maxrow)
char		*table;
char		*attr_name;
int			*maxrow;
{
	char		**data;
	char		sql_str[1024];
	MEMptr		bufr = NULL;

	PDMdebug("ENTER PDMi_maxrow_no\n");

        sql_str [0] = '\0';
	sprintf(sql_str,"SELECT MAX(%s) FROM %s",attr_name,table);
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"SQLquery failed status %d\n",status);
		PDMdebug(s);
		/*return(PDM_E_SQL_QUERY);*/
status = _PDMget_db_error (status);
		return(status);
	}	
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		MEMclose(&bufr);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	*maxrow = atoi(data[0]); MEMclose(&bufr);
	sprintf(s,"maxrow -> %d\n",*maxrow);
	PDMdebug(s);
	PDMdebug("EXIT:PDMi_maxrow_no\n");
	return(PDM_S_SUCCESS);
}

int	PDMi_query_synonym(n_tableno,n_name,n_synonym)
int		n_tableno;
char 	*n_name;
char	*n_synonym;
{
	MEMptr	bufr = NULL;
	char	sql_str[1024];
	char	**data;

	PDMdebug("ENTER:PDMi_query_synonym\n");
        sql_str [0] = '\0';
	sprintf(sql_str,"%s %s %d %s '%s'",
	"SELECT n_synonym FROM nfmattributes ",
	"WHERE n_tableno = ",n_tableno,
	"AND n_name = ",n_name);
	status = SQLquery(sql_str,&bufr,1024);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
		}
		sprintf(s,"SQLquery failed status %d\n",
		status); PDMdebug(s);
status = _PDMget_db_error (status);
		return(status);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMbuild_array failed status %d\n",
		status);PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(n_synonym,data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_query_synonym\n");
	return(PDM_S_SUCCESS);
}

int	PDMi_find_datatype(n_tableno,n_name,n_datatype)
int		n_tableno;
char 	*n_name;
char	*n_datatype;
{
	MEMptr	bufr = NULL;
	char	sql_str[1024];
	char	**data;

	PDMdebug("ENTER:PDMi_find_datatype\n");
        sql_str [0] = '\0';
	sprintf(sql_str,"%s %s %d %s '%s'",
	"SELECT n_datatype FROM nfmattributes ",
	"WHERE n_tableno = ",n_tableno,
	"AND n_name = ",n_name);
	status = SQLquery(sql_str,&bufr,1024);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
		}
		sprintf(s,"SQLquery failed status %d\n",
		status); PDMdebug(s);
status = _PDMget_db_error (status);
		return(status);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMbuild_array failed status %d\n",
		status);PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(n_datatype,data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_find_datatype\n");
	return(PDM_S_SUCCESS);
}

/*
	Since most of the attribute names may be modified ....

	FORMAT of bufr:

	(1)	n_nfmname
	(2) n_tableno
	(3) n_tablename
	(4) n_tabletype
	(5)	n_name

	Columns <1,3,4> are input
	Columns <2,5> are output
*/

int	PDMload_nnames(bufr)
MEMptr	bufr;
{
	int		i, j, nxi, nxj;
	int		n1, n2, n3, n4, n5;
	char	**data, **columns;
	int		n_tableno;
	char	s_tableno[50], n_name[50];

	PDMdebug("ENTER:PDMload_nnames\n");
    if(PDMdebug_on)
	{
		MEMprint_buffer("bufr at ENTER",bufr,PDM_DEBUG_FILE);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed tatus %d\n",
		status); PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	columns = (char **) bufr->column_ptr;
	data = (char **) bufr->data_ptr;
	n1 = -1; n2 = -1; n3 = -1; n4 = -1; n5 = -1; 
	for(i=0;i<bufr->columns;i++)
	{
		if(!strcmp(columns[i],"n_nfmname"))   n1 = i;
		if(!strcmp(columns[i],"n_tableno"))   n2 = i;
		if(!strcmp(columns[i],"n_tablename")) n3 = i;
		if(!strcmp(columns[i],"n_tabletype")) n4 = i;
		if(!strcmp(columns[i],"n_name"))	  n5 = i;
	}
	if(n1 == -1 || n2 == -1 || n3 == -1 || n4 == -1 || n5 == -1)
	{
		sprintf(s,"Could not set offsets in bufr\n");
		PDMdebug(s);
		return(PDM_E_BUFFER_FORMAT);
	}
	
	/* load n_tablenos */

	for(i=0;i<bufr->rows;i++)
	{
		nxi = i * bufr->columns;
		if(!strlen(data[nxi+n2]))
		{
			status = PDMget_table_no(data[nxi+n3],
									data[nxi+n4],&n_tableno);
			if(status != PDM_S_SUCCESS)
			{
				sprintf(s,"PDMget_table_no failed status %d\n",
				status); PDMdebug(s);
				return(status);
			}
			sprintf(s_tableno,"%d",n_tableno);
			for(j=0;j<bufr->rows;j++)
			{
				nxj = j * bufr->columns;
				if(!strcmp(data[nxi+n3],data[nxj+n3]) &&
				   !strcmp(data[nxi+n4],data[nxj+n4]))
				{
					status = MEMwrite_data(bufr,s_tableno,j+1,n2+1);
					if(status != MEM_S_SUCCESS)
					{
						sprintf(s,"MEMwrite_data failed status %d\n",
						status); PDMdebug(s);
						return(PDM_E_WRITE_COLUMN);
					}
				}
			}
		}
	}

	/* load n_names */

	for(i=0;i<bufr->rows;i++)
	{
		nxi = i * bufr->columns;
		if(!strlen(data[nxi+n2]))
		{
			n_name[0] = '\0';
			status = PDMi_get_nname(data[nxi+n1],
								    data[nxi+n2],n_name);
			if(status != PDM_S_SUCCESS)
			{
				sprintf(s,"PDMi_get_nname failed status %d\n",
				status); PDMdebug(s);
				return(status);
			}
			for(j=0;j<bufr->rows;j++)
			{
				nxj = j * bufr->columns;
				if(!strcmp(data[nxi+n1],data[nxj+n1]) &&
				   !strcmp(data[nxi+n2],data[nxj+n2]))
				{
					status = MEMwrite_data(bufr,n_name,j+1,n5+1);
					if(status != MEM_S_SUCCESS)
					{
						sprintf(s,"MEMwrite_data failed status %d\n",
						status); PDMdebug(s);
						return(PDM_E_WRITE_COLUMN);
					}
				}
			}
		}
	}
    if(PDMdebug_on)
	{
		MEMprint_buffer("bufr at EXIT",bufr,PDM_DEBUG_FILE);
	}
	PDMdebug("EXIT:PDMload_nnames\n");
	return(PDM_S_SUCCESS);
}


int	 PDMget_bom_attr_name(n_attrno,n_name)
char *n_name;
int	 *n_attrno;
{
	char	sql_str[512];
	MEMptr	bufr = NULL;
	char	**data;
        char    *fname = "PDMget_bom_attr_name";

	_PDMdebug(fname,"ENTER:PDMget_attribute_name\n");
        sql_str [0] = '\0';
	sprintf(sql_str,"SELECT n_name FROM nfmattributes WHERE n_attrno = %d and n_tableno = (select n_tableno from nfmtables where n_tablename = 'bom_template' )", n_attrno );
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
			MEMclose(&bufr);
			switch(status)
			{
 				case SQL_I_NO_ROWS_FOUND :
					 PDMdebug("Attribute Found \n");
					 return(PDM_I_ATTR_NOT_FOUND);
				default:
status = _PDMget_db_error (status);
		return(status);
			}			
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		_PDMdebug(fname,"MEMbuild_array failed status %d\n",
		status);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(n_name,data[0]);
	MEMclose(&bufr);
	_PDMdebug(fname,"EXIT:PDMget_attribute_name\n");
	return(PDM_S_SUCCESS);
}

