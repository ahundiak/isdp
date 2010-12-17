#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRget_item_no
 
 Abstract:
     This function will return an item number given a catalog name, item name,
     and item revision.
     
 */
 
long NFMRget_item_no (user_id, cat_name, item_name, item_rev, item_num)

long    user_id;       /* i - user id for access */
char    *cat_name;     /* i - the catalog of the item */
char    *item_name;    /* i - the name of the item */
char    *item_rev;     /* i - the revision of the item */
char    *item_num;     /* o - the number of the item */

{
MEMptr info = NULL;
char   str[200];
long   status = 0;
long   ret_status = 0;
char   id[20];
char   **data_ptr;
static char *fname = "NFMRget_item_no";

    _NFMRdebug(( fname, "user_id   : <%ld>\n", user_id));
    _NFMRdebug(( fname, "cat name  : <%s>\n", cat_name));
    _NFMRdebug(( fname, "item name : <%s>\n", item_name));
    _NFMRdebug(( fname, "item rev  : <%s>\n", item_rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "n_catalogname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
 
    sprintf( id, "char(%d)", NFM_ITEMNAME );   
    status = MEMwrite_format (info, "n_itemname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    sprintf( id, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (info, "n_itemrev", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    strcat (str, cat_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_rev);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_GET_ITEM_NO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_Buffer : <0x%.8x>\n", status));
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
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }

    data_ptr = (char **) info->data_ptr;

    strcpy (item_num, data_ptr[0]);

    _NFMRdebug(( fname, "item_num : <%s>\n", item_num));

    MEMclose (&info);

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRget_item_name
 
 Abstract:
     This function will return an item name and item revision given a catalog
     name and item number.

 */
 
long NFMRget_item_name (user_id, cat_name, item_num, item_name, item_rev)

long    user_id;       /* i - user id for access */
char    *cat_name;     /* i - the catalog of the item */
char    *item_num;     /* i - the number of the item */
char    *item_name;    /* o - the name of the item */
char    *item_rev;     /* o - the revision of the item */

{
MEMptr info = NULL;
char   str[200];
long   status = 0;
long   ret_status = 0;
char   id[20];
char   **data_ptr;
static char *fname = "NFMRget_item_name";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));
    _NFMRdebug(( fname, "cat name : <%s>\n", cat_name));
    _NFMRdebug(( fname, "item num : <%s>\n", item_num));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "n_catalogname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "n_itemnum", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    strcat (str, cat_name);
    strcat (str, "\1");
    strcat (str, item_num);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_GET_ITEM_NAME, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
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
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }

    data_ptr = (char **) info->data_ptr;

    strcpy (item_name, data_ptr[0]);
    strcpy (item_rev, data_ptr[1]);

    _NFMRdebug(( fname, "item_name : <%s>\n", item_name));
    _NFMRdebug(( fname, "item_rev  : <%s>\n", item_rev));

    MEMclose (&info);

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}



