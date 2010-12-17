#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRprepare_item_checkin
 
 Abstract:
     This function will prepare an item to be checked in.  The returned buffers
     are used for NFMRcomplete_item_checkin.

 */
 
long NFMRprepare_item_checkin (user_id, catalog_name, item_name, item_rev,
                               attr_list, data_list)

long    user_id;       /* i - user id for access */
char    *catalog_name; /* i - catalog of item */
char    *item_name;    /* i - item to checkin */
char    *item_rev;     /* i - item revision */
MEMptr  *attr_list;    /* o - list of attributes */
MEMptr  *data_list;    /* o - list of data */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];

static char *fname = "NFMRprepare_item_checkin";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));
    _NFMRdebug(( fname, "catalog : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "item    : <%s>\n", item_name));
    _NFMRdebug(( fname, "rev     : <%s>\n", item_rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    sprintf( id, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "n_catalogname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format (info, "n_itemname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (info, "n_itemrev", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, catalog_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_rev);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_PREPARE_ITEM_CHECKIN, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status, 
		attr_list, data_list);
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return (NFM_S_SUCCESS); 
}


/* 
 Doc: NFMRcancel_item_checkin
 
 Abstract:
     This function will cancel the preparation of an item to be checked in.
     It must be called if a checkin has been initiated
     (NFMRprepare_item_checkin has been called) but needs to be cancelled.
     The input buffers are from NFMRprepare_item_checkin.
     
 */
 
long NFMRcancel_item_checkin (user_id, attr_list, data_list)

long    user_id;       /* i - user id for access */
MEMptr  attr_list;     /* i - list of attributes */
MEMptr  data_list;     /* i - list of data */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRcancel_item_checkin";

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld", user_id);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMappend (attr_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMappend (data_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_CANCEL_ITEM_CHECKIN, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    ERRload_struct( NFMR, NFM_E_CANCEL, NULL, NULL );

    return( NFM_S_SUCCESS );
}


/* 
 Doc: NFMRcomplete_item_checkin
 
 Abstract:
     This function will complete the checkin of an item.  The input buffers are
     from NFMRprepare_item_checkin.

 */
 
long NFMRcomplete_item_checkin (user_id, storage_name, tmp_node, tmp_user,
                                tmp_passwd, tmp_path, attr_list, data_list)

long    user_id;       /* i - user id for access */
char    *storage_name; /* i - storage location */
char    *tmp_node;     /* i - node name of temp. storage location */
char    *tmp_user;     /* i - user login of temp. storage location */
char    *tmp_passwd;   /* i - password of temp. storage location */
char    *tmp_path;     /* i - pathname of temp. storage location */
MEMptr  attr_list;     /* i - list of attributes */
MEMptr  data_list;     /* i - list of data */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];

static char *fname = "NFMRcomplete_item_checkin";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));
    _NFMRdebug(( fname, "storage  : <%s>\n", storage_name));
    _NFMRdebug(( fname, "tmp node : <%s>\n", tmp_node));
    _NFMRdebug(( fname, "tmp user : <%s>\n", tmp_user));
    _NFMRdebug(( fname, "tmp pass : <%s>\n", tmp_passwd));
    _NFMRdebug(( fname, "tmp path : <%s>\n", tmp_path));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }
    
    sprintf( id, "char(%d)", NFM_SANAME );
    status = MEMwrite_format (info, "n_saname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }
    
    sprintf( id, "char(%d)", NFM_NODENAME );
    status = MEMwrite_format (info, "n_tmpnode", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }
    
    sprintf( id, "char(%d)", NFM_USERNAME );
    status = MEMwrite_format (info, "n_tmpuser", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    sprintf( id, "char(%d)", NFM_PASSWD );    
    status = MEMwrite_format (info, "n_tmppasswd", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    sprintf( id, "char(%d)", NFM_PATHNAME );    
    status = MEMwrite_format (info, "n_tmppath", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }
    
    sprintf (str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, storage_name);
    strcat (str, "\1");
    strcat (str, tmp_node);
    strcat (str, "\1");
    strcat (str, tmp_user);
    strcat (str, "\1");
    strcat (str, tmp_passwd);
    strcat (str, "\1");
    strcat (str, tmp_path);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMappend (attr_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMappend (data_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_COMPLETE_ITEM_CHECKIN, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}


