#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

/* 
 Doc: NFMSdelete_project
 
 Abstract:
     This function will delete a project.
     
 */
 
long NFMSdelete_project (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long proj_no;
char **data_ptr;

static char *fname = "NFMSdelete_project";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID      : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "project : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMdelete_project (user_id, data_ptr[1], &proj_no);
_NFMSdebug(( fname, "NFMdelete_project <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status);
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}

