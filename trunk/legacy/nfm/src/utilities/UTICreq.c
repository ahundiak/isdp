#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMtypes.h"
#include "MSGstruct.h"
#include "WFcommands.h"
#include "UTIdef.h"
#include "UTIclient.h"
#include "UTIextern.h"
#include "UTImacros.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "NFMRextern.h"
#include <pwd.h>
#include <sys/types.h>
#include <sys/stat.h>

#define    BUFFER_SIZE           1000
#define    NFM_DEBUG_SUBSYSTEMS  15
#define    NFM_DEBUG_FILE_SIZE   80

char ums_msg[300];

extern MSGptr NFMRmsg_ptr;
/**extern struct NFMRglobal_st NFMRglobal;**/

/*  This is the UTILITIES ( UTI ) client request layer which sets up
 *  network requests and buffers to be sent to the NFMserver.  The
 *  function included in this layer are:
	
    UTICconnect		- connects to the NFMserver
    UTIClogin		- logs-in to the NFMserver
    UTICvalidate_user	- validates the user for the requested utility
    UTICupdate_db	- sends status' back to determine database updates
    UTICterminate	- terminates connection to NFMserver
 */


UTICnfm_login( hdr )
    script_header hdr;
{
    long   status;
    char   d_passwd[30];
    
    NFMdecrypt( hdr->passwd, d_passwd );

    _UTI_dbg( "UTICnfm_login : password : %s", hdr->passwd );
    _UTI_dbg( "UTICnfm_login : decrypt password : %s", d_passwd );

    fprintf( stdout, "Nfmutil :  Connecting to Server <%s> ...\n",
	     hdr->server );

    status = NFMRconnect( hdr->server );
    _UTI_dbg ("UTICnfm_login : NFMRconnect <%lx>", status );
   
    _UTI_dbg ("UTICnfm_login : NETid <%d>", NFMRglobal.NETid );
    if( status != NFM_S_SUCCESS )
    {
	UTICerror( UTI_E_SCONNECT, NULL );
	return( UTI_E_FAILURE );
    }

    fprintf( stdout, "Nfmutil :  Logging into Environment <nfme_%s> ...\n",
	     hdr->env );
    status = UTIClogin( hdr->env, hdr->username, d_passwd );
    if( status != UTI_S_SUCCESS )
	return( status );

    return( UTI_S_SUCCESS );
}

UTIClogin( nfmenv, nfmlogin, nfmpassword )
    char *nfmenv;
    char *nfmlogin;
    char *nfmpassword;
{
    long   status;
    char full_nfmenv[20];

    _UTI_dbg ("UTIClogin : nfmlogin : <%s>", nfmlogin );
    _UTI_dbg ("UTIClogin : nfmpassword : <%s>", nfmpassword );
    _UTI_dbg ("UTIClogin : nfmenv : <%s>", nfmenv );

/*****************Try New log_in instead of login **
    MEMptr login_attr = NULL;
    MEMptr login_data = NULL;
    MEMptr login_wf = NULL;
    MEMptr login_value = NULL;

    _UTI_dbg ("UTIClogin : nfmlogin : <%s>", nfmlogin );
    _UTI_dbg ("UTIClogin : nfmpassword : <%s>", nfmpassword );
    _UTI_dbg ("UTIClogin : nfmenv : <%s>", nfmenv );

    status = NFMRquery_login_attributes( "NFM","nfme_", &login_attr,
		 &login_data, &login_value, &login_wf );
    if( status != NFM_S_SUCCESS )
    {
	UTICerror( UTI_E_SLOGIN, NULL );
        _UTI_dbg ("UTIClogin : query_login_attributes : <0x%.8x>", status );
        MEMclose( &login_attr );
        MEMclose( &login_data );
	MEMclose( &login_wf );
        MEMclose( &login_value );
        return( UTI_E_FAILURE );
    }

    status = MEMbuild_array( login_attr );
    if( status != MEM_S_SUCCESS)
    {
	UTICerror( UTI_E_MEMBUILD, NULL );
        _UTI_dbg ("UTIClogin : MEMbuild->login_attr : <0x%.8x>", status );
        MEMclose( &login_attr );
        MEMclose( &login_data );
	MEMclose( &login_wf );
        MEMclose( &login_value );
        return( UTI_E_FAILURE );
    }

    status = MEMbuild_array( login_data );
    if( status != MEM_S_SUCCESS)
    {
	UTICerror( UTI_E_MEMBUILD, NULL );
        _UTI_dbg ("UTIClogin : MEMbuild->login_data : <0x%.8x>", status );
        MEMclose( &login_attr );
        MEMclose( &login_data );
	MEMclose( &login_wf );
        MEMclose( &login_value );
        return( UTI_E_FAILURE );
    }

    status = MEMwrite_data( login_data, nfmlogin, 1, 1 );
    if( status != MEM_S_SUCCESS)
    {
	UTICerror( UTI_E_MEMWRITEDATA, NULL );
        _UTI_dbg ("UTIClogin : MEMwrite_data->nfmlogin : <0x%.8x>", status );
        MEMclose( &login_attr );
        MEMclose( &login_data );
	MEMclose( &login_wf );
        MEMclose( &login_value );
        return( UTI_E_FAILURE );
    }
    status = MEMwrite_data( login_data, nfmpassword, 1, 2 );
    if( status != MEM_S_SUCCESS)
    {
	UTICerror( UTI_E_MEMWRITEDATA, NULL );
        _UTI_dbg ("UTIClogin : MEMwrite_data->nfmpassword : <0x%.8x>", status );
        MEMclose( &login_attr );
        MEMclose( &login_data );
	MEMclose( &login_wf );
        MEMclose( &login_value );
        return( UTI_E_FAILURE );
    }
    status = MEMwrite_data( login_data, nfmenv, 1, 3 );
    if( status != MEM_S_SUCCESS)
    {
	UTICerror( UTI_E_MEMWRITEDATA, NULL );
        _UTI_dbg ("UTIClogin : MEMwrite_data->env : <0x%.8x>", status );
        MEMclose( &login_attr );
        MEMclose( &login_data );
	MEMclose( &login_wf );
        MEMclose( &login_value );
        return( UTI_E_FAILURE );
    }

    MEMprint_buffers("Login Attr", login_attr, "/usr/tmp/util_login.dbg");
    MEMprint_buffers("Login Data", login_data, "/usr/tmp/util_login.dbg");
    MEMprint_buffers("Login Wf", login_wf, "/usr/tmp/util_login.dbg");

***************************END OF old login code *****/

/*******/
    sprintf(full_nfmenv, "nfme_%s", nfmenv);
    status = NFMRlog_in(nfmlogin, nfmpassword,full_nfmenv, "NFM" );
/*******/
/********
    status = NFMRlogin( login_attr, login_data, login_wf, &NFMuser_id );
    _UTI_dbg ("UTIClogin : user_id  : <%ld>", NFMuser_id );

    MEMclose( &login_attr );
    MEMclose( &login_data );
    MEMclose( &login_wf );
    MEMclose( &login_value );

*******/
    if( status != NFM_S_SUCCESS )
    {
	UTICerror( UTI_E_INVALIDUSER, nfmlogin );
        return( UTI_E_FAILURE );
    }
    
    return( UTI_S_SUCCESS );
}

/* 
 Doc: UTICupdate_db
 
 Abstract:
     This function directs the server to update the nfm database
     according to the status sent to it.
     
 Returns:
       0 - Success
    -72 - Invalid user name/password combination
         
 History:
     cmd    10-04-1989    Creation
     
 */

UTICupdate_db( group_no, scr_status, utility, no_copies )
    int		group_no;
    long	scr_status;
    int		utility;
    int       	no_copies;
{
    long	status = 0;
    long	ret_status = 0;

    char	str[256];
    char	int_to_asc[20];

    MEMptr	info = NULL;

    _UTI_dbg( "%s", "Enter UTICupdate_db" );
    _UTI_dbg( "UTICupdate_db: user_id       : <%ld>", NFMuser_id );
    _UTI_dbg( "UTICupdate_db: group_no      : <%d>",  group_no );
    _UTI_dbg( "UTICupdate_db: script_status : <%ld>", scr_status );
    _UTI_dbg( "UTICupdate_db: utility       : <%d>",  utility );
    _UTI_dbg( "UTICupdate_db: storage_no    : <%d>",  UTI_CLIENT_SA );
    _UTI_dbg( "UTICupdate_db: no_copies     : <%d>",  no_copies );

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICupdate_db: MEMopen : <0x%.8x>", status );
	UTICerror( UTI_E_MEMOPEN, NULL );
	return( UTI_E_FAILURE );
    }
   
/************BUFFER IS CHANGED
    status = MEMwrite_format( info, "user_id", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICupdate_db: MEMwrite_format->user_id : <0x%.8x>", status );
	UTICerror( UTI_E_MEMWRITEFORMAT, NULL );
	return( UTI_E_FAILURE );
    }
****************************/

    status = MEMwrite_format( info, "group_no", "char(5)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICupdate_db: MEMwrite_format->group_no : <0x%.8x>", status );
	UTICerror( UTI_E_MEMWRITEFORMAT, NULL );
	return( UTI_E_FAILURE );
    }

    status = MEMwrite_format( info, "status", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICupdate_db: MEMwrite_format->status : <0x%.8x>", status );
	UTICerror( UTI_E_MEMWRITEFORMAT, NULL );
	return( UTI_E_FAILURE );
    }

    status = MEMwrite_format( info, "utility", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICupdate_db: MEMwrite_format->utility : <0x%.8x>", status );
	UTICerror( UTI_E_MEMWRITEFORMAT, NULL );
	return( UTI_E_FAILURE );
    }

    status = MEMwrite_format( info, "sano", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICupdate_db: MEMwrite_format->sano : <0x%.8x>", status );
	UTICerror( UTI_E_MEMWRITEFORMAT, NULL );
	return( UTI_E_FAILURE );
    }

    status = MEMwrite_format( info, "copies", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICupdate_db: MEMwrite_format->copies : <0x%.8x>", status );
	UTICerror( UTI_E_MEMWRITEFORMAT, NULL );
	return( UTI_E_FAILURE );
    }
  
/*********** THIS BUFFER IS CHANGED
    sprintf( int_to_asc, "%ld", NFMuser_id );
    strcpy( str, int_to_asc );
    strcat( str, "\1" );
**********************************/

    sprintf( int_to_asc, "%d", group_no );
    strcpy( str, int_to_asc );
    strcat( str, "\1" );

    sprintf( int_to_asc, "%ld", scr_status );
    strcat( str, int_to_asc );
    strcat( str, "\1" );

    sprintf( int_to_asc, "%d", utility );
    strcat( str, int_to_asc );
    strcat( str, "\1" );

    sprintf( int_to_asc, "%d", UTI_CLIENT_SA );
    strcat( str, int_to_asc );
    strcat( str, "\1" );

    sprintf( int_to_asc, "%d", no_copies );
    strcat( str, int_to_asc );
    strcat( str, "\1" );

    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )    
    {
	MEMclose( &info );
        _UTI_dbg( "UTICupdate_db: MEMwrite : <0x%.8x>", status );
	UTICerror( UTI_E_MEMWRITE, NULL );
	return( UTI_E_FAILURE );
    }

    fprintf( stdout, "%s\n", "Nfmutil :  Updating Server Database ..." );

    _UTI_dbg( "UTICupdate_db: (Before) NETid: %d", NFMRglobal.NETid);
    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_UTILITIES_UPDATE, info );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICupdate_db: NFMcl_send_buffer : <0x%.8x>", status);
        _UTI_dbg( "UTICupdate_db: NETid: %d", NFMRglobal.NETid);

	UTICerror( UTI_E_SENDBUFFER, NULL );
	return( UTI_E_FAILURE );
    }
 
    MEMclose( &info );
    status = NFMRreceive_one_buffer( &NFMRglobal.NETid, &ret_status, &info );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICupdate_db: NFMRreceive_one_buffer : <0x%.8x>", status );
	UTICerror( UTI_E_RECEIVEBUFFER, NULL );
	return( UTI_E_FAILURE );
    }
    if( ret_status != UTI_S_SUCCESS )
    {
        _UTI_dbg( "UTICupdate_db: UNSUCCESSFUL : <0x%.8x>", ret_status );
	UTICerror( UTI_E_NOTUPDATED, NULL );	
	MEMclose( &info );
	return( UTI_E_FAILURE );
    }
    _UTI_dbg( "UTICupdate_db: SUCCESSFUL : <0x%.8x>", ret_status );
    status = UTIprocess_server_buffer( info );
    MEMclose( &info );
    return( UTI_S_SUCCESS );
}

/* 
 Doc: UTICvalidate_user
 
 Abstract:
    This routine validates the user for the given utility. It is only
    called when this is a locally invoked execution.
     
 Returns:
         
 History:
     cmd    10-12-1989    Creation
     
 */

UTICvalidate_user( utility )
    long  utility;
{
    long  status;

    _UTI_dbg( "%s", "Enter UTICvalidate_user" );
    _UTI_dbg( "UTICvalidate_user : User_id <%ld>", NFMuser_id );
    _UTI_dbg( "UTICvalidate_user : Utility <%ld>", utility );

    if( utility == UTI_ARCHIVE )
	status = NFMRvalidate_user_access( NFMuser_id,ARCHIVE,"","","","","");
    else if( utility == UTI_BACKUP )
	status = NFMRvalidate_user_access( NFMuser_id,BACKUP, "","","","","");
    else if( utility == UTI_RESTORE )
	status = NFMRvalidate_user_access( NFMuser_id,RESTORE,"","","","","");
    else
    {
        _UTI_dbg( "UTICvalidate_user: Bad utility <%ld>", utility );
	UTICerror( UTI_E_INVALIDUSER, NULL );	
	return( UTI_E_FAILURE );
    }
    if( status != NFM_S_SUCCESS )
    {
        _UTI_dbg( "UTICvalidate_user: UNSUCCESSFUL : <0x%.8x>", status );
	UTICerror( UTI_E_INVALIDUSER, NULL );	
 	return( UTI_E_FAILURE );
    }
    
    return( UTI_S_SUCCESS );
}

/* 
 Doc: UTICerr_to_srv
 
 Abstract:

     This routine sends an UTI error number, character descriptor
     (if relevant), and NFM error number ( if relevant ) to the NFM 
     server.
     
 Returns:
         
 History:
     cmd    10-12-1989    Creation
     
 */

UTICerr_to_srv( uti_error, msg_str, nfm_error )
    long   uti_error;
    char   *msg_str;
    long   nfm_error;
{
    long	status = 0;
    long	ret_status = 0;

    char	str[256];
    char	int_to_asc[20];

    MEMptr	info = NULL;

    _UTI_dbg( "%s", "Enter UTICerr_to_srv" );
    _UTI_dbg( "UTICerr_to_srv: user_id : <%ld>", NFMuser_id );
    _UTI_dbg( "UTICerr_to_srv: uti_error : <%ld>", uti_error );
    _UTI_dbg( "UTICerr_to_srv: str : <%s>" , msg_str );
    _UTI_dbg( "UTICerr_to_srv: nfm_error : <%ls>" , nfm_error );  

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICerr_to_srv: MEMopen : <0x%.8x>", status );
	UTICerror( UTI_E_MEMOPEN, NULL );
	return( UTI_E_FAILURE );
    }
   
    status = MEMwrite_format( info, "user_id", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICerr_to_srv: MEMwrite_format->user_id : <0x%.8x>", status );
	UTICerror( UTI_E_MEMWRITEFORMAT, NULL );
	return( UTI_E_FAILURE );
    }

    status = MEMwrite_format( info, "uti_error", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICerr_to_srv: MEMwrite_format->uti_error : <0x%.8x>", 
		   status );
	UTICerror( UTI_E_MEMWRITEFORMAT, NULL );
	return( UTI_E_FAILURE );
    }

    status = MEMwrite_format( info, "msg_str", "char(30)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICerr_to_srv: MEMwrite_format->msg_str : <0x%.8x>", status );
	UTICerror( UTI_E_MEMWRITEFORMAT, NULL );
	return( UTI_E_FAILURE );
    }

    status = MEMwrite_format( info, "nfm_error", "char(10)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICerr_to_srv: MEMwrite_format->nfm_error : <0x%.8x>", 
		   status );
	UTICerror( UTI_E_MEMWRITEFORMAT, NULL );
	return( UTI_E_FAILURE );
    }
    memset( int_to_asc, NULL, 20 );
    sprintf( int_to_asc, "%ld", NFMuser_id );
    strcpy( str, int_to_asc );
    strcat( str, "\1" );

    memset( int_to_asc, NULL, 20 );
    sprintf( int_to_asc, "%ld", uti_error );
    strcat( str, int_to_asc );
    strcat( str, "\1" );

    strcat( str, msg_str );
    strcat( str, "\1" );

    memset( int_to_asc, NULL, 20 );
    sprintf( int_to_asc, "%ld", nfm_error );
    strcat( str, int_to_asc );
    strcat( str, "\1" );

    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )    
    {
	MEMclose( &info );
        _UTI_dbg( "UTICerr_to_srv: MEMwrite : <0x%.8x>", status );
	UTICerror( UTI_E_MEMWRITE, NULL );
	return( UTI_E_FAILURE );
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_UTILITIES_ERROR, info );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICerr_to_srv: NFMcl_send_buffer : <0x%.8x>", status );
	UTICerror( UTI_E_SENDBUFFER, NULL );
	return( UTI_E_FAILURE );
    }
 
    MEMclose( &info );

    status = NFMRreceive_one_buffer( &NFMRglobal.NETid, &ret_status, &info );
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &info );
        _UTI_dbg( "UTICerr_to_srv: NFMRreceive_one_buffer : <0x%.8x>", status );
	UTICerror( UTI_E_RECEIVEBUFFER, NULL );
	return( UTI_E_FAILURE );
    }
    if( ret_status != NFM_S_SUCCESS )
    {
        _UTI_dbg( "UTICerror: UNSUCCESSFUL : <0x%.8x>", ret_status );
	UTICerror( UTI_E_NOTUPDATED, NULL );	
	MEMclose( &info );
	return( UTI_E_FAILURE );
    }
    _UTI_dbg( "UTICerror: SUCCESSFUL : <0x%.8x>", ret_status );
    MEMclose( &info );
    return( UTI_S_SUCCESS );
}
/* 
 Doc: NFMRdebug
 
 Abstract:
     This function will turn debug on for the NFMserver.
     
 Returns:
       0 - Success
      <0 - Failure
         
 History:
     kht    8-31-1989    Creation
     
 */
 
long UTICdebug (nfm, nfm_file, net, net_file, sql, sql_file, mem, mem_file)

    int  nfm;       /* i - nfm debug on (1) or off (0) */
    char *nfm_file; /* i - nfm debug_file */
    int  net;       /* i - net debug on (1) or off (0) */
    char *net_file; /* i - net debug_file */
    int  sql;       /* i - sql debug on (1) or off (0) */
    char *sql_file; /* i - sql debug_file */
    int  mem;       /* i - mem debug on (1) or off (0) */
    char *mem_file; /* i - mem debug_file */
{
    MEMptr info = NULL;
    char   str[512];
    long   status = 0;
    long   ret_status = 0;
    char   flag[2];

    _UTI_dbg ("%s", "UTIdebug");
    _UTI_dbg ("UTIdebug : NFM      : <%d>", nfm);
    _UTI_dbg ("UTIdebug : NFM file : <%s>", nfm_file);
    _UTI_dbg ("UTIdebug : NET      : <%d>", net);
    _UTI_dbg ("UTIdebug : NET file : <%s>", net_file);
    _UTI_dbg ("UTIdebug : SQL      : <%d>", sql);
    _UTI_dbg ("UTIdebug : SQL file : <%s>", sql_file);
    _UTI_dbg ("UTIdebug : MEM      : <%d>", mem);
    _UTI_dbg ("UTIdebug : MEM file : <%s>", mem_file);

/*  Set NFMR debug to be same as NFM debug 
 */
    NFMRmsg_ptr.debug_on = nfm;
    strcpy( NFMRmsg_ptr.debug_file, nfm_file );

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : MEMopen : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "nfm", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "nfm_file", "char(40)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "net", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "net_file", "char(40)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "sql", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "sql_file", "char(40)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "mem", "char(2)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "mem_file", "char(40)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    sprintf (flag, "%d", nfm);
    strcpy (str, flag);
    strcat (str, "\1");
    strcat (str, nfm_file);
    strcat (str, "\1");

    sprintf (flag, "%d", net);
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, net_file);
    strcat (str, "\1");

    sprintf (flag, "%d", sql);
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, sql_file);
    strcat (str, "\1");

    sprintf (flag, "%d", mem);
    strcat (str, flag);
    strcat (str, "\1");
    strcat (str, mem_file);
    strcat (str, "\1");

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : MEMwrite : <0x%.8x>", status);
        return (status);
        }
    
    _UTI_dbg ("call NFMcl_send_buffer <%d>", NFMRglobal.NETid);

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_DEBUG, info);
    _UTI_dbg ("UTIdebug : Send Buffer : = <0x%.8x>", status);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : NFMcl_send_buffer : <0x%.8x>", status);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        _UTI_dbg ("UTIdebug : NFMRreceive_one_buffer : <0x%.8x>", status);
        return (status);
        }

    _UTI_dbg ("UTIdebug : Return Status : <0x%.8x>", ret_status);

    MEMclose (&info);

    return (ret_status); 
}

/*  This routine connects to server, does a login and validates
 *  the user for this UTILITIY.
 */
UTICtalk( hdr, dbg )
    script_header hdr;
    srvdbg        dbg;
{
    int	   status;
    long   utility;

    MEMptr login_defaults = NULL;

    _UTI_dbg ( "UTICtalk : Enter UTICtalk for utility : <%s>", hdr->utility );

/*  We must do a server login and validate the user.
 */
    _UTI_dbg("UTICtalk : server   : %s", hdr->server );
    _UTI_dbg("UTICtalk : env      : %s", hdr->env );
    _UTI_dbg("UTICtalk : username : %s", hdr->username );
    _UTI_dbg("UTICtalk : passwd   : %s", hdr->passwd );

    status = UTICnfm_login( hdr );
    if( status != UTI_S_SUCCESS )
        return( UTI_E_FAILURE );

    status = NFMRget_user_defaults( NFMuser_id, &login_defaults );
    _UTI_dbg( "UTICtalk : NFMRget_user_defaults status <0x%.8x>", status );

    if( UTIdebug )
    {
/*  Set up server debug
 */
        fprintf( stdout, "%s\n", "Nfmutil :  Turning on Server Debug ..." );
        status = UTICall_debug( dbg->val, dbg->file_name,
	        dbg->next->val, dbg->next->file_name,
		dbg->next->next->val, dbg->next->next->file_name,
		dbg->next->next->next->val,dbg->next->next->next->file_name );

        _UTI_dbg( "UTIdebug_setup : UTICdebug status <%d>", status );
    }

/*  Validate with username password for this utility
*/
    fprintf( stdout, "%s\n", "Nfmutil :  Validating User Access ..." );
    utility = atol( hdr->utility );
    status = UTICvalidate_user( utility );
    if( status != UTI_S_SUCCESS )
        return( UTI_E_FAILURE );

    return( UTI_S_SUCCESS );
}

/*  This routine processes the list of files sent back from the server.
 *  These are the files to be deleted from the local directory.
 */
UTIprocess_server_buffer( info )
    MEMptr	info;
{
    long	status;
    int		i;
    char	**data_ptr;

    _UTI_dbg( "%s", "Enter UTIproc_server : " );
    status = MEMbuild_array( info );
    if( status != MEM_S_SUCCESS)
    {
	UTICerror( UTI_E_MEMBUILD, NULL );
        _UTI_dbg ("UTICproc_server : MEMbuild : <0x%.8x>", status );
        return( UTI_E_FAILURE );
    }
    data_ptr = (char**) info->data_ptr;

    for( i=0; i<info->rows; ++i )
    {
	_UTI_dbg( "UTICproc_server : Deleting <%s>\n", data_ptr[i] );
	unlink( data_ptr[i] );
    }    

    _UTI_dbg( "%s", "Exit UTIproc_server : " );
    return( UTI_S_SUCCESS );
}

UTICall_debug (nfm, nfm_file, net, net_file, sql, sql_file, uti, uti_file)

    int  nfm;       /* i - nfm debug on (1) or off (0) */
    char *nfm_file; /* i - nfm debug_file */
    int  net;       /* i - net debug on (1) or off (0) */
    char *net_file; /* i - net debug_file */
    int  sql;       /* i - sql debug on (1) or off (0) */
    char *sql_file; /* i - sql debug_file */
    int  uti;	    /* i - uti debug on (1) or off (0) */
    char *uti_file; /* i - uti debug_file */
{
    int  i;
    int  toggles[NFM_DEBUG_SUBSYSTEMS];
    long status;
    char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];

   
    for( i=0; i<NFM_DEBUG_SUBSYSTEMS; ++i )
    {
	toggles[i] = 0;
	strcpy( files[i], "/dev/console" );
    }
    if (net)
    {
        toggles[3] = 1;
        toggles[6] = 1;
        strcpy (files[6], net_file );
        strcpy (files[3], net_file );
    }

    if( nfm )
    {
        toggles[8] = 1;
        strcpy (files[8], nfm_file );
    }

    if( sql )
    {
        toggles[9] = 1;
        strcpy (files[9], sql_file );
    }

    if( uti )
    {
	toggles[12] = 1;
        strcpy (files[12], uti_file );
    }
  
    status = NFMRall_debug ( toggles, files );
    if( status != NFM_S_SUCCESS )
    {
        _UTI_dbg( "UTICall_debug: UNSUCCESSFUL : <0x%.8x>", status );
	UTICerror( UTI_E_INVALIDUSER, NULL );	
 	return( UTI_E_FAILURE );
    }
    return( UTI_S_SUCCESS );
}
