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

struct NFMglobal_st NFMglobal ;

 long NFMget_schema_envinfo (nodename,schema)
   char    *nodename;
   MEMptr  *schema ;

{
  long      status;
  char      *clh_status, *clh_vbyop ();
  
  char      rdbms_type [100], d_rdbms_type [100];
  char      ris_dir    [100], ris_db       [100];
  char      ris_net    [100], d_ris_net    [100];
  char      ris_l_usr  [100], d_ris_l_usr  [100];
  char      risdba_pwd [100], d_risdba_pwd [100];
  char      sch_name   [100], d_sch_name   [100];
  char      d_sch_pwd  [100];
  char      sch_pwd    [100];
  char      d_ris_s_name[100];
  char      temp_str   [100];
  char      node_name  [50] , address      [50] ;
  char      tcp_address [50], n_name       [50] ;
  long      NFMget_schema_buffer () ;
  static char *fname = "NFMget_schema_envinfo";
  
  sprintf (node_name, "nfme_%s", nodename) ;
  
  status = NFMget_schema_buffer (schema) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMget_schema_buffers failed <0x%.8x>\n", status));
      return (NFM_E_MEM) ;
    }
 

  status = MEMbuild_array (*schema) ;
  if (status != MEM_S_SUCCESS)
    {
      
      _NFMdebug ((fname, "MEMbuild_array failed status <0x%.8x>\n", status));
      return(NFM_E_MEM) ;
    }

     _NFMdebug ((fname, "Node Name = <%s>\n", node_name));

/*
        The following ifdef is added by MVR  on 19/11/93
*/
/* HP-PORT IGI 25 Aug 94 */
#if (!defined( OS_SUNOS) && !defined( OS_SOLARIS) && \
     !defined( OS_SCO_UNIX) && !defined(OS_HPUX))
     clh_status = clh_vbyop (node_name, "ADDRESS", address, 25);
     if (clh_status)

     {
       ERRload_struct (NETS, NET_E_MESSAGE,"%s",clh_status);
       status = ERRload_struct (NFM, NFM_E_CLH, "%s%s","ADDRESS", node_name) ;
_NFMdebug ((fname, "Get Nodename of risschema file : status =<0x%.8x>",NFM_E_CLH));
        return (NFM_E_CLH);
      }


     sprintf (temp_str, "%*.*s", 25, 25, address); 
     
       status = MEMwrite_data (*schema,address, 1, 1) ;
       if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite_data status <0x%.8x>\n", status));
	 return (NFM_E_MEM) ;
       }
#endif
      
/*     MEMprint_buffer ("test", *schema, "file1") ; */

/**********/
/* here change*/


/*      The last parameter is changed to 16 from 15
        the tcp_address may extend to 15 characters maximum and we need
        one char for string terminator  --  MVR */

     clh_status = clh_vbyop (node_name, "tcp_address", tcp_address, 16);
     if (clh_status)
      {
/*        strncpy (NETmsg_ptr.error_msg, clh_status, 78);
        NETmsg_ptr.error_msg [79] = 0;
        NETmsg_ptr.error_no = NET_E_CLH_LOOKUP_FAILED;

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get tcp address : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
 */
	strcpy (temp_str, "") ;
      } 
     else
         sprintf (temp_str, "%*.*s", 15, 15, tcp_address); /* here to */

      _NFMdebug ((fname, "tcp address is <%s>\n", temp_str));

     status = MEMwrite_data (*schema, temp_str, 1, 2) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite_data 0x%.8x\n", status));
	 return (NFM_E_MEM) ;
       }

/*    size changet to 26 from 25 on 19/11/93 for SUN/SCO port  -- MVR */
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     clh_status = clh_vbyop (node_name,  "nodename",  n_name,  26);
#else
     clh_status = clh_vbyop (node_name,  "nodename",  n_name,  25);
#endif

     if (clh_status)
      {

        ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
        status = ERRload_struct (NFM, NFM_E_CLH, "%s%s",
                              "Nodename", node_name) ;
  _NFMdebug ((fname, "Get Nodename of risschema file : status =<0x%.8x>", NFM_E_CLH));
        return (NFM_E_CLH);
      }

 /*      rdbms_type not yet obtained.  Redundant stmt MVR 19/11/93 */	
     sprintf (temp_str, "%*.*s", 25, 25, rdbms_type);

     status = MEMwrite_data (*schema, n_name, 1, 3) ;  /*was 3 */  
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite_data 0x%.8x\n", status));
	 return (NFM_E_MEM) ;
       }
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     clh_status = clh_vbyop (node_name, "NETPROP11", rdbms_type, 26);
#else
     clh_status = clh_vbyop (node_name, "NETPROP11", rdbms_type, 25);
#endif

     if (clh_status)
      {
	strcpy(temp_str, "");
      }
      else
       {
          sprintf (temp_str, "%*.*s", 25, 25, rdbms_type);
     
/*     strcpy (d_rdbms_type, rdbms_type);*/

     status = NFMdecrypt (temp_str, d_rdbms_type);
     if (status != NFM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname, "Get SID : status = <0x%.8x>\n",status));
        return (status);
      }
       
     _NFMdebug ((fname, "database type is <%s>\n", d_rdbms_type));

     status = MEMwrite_data (*schema, d_rdbms_type, 1, 4) ; /* was 4 */
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite_data <0x%.8x>\n", status));
	 return (NFM_E_MEM) ;
       }
}
/********/

/*     clh_status = clh_vbyop (node_name, "NETPROP12", sid, 25);
     if (clh_status)

      {
        strncpy (NETmsg_ptr.error_msg, clh_status, 78);
        NETmsg_ptr.error_msg [79] = 0;
        NETmsg_ptr.error_no = NET_E_CLH_LOOKUP_FAILED;

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get NETPROP12 : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
      }

     sprintf (temp_str, "%*.*s", 25, 25, sid);

     status = NFMdecrypt (temp_str, d_sid);
     if (status != NFM_S_SUCCESS)
      {

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get SID : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
      }

     sprintf (temp_str, "%*.*s", 25, 25, sid);

     status = MEMwrite_data (*schema, d_sid, 1, 5) ;
     if (status !=MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite_data <0x%.8x>\n", status));
	 return (NFM_E_MEM) ;
       }
*/
/**********/
/*
     clh_status = clh_vbyop (node_name, "NETPROP13", ris_dir, 50);

     if (clh_status)

     _NFMdebug ((fname, "rdbms directory is <%s>\n", ris_dir));

     status = MEMwrite_data (*schema, ris_dir, 1, 5) ;  was 6 
     if (status!= MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite_data <0x%.8x>\n", status));
	 return (NFM_E_MEM) ;
       }
*/
/**********/
/*
     clh_status = clh_vbyop (node_name, "NETPROP14", ris_db, 50);
     if (clh_status)

     _NFMdebug ((fname, "database name is <%s>\n", ris_db));

     status = MEMwrite_data (*schema, ris_db, 1, 6) ;  was 7 
     if (status!=MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite_data <0x%.8x>\n", status));
	 return (NFM_E_MEM) ;
       }
*/
/**********/

/*     clh_status = clh_vbyop (node_name, "NETPROP15", ris_node, 25);

     if (clh_status)
       {
        strncpy (NETmsg_ptr.error_msg, clh_status, 78);
        NETmsg_ptr.error_msg [79] = 0;
        NETmsg_ptr.error_no = NET_E_CLH_LOOKUP_FAILED;

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get RIS Node : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (temp_str, "%*.*s", 25, 25, ris_node);


     status = NETdecrypt (temp_str, d_ris_node);
     if (status != NET_S_SUCCESS)
      {
        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Decr Ris Node : status = <0x%.8x>\n", status));
        return(status);
      }

     _NFMdebug ((fname, "ris node is <%s>\n", d_ris_node));

     status = MEMwrite_data (*schema, d_ris_node, 1, 8) ;
     if (status!=MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite_data <0x%.8x>\n", status));
	 return (NFM_E_MEM) ;
       }
*/
/**********/
/*      size changet to 26 from 25 on 19/11/93 for SUN/SCO -- MVR */
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     clh_status = clh_vbyop (node_name,  "NETPROP16",  ris_net,  26);
#else
     clh_status = clh_vbyop (node_name, "NETPROP16", ris_net, 25);
#endif
     if (clh_status)
       {
/*	
        strncpy (NETmsg_ptr.error_msg, clh_status, 78);
        NETmsg_ptr.error_msg [79] = 0;
        NETmsg_ptr.error_no = NET_E_CLH_LOOKUP_FAILED;

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get RIS Net : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
*/
        strcpy(temp_str, "");
      }
         
       sprintf (temp_str, "%*.*s", 25, 25, ris_net);

       /*
          For now we are hard coding this property as TCP for the SUN/SCO.
          Hence we need not decrypt this property. MVR
       */
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
        strcpy(d_ris_s_name,ris_net); /* This is a work around MVR */
#else
       if((status = NFMdecrypt (temp_str, d_ris_s_name)) != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "Decr Ris Net : status = <0x%.8x>\n", NFM_E_NET));
          status = NFM_E_NET;
          status = ERRload_struct (NFM,status, "", NULL);
          return (status);
        }

         _NFMdebug ((fname, "ris node is <%s>\n", d_ris_s_name));
#endif
         if((status = MEMwrite_data (*schema, d_ris_s_name, 1, 7)) != MEM_S_SUCCESS)
         {
	  _NFMdebug ((fname, "MEMwrite_data <0x%.8x>\n", status));
	  status = NFM_E_MEM;
          status = ERRload_struct (NFM,status, "", NULL);	  
          return (status) ;
         }

         if((status = MEMwrite_data (*schema, d_ris_s_name, 1, 7)) != MEM_S_SUCCESS)
         {
	  _NFMdebug ((fname, "MEMwrite_data <0x%.8x>\n", status));
	  status = NFM_E_MEM;
          status = ERRload_struct (NFM,status, "", NULL);	  
          return (status) ;

         }

/**********/
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     clh_status = clh_vbyop (node_name, "NETPROP17", ris_l_usr, 26);
#else
     clh_status = clh_vbyop (node_name, "NETPROP17", ris_l_usr, 25);
#endif
     if (clh_status)
      {

        ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
        status = ERRload_struct (NFM, NFM_E_CLH, "%s%s",
                       "Nodename", node_name) ;
 _NFMdebug ((fname, "Get Nodename of risschema file : status = <0x%.8x>",NFM_E_CLH));
        return (NFM_E_CLH);
      }

     sprintf (temp_str, "%*.*s", 25, 25, ris_l_usr);


     status = NFMdecrypt (temp_str, d_ris_l_usr);

     if (status != NFM_S_SUCCESS)
      {
        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Decr Ris User : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
      }


      _NFMdebug ((fname, "ris node is <%s>\n",  d_ris_l_usr));

     status = MEMwrite_data (*schema,  d_ris_l_usr,  1,  8) ;
     if (status!=MEM_S_SUCCESS)
      {
         _NFMdebug ((fname, "MEMwrite_data <0x%.8x>\n",  status));
         return (NFM_E_MEM) ;
       }

/*      size changet to 26 from 25 on 19/11/93 for SUN/SCO -- MVR */
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     clh_status = clh_vbyop (node_name,  "NETPROP18",  ris_l_usr,  26);
#else
     clh_status = clh_vbyop (node_name, "NETPROP18", ris_l_usr, 25);
#endif
     if (clh_status)
       {

        ERRload_struct (NFM, NFM_E_NET, "%s%s", "clh_vbyop", clh_status);
        _NFMdebug ((fname, "clh_vboyp : status = <%s>\n", clh_status));
        _NFMdebug ((fname, "Returning : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
      }

     sprintf (temp_str, "%*.*s", 25,25, ris_l_usr);

     _NFMdebug ((fname, "network protocol type is <%s>\n", d_ris_l_usr));

     status = NFMdecrypt (temp_str, d_ris_l_usr);
     if (status != NFM_S_SUCCESS)
       {

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Decr Ris U Pwd : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
      }
     _NFMdebug ((fname, "ris node is <%s>\n", d_ris_l_usr));

     status = MEMwrite_data (*schema,  d_ris_l_usr,  1,  9) ;
     if (status!=MEM_S_SUCCESS)
       {
         _NFMdebug ((fname, "MEMwrite_data <0x%.8x>\n", status));
         return (NFM_E_MEM) ;
       }

/*     clh_status = clh_vbyop (node_name, "NETPROP19", risdba_pwd, 25);
     if (clh_status)

       {

        strncpy (NETmsg_ptr.error_msg, clh_status, 78);
        NETmsg_ptr.error_msg [79] = 0;
        NETmsg_ptr.error_no = NET_E_CLH_LOOKUP_FAILED;

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get RISDBA Pwd : status = <0x%.8x>\n", status));
        return(status);
       }
     status = MEMwrite_data (*schema, d_risdba_pwd, 1, 13) ;
     if (status!=MEM_S_SUCCESS)
       {
	 return (NFM_E_MEM) ;
       }
*/
/*******/

/*      size changet to 26 from 25 on 19/11/93 for SUN/SCO -- MVR */
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     clh_status = clh_vbyop (node_name,  "NETPROP20",  risdba_pwd,  26);
#else
     clh_status = clh_vbyop (node_name, "NETPROP20", risdba_pwd, 25);
#endif
     if (clh_status)
      {

        ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status);
        ERRload_struct (NFM, NFM_E_NET, "%s%s","nfm schema name", node_name);
        _NFMdebug ((fname, "Get Schema Name : status = <0x%.8x>\n",
                        NFM_E_NET));
        return (NFM_E_NET);
      }

     sprintf (temp_str, "%*.*s", 25, 25, risdba_pwd);

  /* Store the encrypted schema passwd in a global variable.  */

/*     strcpy (NFMglobal.NFMsch_name, temp_str);*/

     status = NFMdecrypt (temp_str, d_risdba_pwd);
     if (status != NFM_S_SUCCESS)
      {

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get Schema Name : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);

       }


     status = MEMwrite_data (*schema, d_risdba_pwd, 1, 10) ; /* was 13 */
     if (status!=MEM_S_SUCCESS)
       {
	 return (NFM_E_MEM) ;
       }
/**********/

/*      The last parameter is changed to 26 from 25 */
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     clh_status = clh_vbyop (node_name, "NETPROP21", sch_name, 26);
#else
     clh_status = clh_vbyop (node_name, "NETPROP21", sch_name, 25);
#endif
     if (clh_status)
     {

      ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
      ERRload_struct (NFM, NFM_E_CLH, "%s%s","nfm schema password", node_name);
      _NFMdebug ((fname, "Get Schema Pwd : status = <0x%.8x>\n",NFM_E_CLH));
      return (NFM_E_CLH);
      }

     sprintf (temp_str, "%*.*s", 25, 25, sch_name);

  /* Store the encrypted schema passwd in a global variable.  */

/*     strcpy (NFMglobal.NFMsch_passwd, temp_str);*/

     status = NFMdecrypt (temp_str, d_sch_name);
     if (status != NFM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname, "Decr Sch Pwd : status = <0x%.8x>\n", status));
        return (status);
      }

     status = MEMwrite_data (*schema, d_sch_name, 1, 11) ;/* was 14 */
     if (status!=MEM_S_SUCCESS)
       {
	 return (NFM_E_MEM) ;
       }

/************/

/*     clh_status = clh_vbyop (node_name, "NETPROP22", nfm_s_pwd, 25);
     if (clh_status)
      {
        strncpy (NETmsg_ptr.error_msg, clh_status, 78);
        NETmsg_ptr.error_msg [79] = 0;
        NETmsg_ptr.error_no = NET_E_CLH_LOOKUP_FAILED;

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get Schema Pwd : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (temp_str, "%*.*s", 25, 25, nfm_s_pwd);


     status = NETdecrypt (temp_str, d_nfm_s_pwd);
     if (status != NET_S_SUCCESS)
      {
  
         status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
         status = NFM_E_NET;
         _NFMdebug ((fname, "Decr Sch Pwd : status = <0x%.8x>\n", status));
         return (status);
   
      }

     _NFMdebug ((fname, "schema password is <%s>\n", d_nfm_s_pwd));

     status = MEMwrite_data (*schema, d_nfm_s_pwd, 1, 15) ;
     if (status != MEM_S_SUCCESS)
       {
	 return (NFM_E_MEM) ;
       }
*/
/*************/
/*     clh_status = clh_vbyop (node_name, "NETPROP23", sch_user, 25);
     if (clh_status)
      {
        strncpy (NETmsg_ptr.error_msg, clh_status, 78);
        NETmsg_ptr.error_msg [79] = 0;
        NETmsg_ptr.error_no = NET_E_CLH_LOOKUP_FAILED;


        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get Schema Pwd : status = <0x%.8x>\n", status));
        return (status);
      }


     sprintf (temp_str, "%*.*s", 25, 25, sch_user);


     status = NETdecrypt (temp_str, d_sch_user);
     if (status != NET_S_SUCCESS)
     { 

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Decr Sch Pwd : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
     }
      
     status = MEMwrite_data (*schema, d_sch_user, 1, 16) ;
     if (status!=MEM_S_SUCCESS)
       {
	 return (NFM_E_MEM) ;
       }
*/
/*************/
 /*   clh_status = clh_vbyop (node_name, "NETPROP24", sch_pwd, 25);
     if (clh_status)
      {

        strncpy (NETmsg_ptr.error_msg, clh_status, 78);
        NETmsg_ptr.error_msg [79] = 0;
        NETmsg_ptr.error_no = NET_E_CLH_LOOKUP_FAILED;

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get Schema Pwd : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (temp_str, "%*.*s", 25, 25, sch_pwd);


     status = NETdecrypt (temp_str, d_sch_pwd);
     if (status != NET_S_SUCCESS)
      {

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Decr Sch Pwd : status = <0x%.8x>\n", status));
        return (status);
    }
       
     _NFMdebug ((fname, "schema password is <%s>\n", d_sch_pwd));

     status = MEMwrite_data (*schema, d_sch_pwd, 1, 17) ;
     if (status!=MEM_S_SUCCESS)
       {
	 return (NFM_E_MEM) ;
       }
*/
/*************/
/*     clh_status = clh_vbyop (node_name, "NETPROP25", def_ris_sch, 25);
     if (clh_status)

      {

        strncpy (NETmsg_ptr.error_msg, clh_status, 78);
        NETmsg_ptr.error_msg [79] = 0;
        NETmsg_ptr.error_no = NET_E_CLH_LOOKUP_FAILED;

        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get Schema Pwd : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (temp_str, "%*.*s", 25, 25, def_ris_sch);

     status = NETdecrypt (temp_str, d_def_ris_sch);
     if (status != NET_S_SUCCESS)
      {
        status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
        status = NFM_E_NET;
        _NFMdebug ((fname, "Get Schema Pwd : status = <0x%.8x>\n", NFM_E_NET));
        return (NFM_E_NET);
      }

  
     _NFMdebug ((fname, "schema password is <%s>\n", d_def_ris_sch));

     status = MEMwrite_data (*schema, d_def_ris_sch, 1, 18) ;
     if (status !=MEM_S_SUCCESS)
       {
	 return (NFM_E_MEM) ;
       }
*/
/**************/

  /*   MEMprint_buffer ("mem", *schema, "/dev/console") ;*/

     return (NFM_S_SUCCESS) ;
   }


 long NFMget_schema_buffer (attr_list)
   MEMptr    *attr_list;
   {
     long   status;
     int    i;
     char   str [100] ;
     static char *fname = "NFMget_schema_buffer";

     _NFMdebug ((fname, "ENTER\n"));
     
     /* Open attr_list buffer  */ 

     status = MEMopen (attr_list, 10 * MEM_SIZE);
     if (status !=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
         return (status);          
       }
      
      status = MEMwrite_format (*attr_list, "ADDRESS", "char(26)");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      status = MEMwrite_format (*attr_list, "tcp_address", "char(15)");/*here*/
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      status = MEMwrite_format (*attr_list, "Nodename", "char(40)");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

     
      status = MEMwrite_format (*attr_list, "NETPROP11", "char(25)");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

/*
      status = MEMwrite_format (*attr_list, "NETPROP12", "char(25)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }
*/
     status = MEMwrite_format (*attr_list, "NETPROP13", "char(50)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

     status = MEMwrite_format (*attr_list, "NETPROP14", "char(50)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }
/*
      status = MEMwrite_format (*attr_list, "NETPROP15", "char(25)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }
*/

      status = MEMwrite_format (*attr_list, "NETPROP16", "char(25)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }


      status = MEMwrite_format (*attr_list, "NETPROP17", "char(25)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      status = MEMwrite_format (*attr_list, "NETPROP18", "char(25)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }
/*
      status = MEMwrite_format (*attr_list, "NETPROP19", "char(25)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }
*/
      status = MEMwrite_format (*attr_list, "NETPROP20", "char(25)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status =<0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      status = MEMwrite_format (*attr_list, "NETPROP21", "char(25)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }
/*
      status = MEMwrite_format (*attr_list, "NETPROP22", "char(25)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }
      status = MEMwrite_format (*attr_list, "NETPROP23", "char(25)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }
      status = MEMwrite_format (*attr_list, "NETPROP24", "char(25)");
      if (status!=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }
      status = MEMwrite_format (*attr_list, "NETPROP25", "char(25)");
      if (status !=MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }
*/
     str [0] = 0 ;

     for (i=0; i<11; i++)
	 strcat (str, "\1") ;


     status = MEMwrite (*attr_list, str) ;
     if (status!=MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMwrite failed <0x%.8x>\n", status));
	 return (NFM_E_MEM) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));

      return (NFM_S_SUCCESS);
   }












