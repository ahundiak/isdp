#include "machine.h"

/***************************************************************************
*				NFMsearch_across_catalogs		   *
*									   *
*	This function generates a list of items from all the catalogs in   *
*	the table NFMCATALOGS 						   *
***************************************************************************/
#include <stdio.h>
#include "MEMstruct.h"
#include "WFstruct.h"
#include "NFMerrordef.h"
#include "MEMerrordef.h"
#include "NFMsacdef.h"
#include "SACproto.h" /* Changed by kumar */
#include "NFMdef.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMapi.h"

#define NO_NFMSYSCAT   1
#define NFM_SAC_TYPE_USPEC      0
#define NFM_SAC_TYPE_DEFLT      1
#define FIRST_TIME              0


long NFMsearch_across_catalogs(user_id,cat_search_str,cat_sort_str,
			item_search_str, item_sort_str,
			in_attr_list,out_buffer_list,mis_attr_list)
	long user_id;
	MEMptr	*out_buffer_list,*mis_attr_list;
	MEMptr in_attr_list;
	char *cat_search_str, *cat_sort_str;
	char *item_search_str , *item_sort_str;
{
	long status = 0,type=0,i=0,flag=0,length=0;
	MEMptr attr_list=MEMNULL,cat_list=MEMNULL,out_list=MEMNULL;
	char temp[SIZE];
	char **format,**data,*fname="NFMsearch_across_catalog";
        char *item_search_ptr, *item_sort_ptr;
	long return_status= NFM_S_SUCCESS,failed_cats = 0;
	long item_search_flag,item_sort_flag;

	struct NFMquery_info item_query_info1,item_query_info2;

	_NFMdebug((fname,"Entry\t>>\n\t\tuser_id\t%d\n\t\tcat_search_str\
\t%s\n\t\tcat_sort_str\t%s\n\t\titem_search_str\t%s\n\t\titem_sort_str\
\t%s\n\t\tin_attr_list\t%d\n\t\tout_buffer_list\t%d\n",user_id
,cat_search_str,cat_sort_str,item_search_str,item_sort_str,in_attr_list,out_buffer_list));
	return_status= NFM_S_SUCCESS;
	flag = FIRST_TIME;
	item_search_flag=item_sort_flag=failed_cats = 0;
	item_search_ptr = item_sort_ptr = NULL ;
/* check if the list pointer is NULL */
	if(out_buffer_list == MEMPTRNULL)
	{
		_NFMdebug((fname,"Output buffer pointer Address is <%d>\n",out_buffer_list));
/*>>>>>>>>>>>>>>Error processor Error here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","output buffer pointer");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);

	}
/* make sure that the list is NULL  at entry point*/
	if(*out_buffer_list != MEMNULL)
	{
		_NFMdebug((fname,"<<<<WARNING>>>> Output buffer pointer  is <%d>(NOT NULL)\n",*out_buffer_list));
		_NFMdebug((fname,"<<<<WARNING>>>> MEMclose on Output buffer <%d>\n",*out_buffer_list));
/* set out_buffer_list to NULL */
		MEMclose(out_buffer_list);
	}
/* check if the list pointer is NULL */
	if(mis_attr_list == MEMPTRNULL)
	{
		_NFMdebug((fname,"Mismatch attribute list pointer Address is <%d>\n",mis_attr_list));
/*>>>>>>>>>>>>>>Error processor Error here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","mismatch buffer pointer");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* make sure that the list is NULL */
	if(*mis_attr_list != MEMNULL)
	{
		_NFMdebug((fname,"<<<<WARNING>>>>Mismatch attribute list pointer  is <%d>(NOT NULL)\n",*mis_attr_list));
		_NFMdebug((fname,"<<<<WARNING>>>> MEMclose on mis_attr_list <%d>\n",*mis_attr_list));
/* set out_buffer_list to NULL */
		MEMclose(mis_attr_list);
	}
/* set the type to NFM_SAC_TYPE_USPEC if in_attr_list is not NULL */
	if(in_attr_list != MEMNULL)
		type = NFM_SAC_TYPE_USPEC;
	else 	type = NFM_SAC_TYPE_DEFLT;

	if((status = NFMlist_pdm_cat_names(user_id , &cat_list , cat_search_str,cat_sort_str,NO_NFMSYSCAT))!=NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Cannot obtain list of catalogs status=<0x%.8x>\n", status));
/* Error processor error loaded by NFMlist_cat_names */
		return(status); /* CALLED FUNCTION WILL MEMclose cat_list IF RQD*/
	}
	if((status = NFMcom_attr_list(user_id , cat_list ,&attr_list))!=NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Cannot generate common attribute list=<0x%.8x>\n", status));
		MEMclose(&cat_list);
/* NFMcom_attr_list loads the error processor string */
		return(status); /* CALLED FUNCTION WILL MEMclose attr_list IF RQD*/
	}
        if(type==NFM_SAC_TYPE_USPEC && (status = NFMcmp_attr_list(in_attr_list
,attr_list,mis_attr_list))!=NFM_S_SUCCESS)

        {
/* NFMcmp_attr_list will load Error processor string */
        	_NFMdebug((fname,"<<<<WARNING>>>>Compare list failed <0x%.8x>\n",status));
                _NFMdebug((fname,"<<<<WARNING>>>>Using default attr_list\n"));
		if(status== NFM_E_BAD_ATTRIBUTE) return_status=status;
		else return(status);
		type = NFM_SAC_TYPE_DEFLT;
        }


        if((status=MEMbuild_array(cat_list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for cat_list\
		 status = <0x%.8x>\n" , status));
		MEMclose(&cat_list);
		MEMclose(&attr_list);
		status = ERRload_struct(NFM,NFM_E_MEM,"");
		if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MEM);
        }
/* generate the data lists */
        data = (char **) cat_list->data_ptr;
        format = (char **) cat_list->format_ptr;
/* get the length of n_catalogname */
	if (cat_list->columns > 0)
	{
        	if (! strncmp (format [0], "char",     4))
                  sscanf (format [0], "%5s%d", temp, &length);
	        if(length <= 0) length = NFM_ITEMNAME;
	}
	else length = NFM_ITEMNAME;

/* retrieve the item search and sort queries */
/* Get the search_string */

        if(strcmp(item_search_str,"")!=0)
        {
                item_search_flag++;
                status = _NFMretrieve_query(item_search_str,&item_query_info1);
                if(status!=NFM_S_SUCCESS)
                {
                        _NFMdebug((fname,"_NFMretrieve_query failed for query_name <%s>: status=<0x%.8x>\n",item_search_str,status));
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",item_search_str);
                        return(NFM_E_BAD_CRITERIA);
                }
		item_search_ptr=item_query_info1.where_clause;
        }

/* Get the sort_string */
        if(strcmp(item_sort_str,"")!=0)
        {
                item_sort_flag++;
                status = _NFMretrieve_query(item_sort_str,&item_query_info2);
                if(status!=NFM_S_SUCCESS)
                {
                        _NFMdebug((fname,"_NFMretrieve_query failed for query_name <%s>: status=<0x%.8x>\n",item_sort_str,status));
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",item_sort_str);
                        if(item_search_flag)  NFMfree_query_struct(&item_query_info1);
                        return(NFM_E_BAD_CRITERIA);
                }
		item_sort_ptr=item_query_info2.order_by_clause;
        }




        for ( i=0 ; i <cat_list->rows*cat_list->columns; i+=2)
        {
               /* Changed by kumar */

                if(type==NFM_SAC_TYPE_USPEC)
                status = NFMgen_list(user_id,in_attr_list,&out_list,data[i],
data[i+1],item_search_ptr,item_sort_ptr);
                else
		status = NFMgen_list(user_id,attr_list,&out_list,data[i], 
data[i+1],item_search_ptr,item_sort_ptr);
		if(status==NFM_S_SUCCESS)
		{
			if(flag!=FIRST_TIME) 
			status=NFMadd_col_val(user_id,out_list ,out_buffer_list,data[i]);
			else
			{
			 	status =NFMadd_col(user_id,out_list,"char",length,out_buffer_list,"n_catalogname" );
				if(status!=NFM_S_SUCCESS)
				{
					_NFMdebug((fname,"Add column failed status=\
<0x%.8x> for catalog %s\n",status,data[i]));
					MEMclose(out_buffer_list);
				}
				else
				{
			 		status = NFMadd_col_val(user_id,out_list,out_buffer_list,data[i]);
					if(status!=NFM_S_SUCCESS)
						_NFMdebug((fname,"Failed to add value\
for catalog %s status=<0x%.8x>\n",data[i],status));
				}
				if(status==NFM_S_SUCCESS)
					flag++;
				else if(return_status!= NFM_S_SUCCESS)
				{
					_NFMdebug((fname,"ERROR Previous status = <0x%.8x>\n",return_status));
					_NFMdebug((fname,"ERROR New status = <0x%.8x>\n",status));
					failed_cats++;
					return_status = status ;
				}
				else 
				{
					_NFMdebug((fname,"ERROR New status = <0x%.8x>\n",status));
					failed_cats++;
					return_status=status ;	
				}
			}
/* ERRLOAD done by add_col functions 
			if(status!=NFM_S_SUCCESS )
			{
				if(return_status != NFM_S_SUCCESS)
				{
					_NFMdebug((fname,"ERROR Previous status = <0x%.8x>\n",return_status));
					_NFMdebug((fname,"ERROR New status = <0x%.8x>\n",status));
					
					return_status = status ;
				}
				else
				{
					_NFMdebug((fname,"ERROR New status = <0x%.8x>\n",status));
					 return_status=status ;	
				}
				failed_cats++;
				status=ERRload_struct(NFM,NFM_E_MEM,"");
				if(status!=ERR_S_SUCCESS)
				{
                        	_NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
				}
			}
*/
		}
		else if ( status == NFM_E_NO_ITEMS_FOUND_IN_CAT)
		{
			_NFMdebug((fname,"No items in catalog %s\n",data[i]));
			failed_cats++;
		}
		else
/* NFMgen_list will load context specific information */
		{
			failed_cats++;
			_NFMdebug((fname,"List Item failed for catalog %s status=<0x%.8x>\n",data[i],status));
			if(return_status != NFM_S_SUCCESS)
			{
				_NFMdebug((fname,"ERROR Previous status = <0x%.8x>\n",return_status));
				_NFMdebug((fname,"ERROR New status = <0x%.8x>\n",status));
				return_status = status ;
			}
			else
			{
				_NFMdebug((fname,"ERROR New status = <0x%.8x>\n",status));
				 return_status=status ;	
			}
		}
/* Reset the memory pointers after closing the memory */
		MEMclose(&out_list);
		out_list = MEMNULL;
	}
/* Free the query structure if required */
        if(item_search_flag)  NFMfree_query_struct(&item_query_info1);
        if(item_sort_flag) NFMfree_query_struct(&item_query_info2);

	if(failed_cats > 0 && failed_cats == cat_list->rows )
	{
		_NFMdebug((fname,"ERROR Previous status = <0x%.8x>\n",return_status));
		_NFMdebug((fname,"Search across catalogs failed for all the catalogs\n"));
		ERRload_struct(NFM,NFM_E_FAILURE,"%s%s","Search_across_catalog","All Catalogs");
	 	return_status=NFM_E_FAILURE;
	}
	MEMclose(&out_list);
	MEMclose(&attr_list);
	MEMclose(&cat_list);
	_NFMdebug((fname,"Exit >> failed catalogs = <%d> status <0x%.8x>\n",failed_cats,return_status));
	return(return_status);
}
