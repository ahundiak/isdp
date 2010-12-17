/*************************************************************************
 *                                                                       *
 *     Module:    NETxns.c                                               *
 *     Author:    Glenn Scott                                            *
 *     Date:      01 May 1989                                            *
 *                                                                       *
 *     Modified:  Bureden Warren                                         * 
 *     Date:      31 May 1989                                            *
 *                                                                       *
 *************************************************************************/
#include "DEBUG.h"


#include <stdio.h>
#include <errno.h>
#include "UNIX_or_VMS.h"

#if UNIX 
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#endif

#if VMS
#include <types.h>
#include <stat.h>
#endif

#include "NETstruct.h"
#include "NETerrordef.h"
#include "ERR.h"

#include "NFMschema.h"

int _NETvax_accept (sni_d)
  int   *sni_d;
  {
char *fname="_NETvax_accept ";
    int    status;
    char   *c_status;

    _NETCdebug ((fname," Sni Id = <%d>\n", *sni_d));
    _NETSdebug ((fname," Sni Id = <%d>\n", *sni_d));

    c_status = (char *) sni_accept (sni_d);
    if (c_status)
     {
       _NETCdebug ((fname,"XNS ACCEPT Inc Error: <%s>\n", c_status));
       _NETSdebug ((fname,"XNS ACCEPT Inc Error: <%s>\n", c_status));
       status = NET_E_SNI_ACCEPT;
	ERRload_struct(NETC,status,"%s",c_status);
	ERRload_struct(NETS,status,"%s",c_status);
       return (status);
     }

    _NETCdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    _NETSdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    return (NET_S_SUCCESS);
  }

int NETvax_close (sni_d)
  int *sni_d;
  {
char *fname="NETvax_close ";
    long    status;
    char    *c_status;

    _NETCdebug ((fname,"Sni Id = <%d>\n", *sni_d));
    _NETSdebug ((fname,"Sni Id = <%d>\n", *sni_d));

    c_status = (char *) sni_close (sni_d);
    if (c_status)
     {
       _NETCdebug ((fname,"Inc Error: Close Failed <%s>\n", c_status));
       _NETSdebug ((fname,"Inc Error: Close Failed <%s>\n", c_status));
       status = NET_E_SNI_CLOSE;
	ERRload_struct(NETS,status,"%s",c_status);
	ERRload_struct(NETC,status,"%s",c_status);
       _NETCdebug ((fname," status = <0x%.8x>\n", status));
       _NETSdebug ((fname," status = <0x%.8x>\n", status));
       return (status);
     }

    _NETCdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    _NETSdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    return (NET_S_SUCCESS);
  }

int NETvax_buffer_send (sni_d, buffer, len)
  int   *sni_d;
  char  *buffer;
  int   *len;
  {
char *fname="NETvax_buffer_send ";
    int     status;
    char    *c_status;
    int     position;
    int     buffer_size;
    int     max_buffer;

    _NETCdebug((fname,"SNI ID <%d> Buffer <%d> Length <%d>\n",*sni_d,buffer,*len));
    _NETSdebug((fname,"SNI ID <%d> Buffer <%d> Length <%d>\n",*sni_d,buffer,*len));

    max_buffer  = XNS_MAX_SIZE;
    buffer_size = *len;

    /* Maximum byte count NETwork can handle is 16K */
 
    position = 0;
    while (buffer_size > XNS_MAX_SIZE)
     {
       c_status = (char *) sni_txw (sni_d, buffer + position, &max_buffer, 0);
       if (c_status)
        {
          _NETCdebug ((fname,"Inc Error : <%s>\n", c_status));
          _NETSdebug ((fname,"Inc Error : <%s>\n", c_status));
          status = NET_E_SNI_SEND;
	ERRload_struct(NETS,status,"%s",c_status);
          _NETCdebug ((fname,"status = <0x%.8x>\n", status));
          _NETSdebug ((fname,"status = <0x%.8x>\n", status));
          return (status);
        }

       buffer_size -= XNS_MAX_SIZE;
       position += XNS_MAX_SIZE;
     }

    c_status = (char *) sni_txw (sni_d, buffer + position, &buffer_size, 0);
    if (c_status)
     {
          _NETCdebug ((fname,"Inc Error : <%s>\n", c_status));
          _NETSdebug ((fname,"Inc Error : <%s>\n", c_status));
          status = NET_E_SNI_SEND;
	ERRload_struct(NETS,status,"%s",c_status);
          _NETCdebug ((fname,"status = <0x%.8x>\n", status));
          _NETSdebug ((fname,"status = <0x%.8x>\n", status));
       return (status);
     }

    _NETCdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    _NETSdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    return (NET_S_SUCCESS);
  }


int NETvax_buffer_receive (sni_d, buffer, len)
  int   *sni_d;
  char  *buffer;
  int   *len;
  {
char *fname="NETvax_buffer_receive ";
    int     status;
    char    *c_status;
    int     position;
    int     buffer_size;
    int     max_buffer;
    _NETCdebug((fname,"SNI ID <%d> Buffer <%d> Length <%d>\n",*sni_d,buffer,*len));
    _NETSdebug((fname,"SNI ID <%d> Buffer <%d> Length <%d>\n",*sni_d,buffer,*len));

    max_buffer  = XNS_MAX_SIZE;
    buffer_size = *len;

    /* Maximum byte count NETwork can handle is 16K */
 
    position = 0;
    while (buffer_size > XNS_MAX_SIZE)
     {
       c_status = (char *) sni_rxw (sni_d, buffer + position, &max_buffer, 0);
       if (c_status)
        {
          _NETCdebug ((fname,"INC Error : <%s>\n", c_status));
          _NETSdebug ((fname,"INC Error : <%s>\n", c_status));
          status = NET_E_SNI_RECEIVE;
	ERRload_struct(NETS,status,"%s",c_status);
          _NETCdebug ((fname," status = <0x%.8x>\n", status));
          _NETSdebug ((fname," status = <0x%.8x>\n", status));
          return (status);
        }
       buffer_size -= XNS_MAX_SIZE;
       position += XNS_MAX_SIZE;
     }

    c_status = (char *) sni_rxw (sni_d, buffer + position, &buffer_size, 0);
    if (c_status)
     {
          _NETCdebug ((fname,"INC Error : <%s>\n", c_status));
          _NETSdebug ((fname,"INC Error : <%s>\n", c_status));
          status = NET_E_SNI_RECEIVE;
	ERRload_struct(NETS,status,"%s",c_status);
          _NETCdebug ((fname," status = <0x%.8x>\n", status));
          _NETSdebug ((fname," status = <0x%.8x>\n", status));
       return (status);
     }

    _NETCdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    _NETSdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
    return (NET_S_SUCCESS);
  }
