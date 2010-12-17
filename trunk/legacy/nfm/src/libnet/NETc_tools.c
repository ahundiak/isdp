#include "machine.h"
#include "NETnet_inc.h"

int NETclose_c (NETid)
  int *NETid;
  {
    char *fname="NETclose_c ";
    _NETCdebug ((fname," NETid  = <%d>\n", *NETid));
    _NETSdebug ((fname," NETid  = <%d>\n", *NETid));
    return (NETclose(NETid));
  }

int NETbuffer_send_c (NETid, buffer, len)
  int        *NETid;
  char       *buffer;
  int        *len;
  {
     char *fname="NETbuffer_send_c ";
     _NETCdebug ((fname,"Entry : NETid = <%d> Length = <%d>\n", *NETid,*len));
     _NETSdebug ((fname,"Entry : NETid = <%d> Length = <%d>\n", *NETid,*len));
     return(NETbuffer_send(NETid,buffer,len));
  }
int NETbuffer_receive_c (NETid, buffer, len)
  int        *NETid;
  char       *buffer;
  int        *len;
  {
     char *fname="NETbuffer_receive_c ";
     _NETCdebug ((fname,"NETid = <%d> Len = <%d>\n  ", *NETid,*len));
     _NETSdebug ((fname,"NETid = <%d> Len = <%d>\n  ", *NETid,*len));
     return(NETbuffer_receive(NETid,buffer,len));
  }

