#include "machine.h"
#define  INCLUDE_EXTERN 1

/*  ifdef sparc changed to include solaris. In case of CLIX */
/*  and SCO BLKSIZ is defined. Any further platforms to be  */
/*  taken care appropriately */
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || defined (__sgi) || defined (OS_HPUX) )
#define  BLKSIZ 1024         /* 12/9/92 - KT - SUN port */
#endif

#include "NFMf_xferinc.h"

static long buffer_info_size = sizeof(NFMbuffer_info);
static long status_buf_size = sizeof(NFMstatus_buf);
static long char_size = sizeof( char );
static long fto_status_size = sizeof( NFMfto_status );
static long file_info_size = sizeof( NFMfile_info );
static long cp_buffer_size = sizeof( NFMcp_buffer );

/** DELETE THESE
#define NFM_E_SUM_CO_FILENAME 99999
#define NFM_E_CHECKSUM_MISMATCH 99998
#define NFM_E_SUM 99997
**/

int CHECKSUM;

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

int NFMfile_send (src_file, dst_file, attribute, file_size,NETid, flag)
  char  *src_file;
  char  *dst_file;
  char  *attribute;
  int   *file_size;
  int   *NETid;
  int flag;
  {
    char *fname="NFMfile_send";
    int     status,status1, x;
    FILE    *infile = NULL;
    int     length, max_size, buffer_size;
    long  alloc_size;
    char    *buffer = NULL,*buf_ptr = NULL ;
    char    file_name [NFM_FILENAME];
    struct  stat            fbuff;
    NFMbuffer_info  buffer_info;
    NFMfile_info    file_info;
    NFMstatus_buf  *buf_info_ptr;
    NFMfto_status  fto_status ;

    int checksum, checksum2;

    _NFMdebug ((fname,"Entry: Src File  = <%s> Dst File  <%s>\n Attribute <%s> \
 FIle Size <%d>\n ", src_file,dst_file,attribute,*file_size  ));

     alloc_size = buffer_size = max_size =  0;

    /*  Get file name  */

    status = NFMget_full_name (src_file, file_name);
    if (status != NFM_S_SUCCESS)
     {
/* Return error that COFILENAME is NULL */
       _NFMdebug ((fname,"Get File Name : status = <0x%.8x>", status));
       return (NFM_E_NO_CO_FILENAME);
     }

/* Check if file exists etc */
    status = stat (file_name, &fbuff);
    if (status) /* OK */
     {
       status = NFM_E_STAT;
       _NFMdebug ((fname,"Stat Failed : filename <%s> status = <0x%.8x> errno  = <%d>\n",file_name,status, errno ));
       ERRload_struct(NFM,status,"%s%x%d",file_name,status,errno);
/* Return error that stat failed for COFILENAME */
       xfer_buf_status.status2 = errno ;
       return (NFM_E_STAT_CO_FILENAME);
     }


    /*  Open the file for read only  */

    infile = fopen (file_name, "r");
    if (! infile)
     {
       status = NFM_E_FOPEN;
       _NFMdebug((fname,"fopen failed : filename <%s>: errno <%d> type <%s> \
:status <0x%.8x>\n",file_name,errno,"r",status));
       ERRload_struct(NFM,status,"%s%d%s",file_name,errno,"r");
/* Return appropriate error to send back to server */
       xfer_buf_status.status2 = errno;
       return (NFM_E_FOPEN_READ_CO_FILENAME);
     }

    /*  Allocate a buffer to read the file into  */
/*
	max_size = fbuff.st_size + buffer_info_size + NFM_FILENAME;
*/
	max_size = 10* TCP_MAX_SIZE + status_buf_size + NFM_FILENAME;
	
	status = NFMmalloc(&buffer,max_size,&alloc_size);
	if(status != NFM_S_SUCCESS || alloc_size < status_buf_size )
     	{
		free(buffer);
       		fclose (infile);
       		_NFMdebug ((fname,"Malloc :size <%d>:Or Cannot get malloc size \
greater than status_buf_size <%d>: status = <0x%.8x>\n",max_size,status_buf_size, status));
       		status = NFM_E_MALLOC;
       		ERRload_struct(NFM,status,"%d",max_size);
       		return (NFM_E_MALLOC_TEMP_FS1);
	}

/* save the pointer for free */
     buf_ptr = buffer ;



    /*  Send a file request to the server  */

    buffer_info.size = 0;
    buffer_info.request = NFM_FILE_SEND;

    length = buffer_info_size ;
    status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:buffer_info.request = <%d>: status = <0x%.8x>\n",
       buffer_info.request,status));
       return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , status));
     }
/* Receive buffer_info from the server */
    status = NFMrecv_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMrecv_info: buffer_info: status <0x%.8x>\n",status));
       return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , status));
     }
/* Check the status of message buffer */
    if( buffer_info.request != NFM_S_FS_SEND_FILE_INFO )
    {
        _NFMdebug((fname,"Fileserver 2 is out of sync: status of FS2 <0x%.8x>\n",buffer_info.request));
        return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , buffer_info.request));

    }

    if(strncmp(buffer_info.username, "CHECKSUM", 7) == 0)
	CHECKSUM = 1;


    /*  Load NFMfile_info structure  */

    strncpy (file_info.name, dst_file, NFM_FILENAME);
    file_info.name [NFM_FILENAME] = '\0';

    strncpy (file_info.attr, attribute, NFM_USERNAME);
    file_info.attr [NFM_USERNAME] = '\0';
    if(flag > 0 )
    {
      strncpy (file_info.platter, "CHECK", NFM_PLATTERNAME);
      file_info.platter [NFM_PLATTERNAME] = '\0';
    }
    else strcpy(file_info.platter,"");
	
    checksum = -1;
    if(CHECKSUM)
    {
	status = NFMcheck_sum(file_name, &checksum);
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname, "NFMcheck_sum failed, status <0x%.8x>\n",
								status));
       		return (NFM_E_SUM_CO_FILENAME);
		/** return(status) ?? **/
	}
	strcpy(file_info.partition, "SUM"); /** CHECKSUM **/
    }

    file_info.size  = fbuff.st_size;
    file_info.mode  = fbuff.st_mode;
    file_info.atime = fbuff.st_atime;
    file_info.mtime = fbuff.st_mtime;

    _NFMdebug((fname,"File Name = <%s> FIle Attr <%s>\n File Size <%d> File Mode <%d> CHECKSUM <%d>\n \
File Atime <%d> File Mtime <%d>\n",file_info.name,file_info.attr,file_info.size,
file_info.mode, checksum, file_info.atime,file_info.mtime));
    /*  Send the file info to the server  */

    length = file_info_size;

    status = NFMsend_info (NFMFILE_INFO, NETid, (char *) &file_info, &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:file_info.filename = <%s>: status = <0x%.8x>\n",
       file_info.name,status));
       return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , status));
     }

    /*  Receive a reply from the server  */

    status = NFMrecv_info (NFMFTO_STATUS, NETid, (char *) &fto_status,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMrecv_info: fto_status: status <0x%.8x>\n",status));
       return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , status));
     }

    if(fto_status.status != NFM_S_MALLOCED_SIZE)
     {
        _NFMdebug((fname,"Fileserver 2 is out of sync: status of FS2 <0x%.8x>\n",fto_status.status));
	free(buf_ptr);
	fclose(infile);
        xfer_buf_status.status2 = fto_status.status2 ;
        xfer_buf_status.status3 = fto_status.status3 ;
	return(fto_status.status);
     }

    if (fto_status.status2 > alloc_size )
	max_size = alloc_size - status_buf_size;
    else 
    	max_size = fto_status.status2 - status_buf_size;
/* Communicate the size to be used to the other side */
    buffer_info.size = max_size ;
    buffer_info.request = NFM_S_FS2_USE_SIZE ;
    length = buffer_info_size;
    status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:file_info.filename = <%s>: status = <0x%.8x>\n",
       file_info.name,status));
       return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , status));
     }

    /*  Receive a reply   */


    status = NFMrecv_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMrecv_info: buffer_info: status <0x%.8x>\n",status));
       return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , status));
     }
/* Check the status of message buffer */
    if( buffer_info.request != NFM_S_FS2_USING_SIZE )
    {
        _NFMdebug((fname,"Fileserver 2 is out of sync: status of FS2 <0x%.8x>\n",buffer_info.request));
        return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , buffer_info.request));

    }


    if (file_info.size > 0)
     {
       buffer_size = file_info.size;
       x = 1;

       length = max_size+status_buf_size;
       buf_info_ptr =  (NFMstatus_buf *)buffer;
       buffer+=status_buf_size;
       buf_info_ptr->status = NFM_S_FS_SENT_BUFFER ;

       while (buffer_size > max_size)
        {
          status = fread (buffer, char_size, max_size , infile);
          if (status != max_size )
           {
/* send message to the fileserver 2 to abort filetransfer 
   clean up and exit to main */
             buf_info_ptr->status = NFM_E_FREAD;
    	     length = status_buf_size;
    	     status1 = NFMsend_info (NFMSTATUS_BUF, NETid, 
                                     (char *) buf_info_ptr, &length);
    	     if (status1 != NET_S_SUCCESS)
     	      {
		_NFMdebug ((fname,"NFMsend_info:buf_info_ptr->status = <0x%.8x>: status = <0x%.8x>\n",
       		buf_info_ptr->status,status1));
       			return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , status1));
     	      }
             free (buf_ptr);
             fclose (infile);
             _NFMdebug ((fname,"fread failed:filename <%s>:size1 <%d>: size2 \
<%d>:errno <%d>: status = <0x%.8x>\n",file_name,max_size,status,errno ,NFM_E_FREAD));
             ERRload_struct(NFM,NFM_E_FREAD,"%s%d%d%d",file_name,max_size,status,errno);
	     xfer_buf_status.status2 = max_size ;
	     xfer_buf_status.status3 = status ;
             return (NFM_E_FREAD_CO_FILENAME);
           }

          _NFMdebug ((fname,"Data Packet No   : <%d> Size <%d>\n  ", x ,length    ));
          status = NFMsend_info (NFMSTATUS_BUF, NETid, (char *) (buf_info_ptr) ,
                                 &length);
          if (status != NET_S_SUCCESS)
           {
	     _NFMdebug((fname,"NFMsend_info:buffer: size <%d>:buffer_size <%d>\
packet_no <%d>: status <0x%.8x>\n", length,buffer_size,x,status));
	     
             return (NFMnet_oper_fail_fs(buf_ptr,infile,0,status));
           }

          buffer_size = buffer_size - max_size;
          x = x + 1;
        }

       status = fread (buffer, char_size , buffer_size , infile);
       if (status != buffer_size )
        {
/* send message to the fileserver 2 to abort filetransfer 
   clean up and exit to main */
	     buf_info_ptr->status = NFM_E_FREAD;
    	     length = status_buf_size;
    	     status1 = NFMsend_info (NFMSTATUS_BUF, NETid, 
                                     (char *) (buf_info_ptr), &length);
    	     if (status1 != NET_S_SUCCESS)
     	      {
       			_NFMdebug ((fname,"NFMsend_info:buf_info_ptr->status = <0x%.8x>: status = <0x%.8x>\n",
       		buf_info_ptr->status,status1));
       			return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , status1));
     	      }
          free (buf_ptr);
          fclose (infile);
          _NFMdebug ((fname,"fread failed:filename <%s>:size1 <%d>: size2 \
<%d>:errno <%d>: status = <0x%.8x>\n",file_name,buffer_size,status,errno ,NFM_E_FREAD));
          ERRload_struct(NFM,NFM_E_FREAD,"%s%d%d%d",file_name,buffer_size,status,errno);
	  xfer_buf_status.status2 = buffer_size ;
	  xfer_buf_status.status3 = status ;
          return (NFM_E_FREAD_CO_FILENAME);
        }

       /*  Send the file buffer to the server  */

       length = buffer_size + status_buf_size;
       _NFMdebug ((fname,"Data Packet No   : <%d> Size <%d>\n  ", x ,length    ));

       status = NFMsend_info (NFMSTATUS_BUF, NETid, (char *)(buf_info_ptr), 
                              &length);
       if (status != NET_S_SUCCESS)
        {
	     _NFMdebug((fname,"NFMsend_info:buffer: size <%d>:buffer_size <%d>\
packet_no <%d>: status <0x%.8x>\n", length,buffer_size,x,status));
	     return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , status));
	     
        } 

     }
/* Receive buffer_info from the server */
       status = NFMrecv_info (NFMFTO_STATUS, NETid, (char *) &fto_status,
             &length);
       if (status != NET_S_SUCCESS)
       {
         _NFMdebug((fname,"NFMrecv_info: fto_status: status <0x%.8x>\n",status));
         return(NFMnet_oper_fail_fs ( buf_ptr, infile,0 , status));
       }
/* Check the status of message buffer */
       if( fto_status.status != NFM_S_FS_FT_COMPLETE )
       {
             _NFMdebug((fname,"Fileserver 2 is out of sync: status of FS2 <0x%.8x>\n",fto_status.status));
	free(buf_ptr);
	fclose(infile);
        xfer_buf_status.status2 = fto_status.status2 ;
        xfer_buf_status.status3 = fto_status.status3 ;
	return(fto_status.status);
       }

    fclose (infile);
    free (buf_ptr);

    buffer_info.request = NFM_S_FS_SEND_FILE_INFO;

    length = buffer_info_size;

    status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info,
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:buffer_info.request = <%d>: status = <0x%.8x>\n",
       buffer_info.request,status));
       return(NFMnet_oper_fail_fs ( 0, 0,0 , status));
     }
    /*  Receive file_info from the server  */

    status = NFMrecv_info (NFMFILE_INFO, NETid, (char *) &file_info,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMrecv_info: file_info: status <0x%.8x>\n",status));
       return(NFMnet_oper_fail_fs ( 0, 0,0 , status));
       
     }

    checksum2 = -1;
    if(CHECKSUM)
    {
    	checksum2 = atoi(file_info.partition);
        _NFMdebug((fname,"FS1: Received checksum for CIFILE: <%d>\n",
							checksum2));
	
    }

    length = buffer_info_size;

    status = NFMrecv_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info,
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
       ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","Receive at FS2:Status",status);
       return (status);
     }

    status = NFMverify_file_info (dst_file, &fbuff, &file_info);
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMverify_file_info : status = <0x%.8x>\n",
       status));
        xfer_buf_status.status2 = sys_buf_status.status2;
        xfer_buf_status.status3 = sys_buf_status.status3;
       return (NFM_E_BAD_SIZE_CI_FILENAME);

     }
     if(CHECKSUM)
     {
	if(checksum != checksum2)
	{
       		_NFMdebug ((fname,"SOURCE FILE <%s> CHECKSUM <%d> \t DESTINATION FILE <%s> CHECKSUM <%d> MISMATCH OCCURED\n", src_file, checksum, dst_file, checksum2));
		status = NFM_E_CHECKSUM_MISMATCH;
        	ERRload_struct(NFM,status,"%s%s",src_file, dst_file);
        	xfer_buf_status.status2 = sys_buf_status.status2;
        	xfer_buf_status.status3 = sys_buf_status.status3;
       		return (NFM_E_CHECKSUM_MISMATCH);
	}
     }

    *file_size = file_info.size;

    _NFMdebug((fname,"SUCCESSFUL:File size = <%d>: status = <0x%.8x>\n",*file_size,NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }

int NFMfile_receive (src_file, dst_file, attribute, file_size,NETid)
  char  *src_file;
  char  *dst_file;
  char  *attribute;
  int   *file_size;
  int   *NETid ;
  {
    char *fname="NFMfile_receive ";
    int     status2,status, x;
    FILE    *outfile = NULL;
    int     length, max_size, buffer_size,avail_disk_space,blk_file_size;
    long alloc_size;
    char    *buffer = NULL, *buf_ptr = NULL ;
    char    file_name [NFM_FILENAME];
    struct  stat           fbuff;

/* 12/17/92 - KT - SUN Port */
#ifdef OS_CLIX
    struct  statfs           sfsbuff;
#else
    struct  ustat            ufbuff;
#endif

    NFMbuffer_info buffer_info ;
    NFMfile_info   file_info;
    NFMstatus_buf  *buf_info_ptr;
    NFMfto_status  fto_status ,*fto_status_ptr;

    _NFMdebug ((fname,"Entry: Src File  = <%s> Dst File  <%s>\n Attribute <%s> \
 FIle Size <%d>\n ", src_file,dst_file,attribute,*file_size  ));

    alloc_size = buffer_size = max_size =  0 ;

    status = NFMget_full_name (dst_file, file_name);
    if (status != NFM_S_SUCCESS)
     {
/* Return error that COFILENAME is NULL */
       _NFMdebug ((fname,"Get File Name : status = <0x%.8x>", status));
       return (NFM_E_NO_CO_FILENAME);
     }

    status = NFMfopen_write (file_name, attribute, &outfile);
    if (status != NFM_S_SUCCESS)
     {
       fclose (outfile);
       _NFMdebug ((fname,"NFMfopen_write File :filename <%s>: status = <0x%.8x>\n", file_name,status));
	xfer_buf_status.status2 = errno ;
	return(NFM_E_FOPEN_WRITE_CO_FILENAME);
     }


    /*  Send a file request to the server  */

    buffer_info.size = 0;
    buffer_info.request = NFM_FILE_RECEIVE;

    length = buffer_info_size;

    status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:buffer_info.request = <%d>: status = <0x%.8x>\n",
       buffer_info.request,status));
       return(NFMnet_oper_fail_fs ( 0, outfile,file_name , status));
     }


/* Receive buffer_info from the server */
    status = NFMrecv_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMrecv_info: buffer_info: status <0x%.8x>\n",status));
       return(NFMnet_oper_fail_fs ( 0, outfile,file_name , status));
     }
/* Check the status of message buffer */
    if( buffer_info.request != NFM_S_FS_SEND_FILE_INFO )
    {
        _NFMdebug((fname,"Fileserver 2 is out of sync: status of FS2 <0x%.8x>\n"
,buffer_info.request));
        return(NFMnet_oper_fail_fs ( 0, outfile,file_name , buffer_info.request));

    }

    /*  Copy in the source filename  */

    strncpy (file_info.name, src_file, NFM_FILENAME);
    file_info.name [NFM_FILENAME] = '\0';
    file_info.attr [0] = '\0';

    file_info.size  = 0;
    file_info.mode  = 0;
    file_info.atime = 0;
    file_info.mtime = 0;

    /*  Send source filename  */

    length = file_info_size;

    status = NFMsend_info (NFMFILE_INFO, NETid, (char *) &file_info, &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:buffer_info.request = <%d>: status = <0x%.8x>\n",
       buffer_info.request,status));
       return(NFMnet_oper_fail_fs ( 0, outfile,file_name , status));
     }





    /*  Receive a reply   */


    status = NFMrecv_info (NFMFTO_STATUS, NETid, (char *) &fto_status,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMrecv_info: fto_status: status <0x%.8x>\n",status));
       return(NFMnet_oper_fail_fs ( 0, outfile,file_name , status));
     }

    if(fto_status.status != NFM_S_MALLOCED_SIZE)
     {
        _NFMdebug((fname,"Fileserver 2 is out of sync: status of FS2 <0x%.8x>\n",buffer_info.request));
        fclose(outfile);
	unlink(file_name);
	
        xfer_buf_status.status2 = fto_status.status2 ;
        xfer_buf_status.status3 = fto_status.status3 ;
	return(fto_status.status);
     }
    /*  Send a file request to the server  */

/* save the allocated size */
    max_size = buffer_info.size  ;

    buffer_info.size    = 0;
    buffer_info.request = NFM_S_FS_SEND_FILE_INFO;

    length = buffer_info_size;

    status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:buffer_info.request = <%d>: status = <0x%.8x>\n",
       buffer_info.request,status));
       return(NFMnet_oper_fail_fs ( 0, outfile,file_name , status));
     }


/* Receive file_info from the server */
    status = NFMrecv_info (NFMFILE_INFO, NETid, (char *) &file_info,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMrecv_info: file_info: status <0x%.8x>\n",status));
       return(NFMnet_oper_fail_fs ( 0, outfile,file_name , status));
     }

/* Check the available disk space */
/* 12/16/92 - KT - Changed 'Stat' to 'stat' */
    status = stat (file_name, &fbuff);
    if (status) /* OK */
     {
       fclose(outfile);
       unlink (file_name);
       status = NFM_E_STAT;
       _NFMdebug ((fname,"Stat Failed : filename <%s> errno <%d> status = <0x%.8x>\n", file_name,errno,status));
       ERRload_struct(NFM,status,"%s%x%d",file_name,status,errno);
       xfer_buf_status.status2 = errno;
       xfer_buf_status.status3 = 0;

       status2 = NFM_E_STAT_CO_FILENAME;
	status = _NFMsend_stat_buf((long *) NETid,status2,fname);
       if(status != NFM_S_SUCCESS) return(status);
       else return(status2);

     }

/* 12/17/92 - KT - SUN Port - Must use ustat on SUN */
#ifdef OS_CLIX
 status = statfs(file_name, &sfsbuff, sizeof(sfsbuff), 0);
    if (status) /* OK */
     {
       fclose(outfile);
       unlink (file_name);
       status2 = status = NFM_E_STATFS_CO_LOCATION;
       _NFMdebug ((fname,"statfs Failed : filename <%s> errno <%d> status = <0x%.8x>\n", file_name,errno,status));
       ERRload_struct(NFM,status,"%s%d",file_name,errno);
       xfer_buf_status.status2 = errno;
       xfer_buf_status.status3 = 0;
       status = _NFMsend_stat_buf((long *)NETid,status2,fname);
       if(status != NFM_S_SUCCESS) return(status);
       else return(status2);
     }
     avail_disk_space =  sfsbuff.f_bfree ;
#else
 status = ustat(fbuff.st_dev, &ufbuff);
    if (status) /* OK */
     {
       fclose(outfile);
       unlink (file_name);
       status2 = status = NFM_E_USTAT_CO_LOCATION;
       _NFMdebug ((fname,"ustat Failed : filename <%s> errno <%d> device <%d> status = <0x%.8x>\n", file_name,errno,fbuff.st_dev,status));
       ERRload_struct(NFM,status,"%s%d%d",file_name,fbuff.st_dev,errno);
       xfer_buf_status.status2 = errno;
       xfer_buf_status.status3 = fbuff.st_dev;
       status = _NFMsend_stat_buf((long *)NETid,status2,fname);
       if(status != NFM_S_SUCCESS) return(status);
       else return(status2);
     }
     avail_disk_space = ufbuff.f_tfree ;
#endif
     blk_file_size = file_info.size/BLKSIZ +1 ;
     if ( blk_file_size  >= avail_disk_space )
     {
       fclose(outfile);
       unlink (file_name);
       status2 = status = NFM_E_NO_SPACE_CO_LOCATION;
       _NFMdebug((fname,"No space available to write: filename <%s> : available disk space <%d> : file size <%d>\n",file_name,avail_disk_space,blk_file_size));
       ERRload_struct(NFM,status,"%s%d%d",file_name,avail_disk_space,blk_file_size);
       xfer_buf_status.status2 = avail_disk_space;
       xfer_buf_status.status3 = blk_file_size;
       status = _NFMsend_stat_buf((long *)NETid,status2,fname);
       if(status != NFM_S_SUCCESS) return(status);
       else return(status2);
     } 
       _NFMdebug((fname,"Space available to write is OK: filename <%s> : \
available disk space <%d> : file size <%d>\n",file_name,avail_disk_space,blk_file_size));


    /*  Allocate a buffer to read the file into  */
/* TEMPORARY SIZE */
        max_size = 10 * TCP_MAX_SIZE + buffer_info_size + NFM_FILENAME ;
	
	status = NFMmalloc(&buffer,max_size,&alloc_size);
	if(status != NFM_S_SUCCESS || alloc_size < status_buf_size )
     	{
		free ( buffer );
       		fclose (outfile);
		unlink(file_name);
       		_NFMdebug ((fname,"Malloc :size <%d>:Or Cannot get malloc size \
greater than status_buf_size <%d>: status = <0x%.8x>\n",max_size,status_buf_size, status));
       		ERRload_struct(NFM,NFM_E_MALLOC,"%d",max_size);
		status2 = NFM_E_MALLOC_TEMP_FS1;
                status = _NFMsend_stat_buf((long *)NETid,status2,fname);
                if(status != NFM_S_SUCCESS) return(status);
                else return(status2);
	}



/* save the pointer for free */
     buf_ptr = buffer ;
    /*  Send a file request to the server  */

    if (max_size > alloc_size )
	max_size = alloc_size - status_buf_size;
    else 
    	max_size = max_size - status_buf_size;
/* Communicate the size to be used to the other side */
    buffer_info.size = max_size ;
    buffer_info.request = NFM_S_FS2_USE_SIZE ;
    length = buffer_info_size;
    status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:file_info.filename = <%s>: status = <0x%.8x>\n",
       file_info.name,status));
       return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , status));
     }

    /*  Receive a reply from the server  */

    status = NFMrecv_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMrecv_info: buffer_info: status <0x%.8x>\n",status));
       return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , status));
     }
/* Check the status of message buffer */
    if( buffer_info.request != NFM_S_FS2_USING_SIZE )
    {
        _NFMdebug((fname,"Fileserver 2 is out of sync: status of FS2 <0x%.8x>\n",buffer_info.request));
       return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , buffer_info.request));

    }




    status2 = NFM_S_FS_FT_COMPLETE ;



    if (file_info.size > 0)
     {
       buffer_size = file_info.size; 
       x = 1;
       length = max_size+status_buf_size;
       buf_info_ptr =  (NFMstatus_buf *)buffer;
       buffer+=status_buf_size;

       while (buffer_size > max_size)
        {

    
          length = max_size+buffer_info_size;
          _NFMdebug ((fname,"Data Packet No   : <%d>  Size <%d>\n ", x  ,length   ));
          status = NFMrecv_info (NFMSTATUS_BUF, NETid, (char *)buf_info_ptr, 
                                 &length);
          if (status != NET_S_SUCCESS)
           {
             _NFMdebug((fname,"NFMrecv_info:buffer: size <%d>:buffer_size <%d> \
packet_no <%d>: status <0x%.8x>\n", length,buffer_size,x,status));
            return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , status));

           }

          buffer_size = buffer_size - max_size;

          x = x + 1;


	   if(buf_info_ptr->status != NFM_S_FS_SENT_BUFFER )
	   {
		_NFMdebug((fname,"FS2 is out of sync: status of FS2: <0x%.8x>\n", buf_info_ptr->status));
            fto_status_ptr =  (NFMfto_status *)buf_info_ptr;
            xfer_buf_status.status2 = fto_status_ptr->status2 ;
            xfer_buf_status.status3 = fto_status_ptr->status3 ;
	    
            return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , buf_info_ptr->status));
           }
           if(status2 != NFM_S_FS_FT_COMPLETE) continue;

          /*  Write the buffer out to the file  */


          length = max_size;
          status = fwrite (buffer, char_size, length, outfile);
          if (status != length)
           {
              _NFMdebug ((fname,"fwrite failed:filename <%s>:size1 <%d>: size2 \
<%d>:errno <%d>: status = <0x%.8x>\n",file_name,length,status,errno ,NFM_E_FWRITE));
              ERRload_struct(NFM,NFM_E_FWRITE,"%s%d%d%d",file_name,length,status,errno);
/* Tell the other side about errors and go to main */
               xfer_buf_status.status2 = length ;
               xfer_buf_status.status3 = status ;
               status2 =  NFM_E_FWRITE_CO_FILENAME;
           }

        }



       length = buffer_size + status_buf_size ;
       _NFMdebug ((fname,"Data Packet No   : <%d>  Size <%d>\n ", x  ,length   ));
       status = NFMrecv_info (NFMSTATUS_BUF, NETid, (char *)buf_info_ptr, 
                              &length);
       if (status != NET_S_SUCCESS)
        {
          _NFMdebug((fname,"NFMrecv_info:buffer: size <%d>:buffer_size <%d> \
packet_no <%d>: status <0x%.8x>\n", length,buffer_size,x,status));
            return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , status));

        }
	if(buf_info_ptr->status != NFM_S_FS_SENT_BUFFER )
        {
		_NFMdebug((fname,"FS2 is out of sync: status of FS2: <0x%.8x>\n", buf_info_ptr->status));
            fto_status_ptr =  (NFMfto_status *)buf_info_ptr;
            xfer_buf_status.status2 = fto_status_ptr->status2 ;
            xfer_buf_status.status3 = fto_status_ptr->status3 ;
            return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , buf_info_ptr->status));
         }

       /*  Write the buffer out to the file  */
        if(status2 == NFM_S_FS_FT_COMPLETE )
        {

       length = buffer_size;

       status = fwrite (buffer, char_size, length, outfile);
       if (status != length)
        {
          _NFMdebug ((fname,"fwrite failed:filename <%s>:size1 <%d>: size2 \
<%d>:errno <%d>: status = <0x%.8x>\n",file_name,length,status,errno ,NFM_E_FWRITE));
          ERRload_struct(NFM,NFM_E_FWRITE,"%s%d%d%d",file_name,length,status,errno);
          xfer_buf_status.status2 = length ;
          xfer_buf_status.status3 = status ;
          status2 =  NFM_E_FWRITE_CO_FILENAME;
        }
       }
     }

    free (buf_ptr);
    fflush (outfile);
    fclose (outfile);

        buffer_info.request = status2 ;
        length = buffer_info_size;
        status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, 
                               &length);
        if (status != NET_S_SUCCESS)
        {
          _NFMdebug ((fname,"NFMsend_info:file_info.filename = <%s>: status = <0x%.8x>\n",
       file_info.name,status));
          return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , status));
        }

    /*  Receive reply from the server  */


    status = NFMrecv_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMrecv_info:buffer_info : status = <0x%.8x>\n", status));
      return(NFMnet_oper_fail_fs ( 0, 0,file_name , status));
       
     }
    if(status2 != NFM_S_FS_FT_COMPLETE) 
     {
	_NFMdebug((fname,"NFM file transfer failed status2: <0x%.8x>\n",status2));
	unlink(file_name);
	return(status2);
     }

    status = buffer_info.request; 
    if (status != NFM_S_SUCCESS)
     {
       unlink (file_name);
       _NFMdebug ((fname,"buffer_info.request =  status = <0x%.8x>\n", status));
       ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","Receive at FS2:Status",status);
       return (NFM_E_CO_FILE_RECEIVE);
     }


    status = NFMset_file_mode (file_name, &file_info);
    if (status != NFM_S_SUCCESS)
     {
	xfer_buf_status.status2 = sys_buf_status.status2;
	xfer_buf_status.status3 = sys_buf_status.status3;
	switch(status)
	{
		case NFM_E_UTIME:
			status = NFM_E_SET_UTIME_CO_FILENAME;
			break;
		case NFM_E_CHMOD:
			status = NFM_E_SET_CHMOD_CO_FILENAME;
			break;
		case NFM_E_CHOWN:
			status = NFM_E_SET_CHOWN_CO_FILENAME;
			break;
	}
       unlink (file_name);
       _NFMdebug ((fname,"NFMset_file_mode : status = <0x%.8x>\n", status));
       return (status);
     }

    status = stat (file_name, &fbuff);
    if (status) /* OK */
     {
       unlink (file_name);
       status = NFM_E_STAT;
       _NFMdebug ((fname,"Stat Failed : filename <%s> errno <%d> status = <0x%.8x>\n", file_name,errno,status));
       ERRload_struct(NFM,status,"%s%x%d",file_name,status,errno);
       xfer_buf_status.status2 = errno;
       xfer_buf_status.status3 = 0;
       return (NFM_E_STAT_CO_FILENAME);
     }

    status = NFMverify_file_info (src_file, &fbuff, &file_info);
    if (status != NFM_S_SUCCESS)
     {
       unlink (file_name);
       _NFMdebug ((fname,"NFMverify_file_info : status = <0x%.8x>\n",
       status));
	xfer_buf_status.status2 = sys_buf_status.status2;
	xfer_buf_status.status3 = sys_buf_status.status3;
       return (NFM_E_BAD_SIZE_CO_FILENAME);
     }

    *file_size = fbuff.st_size;
    _NFMdebug((fname,"SUCCESSFUL:file_size <%d>: status <0x%.8x>\n",*file_size,NFM_S_SUCCESS));
    return(NFM_S_SUCCESS);

  }

int NFMfile_send_s (inpipe, outpipe)
  int   *inpipe;
  int   *outpipe;
  {
    char *fname="NFMfile_send_s";
    int     status, x,status2,avail_disk_space,blk_file_size;
    FILE    *outfile = NULL;
    int     length, max_buffer, buffer_size,new_size; 
    long alloc_size;
    char    *buffer = NULL , *buf_ptr = NULL ;
    char    file_name [NFM_FILENAME], dst_file [NFM_FILENAME];
    struct  stat            fbuff;

/* 12/17/92 - KT - SUN Port */
#ifdef OS_CLIX
    struct  statfs           sfsbuff;
#else
    struct  ustat            ufbuff;
#endif

    NFMfile_info   file_info;
    NFMbuffer_info   buffer_info;
    NFMstatus_buf  *buf_info_ptr;
    NFMfto_status	fto_status ;

    int checksum2;

    _NFMdebug ((fname," In  Pipe = <%d> Out Pipe = <%d>\n  ", *inpipe,*outpipe ));
    new_size = 0;

    buffer_info.request = NFM_S_FS_SEND_FILE_INFO ;

    if(CHECKSUM) /** perform checksum on the CHECKOUT FILE and SEND it to me **/
	strcpy(buffer_info.username, "CHECKSUM");

    length = buffer_info_size;
    status = NFMsend_info (NFMBUFFER_INFO, outpipe, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMsend_info:buffer_info:size <%d>:request: <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,buffer_info.request,status));
/* Exit will be done by calling program  */
	return(NFMnet_oper_fail_fs(0,0,0,status));
     }
	

    status = NFMrecv_info (NFMFILE_INFO, inpipe, (char *) &file_info, &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMrecv_info:file_info: status = <0x%.8x>\n", status));
	return(NFMnet_oper_fail_fs(0,0,0,status));
     }


    strcpy (dst_file, file_info.name);

    status = NFMget_full_name (dst_file, file_name);
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMget_full_name: file_name <%s>: status <0x%.8x>\n",
dst_file,status));
       return(NFM_E_NO_CI_FILENAME);
     }

    if(strlen(file_info.platter) > 0 )
    {
      status = stat (file_name, &fbuff);
      if (status == 0 ) /* File exists locally  */
      {
        status = NFM_E_CI_FILENAME_EXISTS;
       _NFMdebug ((fname,"Stat Succeeded : Check in file : filename <%s> exists locally: status <0x%.8x>\n", file_name,status));
       fto_status.status = NFM_E_CI_FILENAME_EXISTS;
       fto_status.status2 = 0 ;
       fto_status.status3 = 0 ;
       length = fto_status_size;
       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
           _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
       fto_status.status,status));
           return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
       }
       return(NFM_S_FS2_REPLY_SENT);

     }

    }

    if(strncmp(file_info.partition, "SUM", 3) == 0 )
    {
	CHECKSUM = 1;
    }

/* Change mode of the file so that we can write to it */
    status = NFMchmod(file_name,0777);

    status = NFMfopen_write (file_name, file_info.attr, &outfile);
    if (status != NFM_S_SUCCESS)
     {
       fclose (outfile);
       _NFMdebug ((fname," NFMfopen_write: File :file_name <%s>: status = <0x%.8x>\n", file_name,status));
	xfer_buf_status.status2 = errno ;
       return (NFM_E_FOPEN_WRITE_CI_FILENAME);
     }
/* Check the available disk space */
    status = stat (file_name, &fbuff);
    if (status) /* OK */
     {
       fclose(outfile);
       unlink (file_name);
       status = NFM_E_STAT;
       _NFMdebug ((fname,"Stat Failed : filename <%s> errno <%d> status = <0x%.8x>\n", file_name,errno,status));
       ERRload_struct(NFM,status,"%s%x%d",file_name,status,errno);
       fto_status.status = NFM_E_STAT_CI_FILENAME;
       fto_status.status2 = errno ;
       fto_status.status3 = 0 ;
       length = fto_status_size;
       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
           _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
       fto_status.status,status));
           return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
       }
       return(NFM_S_FS2_REPLY_SENT);

/*
       xfer_buf_status.status2 = errno;
       xfer_buf_status.status3 = 0;
       status = NFM_E_STAT_CI_FILENAME;
       return(status);
*/
     }

/* 12/17/92 - KT - SUN Port - Must use ustat on SUN */
#ifdef OS_CLIX
    status = statfs(file_name, &sfsbuff, sizeof(sfsbuff), 0);
    if (status) /* OK */
     {
       fclose(outfile);
       unlink (file_name);
       status = NFM_E_STATFS_CI_LOCATION;
       _NFMdebug ((fname,"statfs Failed : filename <%s> errno <%d> status = <0x%.8x>\n", file_name,errno,status));
       ERRload_struct(NFM,status,"%s%d",file_name,errno);
       fto_status.status = NFM_E_STATFS_CI_LOCATION;
       fto_status.status2 = errno ;
       fto_status.status3 = 0;
       length = fto_status_size;
       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
           _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
       fto_status.status,status));
           return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
       }
       return(NFM_S_FS2_REPLY_SENT);
/*
       xfer_buf_status.status2 = errno;
       xfer_buf_status.status3 = fbuff.st_dev;
       return(status);
*/
     }
     avail_disk_space =  sfsbuff.f_bfree ;
#else
    status = ustat(fbuff.st_dev, &ufbuff);
    if (status) /* OK */
     {
       fclose(outfile);
       unlink (file_name);
       status = NFM_E_USTAT_CI_LOCATION;
       _NFMdebug ((fname,"ustat Failed : filename <%s> errno <%d> device <%d> status = <0x%.8x>\n", file_name,errno,fbuff.st_dev,status));
       ERRload_struct(NFM,status,"%s%d%d",file_name,fbuff.st_dev,errno);
       fto_status.status = NFM_E_USTAT_CI_LOCATION;
       fto_status.status2 = errno ;
       fto_status.status3 = fbuff.st_dev;
       length = fto_status_size;
       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
           _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
       fto_status.status,status));
           return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
       }
       return(NFM_S_FS2_REPLY_SENT);
/*
       xfer_buf_status.status2 = errno;
       xfer_buf_status.status3 = fbuff.st_dev;
       return(status);
*/
     }
     avail_disk_space = ufbuff.f_tfree ;
#endif
     blk_file_size = file_info.size/BLKSIZ + 1;

     if ( blk_file_size  >= avail_disk_space )
     {
       fclose(outfile);
       unlink (file_name);
       status = NFM_E_NO_SPACE_CI_LOCATION;
       _NFMdebug((fname,"No space available to write: filename <%s> : available disk space <%d> : file size <%d>\n",file_name,avail_disk_space,blk_file_size));
       ERRload_struct(NFM,status,"%s%d%d",file_name,avail_disk_space,blk_file_size);
       fto_status.status = NFM_E_NO_SPACE_CI_LOCATION;
       fto_status.status2 = avail_disk_space ;
       fto_status.status3 = blk_file_size ;
       length = fto_status_size;
       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
           _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
       fto_status.status,status));
           return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
       }
       return(NFM_S_FS2_REPLY_SENT);
/*
       xfer_buf_status.status2 = avail_disk_space;
       xfer_buf_status.status3 = file_info.size;
       return(status);
*/
     } 
     _NFMdebug((fname,"Space available to write is OK: filename <%s> : \
available disk space <%d> : file size <%d>\n",file_name,avail_disk_space,blk_file_size));


 /*  Allocate a buffer to read the file into  */
/*
     new_size = file_info.size +  buffer_info_size + NFM_FILENAME ;
*/
     new_size = 10* TCP_MAX_SIZE +  status_buf_size + NFM_FILENAME ;
	
        status = NFMmalloc(&buffer,new_size,&alloc_size);
	if(status != NFM_S_SUCCESS || alloc_size < status_buf_size )
     	{
		free(buffer);
       		fclose (outfile);
                unlink(file_name);
       		_NFMdebug ((fname,"Malloc :size <%d>:Or Cannot get malloc size \
greater than status_buf_size <%d>: status = <0x%.8x>\n",new_size,status_buf_size, status));
       		status = NFM_E_MALLOC;
       		ERRload_struct(NFM,status,"%d",new_size);
       		fto_status.status = NFM_E_MALLOC_TEMP_FS2;
       		fto_status.status2 = new_size ;
       		fto_status.status3 = 0 ;
    		length = fto_status_size;
       		status = NFMsend_info (NFMFTO_STATUS, outpipe, 
                                       (char *) &fto_status, &length);
       		if (status != NET_S_SUCCESS)
       		{
           		_NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
       			fto_status.status,status));
           		return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
       		}
       		return(NFM_S_FS2_REPLY_SENT);
/*
       		return (NFM_E_MALLOC_TEMP_FS2);
*/
	}

        buf_ptr = buffer ;


/* Send back the allocated size in buffer_info to client */
    fto_status.status = NFM_S_MALLOCED_SIZE ;
    fto_status.status2 = alloc_size;

    length = fto_status_size ;

    status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMsend_info:fto_status:size <%d>:request: <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,fto_status.status,status));
       return(NFMnet_oper_fail_fs(buf_ptr,outfile,file_name,status));
     }
/* Receive the size to be used for file transfer  and acknowledge it */

    status = NFMrecv_info (NFMBUFFER_INFO, inpipe, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMrecv_info:buffer_info: status = <0x%.8x>\n", status));
       return(NFMnet_oper_fail_fs(buf_ptr,outfile,file_name,status));
     }

    if( buffer_info.request != NFM_S_FS2_USE_SIZE )
    {
       status = NFM_E_FS2_ERROR ;
       _NFMdebug((fname,"NFMrecv_info:buffer_info.request <0x%.8x>: status <0x%.8x>\n",buffer_info.request,status));
       return(NFMnet_oper_fail_fs(buf_ptr,outfile,file_name,buffer_info.request));

    }
    new_size = buffer_info.size;
    buffer_info.request = NFM_S_FS2_USING_SIZE;
    _NFMdebug((fname,"new_size = <%d> file_info.size <%d>\n",new_size,file_info.size));

    length = buffer_info_size ;
    status = NFMsend_info (NFMBUFFER_INFO, outpipe, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMsend_info:buffer_info:size <%d>:request: <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,buffer_info.request,status));
/* Exit will be done by calling program  */
       return(NFMnet_oper_fail_fs(buf_ptr,outfile,file_name,status));
     }

	


    status2 = NFM_S_FS_FT_COMPLETE ;
    if (file_info.size > 0)
     {
       max_buffer = new_size; 
       buffer_size = file_info.size;
       x = 1;

       buf_info_ptr = (NFMstatus_buf *)buffer ;
       buffer+=status_buf_size;
       length = max_buffer+status_buf_size;
       while (buffer_size > max_buffer)
        {
          _NFMdebug ((fname," Data Packet No   : <%d>  Size : <%d>\n ", x ,length    ));

          status = NFMrecv_info (NFMSTATUS_BUF, inpipe, (char *)(buf_info_ptr),
                                 &length);
          if (status != NET_S_SUCCESS)
           {
             _NFMdebug((fname,"NFMrecv_info:buffer: size <%d>:buffer_size <%d> \
packet_no <%d>: status <0x%.8x>\n", length,buffer_size,x,status));
              return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , status));

           }
/* If error has occured quit  wasting time */
          buffer_size = buffer_size - max_buffer;
          x = x + 1;

	  if(status2 != NFM_S_FS_FT_COMPLETE ) continue;

          if(buf_info_ptr->status != NFM_S_FS_SENT_BUFFER )
	   {
                _NFMdebug((fname,"Fileserver 1 is out of sync: status of FS2 <0x%.8x>\n",buf_info_ptr->status));
                return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , buf_info_ptr->status));
	   }
   

          status = fwrite (buffer, char_size, max_buffer, outfile);
          if (status != max_buffer)
           {
              _NFMdebug ((fname,"fwrite failed:filename <%s>:size1 <%d>: size2 \
<%d>:errno <%d>: status = <0x%.8x>\n",file_name,max_buffer,status,errno ,NFM_E_FWRITE));
              ERRload_struct(NFM,NFM_E_FWRITE,"%s%d%d%d",file_name,max_buffer,status,errno);
              xfer_buf_status.status2 = max_buffer ;
              xfer_buf_status.status3 = status ;
              status2 =  NFM_E_FWRITE_CI_FILENAME;

           }

        }

       length = buffer_size+buffer_info_size;

       _NFMdebug ((fname," Data Packet No   : <%d>  Size : <%d>\n ", x ,length    ));
       status = NFMrecv_info (NFMSTATUS_BUF, inpipe, (char *)(buf_info_ptr), 
                              &length);
       if (status != NET_S_SUCCESS)
        {
             _NFMdebug((fname,"NFMrecv_info:buffer: size <%d>:buffer_size <%d> \
packet_no <%d>: status <0x%.8x>\n", length,buffer_size,x,status));
              return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , status));
        }

	if(status2 == NFM_S_FS_FT_COMPLETE)
	{
         if(buf_info_ptr->status != NFM_S_FS_SENT_BUFFER )
	 {
              _NFMdebug((fname,"Fileserver 1 is out of sync: status of FS2 <0x%.8x>\n",buf_info_ptr->status));
              return(NFMnet_oper_fail_fs ( buf_ptr, outfile,file_name , buf_info_ptr->status));
	 }
   
       /*  Write the buffer out to the file  */

          length = buffer_size;

         status = fwrite (buffer, char_size , length, outfile);
         if (status != length)
          {
          _NFMdebug ((fname,"fwrite failed:filename <%s>:size1 <%d>: size2 \
<%d>:errno <%d>: status = <0x%.8x>\n",file_name,length,status,errno ,NFM_E_FWRITE));
          ERRload_struct(NFM,NFM_E_FWRITE,"%s%d%d%d",file_name,length,status,errno);
          xfer_buf_status.status2 = length ;
          xfer_buf_status.status3 = status ;
          status2 = NFM_E_FWRITE_CI_FILENAME;
          }
        }
     }

    free (buf_ptr);
    fflush (outfile);
    fclose (outfile);
    if(status2 != NFM_S_FS_FT_COMPLETE)
    {
	unlink(file_name);
       _NFMdebug ((fname,"NFMfile transfer : status = <0x%.8x>\n", status2));
       fto_status.status = status2 ;
       fto_status.status2 = xfer_buf_status.status2;
       fto_status.status3 = xfer_buf_status.status3;

       length = fto_status_size;

       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
          _NFMdebug((fname,"NFMsend_info:fto_status:size <%d>:request: <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,fto_status.status,status));
          return(NFMnet_oper_fail_fs(0,0,0,status));
       }
       return (NFM_S_FS2_REPLY_SENT);
    }

    status = NFMset_file_mode (file_name, &file_info);
    if (status != NFM_S_SUCCESS)
     {
	xfer_buf_status.status2 = sys_buf_status.status2;
	xfer_buf_status.status3 = sys_buf_status.status3;
	switch(status)
	{
		case NFM_E_UTIME:
			status = NFM_E_SET_UTIME_CI_FILENAME;
			break;
		case NFM_E_CHMOD:
			status = NFM_E_SET_CHMOD_CI_FILENAME;
			break;
		case NFM_E_CHOWN:
			status = NFM_E_SET_CHOWN_CI_FILENAME;
			break;
	}
       unlink (file_name);       
       _NFMdebug ((fname,"NFMset_file_mode : status = <0x%.8x>\n", status));
       fto_status.status = status ;
       fto_status.status2 = xfer_buf_status.status2;
       fto_status.status3 = xfer_buf_status.status3;

       length = fto_status_size;

       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
          _NFMdebug((fname,"NFMsend_info:fto_status:size <%d>:request: <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,fto_status.status,status));
          return(NFMnet_oper_fail_fs(0,0,0,status));
       }
       return (NFM_S_FS2_REPLY_SENT);
     }

    status = stat (file_name, &fbuff);
    if (status) /* OK */
     {
       unlink (file_name);       
       status = NFM_E_STAT;
       _NFMdebug ((fname,"Stat Failed : filename <%s> errno <%d> status = <0x%.8x>\n", file_name,errno,status));
       ERRload_struct(NFM,status,"%s%x%d",file_name,status,errno);
/*
       xfer_buf_status.status2 = errno ;
*/
       fto_status.status = NFM_E_STAT_CI_FILENAME ;
       fto_status.status2 = errno;
       fto_status.status3 = 0;

       length = fto_status_size;

       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
          _NFMdebug((fname,"NFMsend_info:fto_status:size <%d>:request: <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,fto_status.status,status));
          return(NFMnet_oper_fail_fs(0,0,0,status));
       }
       return (NFM_S_FS2_REPLY_SENT);
     }

    _NFMdebug((fname,"File Size = <%d> Mode = <%d> Atime = <%d> Mtime = <%d>\n",
fbuff.st_size, fbuff.st_mode,fbuff.st_atime,fbuff.st_mtime));

    status = NFMverify_file_info (dst_file, &fbuff, &file_info);
    if (status != NFM_S_SUCCESS)
     {
       unlink (file_name);       
       _NFMdebug ((fname,"NFMverify_file_info : status = <0x%.8x>\n",
       status));
       fto_status.status = NFM_E_BAD_SIZE_CI_FILENAME ;
       fto_status.status2 = 0;
       fto_status.status3 = 0;

       length = fto_status_size ;

       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status,
                              &length);
       if (status != NET_S_SUCCESS)
       {
          _NFMdebug((fname,"NFMsend_info:fto_status:size <%d>:request: <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,fto_status.status,status));
          return(NFMnet_oper_fail_fs(0,0,0,status));
       }
       return (NFM_S_FS2_REPLY_SENT);

     }
    fto_status.status = NFM_S_FS_FT_COMPLETE ;

    length = fto_status_size;

    status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMsend_info:fto_status:size <%d>: status <0x%.8x>\n",length,status));
       return(NFMnet_oper_fail_fs(0,0,file_name,status));
     }

    file_info.size  = fbuff.st_size;
    file_info.mode  = fbuff.st_mode;
    file_info.atime = fbuff.st_atime;
    file_info.mtime = fbuff.st_mtime;
    _NFMdebug((fname,"File_name = <%s> Attr = <%s> Size = <%d>\n Mode = <%d> Atime = <%d> Mtime = <%d>\n",
file_info.name,file_info.attr,file_info.size,file_info.mode,file_info.atime,file_info.mtime));
    status = NFMrecv_info (NFMBUFFER_INFO, inpipe, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMrecv_info:file_info: status = <0x%.8x>\n", status));
       return(NFMnet_oper_fail_fs(0,0,file_name,status));
     }

    if( buffer_info.request != NFM_S_FS_SEND_FILE_INFO )
    {
       status = NFM_E_FS2_ERROR ;
       _NFMdebug((fname,"NFMrecv_info:buffer_info.request <0x%.8x>: status <0x%.8x>\n",buffer_info.request,status));
       return(NFMnet_oper_fail_fs(0,0,file_name,buffer_info.request));

    }


    if(CHECKSUM)
    {
	status = NFMcheck_sum(file_name, &checksum2);
	if(status != NFM_S_SUCCESS)
		checksum2 = -1;
	
	sprintf(file_info.partition, "%d", checksum2);
       _NFMdebug ((fname,"FS2: sending check sum for file <%s>: <%d>\n",
					file_name, checksum2));
    }
    length = file_info_size;

    status = NFMsend_info (NFMFILE_INFO, outpipe, (char *) &file_info, &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:file_info:file_name <%s>:status = <0x%.8x>\n",file_info.name, status));
       return(NFMnet_oper_fail_fs(0,0,file_name,status));
     }

    _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }

int NFMfile_receive_s (inpipe, outpipe)
  int   *inpipe;
  int   *outpipe;
  {
    char *fname="NFMfile_receive_s ";
    int     status, x;
    FILE    *infile = NULL;
    int     length, max_buffer, buffer_size,new_size; 
    long alloc_size;
    char    *buffer = NULL , *buf_ptr = NULL ;
    char    file_name [4*NFM_FILENAME];
    struct  stat           fbuff;
    NFMbuffer_info buffer_info;
    NFMstatus_buf  *buf_info_ptr;
    NFMfile_info   file_info;
    NFMfto_status  fto_status ;

    _NFMdebug ((fname," In  Pipe = <%d> Outpipe = <%d>\n  ", *inpipe,*outpipe ));
    buffer_info.request = NFM_S_FS_SEND_FILE_INFO ;
    length = buffer_info_size;
    status = NFMsend_info (NFMBUFFER_INFO, outpipe, (char *) &buffer_info,
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMsend_info:buffer_info:size <%d>:request: <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,buffer_info.request,status));
/* Exit will be done by calling program  */
        return(NFMnet_oper_fail_fs(0,0,0,status));
     }


    /*  Get the file name from the client  */


    status = NFMrecv_info (NFMFILE_INFO, inpipe, (char *) &file_info, &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMrecv_info:file_info : status = <0x%.8x>\n", status));
       return(NFMnet_oper_fail_fs(0,0,0,status));
     }
   
    status = NFMget_full_name (file_info.name, file_name);
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMget_full_name :filename <%s>: status = <0x%.8x>\n", file_info.name,status));
       fto_status.status = NFM_E_NO_CI_FILENAME;
       fto_status.status2 = 0 ;
       fto_status.status3 = 0 ;
       length = fto_status_size;
       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
           _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
       fto_status.status,status));
           return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
       }
       return(NFM_S_FS2_REPLY_SENT);
/*
       return (NFM_E_NO_CI_FILENAME);
*/
     }
     
    /*  Get file info about the file  */

    status = stat (file_name, &fbuff);
    if (status) /* OK */
     {
       status = NFM_E_STAT;
       _NFMdebug ((fname,"Stat Failed : filename <%s> status = <0x%.8x> errno  = <%d>\n",file_name,status, errno ));
       ERRload_struct(NFM,status,"%s%x%d",file_name,status,errno);
/* Return error that stat failed for CIFILENAME */
       xfer_buf_status.status2 = errno;
       fto_status.status = NFM_E_STAT_CI_FILENAME;
       fto_status.status2 = errno ;
       fto_status.status3 = 0 ;
       length = fto_status_size;
       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
           _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
       fto_status.status,status));
           return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
       }
       return(NFM_S_FS2_REPLY_SENT);
/*
       return (NFM_E_STAT_CI_FILENAME);
*/
     }
    file_info.size  = fbuff.st_size;
    file_info.mode  = fbuff.st_mode;
    file_info.atime = fbuff.st_atime;
    file_info.mtime = fbuff.st_mtime;
 
    infile = fopen (file_name, "r");
    if (! infile)
     {
       status = NFM_E_FOPEN;
       _NFMdebug((fname,"fopen failed : filename <%s>: errno <%d> type <%s> \
:status <0x%.8x>\n",file_name,errno,"r",status));
       ERRload_struct(NFM,status,"%s%d%s",file_name,errno,"r");
/* Return appropriate error to send back to server */
       fto_status.status = NFM_E_FOPEN_READ_CI_FILENAME;
       fto_status.status2 = errno ;
       fto_status.status3 = 0 ;
       length = fto_status_size;
       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
           _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
       fto_status.status,status));
           return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
       }
       return(NFM_S_FS2_REPLY_SENT);
/*
       return (NFM_E_FOPEN_READ_CI_FILENAME);
*/
     }


 /*  Allocate a buffer to read the file into  */
/*
     new_size = file_info.size +  buffer_info_size + NFM_FILENAME ;
*/
     new_size = 10* TCP_MAX_SIZE +  buffer_info_size + NFM_FILENAME ;
	
        status = NFMmalloc(&buffer,new_size,&alloc_size);
	if(status != NFM_S_SUCCESS || alloc_size < status_buf_size )
     	{
		free(buffer);
       		fclose (infile);
       		_NFMdebug ((fname,"Malloc :size <%d>:Or Cannot get malloc size \
greater than status_buf_size <%d>: status = <0x%.8x>\n",new_size,status_buf_size, status));
       		status = NFM_E_MALLOC;
       		ERRload_struct(NFM,status,"%d",new_size);
       		fto_status.status = NFM_E_MALLOC_TEMP_FS2;
	        fto_status.status2 = new_size ;
	        fto_status.status3 = 0 ;
	        length = fto_status_size;
	        status = NFMsend_info (NFMFTO_STATUS, outpipe, 
                                       (char *) &fto_status, &length);
 	       if (status != NET_S_SUCCESS)
      	  	{
                  _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
                  fto_status.status,status));
                  return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
                }
                return(NFM_S_FS2_REPLY_SENT);
/*
       		return (NFM_E_MALLOC_TEMP_FS2);
*/
	}

        buf_ptr = buffer ;


/* Send back the allocated size in buffer_info to client */
    fto_status.status = NFM_S_MALLOCED_SIZE ;
    fto_status.status2 = alloc_size;

    length = fto_status_size;

    status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMsend_info:fto_status:size <%d>: status <0x%.8x>\n",length,status));
       return(NFMnet_oper_fail_fs(buf_ptr,infile,0,status));
     }
/* Receive the size to be used for file transfer  and acknowledge it */
    length = buffer_info_size;

    status = NFMrecv_info (NFMBUFFER_INFO, inpipe, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMrecv_info:file_info: status = <0x%.8x>\n", status));
       return(NFMnet_oper_fail_fs(buf_ptr,infile,0,status));
     }

    if( buffer_info.request != NFM_S_FS_SEND_FILE_INFO )
    {
       status = NFM_E_FS2_ERROR ;
       _NFMdebug((fname,"NFMrecv_info:buffer_info.request <0x%.8x>: status <0x%.8x>\n",buffer_info.request,status));
       return(NFMnet_oper_fail_fs(buf_ptr,infile,0,buffer_info.request));

    }
    length = file_info_size;
    status = NFMsend_info (NFMFILE_INFO, outpipe, (char *) &file_info, &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMsend_info:file_info:size <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,status));
/* Exit will be done by calling program  */
       return(NFMnet_oper_fail_fs(buf_ptr,infile,0,status));
     }

	

/* Receive the size to be used for file transfer  and acknowledge it */
    length = buffer_info_size;

    status = NFMrecv_info (NFMBUFFER_INFO, inpipe, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMrecv_info:file_info: status = <0x%.8x>\n", status));
       return(NFMnet_oper_fail_fs(buf_ptr,infile,0,status));
     }

    if( buffer_info.request != NFM_S_FS2_USE_SIZE )
    {
       status = NFM_E_FS2_ERROR ;
       _NFMdebug((fname,"NFMrecv_info:buffer_info.request <0x%.8x>: status <0x%.8x>\n",buffer_info.request,status));
       return(NFMnet_oper_fail_fs(buf_ptr,infile,0,buffer_info.request));

    }
    new_size = buffer_info.size;
    buffer_info.request = NFM_S_FS2_USING_SIZE;
    _NFMdebug((fname,"new_size = <%d> file_info.size <%d>\n",new_size,file_info.size));

    length = buffer_info_size;
    status = NFMsend_info (NFMBUFFER_INFO, outpipe, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMsend_info:buffer_info:size <%d>:request: <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,buffer_info.request,status));
/* Exit will be done by calling program  */
       return(NFMnet_oper_fail_fs(buf_ptr,infile,0,status));
     }

	



     max_buffer = new_size ;
    if (file_info.size > 0)
     {
        buffer_size = file_info.size;
        x = 1;
        buf_info_ptr = (NFMstatus_buf *)buffer ;
        buffer+=status_buf_size;
        length = max_buffer+status_buf_size;
        buf_info_ptr->status = NFM_S_FS_SENT_BUFFER ;


        while (buffer_size > max_buffer)
         {

           status = fread (buffer, char_size , max_buffer, infile);
           if (status != max_buffer)
            {
              free (buffer);
              fclose (infile);
             _NFMdebug ((fname,"fread failed:filename <%s>:size1 <%d>: size2 \
<%d>:errno <%d>: status = <0x%.8x>\n",file_name,max_buffer,status,errno ,NFM_E_FREAD));
             ERRload_struct(NFM,NFM_E_FREAD,"%s%d%d%d",file_name,max_buffer,status,errno);
/*
	     xfer_buf_status.status2 = max_buffer ;
	     xfer_buf_status.status3 = status ;
*/
       		fto_status.status = NFM_E_FREAD_CI_FILENAME;
	        fto_status.status2 = max_buffer ;
	        fto_status.status3 = status ;
	        length = fto_status_size;
	        status = NFMsend_info (NFMFTO_STATUS, outpipe, 
                                       (char *) &fto_status, &length);
 	       if (status != NET_S_SUCCESS)
      	  	{
                  _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
                  fto_status.status,status));
                  return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
                }
                return(NFM_S_FS2_REPLY_SENT);
/*
             return (NFM_E_FREAD_CI_FILENAME);
*/
            }

           _NFMdebug ((fname,"Data Packet No   : <%d>  Size = <%d>\n ", x,length     ));

           status = NFMsend_info (NFMSTATUS_BUF, outpipe, (char *)buf_info_ptr,
                                  &length);
           if (status != NET_S_SUCCESS)
            {
             _NFMdebug((fname,"NFMsend_info:buffer: size <%d>:buffer_size <%d> \
packet_no <%d>: status <0x%.8x>\n", length,buffer_size,x,status));
             return(NFMnet_oper_fail_fs(buf_ptr,infile,0,status));

            }

           buffer_size = buffer_size - max_buffer;
           x = x + 1;

         }

        /*  Read the file into a buffer  */



        status = fread (buffer, char_size, buffer_size, infile);
        if (status != buffer_size)
         {
           free (buffer);
           fclose (infile);
             _NFMdebug ((fname,"fread failed:filename <%s>:size1 <%d>: size2 \
<%d>:errno <%d>: status = <0x%.8x>\n",file_name,buffer_size,status,errno ,NFM_E_FREAD));
             ERRload_struct(NFM,NFM_E_FREAD,"%s%d%d%d",file_name,buffer_size,status,errno);
	     xfer_buf_status.status2 = buffer_size ;
	     xfer_buf_status.status3 = status ;
       		fto_status.status = NFM_E_FREAD_CI_FILENAME;
	        fto_status.status2 = buffer_size ;
	        fto_status.status3 = status ;
	        length = fto_status_size;
	        status = NFMsend_info (NFMFTO_STATUS, outpipe, 
                                       (char *) &fto_status, &length);
 	       if (status != NET_S_SUCCESS)
      	  	{
                  _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
                  fto_status.status,status));
                  return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
                }
                return(NFM_S_FS2_REPLY_SENT);
/*
             return (NFM_E_FREAD_CI_FILENAME);
*/
         }

        /*  Send the file buffer to the server  */
   
/*MVV - PDM identified file transfer problem. Dt 01/Sep/1997
        length = buffer_size + buffer_info_size;
*/
           _NFMdebug ((fname,"Data Packet No   : <%d>  Size = <%d>\n ", x,length     ));

        status = NFMsend_info (NFMSTATUS_BUF, outpipe, (char *)buf_info_ptr, 
                               &length);
        if (status != NET_S_SUCCESS)
         {
             _NFMdebug((fname,"NFMsend_info:buffer: size <%d>:buffer_size <%d> \
packet_no <%d>: status <0x%.8x>\n", length,buffer_size,x,status));
       return(NFMnet_oper_fail_fs(buf_ptr,infile,0,status));

         }
      }

     free (buf_ptr);
     fclose (infile);

         length = buffer_info_size;

         status = NFMrecv_info (NFMBUFFER_INFO, inpipe, (char *) &buffer_info,
                                &length);
         if (status != NET_S_SUCCESS)
         {
           _NFMdebug ((fname,"NFMrecv_info:file_info: status = <0x%.8x>\n", status));
           return(NFMnet_oper_fail_fs(buf_ptr,infile,0,status));
         }

         if( buffer_info.request != NFM_S_FS_FT_COMPLETE )
         {
           status = buffer_info.request ;
           _NFMdebug((fname,"NFMrecv_info:buffer_info.request <0x%.8x>: status <0x%.8x>\n",buffer_info.request,status));
           return(NFMnet_oper_fail_fs(buf_ptr,infile,0,buffer_info.request));

         }
     /* receive the no of bytes received. */

/*
     length = buffer_info_size;

     buffer_info.size = 0;
     buffer_info.request = NFM_S_SUCCESS;

     status = NFMsend_info (NFMBUFFER_INFO, outpipe, (char *) &buffer_info, 
                            &length);
     if (status != NET_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMsend_info:buffer_info.request: <0x%.8x>: status = <0x%.8x>\n", buffer_info.request,status));
       return(NFMnet_oper_fail_fs(buf_ptr,infile,0,status));
      }
*/
     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
  }

int NFMswitch_disconnect(type,NETid)
        int type , *NETid;
{
	char *fname="NFMswitch_disconnect";
	int status;
        status = NFM_S_SUCCESS;
	_NFMdebug((fname,"Entry> type <%d> *NETid <%d>\n",type,*NETid));
        switch(type)
        {
                case TLI_MC:
                        status = NFMdisconnect(NETid);
                        break;
                case FMU_MC:
                        status = NETfmu_disconnect();
			if(status !=NET_S_SUCCESS)
			{
				_NFMdebug((fname,"NETfmu_disconnect:status <0x%.8x>\n",status));
				ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NETfmu_disconnect",status);
				status = NFM_E_FAILURE;
			}
			else status = NFM_S_SUCCESS ;
                        break;
        }
        _NFMdebug((fname,"Exit: status <0x%.8x>\n",status));
        return(status);
}


/***************************
*/


int NFMfile_copy (src_file, dst_file,attribute, delete_src_flag,NETid)
  char  *src_file;
  char  *dst_file;
  char *attribute;
  int delete_src_flag;
  int   *NETid;
  {
    char *fname="NFMfile_copy";
    int     status;
    int     length;
    NFMbuffer_info  buffer_info;
    NFMcp_buffer    cp_buffer;
    NFMfto_status	fto_status ;


    _NFMdebug ((fname,"Entry: Src File  = <%s> Dst File  <%s>\n delete_src_flag <%d> \
 *NETid  <%d>\n ", src_file,dst_file,delete_src_flag,*NETid  ));

    buffer_info.size    = 0;
    buffer_info.request = NFM_FILE_COPY;

    length = buffer_info_size;
    status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:buffer_info.request = <%d>: status = <0x%.8x>\n",
       buffer_info.request,status));
       return(NFMnet_oper_fail_fs(0,0,0,status));
     }

/* Receive buffer_info from the server */
    status = NFMrecv_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info,
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

    status = NFMsend_info (NFMCP_BUFFER, NETid, (char *) &cp_buffer, &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMsend_info:cp_buffer:src file = <%s>:\
dst_file <%s> : attribute <%s> : delete_src_flag <%d>\n",cp_buffer.src_name,
cp_buffer.dst_name,cp_buffer.attr,cp_buffer.delete_src_flag));
       return(NFMnet_oper_fail_fs(0,0,0,status));
     }


    length = fto_status_size;

    status = NFMrecv_info (NFMFTO_STATUS, NETid, (char *) &fto_status,
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

int NFMfile_copy_s (inpipe, outpipe)
  int   *inpipe;
  int   *outpipe;
{
    char *fname="NFMfile_copy_s";
    int     status,status1;
    int     length,size; 
    NFMbuffer_info buffer_info;
    NFMcp_buffer   cp_buffer;
    NFMfto_status fto_status ;
    char src_file[4*NFM_FILENAME],dst_file[4*NFM_FILENAME],attribute[4*NFM_FILENAME];
    long delete_src_flag;

    _NFMdebug ((fname," In  Pipe = <%d> Outpipe = <%d>\n  ", *inpipe,*outpipe ));

    buffer_info.request = NFM_S_FS_SEND_CP_BUFFER ;
    length = buffer_info_size;
    status = NFMsend_info (NFMBUFFER_INFO, outpipe, (char *) &buffer_info, 
                           &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug((fname,"NFMsend_info:buffer_info:size <%d>:request: <%d>:\
 status <0x%.8x>\n FS2 Exiting due to severe error",length,buffer_info.request,status));
/* Exit will be done by calling program  */
	return(NFMnet_oper_fail_fs(0,0,0,status));
     }
	

    length = cp_buffer_size;

    /*  Get the file name from the client  */

    size = 0;
    status1 = NFM_S_SUCCESS ;

    status = NFMrecv_info (NFMCP_BUFFER, inpipe, (char *) &cp_buffer, &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMrecv_info:file_info : status = <0x%.8x>\n", status));
	return(NFMnet_oper_fail_fs(0,0,0,status));
     }
    strcpy(src_file,cp_buffer.src_name);
    strcpy(dst_file,cp_buffer.dst_name);
    strcpy(attribute,cp_buffer.attr);
    delete_src_flag = cp_buffer.delete_src_flag;

    status = NFMcopy_file(src_file,dst_file,attribute,(long *)&size,delete_src_flag);
    if(status != NFM_S_SUCCESS)
    {
	_NFMdebug((fname,"NFMcopy_file Failed . status : <0x%.8x>\n",status));
       fto_status.status = status;
       fto_status.status2 = sys_buf_status.status2 ;
       fto_status.status3 = sys_buf_status.status3 ;
       length = fto_status_size;
       status = NFMsend_info (NFMFTO_STATUS, outpipe, (char *) &fto_status, 
                              &length);
       if (status != NET_S_SUCCESS)
       {
           _NFMdebug ((fname,"NFMsend_info:fto_status.status = <0x%.8x>: status = <0x%.8x>\n",
       fto_status.status,status));
           return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
       }
       return(NFM_S_FS2_REPLY_SENT);
	
/*
	status1 = status;
*/
    }
   
     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", status1));
     return (status1);
  }


NFMnet_oper_fail_fs ( buffer, file_ptr,filename,  status)
	char *buffer,*filename;
	FILE *file_ptr;
	long status ;
{
	char *fname="NFMnet_oper_fail";
	_NFMdebug((fname,"Entry : buffer <%x> file_ptr <%x> status <0x%.8x>\n",
buffer,file_ptr,status));
	if(buffer != (char *)0) free(buffer);
	if(filename != (char *)0) unlink(filename);
	if(file_ptr != (FILE *)0) fclose(file_ptr);
        xfer_buf_status.status2 = net_buf_status.status2 ;
        xfer_buf_status.status3 = net_buf_status.status3 ;
	
        switch(status)
	{
		case NET_E_TLI_RECEIVE_SIZE:
			return(NFM_E_TLI_RECEIVE_SIZE_FS1_FS2);
/* BREAK NOT REQD	AFTER RETURN
			break;
*/
		case NET_E_TLI_SEND :
        		return (NFM_E_TLI_SEND_FS1_FS2);
/* BREAK NOT REQD	AFTER RETURN
			break;
*/
		case NET_E_TLI_RECEIVE :
	             return (NFM_E_TLI_RECEIVE_FS1_FS2);
/* BREAK NOT REQD	AFTER RETURN
			break;
*/
		default:
		     return(status);
	}
}

_NFMsend_stat_buf(NETid,status2,fname2)
	long *NETid;
	long status2;
	char *fname2;
{
	long status;
        int  length;
	NFMbuffer_info buffer_info;
	char *fname="_NFMsend_stat_buf";

	_NFMdebug((fname,"Entry: *NETid <%d>: status2 <0x%.8x>:fname2 <%s>\n",
*NETid,status2,fname2));
                length = buffer_info_size;
                buffer_info.request = status2 ;
                status = NFMsend_info (NFMBUFFER_INFO, (int *)NETid, 
                                       (char *) &buffer_info, &length);
                if (status != NET_S_SUCCESS)
                 {
                   _NFMdebug ((fname2,"NFMsend_info:buffer_info.request = <0x%.8x>: status = <0x%.8x>\n",
       status2,status));
                   return(NFMnet_oper_fail_fs ( (char *)0, (FILE *)0,(char *)0 , status));
                 }
	_NFMdebug((fname,"EXIT: SUCCESSFUL: status <0x%.8x>\n",status));
	return(NFM_S_SUCCESS);
}
NFMcheck_sum(file_name, checksum)
char *file_name;
int *checksum;
{
	char *fname = "NFMcheck_sum";
	char sum_command[256], buffer[256];
	FILE *fp, *popen(); 
	int failed = 0, junk;
	long status;
	char *ret_status;
	
	sprintf(sum_command, "/bin/sum %s", file_name);

	fp = popen(sum_command, "r");	
	if(!fp)
		failed = 1;
	else
	{
		ret_status = fgets(buffer, 255, fp);
		if(ret_status == NULL)
			failed = 1;
		else
			sscanf(buffer, "%d %d", checksum, &junk); 
	}
	
	if(failed)
	{
		_NFMdebug((fname, "system command: <sum %s> failed, errno <%d>",
				  file_name, errno));
       		status = NFM_E_SUM;
		ERRload_struct(NFM,status,"%s%x%d",file_name,status,errno);
		/* Return error that sum failed for COFILENAME */
       		xfer_buf_status.status2 = errno ;
       		return (status);
	}
	_NFMdebug((fname, "CHECKSUM for FILE <%s> is <%d>\n", 
					file_name, *checksum));
	return(NFM_S_SUCCESS);
}


/***************************************************
12/9/92
Karen Tice

Replacement functions NFMrecv_info and NFMsend_info 
(shells around NETbuffer_receive and NETbuffer_send
****************************************************/

int  NFMrecv_info(type, NETid,  info, length)
int  type;
int  *NETid;
char *info;
int  *length;
{
     char *fname="NFMrecv_info:";
     NFMbuffer_info  *buffer_info;
     NFMfile_info    *file_info;
     NFMfto_status   *fto_status ;
     NFMcp_buffer    *cp_buffer;
     NFMstatus_buf   *buf_inf_ptr;

     int  status = NET_S_SUCCESS;

     _NFMdebug((fname,"Entry.\n"));

     switch ( type )
     {
         case NFMBUFFER_INFO:

              buffer_info = (struct NFMbuffer_info *) info;
/* debug statements added - PS 16.5. 95 */
     		_NFMdebug((fname," before NETbuffer_receive\n"));
	      status = NETbuffer_receive (NETid,(char *)buffer_info,length);
     		_NFMdebug((fname," after NETbuffer_receive\n"));
        /* Solaris included for byte swapping -- MVR 27 Dec 1993 */
/* HP-PORT IGI 25 Aug 94 */
/* Intel/Solaris Port - CN 16.5.95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined (__sgi) || defined (OS_HPUX) )

	      /* Swap the Non-character data in the structure */

              _NFMdebug((fname,"BSW: NFMrecv_info: buffer_info:size <%d> \
request <%d>\n", buffer_info->size, buffer_info->request));

	      buffer_info->request = swapbytes (buffer_info->request);
              buffer_info->size = swapbytes (buffer_info->size);

              _NFMdebug((fname,"ASW: NFMrecv_info: buffer_info:size <%d> \
request <%d>\n", buffer_info->size, buffer_info->request));
#endif
	      break;

         case NFMFILE_INFO:

 	      file_info = (struct NFMfile_info *) info;

 	      status = NETbuffer_receive (NETid,(char *)file_info,length);
/* Solaris included for byte swapping -- MVR 27 Dec 1993 */
/* HP-PORT IGI 25 Aug 94 */
/* Intel/Solaris Port - CN 16.5.95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined (__sgi) || defined (OS_HPUX) )
 
	      /* Swap the Non-character data in the structure */

              _NFMdebug((fname,"BSW: NFMrecv_info: file_info:size <%d> mode <%d> \
atime <%d> mtime <%d>\n",
		      file_info->size, file_info->mode, file_info->atime,
		      file_info->mtime));

	      file_info->size = swapbytes (file_info->size);
	      file_info->mode = swapbytes (file_info->mode);
    	      file_info->atime = swapbytes (file_info->atime);
	      file_info->mtime = swapbytes (file_info->mtime);

              _NFMdebug((fname,"ASW: NFMrecv_info: file_info:size <%d> mode <%d> \
atime <%d> mtime <%d>\n",
		      file_info->size, file_info->mode, file_info->atime,
		      file_info->mtime));
#endif
	      break;

         case NFMFTO_STATUS:

              fto_status = (struct NFMfto_status *) info;

 	      status = NETbuffer_receive (NETid,(char *)fto_status,length);
/* Solaris included for byte swapping - MVR 27 Dec 93 */
/* HP-PORT IGI 25 Aug 94 */
/* Intel/Solaris Port - CN 16.5.95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL)) || defined (__sgi) || defined (OS_HPUX) )
	      /* Swap the Non-character data in the structure */

	      _NFMdebug((fname,"BSW: NFMrecv_info: fto_status:status <%d> status2 <%d> \
status3 <%d> status4 <%d> status5 <%d> status6 <%d>\n",
		      fto_status->status,fto_status->status2,fto_status->status3,
		      fto_status->status4,fto_status->status5,fto_status->status6));

	      fto_status->status = swapbytes (fto_status->status);
	      fto_status->status2 = swapbytes (fto_status->status2);
	      fto_status->status3 = swapbytes (fto_status->status3);
	      fto_status->status4 = swapbytes (fto_status->status4);
	      fto_status->status5 = swapbytes (fto_status->status5);
	      fto_status->status6 = swapbytes (fto_status->status6);

	      _NFMdebug((fname,"ASW: NFMrecv_info: fto_status:status <%d> status2 <%d> \
status3 <%d> status4 <%d> status5 <%d> status6 <%d>\n",
		      fto_status->status,fto_status->status2,fto_status->status3,
		      fto_status->status4,fto_status->status5,fto_status->status6));
#endif
	      break;

         case NFMCP_BUFFER:

	      cp_buffer = (struct NFMcp_buffer *) info;

	      status = NETbuffer_receive (NETid,(char *)cp_buffer,length);
/* Solaris included for byte swapping -- MVR 27 Dec 1993 */
/* HP-PORT IGI 25 Aug 94 */
/* Intel/Solaris Port - CN 16.5.95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined (__sgi) || defined (OS_HPUX) )
	      /* Swap the Non-character data in the structure */

	      _NFMdebug((fname,"BSW: NFMrecv_info: cp_buffer:delete_src_flag <%d>\n",
			 cp_buffer->delete_src_flag));

	      cp_buffer->delete_src_flag = swapbytes (cp_buffer->delete_src_flag);

	      _NFMdebug((fname,"ASW: NFMrecv_info: cp_buffer:delete_src_flag <%d>\n",
		      	cp_buffer->delete_src_flag));
#endif
	      break;

         case NFMSTATUS_BUF:

	      buf_inf_ptr = (struct NFMstatus_buf *) info;

	      status = NETbuffer_receive (NETid,(char *)buf_inf_ptr,length);
/* Solaris included for byte swapping -- MVR 27 Dec 1993 */
/* HP-PORT IGI 25 Aug 94 */
/* Intel/Solaris Port - CN 16.5.95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined (__sgi) || defined (OS_HPUX) )
	      /* Swap the Non-character data in the structure */

	      _NFMdebug((fname,"BSW: NFMsend_info: buf_inf_ptr:status <%d>\n",
		      buf_inf_ptr->status));

	      buf_inf_ptr->status = swapbytes (buf_inf_ptr->status);

	      _NFMdebug((fname,"ASW: NFMsend_info: buf_inf_ptr:status <%d>\n",
		      buf_inf_ptr->status));
#endif
	      break;
     }
     return ( status );
}




int  NFMsend_info(type,  NETid,  info, length)
int  type;
int  *NETid;
char *info;
int  *length;
{
     char *fname="NFMsend_info:";
     NFMbuffer_info  *buffer_info, lbi;
     NFMfile_info    *file_info, lfi;
     NFMfto_status   *fto_status, lfs;
     NFMcp_buffer    *cp_buffer, lcb;
     NFMstatus_buf   *buf_inf_ptr;

     char  *spt;

/* KT - 1/7/93 - CLIX compiler doesn't like this
     char *memcpy();
*/
     int  status = NET_S_SUCCESS;

     _NFMdebug((fname,"Entry.\n"));

     switch ( type )
     {
         case NFMBUFFER_INFO:

	      buffer_info = (struct NFMbuffer_info *) info;
	      spt = memcpy ((char *)&lbi, (char *)buffer_info,
					sizeof(struct NFMbuffer_info));
/* Solaris included for byte swapping -- MVR 27 Dec 1993 */
/* HP-PORT IGI 25 Aug 94 */
/* Intel/Solaris Port - CN 16.5.95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined (__sgi) || defined (OS_HPUX) )

	      /* Swap the Non-character data in the structure */

              _NFMdebug((fname,"BSW: NFMsend_info: buffer_info:size <%d> \
request <%d>\n", lbi.size, lbi.request));

	      lbi.request = swapbytes (buffer_info->request);
              lbi.size = swapbytes (buffer_info->size);

              _NFMdebug((fname,"ASW: NFMsend_info: buffer_info:size <%d> \
request <%d>\n", lbi.size, lbi.request));
#endif
	      /* Now send the swapped or unswapped buffer,    */
	      /* depending on the #ifdef macro                */

	      status = NETbuffer_send (NETid,(char *)&lbi,length);
	      break;

         case NFMFILE_INFO:

	      file_info = (struct NFMfile_info *) info;
	      spt = memcpy ((char *)&lfi, (char *)file_info,
					sizeof(struct NFMfile_info));
/* Solaris included for byte swapping - MVR 27 Dec 93 */
/* HP-PORT IGI 25 Aug 94 */
/* Intel/Solaris Port - CN 16.5.95 */
#if (defined(OS_SUNOS) ||( defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined (__sgi) || defined (OS_HPUX) )
	      /* Swap the Non-character data in the structure */

              _NFMdebug((fname,"BSW: NFMsend_info: file_info:size <%d> mode <%d> \
atime <%d> mtime <%d>\n", lfi.size, lfi.mode, lfi.atime, lfi.mtime));

	      lfi.size = swapbytes (file_info->size);
	      lfi.mode = swapbytes (file_info->mode);
    	      lfi.atime = swapbytes (file_info->atime);
	      lfi.mtime = swapbytes (file_info->mtime);

              _NFMdebug((fname,"ASW: NFMsend_info: file_info:size <%d> mode <%d> \
atime <%d> mtime <%d>\n",
		      lfi.size, lfi.mode, lfi.atime,
		      lfi.mtime));
#endif
	      status = NETbuffer_send (NETid,(char *)&lfi,length);
	      break;

         case NFMFTO_STATUS:

	      fto_status = (struct NFMfto_status *) info;
	      spt = memcpy ((char *)&lfs, (char *)fto_status,
					sizeof(struct NFMfto_status));
/* Solaris included for byte swapping -- MVR 27 Dec 1993 */
/* HP-PORT IGI 25 Aug 94 */
/* Intel/Solaris Port - CN 16.5.95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL)) || defined (__sgi) || defined (OS_HPUX) )
	      /* Swap the Non-character data in the structure */

	      _NFMdebug((fname,"BSW: NFMsend_info: fto_status:status <%d> status2 <%d> \
status3 <%d> status4 <%d> status5 <%d> status6 <%d>\n",
		      lfs.status,lfs.status2,lfs.status3,
		      lfs.status4,lfs.status5,lfs.status6));

	      lfs.status = swapbytes (fto_status->status);
	      lfs.status2 = swapbytes (fto_status->status2);
	      lfs.status3 = swapbytes (fto_status->status3);
	      lfs.status4 = swapbytes (fto_status->status4);
	      lfs.status5 = swapbytes (fto_status->status5);
	      lfs.status6 = swapbytes (fto_status->status6);

	      _NFMdebug((fname,"ASW: NFMsend_info: fto_status:status <%d> status2 <%d> \
status3 <%d> status4 <%d> status5 <%d> status6 <%d>\n",
		      lfs.status,lfs.status2,lfs.status3,
		      lfs.status4,lfs.status5,lfs.status6));
#endif
	      status = NETbuffer_send (NETid,(char *)&lfs,length);
	      break;

         case NFMCP_BUFFER:

	      cp_buffer = (struct NFMcp_buffer *) info;
	      spt = memcpy ((char *)&lcb, (char *)cp_buffer,
					sizeof(struct NFMcp_buffer));
/* Solaris included for byte swapping -- MVR 27 Dec 1993 */
/* HP-PORT IGI 25 Aug 94 */
/* Intel/Solaris Port - CN 16.5.95 */
#if (defined(OS_SUNOS) ||( defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined (__sgi) || defined (OS_HPUX) )
	      /* Swap the Non-character data in the structure */

	      _NFMdebug((fname,"BSW: NFMsend_info: cp_buffer:delete_src_flag <%d>\n",
		      lcb.delete_src_flag));

	      lcb.delete_src_flag = swapbytes (cp_buffer->delete_src_flag);

	      _NFMdebug((fname,"ASW: NFMsend_info: cp_buffer:delete_src_flag <%d>\n",
		      lcb.delete_src_flag));
#endif
	      status = NETbuffer_send (NETid,(char *)&lcb,length);
	      break;

         case NFMSTATUS_BUF:

	      buf_inf_ptr = (struct NFMstatus_buf *) info;
/* Solaris included for byte swapping -- MVR 27 Dec 1993 */
/* HP-PORT IGI 25 Aug 94 */
/* Intel/Solaris Port -CN 16.5.95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined (__sgi) || defined (OS_HPUX) )
	      /* Swap the Non-character data in the structure */

	      _NFMdebug((fname,"BSW: NFMsend_info: buf_inf_ptr:status <%d>\n",
		      buf_inf_ptr->status));

	      buf_inf_ptr->status = swapbytes (buf_inf_ptr->status);

	      _NFMdebug((fname,"ASW: NFMsend_info: buf_inf_ptr:status <%d>\n",
		      buf_inf_ptr->status));
#endif
	      status = NETbuffer_send (NETid,(char *)buf_inf_ptr,length);

/* 2/5/93 - KT - OOPS! Forgot this one! */
/* Solaris included for byte swapping - MVR 27 Dec 93 */
/* HP-PORT IGI 25 Aug 94 */
/* Intel/Solaris Port - CN 16.5.95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined (__sgi) || defined (OS_HPUX) )
              buf_inf_ptr->status = swapbytes (buf_inf_ptr->status);
#endif
	      break;
     }
     return ( status );
}



