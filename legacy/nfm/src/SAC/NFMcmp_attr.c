#include "machine.h"
/************************************************************************
*				NFMcmp_attr				*
*									*
*	This function compares two lists. All the values in the first   *
*	list must exist in the second list. An error is returned	*
*	if a mismatch occurs						*
*	All the mismatched attributes are returned in mis_attr_list	*
************************************************************************/	
#include <stdio.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "NFMerrordef.h"
#include "NFMsacdef.h"
#include "DEBUG.h"
#include "ERR.h"



long NFMcmp_attr_list(list1 , list2 , mis_attr_list)
	MEMptr list1 , list2 ,*mis_attr_list;

{
	long status , i , j,found = 0;
	long flag = 0;
	char *fname="NFMcmp_attr_list";
	char **data1 , **data2,**format1;
	char mismatch_attr[SIZE];
	_NFMdebug((fname,"Entry >>\n\t\tin Attr List\t%d\n\t\tFull attr list\t%d\
\n\t\tmismatch attribute pointer %d\n",list1,list2,mis_attr_list));
	found = 0;
/* check if the MEMptrs are not NULL */
	if((list1== MEMNULL) || (list2==MEMNULL ))
	{
		_NFMdebug((fname,"Null attr list list1 <%d> list2 <%d>\n",list1,list2));
/*	error processor here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","NFMcmp_attr");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}


/*  Build the arrays with list1 and list2 */	
 	if((status=MEMbuild_array(list1)) !=MEM_S_SUCCESS)
        {
		_NFMdebug((fname,"MEMbuild array failed for list1 status<0x%.8x>\n",status));
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_MEM);
        }
 	if((status=MEMbuild_array(list2)) != MEM_S_SUCCESS)
        {
		_NFMdebug((fname,"MEMbuild array failed for list2 status<0x%.8x>\n",status));
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_MEM);
        }
    
/* generate the data lists */
	data1 = (char **) list1->data_ptr;
	data2 = (char **) list2->data_ptr;
	format1 = (char **) list1->format_ptr;

/* Create the mis_match attr list and generate the format */

/* Open a memory structure */
        if((status=MEMopen(mis_attr_list,4*MEM_SIZE)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMopen failed for mis_attr_list\
                 status = <0x%.8x>\n" , status));
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_MEM);
        }
/* generate the format for new column */
        if((status=MEMwrite_format(*mis_attr_list , "n_mismatch_attr", format1[0]))!=MEM_S_SUCCESS)
        {
                _NFMdebug((fname,"MEMwrite_format failed for mis_attr_list\
                  status = <0x%.8x>\n" , status));
                MEMclose(mis_attr_list);
		status=ERRload_struct(NFM,NFM_E_MEM,"");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_MEM);
        }
        for ( i=0 ; i <list1->rows; i++)
	{
		flag = 0;
/* Only the names are compared */
		for (j=0 ; j < (list2->rows) && !flag ; j++)
		{
			if((strcmp(data1[i], data2[j]))==0) flag =1;	
		}
		if(!flag)
		{
			if(strlen(data1[i]) > SIZE -2)
			{
				strncpy(mismatch_attr,data1[i],SIZE - 3);
				mismatch_attr[SIZE-3] = '\0';
			}
			else 
				strcpy(mismatch_attr , data1[i]);
			strcat(mismatch_attr,"\1");
			if((status=MEMwrite(*mis_attr_list,mismatch_attr))!=MEM_S_SUCCESS)
			{
				_NFMdebug((fname,"MEMwrite failed to write mismatch attr %s\n",mismatch_attr));
			}
			found++;
		}
	}
	if(found == 0) MEMclose(mis_attr_list);
	else return(NFM_E_BAD_ATTRIBUTE);
	_NFMdebug((fname,"Exit >  SUCCESSFUL\n"));
	return(NFM_S_SUCCESS);
}
