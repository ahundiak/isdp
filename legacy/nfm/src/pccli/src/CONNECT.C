#include <stdio.h>


#ifdef UNIX
# include "CLI.h"
# include "NFMRstruct.h"
#ifdef EXPORT
#include "TFERdlpt.h"
#endif
#else
# include "CLIerrordef.h"
# include "CLIstruct.h"
# include "CLIextern.h"
# include "NFMerrordef.h"
# include "proto.h"
# include <memcheck.h>
#endif

extern struct NFMRglobal_st NFMRglobal;

long  CLIconnect()
{
    long   status;
    long   err_no=NFM_S_SUCCESS;
    char   message[256]={"\0"};
    char   temp_str[60]={"\0"};
    char   *fname = "CLIconnect";

#ifdef UNIX
    int subsystem;
#else
    char returned_string[256]={"\0"};
#endif

    _CLI_str( "%s", "Entering CLIconnect" );


    if ( strncmp (CLIserver,"nfms_",5) != 0)
    {
       strcpy (temp_str, CLIserver);
       sprintf( CLIserver, "nfms_%s", temp_str);
    }
#ifndef EXPORT
    fprintf( CLIout_file, "CONNECT : Server <%s>\n",&CLIserver[5] );
#endif
    fprintf( stderr, "CONNECT : Server <%s>\n",&CLIserver[5] );

#ifdef UNIX
    status = NFMRconnect(CLIserver);
    ERRget_number(&err_no, &subsystem);
    ERRget_message(message);
    ERRreset_struct();
#else
    status = NFMRconnect( CLIserver, CLIuser );
#endif
    if( status != NFM_S_SUCCESS )
    {
        _CLI_num( "CLIconnect Failed 1st Pass : <0x%.8lx>", status );
       
        strcpy (temp_str, &CLIserver[5]); 
        strcpy (CLIserver, temp_str);

#ifdef UNIX
        status = NFMRconnect(CLIserver);
        ERRget_number(&err_no, &subsystem);
        ERRget_message(message);
#else
        status = NFMRconnect( CLIserver, CLIuser );
#endif
 
        if (status != NFM_S_SUCCESS)
        {
           _CLI_num( "CLIconnect Failed 2nd Pass : <0x%.8lx>", status );
#ifndef EXPORT
	   CLIprint(CLIout_file,"Error connecting to server <%s> : %s", 
	         CLIserver, message);
#endif
	   CLIprint(stderr,"Error connecting to server <%s> : %s", 
	         CLIserver, message);
 	   return( CLI_E_FAILURE );
        }
    }

#ifndef EXPORT
    fprintf( CLIout_file, "   Successful Connection.\n" );
#endif
    fprintf( stderr, "   Successful Connection.\n" );

    _CLI_str( "%s : SUCCESSFUL", fname );

    return( CLI_S_SUCCESS );
}

long  CLIdisconnect()
{
    long  status = NFM_S_SUCCESS;
    char  temp_str[15];

    _CLI_str( "%s", "Entering CLIdisconnect" );

    if (strncmp (CLIserver, "nfms_", 5) == 0)
       strcpy (temp_str, &CLIserver[5]);
    else
       strcpy (temp_str, CLIserver);

#ifndef EXPORT
    fprintf(CLIout_file, "DISCONNECT : Server <%s>\n", temp_str );
#endif
    fprintf(stderr, "DISCONNECT : Server <%s>\n", temp_str );

#ifdef UNIX
    status = NFMdisconnect (&NFMRglobal.NETid) ;
#else
    status = NFMRdisconnect () ;
#endif

    if( status != NFM_S_SUCCESS )
    {
#ifndef EXPORT
       CLIprint(CLIout_file,"Error disconnecting from server <%s> : <0x%.8lx>",
                temp_str, status);
#endif
	CLIprint(stderr,"Error disconnecting from server <%s> : <0x%.8lx>",
                temp_str, status);
	return( CLI_E_FAILURE );
    }
    else
    {
#ifndef EXPORT
	fprintf( CLIout_file, "   Successful Disconnect.\n" );
#endif
	fprintf( stderr, "   Successful Disconnect.\n" );
    }

    _CLI_str( "%s", "Exiting CLIdisconnect" );

    return( CLI_S_SUCCESS );
}
