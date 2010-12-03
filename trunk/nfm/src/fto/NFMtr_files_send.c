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

long NFMfs_src_send_clix ( MEMptr *buffer_ptr)
{
  char  *fname="NFMfs_src_send_clix";
  long   status,status1,status2,status3;
  char **data;
  long   connect_status = 0;
  long   x, y, count, count1,ft_ci_flag,pos;
  char   dec_pass [50];
  char   src_file [512], dst_file [512],file_old[512];
  char   new_file_old[512], *slash; 
  char   tmp_str[1024];
  long   size, protocol,n_status,n_status1,n_status2;
  int   *FILE_SOCK,FILE_SOCK_VAL;

  /* Initialize */
  connect_status = n_status = n_status1 =ft_ci_flag =  0;
  FILE_SOCK = &FILE_SOCK_VAL;
 *FILE_SOCK = -1;
  status1 = NFM_S_SUCCESS ;
  status2 = status3 = 0;

  /* MEMbuild array to access the data */
  status = MEMbuild_array (*buffer_ptr);
  g_return_val_if_fail(status == MEM_S_SUCCESS,NFM_E_MEM_BUILD_ARRAY_BUFFER);

  data    = (char **) (*buffer_ptr) -> data_ptr;

  for (x = 1; x < (*buffer_ptr) -> rows; ++x)
  {
    count = (*buffer_ptr) -> columns * x;

    /* Check the status of in buffer for row 2 ... row 1 is the source info */
    n_status = atol ( data [ count + FTO_STATUS1] );
    if((n_status == NFM_MOVE ||  n_status == NFM_MOVE_MOVE || n_status == NFM_MOVE_FIRST_TIME ))
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
      connect_status = FTP_MC;
 
      for (y = x; y < (*buffer_ptr) -> rows; ++y)
      {
        count1    = (*buffer_ptr) -> columns * y;
        n_status1 = atol ( data [ count1 + FTO_STATUS1] );
	      if (n_status1 == NFM_MOVE_FIRST_TIME) ft_ci_flag = 1;
	      else                                  ft_ci_flag = 0;

	      n_status2 = NFM_TRANSFERED ;
        if((n_status1 == NFM_MOVE ||  n_status1 == NFM_MOVE_MOVE || n_status == NFM_MOVE_FIRST_TIME ) &&
	         (! strcmp (data [count + FTO_SANO],data[count1+FTO_SANO])))
        {
          status = NFMappend_path_file (data [FTO_OPSYS],data [FTO_PATHNAME], data [count1 + FTO_COFILENAME], src_file);
          if (status != NFM_S_SUCCESS)
          {
		        status1 = NFM_E_APPEND_CO;
		        NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
            return (status1);
          }
          status = NFMappend_path_file (data[count1+FTO_OPSYS],data[count1+FTO_PATHNAME],data[count1+FTO_CIFILENAME],dst_file);
          if (status != NFM_S_SUCCESS)
          {
		        status1 = NFM_E_APPEND_CI;
		        NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
            return (status1);
          }
          /* Generate the file_old if NFM_MOVE_MOVE is specified */
		      if(n_status1 == NFM_MOVE_MOVE)
		      {
			      n_status2 = NFM_MOVE_TRANSFERED ;
            status = NFMappend_path_file (data[count1+FTO_OPSYS],data[count1+FTO_PATHNAME],data[count1+FTO_FILEOLD],file_old);
            if (status != NFM_S_SUCCESS)
            {
		          status1 = NFM_E_APPEND_FILEOLD;
		          NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
              return (status1);
            }
		      }
          size = 0;

          // Always ftp
          g_assert(connect_status == FTP_MC);

		      if(n_status1 == NFM_MOVE_MOVE)
		      {
            /* Copy the cifilename to fileold */
            status = NFMftp_rename (data [count1 + FTO_NODENAME],
                                    data [count1 + FTO_USERNAME],
                                    dec_pass, dst_file, file_old,
                                    data[count1 + FTO_MACHID]);
			      if(status != NFM_S_SUCCESS)
			      {
				      n_status2 = NFM_MOVE_MOVE_WARNING ;
			      }
		      }
		      if(n_status1 == NFM_MOVE_FIRST_TIME)
		      {
            status = NFMftp_check_local (data[count1+FTO_NODENAME], data[count1+FTO_USERNAME], dec_pass, dst_file);
			      if(status == NFM_S_SUCCESS )
			      {
				      status1 = NFM_E_CI_FILENAME_EXISTS ;
              NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
				      return(status1);
			      }
		      }
          // Send it
          status = NFMftp_send (data [count1 + FTO_NODENAME],
                                data [count1 + FTO_USERNAME], dec_pass, src_file, dst_file,
                                data [count1 + FTO_FILETYPE], &size);
          if (status != NFM_S_SUCCESS)
          {
			      switch(status)
	          {
				      case NFM_E_NO_FILENAME:              status1 = NFM_E_NO_CO_FILENAME;   break;
				      case NFM_E_STAT:                     status1 = NFM_E_STAT_CO_FILENAME; break;
				      case NFM_E_FTP_FOPEN_WRITE_F_SHELL:  status1 = status;                 break;
				      case NFM_E_FTP_FOPEN_WRITE_F_SCRIPT: status1 = status;                 break;
				      case NFM_E_FTP_FWRITE_F_SHELL:
                status1 = status;
                status  = NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,xfer_buf_status.status2);
                status  = NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS3+1,xfer_buf_status.status3);
					      break;
				      case NFM_E_FTP_FWRITE_F_SCRIPT:
                status1 = status;
                status  = NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,xfer_buf_status.status2);
                status  = NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS3+1,xfer_buf_status.status3);
					      break;
				      default:
		            status1 = NFM_E_FTP_SEND_CO_FILENAME;
			      }
            /* Load the error for n_status return */
		        NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
            return (status1);
          } // Error from ftp_send

          // File is sent, check some stuff
          if (size < 0)
          {
            // Should be no need to disconnect
            // NFMswitch_disconnect(connect_status,FILE_SOCK);
            status1 = status = NFM_E_BAD_CO_FILE_SIZE;
		        status2 = size ;
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,status2);
            return (status1);
          }
          // Everything is fine
		      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_CIFILESIZE+1,size);
		      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,n_status2);
        } // n_status1 loop
      } // Y Loop
    } // n_status loop
  } // X Loop

  // No need to disconnect
  return (NFM_S_SUCCESS);
}
