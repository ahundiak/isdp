#include "machine.h"

/***************************************************************************
*			NFMmultiple_catalog_search			   *
*									   *
*	This function generates a list of items from  the catalogs in      *
*	the list. The list should contain atleast one catalog		   *
*									   *
*	A list of all the common attributes with read flag set to 'Y' is   *
*	generated. 	
***************************************************************************/
#include "NFMnfmsacinc.h"
#include "NFMapi.h"


long NFMmultiple_catalog_search(cat_list,
			search_name, sort_name,
			buffer_list,synonym_list)
	MEMptr	cat_list,*buffer_list,*synonym_list;
	char *search_name , *sort_name;
{
	long status,count,no_of_catalogs,i,return_status;
	int rows,columns,failed_cats;
	char *fname="NFMsearch_across_catalog";
	char src_catalog[NFM_FILENAME];
	char **data;
	MEMptr new_cat_list,attr_list,out_list;
	struct NFMquery_info query_info1,query_info2 ;
	char  *search_ptr, *sort_ptr ;
	long search_flag, sort_flag,query_flag;
	

	_NFMdebug((fname,"Entry:MEMptr cat_list <%x>:Search Criteria <%s>\n\
Sort Criteria <%s>: MEMptr *buffer_list <%x>: MEMptr *synonym_list <%x>\n",
cat_list,search_name,sort_name,*buffer_list,*synonym_list));	
	return_status = NFM_S_SUCCESS ;
	failed_cats = 0;
	new_cat_list = attr_list = out_list = NULL ;
	search_flag = sort_flag =  0;
	query_flag = 0;
	search_ptr = sort_ptr = NULL ;
/* check if the pointer to the Catalog list is NULL */
        if(cat_list == (MEMptr)0)
        {
                _NFMdebug((fname,"Catalog list address is <%x> NULL\n",cat_list)) ;
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","catalog list");
                return(NFM_E_NULL_OUTPUT_MEMPTR);
        }

/* check if the list pointer is NULL */
	
	if(buffer_list == (MEMptr *)0)
	{
		_NFMdebug((fname,"Output buffer pointer Address is <%x>\n",buffer_list));
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","buffer_list pointer");
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* make sure that the list is NULL  at entry point*/
	if(*buffer_list != (MEMptr)0)
	{
		_NFMdebug((fname,"<<<<WARNING>>>> Output buffer pointer  is\
 <%x>(NOT NULL)\n<<<<WARNING>>>> *buffer_ptr set to NULL\n",*buffer_list));
/* set out_buffer_list to NULL */
		MEMclose(buffer_list);
	}
/* check if the list pointer is NULL */
	
	if(synonym_list == (MEMptr *)0)
	{
		_NFMdebug((fname,"Synonym buffer pointer Address is <%x>\n",synonym_list));
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Synonym_list pointer");
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* make sure that the list is NULL  at entry point*/
	if(*synonym_list != (MEMptr)0)
	{
		_NFMdebug((fname,"<<<<WARNING>>>> Synonym buffer pointer  is\
 <%x>(NOT NULL)\n<<<<WARNING>>>> *synonym_list set to NULL\n",*synonym_list));
/* set out_buffer_list to NULL */
		MEMclose(synonym_list);
	}
/* MEMbuild the catalog list */
        if((status=MEMbuild_array(cat_list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for cat_list\
		 status = <0x%.8x>\n" , status));
		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array for catalog list",fname,"Status",status);
                return(NFM_E_MEM_ERR);
        }

/* generate the data lists */
        data = (char **) cat_list->data_ptr;
        no_of_catalogs = cat_list->rows;
/* check if there are any catalogs in catalog list
   There must be atleast one catalog */
        if(no_of_catalogs < 1)
        {
                _NFMdebug((fname,"Number of catalogs  %d < 1\n",no_of_catalogs));
                ERRload_struct(NFM,NFM_E_NO_CATALOGS,"%s","Empty list");
                return(NFM_E_NO_CATALOGS);
        }
/* Load and save the source catalog */
	strncpy(src_catalog,data[0],NFM_FILENAME);
	src_catalog[NFM_FILENAME-1] = '\0';

/* Get catalog number for all the catalogs */

	status = NFMget_cat_list(cat_list,&new_cat_list);
	if(status != NFM_S_SUCCESS)
	{
		MEMclose(&new_cat_list);
		_NFMdebug((fname,"Failed to generate catalog number for all\
catalogs in cat_list:status <0x%.8x>\n",status));
		return(status);
	}
/* MEMbuild the catalog list */
        if((status=MEMbuild_array(new_cat_list)) != MEM_S_SUCCESS )
        {
		MEMclose(&new_cat_list);
                _NFMdebug((fname,"MEMbuild_array failed for new_cat_list\
		 status = <0x%.8x>\n" , status));
		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array for New Catalog List",fname,"Status",status);
                return(NFM_E_MEM_ERR);
        }

/* generate the data lists */
        data = (char **) (new_cat_list)->data_ptr;
	rows = (new_cat_list) -> rows;
	columns = (new_cat_list) -> columns;

/* Generate list of common attributes */
	status = NFMsac_attr_list(new_cat_list,src_catalog,&attr_list,synonym_list,"Catalog Name");
	if(status != NFM_S_SUCCESS)
	{
		MEMclose(&new_cat_list);
		MEMclose(&attr_list);
		MEMclose(synonym_list);
		_NFMdebug((fname,"Failed to generate attribute list and synonym\
 list : status <0x%.8x>\n",status));
		return(status);
	}

/* Get the search_string */

	if((search_name != NULL) && (strcmp(search_name,"")!=0))
	{
		search_flag++;
		status = _NFMretrieve_query(search_name,&query_info1);
		if(status!=NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"_NFMretrieve_query failed for query_name <%s>: status=<0x%.8x>\n",search_name,status));
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",search_name);
                        return(NFM_E_BAD_CRITERIA);
		}
		search_ptr=query_info1.where_clause;
		status = _NFMcat_f_cat(query_info1.from_clause,&query_flag);
		if(status != NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"Cannot figure out the type for query from clause\n"));
		}
		status = _NFMf_cat(query_info1.where_clause,&query_flag);
		if(status != NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"Cannot figure out the type for query where clause\n"));
		}
	}

/* Get the sort_string */
	if((sort_name != NULL) && (strcmp(sort_name,"")!=0))
	{
		sort_flag++;
		status = _NFMretrieve_query(sort_name,&query_info2);
		if(status!=NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"_NFMretrieve_query failed for query_name <%s>: status=<0x%.8x>\n",sort_name,status));
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",sort_name);
	        	if(search_flag)  NFMfree_query_struct(&query_info1);
                        return(NFM_E_BAD_CRITERIA);
		}
		sort_ptr = query_info2.order_by_clause ;
	}




        for ( i=0 ; i <rows; i++)
        {
		count = columns * i;
		status = NFMsac_list(attr_list,&out_list,data[count], 
data[count+1],search_ptr,sort_ptr,query_flag);

		if(status==NFM_S_SUCCESS)
		{
			status=NFMappend_buffer(out_list ,buffer_list);
			if(status!=NFM_S_SUCCESS)
			{
				_NFMdebug((fname,"Failed to append buffer\
for catalog %s status=<0x%.8x>\n",data[i],status));
				failed_cats++;
				return_status = status ;
			}
		}
		else if ( status == NFM_E_NO_ITEMS_FOUND_IN_CAT)
		{
			_NFMdebug((fname,"No items in catalog %s\n",data[i]));
			if(return_status == NFM_S_SUCCESS) return_status = status ;
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
		out_list = (MEMptr)0;
	}
/* Close the query structure */
	if(search_flag)  NFMfree_query_struct(&query_info1);
        if(sort_flag) NFMfree_query_struct(&query_info2);
	if(failed_cats > 0 && failed_cats == rows )
	{
		_NFMdebug((fname,"ERROR Previous status = <0x%.8x>\n",return_status));
		_NFMdebug((fname,"Search across catalogs failed for all the catalogs\n"));
		ERRload_struct(NFM,NFM_E_SAC_ALL_CATALOGS,"%d%d%x",rows,failed_cats,return_status);
	 	return_status=NFM_E_SAC_ALL_CATALOGS;
		MEMclose(&out_list);
		MEMclose(&attr_list);
		MEMclose(&new_cat_list);
		_NFMdebug((fname,"Exit >>Total catalogs <%d> failed catalogs = <%d> status <0x%.8x>\n",rows,failed_cats,return_status));
		return(return_status);
	}
	if (failed_cats > 0)
		ERRload_struct(NFM,NFM_I_SAC_SOME_CATALOGS,"%d%x",failed_cats,return_status);

	MEMclose(&out_list);
	MEMclose(&attr_list);
	MEMclose(&new_cat_list);
	_NFMdebug((fname,"Exit >>Total catalogs <%d> failed catalogs = <%d> status <0x%.8x>\n",rows,failed_cats,NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}
