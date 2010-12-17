#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>


char *fmu_connect (node)
  char *node;
{
  return (NULL);
}

char *fmu_disconnect ()
{
  return (NULL);
}


char *fmu_send (srcfile, dstfile)
  char *srcfile;
  char *dstfile;
{
  return (NULL);
}

char *fmu_receive (srcfile, dstfile)
  char *srcfile;
  char *dstfile;
{
  return (NULL);
}

char *fmu_set (mode)
  char *mode;
{
  return (NULL);
}

char *fmu_rcmd (command)
  char *command;
{
  return (NULL);
}

char *sni_connect (sni_d, node_pc, sernum_s, server_pc)
  int *sni_d;
  char *node_pc;
  unsigned short sernum_s;
  char *server_pc;
{
  return (NULL);
}

char *sni_accept (sni_d)
  int *sni_d;
{
  return (NULL);
}

char *sni_close (sni_d)
  int *sni_d;
{
  return (NULL);
}

char *sni_rxw (sni_d, buffer, len, timeout_l)
  int *sni_d;
  char *buffer;
  int *len;
  long timeout_l;
{
  return (NULL);
}

char *sni_txw (sni_d, buffer, len, timeout_l)
  int *sni_d;
  char *buffer;
  int *len;
  long timeout_l;
{
  return (NULL);
}



low_case (istr, ostr)
char  istr[];
char  ostr[];
{
     int   i,
           len;

     len = strlen (istr);
     if (istr)
     {
	 for (i=0; i<len; ++i)
         {
	     if ( istr[i] >= 'A' && istr [i] <= 'Z') 
                 ostr [i] = istr [i] - 'A' + 'a';
	     else
                 ostr [i] = istr [i];
	   }
     }
     ostr [len] = '\0';
}


ncl_lkp_prop()
{
   
   return(NULL);
}

SWAP_BYTE_ARRAY ()
{
/* _NFMdebug (("NFM SWAP_BYTE_ARRAY", "SWAP_BYTE_ARRAY is stubbed in NFMfmustubs.c\n")); */
   return(NULL);
}


/* temp stub to resolve the non availability of BSD bcopy in some lib
	for the solaris SVR version - TVK 04/01/1994 */

void bcopy (register char *s1, register char *s2, int len)
{
	memcpy (s2, s1, (size_t) len);
}
