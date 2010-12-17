#include "machine.h"
#define INCLUDE_EXTERN  1
#include "NFMf_xferinc.h"

struct   stat  fbuff;

long NFMfs_get_list_attached_reference_files (node_name, user_name, passwd, 
					      path,
					      cofilename, att_files_list)
     char     *node_name, *user_name, *passwd, *path, *cofilename;
     MEMptr    *att_files_list;
   {
      char *fname="NFMfs_get_list_attached_reference_files";
      long    status, status1, sock_no;
      char dec_passwd[NFM_PASSWD+1];
      MEMptr save_buffer = NULL, list = NULL ;
      int protocol=0;
      char absolute_name[NFM_FILENAME];
      char datatype [30] ;

      _NFMdebug ((fname,"nodename <%s> username <%s> password <%s>\
 protocol <%d> path <%s> cofilename <%s> MEMptr *att_files_list <%x>\n",
node_name,user_name,passwd,protocol,path,cofilename,*att_files_list));

/* decrypt the password */

      status = NFMdecrypt (passwd, dec_passwd);
      if (status != NFM_S_SUCCESS)
       {
         status = NFM_E_NET_DECRYPT;
         _NFMdebug ((fname,"Decrypt Passwd : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s","Password");
         return (status);
       }
      
      status = MEMopen (&list, MEM_SIZE);
      if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Open : status = <0x%.8x>\n", status));
	ERRload_struct(NFM,status,"%s","MEMopen");
        return (status);
      }

      sprintf (datatype, "char(%d)", NFM_COFILENAME) ;
     status = MEMwrite_format (list, "n_filename", datatype) ;
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Wr Format : status = <0x%.8x>\n", status));
        ERRload_struct(NFM,status,"%s","MEMwrite_format");
        return (status);
      }


/* connect to the destination file server */
      sock_no = -1;

      status = NFMconnect (node_name, user_name, dec_passwd,
               NFM_TCP_PORT, NFM_XNS_PORT, (int *)&sock_no, protocol);
      if (status != NFM_S_SUCCESS)
       {
         ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMconnect",status);
         _NFMdebug ((fname,"NFM Connect Failed : status = <0x%.8x>\n\
returning status = <0x%.8x>\n", status,NFM_E_FAILURE));
         status = NFM_E_FAILURE;
         return (status);
       }

/* send command to destination  with absolute filename as bufferpointer*/

      if(strlen(path) > 0 )
	      sprintf(absolute_name,"%s/%s",path,cofilename); 
      else
	      strcpy(absolute_name,cofilename); 

      status = MEMwrite (list, absolute_name);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         status = NFM_E_MEM_FAILURE;
         ERRload_struct(NFM,status,"%s","MEMwrite");
         _NFMdebug ((fname,"MEM Write : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
       {
         status = NFM_E_MEM_FAILURE;
	 MEMclose (&list) ;
         _NFMdebug ((fname,"MEM Build Array : status = <0x%.8x>\n", status));
         ERRload_struct(NFM,status,"%s","MEMbuild_array");
         return (status);
       }

      if (*att_files_list == NULL)
       status = NFMcl_send_buffer (&sock_no, NFM_GET_MICRO_FILES, list);
      else
      {
       MEMclose (att_files_list);
       status = NFMcl_send_buffer (&sock_no, NFM_GET_ACAD_FILES, list);
      }

      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Failed to send command NFM_GET_MICRO_FILES\n\
sock_no <%d> cofilename <%s> status = <0x%.8x>\n",sock_no,cofilename, status));
         NFMcl_fs_exit (&sock_no);
         return (status);
       }

      status1 = NFM_S_SUCCESS;

/* receive reply back from file server */

      save_buffer = NULL ;
      status = NFMcl_receive_buffer (&sock_no, &status1, &save_buffer);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         _NFMdebug ((fname,"Failed to receive response to command \
 NFM_GET_MICRO_FILES\
sock_no <%d> cofilename <%s> status = <0x%.8x>\n",sock_no,cofilename, status));
         NFMcl_fs_exit (&sock_no);
         return (status);
       }
        /**MEMclose(buffer_ptr); **/
        *att_files_list = save_buffer ;

/* Receive error buffer from file server */

/* close the file server connection */

/* check for file transfer status */

/* load appropriate error */

      status = NFMcl_fs_exit (&sock_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"NFMcl_fs_exit Failed: status = <0x%.8x>\n", status))
;
         return (status);
       }

      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Command NFM_GET_MICRO_FILES Failed at File Server\n\
File Server status1 = <0x%.8x>\n", status1));
        ERRload_struct(NFM,NFM_E_FAILURE,"%s %x","FS: Get MICROSTATION files Failed",status1);
         return (status1);
       }

      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }
long NFMfs_get_micro_files(in_list, out_list)
MEMptr in_list, *out_list;
{

	char *fname="NFMfs_get_micro_files";
	long status;
	char file_name[NFM_COFILENAME+1];
	char format_str[15];
	char **data_ptr, **col_ptr;

	_NFMdebug((fname, "Entry:\n")); 
	if(status = MEMbuild_array(in_list) != MEM_S_SUCCESS)
	{
		_NFMdebug((fname,"MEMbuild_array = <0x%.8x>\n",status));
		status = NFM_E_MEM;
		ERRload_struct(NFM,status,"",NULL);
		return(status);
	}

	data_ptr = (char **)in_list->data_ptr;
        col_ptr = (char **) in_list->column_ptr;

	if((strcmp(col_ptr[0], "n_filename")) || (in_list->columns != 1))
	{
		_NFMdebug((fname,"Currupted Micro station buffer\n"));
		status = NFM_E_CORRUPTED_BUFFERS;
		ERRload_struct(NFM,status,"",NULL);
		return(status);
	}
	strncpy(file_name,data_ptr[0], NFM_COFILENAME);
	file_name[NFM_COFILENAME] = NULL;
	
	if((status = MEMopen(out_list,MEM_SIZE)) != MEM_S_SUCCESS)
	{
		_NFMdebug((fname,"MEMopen = <0x%.8x>\n",status));
		status = NFM_E_MEM;
		ERRload_struct(NFM,status,"",NULL);
		return(status);
	}
	sprintf(format_str, "char(%d)", NFM_COFILENAME);
	if((status = MEMwrite_format
			(*out_list,"att_file",format_str)) != MEM_S_SUCCESS)
	{
		MEMclose(out_list);
		_NFMdebug((fname,"MEMwrite_format = <0x%.8x>\n",status));
		status = NFM_E_MEM;		
		ERRload_struct(NFM,status,"",NULL);
		return(status);
	}
	if((status = 
	       _NFMget_micro_files(file_name,out_list)) != NFM_S_SUCCESS)
	{
		MEMclose(out_list);
		_NFMdebug((fname,"Get micro files = <0x%.8x>\n",status));
		return(status);
	}
	_NFMdebug((fname, "SUCCESSFUL Completion\n"));
	return(NFM_S_SUCCESS);
}
