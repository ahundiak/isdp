#include "machine.h"
#include <stdio.h>

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
# include "CLI.h"
# include "NFMRstruct.h"
#else
# include "CLIerrordef.h"
# include "CLIstruct.h"
# include "CLIextern.h"
# include "NFMerrordef.h"
# include "proto.h"
#include <memcheck.h>
#endif

extern struct NFMRglobal_st NFMRglobal;

long  CLIconnect()
{
    long   status;
    long   err_no=NFM_S_SUCCESS;
    char   message[256]={"\0"};
    char   temp_str[60]={"\0"};
    char   *fname = "CLIconnect";


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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
    fprintf( CLIout_file, "CONNECT : Server <%s>\n",&CLIserver[5] );
    fprintf( stderr, "CONNECT : Server <%s>\n",&CLIserver[5] );

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
        status = NFMRconnect(CLIserver);
        ERRget_number(&err_no, &subsystem);
        ERRget_message(message);
#else
        status = NFMRconnect( CLIserver, CLIuser );
#endif
 
        if (status != NFM_S_SUCCESS)
        {
           _CLI_num( "CLIconnect Failed 2nd Pass : <0x%.8lx>", status );
	   CLIprint(CLIout_file,"Error connecting to server <%s> : %s", 
	         CLIserver, message);
	   CLIprint(stderr,"Error connecting to server <%s> : %s", 
	         CLIserver, message);
 	   return( CLI_E_FAILURE );
        }
    }

    fprintf( CLIout_file, "   Successful Connection.\n" );
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

    fprintf(CLIout_file, "DISCONNECT : Server <%s>\n", temp_str );
    fprintf(stderr, "DISCONNECT : Server <%s>\n", temp_str );


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
    status = NFMdisconnect (&NFMRglobal.NETid) ;
#else
    status = NFMRdisconnect () ;
#endif

    if( status != NFM_S_SUCCESS )
    {
       CLIprint(CLIout_file,"Error disconnecting from server <%s> : <0x%.8lx>",
                temp_str, status);
	CLIprint(stderr,"Error disconnecting from server <%s> : <0x%.8lx>",
                temp_str, status);
	return( CLI_E_FAILURE );
    }
    else
    {
	fprintf( CLIout_file, "   Successful Disconnect.\n" );
	fprintf( stderr, "   Successful Disconnect.\n" );
    }

    _CLI_str( "%s", "Exiting CLIdisconnect" );

    return( CLI_S_SUCCESS );
}
