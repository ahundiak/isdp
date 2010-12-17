#include <stdio.h>
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include <PDUerror.h>
#include "PDMproto.h"
#include "PDUpdmrpro.h"
#include "NFMerrordef.h"

extern int	PDMdebug_on;
extern char PDM_DEBUG_FILE[];
extern          PDMexec_ptr     PDMexec;
static  long   status;
static  char   s[1024];

int PDMi_query_families(catalog,part_num,revision,type,bufr)
char	*catalog;
char	*part_num;
char	*revision;
int		type;
MEMptr  *bufr;
{
	int		p_libraryno;
	char	sql_str[1024];

	PDMdebug("ENTER:PDMi_query_families\n");

	/* Verify if Library exists */

	status = PDMverify_part(catalog,part_num,revision);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"Library <%s:%s> Not found\n",part_num,revision);
		PDMdebug(s);
		return(PDM_E_LIBRARY_NOT_FOUND);
	}
  
    /* Find part no */

	status = PDMquery_partno(catalog,part_num,revision,&p_libraryno);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMquery_partno failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}
	if(type == 0)
	{
		sprintf(sql_str,"%s %s %d",
		"SELECT p_familyname FROM pdmfamilies ",
		"WHERE p_libraryno = ",p_libraryno);
	}
	else
	{
		sprintf(sql_str,"%s %s %d",
		"SELECT p_familyno,p_familyname FROM pdmfamilies ",
		"WHERE p_libraryno = ",p_libraryno);
	}
	status = SQLquery(sql_str,bufr,512);	
	if(status != SQL_S_SUCCESS)
    {
 		if(status == SQL_I_NO_ROWS_FOUND)
		{
			MEMclose(bufr);
			PDMdebug("EXIT:PDMi_query_families\n");
			return(PDM_I_NO_FAMILIES_DEFINED);
        }
		else if(status == PDMS_NO_SUCH_TABLE)
		{
			MEMclose(bufr);
			return(PDM_E_CATALOG_NOT_FOUND);
		}
		else if(status == PDMS_NO_SUCH_TABLE)
		{
			MEMclose(bufr);
			return(PDM_E_REQ_COLUMN_NOT_FOUND);
		}
		else
		{
			MEMclose(bufr);
			return(PDM_E_FAILURE);
		}
    }
	PDMdebug("EXIT:PDMi_query_families\n");	
	return(PDM_S_SUCCESS);
}

/* Creates a parametric table */

int PDMi_create_pdc_table(user_id,table_name,
						parm_bufr,prompt_bufr)
long	user_id;
char	*table_name;
MEMptr	parm_bufr;
MEMptr	prompt_bufr;
{
	int		a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11;
	int		i,j,nxi,nxj,k;
	int		row_no;
	char	**data1, **data2;
	char	**column_ptr;
	char	one_row[1024];
	MEMptr	attr_buffer = NULL;
	MEMptr	data_buffer = NULL;
	MEMptr	list_buffer = NULL;

	PDMdebug("ENTER:PDMi_create_pdc_table \n");

	status = MEMbuild_array(parm_bufr);
	if(status != MEM_S_SUCCESS)
	{

		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data1 = (char **) parm_bufr->data_ptr;
	status = MEMbuild_array(prompt_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data2 = (char **) prompt_bufr->data_ptr;

	/*  Get a template of attribute bufr from NFM  */
     
     status = NFMquery_table_template(user_id,&attr_buffer);
     if (status != NFM_S_SUCCESS)
     {
		sprintf(s,
 		 "NFMquery_table_template failed; status = %d\n", status);
		PDMdebug(s);
		status = PDM_E_QUERY_TABLE_TEMPLATE;
		return (status);
     }
     status = MEMbuild_array (attr_buffer);
     if (status != MEM_S_SUCCESS)
     {
		sprintf(s,
 		 "MEMbuild_array failed; status = %d\n", status);
		PDMdebug(s);
		MEMclose (&attr_buffer);
		status = PDM_E_BUILD_ARRAY;
		return (status);
     }
	 column_ptr = (char **) attr_buffer->column_ptr;
	 a1 = -1; a2 = -1; a3 = -1; a4 = -1;
     a5 = -1; a6 = -1; a7 = -1;  a8 = -1; a9 = -1; 
	 a10 = -1; a11 = -1;

	 for(i=0;i<attr_buffer->columns;i++)
     {
		if(!strcmp(column_ptr[i],"n_name"))      	   a1 = i;
		else if(!strcmp(column_ptr[i],"n_datatype"))   a2 = i;
		else if(!strcmp(column_ptr[i],"n_synonym"))    a3 = i;
		else if(!strcmp(column_ptr[i],"n_read"))       a4 = i;
		else if(!strcmp(column_ptr[i],"n_write"))      a5 = i;
		else if(!strcmp(column_ptr[i],"n_update"))     a6 = i;
		else if(!strcmp(column_ptr[i],"n_delete"))     a7 = i;
		else if(!strcmp(column_ptr[i],"n_null"))       a8 = i;
		else if(!strcmp(column_ptr[i],"n_seqno"))      a9 = i;
		else if(!strcmp(column_ptr[i],"n_keyin")) 	   a10 = i;
		else if(!strcmp(column_ptr[i],"n_nfmname"))	   a11 = i;
     }

	 if(a1 == -1 || a2 == -1 || a3 == -1 || a4 == -1 ||
		a5 == -1 || a6 == -1 || a7 == -1 || a8 == -1 ||
		a9 == -1 || a10 == -1 || a11 == -1)
     {
		PDMdebug("attr_buffer is of invalid format \n");
		MEMclose (&attr_buffer);
		return(PDM_E_BUFFER_FORMAT);
     }

	/* add p_citno as additional attribute */

	row_no = 1;
	one_row[0] = '\0';
    for(k=0;k<attr_buffer->columns;k++)
    {
		if(k == a1)      strcat(one_row,"p_pdcno");
		else if(k == a2) strcat(one_row,"integer");
		else if(k == a4) strcat(one_row,"Y");
		else if(k == a5) strcat(one_row,"Y");
		else if(k == a6) strcat(one_row,"Y");
		else if(k == a7) strcat(one_row,"N");
		else if(k == a8) strcat(one_row,"Y");
		else if(k == a9) 
		{
			s[0] = '\0';; sprintf(s,"%d",row_no);
			strcat(one_row,s);
        }
		else if(k == a10) 
		{
			s[0] = '\0';; sprintf(s,"%d",-1);
			strcat(one_row,s);
		}
		else if(k == a11) strcat(one_row,"p_pdcno");

		strcat(one_row,"\1");
  }
  status = MEMwrite(attr_buffer,one_row);
  if(status != MEM_S_SUCCESS)
  {
		MEMclose(&attr_buffer);
		sprintf(s,"MEMwrite failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_ROW);
  }

   /*  Add the required attributes for the table  */

	for(i=0;i<parm_bufr->rows;i++)
	{
		nxi = i * parm_bufr->columns;
		for(j=0;j<prompt_bufr->rows;j++)
		{
			nxj = j * prompt_bufr->columns;	
			if(atoi(data1[nxi]) == atoi(data2[nxj]))
			{
			  row_no = row_no + 1;
			  one_row[0] = '\0';
			  for(k=0;k<attr_buffer->columns;k++)
			  {
				if(k == a1)      strcat(one_row,data1[nxi+1]);
				else if(k == a2) strcat(one_row,data1[nxi+2]);
				else if(k == a3) 
				{
					strcat(one_row,data2[nxj+1]);
				}
				else if(k == a4) strcat(one_row,"Y");
				else if(k == a5) strcat(one_row,"Y");
				else if(k == a6) strcat(one_row,"Y");
				else if(k == a7) strcat(one_row,"N");
				else if(k == a8) strcat(one_row,"Y");
				else if(k == a9) 
				{
					s[0] = '\0';; sprintf(s,"%d",row_no);
					strcat(one_row,s);
                                }
				else if(k == a10) 
				{
					s[0] = '\0';; sprintf(s,"%d",-1);
					strcat(one_row,s);
				}
				else if(k == a11) strcat(one_row,data1[nxi+1]);
				strcat(one_row,"\1");
			  }
			  status = MEMwrite(attr_buffer,one_row);
			  if(status != MEM_S_SUCCESS)
			  {
				MEMclose(&attr_buffer);
				sprintf(s,"MEMwrite failed status %d\n",status);
				PDMdebug(s);
				return(PDM_E_WRITE_ROW);
			  }
			}
		}
    }
   /*  Load initial & default values of the above attrbs from 
       .data file */

	status = PDMi_create_databuffer(attr_buffer,&data_buffer);
	if(status != PDM_S_SUCCESS)
    {
	    sprintf(s,"PDMi_create_databuffer failed : %d\n",status);
	    PDMdebug(s);
	    MEMclose (&attr_buffer);
	    MEMclose(&data_buffer);
	    MEMclose(&list_buffer);
	    return (status);
	}

   /*  Load list values of the above attrbs from file */
   /*  there may or may not be a list_file */

    /*  Call NFM to create the table  */

     status = NFMcreate_table (user_id, table_name, table_name, 
			    attr_buffer,data_buffer,list_buffer);
     if (status != NFM_S_SUCCESS)
     {
	    sprintf(s,"NFMcreate_table failed : %d\n",status);
	    PDMdebug(s);
	    MEMclose (&attr_buffer);
	    MEMclose(&data_buffer);
	    MEMclose(&list_buffer);
	    status = PDM_E_CREATE_TABLE;
	    return (status);
     }

    MEMclose(&attr_buffer);
    MEMclose(&data_buffer);
    MEMclose(&list_buffer);
	PDMdebug("EXIT:PDMi_create_pdc_table\n");
    return (PDM_S_SUCCESS);
}

/* attr_buffer is used to create data_buffer. 
   each attr_name and datatype columns in attr_buffer 
   makeup the data_buffer format. 
   entries in filename is of fixed format. */

PDMi_create_databuffer (attr_buffer,data_buffer)
  MEMptr	attr_buffer;
  MEMptr	*data_buffer;
  {
	int	i;
        int     nx1, nx2;
        int     rows,cols;
	int     name_offset, dtype_offset;
	char	**data, **column;
	char	s[1024];
 	char	dummy_row[1024];
	MEMptr	tmp_bufr = NULL;

	PDMdebug("ENTER:PDMi_create_databuffer\n");

/* create data_buffer  */

   status = MEMbuild_array(attr_buffer);
   if(status != MEM_S_SUCCESS)
   {
		sprintf(s,"MEMbuild_array failed status = %d",status);
		PDMdebug(s);
		status = PDM_E_BUILD_ARRAY;
		return (status);
   }
   rows = attr_buffer->rows;
   cols = attr_buffer->columns;
   data = (char **)attr_buffer->data_ptr;
   column = (char **)attr_buffer->column_ptr;
   name_offset = -1;
   dtype_offset = -1;

/* find offsets of n_name and n_datatype in the attr_buffer */

   for(i=0;i<cols;i++)
   {
       if(!strcmp(column[i],"n_name"))
       {
		   name_offset = i;
       }
       if(!strcmp(column[i],"n_datatype"))
       {
		   dtype_offset = i;
       }
       if(name_offset != -1 && dtype_offset != -1)
	   break;
   }
   if(name_offset == -1 || dtype_offset == -1)
   {
       PDMdebug("Input buffer format is invalid\n");
       status = PDM_E_BUFFER_FORMAT;
       return(status);
   }
   status = MEMopen(&tmp_bufr,2048);
   if(status != MEM_S_SUCCESS)
   {
		sprintf(s,"MEMopen failed status = %d",status);
		PDMdebug(s);
		status = PDM_E_OPEN_BUFFER;
		return (status);
   }
   for(i=0;i<rows;i++)
   {
       nx1 = i * cols + name_offset;
       nx2 = i * cols + dtype_offset;
       status = MEMwrite_format(tmp_bufr,data[nx1],data[nx2]);
       if(status != MEM_S_SUCCESS)
       {
 	  		sprintf(s,"MEMwrite_format failed status = %d",status);
	  		PDMdebug(s);
          	MEMclose(&tmp_bufr);
   	  		status = PDM_E_WRITE_FORMAT;
          	return (status);
       }
    }
    strcpy(dummy_row,"");
    for(i=0;i<rows;i++)
    {
		strcat(dummy_row,"\1");
    }   
    status = MEMwrite(tmp_bufr,dummy_row);
    if(status != MEM_S_SUCCESS )
    {
		sprintf(s,"MEMwrite failed status = %d",status);
		PDMdebug(s);
                MEMclose(&tmp_bufr);
		status = PDM_E_WRITE_ROW;
		return (status);
    }
    status = MEMbuild_array(tmp_bufr);
    if(status != MEM_S_SUCCESS)
    {
		sprintf(s,"MEMbuild failed status = %d",status);
		PDMdebug(s);
                MEMclose(&tmp_bufr);
		status = PDM_E_WRITE_ROW;
		return (status);
    }
  *data_buffer = tmp_bufr;
  PDMdebug("EXIT:PDMi_create_databuffer\n");
  return (PDM_S_SUCCESS);
}

int	  PDMi_query_familyno(p_familyname,p_familyno)
char	*p_familyname;
int		*p_familyno;
{
	char	sql_str[512];
	char	**data;
	MEMptr	bufr = NULL;

	PDMdebug("ENTER:PDMi_query_familyno\n");
	sprintf(sql_str,"%s %s '%s' ",
	"SELECT p_familyno FROM pdmfamilies ",
	"WHERE p_familyname = ",p_familyname);
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
 		if(status == SQL_I_NO_ROWS_FOUND)
		{
		return(PDM_E_FAMILY_NOT_FOUND);
		}
		MEMclose(&bufr);
		sprintf(s,"SQLquery failed status %d \n",status);
		PDMdebug(s);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMbuild_array failed status %d \n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	*p_familyno = atoi(data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_query_familyno\n");
	return(PDM_S_SUCCESS);
}

int	  PDMi_query_libraryno(p_familyname,p_libraryno)
char	*p_familyname;
int		*p_libraryno;
{
	char	sql_str[512];
	char	**data;
	MEMptr	bufr = NULL;

	PDMdebug("ENTER:PDMi_query_libraryno\n");
	sprintf(sql_str,"%s %s '%s' ",
	"SELECT p_libraryno FROM pdmfamilies ",
	"WHERE p_familyname = ",p_familyname);
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"SQLquery failed status %d \n",status);
		PDMdebug(s);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMbuild_array failed status %d \n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	*p_libraryno = atoi(data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_query_libraryno\n");
	return(PDM_S_SUCCESS);
}

int	  PDMi_query_flyname(catno,p_familyname)
int	catno;
char	*p_familyname;
{
	char	sql_str[512];
	char	**data;
	MEMptr	bufr = NULL;
      

	PDMdebug("ENTER:PDMi_query_flyname\n");
	sprintf(sql_str,"%s %s %d %s",
	"SELECT pdmfamilies.p_familyname FROM pdmfamilies,nfmcatalogs ",
	"WHERE nfmcatalogs.n_catalogno = ",catno,
        "AND nfmcatalogs.n_catalogname = pdmfamilies.n_catalogname");
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"SQLquery failed status %d \n",status);
		PDMdebug(s);
		MEMclose(&bufr);
 		if(status == SQL_I_NO_ROWS_FOUND)
		{
		return(PDM_E_FAMILY_NOT_FOUND);
		}
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMbuild_array failed status %d \n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(p_familyname,data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_query_flyname\n");
	return(PDM_S_SUCCESS);
}

int	PDMi_verify_macronames(p_libraryno,macro_names)
int		p_libraryno;
MEMptr	macro_names;
{
	int		i,j,found;
	char	sql_str[512];
	char	**data1,**data2;
	MEMptr	macro_old = NULL;

	PDMdebug("ENTER:PDMi_verify_macronames\n");
	status = MEMbuild_array(macro_names);
	if(status != MEM_S_SUCCESS) 
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	sprintf(sql_str,"%s %s %d",
	"SELECT p_familyname FROM pdmfamilies ",
	"WHERE p_libraryno = ",p_libraryno);
	status = SQLquery(sql_str,&macro_old,512);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&macro_old);
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(macro_old);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&macro_old);
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data1 = (char **) macro_names->data_ptr;
	data2 = (char **) macro_old->data_ptr;
	for(i=0;i<macro_old->rows;i++)
	{
	   found = 0;
	   for(j=0;j<macro_names->rows;j++)
	   {
			if(!strcmp(data2[i],data1[j]))  found = 1;
	   }
	   if(!found)
	   {
			MEMclose(&macro_old);
			sprintf(s,
			"Parameteric family <%s> is deleted from library \n",
			data2[j]);PDMdebug(s);
			return(PDM_E_MACRO_DELETED);
	   }
	}
	MEMclose(&macro_old);
	PDMdebug("EXIT:PDMi_verify_macronames\n");
	return(PDM_S_SUCCESS);
}

int PDMi_verify_macrodefn(p_familyname,def_bufr)
char	*p_familyname;
MEMptr	def_bufr;
{
	int		p_familyno;
	int		nxi,i,nxj,macro_modify;
	MEMptr	bufr = NULL;
	char	sql_str[1024];
	char	**data1, **data2;

	PDMdebug("ENTER:PDMi_verify_marodefn\n");
  if(PDMdebug_on)
  MEMprint_buffer("def_bufr", def_bufr,PDM_DEBUG_FILE);
	status = MEMbuild_array(def_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d \n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
    data2 = (char **) def_bufr->data_ptr;
	status = PDMi_query_familyno(p_familyname,&p_familyno);
	if(status != PDM_S_SUCCESS)
    {
		sprintf(s,"%s family is not found \n",p_familyname);
		PDMdebug(s);
		return(PDM_E_FAMILY_NOT_FOUND);
	}
	sprintf(sql_str,"%s FROM pdmparameters %s %d %s",
	"SELECT p_seqno,p_parametertype ",
	"WHERE p_familyno = ",p_familyno, 
	"ORDER BY p_seqno");
	status = SQLquery(sql_str,&bufr,1024);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr);
		PDMdebug("SQLquery failed status %d\n",status);
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	if(bufr->rows != def_bufr->rows)
	{
		MEMclose(&bufr);
		sprintf(s,"No of parameters have been changed for <%s> \n",
		p_familyname);	PDMdebug(s);
		return(PDM_E_MACRO_MODIFIED);
	}
if(PDMdebug_on)
	MEMprint_buffer("compare with bufr", bufr, PDM_DEBUG_FILE);

	    data1 = (char **) bufr->data_ptr;
	macro_modify = 0;
	for(i=0;i<bufr->rows;i++)
	{
		nxi = i * bufr->columns;
		nxj = i * 2;
		if(strcmp(data1[nxi+0],data2[nxj+0]) ||
		   strcmp(data1[nxi+1],data2[nxj+1]))
		{
		   sprintf(s, "<%s:%s> doesn't match with <%s:%s>", 
		   data1[nxi],data1[nxi+1], data2[nxj+0], data2[nxj+1]);
		   PDMdebug(s);
			macro_modify = 1;  break;
		}
	}
	if(macro_modify)
	{
		MEMclose(&bufr);
		sprintf(s,"Parameter-type has been changed for <%s> \n",
		p_familyname);	PDMdebug(s);
		return(PDM_E_MACRO_MODIFIED);
	}
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_verify_marodefn\n");
	return(PDM_S_SUCCESS);
}

int PDMi_delete_pdcentry(p_familyname,citno)
char	*p_familyname;
long	citno;
{
	char	pdc_table[40];
	char	sql_str1[100];
	char	*sql_str;
	char	value[17];
	MEMptr	bufr = NULL;
	char	**data;
	int		i,nxi;

	PDMdebug("ENTER:PDMi_delete_pdcentry\n");
	sprintf(sql_str1,"%s %d",
	"SELECT p_pdcno FROM pdmcit WHERE p_citno = ",
	citno);
	status = SQLquery(sql_str1,&bufr,512);
	if(status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
status = _PDMget_db_error (status);
		return(status);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	sprintf(pdc_table,"y_%s",p_familyname);
/*
   This way of deleting is not efficient
	for(i=0;i<bufr->rows;i++)
	{
		sprintf(sql_str,"%s %s %s %s",
		"DELETE FROM ",
 	     pdc_table,
		"WHERE p_pdcno = ",data[i]);
    	status = SQLstmt(sql_str);
    	if(status != SQL_S_SUCCESS) {
		sprintf(s,"Could not delete %s entry\n",
		pdc_table); PDMdebug(s);
		}
	}
*/
     sql_str = (char *) malloc((bufr->rows * 20) + 100);
      memset (sql_str,NULL,((bufr->rows * 20) + 100));
     sprintf(sql_str1," DELETE FROM %s WHERE p_pdcno = %d", pdc_table,atol(data[0]));  
      strcpy(sql_str,sql_str1);
       for(i = 1 ; i < bufr->rows; i++) {
            nxi = i * bufr->columns;
            value[0] = '\0';
            sprintf(value," OR p_pdcno = %s", data[nxi]);
            strcat(sql_str,value);
          }
    	status = SQLstmt(sql_str);
    	if(status != SQL_S_SUCCESS)
		{
			sprintf(s,"Could not delete %s entry\n",
			pdc_table); PDMdebug(s);
		}
        free(sql_str);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_delete_pdcentry\n");
	return(PDM_S_SUCCESS);
}

int PDMi_insert_pdcinfo(p_flyname,pdc_bufr,parm_data)
char     *p_flyname;
MEMptr     pdc_bufr;
MEMptr  parm_data;
{
     char     *fn = "PDMi_insert_pdcinfo";
     char     *pdc_table;
     char     p_pdcno[40];
     char     ref_catalog [400];
     char     low_pdc_table [40];
     int      i,nx,nx1,j,k,size,length;
     char     **data, **pdc_data;
     char     **column, **format;
     char     *attrbs, *values, *sql_str;
     MEMptr   type_bufr = NULL;
     int     pdc_tblno;

     PDMdebug("ENTER:PDMi_insert_pdcinfo\n");

/*     *pdc_tableno = 0;*/
     if(PDMdebug_on) {
          MEMprint_buffer("pdc_bufr",pdc_bufr,PDM_DEBUG_FILE);
          MEMprint_buffer("parm_data",parm_data,PDM_DEBUG_FILE);
               }

/* commented out since dyn table may not be y_catalog...
     sprintf(pdc_table,"y_%s",p_flyname);
                                          - MaC 011193...*/

        ref_catalog[0] = '\0';
        strcpy (ref_catalog, PDMexec->catalog);
        strcpy (PDMexec->catalog, p_flyname);

        status = PDMdyntable_for_catalog(&pdc_table);
        if (status != PDM_S_SUCCESS) {
            _PDMdebug (fn, "PDMdyntable_for_catalog status = <%d>\n", status);
            if (pdc_table) free (pdc_table);
            return (PDM_E_GET_ATTRIBUTES);
        }
       _PDMdebug (fn, "dynamic_table [%s]\n", pdc_table);

        strcpy (PDMexec->catalog, ref_catalog);


     status = PDMquery_table_no(pdc_table, &pdc_tblno);
     if (status != PDM_S_SUCCESS && status != PDM_E_NO_CAT_ENTRY) {
         _PDMdebug(fn, "PDMquery_table_no status = <%d>\n", status);
        return (PDM_E_NO_CAT_ENTRY);
        }

/* fix to check to see if the table name is in lower case */

        if (status != PDM_S_SUCCESS) {
          PDMconvert_to_lower(pdc_table, low_pdc_table);
          status = PDMquery_table_no(low_pdc_table, &pdc_tblno);
          if (status != PDM_S_SUCCESS) {
            _PDMdebug(fn, "PDMquery_table_no status = <%d>\n", status);
           return (status);
           }
          }
   
      _PDMdebug (fn, "pdc_tblno[%d]\n", pdc_tblno);
/*
     *pdc_tableno = pdc_tblno;
*/

     column = (char **) parm_data->column_ptr;
     size = 512;
     for(i=1;i<parm_data->columns;i++)
     {
          size = size + strlen(column[i]);
     }
     attrbs = (char *) malloc(size);
     if(attrbs == NULL)
     {
          PDMdebug("malloc failed \n");
          return(PDM_E_COULD_NOT_MALLOC);
     }
     format = (char **) parm_data->format_ptr;
     size = 512;
     for(i=1;i<parm_data->columns;i++)
     {
          if(!strncmp(format[i],"char",4))
          {
               sscanf(format[i],"char(%d)",&length);
          }
          else
          {
               length = 40;
          }
          size = size + length;
     }
     values = (char *) malloc(size);
     if(values == NULL)
     {
          PDMdebug("malloc failed \n");
          free(attrbs);
          return(PDM_E_COULD_NOT_MALLOC);
     }
     sql_str = (char *) malloc(strlen(attrbs) + strlen(values) +512);
     if(sql_str == NULL)
     {
          PDMdebug("malloc failed \n");
          free(attrbs); free(values);
          return(PDM_E_COULD_NOT_MALLOC);
     }
     status = MEMopen(&type_bufr,512);
     if(status != MEM_S_SUCCESS)
     {
          free(attrbs); free(values);free(sql_str);
          sprintf(s,"MEMopen failed status %d\n",status);
          PDMdebug(s);
          return(PDM_E_OPEN_BUFFER);
     }

     /* set the type for the family once */

     strcpy (attrbs,"(p_pdcno");
     for(i=2;i<parm_data->columns;i++)
     {
          status = PDMvalidate_attribute(column[i],pdc_tblno);
          if(status != PDM_E_ATTR_EXISTS) {
               sprintf(s,"PDMvalidate_attribute failed status %d\n",
               status); PDMdebug(s);
                        continue;
          }
               strcat(attrbs,",");
               strcat(attrbs,column[i]);               
     }
     strcat(attrbs,")");

     data = (char **) parm_data->data_ptr;
     format = (char **) parm_data->format_ptr;
     pdc_data = (char **) pdc_bufr->data_ptr;
     for(i=0;i<parm_data->rows;i++)
     {
          nx = i * parm_data->columns;
          strcpy(values," VALUES (");
          strcpy(p_pdcno,"");
          for(k=0;k<pdc_bufr->rows;k++)
          {
               nx1 = k * pdc_bufr->columns;
               if(!strcmp(pdc_data[nx1+3],data[nx]))
               {
                    strcpy(p_pdcno,pdc_data[nx1+4]);
                    break;
               }
          }
          if(strlen(p_pdcno) == 0)
          {
               sprintf(s,"p_pdcno not found for child <%d>\n",
               data[nx]);     PDMdebug(s);
               return(PDM_E_FAILURE);
          }
           strcat(values,p_pdcno);
           strcat(values,",");
          for(j=2;j<parm_data->columns;j++)
          {
                    if(!strncmp(format[j],"char",4))
                    {
                         strcat(values,"'");
                         strcat(values,data[nx+j]);
                         strcat(values,"'");
                    }
                                 
                    else
                    {
                                  if((strlen(data[nx+j])== 0)) strcat(values,"NULL");
                                    else
                         strcat(values,data[nx+j]);
                      
                    }
                    if(j != parm_data->columns-1)
                    {
                         strcat(values,",");
                    }
          }
          strcat(values,")");
sprintf(sql_str,"DELETE FROM %s WHERE p_pdcno = %s ",pdc_table,p_pdcno);
          status = SQLstmt(sql_str);
                sql_str[0]='\0';
      
          sprintf(sql_str,"INSERT INTO %s %s %s ",pdc_table,attrbs,values);
          status = SQLstmt(sql_str);
          if(status != SQL_S_SUCCESS)
          {
               if(attrbs) free(attrbs); if(values) free(values);if(sql_str) free(sql_str);
               sprintf(s,"SQLstmt failed status %d\n",status);
               PDMdebug(s);
               return(PDM_E_SQL_STMT);
          }
     }
if(sql_str)free(sql_str);if(attrbs) free(attrbs);if( values) free(values);
     MEMclose(&type_bufr);
        if (pdc_table) free (pdc_table);
     PDMdebug("EXIT:PDMi_insert_pdcinfo\n");
     return(PDM_S_SUCCESS);
}

int PDMi_find_sizes(n_tablename,size1,size2)
char	*n_tablename;
int		*size1;
int		*size2;
{
	char	sql_str[512];
	char	temp[30];
	int		n_tableno,length;
	int		i,nx;
	char	**data;
	MEMptr	bufr = NULL;

	PDMdebug("ENTER:PDMi_find_sizes\n");
	
	/* get n_tableno from nfmtables */

	status = PDMget_table_no(n_tablename,n_tablename,&n_tableno);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMget_tableno failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}
	sprintf(sql_str,"%s %s %d",
	"SELECT n_name,n_datatype FROM nfmattributes ",
	"WHERE n_tableno = ",n_tableno);
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",
		status); PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	for(i=0;i<bufr->rows;i++)
	{
		nx = i * bufr->columns;
		*size1 = *size1 + strlen(data[nx]);
		if(!strncmp(data[nx+1],"char",4))
		{
			sscanf(data[nx+1],"%5s%d",temp,&length);
			*size2 = *size2 + length;
		}
		else
		{
			*size2 = *size2 + 32;
		}
	}
sprintf(s," size1 %d size2 %d\n",*size1, *size2);
PDMdebug(s);
	PDMdebug("EXIT:PDMi_find_sizes\n");
	return(PDM_S_SUCCESS);
}

int  PDMi_delete_pdc_entries(p_citno,p_flyname)
int		p_citno;
char	*p_flyname;
{
	char	sql_str[512];
	char	**data;
	char	pdc_table[20];
	MEMptr	bufr = NULL;
	int		i;

	PDMdebug("ENTER:PDMi_delete_pdc_entries\n");
	sprintf(pdc_table,"y_%s",p_flyname);
	sprintf(sql_str,
	"SELECT p_pdcno FROM pdmcit %s %d",
	"WHERE p_citno = ",p_citno);
	status = SQLquery(sql_str,&bufr,512);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr);
 		if(status == SQL_I_NO_ROWS_FOUND)
		{
			sprintf(s,"No rows in pdmcit for pcit_no = %d\n",
			p_citno); PDMdebug(s);
			return(PDM_S_SUCCESS);
		}
		sprintf(s,"SQLquery %d\n",status);
		PDMdebug(s);
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
           for (i = 0; i < bufr->rows; i++) {
               if (i == 0 && atol(data[i])) {
                sprintf(sql_str, "%s %s %s %d",
                        "DELETE FROM ", pdc_table,
                        " WHERE p_pdcno = ", atol(data[i]));
                     } else {
                        if(atol(data[i]))
                         {
                            strcat(sql_str, " OR p_pdcno = ");
                            strcat(sql_str, data[i]);
                          }
                 }
             }
                status = SQLstmt(sql_str);

	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_delete_pdc_entries\n");
	return(PDM_S_SUCCESS);
}

/* Written to support nthlvel parametric assemblies' dynamic attribute
   information insertion - Kumar 6.10.93 */

int PDMinsert_nthlevel_dynamic_info(p_pdcno,pdc_table, parm_data)
int      p_pdcno;
char     *pdc_table;
MEMptr   parm_data;
{
     char     *fn = "PDMinsert_nthlevel_dynamic_info";
     int      i,nx,j,size,length;
     char     **data, pdcno[5];
     char     **column, **format;
     char     *attrbs, *values, *sql_str;

     _PDMdebug(fn, "ENTER:\n");

     /* status = MEMbuild_array(parm_data);
     if(status != MEM_S_SUCCESS)
       return(PDM_S_SUCCESS); */
     column = (char **) parm_data->column_ptr;
     size = 512;
     for(i=1;i<parm_data->columns;i++)
     {
          size = size + strlen(column[i]);
     }
     attrbs = (char *) malloc(size);
     if(attrbs == NULL)
     {
          PDMdebug("malloc failed \n");
          return(PDM_E_COULD_NOT_MALLOC);
     }
     format = (char **) parm_data->format_ptr;
     size = 512;
     for(i=1;i<parm_data->columns;i++)
     {
          if(!strncmp(format[i],"char",4))
          {
               sscanf(format[i],"char(%d)",&length);
          }
          else
          {
               length = 40;
          }
          size = size + length;
     }
     values = (char *) malloc(size);
     if(values == NULL)
     {
          PDMdebug("malloc failed \n");
          free(attrbs);
          return(PDM_E_COULD_NOT_MALLOC);
     }
     sql_str = (char *) malloc(strlen(attrbs) + strlen(values) +512);
     if(sql_str == NULL)
     {
          PDMdebug("malloc failed \n");
          free(attrbs); free(values);
          return(PDM_E_COULD_NOT_MALLOC);
     }
     /* set the type for the family once */

     strcpy (attrbs,"(p_pdcno");
     for(i=2;i<parm_data->columns;i++)
     {
               strcat(attrbs,",");
               strcat(attrbs,column[i]);               
     }
     strcat(attrbs,")");
     sprintf(pdcno, "%d", p_pdcno);
     data = (char **) parm_data->data_ptr;
     format = (char **) parm_data->format_ptr;
     for(i=0;i<parm_data->rows;i++)
     {
          nx = i * parm_data->columns;
          strcpy(values," VALUES (");
           strcat(values,pdcno);
           strcat(values,",");
          for(j=2;j<parm_data->columns;j++)
          {
                    if(!strncmp(format[j],"char",4))
                    {
                         strcat(values,"'");
                         strcat(values,data[nx+j]);
                         strcat(values,"'");
                    }
                                 
                    else
                    {
                     if((strlen(data[nx+j])== 0)) strcat(values,"NULL");
                     else
                     strcat(values,data[nx+j]);
                    }
                    if(j != parm_data->columns-1)
                    {
                         strcat(values,",");
                    }
          }
          strcat(values,")");
     /* sprintf(sql_str,"DELETE FROM %s WHERE p_pdcno = %d ",pdc_table,p_pdcno);
          status = SQLstmt(sql_str); */
                sql_str[0]='\0';
      
          sprintf(sql_str,"INSERT INTO %s %s %s ",pdc_table,attrbs,values);
          status = SQLstmt(sql_str);
          if(status != SQL_S_SUCCESS)
          {
     if(attrbs) free(attrbs); if(values) free(values);if(sql_str) free(sql_str);
               sprintf(s,"SQLstmt failed status %d\n",status);
               PDMdebug(s);
               return(PDM_E_SQL_STMT);
          }
     }
if(sql_str)free(sql_str);if(attrbs) free(attrbs);if( values) free(values);
     _PDMdebug(fn, "EXIT:\n");
     return(PDM_S_SUCCESS);
}

/* Written to delete the duplicate entries in the dynamic table
   - Kumar 6.15.93 */

int  PDUXi_delete_dynamic_info(p_citno,p_flyname, pdcno)
char	*p_citno;
char	*p_flyname;
MEMptr  pdcno;
{
        char    *fname = "PDMi_delete_dynamic_info";
	char	sql_str[512];
	char	**cit_data, **data;
	char	pdc_table[20];
	MEMptr	bufr = NULL;
	int	found = 0, nxi = 0,	i= 0;

	_PDMdebug(fname, "ENTER:\n");

         if(pdcno != NULL && pdcno->rows > 0)
         {
         sql_str[0]='\0';
     sprintf(sql_str,"SELECT p_dyntable FROM pdmcatalogs WHERE n_catalogno = (select n_catalogno from nfmcatalogs where n_catalogname = '%s')", p_flyname);
             status = SQLquery(sql_str,&bufr,512);
              if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
               {
              _PDMdebug (fname, "SQLquery : status = <0x%.8x>\n", status);
               MEMclose(&bufr);
               return (status) ;
                }
          if(status == SQL_I_NO_ROWS_FOUND)
             return (PDM_S_SUCCESS);
          else
            {
           status = MEMbuild_array(bufr);
           if(status != MEM_S_SUCCESS)
           {
              _PDMdebug (fname, "SQLquery : status = <0x%.8x>\n", status);
               MEMclose(&bufr);
               return (status) ;
           }
        pdc_table[0]= '\0'; 
	data = (char **) bufr->data_ptr;
	sprintf(pdc_table,"%s", data[0]);
         _PDMdebug(fname,"citno %s\n",p_citno);

     if(PDMdebug_on)
        MEMprint_buffer("pdcno bufr", pdcno,PDM_DEBUG_FILE);

           status = MEMbuild_array(pdcno);
           if(status != MEM_S_SUCCESS)
           {
              _PDMdebug (fname, "SQLquery : status = <0x%.8x>\n", status);
               return (status) ;
           }
           if(pdcno->rows == 0)
             {
              MEMclose(&bufr);
               return (PDM_S_SUCCESS) ;
             }
           found = 0;
	cit_data = (char **) pdcno->data_ptr;
           for (i = 0; i < pdcno->rows; i++) {
                 nxi = i * pdcno->columns;
               if(!strcmp(cit_data[nxi], p_citno))
                {
               if (found == 0 && atol(cit_data[nxi+1])) {
                sprintf(sql_str, "%s %s %s %s",
                        "DELETE FROM ", pdc_table,
                        " WHERE p_pdcno = ", cit_data[nxi+1]);
                       found = 1;
                     } else {
                        if(atol(cit_data[nxi+1]))
                         {
                            strcat(sql_str, " OR p_pdcno = ");
                            strcat(sql_str, cit_data[nxi+1]);
                          }
                       }
               }
             }
                status = SQLstmt(sql_str);
            }
	MEMclose(&bufr);
         }
	PDMdebug("EXIT:PDMi_delete_dynamic_info\n");
	return(PDM_S_SUCCESS);
}

