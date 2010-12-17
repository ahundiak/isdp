#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

long NFMSreview_state (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
int  state_no;
char **data_ptr;
char state_name[30];
char state_number[30];
char str[500];
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSreview_state";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID            : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name  : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item name     : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item revision : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

/*
ret_status = NFMsdp_get_state (user_id, data_ptr[1], data_ptr[2], data_ptr[3],
                               &state_no);

_NFMSdebug(( fname, "Status -> <0x%.8x>\n", ret_status));

ret_status = NFMget_state_name (3, state_no, state_name);
_NFMSdebug(( fname, "Status -> <0x%.8x>\n", ret_status));

    status = MEMopen (&data_list, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMwrite_format (data_list, "n_stateno", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMwrite_format (data_list, "n_statename", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
        }
    
    sprintf (state_number, "%d", state_no);

    strcpy (str, state_number);
    strcat (str, "\1");
    strcat (str, state_name);
    strcat (str, "\1");
    status = MEMwrite (data_list, str);
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        return (status);
        }
*/
ERRload_struct( NFM, NFM_E_BAD_COMMAND, NULL, NULL );
ret_status = NFM_E_BAD_COMMAND;

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return (ret_status);
}

