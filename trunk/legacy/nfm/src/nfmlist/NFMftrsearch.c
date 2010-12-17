/***************************************************************************
*			NFMftr_search     		                   *
*									   *
*	This function performs item listing across multiple catalogs	   *
*	The list will contain all the items from the list of catalogs      *
*	that satisfy the search criteria, ftr, advance query. 		   *
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
#include "NFTftr.h"
#include "NEWdef.h"
#include "UTIerrordef.h"

#define  BLOCK_START 	0
#define  BLOCK_NEXT	1
#define  BLOCK_CLEANUP	2
#define  N_COLUMN_NAME	0
#define  N_DATATYPE	1
#define  NUM_OF_CURSOR	21


struct NFMbftr_adv_globals {
			char *search_ptr;
			char *sort_ptr;
			char *adv_select,*adv_from, *adv_where;
	                struct NFMquery_info query_info2 ;
	                MEMptr new_cat_list  ,attr_list  ;
	                MEMptr template_buffer ;
			long cur_cat_pos ,action_flag;
	                long search_flag  , sort_flag  ,query_flag;
        		struct NFMquery_ftr_info query_info1,ftr_query_info;
                        long ftr_flag;
			long cursor_open ;
			long flag;
                       } NFMbftr_adv_globals[NUM_OF_CURSOR] ;
			


long NFMftr_search(cat_list,
			search_name, sort_name,
			buffer_list,synonym_list,
			row_size,cursor_id, ftr_search)
	MEMptr	cat_list,*buffer_list,*synonym_list;
	char *search_name , *sort_name;
	long row_size,cursor_id;
	char *ftr_search;
{
	char *fname="NFMftr_search";
	long status,status2,count,i,return_status,j,done_flag,row_count;
	static long flag = 0;
	int rows,columns,failed_cats,no_of_catalogs;
	char src_catalog[NFM_FILENAME],tmp_str[NFM_FILENAME],
        tmp_str2[NFM_FILENAME];
	char **data,**data2,**format;
        struct NFMquery_ftr_info ftr_query_info;
        char *item_nos=NULL, *file_nos=NULL;
        char *temp_str=NULL, *sql_str=NULL, *strptr=NULL, *tokptr=NULL;
	MEMptr adv_buf;
        long or, x;
        long NFMbftr_adv_globals_cleanup();
	

	_NFMdebug((fname,"ENTER:MEMptr cat_list <%x>:Search Criteria <%s>\n\
          Sort Criteria <%s>: MEMptr *buffer_list <%x>: \n\
          MEMptr *synonym_list <%x> Row Size: <%d> cursor_id <%d>\n\
          ftr_search [%s]\n", 
          cat_list,search_name,sort_name,*buffer_list,
          *synonym_list,row_size,cursor_id, ftr_search));	

        if (_NFMdebug_st.NFMdebug_on)
        {
          MEMprint_buffer ("cat_list", cat_list, _NFMdebug_st.NFMdebug_file);
          MEMprint_buffer ("buffer_list", *buffer_list, 
                            _NFMdebug_st.NFMdebug_file);
          MEMprint_buffer ("synonym_list", *synonym_list, 
                            _NFMdebug_st.NFMdebug_file);
        }

        /* Check if the cursor_id is valid */
	if(cursor_id >= NUM_OF_CURSOR || cursor_id <= 0 )
	{
		_NFMdebug((fname,"Cursor id <%d>  must be less than <%d>\n",
                     cursor_id,NUM_OF_CURSOR));
		return(NFM_E_FAILURE);
	}

        /* Turn off auto commit: This causes cursors to stay open */

    	status = NFMcheck_transaction();
    	if( status == NFM_E_TRANSACTION_OFF )
    	{
       	 ERRload_struct( NFM, NFM_S_SUCCESS, NULL, NULL );
       	 _NFMdebug(( fname, "%s\n", "Autocommit was turned off" ));
    	}
    	else
    	{
       	 status = NFMset_autocommit_off (0);
       	 _NFMdebug(( fname, "Autocommit status <0x%.8x>\n", status ));
       	 _NFMdebug(( fname, "%s\n", "Autocommit was turned on" ));
    	}


	/* Initialize variables the first time a block query is done */

	if(!NFMbftr_adv_globals[cursor_id].flag)
	{
		_NFMdebug((fname,"Cursor_id <%d> flag <%d>\n",cursor_id,
                    NFMbftr_adv_globals[cursor_id].flag));
		NFMbftr_adv_globals[cursor_id].cursor_open = 0;
		NFMbftr_adv_globals[cursor_id].search_flag = 0;
		NFMbftr_adv_globals[cursor_id].sort_flag = 0;
		NFMbftr_adv_globals_cleanup(cursor_id);
		NFMbftr_adv_globals[cursor_id].flag++;
	}

	/* If row size is 0 a CLEANUP IS REQUESTED */

	if(row_size == 0 )
	{

		/* IF action_flag is set to BLOCK_START global variables 
		are already initialized */

		if(NFMbftr_adv_globals[cursor_id].action_flag == BLOCK_START)
		{
			_NFMdebug((fname,"Buffers already initialized:\
                	SUCCESSFUL: <0x%.8x>\n",NFM_S_SUCCESS));
			return(NFM_S_SUCCESS);
		}
		 NFMbftr_adv_globals[cursor_id].action_flag = BLOCK_CLEANUP ;
	}

	return_status = NFM_S_SUCCESS ;
	failed_cats = 0;

	/* Row count keeps track of how many more rows are required to complete
   	the request */

        row_count = row_size ;

	switch(NFMbftr_adv_globals[cursor_id].action_flag)
	{
	/* START A NEW QUERY */

		case BLOCK_START:
		/* check if the pointer to the Catalog list is NULL */
       		if(cat_list == (MEMptr)0)
       		{
       		        _NFMdebug((fname,"Catalog list address is <%x> NULL\n",				cat_list)) ;
       		        ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s",
			"catalog list");
       		        return(NFM_E_NULL_OUTPUT_MEMPTR);
       		}


		/* check if the list pointer is NULL */
	
		if(buffer_list == (MEMptr *)0)
	 	{
			_NFMdebug((fname,
                          "Output buffer pointer Address is <%x>\n",
                          buffer_list));
                	ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,
                           "%s","Output buffr pointer");
                	return(NFM_E_NULL_OUTPUT_MEMPTR);
		}
		/* make sure that the list is NULL  at entry point*/
		if(*buffer_list != (MEMptr)0)
		{
			_NFMdebug((fname,"<<<<WARNING>>>> Output \n \
                           buffer pointer  is\ <%x>(NOT NULL)\n\
                           <<<<WARNING>>>> *buffer_ptr set to NULL\n",
                          *buffer_list));

                          /* set out_buffer_list to NULL */
		
                          MEMclose(buffer_list);
	
                }
        /* check if the list pointer is NULL */
	
	if(synonym_list == (MEMptr *)0)
	{
		_NFMdebug((fname,"Synonym buffer pointer Address is <%x>\n",
                  synonym_list));
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s",
                 "Synonym_list pointer");
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
        /* make sure that the list is NULL  at entry point*/
	if(*synonym_list != (MEMptr)0)
	{
		_NFMdebug((fname,"<WARNING> Synonym buffer pointer  is\
                     <%x>(NOT NULL)\n\
                     <WARNING>>>> *synonym_list set to NULL\n",
                      *synonym_list));
                /* set out_buffer_list to NULL */
		MEMclose(synonym_list);
	}
        /* MEMbuild the catalog list */
        if((status=MEMbuild_array(cat_list)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for cat_list\
		 status = <0x%.8x>\n" , status));
		ERRload_struct(NFM,NFM_E_MEM_ERR,
                    "%s%s%s%x","MEMbuild_array for catalog list",
                    fname,"Status",status);
                return(NFM_E_MEM_ERR);
        }

        /* generate the data lists */
        data = (char **) cat_list->data_ptr;
        no_of_catalogs = cat_list->rows;
        /* check if there are any catalogs in catalog list
           There must be atleast one catalog */
        if(no_of_catalogs < 1)
        {
                _NFMdebug((fname,"Number of catalogs  %d < 1\n",
                        no_of_catalogs));
                ERRload_struct(NFM,NFM_E_NO_CATALOGS,"%s","Empty list");
                return(NFM_E_NO_CATALOGS);
        }

        /* Load and save the source catalog */
	strncpy(src_catalog,data[0],NFM_FILENAME);
	src_catalog[NFM_FILENAME-1] = '\0';

        /* Get catalog number for all the catalogs */

	status = NFMget_cat_list(cat_list,
             &NFMbftr_adv_globals[cursor_id].new_cat_list);
	if(status != NFM_S_SUCCESS)
	{
		MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
		_NFMdebug((fname,"Failed to generate catalog number for all\
                   catalogs in cat_list:status <0x%.8x>\n",status));
		return(status);
	}
        /* Get the search_string */

	adv_buf = NULL;

	if((search_name != NULL) && (strcmp(search_name,"")!=0))
	{
		NFMbftr_adv_globals[cursor_id].search_flag++;
                _NFMdebug ((fname, "search_name[0] = %c\n", search_name[0]));
                if (search_name[0] != ' ')
                {
    		  status = _NFMretrieve_ftr_query(search_name, "B",
                     &NFMbftr_adv_globals[cursor_id].query_info1);
		  if(status!=NFM_S_SUCCESS)
		  {
			_NFMdebug((fname,
                          "_NFMretrieve_query failed for query_name <%s>:\n\
                             status=<0x%.8x>\n",search_name,status));
			MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",search_name);
                        return(NFM_E_BAD_CRITERIA);
		  }
                  _NFMdebug ((fname, "retrieved ftr string [%s]\n",
                               NFMbftr_adv_globals[cursor_id].query_info1.ftr));
                }
                else 
                {

                  NFMbftr_adv_globals[cursor_id].query_info1.ftr = (char *)
                      calloc (strlen (search_name), sizeof (char));
                  for (x = 1; x < strlen (search_name); x ++)
                  {
                    NFMbftr_adv_globals[cursor_id].query_info1.ftr[x-1] = 
                                                          search_name [x];
                  }
                  NFMbftr_adv_globals[cursor_id].query_info1.ftr[x] = '\0';
                  _NFMdebug ((fname, "retrieved ftr string [%s]\n",
                               NFMbftr_adv_globals[cursor_id].query_info1.ftr));
                }
		status = _NFMgetAdvancedClauses(NFMbftr_adv_globals[cursor_id].query_info1 , &NFMbftr_adv_globals[cursor_id].adv_select , &NFMbftr_adv_globals[cursor_id].adv_from , &NFMbftr_adv_globals[cursor_id].adv_where);
		if(status!=NFM_S_SUCCESS)
		{
			_NFMdebug((fname,
                          "_NFMretrieve_adv_query failed for query_name <%s>:\n\
                             status=<0x%.8x>\n",search_name,status));
			MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
	        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info1);
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",search_name);
                        return(NFM_E_BAD_CRITERIA);
		}
		status = _NFMbuildRISattributes(NFMbftr_adv_globals[cursor_id].query_info1 , &adv_buf);
		if(status!=NFM_S_SUCCESS)
		{
			_NFMdebug((fname,
                          "_NFMretrieve_adv_query failed for query_name <%s>:\n\
                             status=<0x%.8x>\n",search_name,status));
			MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
			MEMclose(&adv_buf);
	        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info1);
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",search_name);
                        return(NFM_E_BAD_CRITERIA);
		}
		NFMbftr_adv_globals[cursor_id].search_ptr=
                   NFMbftr_adv_globals[cursor_id].query_info1.where_clause;
		status = _NFMcat_f_cat(
                   NFMbftr_adv_globals[cursor_id].query_info1.from_clause,
                      &NFMbftr_adv_globals[cursor_id].query_flag);
		if(status != NFM_S_SUCCESS)
		{
			_NFMdebug((fname,
                         "Cannot figure out the type for query from clause\n"));
		}
		status = _NFMf_cat
                  (NFMbftr_adv_globals[cursor_id].query_info1.where_clause,
                   &NFMbftr_adv_globals[cursor_id].query_flag);
		if(status != NFM_S_SUCCESS)
		{
			_NFMdebug((fname,
                        "Cannot figure out the type for query where clause\n"));
		}

	}
        /* Generate list of common attributes */
	status = NFMblockftr_attr_list(
              NFMbftr_adv_globals[cursor_id].new_cat_list,src_catalog,
              &NFMbftr_adv_globals[cursor_id].attr_list,synonym_list,adv_buf,
              "Catalog Name");
	if(status != NFM_S_SUCCESS)
	{
		MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
		MEMclose(&NFMbftr_adv_globals[cursor_id].attr_list);
		MEMclose(synonym_list);
		MEMclose(&adv_buf);
        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                          NFMfree_ftr_query_struct(
                             &NFMbftr_adv_globals[cursor_id].query_info1);
		_NFMdebug((fname,"Failed to generate attribute list and synonym\
                    list : status <0x%.8x>\n",status));
		return(status);
	}

        /* Get the sort_string */
	if((sort_name != NULL) && (strcmp(sort_name,"")!=0))
	{
		NFMbftr_adv_globals[cursor_id].sort_flag++;
		status = _NFMretrieve_query(sort_name,
                    &NFMbftr_adv_globals[cursor_id].query_info2);
		if(status!=NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"_NFMretrieve_query query_name <%s>:\n\
                            status=<0x%.8x>\n",sort_name,status));
			MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
			MEMclose(&NFMbftr_adv_globals[cursor_id].attr_list);
			MEMclose(&adv_buf);
			MEMclose(synonym_list);
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",sort_name);
	        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info1);
                        return(NFM_E_BAD_CRITERIA);
		}
	        if(NFMbftr_adv_globals[cursor_id].query_info2.order_by_clause
	         && *NFMbftr_adv_globals[cursor_id].query_info2.order_by_clause !=                        '\0')
             	  NFMbftr_adv_globals[cursor_id].sort_ptr = 
                      NFMbftr_adv_globals[cursor_id].query_info2.order_by_clause ;
		else
		  NFMbftr_adv_globals[cursor_id].sort_ptr = 
                     NFMbftr_adv_globals[cursor_id].query_info2.where_clause ;
	}

	if(strlen (ftr_search))
	{
		NFMbftr_adv_globals[cursor_id].ftr_flag++;
                _NFMdebug ((fname, "ftr_search[0] = [%c]\n",
                                    ftr_search[0]));
                if (ftr_search[0] != ' ')
                {
		  status = _NFMretrieve_ftr_query(ftr_search, "F", 
                             &NFMbftr_adv_globals[cursor_id].ftr_query_info);
		
                  if(status!=NFM_S_SUCCESS)
                  {
			_NFMdebug((fname,
                          "_NFMretrieve_ftr_query 4 ftr_q <%s>:\n\
                             status=<0x%.8x>\n",ftr_search,status));
			MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
			MEMclose(&NFMbftr_adv_globals[cursor_id].attr_list);
			MEMclose(synonym_list);
			MEMclose(&adv_buf);
	        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info1);
	        	if(NFMbftr_adv_globals[cursor_id].sort_flag)  
                           NFMfree_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info2);
	        	if(NFMbftr_adv_globals[cursor_id].ftr_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].ftr_query_info);
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",ftr_search);
                        return(NFM_E_BAD_CRITERIA);
		  }
		
                  _NFMdebug ((fname, "Retrieved FTR string [%s]\n",
                     NFMbftr_adv_globals[cursor_id].ftr_query_info.ftr));
                }
                else
                {
               
                   NFMbftr_adv_globals[cursor_id].ftr_query_info.ftr = (char *)
                      calloc (strlen (ftr_search) + 1, sizeof (char));
                   for (x = 1; x < strlen (ftr_search); x ++)
                   {
                     NFMbftr_adv_globals[cursor_id].ftr_query_info.ftr[x-1] =
                           ftr_search[x];
                   }
                   NFMbftr_adv_globals[cursor_id].ftr_query_info.ftr[x] = '\0';
                   _NFMdebug ((fname, "Assigned FTR string [%s]\n",
                     NFMbftr_adv_globals[cursor_id].ftr_query_info.ftr));
                }                   
	}


        /* Generate the template buffer */
		

        /* Open a memory structure */
        if((status=MEMopen(&NFMbftr_adv_globals[cursor_id].template_buffer,
            MEM_SIZE)) != MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMopen failed for template buffer\
                 status = <0x%.8x>\n" , status));
        	MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
		MEMclose(&NFMbftr_adv_globals[cursor_id].attr_list);
		MEMclose(&NFMbftr_adv_globals[cursor_id].template_buffer);
		MEMclose(synonym_list);
			MEMclose(&adv_buf);
	        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info1);
	        	if(NFMbftr_adv_globals[cursor_id].sort_flag)  
                           NFMfree_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info2);
	        	if(NFMbftr_adv_globals[cursor_id].ftr_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].ftr_query_info);
                ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                   "MEMopen for template_buffer", fname,"status",status);
                return(NFM_E_MEM_ERR);
        }
        sprintf(tmp_str,"char(%d)",NFM_CATALOGNAME);
	_NFMdebug((fname,"column: <%s> : datatype: <%s>\n",
                 "n_catalogname",tmp_str));
        if((status=MEMwrite_format(
              NFMbftr_adv_globals[cursor_id].template_buffer , 
              "n_catalogname", tmp_str))!=MEM_S_SUCCESS)
        {
                _NFMdebug((fname,"MEMwrite_format failed for template_buffer\
                  status = <0x%.8x>\n" , status));
        	MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
		MEMclose(&NFMbftr_adv_globals[cursor_id].attr_list);
		MEMclose(&NFMbftr_adv_globals[cursor_id].template_buffer);
		MEMclose(synonym_list);
			MEMclose(&adv_buf);
	        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info1);
	        	if(NFMbftr_adv_globals[cursor_id].sort_flag)  
                           NFMfree_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info2);
	        	if(NFMbftr_adv_globals[cursor_id].ftr_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].ftr_query_info);
                ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                  "MEMwrite_format for template_buffer",fname,"status",status);
                return(NFM_E_MEM_ERR);
        }

        if((status=MEMbuild_array(NFMbftr_adv_globals[cursor_id].attr_list)) !=                   MEM_S_SUCCESS )
        {
                _NFMdebug((fname,"MEMbuild_array failed for attribute list\
                 status = <0x%.8x>\n" , status));
        	MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
		MEMclose(&NFMbftr_adv_globals[cursor_id].attr_list);
		MEMclose(&NFMbftr_adv_globals[cursor_id].template_buffer);
		MEMclose(synonym_list);
			MEMclose(&adv_buf);
	        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info1);
	        	if(NFMbftr_adv_globals[cursor_id].sort_flag)  
                           NFMfree_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info2);
	        	if(NFMbftr_adv_globals[cursor_id].ftr_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].ftr_query_info);
                ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array",
                     fname,"Status",status);
                return(NFM_E_MEM_ERR);
        }
        data2 = (char **) NFMbftr_adv_globals[cursor_id].attr_list->data_ptr;

        for(j=0; j < NFMbftr_adv_globals[cursor_id].attr_list->rows ; j++ )
        {
          	count= NFMbftr_adv_globals[cursor_id].attr_list->columns * j ;


		_NFMdebug((fname,"column: <%s> : datatype: <%s>\n",
                   data2[count+N_COLUMN_NAME],data2[count+N_DATATYPE]));
                /*  This is because Glenn made me do this under duress  */

                if ((strcmp (data2[count], "n_aclno")) == 0)
		{
                        strcpy (tmp_str2, "n_aclname");
                        sprintf (tmp_str, "char(%d)",NFM_ACLNAME);
        	    	status=MEMwrite_format(
                            NFMbftr_adv_globals[cursor_id].template_buffer , 
                            tmp_str2,tmp_str) ;
		}
                else if ((strcmp (data2[count], "n_stateno")) == 0)
		{
                        strcpy (tmp_str2, "n_statename");
                        sprintf (tmp_str, "char(%d)",NFM_STATENAME);
        	    	status=MEMwrite_format(
                            NFMbftr_adv_globals[cursor_id].template_buffer , 
                            tmp_str2,tmp_str) ;
		}
		else
        	    status=MEMwrite_format(
                      NFMbftr_adv_globals[cursor_id].template_buffer , 
                      data2[count+N_COLUMN_NAME], data2[count+N_DATATYPE]) ;

        	if(status!=MEM_S_SUCCESS)
        	{
                	_NFMdebug((fname,
                          "MEMwrite_format failed for  template_buffer\
                  	status = <0x%.8x>\n" , status));
        		MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
			MEMclose(&NFMbftr_adv_globals[cursor_id].attr_list);
			MEMclose(&NFMbftr_adv_globals[cursor_id].template_buffer);
			MEMclose(synonym_list);
			MEMclose(&adv_buf);
	        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info1);
	        	if(NFMbftr_adv_globals[cursor_id].sort_flag)  
                           NFMfree_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info2);
	        	if(NFMbftr_adv_globals[cursor_id].ftr_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].ftr_query_info);
                	ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                          "MEMwrite_format for template_buffer",fname,
                          "status",status);
                	return(NFM_E_MEM_ERR);
        	}
        }
        if(adv_buf != (MEMptr) NULL )
	{
           if((status=MEMbuild_array(adv_buf)) != MEM_S_SUCCESS )
           {
                _NFMdebug((fname,"MEMbuild_array failed for attribute list\
                 status = <0x%.8x>\n" , status));
        	MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
		MEMclose(&NFMbftr_adv_globals[cursor_id].attr_list);
		MEMclose(&NFMbftr_adv_globals[cursor_id].template_buffer);
		MEMclose(synonym_list);
			MEMclose(&adv_buf);
	        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info1);
	        	if(NFMbftr_adv_globals[cursor_id].sort_flag)  
                           NFMfree_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info2);
	        	if(NFMbftr_adv_globals[cursor_id].ftr_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].ftr_query_info);
                ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array",
                     fname,"Status",status);
                return(NFM_E_MEM_ERR);
           }
           data2 = (char **) adv_buf->data_ptr;

           for(j=0; j < adv_buf->rows ; j++ )
           {
          	count= adv_buf->columns * j ;


		_NFMdebug((fname,"column: <%s> : datatype: <%s>\n",
                   data2[count+N_ADV_NAME_INDEX],data2[count+N_ADV_DATATYPE_INDEX]));
        	status=MEMwrite_format(
                   NFMbftr_adv_globals[cursor_id].template_buffer , 
                      data2[count+N_ADV_NAME_INDEX], data2[count+N_ADV_DATATYPE_INDEX]) ;

        	if(status!=MEM_S_SUCCESS)
        	{
                	_NFMdebug((fname,
                          "MEMwrite_format failed for  template_buffer\
                  	status = <0x%.8x>\n" , status));
        		MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
			MEMclose(&NFMbftr_adv_globals[cursor_id].attr_list);
			MEMclose(&NFMbftr_adv_globals[cursor_id].template_buffer);
			MEMclose(synonym_list);
			MEMclose(&adv_buf);
	        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info1);
	        	if(NFMbftr_adv_globals[cursor_id].sort_flag)  
                           NFMfree_query_struct(
                              &NFMbftr_adv_globals[cursor_id].query_info2);
	        	if(NFMbftr_adv_globals[cursor_id].ftr_flag)  
                           NFMfree_ftr_query_struct(
                              &NFMbftr_adv_globals[cursor_id].ftr_query_info);
                	ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                          "MEMwrite_format for template_buffer",fname,
                          "status",status);
                	return(NFM_E_MEM_ERR);
        	}
           }
	   MEMclose(&adv_buf);
        }
        if((status= MEMsplit_copy_buffer (
             NFMbftr_adv_globals[cursor_id].template_buffer,buffer_list,0))!=                         MEM_S_SUCCESS)
        {
               	_NFMdebug((fname,"MEMwrite_format failed for  template_buffer\
               	status = <0x%.8x>\n" , status));
        	MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
		MEMclose(&NFMbftr_adv_globals[cursor_id].attr_list);
		MEMclose(&NFMbftr_adv_globals[cursor_id].template_buffer);
		MEMclose(synonym_list);
		MEMclose(buffer_list);
        	if(NFMbftr_adv_globals[cursor_id].search_flag)  
                          NFMfree_ftr_query_struct(
                             &NFMbftr_adv_globals[cursor_id].query_info1);
        	if(NFMbftr_adv_globals[cursor_id].sort_flag)  
                          NFMfree_query_struct(
                             &NFMbftr_adv_globals[cursor_id].query_info2);
        	if(NFMbftr_adv_globals[cursor_id].ftr_flag)  
                          NFMfree_ftr_query_struct(
                             &NFMbftr_adv_globals[cursor_id].ftr_query_info);
               	ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                  "MEMwrite_format for template_buffer",fname,"status",status);
               	return(NFM_E_MEM_ERR);
         }
             

		NFMbftr_adv_globals[cursor_id].action_flag = BLOCK_NEXT ;



				break;
		case BLOCK_NEXT:

        if((status= MEMsplit_copy_buffer (
          NFMbftr_adv_globals[cursor_id].template_buffer,
          buffer_list,0))!= MEM_S_SUCCESS)
        {
               	_NFMdebug((fname,
                  "MEMsplit_copy_buffer failed for  template_buffer\
               	status = <0x%.8x>\n" , status));
		MEMclose(buffer_list);
		NFMbftr_adv_globals_cleanup(cursor_id);
               	ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                   "MEMsplit_copy_buffer for template_buffer",fname,
                   "status",status);
               	return(NFM_E_MEM_ERR);
         }
				break;
		case BLOCK_CLEANUP:
		default:
			NFMbftr_adv_globals_cleanup(cursor_id);
			_NFMdebug((fname,
                             "Returning after cleanup status <0x%.8x>\n",
                             NFM_S_SUCCESS));
			return(NFM_S_SUCCESS);
	}


        /* MEMbuild the catalog list */
        if((status=MEMbuild_array(NFMbftr_adv_globals[cursor_id].new_cat_list))                 != MEM_S_SUCCESS )
        {
		NFMbftr_adv_globals_cleanup(cursor_id);
                _NFMdebug((fname,"MEMbuild_array failed for new_cat_list\
		 status = <0x%.8x>\n" , status));
		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                  "MEMbuild_array for New Catalog List",fname,"Status",status);
                return(NFM_E_MEM_ERR);
        }

        /* generate the data lists */
        data = (char **) (NFMbftr_adv_globals[cursor_id].new_cat_list)->data_ptr;
	rows = (NFMbftr_adv_globals[cursor_id].new_cat_list) -> rows;
	columns = (NFMbftr_adv_globals[cursor_id].new_cat_list) -> columns;

       
	done_flag = 0;
        for ( i=NFMbftr_adv_globals[cursor_id].cur_cat_pos ; 
              i <rows && !done_flag; i++)
        {

		count = columns * i;
		NFMbftr_adv_globals[cursor_id].cur_cat_pos = i;
        	if((status2=MEMbuild_array(*buffer_list)) != MEM_S_SUCCESS )
        	{
			NFMbftr_adv_globals_cleanup(cursor_id);
                	_NFMdebug((fname,
                          "MEMbuild_array failed for new_cat_list\
		 	   status = <0x%.8x>\n" , status2));
			ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                           "MEMbuild_array for New Catalog List",
                           fname,"Status",status2);
                	return(NFM_E_MEM_ERR);
		}
		format = (char **) (*buffer_list) -> format_ptr;
	        _NFMdebug((fname,"format <%s> : catalog <%s>\n",
                           format[0],data[count]));
                /** 3/23/94 begin **/
     
                if (NFMbftr_adv_globals[cursor_id].ftr_flag > 0)
                {
                  status = NFT_ftr_search (atol (data[count+1]),
                             NFMbftr_adv_globals[cursor_id].ftr_query_info.ftr, &item_nos, &file_nos);
                  if (status != UTI_S_SUCCESS)
                  {

		    if(return_status == NFM_S_SUCCESS)
			return_status = status;

                    _NFMdebug ((fname, "NFT_ftr_search 0x%.8x\n", status));
/*
		    NFMbftr_adv_globals_cleanup(cursor_id);
                    return (status);
*/
                  }
		    
		  if(item_nos == (char *) 0)
		  {
		    	item_nos = (char *)malloc(20);
		    if(item_nos == (char *) 0)
		    {
			_NFMdebug((fname, "Malloc Failed for %d\n",20));
			NFMbftr_adv_globals_cleanup(cursor_id);
			ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                           "Malloc Failed for item no",
                           fname,"Status",NFM_E_MEM_ERR);
			return(NFM_E_MEM_ERR);
		    }
		    strcpy(item_nos,"-1");
		    file_nos = (char *)malloc(20);
		    if(file_nos == (char *) 0)
		    {
			_NFMdebug((fname, "Malloc Failed for %d\n",20));
			free(item_nos);
			NFMbftr_adv_globals_cleanup(cursor_id);
			ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                           "Malloc Failed for file no",
                           fname,"Status",NFM_E_MEM_ERR);
			return(NFM_E_MEM_ERR);
		    }
		    strcpy(file_nos,"-1");
		   }
                  _NFMdebug ((fname, "item_nos [%s] file_nos [%s]\n",
                              item_nos, file_nos));
                  strptr = (char *) calloc (strlen (item_nos) + 1, 
                                            sizeof (char));
                  if (strptr == (char *) NULL)
                  {
		    NFMbftr_adv_globals_cleanup(cursor_id);
                    _NFMdebug ((fname, "NFT_ftr_search 0x%.8x\n", status));
                  if (item_nos != (char *) NULL)
                    free (item_nos);
                  if (file_nos != (char *) NULL)
                    free (file_nos);
			NFMbftr_adv_globals_cleanup(cursor_id);
			ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                           "Malloc Failed for strptr",
                           fname,"Status",NFM_E_MEM_ERR);
			return(NFM_E_MEM_ERR);
                  }
                  sql_str = (char *) calloc (strlen (item_nos) * 20, 
                                             sizeof (char));
                  if (sql_str == (char *) NULL)
                  {
		    NFMbftr_adv_globals_cleanup(cursor_id);
                    _NFMdebug ((fname, "NFT_ftr_search 0x%.8x\n", status));
                  if (item_nos != (char *) NULL)
                    free (item_nos);
                  if (file_nos != (char *) NULL)
                    free (file_nos);
                  if (strptr != (char *) NULL)
                    free (strptr);
			ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x",
                           "Malloc Failed for sql_str",
                           fname,"Status",NFM_E_MEM_ERR);
			return(NFM_E_MEM_ERR);
                  }
                  strcpy (strptr, item_nos);
                  _NFMdebug ((fname, "strptr [%s]\n"));
                  or = 0; sql_str[0]='\0';
                  while ((tokptr = (char *) strtok (strptr, ",")) !=
                         (char *) NULL)
                  {
                     _NFMdebug ((fname, "tokptr[%s]\n", tokptr));
                     if (! or)
                     {
                       sprintf (sql_str, "(a.n_itemno = %s", tokptr);
                       or = 1;
                     }
                     else
                     {
                       strcat (sql_str, " or a.");
                       strcat (sql_str, "n_itemno = ");
                       strcat (sql_str, tokptr);
                     }
                     strptr = (char *) NULL;
                  }
                  if(or)
                  	strcat (sql_str, ")");
                  _NFMdebug ((fname, "sql_str [%s]\n", sql_str));
/*
                  if (strlen (NFMbftr_adv_globals[cursor_id].search_ptr))
                  {
                    _NFMdebug ((fname, "assemble [%s] and [%s]\n",
                                NFMbftr_adv_globals[cursor_id].search_ptr,
                                sql_str));
                    temp_str = (char *) calloc 
                      (strlen(NFMbftr_adv_globals[cursor_id].search_ptr) +
                       strlen (sql_str) + 5, sizeof (char));
                    if (temp_str == (char *) NULL)
                    {
		      NFMbftr_adv_globals_cleanup(cursor_id);
                      _NFMdebug ((fname, "NFT_ftr_search 0x%.8x\n", status));
                      return (status);
                    }
                    strncpy (temp_str,
                      NFMbftr_adv_globals[cursor_id].search_ptr, 
                      strlen(NFMbftr_adv_globals[cursor_id].search_ptr));
                    strcat (temp_str, " and ");
                    strcat (temp_str, sql_str);
                    free (NFMbftr_adv_globals[cursor_id].search_ptr);
                    NFMbftr_adv_globals[cursor_id].search_ptr = temp_str;
                    free (sql_str);
                  }
                  else
                  {
                    NFMbftr_adv_globals[cursor_id].search_ptr = sql_str;
                  }
*/
                  if (item_nos != (char *) NULL)
                    free (item_nos);
                  if (file_nos != (char *) NULL)
                    free (file_nos);
                  if (strptr != (char *) NULL)
                  	free (strptr);
                _NFMdebug ((fname, "ftr_search [%s]\n",
                           sql_str));
                }
                /** 3/23/94 end **/

		status = NFMblockftr_adv(
                           NFMbftr_adv_globals[cursor_id].attr_list,
                           buffer_list,data[count], 

                           data[count+1],
                           NFMbftr_adv_globals[cursor_id].search_ptr,
                           NFMbftr_adv_globals[cursor_id].sort_ptr,
                           NFMbftr_adv_globals[cursor_id].adv_select,
                           NFMbftr_adv_globals[cursor_id].adv_from,
                           NFMbftr_adv_globals[cursor_id].adv_where,
			   sql_str,
                           NFMbftr_adv_globals[cursor_id].query_flag,
                           row_count,cursor_id);

		if(sql_str != NULL) free(sql_str);

			
		if ( (*buffer_list)->rows >= row_size )
			 done_flag++;
		row_count = row_size - (*buffer_list)->rows;
		if(status==NFM_S_SUCCESS)
		{
			NFMbftr_adv_globals[cursor_id].cursor_open = 1;
		}
		else if ( status == NFM_E_NO_ITEMS_FOUND_IN_CAT)
		{
			NFMbftr_adv_globals[cursor_id].cursor_open = 0;
			_NFMdebug((fname,"No items in catalog %s\n",data[i]));
			if(return_status == NFM_S_SUCCESS) 
                          return_status = status ;
			failed_cats++;
		}
		else if ( status == NFM_I_NO_MORE_BUFFERS) 
		{
			NFMbftr_adv_globals[cursor_id].cursor_open = 0;
			continue;
		}
		else
                /* NFMgen_list will load context specific information */
		{
			NFMbftr_adv_globals[cursor_id].cursor_open = 0;
			failed_cats++;
			_NFMdebug((fname,
                          "List Item failed for catalog %s status=<0x%.8x>\n",
                          data[count],status));
			if(return_status != NFM_S_SUCCESS)
			{
				_NFMdebug((fname,
                                  "ERROR Previous status = <0x%.8x>\n",
                                  return_status));
			       _NFMdebug((fname,"ERROR New status = <0x%.8x>\n",
                                  status));
				return_status = status ;
			}
			else
			{
				_NFMdebug((fname,
                                  "ERROR New status = <0x%.8x>\n",status));
				 return_status=status ;	
			}
		}
	}
	if (failed_cats > 0)
		ERRload_struct(NFM,NFM_I_SAC_SOME_CATALOGS,
                "%d%x",failed_cats,return_status);
        /* Close the query structure */
	if(failed_cats > 0 && failed_cats == rows )
	{
		_NFMdebug((fname,"ERROR Previous status = <0x%.8x>\n",
                  return_status));
		_NFMdebug((fname,
                   "Search across catalogs failed for all the catalogs\n"));
		ERRload_struct(NFM,NFM_E_SAC_ALL_CATALOGS,
                   "%d%d%x",rows,failed_cats,return_status);
	 	return_status=NFM_E_SAC_ALL_CATALOGS;
		NFMbftr_adv_globals_cleanup(cursor_id);
		_NFMdebug((fname,"Exit >>Total catalogs <%d> \n\
                   failed catalogs = <%d> status <0x%.8x>\n",
                   rows,failed_cats,return_status));
		return(return_status);
	}

	if (NFMbftr_adv_globals[cursor_id].cur_cat_pos >= rows-1 && !done_flag  )
	{
		NFMbftr_adv_globals_cleanup(cursor_id);
		return(NFM_I_NO_MORE_BUFFERS);
	}
        if(NFMbftr_adv_globals[cursor_id].cur_cat_pos == (rows -1 ) && 
           status == NFM_I_NO_MORE_BUFFERS)
	{
		NFMbftr_adv_globals_cleanup(cursor_id);
		return(NFM_I_NO_MORE_BUFFERS);
	}
	_NFMdebug((fname,"Exit >>Total catalogs <%d> failed \n\
          catalogs = <%d> status <0x%.8x>\n",rows,failed_cats,NFM_S_SUCCESS));
	if (failed_cats > 0)
		return(NFM_I_SAC_SOME_CATALOGS);

	return(NFM_S_SUCCESS);
}
long NFMbftr_adv_globals_init()
{
	long i;
        long NFMbftr_adv_globals_cleanup();
	for (i=0; i < NUM_OF_CURSOR; i++)
		NFMbftr_adv_globals_cleanup(i);
}
long NFMbftr_adv_globals_cleanup(cursor_id)
long cursor_id;
{
	char *fname="NFMbftr_adv_globals_cleanup";
	static char *null_str="" ;
	_NFMdebug((fname,"Entry : cursor_id <%d>\n",cursor_id));
	NFMbftr_adv_globals[cursor_id].search_ptr = null_str;
	NFMbftr_adv_globals[cursor_id].sort_ptr = null_str;
	NFMbftr_adv_globals[cursor_id].adv_select = null_str;
	NFMbftr_adv_globals[cursor_id].adv_from = null_str;
	NFMbftr_adv_globals[cursor_id].adv_where = null_str;
	if(NFMbftr_adv_globals[cursor_id].search_flag)  NFMfree_ftr_query_struct(&NFMbftr_adv_globals[cursor_id].query_info1);
        if(NFMbftr_adv_globals[cursor_id].sort_flag) NFMfree_query_struct(&NFMbftr_adv_globals[cursor_id].query_info2);
        if(NFMbftr_adv_globals[cursor_id].ftr_flag) NFMfree_ftr_query_struct(&NFMbftr_adv_globals[cursor_id].ftr_query_info);
	NFMbftr_adv_globals[cursor_id].ftr_flag = 0;
	NFMbftr_adv_globals[cursor_id].search_flag = 0;
	NFMbftr_adv_globals[cursor_id].sort_flag = 0;
	NFMbftr_adv_globals[cursor_id].query_flag = 0;
	NFMbftr_adv_globals[cursor_id].action_flag = BLOCK_START;
	NFMbftr_adv_globals[cursor_id].cur_cat_pos = 0;
	if(NFMbftr_adv_globals[cursor_id].cursor_open) 
	{
		_NFMdebug((fname, "Cursor is open\n"));
		
	     switch(cursor_id)
	     {
		case 1:
		SQLquery_cursor11("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 2:
		SQLquery_cursor12("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 3:
		SQLquery_cursor13("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 4:
		SQLquery_cursor14("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 5:
		SQLquery_cursor15("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 6:
		SQLquery_cursor16("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 7:
		SQLquery_cursor17("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 8:
		SQLquery_cursor18("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 9:
		SQLquery_cursor19("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 10:
		SQLquery_cursor20("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 11:
		SQLquery_cursor21("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 12:
		SQLquery_cursor22("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 13:
		SQLquery_cursor23("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 14:
		SQLquery_cursor24("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 15:
		SQLquery_cursor25("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 16:
		SQLquery_cursor26("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 17:
		SQLquery_cursor27("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 18:
		SQLquery_cursor28("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 19:
		SQLquery_cursor29("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
		case 20:
		SQLquery_cursor30("select * from nfmcatalogs",&NFMbftr_adv_globals[cursor_id].template_buffer,MEM_SIZE,0);
		break;
	     }
		_NFMdebug((fname, "Cursor is closed\n"));
	}
	NFMbftr_adv_globals[cursor_id].cursor_open = 0;
	MEMclose(&NFMbftr_adv_globals[cursor_id].new_cat_list);
	MEMclose(&NFMbftr_adv_globals[cursor_id].attr_list);
	MEMclose(&NFMbftr_adv_globals[cursor_id].template_buffer);
	NFMbftr_adv_globals[cursor_id].flag = 0;
	_NFMdebug((fname,"SUCCESSFUL: <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}

/*
long _NFMgetAdvancedClauses (qInfo, selectClause, fromClause, whereClause)
   struct NFMquery_info qInfo; 	   /# I - Structure of query info #/
   char   #selectClause;           /# O - Advanced select clause #/
   char   #fromClause;             /# O - Advanced from clause #/
   char   #whereClause;            /# O - Advanced where clause #/
{
	if(qInfo.selectClause != (char * )0 )
		selectClause = qInfo.selectClause;
	if(qInfo.fromClause != (char * )0 )
		fromClause = qInfo.fromClause;
	if(qInfo.whereClause != (char * )0 )
		whereClause = qInfo.whereClause;
	return(NFM_S_SUCCESS);
}
long  _NFMbuildRISattributes(query_info , adv_buf)
	MEMptr *adv_buf;
	struct NFMquery_info query_info;
{
	*adv_buf = NULL;
	return(NFM_S_SUCCESS);
}
*/
