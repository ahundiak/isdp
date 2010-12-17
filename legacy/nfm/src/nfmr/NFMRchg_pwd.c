#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRchange_storage_area_passwd
 
 Abstract:
     This function will change the passwd assigned to a storage area.
     
 */

long NFMRchange_storage_area_passwd (user_id, storage_name, old_passwd,
                                     new_passwd)

long    user_id;       /* i - user id for access */
char    *storage_name; /* i - storage area to be modified */
char    *old_passwd;   /* i - old storage area passwd (for verification) */
char    *new_passwd;   /* i - new storage area passwd */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRchange_storage_area_passwd";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));
    _NFMRdebug(( fname, "storage : <%s>\n", storage_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_SANAME );
    status = MEMwrite_format (info, "n_saname", id );
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_PASSWD );
    status = MEMwrite_format (info, "n_oldpasswd", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_PASSWD );
    status = MEMwrite_format (info, "n_newpasswd", id );
    if (status != MEM_S_SUCCESS)
        {
	MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, storage_name);
    strcat (str, "\1");
    strcat (str, old_passwd);
    strcat (str, "\1");
    strcat (str, new_passwd);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_CHANGE_SA_PASSWD, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffers : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRchange_user_passwd
 
 Abstract:
     This function will change the passwd assigned to an I/NFM user.
 */

long NFMRchange_user_passwd (user_id, user_name, old_passwd, new_passwd)

long    user_id;       /* i - user id for access */
char    *user_name;    /* i - I/NFM user to be modified */
char    *old_passwd;   /* i - old user passwd (for verification) */
char    *new_passwd;   /* i - new user passwd */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRchange_user_passwd";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));
    _NFMRdebug(( fname, "user_name : <%s>\n", user_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_USERNAME );
    status = MEMwrite_format (info, "n_username", id );
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_PASSWD );
    status = MEMwrite_format (info, "n_oldpasswd", id );
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_PASSWD );
    status = MEMwrite_format (info, "n_newpasswd", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld", user_id);
    strcat (str, "\1" );
    strcat (str, user_name);
    strcat (str, "\1");
    strcat (str, old_passwd);
    strcat (str, "\1");
    strcat (str, new_passwd);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_CHANGE_USER_PASSWD, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffers : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

long NFMRchange_working_area_passwd (st_name, old_passwd, new_passwd)
     char    *st_name;                  /* I - storagearea area name */
     char    *old_passwd ;              /* I - (decrypted) old passwd */
     char    *new_passwd;               /* I - (decrypted) new passwd */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRchange_working_area_passwd";

    _NFMRdebug(( fname, "st_name   : <%s>\n", st_name));
    _NFMRdebug(( fname, "old : <%s>\n", old_passwd));
    _NFMRdebug(( fname, "new : <%s>\n", new_passwd));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_SANAME );
    status = MEMwrite_format (info, "st_name", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_PASSWD );
    status = MEMwrite_format (info, "oldpasswd", id );
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_PASSWD );
    status = MEMwrite_format (info, "newpasswd", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    strcpy (str, st_name);
    strcat (str, "\1");
    strcat (str, old_passwd);
    strcat (str, "\1");
    strcat (str, new_passwd);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_CHANGE_WA_PASSWD, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffers : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}
