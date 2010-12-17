#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

/* 
 Doc: NFMSquery_template_attributes
 
 Abstract:
     This function will query for the template attributes.

 */
 
long NFMSquery_template_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_template_attributes";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID         : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "table type : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "table name : <%s>\n", data_ptr[2]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_template_attributes (user_id, data_ptr[1], data_ptr[2],
				 &attr_list, &data_list, &value_list);
_NFMSdebug(( fname, "NFMquery_template_attributes <0x%.8x>\n", ret_status));
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
 Doc: NFMSquery_template_definition
 
 Abstract:
     This function will query for the template attributes only.

 */
 
long NFMSquery_template_definition (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSquery_template_definition";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID         : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "table type : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "table name : <%s>\n", data_ptr[2]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_template_definition (user_id, data_ptr[1],data_ptr[2],
					   &data_list);

_NFMSdebug(( fname, "NFMquery_template_definition <0x%.8x>\n", ret_status));

status = NFMSsend_one_buffers( ret_status, data_list);
_NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);

}


