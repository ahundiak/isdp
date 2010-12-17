#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "NFMschema.h"
#include "ERR.h"

long NFMSadd_default_working_area (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;
char wa[NFM_SANAME+1];
char str[100];
MEMptr node_info = NULL;
MEMptr sa_info = NULL;
MEMptr ret_info = NULL;

static char *fname = "NFMSadd_default_working_area";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &node_info, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_info);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    }

status = MEMreset_buffer_no (in_list, 3);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &sa_info, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&node_info);
	MEMclose (&sa_info);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    }

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "node : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "user : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "path : <%s>\n", data_ptr[2]));

ret_status = NFMadd_default_working_area (data_ptr[0], data_ptr[1],data_ptr[2],				      wa, node_info, sa_info);
    
_NFMSdebug(( fname, "NFMadd_default_working_area <0x%.8x>\n", ret_status));
if( ret_status != NFM_S_SUCCESS )
{
    status = NFMSsend_one_buffer( ret_status, ret_info );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
    return( ret_status );
}

status = MEMopen (&ret_info, MEM_SIZE);
if (status != MEM_S_SUCCESS)
{
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
}

sprintf( str, "char(%d)", NFM_SANAME );
status = MEMwrite_format (ret_info, "path", str);
if (status != MEM_S_SUCCESS)
{
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
}
    
sprintf (str, "%s\1", wa );
status = MEMwrite (ret_info, str);
if (status != MEM_S_SUCCESS)
    {
    _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

status = NFMSsend_one_buffer( ret_status, ret_info );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &ret_info );

return( ret_status );

}

