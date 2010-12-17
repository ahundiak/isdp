#include "machine.h"

/***************************************************************************
*			NFMblock_multiple_catalog_search       		   *
*									   *
*	This function performs item listing across multiple catalogs	   *
*	The list will contain all the items from the list of catalogs      *
*	that satisfy the search criteria. 				   *
*	This function supports BLOCK listing. If the list of items consist *
*	more entries than the block size, a partial list is maintained.    *
*	The calling function controls, start, stop, regenration, and       *
*	cleanup activities						   *
*									   *
*	A list of all the common attributes with read flag set to 'Y' is   *
*	generated. 							   *
***************************************************************************/
#include "NFMnfmsacinc.h"
#include "NFMapi.h"

#define  BLOCK_START 	0
#define  BLOCK_NEXT	1
#define  BLOCK_CLEANUP	2
#define  N_COLUMN_NAME	0
#define  N_DATATYPE	1

struct NFMbmcs_globals {
			char *search_ptr;
			char *sort_ptr;
	                struct NFMquery_info query_info1  ,query_info2 ;
	                MEMptr new_cat_list  ,attr_list  ;
	                MEMptr template_buffer ;
			long cur_cat_pos ,action_flag;
	                long search_flag  , sort_flag  ,query_flag;
			long cursor_open ;
                       } NFMbmcs_globals ;
			


long NFMblock_multiple_catalog_search(cat_list,
			search_name, sort_name,
			buffer_list,synonym_list,
			row_size)
	MEMptr	cat_list,*buffer_list,*synonym_list;
	char *search_name , *sort_name;
	long row_size;
{
	char *fname="NFMblock_multiple_catalog_search";
	long status,status2,count,i,return_status,j,done_flag,row_count;
	static long flag = 0;
	int rows,columns,failed_cats,no_of_catalogs;
	char src_catalog[NFM_FILENAME],tmp_str[NFM_FILENAME],tmp_str2[NFM_FILENAME];
	char **data,**data2,**format;
	

	_NFMdebug((fname,"Entry:MEMptr cat_list <%x>:Search Criteria <%s>\n\
Sort Criteria <%s>: MEMptr *buffer_list <%x>: MEMptr *synonym_list <%x>\n\
Row Size: <%d>\n", cat_list,search_name,sort_name,*buffer_list,*synonym_list,row_size));	


/* Initialize variables the first time a block query is done */

	if(!flag)
	{
		flag++;
		NFMbmcs_globals.cursor_open = 0;
		NFMbmcs_globals.search_flag = 0;
		NFMbmcs_globals.sort_flag = 0;
		NFMbmcs_globals_cleanup();
	}

/* If row size is 0 a CLEANUP IS REQUESTED */

	if(row_size == 0 )
	{

/* IF action_flag is set to BLOCK_START global variables are already
   initialized */
		if(NFMbmcs_globals.action_flag == BLOCK_START)
		{
			_NFMdebug((fname,"Buffers already initialized:\
	SUCCESSFUL: <0x%.8x>\n",NFM_S_SUCCESS));
			return(NFM_S_SUCCESS);
		}
		 NFMbmcs_globals.action_flag = BLOCK_CLEANUP ;
	}

	return_status = NFM_S_SUCCESS ;
	failed_cats = 0;
/* Row count keeps track of how many more rows are required to complete
   the request */
        row_count = row_size ;


	switch(NFMbmcs_globals.action_flag)
	{
/* START A NEW QUERY */

		case BLOCK_START:
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
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Output buffr pointer");
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

	status = NFMget_cat_list(cat_list,&NFMbmcs_globals.new_cat_list);
	if(status != NFM_S_SUCCESS)
	{
		MEMclose(&NFMbmcs_globals.new_cat_list);
		_NFMdebug((fname,"Failed to generate catalog number for all\
catalogs in cat_list:status <0x%.8x>\n",status));
		return(status);
	}
/* Generate list of common attributes */
	status = NFMblocksac_attr_list(NFMbmcs_globals.new_cat_list,src_catalog,&NFMbmcs_globals.attr_list,synonym_list,"Catalog Name");
	if(status != NFM_S_SUCCESS)
	{
		MEMclose(&NFMbmcs_globals.new_cat_list);
		MEMclose(&NFMbmcs_globals.attr_list);
		MEMclose(synonym_list);
		_NFMdebug((fname,"Failed to generate attribute list and synonym\
 list : status <0x%.8x>\n",status));
		return(status);
	}
/* Get the search_string */

	if((search_name != NULL) && (strcmp(search_name,"")!=0))
	{
		NFMbmcs_globals.search_flag++;
		status = _NFMretrieve_query(search_name,&NFMbmcs_globals.query_info1);
		if(status!=NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"_NFMretrieve_query failed for query_name <%s>: status=<0x%.8x>\n",search_name,status));
			MEMclose(&NFMbmcs_globals.new_cat_list);
			MEMclose(&NFMbmcs_globals.attr_list);
			MEMclose(synonym_list);
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",search_name);
                        return(NFM_E_BAD_CRITERIA);
		}
		NFMbmcs_globals.search_ptr=NFMbmcs_globals.query_info1.where_clause;
		status = _NFMcat_f_cat(NFMbmcs_globals.query_info1.from_clause,&NFMbmcs_globals.query_flag);
		if(status != NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"Cannot figure out the type for query from clause\n"));
		}
		status = _NFMf_cat(NFMbmcs_globals.query_info1.where_clause,&NFMbmcs_globals.query_flag);
		if(status != NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"Cannot figure out the type for query where clause\n"));
		}
	}

/* Get the sort_string */
	if((sort_name != NULL) && (strcmp(sort_name,"")!=0))
	{
		NFMbmcs_globals.sort_flag++;
		status = _NFMretrieve_query(sort_name,&NFMbmcs_globals.query_info2);
		if(status!=NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"_NFMretrieve_query failed for query_name <%s>: status=<0x%.8x>\n",sort_name,status));
			MEMclose(&NFMbmcs_globals.new_cat_list);
			MEMclose(&NFMbmcs_globals.attr_list);
			MEMclose(synonym_list);
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",sort_name);
	        	if(NFMbmcs_globals.search_flag)  NFMfree_query_struct(&NFMbmcs_globals.query_info1);
                        return(NFM_E_BAD_CRITERIA);
		}
		NFMbmcs_globals.sort_ptr = NFMbmcs_globals.query_info2.order_by_clause ;
	}
/* Generate the template buffer */
		

/* Open a memory structure */
        if((status=MEMopen(&NFMbmcs_globals.template_buffer,MEM_SIZE)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMopen failed for template buffer\
                 status = <0x%.8x>\n" , status));
        	MEMclose(&NFMbmcs_globals.new_cat_list);
		MEMclose(&NFMbmcs_globals.attr_list);
		MEMclose(&NFMbmcs_globals.template_buffer);
		MEMclose(synonym_list);
                ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMopen for template_buffer", fname,"status",status);
                return(NFM_E_MEM_ERR);
        }
        sprintf(tmp_str,"char(%d)",NFM_CATALOGNAME);
	_NFMdebug((fname,"column: <%s> : datatype: <%s>\n","n_catalogname",tmp_str));
        if((status=MEMwrite_format(NFMbmcs_globals.template_buffer , "n_catalogname", tmp_str))!=MEM_S_SUCCESS)
        {
                _NFMdebug((fname,"MEMwrite_format failed for template_buffer\
                  status = <0x%.8x>\n" , status));
        	MEMclose(&NFMbmcs_globals.new_cat_list);
		MEMclose(&NFMbmcs_globals.attr_list);
		MEMclose(&NFMbmcs_globals.template_buffer);
		MEMclose(synonym_list);
                ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMwrite_format for template_buffer",fname,"status",status);
                return(NFM_E_MEM_ERR);
        }

        if((status=MEMbuild_array(NFMbmcs_globals.attr_list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for attribute list\
                 status = <0x%.8x>\n" , status));
        	MEMclose(&NFMbmcs_globals.new_cat_list);
		MEMclose(&NFMbmcs_globals.attr_list);
		MEMclose(&NFMbmcs_globals.template_buffer);
		MEMclose(synonym_list);
                ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array",fname,"Status",status);
                return(NFM_E_MEM_ERR);
        }
        data2 = (char **) NFMbmcs_globals.attr_list->data_ptr;

        for(j=0; j < NFMbmcs_globals.attr_list->rows ; j++ )
        {
          	count= NFMbmcs_globals.attr_list->columns * j ;


		_NFMdebug((fname,"column: <%s> : datatype: <%s>\n",data2[count+N_COLUMN_NAME],data2[count+N_DATATYPE]));
                /*  This is because Glenn made me do this under duress  */

                if ((strcmp (data2[count], "n_aclno")) == 0)
		{
                        strcpy (tmp_str2, "n_aclname");
                        sprintf (tmp_str, "char(%d)",NFM_ACLNAME);
        	    	status=MEMwrite_format(NFMbmcs_globals.template_buffer , tmp_str2,tmp_str) ;
		}
                else if ((strcmp (data2[count], "n_stateno")) == 0)
		{
                        strcpy (tmp_str2, "n_statename");
                        sprintf (tmp_str, "char(%d)",NFM_STATENAME);
        	    	status=MEMwrite_format(NFMbmcs_globals.template_buffer , tmp_str2,tmp_str) ;
		}
		else
        	    status=MEMwrite_format(NFMbmcs_globals.template_buffer , data2[count+N_COLUMN_NAME], data2[count+N_DATATYPE]) ;

        	if(status!=MEM_S_SUCCESS)
        	{
                	_NFMdebug((fname,"MEMwrite_format failed for  template_buffer\
                  	status = <0x%.8x>\n" , status));
        		MEMclose(&NFMbmcs_globals.new_cat_list);
			MEMclose(&NFMbmcs_globals.attr_list);
			MEMclose(&NFMbmcs_globals.template_buffer);
			MEMclose(synonym_list);
                	ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMwrite_format for template_buffer",fname,"status",status);
                	return(NFM_E_MEM_ERR);
        	}
        }
        if((status= MEMsplit_copy_buffer (NFMbmcs_globals.template_buffer,buffer_list,0))!= MEM_S_SUCCESS)
        {
               	_NFMdebug((fname,"MEMwrite_format failed for  template_buffer\
               	status = <0x%.8x>\n" , status));
        	MEMclose(&NFMbmcs_globals.new_cat_list);
		MEMclose(&NFMbmcs_globals.attr_list);
		MEMclose(&NFMbmcs_globals.template_buffer);
		MEMclose(synonym_list);
		MEMclose(buffer_list);
               	ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMwrite_format for template_buffer",fname,"status",status);
               	return(NFM_E_MEM_ERR);
         }
             

		NFMbmcs_globals.action_flag = BLOCK_NEXT ;



				break;
		case BLOCK_NEXT:

        if((status= MEMsplit_copy_buffer (NFMbmcs_globals.template_buffer,buffer_list,0))!= MEM_S_SUCCESS)
        {
               	_NFMdebug((fname,"MEMsplit_copy_buffer failed for  template_buffer\
               	status = <0x%.8x>\n" , status));
		MEMclose(buffer_list);
		NFMbmcs_globals_cleanup();
               	ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMsplit_copy_buffer for template_buffer",fname,"status",status);
               	return(NFM_E_MEM_ERR);
         }
				break;
		case BLOCK_CLEANUP:
		default:
			NFMbmcs_globals_cleanup();
			_NFMdebug((fname,"Returning after cleanup status <0x%.8x>\n",NFM_S_SUCCESS));
			return(NFM_S_SUCCESS);
	}


/* MEMbuild the catalog list */
        if((status=MEMbuild_array(NFMbmcs_globals.new_cat_list)) != MEM_S_SUCCESS )
        {
		NFMbmcs_globals_cleanup();
                _NFMdebug((fname,"MEMbuild_array failed for new_cat_list\
		 status = <0x%.8x>\n" , status));
		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array for New Catalog List",fname,"Status",status);
                return(NFM_E_MEM_ERR);
        }

/* generate the data lists */
        data = (char **) (NFMbmcs_globals.new_cat_list)->data_ptr;
	rows = (NFMbmcs_globals.new_cat_list) -> rows;
	columns = (NFMbmcs_globals.new_cat_list) -> columns;

       
	done_flag = 0;
        for ( i=NFMbmcs_globals.cur_cat_pos ; i <rows && !done_flag; i++)
        {

		count = columns * i;
		NFMbmcs_globals.cur_cat_pos = i;
        	if((status2=MEMbuild_array(*buffer_list)) != MEM_S_SUCCESS )
        	{
			NFMbmcs_globals_cleanup();
                	_NFMdebug((fname,"MEMbuild_array failed for new_cat_list\
		 	status = <0x%.8x>\n" , status2));
			ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array for New Catalog List",fname,"Status",status2);
                	return(NFM_E_MEM_ERR);
		}
		format = (char **) (*buffer_list) -> format_ptr;
/*
		sprintf(format[0],"char(%d)",strlen(data[count])+1);
*/
	        _NFMdebug((fname,"format <%s> : catalog <%s>\n",format[0],data[count]));

		status = NFMblocksac_list(NFMbmcs_globals.attr_list,buffer_list,data[count], 
data[count+1],NFMbmcs_globals.search_ptr,NFMbmcs_globals.sort_ptr,NFMbmcs_globals.query_flag,row_count);

			
		if ( (*buffer_list)->rows >= row_size )
			 done_flag++;
		row_count = row_size - (*buffer_list)->rows;
		if(status==NFM_S_SUCCESS)
		{
			NFMbmcs_globals.cursor_open = 1;
		}
		else if ( status == NFM_E_NO_ITEMS_FOUND_IN_CAT)
		{
			NFMbmcs_globals.cursor_open = 0;
			_NFMdebug((fname,"No items in catalog %s\n",data[i]));
			if(return_status == NFM_S_SUCCESS) return_status = status ;
			failed_cats++;
		}
		else if ( status == NFM_I_NO_MORE_BUFFERS) 
		{
			NFMbmcs_globals.cursor_open = 0;
			continue;
		}
		else
/* NFMgen_list will load context specific information */
		{
			NFMbmcs_globals.cursor_open = 0;
			failed_cats++;
			_NFMdebug((fname,"List Item failed for catalog %s status=<0x%.8x>\n",data[count],status));
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
	}
	if (failed_cats > 0)
		ERRload_struct(NFM,NFM_I_SAC_SOME_CATALOGS,"%d%x",failed_cats,return_status);
/* Close the query structure */
	if(failed_cats > 0 && failed_cats == rows )
	{
		_NFMdebug((fname,"ERROR Previous status = <0x%.8x>\n",return_status));
		_NFMdebug((fname,"Search across catalogs failed for all the catalogs\n"));
		ERRload_struct(NFM,NFM_E_SAC_ALL_CATALOGS,"%d%d%x",rows,failed_cats,return_status);
	 	return_status=NFM_E_SAC_ALL_CATALOGS;
		NFMbmcs_globals_cleanup();
		_NFMdebug((fname,"Exit >>Total catalogs <%d> failed catalogs = <%d> status <0x%.8x>\n",rows,failed_cats,return_status));
		return(return_status);
	}

	if (NFMbmcs_globals.cur_cat_pos >= rows-1 && !done_flag  )
	{
		NFMbmcs_globals_cleanup();
		return(NFM_I_NO_MORE_BUFFERS);
	}
        if(NFMbmcs_globals.cur_cat_pos == (rows -1 ) && status == NFM_I_NO_MORE_BUFFERS)
	{
		NFMbmcs_globals_cleanup();
		return(NFM_I_NO_MORE_BUFFERS);
	}
	_NFMdebug((fname,"Exit >>Total catalogs <%d> failed catalogs = <%d> status <0x%.8x>\n",rows,failed_cats,NFM_S_SUCCESS));
	if (failed_cats > 0)
		return(NFM_I_SAC_SOME_CATALOGS);

	return(NFM_S_SUCCESS);
}

NFMbmcs_globals_cleanup()
{
	char *fname="NFMbmcs_globals_cleanup";
	static char *null_str="" ;
	_NFMdebug((fname,"Entry\n"));
	NFMbmcs_globals.search_ptr = null_str;
	NFMbmcs_globals.sort_ptr = null_str;
	if(NFMbmcs_globals.search_flag)  NFMfree_query_struct(&NFMbmcs_globals.query_info1);
        if(NFMbmcs_globals.sort_flag) NFMfree_query_struct(&NFMbmcs_globals.query_info2);
	NFMbmcs_globals.search_flag = 0;
	NFMbmcs_globals.sort_flag = 0;
	NFMbmcs_globals.query_flag = 0;
	NFMbmcs_globals.action_flag = BLOCK_START;
	NFMbmcs_globals.cur_cat_pos = 0;
	if(NFMbmcs_globals.cursor_open) 
	{
		_NFMdebug((fname, "Cursor is open\n"));
		SQLquery_cursor2("select * from nfmcatalogs",&NFMbmcs_globals.template_buffer,MEM_SIZE,0);
		_NFMdebug((fname, "Cursor is closed\n"));
	}
	NFMbmcs_globals.cursor_open = 0;
	MEMclose(&NFMbmcs_globals.new_cat_list);
	MEMclose(&NFMbmcs_globals.attr_list);
	MEMclose(&NFMbmcs_globals.template_buffer);
	_NFMdebug((fname,"SUCCESSFUL: <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}
