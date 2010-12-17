#include "machine.h"
#define  INCLUDE_EXTERN 1

/* 12/9/92 - KT - include for SEEK_SET */
#include <unistd.h>

#include "NFMf_xferinc.h"

#define NO_LFM_CHECK            0

extern NFMuser_info_struct NFMuser_info ;

/*************************************************************************
*			NFMfs_nfs_cleanup				 *	
*	This is a server side function to kick off file server with      *
*	command NFM_NFS_CLEANUP, called by Nfmadmin			 *
*************************************************************************/

long NFMfs_nfs_cleanup(node_name, user_name, passwd)
char *node_name; 
char *user_name, *passwd; /** Drop these arguments later**/ 
   {
      char *fname="NFMfs_nfs_cleanup";
      long    status, status1, sock_no, protocol;
      char dec_passwd[NFM_PASSWD];
      MEMptr save_buffer = NULL, buffer_ptr = NULL ;

      _NFMdebug ((fname,"nodename <%s> username <%s> password <%s>\n",
		node_name,user_name,passwd));

      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         status = NFM_E_NET_DECRYPT_CO_LOCATION;
         _NFMdebug ((fname,"Decrypt Passwd : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s%s%s%s",node_name,user_name,passwd,"");
         return (NFM_E_SEVERE_ERROR);
       }

      sock_no = -1;
      protocol = 0;

      net_buf_status.status1 = net_buf_status.status2 = net_buf_status.status3  = 0;

      /** use root to kick off fileserver since this is the only valid user
	  name that exist forever **/ 
      status = NFMconnect (node_name, "root", "",
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

      status = NFMcl_send_buffer (&sock_no, NFM_NFS_CLEANUP, buffer_ptr);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Failed to send command NFM_NFS_CLEANUP\n\
to fileserver at nodename <%s> username <%s> sock_no <%d> status = <0x%.8x>\n",
	node_name,user_name,sock_no, status));
	 status = NFM_E_SEND_COMMAND_S_TO_FS ;
	 ERRload_struct(NFM,status,"%s%s%s"," NFS Cleanup:", 
			node_name,user_name);
         NFMcl_fs_exit (&sock_no);
         return (NFM_E_SEVERE_ERROR);
       }      

      status1 = NFM_S_SUCCESS;

      save_buffer = NULL ;
      status = NFMcl_receive_buffer (&sock_no, &status1, &save_buffer);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose(&save_buffer); 

         _NFMdebug ((fname,"Receive from Fileserver filed; \n\
at node <%s> username <%s> sock_no <%d> status = <0x%.8x>\n",
	 node_name,user_name,sock_no, status));
	 status = NFM_E_RECEIVE_RESPONSE_FS_TO_S ;
	 ERRload_struct(NFM,status,"%s%s%s","NFS Cleanup:",node_name,user_name);
         NFMcl_fs_exit (&sock_no);
         return (NFM_E_SEVERE_ERROR);
       }      
	/*MEMclose(buffer_ptr);
	*buffer_ptr = save_buffer ;*/

      status = NFMcl_fs_exit (&sock_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFMcl_fs_exit Failed:Connection to nodename <%s>\
username <%s> status = <0x%.8x>\n",node_name,user_name, status));
	status = NFM_E_EXIT_S_TO_FS;
	 ERRload_struct(NFM,status,"%s%s%s","NFS Cleanup",node_name,user_name);
         return (status);
       }

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFMCleanup on File server failed,\
loading error <0x%.8x>\n", status1)); 
	 ERRload_struct(NFM,status1,"",NULL);
         return (status1);
       }
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", status1));
      return (status1);
   }
/************************************************************************
*									*
*			NFMfs_dest_nfs_cleanup				*
*									*
*	This procedure is the file server side function, which is       *
*	called when the Admin utility sends the command			*
*	NFM_NFS_CLEANUP. The files /usr/ip32/nfm/config/nfs/nfmnfstabs 	*
*	and /usr/ip32/nfm/config/nfs/nfmnfslinks are cleaned up in this.*
************************************************************************/

 long NFMfs_dest_nfs_cleanup ( buffer_ptr)
   MEMptr *buffer_ptr; 
   {
      char *fname="NFMfs_dest_nfs_cleanup";
      FILE *fp1, *fp2, *fp3;
      char buffer[256], buffer1[256], buffer2[256];
      char *mount; 
      long status1, status, size;
      int m_length, cleanedup, row_found=0 ;

	_NFMdebug ((fname,"Entry\n"));
  	
	status1 = NFM_S_SUCCESS;
	fp1 = fopen("/usr/ip32/nfm/config/nfs/nfmnfstabs", "r"); 
	if(!fp1)
	{
	 	_NFMdebug((fname, "Can't open nfmnfstabs file, errorno <%d>\n",
			 errno));	
		status1 = NFM_E_NO_NFSTABS;
	}
	fp2 = fopen("/usr/ip32/nfm/config/nfs/nfmnfslinks", "r"); 
	if(!fp2)
	{
	 	_NFMdebug((fname, "Can't open nfmnfslinks file, errorno<%d>\n", 
			errno));	
		if(status1 == NFM_E_NO_NFSTABS)
		{
			status = NFM_I_NO_NFS_ACTIVITY;
			ERRload_struct(NFM, status, "", 0);
			return(status); /**Node has no NFS activity**/
		}
		else if(status1 == NFM_S_SUCCESS)
			return(NFM_E_NO_NFSLINKS);
	}
	else if(status1 != NFM_S_SUCCESS)
		return(status1);

	fp3 = fopen("/usr/ip32/nfm/config/nfs/nfmtmptabs", "w"); 
	if(!fp3)
	{
	    _NFMdebug((fname, "Can't open nfmtmplinks temp file, error <%d>\n",
		 errno));	
	    return(NFM_E_OPEN_NFS_TEMP);
	}

	cleanedup = 0;
	while(fgets(buffer, 256, fp1)!= NULL)
	{
		strcpy(buffer1, buffer);
		mount = strtok(buffer, " ");	
		mount = strtok(NULL, " ");	
		m_length = strlen(mount); 	

		fseek(fp2, 0, SEEK_SET);
		row_found = 0;
		while(fgets(buffer2, 256, fp2)!= NULL)
		{
			if(strncmp(mount, buffer2, m_length)==0)
			{
			    _NFMdebug((fname, "Match found\n"));
			    fputs(buffer1, fp3); 
			    row_found = 1;
			    break;
			}
		}
		if(row_found == 0)
			cleanedup = 1;
	}
	fclose(fp1);
	fclose(fp2);
	fclose(fp3);

	status = NFMcopy_file("/usr/ip32/nfm/config/nfs/nfmtmptabs",
			      "/usr/ip32/nfm/config/nfs/nfmnfstabs",
			      "777",
		     	      &size, 0);
	if(status == NFM_S_SUCCESS)
		unlink("/usr/ip32/nfm/config/nfs/nfmtmptabs");
	
	if(cleanedup == 0)
	{
		status = NFM_I_NFS_NOT_CLEANED; 
		ERRload_struct(NFM, status, "", 0); 
		return(status);
	}
	return(status);
   }
