#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000

long NFMSprepare_item_checkin (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
static char *fname = "NFMSprepare_item_checkin";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item name    : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item rev     : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMprepare_item_checkin (user_id, data_ptr[1], data_ptr[2],
                                      data_ptr[3], &attr_list, &data_list);
_NFMSdebug(( fname, "NFMprepare_item_checkin <0x%.8x>\n", ret_status));

status = NFMSsend_two_buffers( ret_status, attr_list, data_list );
_NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

if (ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}


long NFMScancel_item_checkin (in_list)

MEMptr in_list;


{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
static char *fname = "NFMScancel_item_checkin";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));

user_id = atol (data_ptr[0]);

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &attr_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 3);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &data_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&data_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

ret_status = NFMcancel_item_checkin (user_id, attr_list, data_list);
_NFMSdebug(( fname, "NFMcancel_item_checkin <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}


long NFMScomplete_item_checkin (in_list)

MEMptr in_list;

{
long ret_status;
long status;
long user_id;
char **data_ptr;
char  sa_name[15];
char  node[31];
char  user_name[15];
char  passwd[50];
char  path[50];
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
static char *fname = "NFMScomplete_item_checkin";

_NFMSdebug(( fname, "%s\n", "Entering ..." ));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;
user_id = atol (data_ptr[0]);
strcpy(sa_name,data_ptr[1]);
strcpy(node,data_ptr[2]);
strcpy(user_name,data_ptr[3]);
strcpy(passwd,data_ptr[4]);
strcpy(path,data_ptr[5]);

_NFMSdebug(( fname, "ID           : <%s>\n", user_id));
_NFMSdebug(( fname, "storage name : <%s>\n", sa_name));
_NFMSdebug(( fname, "tmp node     : <%s>\n", node));
_NFMSdebug(( fname, "tmp user     : <%s>\n", user_name));
_NFMSdebug(( fname, "tmp passwd   : <%s>\n", passwd));
_NFMSdebug(( fname, "tmp path     : <%s>\n", path));

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &attr_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 3);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &data_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&data_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = NFMcomplete_item_checkin (user_id, sa_name, node,user_name,
				   passwd,path,attr_list, data_list);
_NFMSdebug(( fname, "NFMcomplete_item_checkin <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}
