#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRquery_project_acl_map
 
 Abstract:
     This function will return the attributes needed to add an ACL mapping
     to a project.
     
 */

 
long NFMRquery_project_acl_map (user_id, project_name, attr_list, data_list,
                                value_list)

long    user_id;       /* i - user id for access */
char    *project_name; /* i - project to add acl mapping */
MEMptr  *attr_list;    /* o - the returned attribute list */
MEMptr  *data_list;    /* o - the returned acl data list */
MEMptr  *value_list;   /* o - the returned acl value list */

{
MEMptr info = NULL;
char   str[100];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRquery_project_acl_map";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));
    _NFMRdebug(( fname, "project  : <%s>\n", project_name));

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
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_PROJECTNAME );
    status = MEMwrite_format (info, "n_projectname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld\1", user_id);
    strcat (str, project_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_PROJ_ACL_MAP, info);
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
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        {
        MEMprint_buffers ("PROJ ACL ATTR", *attr_list, 
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("PROJ ACL DATA", *data_list, 
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("PROJ ACL VALUE", *value_list, 
			   _NFMdebug_st.NFMRdebug_file);
        }

    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRupdate_project_acl_map
 
 Abstract:
     This function will add an ACL mapping to a project given the updated 
     buffers returned from NFMRquery_project_acl_map.
     
 */


long NFMRupdate_project_acl_map (user_id, attr_list, data_list)

long    user_id;       /* i - user id for access */
MEMptr  attr_list;     /* i - the attribute list (from NFMRquery_project_acl_map) */
MEMptr  data_list;     /* i - the acl data list (from NFMRquery_project_acl_map) */

{
MEMptr info = NULL;
char   str[50];
long   status = 0;
long   ret_status = 0;
static char *fname = "NFMRupdate_project_acl_map";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));

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
	MEMclose( &info );
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

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_UPDATE_PROJ_ACL_MAP, info);
    _NFMRdebug(( fname, "Send Buffer = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRquery_project_sa_map
 
 Abstract:
     This function will return the attributes needed to add a storage area
     mapping to a project.

 */
 

long NFMRquery_project_sa_map (user_id, project_name, attr_list, data_list,
                               value_list)

long    user_id;       /* i - user id for access */
char    *project_name; /* i - project to add storage area mapping */
MEMptr  *attr_list;    /* o - the returned attribute list */
MEMptr  *data_list;    /* o - the returned acl data list */
MEMptr  *value_list;   /* o - the returned acl value list */

{
MEMptr info = NULL;
char   str[50];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRquery_project_sa_map";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));
    _NFMRdebug(( fname, "project  : <%s>\n", project_name));

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
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_PROJECTNAME );
    status = MEMwrite_format (info, "n_projectname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld\1", user_id );
    strcat (str, project_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_PROJ_SA_MAP, info);
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
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        {
        MEMprint_buffers ("PROJ SA ATTR", *attr_list,
                           _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("PROJ SA DATA", *data_list,
                           _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("PROJ SA VALUE", *value_list,
                           _NFMdebug_st.NFMRdebug_file);
        }

    return( NFM_S_SUCCESS );

}



/* 
 Doc: NFMRupdate_project_sa_map
 
 Abstract:
     This function will add a storage area mapping to a project given the
     updated buffers returned from NFMRquery_project_sa_map.
          
 */

 
long NFMRupdate_project_sa_map (user_id, attr_list, data_list)

long    user_id;       /* i - user id for access */
MEMptr  attr_list;     /* i - the attribute list (from NFMRquery_project_sa_map) */
MEMptr  data_list;     /* i - the acl data list (from NFMRquery_project_sa_map) */

{
MEMptr info = NULL;
char   str[50];
long   status = 0;
long   ret_status = 0;
static char *fname = "NFMRupdate_project_sa_map";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));

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
	MEMclose( &info );
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

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_UPDATE_PROJ_SA_MAP, info);
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
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );
}




