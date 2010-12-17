#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMSsqlquery
 
 Abstract:
     This function will perform the input sql query.

 */
 
long NFMSsqlquery (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSsqlquery";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "sql_string  : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "buffer_size : <%s>\n", data_ptr[1]));

ret_status = NFMsqlquery ( data_ptr[0], data_ptr[1], &data_list);
_NFMSdebug(( fname, "NFMsqlquery <0x%.8x>\n", ret_status ));

status = NFMSsend_one_buffer( ret_status, data_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &data_list );

if( ret_status != NFM_S_SUCCESS )
    return (ret_status);

return (NFM_S_SUCCESS);
}


/* 
 Doc: NFMSsqlquery_cursor
 
 Abstract:
     This function will perform the input sql query using a specific
cursor.

 */
 
long NFMSsqlquery_cursor (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSsqlquery_cursor";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

data_ptr = (char **) in_list->data_ptr;

    _NFMSdebug(( fname, "sql_string  : <%s>\n", data_ptr[0]));
    _NFMSdebug(( fname, "buffer_size : <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "rows        : <%s>\n", data_ptr[2]));
    _NFMSdebug(( fname, "cursor      : <%s>\n", data_ptr[3]));

    ret_status = NFMsqlquery_cursor ( data_ptr[0], data_ptr[1], 
		atol(data_ptr[2]), atoi(data_ptr[3]), &data_list);
    _NFMSdebug(( fname, "NFMsqlquery_cursor <0x%.8x>\n", ret_status ));

status = NFMSsend_one_buffer( ret_status, data_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &data_list );

if( ret_status != NFM_S_SUCCESS )
    return (ret_status);

return (NFM_S_SUCCESS);
}

