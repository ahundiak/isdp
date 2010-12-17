#include "machine.h"
#define  INCLUDE_EXTERN 1
#include "NFMf_xferinc.h"
#ifdef sparc
#define  BLKSIZ 1024         /* 12/9/92 - KT - SUN port */
#endif

static long buffer_info_size = sizeof(NFMbuffer_info);
static long status_buf_size = sizeof(NFMstatus_buf);
static long char_size = sizeof( char );
static long fto_status_size = sizeof( NFMfto_status );
static long file_info_size = sizeof( NFMfile_info );
static long cp_buffer_size = sizeof( NFMcp_buffer );


extern int CHECKSUM;

/************************************************************
12/9/92
Modifications by Karen Tice

Call to 'Stat' are replaced by calls to 'stat'.

Each call to NETbuffer_send has been replaced by NFMsend_info.
Each call to NFMbuffer_receive has been replaced by NFMrecv_info.

Special byte swapping must be done before a 'send' and after a
'receive' for SUN network transfers.

At first glance, it appeared that all I had to do was modify
the NETbuffer_send and NETbuffer_receive functions. However,
input into these functions can either be NFMbuffer_info or 
NFMfile_info or NFMfto_status or NFMstatus_buf or NFMcp_buffer. 
Inside the NETbuffer_send and NETbuffer_receive I would not be able to 
tell what type of info was passed in. Therefore, input to NFMsend_info 
and NFMrecv_info is a buffer type. If 'sparc' is defined (#ifdef sparc) 
for SUN, the byte swapping will occur!
*************************************************************/



/************************************************************************
*									*
*			_NFMftr_make_files_local			*
*									*
*	This function makes the files locally available to the FTR      *
*	engine on the environment node.                                 *
************************************************************************/

long _NFMftr_make_files_local (buffer_ptr)

MEMptr  *buffer_ptr;
{
  char *fname="_NFMftr_make_files_local";
  long     status;

  _NFMdebug((fname,"Entry > MEMptr: *buffer_ptr = <%x>\n",*buffer_ptr));
  
  status = _NFMfs_recv_files(buffer_ptr);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname,"NFM File server  receive  clix : status = <0x%.8x>\n",
    status));
    return (status);             

  }
  _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);     
}

/***********************************************************************
*                                                                       *
*                       _NFMftr_undo_make_files_local                   *
*                                                                       *
*       This function is used to undo the operation performed by        *
*        _NFMftr_make_files_local. This can be called after a partial   *
* 	failure  or after a successful completion.                      *
*       All files with n_status set to NFM_TRANSFERED, NFM_READ_ONLY         *
*       NFM_NFSED will be handled.                                      *
*       n_status        n_status                Action                  *
*       before          after                                           *
*       NFM_TRANSFERED  NFM_UNDONE              Delete COFILENAME       *
*       NFM_NFSED       NFM_NFS_UNDONE          Undo nfs mount/link     *
*       NFM_READ_ONLY        NFM_READ_DONE           Change mode on          *
*                                               COFILENAME to Read only *
*                       NFM_FAILURE             Operation Failed        *
*                                                                       *
************************************************************************/


 long _NFMftr_undo_make_files_local (buffer_ptr)
   MEMptr  *buffer_ptr;
   {
     return(NFMrm_co_files(buffer_ptr,0));
   }


 long NFMftr_no_op_lock_s (inpipe,outpipe)
	int *inpipe,*outpipe;
{
	char *fname="NFMftr_no_op_lock_s";
	long count,status,lock,pid;

	_NFMdebug((fname,"Entry: inpipe <%ld> : outpipe : <%ld>\n",inpipe,outpipe));
	lock = -1;

	pid = getpid();
	count = 0;

	status = NETcheck_lock(&lock);

	while ( lock != pid && count < 50 )
	{
		_NFMdebug((fname,"Locking: PID <%d> : Lock <%d>\n",pid,lock));
		if(lock == 0 )
			NETset_lock(pid);
		else
			sleep(1);
		NETcheck_lock(&lock);
		count++;
		
	}
	if(lock == pid)
	{
		status = NFM_S_SUCCESS;
        }
	else
	{
		status =  NFM_E_FTR_OPTIONS_LOCK;
		_NFMdebug((fname,"Cannot lock the FTR Options : status : <0x%.8x>\n",status));
		/* error */
		/* Exit will be done by calling program  */
	        return(NFMnet_oper_fail_fs(0,0,0,status));

	}
    _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);

	
}


 long NFMftr_options_file_reset_s (inpipe,outpipe)
	int *inpipe,*outpipe;
{
	char *fname="NFMftr_options_file_reset_s";
	long status,status1;
        int length;
    NFMbuffer_info buffer_info;

	long pid,lock;
	
	_NFMdebug((fname,"Entry: inpipe <%ld> : outpipe : <%ld>\n",inpipe,outpipe));
	status = status1=NFM_S_SUCCESS;
	pid = getpid();
	NETcheck_lock(&lock);
	if(pid == lock)
	{
		status1 = NFMfile_copy_s(inpipe,outpipe);
		NETset_lock(0);
	}
        else
	{
		status = NFM_E_FTR_OPTIONS_UNLOCK;
    buffer_info.request = status;
    length = buffer_info_size;

    status = NFMsend_info (NFMBUFFER_INFO, outpipe, (char *) &buffer_info,
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMsend_info:buffer_info:size <%d>:request: <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,buffer_info.request,
status));
/* Exit will be done by calling program  */
        return(NFMnet_oper_fail_fs(0,0,0,status));
     }

		_NFMdebug((fname,"Unlock Failed PID <%d> : Lock Id <%d>\n",pid,lock));
	}
	if(status == NFM_S_SUCCESS && status1 != NFM_S_SUCCESS) status = status1;
        return (status);
}

long NFMftr_no_op_lock(NETid)
	long *NETid;
{
    char *fname="NFMftr_no_op_lock";
    long status;
    int length;
    NFMbuffer_info buffer_info;
    /*  Send a file request to the server  */

    buffer_info.size = 0;
    buffer_info.request = NFM_FTR_NO_OP_LOCK;

    length = buffer_info_size ;
    status = NFMsend_info (NFMBUFFER_INFO, (int *)NETid, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:buffer_info.request = <%d>: status = <0x%.8x>\n",
       buffer_info.request,status));
       return(NFMnet_oper_fail_fs ( 0, 0,0 , status));
     }
/* Receive buffer_info from the server */
    length = buffer_info_size;

    status = NFMrecv_info (NFMBUFFER_INFO, (int *)NETid, (char *) &buffer_info,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMrecv_info: buffer_info: status <0x%.8x>\n",status));
       return(NFMnet_oper_fail_fs ( 0, 0,0 , status));
     }

    status = buffer_info.request;
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname,"Ser Main Ret Status : status = <0x%.8x>\n",
       status));
       _NFMdebug ((fname,"buffer_info.request =  status = <0x%.8x>\n", status));
       ERRload_struct(NFM,status,"");
     }
    _NFMdebug((fname,"SUCCESSFUL status = <0x%.8x>\n",status));
    return (status);
}





long NFMftr_options_file_reset (src_file, dst_file,attribute, delete_src_flag,NETid)
  char  *src_file;
  char  *dst_file;
  char *attribute;
  long delete_src_flag;
  long   *NETid;
  {
    char *fname="NFMftr_options_file_reset";
    long     status;
    int     length;
    NFMbuffer_info  buffer_info;
    NFMcp_buffer    cp_buffer;
    NFMfto_status	fto_status ;


    _NFMdebug ((fname,"Entry: Src File  = <%s> Dst File  <%s>\n delete_src_flag <%d> \
 *NETid  <%d>\n ", src_file,dst_file,delete_src_flag,*NETid  ));

    buffer_info.size    = 0;
    buffer_info.request = NFM_FTR_OPTIONS_FILE_RESET;

    length = buffer_info_size;
    status = NFMsend_info (NFMBUFFER_INFO, (int *)NETid, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:buffer_info.request = <%d>: status = <0x%.8x>\n",
       buffer_info.request,status));
       return(NFMnet_oper_fail_fs(0,0,0,status));
     }

/* Receive buffer_info from the server */
    status = NFMrecv_info (NFMBUFFER_INFO, (int *)NETid, (char *) &buffer_info,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMrecv_info: buffer_info: status <0x%.8x>\n",status));
       return(NFMnet_oper_fail_fs(0,0,0,status));
     }
/* Check the status of message buffer */
    if( buffer_info.request != NFM_S_FS_SEND_CP_BUFFER )
    {
        _NFMdebug((fname,"Fileserver 2 is out of sync: status of FS2 <0x%.8x>\n",buffer_info.request));
       return(NFMnet_oper_fail_fs(0,0,0,status));
    }
    /*  Send the file info to the server  */

    strncpy (cp_buffer.src_name, src_file, NFM_FILENAME);
    cp_buffer.src_name [NFM_FILENAME] = '\0';
    strncpy (cp_buffer.dst_name, dst_file, NFM_FILENAME);
    cp_buffer.dst_name [NFM_FILENAME] = '\0';

    strncpy (cp_buffer.attr, attribute, NFM_USERNAME);
    cp_buffer.attr [NFM_USERNAME] = '\0';

    cp_buffer.delete_src_flag = delete_src_flag;
    length = cp_buffer_size;

    status = NFMsend_info (NFMCP_BUFFER, (int *)NETid, (char *) &cp_buffer, &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:cp_buffer:src file = <%s>:\
dst_file <%s> : attribute <%s> : delete_src_flag <%d>\n",cp_buffer.src_name,
cp_buffer.dst_name,cp_buffer.attr,cp_buffer.delete_src_flag));
       return(NFMnet_oper_fail_fs(0,0,0,status));
     }


    length = fto_status_size;

    status = NFMrecv_info (NFMFTO_STATUS, (int *)NETid, (char *) &fto_status,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMrecv_info: fto_status: status <0x%.8x>\n",status));
       return(NFMnet_oper_fail_fs(0,0,0,status));
     }

    status = fto_status.status;
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname,"Ser Main Ret Status : status = <0x%.8x>\n",
       status));
       _NFMdebug ((fname,"buffer_info.request =  status = <0x%.8x>\n", status));
       ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","Receive at FS2:Status",status);
       xfer_buf_status.status2 = fto_status.status2;
       xfer_buf_status.status3 = fto_status.status3;

       return (status);
     }
	_NFMdebug((fname,"SUCCESSFUL:	status <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);


}




long NFMftr_options_file_lock (node,user,pass,src_file, dst_file,ori_file,NETid,flag)
  char *node;
  char *user;
  char *pass;
  char  *src_file;
  char  *dst_file;
  char  *ori_file;
  long *NETid;
  long flag; /* 0 - - Send New Options File 1 -- Do Not  Send New Options File */
  {
	char *fname="NFMftr_options_file_lock";
	long status,status1;
  char *attribute="";
  long *file_size,file_size_val;
  long   protocol=0;
	file_size = &file_size_val;
	protocol = 0;


	_NFMdebug((fname,"Entry: Node <%s>: user <%s> : source <%s>\n\
destination <%s> : temporary <%s> attribute <%s>\n\
file size <%d> : protocol <%d>\n",node,user,src_file,dst_file,ori_file,attribute, *file_size, protocol ));

      status1 = NFM_S_SUCCESS;
/* Connect */
      
      if( *NETid < 0 )
      {

      status = NFMconnect (node, user, pass,
               NFM_TCP_PORT, NFM_XNS_PORT, (int *)NETid, protocol);
      if (status != NFM_S_SUCCESS)
       {

         status = NFM_E_TLI_CONNECT_FS1;
         ERRload_struct(NFM,status,"%d%d%s%s",net_buf_status.status2,
net_buf_status.status3,node,user);
         _NFMdebug ((fname,"NFMconnect Failed :node_name <%s>: username <%s>:\
connect_status <%d>:errno <%d>: status = <0x%.8x>\n",node,user,
net_buf_status.status2, net_buf_status.status3,status));
         return (NFM_E_SEVERE_ERROR);
       }
      }
      else
      {
	_NFMdebug((fname,"Previous Connection is Open: Using NETid <%d>\n",*NETid));
      }
/* Set the lock */
       status = NFMftr_no_op_lock(NETid);
       if(status != NFM_S_SUCCESS)
       {
           _NFMdebug((fname,"Failed to set option Lock  status <0x%.8x>\n",status));
  /* If it is a send or receive failure then try to disconnect the second
     fileserver and break */

	   NFMftr_options_file_unlock ( ori_file,dst_file,NETid,0);

            if(status == NFM_E_TLI_SEND_FS1_FS2 ||
               status == NFM_E_TLI_RECEIVE_SIZE_FS1_FS2 ||
               status == NFM_E_TLI_RECEIVE_FS1_FS2)
            {
		  NFMdisconnect ((int *)NETid);
  		_NFMdebug ((fname,"Network connection broken: status = <0x%.8x>\n", status));
            }
	   return(status);
        }
/* Copy file */
       status = NFMfile_copy(ori_file,dst_file, attribute, 0,(int *)NETid);
       if(status != NFM_S_SUCCESS)
       {
           _NFMdebug((fname,"Failed to move options file <%s> \
 to temporary <%s> : status <0x%.8x>\n",ori_file,dst_file,status));
  /* If it is a send or receive failure then try to disconnect the second
     fileserver and break */
            if(status == NFM_E_TLI_SEND_FS1_FS2 ||
               status == NFM_E_TLI_RECEIVE_SIZE_FS1_FS2 ||
               status == NFM_E_TLI_RECEIVE_FS1_FS2)
            {
		  NFMdisconnect ((int *)NETid);
  		_NFMdebug ((fname,"Network connection broken: status = <0x%.8x>\n", status));
            }

	   status = NFM_E_FTR_OPTIONS_FILE_COPY;
	   return(status);
         }

/* Lock and send new file */
       if(flag <= 0 )
       {
       status =  NFMfile_send (src_file, dst_file, attribute, (int *)file_size,(int *)NETid, 0);
       if(status != NFM_S_SUCCESS)
       {
           _NFMdebug((fname,"Failed to send options file <%s> \
 to file <%s> : status <0x%.8x>\n",src_file,dst_file,status));
  /* If it is a send or receive failure then try to disconnect the second
     fileserver and break */

	   NFMftr_options_file_unlock ( ori_file,dst_file,NETid,0);

            if(status == NFM_E_TLI_SEND_FS1_FS2 ||
               status == NFM_E_TLI_RECEIVE_SIZE_FS1_FS2 ||
               status == NFM_E_TLI_RECEIVE_FS1_FS2)
            {
		  NFMdisconnect ((int *)NETid);
  		_NFMdebug ((fname,"Network connection broken: status = <0x%.8x>\n", status));
            }
	   return(status);
        }
       }
	
	_NFMdebug((fname,"SUCCESSFUL : <0x%.8x>\n",status));
	return(status);
  }

long NFMftr_options_file_unlock ( ori_file,dst_file,NETid , flag)
  char  *ori_file;
  char  *dst_file;
  long *NETid;
  long flag; /* 0 -- Disconnect 1 -- Do not disconnect */
  {
	char *fname="NFMftr_options_file_unlock";
	long status;
  char *attribute="";


	_NFMdebug((fname,"Entry: destination <%s> : temporary <%s> attribute <%s>\n\
 : NETid <%d>\n",dst_file,ori_file,attribute, *NETid ));

	if(*NETid < 0 )
        {
		status = NFM_E_FTR_BAD_NETID;
		_NFMdebug((fname,"Bad NETid: No Connection exists: NETid <%d> : status <0x%.8x>\n", *NETid,status));
		return(status);
	}
/* Reset */
	status = NFMftr_options_file_reset (ori_file, dst_file,attribute, 0,NETid);
       if(status != NFM_S_SUCCESS)
       {
           _NFMdebug((fname,"Failed to move temporary file <%s> \
 to options file <%s> : status <0x%.8x>\n",ori_file,dst_file,status));
  /* If it is a send or receive failure then try to disconnect the second
     fileserver and break */
            if(status == NFM_E_TLI_SEND_FS1_FS2 ||
               status == NFM_E_TLI_RECEIVE_SIZE_FS1_FS2 ||
               status == NFM_E_TLI_RECEIVE_FS1_FS2)
            {
		  NFMdisconnect ((int *)NETid);
  		_NFMdebug ((fname,"Network connection broken: status = <0x%.8x>\n", status));
            }
	   return(status);
        }
/* disconnect */
	if(flag <= 0 )
	        NFMdisconnect ((int *)NETid);
	_NFMdebug((fname,"SUCCESSFUL : <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}
