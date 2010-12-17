#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

/************************************************************************
*									*
*			_DMfs_recv_files				*
*									*
*	This function is used by check out in which case the destination*
*	for all the files is the same storage location			*
************************************************************************/

long _DMfs_recv_files (buffer_ptr)

MEMptr  *buffer_ptr;
{
  char *fname="_DMfs_recv_files";
  long status;

  _NFMdebug((fname,"Entry > MEMptr: *buffer_ptr = <%x>\n",*buffer_ptr));

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



/* check if the destination location is a CLIX m/c */

    status = NFMs_dest_recv_dmmgr(buffer_ptr);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFM File server destination receive clix : status = <0x%.8x>\n",
      status));
      return (status);             
    }
  _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);     
}

/************************************************************************
*									*
*			_DMfs_send_files				*
*									*
*	This function is used by "check in" in which case the source    *
*	for all the files is the same storage location			*
************************************************************************/

long _DMfs_send_files (buffer_ptr, NETid,close_flag)

MEMptr  *buffer_ptr;
long *NETid,close_flag;
{
  char *fname="_DMfs_send_files";
  long     status;

  _NFMdebug((fname,"Entry > MEMptr: buffer = <%x>\n",*buffer_ptr));

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



/* check if the destination location is a CLIX m/c */

    status = NFMs_src_send_dmmgr( buffer_ptr);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFM File server source send clix : status = <0x%.8x>\n",
      status));
      return (status);             
    }

  _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);     

}



long NFMs_dest_recv_dmmgr ( buffer_ptr)
   MEMptr    *buffer_ptr;
   {
      char *fname="NFMs_dest_recv_dmmgr";
      long    status,status1;
      MEMptr save_buffer = NULL ;

      _NFMdebug ((fname," *buffer_ptr <%x>\n",*buffer_ptr));




/* send command to destination */

      status = NFMcl_send_buffer (&CLIENT_NETid, NFM_DEST_RECEIVE_FILES, *buffer_ptr);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Failed to send command NFM_DEST_RECEIVE_FILES\n\
to fileserver at client MEMptr *buffer_ptr  <%x> status = <0x%.8x>\n",*buffer_ptr, status));
	 status = NFM_E_SEND_COMMAND_S_TO_FS ;
	 ERRload_struct(NFM,status,"%s%s%s","checkout/copy:NFM_DEST_RECEIVE_FILES",
"dmmgr","dmmgr_user");
         return (NFM_E_SEVERE_ERROR);
       }      

      status1 = NFM_S_SUCCESS;

/* receive reply back from file server */

      save_buffer = NULL ;
      status = NFMcl_receive_buffer (&CLIENT_NETid, &status1, &save_buffer);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         _NFMdebug ((fname,"Failed to receive response to command NFM_DEST_RECEIVE_FILES\n\
from fileserver at client MEMptr *buffer_ptr  <%x> status = <0x%.8x>\n",*buffer_ptr, status));
	 status = NFM_E_RECEIVE_RESPONSE_FS_TO_S ;
	 ERRload_struct(NFM,status,"%s%s%s","checkout/copy:NFM_DEST_RECEIVE_FILES",
"dmmgr","dmmgruser");
         return (NFM_E_SEVERE_ERROR);
       }      
	MEMclose(buffer_ptr);
	*buffer_ptr = save_buffer ;


      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Command NFM_DEST_RECEIVE_FILES Failed at File Server\n\
File Server status1 = <0x%.8x>\n", status1));
        ERRload_struct(NFM,NFM_E_FAILURE,"%s %x","FS: Destination Receive Files Failed",status1);
         return (status1);
       }

     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

long NFMs_src_send_dmmgr ( buffer_ptr)
   MEMptr    *buffer_ptr;
   {
      char *fname="NFMs_src_send_dmmgr";
      long    status,status1;
      MEMptr save_buffer = NULL ;

      _NFMdebug ((fname,"MEMptr *buffer_ptr <%x>\n",
*buffer_ptr));

/* send command to destination */

      status = NFMcl_send_buffer (&CLIENT_NETid, NFM_SRC_SEND_FILES, *buffer_ptr);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Failed to send command NFM_SRC_SEND_FILES\n\
to fileserver at client MEMptr *buffer_ptr  <%x> status = <0x%.8x>\n",*buffer_ptr,status));
	 status = NFM_E_SEND_COMMAND_S_TO_FS ;
	 ERRload_struct(NFM,status,"%s%s%s","checkin:NFM_SRC_SEND_FILES",
"dmmgr","dmmgruser");
         return (NFM_E_SEVERE_ERROR);
       }      

/* close the memory buffer as the file server will return the buffer loaded with
   size information */


      status1 = NFM_S_SUCCESS;

/* receive reply back from file server */

      save_buffer = NULL ;
      status = NFMcl_receive_buffer (&CLIENT_NETid, &status1, &save_buffer);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         _NFMdebug ((fname,"Failed to receive response to command NFM_SRC_SEND_FILES\n\
from fileserver at client MEMptr *buffer_ptr  <%x> status = <0x%.8x>\n",*buffer_ptr,status));
	 status = NFM_E_RECEIVE_RESPONSE_FS_TO_S ;
	 ERRload_struct(NFM,status,"%s%s%s","checkin:NFM_SRC_SEND_FILES",
"dmmgr","dmmgruser");
         return (NFM_E_SEVERE_ERROR);
       }      

       MEMclose(buffer_ptr);
       *buffer_ptr = save_buffer ;



      if (status1 != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Command NFM_SRC_SEND_FILES Failed at File Server\n\
 File Server status1 = <0x%.8x>\n", status1));
         ERRload_struct(NFM,NFM_E_FAILURE,"%s %x","FS: Source send Files Failed" ,status1);
         return (status1);
       }

     
      _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }


 long _DMfs_undo_recv_files (buffer_ptr)
   MEMptr  *buffer_ptr;
   {
     return(DMs_rm_co_files(buffer_ptr));
   }
long DMrm_co_files (buffer_ptr, fs_net_id)
   MEMptr  *buffer_ptr;
   long *fs_net_id;
   {
     return(DMs_rm_co_files(buffer_ptr));
   }


long DMs_rm_co_files(buffer_ptr)
        MEMptr  *buffer_ptr;
{
        char *fname="DMs_rm_co_files";
        long status,status1;
        MEMptr save_buffer = NULL ;
      _NFMdebug ((fname,"MEMptr *buffer_ptr <%x>\n",
*buffer_ptr));

      status = NFMcl_send_buffer (&CLIENT_NETid, NFM_RM_CO_FILES, *buffer_ptr);
      if (status != NFM_S_SUCCESS)
       {

         _NFMdebug ((fname,"NFMcl_send_buffer failed for NFM_RM_CO_FILES: status = <0x%.8x>\n",
         status));
         status = NFM_E_SEND_COMMAND_S_TO_FS ;
         ERRload_struct(NFM,status,"%s%s%s","NFM_RM_CO_FILES","dmmgr", "dmmgruser");
         return (NFM_E_SEVERE_ERROR);
       }      

      status1 = NFM_S_SUCCESS;

      save_buffer = NULL ;
      status = NFMcl_receive_buffer (&CLIENT_NETid, &status1, &save_buffer);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         _NFMdebug ((fname,"NFMcl_receive_buffer Failed for NFM_RM_CO_FILES: status = <0x%.8x>\n",
         status));
         status = NFM_E_RECEIVE_RESPONSE_FS_TO_S ;
         ERRload_struct(NFM,status,"%s%s%s","NFM_RM_CO_FILES","dmmgr", "dmmgruser");

         return (NFM_E_SEVERE_ERROR);
	
       }      
      MEMclose(buffer_ptr);
      *buffer_ptr = save_buffer ;
 
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




long DMfs_get_list_attached_reference_files ( path,
					      cofilename, att_files_list,filetype)
     char     *path, *cofilename;
     MEMptr    *att_files_list;
     long filetype;
   {
      char *fname="DMfs_get_list_attached_reference_files";
      long    status, status1, len;
      MEMptr save_buffer = NULL, list = NULL ;
      char absolute_name[NFM_FILENAME];
      char datatype [30] ;

      _NFMdebug ((fname,
        "path <%s> cofilename <%s> MEMptr *att_files_list <%x> filetype [%d]\n",
path,cofilename,*att_files_list, filetype));

      
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



/* send command to destination  with absolute filename as bufferpointer*/

      if((len=strlen(path)) > 0 )
      {
	      if(path[len-1]=='\\')
	      	sprintf(absolute_name,"%s%s",path,cofilename); 
              else
	      	sprintf(absolute_name,"%s\\%s",path,cofilename); 
      }
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

      status = NFMcl_send_buffer (&CLIENT_NETid, filetype, list);

      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname,"Failed to send command NFM_GET_MICRO_FILES\n\
or NFM_GET_ACAD_FILES sock_no <%d> cofilename <%s> status = <0x%.8x>\n",CLIENT_NETid,cofilename, status));
         return (status);
       }

      status1 = NFM_S_SUCCESS;

/* receive reply back from file server */

      save_buffer = NULL ;
      status = NFMcl_receive_buffer (&CLIENT_NETid, &status1, &save_buffer);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose(&save_buffer);
         _NFMdebug ((fname,"Failed to receive response to command \
 NFM_GET_MICRO_FILES\
sock_no <%d> cofilename <%s> status = <0x%.8x>\n",CLIENT_NETid,cofilename, status));
         return (status);
       }
        /**MEMclose(buffer_ptr); **/
        *att_files_list = save_buffer ;

/* Receive error buffer from file server */

/* close the file server connection */

/* check for file transfer status */

/* load appropriate error */


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


long _DMdo_nothing ()

{

  char *fname="_DMdo_nothing";
  long status, status1=NFM_S_SUCCESS;
  MEMptr null_buffer=NULL, save_buffer=NULL;

  _NFMdebug ((fname, "ENTER:\n"));

  status = NFMcl_send_buffer (&CLIENT_NETid, NFM_DO_NOTHING, 
                              null_buffer);

  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname,"Failed to send command NFM_DO_NOTHING\n\
                sock_no <%d> status = <0x%.8x>\n",
                CLIENT_NETid, status));
    return (status);
  }

  status = NFMcl_receive_buffer (&CLIENT_NETid, &status1, &save_buffer);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose(&save_buffer);
    _NFMdebug ((fname,"Failed to receive response to command NFM_DO_NOTHING\
                sock_no <%d> status = <0x%.8x>\n",
                CLIENT_NETid, status));
    return (status);
  }


  MEMclose (&save_buffer);

  _NFMdebug ((fname, "Successful\n"));
  return (NFM_S_SUCCESS);
}






