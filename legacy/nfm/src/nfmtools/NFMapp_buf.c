#include "machine.h"

/************************************************************************
*									*
*			NFMapp_buf					*
*									*
*									*
************************************************************************/

#include "NFMnfmsacinc.h"

NFMappend_buffer(list,out_list)
	MEMptr list,*out_list;
{
 long status,size,offset,length;
 char *fname="NFMappend_buffer";
 char **data,**format,**column;
 char *return_str,temp[NFM_FILENAME];
 long i=0,j=0;

	_NFMdebug((fname,"Entry : list <%x>:out_list <%x>\n",list,out_list));

/* check if the pointer to the list is NULL */
	if(list == (MEMptr)0)
	{
		_NFMdebug((fname,"Input list is NULL <%d>\n",list));
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","input_list");
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* check if the pointer to the MEMptr is NULL */
	if(out_list == (MEMptr *)0)
	{
		_NFMdebug((fname,"Output list pointer address is <%d>NULL\n",out_list));
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Output Buffer ptr");
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}

/*	build the array of list */
        if((status=MEMbuild_array(list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for  list\
                 status = <0x%.8x>\n" , status));
		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array",fname,"status",status);
                return(NFM_E_MEM_ERR);
        }

/* generate the data lists */
        data = (char **) list->data_ptr;
/* find the size of string required */
	format = (char **)(list)-> format_ptr;
	column = (char **)(list)-> column_ptr;

	if(*out_list == (MEMptr)0)
	{
/* Open a memory structure */
        	if((status=MEMopen(out_list,4*MEM_SIZE)) != MEM_S_SUCCESS )
        	{
                	_NFMdebug((fname,"MEMopen failed for out_list\
                 	status = <0x%.8x>\n" , status));
                	ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMopen",fname,"status",status);
                	return(NFM_E_MEM_ERR);
        	}
/* write the format */
	        for(i=0 ; i < list-> columns; i++)
       		{
                	if((status=MEMwrite_format(*out_list , column[i] , format[i]))!= MEM_S_SUCCESS)
                	{
                        	_NFMdebug((fname,"MEMwrite_format failed for \
out_list status = <0x%.8x>\n" , status));
                        	MEMclose(out_list);
                		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMwrite_format",fname,"status",status);
                		return(NFM_E_MEM_ERR);
                	}
        	}
	}
	size =  5;
	for(i=0;i < (list)->columns ; i++)
	{
		length = 0;
		if (! strncmp (format [i], "integer",  7)) length = 15;
          	else if (! strncmp (format [i], "smallint", 8)) length = 15;
          	else if (! strncmp (format [i], "double",   6)) length = 50;
          	else if (! strncmp (format [i], "real",     4)) length = 50;
          	else if (! strncmp (format [i], "timestamp",9)) length = 20;
          	else if (! strncmp (format [i], "char",     4))
                  	sscanf (format [i], "%5s%d", temp, &length);
		if(length <= 0)
		{
			_NFMdebug((fname,"Failed to get length of attribute <%d>\n",i));
                	ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","Format length 0");
			return(NFM_E_NULL_VALUE);
		}		
		size = size + length +2;
	}
	size = size + 200;
	if((return_str = (char *)malloc(size)) == (char *)0)
	{
		_NFMdebug((fname,"Failed to malloc <%d> bytes for MEMwrite string\n",size));
                ERRload_struct(NFM,NFM_E_MALLOC,"%s","Add column Value 1");
		return(NFM_E_MALLOC);
	}


	for(i=0;i< list->rows ; i++ )
	{
		offset = i * list->columns ;
		strcpy(return_str,"");
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
                	ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMwrite",fname,"status",status);
                	return(NFM_E_MEM_ERR);
		}

	}
	free(return_str);
	_NFMdebug((fname,"Exit >> SUCCESSFUL <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}
