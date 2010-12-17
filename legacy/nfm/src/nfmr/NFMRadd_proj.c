#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRquery_addto_lop_attributes
 
 Abstract:
     This function will return the attributes needed to add a project to the
     LOP (List of Projects).

 */
 

long NFMRquery_addto_lop_attributes (user_id, lop_name, attr_list, data_list,
                                     value_list)

long    user_id;       /* i - user id for access */
char    *lop_name;     /* o - Lis of Projects name */
MEMptr  *attr_list;    /* o - the returned attribute list */
MEMptr  *data_list;    /* o - the returned data list */
MEMptr  *value_list;   /* o - the returned value list */

{
MEMptr info = NULL;
char   str[1028];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRquery_addto_lop_attributes";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));
    _NFMRdebug(( fname, "LOP     : <%s>\n", lop_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld\1", user_id);
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_ADDTO_LOP_ATTR, info);
    _NFMRdebug(( fname, "Send Buffer = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_three_buffers (&NFMRglobal.NETid, &ret_status, 
		attr_list, data_list, value_list);
    _NFMRdebug(( fname, "NFMRreceive_three_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        {
        MEMprint_buffers ("PROJECT ATTR LIST", *attr_list, 
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("PROJECT DATA LIST", *data_list, 
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("PROJECT VALUE LIST", *value_list, 
			   _NFMdebug_st.NFMRdebug_file);
        }

    return( NFM_S_SUCCESS );
}


/* 
 Doc: NFMRadd_project
 
 Abstract:
     This function will add a project given the updated 
     buffers returned from NFMRquery_addto_lop_attributes.

 */
 

long NFMRadd_project (user_id, attr_list, data_list)

long    user_id;       /* i - user id for access */
MEMptr  attr_list;     /* i - the attribute list (from NFMRquery_addto_lop_attributes) */
MEMptr  data_list;     /* i - the acl data list (from NFMRquery_addto_lop_attributes) */

{
MEMptr info = NULL;
char   str[1028];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRadd_project";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld\1", user_id);
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMappend (attr_list, info);
    if (status != MEM_S_SUCCESS)
        {
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

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_ADD_PROJECT, info);
    _NFMRdebug(( fname, "Send Buffer = <0x%.8x>\n", status));
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




