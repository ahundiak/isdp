#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMSquery_change_template_attributes
 
 Abstract:
     This function will query for the attributes needed to change a template.

 */
 
long NFMSquery_change_template_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_change_template_attributes";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID      : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "tabtype : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_change_template_attributes (user_id, data_ptr[1], 
                                &attr_list, &data_list, &value_list);
_NFMSdebug(( fname, "NFMquery_change_tmeplate_attr <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}

