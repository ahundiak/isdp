#include "machine.h"
#include <stdio.h>
#include <inc.h>
#include "MSGstruct.h"
#include "UTIclient.h"
#include "UTIdef.h"
#include "UTImacros.h"
#include "UTIstruct.h"

int  UTIdebug;
FILE *UTIconsole;

int  NETdebug_on;
FILE *NET_DEBUG_FILE;

extern MSGptr NETmsg_ptr;
extern MSGptr NFMmsg_ptr;
long NETid;
int  NETprotocol;

int  NFMuser_id;

/*  This is the main for the NFM utilities client executable.  
 *  It talks to the NFM server AND functions locally by executing 
 *  shell scripts which were put here by the server. The shell script
 *  execution status' are returned to the server so the database can be
 *  updated. The client executable is invoked locally to execute shell
 *  scripts pertaining to OFF-LINE devices such as MTAPE.
 *  Invoke the client executable locally by :
 *	> NFMutil <script_name>
 *
 *		  <script_name>   -  name of shell script to execute.
 *
 *  If no parameters are given, the user is prompted for
 *  them. Once the script has executed, return signals are sent
 *  back to the server and the database is updated.
 */
 
main( argc, argv )
    int  argc;
    char *argv[];
{
    srvdbg  NFMsrv_dbg;

    debug_setup( &NFMsrv_dbg );

    NETmsg_ptr.debug_on = 1;
    strcpy(NETmsg_ptr.debug_file, "[]netdbg.out");
    
    NFMmsg_ptr.debug_on = 1;
    strcpy(NFMmsg_ptr.debug_file, "[]netdbg.out");


    if( argc == 1 )
	UTIVrequest( NFMsrv_dbg );	        /* Local, get user inputs */
    else
	UTIVdocommand( argv[1],NFMsrv_dbg );	/* Process entire command */

    fprintf( stdout, "NFMutil :  Exiting NFM OFF-LINE utility\n" );
}
