#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NETstruct.h"
#include "NFMlisten.h"
#include "NFMerrordef.h"
#include "MSGstruct.h"
#include "DEBUG.h"

/** Not required after 3.0
 extern MSGptr   NETmsg_ptr;
 extern MSGptr   NFMmsg_ptr;
**/

/** GLOBAL VARIABLE, find the right include file later **/
/* 12/16/92 - KT - SUN Port - Cannot initialize an extern variable */
/* ifdef sparc upgraded to include SCO and SOLARIS MVR 23 Dec 1993 */
/* HP PORT-IGI- 10 Jun 1994 */
#if (defined( OS_SUNOS) || defined (OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined (OS_HPUX))
extern int CHECKSUM;
#else
extern int CHECKSUM=0;
#endif
long INPIPE, OUTPIPE;

 int main (argc, argv)
   int    argc;
   char   *argv[];
   {
     char *fname = "FileServer Main";
     long    status, cont_status;
     long    in_pipe, out_pipe, in_command;
     MEMptr  in_list = NULL, out_list = NULL;
     long    protocol_val=0; 
     char dbg_file[256];
     int pid;
     long i;
     int Signal_function();
/* Variable to extract lock value  for FTR options file */
     long lock_val=0;

     pid = getpid();
/*  Trap Signals 1 - 17 , 19, 27 */
 for (i = 1; i <= 17; ++i)
     signal (i, Signal_function);
 for (i = 19; i <= 27; ++i)
     signal (i, Signal_function);

/** Modified for 3.0.0.1, because protocol value is not required at command line
    --DONTU 12/17/91


     if (argc > 1) 
      {
         _NFMdebug_st.NFMdebug_on=1 ;
	 NFMmsg_ptr.debug_on = 1;
         _NFMtranslate_dbg_file (dbg_file,argv[1],pid);

         strncpy (NFMmsg_ptr.debug_file, dbg_file,sizeof(NFMmsg_ptr.debug_file));
	 strncpy(_NFMdebug_st.NFMdebug_file,dbg_file,sizeof(_NFMdebug_st.NFMdebug_file));
      }
       
     if (argc > 2)
      {
         _NFMdebug_st.NETSdebug_on= 1;
         NETmsg_ptr.debug_on = 1;
         _NFMtranslate_dbg_file (dbg_file,argv[2],pid);
         strncpy (NETmsg_ptr.debug_file, dbg_file,sizeof(NFMmsg_ptr.debug_file));
	 strncpy(_NFMdebug_st.NETSdebug_file,dbg_file,sizeof(_NFMdebug_st.NETSdebug_file));
      }

     protocol_val = NULL;
3.0.0.1 Comment ends here**/

      CHECKSUM = 0;
      if(argc > 1)
      {
	 if(strcmp(argv[1], "CHECKSUM") == 0)
		CHECKSUM = 1; /** Set Global Varaible **/
	 else
	 {
         _NFMtranslate_dbg_file (dbg_file,argv[1],pid);
         _NFMdebug_st.NFMdebug_on=1 ;
	 strncpy(_NFMdebug_st.NFMdebug_file,dbg_file,sizeof(_NFMdebug_st.NFMdebug_file));
	 }
      }

      if(argc > 2)
      {
	if(CHECKSUM)
	{
         _NFMtranslate_dbg_file (dbg_file,argv[2],pid);
         _NFMdebug_st.NFMdebug_on=1 ;
	 strncpy(_NFMdebug_st.NFMdebug_file,dbg_file,sizeof(_NFMdebug_st.NFMdebug_file));
	}
	else
	{
         _NFMtranslate_dbg_file (dbg_file,argv[2],pid);
         _NFMdebug_st.NETSdebug_on=1 ;
	 strncpy(_NFMdebug_st.NETSdebug_file,dbg_file,sizeof(_NFMdebug_st.NETSdebug_file));
	}
      }
      if(argc > 3)
      {
	if(CHECKSUM)
	{
         _NFMtranslate_dbg_file (dbg_file,argv[3],pid);
         _NFMdebug_st.NFMdebug_on=1 ;
	 strncpy(_NFMdebug_st.NFMdebug_file,dbg_file,sizeof(_NFMdebug_st.NFMdebug_file));
         _NFMdebug_st.NETSdebug_on=1 ;
	 strncpy(_NFMdebug_st.NETSdebug_file,dbg_file,sizeof(_NFMdebug_st.NETSdebug_file));
	}
      }

/*
   Karen Tice - August 13, 1990
   There is a problem passing a command line argument (XNS) in the server.dat
   file when connect to a VAX. For now, if there is NO command line argument
   we assume XNS protocol.

   Old code:

     if (argc > 1)
      {
             if (! strcmp (argv [1], "TCP"))  protocol_val = NET_TCP;
        else if (! strcmp (argv [1], "XNS"))  protocol_val = NET_XNS;
        else                                  protocol_val = NULL;
      }
*/

/* MRG 020691	protocol value always defined to be either
	NET_XNS or NET_TCP
	since NET_TCP == 0 giving a NULL value defaults to TCP
	correction is required
*/

/** Not required after 3.0.0.1
     if (argc > 1)
         {
         if (! strcmp (argv [1], "TCP"))
             protocol_val = NET_TCP;
         else
             protocol_val = NET_XNS;
         }
     else
         protocol_val = NET_XNS;
**/

     /*  Accept the connection  */

     in_pipe = 0; out_pipe = 0;

     status = NFMaccept (&in_pipe, &out_pipe, protocol_val);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug((fname,"NFM FS : Accept Connect Failed : status = <0x%.8x>\n",                   status));
        return (status);
      }

     /*  Receive the request type  */
 
     cont_status = 1;

     while (cont_status)
      {
         in_command = 0;

         status = NFMsrv_receive_buffer (&in_pipe, &out_pipe, &in_command,
                  &in_list);
         if (status != NFM_S_SUCCESS)
          {
            in_command = REC_FAILED;
            _NFMdebug ((fname,"NFM FS : Buffer Rec : status = <0x%.8x>\n", status));
            if ( status == NET_E_TLI_RECEIVE || status == NET_E_TLI_RECEIVE_SIZE)
	    {
		_NFMdebug((fname,"Cannot receive from server: Exiting ... \n"));
		cont_status = 0;
	    }
          }

         _NFMdebug((fname,"NFM FS : Command Begin = <%d>\n\n", in_command));

         /*  Determine which function to call  */

         if (in_command == EXIT)
          {
             cont_status = 0;
             status = NFM_S_SUCCESS;
          }
         else if (in_command == REC_FAILED)
          {
             status = REC_FAILED;
          }
         else
          {
             status = NFMswitch_command (&in_pipe, &out_pipe, in_command,
                      in_list, &out_list);
          }

         _NFMdebug((fname,"NFM FS : Command End = <%d>, Status = <0x%.8x>\n\n\n", in_command,status));

         if(status != NFM_S_FS2_REPLY_SENT)
	 {
         status = NFMsrv_send_buffer (&in_pipe, &out_pipe, status, out_list);
         if (status != NFM_S_SUCCESS)
          {
            _NFMdebug((fname,"NFM FS : Buffer Send : status = <0x%.8x>\n", 
		       status));
	    if(status == NET_E_TLI_SEND)
	    {
		_NFMdebug((fname,"Cannot send  to server: Exiting ...\n"));
		cont_status = 0;
	    }
          }
	 }

         MEMclose (&out_list);
         MEMclose (&in_list);
     }
/* Check if an FTR options Lock was performed by this fileserver.
   If so release the lock before exiting */
    lock_val =0;
    status = NETcheck_lock (&lock_val);
    if(status != NET_S_SUCCESS)
    {
       _NFMdebug((fname,"Check lock failed: lock_val <%d>:pid <%d>: status = <0x%.8x>\n",lock_val,pid , status));
    }
    if(pid == lock_val ) 
    {
 	status = NETset_lock(0);
    	if(status != NET_S_SUCCESS)
    	{
       	_NFMdebug((fname,"Reset lock failed: lock_val <%d>:pid <%d>: status = <0x%.8x>\n",lock_val,pid , status));
    	}
    }

    status = NFMsrv_fs_exit (&in_pipe, &out_pipe);
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug((fname,"NFM FS : Ser Exit : status = <0x%.8x>\n", status));

/*  Possible optical disk cleanup Before 3.0.0.1, 12/17/91
       if( protocol_val == NET_XNS )
	   exit( status );
       else
           return (status);
 */

/* 12/16/92 - KT SUN Port - changed 'Exit' to 'exit' */
	exit( status );

     }

    _NFMdebug ((fname,"NFM FS : MAIN SUCCESS : status = <0x%.8x>\n", 
		NFM_S_SUCCESS));

/*  Possible optical disk cleanup Before 3.0.0.1, 12/17/91
    if( protocol_val == NET_XNS )
	exit( NFM_S_SUCCESS );
    else
        return (NFM_S_SUCCESS);
 */

/* 12/16/92 - KT SUN Port - changed 'Exit' to 'exit' */
	exit( NFM_S_SUCCESS);
  }





int Signal_function (sig)
    int sig;
{
    static  char *fname = "Signal_function";
    long lock_val,pid;

    _NFMSdebug((fname, "Received signal %d\n", sig));
    pid =getpid();
    NETcheck_lock (&lock_val);
    if(pid == lock_val ) NETset_lock(0);
    NFMsrv_fs_exit (&INPIPE, &OUTPIPE);
    exit (1);
    return(0);
}
