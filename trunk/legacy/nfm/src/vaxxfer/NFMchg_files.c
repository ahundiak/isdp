#include "machine.h"
#define  INCLUDE_EXTERN	1
#include "NFMf_xferinc.h"


 long NFMfs_chg_files (buffer_ptr)
   MEMptr  *buffer_ptr;
   {
     long     status;
     char *fname="NFMfs_chg_files";
     long NFMrename_files(), NFMrm_ci_files(), NFMmove_files();

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


     status = NFMrm_ci_files(buffer_ptr);
     if(status != NFM_S_SUCCESS )
     {	
	_NFMdebug((fname,"NFMrm_ci_files Failed : status <0x%.8x>\n",status));
	return(status);
     }
     else status = NFMrename_files(buffer_ptr);
     if(status != NFM_S_SUCCESS )
     {
	_NFMdebug((fname,"NFMrename_files Failed : status <0x%.8x>\n",status));
	return(status);
     }
     status = NFMmove_files(buffer_ptr);
     if(status != NFM_S_SUCCESS )
     {
	_NFMdebug((fname,"NFMmove_files Failed : status <0x%.8x>\n",status));
	return(status);
     }

     _NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
     return(NFM_S_SUCCESS);
}


 long NFMrename_files(buffer_ptr)
   MEMptr  *buffer_ptr;
   {
     long     status,n_status,n_status1,status1,status2;
     char     **column, **data ;
     long     x, y, protocol,count,count1;
     long     NFMftp_rename_files (),NFMfmu_rename_files(),NFMs_rename_files();
     char     *fname="NFMrename_files";

     _NFMdebug((fname,"Entry: MEMptr *buffer_ptr <%x>\n",*buffer_ptr));

     status = MEMbuild_array (*buffer_ptr);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (buffer_ptr);
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

         if(n_status == NFM_RENAME || n_status == NFM_COPY_LOCAL )
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

               status = NFMs_rename_files(data[count+FTO_NODENAME],
data[count+FTO_USERNAME],data[count+FTO_PASSWD],protocol,buffer_ptr);
               status2 = MEMbuild_array (*buffer_ptr);
               if (status2 != MEM_S_SUCCESS)
                {
                  MEMclose (buffer_ptr);
                  ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMbuild_array",fname,"status",status1);
                  _NFMdebug((fname,"MEMbuild_array failed for *buffer_ptr: status = <0x%.8x>\n", status1));
                  return (NFM_E_MEM_BUILD_ARRAY_BUFFER);        
                 }

              column = (char **) (*buffer_ptr) -> column_ptr;
              data   = (char **) (*buffer_ptr) -> data_ptr;
            }
            else if ( !strcmp(data[count+FTO_OPSYS],"VMS") && (protocol == NET_XNS)) /* VAX - IGI */
        	status = NFMfmu_rename_files (data[count+FTO_NODENAME],
data[count+FTO_USERNAME],data[count+FTO_PASSWD],data[count+FTO_SANO],buffer_ptr);
            else
                status = NFMftp_rename_files (data[count+FTO_NODENAME],
data[count+FTO_USERNAME],data[count+FTO_PASSWD],data[count+FTO_SANO],buffer_ptr) ;

            if(status != NFM_S_SUCCESS)
            {
                status1 = status ;
           	_NFMdebug((fname,"Rename checkin filenames  failed. nodename <%s> status <0x%.8x>\n",data[count+FTO_NODENAME],status));
	        for(y=0;y < (*buffer_ptr)->rows;y++)
		{
                     count1 = (*buffer_ptr)->columns * y ;
                     n_status1 = atol(data[count1+FTO_STATUS1]);
	             if(!strcmp(data[count+FTO_NODENAME],data[count1+FTO_NODENAME]))
		     {
			if(n_status1 == NFM_RENAME)
                        {
			   switch(status)
			   {
				case NFM_E_NET_DECRYPT_CI_LOCATION:
                           		n_status1 = status ;
					break;
				case NFM_E_CONNECT_CI_LOCATION:
					n_status1 = status ;
NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS2+1,net_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS3+1,net_buf_status.status3);
					break;
				case NFM_E_UNAME_CI_LOCATION:
					n_status1 = status ;
					break;
				case NFM_E_FOPEN_WRITE_FTP_SCRIPT_RE:
					n_status1 = status ;
					break;
				case NFM_E_FWRITE_FTP_SCRIPT_RENAME:
					n_status1 = status ;
					break;
				case NFM_E_FTP_RENAME_CI_FILENAME:
					n_status1 = status ;
					break;
				case NFM_E_FMU_CONNECT_CI_LOCATION:
					n_status1 = status ;
					break;
				default:
                           		n_status1 = NFM_E_RENAME_CI_FILENAME ;
			   }
                           NFMset_buf_stat(*buffer_ptr,y+1,FTO_STATUS1+1,n_status1);
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

long NFMs_rename_files(node_name,user_name,passwd,protocol,buffer_ptr)
	char *node_name,*user_name,*passwd;
        int protocol;
        MEMptr  *buffer_ptr;
{
        char *fname="NFMs_rename_files";
        char dec_passwd[NFM_PASSWD];
        long status1,status,sock_no;
        MEMptr save_buffer ;
	_NFMdebug((fname,"Entry: Nodename <%s> Username <%s> Passwd <%s>\
\nProtocol <%d> MEMptr *buffer_ptr <%x>\n",node_name,user_name,passwd,protocol,*buffer_ptr));

      sock_no = -1 ;
      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         status = NFM_E_NET_DECRYPT;
         _NFMdebug ((fname,"Decrypt Passwd  : status = <0x%.8x>\n",
         status));
	ERRload_struct(NFM,status,"%s","Password");
         return (NFM_E_NET_DECRYPT_CI_LOCATION);
       }

      status = NFMconnect (node_name, user_name,dec_passwd,
               NFM_TCP_PORT, NFM_XNS_PORT, (int *)&sock_no, protocol);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFMconnect Failed: status = <0x%.8x>\n",
         status));
         return (NFM_E_CONNECT_CI_LOCATION);
       }

      status = NFMcl_send_buffer (&sock_no, NFM_RENAME_FILES, *buffer_ptr);
      if (status != NFM_S_SUCCESS)
       {
         NFMcl_fs_exit (&sock_no);
         status = NFM_E_SEND_COMMAND_S_TO_FS ;
         ERRload_struct(NFM,status,"%s%s%s","Rename:NFM_RENAME_FILES",
node_name,user_name);

         _NFMdebug ((fname,"NFMcl_send_buffer failed for NFM_RENAME_FILES: status = <0x%.8x>\n",
         status));
         return (NFM_E_SEVERE_ERROR);
       }      

      save_buffer = NULL ;

      status1 = NFM_S_SUCCESS;

      status = NFMcl_receive_buffer (&sock_no, &status1, &save_buffer);
      if (status != NFM_S_SUCCESS)
       {
	 MEMclose(&save_buffer);
         status = NFM_E_RECEIVE_RESPONSE_FS_TO_S ;
         ERRload_struct(NFM,status,"%s%s%s","Rename:NFM_RENAME_FILES",
node_name,user_name);

         NFMcl_fs_exit (&sock_no);
         _NFMdebug ((fname,"NFMcl_receive_buffer Failed for NFM_RENAME_FILES: status = <0x%.8x>\n",
         status));
         return (NFM_E_SEVERE_ERROR);
       }      
 
      MEMclose ( buffer_ptr);
      *buffer_ptr = save_buffer ;
/* Receive error buffer */
      status = NFMcl_fs_exit (&sock_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"CL FS  Exit Failed : status = <0x%.8x>\n",
         status));
        status = NFM_E_EXIT_S_TO_FS;
         ERRload_struct(NFM,status,"%s%s%s","Rename:NFM_RENAME_FILES",
node_name,user_name);
         return (status);
       }

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFM_RENAME_FILES Failed at server side: status1 = <0x%.8x>\n",
         status1));
	ERRload_struct(NFM,NFM_E_FAILURE,"%s %x","NFM_RENAME_FILES Failed at server", status1);
         return (status1);
       }
     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMfs_rename_files (buffer_ptr)
   MEMptr    *buffer_ptr;
   {
      char *fname="NFMfs_rename_files ";
      long     n_status,status, status4;
      long     x, count;
      char     **column, **data;
      char     dst_file [ 512 ] , src_file [512];
      char     sano[INTEGER+1];
      struct stat fbuff ;

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
                }
                else continue;
         }

         n_status = atol(data[count+FTO_STATUS1]);

         if(n_status == NFM_RENAME || n_status == NFM_COPY_LOCAL )
          {
            if(!strcmp(sano,data[count+FTO_SANO]))
            {
		if(n_status == NFM_RENAME)
	            n_status = NFM_RENAMED ;
		else
	            n_status = NFM_COPIED ;
            status = NFM_S_SUCCESS ;
            status = NFMappend_path_file (data[count+FTO_OPSYS],
                     data [count+FTO_PATHNAME], data [count + FTO_CIFILENAME], src_file);
            if(status != NFM_S_SUCCESS)
            {
            	_NFMdebug((fname,"Append Path Failed: status = <0x%.8x>\n",status));
                n_status = NFM_E_RENAME_APPEND_CI_FROM ;
                status4 = n_status ;
                ERRload_struct(NFM,status4,"%s%s%s%s",data[count+FTO_NODENAME],
data[count+FTO_USERNAME],data[count+FTO_PATHNAME],data[count+FTO_CIFILENAME]);
		NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
		continue;
            }
            status = NFMappend_path_file (data[count+FTO_OPSYS],
                     data [count+FTO_PATHNAME], data [count + FTO_COFILENAME], dst_file);
            if(status != NFM_S_SUCCESS)
            {
            	_NFMdebug((fname,"Append Path Failed: status = <0x%.8x>\n",status));
                n_status = NFM_E_RENAME_APPEND_CI_TO ;
                status4 = n_status ;
                ERRload_struct(NFM,status4,"%s%s%s%s",data[count+FTO_NODENAME],
data[count+FTO_USERNAME],data[count+FTO_PATHNAME],data[count+FTO_COFILENAME]);
		NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
		continue;
           
            }

/* 12/9/92 - KT - Replace 'Stat' with 'stat'
            status = Stat ( dst_file,&fbuff);
*/
            status = stat ( dst_file,&fbuff);
	    if(status == 0) /* File exists in check in location */
            {
/* ERROR Loading is not done this is a fileserver function */
                   n_status = NFM_E_CI_FILENAME_EXISTS ;
                   status4 = n_status ;
                   NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
		   continue;
	    }
	    if(n_status == NFM_RENAMED)
            	status = NFMcopy_file (src_file, dst_file,
                        data [count + FTO_FILETYPE], &size,1);
	    else
            	status = NFMcopy_file (src_file, dst_file,
                        data [count + FTO_FILETYPE], &size,0);
            if(status != NFM_S_SUCCESS)
            {
               _NFMdebug((fname,"NFMcopy_file failed : src_file <%s> dst_file <%s> status <0x%.8x>\n",src_file,dst_file,status));
		ERRload_struct(NFM,NFM_E_FAILURE,"%s%d","NFMcopy_file in rename failed for row",x);
	       switch(status)
		{
			case NFM_E_NO_FILENAME_SRC:
			n_status = NFM_E_RENAME_NO_CI_FROM;
			break;
			case NFM_E_NO_FILENAME_DST:
			n_status = NFM_E_RENAME_NO_CI_TO;
			break;
			case NFM_E_UNLINK:
			n_status = NFM_E_UNLINK_CI_FROM;
			break;
			case NFM_E_FOPEN_SRC:
			n_status = NFM_E_FOPEN_READ_CI_FROM;
			break;
			case NFM_E_FOPEN_DST:
			n_status = NFM_E_FOPEN_WRITE_CI_TO;
			break;
			case NFM_E_FWRITE:
			n_status = NFM_E_FWRITE_CI_TO;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,sys_buf_status.status3);
			break;
			case NFM_E_FCLOSE_SRC:
			n_status = NFM_E_FCLOSE_CI_FROM;
			break;
			case NFM_E_FCLOSE_DST:
			n_status = NFM_E_FCLOSE_CI_TO;
			break;
			case NFM_E_STAT_SRC:
			n_status = NFM_E_STAT_CI_FROM;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
			break;
			case NFM_E_STAT_DST:
			n_status = NFM_E_STAT_CI_TO;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
			break;
			case NFM_E_UTIME:
			n_status = NFM_E_SET_UTIME_CI_TO;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,sys_buf_status.status3);
			break;
			case NFM_E_CHMOD:
			n_status = NFM_E_SET_CHMOD_CI_TO;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,sys_buf_status.status3);
			break;
			case NFM_E_CHOWN:
			n_status = NFM_E_SET_CHOWN_CI_TO;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,sys_buf_status.status3);
			break;
			case NFM_E_FILESIZE_MISMATCH:
			n_status = NFM_E_BAD_SIZE_CI_TO;
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS2+1,sys_buf_status.status2);
NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS3+1,sys_buf_status.status3);
			break;
			default:
               		n_status = NFM_E_RENAME_CI_FILENAME ;
		}
               status4 = n_status ;
               NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
		continue;
            }
               NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
           }
          }
       }



      if (status4 != NFM_S_SUCCESS)
       {
         status = NFM_E_FAILURE ;
         _NFMdebug ((fname,"Previous Failure: status4 = <0x%.8x>\n", status4));
         ERRload_struct(NFM,status,"%s%x","APPEND or GET_FILE_NAME or UNLINK",status4);
         return(status4);
       }

      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n",NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

 long NFMftp_rename_files (node_name, user_name, passwd,sano ,
                              buffer_ptr)
   char    *node_name, *user_name, *passwd,*sano;
   MEMptr  *buffer_ptr;
   {
      long     n_status,n_status1,status,status1;
      long     x,  count;
      char     **data;
      char     src_file [512],dst_file[512], dec_pass [50];
      char *fname="NFMftp_rename_files" ;

      
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
         n_status = atol (data[count+FTO_STATUS1]);

         if(n_status == NFM_RENAME )
          {
            if(!strcmp(data[count+FTO_SANO],sano))
            {
            status = NFMappend_path_file (data [count+FTO_OPSYS],
                     data [count+ FTO_PATHNAME], data [count + FTO_CIFILENAME], src_file);
            if (status != NFM_S_SUCCESS)
             {
               _NFMdebug((fname,"Append Path : status = <0x%.8x>\n", status));
               ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMappen",status);
	       NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_RENAME_APPEND_CI_FROM);
		status1 = status;
		continue;
             }
            status = NFMappend_path_file (data [count+FTO_OPSYS],
                     data [count+ FTO_PATHNAME], data [count + FTO_COFILENAME], dst_file);
            if (status != NFM_S_SUCCESS)
             {
               _NFMdebug((fname,"Append Path : status = <0x%.8x>\n", status));
               ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMappen",status);
	       NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_RENAME_APPEND_CI_TO);
		status1 = status;
		continue;
             }
            status = NFMftp_check_local(node_name,user_name,dec_pass,dst_file);
	    if(status == NFM_S_SUCCESS)
	    {
		_NFMdebug((fname,"Check in file <%s> exists locally on node <%s>\n",
dst_file,node_name));
		n_status1 = NFM_E_CI_FILENAME_EXISTS;
                NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status1);
		status1 = n_status1;
		continue;
	    }
	    status = NFMftp_rename(node_name,user_name,dec_pass,src_file,dst_file, data[count+FTO_MACHID]); /* VAX - IGI */
	    if(status!=NFM_S_SUCCESS) status1 = status ;
	    switch(status)
		{
			case NFM_S_SUCCESS:
				n_status1 = NFM_RENAMED;
				break;
			default:
				n_status1 = NFM_E_FTP_RENAME_CI_FILENAME;
		}
             NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status1);


             }

          }
        }

      
      _NFMdebug((fname," SUCCESSFUL : status = <0x%.8x>\n", status1));
      return (status1);      
   }

 long NFMfmu_rename_files (node_name, user_name, passwd,sano, buffer_ptr)
   char    *node_name, *user_name, *passwd,*sano;
   MEMptr   *buffer_ptr;
   {
      long     n_status,status,status1;
      long     x, count;
      char     **column, **data;
      char     str [1024], dst_file[512],src_file [512], dec_pass [50];
      long     delete,pos;
      char *fname="NFMfmu_rename_files";

      _NFMdebug((fname,"Entry Username <%s> Nodename <%s> passwd <%s>\n\
 sano <%s> MEMptr : *buffer_ptr <%x>\n", node_name,user_name,passwd,sano,*buffer_ptr));

      delete = 0;
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
		 return(NFM_E_FMU_CONNECT_CI_LOCATION);
	}
   
      status1 = NFM_S_SUCCESS ;
      for (x = 0; x < (*buffer_ptr) -> rows; ++x)
       {
         count = (*buffer_ptr) -> columns * x;
         n_status = atol (data[count+FTO_STATUS1]);

         if (n_status == NFM_RENAME)
          {

               if(!strcmp(data[count+FTO_SANO],sano))
               {
               status = NFMappend_path_file (data [count+FTO_OPSYS],
                        data [count+FTO_PATHNAME], data [count + FTO_CIFILENAME], src_file);
               if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname," Append Path : status = <0x%.8x>\n",
                  status));
               ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMappen",status);
	       NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_RENAME_APPEND_CI_FROM);
		status1 = status;
		continue;
                 
                }
               status = NFMappend_path_file (data [count+FTO_OPSYS],
                        data [count+FTO_PATHNAME], data [count + FTO_COFILENAME], dst_file);
               if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname," Append Path : status = <0x%.8x>\n",
                  status));
               ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMappen",status);
	       NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_RENAME_APPEND_CI_TO);
		status1 = status;
		continue;
                }
	       
	       NFMconvert_to_vax_file(src_file);
	       NFMconvert_to_vax_file(dst_file);
               sprintf (str, "dir %s ", dst_file);
	       status = NFMfmu_rcmd(str,"");
	       if(status==NFM_S_SUCCESS || status == NFM_I_NO_OUTPUT )
		{
		  status1 = NFM_E_CI_FILENAME_EXISTS;
                  _NFMdebug ((fname," Check in File <%s> exists locally:status <0x%.8x>\n",dst_file,status1));
                  ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","Check in file exists locally",status);
                  NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,status1);
	          continue;
		}
               sprintf (str, "rename %s %s", src_file,dst_file);
	       status = NFMfmu_rcmd(str,"");
	       if(status!=NFM_S_SUCCESS && status != NFM_I_NO_OUTPUT )
		{
                  _NFMdebug ((fname," fmu_rcmd failed for command <%s>: status = <0x%.8x>\n",str, status));
               ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMfmu_rcmd",status);
	       NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_E_FMU_RENAME_CI_FILENAME);
		status1 = status;
		continue;
		}
	       NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,NFM_RENAMED);
              }
          }
       }

      status=NETfmu_disconnect();
/*
      if(status != NET_S_SUCCESS )
      {
          _NFMdebug ((fname," fmu_disconnect failed  status = <0x%.8x>\n", status));
            return(status);
      }
*/

      
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", status1));
      return (status1);      
   }

/*

==============================================================================
*/

long NFMmove_files(buffer_ptr)
	MEMptr *buffer_ptr ;
{
     long     status,status1,n_status,n_status1;
     MEMptr   save_buffer = NULL;
     char     **column, **data,**data2;
     long     x, count,count1,count2,NETid = -1 ;
     char     *fname="NFMmove_files";

     _NFMdebug((fname,"Entry: MEMptr *buffer_ptr <%x>\n",*buffer_ptr));
     status1 = NFM_S_SUCCESS ;
     status = MEMbuild_array (*buffer_ptr);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (buffer_ptr);
        ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMbuild_array",fname,"status",status);
        _NFMdebug((fname,"MEMbuild_array failed for *buffer_ptr: status = <0x%.8x>\n", status));
        return (NFM_E_MEM_BUILD_ARRAY_BUFFER);
      }

     column = (char **) (*buffer_ptr) -> column_ptr;
     data   = (char **) (*buffer_ptr) -> data_ptr;

     for(x=0 ; x < (*buffer_ptr)->rows; x++)
     {
	count = (*buffer_ptr)->columns * x ;
	n_status = atol(data[count+FTO_STATUS1]);
	_NFMdebug((fname,"x <%d>, count <%d>, n_status <0x%.8x>\n",x, count, n_status));
	if(n_status == NFM_DESTINATION )
	{
	        count1 = (*buffer_ptr)->columns * (x+1) ;
                if(x < (*buffer_ptr)->rows - 1 ) n_status1 = atol (data[count1+FTO_STATUS1]);
	        else n_status1 = n_status;
		_NFMdebug((fname,"n_status is NFM_DESTINATION:  n_status1 <0x%.8x>\n",n_status1));
		if(n_status1 != NFM_MOVE )
		{
			_NFMdebug((fname,"Mismatched NFM_DESTINATION and NFM_MOVE at row <%d>\n",x));
			ERRload_struct(NFM,NFM_E_FAILURE,"%s%d","Mismatched NFM_MOVE and NFM_DESTINATION at row",x);
                        n_status = NFM_E_MISMATCH_MOVE_DESTINATION;
                  	NFMset_buf_stat(*buffer_ptr,x+1,FTO_STATUS1+1,n_status);
			continue;
/*
			return(n_status);
*/
                }
/* Build buffer and call NFMfs_send_files */
                status = MEMcopy_row ( *buffer_ptr,&save_buffer,x+2);
		_NFMdebug((fname,"MEMcopy_row (save_buffer = %x, row <%d>) <0x%.8x>\n",save_buffer, x+2, status));
		if(status!=MEM_S_SUCCESS)
		{
			_NFMdebug((fname,"Failed to copy row number <%d> status <0x%.8x>\n",x+2,status));
                        ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","MEMcopy_row",status);
			n_status = NFM_E_CHANGE_COPY_ROW;
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS1+1,n_status);
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS2+1,status);
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS3+1,x+1);
                	MEMclose(&save_buffer);
			continue;
/*
			return(status);
*/
		}
		status = MEMcopy_row ( *buffer_ptr,&save_buffer, x+1) ;
		_NFMdebug((fname,"MEMcopy_row (save_buffer = %x, row <%d>) <0x%.8x>\n",save_buffer, x+1, status));
		if(status!=MEM_S_SUCCESS)
		{
			_NFMdebug((fname,"Failed to copy row number <%d> status <0x%.8x>\n",x+1,status));
                        ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","MEMcopy_row",status);
			n_status = NFM_E_CHANGE_COPY_ROW;
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS1+1,n_status);
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS2+1,status);
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS3+1,x+2);
                	MEMclose(&save_buffer);
			continue;
/*
			return(status);
*/
		}
		status = MEMbuild_array(save_buffer);
		if(status != MEM_S_SUCCESS)
		{
			_NFMdebug((fname,"MEMbuild_array failed  status <0x%.8x>\n",status));
			ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","MEMbuild_array",status);
			n_status = NFM_E_CHANGE_COPY_DATA; 
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS1+1,n_status);
                	MEMclose(&save_buffer);
			continue;
		}
/* Copy the cofilename and check in filename to second row
*/
		status = MEMwrite_data(save_buffer,data[count1+FTO_COFILENAME],2,FTO_CIFILENAME+1);
		if(status != MEM_S_SUCCESS)
		{
			_NFMdebug((fname,"MEMwrite_data failed to copy COFILENAME to the MOVE Buffer. status <0x%.8x>\n",status));
			ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","MEMwrite_data",status);
			n_status = NFM_E_CHANGE_COPY_DATA; 
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS1+1,n_status);
                	MEMclose(&save_buffer);
			continue;
		}
		status = MEMwrite_data(save_buffer,data[count1+FTO_CIFILENAME],2,FTO_COFILENAME+1);
		if(status != MEM_S_SUCCESS)
		{
			_NFMdebug((fname,"MEMwrite_data failed to copy COFILENAME to the MOVE Buffer. status <0x%.8x>\n",status));
			ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","MEMwrite_data",status);
			n_status = NFM_E_CHANGE_COPY_DATA; 
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS1+1,n_status);
                	MEMclose(&save_buffer);
			continue;
		}
                status= NFMset_buf_stat ( save_buffer,1,FTO_STATUS1+1,0);
		if(status != NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"NFMset_buf_stat:save_buffer:row_no <%d> : status1 <%d>: status <0x%.8x>\n",1,0,status));
			ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","Set buffer status Failed in NFMmove_files",status);
			n_status = NFM_E_CHANGE_COPY_DATA; 
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS1+1,n_status);
                	MEMclose(&save_buffer);
			continue;
		}
                status= NFMset_buf_stat ( save_buffer,2,FTO_STATUS1+1,NFM_MOVE_FIRST_TIME);
		if(status != NFM_S_SUCCESS)
		{
			_NFMdebug((fname,"NFMset_buf_stat:save_buffer:row_no <%d> : status1 <%d>: status <0x%.8x>\n",1,0,status));
			ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","Set buffer status Failed in NFMmove_files",status);
			n_status = NFM_E_CHANGE_COPY_DATA; 
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS1+1,n_status);
                	MEMclose(&save_buffer);
			continue;
		}
/*  Remove files INCOMPLETE */
		status = _NFMfs_send_files(&save_buffer,&NETid,0);
		if (status != NFM_S_SUCCESS) status1 = status;
		n_status = MEMbuild_array(save_buffer);
		if(n_status != MEM_S_SUCCESS)
		{
			_NFMdebug((fname,"MEMbuild_array failed  status <0x%.8x>\n",n_status));
			status1 = n_status;
			ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","MEMbuild_array",n_status);
			n_status = NFM_E_CHANGE_COPY_DATA; 
			NFMdisconnect((int *)&NETid);
			_NFMfs_undo_send_files(&save_buffer);
                  	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS1+1,n_status);
                	MEMclose(&save_buffer);
			continue;
		}
                data2   = (char **) (save_buffer) -> data_ptr;
		count2 = save_buffer->columns;
                n_status = atol ( data2[count2+FTO_STATUS1]);
	        if(status!=NFM_S_SUCCESS) 
			_NFMfs_undo_send_files(&save_buffer);
		else 
		{
			status = NFMrm_co_files(&save_buffer,NETid);
		        if(status!= NFM_S_SUCCESS)
		        	n_status = NFM_E_MOVE_FILE_DESTINATION ;
		}
               	NFMset_buf_stat(*buffer_ptr,x+2,FTO_STATUS1+1,n_status);
                MEMclose(&save_buffer);
		
	}
 	_NFMdebug((fname,"End of for loop, index x=<%d>\n",x));
     }

 _NFMdebug((fname,"Returning : status <0x%.8x>\n",status1));
 return(status1);
}

