#include <stdio.h>
#define		UNIX	1

#include "PDUris_incl.h"
#include "SQLerrordef.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "PDMproto.h"
#include "NFMerrordef.h"

extern int	PDMdebug_on;
extern char PDM_DEBUG_FILE[];
static	long   status;
static  char   s[1024];

/* Returns the maximum string size for an attribute
   i.e., attributes with identical domains
*/
 
int	PDMi_find_maxtype(buffer,n,n_name,size)
MEMptr	buffer;
int		n;
char	*n_name;
int		*size;
{
	MEMptr	bufr = NULL;
	char	*sql_str;
	char	**data;
	int		i, nx;
	int		length, max_length;
 
	PDMdebug("ENTER:PDMi_find_maxtype\n");
	status = MEMbuild_array(buffer);
    if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",
		status); PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) buffer->data_ptr;
	sql_str = (char *) malloc(512 + buffer->rows * 50);
	if(sql_str == NULL)
	{
		PDMdebug(" Failed to malloc \n");
		return(PDM_E_COULD_NOT_MALLOC);
	}
        sql_str [0] = '\0';
	sprintf(sql_str,"%s %s '%s' %s %s ",
	"SELECT n_datatype FROM ",
	"nfmattributes WHERE n_name = ",n_name,
	"AND (n_tableno = ",data[n]);
	for(i=1;i<buffer->rows;i++)
	{
		nx = i * buffer->columns;
		strcat(sql_str," OR n_tableno = ");
		strcat(sql_str,data[nx+n]);
	}
	strcat(sql_str,")");
	status = SQLquery(sql_str,&bufr,1024);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr); free(sql_str);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			sprintf(s,"%s %s \n",
			"No Rows: Table Definition can not be found in ",
			"nfmattributes Table");PDMdebug(s);
			return(PDM_I_NO_ROWS_FOUND);
		}
		sprintf(s,"SQLquery failed status %d\n",
		status); PDMdebug(s);
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr); free(sql_str);
		sprintf(s,"MEMbuild_array failed status %d\n",
		status);PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	max_length = 0;
	for(i=0;i<bufr->rows;i++)
	{
		nx = i * bufr->columns;
		if(!strncmp(data[nx],"char",4))
     	{
			sscanf(data[nx],"char(%d)",&length);
			if(length > max_length)
			{
				max_length = length;
			}
		}
	}
	sprintf(s,"max_length -> %d\n",max_length);
	PDMdebug(s);
	MEMclose(&bufr);
	free(sql_str);
	*size = max_length;
	PDMdebug("EXIT:PDMi_find_maxtype\n");
	return(PDM_S_SUCCESS);
}

/*
	the formats of bufr1,bufr2 are used to open bufr3
	data from bufr1,bufr2 is loaded as is into bufr3
*/

int	PDMexpand_copy_buffer(bufr1,bufr2,bufr3)
MEMptr	bufr1;
MEMptr	bufr2;
MEMptr	*bufr3;
{
	char	*fn = "PDMexpand_copy_buffer";
	char	*a_row;
	char	**column, **format;
	char	**data = NULL, **data1 = NULL;
	int		i, j, nx1, nx2;
	int		rows;
 
	PDMdebug("ENTER:PDMexpand_copy_buffer\n");
/*	if(PDMdebug_on)
	{
		MEMprint_buffer("before expansion",bufr1,PDM_DEBUG_FILE);
		MEMprint_buffer("before expansion",bufr2,PDM_DEBUG_FILE);
	}
*/
	status = MEMopen(bufr3,1024);
    if(status != MEM_S_SUCCESS)
	{
		_PDMdebug (fn,"MEMopen failed status %d\n",
		status); 
		return(PDM_E_OPEN_BUFFER);
	}
	status = MEMbuild_array(bufr1);
    if(status != MEM_S_SUCCESS)
	{
		MEMclose(bufr3);
		_PDMdebug (fn,"MEMbuild_array failed status %d\n",
		status);
		return(PDM_E_BUILD_ARRAY);
	}
 	format = (char **) bufr1->format_ptr;
 	column = (char **) bufr1->column_ptr;
	for(i=0;i<bufr1->columns;i++)
	{
		status = MEMwrite_format(*bufr3,column[i],format[i]);
		if(status != MEM_S_SUCCESS)
		{
		MEMclose(bufr3);
		_PDMdebug (fn,"MEMwrite_format failed status %d\n",
		status); 
		return(PDM_E_WRITE_FORMAT);
		}
	}
	status = MEMbuild_array(bufr2);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(bufr3);
		_PDMdebug (fn,"MEMbuild_array failed status %d\n",
		status);
		return(PDM_E_BUILD_ARRAY);
	}
 	format = (char **) bufr2->format_ptr;
 	column = (char **) bufr2->column_ptr;
	for(i=0;i<bufr2->columns;i++)
	{
		status = MEMwrite_format(*bufr3,column[i],format[i]);
		if(status != MEM_S_SUCCESS)
		{
		MEMclose(bufr3);
		_PDMdebug (fn,"MEMwrite_format failed status %d\n",
			status); 
		return(PDM_E_WRITE_FORMAT);
		}
	}
	if(!bufr1->rows && !bufr2->rows)
	{
	if(PDMdebug_on)
	{
	MEMprint_buffer("after expansion",*bufr3,PDM_DEBUG_FILE);
	}
	PDMdebug("EXIT:PDMexpand_copy_buffer\n");
	return(PDM_S_SUCCESS);
	}
	if(bufr1->rows)
		data = (char **) bufr1->data_ptr;
	if(bufr2->rows)
		data1 = (char **) bufr2->data_ptr;

	a_row = (char *) malloc(bufr1->row_size + 
						    bufr2->row_size + 300);
	if(a_row == NULL)
	{
		MEMclose(bufr3);
		PDMdebug("Could not malloc \n");
		return(PDM_E_COULD_NOT_MALLOC);
	}
	if(bufr1->rows  > bufr2->rows)
		rows = 	bufr1->rows;
	else 
		rows = bufr2->rows;
	for(i=0;i<rows;i++)
	{
		a_row[0] = '\0';
		nx1 = i * bufr1->columns;
		for(j=0;j<bufr1->columns;j++)
		{
			if(bufr1->rows && i < bufr1->rows)
			{
				strcat(a_row,data[nx1+j]);
			}
			strcat(a_row,"\1");
		}
		nx2 = i * bufr2->columns;
		for(j=0;j<bufr2->columns;j++)
		{
			if(bufr2->rows && i < bufr2->rows)
			{
				strcat(a_row,data1[nx2+j]);
			}
			strcat(a_row,"\1");
		}
		status = MEMwrite(*bufr3,a_row);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(bufr3);	free(a_row);
			sprintf(s,"MEMwrite failed status %d\n",
			status); PDMdebug(s);
			return(PDM_E_WRITE_ROW);
		}
	}
	free(a_row);
/*
	if(PDMdebug_on)
	{
	MEMprint_buffer("after expansion",*bufr3,PDM_DEBUG_FILE);
	}
*/
	PDMdebug("EXIT:PDMexpand_copy_buffer\n");
	return(PDM_S_SUCCESS);
}

/*
		offsets_bufr

				n_nfmname
				n_offset
				n_name

		attr_bufr,data_bufr are used to find the offset of 
		n_nfmname in data_bufr. <n_offset,n_name> are set 
		in offsets_bufr
*/

int  PDMset_offsets(attr_bufr,data_bufr,offsets_bufr)
MEMptr	attr_bufr;
MEMptr	data_bufr;
MEMptr	offsets_bufr;
{
		char		**attr_column, **attr_data;
		char 		**data_column, **offsets_data;
		char		offset[40];
		int		i, j, k, n1, n2, nxi = 0, nxj = 0, found;

	PDMdebug("ENTER:PDMset_offsets\n");
/*	if(PDMdebug_on)
    {
			MEMprint_buffer("before setting offset",
			offsets_bufr,PDM_DEBUG_FILE);
    }
*/
	status = MEMbuild_array(attr_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	n1 = -1; n2 = -1;
	attr_column = (char **) attr_bufr->column_ptr;
	attr_data = (char **) attr_bufr->data_ptr;
	for(i=0;i<attr_bufr->columns;i++)
	{
		if(!strcmp(attr_column[i],"n_name"))	  n1 = i;
		if(!strcmp(attr_column[i],"n_name"))	  n2 = i;
		if(n1 != -1 && n2 != -1)   break;
	}
	if(n1 == -1 || n2 == -1)
	{
		sprintf(s,"Could not find reqd. columns in attr_bufr\n");
		PDMdebug(s);
		return(PDM_E_BUFFER_FORMAT);
	}
	status = MEMbuild_array(data_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data_column = (char **) data_bufr->column_ptr;

	status = MEMbuild_array(offsets_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	offsets_data = (char **) offsets_bufr->data_ptr;

	for(i=0;i<offsets_bufr->rows;i++)
	{
		nxi = i * offsets_bufr->columns;

			/* find row in attr_bufr */

		found = 0;
		for(j=0;j<attr_bufr->rows;j++)
		{
			nxj = j * attr_bufr->columns;
			if(!strcmp(offsets_data[nxi],attr_data[nxj+n1]))
			{
				found = 1;
				break;
			}
		}
		if(!found)
		{
			sprintf(s,"n_nfmname <%s> Can not be found in attr_bufr\n",
			offsets_data[nxi]);		PDMdebug(s);
			return(PDM_E_FAILURE);
		}
		   /* use row found above and locate offset in data_bufr */

		for(k=0;k<data_bufr->columns;k++)
		{
			if(!strcmp(attr_data[nxj+n2],data_column[k]))
			{
				sprintf(offset,"%d",k);
				status = MEMwrite_data(offsets_bufr,offset,i+1,2);
				if(status != MEM_S_SUCCESS)
				{
					return(PDM_E_WRITE_COLUMN);
				}
				status = MEMwrite_data(offsets_bufr,
								attr_data[nxj+n2],i+1,3);
				if(status != MEM_S_SUCCESS)
				{
					return(PDM_E_WRITE_COLUMN);
				}
			}
		}
	}
/*	if(PDMdebug_on)
    {
			MEMprint_buffer("after setting offsets ",
				offsets_bufr,PDM_DEBUG_FILE);
    }
*/
	PDMdebug("EXIT:PDMset_offsets\n");
	return(PDM_S_SUCCESS);
}
