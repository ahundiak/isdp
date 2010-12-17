#include "machine.h"
#include "NFMRextern.h"

#define  BUFFER_SIZE  1000

long NFMRlog_in (user_name, password, environment, application)
 
   char            *user_name;      /*  I  Login user. */
   char            *password;       /*  I  Password for login user. */
   char            *environment;    /*  I  Environment to log into. Must
                                          specify application prefix
                                          ("nfme_"). */
   char            *application;    /*  I  Login application. */

{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRlog_in";

    _NFMRdebug(( fname, "user_name      : <%s>\n", user_name));
    _NFMRdebug(( fname, "environment    : <%s>\n", environment ));
    _NFMRdebug(( fname, "application     : <%s>\n", application));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_USERNAME );    
    status = MEMwrite_format (info, "user_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_PASSWD);    
    status = MEMwrite_format (info, "passwd", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(environment)+1) );
    status = MEMwrite_format (info, "environment", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_APPLICATION );
    status = MEMwrite_format (info, "application", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_USERNAME + NFM_PASSWD + NFM_APPLICATION + 20);

    strcpy (str, user_name);
    strcat (str, "\1");
    strcat (str, password);
    strcat (str, "\1");
    strcat (str, environment );
    strcat (str, "\1" );
    strcat (str, application);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    free (str);

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_LOG_IN, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug((fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}
