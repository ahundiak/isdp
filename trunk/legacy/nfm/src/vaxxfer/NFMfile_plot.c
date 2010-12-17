#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

#define NO_LFM_CHECK            0

extern NFMuser_info_struct NFMuser_info ;


/************************************************************************
*									*
*			_NFMfs_plot_files				*
*									*
*	This function is used by plot item in which case the destination*
*	for all the files is the same storage location			*
************************************************************************/

long _NFMfs_plot_files (buffer_ptr)

MEMptr  *buffer_ptr;
{
  char	   *fname="_NFMfs_plot_files";
  long     status,protocol;
  char     **data;
  long     NFMs_dest_plot_clix ();

  _NFMdebug((fname,"Entry > MEMptr: *buffer_ptr = <%x>\n",*buffer_ptr));



/* MEM build the buffer_ptr to access the data */

  status = MEMbuild_array (*buffer_ptr);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array for *buffer_ptr",fname,"status",status); 
    _NFMdebug((fname,"MEM operation failed: Operation <%s> for <%s> status <0x%.8x>\n","MEMbuild_array","*buffer_ptr",status));
/* Return NFM_E_FAILURE to indicate General failure: Do not look in buffer */
    return (NFM_E_MEM_BUILD_ARRAY_BUFFER);        
  }
/* Check to see if local sa is set otherwise set it */
  if(filexfer_loc_sa.local_sa_flag != NFM_S_SUCCESS)
  {
	status = NFMget_server_sa_info();
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to set server information in local\
buffer. status : <0x%.8x>\n",status));
		ERRload_struct(NFM,NFM_I_LOAD_SERVER_NODE_INFO,"%x",status);
	}
  }


  data   = (char **) (*buffer_ptr) -> data_ptr;

/* set the value of protocol 
   for Server to Fileserver Connection */

  if (! strcmp (data [FTO_TCPIP], "Y") &&
      ! strcmp (filexfer_loc_sa.LOCAL_SA[FTO_TCPIP],"Y")) protocol = NET_TCP;
  else if (! strcmp (data [FTO_XNS], "Y") &&
           ! strcmp ( filexfer_loc_sa.LOCAL_SA[FTO_XNS], "Y")) protocol = NET_XNS;
  else      
  {
                         protocol = NULL;
     _NFMdebug((fname,"<WARNING> No match found for protocol between Server and\
file_server proceeding with NULL\n"));
  }



/* check if the destination location is a CLIX m/c */

  if ((! strcmp (data [FTO_OPSYS], "CLIX"))||(! strcmp (data [FTO_OPSYS], "UNIX")))
  {
    status = NFMs_dest_plot_clix(data [FTO_NODENAME], 
                                 data [FTO_USERNAME], 
				 data [FTO_PASSWD],
			         protocol, buffer_ptr);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFM File server destination receive clix : status = <0x%.8x>\n",
      status));
      return (status);             
    }
  }
  else
  {
      /** Can't plot on nonclix machines**/ 
      return (NFM_E_PLOT_NOT_CLIX);             
  }
  _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);     
}

/************************************************************************
*									*
*			NFMs_dest_plot_clix				*
*									*
*	This function is called during plot item. The destination node  *
* 	is same for all the files. The destination node is clix		*
*	This is the server side function. It will open a connection to  *
* 	destination node file server and instruct it to receive files   *
*       from the sources. 						*
************************************************************************/

long NFMs_dest_plot_clix (node_name, user_name, passwd,
                          protocol, buffer_ptr)
   char     *node_name, *user_name, *passwd;
   long     protocol;
   MEMptr    *buffer_ptr;
   {
      char *fname="NFMs_dest_plot_clix";
      long    status, status1, sock_no;
      char dec_passwd[NFM_PASSWD], **data;
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


/* connect to the destination file server */

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

      status = NFMcl_send_buffer (&sock_no, NFM_DEST_PLOT_FILES, *buffer_ptr);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Failed to send command NFM_DEST_PLOT_FILES\n\
to fileserver at nodename <%s> username <%s> sock_no <%d> MEMptr *buffer_ptr \
<%x> status = <0x%.8x>\n",node_name,user_name,sock_no,*buffer_ptr, status));
	 status = NFM_E_SEND_COMMAND_S_TO_FS ;
	 ERRload_struct(NFM,status,"%s%s%s","Plot :Send NFM_DEST_PLOT_FILES",
node_name,user_name);
	 NFMcl_fs_exit(&sock_no);
         return (NFM_E_SEVERE_ERROR);
       }      

      status1 = NFM_S_SUCCESS;

/* receive reply back from file server */

      save_buffer = NULL ;
      status = NFMcl_receive_buffer (&sock_no, &status1, &save_buffer);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         _NFMdebug ((fname,"Failed to receive response to command NFM_DEST_PLOT_FILES\n\
from fileserver at nodename <%s> username <%s> sock_no <%d> MEMptr *buffer_ptr\
 <%x> status = <0x%.8x>\n",node_name,user_name,sock_no,*buffer_ptr, status));
	 status = NFM_E_RECEIVE_RESPONSE_FS_TO_S ;
	 ERRload_struct(NFM,status,"%s%s%s","Plot :Receive NFM_DEST_PLOT_FILES",
node_name,user_name);
	 NFMcl_fs_exit(&sock_no);
         return (NFM_E_SEVERE_ERROR);
       }      
	MEMclose(buffer_ptr);
	*buffer_ptr = save_buffer ;

      status = NFMcl_fs_exit (&sock_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFMcl_fs_exit Failed:Connection to nodename <%s>\
username <%s> status = <0x%.8x>\n",node_name,user_name, status));
	status = NFM_E_EXIT_S_TO_FS;
	 ERRload_struct(NFM,status,"%s%s%s","Plot :Exit NFM_DEST_PLOT_FILES",
node_name,user_name);
         return (status);
       }

      if (status1 == NFM_E_IPLOT_GEN)
       {
         status = MEMbuild_array (save_buffer);
         if (status != MEM_S_SUCCESS)
         {
           ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array for *buffer_ptr",fname,"status",status);
           _NFMdebug ((fname,"MEM Build Array for *buffer_ptr : status = <0x%.8x>\n", status));
           return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
         }
	 data = (char **)save_buffer->data_ptr;
	 
         _NFMdebug ((fname,"Iplot generate Failed at File Server\n Error = <%s>\n", data[FTO_CIFILENAME]));
	ERRload_struct(NFM,status1,"%s", data[FTO_CIFILENAME]);
         return (status1);
       }
	
      if (status1 == NFM_E_IPLOT_SUBMIT)
       {
         status = MEMbuild_array (save_buffer);
         if (status != MEM_S_SUCCESS)
         {
           ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array for *buffer_ptr",fname,"status",status);
           _NFMdebug ((fname,"MEM Build Array for *buffer_ptr : status = <0x%.8x>\n", status));
           return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
         }
	 data = (char **)save_buffer->data_ptr;
	 
         _NFMdebug ((fname,"Iplot submit Failed at File Server\n Error = <%s>\n", data[FTO_CIFILENAME]));
	ERRload_struct(NFM,status1,"%s",data[FTO_CIFILENAME]);
         return (status1);
       }

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Command NFM_DEST_PLOT_FILES Failed at File Server\n\
File Server status1 = <0x%.8x>\n", status1));
	ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","FS: Plot Files Failed",status1);
         return (NFM_E_FAILURE);
       }
     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

/************************************************************************
*									*
*			NFMfs_dest_plot_clix				*
*									*
*	This procedure is the file server side function, which is       *
*	called when the file server receives the command		*
*	NFM_DEST_PLOT_FILES. The files are moved and the status is 	*
*	returned in n_status within the buffer. A fatal error will cause*
*	immediate erroring out, else the function will try to do as 	*
*	many files as possible						*
************************************************************************/

 long NFMfs_dest_plot_clix ( buffer_ptr)
   MEMptr *buffer_ptr;
   {
      char *fname="NFMfs_dest_plot_clix";
      long     status,status1,status2,status3,dst_stat_status;
      char     **data;
      long     connect_status = 0;
      long     x, y, count, count1;
      char     dec_pass [NFM_PASSWD],NFS_CO_DIR[NFM_FILENAME+1];
      char     src_file [512], dst_file [512];
      long     size, protocol,n_status,n_status1, delete_status;
      long     NFMftp_receive ();
      struct   stat  fbuff;
      int     *FILE_SOCK,FILE_SOCK_VAL;

      int      param_count, param_y;
      char     param_file[512], iparm_path[512], *dot_pos;
      char     err_file[512], err_file2[512], out_buf[128], first_buf[128];
      FILE     *err_fp;
      char     sys_command[512];


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


      strcpy(iparm_path, NFS_CO_DIR); 
      param_count = 0;
      for (x = 1; x < (*buffer_ptr) -> rows; ++x)
       {
/* Extract n_status from the second position onwards. First position is the
   "check out plot location"  */

/* Process All the rows even if error occurs in processing ???*/

         count = (*buffer_ptr) -> columns * x;
         n_status = atol(data [ count + FTO_STATUS1]);

         if(n_status == NFM_LFM_NFS_MOVE_NO_REMOVE || 
	    n_status == NFM_NFS_MOVE_NO_REMOVE  || 
	    n_status == NFM_LFM_NFS_MOVE_REMOVE )
          {
/* Close a previous connection is open */
/************
	    if((param_count == 0) && (strcmp(data[count+FTO_FILETYPE], "P")==0))
	    {
		param_count = count;
		delete_status = n_status;
		_NFMdebug((fname, "Delete Status is <%d>\n", delete_status));
	    }
************/

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
		  return(status);
		  /**continue ;**/
                }

/* Check the source location operating system . Use the appropriate method
   to establish connection and transfer files */

               if ((! strcmp (data [count + FTO_OPSYS], "CLIX")) || (! strcmp (data [count + FTO_OPSYS], "UNIX")))
                {
		   connect_status = TLI_MC_CONN_LESS;
/* SAVE THE CONNECTION FOR LATER USE JUST IN CASE NFS IS
   THE ONLY OPERATION */
                }
		
            for (y = x; y < (*buffer_ptr) -> rows; ++y)
             {
               count1 = (*buffer_ptr) -> columns * y;
               n_status1 = atol(data [ count1 + FTO_STATUS1]);

	       if((param_count == 0) && 
		  (strcmp(data[count1+FTO_FILETYPE], "P")==0))
		{
		   param_count = count1;
		   param_y = y;
		   delete_status = n_status1;
		   _NFMdebug((fname, "Delete Status is <%d>\n", delete_status));
		}

               if((n_status1 == NFM_LFM_NFS_MOVE_NO_REMOVE || 
		   n_status1 == NFM_NFS_MOVE_NO_REMOVE || 
		   n_status1 == NFM_LFM_NFS_MOVE_REMOVE) &&
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
         	      NFMswitch_disconnect (connect_status,FILE_SOCK);
		      return(status1);
		      /**continue ;**/
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
         	      NFMswitch_disconnect (connect_status,FILE_SOCK);
		      return(status1);
		      /**continue ;**/
                   }
 
                  size = 0;
/* Verify that file is not there locally */
                 dst_stat_status = stat (dst_file, &fbuff);
/* For local file manager transfers do the lfm check */
	         if(n_status1 == NFM_LFM_NFS_MOVE_NO_REMOVE || 
		    n_status1 == NFM_LFM_NFS_MOVE_REMOVE )
	 {
/* Make sure it is not "/usr/tmp" as we use this for temporary transfer */
	    if(strncmp(dst_file,"/usr/tmp", 8 ) == 0 )
	     dst_stat_status = NFM_S_SUCCESS ;
	    if (dst_stat_status == 0 ) 
    {
     ERRload_struct (NFM, NFM_E_LFM_FILE_EXISTS, "%s%s", dst_file,data[FTO_NODENAME]);
     _NFMdebug((fname,"Plot File <%s> exists locally on <%s>: status = <0x%.8x>\n",dst_file,data[FTO_NODENAME], NFM_E_LFM_FILE_EXISTS));
/* Load the error NFM_EXIST_LOCALLY for n_status and continue with next buffer */
      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,NFM_E_LFM_NFS_EXISTS_LOCALLY);
      status1= NFM_E_LFM_FILE_EXISTS ;

      if(n_status1 == NFM_LFM_NFS_MOVE_NO_REMOVE)
      {
         NFMswitch_disconnect (connect_status,FILE_SOCK);
	 return(status1);
      }

      continue ; /** OK here to continue since it exists already **/
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
for Plot file <%s>: status <0x%.8x>\n",dst_file,status));
                		NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,NFM_E_CHMOD_CO_FILENAME);
                		NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,
                                  0777);
				continue; / ** OK even if chmod fails ** /
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
				status = NFMnfs_file_remove(data[FTO_NODENAME]
,data[count1+FTO_NODENAME],data[count1+FTO_PATHNAME],data[count1+FTO_CIFILENAME],
data[count1+FTO_COFILENAME],NFS_CO_DIR,data[count1+FTO_MOUNTPOINT],0);
				if(status != NFM_S_SUCCESS)
				{
_NFMdebug((fname,"Unable to remove NFS mounted/linked file <%s/%s>\n",
data[FTO_PATHNAME],data[count1+FTO_COFILENAME]));
                                  NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS1+1,NFM_E_NFS_REMOVE_FILE);

				}
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




                  switch ( connect_status)
		  {
		    case TLI_MC_CONN_LESS :
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
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,status2);
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS3+1,status3);
		      NFMchmod(dst_file,fbuff.st_mode);
         	      NFMswitch_disconnect (connect_status,FILE_SOCK);
		      return(status1);
		      /**continue ;**/
                    }
                    connect_status = TLI_MC ;
		    case TLI_MC :
                     status = NFMfile_receive (src_file, dst_file,
                              data [count1 + FTO_FILETYPE], (int *)&size,FILE_SOCK);
                     if (status != NFM_S_SUCCESS)
                      {
                        _NFMdebug ((fname,"Rec File: status = <0x%.8x>\n",
                        status));
/* Load the error  for n_status and continue with next buffer */
		      status1 = status;
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,xfer_buf_status.status2);
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS3+1,xfer_buf_status.status3);
  /* If it is a send or receive failure then try to disconnect the second
     fileserver and break */
                      if(status == NFM_E_TLI_SEND_FS1_FS2 ||
                         status == NFM_E_TLI_RECEIVE_SIZE_FS1_FS2 ||
                         status == NFM_E_TLI_RECEIVE_FS1_FS2)
                        {
                               NFMdisconnect (FILE_SOCK);
                               break;
                        }
		      NFMchmod(dst_file,fbuff.st_mode);

		      /**continue ;**/
         	      NFMswitch_disconnect (connect_status,FILE_SOCK);
		      return(status1);
                      }
		      break;
                   }
			status = NFMchmod(dst_file,0444);
			if(status != NFM_S_SUCCESS)
			{
				_NFMdebug((fname,"Cannot change mode to 0444 \
for check out file <%s>: status <0x%.8x>\n",dst_file,status));
			}	

                  if (size < 0)
                   {
                     status1=	status = NFM_E_BAD_CO_FILE_SIZE;
		     status2 = size ;
                     _NFMdebug ((fname,"Bad File Size: status =<0x%.8x>\n",
                     status));
                     ERRload_struct (NFM, status, "%d", size);
/* Load the error  for n_status and continue with next buffer */
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS1+1,status1);
              	      NFMset_buf_stat ( *buffer_ptr,y+1,FTO_STATUS2+1,status2);
         	      NFMswitch_disconnect (connect_status,FILE_SOCK);
		      return(status1);
		      /**continue ;**/
                   }

                  n_status1 = NFM_TRANSFERED ;
                  NFMset_buf_stat(*buffer_ptr,y+1,FTO_CIFILESIZE+1,size);
                  NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS1+1,n_status1);
                }
             }
          }
/********************
	  else
	  {
		/ ** Invalid command from Server, Return Error ** /
             _NFMdebug((fname,"Invalid command <%d> for plotting:status =<0x%.8x>\n", n_status, NFM_E_FAILURE));
		return(NFM_E_FAILURE);
	  }
********************/
      }


/*****IMPORTANT **************************

	ISSUE iplot command to plot all the files that are
	transferred

******************************************/

    if(param_count != 0)	
    {
      _NFMdebug ((fname,"Start Plotting\n"));	
      strcpy(param_file, data[param_count+FTO_COFILENAME]);

      dot_pos = strchr(param_file, '.');
      if(dot_pos != NULL)
	dot_pos[0] = '\0';

      if(chdir(iparm_path)!=0)
      {
         _NFMdebug ((fname,"Cannot change dir to <%s>, errno <%d>\n",	
				iparm_path, errno));
         NFMswitch_disconnect (connect_status,FILE_SOCK);
	 status1 = NFM_E_CHDIR;
         ERRload_struct (NFM, status1, "%s%d", iparm_path, errno);
         NFMset_buf_stat ( *buffer_ptr,param_count+1,FTO_STATUS1+1,status1);
	 return(status1);
      }

	sprintf(sys_command,"/usr/bin/iplot generate %s", param_file); 
	status1 = NFMsystem2(sys_command, err_file);
	err_fp = fopen(err_file, "r");
	if(err_fp)
	{
		fgets(first_buf, 127, err_fp);
		strcpy(out_buf, first_buf);

		while(!feof(err_fp))
			fgets(out_buf, 127, err_fp);

		if(strstr(out_buf, "IPLOT-I-GENSUCCESS")!=NULL)
		{
                        _NFMdebug ((fname,"GEN Success via error file \n")); 
			status1 = NFM_S_SUCCESS;
		}
		else
			status1 = NFM_E_IPLOT_GEN;
		fclose(err_fp);
	}
	else
                _NFMdebug ((fname,"Can't open generate error file <%s>\n", 
					err_file));

	if(status1 != NFM_S_SUCCESS)
	{
		status1 = NFM_E_IPLOT_GEN;
              	NFMset_buf_stat ( *buffer_ptr,param_y+1,FTO_STATUS1+1,status1);
		status=MEMwrite_data(*buffer_ptr,first_buf,1, FTO_CIFILENAME+1);
        	if(status!=MEM_S_SUCCESS)
        	{
                	_NFMdebug ((fname,"MEMwrite_data: status = <0x%.8x>\n",
								      status));
               		ERRload_struct(NFM,NFM_E_MEM_FAILURE,"%s",
						    	      "MEMwrite_data");
                	return(NFM_E_MEM_FAILURE);
        	}

                _NFMdebug ((fname,"Iplot generate <%s> failed: <%s>\n",
				param_file, first_buf));
		fclose(err_fp);
	}
	else
	{
	   unlink(err_file); /** Remove iplot generate error file**/
	   sprintf(sys_command,"/usr/bin/iplot submit %s -qpr_options={-R}", 
								param_file);
	   status1 = NFMsystem2(sys_command, err_file2);
	   err_fp = fopen(err_file2, "r");
	   if(err_fp)
	   {
		fgets(first_buf, 127, err_fp);		
		strcpy(out_buf, first_buf);

		while(!feof(err_fp))
			fgets(out_buf, 127, err_fp);		

		if(strstr(out_buf, "IPLOT-I-SUBSUCCESS")!=NULL)
		{
                        _NFMdebug ((fname,"Success via error file \n")); 
			status1 = NFM_S_SUCCESS;
		}
		else
		{
                    _NFMdebug ((fname,"Unable to grep IPLOT-I-SUBSUCCESS in the error file <%s>\n", err_file2)); 
		    status1 = NFM_E_IPLOT_SUBMIT;
		}
		fclose(err_fp);
	   }
	   else
                _NFMdebug ((fname,"Can't open submit error file <%s>\n", 
					err_file));

	   if(status1 != NFM_S_SUCCESS)
	   {
		status1 = NFM_E_IPLOT_SUBMIT;
              	NFMset_buf_stat ( *buffer_ptr,param_y+1,FTO_STATUS1+1,status1);
		status=MEMwrite_data(*buffer_ptr,first_buf,1, FTO_CIFILENAME+1);
        	if(status!=MEM_S_SUCCESS)
        	{
                	_NFMdebug ((fname,"MEMwrite_data: status = <0x%.8x>\n",
								      status));
               		ERRload_struct(NFM,NFM_E_MEM_FAILURE,"%s",
						    	      "MEMwrite_data");
                	return(NFM_E_MEM_FAILURE);
        	}

                _NFMdebug ((fname,"Iplot submit <%s> failed <%s>\n",
				param_file, first_buf));
	   }
        }
     }
     else
     {
	status1 = NFM_E_MISSING_IPARM;
        _NFMdebug ((fname,"Param file not specified status =<0x%.8x>\n",
			status1));
        NFMset_buf_stat ( *buffer_ptr,1,FTO_STATUS1+1,status1);
     }
	
     if(status1 == NFM_S_SUCCESS)
	  unlink(err_file2);

     if(delete_status == NFM_LFM_NFS_MOVE_REMOVE)
     {
	for (x = 1; x < (*buffer_ptr) -> rows; ++x)
	{
         	count = (*buffer_ptr) -> columns * x;

		status = NFMappend_path_file (data [FTO_OPSYS],
                         		      data [FTO_PATHNAME], 
			 		      data [count + FTO_COFILENAME],
			 		      dst_file);
                if (status != NFM_S_SUCCESS)
                {
                     _NFMdebug ((fname,"Append path failed (while final delete): opsys <%s> pathname <%s>\n filename <%s> : status = <0x%.8x>\n",
			data[FTO_OPSYS],data[FTO_PATHNAME],
			data[count + FTO_COFILENAME], status));

/* Load the error NFM_MOVE_FAILURE for n_status and continue with next buffer */
                     status2 = NFM_E_APPEND_CO ;
                     NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,status2);
                     continue ; /* OK if failed to delete local file **/
                }

        	_NFMdebug ((fname,"Delete file <%s>\n", dst_file));
		unlink(dst_file);
	} 
     }

      status=NFMswitch_disconnect (connect_status,FILE_SOCK);
/* The transfer is complete
*/
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFMswitch_disconnect: status = <0x%.8x>\n",
         status));
         return (status);
       }

      
      _NFMdebug ((fname," Returning : status1 = <0x%.8x>\n", status1));
      return (status1);
   }
