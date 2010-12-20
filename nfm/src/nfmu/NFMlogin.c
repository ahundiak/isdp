#ifndef OS_SOLARIS
#define OS_SOLARIS
#endif

#include <glib.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "NFMapi.h"
#include "NFMU.h"
#include "NFMfto_buf.h"
#include "NFMstruct.h"
#include "NFMsysstruct.h"
#include "NFMitems.h"
#include "NFMflag.h"

#include "UTIerrordef.h"

#include "MEMproto.h"

#include "MSGstruct.h"
#include "WFstruct.h"
#include "WFproto.h"

#include "SQLproto.h"
#include "SYSTproto.h"

#include "CMDTOOLS.h"
#include "CMDTproto.h"
#include "NFTproto.h"

extern int _SQLglobal_init () ;

 struct NFMglobal_st NFMglobal ;

 long NFM_PL_LOCK   = 0603;
 extern long SQLstmt_count ;
 extern long SQLquery_count;

 extern long SQLcursor[41];
 extern long SQLcursor_count[41];

 MEMptr  NFMcomm_ptr = NULL;

 MEMptr  NFMwf_ptr      = NULL, NFMst_ptr = NULL;
 MEMptr  NFMcl_ptr      = NULL, NFMtr_ptr = NULL, NFMac_ptr = NULL;

 MEMptr  NFMacl_ptr     = NULL, NFMaclusr_ptr  = NULL;
 MEMptr  NFMaclsign_ptr = NULL, NFMsignoff_ptr = NULL ;

 MEMptr  NFMproc_ptr = NULL;

 MEMptr  NFMnodes_ptr = NULL;
 MEMptr  NFMstor_ptr = NULL;
 MEMptr  NFMusrs_ptr = NULL;

 MEMptr  NFMloc_ptr = NULL;
 MEMptr  NFMlop_ptr = NULL;

 long       NFMprocess_id;

/*    GLOBAL VARIABLES    */
 extern char NFM_WF_CACHED[]; 
 extern char NFMenv_logged[]; 
 int  NFM_SRV_ENV = 0;
 char NFM_SRV_NODE[100];      /* nodename of server */
 char NFM_ENV_NODE[100];      /* nodename where schema definition(risschema) */
                              /* for environment resides */

 long DM_MANAGER = 0;         /* Flag indicating if client is  DM/Manager */
 long PDM_VAULT_VERSION = 0;
 long PDMVAULT_DONT_TYPE_SET = 0;
 long DM_VAULT_VERSION = 0;
 

/*  char NFM_ENV_NAME [100]; */    /* environment name */
 char NFM_ENV_FILE [100];     /* environment file */

 
/* FTR init successful/failure flag */

 long NFM_FTR_INITED = 0;

 long NFMlog_in(user_name, passwd, environment, application)
  char *user_name ;
  char *passwd ;             /* decrypted password */
  char *environment ;        /* nfme_environment */
  char *application ;
{
      static char *fname = "NFMlog_in" ;
      long     status, user_id, atol ();
      char     sql_str [1024], e_passwd [60] ;
      MEMptr   list = NULL ;
      char     schema_name[100];
      char     **data ;
      long     user_no, t, offsett, x ;
      char     value [100] ;
/*      struct   fto_buf file_buffer ; */
      long     NFMlogoff ();
      long     NFMget_schema_info ();
      long NFMget_syscat_configuration ();
      long NFMget_db_info () ;
      long NFMfix_queries() ;
      long _NFMcheck_vault_version_number ();
      long sa_no=0;
      char sa_name[NFM_SANAME+1], node[NFM_NODENAME+1], user[NFM_USERNAME+1],
                 sa_passwd[NFM_PASSWD+1], path [NFM_PATHNAME+1],
                 device[NFM_DEVICETYPE+1], platter[NFM_PLATTERNAME+1],
                 partition[NFM_PARTITION+1], nfs[NFM_NFS+1],
                 compress[NFM_COMPRESS+1],
                 machid[NFM_MACHID+1], opsys[NFM_OPSYS+1], tcpip[NFM_TCPIP+1],
                 xns[NFM_XNS+1], decnet[NFM_DECNET+1], netware[NFM_NETWARE+1];
      char ftr_path[NFM_PATHNAME+10], *found_str;
      long back_slash;


      _NFMdebug ((fname, "username %s : environment %s : application %s\n",
		  user_name, environment, application)) ;

      g_message("NFMlog_in for %s",user_name);
      
      strcpy (NFMglobal.application, application) ;
      if (strcmp (user_name, "PUBLIC") == 0)
	{
	  _NFMdebug ((fname, "CAN NOT LOGIN AS PUBLIC\n")) ;
	  ERRload_struct (NFM, NFM_E_CANNOT_LOG_AS_PUBLIC, "", "") ;
	  return  (NFM_E_CANNOT_LOG_AS_PUBLIC) ;
	}

      _WFinit_wfinfo_login ();
      _SQLglobal_init () ;
/*
      Change The RISDBA On The Current Server
             For The Appropriate Environment.
*/

/*      strcpy(NFM_ENV_NAME, &environment[5]) ; */
      strcpy(NFMglobal.environment_name, &environment[5]) ; 
      sprintf (NFM_ENV_FILE, "%s", environment) ;
      
      _NFMdebug ((fname, "environment name is %s : environment file is %s\n",
		  NFMglobal.environment_name, NFM_ENV_FILE)) ;

      /* default to schema */
      status = NFMget_schema_info (NFM_ENV_FILE,schema_name);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Schema Info1 : status = <0x%.8x>\n", status));
         return (status);
       }

      if(NFM_SRV_ENV)
      {
        _NFMdebug ((fname, "NFM Server and Environment are on the same machine %d : Server -> %s : Environment -> %s\n",
		    NFM_SRV_ENV, NFM_SRV_NODE, NFM_ENV_NODE));
      }
      else
      {
        _NFMdebug ((fname, "NFM Server and Environment are on different machines %d : Server -> %s :Environment -> %s\n",
		    NFM_SRV_ENV, NFM_SRV_NODE, NFM_ENV_NODE));
      }

      sprintf(sql_str,
	      "SELECT n_userno,n_passwd, n_username FROM nfmusers \
WHERE n_username = '%s' or n_username = 'PUBLIC'",
	      user_name) ;

      strcpy (NFMglobal.NFMusername, user_name) ;

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if (status != SQL_S_SUCCESS) 
       {
          MEMclose (&list);
          NFMlogoff ();

          /*   Bad Login */
          if ((status) == SQL_I_NO_ROWS_FOUND)
           {
              ERRload_struct (NFM, NFM_E_BAD_USER, "", NULL);
              _NFMdebug ((fname, "LOGIN : Bad LOGIN : status = <0x%.8x>\n", 
			  NFM_E_BAD_USER));
              return (NFM_E_BAD_USER);
           }

          /*      bad return from query             */

          ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
          _NFMdebug ((fname, "Query Syntax : status = <0x%.8x>\n",
		      status));
          return (NFM_E_SQL_QUERY);
       }

      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
       {
          MEMclose (&list);
          NFMlogoff ();
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          _NFMdebug ((fname, "Build Array : status = <0x%.8x>\n", 
		      status));
          return (NFM_E_MEM);
       }

      data = (char **) list -> data_ptr;
      user_no = -1 ;
      NFMglobal.PUBLIC_userno= -1 ;
      NFMglobal.NFMuserno = -1 ;
      for (t=0; t<list->rows; t++)
	{
	  offsett = t*list->columns ;
	  if (strcmp (data[offsett+2], NFMglobal.NFMusername) == 0)
	    {
	      user_no = atol (data [offsett]);
	      NFMglobal.NFMuserno = user_no ;
	      sprintf (value, "%-25.25s", data [offsett+1]);
	    }
	  else if (strcmp (data [offsett+2], "PUBLIC") == 0)
	    {
	      NFMglobal.PUBLIC_userno = atol (data [offsett]) ;
	    }
	}

      MEMclose (&list);

/*      _NFMdebug ((fname, "FOR TEST ONLY : User no <%d> : PUBLIC no <%d>\n",
		  NFMglobal.NFMuserno, NFMglobal.PUBLIC_userno)) ; 
*/

      if ((NFMglobal.NFMuserno == -1) || (NFMglobal.PUBLIC_userno == -1))
	{
	  if (NFMglobal.NFMuserno == -1)
	    {
	      _NFMdebug ((fname, "Bad user <%s>\n",
			  NFMglobal.NFMusername)) ;
	      ERRload_struct (NFM, NFM_E_USER_NOT_FOUND, "%s", 
                              NFMglobal.NFMusername);
	    }
	  else if (NFMglobal.PUBLIC_userno == -1)
	    {
	      _NFMdebug ((fname, "There is no PUBLIC user in schema\n")) ;
      	      ERRload_struct (NFM, NFM_E_USER_NOT_FOUND, "%s", 
                              "PUBLIC");
	    }
         NFMlogoff ();
	  _NFMdebug ((fname, "LOGIN : Bad LOGIN : status = <0x%.8x>\n", 
		      NFM_E_BAD_USER));
	  return (NFM_E_BAD_USER);
	}

      e_passwd [0] = 0;
      status = NFMdecrypt (value, e_passwd);
      if (status != NFM_S_SUCCESS)
       {
         NFMlogoff ();
         ERRload_struct (NFM, NFM_E_NET, "", NULL);
         _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n", status));
         return (status) ;
       }

      strcpy (NFMglobal.NFMpasswd, e_passwd) ;

      if (strcmp (passwd, e_passwd))
       {
         NFMlogoff ();
	 _NFMdebug ((fname, "Bad Password\n")) ;
         ERRload_struct (NFM, NFM_E_USER_PASSWD, "", NULL);
         return (NFM_E_USER_PASSWD);
       }

      NFMprocess_id = getpid ();

      _NFMdebug ((fname, "PID     = <%d>  : User No = <%d>\n",
		  NFMprocess_id, user_no)) ;

      user_id = (user_no << 16) | NFMprocess_id;
      NFMglobal.NFMuserid = user_id ;

      NFM_PL_LOCK = user_id;

      status = NFMget_db_info (schema_name);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get DB info : status = <0x%.8x>\n", status));
         return (status);
       }

      /* prepare 14 freq. used NFM queries */
/****************** mms - fix if needed ***********
      status = NFMfix_queries();
      if (status != NFM_S_SUCCESS)
       {
         NFMlogoff ();
	 ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
         _NFMdebug ((fname, "NFMfix_queries : status = <0x%.8x>\n", status));
         return (NFM_E_SQL_STMT) ;
       }
******************************************************/
/* set NFMglobal.administrator = 1 if user is an I/NFM administrator */

      sprintf (sql_str, "Select c.n_userno from nfmacls a, nfmworkflow b, nfmaclusers c, nfmclasses d where c.n_userno = %d and b.n_workflowname = 'NFM_ADMIN_WORKFLOW' and a.n_workflowno = b.n_workflowno and c.n_aclno = a.n_aclno and d.n_classname = 'administrator' and d.n_workflowno = b.n_workflowno",
	       NFMglobal.NFMuserno) ;

      status = SQLquery (sql_str, &list, MEM_SIZE) ;

      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  NFMlogoff() ;
	  MEMclose (&list) ;
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
		      status)) ;
	  return (NFM_E_SQL_QUERY) ;
	}

      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  NFMglobal.administrator = 0 ;
	}
      else
	{
	  NFMglobal.administrator = 1 ;
	}

      status = MEMclose (&list) ;
      if (status != MEM_S_SUCCESS)
	{
	  NFMlogoff() ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  _NFMdebug ((fname, "MEMclose : failed : status = <0x%.8x>\n",
		      status)) ;
	  return (NFM_E_MEM) ;
	}

      status =  NFMget_syscat_configuration ();
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failed : status = <0x%.8x>\n",status)) ;
	  return (status) ;
	}

      if (DM_MANAGER)
      {
        _NFMdebug ((fname, "check for the version of vault (DMM and PDM)\n"));
        status = _NFMcheck_vault_version_number ();
        if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "vault is not operable with DM/Manager\n"));
          return (status);
        }
      }

/********** mms - performance move elsewhere 07/01/92 *****
      status = _NFMget_sano_info_fto_buf (0, "NFMFILES",  &file_buffer) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}
      
      status = NFMbuild_fto_buffer (&buffer, MEM_SIZE) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}
       
      status = NFMload_fto_buf (&buffer, &file_buffer) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Loading first row failed : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}

      status = NFMload_local_sa (&buffer) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "load local sa failed : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}
**************************************************************/
      _NFMdebug ((fname, "Initialize FTR engine\n"));
      sa_name[0] = '\0'; sa_no = 4;
      status = NFMget_storage_info (sa_name, &sa_no, node, user,
                 sa_passwd, path, device, platter, partition, nfs, compress,
                 machid, opsys, tcpip, xns, decnet, netware);

      found_str = (char *) strrchr (path, '/' );

      _NFMdebug ((fname, "found_str %s \n", found_str));

      for (x = 0; x < (found_str - path); x++)
      {
        _NFMdebug ((fname, "path[%d] %c\n", x, path[x]));
        ftr_path[x] = path[x];
      }
      ftr_path[x] =  '/';
      ftr_path[x+1] =  '\0';
      _NFMdebug ((fname, "ftr_path [%s] \n", ftr_path));
      strcat (ftr_path, "dmd_ftr");

      _NFMdebug ((fname, "ftr_path [%s]\n", ftr_path));

      _NFMdebug ((fname, "Jujare--> NFT_init started .. \n"));
      status = NFT_init (NFM_ENV_NODE, ftr_path);
       _NFMdebug ((fname, "Jujare--> NFT_init over .. \n"));
      if (status == UTI_S_SUCCESS)
      {
        _NFMdebug ((fname, "Successfully initialized FTR engine\n"));
        NFM_FTR_INITED = 1;
      }
      else
      {
        _NFMdebug ((fname, "NFT_init 0x%.8x\n", status));
      }
      /* this is a bad solution, but UTI is the oly one available under the 
         DM 1.1 delivery time constraint */
      ERRreset_struct ();

      _NFMdebug ((fname, "user [%s] login SUCCESSFUL\n",
                  NFMglobal.NFMusername)) ;
      return (NFM_S_SUCCESS) ;
    }

#if 0
 long NFMget_schema_info (node_name, schema_name)
   char    *node_name;
   char    *schema_name;
   {
     static char *fname = "NFMget_schema_info" ;
     int       i;
     long      status, tmp_flag ;
     char      sql_str[200], *clh_status, *clh_vbyop ();
     char      sch_name   [100], d_sch_name   [100];
     char      sch_pwd    [100], d_sch_pwd    [100];
     char      temp_str   [100] ;
     long      NFMlogoff ();

     _NFMdebug ((fname, "Node Name = <%s>\n", node_name)) ;

     /* look up the node_name of the server */
     
     clh_status = clh_vbyop ("TEMPLATE", "NODENAME", NFM_SRV_NODE, 25);
     if (clh_status)
      {
	ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
        ERRload_struct (NFM, NFM_E_CLH, "%s%s",
		       "Nodename", "template");
        _NFMdebug ((fname, "Get Nodename of Server: status = <0x%.8x>\n",
        NFM_E_CLH));
        return (NFM_E_CLH);
      }

	/* look up the node_name of the environment */
	
     clh_status = clh_vbyop (node_name, "NODENAME", NFM_ENV_NODE, 25);
     if (clh_status)
      {
	ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
        ERRload_struct (NFM, NFM_E_CLH, "%s%s", "Nodename", node_name) ;
        _NFMdebug ((fname, "Get Nodename of risschema file : status = <0x%.8x>\n",
        NFM_E_CLH));
        return (NFM_E_CLH);
      }

     if ( strcmp (NFM_SRV_NODE, NFM_ENV_NODE) )
     {
     status = NFMwrite_ris_parameters (node_name,NFM_ENV_NODE) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "status = <0x%.8x>\n", status));
	 return (status) ;
       }
     }
     
     if(!strcmp(NFM_SRV_NODE,NFM_ENV_NODE)) NFM_SRV_ENV = 1;
     else  NFM_SRV_ENV = 0;
     /* size changed from 25 to 26 for SUN/SCO - SSRS - 15/11/93 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     clh_status = clh_vbyop (node_name,  "NETPROP20",  sch_name,  26);
#else
     clh_status = clh_vbyop (node_name,  "NETPROP20",  sch_name,  25);
#endif
     if (clh_status)
      {
	ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
        ERRload_struct (NFM, NFM_E_CLH, "%s%s", "I/NFM schema name", node_name);
        _NFMdebug ((fname, "Get Schema Name : status = <0x%.8x>\n",
        NFM_E_CLH));
        return (NFM_E_CLH);
      }

     sprintf (temp_str, "%*.*s", 25, 25, sch_name);

     /* Store the encrypted schema name in a global variable. */

     strcpy (NFMglobal.NFMsch_name, temp_str);

     status = NFMdecrypt (temp_str, d_sch_name);
     if (status != NFM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname, "Decrypy Schema Name : status = <0x%.8x>\n",
		    status));
        return (status) ;
      }

     strcpy (schema_name, d_sch_name) ;

    /* size changed from 25 to 26 for SUN/SCO - SSRS - 15/11/93 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     clh_status = clh_vbyop (node_name,  "NETPROP21",  sch_pwd,  26);
#else
     clh_status = clh_vbyop (node_name,  "NETPROP21",  sch_pwd,  25);
#endif
     if (clh_status)
      {
	ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
        ERRload_struct (NFM, NFM_E_CLH, "%s%s", 
				 "I/NFM schema password", node_name);
        _NFMdebug ((fname, "Get Schema Pwd : status = <0x%.8x>\n",
		  NFM_E_CLH));
        return (NFM_E_CLH);
      }

     sprintf (temp_str, "%*.*s", 25, 25, sch_pwd);

     /* Store the encrypted schema passwd in a global variable.  */

     strcpy (NFMglobal.NFMsch_passwd, temp_str);


     status = NFMdecrypt (temp_str, d_sch_pwd);
     if (status != NFM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname, "Decrypt Schema Password : status = <0x%.8x>\n",
		    status));
        return (status);
      }


     _NFMdebug ((fname, "Executing SET DATABASE ENABLE statement\n")) ;
     /* By excluding RD2 the ris locking default becomes no locking in
        all the tables used in a transaction just the ones to be locked */
     sprintf (sql_str, "SET DATABASE ENABLE ONLY INFORMIX, ORACLE, INGRES, DB2, SYBASE");
     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
       {
        NFMlogoff ();
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SET DATABASE ENABLE : status = <0x%.8x>\n",
                    status));
        return (NFM_E_SQL_STMT);
      }

     for( i=0; i<41; ++i )
     {
        SQLcursor_count[i] = 0;
        SQLcursor[i] = 0;
     }

     sql_str [0] = 0;
     
     SQLstmt_count = 0; SQLquery_count = 0;
       
     _NFMdebug ((fname, "Executing default schema statement\n")) ;
     _NFMdebug ((fname, "schname = %s schpwd = <NOT PRINTED>\n", d_sch_name)) ;
     tmp_flag = _NFMdebug_st.SQLdebug_on ;  
     _NFMdebug_st.SQLdebug_on = 0 ; 
     if (! strlen (d_sch_pwd))      
       sprintf (sql_str, "DEFAULT SCHEMA %s", d_sch_name);
     else
       sprintf (sql_str, "DEFAULT SCHEMA %s.%s", d_sch_name, d_sch_pwd);

/*     _NFMdebug ((fname, "sql_str = %s\n", sql_str)) ;
 - to avoid printing schema password through sql_str - PS
*/
     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
	_NFMdebug_st.SQLdebug_on = tmp_flag ;
        NFMlogoff ();
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "Default Schema : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }
     _NFMdebug_st.SQLdebug_on = tmp_flag ; 

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
  }

/******* get db information - if informix (online) exec dirty read ******/
/****** exec must never be in a middle of transaction, if this occurs ***/
/****** a "COMMIT WORK" needs to be issued before the exec -mms 02/02/92*/
 long NFMget_db_info (schema_name)
   char    *schema_name;
  {
     static char *fname = "NFMget_db_info" ;
     long      status;
     long      NFMlogoff ();
     char      sql_str[200];
     char      dbtype[2] ;

     _NFMdebug ((fname, "Schema Name = <%s>\n", schema_name)) ;
/********* mms - locking problem ***************
      status =  NFMglobal_ris_data (schema_name, dbtype) ;
      if (status != NFM_S_SUCCESS) 
	{
	  NFMlogoff ();
	  _NFMdebug ((fname, "status = <0x%.8x>\n", status));
	  return (status);
	}
***********************************************/
     status = SQLget_dbtype (schema_name, dbtype) ;
     if (status != SQL_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     /* get ris info for database name */
     /* if database is informix it should speed up read access -mms */

     SQLget_database_type (dbtype) ;
     
     _NFMdebug ((fname, "DB Type = <%s>\n", dbtype)) ;
     
     if (dbtype[0] == 'X')
      {
         sprintf (sql_str, "EXEC %s SET ISOLATION DIRTY READ", 
                  "INFORMIX");

        /* SSRS - 16/11/93 - The above statement is specific to Online engine.
                             The impact of the above statement is not known
                             exactly. Temporarily the execution of the above
                             statement is avoided for SUN.
       */
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS))
        status = SQLstmt (sql_str);
#endif
/*** mms - do not check status ; this query will fail with standard engine
           to distinguish standard engine Vs online extra processing is
           needed 
        if (status != SQL_S_SUCCESS)
         {
           free (sql_str);
           NFMlogoff ();
           _NFMdebug ((fname, "Lock Mode to Wait : status = <0x%.8x>\n",
           status));
	   ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
           return (NFM_E_SQL_STMT) ;
         }        
****************************/
       }
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

long NFMfix_queries()
{
     static char *fname = "NFMfix_queries" ;
     long	status;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = SQLfix_qry_prep_3 ();
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Fix Qry 3 : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY); 
      }

     status = SQLfix_qry_prep_5 ();
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Fix Qry 5: status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY); 
      }
     status = SQLfix_qry_prep_6 ();
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Fix Qry 6: status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY); 
      }
/********* needs to be redone in WFvalidate_user_access() *********
     status = SQLfix_qry_prep_7 ();
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Fix Qry7 : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY); 
      }
**********************************************************/
     status = SQLfix_qry_prep_8 ();
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Fix Qry 8 : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY); 
      }
/********* needs to be redone in WFvalidate_user_access() *********
     status = SQLfix_qry_prep_9 ();
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Fix Qry 9 : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY); 
      }
     status = SQLfix_qry_prep_10 ();
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Fix Qry10 : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY); 
      }
************************************************************/
     status = SQLfix_qry_prep_11 ();
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Fix Qry11 : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY); 
      }

     status = SQLfix_qry_prep_12 ();
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Fix Qry12 : status = <0x%.8x>",
		  status));
        return (NFM_E_SQL_QUERY); 
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
}

 long NFMlogoff ()
   {
     static char *fname = "NFMlogoff" ;
     char    *clh_vbyop ();
     long    status, tmp_flag ;
     char    sql_str [1024];
     char    temp_str [1024] ;
     char    d_sch_name [100], sch_name [100] ;
     char    *clh_status ;

     _NFMdebug ((fname, "ENTER\n")) ;

     /*
     status = NFT_close ();
     if (status != UTI_S_SUCCESS)
     {
       _NFMdebug ((fname, "NFT_close 0x%.8x\n", status));
     }
     else
     {
       _NFMdebug ((fname, "NFT_close successfully\n"));
     }
     */

     /* size changed from 25 to 26 for SUN/SCO - SSRS - 15/11/93 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
     clh_status = clh_vbyop (NFM_ENV_FILE,  "NETPROP20",  sch_name,  26);
#else
     clh_status = clh_vbyop (NFM_ENV_FILE,  "NETPROP20",  sch_name,  25);
#endif
     if (clh_status)
         {
	   ERRget_specific_number (NETS, &status) ;
	   NFMreset_ris_env () ;
	   RISterminate () ;
	   if (status == NET_S_SUCCESS)
	     ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
	   ERRget_specific_number (NFM, &status) ;
	   if (status == NFM_S_SUCCESS)
	     ERRload_struct (NFM, NFM_E_CLH, "%s%s",
			     "I/NFM schema name", NFM_ENV_FILE);
	   _NFMdebug ((fname, "Get Schema Name : status = <0x%.8x>\n",
		     NFM_E_CLH));
	   return (NFM_E_CLH);
         }
     
     sprintf (temp_str, "%*.*s", 25, 25, sch_name);

     status = NFMdecrypt (temp_str, d_sch_name);
     if (status != NFM_S_SUCCESS)
       { 
	 ERRget_specific_number (NFM, &status) ;
	 NFMreset_ris_env () ;
	 RISterminate () ;
	 if (status == NFM_S_SUCCESS)
	   ERRload_struct (NFM, NFM_E_NET, "", NULL);
	 _NFMdebug ((fname, "Decrypt Schema Name : status = <0x%.8x>\n",
		     status));
	 return (status);
       }

      SQLclear_fix_qrys(); 

/* Set transaction autocommit ON */

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }

     
     /* default schema */
     
     _NFMdebug ((fname, "Executing close default schema statement\n")) ;
     tmp_flag = _NFMdebug_st.SQLdebug_on ;
     _NFMdebug_st.SQLdebug_on = 0 ;
     sprintf (sql_str, "CLOSE SCHEMA %s", d_sch_name);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
       {
	 ERRget_specific_number (NFM, &status) ;
	 NFMreset_ris_env () ;
	 RISterminate () ;
	 if (status == NFM_S_SUCCESS)
	   ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	 return (NFM_E_SQL_STMT) ;
       }
     _NFMdebug_st.SQLdebug_on = tmp_flag ;

     NFMreset_ris_env () ;
     RISterminate () ;

     _NFMdebug ((fname, "Total SQL Stmt  Done = <%d> : Total SQL Query Done = <%d> : SUCCESSFUL\n", 
		 SQLstmt_count, SQLquery_count));
     return (NFM_S_SUCCESS);
   }


long  NFMglobal_ris_data(schema_name, dbtype)
char *schema_name ;
char *dbtype;
{
  static char *fname = "NFMglobal_ris_data" ;
  char    sql_str[1024] ;
  MEMptr  return_buffer = NULL ;
  long    status ;
  char    **data ;

  _NFMdebug ((fname, "ENTER schema_name %s\n", schema_name)) ;

/******* old RIS 3.0 **********
  sprintf (sql_str, "SELECT risdbs.dtype from risdbs, risschemas \
WHERE risschemas.schema_name = '%s' \
AND risschemas.dbid = risdbs.dbid",
	   schema_name) ;
************************/

/* JUJARE - 3 Aug 95
   risdbs and risschemas cannot be accessed through RIS interface for RIS 5.0 
   and later.  So Changed risdbs and risschemas to ris5dbs and ris5schemas */

 sprintf (sql_str, "SELECT ris5dbs.database_type \
from ris5dbs, ris5schemas \
WHERE ris5schemas.schema_name = '%s' \
AND ris5schemas.database_id = ris5dbs.database_id", schema_name) ;

  status = SQLquery (sql_str, &return_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQLquery : <0x%.8x>\n", status));
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (return_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&return_buffer) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
      return (NFM_E_MEM) ;
    }

  data = (char **) return_buffer -> data_ptr ;

  dbtype[0] = data[0][0] ;
  dbtype[1] = 0 ;
  SQLload_database_type (dbtype) ;

  _NFMdebug ((fname, "database type is %s\n", dbtype)) ;
  status = MEMclose (&return_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&return_buffer) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
      return (NFM_E_MEM) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


 long NFMlogin(attr_list, data_list,wf_list,us_id)
   MEMptr   attr_list, data_list, wf_list;
   long     *us_id;
{
      static char *fname = "NFMlogin" ;
      long     status, atol ();
      char     env_node [50];
      char     user_name [NFM_USERNAME], passwd [NFM_PASSWD];
      char     **column, **data, **data1 ;
      long     x, y, count, a, b, i, j, k, l;
      long     NFMget_syscat_configuration ();

      _NFMdebug ((fname, "ENTER\n")) ;
      *us_id = *us_id ;
      wf_list = wf_list ;
      _WFinit_wfinfo();

      status = MEMbuild_array (attr_list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      status = MEMbuild_array (data_list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);          
       }

      column = (char **) attr_list -> column_ptr;  
      data   = (char **) attr_list -> data_ptr;  

      data1  = (char **) data_list -> data_ptr;

      a = -1; b = -1;

      for (y = 0; y < attr_list -> columns; ++y)
       {
               if (! strcmp (column [y], "n_name"))       a = y;
          else if (! strcmp (column [y], "n_datatype"))   b = y;
       }

      i = -1; j = -1; k = -1; l = -1;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;

              if (! strcmp (data [count + a], "n_username"))   i = x;
         else if (! strcmp (data [count + a], "n_passwd"))     j = x;
         else if (! strcmp (data [count + a], "n_env"))        k = x;
         else if (! strcmp (data [count + a], "n_envtype"))    l = x;
       }

      sprintf (env_node, "%s%s", data1 [l], data1 [k]);

/*      sprintf (NFM_ENV_NAME, "%s", data1 [k]) ; */
      sprintf (NFMglobal.environment_name, "%s", data1 [k]) ; 
      sprintf (NFM_ENV_FILE, "%s", env_node) ;
      sprintf (user_name, "%s", data1[i]) ;
      sprintf (passwd, "%s", data1[j]) ;

      status = NFMlog_in(data1[i], data1[j], env_node, NFMglobal.application);
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "log in failed : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS) ;
    }


 long NFMquery_login_attributes (app_id,env_type, 
				 attr_list, data_list, 
				 value_list,wf_list)
   char     *app_id,*env_type;
   MEMptr   *attr_list, *data_list, *value_list, *wf_list;
   {
      static char *fname = "NFMquery_login_attributes" ;
      long     status;
      long     x, y, count, a = -1, b = -1;
      char     **column, **data;
      char     *sql_str;
      char     wf_str[25];
      long     NFMi_template ();


      strcpy (NFMglobal.application, app_id) ;

      _NFMdebug ((fname, "App Id = <%s> : Env Type : <%s>\n", 
		  app_id, env_type));

      strcpy(NFMglobal.application,app_id);

      status = NFMi_template (attr_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Def Tab Attr : status = <0x%.8x>\n", status)) ;
         return (status);
       }

      sql_str = (char *) malloc ((*attr_list) -> row_size);
      if (! sql_str)
       {
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Def Tab Attr : status = <0x%.8x>\n", NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }

      for (x = 0; x < 4; ++x)
       {
        sql_str [0] = 0;

        switch (x)
         {
          case 0 : 
           sprintf (sql_str,
           "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
           "n_username", "char(14)", "USER NAME", 
           "NFM", "Y", "Y", "N", "N", "N", "N", "N", x, 
	   0,0,0,0);
           break;

          case 1 : 
           sprintf (sql_str,
           "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
           "n_passwd", "char(14)", "PASSWORD",
           "NFM", "N", "Y", "N", "N", "Y", "N", "N", x,
	   0,0,0,0);
           break;

          case 2 : 
           sprintf (sql_str,
           "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
           "n_env", "char(9)", "ENVIRONMENT NAME", 
           "NFM", "Y", "Y", "N", "N", "Y", "N", "N", x, 
	   0,0,0,0);
           break;

          case 3 : 
           sprintf (sql_str,
           "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1%d\1",
           "n_envtype", "char(5)", "ENVIRONMENT TYPE", 
           "NFM", "N", "N", "N", "N", "N", "N", "N", x, 
	   0,0,0,0);
           break;
         }

        status = MEMwrite (*attr_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (attr_list);
           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (NFM_E_MEM);
         }
       }

      free (sql_str);

      status = MEMbuild_array (*attr_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status)) ;
         return (NFM_E_MEM);         
       }

      data   = (char **) (*attr_list) -> data_ptr;
      column = (char **) (*attr_list) -> column_ptr;

      for (y = 0; y < (*attr_list) -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      status = MEMopen (data_list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);         
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		     NFM_E_MALLOC));
         return (NFM_E_MALLOC);         
       }
      sql_str [0] = 0;

      for (x = 0; x < (*attr_list) -> rows; ++x)
       {
          count = (*attr_list) -> columns * x;

          status = MEMwrite_format (*data_list,
                   data [count + a], data [count + b]);
          if (status != MEM_S_SUCCESS)
           {
              free (sql_str);
              MEMclose (attr_list);
              MEMclose (data_list);
              ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);
           }

          if (! strcmp (data [count + a], "n_envtype"))
           {
              strcat (sql_str, env_type);
              strcat (sql_str, "\1");
           }
          else
            strcat (sql_str, "\1");
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status)) ;
         return (NFM_E_MEM);
       }

      free (sql_str); 

      status = NFMls_nodes (env_type, value_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         MEMclose (value_list);
         ERRload_struct (NFM, NFM_E_NET, "", NULL);  
         _NFMdebug ((fname, "NFM List Nodes : status = <0x%.8x>\n",
		   status)) ;
         return (status) ;
       }

       status = MEMopen (wf_list, MEM_SIZE);
       if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         MEMclose (value_list);
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status)) ;
         return (NFM_E_MEM);         
       }
       status = MEMwrite_format (*wf_list,"n_workflowname","char(20)");
       if (status != MEM_S_SUCCESS)
       {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
              MEMclose (wf_list);
              ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			  status)) ;
              return (NFM_E_MEM);
       }

       if(!strncmp(app_id,"NFM",3))
       {
	 sprintf(wf_str,"NFM_ITEM_WORKFLOW\1");
      	 status = MEMwrite (*wf_list, wf_str);
         if (status != MEM_S_SUCCESS)
         {
	      MEMclose (attr_list);
 	      MEMclose (data_list);
              MEMclose (value_list);
              MEMclose (wf_list);
              ERRload_struct (NFM, NFM_E_MEM, "", NULL);
   	      _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
    	      return (NFM_E_MEM);
         }      
       }
      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);     
    }

long NFMlogout (user_id) 
     long user_id ;
{
  char *fname = "NFMlogout" ;
  long status ;

  _NFMdebug ((fname, "ENTER\n")) ;
  user_id = user_id ;
  status = NFMlogoff () ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Logoff failed : status = <0x%.8x>\n")) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return(NFM_S_SUCCESS) ;
}

/* this function stores all configuration information : version, date_format*/
long NFMget_syscat_configuration ()
{
  static char *fname = "NFMget_syscat_configuration" ;
  long   status, offset ;
  char   *p1, *p2 ;
  char   s_version [NFM_DESCRIPTION + 1] ;
  int    version, release, i ;
  MEMptr return_buffer = NULL ;
  char   sql_str [256], **data, ris_print_format [50] ;
  char   date_print_format [50], time_print_format [50] ;
  char   message [512] ;
  short  pdm_version_found,version_found, date_format_found, time_format_found ;
  short  query_row_found ;
  char temp_str[12];
  long   atol() ;

  _NFMdebug ((fname, "ENTER\n")) ;

  strcpy (sql_str, "SELECT n_infotype, n_description FROM nfmsyscat where n_infotype = 'VERSION' or n_infotype = 'DATE_FORMAT' or n_infotype = 'TIME_FORMAT' or n_infotype = 'QUERY_ROW' or n_infotype = 'PDM'") ;
  
  status = SQLquery (sql_str, &return_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "Version stamp does not exist\n")) ;
	  ERRload_struct (NFM, NFM_E_BAD_VERSION, "", "") ;
	  return (NFM_E_BAD_VERSION) ;
	}
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQLquery : <0x%.8x>\n", status));
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (return_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
      return (NFM_E_MEM) ;
    }
  
  version_found = 0 ; date_format_found = 0 ; time_format_found = 0 ;
  query_row_found = 0 ; pdm_version_found = 0;

  data = (char **) return_buffer -> data_ptr ;
  for (i=0; i<return_buffer->rows; i++)
    {
      offset = i*return_buffer->columns ;
      _NFMdebug ((fname, "n_infotype %s n_description %s\n",
		  data [offset], data [offset+1])) ;
      if ((!version_found)  && (!strcmp (data [offset], "VERSION")))
	  {
	    _NFMdebug ((fname, "VERSION found\n")) ;
	    strcpy (NFMglobal.NFMversion, data [offset+1]) ;
            strcpy (temp_str, data[offset+1]);
            temp_str[2] = temp_str[3];
            temp_str[3] = temp_str[4];
            temp_str[4] = temp_str[6];
            temp_str[5] = temp_str[7];
            temp_str[6] = temp_str[9];
            temp_str[7] = temp_str[10];
            temp_str[8] = '\0';
            DM_VAULT_VERSION = atol (temp_str);
	    version_found = 1 ;
	  }
      else if ((!pdm_version_found)  && (!strcmp (data [offset], "PDM")))
	  {
	    _NFMdebug ((fname, "PDM VERSION found\n")) ;
            strcpy (temp_str, data[offset+1]);
            temp_str[1] = temp_str[2];
            temp_str[2] = temp_str[4];
            temp_str[3] = '\0';
            PDM_VAULT_VERSION = atol (temp_str);
	    pdm_version_found = 1 ;
	  }
      else if ((!query_row_found)  && (!strcmp (data [offset], "QUERY_ROW")))
	  {
	    _NFMdebug ((fname, "Query row found\n")) ;
	    NFMglobal.query_rows =  atol(data [offset+1]) ;
	    query_row_found = 1 ;
	  }
      else if ((!date_format_found) && 
	       (!strcmp (data [offset], "DATE_FORMAT")))
	  {
	    date_format_found = 1 ;
	    NFMupper_case (data [offset+1], NFMglobal.date_format) ;
	    _NFMdebug ((fname, "DATE_FORMAT found : %s\n",
			NFMglobal.date_format)) ;
	    if (!strcmp (NFMglobal.date_format, "AMERICAN"))
	      {
		/* mm/dd/yyyy */
		strcpy (date_print_format, "mm/dd/yyyy") ;
	      }
	    else if (!strcmp (NFMglobal.date_format, "BRITISH"))
	      {
		/* dd/mm/yyyy */
		strcpy (date_print_format, "dd/mm/yyyy") ;
	      }
	    else if (!strcmp (NFMglobal.date_format, "ITALIAN"))
	      {
		/* dd-mm-yyyy */
		strcpy (date_print_format, "dd-mm-yyyy") ;
	      }
	    else if ((!strcmp (NFMglobal.date_format, "FRENCH")) || 
		     (!strcmp (NFMglobal.date_format, "SPANISH")) ||
		     (!strcmp (NFMglobal.date_format, "GERMAN")))
	      {
		/* dd.mm.yyyy */
		strcpy (date_print_format, "dd.mm.yyyy") ;
	      }
	    else
	      date_format_found = 0 ;
	  }
      else if ((!time_format_found) && (!strcmp (data [offset],
						 "TIME_FORMAT")))
	  {
	    time_format_found = 1 ;
	    NFMupper_case (data [offset+1], NFMglobal.time_format) ;
	    _NFMdebug ((fname, "TIME FORMAT is %s\n",
			NFMglobal.time_format)) ;
	    if (!strcmp (NFMglobal.time_format, "24HR"))
	      {
		strcpy (time_print_format, "hh24:nn:ss") ;
	      }
	    else if (!strcmp (NFMglobal.time_format, "12HR"))
	      {
		strcpy (time_print_format, "hh12:nn:ss") ;
	      }
	    else time_format_found = 0 ;
	  }
      if ((version_found) && (date_format_found) && (time_format_found) && (query_row_found)) 
	break ;
    }

  
  status = MEMclose (&return_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose (return_buffer) : status = <0%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  if (!version_found)
    {
      _NFMdebug ((fname, "Failure : UNKNOWN NFM VERSION")) ;
      ERRload_struct (NFM, NFM_E_BAD_VERSION, "", "") ;
      return (NFM_E_BAD_VERSION) ;
    }

  if (!query_row_found)
    {
      _NFMdebug ((fname, "No QUERY_ROW ENTRY Default to 0")) ;
      NFMglobal.query_rows = 0 ;
    }

  if (!date_format_found)
    {
      strcpy (message, "No date format configuration found - DEFAULTING TO AMERICAN mm/dd/yyyy") ;
      _NFMdebug ((fname, "%s\n", message)) ;
      strcpy (date_print_format, "mm/dd/yyyy") ;
      strcpy (NFMglobal.date_format, "AMERICAN") ;
    }

  if (!time_format_found)
    {
      strcpy (message, 
	      "No time format configuration found - DEFAULTING TO hh24") ;
      _NFMdebug ((fname, "%s\n", message)) ;
      strcpy (time_print_format, "hh24:nn:ss") ;
      strcpy (NFMglobal.time_format, "24HR");
    }

  sprintf (ris_print_format, "%s %s", date_print_format, time_print_format) ;
  SQLload_ris_print_format (ris_print_format) ;

  strcpy (s_version, NFMglobal.NFMversion) ;

  _NFMdebug ((fname, "Version is %s : ris_print_format %s\n", 
	      s_version, ris_print_format)) ;
  p1 = (char *) strchr (s_version, '.') ;
  if (p1 == NULL)
    {
      _NFMdebug ((fname, "Version %s in nfmsyscat is corrupted\n", 
		  NFMglobal.NFMversion)) ;
      ERRload_struct (NFM, NFM_E_MALLOC, NULL) ;
      return (NFM_E_MALLOC) ;
    }
  *p1 = 0 ;
  ++p1 ;
  
  p2 = (char *) strchr (p1, '.') ;
  if (p2 == NULL)
    {
      _NFMdebug ((fname, "Version %s in nfmsyscat is corrupted\n",
		  NFMglobal.NFMversion)) ;
      ERRload_struct (NFM, NFM_E_MALLOC, NULL) ;
      return (NFM_E_MALLOC) ;
    }
  *p2 = 0 ;
  ++p2 ;

  version =  (int) atoi (s_version) ;

  release = ((atoi (p1)) * 100) + (atoi (p2)) ;

  sprintf (NFMglobal.NFMversion, "%02d:%02d:%02d", 
	    version, ((atoi (p1)) * 100), (atoi (p2)));

  _NFMdebug ((fname, "NFM VERSION is %s\n", NFMglobal.NFMversion));
  return (NFM_S_SUCCESS) ;
}

/* this function checks the NFM version to be greater or equal to  2.1.0 */
long NFMcheck_version ()
{
  static char *fname = "NFMcheck_version" ;
  MEMptr return_buffer = NULL ;
  char   sql_str [100] ;
  long   status ;
  char   **data ;
  char   *p1, *p2 ;
  int    version, release ;

  strcpy (sql_str, "SELECT n_description FROM nfmsyscat WHERE n_infotype = 'VERSION'") ;

  status = SQLquery (sql_str, &return_buffer, MEM_SIZE) ;

  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "","" ) ;
      _NFMdebug ((fname, "SQLquery : <0x%.8x>\n", status));
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (return_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
      return (NFM_E_MEM) ;
    }

  data = (char **) return_buffer -> data_ptr ;

  strcpy (NFMglobal.NFMversion, data [0]) ;

  p1 = (char *) strchr (data [0], '.') ;
  if (p1 == NULL)
    {
      _NFMdebug ((fname, "Version %s in nfmsyscat is corrupted\n",
		  NFMglobal.NFMversion)) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", NULL) ;
      return (NFM_E_MALLOC) ;
    }
  *p1 = 0 ;
  ++p1 ;
  
  p2 = (char *) strchr (p1, '.') ;
  if (p2 == NULL)
    {
      _NFMdebug ((fname, "Version %s in nfmsyscat is corrupted\n",
		  NFMglobal.NFMversion)) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", NULL) ;
      return (NFM_E_MALLOC) ;
    }
  *p2 = 0 ;
  ++p2 ;

  version =  (int) atoi (data [0]) ;

  MEMclose (&return_buffer) ;

/*  release = (int) atoi (p1) ; */

  release = ((atoi (p1)) * 100) + (atoi (p2)) ;

  _NFMdebug ((fname, "NFM VERSION is %d:%d:%d\n", 
	    version, ((atoi (p1)) * 100), (atoi (p2))));

  if ((version < 2) || ((version == 2) && (release < 1)))
    {
      ERRload_struct (NFM, NFM_W_OLD_SA_FILENAMES, "", "") ;
      return (NFM_W_OLD_SA_FILENAMES) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long NFMset_client_info()
{
  char *fname="NFMset_client_info";
  _NFMdebug ((fname, "Entry\n")) ;
	DM_MANAGER = 1;
	NFMbmcsmc_globals_init();
	NFMbftr_adv_globals_init();
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
	return(NFM_S_SUCCESS);
}

#define DM_VALID_VAULT_VERSION   3040000
#define PDM_VALID_VAULT_VERSION   240

long _NFMcheck_vault_version_number ()
{

  char *fname="_NFMcheck_vault_version_number";

  _NFMdebug ((fname, "ENTER: DM VERSION [%d] PDM VERSION [%d]\n",
                  DM_VAULT_VERSION, PDM_VAULT_VERSION));

  if (DM_VAULT_VERSION < DM_VALID_VAULT_VERSION)
  {
    _NFMdebug ((fname, 
      "DM/Manager will not operate with this version of vault\n"));
    ERRload_struct (NFM, NFM_E_NFM_VERSION, "", NULL);
    return (NFM_E_NFM_VERSION);
  }
  if (PDM_VAULT_VERSION > 0  && 
           PDM_VAULT_VERSION < PDM_VALID_VAULT_VERSION)
  {
    _NFMdebug ((fname, "Do not type the set\n"));
    PDMVAULT_DONT_TYPE_SET = 1;
  }

  _NFMdebug ((fname, "EXIT Successful\n"));
  return (NFM_S_SUCCESS);
}
#endif
