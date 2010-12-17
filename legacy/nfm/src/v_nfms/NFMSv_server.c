#include <stdio.h>
#include <errno.h>
#include <sys/utsname.h>
#include <UMS.h>
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMtypes.h"
#include "NFMSextern.h"
#include "UTIstruct.h"
#include "NETdef.h"
#include "NETstruct.h"
#include "ERR.h"

#if UNIX
#include <pwd.h>
#include <sys/types.h>
#include <sys/stat.h>
#endif

extern struct _ERRstruct _ERRstruct;

UTIpending flist = NULL;

int IN_PIPE      = 0;
int OUT_PIPE     = 0;

int main (argc, argv)
   int   argc;
   char  *argv[];

{
long    status, cont_status;
long    cmd_status, cmd_status2, cmd_status3;
int     in_command;
static  char *fname = "NFMSserver";
MEMptr  in_list = NULL, out_list = NULL;
MEMptr  err_buffer = NULL, err_buffer2 = NULL, err_buffer3 = NULL;
MEMptr  csd_buffer = NULL;
FILE    *fopen ();
int     protocol_val;

char    node[15];
struct  utsname  uts_structure;
long    sock_no=0;
int     server_connect=NFM_S_SUCCESS;

int	i, Signal_function ();

if (argc > 2) 
    {
    _NFMdebug_st.NFMdebug_on =  1;
    strcpy (_NFMdebug_st.NFMdebug_file, argv[2]);
    _NFMdebug_st.SQLdebug_on =  1;
    strcpy (_NFMdebug_st.SQLdebug_file, argv[2]);
    _NFMdebug_st.NETSdebug_on = 1;
    strcpy (_NFMdebug_st.NETSdebug_file, argv[2]);
/**
    NFMmsg_ptr.debug_on = 1;
    strcpy (NFMmsg_ptr.debug_file, argv[2]);
    SQLmsg_ptr.debug_on = 1;
    strcpy (SQLmsg_ptr.debug_file, argv[2]);
    NETmsg_ptr.debug_on = 1;
    strcpy (NETmsg_ptr.debug_file, argv[2]);
**/
    }

protocol_val = NULL;

if (argc > 1)
    {
         if (strcmp (argv [1], "TCP") == 0)
             protocol_val = NET_TCP;

    else if (strcmp (argv [1], "XNS") == 0)
             protocol_val = NET_XNS;

    else
             protocol_val = NULL;
    }

/*  Trap any signals except signal 18 RIS uses this signal for interprocess
    communication.
 */
/*
for (i=1; i<=27; ++i)
    signal (i, Signal_function);
   RIS is no longer using signal 18
for (i=19; i<=27; ++i)
    signal (i, Signal_function);
*/

/*  RIS is STILL using signal 18!!!  Glenn 2/23/91  */

for (i = 1; i <= 17; ++i)
    signal (i, Signal_function);

for (i = 19; i <= 27; ++i)
    signal (i, Signal_function);

    _NFMdebug ((fname, "NET status : <0x%.8x>\n", _ERRstruct.NETSstatus));
    _NFMdebug ((fname, "NFM status : <0x%.8x>\n", _ERRstruct.NFMstatus));
    _NFMdebug ((fname, "MEM status : <0x%.8x>\n", _ERRstruct.MEMstatus));

/*  Accept the connection  */

IN_PIPE = 0;
OUT_PIPE = 0;

_NFMdebug((fname, "protocol value : <%d>\n", protocol_val));

status = NETvax_accept (&IN_PIPE, &OUT_PIPE, protocol_val);
if (status != NET_S_SUCCESS)
    {
    _NFMdebug ((fname, "Accept Connect Failed : status : <0x%.8x>\n",status));
    return (NFM_E_FAILURE);
    }

_NFMdebug((fname, "Accept Connect : status : <0x%.8x>\n", status));

/** DO NFMconnect here for the 3.0 NFMserver **/

    if(uname(&uts_structure) < 0)
    {
	_NFMdebug((fname, "Unable to find node name\n"));
	node[0] = '\0';
    }
    else
    {
	strncpy(node, uts_structure.nodename, 9);
        node[9] = '\0';
    }
	
    if(node[0] != '\0')
    {
        status = NFMconnect (node, "", "", NFM_SERVER_PORT, NFM_SERVER_PORT,
                             &sock_no, NULL);

        _NFMdebug(( fname, "NFM Connect = <0x%.8x>\n", status));

        if (status != NFM_S_SUCCESS)
            server_connect = NFM_E_FAILURE;

    }

        cont_status = 1;

/*  Receive the request type  */
 

while (cont_status && (server_connect != NFM_E_FAILURE))
    {
    in_command = 0;
    ERRreset_struct();

    status = NFMvax_srv_receive_buffer (&IN_PIPE, &OUT_PIPE, &in_command,
                                        &in_list);

    _NFMdebug((fname, "Receive Buffer : status : <0x%.8x>\n", status));
    _NFMdebug((fname, "Receive Buffer : in_command : <%ld>\n", in_command));
    MEMprint_buffers("In List", in_list, "/usr/tmp/v_inlist.dbg");

    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug((fname, "Buffer Rec : FAILED : status <0x%.8x>\n", status));
        in_command = REC_FAILED;
        }
/* if NET_E_SNI_RECEIVE Close connection and EXIT */
	if(status == NET_E_SNI_RECEIVE)
	{
		cont_status = 0;
		cmd_status = NFM_S_SUCCESS ;
	}
		

        /*  Determine which function to call  */

              if (in_command == REC_FAILED)
                 {
                 cmd_status = REC_FAILED;
                 }

             else
                 {
/**
                 cmd_status = NFMswitch_command (in_command, in_list, 
						 &out_list);
**/
		/** Send the command to NFMserver **/
    MEMprint_buffers("In List2", in_list, "/usr/tmp/v_inlist.dbg");
                 status = NFMcl_send_buffer (&sock_no, in_command, in_list);
                 if(in_command == EXIT)
		 {
			cont_status = 0;
			cmd_status = NFM_S_SUCCESS;
                 }
 		}

	if( cmd_status == NFM_S_SUCCESS )
	    ERRreset_struct();
 
        _NFMdebug((fname, "Function Return : cmd_status : <0x%.8x>\n",
			 cmd_status));


	if(in_command == EXIT)
	{
              NFMcl_receive_buffer(&sock_no, &cmd_status, &err_buffer);
              NFMvax_srv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, 
				         err_buffer);
	      MEMclose (&err_buffer);
	      MEMclose (&err_buffer2);
	      MEMclose (&err_buffer3);
	      MEMclose (&csd_buffer);
              MEMclose (&out_list);
              MEMclose (&in_list);
	      break;
	}

/** Receive from NFMserver and send it to VAX client **/
/** 10/20/92 Start Receiving 2 error buffers from NFMserver **/ 
	if((cmd_status != REC_FAILED) && (server_connect != NFM_E_FAILURE))
	{
              status = NFMcl_receive_buffer(&sock_no, &cmd_status, &err_buffer);
              status=NFMcl_receive_buffer(&sock_no, &cmd_status2, &err_buffer2);
              MEMprint_buffers("Err Buf", err_buffer, "/usr/tmp/v_inlist.dbg");
              MEMprint_buffers("Err Buf2",err_buffer2, "/usr/tmp/v_inlist.dbg");
	}

	/** Kludge for NFMRsend_one_buffer and NFMRreceive_one_buffer **/
	if(in_command == NFM_UTILITIES_UPDATE)
	{
              status = NFMcl_receive_buffer(&sock_no,&cmd_status3,&err_buffer3);
              MEMprint_buffers("Err Buf3",err_buffer3, "/usr/tmp/v_inlist.dbg");
	}

        status = NFMvax_srv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status, 
				         err_buffer);
        if (status != NFM_S_SUCCESS)
            {
            _NFMdebug((fname, "Error Buffer1 Send :status <0x%.8x>\n", status));
            }
        status = NFMvax_srv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status2, 
				         err_buffer2);
        if (status != NFM_S_SUCCESS)
            {
            _NFMdebug((fname, "Error Buffer2 Send :status <0x%.8x>\n", status));
            }

	if(in_command == NFM_UTILITIES_UPDATE)
	{
        status = NFMvax_srv_send_buffer (&IN_PIPE, &OUT_PIPE, cmd_status3, 
				         			err_buffer3);
	}
	MEMclose (&err_buffer);
	MEMclose (&err_buffer2);
	MEMclose (&err_buffer3);
	MEMclose (&csd_buffer);
        MEMclose (&out_list);
        MEMclose (&in_list);
	
	ERRreset_struct();

    }  /* end while */

	if(server_connect == NFM_E_FAILURE)
	{
          NFMvax_srv_receive_buffer (&IN_PIPE, &OUT_PIPE, &in_command,
                                              &in_list); 	
          NFMvax_srv_send_buffer (&IN_PIPE, &OUT_PIPE, REC_FAILED,
                                           in_list);
	}

/** This is not required 
status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
if (status != NFM_S_SUCCESS)
    {
    _NFMdebug((fname, "Exit : status : <0x%.8x>\n", status));
    return (NFM_E_FAILURE);
    }
**/

_NFMdebug((fname, "MAIN SUCCESS : status : <0x%.8x>\n", NFM_S_SUCCESS));
return (NFM_S_SUCCESS);
}
 

int Signal_function (sig)
    int sig;
{
    static  char *fname = "Signal_function";

    _NFMdebug((fname, "Received signal %d\n", sig));
    NETclose_s( &IN_PIPE, &OUT_PIPE );
    exit (1);
}
