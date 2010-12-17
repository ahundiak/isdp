#include "machine.h"
#include "DEBUG.h"

/****************************************************************************
*									*
*			NFMadd_col_val					*
*									*
*	This function adds a column entry in a list			*
*	The format must be created and a new list must be generated 	*
*	using NFMadd_col prior to using this function 			*
*<<>>	The same value is added to all the rows in the list		*
*	as the first column. The format for this column is loaded by	*
*	calling NFMadd_col
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
#include "ERR.h"


NFMadd_col_val(user_id,list,out_list, value)
	long user_id;
	MEMptr list,*out_list;
	char *value;
{
 long status,size,offset,length;
 MEMptr temp_ptr = MEMNULL;
 char *fname="NFMadd_col_val";
 char **data,**format;
 char *return_str,temp[SIZE];
 long i=0,j=0;

	_NFMdebug((fname,"Entry >>user_id %d  list %d\
 Out list address %d Value %s\n",user_id,list,out_list,value));

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
/* check if the pointer to the list is NULL */
	if(list == MEMNULL)
	{
		_NFMdebug((fname,"Input list is NULL <%d>\n",list));
/*	Error processor string here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","input_list");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* check if the pointer to the MEMptr is NULL */
	if(out_list == MEMPTRNULL)
	{
		_NFMdebug((fname,"Output list pointer address is <%d>NULL\n",out_list));
/*	Error processor string here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Output Buffer ptr");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* check if the pointer to the out list is NULL */
/* This must be a non-null val ptr created by calling NFMadd_col */
	if(*out_list == MEMNULL)
	{
		_NFMdebug((fname,"out list is NULL <%d>\n",*out_list));
/*	Error processor string here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Output Buffer Entries");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}

/*	build the array of list */
        if((status=MEMbuild_array(list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for  list\
                 status = <0x%.8x>\n" , status));
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MEM);
        }
/*	build the array of out_list */
        if((status=MEMbuild_array(*out_list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for  *out_list\
                 status = <0x%.8x>\n" , status));
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MEM);
        }

/* generate the data lists */
        data = (char **) list->data_ptr;
/* find the size of string required */
	size = strlen(value) + 5 + (*out_list)->row_size + 2 * SIZE;
/* NO NEED AS ROW_SIZE CONTAINS THE TOTAL SIZE REQUIRED 


	format = (char **)(*out_list)-> format_ptr;
	for(i=0;i < (*out_list)->columns ; i++)
	{
		length = 0;
		if (! strncmp (format [i], "integer",  7)) length = 15;
          	else if (! strncmp (format [i], "smallint", 8)) length = 15;
          	else if (! strncmp (format [i], "double",   6)) length = 50;
          	else if (! strncmp (format [i], "real",     4)) length = 50;
          	else if (! strncmp (format [i], "char",     4))
                  	sscanf (format [i], "%5s%d", temp, &length);
		if(length <= 0)
		{
			_NFMdebug((fname,"Failed to get length of attribute <%d>\n",i));
                	status = ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","Format length 0");
                	if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
			
			return(NFM_E_FAILURE);
		}		
		size = size + length +2;
	}
	size = size + 2*SIZE;

END OF COMMENTED OUT
*/
	_NFMdebug((fname,"Malloc size <%d>\n",size));
	if((return_str = (char *)malloc(size)) == (char *)0)
	{
		_NFMdebug((fname,"Failed to malloc <%d> bytes for MEMwrite string\n",size));
                status = ERRload_struct(NFM,NFM_E_MALLOC,"%s","Add column Value 1");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_MALLOC);
	}


	for(i=0;i< list->rows ; i++ )
	{
		offset = i * list->columns ;
		strcpy(return_str,value);
		strcat(return_str,"\1");
		for(j=0;j < list->columns ; j++)
		{
			strcat(return_str,data[offset+j]);
			strcat(return_str,"\1");
		}
		if((status=MEMwrite(*out_list , return_str))!=MEM_S_SUCCESS)
		{	
                	_NFMdebug((fname,"MEMwrite failed for out_list\
       		          status = <0x%.8x> string=%s\n" , status,return_str));
			free(return_str);
			status=ERRload_struct(NFM,NFM_E_MEM,"");
	                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
       		        return(NFM_E_MEM);
		}

	}
	_NFMdebug((fname,"Exit >> SUCCESSFUL\n"));
	free(return_str);
	return(NFM_S_SUCCESS);
}
