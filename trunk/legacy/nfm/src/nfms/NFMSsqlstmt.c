#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMSsqlstmt
 
 Abstract:
     This function will perform the input sql stmt.
 */
 
long NFMSsqlstmt (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;

static char *fname = "NFMSsqlstmt";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (NFM_E_FAILURE);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "sql_string : <%s>\n", data_ptr[0]));

ret_status = NFMsqlstmt ( data_ptr[0] );
_NFMSdebug(( fname, "NFMsqlstmt <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}

