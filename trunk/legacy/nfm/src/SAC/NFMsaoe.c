#include "machine.h"


/***************************************************************************
*				NFMsearch_across_oper_env		   *
*									   *
*	This function generates a list of items from all the catalogs in   *
*	the table NFMCATALOGS in all the environments  			  *
***************************************************************************/
#include <stdio.h>
#include "MEMstruct.h"
#include "WFstruct.h"
#include "NFMerrordef.h"
#include "MEMerrordef.h"
#include "NFMsacdef.h"
#include "DEBUG.h"
#include "ERR.h"

extern char NFM_SRV_NODE[100], NFM_ENV_NODE[100];
#define FIRST_TIME              0
#define MEM_INT_SIZE            15
#define ENV_NAME_SIZE           60




long NFMsearch_across_oper_env(user_id,cat_search_str,cat_sort_str,
			item_search_str, item_sort_str,
			in_attr_list,env_list,out_buffer_list,mis_attr_list)
	long user_id;
	MEMptr	*out_buffer_list,*mis_attr_list;
	MEMptr in_attr_list,env_list;
	char *cat_search_str, *cat_sort_str;
	char *item_search_str , *item_sort_str;
{
	MEMptr out_buffer=MEMNULL, mis_attr=MEMNULL,node_list=MEMNULL;
	MEMptr out_buffer_new=MEMNULL;
	MEMptr mis_env_list=MEMNULL;
	char **data,**format;
	char **env_data;
	long rows,sac_status,status,return_status=NFM_S_SUCCESS,i,flag_out,flag_mis, length;
	char *fname="NFMsearch_across_oper_env";
	char env_name[SIZE],schema_name[SIZE];
	flag_out = FIRST_TIME;
	flag_mis = FIRST_TIME;
	length = ENV_NAME_SIZE;
	_NFMdebug((fname,"Entry\t>>\n\t\tuser_id\t%d\n\t\tcat_search_str\
\t%s\n\t\tcat_sort_str\t%s\n\t\titem_search_str\t%s\n\t\titem_sort_str\
\t%s\n\t\tin_attr_list\t%d\n\t\tenv_list\t%d\n\t\tout_buffer_list\t%d\n",user_id
,cat_search_str,cat_sort_str,item_search_str,item_sort_str,in_attr_list,
env_list,out_buffer_list));
/* check if the list pointer is NULL */
	if(out_buffer_list == MEMPTRNULL)
	{
		_NFMdebug((fname,"Output buffer pointer Address is <%d>\n",out_buffer_list));
		status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","out_buffer_list");
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
		status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","mis_attr_list");
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
/* Generate the list of known nfme_ nodes */

	if((status=NETls_nodes("nfme_" , &node_list))!= NET_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to generate environment list\n"));
		status = ERRload_struct(NFM,NFM_E_NO_ENV_NAME,"");
		if(status!=ERR_S_SUCCESS)
			_NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_NO_ENV_NAME);
	}
	if(env_list != MEMNULL)
	{
/* check to see that the env list has the accesible environments */
		if((status=NFMcmp_attr_list(env_list,node_list,&mis_env_list))!=NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"Environment list has bad environment name\n"));
			return_status= status;
			if(status==NFM_E_BAD_ATTRIBUTE)
		       {
				status = ERRload_struct(NFM,NFM_E_BAD_ENV,"%s","mismatch");
				if(status!=ERR_S_SUCCESS)
				_NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
			if((status=MEMbuild_array(mis_env_list))!=MEM_S_SUCCESS)
			{
				_NFMdebug((fname,"MEMbuild failed on mis_env_list\n"));
				MEMclose(&node_list);
				MEMclose(&mis_env_list);
				return(status);
			}
			data=(char **)mis_env_list->data_ptr;
			for(i=0;i<mis_env_list->rows;i++)
				_NFMdebug((fname,"Bad environment <%s>\n",data[i]));
				return_status=NFM_E_BAD_ENV;
		       }
			MEMclose(&node_list);
			MEMclose(&mis_env_list);
			
			return(return_status);
		}


		if((status=MEMbuild_array(env_list))!=MEM_S_SUCCESS)
		{
			_NFMdebug((fname,"MEMbuild failed on env_list\n"));
			status = ERRload_struct(NFM,NFM_E_BAD_ENV,"%s","<INTERNAL>MEMbuild_array fail env_list");
			if(status!=ERR_S_SUCCESS)
				_NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
			MEMclose(&node_list);
			MEMclose(&mis_env_list);
			return(NFM_E_BAD_ENV);
		}
		data = (char **)env_list->data_ptr;
		rows = env_list->rows;
	}
	else
	{

/* build list of nfme_ nodes */
		if((status=MEMbuild_array(node_list))!=MEM_S_SUCCESS)
		{
			_NFMdebug((fname,"MEMbuild failed on node_list\n"));
			status = ERRload_struct(NFM,NFM_E_BAD_ENV,"%s","<Internal>MEMbuild_array fail node_list");
			if(status!=ERR_S_SUCCESS)
				_NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
			MEMclose(&node_list);
			return(NFM_E_BAD_ENV);
		}

		data= (char **)node_list->data_ptr;
		rows = node_list->rows;
	}
	if(rows <= 0)
	{
		_NFMdebug((fname,"No rows in environment list\n"));
		status = ERRload_struct(NFM,NFM_E_BAD_ENV,"%s","Empty List");
		if(status!=ERR_S_SUCCESS)
			_NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		MEMclose(&node_list);
		return(NFM_E_BAD_ENV);
	}
/* For nodes in the list Define a schema */
	for ( i =0;i < rows; i++)
	{
		sprintf(env_name , "%s%s","nfme_",data[i]);
		strcpy(NFM_ENV_NODE,data[i]);
		if((status = NFMget_schema_info1(env_name,schema_name)) == NFM_S_SUCCESS)
		{
		
/* Perform the search across catalogs */
			sac_status=NFMsearch_across_catalogs(user_id,cat_search_str,
cat_sort_str,item_search_str,item_sort_str,in_attr_list,&out_buffer,&mis_attr);
		   if ( sac_status== NFM_S_SUCCESS || sac_status == NFM_E_BAD_ATTRIBUTE)
		   {
/* Generate a list of items with environment and environment name prepended */
                   	status =NFMadd_col(user_id,out_buffer,"char",length,&out_buffer_new,"n_env_name" );
                        if(status!=NFM_S_SUCCESS)
                        {
                       		_NFMdebug((fname,"Add column failed\
 status= <0x%.8x> for catalog %s\n",status,data[i]));
				return_status=status;
                                MEMclose(&out_buffer_new);
                        }
                        else
                        {
                        	status = NFMadd_col_val(user_id,out_buffer ,&out_buffer_new,data[i]);
                                if(status!=NFM_S_SUCCESS)
				{
                                	_NFMdebug((fname,"Failed to add\
value for catalog %s status=<0x%.8x>\n",data[i],status));
				}
				else
				{
					if(flag_out == FIRST_TIME)
					{
						status=MEMsplit_copy_buffer(out_buffer_new,out_buffer_list,0);
						if(status == MEM_S_SUCCESS) flag_out++;
						else
						{
_NFMdebug((fname,"Failed to MEMsplit_copy_buffer for environment <%s>\n",data[i]));
						}
					}
					else
					{
						status=MEMappend(out_buffer_new,*out_buffer_list);
						if(status!=MEM_S_SUCCESS)
						{
_NFMdebug((fname,"Failed to MEMappend for environment <%s>\n",data[i]));
						}

					}
					if(status != MEM_S_SUCCESS)
					{
					status=ERRload_struct(NFM,NFM_E_MEM,"");
       		                 	if(status!=ERR_S_SUCCESS)
					{
               		                 _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
					}
					}
				}
                        }

		   }
		   if (sac_status == NFM_E_BAD_ATTRIBUTE)
		   {
			_NFMdebug((fname,"Mismatch attribute occured for environment <%s>\n",data[i]));
			return_status=status;
			status=ERRload_struct(NFM,return_status,"%s%s","environment ",env_name);
                        if(status!=ERR_S_SUCCESS)
			{
                                _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
			}

                        if(flag_mis!=FIRST_TIME)
                        status=NFMadd_col_val(user_id,mis_attr ,mis_attr_list, data[i]);
                        else
                        {
                                status =NFMadd_col(user_id,mis_attr,"char",length,mis_attr_list,"n_env_name" );
                                if(status!=NFM_S_SUCCESS)
                                {
                                        _NFMdebug((fname,"Add column failed\
 status= <0x%.8x> for catalog %s\n",status,data[i]));
                                        MEMclose(mis_attr_list);
                                }
                                else
                                {
                                        status = NFMadd_col_val(user_id,mis_attr
,mis_attr_list,data[i]);
                                        if(status!=NFM_S_SUCCESS)
					{
                                                _NFMdebug((fname,"Failed to add\
value for catalog %s status=<0x%.8x>\n",data[i],status));
					}
                                }
                                if(status==NFM_S_SUCCESS)
                                        flag_mis++;
			} 
		   }
		   else if (sac_status != NFM_S_SUCCESS )
/* No error is loaded at this point as
	1.	An internal error caused SAC to Fail
	2.	No context sensitive information is available here
*/
			_NFMdebug((fname,"Search across catalog failed for env <%s> status <%d>\n",data[i],sac_status));
		   MEMclose(&out_buffer);
		   MEMclose(&out_buffer_new);
		   MEMclose(&mis_attr);
		   NFMlogoff();
/*
		   SQLstmt("CLOSE SCHEMA RISDBA");
*/
		}
		else
		{
			_NFMdebug((fname,"Unable to open schema for environment <%s>\n", data[i]));
			status=ERRload_struct(NFM,NFM_E_DEFINE_SCHEMA,"%s",env_name);
			if(status!=ERR_S_SUCCESS)
			{
			_NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
			}

		}
	}
	MEMclose(&node_list);
	MEMclose(&out_buffer);
	MEMclose(&out_buffer_new);
	MEMclose(&mis_attr);
	_NFMdebug((fname,"SUCCESSFUL Exit status <0x%.8x>\n",return_status));
	return(return_status);
}
