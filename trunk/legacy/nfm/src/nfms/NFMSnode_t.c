#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMSget_node_no
 
 Abstract:
     This function will return a node number given a node name.

 */
 
long NFMSget_node_no (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long node_no;
char node_num[20];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_node_no";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID        : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "node name : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMget_node_no (user_id, data_ptr[1], &node_no);

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_nodeno", "char(20)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
sprintf (node_num, "%ld", node_no);

strcpy (str, node_num);
strcat (str, "\1");
status = MEMwrite (data_list, str);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
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
 Doc: NFMSget_node_name
 
 Abstract:
     This function will return a node name given a node number.
 
 */
 
long NFMSget_node_name (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long node_no;
char node_name[31];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_node_name";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID    : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "node no : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);
node_no = atol (data_ptr[1]);

ret_status = NFMget_node_name (user_id, node_no, node_name);

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_nodename", "char(30)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
strcpy (str, node_name);
strcat (str, "\1");
status = MEMwrite (data_list, str);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
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


