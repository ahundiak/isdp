#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000

long NFMSlogin (in_list)

MEMptr in_list;
{
long   status;
long   id_status;
long   ret_status;

char   id[10];
char   str[20];

MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr wf_list   = NULL;
MEMptr info	 = NULL;

static char *fname = "NFMSlogin";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

status = MEMsplit_copy_buffer (in_list, &attr_list, 0);
if (status != MEM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
    return (status);
    }

status = MEMreset_buffer_no (in_list, 2);
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

status = MEMreset_buffer_no (in_list, 3);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &wf_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&wf_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

    ret_status = NFMlogin (attr_list, data_list, wf_list, &id_status);
    _NFMSdebug(( fname, "NFMlogin <0x%.8x>\n", ret_status));
    MEMclose (&data_list);
    MEMclose (&attr_list);
    MEMclose (&wf_list);

    _NFMSdebug(( fname, "id_status -> <%ld>\n", id_status));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));

    status = NFMSsend_one_buffer( ret_status, info );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));    
        return (status);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	info = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, info );
	_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    sprintf (id, "%ld", id_status);

    strcpy (str, id);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	info = NULL;
        _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, info );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));    
        return (NFM_E_MEM);
        }

    status = NFMSsend_one_buffer( ret_status, info );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));    

    MEMclose (&info);

    return (NFM_S_SUCCESS);
}


long NFMSquery_login_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char app_id[10];
char env_type[10];
char **data_ptr;
MEMptr attr_list  = NULL;
MEMptr data_list  = NULL;
MEMptr value_list = NULL;
MEMptr wf_list    = NULL;

static char *fname = "NFMSquery_login_attributes";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;
strcpy (app_id,  data_ptr[0]);
strcpy (env_type,data_ptr[1]);

_NFMSdebug(( fname, "app_id   : <%s>\n", app_id));
_NFMSdebug(( fname, "env_type : <%s>\n", env_type));

ret_status = NFMquery_login_attributes (app_id, env_type, &attr_list, 
	&data_list, &value_list, &wf_list);
_NFMSdebug(( fname, "Status -> <0x%.8x>\n", ret_status));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&wf_list);
    attr_list = NULL;
    data_list = NULL;
    value_list= NULL;
    wf_list   = NULL;
    }

status = NFMSsend_four_buffers( ret_status, attr_list, data_list,
	wf_list, value_list );
_NFMSdebug(( fname, "NFMSsend_four_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);
MEMclose (&wf_list);

return (ret_status);
}


