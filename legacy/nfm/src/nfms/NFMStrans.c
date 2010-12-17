#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000

/* 
 Doc: NFMSquery_make_transition
 
 Abstract:
     This function will return an item's current state and all of its
     possible to-states.  The first row is the current state.  All remaining
     rows are the possible states that the item can move to.
 */
 
long NFMSquery_make_transition (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr data_list = NULL;
MEMptr attr_list = NULL;

static char *fname = "NFMSquery_make_transition";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

user_id = atol (data_ptr[0]);

ret_status = NFMquery_make_transition (user_id, &attr_list, &data_list);
_NFMSdebug(( fname, "NFMquery_make_transition <0x%.8x>\n", ret_status));

status = NFMSsend_two_buffers( ret_status, attr_list, data_list );
_NFMSdebug(( fname, "NFMsend_two_buffers <0x%.8x>\n", status));

MEMclose( &attr_list );
MEMclose( &data_list );

if (ret_status != NFM_S_SUCCESS)
    return (ret_status);

return (NFM_S_SUCCESS);
}


/* 
 Doc: NFMSmake_transition
 
 Abstract:
     This function will change the state of an item.  The new state has
     "next" in "n_status" of the data_list returned from 
     NFMSquery_make_transition.

 */
 
long NFMSmake_transition (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSmake_transition";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

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

ret_status = NFMmake_transition (user_id, attr_list, data_list);
_NFMSdebug(( fname, "NFMmake_transition <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}


