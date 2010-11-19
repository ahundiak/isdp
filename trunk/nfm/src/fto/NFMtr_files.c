#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

#include "ERR.h"
#include "DEBUG.h"
#include "MEM.h"

#include "NFMerrordef.h"
#include "NFMxferstrct.h"
#include "NFMxferextrn.h"
#include "NFMfto_buf.h"

#include "NFMsysstruct.h"
#include "SYSTproto.h"

#include "TFERproto.h"

#include "NETdef.h"
#include "NETproto.h"
#include "NETstruct.h"
#include "NETnetstruct.h"
#include "NETnetextern.h"

static int tracex = 1;


#define NO_LFM_CHECK		0

extern NFMuser_info_struct NFMuser_info ;

/************************************************************************
*									*
*			NFMs_dest_recv_clix				*
*									*
*	This function is called during check out. The destination node  *
* 	is same for all the files. The destination node is clix		*
*	This is the server side function. It will open a connection to  *
* 	destination node file server and instruct it to receive files   *
*       from the sources which can be CLIX or NON-CLIX			*
 *
 * This talks to the daemon, want to eliminate it
************************************************************************/
#if 0
long NFMs_dest_recv_clix (node_name, user_name, passwd,
                          protocol, buffer_ptr)
  char   *node_name, *user_name, *passwd;
  long    protocol;
  MEMptr *buffer_ptr;
{
  char  *fname="NFMs_dest_recv_clix";
  long   status, status1, sock_no;
  char   dec_passwd[NFM_PASSWD];
  MEMptr save_buffer = NULL ;

  if (tracex) g_message(">>> %s %s %s %s",fname,node_name,user_name,passwd);

  /* decrypt the password */
  status = NFMdecrypt (passwd, dec_passwd);
  g_return_val_if_fail(status == NFM_S_SUCCESS,NFM_E_SEVERE_ERROR);

  /* connect to the destination file server */
  sock_no = -1;
  net_buf_status.status1 = net_buf_status.status2 = net_buf_status.status3  = 0;

  status = NFMconnect (node_name, user_name, dec_passwd, NFM_TCP_PORT, NFM_XNS_PORT, (int *)&sock_no, protocol);
  g_return_val_if_fail(status == NFM_S_SUCCESS,NFM_E_SEVERE_ERROR);

  /* send command to destination */
  status = NFMcl_send_buffer (&sock_no, NFM_DEST_RECEIVE_FILES, *buffer_ptr);
  g_return_val_if_fail(status == NFM_S_SUCCESS,NFM_E_SEVERE_ERROR);

    // Close socket on failure
    // NFMcl_fs_exit (&sock_no);

  status1 = NFM_S_SUCCESS;

  /* receive reply back from file server */
  save_buffer = NULL ;
  status = NFMcl_receive_buffer (&sock_no, &status1, &save_buffer);
  g_return_val_if_fail(status == NFM_S_SUCCESS,NFM_E_SEVERE_ERROR);

	MEMclose(buffer_ptr);
	*buffer_ptr = save_buffer ;

  status = NFMcl_fs_exit (&sock_no);
  g_return_val_if_fail(status == NFM_S_SUCCESS,NFM_E_EXIT_S_TO_FS);

  g_return_val_if_fail(status1 == NFM_S_SUCCESS,status1);

  return (NFM_S_SUCCESS);
}
#endif
#if 0
/************************************************************************
*									*
*			NFMs_src_send_clix				*
*									*
*	This function is called during check in. The source node        *
* 	is same for all the files. The source node is clix		*
*	This is the server side function. It will open a connection to  *
* 	source node file server and instruct it to send  files		*
*       to the destination which can be CLIX or NON-CLIX		*
************************************************************************/

long NFMs_src_send_clix (node_name, user_name, passwd,
                          protocol, buffer_ptr,NETid,close_flag)
   char     *node_name, *user_name, *passwd;
   long     protocol,*NETid,close_flag;
   MEMptr    *buffer_ptr;
   {
      char *fname="NFMs_src_send_clix";
      long    status, status1, sock_no;
      char dec_passwd[NFM_PASSWD];
      MEMptr save_buffer = NULL ;

      _NFMdebug ((fname,"nodename <%s> username <%s> password <%s>\
 protocol <%d> MEMptr *buffer_ptr <%x>\n",
node_name,user_name,passwd,protocol,*buffer_ptr));

/* decrypt the password */

      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         status = NFM_E_NET_DECRYPT_CO_LOCATION;
         _NFMdebug ((fname,"Decrypt Passwd : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s%s%s%s",node_name,user_name,passwd,"");
         return (NFM_E_SEVERE_ERROR);
       }

/* connect to the source file server */

      sock_no = -1;

      net_buf_status.status1 = net_buf_status.status2 = net_buf_status.status3  = 0;
      status = NFMconnect (node_name, user_name, dec_passwd,
               NFM_TCP_PORT, NFM_XNS_PORT, (int *)&sock_no, protocol);
      if (status != NFM_S_SUCCESS)
       {
	 status = NFM_E_TLI_CONNECT_FS1;
         ERRload_struct(NFM,status,"%d%d%s%s",net_buf_status.status2,
net_buf_status.status3,node_name,user_name);
         _NFMdebug ((fname,"NFMconnect Failed :node_name <%s>: username <%s>:\
connect_status <%d>:errno <%d>: status = <0x%.8x>\n",node_name,user_name,
net_buf_status.status2, net_buf_status.status3,status));
         return (NFM_E_SEVERE_ERROR);
       }

/* send command to destination */

      status = NFMcl_send_buffer (&sock_no, NFM_SRC_SEND_FILES, *buffer_ptr);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Failed to send command NFM_SRC_SEND_FILES\n\
to fileserver at nodename <%s> username <%s> sock_no <%d> MEMptr *buffer_ptr \
<%x> status = <0x%.8x>\n",node_name,user_name,sock_no,*buffer_ptr, status));
	 status = NFM_E_SEND_COMMAND_S_TO_FS ;
	 ERRload_struct(NFM,status,"%s%s%s","checkin:NFM_SRC_SEND_FILES",
node_name,user_name);
         NFMcl_fs_exit (&sock_no);
         return (NFM_E_SEVERE_ERROR);
       }      

/* close the memory buffer as the file server will return the buffer loaded with
   size information */


      status1 = NFM_S_SUCCESS;

/* receive reply back from file server */

      save_buffer = NULL ;
      status = NFMcl_receive_buffer (&sock_no, &status1, &save_buffer);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         _NFMdebug ((fname,"Failed to receive response to command NFM_SRC_SEND_FILES\n\
from fileserver at nodename <%s> username <%s> sock_no <%d> MEMptr *buffer_ptr\
 <%x> status = <0x%.8x>\n",node_name,user_name,sock_no,*buffer_ptr, status));
         NFMcl_fs_exit (&sock_no);
	 status = NFM_E_RECEIVE_RESPONSE_FS_TO_S ;
	 ERRload_struct(NFM,status,"%s%s%s","checkin:NFM_SRC_SEND_FILES",
node_name,user_name);
         return (NFM_E_SEVERE_ERROR);
       }      

       MEMclose(buffer_ptr);
       *buffer_ptr = save_buffer ;

/* load appropriate error */

 
      if(close_flag > 0)
      {
      status = NFMcl_fs_exit (&sock_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFMcl_fs_exit Failed:Connection to nodename <%s>\
username <%s> status = <0x%.8x>\n",node_name,user_name, status));
	status = NFM_E_EXIT_S_TO_FS;
	 ERRload_struct(NFM,status,"%s%s%s","checkin:NFM_SRC_SEND_FILES",
node_name,user_name);
         return (status);
       }
      }



      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Command NFM_SRC_SEND_FILES Failed at File Server\n\
File Server status1 = <0x%.8x>\n", status1));
	 ERRload_struct(NFM,NFM_E_FAILURE,"%s %x","FS: Source send Files Failed",status1);
         NFMcl_fs_exit (&sock_no);
         return (status1);
       }
/* Set NETid   */
      *NETid = sock_no;
     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }
#endif

/************************************************************************
*	
*	NFMfs_dest_recv_clix
*	
*	This procedure is the file server side function, which is
*	called when the file server receives the command
*	NFM_DEST_RECV_FILES. The files are moved and the status is
*	returned in n_status within the buffer. A fatal error will cause
*	immediate erroring out, else the function will try to do as
*	many files as possible
 *
 * The goal is to call this directly from isdp instead of through the daemon
 * Also simplify to just use ftp
************************************************************************/

long NFMfs_dest_recv_clix ( MEMptr *buffer_ptr)
{
  char  *fname="NFMfs_dest_recv_clix";
  long   status,status1,status2,status3,dst_stat_status;
  char **data;
  long   connect_status = 0;
  long   x, y, count, count1;
  char   dec_pass [NFM_PASSWD],NFS_CO_DIR[NFM_FILENAME+1];
  char   src_file [512], dst_file [512];
  long   size, protocol,n_status,n_status1;
  struct stat  fbuff;
  int   *FILE_SOCK,FILE_SOCK_VAL;

  /* Initialize variables */
  connect_status = 0;
  FILE_SOCK = &FILE_SOCK_VAL;
 *FILE_SOCK = -1 ;
  n_status = n_status1 = status2 = status3 = 0;
  status1 = NFM_S_SUCCESS ;

  /* MEMbuild array to access data in the buffer Return on failure */
  status = MEMbuild_array (*buffer_ptr);
  g_return_val_if_fail(status == MEM_S_SUCCESS,NFM_E_MEM_BUILD_ARRAY_BUFFER);

  data    = (char **) (*buffer_ptr) -> data_ptr;
  if(strlen(data[FTO_PATHNAME]) > 0 ) strncpy(NFS_CO_DIR, data[FTO_PATHNAME],NFM_FILENAME);
  else                                strncpy(NFS_CO_DIR, NFMuser_info.dir,  NFM_FILENAME);
  NFS_CO_DIR[NFM_FILENAME] = '\0';

  for (x = 1; x < (*buffer_ptr) -> rows; ++x)
  {
    /* Extract n_status from the second position onwards.
     * First position is the "check out location"
     */

    /* Process All the rows even if error occurs in processing */
    count = (*buffer_ptr) -> columns * x;
    n_status = atol(data [ count + FTO_STATUS1]);

    /* If the  status is *_MOVE move the files */
    if(n_status == NFM_MOVE     || n_status == NFM_LFM_MOVE ||
       n_status == NFM_NFS_MOVE || n_status == NFM_LFM_NFS_MOVE)
    {
      // Always tcp
      protocol = NET_TCP;
      connect_status = 0;

      /* Decrypt the password */
      status = NFMdecrypt (data [count + FTO_PASSWD], dec_pass);
      if (status != NFM_S_SUCCESS)
      { 
		    status  = NFM_E_NET_DECRYPT;
        status1 = NFM_E_NET_DECRYPT_CI_LOCATION ;
		    NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,status1);
		    continue ;
      }
      connect_status = FTP_MC ;
    
      for (y = x; y < (*buffer_ptr) -> rows; ++y)
      {
        count1 = (*buffer_ptr) -> columns * y;
        n_status1 = atol(data [ count1 + FTO_STATUS1]); // 2033 NFM_NFS_MOVE

        if
        (
          (n_status1 == NFM_MOVE || n_status1 == NFM_LFM_MOVE || n_status1 == NFM_NFS_MOVE || n_status1 == NFM_LFM_NFS_MOVE) &&
          (! strcmp (data [count + FTO_SANO],data[count1+FTO_SANO]))
        )
        {
          status = NFMappend_path_file (
            data [count1 + FTO_OPSYS],
            data [count1 + FTO_PATHNAME],
            data [count1 + FTO_CIFILENAME],
            src_file);
          if (status != NFM_S_SUCCESS)
          {
            /* Load the error  for n_status and continue with next buffer */
		        status1 = NFM_E_APPEND_CI ;
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
		        continue ;
          }
          status = NFMappend_path_file (
            data [FTO_OPSYS],
            data [FTO_PATHNAME],
            data [count1 + FTO_COFILENAME],
            dst_file);
          if (status != NFM_S_SUCCESS)
          {
            /* Load the error NFM_MOVE_FAILURE for n_status and continue with next buffer */
		        status1 = NFM_E_APPEND_CO ;
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
		        continue ;
          }
          size = 0;
          /* Verify that file is not there locally */
          dst_stat_status = stat (dst_file, &fbuff);

          /* For local file manager transfers do the lfm check */
	        if(n_status1 == NFM_LFM_MOVE || n_status1 == NFM_LFM_NFS_MOVE )
          {
            /* Make sure it is not "/usr/tmp" as we use this for temporary transfer */
		        if(strncmp(dst_file,"/usr/tmp", 8 ) == 0 ) dst_stat_status = NFM_S_SUCCESS ;
            if (dst_stat_status == 0 )
            {
		          if(n_status1 == NFM_LFM_MOVE ) NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS1+1,NFM_E_LFM_EXISTS_LOCALLY);
              else                           NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS1+1,NFM_E_LFM_NFS_EXISTS_LOCALLY);
              status1= NFM_E_LFM_FILE_EXISTS ;
		          continue ;
            }
          }
          /* If the file exists locally change mode to   0777
              Now the file can be written to */
          if(dst_stat_status == 0)
          {
            // Ignore if file cannot be written to
            status = NFMchmod(dst_file,0777);
          }
			  }
      } // y counter

      // Always ftp
      status = NFMftp_receive (data [count1 + FTO_NODENAME],
                               data [count1 + FTO_USERNAME], dec_pass, src_file, dst_file,
                               data [count1 + FTO_FILETYPE], &size);
      if (status != NFM_S_SUCCESS)
      {
			  switch(status)
			  {
				  case NFM_E_NO_FILENAME:
					  status1 = NFM_E_NO_CO_FILENAME;
					  break;
				  case  NFM_E_FTP_FOPEN_WRITE_F_SHELL:
					  status1 = status;
					  break;
				  case  NFM_E_FTP_FOPEN_WRITE_F_SCRIPT:
					  status1 = status;
					  break;
				  case  NFM_E_FTP_FWRITE_F_SHELL:
					  status1 = status;
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,xfer_buf_status.status2);
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS3+1,xfer_buf_status.status3);
					  break;
				  case  NFM_E_FTP_FWRITE_F_SCRIPT:
					  status1 = status;
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,xfer_buf_status.status2);
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS3+1,xfer_buf_status.status3);
					  break;
				  case  NFM_E_STAT:
					  status1 = NFM_E_STAT_CO_FILENAME;
					  break;
				  default:
		        status1 = NFM_E_FTP_REC_CO_FILENAME;
			  }
        NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
		    NFMchmod(dst_file,fbuff.st_mode);
		    continue ;
      }
		  if ( n_status1 == NFM_NFS_MOVE || n_status1 == NFM_LFM_NFS_MOVE)
		  {
			  status = NFMchmod(dst_file,0444);
      }
      if (size < 0)
      {
        status1 = status = NFM_E_BAD_CO_FILE_SIZE;
		    status2 = size ;
        NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
        NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,status2);
		    continue ;
      }
      n_status1 = NFM_TRANSFERED ;
      NFMset_buf_stat(*buffer_ptr,y+1,FTO_CIFILESIZE+1,size);
      NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS1+1,n_status1);
    }
  }
  // Done
  return (status1);
}
#if 0
 long NFMfs_src_send_clix ( buffer_ptr)
   MEMptr *buffer_ptr;
   {
      char *fname="NFMfs_src_send_clix";
      long     status,status1,status2,status3;
      char     **data;
      long     connect_status = 0;
      long     x, y, count, count1,ft_ci_flag,pos;
      char     dec_pass [50];
      char     src_file [512], dst_file [512],file_old[512];
      char     new_file_old[512], *slash; 
      char     tmp_str[1024];
      long     size, protocol,n_status,n_status1,n_status2;
      int *FILE_SOCK,FILE_SOCK_VAL;
      long     NFMftp_receive ();

      _NFMdebug ((fname,"Entry MEMptr *buffer_ptr = <%x>\n",*buffer_ptr));

/* Initialize */

      connect_status = n_status = n_status1 =ft_ci_flag =  0;
      FILE_SOCK = &FILE_SOCK_VAL;
      *FILE_SOCK = -1;
      status1 = NFM_S_SUCCESS ;
      status2 = status3 = 0;

/* MEMbuild array to access the data */

      status = MEMbuild_array (*buffer_ptr);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array",fname,"status",status);

         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }


      data    = (char **) (*buffer_ptr) -> data_ptr;


      for (x = 1; x < (*buffer_ptr) -> rows; ++x)
       {
         count = (*buffer_ptr) -> columns * x;

/* Check the status of in buffer for row 2 ... 
   row 1 is the source info */

         n_status = atol ( data [ count + FTO_STATUS1] );
         if((n_status == NFM_MOVE ||  n_status == NFM_MOVE_MOVE ||
		n_status == NFM_MOVE_FIRST_TIME ))
          {

/* Close previous connection */

            if (connect_status > 0 )
             {
               switch ( connect_status )
		{
			case TLI_MC:
			
		               status = NFMdisconnect (FILE_SOCK);
                               break;
			case FMU_MC:
		               status = NETfmu_disconnect ();
                               break;
			case FTP_MC:
				break;
			default:
		               status = NFMdisconnect (FILE_SOCK);
                               break;
                 }
		connect_status = 0;
	      }

/* Set the value of protocol based on source and destination nodes info */
              if    (! strcmp (data [count+FTO_TCPIP], "Y")  && 
                     ! strcmp (data [FTO_TCPIP], "Y"))
                 protocol = NET_TCP;
              else if    (! strcmp (data [count+FTO_XNS], "Y")  && 
                          ! strcmp (data [FTO_XNS], "Y"))
                 protocol = NET_XNS;
              else   
              {
                 _NFMdebug((fname,"<WARNING> Source and destination have no match on \
protocol. Proceeding ....\n"));

                 protocol = NULL;
	      }

/* Decrypt the password */

              status = NFMdecrypt (data [count + FTO_PASSWD], dec_pass);
              if (status != NFM_S_SUCCESS)
               { 
		  status=NFM_E_NET_DECRYPT;
		  ERRload_struct(NFM,status,"%s","Password");
                  _NFMdebug ((fname," Net Decrypt : status = <0x%.8x>\n", status));
		  status1 = NFM_E_NET_DECRYPT_CI_LOCATION ;
/* Load the error for n_status and continue with next buffer */
		  NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,status1);
                  return(status1);
                }

/* Verify the destination node operating system. Establish appropriate 
   connection and transfer the file */

               if ((! strcmp (data [count + FTO_OPSYS], "CLIX")) ||
               (! strcmp (data [count + FTO_OPSYS], "UNIX")))
                {
                   status = NFMconnect (data [count + FTO_NODENAME],
                            data [count + FTO_USERNAME], dec_pass,NFM_TCP_PORT,
                            NFM_XNS_PORT,FILE_SOCK, protocol);
                   if (status != NFM_S_SUCCESS)
                    {
			NFMdisconnect (FILE_SOCK);
                      _NFMdebug ((fname,"File_connect : status = <0x%.8x>\n",
                      status));
		      status3 =  status2 = 0;
		      switch(status)
		      {
				case NET_E_UNKNOWN_NODE:
					status1=NFM_E_UNKNOWN_CI_NODENAME;
					break;
				case NET_E_TLI_BAD_PORT:
					status1= NFM_E_BAD_TLI_PORT_FS1_FS2 ;
					status2= net_buf_status.status2; 
					break;
				case NET_E_UNKNOWN_PROTOCOL:
					status1= NFM_E_UNKNOWN_PROTOCOL_FS1_FS2;
					status2 = net_buf_status.status2 ;
					break;
				case NET_E_TLI_CONNECT:
					status1 = NFM_E_TLI_CONNECT_FS1_FS2;
					status2 = net_buf_status.status2;
					status3 = net_buf_status.status3;
					break;
				case NET_E_TLI_SEND:
					status1 = NFM_E_TLI_SEND_FS1_FS2;
					status2 = net_buf_status.status2;
					status3 = net_buf_status.status3;
				case NET_E_TLI_RECEIVE_SIZE:
					status1 = NFM_E_TLI_RECEIVE_SIZE_FS1_FS2;
					status2 = net_buf_status.status2;
					status3 = net_buf_status.status3;
				case NET_E_TLI_RECEIVE:
					status1 = NFM_E_TLI_RECEIVE_FS1_FS2;
					status2 = net_buf_status.status2;
					status3 = net_buf_status.status3;
				default:
/* Load the errors returned by load_user_info ################### */
					status1 = NFM_E_LOAD_USER_INFO_FS2;
					status2 = status;
				}
/* Load the error  n_status and continue with next buffer */
              	      NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,status1);
              	      NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS2+1,status2);
              	      NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS3+1,status3);
                      return(status1);
                    }
                    connect_status = TLI_MC ;
                }
               else if ((! strcmp (data [count + FTO_OPSYS], "VMS")) &&
                        ( protocol == NET_XNS )) 
                {
                   status = NETfmu_connect (data [count + FTO_NODENAME],
                            data [count + FTO_USERNAME],dec_pass);
                   if (status != NET_S_SUCCESS)
                    {
                      NETfmu_disconnect();
                      _NFMdebug ((fname,"fmu_connect : status = <0x%.8x>\n",
                      status));
		      status1 = NFM_E_FMU_CONNECT_FS1_FS2;
              	      NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,status1);
                      return(status1);
                    }
                    connect_status = FMU_MC ;
                }
               else
                    connect_status = FTP_MC ;

		
            for (y = x; y < (*buffer_ptr) -> rows; ++y)
             {
               count1 = (*buffer_ptr) -> columns * y;
               n_status1 = atol ( data [ count1 + FTO_STATUS1] );
	       if (n_status1 == NFM_MOVE_FIRST_TIME) ft_ci_flag = 1;
	       else ft_ci_flag = 0;

	       n_status2 = NFM_TRANSFERED ;
               if((n_status1 == NFM_MOVE ||  n_status1 == NFM_MOVE_MOVE ||
n_status == NFM_MOVE_FIRST_TIME ) &&

	              (! strcmp (data [count + FTO_SANO],data[count1+FTO_SANO])))
                {
                  status = NFMappend_path_file (data [FTO_OPSYS],
                           data [FTO_PATHNAME], data [count1 + FTO_COFILENAME], src_file);
                  if (status != NFM_S_SUCCESS)
                   {
                     NFMswitch_disconnect(connect_status,FILE_SOCK);
                     _NFMdebug ((fname,"Append path failed : opsys <%s> pathname <%s>\n\
filename <%s> : status = <0x%.8x>\n",data[FTO_OPSYS],data[FTO_PATHNAME],
data[count1 + FTO_COFILENAME], status));
/* Load the error for n_status and continue with next buffer */
		      status1 = NFM_E_APPEND_CO;		
		      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
                     return (status1);
                   }

                  status = NFMappend_path_file (data [count1 + FTO_OPSYS],
                           data [count1 + FTO_PATHNAME], data [count1 + FTO_CIFILENAME], 
                           dst_file);
                  if (status != NFM_S_SUCCESS)
                   {
                     NFMswitch_disconnect(connect_status,FILE_SOCK);
                     _NFMdebug ((fname,"Append path failed : opsys <%s> pathname <%s>\n\
filename <%s> : status = <0x%.8x>\n",data[count1+FTO_OPSYS],data[count1+FTO_PATHNAME],
data[count1 + FTO_CIFILENAME], status));
		      status1 = NFM_E_APPEND_CI;		
		      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
                     return (status1);
                   }
/* Generate the file_old if NFM_MOVE_MOVE is specified */
		  if(n_status1 == NFM_MOVE_MOVE)
		  {
			n_status2 = NFM_MOVE_TRANSFERED ;
                  status = NFMappend_path_file (data [count1 + FTO_OPSYS],
                           data [count1 + FTO_PATHNAME], data [count1 + FTO_FILEOLD], 
                           file_old);
                  if (status != NFM_S_SUCCESS)
                   {
                     NFMswitch_disconnect(connect_status,FILE_SOCK);
                     _NFMdebug ((fname,"Append path failed : opsys <%s> pathname <%s>\n\
filename <%s> : status = <0x%.8x>\n",data[count1+FTO_OPSYS],data[count1+FTO_PATHNAME],
data[count1 + FTO_FILEOLD], status));
		      status1 = NFM_E_APPEND_FILEOLD;		
		      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
                     return (status1);
                   }
		  }
 
 
                  size = 0;

/* Perform the copy operation for cifilename to file_old if 
   n_status1 = NFM_MOVE_MOVE */

                  switch ( connect_status)
		  {
		    case TLI_MC :
		     if(n_status1 == NFM_MOVE_MOVE)
		     {
/* Copy the cifilename to fileold */
			status = NFMfile_copy(dst_file,file_old,
                              data [count1 + FTO_FILETYPE], 0,FILE_SOCK);
			if(status != NFM_S_SUCCESS)
			{
				_NFMdebug((fname,"Failed to move cifilename <%s>\
 to file_old <%s> : status <0x%.8x>\n",dst_file,file_old,status));
  /* If it is a send or receive failure then try to disconnect the second
     fileserver and break */
                              if(status == NFM_E_TLI_SEND_FS1_FS2 ||
                                 status == NFM_E_TLI_RECEIVE_SIZE_FS1_FS2 ||
                                 status == NFM_E_TLI_RECEIVE_FS1_FS2)
                                {
  NFMdisconnect (FILE_SOCK);
  _NFMdebug ((fname,"Network connection broken: status = <0x%.8x>\n",
                          status));
  status1 = status;
  NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
  NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,xfer_buf_status.status2);
  NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS3+1,xfer_buf_status.status3);
 
  return (status1);
                                }

				n_status2 = NFM_MOVE_MOVE_WARNING ;
			}
		     }
                     status = NFMfile_send (src_file, dst_file,
                              data [count1 + FTO_FILETYPE], (int *)&size,FILE_SOCK,ft_ci_flag);
                     if (status != NFM_S_SUCCESS)
                      {
                        NFMdisconnect (FILE_SOCK);
                        _NFMdebug ((fname,"Rec File: status = <0x%.8x>\n",
                        status));
		      status1 = status;
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,xfer_buf_status.status2);
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS3+1,xfer_buf_status.status3);

                        return (status1);
                      }
		      break;
                    case FMU_MC :
		     if(n_status1 == NFM_MOVE_MOVE)
		     {
/* Copy the cifilename to fileold */
			NFMconvert_to_vax_file(dst_file);
			NFMconvert_to_vax_file(file_old);
			sprintf(tmp_str,"rename %s %s",dst_file,file_old);
			status = NFMfmu_rcmd(tmp_str,"");
			if(status != NFM_S_SUCCESS && status != NFM_I_NO_OUTPUT) 
			{
				_NFMdebug((fname,"Failed to copy cifilename <%s>\
 to file_old <%s> : status <0x%.8x>\n",dst_file,file_old,status));
				n_status2 = NFM_MOVE_MOVE_WARNING ;
			}
		     }
		     if(n_status1 == NFM_MOVE_FIRST_TIME)
		     {
/* Copy the cifilename to fileold */
			sprintf(tmp_str,"dir %s",dst_file);
			status = NFMfmu_rcmd(tmp_str,"");
			if(status == NFM_S_SUCCESS || status == NFM_I_NO_OUTPUT) 
			{
				_NFMdebug((fname,"Check in file <%s> exists locally on node <%s>:\
 status <0x%.8x>\n",dst_file,data[count1+FTO_NODENAME],status));
				status1 = NFM_E_CI_FILENAME_EXISTS ;
              	                NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
				return(status1);
			}
		     }
		     status = NETfmu_send(src_file, dst_file,
                              data [count1 + FTO_FILETYPE], (int *)&size);
                     if (status != NET_S_SUCCESS)
                      {
                        NETfmu_disconnect ();
                        _NFMdebug ((fname,"FMU Rec File: status = <0x%.8x>\n",
                        status));
			switch (status)
			{
				case NET_E_FMU_SEND:
					status1 = NFM_E_FMU_SEND_CO_FILENAME;
					break;
				case NET_E_FMU_SET:
					status1 = NFM_E_FMU_SET_CI;
					break;
				case NET_E_FMU_UNSET:
					status1 = NFM_E_FMU_UNSET_CI;
					break;
				case NET_E_STAT:
					status1 = NFM_E_STAT_CO_FILENAME;
					status2 = errno ;
					break;
			}
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,status2);
                        return (status1);
                      }                     
                     break;
                    case FTP_MC:
		    default:
		     if(n_status1 == NFM_MOVE_MOVE)
		     {
/* Copy the cifilename to fileold */
                        status = NFMftp_rename (data [count1 + FTO_NODENAME],
                              data [count1 + FTO_USERNAME], dec_pass, dst_file, file_old, data[count1 + FTO_MACHID]); /* VAX - IGI */
			if(status != NFM_S_SUCCESS)
			{
				_NFMdebug((fname,"Failed to ftp_rename cifilename <%s>\
 to file_old <%s> : status <0x%.8x>\n",dst_file,file_old,status));
				n_status2 = NFM_MOVE_MOVE_WARNING ;
			}
		     }
		     if(n_status1 == NFM_MOVE_FIRST_TIME)
		     {
                        status = NFMftp_check_local (data[count1+FTO_NODENAME], data[count1+FTO_USERNAME], dec_pass,
	            dst_file);
			if(status == NFM_S_SUCCESS ) 
			{
				_NFMdebug((fname,"Check in file <%s> exists locally on node <%s>:\
 status <0x%.8x>\n",dst_file,data[count1+FTO_NODENAME],status));
				status1 = NFM_E_CI_FILENAME_EXISTS ;
              	                NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
				return(status1);
			}
		     }
                     status = NFMftp_send (data [count1 + FTO_NODENAME],
                              data [count1 + FTO_USERNAME], dec_pass, src_file, dst_file,
                              data [count1 + FTO_FILETYPE], &size);
                     if (status != NFM_S_SUCCESS)
                      {
                        _NFMdebug ((fname,"NFMftp_send: status = <0x%.8x>\n",
                        status));
			switch(status)
			{
				case NFM_E_NO_FILENAME:
					status1 = NFM_E_NO_CO_FILENAME;
					break;
				case  NFM_E_STAT:
					status1 = NFM_E_STAT_CO_FILENAME;
					break;
				case  NFM_E_FTP_FOPEN_WRITE_F_SHELL:
					status1 = status;
					break;
				case  NFM_E_FTP_FOPEN_WRITE_F_SCRIPT:
					status1 = status;
					break;
				case  NFM_E_FTP_FWRITE_F_SHELL:
					status1 = status;
status = NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,xfer_buf_status.status2);
status = NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS3+1,xfer_buf_status.status3);
					break;
				case  NFM_E_FTP_FWRITE_F_SCRIPT:
					status1 = status;
status = NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,xfer_buf_status.status2);
status = NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS3+1,xfer_buf_status.status3);
					break;
				default:
		      			status1 = NFM_E_FTP_SEND_CO_FILENAME;
			}
/* Load the error for n_status return */
		        NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
                        return (status1);
                      }                     
		      break;
                   }

                  if (size < 0)
                   {
                     NFMswitch_disconnect(connect_status,FILE_SOCK);
                     status1=	status = NFM_E_BAD_CO_FILE_SIZE;
		     status2 = size ;
                     _NFMdebug ((fname,"Bad File Size: status =<0x%.8x>\n",
                     status));
                     ERRload_struct (NFM, status, "%d", size);
/* Load the error NFM_MOVE_FAILURE for n_status and continue with next buffer */
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,status2);
                     return (status1);
                   }

		  NFMset_buf_stat ( *buffer_ptr,y+1,FTO_CIFILESIZE+1,size);
		  NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,n_status2);
   
                }
             }
          }
      }

      status = NFMswitch_disconnect (connect_status,FILE_SOCK);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Net File Close : status = <0x%.8x>\n",
         status));
         return (status);
       }

      
      _NFMdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }



 long NFMs_dest_recv_nonclix ( node_name, user_name, passwd,
			       protocol, buffer_ptr)
   char    *node_name, *user_name, *passwd;
   MEMptr   *buffer_ptr;
   long protocol ;
   {

      long     status1,status,n_status;
      long      count;
      int x;
      char     **data,  **data2;
      char     rcmd_str [560], dst_file [512], temp [50];
      char *fname="NFMs_dest_recv_nonclix";
      MEMptr   save_buffer = NULL;
      long connect_status;
      char     dec_passwd [50];
      long     size;


      _NFMdebug((fname,"Entry: nodename <%s> username <%s> passwd <%s>\n \
protocol <%d> MEMptr *buffer_ptr <%x> \n",node_name,user_name,passwd,protocol,*buffer_ptr));
/* Initialize */
      connect_status = 0;
      status1 = NFM_S_SUCCESS ;

/* save the old buffer */
      status = MEMsplit_copy_buffer (*buffer_ptr, &save_buffer, 1);
      
      if (status != MEM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMsplit_copy_buffer",fname,"status",status);

         _NFMdebug ((fname,"MEM split copy buffer : status = <0x%.8x>\n", status));
         return (NFM_E_SEVERE_ERROR);
       }
      status = MEMbuild_array (save_buffer);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array",fname,"status",status);

         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }

      data    = (char **) (save_buffer) -> data_ptr;

/* figure out destination it is a FTP or FMU machine */
     if ((! strcmp (data [FTO_OPSYS], "VMS"))) 
	connect_status = FMU_MC ;
     else connect_status = FTP_MC ;

/* Change the first row in the saved buffer to server info */
	for(x=0; x < (save_buffer)->columns && x < FTO_MAX_BUF ; x++)
		if((status=MEMwrite_data(save_buffer,filexfer_loc_sa.LOCAL_SA[x],1,x+1))!= MEM_S_SUCCESS)
       		{
		         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%d%x", "MEMwrite_data",fname,x,status);

		         _NFMdebug ((fname,"MEM write data: status = <0x%.8x>\n", status));
                         MEMclose(&save_buffer);
		         return (NFM_E_SEVERE_ERROR);
       		}


      for (x = 1; x < (save_buffer) -> rows; ++x)
       {
         count = (save_buffer) -> columns * x;
/* Check the n_status of each row from row # 2 .....
   row 1 has data regarding destination */
         n_status = atol(data[count+FTO_STATUS1]);
         if(n_status == NFM_MOVE || n_status == NFM_LFM_MOVE || n_status == NFM_NFS_MOVE || NFM_LFM_NFS_MOVE)
          {
            dst_file [0] = 0;

            sprintf (temp, "%dXXXXXX", x);
            sprintf (dst_file, "/usr/tmp/%s",  mktemp (temp));

/* Load the temporary name in COFILENAME */

            status = MEMwrite_data (save_buffer, dst_file, x + 1, FTO_COFILENAME + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose(&save_buffer);
               ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMwrite_data",fname,"status",status); 
               _NFMdebug((fname," MEM Write Data : status = <0x%.8x>\n", NFM_E_MEM));
               return (NFM_E_SEVERE_ERROR);
             }
          }
       }

/* set the protocol value based on the existence of TCPIP and or XNS */
/* Check the source node also */
              if    (! strcmp (filexfer_loc_sa.LOCAL_SA[FTO_TCPIP], "Y")  && 
                     ! strcmp (data [FTO_TCPIP], "Y"))
                 protocol = NET_TCP;
              else if    (! strcmp ( filexfer_loc_sa.LOCAL_SA[FTO_XNS], "Y")  && 
                          ! strcmp (data [FTO_XNS], "Y"))
                 protocol = NET_XNS;
              else   
              {
                 _NFMdebug((fname,"<WARNING> Source and destination have no match on \
protocol. Proceeding ....\n"));

                 protocol = NULL;
	      }


      status1 = NFMs_dest_recv_clix (data [FTO_NODENAME], data [FTO_USERNAME],data[FTO_PASSWD],
               protocol, &save_buffer);

/* MEMbuild the buffer_ptr to see if transfer succeeded */
      status = MEMbuild_array (save_buffer);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array",fname,"status",status);

         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }

/* Check if all files were transfered successfully
   if not set the status for files that were not transfered successfully
*/
      data    = (char **) (save_buffer) -> data_ptr;
      if(status1 != NFM_S_SUCCESS )
       {
        for(x=1;x < (save_buffer)->rows; x++)
	{
		count = save_buffer->columns * x ;
		n_status = atol(data[count+FTO_STATUS1]);
		if(n_status != NFM_TRANSFERED)
		{
			MEMwrite_data(*buffer_ptr,data[count+FTO_STATUS1],x+1,FTO_STATUS1+1);
			MEMwrite_data(*buffer_ptr,data[count+FTO_STATUS2],x+1,FTO_STATUS2+1);
			MEMwrite_data(*buffer_ptr,data[count+FTO_STATUS3],x+1,FTO_STATUS3+1);
		}
        }
         _NFMdebug((fname,"NFMs_dest_recv_clix failed : status = <0x%.8x>\n",
         status1));
       }
/* Complete the transfer to real destination */
      status = MEMbuild_array (*buffer_ptr);
      if (status != MEM_S_SUCCESS)
       {
         NFMrm_co_files(&save_buffer, 0 );
         MEMclose (&save_buffer);
         ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMbuild_array",fname,"status",status); 
         _NFMdebug((fname," MEM Write Data : status = <0x%.8x>\n", NFM_E_MEM));
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }
      data2   = (char **) (*buffer_ptr) -> data_ptr;


/* decrypt the password */

      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         NFMrm_co_files(&save_buffer,0);
         MEMclose (&save_buffer);
         status = NFM_E_NET_DECRYPT_CO_LOCATION;
         _NFMdebug ((fname,"Decrypt Passwd : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s%s%s%s",node_name,user_name,passwd,"");
         return (NFM_E_SEVERE_ERROR);
       }


      if(connect_status == FMU_MC)
      {
         status = NETfmu_connect(node_name,user_name,dec_passwd);
	 if (status != NET_S_SUCCESS)
         {
            NFMrm_co_files(&save_buffer,0);
            MEMclose(&save_buffer);
            ERRload_struct(NFM,NFM_E_FMU_CONNECT_NONCLIX,"%s%s%s",node_name,user_name,passwd);
            _NFMdebug((fname,"NETfmu_connect failed to node <%s> username <%s>\n\
passwd <%s> : status <0x%.8x>\n",node_name,user_name,passwd,status));
	    return(NFM_E_SEVERE_ERROR);
         }
      }

      for (x = 1; x < (*buffer_ptr) -> rows; ++x)
       {
         count = (*buffer_ptr) -> columns * x;
         n_status = atol(data2[count+FTO_STATUS1]);

         if((n_status == NFM_MOVE || n_status == NFM_LFM_MOVE || n_status == NFM_NFS_MOVE || n_status == NFM_LFM_NFS_MOVE))
          {
            status = NFMappend_path_file (data2 [FTO_OPSYS],
                     data2 [FTO_PATHNAME], data2 [count + FTO_COFILENAME], dst_file);
            if (status != NFM_S_SUCCESS)
             {
                     _NFMdebug ((fname,"Append path failed : opsys <%s> pathname <%s>\n\
filename <%s> : status = <0x%.8x>\n",data2[FTO_OPSYS],data2[FTO_PATHNAME],
data2[count + FTO_COFILENAME], status));
/* Load the error for n_status and continue with next buffer */
                status1 = NFM_E_APPEND_CO ;
                NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,status1);
                continue ;
             }
            
	    if(connect_status == FTP_MC)
	    {
/* For local file manager transfers do the lfm check */
	         if(n_status == NFM_LFM_MOVE || n_status == NFM_LFM_NFS_MOVE )
                 {
                    status = NFMftp_check_local (node_name, user_name, dec_passwd,
	            dst_file);
                    if (status == NFM_S_SUCCESS ) 
                    {
                     ERRload_struct (NFM, NFM_E_LFM_FILE_EXISTS, "%s%s", dst_file,data2[FTO_NODENAME]);
                     _NFMdebug((fname,"File <%s> exists locally on <%s>: status = <0x%.8x>\n",dst_file,data2[FTO_NODENAME], NFM_E_LFM_FILE_EXISTS));
/* Load the error NFM_EXIST_LOCALLY for n_status and continue with next buffer */
              	      NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_LFM_EXISTS_LOCALLY);
                      status1= NFM_E_LFM_FILE_EXISTS ;
		      continue ;
                    }
                 }


            status = NFMftp_send (node_name, user_name, dec_passwd,
                     data [count + FTO_COFILENAME], dst_file, data2 [count + FTO_FILETYPE], &size);
            if (status != NFM_S_SUCCESS)
             {
               _NFMdebug((fname,"NFMftp_send failed: status = <0x%.8x>\n",
               status));
/* Load the error for n_status and continue with next buffer */
		status1 = NFM_E_FTP_SEND_CI_FILENAME;
                NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,status1);
		continue;
             }
	   }
	   else 
           {
/* For local file manager transfers do the lfm check */
	         if(n_status == NFM_LFM_MOVE || n_status == NFM_LFM_NFS_MOVE)
                 {
		    sprintf(rcmd_str,"dir %s",dst_file);
		    status = NFMfmu_rcmd(rcmd_str,""); 
                    if (status == NFM_S_SUCCESS ) 
                    {
                     ERRload_struct (NFM, NFM_E_LFM_FILE_EXISTS, "%s%s", dst_file,data2[FTO_NODENAME]);
                     _NFMdebug((fname,"File <%s> exists locally on <%s>: status = <0x%.8x>\n",dst_file,data2[FTO_NODENAME], NFM_E_LFM_FILE_EXISTS));
/* Load the error NFM_EXIST_LOCALLY for n_status and continue with next buffer */
              	      NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_LFM_EXISTS_LOCALLY);
                      status1= NFM_E_LFM_FILE_EXISTS ;
		      continue ;
                    }
                 }



            status = NETfmu_send (data [count + FTO_COFILENAME], dst_file, data2 [count + FTO_FILETYPE], (int *)&size);
            if (status != NET_S_SUCCESS)
             {
               _NFMdebug((fname,"NETfmu_send failed status = <0x%.8x>\n",
               status));
/* Load the error for n_status and continue with next buffer */
		status1 = NFM_E_FMU_SEND_CO_FILENAME ;
                status = NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,status1);
		continue;
             }
	   }

            n_status = NFM_TRANSFERED;
            size = atol ( data[count + FTO_CIFILESIZE]);
            NFMset_buf_stat(*buffer_ptr,x+1,FTO_CIFILESIZE + 1 , size);
            NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1 + 1 , n_status);

          }
       }
      if(connect_status == FMU_MC) NETfmu_disconnect();

      NFMrm_co_files(&save_buffer,0);
      MEMclose (&save_buffer);
     _NFMdebug((fname,"SUCCESSFUL:	status    <0x%.8x>\n",status1));
     return (status1); 
   }


 long NFMs_src_send_nonclix ( node_name, user_name, passwd,
			       protocol, buffer_ptr)
   char    *node_name, *user_name, *passwd;
   MEMptr   *buffer_ptr;
   long protocol ;
   {
      long     status1,status,n_status;
      long     x, count,y;
      char     **data,**data2;
      char     src_file [512], dst_file [512], temp [50];
      char     *fname="NFMs_src_send_nonclix";
      MEMptr   save_buffer = NULL ;
      long connect_status;
      char     dec_passwd [50];
      long 	NFMfmU_receive(), NFMftp_receive();
      long     size,NETid;

      _NFMdebug((fname,"Entry: nodename <%s> username <%s> passwd <%s>\n \
protocol <%d> MEMptr *buffer_ptr <%x> \n",node_name,user_name,passwd,protocol,*buffer_ptr));
/* Initialize */
      connect_status = 0;
      status1 = NFM_S_SUCCESS ;


/* save the old buffer */
      status = MEMsplit_copy_buffer (*buffer_ptr, &save_buffer, 1);
      
      if (status != MEM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMsplit_copy_buffer",fname,"status",status);

         _NFMdebug ((fname,"MEM split copy buffer : status = <0x%.8x>\n", status));
         return (NFM_E_SEVERE_ERROR);
       }
      status = MEMbuild_array (*buffer_ptr);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array",fname,"status",status);

         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }

      data    = (char **) (*buffer_ptr) -> data_ptr;

      status = MEMbuild_array (save_buffer);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array",fname,"status",status);

         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }

      data2    = (char **) (save_buffer) -> data_ptr;

/* figure out if it is a FTP or FMU machine */
     if ((! strcmp (data [FTO_MACHID], "VAX")) && (protocol == NET_XNS))  /* VAX - IGI */
	connect_status = FMU_MC ;
     else connect_status = FTP_MC ;



/* Change the first row in the saved buffer to server info */
	for(x=0; x < (*buffer_ptr)->columns  && x < FTO_MAX_BUF; x++)
		if((status=MEMwrite_data(save_buffer,filexfer_loc_sa.LOCAL_SA[x],1,x+1))!= MEM_S_SUCCESS)
       		{
		         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%d%x", "MEMwrite_data",fname,x,status);

		         _NFMdebug ((fname,"MEM write data: status = <0x%.8x>\n", status));
                         MEMclose(&save_buffer);
		         return (NFM_E_SEVERE_ERROR);
       		}


/* decrypt the password */

      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         status = NFM_E_NET_DECRYPT_CO_LOCATION;
         _NFMdebug ((fname,"Decrypt Passwd : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s%s%s%s",node_name,user_name,passwd,"");
         return (NFM_E_SEVERE_ERROR);
       }


      if(connect_status == FMU_MC)
      {
         status = NETfmu_connect(node_name,user_name,dec_passwd);
         if (status != NET_S_SUCCESS)
         {
            MEMclose(&save_buffer);
            ERRload_struct(NFM,NFM_E_FMU_CONNECT_NONCLIX,"%s%s%s",node_name,user_name,passwd);
            _NFMdebug((fname,"NETfmu_connect failed to node <%s> username <%s>\n\
passwd <%s> : status <0x%.8x>\n",node_name,user_name,passwd,status));
            return(NFM_E_SEVERE_ERROR);
         }
      }


      for (x = 1; x < (*buffer_ptr) -> rows; ++x)
       {
         count = (*buffer_ptr) -> columns * x;

/* Check the status of row 2 ......
   row 1 is source information */

         n_status = atol(data[count+FTO_STATUS1]);
         if(n_status == NFM_MOVE ||  n_status == NFM_MOVE_MOVE ||
	    n_status == NFM_MOVE_FIRST_TIME )
          {
            status = NFMappend_path_file (data[FTO_OPSYS],
                     data [FTO_PATHNAME], data [count + FTO_COFILENAME], src_file);
            if (status != NFM_S_SUCCESS)
             {
	       for(y=1;y < x; y++) unlink ( data2 [ (save_buffer)->columns * y +FTO_COFILENAME]);
               MEMclose (&save_buffer);
	       status1 = NFM_E_APPEND_CO;
               status = NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1 + 1 , status1);
	       ERRload_struct(NFM,status1,"%s%s",data[FTO_PATHNAME],data[count+FTO_COFILENAME]);
              _NFMdebug ((fname,"Append path failed : opsys <%s> pathname <%s>\n\
filename <%s> : status = <0x%.8x>\n",data[FTO_OPSYS],data[FTO_PATHNAME],
data[count + FTO_COFILENAME], status));
               return (status1);
             }

            dst_file [0] = 0;

            sprintf (temp, "%dXXXXXX", x);
            sprintf (dst_file, "/usr/tmp/%s",  mktemp (temp));
          if(connect_status == FTP_MC)
          {
            status = NFMftp_receive (node_name, user_name, dec_passwd,
                     src_file, dst_file, data [count + FTO_FILETYPE], &size);
            if (status != NFM_S_SUCCESS)
             {
	       for(y=1;y < x; y++) unlink ( data2 [ (save_buffer)->columns * y +FTO_COFILENAME]);
               MEMclose (&save_buffer);
	       status1 = NFM_E_FTP_REC_CO_FILENAME;
               status = NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1 + 1 , status1);
	       ERRload_struct(NFM,status1,"%s%s%s",data[count+FTO_COFILENAME],node_name,data[FTO_PATHNAME]);
	
	       
               _NFMdebug((fname,"NFMftp_receive failed: status = <0x%.8x>\n",
               status));
               return (status1);
             }
           }
           else
           {
            status = NETfmu_receive (src_file, dst_file, data [count + FTO_FILETYPE], (int *)&size);
            if (status != NET_S_SUCCESS)
             {
	       for(y=1;y < x; y++) unlink ( data2 [ (save_buffer)->columns * y +FTO_COFILENAME]);
               MEMclose (&save_buffer);
               NETfmu_disconnect();
	       status1 = NFM_E_FMU_REC_CO_FILENAME;
               status = NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1 + 1 , status1);
               _NFMdebug((fname,"NETfmu_receive failed status = <0x%.8x>\n",
               status));
               return (status1);
             }
           }
            status = MEMwrite_data (save_buffer, dst_file, x + 1, FTO_COFILENAME + 1);
            if (status != MEM_S_SUCCESS)
             {
	       for(y=1;y < x; y++) unlink ( data2 [ (save_buffer)->columns * y +FTO_COFILENAME]);
               MEMclose(&save_buffer);
               ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMwrite_data",fname,"status",status); 
               _NFMdebug((fname," MEM Write Data : status = <0x%.8x>\n", NFM_E_MEM));
               return (NFM_E_SEVERE_ERROR);
             }

          }
       }
      if(connect_status == FMU_MC) NETfmu_disconnect();


/* Set the value of protocol based on source and destination nodes info */
              if    (! strcmp (filexfer_loc_sa.LOCAL_SA [FTO_TCPIP], "Y")) 
                 protocol = NET_TCP;
              else if    (! strcmp (filexfer_loc_sa.LOCAL_SA [FTO_XNS], "Y") )
                 protocol = NET_XNS;
              else   
              {
                 _NFMdebug((fname,"<WARNING> Source and destination have no match on \
protocol. Proceeding ....\n"));

                 protocol = NULL;
	      }


/* Transfer files from temporary location */

      status1 = NFMs_src_send_clix (filexfer_loc_sa.LOCAL_SA [FTO_NODENAME], filexfer_loc_sa.LOCAL_SA [FTO_USERNAME],filexfer_loc_sa.LOCAL_SA[FTO_PASSWD],
               protocol, &save_buffer,&NETid ,  (long)1);

    
      status = MEMbuild_array (save_buffer);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array",fname,"status",status);

         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }

      data    = (char **) (save_buffer) -> data_ptr;

/*
      if (status1 != NFM_S_SUCCESS)
       {
         for (x = 1; x < (save_buffer) -> rows; ++x)
         {
            count = (save_buffer)->columns * x ;
	    status = MEMwrite_data(*buffer_ptr,data[count+FTO_STATUS1],x+1,FTO_STATUS1+1);
	    status = MEMwrite_data(*buffer_ptr,data[count+FTO_STATUS2],x+1,FTO_STATUS2+1);
	    status = MEMwrite_data(*buffer_ptr,data[count+FTO_STATUS3],x+1,FTO_STATUS3+1);
         }
         MEMclose (&save_buffer);
         _NFMdebug((fname,"NFMs_src_send_clix failed : status = <0x%.8x>\n",
         status1));
         return (status1);
       }
*/

      for (x = 1; x < (save_buffer) -> rows; ++x)
       {

            count = (save_buffer)->columns * x ;

            status = MEMwrite_data (*buffer_ptr, data[count+FTO_CIFILESIZE], x + 1, FTO_CIFILESIZE + 1);
            if (status != MEM_S_SUCCESS)
            {
               ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMwrite_data",fname,"status",status); 
	       status1 = NFM_E_MEM_ERR ;
	    }
            status = MEMwrite_data (*buffer_ptr, data[count+FTO_STATUS1], x + 1, FTO_STATUS1 + 1);
            if (status != MEM_S_SUCCESS)
            {
               ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMwrite_data",fname,"status",status); 
	       status1 = NFM_E_MEM_ERR ;
	    }
            status = MEMwrite_data (*buffer_ptr, data[count+FTO_STATUS2], x + 1, FTO_STATUS2 + 1);
            if (status != MEM_S_SUCCESS)
            {
               ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMwrite_data",fname,"status",status); 
	       status1 = NFM_E_MEM_ERR ;
	    }
            status = MEMwrite_data (*buffer_ptr, data[count+FTO_STATUS3], x + 1, FTO_STATUS3 + 1);
            if (status != MEM_S_SUCCESS)
            {
               ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMwrite_data",fname,"status",status); 
	       status1 = NFM_E_MEM_ERR ;
	    }
          }


      NFMrm_co_files(&save_buffer,0);
      MEMclose (&save_buffer);
     _NFMdebug((fname,"SUCCESSFUL:	status    <0x%.8x>\n",status1));
     return (status1); 
}
#endif
