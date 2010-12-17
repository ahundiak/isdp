#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/*
 Doc: NFMRdelete_node
 
 Abstract:
     This function will delete a node.

*/

long NFMRdelete_node (user_id, nodename)

long    user_id;     /* i - user id for access */
char    *nodename;   /* i - node name to be deleted */

{
MEMptr info;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRdelete_node";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));
    _NFMRdebug(( fname, "nodename : <%s>\n", nodename));

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

    sprintf( id, "char(%d)", NFM_NODENAME );
    status = MEMwrite_format (info, "n_nodename", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    sprintf (str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, nodename);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_DELETE_NODE, info);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    status = MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
        return (status);
        }

    _NFMRdebug(( fname, "Return Status = <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

