#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000

/* 
 Doc: NFMSget_state_no
 
 Abstract:
     This function will return a state number given a workflow number and a
     state name.
     
 */
 
long NFMSget_state_no (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long state_no;
long wf_no;
char state_num[20];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_state_no";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "workflow num : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "state name   : <%s>\n", data_ptr[2]));

user_id = atol (data_ptr[0]);
wf_no = atol (data_ptr[1]);

ret_status = NFMget_state_no (user_id, wf_no, data_ptr[2], &state_no);
_NFMSdebug(( fname, "NFMget_state_no <0x%.8x>\n", ret_status ));

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_stateno", "char(20)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
sprintf (state_num, "%ld", state_no);

strcpy (str, state_num);
strcat (str, "\1");
status = MEMwrite (data_list, str);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

status = NFMSsend_one_buffer( ret_status, data_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &data_list );
    
if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}


/* 
 Doc: NFMSget_state_name
 
 Abstract:
     This function will return a state name given a workflow number and a
     state number.

 */
 
long NFMSget_state_name (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long state_no;
long wf_no;
char state_name[41];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_state_name";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "workflow num : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "state num    : <%s>\n", data_ptr[2]));

user_id = atol (data_ptr[0]);
wf_no = atol (data_ptr[1]);
state_no = atol (data_ptr[2]);

ret_status = NFMget_state_name (user_id, wf_no, state_no, state_name);
_NFMSdebug(( fname, "NFMget_state_name <0x%.8x>\n", ret_status ));

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_statename", "char(41)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
strcpy (str, state_name);
strcat (str, "\1");
status = MEMwrite (data_list, str);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

status = NFMSsend_one_buffer( ret_status, data_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose( &data_list );

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}


