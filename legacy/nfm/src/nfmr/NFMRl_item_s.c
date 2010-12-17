#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRlist_items_short
 
 Abstract:
     This function will get a short list of items containing n_itemno,
     n_itemname, n_itemrev.
     
 Returns:
       0 - Success
      <0 - Failure
         
 */
 
long NFMRlist_items_short (user_id, catalog_name, data_list)

long    user_id;          /* i - user id for access */
char    *catalog_name;    /* i - the catalog name to query */
MEMptr  *data_list;       /* o - list of data */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];

static char *fname = "NFMRlist_items_short";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));
    _NFMRdebug(( fname, "catalog : <%s>\n", catalog_name));

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
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "n_catalogname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }
    
    sprintf (str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, catalog_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        return (status);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_LIST_ITEMS_SHORT, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    status = MEMsplit_copy_buffer (info, data_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }

    MEMclose (&info);

    if (_NFMdebug_st.NFMRdebug_on)
        MEMprint_buffers ("ITEM DATA LIST", *data_list, 
			  _NFMdebug_st.NFMRdebug_file);
  
    return (NFM_S_SUCCESS); 
}
