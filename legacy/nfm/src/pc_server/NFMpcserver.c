#include "machine.h"
#include <stdio.h>
#include <errno.h>
#include <time.h>
#include <UMS.h>
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "NFMtypes.h"
#include "NFMSextern.h"
#include "NETdef.h"
#include "NETstruct.h"
#include "ERR.h"
#include "pc.h"
#include <pwd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "MEMstruct.h"
#include "NFMpcproto.h"

extern struct _ERRstruct _ERRstruct;
char *COMMAND_BUFFER ;
MEMptr NFMmessage_buffer = NULL ;

int IN_PIPE      = 0;
int OUT_PIPE     = 0;

int main (argc, argv)
     int   argc;
     char  *argv[];
{
  long    status, cont_status;
  long    cmd_status;
  int     in_command, size ;
  static  char *fname = "PCserver";
  char    *in_list= NULL ;
/*  char    *out_list= NULL; */
  char    out_list [512] ;
  int     protocol_val ;
  struct  NETbuffer_info *buffer_info ;
  int	  i, Signal_function ();
  char    BLANK_MESSAGE [MAX_MESSAGE_LENGTH + 1], *str ;
  char    s_error_no [20], error_message [512] ;
  long    err_no ;
  int     subsystem ;

  /**************  ENABLE DEBUG *******************************/

  _NFMdebug_st.NFMdebug_on =  0;
  _NFMdebug_st.NFMSdebug_on = 0 ;
  _NFMdebug_st.SQLdebug_on =  0 ;
  NFMmsg_ptr.debug_on = 0 ;
  _NFMdebug_st.NETSdebug_on =  0 ;
  _NFMdebug_st.MEMdebug_on =  0 ;

  switch ( argc )
    {
    case 1 : 
      break ;
      
    case 2 :
      _NFMdebug_st.NFMdebug_on =  1;
      strcpy (_NFMdebug_st.NFMdebug_file, argv[1] );
      _NFMdebug_st.NFMSdebug_on =  1;
      strcpy (_NFMdebug_st.NFMSdebug_file, argv[1] );
      _NFMdebug_st.SQLdebug_on =  1;
      strcpy (_NFMdebug_st.SQLdebug_file, argv[1] );
      NFMmsg_ptr.debug_on = 1;
      strcpy (NFMmsg_ptr.debug_file, argv[1]);
      break ;

      case 3 :
      _NFMdebug_st.NFMdebug_on =  1;
      strcpy (_NFMdebug_st.NFMdebug_file, argv[1] );
      _NFMdebug_st.NFMSdebug_on =  1;
      strcpy (_NFMdebug_st.NFMSdebug_file, argv[1] );
      _NFMdebug_st.SQLdebug_on =  1;
      strcpy (_NFMdebug_st.SQLdebug_file, argv[1] );
      NFMmsg_ptr.debug_on = 1;
      strcpy (NFMmsg_ptr.debug_file, argv[1]);
      _NFMdebug_st.NETSdebug_on =  1;
      strcpy (_NFMdebug_st.NETSdebug_file, argv[2] );
      break ;

    case 4 :
      _NFMdebug_st.NFMdebug_on =  1;
      strcpy (_NFMdebug_st.NFMdebug_file, argv[1] );
      _NFMdebug_st.NFMSdebug_on =  1;
      strcpy (_NFMdebug_st.NFMSdebug_file, argv[1] );
      _NFMdebug_st.SQLdebug_on =  1;
      strcpy (_NFMdebug_st.SQLdebug_file, argv[1] );
      NFMmsg_ptr.debug_on = 1;
      strcpy (NFMmsg_ptr.debug_file, argv[1]);
      _NFMdebug_st.NETSdebug_on =  1;
      strcpy (_NFMdebug_st.NETSdebug_file, argv[2] );
      _NFMdebug_st.MEMdebug_on =  1;
      strcpy (_NFMdebug_st.MEMdebug_file, argv[3] );
      break ;

      default :
	break ;
    }

  /**************  TRAP SIGNAL 18 ********************************/
  /*  Trap any signals except signal 18 RIS uses this signal for interprocess
      communication.
   */
  
  /*  RIS is STILL using signal 18!!!  Glenn 2/23/91  */
  
  for (i = 1; i <= 17; ++i)
    signal (i, Signal_function);
  
  for (i = 19; i <= 27; ++i)
    signal (i, Signal_function);
  
  /**************  ALWAYS USE TCP PROTOCOL ***********************/
  protocol_val = NET_TCP ;
  IN_PIPE = 0;
  OUT_PIPE = 0;
  
  /***************  ACCEPT THE CONNECTION ***************************/
  status = NFMaccept (&IN_PIPE, &OUT_PIPE, protocol_val);
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Accept Connect Failed : status : <0x%.8x>\n",status));
      exit (-1) ;
    }
  
  _NFMSdebug ((fname, "Connection Established\n")) ;

  /*  Receive the request type  */
  
  cont_status = 1;

  for (i=0; i<MAX_MESSAGE_LENGTH; i++)
    BLANK_MESSAGE [i] = ' ' ;
 /*   memset (BLANK_MESSAGE, " ", MAX_MESSAGE_LENGTH+2) ; */

  BLANK_MESSAGE [MAX_MESSAGE_LENGTH] = 0 ;


  status = ERRinit_messages ("", 0) ;
  if (status != ERR_S_SUCCESS)
    {
      _NFMSdebug ((fname, "Failed to initialize messages : status = <0x%.8x>\n",
		  status)) ;
      exit (-1) ;
    }

  in_list = (char *) malloc (PC_ALLOCATION_SIZE) ;
  if (in_list == NULL)
    {
      _NFMSdebug ((fname, "Malloc in_list failed\n")) ;
      exit (-1) ;
    }
  
  while (cont_status)
    {
      in_command = 0;
      ERRreset_struct();

      _NFMSdebug ((fname, "Receive next command from client ...\n")) ;

      /*****************  RECEIVE DATA *****************************/

      status = NETbuffer_receive (&IN_PIPE, (char *) in_list, &size) ;

/*      _NFMSdebug((fname, "Received Buffer of size %d : status : <0x%.8x>\n", 
		  size, status)); */

      if (_NFMdebug_st.NFMSdebug_on)
	_NFMpc_print_mem_buffer ("PC CLIENT BUFFER", in_list, 
				 _NFMdebug_st.NFMSdebug_file) ;

      /************* GET COMMAND, INITIALIZE OUT_LIST ****************/
      buffer_info = (struct NETbuffer_info *) in_list ;
      
      in_command = buffer_info -> request  ;

/*      out_list = NULL ; */
      
      if (status != NET_S_SUCCESS)
        {
	  _NFMSdebug((fname, "Buffer Rec : FAILED : status <0x%.8x>\n", 
		      status));
	  in_command = REC_FAILED;
        }
      _NFMSdebug ((fname, "COMMAND RECEIVED <%d>\n", in_command)) ;

      /***********  ANALYZE COMMAND *******************************/
      if (in_command == PC_EXIT)
	{
	  _NFMSdebug ((fname, "TERMINATION COMMAND\n")) ;
	  cont_status = 0;
	  cmd_status = NFM_S_SUCCESS;
	}
      else if (in_command == REC_FAILED)
	{
	  _NFMSdebug ((fname, "RECEIVED FAILURE\n")) ;
	  cmd_status = REC_FAILED;
	}
      else
	{
/*	  _NFMSdebug ((fname, "Processing command\n")) ; */
	  out_list [0] = 0 ;
	  cmd_status = NFMpc_switch_command (in_list, out_list) ;
	}
      
/*      
      _NFMSdebug((fname, "Function Return : cmd_status : <0x%.8x>\n",
		  cmd_status)); 
*/

      if( cmd_status == NFM_S_SUCCESS )
	{
	  ERRreset_struct();
	}

/* 3 columns 
      column 1 = error no
      column 2 = error message
      column 3 = blank or special value such as working area name 
 */
      status = _NFMpc_build_buffer (&COMMAND_BUFFER, 3) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMSdebug ((fname, "UNABLE TO BUILD BUFFER : status = <0x%.8x>\n",
		      status)) ;
	  exit (-1) ;
	}
      
      ERRget_number (&err_no, &subsystem) ;
      ERRget_message (error_message) ;

      sprintf (s_error_no, "%d", err_no) ;

      str = (char *) malloc (strlen (s_error_no) + 
			     strlen (error_message) +
			     strlen (out_list) + 10) ;
      if (str == NULL)
	{
	  _NFMSdebug ((fname, "malloc failed\n")) ;
	  exit (-1) ;
	}

      if (strlen (out_list))
	{
	  sprintf (str, "%s\001%s\001%s\001", 
		   s_error_no, error_message, out_list) ;
	}
      else
	{
	  _NFMSdebug ((fname, "NO DATA WILL BE SENT TO CLIENT just status\n"));
	  sprintf (str, "%s\001%s\001\001", s_error_no, error_message) ;
	}

      status = _NFMpc_write_row (&COMMAND_BUFFER, str) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMSdebug ((fname, "UNABLE TO WRITE A ROW OF size %d into command_buffer : status = <0x%.8x>\n",
		      strlen (str), status)) ;
	  if (str) free (str) ;
	  exit (-1) ;
	}
      
      if (str) free (str) ;

      buffer_info = (struct NETbuffer_info *) COMMAND_BUFFER ;
      buffer_info -> request = cmd_status ;

      size = buffer_info -> size ;

      if (_NFMdebug_st.NFMSdebug_on)
	_NFMpc_print_mem_buffer ("SERVER COMMAND STATUS", COMMAND_BUFFER,
				 _NFMdebug_st.NFMSdebug_file) ;

/*      _NFMSdebug ((fname, "send buffer of size %d\n", 
		  buffer_info -> size)) ; */

      status = NETbuffer_send (&OUT_PIPE, (char *) COMMAND_BUFFER, &size);
      
      if (status != NET_S_SUCCESS)
	{
	  _NFMSdebug((fname, "Buffer Send : status <0x%.8x>\n", status));
	}

      if (COMMAND_BUFFER != NULL) 
	{
	  free (COMMAND_BUFFER) ;
	}
/**************
  if any send outlist
***************/
      
      ERRreset_struct();
/*      
      if (out_list != NULL)  
	{
	  free (out_list) ;
	}
*/
    }  /* end while */

  free (in_list) ;
  
  status = NFMsrv_fs_exit (&IN_PIPE, &OUT_PIPE);
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug((fname, "Exit : status : <0x%.8x>\n", status));
      exit (-1) ;
    }
  
  _NFMSdebug((fname, "Server Process exiting  : SUCCESSFULLY\n")) ;
  exit (0) ;
}
 

int Signal_function (sig)
    int sig;
{
    static  char *fname = "Signal_function";

    _NFMSdebug((fname, "Received signal %d\n", sig));
    NETclose_s( &IN_PIPE, &OUT_PIPE );
    exit (1);
}
