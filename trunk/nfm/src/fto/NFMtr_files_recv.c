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
*			NFMfs_dest_recv_clix				*
*									*
*	This procedure is the file server side function, which is       *
*	called when the file server receives the command		*
*	NFM_DEST_RECV_FILES. The files are moved and the status is 	*
*	returned in n_status within the buffer. A fatal error will cause*
*	immediate erroring out, else the function will try to do as 	*
*	many files as possible						*
************************************************************************/

long NFMfs_dest_recv_clix ( MEMptr *buffer_ptr)
{
  char    *fname="NFMfs_dest_recv_clix";
  long     status,status1,status2,status3,dst_stat_status;
  char     **data;
  long     connect_status = 0;
  long     x, y, count, count1;
  char     dec_pass [NFM_PASSWD],NFS_CO_DIR[NFM_FILENAME+1];
  char     src_file [512], dst_file [512];
  long     size, protocol,n_status,n_status1;
  struct   stat  fbuff;
  int     *FILE_SOCK,FILE_SOCK_VAL;

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
  if(strlen(data[FTO_PATHNAME]) > 0 ) strncpy(NFS_CO_DIR,data[FTO_PATHNAME],NFM_FILENAME);
  else                                strncpy(NFS_CO_DIR,NFMuser_info.dir,NFM_FILENAME);
  NFS_CO_DIR[NFM_FILENAME] = '\0';

  for (x = 1; x < (*buffer_ptr) -> rows; ++x)
  {
    /* Extract n_status from the second position onwards. First position is the "check out location"  */

    /* Process All the rows even if error occurs in processing */
    count = (*buffer_ptr) -> columns * x;
    n_status = atol(data [ count + FTO_STATUS1]);

    /* If the  status is *_MOVE move the files */
    if(n_status == NFM_MOVE || n_status == NFM_LFM_MOVE || n_status == NFM_NFS_MOVE || n_status == NFM_LFM_NFS_MOVE)
    {
      /* Close a previous connection is open */
		  connect_status = 0;

      /* set the protocol value based on the existence of TCPIP and or XNS */
      protocol = NET_TCP;

      /* Decrypt the password */
      status = NFMdecrypt (data [count + FTO_PASSWD], dec_pass);
      if (status != NFM_S_SUCCESS)
      { 
		    status  = NFM_E_NET_DECRYPT;
        status1 = NFM_E_NET_DECRYPT_CI_LOCATION ;
		    NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,status1);
		    continue ;
      }

      /* Check the source location operating system . Use the appropriate method to establish connection and transfer files */
      connect_status = FTP_MC ;

      // Still not sure about this loop
      for (y = x; y < (*buffer_ptr) -> rows; ++y)
      {
        count1 = (*buffer_ptr) -> columns * y;
        n_status1 = atol(data [ count1 + FTO_STATUS1]);

        if((n_status1 == NFM_MOVE || n_status1 == NFM_LFM_MOVE || n_status1 == NFM_NFS_MOVE || n_status1 == NFM_LFM_NFS_MOVE) &&
           (! strcmp (data [count + FTO_SANO],data[count1+FTO_SANO])))
        {
          // Always does this
          status = NFMappend_path_file (data [count1 + FTO_OPSYS],data [count1 + FTO_PATHNAME], data [count1 + FTO_CIFILENAME], src_file);
          if (status != NFM_S_SUCCESS)
          {
            /* Load the error  for n_status and continue with next buffer */
		        status1 = NFM_E_APPEND_CI ;
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
		        continue ;
          }
          status = NFMappend_path_file (data [FTO_OPSYS],data [FTO_PATHNAME], data [count1 + FTO_COFILENAME], dst_file);
          if (status != NFM_S_SUCCESS)
          {
            /* Load the error NFM_MOVE_FAILURE for n_status and continue with next buffer */
		        status1 = NFM_E_APPEND_CO ;
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
		        continue ;
          }
          size = 0;

          /* Verify that file is not there locally */
          // A return of 0 means the file was found
          dst_stat_status = stat (dst_file, &fbuff);

          /* For local file manager transfers do the lfm check */
	        if(n_status1 == NFM_LFM_MOVE || n_status1 == NFM_LFM_NFS_MOVE )
          {
            /* Make sure it is not "/usr/tmp" as we use this for temporary transfer */
		        if(strncmp(dst_file,"/usr/tmp", 8 ) == 0 )dst_stat_status = NFM_S_SUCCESS ;
            if (dst_stat_status == 0 ) 
            {
		          if(n_status1 == NFM_LFM_MOVE ) NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,NFM_E_LFM_EXISTS_LOCALLY);
              else                           NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,NFM_E_LFM_NFS_EXISTS_LOCALLY);
              status1= NFM_E_LFM_FILE_EXISTS ;
		          continue ;
            }
          }
          /* If the file exists locally change mode to   0777  Now the file can be written to */
          // Other code kicks in to control overwrites???
		      if(dst_stat_status == 0)
		      {
			      status = NFMchmod(dst_file,0777);
		      }

          // Always ftp
          g_assert(connect_status == FTP_MC);
          status = NFMftp_receive (
            data [count1 + FTO_NODENAME],
            data [count1 + FTO_USERNAME], dec_pass, src_file, dst_file,
            data [count1 + FTO_FILETYPE], &size);
          if (status != NFM_S_SUCCESS)
          {
			      switch(status)
			      {
				      case  NFM_E_NO_FILENAME:              status1 = NFM_E_NO_CO_FILENAME; break;
  				    case  NFM_E_FTP_FOPEN_WRITE_F_SHELL:  status1 = status; break;
			  	    case  NFM_E_FTP_FOPEN_WRITE_F_SCRIPT: status1 = status; break;
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
			      } // Status switch statement
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
		        NFMchmod(dst_file,fbuff.st_mode); // This I don't like
		        continue ;
          } // NFMftp_receive status check
		      if ( n_status1 == NFM_NFS_MOVE || n_status1 == NFM_LFM_NFS_MOVE)
		      {
			      status = NFMchmod(dst_file,0444);
			      if(status != NFM_S_SUCCESS) { }
          }
          if (size < 0)
          {
            status1=	status = NFM_E_BAD_CO_FILE_SIZE;
		        status2 = size ;
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,status2);
            continue ;
          }
          n_status1 = NFM_TRANSFERED ;
          NFMset_buf_stat(*buffer_ptr,y+1,FTO_CIFILESIZE+1,size);
          NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS1+1,n_status1);
        } // n_status1 loop
      } // Y Loop
    } // n_status loop
  } // X loop

  // No need to disconnect
  return (status1);
}

