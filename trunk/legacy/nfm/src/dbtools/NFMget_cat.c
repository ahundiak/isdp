#include "machine.h"
/***************************************************************************
*				NFMget_cat_list			           *
*									   *
*	This function generates a list of catalog names and catalog number *
*	for all the catalogs in cat_list from the table nfmcatalogs.	   *
***************************************************************************/
#include "NFMnfmsacinc.h"


long NFMget_cat_list(cat_list,list)
	MEMptr	cat_list,*list;
{
	char **data ;
	long status,size,count,i;
	char *fname="NFMget_cat_list";
	char *qry_str;
	long SQLquery();

	_NFMdebug((fname,"Entry: MEMptr cat_list <%x>: Out_list <%x>\n",
cat_list,list));

/* Make sure the list is NULL */
	MEMclose(list);

	status = MEMbuild_array(cat_list);
	if(status != MEM_S_SUCCESS)
	{
         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array for cat_list",fname,"status",status);

         _NFMdebug ((fname,"MEM Build Array for cat_list : status = <0x%.8x>\n", status));
         return (NFM_E_MEM_ERR);

	}
	data = (char **)cat_list->data_ptr;
        if(cat_list->rows < 1)
        {
                _NFMdebug((fname,"Number of catalogs  %d < 1\n",cat_list->rows));
                ERRload_struct(NFM,NFM_E_NO_CATALOGS,"%s","Empty list");
                return(NFM_E_NO_CATALOGS);
        }

	size = cat_list->rows * (NFM_CATALOGNAME + 5) + 24 +128 ;
	qry_str = (char *)malloc(size);
	if(qry_str == (char *)0)
	{
         _NFMdebug((fname,"Malloc failed for temporary string. size <%d>:\
status <0x%.8x>\n",size,NFM_E_MALLOC));
        ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
        return(NFM_E_MALLOC);

	}

/* Generate the sql string */
	sprintf(qry_str,"SELECT nfmcatalogs.n_catalogname,nfmcatalogs.\
n_catalogno FROM nfmcatalogs WHERE nfmcatalogs.n_catalogname  in (");
	for ( i=0; i < cat_list->rows  ; i++)
	{
		if(i > 0 ) strcat(qry_str,",");
		count = cat_list->columns * i;
		strcat(qry_str,"'");
		strcat(qry_str,data[count]);
		strcat(qry_str,"'");
	}
	strcat(qry_str,")");
/* Call the SQL function */
	_NFMdebug((fname,"query string <%s>\n",qry_str));
 	status=SQLquery (qry_str, list, MEM_SIZE);
	free(qry_str);
 	if(status!=SQL_S_SUCCESS)
	{
		_NFMdebug((fname,"SQL query failed status <0x%.8x>\n",status));
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			
                	ERRload_struct(NFM,NFM_E_NO_CATALOGS,"%s","NFMget_cat_list");
               		return(NFM_E_NO_CATALOGS);
		}
		else
		{
                	ERRload_struct(NFM,NFM_E_SQL_QUERY,"%s","NFMget_cat_list");
               		return(NFM_E_SQL_QUERY);
		}
	}
	_NFMdebug((fname,"Exit >> SUCCESSFUL: <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}
