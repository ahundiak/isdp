#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMSload_workflow
 
 Abstract:
     This function load a workflow from a pre-defined workflow data file.
     The file must reside on the NFMserver node.

 */
 
long NFMSload_workflow (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;

static char *fname = "NFMSload_workflow";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID            : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "Application   : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "Workflow File : <%s>\n", data_ptr[2]));

user_id = atol (data_ptr[0]);

ret_status = NFMload_workflow (user_id, data_ptr[1], data_ptr[2]);
_NFMSdebug(( fname, "NFMload_workflow <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}


