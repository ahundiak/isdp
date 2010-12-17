#include "machine.h"

/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFMRextern.h"
#include "NFMdef.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRreceive_buffer
 
 Abstract:
     This function will receive a buffer from the server.  All global error
     structures are filled according to whether there was an error on the 
     server or not.
 */

long NFMRreceive_buffer (netid, ret_status, return_buffer)
    long   *netid;         /* i - the address of the network ID */
    long   *ret_status;    /* i - address for the function return status */
    MEMptr *return_buffer; /* i - address of the output buffer */
{
    long    status;
    long    term_status;
    MEMptr  status_buffer = NULL;
    MEMptr  csd_buffer    = NULL;
    MEMptr  info	  = NULL;

    static  char *fname = "NFMRreceive_buffer";

    status = NFMcl_receive_buffer( netid, ret_status, &info);
    _NFMRdebug(( fname, "NET rec Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        term_status = NFMRterminate ();
        _NFMRdebug(( fname, "NFMRterminate : status=<0x%.8x>\n",term_status));
        return (status);
        }
/*  Tear off first three buffers which are the error status buffer, the
 *  Context Specific Data buffer and the multiple message buffer and 
 *  load the information into the global '_ERRstruct' which will be 
 *  used to display return status'.
 */

    status = MEMsplit_copy_buffer (info, &status_buffer, 0);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMsplit_copy_buffer1 : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    status = MEMreset_buffer_no (info, 2);
    if (status == MEM_S_SUCCESS)
        {
        status = MEMsplit_copy_buffer (info, &csd_buffer, 0);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&info);
            _NFMRdebug(( fname, "MEMsplit_copy_buffer2 : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
            }
        }
    else
	{
        MEMclose( &info );
	return( status );
	}

    status = MEMreset_buffer_no (info, 3);
    if (status == MEM_S_SUCCESS)
        {
        status = MEMsplit_copy_buffer (info, return_buffer, 1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&info);
            _NFMRdebug(( fname, "MEMsplit_copy_buffer3 : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
            }
        }
    else if (status == MEM_E_BAD_BUFFER_NO )
	{
	_NFMRdebug(( fname, "%s\n", "Empty return buffer " ));
	}
    else
	{
	return( status );
	}

    MEMclose( &info );

    status = NFMRload_ERRstruct( status_buffer, csd_buffer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &status_buffer );
	MEMclose( &csd_buffer );
	return( status );
    }
    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", *ret_status));

    MEMclose( &status_buffer );
    MEMclose( &csd_buffer );

    return (NFM_S_SUCCESS); 
}


long NFMRreceive_error_buffers (netid, ret_status)
    long   *netid;         /* i - the address of the network ID */
    long   *ret_status;    /* i - address for the function return status */
{
    long    status;
    long    int_status;

    MEMptr  status_buffer = NULL;
    MEMptr  csd_buffer    = NULL;

    static  char *fname = "NFMRreceive_error_buffers";

    status = NFMcl_receive_buffer( netid, ret_status, &status_buffer);
    _NFMRdebug(( fname, "Status_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&status_buffer);
        return (status);
        }
    status = NFMcl_receive_buffer( netid, &int_status, &csd_buffer);
    _NFMRdebug(( fname, "Csd_buffer : <0x%.8x>\n", status));

    if (status != NFM_S_SUCCESS)
        {
	MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
        }
 
    status = NFMRload_ERRstruct( status_buffer, csd_buffer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &status_buffer );
	MEMclose( &csd_buffer );
	return( status );
    }
    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", *ret_status));

    MEMclose( &status_buffer );
    MEMclose( &csd_buffer );

    return (NFM_S_SUCCESS); 
}

long NFMRreceive_one_buffer (netid, ret_status, return_buffer1)
    long   *netid;         /* i - the address of the network ID */
    long   *ret_status;    /* i - address for the function return status */
    MEMptr *return_buffer1; /* i - address of the output buffer1 */
{
    long    status;
    long    int_status;

    MEMptr  status_buffer = NULL;
    MEMptr  csd_buffer    = NULL;

    static  char *fname = "NFMRreceive_one_buffers";

    status = NFMcl_receive_buffer( netid, ret_status, &status_buffer);
    _NFMRdebug(( fname, "Status_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&status_buffer);
        return (status);
        }

    status = NFMcl_receive_buffer( netid, &int_status, &csd_buffer);
    _NFMRdebug(( fname, "Csd_buffer : <0x%.8x>\n", status));

    if (status != NFM_S_SUCCESS)
        {
	MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
        }

    if( *ret_status == NFM_I_NO_MORE_BUFFERS )
        _NFMRdebug(( fname, "NO MORE BUFFERS : <0x%.8x>\n", *ret_status));    

    status = NFMcl_receive_buffer(netid, &int_status, return_buffer1);
    _NFMRdebug(( fname, "Return_buffer1 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }
 
    status = NFMRload_ERRstruct( status_buffer, csd_buffer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &status_buffer );
	MEMclose( &csd_buffer );
	return( status );
    }
    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", *ret_status));

    MEMclose( &status_buffer );
    MEMclose( &csd_buffer );

    return (NFM_S_SUCCESS); 
}

long NFMRreceive_two_buffers (netid, ret_status, return_buffer1,
			      return_buffer2)
    long   *netid;         /* i - the address of the network ID */
    long   *ret_status;    /* i - address for the function return status */
    MEMptr *return_buffer1; /* i - address of the output buffer1 */
    MEMptr *return_buffer2; /* i - address of the output buffer2 */
{
    long    status;
    long    int_status;

    MEMptr  status_buffer = NULL;
    MEMptr  csd_buffer    = NULL;

    static  char *fname = "NFMRreceive_two_buffers";

    status = NFMcl_receive_buffer( netid, ret_status, &status_buffer);
    _NFMRdebug(( fname, "Status_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&status_buffer);
        return (status);
        }

    status = NFMcl_receive_buffer( netid, &int_status, &csd_buffer);
    _NFMRdebug(( fname, "Csd_buffer : <0x%.8x>\n", status));
    _NFMRdebug(( fname, "Int Status : <0x%.8x>\n", int_status));
    if (status != NFM_S_SUCCESS)
        {
	MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
        }

    if( *ret_status == NFM_I_NO_MORE_BUFFERS )
        _NFMRdebug(( fname, "NO MORE BUFFERS : <0x%.8x>\n", *ret_status));    

    status = NFMcl_receive_buffer(netid, &int_status, return_buffer1);
    _NFMRdebug(( fname, "Return_buffer1 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer2);
    _NFMRdebug(( fname, "Return_buffer2 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }
 
    status = NFMRload_ERRstruct( status_buffer, csd_buffer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &status_buffer );
	MEMclose( &csd_buffer );
	return( status );
    }
    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", *ret_status));

    MEMclose( &status_buffer );
    MEMclose( &csd_buffer );

    return (NFM_S_SUCCESS); 
}

long NFMRreceive_three_buffers (netid, ret_status, return_buffer1,
			      return_buffer2, return_buffer3)
    long   *netid;         /* i - the address of the network ID */
    long   *ret_status;    /* i - address for the function return status */
    MEMptr *return_buffer1; /* i - address of the output buffer1 */
    MEMptr *return_buffer2; /* i - address of the output buffer2 */
    MEMptr *return_buffer3; /* i - address of the output buffer3 */
{
    long    status;
    long    int_status;

    MEMptr  status_buffer = NULL;
    MEMptr  csd_buffer    = NULL;

    static  char *fname = "NFMRreceive_three_buffers";

    status = NFMcl_receive_buffer( netid, ret_status, &status_buffer);
    _NFMRdebug(( fname, "Status_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&status_buffer);
        return (status);
        }

    status = NFMcl_receive_buffer( netid, &int_status, &csd_buffer);
    _NFMRdebug(( fname, "Csd_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
	MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
        }

    status = NFMcl_receive_buffer(netid, &int_status, return_buffer1);
    _NFMRdebug(( fname, "Return_buffer1 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer2);
    _NFMRdebug(( fname, "Return_buffer2 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer3);
    _NFMRdebug(( fname, "Return_buffer3 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }
 
    status = NFMRload_ERRstruct( status_buffer, csd_buffer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &status_buffer );
	MEMclose( &csd_buffer );
	return( status );
    }
    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", *ret_status));

    MEMclose( &status_buffer );
    MEMclose( &csd_buffer );

    return (NFM_S_SUCCESS); 
}

long NFMRreceive_four_buffers (netid, ret_status, return_buffer1,
			      return_buffer2, return_buffer3, return_buffer4)
    long   *netid;         /* i - the address of the network ID */
    long   *ret_status;    /* i - address for the function return status */
    MEMptr *return_buffer1; /* i - address of the output buffer1 */
    MEMptr *return_buffer2; /* i - address of the output buffer2 */
    MEMptr *return_buffer3; /* i - address of the output buffer3 */
    MEMptr *return_buffer4; /* i - address of the output buffer4 */
{
    long    status;
    long    int_status;

    MEMptr  status_buffer = NULL;
    MEMptr  csd_buffer    = NULL;

    static  char *fname = "NFMRreceive_four_buffers";

    status = NFMcl_receive_buffer( netid, ret_status, &status_buffer);
    _NFMRdebug(( fname, "Status_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&status_buffer);
        return (status);
        }

    status = NFMcl_receive_buffer( netid, &int_status, &csd_buffer);
    _NFMRdebug(( fname, "Csd_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
	MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
        }

    status = NFMcl_receive_buffer(netid, &int_status, return_buffer1);
    _NFMRdebug(( fname, "Return_buffer1 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer2);
    _NFMRdebug(( fname, "Return_buffer2 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer3);
    _NFMRdebug(( fname, "Return_buffer3 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer4);
    _NFMRdebug(( fname, "Return_buffer4 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }
 
    status = NFMRload_ERRstruct( status_buffer, csd_buffer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &status_buffer );
	MEMclose( &csd_buffer );
	return( status );
    }
    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", *ret_status));

    MEMclose( &status_buffer );
    MEMclose( &csd_buffer );

    return (NFM_S_SUCCESS); 
}

long NFMRreceive_five_buffers (netid, ret_status, return_buffer1,
	      return_buffer2, return_buffer3, return_buffer4, return_buffer5)
    long   *netid;         /* i - the address of the network ID */
    long   *ret_status;    /* i - address for the function return status */
    MEMptr *return_buffer1; /* i - address of the output buffer1 */
    MEMptr *return_buffer2; /* i - address of the output buffer2 */
    MEMptr *return_buffer3; /* i - address of the output buffer3 */
    MEMptr *return_buffer4; /* i - address of the output buffer4 */
    MEMptr *return_buffer5; /* i - address of the output buffer5 */
{
    long    status;
    long    int_status;

    MEMptr  status_buffer = NULL;
    MEMptr  csd_buffer    = NULL;

    static  char *fname = "NFMRreceive_five_buffers";

    status = NFMcl_receive_buffer( netid, ret_status, &status_buffer);
    _NFMRdebug(( fname, "Status_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&status_buffer);
        return (status);
        }

    status = NFMcl_receive_buffer( netid, &int_status, &csd_buffer);
    _NFMRdebug(( fname, "Csd_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
	MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
        }

    status = NFMcl_receive_buffer(netid, &int_status, return_buffer1);
    _NFMRdebug(( fname, "Return_buffer1 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer2);
    _NFMRdebug(( fname, "Return_buffer2 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer3);
    _NFMRdebug(( fname, "Return_buffer3 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer4);
    _NFMRdebug(( fname, "Return_buffer4 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer5);
    _NFMRdebug(( fname, "Return_buffer5 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }
 
    status = NFMRload_ERRstruct( status_buffer, csd_buffer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &status_buffer );
	MEMclose( &csd_buffer );
	return( status );
    }
    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", *ret_status));

    MEMclose( &status_buffer );
    MEMclose( &csd_buffer );

    return (NFM_S_SUCCESS); 
}

long NFMRreceive_six_buffers (netid, ret_status, return_buffer1,
      return_buffer2, return_buffer3, return_buffer4, return_buffer5,
      return_buffer6)
    long   *netid;         /* i - the address of the network ID */
    long   *ret_status;    /* i - address for the function return status */
    MEMptr *return_buffer1; /* i - address of the output buffer1 */
    MEMptr *return_buffer2; /* i - address of the output buffer2 */
    MEMptr *return_buffer3; /* i - address of the output buffer3 */
    MEMptr *return_buffer4; /* i - address of the output buffer4 */
    MEMptr *return_buffer5; /* i - address of the output buffer5 */
    MEMptr *return_buffer6; /* i - address of the output buffer6 */
{
    long    status;
    long    int_status;

    MEMptr  status_buffer = NULL;
    MEMptr  csd_buffer    = NULL;

    static  char *fname = "NFMRreceive_six_buffers";

    status = NFMcl_receive_buffer( netid, ret_status, &status_buffer);
    _NFMRdebug(( fname, "Status_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&status_buffer);
        return (status);
        }

    status = NFMcl_receive_buffer( netid, &int_status, &csd_buffer);
    _NFMRdebug(( fname, "Csd_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
	MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
        }

    status = NFMcl_receive_buffer(netid, &int_status, return_buffer1);
    _NFMRdebug(( fname, "Return_buffer1 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer2);
    _NFMRdebug(( fname, "Return_buffer2 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer3);
    _NFMRdebug(( fname, "Return_buffer3 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer4);
    _NFMRdebug(( fname, "Return_buffer4 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer5);
    _NFMRdebug(( fname, "Return_buffer5 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }

    status = NFMcl_receive_buffer (netid, &int_status, return_buffer6);
    _NFMRdebug(( fname, "Return_buffer6 : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&csd_buffer);
        MEMclose (&status_buffer);
        return (status);
    }
 
    status = NFMRload_ERRstruct( status_buffer, csd_buffer );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &status_buffer );
	MEMclose( &csd_buffer );
	return( status );
    }
    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", *ret_status));

    MEMclose( &status_buffer );
    MEMclose( &csd_buffer );

    return (NFM_S_SUCCESS); 
}
