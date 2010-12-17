#include "machine.h"
#include <stdio.h>
#include "MSGstruct.h"
#include "UTIclient.h"
#include "UTIdef.h"
#include "UTImacros.h"
#include "UTIstruct.h"
#include "DEBUG.h"

int  UTIdebug;
FILE *UTIconsole;

int  NETdebug_on;
FILE *NET_DEBUG_FILE;

long NETid;
int  NETprotocol;

int  NFMuser_id;
extern MSGptr NETmsg_ptr;

/*  This is the main for the NFM utilities client executable.  
 *  It talks to the NFM server AND functions locally by executing 
 *  shell scripts which were put here by the server. The shell script
 *  execution status' are returned to the server so the database can be
 *  updated. The client executable is invoked locally to execute shell
 *  scripts pertaining to OFF-LINE devices such as UTAPE, CTAPE, FDISK.
 *  Invoke the client executable locally by :
 *	> Nfmutil <script_name>
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
    long    status;
    srvdbg  NFMsrv_dbg;
    
    debug_setup( &NFMsrv_dbg );

    status = UTICinit_ums(argv[0]);
    if( status != UTI_S_SUCCESS )
    {
	fprintf( stdout, "Nfmutil :  Message subsystem NOT initialized\n");
        fprintf( stdout, "Nfmutil :  Exiting NFM OFF-LINE utility\n" );
	exit();
    }

    _NFMdebug_st.NETCdebug_on= 1;
    strcpy(_NFMdebug_st.NETCdebug_file,"/usr/tmp/net.dbg");
    if( argc == 1 )
	UTICrequest( NFMsrv_dbg );	        /* Local, get user inputs */
    else
	UTICdocommand( argv[1],NFMsrv_dbg );	/* Process entire command */

    fprintf( stdout, "Nfmutil :  Exiting NFM OFF-LINE utility\n" );
}
