#include "machine.h"
#include "NFMRextern.h"

#define  BUFFER_SIZE  1000

/*  This routine packages the storage area number, file numbers and
 *  chosen label into buffers and sends them back to the server 
 *  to actually perform the archive.
 */

long  NFMRarchive_files( server, env, user, passwd, 
		   sa_no, label, flist, msg_buffer )
    char   *server;
    char   *env;
    char   *user;
    char   *passwd;
    char   *sa_no;		/* i - chosen storage area number */
    char   *label;		/* i - chosen label OR 'SYSLAB' */
    MEMptr flist;	        /* i - list of chosen file numbers */
    MEMptr *msg_buffer; 	/* o - return message buffer */
{
    long   status;
    long   ret_status;

    char   str[256];
 
    MEMptr file_info = NULL;
    MEMptr info      = NULL;

    static char *fname = "NFMRarchive_files";
 
    _NFMRdebug(( fname, "Server : <%s>\n", server ));
    _NFMRdebug(( fname, "Env    : <%s>\n", env ));
    _NFMRdebug(( fname, "User   : <%s>\n", user ));
    _NFMRdebug(( fname, "Sa No  : <%s>\n", sa_no ));
    _NFMRdebug(( fname, "Label  : <%s>\n", label ));
    if( _NFMdebug_st.NFMRdebug_on )
	MEMprint_buffers( "FILE LIST", flist, _NFMdebug_st.NFMRdebug_file);

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format( info, "server", "char(15)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( info, "env", "char(15)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_USERNAME );
    status = MEMwrite_format( info, "user", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_PASSWD );
    status = MEMwrite_format( info, "passwd", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", INTEGER );
    status = MEMwrite_format( info, "sano", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_LABEL );
    status = MEMwrite_format( info, "label", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
   
    sprintf( str, "%s\1%s\1%s\1%s\1%s\1%s\1", 
	     server, env, user, passwd, sa_no, label );

    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMappend( flist, info );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &info );
        _NFMRdebug(( fname, "MEMappend <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_ARCHIVE_FILE , info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
	MEMclose (&file_info );
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, 
					msg_buffer);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));

    if( ret_status != NFM_S_SUCCESS )
	return( ret_status );

    if( _NFMdebug_st.NFMRdebug_on )
        MEMprint_buffers( "MSG", *msg_buffer, _NFMdebug_st.NFMRdebug_file);

    return( NFM_S_SUCCESS );
}

long  NFMRbackup_files( server, env, user, passwd, 
		   sa_no, label, flist, msg_buffer )
    char   *server;
    char   *env;
    char   *user;
    char   *passwd;
    char   *sa_no;		/* i - chosen storage area number */
    char   *label;		/* i - chosen label OR 'SYSLAB' */
    MEMptr flist;		/* i - list of chosen file numbers */
    MEMptr *msg_buffer;		/* o - return message buffer */
{
    long   status;
    long   ret_status;

    char   str[256];
 
    MEMptr info      = NULL;

    static char *fname = "NFMRbackup_files";
 
    _NFMRdebug(( fname, "Server : <%s>\n", server ));
    _NFMRdebug(( fname, "Env    : <%s>\n", env ));
    _NFMRdebug(( fname, "User   : <%s>\n", user ));
    _NFMRdebug(( fname, "Sa No  : <%s>\n", sa_no ));
    _NFMRdebug(( fname, "Label  : <%s>\n", label ));
    if( _NFMdebug_st.NFMRdebug_on )
        MEMprint_buffers( "FILE LIST", flist, _NFMdebug_st.NFMRdebug_file);

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format( info, "server", "char(15)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( info, "env", "char(15)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_USERNAME );
    status = MEMwrite_format( info, "user", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_PASSWD );
    status = MEMwrite_format( info, "passwd", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", INTEGER );
    status = MEMwrite_format( info, "sano", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_LABEL );
    status = MEMwrite_format( info, "label", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
   
    sprintf( str, "%s\1%s\1%s\1%s\1%s\1%s\1", 
	     server, env, user, passwd, sa_no, label );

    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMappend( flist, info );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &info );
        _NFMRdebug(( fname, "MEMappend <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_BACKUP_FILE , info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, 
			msg_buffer);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));

    if( ret_status != NFM_S_SUCCESS )
	return( ret_status );

    if( _NFMdebug_st.NFMRdebug_on )
        MEMprint_buffers( "MSG", *msg_buffer, _NFMdebug_st.NFMRdebug_file);

    return( NFM_S_SUCCESS );
}

/*  This routine packs up the chosen file link numbers for restore and 
 *  sends them back to the server.
 */
long  NFMRrestore_files( server, env, user, passwd, flist, msg_buffer )    
    char 	   *server;
    char	   *env;
    char	   *user;
    char 	   *passwd;
    MEMptr	   flist;	/* i - list of chosen file numbers */
    MEMptr	   *msg_buffer; /* o - return message buffer */
{
    long   status;
    long   ret_status;

    char   str[256];

    MEMptr info      = NULL;

    static char *fname = "NFMRrestore_files";

    _NFMRdebug(( fname, "Server : <%s>\n", server ));
    _NFMRdebug(( fname, "Env    : <%s>\n", env ));
    _NFMRdebug(( fname, "User   : <%s>\n", user ));
    if( _NFMdebug_st.NFMRdebug_on )
        MEMprint_buffers( "FILE LIST", flist, _NFMdebug_st.NFMRdebug_file);

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
 	_NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_NODENAME );
    status = MEMwrite_format( info, "server", str);
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( info, "env", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_USERNAME );
    status = MEMwrite_format( info, "user", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_PASSWD );
    status = MEMwrite_format( info, "passwd", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "%s\1%s\1%s\1%s\1", server, env, user, passwd );

    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &info );
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMappend( flist, info );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &info );
	_NFMRdebug(( fname, "MEMappend <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_RESTORE_FILE , info );
    _NFMRdebug(( fname, "Send Buffer <0x%.8x>\n", status ));
    if( status != NFM_S_SUCCESS )
    {
	MEMclose (&info );
	return( status );
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, 
			msg_buffer);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer <0x%.8x>\n", status ));
    if (status != NFM_S_SUCCESS)
        return( status );

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));
    if(ret_status != NFM_S_SUCCESS )
	return( ret_status );

    if( _NFMdebug_st.NFMRdebug_on )
        MEMprint_buffers( "MSG", *msg_buffer, _NFMdebug_st.NFMRdebug_file);
 
    return( NFM_S_SUCCESS );
}

long  NFMRdelete_files( server, env, user, passwd, flist )    
    char	   *server;
    char 	   *env;
    char           *user;
    char           *passwd;
    MEMptr         flist;	/* list of chosen file numbers */
{
    long   status;
    long   ret_status;
    char   str[100];
    MEMptr info = NULL;
    static char *fname = "NFMRdelete_files";

    _NFMRdebug(( fname, "Server : <%s>\n", server ));
    _NFMRdebug(( fname, "Env    : <%s>\n", env ));
    _NFMRdebug(( fname, "User   : <%s>\n", user ));
    if( _NFMdebug_st.NFMRdebug_on )
        MEMprint_buffers( "FILE LIST", flist, _NFMdebug_st.NFMRdebug_file);

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
 	_NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_NODENAME );
    status = MEMwrite_format( info, "server", str);
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( info, "env", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_USERNAME );
    status = MEMwrite_format( info, "user", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "char(%d)", NFM_PASSWD );
    status = MEMwrite_format( info, "passwd", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( str, "%s\1%s\1%s\1%s\1", server, env, user, passwd );

    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &info );
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMappend( flist, info );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &info );
	_NFMRdebug(( fname, "MEMappend <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_DEL_FILES , info );
    _NFMRdebug(( fname, "Send Buffer <0x%.8x>\n", status ));    
    if( status != NFM_S_SUCCESS )
        return (status);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer <0x%.8x>\n", status ));    
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );
}

