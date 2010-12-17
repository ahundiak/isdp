#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000

/* 
 Doc: NFMRset_to_state
 
 Abstract:
     This function will set an item to the appropriate "to_state" after
     successful completion of a command.

 */
 
long NFMSset_to_state (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MSGptr app_ptr;

static char *fname = "NFMSset_to_state";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID            : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "application   : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "error number  : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "error message : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);
app_ptr.error_no = atol (data_ptr[2]);
strncpy (app_ptr.error_msg, data_ptr[3], sizeof (app_ptr.error_msg) - 1);

ret_status = WFset_to_state (user_id, data_ptr[1], app_ptr);
_NFMSdebug(( fname, "WFset_to_state <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));
 
if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}

 
long NFMSset_wf_state (in_list)

MEMptr in_list;

{
long status;
long ret_status;

char **data_ptr;

static char *fname = "NFMSset_wf_state";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "application   : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "error number  : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "error message : <%s>\n", data_ptr[2]));

ret_status = NFMset_wf_state ( data_ptr[0], atol(data_ptr[1]), data_ptr[2] );
_NFMSdebug(( fname, "NFMset_wf_state <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));
 
if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}

