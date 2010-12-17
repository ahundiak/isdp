#include "machine.h"
#include "NFMRextern.h"
#include <UMS.h>

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRset_to_state
 
 Abstract:
     This function will set an item to the appropriate "to_state" after
     successful completion of a command.  This function must be called after 
     each command (initiated by an NFMRvalidate_user_acces) regardless of
     whether or not the command was successful.  The app_ptr argument must
     contain the application's error status int the "error_no" field (0 -
     success; non-zero - failure) and an error message in the "error_msg"
     field (see MSGstruct.h).  I/NFM makes the appropriate transition based
     on the error number.

 */
 
long NFMRset_to_state (user_id, application )

long    user_id;       /* i - user id for access */
char    *application;  /* i - application name */
{
MEMptr info = NULL;
char   str[1028];
char   msg[512];
long   status = 0;
long   err_status;
long   ret_status = 0;
long   error_number;

int    fake_index=0;
int    subsystem;

char   id[20];
char   err_no[20];
char   *fake_path=NULL;
static int reset_flag = 0;

FILE   *ALFconsole = NULL;
FILE   *fopen();

static char *fname = "NFMRset_to_state";

    _NFMRdebug(( fname, "user_id       : <%ld>\n", user_id));
    _NFMRdebug(( fname, "application   : <%s>\n", application));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "n_application", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "error_no", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "error_msg", "char(512)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    ALFconsole = fopen("/dev/console","w");

    ERRget_number( &error_number, &subsystem );

/*  What follows is the attempt to keep applications from having to worry
 *  about initializing the message subsystem and still not mess up the
 *  'set_to_state' functionality.
 */
    err_status = ERRget_message( msg );
    if( err_status != ERR_S_SUCCESS )
    {
	if( err_status == ERR_E_UMS )
	{
	    status = ERRinit_messages( fake_path, fake_index );
	    if( status != ERR_S_SUCCESS )
	    {
		/*  Cannot successfully initialize -- something may be
		 *  wrong with the product configuration !
	 	 */
		_NFMRdebug(( fname, "ERRinit_messages <0x%.8x>\n",
			    status ));
		sprintf( msg, "%s", "NFM : ** SEVERE ERROR **  Cannot initialize message subsystem");
		fprintf( ALFconsole, "\n%s\n", msg );
	    }
	    else
	    {
	 	/*  We could initialize so get the message */
		err_status = ERRget_message( msg );
	 	if( err_status != ERR_S_SUCCESS )
		{
		    _NFMRdebug(( fname, "ERRget_message(2) <0x%.8x>\n",
				err_status ));
		    sprintf( msg, "%s", "NFM : ** SEVERE ERROR ** : Cannot get messages after successful subsystem initialization" );
		    fprintf( ALFconsole, "\n%s\n", msg );
		}
	    }
	    reset_flag = 1;

	}  /*  end  if( err_status == ERR_E_UMS )  */

	_NFMRdebug(( fname, "ERRget_message(1) <0x%.8x>\n", err_status ));
	sprintf( msg, "%s", "NFM : **  SEVERE ERROR ** : Cannot get messages after successful subsystem initialization" );
	fprintf( ALFconsole, "\n%s\n", msg );
    }   /* end  if( err_status != ERR_S_SUCCESS ) */

    /*  Determine if this is an informational message, in which case,
     *  the error status is reset to NFM_S_SUCCESS so that it falls
     *  through the 'set_to_state' logic properly.
     */
    status = UMSMsgCode( id, error_number,UMS_SUPPRESS_COMP|UMS_SUPPRESS_EXT,
			 NULL, NULL, NULL  );
    if( status != UMS_S_SUCCESS )
    {
         error_number = NFM_S_SUCCESS;
         strcpy( msg, "Error determining message severity" );
    }
    else
    {
	_NFMRdebug(( fname, "Message Type <%s>\n", id ));
        if( strcmp( id, "I" ) == 0 )
   	    error_number = NFM_S_SUCCESS;   
    }
    fclose( ALFconsole );
    
    _NFMRdebug(( fname, "Error Number <0x%.8x>\n", error_number ));
    _NFMRdebug(( fname, "Message <%s>\n", msg ));

    sprintf (id, "%ld", user_id);
    sprintf (err_no, "%ld", error_number );
    strcpy (str, id);
    strcat (str, "\1");
    strcat (str, application);
    strcat (str, "\1");
    strcat (str, err_no);
    strcat (str, "\1");
    strcat (str, msg );
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_SET_TO_STATE, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffers <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    /*  We are initializing and reseting messages for the application if
     *  reset_flag is set.
     */
    if( reset_flag == 1 )
	ERRreset_struct();
 
    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}
 
long NFMRset_wf_state ( application, err_number, err_message )

char    *application;  /* i - application name */
long    err_number;    /* i - error number */
char    *err_message;  /* i - error message */
{

MEMptr info = NULL;
char   str[1028];
char   err_no[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRset_wf_state";

    _NFMRdebug(( fname, "application   : <%s>\n", application));
    _NFMRdebug(( fname, "error number  : <0x%.8x>\n", err_number ));
    _NFMRdebug(( fname, "error message : <%s>\n", err_message ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "n_application", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "error_no", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "error_msg", "char(512)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }

    sprintf( err_no, "%ld", err_number );
    strcpy (str, application);
    strcat (str, "\1");
    strcat (str, err_no);
    strcat (str, "\1");
    strcat (str, err_message );
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_SET_WF_STATE, info);
    _NFMRdebug(( fname, "Send Buffer = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffers <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


