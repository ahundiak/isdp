#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRquery_addto_loc_attributes
 
 Abstract:
     This function will query for the LOC (List of Catalog) attributes.
     Output buffers are for NFMRcreate_catalog.
     
 */
 
long NFMRquery_addto_loc_attributes (user_id, loc_name, attr_list,
                                     data_list, value_list)

long    user_id;          /* i - user id for access */
char    *loc_name;        /* o - the name of the List Of Catalogs */
MEMptr  *attr_list;       /* o - list of attributes */
MEMptr  *data_list;       /* o - list of data */
MEMptr  *value_list;      /* o - list of values */

{
MEMptr info = NULL;
char   str[20];
long   status = 0;
long   ret_status = 0;
char   **data_ptr;

static char *fname = "NFMRquery_addto_loc_attributes";

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
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_ADDTO_LOC_ATTR, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_four_buffers (&NFMRglobal.NETid, &ret_status,
		&info, attr_list, data_list, value_list );
    _NFMRdebug(( fname, "NFMRreceive_four_buffers : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    status = MEMbuild_array( info );
    if( status != MEM_S_SUCCESS )
    {
        _NFMRdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    data_ptr = (char**)info->data_ptr;
    strcpy( loc_name, data_ptr[0] );
    MEMclose( &info );

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        {
        MEMprint_buffers ("LOC ATTR", *attr_list, 
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("LOC DATA", *data_list,
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("LOC VALUE", *value_list,
			   _NFMdebug_st.NFMRdebug_file);
        }
    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRquery_loc_definition
 
 Abstract:
     This function will query for the LOC (List of Catalog) attributes only.

 */
 
long NFMRquery_loc_definition (user_id, loc_name, attr_list)

long    user_id;          /* i - user id for access */
char    *loc_name;        /* i - the name of the List Of Catalogs */
MEMptr  *attr_list;       /* o - list of attributes */

{
MEMptr info = NULL;
char   str[100];
long   status = 0;
long   ret_status = 0;
char   id[10];

static char *fname = "NFMRquery_loc_definition";

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

    sprintf( id, "char(%s)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "n_locname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }
    
    sprintf (str, "%ld\1", user_id);
    strcat (str, loc_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        return (status);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_LOC_DEF, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status,attr_list);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return( NFM_S_SUCCESS );

}


