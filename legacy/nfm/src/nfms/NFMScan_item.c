#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "NFMapi.h"
#include "ERR.h"

long NFMScancel_co_item (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
long   user_id;
char   **data_ptr;
MEMptr data_list = NULL;
static char *fname =  "NFMScancel_co_item";

_NFMSdebug(( fname, "%s\n", "Entering ..." ));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));

user_id = atol (data_ptr[0]);

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &data_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&data_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    }

ret_status = NFMcancel_co_item (user_id, data_list);
_NFMSdebug(( fname, "NFMcancel_co_item <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSend_error_buffers <0x%.8x>\n", status ));

MEMclose( &data_list );

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);

}

long NFMScancel_check_out_item (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
struct NFMwf_info wf_info;
struct NFMoperation operation;

static char *fname = "NFMScancel_check_out_item";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog      <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Catalog No   <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Item         <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Revision     <%s>\n", data_ptr[3] ));
    _NFMSdebug(( fname, "Transfer     <%s>\n", data_ptr[4] ));
    _NFMSdebug(( fname, "Delete       <%s>\n", data_ptr[5] ));
    _NFMSdebug(( fname, "Purge        <%s>\n", data_ptr[6] ));
    _NFMSdebug(( fname, "Workflow     <%s>\n", data_ptr[7] ));

    operation.transfer = atoi( data_ptr[4] );
    operation.delete   = atoi( data_ptr[5] );
    operation.purge    = atoi( data_ptr[6] );

    wf_info.workflow = atoi(data_ptr[7]);
    if( wf_info.workflow == NFM_WORKFLOW )
    {
	_NFMSdebug(( fname, "Command       <%s>\n", data_ptr[8] ));
	_NFMSdebug(( fname, "Workflow Name <%s>\n", data_ptr[9] ));
	_NFMSdebug(( fname, "Project Name  <%s>\n", data_ptr[10] ));
	_NFMSdebug(( fname, "Application   <%s>\n", data_ptr[11] ));
	strncpy( wf_info.command, data_ptr[8], NFM_COMMANDNAME );
	strncpy( wf_info.workflow_name, data_ptr[9], NFM_WORKFLOWNAME );
	strncpy( wf_info.project_name, data_ptr[10], NFM_PROJECTNAME );
	strncpy( wf_info.app_name, data_ptr[11], NFM_APPLICATION );	
    }

    ret_status = NFMcancel_check_out_item( data_ptr[0], atol(data_ptr[1]), 
		data_ptr[2], data_ptr[3], wf_info, operation );
    _NFMSdebug(( fname, "NFMcancel_check_out_item <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status);

    return (NFM_S_SUCCESS);
}
