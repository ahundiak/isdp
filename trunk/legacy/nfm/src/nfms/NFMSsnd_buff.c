#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "NFMtypes.h"
#include "ERR.h"

extern int  IN_PIPE;
extern int  OUT_PIPE;

long  NFMSsend_error_buffers( status1, status2 )
    long    status1;
    long    status2;
{
    long    status;
    MEMptr  err_buffer = NULL;
    MEMptr  csd_buffer = NULL;

    static  char *fname = "NFMSsend_error_buffers";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = NFMSerror_status_buffer( &err_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_status_buffer : <0x%.8x>\n", status));
    }

    status = NFMSerror_csd_buffer( &csd_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_csd_buffer : <0x%.8x>\n", status));
    }
 
    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, status1, err_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (err_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, status2, csd_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (csd_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    _NFMSdebug(( fname, "%s\n", "Exiting..." ));

    return( NFM_S_SUCCESS );
}

long  NFMSsend_one_buffer( cmd_status, buffer1 )
    long    cmd_status;
    MEMptr  buffer1;
{
    long    status;
    MEMptr  err_buffer = NULL;
    MEMptr  csd_buffer = NULL;

    static  char *fname = "NFMSsend_one_buffer";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = NFMSerror_status_buffer( &err_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_status_buffer : <0x%.8x>\n", status));
    }

    status = NFMSerror_csd_buffer( &csd_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_csd_buffer : <0x%.8x>\n", status));
    }

    if (_NFMdebug_st.NFMSdebug_on)
    {
        MEMprint_buffers ("BUFFER_1", buffer1, _NFMdebug_st.NFMSdebug_file);
    }
 
    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, err_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (err_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, csd_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (csd_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, buffer1);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer1) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
                _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    _NFMSdebug(( fname, "%s\n", "Exiting..." ));

    return( NFM_S_SUCCESS );
}

long  NFMSsend_two_buffers( cmd_status, buffer1, buffer2 )
    long    cmd_status;
    MEMptr  buffer1;
    MEMptr  buffer2;
{
    long    status;
    MEMptr  err_buffer = NULL;
    MEMptr  csd_buffer = NULL;

    static  char *fname = "NFMSsend_two_buffers";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = NFMSerror_status_buffer( &err_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_status_buffer : <0x%.8x>\n", status));
    }

    status = NFMSerror_csd_buffer( &csd_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_csd_buffer : <0x%.8x>\n", status));
    }

    if (_NFMdebug_st.NFMSdebug_on)
    {
        MEMprint_buffers ("BUFFER_1", buffer1, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_2", buffer2, _NFMdebug_st.NFMSdebug_file);
    }
 
    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, err_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (err_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, csd_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (csd_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, buffer1);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer1) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
                _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer2);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer2) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    _NFMSdebug(( fname, "%s\n", "Exiting..." ));

    return( NFM_S_SUCCESS );
}


long  NFMSsend_three_buffers( cmd_status, buffer1, buffer2, buffer3 )
    long    cmd_status;
    MEMptr  buffer1;
    MEMptr  buffer2;
    MEMptr  buffer3;
{
    long    status;
    MEMptr  err_buffer = NULL;
    MEMptr  csd_buffer = NULL;

    static  char *fname = "NFMSsend_three_buffers";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = NFMSerror_status_buffer( &err_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_status_buffer : <0x%.8x>\n", status));
    }

    status = NFMSerror_csd_buffer( &csd_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_csd_buffer : <0x%.8x>\n", status));
    }

    if (_NFMdebug_st.NFMSdebug_on)
    {
        MEMprint_buffers ("BUFFER_1", buffer1, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_2", buffer2, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_3", buffer3, _NFMdebug_st.NFMSdebug_file);
    }
 
    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, err_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (err_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, csd_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (csd_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, buffer1);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer1) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
                _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer2);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer2) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer3);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer3) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    _NFMSdebug(( fname, "%s\n", "Exiting..." ));

    return( NFM_S_SUCCESS );
}

long  NFMSsend_four_buffers( cmd_status, buffer1, buffer2, buffer3, buffer4 )
    long    cmd_status;
    MEMptr  buffer1;
    MEMptr  buffer2;
    MEMptr  buffer3;
    MEMptr  buffer4;
{
    long    status;
    MEMptr  err_buffer = NULL;
    MEMptr  csd_buffer = NULL;

    static  char *fname = "NFMSsend_four_buffers";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = NFMSerror_status_buffer( &err_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_status_buffer : <0x%.8x>\n", status));
    }

    status = NFMSerror_csd_buffer( &csd_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_csd_buffer : <0x%.8x>\n", status));
    }

    if (_NFMdebug_st.NFMSdebug_on)
    {
        MEMprint_buffers ("BUFFER_1", buffer1, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_2", buffer2, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_3", buffer3, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_4", buffer4, _NFMdebug_st.NFMSdebug_file);
    }
 
    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, err_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (err_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, csd_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (csd_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, buffer1);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer1) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
                _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer2);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer2) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer3);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer3) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer4);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer4) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    _NFMSdebug(( fname, "%s\n", "Exiting..." ));

    return( NFM_S_SUCCESS );
}


long  NFMSsend_five_buffers( cmd_status, buffer1, buffer2, buffer3, buffer4,
			     buffer5 )
    long    cmd_status;
    MEMptr  buffer1;
    MEMptr  buffer2;
    MEMptr  buffer3;
    MEMptr  buffer4;
    MEMptr  buffer5;
{
    long    status;
    MEMptr  err_buffer = NULL;
    MEMptr  csd_buffer = NULL;

    static  char *fname = "NFMSsend_four_buffers";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = NFMSerror_status_buffer( &err_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_status_buffer : <0x%.8x>\n", status));
    }

    status = NFMSerror_csd_buffer( &csd_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_csd_buffer : <0x%.8x>\n", status));
    }

    if (_NFMdebug_st.NFMSdebug_on)
    {
        MEMprint_buffers ("BUFFER_1", buffer1, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_2", buffer2, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_3", buffer3, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_4", buffer4, _NFMdebug_st.NFMSdebug_file);
    }
 
    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, err_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (err_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, csd_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (csd_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, buffer1);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer1) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
                _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer2);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer2) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer3);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer3) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer4);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer4) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer5);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer5) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    _NFMSdebug(( fname, "%s\n", "Exiting..." ));

    return( NFM_S_SUCCESS );
}


long  NFMSsend_six_buffers( cmd_status, buffer1, buffer2, buffer3, buffer4,
				buffer5, buffer6 )
    long    cmd_status;
    MEMptr  buffer1;
    MEMptr  buffer2;
    MEMptr  buffer3;
    MEMptr  buffer4;
    MEMptr  buffer5;
    MEMptr  buffer6;
{
    long    status;
    MEMptr  err_buffer = NULL;
    MEMptr  csd_buffer = NULL;

    static  char *fname = "NFMSsend_four_buffers";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = NFMSerror_status_buffer( &err_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_status_buffer : <0x%.8x>\n", status));
    }

    status = NFMSerror_csd_buffer( &csd_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_csd_buffer : <0x%.8x>\n", status));
    }

    if (_NFMdebug_st.NFMSdebug_on)
    {
        MEMprint_buffers ("BUFFER_1", buffer1, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_2", buffer2, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_3", buffer3, _NFMdebug_st.NFMSdebug_file);
        MEMprint_buffers ("BUFFER_4", buffer4, _NFMdebug_st.NFMSdebug_file);
    }
 
    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, err_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (err_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, csd_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (csd_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, buffer1);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer1) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
                _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer2);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer2) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer3);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer3) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer4);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer4) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer5);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer5) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE,cmd_status, buffer6);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (buffer6) : status <0x%.8x>\n",status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    _NFMSdebug(( fname, "%s\n", "Exiting..." ));

    return( NFM_S_SUCCESS );
}


long  NFMSsend_end_buffer( cmd_status )
    long    cmd_status;
{
    long    status;
    MEMptr  err_buffer = NULL;

    static  char *fname = "NFMSsend_end_buffer";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = NFMSerror_status_buffer( &err_buffer );
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMSerror_status_buffer : <0x%.8x>\n", status));
    }
 
    status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, err_buffer);
    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "NFMsrv_send_buffer (end_buffer) : status <0x%.8x>\n", status));
        status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
        if (status != NFM_S_SUCCESS)
            _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
        return (NFM_E_FAILURE);
    }

    _NFMSdebug(( fname, "%s\n", "Exiting..." ));

    return( NFM_S_SUCCESS );
}
