#include "machine.h"
#include "NFMRinclude.h"
#include "ERR.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRreceive_buffer
 
 Abstract:
     This function will receive a buffer from the server.  All global error
     structures are filled according to whether there was an error on the 
     server or not.
     
 Returns:
       0 - Success
      <0 - Failure
         
 History:
     kht    8-31-1989    Creation
     
 */

long NFMRreceive_buffer (NETid, ret_status, return_buffer)
    long   *NETid;         /* i - the address of the network ID */
    long   *ret_status;    /* i - address for the function return status */
    MEMptr *return_buffer; /* i - address of the output buffer */
{
    long    status;

    MEMptr  status_buffer = NULL;
    MEMptr  csd_buffer    = NULL;
    MEMptr  info	  = NULL;

    extern long ERRload_struct();

    _NFMR_str ("%s", "NFMRreceive_buffer");

    status = NFMcl_receive_buffer (NETid, ret_status, &info);
    _NFMR_num ("NFMRreceive_buffer : NET rec Buffer : <0x%.8x>", status);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        NETclose_c (NETid);
        _NFMR_num("NFMRreceive_buffer : NFMcl_receive_buffer : <0x%.8x>", status);
        return (status);
        }
/*  Tear off first two buffers which are the error status buffer and the
 *  Context Specific Data buffer and load the information into the global
 *  '_ERRstruct' which will be used to display return status'.
 */

    _NFMR_str ("%s", "NFMRreceive_buffer : MEMsplit_copy STATUS");
    status = MEMsplit_copy_buffer (info, &status_buffer, 0);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMR_num("NFMRreceive_buffer : MEMsplit_copy_buffer1: <0x%.8x>", status);
        return (status);
    }

    _NFMR_str ("%s", "NFMRreceive_buffer : Reset to buffer 2");
    status = MEMreset_buffer_no (info, 2);
    if (status == MEM_S_SUCCESS)
        {
        _NFMR_str ("%s", "NFMRreceive_buffer : MEMsplit_copy CSD");
        status = MEMsplit_copy_buffer (info, &csd_buffer, 0);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&info);
            _NFMR_num ("NFMRreceive_buffer : MEMsplit_copy_buffer2 : <0x%.8x>",
		 status);
            return (status);
            }
        }
    else
	{
	_NFMR_num ("NFMRreceive_buffer : MEMreset_buffer_no 2 : <0x%.8x>",
			status );
        MEMclose( &info );
	return( status );
	}

    _NFMR_str ("%s", "NFMRreceive_buffer : MEMreset buffer no 3");
/** reset_buffer_no (info,3) is changer to (info, 4) since server is sending
    and extra buffer (message buffer) from NFM 3.0 on wards 
**/
    status = MEMreset_buffer_no (info, 4);
    if (status == MEM_S_SUCCESS)
        {
        _NFMR_str ("%s", "NFMRreceive_buffer : MEMsplit_copy RETURN");
        status = MEMsplit_copy_buffer (info, return_buffer, 1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&info);
            _NFMR_num ("NFMRreceive_buffer : MEMsplit_copy_buffer3 : <0x%.8x>",
		 status);
            return (status);
            }
        }
    else if (status == MEM_E_BAD_BUFFER_NO )
	_NFMR_str( "%s", "NFMRreceive_buffer : Empty return buffer " );
    else
	{
	_NFMR_num ("NFMRreceive_buffer : MEMreset_buffer_no 3 : <0x%.8x>",
			status );
	return( status );
	}

    MEMclose( &info );

    _NFMR_str( "%s", "NFMRreceive_buffer : Loading ERR structure :" );    

    status = NFMRload_ERRstruct( status_buffer, csd_buffer );

    if( status != NFM_S_SUCCESS )
    {
        MEMclose( &status_buffer );
        MEMclose( &csd_buffer );
        return( status );
    }

    _NFMR_num ("NFMRreceive_buffer : Return Status : <0x%.8x>", *ret_status);

    MEMclose( &status_buffer );
    MEMclose( &csd_buffer );

    return (NFM_S_SUCCESS); 
}
