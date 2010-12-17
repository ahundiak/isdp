#include "machine.h"

/************************************************************************
*									*
*			NFMlfm_information                                    *
*									*
* This procedure will query the local file manager table ( nfmsafiles)  *
* and return the data to the user.					*
*									*
* Input:								*
*	1. long sa_no; The working storage area number. A valid number  *
*	   must be passed by the caller. A value of  < 0 implies that   *
*	   working storage area number will be ignored.                 *
*									*
*	2. long flag; Flag must be					*
*		NFM_QUERY_LFM_BY_SANO ---->  query using the storage    *
*					     area number sa_no.    	*
*		NFM_QUERY_LFM ---->  query for all entries in 		*
*					   nfmsafiles			*
*									*
*	3. char *search; The query may be limited using a search 	*
*	   criteria.	Default is no search criteria. A "" implies no  *
*	   search criteria to be applied.				*
*									*
*	4. char *sort;	The query is to be sorted by sort criteria	*
*	   default is n_sano						*
*									*
* Output:								*
*	1. MEMptr *output_list; Memory buffer containing the results of *
*	   the query.							*
************************************************************************/

#include <stdio.h>

/* Application include files */
#include "NFMapi.h"  
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"
#include "RPSdef.h"

/* Function specific #defines */
#define SQL_STR_SIZE		2048
#define STR_SIZE		1024

/* External variables */


long NFMlfm_information(sa_no , flag , search , sort , output_list )
	long sa_no , flag ;
	char *search, *sort ;
	MEMptr *output_list ;
{
/* Internal variables */
	long and_flag= 0,length,status,user_id = 1;
	char sql_str[SQL_STR_SIZE] , return_str[STR_SIZE] ;
	char *fname="NFMlfm_information" ;

	_NFMdebug((fname,"Enter> sa_no <%d> flag <%d> search <%s>\n\
sort <%s> output_list address <%x>\n",sa_no,flag,search,sort,output_list));
/* Validate data */

/* If flag is 1 set sa_no to -1 */
/* 	if(flag == NFM_QUERY_LFM ) sa_no = -1 ;  changed by B.W. 12-16-1991 */
	if(flag == NFM_QUERY_LFM_ALL ) sa_no = -1 ;
	else if ( flag == NFM_QUERY_LFM_BY_SANO )
	{
		if ( sa_no < 0 )
		{
			ERRload_struct(NFM,NFM_E_BAD_SA_NO,"%d",sa_no);
			_NFMdebug((fname,"Bad storage area number <%d> status\
<0x%.8x>\n",sa_no,NFM_E_BAD_SA_NO));
			return(NFM_E_BAD_SA_NO);
		}
	}
	else
	{
		ERRload_struct(NFM,NFM_E_BAD_VALUE,"%s%d","flag",flag);
			_NFMdebug((fname,"Retrieve flag has bad valuer <%d> status\
<0x%.8x>\n",flag,NFM_E_BAD_SA_NO));
		return(NFM_E_BAD_VALUE);
	}


/* Initialize */
	and_flag = 0 ;
	length = sizeof(sql_str);

	MEMclose(output_list);

	strncpy(sql_str , "SELECT n_sano,n_filename,n_catalogno,n_itemno,\
n_filenum,n_date,n_co,n_copy,n_ref,n_nfs,n_cisano,n_mountpoint",length);

	strncat(sql_str," FROM nfmsafiles",length);

	if ( sa_no >= 0 )
	{
		sprintf(return_str , "WHERE n_sano = %d " , sa_no);
		strncat(sql_str,return_str , length); 
		and_flag = 1;
	}

/* get search string */
	if( ( search != (char *)0) && (strcmp(search,"")!=0))
	{
		status = NFMget_string_criteria(user_id,search,RPS_SEARCH_TYPE,return_str);
                if(status!=NFM_S_SUCCESS)
                {
                        _NFMdebug((fname,"String search failed STRING %s , status <0x%.8x>\n",search,status));
                        status = ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",search);
                        if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));

                        return(NFM_E_BAD_CRITERIA);
                }
		if(and_flag > 0 ) strncat ( sql_str , " AND ",length);
		else strncat (sql_str," WHERE ",length);
		strncat(sql_str,return_str,length);
	}


/* get sort string */
	if( ( sort != (char *)0) && (strcmp(sort,"")!=0))
	{
		status = NFMget_string_criteria(user_id,sort,RPS_SORT_TYPE,return_str);
                if(status!=NFM_S_SUCCESS)
                {
                        _NFMdebug((fname,"String search failed STRING %s , status <0x%.8x>\n",sort,status));
                        status = ERRload_struct(NFM,NFM_E_BAD_CRITERIA,"%s",sort);
                        if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                        return(NFM_E_BAD_CRITERIA);
                }
		strncat (sql_str," ORDER BY ",length);
		strncat(sql_str,return_str,length);
	}


/* query */
	if((status=SQLquery(sql_str,output_list,MEM_SIZE))!=SQL_S_SUCCESS)
	{
		_NFMdebug((fname,"SQL query failed status <0x%.8x>\nquery=<%s>\n",status,sql_str));
		MEMclose(output_list);
		if(status == SQL_I_NO_ROWS_FOUND)
			return(NFM_I_NO_ROWS_FOUND);
		else
		{
                        status = ERRload_struct(NFM,NFM_E_SQL_QUERY,"%s","NFMquery_lfm");
                        if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                        return(NFM_E_SQL_QUERY);

		}
	}


/* return data */
	_NFMdebug((fname,"EXIT >> SUCCESSFUL\n"));
	return(NFM_S_SUCCESS);
}


