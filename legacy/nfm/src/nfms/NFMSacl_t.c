#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000

/* 
 Doc: NFMSget_acl_no
 
 Abstract:
     This function will return an acl number given an acl name.
*/
 
long NFMSget_acl_no (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long acl_no;
char acl_num[20];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_acl_no";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
{
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
}
data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID         : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "acl name : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMget_acl_no (user_id, data_ptr[1], &acl_no);
_NFMSdebug(( fname, "NFMget_acl_no <0x%.8x>\n", ret_status ));

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_aclno", "char(20)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
sprintf (acl_num, "%ld", acl_no);

strcpy (str, acl_num);
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
    
return (ret_status);
}


/* 
 Doc: NFMSget_acl_name
 
 Abstract:
     This function will return an acl name given an acl number.
     
 */
 
long NFMSget_acl_name (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long acl_no;
char acl_name[21];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_acl_name";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID       : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "acl no : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);
acl_no = atol (data_ptr[1]);

ret_status = NFMget_acl_name (user_id, acl_no, acl_name);
_NFMSdebug(( fname, "NFMget_acl_name <0x%.8x>\n", ret_status ));

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_aclname", "char(20)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    MEMclose( &data_list );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
strcpy (str, acl_name);
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

return (ret_status);
}


