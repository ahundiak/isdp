/**********************************************
File : NFMo_login.c  
Desc : This is a very old version of source code of NFMlogin.c (1989 ?)
       This is not directly being used anywher in NFM. But since there
       are users who are using these  old functions bundled with NFMDP,
       we need to retain this for NFMDP product.
                     
                                      -- Jujare Govind Raj, 21-Dec-95 

 * 17 Dec 2010 - one big difference is that this rouitne has no FTR support built in
**********************************************/

#include "machine.h"
#include "NFMU.h"
/* #include "NFMfto_buf.h" */
#include "pwd.h"
#include "stdlib.h"
#include "NFMf_xferinc.h"

 extern struct NFMglobal_st NFMglobal;
 extern long NFM_PL_LOCK;
 extern long SQLstmt_count ;
 extern long SQLquery_count;

 extern long SQLcursor[41];
 extern long SQLcursor_count[41];
 extern char * getenv();
 extern MEMptr  NFMcomm_ptr;

 extern MEMptr  NFMwf_ptr;
extern  MEMptr  NFMcl_ptr; 
 extern NFMtr_ptr; 
 extern NFMac_ptr;

extern  MEMptr  NFMacl_ptr ; 
 extern NFMaclusr_ptr;
extern  MEMptr  NFMaclsign_ptr;
 extern  NFMsignoff_ptr;

extern  MEMptr  NFMproc_ptr ;

extern  MEMptr  NFMnodes_ptr;

extern MEMptr  NFMstor_ptr ;
extern  MEMptr  NFMusrs_ptr;

extern  MEMptr  NFMloc_ptr ;
extern  MEMptr  NFMlop_ptr ;

extern  long       NFMprocess_id;

/*    GLOBAL VARIABLES    */
 extern char NFM_WF_CACHED[];
 extern char NFMenv_logged[];
 extern int  NFM_SRV_ENV ;
extern  char NFM_SRV_NODE[100];      /* nodename of server */
extern  char NFM_ENV_NODE[100];      /* nodename where schema definition(risschema) */
                              /* for environment resides */
/*  char NFM_ENV_NAME [100]; */    /* environment name */
extern  char NFM_ENV_FILE [100];     /* environment file */

 
 long NFMunix_log_in(user_name, passwd, environment, application)
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
      long     user_no, t, offsett ;
      char     value [100] ;
      long     NFMlogoff ();
      long     NFMsun_get_schema_info ();
      long NFMget_syscat_configuration ();
      long NFMget_db_info () ;
      long NFMfix_queries() ;

      _NFMdebug ((fname, "username %s : environment %s : application %s\n", user_name, environment, application)) ;

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
      status = NFMsun_get_schema_info (NFM_ENV_FILE,schema_name);
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

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS) ;
    }


 long NFMsun_get_schema_info (node_name, schema_name)
   char    *node_name;
   char    *schema_name;
   {
     static char *fname = "NFMsun_get_schema_info" ;
     int       i;
     long      status, tmp_flag ;
     char      sql_str[200], *clh_status;

/* OV - IGI-320. OS_CLIX condition is added to mkae sure that for clix also
   clh_vbyop is used. */
#if defined (__sgi) || defined (__Sol2__) || defined(OS_CLIX)
	char       *clh_vbyop ();
#else
	char       *sunclh_vbyop ();
#endif
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

     _NFMdebug ((fname, "Node Name = <%s>\n", node_name)) ;

	/* look up the node_name of the environment */
	
     clh_status = clh_vbyop (node_name, "NODENAME", NFM_ENV_NODE, 25);
     if (clh_status)
      {
	ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
        ERRload_struct (NFM, NFM_E_CLH, "%s%s", 
				 "Nodename", node_name) ;
        _NFMdebug ((fname, "Get Nodename of risschema file : status = <0x%.8x>\n",
        NFM_E_CLH));
        return (NFM_E_CLH);
      }

     _NFMdebug ((fname, "NFMsrvnode [%s], NFMenvnode[%s]\n", 
                                            NFM_SRV_NODE, NFM_ENV_NODE)) ;

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
     
     clh_status = clh_vbyop (node_name, "NETPROP20", sch_name, 30);
     if (clh_status)
      {
	ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
        ERRload_struct (NFM, NFM_E_CLH, "%s%s", 
				 "nfm schema name", node_name);
        _NFMdebug ((fname, "Get Schema Name : status = <0x%.8x>\n",
        NFM_E_CLH));
        return (NFM_E_CLH);
      }

     sprintf (temp_str, "%*.*s", 25, 25, sch_name);
     _NFMdebug ((fname, "temp_str[%s]\n", temp_str)) ;

     /* Store the encrypted schema name in a global variable. */

     strcpy (NFMglobal.NFMsch_name, temp_str);


     _NFMdebug ((fname, "sch_name %s\n", sch_name)) ;
     _NFMdebug ((fname, "sch_name %s\n", temp_str)) ;
     status = NFMdecrypt (sch_name, d_sch_name);
     if (status != NFM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname, "Decrypy Schema Name : status = <0x%.8x>\n",
		    status));
        return (status) ;
      }

     _NFMdebug ((fname, "d sch_name %s\n", d_sch_name)) ;
     strcpy (schema_name, d_sch_name) ;

     clh_status = clh_vbyop (node_name, "NETPROP21", sch_pwd, 30);
     if (clh_status)
      {
	ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
        ERRload_struct (NFM, NFM_E_CLH, "%s%s", 
				 "nfm schema password", node_name);
        _NFMdebug ((fname, "Get Schema Pwd : status = <0x%.8x>\n",
		  NFM_E_CLH));
        return (NFM_E_CLH);
      }

     sprintf (temp_str, "%*.*s", 25, 25, sch_pwd);

     /* Store the encrypted schema passwd in a global variable.  */

     strcpy (NFMglobal.NFMsch_passwd, temp_str);


     _NFMdebug ((fname, "sch_pwd %s\n", sch_pwd)) ;
     _NFMdebug ((fname, "sch_pwd %s\n", temp_str)) ;
     status = NFMdecrypt (sch_pwd, d_sch_pwd);
     if (status != NFM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname, "Decrypt Schema Password : status = <0x%.8x>\n",
		    status));
        return (status);
      }
     _NFMdebug ((fname, "dec sch_pwd %s\n", d_sch_pwd)) ;


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
     tmp_flag = _NFMdebug_st.SQLdebug_on ;  
     _NFMdebug_st.SQLdebug_on = 0 ; 
     if (! strlen (d_sch_pwd))      
       sprintf (sql_str, "DEFAULT SCHEMA %s", d_sch_name);
     else
       sprintf (sql_str, "DEFAULT SCHEMA %s.%s", d_sch_name, d_sch_pwd);
     
     _NFMdebug ((fname, "%s\n", sql_str)) ;
     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
     _NFMdebug ((fname, "default schema failed\n")) ;
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

/* Function to pull the file from the well known node.   */
long NFMget_nfmenvdat_file ()
{
  static char *fname = "NFMget_nfmenvdatfile" ;
  MEMptr file_list = NULL ;
  char   *host=NULL, address[50], *host1=NULL, row_str [3072] ;
  long   status = NFM_S_SUCCESS;
  char   *node_name=NULL, *username=NULL, *passwd=NULL, *cwd=NULL ;
  long   NFMcheck_wellknown_node (), NETid = -1;
  long   NFMsunget_nodeinfo();
       
  _NFMdebug ((fname, "Enter\n"));
             host1 = (char *) gethostbyname( "NFMENV" );
             if( host1 == NULL )
              {
            _NFMdebug((fname,"gethostsbyname failed for NFMENV alias\n"));
            _NFMdebug((fname,"Trying to check /etc/hosts file\n"));
               status = MYgethostaddr("NFMENV", address);
                if(status)
                  {
            _NFMdebug((fname,"No entry  for NFMENV in /etc/hosts file \n"));
          _NFMdebug((fname,"Trying to check for NFMENV enviroment variable\n"));
                    host = (char *) getenv("NFMENV");
                     if(host == NULL)
                      {
            _NFMdebug((fname,"No environment value set for NFMENV variable\n"));
          _NFMdebug((fname,"Trying to check for local file NFMENV \n"));
                      status =  NFMcheck_wellknown_node (&host);
                        if(status != NFM_S_SUCCESS)
                         {
        _NFMdebug((fname,"Error getting server info from local NFMENV file\n"));
               ERRload_struct (NFM, NFM_E_NO_SERVER, "", "") ;
                     return(NFM_I_LOAD_SERVER_NODE_INFO);
                         }
                       }                       
                    }
                    else 
                        {
                  host = (char *) malloc(20);
                 host[0] = '\0';
                        strcpy(host,"NFMENV");
                         }
               }
               else 
                {
                  host = (char *) malloc(20);
                 host[0] = '\0';
                 strcpy(host,"NFMENV");
                 free(host1);
                 }
                
     
 status =  NFMsunget_nodeinfo(&node_name, &username, &passwd, &cwd);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
      if (node_name) free (node_name);
      if (username) free (username);
      if (passwd) free (passwd);
      if (cwd) free (cwd);
      if (host) free (host);
      return (status);
    }
      _NFMdebug ((fname, "Local node name %s , Local username %s Local passwd %s Local cwd %s\n",node_name, username, passwd, cwd));
 status = NFMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
      MEMclose(&file_list);
      return (status);
    }

    /*
    sprintf (row_str,
     "\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
     host, "nfmadmin", "",
     "", "HD", "",
     "", "N", "",
     "CLIX", "CLIX", "Y",
     "N", "N",
     "N", "\1\1\1\1\1\1\1\1\1");
     */

    row_str[0] = '\0'; 
    sprintf (row_str,
     "\1%s\1nfmadmin\1\1\1HD\1\1\1N\1\1\1CLIX\1CLIX\1Y\1N\1N\1N\1\1\1\1\1\1\1\1\1\1", host);
    _NFMdebug ((fname, "MEMwrite %s\n", row_str));

     status = MEMwrite (file_list, row_str);
     if (status != MEM_S_SUCCESS)
     {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      MEMclose (&file_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (status);
    }
    row_str[0] = '\0'; 
    sprintf (row_str,
     "\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1\1\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1%s\1\1%d\1%d\1\1\1",
     node_name, username, passwd, cwd, "HD", "N", "UNIX", "UNIX", "Y", "N", "N",
     "N","NFMenv.dat","NFMenv.dat",222,NFM_MOVE);
    _NFMdebug ((fname, "MEMwrite %s\n", row_str));
     status = MEMwrite (file_list, row_str);
     if (status != MEM_S_SUCCESS)
      {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
      return (NFM_E_MEM) ;
      }

    /*
     status = _NFMfs_recv_files (&file_list);
     */
       
   status = NFMs_src_send_clix (host,"nfmadmin","",NET_TCP,&file_list,&NETid,1);
     if (status != NFM_S_SUCCESS)
      {
      _NFMdebug ((fname, "_NFMfs_recv_files 0x%.8x\n", status));
      if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
      _NFMfs_undo_recv_files (&file_list);
        MEMclose (&file_list);
        return (status);
       }

      MEMclose(&file_list);
      if (node_name) free (node_name);
      if (username) free (username);
      if (passwd) free (passwd);
      if (cwd) free (cwd);
      if (host) free (host);
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long NFMcheck_wellknown_node (char **name)
{
     FILE   *fp;
     char   *s, *cwd, str[1024], *substr, *token;
     char   *fname = "NFMcheck_wellknown_node";

      _NFMdebug ((fname, "Enter\n")) ;

       if(( cwd = (char *) PDUgetcwd( (char *) NULL, 128)) == NULL)
         {
        _NFMdebug((fname,"Error getting current working directory \n"));
           ERRload_struct (NFM, NFM_E_GETPWD, "", "") ;
          return (NFM_E_GETPWD) ;
         }
        str[0] = '\0';

        sprintf(str,"%s/NFMENV", cwd);

       fp = fopen (str, "r");
       if ( !fp )
        {
        _NFMdebug((fname,"Error opening  local NFMENV file\n"));
           ERRload_struct (NFM, NFM_E_OPEN_FILE, "", "") ;
     	  return ( NFM_E_OPEN_FILE );
         }

     while ( (s=fgets(str, 1023, fp)) != NULL )
     {
	  substr = (char *) strstr ( str, "NFMENV" );
	  if ( substr == NULL )
	       continue;
      }
	  token = (char *) strtok ( str, " ");
	  if ( token == NULL )
	  {
        _NFMdebug((fname,"Error getting server from local NFMENV file\n"));
                ERRload_struct (NFM, NFM_E_NO_SERVER, "", "") ;
		fclose (fp);
              return ( NFM_E_NO_SERVER );
	  }
          *name = (char *) malloc (20);
	  strcpy (*name, token);
	  fclose (fp);
	  return ( NFM_S_SUCCESS );  
}

long NFMsunget_nodeinfo(char **node_name, char **username, char **passwd,
                     char **cwd)  

{
  FILE                        *hostfile;
  long                        status = NFM_S_SUCCESS;
  struct passwd               *user_info;
  unsigned short              getuid();
  char                        s[1024], s1[1024];
  char                        *NFMfgets();
  char                        *fname = "NFMsunget_nodeinfo";

  _NFMdebug((fname,"Enter\n"));
  user_info = (struct passwd *) malloc (sizeof(struct passwd));
  user_info = getpwuid(getuid());

  *username = user_info->pw_name;
  *passwd = user_info->pw_passwd;
  *cwd = (char *) PDUgetcwd((char *)NULL, 128);
  *node_name = (char *)malloc(20); 

  hostfile = fopen ("/etc/hostname.le0", "r");
  if (!hostfile)
    {
    _NFMdebug((fname,"Error opening /etc/hostname.le0 file", 0));
    return(status);
    }
   if ((NFMfgets (s1, 1024, hostfile)) == NULL)
          {
    _NFMdebug((fname,"Error opening /etc/hostname.le0 file", 0));
                return (NFM_E_OPEN_FILE);
          }
   if ((s1 == NULL) || !strcmp (s1, ""))
       {
       strcpy(*node_name,"");
       }
   else
      {
       if ((*node_name = (char *) malloc (strlen (s1) + 1)) == NULL)
        {
         _NFMdebug((fname,"Error allocating memory", 0));
         return(NFM_S_SUCCESS);
        }
        else strcpy(*node_name,s1);
      }

  _NFMdebug((fname,"%s, %s, %s, %s\n", *node_name,*username,*passwd,*cwd));
  _NFMdebug((fname,"Exit\n"));
   return(NFM_S_SUCCESS);
}

char *NFMfgets(char *s,int n,FILE *stream)
{
    char *sts,*strchr();

    if ((sts = fgets(s,n,stream)) == NULL) return(sts);
    if ((sts = strchr(s,'\n')) == NULL) return(s);
    *sts = 0;
    return(s);
}
         

