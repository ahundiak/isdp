#include <stdio.h>
#include "MEMstruct.h"
#include "NETstruct.h"
#include "NFMlisten.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMvax_srv_receive_buffer (in_pipe, out_pipe, in_command, list)
   long       *in_pipe, *out_pipe;
   long       *in_command;
   MEMptr     *list;
   {
char *fname="NFMvax_srv_receive_buffer ";
     long   status;
     long   size, in_size, size1;
     char   *buffer_ptr;
     struct NETbuffer_info buffer_info;

     _NFMdebug ((fname,"In  Pipe = <%d> Out Pipe <%d> Command <%d>\n  ", *in_pipe ,*out_pipe,*in_command   ));

     size = sizeof (struct NETbuffer_info);
 
     buffer_info.request = 0;
     buffer_info.size    = 0;

     status = NETvax_buffer_receive (in_pipe, (char *) &buffer_info, &size);
     if (status != NET_S_SUCCESS)
      {
         _NFMdebug ((fname,"Buffer Rec : status = <0x%.8x>\n", status));
         return (status);
      }
 
     *in_command = buffer_info.request;
     in_size     = buffer_info.size;

     _NFMdebug ((fname," COMMAND = <%d> Size <%d>\n", *in_command,in_size));

     buffer_ptr = NULL;

     if (in_size > 0)
      {
        buffer_ptr = (char *) malloc (in_size);
        if (! buffer_ptr)
         {
           status = NFM_E_MALLOC;
           _NFMdebug ((fname,"Malloc Failed : status = <0x%.8x> size <%d>\n", status,in_size));
           ERRload_struct (NFM, status, "%d",in_size);
           return (status);
         }

        size1 = in_size;
        status = NETvax_buffer_receive (in_pipe, buffer_ptr, &size1);
        if (status != NET_S_SUCCESS)
         {
           _NFMdebug ((fname,"Rec Buffer : status = <0x%.8x>", status));
           return (status);
         }

        if (in_size != size1)
         {
           status = NFM_E_BAD_SR_REC_TRANS;
           _NFMdebug ((fname,"Confirm Status : in_size <%d> != size <%d> status = <0x%.8x>",in_size,size1,status));
           ERRload_struct (NFM, status, "%d%d",in_size,size1);
           return (status);
         }

        status = MEMbuild_struct (buffer_ptr, list);
        if (status != MEM_S_SUCCESS)
         {
           status = NFM_E_MEM_FAILURE;
           _NFMdebug ((fname,"MEM Build Struct : status = <0x%.8x>\n",
           status));
	   ERRload_struct(NFM,status,"%s","MEMbuild_struct");
           return (status);
         }
      }

     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }
  
 long NFMvax_srv_send_buffer (in_pipe, out_pipe, out_command, list)
   long       *in_pipe, *out_pipe;
   long       out_command;
   MEMptr     list;
   {
char *fname="NFMvax_srv_send_buffer ";
     long   status;
     long   size, out_size, size1;
     struct NETbuffer_info buffer_info;

     _NFMdebug ((fname,"In  Pipe = <%d> Out Pipe <%d> Command <%d>\n", *in_pipe ,*out_pipe,out_command   ));

     buffer_info.request = out_command;

     if (list)
     {
	 MEMbuffer_size (list, &out_size);
	 buffer_info.size = out_size;
     }
     else       out_size = buffer_info.size = 0;

     _NFMdebug ((fname,"Command  = <%d> size <%d>\n", buffer_info.request,buffer_info.size));

     /*  Send info  */

     size = sizeof (struct NETbuffer_info);

     status = NETvax_buffer_send (out_pipe, (char *) &buffer_info, &size);
     if (status != NET_S_SUCCESS)
      {
         _NFMdebug ((fname,"Buffer Send : status = <0x%.8x>\n", status));
         return (status);
      }

     if (out_size)
      {
        size1 = out_size;
        status = NETvax_buffer_send (out_pipe, list -> buffer_ptr, &size1);
        if (status != NET_S_SUCCESS)
         {
           _NFMdebug ((fname,"Buffer Send : status = <0x%.8x>\n",status));
           return (status);
         }

        if (out_size != size1)
         {
           status = NFM_E_SR_SEND_TRANS;
           _NFMdebug ((fname,"SER SEND BUF : Confirm Failed Out_size <%d> != size <%d> : status = <0x%.8x>\n",
           out_size,size1,status));
           ERRload_struct (NFM, status, "%d%d",out_size,size1);
           return (status);
         }
      }

     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n",NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

/** Is this function required for vax ? **/

 long NFMvax_srv_fs_exit (in_pipe, out_pipe)
   long   *in_pipe, *out_pipe;
   {
char *fname="NFMvax_srv_fs_exit ";
     long    status;

     _NFMdebug ((fname," In  Pipe = <%d> Out Pipe <%d>\n  ", *in_pipe,*out_pipe ));

     status = NETclose_s (in_pipe, out_pipe);
     if (status != NET_S_SUCCESS)
      {
        _NFMdebug ((fname,"Close Socket : status = <0x%.8x>\n", status));
        ERRload_struct(NETS,status,"");
        return (status);
      }

     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
   }
