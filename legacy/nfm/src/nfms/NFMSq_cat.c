#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

/* 
 Doc: NFMSquery_catalog_attributes
 
 Abstract:
     This function will query for the Catalog attributes.
 */
 
long NFMSquery_catalog_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_catalog_attributes";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog_name : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_catalog_attributes (user_id, data_ptr[1], &attr_list,
                                          &data_list, &value_list);
_NFMSdebug(( fname, "NFMquery_catalog_attributes <0x%.8x>\n", ret_status));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list= NULL;
    }

status = NFMSsend_three_buffers( ret_status, attr_list, data_list, value_list);
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}


/* 
 Doc: NFMSquery_catalog_template
 
 Abstract:
     This function will query for the Catalog template.  This template
     can be modified and/or sent to create a catalog.
 */
 
long NFMSquery_catalog_template (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_catalog_template";

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

ret_status = NFMquery_catalog_template (user_id, &attr_list, &data_list,
                                        &value_list);

_NFMSdebug(( fname, "NFMquery_catalog_template <0x%.8x>\n", ret_status));

if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list= NULL;
    }

status = NFMSsend_three_buffers( ret_status, attr_list, data_list, value_list);
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);

}


/* 
 Doc: NFMSquery_catalog_template_n
 
 Abstract:
     This function will query for the Catalog template.  This template
     can be modified and/or sent to create a catalog.
 */
 
long NFMSquery_catalog_template_n (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_catalog_template";

ret_status = NFMquery_catalog_template_n (&attr_list, &data_list,
			      &value_list, in_list);

_NFMSdebug(( fname, "NFMquery_catalog_template_n <0x%.8x>\n", ret_status));

if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list= NULL;
    }

status = NFMSsend_three_buffers( ret_status, attr_list, data_list, value_list);
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);

}


/* 
 Doc: NFMSquery_catalog_definition
 
 Abstract:
     This function will query for the Catalog attributes only.
 */
 
long NFMSquery_catalog_definition (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSquery_catalog_definition";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID      : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_catalog_definition (user_id, data_ptr[1], &data_list);
_NFMSdebug(( fname, "NFMquery_catalog_definition  <0x%.8x>\n", ret_status));
if( ret_status != NFM_S_SUCCESS )
{
    MEMclose( &data_list );
    data_list = NULL;
}

status = NFMSsend_one_buffer( ret_status, data_list);
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

return( ret_status );
}

/* 
 Doc: NFMSget_ris_attributes
 
 Abstract:
     This function will query for the RIS Catalog attributes only.
 */
 
long NFMSget_ris_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_ris_attributes";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[0]));

ret_status = NFMget_ris_attributes (data_ptr[0], &data_list);
_NFMSdebug(( fname, "NFMget_ris_attributes  <0x%.8x>\n", ret_status));
if( ret_status != NFM_S_SUCCESS )
{
    MEMclose( &data_list );
    data_list = NULL;
}

status = NFMSsend_one_buffer( ret_status, data_list);
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

return( ret_status );
}


