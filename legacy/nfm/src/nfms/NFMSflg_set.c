#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

long NFMSflag_set_archive (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;

static char *fname = "NFMSflag_set_archive";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "set name     : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "set rev      : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMflag_set_archive (user_id, data_ptr[1], data_ptr[2], 
				  data_ptr[3]);

_NFMSdebug(( fname, "NFMflag_set_archive <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}


long NFMSflag_set_backup (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;

static char *fname = "NFMSflag_set_backup";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "set name     : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "set rev      : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMflag_set_backup (user_id, data_ptr[1], data_ptr[2], 
				data_ptr[3]);
_NFMSdebug(( fname, "NFMflag_set_backup <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

if( status != NFM_S_SUCCESS )
    return( status);

return (NFM_S_SUCCESS);

}


long NFMSflag_set_restore (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;

static char *fname = "NFMSflag_set_restore";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "set name     : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "set rev      : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMflag_set_restore (user_id, data_ptr[1], data_ptr[2], 
				data_ptr[3]);
_NFMSdebug(( fname, "NFMflag_set_restore <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}



