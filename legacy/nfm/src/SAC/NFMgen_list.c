#include "machine.h"

/***************************************************************************
*				NFMgen_list				   *
*	This function generates a listing of attributes specified in the   *
*	attribute list from the catalog specified by the catalog name      *
*									   *
***************************************************************************/
#include <stdio.h>
#include "MEMstruct.h"
#include "WFstruct.h"
#include "NFMerrordef.h"
#include "MEMerrordef.h"
#include "RPSdef.h"
#include "NFMsacdef.h"
#include "NFMdef.h"
#include "DEBUG.h"
#include "ERR.h"


extern struct WFstruct WFinfo;


long NFMgen_list(user_id,attr_list,out_list,cat_name,cat_no,search_name , sort_name)
	long user_id;
	MEMptr	attr_list, *out_list;
	char *search_name , *sort_name;
	char *cat_name,*cat_no;
{
	long status = 0,flag=0,i=0,m,n,size = 0;
	long length=0,x=0;
	char *qry_str,return_str[2*STR_SIZE],temp[SIZE];
	char **data,**format;
	char *fname="NFMgen_list";
	long SQLquery();
	MEMptr loc_attr_list;
	_NFMdebug((fname,"Entry >>\n\t\tuser_id\t%d\n\t\tattribute list\t%d\n\t\
\toutput list\t%d\n\t\tcatalog name\t%s\n\t\tcatalog number\t%s\n\t\tsearch name\
\t%s\n\t\tsort name\t%s\n",user_id,attr_list,out_list,cat_name,
cat_no,search_name,sort_name));
	loc_attr_list = MEMNULL ;
/* check if the list pointer is NULL */
	if(out_list == MEMPTRNULL)
	{
		_NFMdebug((fname,"Output list address pointer is <%d>\n",out_list));
/*>>>>>>>>>>>>>>Error processor Error here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Out buffer ptr");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);

	}
/* make sure that the list is NULL */
	if(*out_list != MEMNULL)
	{
		_NFMdebug((fname,"<<<<WARNING>>>> Output list is not null <%d>\n",*out_list));
		_NFMdebug((fname,"<<<<WARNING>>>> MEMclose on Output list <%d>\n",*out_list));
/* Close the out list memory */
		MEMclose(out_list);
	}
/* make sure that the attr list is  not NULL */
	if(attr_list == MEMNULL)
	{
		_NFMdebug((fname,"Attribute list is NULL <%d>\n",attr_list));
/*>>>>>>>>>>>>>>Error processor Error here */
                status = ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Attribute list");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}

/* make sure the catalog name is non empty */
	if((strlen(cat_name)) <= 0)
	{
		_NFMdebug((fname,"Catalog name is empty <%s>\n",cat_name));
/*>>>>>>>>>>>>>>Error processor Error here */
                status = ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","Catalog name");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_VALUE);
	}
/* make sure the catalog number is non empty */
	if((strlen(cat_no)) <= 0)
	{
		_NFMdebug((fname,"Catalog number is empty <%s>\n",cat_no));
/*>>>>>>>>>>>>>>Error processor Error here */
                status = ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","Catalog number");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_NULL_VALUE);
	}
/* Get the n_names for attr_list */
/* generate the attribute list */
        if((status=MEMbuild_array(attr_list)) !=MEM_S_SUCCESS)
        {
		_NFMdebug((fname,"MEMbuild_array failed for *attr_list <0x%.8x>\n",status));
		status=ERRload_struct(NFM,NFM_E_MEM,"%s","MEMbuild_array");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MEM);
        }
/* Generate the sql string */
/* generate the data lists */
	flag = 0;
        data = (char **) (attr_list)->data_ptr;
        format = (char **) (attr_list)->format_ptr;

	m=(attr_list)->rows;
	n=(attr_list)->columns;
/* Do a sanity check on attribute list */
	if ( m < 1 )
	{
		_NFMdebug((fname,"Number of rows is %d < 1\n", m));
		status=ERRload_struct(NFM,NFM_E_BAD_ATTR,"%s","NFMgen_list");
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_FAILURE);
        }
	x = 0;

               if (! strncmp (format [x], "integer",  7)) length = 15;
          else if (! strncmp (format [x], "smallint", 8)) length = 15;
          else if (! strncmp (format [x], "double",   6)) length = 50;
          else if (! strncmp (format [x], "real",     4)) length = 50;
          else if (! strncmp (format [x], "char",     4))
                  sscanf (format [x], "%5s%d", temp, &length);
	if(length <= 0) length = NFM_ITEMNAME;



		
/*	Check if the SQL string is long enough */
	size = 10 + (strlen(cat_name)+5 + length) * m ;
	size = size + 6 + 21 + 4*strlen(cat_name)+ 150 + length + 4*STR_SIZE;
	if(search_name != NULL ) size = size + strlen(search_name);
	if(sort_name != NULL ) size = size + strlen(sort_name);
/* Allocate the memory required for the query string */
	if((qry_str = (char *)malloc(size)) == (char *)0)
	{
		_NFMdebug((fname,"Cannot malloc string for query size =<%d>\n",size));
                status = ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
                if(status!=ERR_S_SUCCESS)
                        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
                return(NFM_E_MALLOC);
	}
	strcpy(qry_str,"SELECT ");

        for ( i=0 ; i < m * n; i++)
        {
/* NOT REQUIRED AS attr_list is list of attributes
		if( (i%2)!= 0 ) continue;
*/
		if(flag) strcat(qry_str , ",");
		sprintf(return_str , " %s.%s " , cat_name,data[i]);
		strcat(qry_str,return_str);
		flag++;
	}

/* Generate the sql string */
	strcat (qry_str , " FROM ");
	strcat (qry_str , cat_name);
	strcat(qry_str," , nfmstates, nfmacls ");
	sprintf(return_str , " %s %s.%s " ,"WHERE nfmstates.n_stateno = ", cat_name,"n_stateno");
	strcat(qry_str , return_str);
	sprintf(return_str," %s %s.%s ","AND nfmacls.n_aclno =",cat_name,"n_aclno");
	strcat(qry_str , return_str);
	
/* Get the search_string */
	if(search_name!= NULL )
	{
		strcat(qry_str, " AND ");
		strcat(qry_str,search_name);
	}
	
/* Get the sort_string */
	if(sort_name!= NULL )
	{
		strcat(qry_str, " ORDER BY ");
		strcat(qry_str,sort_name);
	}
	
	else
	{
		sprintf(return_str," %s %s.%s","ORDER BY ",cat_name,data[0]);
		strcat(qry_str,return_str);
	}
/* Call the SQL function */
 	if((status=SQLquery (qry_str, out_list, MEM_SIZE))!=SQL_S_SUCCESS)
	{
		_NFMdebug((fname,"SQL query failed to list items status <0x%.8x>\n",status));
		MEMclose(out_list);
		free(qry_str);
		MEMclose(&loc_attr_list);
		if (status == SQL_I_NO_ROWS_FOUND )
		{
			ERRload_struct(NFM,NFM_E_NO_ITEMS_FOUND_IN_CAT,"");
			return(NFM_E_NO_ITEMS_FOUND_IN_CAT);
		}
		else
		{
	                status = ERRload_struct(NFM,NFM_E_SQL_QUERY,"%s","NFMgen_list");
       		        if(status!=ERR_S_SUCCESS)
			{
                	        _NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
			}
	                return(NFM_E_SQL_QUERY);
		}

	}
	_NFMdebug((fname,"Exit > SUCCESSFUL \n"));
	MEMclose(&loc_attr_list);
	free(qry_str);
	return(NFM_S_SUCCESS);
}
