#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"

 long NFMcl_receive_buffer (sock_no, in_command, list)
   long       *sock_no;
   long       *in_command;
   MEMptr     *list;
   {
     char *fname="NFMcl_receive_buffer ";
     long   status;
     long   in_size;
     int size,size1;
     char   *buffer_ptr;
     NFMbuffer_info buffer_info;

     _NFMdebug ((fname,"Sock    No = <%d> Command = <%d>\n", *sock_no,*in_command    ));

     size = sizeof (NFMbuffer_info);
 
     buffer_info.request = 0;
     buffer_info.size    = 0;

/* KT - 1/5/93 - SUN Port */
/* The __unix__ has been changed to read as OS_CLIX & OS_SCO_UNIX  */
/* for consistancy/readability  MVR 27 Dec 1993 */
/* Intel/Solaris Port - PS 16 May 95 */
#if (defined(OS_CLIX) || defined(OS_SCO_UNIX) || defined(OS_INTELSOL))
     status = NETbuffer_receive_c ((int *)sock_no, (char *) &buffer_info, &size);
/* HP PORT-IGI- 10 Jun 1994 */
/* Intel/Solaris Port - PS 16 May 95 */
#elif ( defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined(OS_HPUX))

/* Above line changed from ifdef sparc MVR 27 Dec 1993              */
/* sock_no is casted to (int *) as the prototype of NFMrecv_info    */
/*  expects pointer to integer as second argument - SSRS - 19/11/93 */
     status = NFMrecv_info (NFMBUFFER_INFO, (int *)sock_no, 
                            (char *) &buffer_info, &size);
#else
/* This is to be taken care for other platforms, if needed. MVR 27 Dec 1993  */
#endif

     if (status != NET_S_SUCCESS)
      {
         _NFMdebug ((fname,"Buffer Rec : status = <0x%.8x>\n", status));
/* Client side close the connection  on failure */
	 NETclose_c ( (int *)sock_no);
	 ERRload_struct(NETC,NET_E_NO_SERVER_CONNECTION,"");
         return (status);
      }
 
     *in_command = buffer_info.request;
     in_size     = buffer_info.size;

     _NFMdebug ((fname," COMMAND = <%d>, size = <%d>\n", *in_command,in_size));

     buffer_ptr = NULL;

     if (in_size > 0)
      {
        buffer_ptr = (char *) malloc (in_size);
        if (! buffer_ptr)
         {
           status = NFM_E_MALLOC;
           _NFMdebug ((fname,"CL REC BUF : Malloc Failed : Size = <%d> status = <0x%.8x>\n",in_size, status));
           ERRload_struct (NFM, status,"%d" ,in_size);
           return (status);
         }

        size1 = in_size;
        status = NETbuffer_receive_c ((int *)sock_no, buffer_ptr, &size1);
        if (status != NET_S_SUCCESS)
         {
           free (buffer_ptr);
           _NFMdebug ((fname,"Rec Buffer : status = <0x%.8x>\n", status));
/* Client side close the connection  on failure */
	   NETclose_c ( (int *)sock_no);
	   ERRload_struct(NETC,NET_E_NO_SERVER_CONNECTION,"");
           return (status);
         }

        if (in_size != size1)
         {
           free (buffer_ptr);
           status = NFM_E_BAD_CL_REC_TRANS;
           _NFMdebug ((fname,"Confirm Status in_size = <%d> size = <%d> : status = <0x%.8x>\n",in_size,size1, status));
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
  
 long NFMcl_send_buffer (sock_no, out_command, list)
   long       *sock_no;
   long       out_command;
   MEMptr     list;
   {
     char *fname="NFMcl_send_buffer ";
     long   status;
     int   size, out_size, size1;
     NFMbuffer_info buffer_info;

     _NFMdebug ((fname," Sock    No = <%d> Command = <%d>\n  ", *sock_no,out_command    ));

     buffer_info.request = out_command;

     if (list)
     {
	 MEMbuffer_size (list, &out_size);
	 buffer_info.size = out_size;
     }
     else       out_size = buffer_info.size = 0;

     _NFMdebug ((fname,"Command  = <%d> Size <%d>\n ", buffer_info.request,buffer_info.size));

     /*  Send info  */

     size = sizeof (NFMbuffer_info);

/* KT - 1/5/93 - SUN Port */
/* The __unix__ has been changed to read as OS_CLIX and OS_SCO_UNIX  */
/* for consistancy/readability  MVR 27 Dec 1993   */
/* Intel/Solaris Port - PS 16 May 95 */
#if (defined(OS_CLIX) || defined(OS_SCO_UNIX) || defined(OS_INTELSOL))
     status = NETbuffer_send_c ((int *)sock_no, (char *) &buffer_info, &size);

/* HP PORT-IGI- 10 Jun 1994 */
/* Intel/Solaris Port - PS 16 May 95 */
#elif ( defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined(OS_HPUX))

/* Above line changed from ifdef sparc MVR 27 Dec 1993 */
/* sock_no is casted to (int *) as the prototype of NFMrecv_info   */
/* expects pointer to integer as second argument - SSRS - 19/11/93 */
     status = NFMsend_info (NFMBUFFER_INFO, (int *)sock_no, 
                            (char *) &buffer_info, &size);
#else
/* This is to be taken care for other platforms, if needed. MVR 27 Dec 1993  */
#endif
 
     if (status != NET_S_SUCCESS)
      {
         _NFMdebug ((fname,"Buffer Send : status = <0x%.8x>\n", status));
/* Client side close the connection  on failure */
	 NETclose_c ( (int *)sock_no);
	 ERRload_struct(NETC,NET_E_NO_SERVER_CONNECTION,"");
         return (status);
      }

     if (out_size)
      {
        size1 = out_size;
        status = NETbuffer_send_c ((int *)sock_no, list -> buffer_ptr, &size1);
        if (status != NET_S_SUCCESS)
         {
         _NFMdebug ((fname,"Buffer Send : status = <0x%.8x>\n", status));
/* Client side close the connection  on failure */
	 NETclose_c ( (int *)sock_no);
	 ERRload_struct(NETC,NET_E_NO_SERVER_CONNECTION,"");
           return (status);
         }

        if (out_size != size1)
         {
           status = NFM_E_BAD_CL_SEND_TRANS;
           _NFMdebug ((fname,"CL SEND BUF: Confirm Failed:out_size <%d> size1 <%d> status = <0x%.8x>\n",out_size,size1,status));
/* Client side close the connection  on failure */
           NETclose_c ( (int *)sock_no);
	 ERRload_struct(NETC,NET_E_NO_SERVER_CONNECTION,"");
           ERRload_struct (NFM, status,"%d%d",out_size,size1 );
           return (status);
         }
      }

     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMsrv_receive_buffer (in_pipe, out_pipe, in_command, list)
   long       *in_pipe, *out_pipe;
   long       *in_command;
   MEMptr     *list;
   {
     char *fname="NFMsrv_receive_buffer ";
     long   status;
     int   size, in_size, size1;
     char   *buffer_ptr;
     NFMbuffer_info buffer_info;

     _NFMdebug ((fname,"In  Pipe = <%d> Out Pipe <%d> Command <%d>\n  ", *in_pipe ,*out_pipe,*in_command   ));

     size = sizeof (NFMbuffer_info);
 
     buffer_info.request = 0;
     buffer_info.size    = 0;

/* KT - 1/5/93 - SUN Port */
/*      The __unix__ has been changed to read as OS_CLIX  for
        consistancy/readability  MVR 27 Dec 1993*/
/* Intel/Solaris Port - PS 16 May 95 */
#if (defined(OS_CLIX) || defined(OS_SCO_UNIX) || defined(OS_INTELSOL))
     status = NETbuffer_receive_s ((int *)in_pipe, (char *) &buffer_info, &size)
;

/* HP PORT-IGI- 10 Jun 1994 */
/* Intel/Solaris Port - PS 16 May 95 */
#elif ( defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined(OS_HPUX))
/* Above line changed from ifdef sparc MVR 27 Dec 1993 */

     status = NFMrecv_info (NFMBUFFER_INFO, in_pipe, 
			    (char *) &buffer_info, &size);
#else
/* This is to be taken care for other platforms, if needed. MVR 27 Dec 1993  */
#endif

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
        status = NETbuffer_receive_s ((int *)in_pipe, buffer_ptr, &size1);
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
  
 long NFMsrv_send_buffer (in_pipe, out_pipe, out_command, list)
   long       *in_pipe, *out_pipe;
   long       out_command;
   MEMptr     list;
   {
char *fname="NFMsrv_send_buffer ";
     long   status;
     int   size, out_size, size1;
     NFMbuffer_info buffer_info;

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

     size = sizeof (NFMbuffer_info);

/* KT - 1/5/93 - SUN Port */
/*      The __unix__ has been changed to read as OS_CLIX  for
        consistancy/readability  MVR 27 Dec 1993 */
/* Intel/Solaris Port - PS 16 May 95 */

#if (defined(OS_CLIX) || defined(OS_SCO_UNIX) || defined(OS_INTELSOL))
     status = NETbuffer_send_s ((int *)out_pipe, (char *) &buffer_info, &size);

/* HP PORT-IGI- 10 Jun 1994 */
/* Intel/Solaris Port - PS 16 May 95 */
#elif (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined(OS_HPUX))

/* Above line changed from ifdef sparc to as it reads now  */
/* MVR 27 Dec 1993*/
/* out_pipe is casted to (int *) as the prototype of NFMrecv_info */
/* expects pointer to integer as second argument - SSRS - 19/11/93 */
     status = NFMsend_info (NFMBUFFER_INFO, (int *)out_pipe, 
			    (char *) &buffer_info, &size);
#else
/* This is to be taken care for other platforms, if needed. MVR 27 Dec 1993  */
#endif

     if (status != NET_S_SUCCESS)
      {
         _NFMdebug ((fname,"Buffer Send : status = <0x%.8x>\n", status));
         return (status);
      }

     if (out_size)
      {
        size1 = out_size;
        status = NETbuffer_send_s ((int *)out_pipe, list -> buffer_ptr, &size1);
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

 long NFMcl_fs_exit (sock_no)
   long   *sock_no;
   {
char *fname="NFMcl_fs_exit ";
     long    status, status1;
     long    command;
     MEMptr  list = NULL;

     _NFMdebug ((fname,"CL EXIT : Sock No = <%d>\n", *sock_no));
     if ( *sock_no < 0 )
     {
	_NFMdebug((fname,"Bad Socket:Socket number <%d>  <  0 : returning <0x%.8x>\n",*sock_no,NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);

     }

     command = EXIT;
     status = NFMcl_send_buffer (sock_no, command , list); 
     if (status != NFM_S_SUCCESS)
      { 
        _NFMdebug( (fname,"CL Buff Send : status = <%d>\n", status));
        status = NETclose_c ((int *)sock_no);
        return (status);
      }

     MEMclose (&list);

     /* receive a reply from the server. */

     status = NFMcl_receive_buffer (sock_no, &status1, &list); 
     if (status != NFM_S_SUCCESS)
      { 
        MEMclose (&list);
        _NFMdebug( (fname,"Cl Buffer Rec : status = <%d>\n", status));
        status = NETclose_c ((int *)sock_no);
        return (status);
      }

     MEMclose (&list);

     /* status from the server */

     status = NETclose_c ((int *)sock_no);
     if (status != NET_S_SUCCESS)
      {
        _NFMdebug ((fname,"Close Socket : status = <0x%.8x>\n", status));
/* ERRload done by lower level functions	NETclose in libnet
        ERRload_struct(NETC,status,"");
*/
        return (status);
      }

     if (status1 != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname,"Server Exit Status : status = <0x%.8x>\n", status1));
        ERRload_struct(NFM,NFM_E_FAILURE,"%s %x","Server Exit Status",status1);
        return (status1);
      }

     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
   }

 long NFMsrv_fs_exit (in_pipe, out_pipe)
   long   *in_pipe, *out_pipe;
   {
char *fname="NFMsrv_fs_exit ";
     long    status;

     _NFMdebug ((fname," In  Pipe = <%d> Out Pipe <%d>\n  ", *in_pipe,*out_pipe ));

/* Sleep for 2 seconds to allow the kernel to send previous data */
     sleep(2);

     status = NETclose_s ((int *)in_pipe, (int *)out_pipe);
     if (status != NET_S_SUCCESS)
      {
        _NFMdebug ((fname,"Close Socket : status = <0x%.8x>\n", status));
/* ERRload done by lower level functions	NETclose in libnet
        ERRload_struct(NETS,status,"");
*/
        return (status);
      }

     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
   }
