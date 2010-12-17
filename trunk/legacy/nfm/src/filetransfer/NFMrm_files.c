#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

#include "NEWdef.h"
extern NFMuser_info_struct NFMuser_info;

/***********************************************************************
*                                                                       *
*                       NFMrm_co_files                                  *
*                                                                       *
*       This function removes the checkout files from the checkout      *
*       location. The first row in the buffer identifies the checkout   *
*       location. All subsequent entries with n_status set to NFM_DELETE_FILE*
*       NFM_TRANSFERED, NFM_MOVE_MOVE_WARNING, NFM_MOVE_TRANSFERED      *
*       will cause COFILENAME to be deleted from the Checkout location  *
*       All entries with n_status set to NFM_READ_ONLY will change the mode  *
*       of COFILENAME to READ ONLY                                      *
*                                                                       *
*       This function must be called after a successful check_in        *
*       n_status will be set to NFM_REMOVED                             *
************************************************************************/




 long NFMrm_co_files (buffer_ptr,NETid)
   MEMptr  *buffer_ptr;
   long NETid ;
   {
     long     status;
     char     **data;
     long     protocol;
     int sock;
     long     NFMftp_rm_co_files (),NFMfmu_rm_co_files(),NFMs_rm_co_files();
     char     *fname="NFMrm_co_files";

     _NFMdebug((fname,"Entry: MEMptr *buffer_ptr <%x>  NETid <%d>\n",*buffer_ptr,NETid));
     sock = NETid;
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


     status = MEMbuild_array (*buffer_ptr);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMbuild_array",fname,"status",status);
        _NFMdebug((fname,"MEMbuild_array failed for *buffer_ptr: status = <0x%.8x>\n", status));
        NFMdisconnect(&sock);
        return (NFM_E_MEM_BUILD_ARRAY_BUFFER);        
      }

     data   = (char **) (*buffer_ptr) -> data_ptr;
/* set the value of protocol for check out destination location  */

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



     
      status = NFM_S_SUCCESS ;
     if(!strcmp(data[FTO_OPSYS],"CLIX") || !strcmp(data[FTO_OPSYS],"UNIX"))
        status = NFMs_rm_co_files(data[FTO_NODENAME],data[FTO_USERNAME],data[FTO_PASSWD],protocol,buffer_ptr,NETid);
     else if ( !strcmp(data[FTO_OPSYS],"VMS") && (protocol == NET_XNS)) /* VAX - IGI */
	status = NFMfmu_rm_co_files (data[FTO_NODENAME],data[FTO_USERNAME],data[FTO_PASSWD],buffer_ptr);
     else
        status = NFMftp_rm_co_files (data[FTO_NODENAME],data[FTO_USERNAME],data[FTO_PASSWD],buffer_ptr) ;
     if(status != NFM_S_SUCCESS)
      {
	_NFMdebug((fname,"Remove checkout filenames : Failed. status <0x%.8x>\n",status));
      }
     else
        _NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",status));
     return(status);
}

long NFMs_rm_co_files(node_name,user_name,passwd,protocol,buffer_ptr,NETid)
	char *node_name,*user_name,*passwd;
        int protocol;
        long NETid;
        MEMptr  *buffer_ptr;
{
        char *fname="NFMs_rm_co_files";
        char dec_passwd[NFM_PASSWD];
        long status,status1, sock_no;
        MEMptr save_buffer = NULL ;
	_NFMdebug((fname,"Entry: Nodename <%s> Username <%s> Passwd <%s>\
\nProtocol <%d> MEMptr *buffer_ptr <%x>\n",node_name,user_name,passwd,protocol,*buffer_ptr));

      sock_no = NETid;
/* Decrypt the password */
      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         status = NFM_E_NET_DECRYPT_CO_LOCATION;
         _NFMdebug ((fname,"Decrypt Passwd  : status = <0x%.8x>\n",
         status));
	ERRload_struct(NFM,status,"%s%s%s%s",node_name,user_name,passwd,"");
         NFMdisconnect((int *)&sock_no);
         return (NFM_E_SEVERE_ERROR);
       }

/* connect to the check out node */
/* if NETid > 0 then connection is still open Use it */
      if(NETid <= 0 )
      {
        sock_no = -1 ;
      status = NFMconnect (node_name, user_name,dec_passwd,
               NFM_TCP_PORT, NFM_XNS_PORT, (int *)&sock_no, protocol);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFMconnect Failed: status = <0x%.8x>\n",
         status));
	 status = NFM_E_TLI_CONNECT_FS1 ;
         ERRload_struct(NFM,status,"%d%d%s%s",net_buf_status.status2,net_buf_status.status3,node_name,user_name);
         return (NFM_E_SEVERE_ERROR);
       }
     }

      status = NFMcl_send_buffer (&sock_no, NFM_RM_CO_FILES, *buffer_ptr);
      if (status != NFM_S_SUCCESS)
       {

         NFMcl_fs_exit (&sock_no);
         _NFMdebug ((fname,"NFMcl_send_buffer failed for NFM_RM_CO_FILES: status = <0x%.8x>\n",
         status));
         status = NFM_E_SEND_COMMAND_S_TO_FS ;
         ERRload_struct(NFM,status,"%s%s%s","NFM_RM_CO_FILES",node_name,user_name);
         return (NFM_E_SEVERE_ERROR);
       }      

      status1 = NFM_S_SUCCESS;

      save_buffer = NULL ;
      status = NFMcl_receive_buffer (&sock_no, &status1, &save_buffer);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         NFMcl_fs_exit (&sock_no);
         _NFMdebug ((fname,"NFMcl_receive_buffer Failed for NFM_RM_CO_FILES: status = <0x%.8x>\n",
         status));
         status = NFM_E_RECEIVE_RESPONSE_FS_TO_S ;
         ERRload_struct(NFM,status,"%s%s%s","NFM_RM_CO_FILES", node_name,user_name);

         return (NFM_E_SEVERE_ERROR);
	
       }      
      MEMclose(buffer_ptr);
      *buffer_ptr = save_buffer ;
 
/* Receive the error buffer */
      status = NFMcl_fs_exit (&sock_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"CL FS  Exit Failed : status = <0x%.8x>\n",
         status));
        status = NFM_E_EXIT_S_TO_FS;
         ERRload_struct(NFM,status,"%s%s%s","NFM_RM_CO_FILES",
node_name,user_name);
         return (status);
       }

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFM_RM_CO_FILES Failed at server side: status1 = <0x%.8x>\n",
         status1));
	ERRload_struct(NFM,NFM_E_FAILURE,"%s %x","NFM_RM_CO_FILES Failed at server", status1);
         return (status1);
       }
     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMfs_rm_co_files (buffer_ptr)
   MEMptr    *buffer_ptr;
   {
      char *fname="NFMfs_rm_co_files ";
      long     n_status,status, status1, status2, status3, status4;
      long     x, count;
      int NETid = -1;
      long umount_flag;
      char     **data;
      char     src_file [512], file_name [512],NFS_CO_DIR[NFM_FILENAME+1];


      _NFMdebug ((fname,"Entry:MEMptr *buffer_ptr <%x>\n",*buffer_ptr));
	
	umount_flag = 0;

      status = MEMbuild_array (*buffer_ptr);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         status = NFM_E_MEM_FAILURE;
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }


      data    = (char **) (*buffer_ptr) -> data_ptr;
      if(strlen(data[FTO_PATHNAME]) > 0)
	strncpy(NFS_CO_DIR,data[FTO_PATHNAME],NFM_FILENAME);
      else
	strncpy(NFS_CO_DIR,NFMuser_info.dir,NFM_FILENAME);
      NFS_CO_DIR[NFM_FILENAME]='\0';

      status1 = atol(data[FTO_STATUS1]);
      if(status1 == NFM_FTR_MT_PT_REMOVE) umount_flag = 1;

      status1 = NFM_S_SUCCESS;    status2 = NFM_S_SUCCESS;
      status3 = NFM_S_SUCCESS;    status4 = NFM_S_SUCCESS;

      for (x = 1; x < (*buffer_ptr) -> rows; ++x)
       {
         count = (*buffer_ptr) -> columns * x;
         n_status = atol(data[count+FTO_STATUS1]);

         if(n_status == NFM_DELETE_FILE || n_status == NFM_TRANSFERED  || 
		n_status == NFM_READ_ONLY || n_status == NFM_NFSED  ||
/* Handle removing of files in temporary location */
/* Files in /usr/tmp created for non clix check out nodes must be deleted
   after operation is complete */
		n_status == NFM_MOVE_TRANSFERED || n_status == NFM_MOVE_MOVE_WARNING)
          {
            status = NFMappend_path_file (data[FTO_OPSYS],
                     data [FTO_PATHNAME], data [count + FTO_COFILENAME], src_file);
            if (status != NFM_S_SUCCESS)
             {
               _NFMdebug ((fname,"Append Path : status = <0x%.8x>\n", status));
               ERRload_struct(NFM,status,"%s%x","NFMappend_file_path",status);
               n_status = NFM_E_APPEND_CO ;
               status = NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
               status4 = n_status;
	       continue;
             }
            status = NFMget_full_name (src_file, file_name);
            if (status != NFM_S_SUCCESS)
             {
               _NFMdebug ((fname,"NFMget_full_name : src_file <%s> status = <0x%.8x>\n",src_file, status2));
               n_status = NFM_E_NO_CO_FILENAME ;
               status = NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
               status4 = n_status ;
	       continue;
             }

	     switch(n_status)
	       {
		  	case NFM_READ_ONLY:
/* READ ONLY FOR EVERYONE IS 00444 */
				status = chmod(file_name,00444);
				n_status = NFM_READ_DONE;
				break;
			case NFM_NFSED:
/* Undo the NFS activity ( rm link / rm mount point if necessary
   update s99nfm file */
				status = 0;
				status = NFMnfs_file_remove(data[FTO_NODENAME],
data[count+FTO_NODENAME],data[count+FTO_PATHNAME],data[count+FTO_CIFILENAME],
data[count+FTO_COFILENAME],NFS_CO_DIR,data[count+FTO_MOUNTPOINT],umount_flag);
				if(status == NFM_S_SUCCESS) status = 0;
				else status = -1;
				n_status = NFM_NFS_UNDONE;
				break;
			default:
                 		status = unlink (file_name);
                                n_status = NFM_REMOVED ;
		}

            if (status) /* OK */
             {
               status4 = NFM_E_UNLINK_FILE;
               n_status = NFM_E_UNLINK_CO_FILENAME ;
               _NFMdebug ((fname,"Unlink File filename <%s> Error No : status = <%d>\n",file_name, errno));
               ERRload_struct (NFM, status, "%s%d", file_name,errno);
               status = NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,errno);
             }
            status = NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
          }
       }



      if (status4 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Previous Failure: status4 = <0x%.8x>\n", status4));
         return(status4);
       }

      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n",NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMftp_rm_co_files (node_name, user_name, passwd, 
                              buffer_ptr)
   char    *node_name, *user_name, *passwd;
   MEMptr  *buffer_ptr;
   {
      long     n_status,n_status1,status,status1;
      long     x,  count;
      char     **data;
      char     src_file[512],dec_pass [50];
      char *fname="NFMftp_rm_co_files" ;

      
      _NFMdebug((fname,"Entry: Nodename <%s> username <%s> passwd <%s>\n\
MEMptr: *buffer_ptr <%x>\n",node_name,user_name,passwd,*buffer_ptr));

      n_status1 = NFM_REMOVED;
      status1 = NFM_S_SUCCESS ;
      status = MEMbuild_array (*buffer_ptr);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         status = NFM_E_MEM_FAILURE;
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }


      data    = (char **) (*buffer_ptr) -> data_ptr;


      status = NFMdecrypt (passwd, dec_pass);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug((fname,"Password decryption failed. status = <0x%.8x>\n",status));
         ERRload_struct(NFM,NFM_E_NET_DECRYPT_CO_LOCATION,"%s%s%s",node_name,user_name,passwd);
         return (NFM_E_NET_DECRYPT_CO_LOCATION);  
       }

   
      for (x = 1; x < (*buffer_ptr) -> rows; ++x)
       {
         count = (*buffer_ptr) -> columns * x;
         n_status = atol (data[count+FTO_STATUS1]);
         n_status1 = NFM_REMOVED;

         if(n_status == NFM_DELETE_FILE || n_status == NFM_TRANSFERED ||
/* FTP site cannot be NFM_NFSED at this time 09/23/91 
   A NFM_READ_ONLY will be ignored and no action will be taken */
		n_status == NFM_MOVE_TRANSFERED || n_status == NFM_MOVE_MOVE_WARNING)
          {
            status = NFMappend_path_file (data [FTO_OPSYS],
                     data [FTO_PATHNAME], data [count + FTO_COFILENAME], src_file);
            if (status != NFM_S_SUCCESS)
             {
               _NFMdebug((fname,"Append Path : status = <0x%.8x>\n", status));
	       ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMappend_path_file",status);
	       NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_APPEND_CO);
	       status1 = status ;
	       continue;
             }

	       status = NFMftp_delete(node_name,user_name,dec_pass,src_file, data[FTO_MACHID]); /* VAX - IGI */
	       if(status!=NFM_S_SUCCESS) status1 = status ;
	       switch(status)
	       {
			case NFM_S_SUCCESS:
				n_status1 = NFM_REMOVED ;
				break;
			case NFM_E_FTP_FOPEN_WRITE_F_SCRIPT:
			case NFM_E_FTP_FWRITE_F_SCRIPT:
	       NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,xfer_buf_status.status2);
	       NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,xfer_buf_status.status3);
			default:
	     			n_status1 = NFM_E_FTP_DELETE_CO_FILENAME; 
	       }
	       NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status1);
	       continue;

          }
	 else
		if(n_status == NFM_NFSED )
		{
			NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_NON_NFS_SITE);
			status1 = NFM_E_NON_NFS_SITE ;
		}
	
       }

      
      _NFMdebug((fname," SUCCESSFUL : status = <0x%.8x>\n", status1));
      return (status1);      
   }

 long NFMfmu_rm_co_files (node_name, user_name, passwd, 
                              buffer_ptr)
   char    *node_name, *user_name, *passwd;
   MEMptr   *buffer_ptr;
   {
      long     n_status,status,status1;
      long     x,  count;
      char     **column, **data;
      char     str [1024], src_file [512], dec_pass [50];
      long     pos;
      char *fname="NFMfmu_rm_co_files";

      _NFMdebug((fname,"Entry Username <%s> Nodename <%s> passwd <%s>\n\
MEMptr : *buffer_ptr <%x>\n", node_name,user_name,passwd,*buffer_ptr));

      status = MEMbuild_array (*buffer_ptr);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         status = NFM_E_MEM_FAILURE;
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }

      column  = (char **) (*buffer_ptr) -> column_ptr;
      data    = (char **) (*buffer_ptr) -> data_ptr;

      status = NFMdecrypt (passwd, dec_pass);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug((fname,"Password decryption failed. status = <0x%.8x>\n",status));
         ERRload_struct(NFM,NFM_E_NET_DECRYPT_CO_LOCATION,"%s%s%s",node_name,user_name,passwd);
         return (NFM_E_NET_DECRYPT_CO_LOCATION);  
       }

      status = NETfmu_connect(node_name,user_name,dec_pass);
      if(status != NET_S_SUCCESS)
	{
		 _NFMdebug((fname,"fmu_connect failed to nodename <%s> username <%s> password <%s>\n",node_name,user_name,dec_pass));
		 status = NFM_E_FMU_CONNECT_NONCLIX;
		 ERRload_struct(NFM,status,"%s%s%s",node_name,user_name,passwd);
		 return(status);
	}
   
      status1 = NFM_S_SUCCESS ;
      for (x = 1; x < (*buffer_ptr) -> rows; ++x)
       {
         count = (*buffer_ptr) -> columns * x;
         n_status = atol (data[count+FTO_STATUS1]);

         if(n_status == NFM_DELETE_FILE || n_status == NFM_TRANSFERED  || 
		 n_status == NFM_READ_ONLY ||
		n_status == NFM_MOVE_TRANSFERED || n_status == NFM_MOVE_MOVE_WARNING)
/* NFM_NFSED not possible for FMU m/c */
          {
               status = NFMappend_path_file (data [FTO_OPSYS],
                        data [FTO_PATHNAME], data [count + FTO_COFILENAME], src_file);
               if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname," Append Path : status = <0x%.8x>\n",
                  status));
                   ERRload_struct (NFM, NFM_E_FAILURE, "%s%x", "NFMappend_path_file",status);
		  status1 = status;
		  NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_APPEND_CO);
		  continue;
                }
	       
	       NFMconvert_to_vax_file(src_file);
	       if(n_status == NFM_READ_ONLY)
		sprintf(str,"SET PROTECTION=(SYSTEM:R,OWNER:R,GROUP:R,WORLD:R) %s",src_file);
               else
		sprintf(str,"SET PROTECTION=(SYSTEM:RWD,OWNER:RWD,GROUP:RWD,WORLD:RWD) %s",src_file);
	       status = NFMfmu_rcmd(str,"");
	       if(status!=NFM_S_SUCCESS && status != NFM_I_NO_OUTPUT )
		{
                  _NFMdebug ((fname," fmu_rcmd failed for command <%s>: status = <0x%.8x>\n",str, status));
                   ERRload_struct (NFM, NFM_E_FAILURE, "%s%x", "NFMfmu_rcmd",status);
		  status1 = status;
		  if (n_status == NFM_READ_ONLY) n_status = NFM_E_FMU_SET_READ_ONLY;
		  else n_status = NFM_E_FMU_DELETE_CO_FILENAME;
		  NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
		  continue;
		}
	       if(n_status != NFM_READ_ONLY)
	       {
                	sprintf (str, "delete %s", src_file);
	       		status = NFMfmu_rcmd(str,"");
	       		if(status!=NFM_S_SUCCESS && status != NFM_I_NO_OUTPUT )
			{
                  		_NFMdebug ((fname," fmu_rcmd failed for command <%s>: status = <0x%.8x>\n",str, status));
                   		ERRload_struct (NFM, NFM_E_FAILURE, "%s%x", "NFMfmu_rcmd",status);
		  		status1 = status;
		  		n_status = NFM_E_FMU_DELETE_CO_FILENAME;
		  		NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
		  		continue;
			}
                }
		if(n_status == NFM_READ_ONLY) n_status = NFM_READ_DONE;
                else  n_status = NFM_REMOVED ;
                status = NFMset_buf_stat (*buffer_ptr, x + 1, FTO_STATUS1 + 1,n_status);
                if (status != NFM_S_SUCCESS)
                 {
                   status = ERRload_struct (NFM, NFM_E_FAILURE, "%s%x", "NFMset_buf_stat",status);
                   _NFMdebug ((fname," NFMset_buf_stat : status = <0x%.8x>\n",
                   status));
                 }
          }
       }

      status=NETfmu_disconnect();
      if(status != NET_S_SUCCESS )
      {
          _NFMdebug ((fname," fmu_disconnect failed  status = <0x%.8x>\n", status));
            return(status);
      }

      
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", status1));
      return (status1);      
   }



/*
==============================================================================
*/



 long NFMrm_ci_files (buffer_ptr)
   MEMptr  *buffer_ptr;
   {
     long     status,n_status,n_status1,status1,status2,count,count1;
     char     **column, **data ;
     long     x, y, protocol;
     long     NFMftp_rm_ci_files (),NFMfmu_rm_ci_files(),NFMs_rm_ci_files();
     char     *fname="NFMrm_ci_files";

     _NFMdebug((fname,"Entry: MEMptr *buffer_ptr <%x>\n",*buffer_ptr));
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


     status = MEMbuild_array (*buffer_ptr);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMbuild_array",fname,"status",status);
        _NFMdebug((fname,"MEMbuild_array failed for *buffer_ptr: status = <0x%.8x>\n", status));
        return (NFM_E_MEM_BUILD_ARRAY_BUFFER);        
      }

     column = (char **) (*buffer_ptr) -> column_ptr;
     data   = (char **) (*buffer_ptr) -> data_ptr;
     status1 = NFM_S_SUCCESS ;
/* Start a loop and do the files a row at a time */
    for(x=0; x < (*buffer_ptr)->rows; x++)
    {
         count = (*buffer_ptr) -> columns * x;
         n_status = atol(data[count+FTO_STATUS1]);
	 _NFMdebug((fname,"row no <%d> n_status <%d>\n",x,n_status));

         if(n_status == NFM_DELETE_FILE || n_status == NFM_TRANSFERED ||
            n_status == NFM_MOVE_MOVE_WARNING || n_status == NFM_MOVE_TRANSFERED  ||
            n_status == NFM_PURGE_FILE )
         {

            if(!strcmp(data[count+FTO_TCPIP],"Y") && 
               !strcmp(filexfer_loc_sa.LOCAL_SA[FTO_TCPIP],"Y")) protocol = NET_TCP; 
            else if(!strcmp(data[count+FTO_XNS],"Y") &&
               !strcmp(filexfer_loc_sa.LOCAL_SA[FTO_XNS],"Y")) protocol = NET_XNS; 
            else protocol = NULL ;

            status = NFM_S_SUCCESS ;
            if(!strcmp(data[count+FTO_OPSYS],"CLIX") || !strcmp(data[count+FTO_OPSYS],"UNIX"))
            {
/* USE N_STATUS2 to INDICATE WHICH SANO */
	       status = MEMwrite_data(*buffer_ptr,data[count+FTO_SANO],x+1,FTO_STATUS2+1);
	       if(status != MEM_S_SUCCESS)
                {
                  ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%d", "MEMwrite_data",fname,"SANO IN BUFFER AT ROW",x+1);
                  _NFMdebug((fname,"MEMwrite_data failed for *buffer_ptr: row <%d>: status = <0x%.8x>\n",x+1, status));
		  NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_SET_SANO_IN_STATUS2);
		  continue;
                 }
               status = NFMs_rm_ci_files(data[count+FTO_NODENAME],
data[count+FTO_USERNAME],data[count+FTO_PASSWD],protocol,buffer_ptr);
               status2 = MEMbuild_array (*buffer_ptr);
               if (status2 != MEM_S_SUCCESS)
                {
                  MEMclose (buffer_ptr);
                  ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMbuild_array",fname,"status",status2);
                  _NFMdebug((fname,"MEMbuild_array failed for *buffer_ptr: status = <0x%.8x>\n", status2));
                  return (NFM_E_MEM_BUILD_ARRAY_BUFFER);        
                 }

              column = (char **) (*buffer_ptr) -> column_ptr;
              data   = (char **) (*buffer_ptr) -> data_ptr;
	      _NFMdebug((fname,"FTO_STATUS1 = <%s>\n",data[count+FTO_STATUS1]));
            }
            else if ( !strcmp(data[count+FTO_OPSYS],"VMS") && (protocol == NET_XNS)) /* VAX - IGI */
        	status = NFMfmu_rm_ci_files (data[count+FTO_NODENAME],
data[count+FTO_USERNAME],data[count+FTO_PASSWD],data[count+FTO_SANO],buffer_ptr);
            else
                status = NFMftp_rm_ci_files (data[count+FTO_NODENAME],
data[count+FTO_USERNAME],data[count+FTO_PASSWD],data[count+FTO_SANO],buffer_ptr) ;

            if(status != NFM_S_SUCCESS)
            {
                status1 = status ;
           	_NFMdebug((fname,"Remove checkin filenames  failed. nodename <%s> status <0x%.8x>\n",data[count+FTO_NODENAME],status));
	        for(y=0;y < (*buffer_ptr)->rows;y++)
		{
                     count1 = (*buffer_ptr)->columns * y ;
                     n_status1 = atol(data[count1+FTO_STATUS1]);
	             if(!strcmp(data[count+FTO_NODENAME],data[count1+FTO_NODENAME]))
		     {
                      if(n_status1 == NFM_DELETE_FILE || n_status1 == NFM_TRANSFERED ||
                      n_status1 == NFM_MOVE_MOVE_WARNING || NFM_MOVE_TRANSFERED  ||
                      n_status1 == NFM_PURGE_FILE )
                        {
			   switch (status)
			   {
				case NFM_E_NET_DECRYPT_CI_LOCATION:
				   n_status1 = status;
                                case NFM_E_CONNECT_CI_LOCATION:
                                        n_status1 = status ;
NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS2+1,net_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS3+1,net_buf_status.status3);
                                        break;
                                case NFM_E_FWRITE_FTP_SCRIPT_DELETE_:
                                        n_status1 = status ;
                                        break;
                                case NFM_E_FOPEN_WRITE_FTP_SCRIPT_DE:
                                        n_status1 = status ;
                                        break;
                                case NFM_E_UNAME_CI_LOCATION:
                                        n_status1 = status ;
                                        break;
                                case NFM_E_FTP_DELETE_CI_FILENAME:
                                        n_status1 = status ;
                                        break;


				default:
                                   n_status1 = NFM_E_REMOVE_CI_FILENAME ;
			   }
                           NFMset_buf_stat (*buffer_ptr,  y + 1, FTO_STATUS1 + 1,n_status1);
		        }
                     }
		}
            }
            else
               _NFMdebug((fname,"SUCCESSFUL:nodename <%s> status <0x%.8x>\n",data[count+FTO_NODENAME],status));
        }
     } 

    _NFMdebug((fname,"Returning: status <0x%.8x>\n",status1));
     return(status1);
}


long NFMs_rm_ci_files(node_name,user_name,passwd,protocol,buffer_ptr)
	char *node_name,*user_name,*passwd;
        int protocol;
        MEMptr  *buffer_ptr;
{
        char *fname="NFMs_rm_ci_files";
        char dec_passwd[NFM_PASSWD];
        long status,status1,sock_no;
        MEMptr save_buffer ;
	_NFMdebug((fname,"Entry: Nodename <%s> Username <%s> Passwd <%s>\
\nProtocol <%d> MEMptr *buffer_ptr <%x>\n",node_name,user_name,passwd,protocol,*buffer_ptr));

      sock_no = -1 ;
/* decrypt the password */
      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         status = NFM_E_NET_DECRYPT_CI_LOCATION;
         _NFMdebug ((fname,"Decrypt Passwd  : status = <0x%.8x>\n",
         status));
	ERRload_struct(NFM,status,"%s%s%s%s",node_name,user_name,passwd,"");
         return (status);
       }

      status = NFMconnect (node_name, user_name,dec_passwd,
               NFM_TCP_PORT, NFM_XNS_PORT, (int *)&sock_no, protocol);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFMconnect Failed: status = <0x%.8x>\n",
         status));
         return (NFM_E_CONNECT_CI_LOCATION);
       }

      status = NFMcl_send_buffer (&sock_no, NFM_RM_CI_FILES, *buffer_ptr);
      if (status != NFM_S_SUCCESS)
       {
         NFMcl_fs_exit (&sock_no);
         status = NFM_E_SEND_COMMAND_S_TO_FS ;
         ERRload_struct(NFM,status,"%s%s%s","NFM_RM_CI_FILES",
node_name,user_name);

         _NFMdebug ((fname,"NFMcl_send_buffer failed for NFM_RM_CI_FILES: status = <0x%.8x>\n",
         status));
         return (NFM_E_SEVERE_ERROR);
       }      

      status1 = NFM_S_SUCCESS;

      save_buffer = NULL ;
      status = NFMcl_receive_buffer (&sock_no, &status1, &save_buffer);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         status = NFM_E_RECEIVE_RESPONSE_FS_TO_S ;
         ERRload_struct(NFM,status,"%s%s%s","NFM_RM_CI_FILES",
node_name,user_name);

         NFMcl_fs_exit (&sock_no);
         _NFMdebug ((fname,"NFMcl_receive_buffer Failed for NFM_RM_CI_FILES: status = <0x%.8x>\n",
         status));
         return (NFM_E_SEVERE_ERROR);

       }      
 
      MEMclose(buffer_ptr);
      *buffer_ptr = save_buffer ;
/* Receive the error buffer */
      status = NFMcl_fs_exit (&sock_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"CL FS  Exit Failed : status = <0x%.8x>\n",
         status));
         return (status);
       }

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFM_RM_CI_FILES Failed at server side: status1 = <0x%.8x>\n",
         status1));
	ERRload_struct(NFM,NFM_E_FAILURE,"%s %x","NFM_RM_CI_FILES Failed at server", status1);
         return (status1);

       }
     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMfs_rm_ci_files (buffer_ptr)
   MEMptr    *buffer_ptr;
   {
      char *fname="NFMfs_rm_ci_files ";
      long     n_status,status,  status4;
      long     x, count,status5,status6;
      char     **column, **data;
      char     dst_file[512],src_file [512], file_name [512];
      char     sano[INTEGER+1];

      long     size,found;

      _NFMdebug ((fname,"Entry:MEMptr *buffer_ptr <%x>\n",*buffer_ptr));
      strcpy(sano,"-1");
      found = 0 ;


      status = MEMbuild_array (*buffer_ptr);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         status = NFM_E_MEM_FAILURE;
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }


      column  = (char **) (*buffer_ptr) -> column_ptr;
      data    = (char **) (*buffer_ptr) -> data_ptr;


      status4 = NFM_S_SUCCESS;

      for (x = 0; x < (*buffer_ptr) -> rows; ++x)
       {
         count = (*buffer_ptr) -> columns * x;
	 if(!found)
	 {
		if ( !strcmp(data[count+FTO_SANO],data[count+FTO_STATUS2]))
		{
			found = 1;
			strcpy(sano,data[count+FTO_SANO]);
	       		status = MEMwrite_data(*buffer_ptr,"",x+1,FTO_STATUS2+1);
	       		if(status != MEM_S_SUCCESS)
                	{
                  		ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%d", "MEMwrite_data",fname,"SANO IN BUFFER AT ROW",x+1);
                  		_NFMdebug((fname,"MEMwrite_data failed for *buffer_ptr: row <%d>: status = <0x%.8x>\n",x+1, status));
		  		NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_SET_SANO_IN_STATUS2);
		  		continue;
                 	}
		}
		else continue;
	 }
         n_status = atol(data[count+FTO_STATUS1]);
         status5 = NFM_S_SUCCESS ;
         status6 = NET_S_SUCCESS ;
	 _NFMdebug((fname,"row no <%d> n_status <%d> sano <%s> row_sano <%s>\n",x,n_status,sano,data[count+FTO_SANO]));

         if(n_status == NFM_DELETE_FILE || n_status == NFM_TRANSFERED ||
            n_status == NFM_MOVE_MOVE_WARNING || n_status == NFM_MOVE_TRANSFERED  ||
            n_status == NFM_PURGE_FILE )
          {
            if(!strcmp(sano,data[count+FTO_SANO]))
            {
            status = NFMappend_path_file (data[count+FTO_OPSYS],
                     data [count+FTO_PATHNAME], data [count + FTO_CIFILENAME], file_name);
	    if(status != NFM_S_SUCCESS)
	    {
               _NFMdebug ((fname,"Append Path : status = <0x%.8x>\n", status));
               ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMappend_file_path",status);
               n_status = NFM_E_APPEND_CI ;
               status = NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
               status4 = n_status;
               continue;

	    }
            status = NFMget_full_name (file_name,src_file);
	    if(status != NFM_S_SUCCESS)
	    {
               _NFMdebug ((fname,"NFMget_full_name : src_file <%s> status = <0x%.8x>\n",src_file, status));
               n_status = NFM_E_NO_CI_FILENAME ;
               status = NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
               status4 = n_status ;
               continue;

	    }

            if(n_status != NFM_MOVE_TRANSFERED)
            {
		status = unlink (src_file);
		if(status)
		{
                   status4 = n_status = NFM_E_UNLINK_CI_FILENAME ;
                   _NFMdebug ((fname,"Unlink File filename <%s> Error No : status = <%d>\n",src_file, errno));
                    ERRload_struct (NFM, NFM_E_FAILURE, "%s%d", src_file,errno);
                   NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,errno);
                   NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
                   continue;
		}
	    }
	    else if ( n_status == NFM_MOVE_TRANSFERED )
	    {
               status = NFMappend_path_file (data[count+FTO_OPSYS],
                     data [count+FTO_PATHNAME], data [count + FTO_FILEOLD], dst_file);
               if(status != NFM_S_SUCCESS)
		{
                  _NFMdebug ((fname,"Append Path : status = <0x%.8x>\n", status));
                  ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMappend_file_path",status);
                  n_status = NFM_E_APPEND_FILEOLD ;
                  status = NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
                  status4 = n_status;
                  continue;

		}
		status = NFMcopy_file(dst_file,src_file,"",&size,1);
	        if(status != NFM_S_SUCCESS)
		{
			switch(status)
			{
                        case NFM_E_NO_FILENAME_SRC:
                        n_status = NFM_E_NO_FILEOLD;
                        break;
                        case NFM_E_NO_FILENAME_DST:
                        n_status = NFM_E_NO_CI_FILENAME;
                        break;
                        case NFM_E_UNLINK:
                        n_status = NFM_E_UNLINK_FILEOLD;
                        break;
                        case NFM_E_FOPEN_SRC:
                        n_status = NFM_E_FOPEN_READ_FILEOLD;
                        break;
                        case NFM_E_FOPEN_DST:
                        n_status = NFM_E_FOPEN_WRITE_CI_FILENAME;
                        break;
                        case NFM_E_FWRITE:
                        n_status = NFM_E_FWRITE_CI_FILENAME;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,sys_buf_status.status3);
                        break;
                        case NFM_E_FCLOSE_SRC:
                        n_status = NFM_E_FCLOSE_FILEOLD;
                        break;
                        case NFM_E_FCLOSE_DST:
                        n_status = NFM_E_FCLOSE_CI_FILENAME;
                        break;
                        case NFM_E_STAT_SRC:
                        n_status = NFM_E_STAT_FILEOLD;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
                        break;
                        case NFM_E_STAT_DST:
                        n_status = NFM_E_STAT_CI_FILENAME;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
                        break;
                        case NFM_E_UTIME:
                        n_status = NFM_E_SET_UTIME_CI_FILENAME;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,sys_buf_status.status3);
                        break;
                        case NFM_E_CHMOD:
                        n_status = NFM_E_SET_CHMOD_CI_FILENAME;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,sys_buf_status.status3);
                        break;
                        case NFM_E_CHOWN:
                        n_status = NFM_E_SET_CHOWN_CI_FILENAME;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,sys_buf_status.status3);
                        break;
                        case NFM_E_FILESIZE_MISMATCH:
                        n_status = NFM_E_BAD_SIZE_CI_FILENAME;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,sys_buf_status.status3);
                        break;
                        default:
                        n_status = NFM_E_UNLINK_CI_FILENAME ;

			}
                 NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,n_status);
		 continue;
		}
	
	    }
	     switch(n_status)
	     {
		case NFM_PURGE_FILE:
			n_status = NFM_PURGED;
			break;
		case NFM_MOVE_TRANSFERED:
			n_status = NFM_MOVE_MOVE_UNDONE ;
			break;
                case NFM_DELETE_FILE:
			n_status = NFM_REMOVED ;
			break;
		default:
			n_status = NFM_UNDONE;
	     }		
            status = NFMset_buf_stat (*buffer_ptr,  x + 1, FTO_STATUS1 + 1,n_status);
           }
          }
       }



      if (status4 != NFM_S_SUCCESS)
       {
         status = NFM_E_FAILURE ;
         _NFMdebug ((fname,"Previous Failure: status4 = <0x%.8x>\n", status4));
         return(status);
       }

      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n",NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMftp_rm_ci_files (node_name, user_name, passwd,sano ,
                              buffer_ptr)
   char    *node_name, *user_name, *passwd,*sano;
   MEMptr  *buffer_ptr;
   {
      long     n_status,n_status1,status,status1;
      long     x,  count;
      char      **data;
      char     src_file[512],file_old[512], dec_pass [50];
      char *fname="NFMftp_rm_ci_files" ;

      
      _NFMdebug((fname,"Entry: Nodename <%s> username <%s> passwd <%s>\n\
sano <%s> MEMptr: *buffer_ptr <%x>\n",node_name,user_name,passwd,sano,*buffer_ptr));

      status1 = NFM_S_SUCCESS ;
      status = MEMbuild_array (*buffer_ptr);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         status = NFM_E_MEM_FAILURE;
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }


      data    = (char **) (*buffer_ptr) -> data_ptr;


      status = NFMdecrypt (passwd, dec_pass);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug((fname,"Password decryption failed. status = <0x%.8x>\n",status));
         ERRload_struct(NFM,NFM_E_NET_DECRYPT,"%s","Password");
         return (NFM_E_NET_DECRYPT_CI_LOCATION);  
       }


   
      for (x = 0; x < (*buffer_ptr) -> rows; ++x)
       {
         count = (*buffer_ptr) -> columns * x;
         n_status =  n_status1 = atol (data[count+FTO_STATUS1]);

         if(n_status == NFM_DELETE_FILE || n_status == NFM_TRANSFERED ||
            n_status == NFM_MOVE_MOVE_WARNING || n_status == NFM_MOVE_TRANSFERED  ||
            n_status == NFM_PURGE_FILE )
          {
            if(!strcmp(data[count+FTO_SANO],sano))
            {
            status = NFMappend_path_file (data [count+FTO_OPSYS],
                     data [count+ FTO_PATHNAME], data [count + FTO_CIFILENAME], src_file);
            if (status != NFM_S_SUCCESS)
             {
               ERRload_struct(NFM,NFM_E_FAILURE,"NFMappend_path",status);
               _NFMdebug((fname,"Append Path : status = <0x%.8x>\n", status));
               status1 = status;
	       NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_APPEND_CI);
	       continue;
             }
             switch(n_status)
             {
                case NFM_PURGE_FILE:
                        n_status1 = NFM_PURGED;
                        break;
                case NFM_MOVE_TRANSFERED:
                 status = NFMappend_path_file (data [count+FTO_OPSYS],
                     data [count+ FTO_PATHNAME], data [count + FTO_FILEOLD], file_old);
                 if (status != NFM_S_SUCCESS)
                 {
                   ERRload_struct(NFM,NFM_E_FAILURE,"NFMappend_path",status);
                   _NFMdebug((fname,"Append Path : status = <0x%.8x>\n", status));
                   status1 = status;
	           NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_APPEND_FILEOLD);
	           continue;
                 }
/* DO THE RENAME PART HERE */
		   status = NFMftp_rename(node_name,user_name,dec_pass,file_old,src_file, data[count+FTO_MACHID]); /* VAX - IGI */
		   if(status != NFM_S_SUCCESS)
		   {
			status1 = status;
             		n_status1 = NFM_E_FTP_DELETE_CI_FILENAME;
		   }
                   else n_status1 = NFM_MOVE_MOVE_UNDONE ;
                   NFMset_buf_stat (*buffer_ptr,  x + 1, FTO_STATUS1 + 1,n_status1);
			continue;
/* NOT REQD DUE TO CONTINUE
                        break;
*/
                default:
                        n_status1= NFM_UNDONE;
             }
	     status = NFMftp_delete(node_name,user_name,dec_pass,src_file, data[count + FTO_MACHID]); /* VAX - IGI */
	     if(status != NFM_S_SUCCESS) status1 = status;
	     switch(status)
		{
			case NFM_S_SUCCESS:
			break;
			default:
             		n_status1 = NFM_E_FTP_DELETE_CI_FILENAME;
	
		}
             NFMset_buf_stat (*buffer_ptr,  x + 1, FTO_STATUS1 + 1,n_status1);
          }
        }
       }

      
      _NFMdebug((fname," SUCCESSFUL : status = <0x%.8x>\n", status1));
      return (status1);      
   }

 long NFMfmu_rm_ci_files (node_name, user_name, passwd,sano ,
                              buffer_ptr)
   char    *node_name, *user_name, *passwd,*sano;
   MEMptr   *buffer_ptr;
   {
      long     n_status,status,status1;
      long     x,  count;
      char     **column, **data;
      char     str [1024], src_file [512],file_old[512], dec_pass [50];
      long     pos;
      char *fname="NFMfmu_rm_ci_files";

      _NFMdebug((fname,"Entry Username <%s> Nodename <%s> passwd <%s>\n\
sano <%s> MEMptr : *buffer_ptr <%x>\n", node_name,user_name,passwd,sano,*buffer_ptr));

      status1 = NFM_S_SUCCESS ;

      status = MEMbuild_array (*buffer_ptr);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         status = NFM_E_MEM_FAILURE;
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
       }

      column  = (char **) (*buffer_ptr) -> column_ptr;
      data    = (char **) (*buffer_ptr) -> data_ptr;

      status = NFMdecrypt (passwd, dec_pass);
      if (status != NFM_S_SUCCESS)
       {
         ERRload_struct(NFM,NFM_E_NET_DECRYPT,"%s","Password");
         _NFMdebug ((fname," Dec Passwd : status = <0x%.8x>\n", status));
         return (NFM_E_NET_DECRYPT_CI_LOCATION);  
       }

      status = NETfmu_connect(node_name,user_name,dec_pass);
      if(status != NET_S_SUCCESS)
	{
		 _NFMdebug((fname,"fmu_connect failed to nodename <%s> username <%s> password <%s>\n",node_name,user_name,dec_pass));
		 return(status);
	}
   
      for (x = 0; x < (*buffer_ptr) -> rows; ++x)
       {
         count = (*buffer_ptr) -> columns * x;
         n_status = atol (data[count+FTO_STATUS1]);

         if(n_status == NFM_DELETE_FILE || n_status == NFM_TRANSFERED ||
          n_status == NFM_MOVE_MOVE_WARNING || n_status == NFM_MOVE_TRANSFERED  ||
          n_status == NFM_PURGE_FILE )
          {

               if(!strcmp(data[count+FTO_SANO],sano))
               {
               status = NFMappend_path_file (data [count+FTO_OPSYS],
                        data [count+FTO_PATHNAME], data [count + FTO_CIFILENAME], src_file);
               if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname," Append Path : status = <0x%.8x>\n",
                  status));
		 ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMappend_path",status);
		 status1 = status ;
                 NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_APPEND_CI);
		 continue;
		  
                }
               if(n_status == NFM_MOVE_TRANSFERED )
               {
               status = NFMappend_path_file (data [count+FTO_OPSYS],
                        data [count+FTO_PATHNAME], data [count + FTO_FILEOLD], file_old);
               if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname," Append Path : status = <0x%.8x>\n",
                  status));
		 ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMappend_path",status);
		 status1 = status ;
                 NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_APPEND_FILEOLD);
		 continue;
		  
                }
	       NFMconvert_to_vax_file(src_file);
	       NFMconvert_to_vax_file(file_old);
               sprintf (str, "rename %s %s", file_old,src_file);
               }
              else
               {
	       NFMconvert_to_vax_file(src_file);
               sprintf (str, "delete %s", src_file);
               }
	       status = NFMfmu_rcmd(str,"");
	       if(status!=NFM_S_SUCCESS)
		{
                  _NFMdebug ((fname," fmu_rcmd failed for command <%s>: status = <0x%.8x>\n",str, status));
		  ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMfmu_rcmd",status);
                  NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_FMU_DELETE_CI_FILENAME);
		  status1 = NFM_E_FAILURE;
		  continue;
		}
               switch(n_status)
               {
                case NFM_PURGE_FILE:
                        n_status = NFM_PURGED;
                        break;
                case NFM_MOVE_TRANSFERED:
                        n_status = NFM_MOVE_MOVE_UNDONE ;
                        break;
                case NFM_DELETE_FILE:
                        n_status = NFM_REMOVED ;
                        break;
                default:
                        n_status = NFM_UNDONE;
               }

               status = NFMset_buf_stat (*buffer_ptr,  x + 1, FTO_STATUS1 + 1,n_status);
              }
          }
       }

      status=NETfmu_disconnect();
      if(status != NET_S_SUCCESS )
      {
          _NFMdebug ((fname," fmu_disconnect failed  status = <0x%.8x>\n", status));
            return(status);
      }

      
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", status1));
      return (status1);      
   }


