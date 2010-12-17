#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

long NFMSlog_in (in_list)

MEMptr in_list;
{
long   status;
long   ret_status;
char   **data_ptr;
static char *fname = "NFMSlog_in";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Username    <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Environment <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Application <%s>\n", data_ptr[3] ));

    ret_status = NFMlog_in( data_ptr[0], data_ptr[1], data_ptr[2],
			data_ptr[3] );
    _NFMSdebug(( fname, "NFMlog_in <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    return (ret_status);
}
