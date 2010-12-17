#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

/* 
 Doc: NFMSquery_addto_loc_attributes
 
 Abstract:
     This function will query for the LOC (List of Catalog) attributes.
     If the "catalog_name" argument is "", the default LOC values are 
     returned in the data_list.  Otherwise the existing values in the
     database for "catalog_name" are returned.
     
 */
 
long NFMSquery_addto_loc_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char loc_name[20];
char str[200];
char **data_ptr;
MEMptr loc_list  = NULL;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_addto_loc_attributes";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID : <%s>\n", data_ptr[0]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_addto_loc_attributes (user_id, loc_name, &attr_list,
                                            &data_list, &value_list);
_NFMSdebug(( fname, "NFMquery_addto_loc_attributes <0x%.8x>\n", ret_status ));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list= NULL;
    }

else
{
    status = MEMopen (&loc_list, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
        {
	MEMclose (&loc_list);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (loc_list, "n_locname", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
	MEMclose (&loc_list);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        _NFMSdebug(( fname,"MEMwrite_format : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    strcpy (str, loc_name);
    strcat (str, "\1");
    status = MEMwrite (loc_list, str);
    if (status != MEM_S_SUCCESS)
        {
	MEMclose (&loc_list);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
}

status = NFMSsend_four_buffers( ret_status, loc_list, attr_list, data_list, 
				value_list);
_NFMSdebug(( fname, "NFMSsend_four_buffers <0x%.8x>\n", status ));

MEMclose (&loc_list);
MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}


/* 
 Doc: NFMSquery_loc_definition
 
 Abstract:
     This function will query for the LOC (List of Catalog) attributes
     only.
 */
 
long NFMSquery_loc_definition (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr loc_list = NULL;

static char *fname = "NFMSquery_loc_definition";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "loc_name     : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_loc_definition (user_id, data_ptr[1], loc_list);
_NFMSdebug(( fname, "NFMquery_loc_definition : <0x%.8x>\n", ret_status));
if( ret_status != NFM_S_SUCCESS )
{
    MEMclose (&loc_list);
    loc_list = NULL;
}
status = NFMSsend_one_buffer( ret_status, loc_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &loc_list );

return (ret_status);

}

