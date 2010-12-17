#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "UNIX_or_VMS.h"
#include "NETstruct.h"
#include "NETerrordef.h"
#include "MEMstruct.h"
#include "ERR.h"
#include "DEBUG.h"

/*************************************************************************
 *                                                                       *
 *     Module:    NETtools.c                                             *
 *     Date:      July 7, 1989                                           *
 *                                                                       *
 *     Includes:  TCP/IP and XNS support.                                *
 *                Incorporated NFS into NETfile_send and receive         * 
 *                functions.                                             *
 *                                                                       *
 *************************************************************************/

int NETvax_accept (inpipe, outpipe, protocol)
  int        *inpipe;
  int        *outpipe;
  int        protocol;        /* NET_XNS, or NET_TCP, or NULL */
  {
char *fname="NETaccept ";
     int         status, status1;
     int         length;
     struct      NETbuffer_info buffer_info;

#ifdef __unix__
     struct  passwd *getpwnam ();
     void    setpwent();
     void    endpwent();
     struct  passwd *pswd_ptr;
#endif
     _NETCdebug((fname,"Inpipe <%d> Outpipe <%d> Protocol <%d>\n",*inpipe,*outpipe,protocol));
     _NETSdebug((fname,"Inpipe <%d> Outpipe <%d> Protocol <%d>\n",*inpipe,*outpipe,protocol));

     status = _NETvax_accept (inpipe);
     *outpipe = *inpipe;

     if (status != NET_S_SUCCESS)
      { 
        _NETCdebug ((fname,"Net Switch Accept Failed : status = <0x%.8x>\n", status));
        _NETSdebug ((fname,"Net Switch Accept Failed : status = <0x%.8x>\n", status));
        return (status);
      }

     /* receive the username from the client. */

     length = sizeof (struct NETbuffer_info);

     status = NETbuffer_receive_s (inpipe, (char *) &buffer_info, &length); 
     if (status != NET_S_SUCCESS)
      { 
        _NETCdebug ((fname," Net Ser Buff Rec Failed : status = <0x%.8x>\n", status));
        _NETSdebug ((fname," Net Ser Buff Rec Failed : status = <0x%.8x>\n", status));
        return (status);
      }
        
     /* set the uid of the listener process to that of the user. */
     /* on VMS setuid has no functionality and always returns zero. */ 

     status = NETload_user_info (buffer_info.username);
     if (status != NET_S_SUCCESS)
      {
        _NETCdebug ((fname,"Load user info failed: status = <0x%.8x>\n", status));
        _NETSdebug ((fname,"Load user info failed: status = <0x%.8x>\n", status));
      }

     strcpy (buffer_info.username, "");
     buffer_info.size    = 0; 
     buffer_info.request = status;

     length = sizeof (struct NETbuffer_info);

     status1 = NETbuffer_send_s (outpipe, (char *) &buffer_info, &length); 
     if (status1 != NET_S_SUCCESS)
      {
        _NETCdebug ((fname,"Buff Send Failed : status = <0x%.8x>\n", status1));
        _NETSdebug ((fname,"Buff Send Failed : status = <0x%.8x>\n", status1));
        return (status1);
      }

     if (status != NET_S_SUCCESS)
      {
        _NETCdebug ((fname," Set User Id : status = <0x%.8x>\n", status));
        _NETSdebug ((fname," Set User Id : status = <0x%.8x>\n", status));
        return (status);
      }

     _NETCdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
     _NETSdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
     return (NET_S_SUCCESS);
  }

int NETclose_s (inpipe, outpipe)
  int *inpipe;
  int *outpipe;       /* outpipe returned from NETaccept. */
  {
char *fname="NETclose_s ";
    int     status;

    _NETCdebug ((fname,"Inpipe  = <%d>  Out Pipe = <%d>\n ", *inpipe,*outpipe));
    _NETSdebug ((fname,"Inpipe  = <%d>  Out Pipe = <%d>\n ", *inpipe,*outpipe));

    status = NETvax_close (inpipe);
    if (status != NET_S_SUCCESS)
     {
       _NETCdebug ((fname," Sw Close S : status = <0x%.8x>\n", status));
       _NETSdebug ((fname," Sw Close S : status = <0x%.8x>\n", status));
       return (status);
     }

    _NETCdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    _NETSdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    return (NET_S_SUCCESS);
  }

int NETbuffer_send_s (NETid, buffer, len)
  int        *NETid;
  char       *buffer;
  int        *len;
  {
char *fname="NETbuffer_send_s ";
    int        status;

    _NETCdebug ((fname," NETid = <%d>  Lengthe = <%d> \n ", *NETid,*len));
    _NETSdebug ((fname," NETid = <%d>  Lengthe = <%d> \n ", *NETid,*len));

    status = NETvax_buffer_send (NETid, buffer, len);
    if (status != NET_S_SUCCESS)
     {
       _NETCdebug ((fname, " Sw Buff Send S : status = <0x%.8x>\n", status));
       _NETSdebug ((fname, " Sw Buff Send S : status = <0x%.8x>\n", status));
       return (status);
     }

    _NETCdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    _NETSdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    return (NET_S_SUCCESS);
  }

int NETbuffer_receive_s (NETid, buffer, len)
  int        *NETid;
  char       *buffer;
  int        *len;
  {
char *fname="NETbuffer_receive_s ";
    int        status;

    _NETCdebug ((fname," NETid = <%d>  Length = <%d>\n ", *NETid,*len));
    _NETSdebug ((fname," NETid = <%d>  Length = <%d>\n ", *NETid,*len));

    status = NETvax_buffer_receive (NETid, buffer, len);
    if (status != NET_S_SUCCESS)
     {
       _NETCdebug ((fname,"Sw Buff Rec S : status = <0x%.8x>\n", status));
       _NETSdebug ((fname,"Sw Buff Rec S : status = <0x%.8x>\n", status));
       return (status);
     }

    _NETCdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    _NETSdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    return (NET_S_SUCCESS);
  }
