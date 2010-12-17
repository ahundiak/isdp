#include "machine.h"
#include <signal.h>
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMtypes.h"
#include "NFMSextern.h"
#include "UTIstruct.h"
#include "NETdef.h"
#include "NETstruct.h"
#include "ERR.h"

extern struct _ERRstruct _ERRstruct;

int IN_PIPE      = 0;
int OUT_PIPE     = 0;

int main (argc, argv)
   int   argc;
   char  *argv[];

{
long    status, cont_status;
long    cmd_status = 0;
int     in_command;
static  char *fname = "NFMSserver";
MEMptr  in_list = NULL;
FILE    *fopen ();
int     protocol_val = 0, pid;
char 	dbg_file[256];

int     i;
/*
   Changed the function return value from
   int to void as required - Vasu 01.02.94
*/
void Signal_function ();


   pid=getpid();

   switch( argc )
   {
    	case 1 :
	    break;

	case 2 :
	   _NFMtranslate_dbg_file (dbg_file,argv[1],pid);
	   _NFMdebug_st.NFMSdebug_on = 1;
	   strcpy (_NFMdebug_st.NFMSdebug_file, dbg_file );
           _NFMdebug_st.NFMdebug_on =  1;
           strcpy (_NFMdebug_st.NFMdebug_file, dbg_file);
  	   NFMmsg_ptr.debug_on = 1;
	   strcpy (NFMmsg_ptr.debug_file, dbg_file);
/* PS */
/*
           _NFMdebug_st.TLIdebug_on =  1;
           strcpy (_NFMdebug_st.TLIdebug_file, dbg_file);
*/
	   break;
	
	case 3 :
	   _NFMtranslate_dbg_file (dbg_file,argv[1],pid);
	   _NFMdebug_st.NFMSdebug_on = 1;
	   strcpy (_NFMdebug_st.NFMSdebug_file, dbg_file );
           _NFMdebug_st.NFMdebug_on =  1;
           strcpy (_NFMdebug_st.NFMdebug_file, dbg_file );
           NFMmsg_ptr.debug_on = 1;
           strcpy (NFMmsg_ptr.debug_file, dbg_file );
/* PS */
/*
           _NFMdebug_st.TLIdebug_on =  1;
           strcpy (_NFMdebug_st.TLIdebug_file, dbg_file);
*/

	   _NFMtranslate_dbg_file (dbg_file,argv[2],pid);
	   _NFMdebug_st.SQLdebug_on = 1;
 	   strcpy (_NFMdebug_st.SQLdebug_file, dbg_file );
	   break;

	case 4 :
	   _NFMtranslate_dbg_file (dbg_file,argv[1],pid);
	   _NFMdebug_st.NFMSdebug_on = 1;
	   strcpy (_NFMdebug_st.NFMSdebug_file, dbg_file );
           _NFMdebug_st.NFMdebug_on =  1;
           strcpy (_NFMdebug_st.NFMdebug_file, dbg_file );
           NFMmsg_ptr.debug_on = 1;
           strcpy (NFMmsg_ptr.debug_file, dbg_file );
/* PS       
           _NFMdebug_st.MEMdebug_on =  1;
           strcpy (_NFMdebug_st.MEMdebug_file, dbg_file );
 */
/*tmpMVV */
           _NFMdebug_st.ERRdebug_on =  1;
           strcpy (_NFMdebug_st.ERRdebug_file, dbg_file );

	   _NFMtranslate_dbg_file (dbg_file,argv[2],pid);
	   _NFMdebug_st.SQLdebug_on = 1;
 	   strcpy (_NFMdebug_st.SQLdebug_file, dbg_file );

	   _NFMtranslate_dbg_file (dbg_file,argv[3],pid);
 	   _NFMdebug_st.NETSdebug_on = 1;
	   strcpy (_NFMdebug_st.NETSdebug_file, dbg_file );
/* PS */ 
/*
           _NFMdebug_st.TLIdebug_on =  1;
           strcpy (_NFMdebug_st.TLIdebug_file, dbg_file);
*/
	   break;

	default :
	   break;	
   }

/*  Trap any signals except signal 18 RIS uses this signal for interprocess
    communication.
 */

for (i = 1; i <= 17; ++i)
    signal (i, Signal_function);

for (i = 19; i <= 27; ++i)
{
/*      work around change MVR 31 Dec 1993 */
   if (i!=SIGCHLD)
    signal (i, Signal_function);
}

    _NFMSdebug ((fname, "NET status : <0x%.8x>\n", _ERRstruct.NETSstatus));
    _NFMSdebug ((fname, "NFM status : <0x%.8x>\n", _ERRstruct.NFMstatus));
    _NFMSdebug ((fname, "MEM status : <0x%.8x>\n", _ERRstruct.MEMstatus));

/*  Accept the connection  */

IN_PIPE = 0;
OUT_PIPE = 0;

status = NFMaccept (&IN_PIPE, &OUT_PIPE, protocol_val);
if (status != NFM_S_SUCCESS)
    {
    _NFMSdebug ((fname, "Accept Connect Failed : status : <0x%.8x>\n",status));
    return (NFM_E_FAILURE);
    }

_NFMSdebug((fname, "Accept Connect : status : <0x%.8x>\n", status));

    status = ERRinit_messages (fname, protocol_val);
    if( status != ERR_S_SUCCESS )
    {
        _NFMSdebug(( fname,"Error initializing error message files <0x%.8x>\n",
		     status));
    }

cont_status = 1;

while (cont_status)
{
    in_command = 0;
    ERRreset_struct();

    status = NFMsrv_receive_buffer (&IN_PIPE, &OUT_PIPE, &in_command,
                                    &in_list);

    _NFMSdebug((fname, "Receive Buffer : status : <0x%.8x>\n", status));
    _NFMSdebug((fname, "Receive Buffer : in_command : <%ld>\n", in_command));

    if (status != NFM_S_SUCCESS)
    {
        _NFMSdebug((fname, "Buffer Rec : FAILED : status <0x%.8x>\n", status));
        in_command = REC_FAILED;
	cont_status = 0;
  	status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
	if (status != NFM_S_SUCCESS)
	{
	    _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
	    return (NFM_E_FAILURE);
	}
    }

    /*  Determine which function to call  */

    else if (in_command == EXIT)
    {
        cont_status = 0;
        cmd_status = NFM_S_SUCCESS;
    }
    else
    {
        cmd_status = NFMswitch_command (in_command, in_list);
    }

	   if (cmd_status!=NFM_S_SUCCESS)
    		{
    		_NFMSdebug((fname, "Function Return : cmd_status : <0x%.8x>\n",
			 cmd_status));

    /* 8/28/92 - Karen Tice - Free the pointer at the end of the loop. */
    		MEMclose( &in_list );
    		in_list = NULL;
    		}
    }  /* end while */

/* Send one last buffer because client is waiting to hear from
 * server.
 */
/* NULL check condition added to check random memory errors - SSRS 14 Feb 94 */
if(in_list != NULL)
{
    MEMclose( &in_list );
    in_list = NULL;
}

status = NFMsrv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, in_list );
_NFMSdebug((fname, "NFMsrv_send_buffer <0x%.8x>\n", status));

status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
_NFMSdebug((fname, "NFMsrv_fs_exit <0x%.8x>\n", status));

NFT_close ();
_NFMSdebug ((fname, "called NFT_close\n"));

if (status != NFM_S_SUCCESS)
    return (NFM_E_FAILURE);

_NFMSdebug((fname, "MAIN SUCCESS : status : <0x%.8x>\n", NFM_S_SUCCESS));
return (NFM_S_SUCCESS);
}
 

void Signal_function (sig)      /* void from int - Vasu 01.02.94 */
    int sig;
{
    static  char *fname = "Signal_function";

    _NFMSdebug((fname, "Received signal %d\n", sig));
    NETclose_s( &IN_PIPE, &OUT_PIPE );
    exit (1);
/*  return(0);  Removed this line. (Void function) - Vasu 01.02.94 */
}
