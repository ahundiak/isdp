#include "machine.h"
#include "MEMstruct.h"
#include "NETstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000
 

long NFMSget_bulk_data (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long sa_no;
long mode;
char str[256];
char node[31], user[15], passwd[51], path[81];
char device[3], machid[11], opsys[11], tcp[2], xns[2], dec[2];
char **data_ptr;
MEMptr info = NULL;
MEMptr out_list = NULL;

static char *fname = "NFMSget_bulk_data";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
    MEMclose( &info );
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID		  : <%s>\n", data_ptr[0] ));
_NFMSdebug(( fname, "storage      : <%s>\n", data_ptr[1] ));
_NFMSdebug(( fname, "dir Only/All : <%s>\n", data_ptr[2] ));

user_id = atol (data_ptr[0]);

ret_status = NFMget_sa_no (user_id, data_ptr[1], &sa_no);
if (ret_status != NFM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "NFMget_sa_no : <0x%.8x>\n", ret_status));
    status = NFMSsend_one_buffer( ret_status, info );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
    return (ret_status);
    }

_NFMSdebug(( fname, "Storage No : <%d>\n", sa_no));

ret_status = NFMget_sa_no_info (user_id, sa_no, node, user, passwd, path,
                            device, machid, opsys, tcp, xns, dec);
if (ret_status != NFM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "NFMget_sa_no_info : <0x%.8x>\n", status));
    status = NFMSsend_one_buffer( ret_status, info );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
    return (ret_status);
    }


status = MEMopen (&info,  BUFFER_SIZE);
if (status != MEM_S_SUCCESS)
    {
    MEMclose (&info);
    _NFMSdebug(( fname,  "MEMopen : <0x%.8x>\n",  status));
    ERRload_struct( NFM,  NFM_E_MEM,  NULL,  NULL );
    return( NFM_E_MEM );
    }

status = MEMwrite_format (info,  "n_mode",  "char(1)");
if (status != MEM_S_SUCCESS)
    {
    MEMclose (&info);
    _NFMSdebug(( fname,  "MEMwrite_format : <0x%.8x>\n",  status));
    ERRload_struct( NFM,  NFM_E_MEM,  NULL,  NULL );
    return( NFM_E_MEM );
    }

status = MEMwrite_format (info,  "n_pathname",  "char(80)");
if (status != MEM_S_SUCCESS)
    {
    MEMclose (&info);
    _NFMSdebug(( fname,  "MEMwrite_format : <0x%.8x>\n",  status));
    ERRload_struct( NFM,  NFM_E_MEM,  NULL,  NULL );
    return( NFM_E_MEM );
    }

status = MEMwrite_format (info,  "n_username",  "char(15)");
if (status != MEM_S_SUCCESS)
    {
    MEMclose (&info);
    _NFMSdebug(( fname,  "MEMwrite_format : <0x%.8x>\n",  status));
    ERRload_struct( NFM,  NFM_E_MEM,  NULL,  NULL );
    return( NFM_E_MEM );
    }

status = MEMwrite_format (info,  "n_devicetype",  "char(2)");
if (status != MEM_S_SUCCESS)
    {
    MEMclose (&info);
    _NFMSdebug(( fname,  "MEMwrite_format : <0x%.8x>\n",  status));
    ERRload_struct( NFM,  NFM_E_MEM,  NULL,  NULL );
    return( NFM_E_MEM );
    }

status = MEMwrite_format (info,  "n_machid",  "char(10)");
if (status != MEM_S_SUCCESS)
    {
    MEMclose (&info);
    _NFMSdebug(( fname,  "MEMwrite_format : <0x%.8x>\n",  status));
    ERRload_struct( NFM,  NFM_E_MEM,  NULL,  NULL );
    return( NFM_E_MEM );
    }

status = MEMwrite_format (info,  "n_opsys",  "char(10)");
if (status != MEM_S_SUCCESS)
    {
    MEMclose (&info);
    _NFMSdebug(( fname,  "MEMwrite_format : <0x%.8x>\n",  status));
    ERRload_struct( NFM,  NFM_E_MEM,  NULL,  NULL );
    return( NFM_E_MEM );
    }

strcpy (str,  data_ptr[2]);
strcat (str,  "\1");
strcat (str,  path);
strcat (str,  "\1");
strcat (str,  user);
strcat (str,  "\1");
strcat (str,  device);
strcat (str,  "\1");
strcat (str,  machid);
strcat (str,  "\1");
strcat (str,  opsys);
strcat (str,  "\1");

status = MEMwrite (info,  str);
if (status != MEM_S_SUCCESS)
   {
    MEMclose (&info);
    _NFMSdebug(( fname,  "MEMwrite : <0x%.8x>\n",  status));
    ERRload_struct( NFM,  NFM_E_MEM,  NULL,  NULL );
    return( NFM_E_MEM );
    }

     if (strncmp (tcp,  "Y",  1) == 0)
         mode = NET_TCP;
else if (strncmp (xns,  "Y",  1) == 0)
         mode = NET_XNS;
else
         mode = 0;

ret_status = NFMcl_get_bulk_data (node, user, passwd, mode, info, &out_list);


status = NFMSsend_one_buffer( ret_status, out_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

MEMclose (&info);

if (ret_status != NFM_S_SUCCESS)
    return (ret_status);

return (ret_status);
}
