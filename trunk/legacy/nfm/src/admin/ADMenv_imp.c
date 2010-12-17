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
#include "NFMstruct.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"
#include "NFMschema.h"

/* long NFM_PL_LOCK  =0603; */

char  NODE_NAME[100];
struct NFMglobal_st NFMglobal ;

 long ADMget_import_info (nodename,local_passwd)
   char     *nodename;
   char     *local_passwd;
{
  long      status;
  char      *clh_status, *clh_vbyop ();

  char       nfm_usr  [100] , d_nfm_usr[100];
  char      nfm_pwd   [100],  d_nfm_pwd[100];
  char      n_name    [100];
  char      rdbms_type[100];
  char      temp_str  [100];
  char      env_name  [100];
  char      node_name  [50] , address      [50] ;
  char      *dbpath;
  char      make_env[100];

  static char *fname = "ADMget_import_info";

      sprintf (node_name, "nfme_%s", nodename);
      _NFMdebug((fname, "This Is env Name %s\n", node_name));

      clh_status = clh_vbyop (node_name, "nodename", NODE_NAME, 25);

      if (clh_status)
       {

         _NFMdebug((fname, "This is : <%s>\n", clh_status));
         ERRload_struct (NFM, NFM_E_BAD_TEMPLATE, NULL, NULL) ;
         _NFMdebug ((fname, "Node Name Not Defined : status =<0x%.8x>", NFM_E_CLH));
        return (NFM_E_BAD_TEMPLATE);
      }
	
     sprintf (temp_str, "%*.*s", 25, 25, NODE_NAME);
/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
     clh_status = clh_vbyop (node_name, "NETPROP17", nfm_usr, 26);
#else
     clh_status = clh_vbyop (node_name, "NETPROP17", nfm_usr, 25);
#endif

     if (clh_status)
      {
       _NFMdebug((fname, "This is sec clh_status: <%s>\n", clh_status));
       ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
       status = ERRload_struct (NFM, NFM_E_CLH, "%s%s", nfm_usr, node_name) ;
       _NFMdebug ((fname, "CLH_VBYOP:User Name: status = <0x%.8x>",NFM_E_CLH));
        return (NFM_E_CLH);
      }

     sprintf (temp_str, "%*.*s", 25, 25, nfm_usr);


     status = NFMdecrypt (temp_str, d_nfm_usr);

     if (status != NFM_S_SUCCESS)
      {
        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Decr Ris User : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
      }

/* HP-PORT IGI 25 Aug 94 */
#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) || defined(OS_HPUX))
     clh_status = clh_vbyop (node_name, "NETPROP18", nfm_pwd, 26);
#else
     clh_status = clh_vbyop (node_name, "NETPROP18", nfm_pwd, 25);
#endif

     if (clh_status)
       {
        _NFMdebug((fname, "This Is a Third clh_status : <%s>\n", clh_status));
        ERRload_struct (NFM, NFM_E_NET, "%s%s", "clh_vbyop", clh_status);
        _NFMdebug ((fname, "clh_vboyp : status = <%s>\n", clh_status));
        _NFMdebug ((fname, "Returning : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
      }

     sprintf (temp_str, "%*.*s", 25,25, nfm_pwd);
     _NFMdebug((fname, "this a nfmpassws <%s>", nfm_pwd));     

     status = NFMdecrypt (temp_str, d_nfm_pwd);

     if (status != NFM_S_SUCCESS)
       {

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Decr Ris U Pwd : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
      }

     status =ADMimport_env(NODE_NAME,d_nfm_usr,d_nfm_pwd,&node_name[5],local_passwd, dbpath , make_env);
     if (status != NFM_S_SUCCESS)
     {
        _NFMdebug (( fname, "Status is :<0x%.8x>\n", status));
         return(NFM_E_FAILURE);
     }
     return (NFM_S_SUCCESS);
}


