#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

/* 
 Doc: NFMSquery_change_catalog_attributes
 
 Abstract:
     This function will query for the attributes needed to change a Catalog.
 */
 
long NFMSquery_change_catalog_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_change_catalog_attributes";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID      : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_change_catalog_information (user_id, data_ptr[1], 
                        &attr_list, &data_list, &value_list);
_NFMSdebug(( fname, "NFMquery_change_catalog_information\n", ret_status ));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list = NULL;
    }

status = NFMSsend_three_buffers( ret_status, attr_list, data_list, value_list);
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}


/* 
 Doc: NFMSquery_changeto_loc_attributes
 
 Abstract:
     This function will query for the attributes needed to change a Catalog
     entry in the LOC.

 */
 
long NFMSquery_changeto_loc_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char loc_name[21];
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_changeto_loc_attributes";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID      : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_changeto_loc_attributes (user_id, loc_name, data_ptr[1], 
                        &attr_list, &data_list, &value_list);
_NFMSdebug(( fname, "NFMquery_changeto_loc_attributes <0x%.8x>\n",ret_status));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list = NULL;
    }

status = NFMSsend_three_buffers( ret_status, attr_list, data_list, value_list);
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}



