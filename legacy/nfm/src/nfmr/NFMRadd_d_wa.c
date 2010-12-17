#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

long NFMRadd_default_working_area (node, user, path, wa, node_info,
				   sa_info)
  char    *node;  /*  i - Name of client node                           */
  char    *user;  /*  i - CLIX username                                 */
  char    *path;  /*  i - Absolute pathname; current working directory  */
  char    *wa;    /*  o - Name of newly created working area            */
  MEMptr  node_info; /*  i - Buffer of node information */
  MEMptr  sa_info;   /*  i - Buffer of storage area information */
{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];
char   **data_ptr;
static char *fname = "NFMRadd_default_working_area";

    _NFMRdebug(( fname, "node <%s>\n", node ));
    _NFMRdebug(( fname, "user <%s>\n", user ));
    _NFMRdebug(( fname, "path <%s>\n", path ));

    if( _NFMdebug_st.NFMRdebug_on )
    {
	MEMprint_buffers( "NODE INFO", node_info,_NFMdebug_st.NFMRdebug_file );

	MEMprint_buffers( "SA INFO", sa_info,_NFMdebug_st.NFMRdebug_file );
    }
    
    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_NODENAME );
    status = MEMwrite_format (info, "node", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    sprintf( id, "char(%d)", NFM_USERNAME );
    status = MEMwrite_format (info, "user", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    sprintf( id, "char(%d)", NFM_PATHNAME );
    status = MEMwrite_format (info, "path", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%s\1%s\1%s\1", node, user, path);
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMappend (node_info, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMappend (sa_info, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_ADD_DEFAULT_WA, info);
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
    if( ret_status != NFM_S_SUCCESS )
    {
	MEMclose( &info );
        return( ret_status );
    }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    data_ptr = (char**) info->data_ptr;
    strcpy( wa, data_ptr[0] );

    _NFMRdebug(( fname, "Default Working Area <%s>\n", wa ));

    MEMclose (&info);

    return( NFM_S_SUCCESS );

}


