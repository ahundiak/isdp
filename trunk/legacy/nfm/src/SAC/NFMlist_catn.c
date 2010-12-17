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
#include "NFMapi.h"


long NFMlist_pdm_cat_names(user_id,list,search_name , sort_name,flag)
	long user_id;
	MEMptr	*list;
	char *search_name , *sort_name;
	long flag;
{
	long status = 0;
	char qry_str[5*STR_SIZE],return_str[2*STR_SIZE];
	char *fname="NFMlist_pdm_cat_names";
	char n_catalogname[SIZE] , n_catalogno[SIZE];
	long SQLquery();
	long size;
        struct NFMquery_info cat_query_info1, cat_query_info2;
	_NFMdebug((fname,"Entry >>\n\t\tuser_id\t%d\n\t\tlist address\t%d\n\t\t\
search_name\t%s\n\t\tsort_name\t%s\n\t\tFLAG\t%d\n",user_id,list,search_name,sort_name,flag));
	strcpy(n_catalogname,"n_catalogname");
	strcpy(n_catalogno,"n_catalogno");
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
/* retrieve the item search and sort queries */
/* Get the search_string */

        if(strcmp(search_name,"")!=0)
        {
                status = _NFMretrieve_query(search_name,&cat_query_info1);
                if(status!=NFM_S_SUCCESS)
                {
                        _NFMdebug((fname,"_NFMretrieve_query failed for query_name <%s>: status=<0x%.8x>\n",search_name,status));
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",search_name);
                        return(NFM_E_BAD_CRITERIA);
                }
		size = size + strlen(cat_query_info1.where_clause) + 5;
		if(size >= 5 *STR_SIZE)
		{
			_NFMdebug((fname,"Query string insufficient for search string\n"));
                        NFMfree_query_struct(&cat_query_info1);
			return(NFM_E_FAILURE);
		}
		strcat(qry_str, " AND ");
		strcat(qry_str,cat_query_info1.where_clause);
                NFMfree_query_struct(&cat_query_info1);
        }

/* Get the sort_string */
        if(strcmp(sort_name,"")!=0)
        {
                status = _NFMretrieve_query(sort_name,&cat_query_info2);
                if(status!=NFM_S_SUCCESS)
                {
                        _NFMdebug((fname,"_NFMretrieve_query failed for query_name <%s>: status=<0x%.8x>\n",sort_name,status));
                        ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",sort_name);
                        return(NFM_E_BAD_CRITERIA);
                }
		size = size + strlen(cat_query_info2.order_by_clause) + 10;
		if(size >= 5 * STR_SIZE)
		{
			_NFMdebug((fname,"Query string insufficient for sort string\n"));
                        NFMfree_query_struct(&cat_query_info2);
			return(NFM_E_FAILURE);
		}
		strcat(qry_str, " ORDER BY ");
		strcat(qry_str,cat_query_info2.order_by_clause);
                NFMfree_query_struct(&cat_query_info2);
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
