#include "machine.h"
/****************************************************************************
*									*
*			NFMattr_list					*
*									*
*	This procedure returns the list of attributes for a catalog	*
*	For each attribute in the table the n_name and n_nfmname are	*
*	returned							*
*									*
************************************************************************/

#include <stdio.h>
#include <malloc.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "SQLerrordef.h"
#include "NFMsacdef.h"
#include "DEBUG.h"
#include "ERR.h"


NFMattr_list(user_id,cat_name,cat_no,out_list,in_attr_list)
	long user_id;
	char *cat_name,*cat_no;
	MEMptr *out_list,in_attr_list;
{
 long status,table_no,size,length =0,i=0;
 char *sql_str,*cond_str,temp[SIZE];
 char *fname="NFMattr_list";
 char **data,**format;
	_NFMdebug((fname,"Entry >>\n\t\tuser_id\t%d\n\t\tcatalog name\t%s\n\t\t\
Catalog Number%s\n\t\tOutput list address\t%d\n\t\tIn_attribute_list\t%d\n",
user_id,cat_name,cat_no,out_list,in_attr_list));

	sql_str=cond_str=(char *)0;
/*	Check if user id is NULL */
	if(user_id <= 0)
	{
		_NFMdebug((fname,"Bad user_id <%d>\n",user_id));
/*	Error processor string here */
                status = ERRload_struct(NFM,NFM_E_BAD_USER_ID,"%d",user_id);
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_BAD_USER_ID);
	}
/* check if catalog name is non empty */
	if((strlen(cat_name)) <= 0)
	{
		_NFMdebug((fname,"Catalog name is empty <%s>\n",cat_name));
/*	Error processor string here */
                status = ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","Catalog name");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_VALUE);
	}
/* check if catalog number is non empty */
	if((strlen(cat_no)) <= 0  )
	{
		_NFMdebug((fname,"Catalog name is empty <%s>\n",cat_name));
/*	Error processor string here */
                status = ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","Catalog number");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_VALUE);
	}
/* check if the pointer to the MEMptr is NULL */
	if(out_list == MEMPTRNULL)
	{
		_NFMdebug((fname,"Output list pointer address is <%d>\n",out_list));
/*	Error processor string here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Out Buffer ptr");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);

	}
/* check if the output pointer is non empty */
	if(*out_list != MEMNULL)
	{
		_NFMdebug((fname,"<<<<WARNING>>>>Output list pointer is <%d>(NOT NULL)\n",*out_list));
		_NFMdebug((fname,"<<<<WARNING>>>>MEMclose on Output list pointer\n"));
		MEMclose(out_list);
	}

/* Get the table number */
/******************************************************************************

OLD  METHOD ( NOW TABLE NUMBER IS PASSED AS AN ARGUMENT 

	if((status=NFMget_table_no ( user_id , "CATALOG" , cat_name , &table_no))!=NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Cant get table number for catalog %s, status = <%0x%.8x>\n",cat_name,status));
		return(status);
	}
******************************************************************************/

	if((table_no = atol(cat_no)) <= 0)
	{
		_NFMdebug((fname,"Bad catalog table number  %s\n",cat_no));
		status = ERRload_struct(NFM,NFM_E_NO_CATALOGS,"%s","Bad catalog number");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_FAILURE);
	}
/* Check if a list of n_nfmnames is provided , if so append a condition string */
	size = STR_SIZE;
	if(in_attr_list != MEMNULL)
	{
	        if((status=MEMbuild_array(in_attr_list)) !=MEM_S_SUCCESS)
       		 {
			_NFMdebug((fname,"MEMbuild_array failed for *attr_list <0x%.8x>\n",status));
			status = ERRload_struct(NFM,NFM_E_MEM,"");
			if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                	return(NFM_E_MEM);
        	 }
		data = (char **)in_attr_list->data_ptr;
		format = (char **) in_attr_list -> format_ptr;
		
		if(in_attr_list->columns < 1 || in_attr_list-> rows < 1)
		{
			_NFMdebug((fname, " Rows %d Columns %d invalid\n",in_attr_list->rows,in_attr_list->columns));
			status=ERRload_struct(NFM,NFM_E_BAD_ATTR_VALUE,"%s","NFMattr_list");
                	if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
			return(NFM_E_BAD_ATTR_VALUE);
		}
/* Find the size of condition string required */
		size = 0;
                length = 0;
                if (! strncmp (format [0], "integer",  7)) length = 15;
                else if (! strncmp (format [0], "smallint", 8)) length = 15;
                else if (! strncmp (format [0], "double",   6)) length = 50;
                else if (! strncmp (format [0], "real",     4)) length = 50;
                else if (! strncmp (format [0], "char",     4))
                        sscanf (format [0], "%5s%d", temp, &length);
                if(length <= 0)
                {
                        _NFMdebug((fname,"Failed to get length of attribute 0\n"));
                        status = ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","Format length 0");
                        if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));

                        return(NFM_E_NULL_VALUE);
                }
                size = size + in_attr_list-> rows * (5+length) + 20 +SIZE;
/* allocate the buffers required */
		if((cond_str = malloc(size))== (char *)0)
		{
			_NFMdebug((fname,"Failed to malloc condition string size <%d>\n",size));
       		         status = ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
	                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                	return(NFM_E_MALLOC);
		}
		size = size + 2 * SIZE ;
		if((sql_str = malloc(size))== (char *)0)
		{
			_NFMdebug((fname,"Failed to malloc sql string size <%d>\n",size));
			if(cond_str!= (char *)0) free(cond_str);
       		         status = ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
	                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                	return(NFM_E_MALLOC);
		}
		strcpy(cond_str,"AND n_nfmname IN (");
		for(i=0;i<in_attr_list->rows; i++)
		{
			if(i > 0) strcat (cond_str,",");
			strcat(cond_str,"'");
			strcat(cond_str,data[i]);
			strcat(cond_str,"'");
		}
		strcat (cond_str , ")");
	}
	else if((sql_str = malloc(size))== (char *)0)
		{
			_NFMdebug((fname,"Failed to malloc condition string size <%d>\n",size));
       		         status = ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
	                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                	return(NFM_E_MALLOC);
		}
/* generate query to get n_name , n_nfmname from table number table_no */
	sprintf(sql_str,
	"SELECT %s FROM %s WHERE %s %d ",
        "n_name , n_nfmname " , "NFMATTRIBUTES" , "n_tableno = " , table_no);

	if(in_attr_list != MEMNULL) strcat (sql_str , cond_str);
			

/*
ORDER BY n_nfmname");
*/
	status = SQLquery(sql_str , out_list , 4*MEM_SIZE);
	if(status!=SQL_S_SUCCESS)
	{
		_NFMdebug((fname,"SQL query failed to get attribute list status=<0x%.8x>\n",status));
		MEMclose(out_list);
		free(sql_str);
		if(cond_str != (char *)0) free(cond_str);
                status = ERRload_struct(NFM,NFM_E_SQL_QUERY,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_SQL_QUERY);

	}
	_NFMdebug((fname,"Exit >> SUCCESSFUL\n"));
	free(sql_str);
	if(cond_str != (char *)0) free(cond_str);
	return(NFM_S_SUCCESS);
}
