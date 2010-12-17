#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/*
 Doc: NFMRdelete_label
 
 Abstract:
     This function will delete a label.

*/

long NFMRdelete_label (label_buffer)

MEMptr   label_buffer;   /* i - single column buffer of labels */

{
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdelete_label";

    if( _NFMdebug_st.NFMRdebug_on )
	MEMprint_buffer( "LABELS", label_buffer, _NFMdebug_st.NFMRdebug_file );

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_DELETE_LABEL, 
				label_buffer);
    if (status != NFM_S_SUCCESS)
        return (status);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status = <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

