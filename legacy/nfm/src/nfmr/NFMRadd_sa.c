#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRadd_storage_area
 
 Abstract:
     This function will add a storage area to the NFM database. The input
     buffers are from NFMRquery_add_st_area_attributes.
 */
 
long NFMRadd_storage_area (user_id, attr_list, data_list)

long    user_id;     /* i - user id for access */
MEMptr  attr_list;   /* i - list of attributes */
MEMptr  data_list;   /* i - list of data */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
static char *fname = "NFMRadd_storage_area";

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
    
    sprintf (str, "%ld", user_id);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
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

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_ADD_SA, info);
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
        return( ret_status );

    return( NFM_S_SUCCESS );

}

long NFMRadd_return_sa_name (attr_list, data_list, saname)

MEMptr  attr_list;   /* i - list of attributes */
MEMptr  data_list;   /* i - list of data */
char    *saname ;    /* o - storagearea name */

{
MEMptr info = NULL;
long   status = 0;
long   ret_status = 0;
char   **data ;
static char *fname = "NFMRadd_return_sa_name" ;

    _NFMRdebug ((fname, "ENTER\n")) ;

    saname [0] = 0 ;
    
    status = MEMsplit_copy_buffer (attr_list, &info, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMappend (data_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    if (_NFMdebug_st.NFMRdebug_on)
      {
	MEMprint_buffer ("info", info, _NFMdebug_st.NFMRdebug_file) ;
      }


    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_ADD_RETURN_SA_NAME, 
				info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
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
    if (_NFMdebug_st.NFMRdebug_on)
      {
	MEMprint_buffer ("info", info, _NFMdebug_st.NFMRdebug_file) ;
      }

    if(( ret_status != NFM_S_SUCCESS )&& (ret_status != NFM_E_DUP_ST_AREA))
        return (ret_status); 

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS) 
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    data = (char **) info->data_ptr ;
    strcpy (saname, data [0]) ;
    MEMclose (&info);

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    _NFMRdebug ((fname, "SUCCESSFUL : saname <%s>\n", saname)) ;

    return( NFM_S_SUCCESS );
}



/* 
 Doc: NFMRquery_add_st_area_attributes
 
 Abstract:
     This function will query for the attributes needed to add a 
     storage area.  Output buffers are for NFMRadd_storage_area.
     
 */
 
long NFMRquery_add_st_area_attributes (user_id, attr_list, data_list,
                                       value_list)

long    user_id;     /* i - user id for access */
MEMptr  *attr_list;  /* o - buffer for attributes */
MEMptr  *data_list;  /* o - buffer for data */
MEMptr  *value_list; /* o - buffer for values */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
static char *fname = "NFMRquery_st_area";

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

    sprintf (str, "%ld\1", user_id);
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_ADD_SA, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
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

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if( _NFMdebug_st.NFMRdebug_on)
    {
	MEMprint_buffers("ATTR LIST", *attr_list, _NFMdebug_st.NFMRdebug_file);
	MEMprint_buffers("DATA LIST", *data_list, _NFMdebug_st.NFMRdebug_file);
	MEMprint_buffers("VAL LIST", *value_list, _NFMdebug_st.NFMRdebug_file);
    }

    return( NFM_S_SUCCESS );

}

