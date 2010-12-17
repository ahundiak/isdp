#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


long NFMSdelete_copied_files (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
MEMptr data_list = NULL;
char *wa_ptr;

static char *fname = "NFMSdelete_copied_files";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

	wa_ptr=data_ptr[0];
_NFMSdebug(( fname, "working area : <%s>\n", wa_ptr));

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &data_list, 1);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&data_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
        }
    }

ret_status = NFMdelete_copied_files (wa_ptr, data_list );
_NFMSdebug(( fname, "NFMdelete_copied_files <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose( &data_list );

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}


