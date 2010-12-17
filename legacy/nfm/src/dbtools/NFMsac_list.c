#include "machine.h"

/***************************************************************************
*				NFMsac_list				   *
*	This function generates a listing of attributes specified in the   *
*	attribute list from the catalog specified by the catalog name      *
*									   *
***************************************************************************/
#include "NFMnfmsacinc.h"
#include "NFMapi.h"


long NFMsac_list(attr_list,out_list,cat_name,cat_no,search_name , sort_name,query_flag)
	MEMptr	attr_list, *out_list;
	char *search_name , *sort_name;
	char *cat_name,*cat_no;
	long query_flag;
{
	long status = 0,i=0,m,n,size = 0;
	long length=0,count;
	char *qry_str,return_str[NFM_FILENAME];
	char **data,**format;
	char *fname="NFMsac_list";
	long SQLquery();

	_NFMdebug((fname,"Entry: attr_list <%x>: out_list <%x>: catalog name <%s>\
Catalog no <%s>: ",attr_list,out_list,cat_name, cat_no));

	if(search_name == NULL)
        { 
	    _NFMdebug((fname,"search_name <>: "));
        }
	else
	{
	    _NFMdebug((fname,"search_name <%s>: ", search_name));
        }

	if(sort_name == NULL)
	{
	    _NFMdebug((fname,"sort_name <>\n"));
	}
	else
	{
	    _NFMdebug((fname,"sort_name <%s>\n", sort_name));
 	}


/* check if the list pointer is NULL */
	if(out_list == (MEMptr *)0)
	{
		_NFMdebug((fname,"Output list address pointer is <%x>\n",out_list));
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Out buffer ptr");
                return(NFM_E_NULL_OUTPUT_MEMPTR);

	}
/* make sure that the list is NULL */
	if(*out_list != (MEMptr)0)
	{
		_NFMdebug((fname,"<<<<WARNING>>>> Output list is not null <%x>\
\n<<<<WARNING>>>> *out_list will be set to NULL\n",*out_list));
/* Close the out list memory */
		MEMclose(out_list);
	}
/* make sure that the attr list is  not NULL */
	if(attr_list == (MEMptr)0)
	{
		_NFMdebug((fname,"Attribute list is NULL <%x>\n",attr_list));
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Attribute list");
                return(NFM_E_NULL_OUTPUT_MEMPTR);
	}

/* make sure the catalog name is non empty */
	if((strlen(cat_name)) <= 0)
	{
		_NFMdebug((fname,"Catalog name is empty <%s>\n",cat_name));
                ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","Catalog name");
                return(NFM_E_NULL_VALUE);
	}
/* make sure the catalog number is non empty */
	if((strlen(cat_no)) <= 0)
	{
		_NFMdebug((fname,"Catalog number is empty <%s>\n",cat_no));
                ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","Catalog number");
                return(NFM_E_NULL_VALUE);
	}
/* generate the attribute list */
        if((status=MEMbuild_array(attr_list)) !=MEM_S_SUCCESS)
        {
		_NFMdebug((fname,"MEMbuild_array failed for *attr_list <0x%.8x>\n",status));
		ERRload_struct(NFM,NFM_E_MEM_ERR,"%s%s%s%x","MEMbuild_array",fname,"status",status);
                return(NFM_E_MEM_ERR);
        }
/* generate the data lists */
        data = (char **) (attr_list)->data_ptr;
        format = (char **) (attr_list)->format_ptr;

	m=(attr_list)->rows;
	n=(attr_list)->columns;
/* Do a sanity check on attribute list */
	if ( m < 1 )
	{
		_NFMdebug((fname,"Number of rows is %d < 1\n", m));
		ERRload_struct(NFM,NFM_E_BAD_ATTR,"%s","NFMsac_list");
                return(NFM_E_BAD_ATTR);
        }

               if (! strncmp (format [0], "integer",  7)) length = 15;
          else if (! strncmp (format [0], "smallint", 8)) length = 15;
          else if (! strncmp (format [0], "double",   6)) length = 50;
          else if (! strncmp (format [0], "real",     4)) length = 50;
          else if (! strncmp (format [0], "timestamp",9)) length = 20;
          else if (! strncmp (format [0], "char",     4))
                  sscanf (format [0], "%5s%d", return_str, &length);
	if(length <= 0) length = NFM_ITEMNAME;
		
/*	Check if the SQL string is long enough */
	size = 10 + (strlen(cat_name)+5 + length) * m ;
	size = size + 6 + 21 + 5*strlen(cat_name)+ 200 + length;
	if(search_name != NULL ) size = size + strlen(search_name)+10;
	if(sort_name != NULL ) size = size + strlen(sort_name)+10;
	else size = size + 128 ;
/* Allocate the memory required for the query string */
	if((qry_str = (char *)malloc(size)) == (char *)0)
	{
		_NFMdebug((fname,"Cannot malloc string for query size =<%d>\n",size));
                ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
                return(NFM_E_MALLOC);
	}
        if (query_flag > 0 )
	strcpy(qry_str,"SELECT DISTINCT nfmcatalogs.n_catalogname ");
        else
	strcpy(qry_str,"SELECT nfmcatalogs.n_catalogname ");

        for ( i=0 ; i < m ; i++)
        {
		count = n * i;

		/*  This is because Glenn made me do this under duress  */

		if ((strcmp (data[count], "n_aclno")) == 0)
			strcat (qry_str, ", nfmacls.n_aclname ");
		else if ((strcmp (data[count], "n_stateno")) == 0)
			strcat (qry_str, ", nfmstates.n_statename ");
		else
		{
			sprintf(return_str , ", a.%s " , data[count]);
			strcat(qry_str,return_str);
		}
	}

/* Generate the sql string */
	strcat (qry_str , " FROM ");

	/*  if query_flag=0, only cat; =1 only f_cat; =2 both  */

	if (query_flag > 0)
	{
		sprintf(return_str," %s a , f_%s f_a ",cat_name,cat_name);
		strcat(qry_str,return_str);
	}
	else
	{
		sprintf(return_str," %s a ",cat_name);
		strcat(qry_str,return_str);
	}
	strcat(qry_str," , nfmstates, nfmacls ,nfmcatalogs");
	sprintf(return_str , " %s a.%s " ,"WHERE nfmstates.n_stateno = ", "n_stateno");
	strcat(qry_str , return_str);
	sprintf(return_str," %s a.%s ","AND nfmacls.n_aclno =","n_aclno");
	strcat(qry_str , return_str);
	sprintf(return_str," %s '%s' ","AND nfmcatalogs.n_catalogname =",cat_name);
	strcat(qry_str , return_str);

	if (search_name != NULL)
	{
                if(strlen(search_name))
                {
                        strcat(qry_str , " AND ");
                        strcat(qry_str , search_name);
                }
	}

	if (query_flag > 0 )
		strcat(qry_str , " AND a.n_itemno = f_a.n_itemnum");

	if (sort_name != NULL)
	{
                if(strlen(sort_name))
                {
                        strcat(qry_str , " ORDER BY ");
                        strcat(qry_str , sort_name);
                }
                else
                {
/*
                        sprintf(return_str," %s a.%s"," ORDER BY ",data[0]);
                        strcat(qry_str,return_str);
*/
                }
	}
        else
	{
/*
                sprintf(return_str," %s a.%s","ORDER BY ",data[0]);

		strcat(qry_str,return_str);
*/
	}
	
/* Call the SQL function */
 	if((status=SQLquery (qry_str, out_list, 8*MEM_SIZE))!=SQL_S_SUCCESS)
	{
		_NFMdebug((fname,"SQL query failed to list items status <0x%.8x>\n",status));
		MEMclose(out_list);
		free(qry_str);
		if (status == SQL_I_NO_ROWS_FOUND )
		{
			ERRload_struct(NFM,NFM_E_NO_ITEMS_FOUND_IN_CAT,"");
			return(NFM_E_NO_ITEMS_FOUND_IN_CAT);
		}
		else
		{
	                ERRload_struct(NFM,NFM_E_SQL_QUERY,"%s","NFMgen_list");
	                return(NFM_E_SQL_QUERY);
		}

	}
	free(qry_str);
	_NFMdebug((fname,"Exit > SUCCESSFUL status <0x%.8x> \n",status));
	return(NFM_S_SUCCESS);
}
