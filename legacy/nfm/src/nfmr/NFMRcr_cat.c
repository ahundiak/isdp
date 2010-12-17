#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRcreate_catalog
 
 Abstract:
     This function will create a catalog with a given set of LOC attributes
     and data (modified buffers returned from NFMRquery_addto_loc_attributes)
     and a given set of CATALOG attributes, data, and values (modified buffers
     returned from NFMRquery_catalog_template).
     
 */
 
long NFMRcreate_catalog (user_id, loc_attr, loc_data, attr_list,
                         data_list, value_list)

long    user_id;          /* i - user id for access */
MEMptr  loc_attr;         /* i - list of catalog (LOC) attributes */
MEMptr  loc_data;         /* i - list of catalog (LOC) data */
MEMptr  attr_list;        /* i - list of item attributes */
MEMptr  data_list;        /* i - list of item data */
MEMptr  value_list;       /* i - list of item values */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];

static char *fname = "NFMRcreate_catalog";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));

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
    
    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMappend (loc_attr, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMappend (loc_data, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
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

    if (value_list != NULL)
        {    
        status = MEMappend (value_list, info);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&info);
            _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
            return (status);
            }
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_CREATE_CATALOG, info);
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
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );
}

