#include "machine.h"
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>


char *fmu_connect (node)
  char *node;
{
  return("FMU does not exist on SUN/SCO"); /* SSRS */
}

char *fmu_disconnect ()
{
  return("FMU does not exist on SUN/SCO"); /* SSRS */
}


char *fmu_send (srcfile, dstfile)
  char *srcfile;
  char *dstfile;
{
  return("FMU does not exist on SUN/SCO"); /* SSRS */
}

char *fmu_receive (srcfile, dstfile)
  char *srcfile;
  char *dstfile;
{
  return("FMU does not exist on SUN/SCO"); /* SSRS */
}

char *fmu_set (mode)
  char *mode;
{
  return("FMU does not exist on SUN/SCO"); /* SSRS */
}

char *fmu_rcmd (command)
  char *command;
{
  return("FMU does not exist on SUN/SCO"); /* SSRS */
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

#if defined(OS_SCO_UNIX)

/* The following functions are stubbed out for SCO only.*/

/* Help functions are not available on SCO. So we are stubbing out these set of
   help functions. SSRS 24 Feb 94 */
#include <helpif.h>
#include <helpifproto.h>

int Help_kill (void)
{
}
int Help_origin (int xorigin, int yorigin)
{
}
int Help_remove (void)
{
}
int Help_status (struct HP_status_struct *status_ptr)
{
}
int Help_defaults (struct HP_defaults_struct *defaults)
{
}
int Help_display (void){ }
int Help_toc (void){ }
int Help_topic (char *logical_name){ }
int Help_set_topic (char *topic_logical_name){ }
int Help_document (struct HP_doc_id_struct *doc_id){ }
int Help_pass_through_signal (int signal_number,  
                              void  (*data_rec_function )(), 
                              char *data_buffer,int size){ }
int Help_pass_through_get (char *data, int size){ }
int Help_set_Xdisplay (char *xdisplay_name){ }
int Help_active(int *status_in){ }
struct HP_status_struct *Help_init_status(){ }
int Help_free_status(struct HP_status_struct *h_stat_struck){ }
int Help_hc(char **source_file_names,char **search_path,
            char *title_string,char *doc_id_string,
            char *compiled_file_name, unsigned int options,
            char ***messages){ }

#endif
