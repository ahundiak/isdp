#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRquery_change_template_attributes
 
 Abstract:
     This function will query for the attributes needed to change
     a template.  Output buffers are for NFMRchange_template.
     
 */
 
long NFMRquery_change_template_attributes (user_id, table_type,
                                           attr_list, data_list, value_list)

long    user_id;          /* i - user id for access */
char    *table_type;      /* i - the type of template to query */
MEMptr  *attr_list;       /* o - list of attributes */
MEMptr  *data_list;       /* o - list of data */
MEMptr  *value_list;      /* o - list of values */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];

static char *fname = "NFMRquery_change_template_attributes";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));
    _NFMRdebug(( fname, "table type : <%s>\n", table_type));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_TABLETYPE );
    status = MEMwrite_format (info, "n_tabletype", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    strcat (str, table_type);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_CHANGE_TEMP_ATTR, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_three_buffers (&NFMRglobal.NETid, &ret_status, 
		attr_list, data_list, value_list);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return( NFM_S_SUCCESS );

}

