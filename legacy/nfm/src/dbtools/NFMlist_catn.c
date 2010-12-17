#include "machine.h"
/***************************************************************************
*				NFMlist_cat_names			   *
*									   *
*	This function generates a list of catalog names from the table     *
*	nfmcatalogs.							   *
***************************************************************************/
#include <stdio.h>
#include "MEMstruct.h"
#include "WFstruct.h"
#include "NFMerrordef.h"
#include "RPSdef.h"
#include "NFMsacdef.h"
#include "ERR.h"
#include "DEBUG.h"


long NFMlist_cat_names(user_id,list,search_name , sort_name,flag)
	long user_id;
	MEMptr	*list;
	char *search_name , *sort_name;
	long flag;
{
	long i,status = 0;
	char qry_str[5*STR_SIZE],return_str[2*STR_SIZE];
	char *fname="NFMlist_cat_names";
	char n_catalogname[SIZE] , n_catalogno[SIZE];
	char **data ;
	long SQLquery();
	long length,size;
	MEMptr attr_list = MEMNULL ;
	strcpy(n_catalogname,"n_catalogname");
	strcpy(n_catalogno,"n_catalogno");
	_NFMdebug((fname,"Entry >>\n\t\tuser_id\t%d\n\t\tlist address\t%d\n\t\t\
search_name\t%s\n\t\tsort_name\t%s\n\t\tFLAG\t%d\n",user_id,list,search_name,sort_name,flag));
/* check if the list pointer is NULL */
	if(list == MEMPTRNULL)
	{
		_NFMdebug((fname,"MEMptr list address is <%d>\n",list));
/*>>>>>>>>>>>>>>Error processor Error here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Output Buffer ptr");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}
/* make sure that the list is NULL as we will fill new info here */
	if(*list != MEMNULL)
	{
		_NFMdebug((fname,"<<<<WARNING>>>>List is non empty List =<%d>\n",*list));
		_NFMdebug((fname,"<<<<WARNING>>>>MEMclose on List =<%d>\n",*list));
		MEMclose(list);
	}
/* Get n_name for n_catalogno and n_catalogname */
/*
	strcpy(qry_str,"SELECT distinct n_nfmname, n_name from nfmattributes where\
  n_nfmname='n_catalogname' or n_nfmname='n_catalogno'");
	if((status=SQLquery(qry_str,&attr_list,MEM_SIZE))!=SQL_S_SUCCESS)
	{
		_NFMdebug((fname,"<<<WARNING>>>\t\tCannot obtain n_name for\
 n_catalogname and n_catalogno\n\t\t\tUsing n_catalogname and n_catalogno\n"));
	}
	else
	{
		if((status=MEMbuild_array(attr_list))!=MEM_S_SUCCESS)
		{
			_NFMdebug((fname,"<<WARNING>>\t\tInternal Failure MEMbuild_array failed on\n\t\t\tattribute list. Using n_catalogname and n_catalogno\n"));
		}
		else
		{
			data = (char **)attr_list->data_ptr;
			for(i=0;i < attr_list->rows ; i+=2)
			{
			if(strcmp(data[i],"n_catalogname")== 0)
strncpy(n_catalogname,data[i+1],SIZE -1);
			else  if(strcmp(data[i],"n_catalogno")== 0)
strncpy(n_catalogno,data[i+1],SIZE -1);
			}
		}
	}

	MEMclose(&attr_list);
*/

/* Generate the sql string */
	sprintf(qry_str,"SELECT nfmcatalogs.%s,nfmcatalogs.%s",n_catalogname,n_catalogno);
	strcat(qry_str," FROM nfmcatalogs, nfmstates, nfmacls ");
	strcat(qry_str," WHERE nfmstates.n_stateno = nfmcatalogs.n_stateno ");
 	strcat(qry_str, " AND nfmacls.n_aclno = nfmcatalogs.n_aclno ");
	if(flag > 0)
	{
		sprintf(return_str, " AND nfmcatalogs.%s != 'nfmsyscat' ",n_catalogname);
		strcat(qry_str,return_str);
	}
	size = strlen(qry_str);
/* Get the search_string */
	if(strcmp(search_name,"")!=0)
	{
		status = NFMget_string_criteria(user_id,search_name,RPS_SEARCH_TYPE,return_str);
		if(status!=NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"String search failed STRING %s , status <0x%.8x>\n",search_name,status));
	                status = ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",search_name);
        	        if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));

			return(NFM_E_BAD_CRITERIA);
		}
		size = size + strlen(return_str) + 5;
		if(size >= 5 *STR_SIZE)
		{
			_NFMdebug((fname,"Query string insufficient for search string\n"));
			return(NFM_E_FAILURE);
		}
		strcat(qry_str, " AND ");
		strcat(qry_str,return_str);
	}
	
/* Get the sort_string */
	if(strcmp(sort_name,"")!=0)
	{
		status = NFMget_string_criteria(user_id,sort_name,RPS_SORT_TYPE,return_str);
		if(status!=NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"String sort failed STRING %s , status <0x%.8x>\n",sort_name,status));
	                status = ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",sort_name);
        	        if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
			return(status);
		}
		size = size + strlen(return_str) + 10;
		if(size >= 5 * STR_SIZE)
		{
			_NFMdebug((fname,"Query string insufficient for sort string\n"));
			return(NFM_E_FAILURE);
		}
		strcat(qry_str, " ORDER BY ");
		strcat(qry_str,return_str);
	}
	
	else strcat(qry_str, " ORDER BY nfmcatalogs.n_catalogname");
/* Call the SQL function */
 	if((status=SQLquery (qry_str, list, MEM_SIZE))!=SQL_S_SUCCESS)
	{
		_NFMdebug((fname,"SQL query failed status <0x%.8x>\n",status));
		MEMclose(list);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			
                	status = ERRload_struct(NFM,NFM_E_NO_CATALOGS,"%s","NFMlist_catalogs");
                	if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
               		return(NFM_E_NO_CATALOGS);
		}
		else
		{
                	status = ERRload_struct(NFM,NFM_E_SQL_QUERY,"%s","NFMlist_catalogs");
                	if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
               		return(NFM_E_SQL_QUERY);
		}
	}
	_NFMdebug((fname,"Exit >> SUCCESSFul\n"));
	return(NFM_S_SUCCESS);
}
