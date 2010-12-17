#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMSget_sa_no
 
 Abstract:
     This function will return a storage area number given a storage area name.
     
 */
 
long NFMSget_sa_no (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long sa_no;
char sa_num[20];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_sa_no";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID      : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "sa name : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMget_sa_no (user_id, data_ptr[1], &sa_no);

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_sano", "char(20)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
sprintf (sa_num, "%ld", sa_no);

strcpy (str, sa_num);
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
 Doc: NFMSget_sa_name
 
 Abstract:
     This function will return a storage area name given a storage area number.
 */
 
long NFMSget_sa_name (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long sa_no;
char sa_name[20];
char str[100];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_sa_name";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID    : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "sa no : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);
sa_no = atol (data_ptr[1]);

ret_status = NFMget_sa_name (user_id, sa_no, sa_name);

status = MEMopen (&data_list, BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_saname", "char(14)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
strcpy (str, sa_name);
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
 Doc: NFMSget_sa_no_info
 
 Abstract:
     This function will return all relative information (node, user, encrypted
     password, path name, device type, machine id, operating system, tcp?,
     xns?, and decnet?) given a storage area number.

 */
 
long NFMSget_sa_no_info (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long sa_no;
char node_name[31];
char user_name[15];
char encr_passwd[26];
char path_name[51];
char dev_type[3];
char mach_id[11];
char op_sys[11];
char net_tcp[2];
char net_xns[2];
char net_dec[2];
char str[250];
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSget_sa_no_info";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID    : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "sa no : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);
sa_no = atol (data_ptr[1]);

ret_status = NFMget_sa_no_info (user_id, sa_no, node_name, user_name,
                                encr_passwd, path_name, dev_type, mach_id,
                                op_sys, net_tcp, net_xns, net_dec);

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
    
status = MEMwrite_format (data_list, "n_username", "char(14)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_encrpasswd", "char(25)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_pathname", "char(50)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_devicetype", "char(3)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_machid", "char(10)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_opsys", "char(10)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_tcpip", "char(1)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_xns", "char(1)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
status = MEMwrite_format (data_list, "n_decnet", "char(1)");
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }
    
strcpy (str, node_name);
strcat (str, "\1");
strcat (str, user_name);
strcat (str, "\1");
strcat (str, encr_passwd);
strcat (str, "\1");
strcat (str, path_name);
strcat (str, "\1");
strcat (str, dev_type);
strcat (str, "\1");
strcat (str, mach_id);
strcat (str, "\1");
strcat (str, op_sys);
strcat (str, "\1");
strcat (str, net_tcp);
strcat (str, "\1");
strcat (str, net_xns);
strcat (str, "\1");
strcat (str, net_dec);
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



