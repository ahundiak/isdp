#include "machine.h"
#define INCLUDE_EXTERN	1
#include "NETnet_inc.h"

int NETclose_s (inpipe, outpipe)
  int *inpipe;
  int *outpipe;       /* outpipe returned from NETaccept. */
  {
    char *fname="NETclose_s ";
    int     status;

    _NETCdebug ((fname,"Inpipe  = <%d>  Out Pipe = <%d>\n ", *inpipe,*outpipe));
    _NETSdebug ((fname,"Inpipe  = <%d>  Out Pipe = <%d>\n ", *inpipe,*outpipe));

    status = NETclose(inpipe) ;
    if (status != NET_S_SUCCESS )
     {
       _NETCdebug ((fname," NETclose failed : status = <0x%.8x>\n", status));
       _NETSdebug ((fname," NETclose failed : status = <0x%.8x>\n", status));
       return (status);
     }
	*inpipe = *outpipe = -1 ;

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

    _NETCdebug ((fname," NETid = <%d>  Lengthe = <%d> \n ", *NETid,*len));
    _NETSdebug ((fname," NETid = <%d>  Lengthe = <%d> \n ", *NETid,*len));
    return(NETbuffer_send(NETid,buffer,len));
  }

int NETbuffer_receive_s (NETid, buffer, len)
  int        *NETid;
  char       *buffer;
  int        *len;
  {
    char *fname="NETbuffer_receive_s ";
    _NETCdebug ((fname," NETid = <%d>  Length = <%d>\n ", *NETid,*len));
    _NETSdebug ((fname," NETid = <%d>  Length = <%d>\n ", *NETid,*len));
    return(NETbuffer_receive(NETid,buffer,len));
  }
