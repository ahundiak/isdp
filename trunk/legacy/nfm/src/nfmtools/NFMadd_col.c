#include "machine.h"
#include "DEBUG.h"


/****************************************************************************
*									*
*			NFMadd_col					*
*									*
*	This function adds a column to a memory structure and returns   *
*	a pointer to a new list which contains the new format		*
*									*
*<<>>	Column name has a size limitataion of SIZE
*<<>>	Default data size for char is 1
*<<>>	Data size field ignored for other data type
************************************************************************/

#include <stdio.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "NFMsacdef.h"
#include "ERR.h"


NFMadd_col(user_id,list,new_format,data_size,out_list,column_name)
	long user_id;
	MEMptr list,*out_list;
	char *new_format,*column_name;
	long data_size;
{
 long status,size;
 char *fname="NFMadd_col";
 char return_str[SIZE],name[SIZE];
 long i =0;
 char **data,**format,**column;
	_NFMdebug((fname,"Entry >>user_id  %d list  %d format %s\n\
Data size %d Out list address %d\n",user_id,list,
new_format,data_size,out_list));

/*	Check if user id is NULL */
	if(user_id <= 0)
	{
		_NFMdebug((fname,"Bad user_id <%d>\n",user_id));
                status = ERRload_struct(NFM,NFM_E_BAD_USER_ID,"%d",user_id);
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_BAD_USER_ID);
	}
/* check if the pointer to the list is NULL */
	if(list == MEMNULL)
	{
		_NFMdebug((fname,"Input MEMlist is NULL <%d>\n",list));
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","input_list");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);

	}
/* check if the pointer to the MEMptr is NULL */
	if(out_list == MEMPTRNULL)
	{
		_NFMdebug((fname,"Output list pointer address is <%d>\n",out_list));
/*	Error processor string here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","output buffer ptr NULL");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* check if output list is empty */
	if(*out_list != MEMNULL)
	{
		_NFMdebug((fname,"<<<<WARNING>>>>Output list is <%d>(NON NULL)\n",*out_list));
		_NFMdebug((fname,"<<<<WARNING>>>>MEMclose on Output list <%d>\n",*out_list));
		MEMclose(out_list);
	}
/* check if format is null string */
	if(strlen(new_format) <=0 )
	{
		_NFMdebug((fname,"No format specified  new_format=<%s>\n",new_format));
/*	Error processor string here */
                status = ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","Format string");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_VALUE);

	}
	if((strlen(column_name))> SIZE -1) column_name[SIZE-1] = '\0';
	if(data_size <= 0 ) data_size = 1;
	if((strlen(column_name)) <= 0) strcpy(name, "n_newcolumn");
	else	strcpy(name,column_name);
	

/*	build the array of list */
        if((status=MEMbuild_array(list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for  input list\
                 status = <0x%.8x>\n" , status));
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MEM);
        }

/* generate the data lists */
        data = (char **) list->data_ptr;
	column =( char **) list->column_ptr;
	format = (char **) list->format_ptr;
		
/* Open a memory structure */
        if((status=MEMopen(out_list,4*MEM_SIZE)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMopen failed for out_list\
                 status = <0x%.8x>\n" , status));
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MEM);
        }
/* generate the format for new column */
        if (! strncmp (new_format, "char",     4))
		sprintf(return_str,"char(%d)",data_size);
	else strcpy(return_str,new_format);
	if((status=MEMwrite_format(*out_list , name, return_str))!=MEM_S_SUCCESS)
	{	
               	_NFMdebug((fname,"MEMwrite_format failed for out_list name <%s>\
       	          status = <0x%.8x>\n" ,name, status));
		MEMclose(out_list);
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MEM);
	}
	

/* write the format */
	for(i=0 ; i < list-> columns; i++)
	{
		if((status=MEMwrite_format(*out_list , column[i] , format[i]))!=MEM_S_SUCCESS)
		{	
                	_NFMdebug((fname,"MEMwrite_format failed for out_list\
column <%s>          status = <0x%.8x>\n" , status));
			MEMclose(out_list);
			status=ERRload_struct(NFM,NFM_E_MEM,"");
	                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
       		        return(NFM_E_MEM);
		}
        }
	_NFMdebug((fname,"Exit >> SUCCESSFUL\n"));
	return(NFM_S_SUCCESS);
}
