#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRlogout
 
 Abstract:
     This function will log a user out of the current environment.

 */

long NFMRlogout (user_id)
long   user_id;
{
MEMptr info = NULL;
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRlogout";

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_LOGOUT, info);
    if (status != NFM_S_SUCCESS)
        {
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
        }

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    if (status != NFM_S_SUCCESS)
        {
        _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}
