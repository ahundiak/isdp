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

 long NFMfs_dest_recv_clix ( buffer_ptr)
   MEMptr *buffer_ptr;
   {
      char *fname="NFMfs_dest_recv_clix";
      long     status,status1,status2,status3,dst_stat_status;
      char     **data;
      long     connect_status = 0;
      long     x, y, count, count1;
      char     dec_pass [NFM_PASSWD],NFS_CO_DIR[NFM_FILENAME+1];
      char     src_file [512], dst_file [512];
      long     size, protocol,n_status,n_status1;
      struct   stat  fbuff;
      int     *FILE_SOCK,FILE_SOCK_VAL;


      _NFMdebug ((fname,"Entry MEMptr *buffer_ptr = <%x>\n",*buffer_ptr));

/* Initialize variables */
      connect_status = 0;
      FILE_SOCK = &FILE_SOCK_VAL;
      *FILE_SOCK = -1 ;
      n_status = n_status1 = status2 = status3 = 0;
      status1 = NFM_S_SUCCESS ;

/* MEMbuild array to access data in the buffer Return on failure */

      status = MEMbuild_array (*buffer_ptr);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array for *buffer_ptr",fname,"status",status);

         _NFMdebug ((fname,"MEM Build Array for *buffer_ptr : status = <0x%.8x>\n", status));
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }


      data    = (char **) (*buffer_ptr) -> data_ptr;
      if(strlen(data[FTO_PATHNAME]) > 0 )
	strncpy(NFS_CO_DIR,data[FTO_PATHNAME],NFM_FILENAME);
      else
	strncpy(NFS_CO_DIR,NFMuser_info.dir,NFM_FILENAME);
      NFS_CO_DIR[NFM_FILENAME] = '\0';


      for (x = 1; x < (*buffer_ptr) -> rows; ++x)
       {
/* Extract n_status from the second position onwards. First position is the
   "check out location"  */

/* Process All the rows even if error occurs in processing */

         count = (*buffer_ptr) -> columns * x;
         n_status = atol(data [ count + FTO_STATUS1]);
/* If the  status is *_MOVE move the files */

         if(n_status == NFM_MOVE || n_status == NFM_LFM_MOVE || 
            n_status == NFM_NFS_MOVE || n_status == NFM_LFM_NFS_MOVE)
          {
/* Close a previous connection is open */

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

/* set the protocol value based on the existence of TCPIP and or XNS */
/* Check the source node also */
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
                  _NFMdebug ((fname," Net Decrypt : status = <0x%.8x>\n", status));
		  status=NFM_E_NET_DECRYPT;
		  ERRload_struct(NFM,status,"%s","Password");
/* Load the error NFM_MOVE_FAILURE for n_status and continue with next buffer */
                  status1 = NFM_E_NET_DECRYPT_CI_LOCATION ;
		  NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,status1);
		  continue ;
                }

/* Check the source location operating system . Use the appropriate method
   to establish connection and transfer files */

               if ((! strcmp (data [count + FTO_OPSYS], "CLIX")) || (! strcmp (data [count + FTO_OPSYS], "UNIX")))
                {
		   connect_status = TLI_MC_CONN_LESS;
/* SAVE THE CONNECTION FOR LATER USE JUST IN CASE NFS IS
   THE ONLY OPERATION */
		 if(data[count + FTO_PLATTERNAME][0] != NULL) 
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
					status2 = net_buf_status.status2;
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
/* Load the error  for n_status and continue with next buffer */
              	      NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,status1);
              	      NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS2+1,status2);
              	      NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS3+1,status3);
		      continue ;
                    }
                    connect_status = TLI_MC ;
		   }
                }
               else if ((! strcmp (data [count + FTO_OPSYS], "VMS")) &&
                        (protocol == NET_XNS)) /* VAX - IGI */ 
                {
                   status = NETfmu_connect (data [count + FTO_NODENAME],
                            data [count + FTO_USERNAME],dec_pass);
                   if (status != NET_S_SUCCESS)
                    {
                      NETfmu_disconnect();
                      _NFMdebug ((fname,"fmu_connect : status = <0x%.8x>\n",
                      status));
/* Load the error for n_status and continue with next buffer */
		      status1 = NFM_E_FMU_CONNECT_FS1_FS2;
              	      NFMset_buf_stat ( *buffer_ptr,x+1,FTO_STATUS1+1,status1);
		      continue ;
                    }
                    connect_status = FMU_MC ;
                }
               else
                    connect_status = FTP_MC ;

		
            for (y = x; y < (*buffer_ptr) -> rows; ++y)
             {
               count1 = (*buffer_ptr) -> columns * y;
               n_status1 = atol(data [ count1 + FTO_STATUS1]);

               if((n_status1 == NFM_MOVE || n_status1 == NFM_LFM_MOVE || n_status1 == NFM_NFS_MOVE || n_status1 == NFM_LFM_NFS_MOVE) &&

	              (! strcmp (data [count + FTO_SANO],data[count1+FTO_SANO])))
                {
                  status = NFMappend_path_file (data [count1 + FTO_OPSYS],
                           data [count1 + FTO_PATHNAME], data [count1 + FTO_CIFILENAME], 
                           src_file);
                  if (status != NFM_S_SUCCESS)
                   {
                     _NFMdebug ((fname,"Append path failed : opsys <%s> pathname <%s>\n\
filename <%s> : status = <0x%.8x>\n",data[count1 + FTO_OPSYS],data[count1 + FTO_PATHNAME],
data[count1 + FTO_CIFILENAME], status));
/* Load the error  for n_status and continue with next buffer */
		      status1 = NFM_E_APPEND_CI ;
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
		      continue ;
                   }

                  status = NFMappend_path_file (data [FTO_OPSYS],
                           data [FTO_PATHNAME], data [count1 + FTO_COFILENAME], dst_file);
                  if (status != NFM_S_SUCCESS)
                   {
                     _NFMdebug ((fname,"Append path failed : opsys <%s> pathname <%s>\n\
filename <%s> : status = <0x%.8x>\n",data[FTO_OPSYS],data[FTO_PATHNAME],
data[count1 + FTO_COFILENAME], status));
/* Load the error NFM_MOVE_FAILURE for n_status and continue with next buffer */
		      status1 = NFM_E_APPEND_CO ;
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
		      continue ;
                   }
 
                  size = 0;
/* Verify that file is not there locally */

/* 12/9/92 - KT - Replace 'Stat' with stat
                 dst_stat_status = Stat (dst_file, &fbuff);
*/
                 dst_stat_status = stat (dst_file, &fbuff);
/* For local file manager transfers do the lfm check */
	         if(n_status1 == NFM_LFM_MOVE || n_status1 == NFM_LFM_NFS_MOVE )
                 {
/* Make sure it is not "/usr/tmp" as we use this for temporary transfer */
		    if(strncmp(dst_file,"/usr/tmp", 8 ) == 0 )
                     dst_stat_status = NFM_S_SUCCESS ;
                    if (dst_stat_status == 0 ) 
                    {
                     ERRload_struct (NFM, NFM_E_LFM_FILE_EXISTS, "%s%s", dst_file,data[FTO_NODENAME]);
                     _NFMdebug((fname,"File <%s> exists locally on <%s>: status = <0x%.8x>\n",dst_file,data[FTO_NODENAME], NFM_E_LFM_FILE_EXISTS));
/* Load the error NFM_EXIST_LOCALLY for n_status and continue with next buffer */
		      if(n_status1 == NFM_LFM_MOVE )
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,NFM_E_LFM_EXISTS_LOCALLY);
                      else
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,NFM_E_LFM_NFS_EXISTS_LOCALLY);
                      status1= NFM_E_LFM_FILE_EXISTS ;
		      continue ;
                    }
                 }
/* If the file exists locally change mode to   0777 
   Now the file can be written to */
		if(dst_stat_status == 0)
		{
			status = NFMchmod(dst_file,0777);
/* CHMOD Failed OK 
   FOPEN WRITE WILL FAIL IF FILE IS NOT WRITABLE BY USER
   PROCEED ANYWAY
			if(status != NFM_S_SUCCESS )
			{
				_NFMdebug((fname,"Cannot change mode to 0777 \
for check out file <%s>: status <0x%.8x>\n",dst_file,status));
                		NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,NFM_E_CHMOD_CO_FILENAME);
                		NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,
                                  0777);
				continue;
			}	
*/
		}

/* If it is a TLI_MC 
   Check if NFS is specified, mountpoint is given and
   TCP/IP is set to 'Y' on both the machines 
*/
		if((connect_status == TLI_MC || connect_status == TLI_MC_CONN_LESS)  && 
		   !strcmp(data[FTO_NFS],"Y")  &&
		   !strcmp(data[count1+FTO_NFS],"Y"))
		{
/* If a file was transfered using NFS remove it anyway
   as a new nfs_file_transfer will be performed
*/
/*
			if((n_status1 == NFM_MOVE || n_status1 == NFM_LFM_MOVE))
			{
*/
				status = NFMnfs_file_remove(data[FTO_NODENAME]
,data[count1+FTO_NODENAME],data[count1+FTO_PATHNAME],data[count1+FTO_CIFILENAME],
data[count1+FTO_COFILENAME],NFS_CO_DIR,data[count1+FTO_MOUNTPOINT], 0);
				if(status != NFM_S_SUCCESS)
				{
_NFMdebug((fname,"Unable to remove NFS mounted/linked file <%s/%s>\n",
data[FTO_PATHNAME],data[count1+FTO_COFILENAME]));
                                  NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS1+1,NFM_E_NFS_REMOVE_FILE);

				}
/*
			}
*/
			if(n_status1 == NFM_NFS_MOVE || n_status1 == NFM_LFM_NFS_MOVE)
			{
				status = NFMnfs_file_transfer(data[FTO_NODENAME]
,data[count1+FTO_NODENAME],data[count1+FTO_PATHNAME],data[count1+FTO_CIFILENAME],
data[count1+FTO_COFILENAME],NFS_CO_DIR,data[count1+FTO_MOUNTPOINT],NO_LFM_CHECK);
				if(status == NFM_S_SUCCESS)
				{

/* Set size to 0 for NFSED files */

				  size = 0;
                                  NFMset_buf_stat(*buffer_ptr,y+1,FTO_CIFILESIZE+1,size);

                                  NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS1+1,NFM_NFSED);
				 _NFMdebug((fname,"NFS Used for file <%s/%s>\n",
data[FTO_PATHNAME],data[count1+FTO_COFILENAME]));
				  continue;
		
				}
				else
				{
/* reset the mountpoint and n_nfs fields */
					MEMwrite_data(*buffer_ptr,"",y+1,FTO_MOUNTPOINT+1);
					MEMwrite_data(*buffer_ptr,"",y+1,FTO_NFS+1);
				}
			}
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
			      } // Status switch statement
            NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
		        NFMchmod(dst_file,fbuff.st_mode);
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
        }
      }
    } // Should be the test for NFM_MOVE
  } // Master loop for each row

  // connect_status should always be three, no need to disconnect
  g_assert(connect_status == FTP_MC);
  return (status1);
}

