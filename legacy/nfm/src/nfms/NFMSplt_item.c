#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

long NFMSplot_item (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;

static char *fname = "NFMSplot_item";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "catalog name  : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "item name     : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item revision : <%s>\n", data_ptr[2]));

ret_status = NFMplot_item (data_ptr[0], data_ptr[1], data_ptr[2] );

_NFMSdebug(( fname, "NFMplot_item <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);

}
