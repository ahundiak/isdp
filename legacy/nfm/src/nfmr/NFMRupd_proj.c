#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRquery_project_members
 
 Abstract:
     This function will return the attributes needed to add items
     to a project.

 */
 

long NFMRquery_project_members (user_id, project_name, attr_list, data_list)

long    user_id;       /* i - user id for access */
char    *project_name; /* i - project to add members */
MEMptr  *attr_list;    /* o - the returned attribute list */
MEMptr  *data_list;    /* o - the returned acl data list */

{
MEMptr info = NULL;
char   str[50];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRquery_project_members";

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
        _NFMRdebug(( fname, "MEMwrite : <0x%8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
         }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_PROJ_MEM, info);
    _NFMRdebug(( fname, "Send Buffer = <0x%8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status,
		attr_list, data_list);
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        {
        MEMprint_buffers ("PROJ MEM ATTR LIST", *attr_list, 
			_NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("PROJ MEM DATA LIST", *data_list,
			_NFMdebug_st.NFMRdebug_file);
        }

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRupdate_project_members
 
 Abstract:
     This function will add items to a project given the updated 
     buffers returned from NFMRquery_project_members.
     
 */
 

long NFMRupdate_project_members (user_id, attr_list, data_list)

long    user_id;       /* i - user id for access */
MEMptr  attr_list;     /* i - the attribute list (from NFMRquery_project_members) */
MEMptr  data_list;     /* i - the acl data list (from NFMRquery_project_members) */

{
MEMptr info = NULL;
char   str[10];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRupdate_project_members";

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
        _NFMRdebug(( fname, "MEMappend : <0x%8x>\n", status));
        return (status);
        }

    status = MEMappend (data_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%8x>\n", status));
        return (status);
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_UPDATE_PROJ_MEM, info);
    _NFMRdebug(( fname, "Send Buffer = <0x%8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRqry_item_in_cat_for_project
 
 Abstract:
     This function will return the items that can be validly added
     to a project.

 */
 

long NFMRqry_items_in_cat_for_project(user_id, project_name, catalog_name,
 item_list )

long    user_id;       /* i - user id for access */
char    *project_name; /* i - project to add members */
char    *catalog_name; /* i - catalog name */
MEMptr  *item_list;    /* o - the returned item list */
{
MEMptr info = NULL;
char   str[100];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRquery_items_for_project";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));
    _NFMRdebug(( fname, "project  : <%s>\n", project_name));
    _NFMRdebug(( fname, "catalog  : <%s>\n", catalog_name));

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
    status = MEMwrite_format (info, "n_projectname", id );
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "n_catalogname", id);
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
    strcat (str, catalog_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_ITEMS_FOR_PROJ, info);
    _NFMRdebug(( fname, "Send Buffer = <0x%8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status,item_list);
    _NFMRdebug(( fname, "NFMRreceive_one_Buffer : <0x%8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        MEMprint_buffers ("PROJ ITEM LIST", *item_list,
			_NFMdebug_st.NFMRdebug_file);

    return( NFM_S_SUCCESS );

}
 

long NFMRqry_project_members (user_id, project_name, attr_list, data_list)

long    user_id;       /* i - user id for access */
char    *project_name; /* i - project to add members */
MEMptr  *attr_list;    /* o - the returned attribute list */
MEMptr  *data_list;    /* o - the returned acl data list */

{
MEMptr info = NULL;
char   str[50];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRqry_project_members";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));
    _NFMRdebug(( fname, "project  : <%s>\n", project_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
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
        _NFMRdebug(( fname, "MEMwrite : <0x%8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QRY_PROJ_MEM, info);
    _NFMRdebug(( fname, "Send Buffer = <0x%8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status, 
			attr_list, data_list );
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        {
        MEMprint_buffers ("PROJ MEM ATTR LIST", *attr_list, 
		_NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("PROJ MEM DATA LIST", *data_list, 
		_NFMdebug_st.NFMRdebug_file);
        }

    return( NFM_S_SUCCESS );

}
