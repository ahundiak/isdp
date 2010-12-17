#include "machine.h"

/***************************************************************************
*				NFMblocksac_list_m_crsr			   *
*	This function generates a listing of attributes specified in the   *
*	attribute list from the catalog specified by the catalog name      *
*	The row size governs the number of rows returned by the query.	   *
*	This function supports block listing. This means that only a block *
*	of data ( determined by row size) is returned on each call. The    *
*	SQL cursor is left open for future use. Subsequent calls will      *
*	return data starting at the current cursor position.		   *
*									   *
*	THe cursor is closed when					   *
*	1.	End of data is reached. In this case NFM_I_NO_MORE_BUFFERS *
*		is returned.						   *
*	2.	If row size is set to 0. The cursor is closed and no data  *
*		will be returned. This function is used in conjunction     *
*		NFMblockmultiple_catalog_search. The query will be         *
*		generated even if row size is 0				   *
*									   *
*	On successful completion NFM_S_SUCCESS is returned.		   *
*									   *
*	This function is used for multiple catalog search		   *
*									   *
***************************************************************************/
#include "NFMnfmsacinc.h"
#include "NFMapi.h"
#include "SQLproto.h"


long NFMblocksac_list_m_crsr(attr_list,out_list,cat_name,cat_no,search_name , sort_name,query_flag,row_size, cursor_id)
	MEMptr	attr_list, *out_list;
	char *search_name , *sort_name;
	char *cat_name,*cat_no;
	long query_flag,row_size,cursor_id;
{
	long status = 0,i=0,m,n,size = 0;
	long length=0,count;
	char *qry_str,return_str[NFM_FILENAME],format_str[100];
	char **data,**format;
	char *fname="NFMblocksac_list_m_crsr";

	_NFMdebug((fname,"Entry: attr_list <%x>: out_list <%x>: catalog name <%s>\
Catalog no <%s>: search_name <%s>: sort_name <%s> query_flag <%d> row_size <%d>\
 cursor_id <%d> \n",
attr_list,out_list,cat_name, cat_no,search_name,sort_name,query_flag,row_size,cursor_id));


/* check if the list pointer is NULL */
	if(out_list == (MEMptr *)0)
	{
		_NFMdebug((fname,"Output list address pointer is <%x>\n",out_list));
                ERRload_struct(NFM,NFM_E_NULL_OUTPUT_MEMPTR,"%s","Out buffer ptr");
                return(NFM_E_NULL_OUTPUT_MEMPTR);

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
		_NFMdebug((fname,"Attribute list is empty:Number of rows is %d < 1\n", m));
		ERRload_struct(NFM,NFM_E_ATTR_LIST_EMPTY,"");
                return(NFM_E_ATTR_LIST_EMPTY);
        }

          if (! strncmp (format [0], "char",     4))
                  sscanf (format [0], "%5s%d", return_str, &length);
          else if (! strncmp (format [0], "integer",  7)) length = 15;
          else if (! strncmp (format [0], "smallint", 8)) length = 15;
          else if (! strncmp (format [0], "double",   6)) length = 50;
          else if (! strncmp (format [0], "real",     4)) length = 50;
          else if (! strncmp (format [0], "timestamp",9)) length = 20;
	if(length <= 0) length = NFM_ITEMNAME;
		
/*	Check if the SQL string is long enough */
	size = 10 + (strlen(cat_name)+5 + length) * m ;
        size = size + NFM_CATALOGNAME*3+40;
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
/* THIS DOES NOT WORK IN RIS 4.2
	sprintf(format_str,"SELECT '%%-%ds' ",NFM_CATALOGNAME-1);
	sprintf(qry_str,format_str,cat_name);
*/
       if(query_flag > 0 )
        strcpy(qry_str,"SELECT DISTINCT NFMCATALOGS.n_catalogname ");
       else
        strcpy(qry_str,"SELECT NFMCATALOGS.n_catalogname ");

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
	strcat(qry_str," , nfmstates, nfmacls, NFMCATALOGS ");
	sprintf(return_str , " %s a.%s " ,"WHERE nfmstates.n_stateno = ", "n_stateno");
	strcat(qry_str , return_str);
	sprintf(return_str," %s a.%s ","AND nfmacls.n_aclno =","n_aclno");
	strcat(qry_str , return_str);
/* REQUIRED */
	sprintf(return_str," %s '%s' ","AND nfmcatalogs.n_catalogname =",cat_name);
	strcat(qry_str , return_str);
/* */

	if (search_name != NULL )
	{
		if(strlen(search_name))
		{
			strcat(qry_str , " AND ");
			strcat(qry_str , search_name);
		}
	}

	if (query_flag > 0)
		strcat(qry_str , " AND a.n_itemno = f_a.n_itemnum");

	if (sort_name != NULL  )
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
                sprintf(return_str," %s a.%s"," ORDER BY ",data[0]);

		strcat(qry_str,return_str);
*/
	}
	
/* Call the SQL function */
/*
 	if((status=status = SQLquery (qry_str, out_list, MEM_SIZE))!=SQL_S_SUCCESS)
*/

	     switch(cursor_id)
	     {
		case 1:
		status = SQLquery_cursor11 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 2:
		status = SQLquery_cursor12 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 3:
		status = SQLquery_cursor13 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 4:
		status = SQLquery_cursor14 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 5:
		status = SQLquery_cursor15 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 6:
		status = SQLquery_cursor16 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 7:
		status = SQLquery_cursor17 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 8:
		status = SQLquery_cursor18 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 9:
		status = SQLquery_cursor19 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 10:
		status = SQLquery_cursor20 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 11:
		status = SQLquery_cursor21 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 12:
		status = SQLquery_cursor22 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 13:
		status = SQLquery_cursor23 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 14:
		status = SQLquery_cursor24 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 15:
		status = SQLquery_cursor25 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 16:
		status = SQLquery_cursor26 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 17:
		status = SQLquery_cursor27 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 18:
		status = SQLquery_cursor28 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 19:
		status = SQLquery_cursor29 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		case 20:
		status = SQLquery_cursor30 (qry_str, out_list, 32*MEM_SIZE,row_size);
		break;
		default:

		status = NFM_E_SQL_QUERY;
	     }
	free(qry_str);
	if(status != SQL_S_SUCCESS )
	{
		_NFMdebug((fname,"SQL query  list items status <0x%.8x>\n",status));
		if (status == SQL_I_NO_ROWS_FOUND )
		{
			ERRload_struct(NFM,NFM_E_NO_ITEMS_FOUND_IN_CAT,"");
			return(NFM_E_NO_ITEMS_FOUND_IN_CAT);
		}
		else if (status == SQL_I_NO_MORE_DATA )
		{
/*
			ERRload_struct(NFM,NFM_I_NO_MORE_BUFFERS,"");
*/
			return(NFM_I_NO_MORE_BUFFERS);
		}
		else
		{
	                ERRload_struct(NFM,NFM_E_SQL_QUERY,"");
	                return(NFM_E_SQL_QUERY);
		}

	}
	_NFMdebug((fname,"Exit > SUCCESSFUL status <0x%.8x> \n",status));
	return(NFM_S_SUCCESS);
}
