#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


long NFMSupdate_state (in_list)

MEMptr in_list;

{
long status     = NFM_S_SUCCESS;
long ret_status = NFM_S_SUCCESS;
long user_id;
int  state_no;
char **data_ptr;
char state_name[30];
char state_number[30];
char str[500];
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSupdate_state";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID            : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name  : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item name     : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item revision : <%s>\n", data_ptr[3]));
_NFMSdebug(( fname, "to state      : <%s>\n", data_ptr[4]));

user_id = atol (data_ptr[0]);
state_no = atoi (data_ptr[4]);

/*
ret_status = NFMsdp_set_to_state (user_id, data_ptr[1], data_ptr[2],
                                  data_ptr[3], state_no);
_NFMSdebug(( fname, "NFMsdp_set_to_state <0x%.8x>\n", ret_status));
*/

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));


if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);

}


long NFMSquery_states (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
int  state_no;
char **data_ptr;
char str[100];
MEMptr data_list = NULL;

static char *fname = "NFMSquery_states";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID            : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name  : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item name     : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item revision : <%s>\n", data_ptr[3]));

strcpy (str, "SELECT n_stateno, n_statename FROM NFMSTATES WHERE ");
strcat (str, "n_workflowno = 3");

ret_status = SQLquery (str, &data_list, 512);
_NFMSdebug(( fname, "SQLquery <0x%.8x>\n", ret_status));

status = NFMSsend_one_buffer( ret_status, data_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &data_list );

if( ret_status != SQL_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);

}


