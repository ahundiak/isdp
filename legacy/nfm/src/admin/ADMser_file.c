#include "machine.h"
#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include "MEMstruct.h"
#include "NETstruct.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "MSGstruct.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"
#include <pwd.h>

/* included for SUN/SCO port - SSRS - 7/12/93 */
/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
#include "NFMenv.h"
#endif

/* long NFM_PL_LOCK  =0603; */

int  NFM_SER_ENV = 0;
char NFM_SRV_NODE[100];
char NFM_ENV_NODE[100];

long ADMcreate_server (sername, tcp_net)
   char    *sername;
   char    *tcp_net;
{
  long      status;
  char      *clh_status, *clh_vbyop ();

  int       i;
  char      ch;  
  char      ser_name  [50] , address      [50] ;
  char      tcp_address [50], NAME_SER       [50] ;
  char      encr_user[41], encr_pass[41];
  FILE      *fopen(), *in_file;
  struct passwd *pwd;

  static char *fname = "ADMcreate_server";
  
/*  strcpy (sername, "dummy") ;*/

/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
     /* This code writes node information to file NFMser.dat,  instead of
         writing to  file /usr/lib/nodes/owned/nfms_*.
        SSRS - 7/12/93
     */
     pwd = getpwnam( "nfmadmin" );
     sprintf (ser_name,  "%s/%s/%s",  pwd->pw_dir, ENV_PATH,  SER_FILE);
      clh_status = (char *) clh_vbyop ("TEMPLATE",  "NODENAME", NAME_SER,  25);
      if (clh_status)
      {
        ERRload_struct (NETS,  NET_E_MESSAGE,  "%s",  clh_status) ;
        status = ERRload_struct (NFM,  NFM_E_CLH,  "%s%s", "TEMPLATE",  "NODENAME");
       _NFMdebug ((fname,  "Get Nodename of Server: status = <0x%.8x>", 
        NFM_E_CLH));
        return (NFM_E_CLH);
      }

       for (i = 0; i < strlen (NAME_SER); ++i)
      {
        ch = tolower (NAME_SER [i]);
         NAME_SER [i] = ch;
      }

     if ((in_file = fopen (ser_name,  "a")) == NULL)
      {
        status = NET_E_OPEN_FILENAME;
        ERRload_struct(NETS, status, "%s", ser_name);
        return (status);
      }

      fprintf(in_file,  "nfms_%s\1%s\1NFM\1\n",  sername,  NAME_SER);

#else
  sprintf (ser_name, "/usr/lib/nodes/owned/nfms_%s", sername) ;

  _NFMdebug ((fname, "Server Name = <%s>\n", ser_name));

     if ((in_file = fopen (ser_name, "w"))==NULL)
     {
      unlink (ser_name);
      status = NET_E_OPEN_FILENAME;
      _NETCdebug ((fname,"File Open Failed File = <%s>  : status = <0x%.8x>\n",ser_name, status));
        ERRload_struct(NETS,status,"%s",sername);
        return (status);
      }   
       clh_status = clh_vbyop ("TEMPLATE", "NODENAME", NAME_SER, 25);
       if (clh_status)

      {
        ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
        status = ERRload_struct (NFM, NFM_E_CLH, "%s%s", 
        "TEMPLATE", "NODENAME");
       _NFMdebug ((fname, "Get Nodename of Server: status = <0x%.8x>",
        NFM_E_CLH));
        return (NFM_E_CLH);
      }


/**********/

     clh_status = clh_vbyop (NAME_SER, "Address", address, 25);
   
     if (clh_status) 
      {
 
         ERRload_struct (NETS, NET_E_MESSAGE,"%s",clh_status);
        status = ERRload_struct (NFM, NFM_E_CLH, "%s%s","Address",NAME_SER) ;
        _NFMdebug ((fname, "Get Address of risschema file : status =<0x%.8x>",
            NFM_E_CLH));
        return (NFM_E_CLH);
      }

        fprintf (in_file, "Address      : %s\n", address);

     if (strlen (tcp_net))
     {
      /* The last parameter is changed to 16 from 14 to fit any	dotted decima\
	l */
      /* address  MVR 19/11/93
      */

       clh_status = clh_vbyop (NAME_SER, "tcp_address", tcp_address, 16);
       if (clh_status)
        {
          ERRload_struct (NFM, NFM_W_NO_TCP_ADD, "%s", sername );
 _NFMdebug ((fname, "Get tcp address : message = %s : status = <0x%.8x>\n",
          clh_status, NFM_W_NO_TCP_ADD));
/*         return (NFM_E_NET);*/
        }
        else
         fprintf (in_file, "tcp_address  :%s\n", tcp_address); 
         fprintf (in_file, "Nodename     :%s\n", NAME_SER);

    }  
#endif

     status = fclose (in_file);
     if (status)
     {
        status = NET_E_CLOSE_FILE;
        _NFMdebug ((fname, " File Close : status = <0x%.8x>\n", status));
        ERRload_struct(NETS,status,"%s",in_file);
        return (status);
      }
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
/*    if (status == NFM_W_NO_TCP_ADD)
     return (status)
    else*/
     return (NFM_S_SUCCESS) ;
   }

