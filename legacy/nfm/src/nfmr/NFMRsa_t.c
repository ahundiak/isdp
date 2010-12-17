#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRget_sa_no
 
 Abstract:
     This function will return a storage area number given a storage area name.
 */
 
long NFMRget_sa_no (user_id, sa_name, sa_num)

long    user_id;       /* i - user id for access */
char    *sa_name;      /* i - the name of the storage area */
char    *sa_num;       /* o - the number of the storage area */

{
MEMptr info = NULL;
char   str[200];
long   status = 0;
long   ret_status = 0;
char   id[20];
char   **data_ptr;
static char *fname = "NFMRget_sa_no";

    _NFMRdebug(( fname, "sa name : <%s>\n", sa_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    sprintf( id, "char(%d)", NFM_SANAME );
    status = MEMwrite_format (info, "n_saname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    strcat (str, sa_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_GET_SA_NO, info);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (ret_status); 
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }

    data_ptr = (char **) info->data_ptr;

    strcpy (sa_num, data_ptr[0]);

    _NFMRdebug(( fname, "sa_num : <%s>\n", sa_num));

    MEMclose (&info);

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRget_sa_name
 
 Abstract:
     This function will return a storage area name given a storage area number.

 */
 
long NFMRget_sa_name (user_id, sa_num, sa_name)

long    user_id;       /* i - user id for access */
char    *sa_num;       /* i - the number of the storage area */
char    *sa_name;      /* o - the name of the storage area */

{
MEMptr info = NULL;
char   str[200];
long   status = 0;
long   ret_status = 0;
char   id[20];
char   **data_ptr;
static char *fname = "NFMRget_sa_name";

    _NFMRdebug(( fname, "sa num : <%s>\n", sa_num));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "n_sanum", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    strcat (str, sa_num);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_GET_SA_NAME, info);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (ret_status); 
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }

    data_ptr = (char **) info->data_ptr;

    strcpy (sa_name, data_ptr[0]);

    _NFMRdebug(( fname, "sa_name : <%s>\n", sa_name));

    MEMclose (&info);

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}



/* 
 Doc: NFMRget_sa_no_info
 
 Abstract:
     This function will return all relative information (node, user, encrypted
     password, path name, device type, machine id, operating system, tcp?,
     xns?, and decnet?) given a storage area number.
     
 */
 
long NFMRget_sa_no_info (user_id, sa_num, node_name, user_name, encr_passwd,
                         path_name, dev_type, mach_id, op_sys, net_tcp,
                         net_xns, net_dec)

long    user_id;       /* i - user id for access */
char    *sa_num;       /* i - the number of the storage area */
char    *node_name;    /* o - the name storage area's node */
char    *user_name;    /* o - the storage area's user name */
char    *encr_passwd;  /* o - the storage area's encrypted password */
char    *path_name;    /* o - the storage area's path name */
char    *dev_type;     /* o - the storage area's device type */
char    *mach_id;      /* o - the storage area's machine ID */
char    *op_sys;       /* o - the storage area's operating system */
char    *net_tcp;      /* o - does the storage area have tcpip? */
char    *net_xns;      /* o - does the storage area have xns? */
char    *net_dec;      /* o - does the storage area have decnet? */

{
MEMptr info = NULL;
char   str[200];
long   status = 0;
long   ret_status = 0;
char   id[20];
char   **data_ptr;
static char *fname = "NFMRget_sa_no_info";

    _NFMRdebug(( fname, "sa num : <%s>\n", sa_num));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "n_sanum", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    strcat (str, sa_num);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_GET_SA_NO_INFO, info);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (ret_status); 
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }

    data_ptr = (char **) info->data_ptr;

    strcpy (node_name, data_ptr[0]);
    _NFMRdebug(( fname, "node_name   : <%s>\n", node_name));

    strcpy (user_name, data_ptr[1]);
    _NFMRdebug(( fname, "user_name   : <%s>\n", user_name));

    strcpy (encr_passwd, data_ptr[2]);
    _NFMRdebug(( fname, "encr_passwd : <%s>\n", encr_passwd));

    strcpy (path_name, data_ptr[3]);
    _NFMRdebug(( fname, "path_name   : <%s>\n", path_name));

    strcpy (dev_type, data_ptr[4]);
    _NFMRdebug(( fname, "dev_type    : <%s>\n", dev_type));

    strcpy (mach_id, data_ptr[5]);
    _NFMRdebug(( fname, "mach_id     : <%s>\n", mach_id));

    strcpy (op_sys, data_ptr[6]);
    _NFMRdebug(( fname, "op_sys      : <%s>\n", op_sys));

    strcpy (net_tcp, data_ptr[7]);
    _NFMRdebug(( fname, "net_tcp     : <%s>\n", net_tcp));

    strcpy (net_xns, data_ptr[8]);
    _NFMRdebug(( fname, "net_xns     : <%s>\n", net_xns));

    strcpy (net_dec, data_ptr[9]);
    _NFMRdebug(( fname, "net_dec     : <%s>\n", net_dec));

    MEMclose (&info);

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}




