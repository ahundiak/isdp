#include "machine.h"
#include "INIT.h"
#include <sys/types.h> 
#include <sys/stat.h>
#include "NFMversion.h"
#include "SQLstruct.h"

 extern MSGptr INITmsg_ptr;
 struct NFMglobal_st NFMglobal ;

        char NFMCWD    [100];
extern  char EXECPATH  [];
        char NFM_ENV   [200];
        char NFM_SYS   [200];
        char NFM_UTL   [200];
        char NFM_FILES [200];
        char NFM_SA_UTIL[200];
/* extern char DEF_STR   []; */
 extern char DRP_STR   [];
        char OWN_ENV_FILE [100] ;
        char OWN_SERVER_FILE [100] ;
/********************************************************************
 *                                                                  *
 *    NOTES :                                                       *
 *    This version is 2.2.0 or bigger : Date Format is ANSI         *
 *                                                                  *
 *                                                                  *
 ********************************************************************/

 long NFMris_init (node_attr, node_data, st_attr, st_data,
		   user_attr, user_data, db_attr, db_data,
		   db2_attr, db2_data, os_attr, os_data,
		   SYserver, SYinterfaces)
   MEMptr  node_attr, node_data, st_attr, st_data;
   MEMptr  user_attr, user_data, db_attr, db_data;
   MEMptr  db2_attr, db2_data, os_attr, os_data;
   char    *SYserver, *SYinterfaces;
   {
     static char *fname ="NFMris_init" ;
     long    status ;
     char    user_name [50], passwd [50];
     char    **d_data ;
     char    sch_passwd [100], sql_str [200] ;
     long    NFMvalidate_init_buffers ();
     long    NFMupdate_db ();
     char    date [50] ;
     long    def ;
     struct stat buf ;
     int    i_status ;

     _NFMdebug ((fname, "INIT : %s\n", ""));

     db2_attr = db2_attr ;
/*****************************************************************
This is the content of the db_data buffer:

data [0]  : Server Name 
data [1]  : Environment Name 
data [2]  : RDBMS Type 
data [3]  : RDBMS Home Directory 
data [4]  : RIS Database Name 
data [5]  : Environment Node
data [6]  : ENvironment Node Protocol 
data [7] : Schema Name 
data [8] : Schema Password 
data [9] : Environment Username
data [10]: Environment Passwd

*****************************************************************/

     status = NFMset_autocommit_on (0) ;
     if (status != NFM_S_SUCCESS)
       {
	 _INIT_str ("SET AUTOCOMMIT ON %s", "") ;
	 _NFMdebug ((fname, "Set autocommit on : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     SQLload_ris_print_format ("mm/dd/yyyy hh24:nn:ss") ;

     status = NFMget_datetime (date) ;
     if (status == NFM_S_SUCCESS)
       {
	 _INIT_str ("START NFM INITIALIZE :\nDATE : %s", date) ;
       }

     if (!strlen (NFMversion))
       {
	 _NFMdebug ((fname, "Bad Version %s\n", NFMversion));
	 _INIT_str ("Bad Version %s\n", NFMversion) ;
	 ERRload_struct (NFM, NFM_E_BAD_VERSION, "", "") ;
	 return (NFM_E_BAD_VERSION) ;
       }

     sch_passwd [0] = 0;

     user_name [0] = 0;  passwd [0] = 0;

     
    _NFMdebug ((fname, "Executing SET DATABASE ENABLE statement\n")) ;
    _INIT_str ("Executing SET DATABASE ENABLE statement %s", "") ;

     strcpy (sql_str, 
	     "SET DATABASE ENABLE ONLY INFORMIX, ORACLE, INGRES, DB2, SYBASE");

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
       {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SET DATABASE ENABLE : status = <0x%.8x>\n",
                    status));
        _INIT_num ("INIT : SET DATABASE ENABLED failed : status = <0x%.8x>\n",
		   status);
        return (NFM_E_SQL_STMT);
      }

    _INIT_str ("Executing SET DATABASE ENABLE statement %s", "SUCCESSFUL") ;

     _INIT_str ("NFMvalidate_init_buffers %s", "") ;

     status = NFMvalidate_init_buffers (node_data,
              st_data, user_data, db_data, os_data,
              user_name, passwd);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Validate Init Failed : status = <0x%.8x>\n",
        status));
        _INIT_num ("INIT : Validate Init Failed : status = <0x%.8x>\n",
        status);
        return (status);
      }

     _INIT_str ("NFMvalidate_init_buffers %s", "SUCCESS") ;

     d_data = (char **) db_data -> data_ptr ;

     sprintf (NFM_ENV, "%s/%s", NFMCWD, d_data [1]);
     sprintf (NFM_SYS, "%s/%s/system", NFMCWD, d_data [1]);
     sprintf (NFM_UTL, "%s/%s/utilities", NFMCWD,  d_data [1]);
     sprintf (NFM_FILES, "%s/%s/files", NFMCWD, d_data [1]);

     _NFMdebug ((fname, "Create Directories %s %s %s %s\n", 
		NFM_ENV, NFM_SYS, NFM_UTL, NFM_FILES)) ;

     _INIT_str ("Create Directories %s\n", "") ;

     status = NFMcreate_directories () ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "failed = <0x%.8x>\n",
		   status));
	 _INIT_num ("NFMcreate_directories : failed = <0x%.8x>\n",
		    status) ;
	 return (status) ;
       }
     
     _INIT_str (" Create Directories %s\n", "SUCCESS") ;

     _INIT_str (" Write Server and Environment Files %s", "");
     
     status = NFMwrite_init_files (node_attr, node_data, st_attr, st_data,
				   user_attr, user_data, db_attr, db_data);
     if (status != NFM_S_SUCCESS)
       {
	 NFMremove_directories () ;
	 _NFMdebug ((fname, "Write Init Files : status = <0x%.8x>\n",
		   status));
	 _INIT_num ("INIT : Write Init Files : status = <0x%.8x>\n",
		    status);
	 return (status);
       }
     
     _INIT_str (" Write Server and Environment Files %s", "SUCCESS");

     _INIT_str ("  CREATE nfm_template SCHEMA %s", "");

     def= 1 ;
     status = NFMcreate_nfmdb (db_data, user_name, passwd, def, db2_data,
				os_data, SYserver, SYinterfaces) ;
     if (status != NFM_S_SUCCESS) 
      {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
        del_ser_env("server", d_data[0]);
        del_ser_env("owned", d_data[1]);
        del_ser_env("heard", d_data[1]);
#else
	unlink (OWN_SERVER_FILE) ;
        unlink (OWN_ENV_FILE) ;
#endif
	NFMremove_directories () ;
	 SQLexec_imm (DRP_STR) ;
        _NFMdebug ((fname, "Create NFM DB : status = <0x%.8x>\n", status));
        _INIT_num ("INIT : Create NFM DB : status = <0x%.8x>\n", status);
        return (status);
      }

     _INIT_str ("  CREATE nfm_template SCHEMA %s", "SUCCESS");

     _INIT_str ("  Loading NFM data using RIS_loader %s", "");

/* KT - 1/23/93 - Try new SQLload function! Don't need 'risload' utility
     i_status = stat ("/usr/ip32/ris/bin/risload", &buf) ;
     if (i_status)
       {
	 unlink (OWN_SERVER_FILE) ;
	 unlink (OWN_ENV_FILE) ;
	 SQLexec_imm (DRP_STR) ;
	 _INIT_str ("/usr/ip32/ris/bin/risload was not found %s", "") ;
	 NFMremove_directories () ;
	 ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "/usr/ip32/ris/bin/risload was not found - may have to create software link") ;
	 return (NFM_E_MESSAGE) ;
       }
*/

     i_status = stat ("/usr/ip32/nfm/config/initial/ris3.0.dmp", &buf) ;
     if (i_status)
       {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
        del_ser_env("server", d_data[0]);
        del_ser_env("owned", d_data[1]);
        del_ser_env("heard", d_data[1]);
#else
	 unlink (OWN_SERVER_FILE) ;
	 unlink (OWN_ENV_FILE) ;
#endif
	 NFMremove_directories () ;
	 SQLexec_imm (DRP_STR) ;
	 _INIT_str ("/usr/ip32/nfm/config/initial/ris3.0.dmp was not found %s", "") ;
	 ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
			 "/usr/ip32/nfm/config/initial/ris3.0.dmp was not found") ;
	 return (NFM_E_MESSAGE) ;
       }

/* KT - 1/23/93 - Try new SQLload function!
     unlink ("ris.bad") ;
     if (_NFMdebug_st.NFMdebug_on)
       {
	 sprintf (sql_str, 
		  "/usr/ip32/ris/bin/risload -i /usr/ip32/nfm/config/initial/ris3.0.dmp -m w -s nfm_template all >%s",
		  _NFMdebug_st.NFMdebug_file);
	 status = system (sql_str) ;
       }
     else
       status = system ("/usr/ip32/ris/bin/risload -i /usr/ip32/nfm/config/initial/ris3.0.dmp -m w -s nfm_template all >/dev/null") ;
     
     if (status < 0)
       {
	 unlink (OWN_SERVER_FILE) ;
	 unlink (OWN_ENV_FILE) ;
	 _NFMdebug ((fname, "system : errno %d\n", errno));
         NFMremove_directories () ;
	 _NFMdrop_tables() ;
	 SQLexec_imm (DRP_STR) ;
	 ERRload_struct (NFM, NFM_E_SYSTEM_CALL, "%s", "risload") ;
	 return (NFM_E_SYSTEM_CALL) ;
       }
*/

     _NFMdebug ((fname, "INIT : Call SQLload_schema...\n"));
     status = SQLload_schema ();
     if (status != SQL_S_SUCCESS)
       {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
        del_ser_env("server", d_data[0]);
        del_ser_env("owned", d_data[1]);
        del_ser_env("heard", d_data[1]);
#else
	 unlink (OWN_SERVER_FILE) ;
	 unlink (OWN_ENV_FILE) ;
#endif
	 _NFMdebug ((fname, "system : errno %d\n", errno));
         NFMremove_directories () ;
	 _NFMdrop_tables() ;
	 SQLexec_imm (DRP_STR) ;
	 ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "RIS_loader") ;
	 return (NFM_E_MESSAGE) ;
       }

     _NFMdebug ((fname, "INIT : SQLload_schema : SUCCESSFUL\n"));
     status = _NFMcheck_ris_bad ("NFMris.bad") ;
     if (status != NFM_S_SUCCESS)
       {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
        del_ser_env("server", d_data[0]);
        del_ser_env("owned", d_data[1]);
        del_ser_env("heard", d_data[1]);
#else
	 unlink (OWN_SERVER_FILE) ;
	 unlink (OWN_ENV_FILE) ;
#endif
         NFMremove_directories () ;
	 _NFMdrop_tables() ;
	 SQLexec_imm (DRP_STR) ;
	 ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
			 "May have to drop and recreate database - risload failed") ;
	 return (NFM_E_MESSAGE) ;
       }

/**** risload still around make sure is gone - Greg report this problem  *****/
     sleep (10) ;

     _INIT_str ("  Update Database %s", "");

     status = NFMupdate_db (node_data, user_data, st_data) ;
     if (status != NFM_S_SUCCESS)
       {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
        del_ser_env("server", d_data[0]);
        del_ser_env("owned", d_data[1]);
        del_ser_env("heard", d_data[1]);
#else
	 unlink (OWN_SERVER_FILE) ;
	 unlink (OWN_ENV_FILE) ;
#endif
	 NFMremove_directories () ; 
	 _NFMdrop_tables () ;
	 SQLexec_imm (DRP_STR) ;
	 _NFMdebug ((fname, "Update database : status = <0x%.8x>\n",
		   status));
	 _INIT_num ("INIT : Update database : status = <0x%.8x>\n",
		    status);
	 return (status);
       }

     _INIT_str ("  Update Database %s", "SUCCESS");
     _INIT_str ("  Drop Schema nfm_template %s", "");
     
     status = SQLexec_imm ("DROP SCHEMA nfm_template") ;
     if (status != SQL_S_SUCCESS) 
       {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
        del_ser_env("server", d_data[0]);
        del_ser_env("owned", d_data[1]);
        del_ser_env("heard", d_data[1]);
#else
	 unlink (OWN_SERVER_FILE) ;
	 unlink (OWN_ENV_FILE) ;
#endif
         NFMremove_directories () ;
	 _NFMdrop_tables () ;
	 SQLexec_imm (DRP_STR) ;
	 ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
/*	 ERRload_struct (NFM, NFM_E_MESSAGE,
			 "%s", "Error droping schema nfm_template") ; 
	 return (NFM_E_MESSAGE) ;
*/
	 return (NFM_E_SQL_STMT) ;
       }
     
     _INIT_str ("  Drop Schema nfm_template %s", "SUCCESS");

     def= 0 ;
     status = NFMcreate_nfmdb (db_data, user_name, passwd, def,db2_data,
			       os_data,	SYserver, SYinterfaces) ;
     if (status != NFM_S_SUCCESS) 
       {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
        del_ser_env("server", d_data[0]);
        del_ser_env("owned", d_data[1]);
        del_ser_env("heard", d_data[1]);
#else
	 unlink (OWN_SERVER_FILE) ;
	 unlink (OWN_ENV_FILE) ;
#endif
         NFMremove_directories () ;
	 _NFMdrop_tables () ;
	 SQLexec_imm (DRP_STR) ;
        _NFMdebug ((fname, "INIT : Create NFM DB : status = <0x%.8x>\n", status));
        _INIT_num ("INIT : Create NFM DB : status = <0x%.8x>\n", status);
	 return (status) ;
       }
     
     strcpy (NFMglobal.environment_name, d_data[1]);
     status = NFMdefault_queries ();
     if (status != NFM_S_SUCCESS)
         {
         /* Don't do anything; Continue. */
         _NFMdebug ((fname, "NFMdefault_queries : status = <0x%.8x>\n",
                     status));
         }

     sprintf (sql_str, "CLOSE SCHEMA %s", d_data [7]) ;

     SQLexec_imm (sql_str) ;

     status = NFMget_datetime (date);

     if (status == NFM_S_SUCCESS)
       {
	 _INIT_str ("End initialize : \nDATE : %s", date) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     ERRload_struct (NFM, NFM_S_SUCCESS, NULL, NULL) ;
     return (NFM_S_SUCCESS);
   }

 long NFMvalidate_init_buffers (node_data, st_data,
                                user_data, db_data, os_data,
                                user_name, passwd)
   MEMptr  node_data, st_data;
   MEMptr  user_data, db_data, os_data;
   char    *user_name, *passwd;
   {
     static char *fname = "NFMvalidate_init_buffers" ;
      long     status;
      char     **n_data, **s_data, **u_data, **d_data, **o_data;

      status = MEMbuild_array (node_data);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
         status));
         return (NFM_E_MEM);
       }

      n_data  = (char **) node_data -> data_ptr;

      status = MEMbuild_array (st_data);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
         status));
         return (NFM_E_MEM);
       }

      s_data  = (char **) st_data -> data_ptr;

      status = MEMbuild_array (user_data);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
         status));
         return (NFM_E_MEM);
       }

      u_data  = (char **) user_data -> data_ptr;

      status = MEMbuild_array (db_data);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
         status));
         return (NFM_E_MEM);
       }

      d_data  = (char **) db_data -> data_ptr;
      NFMupper_case ( d_data [2], d_data [2]);
/* added by naidu --1 Feb 95 **************/

      status = MEMbuild_array (os_data);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
         status));
         return (NFM_E_MEM);
       }
      o_data  = (char **) os_data -> data_ptr;
      _NFMdebug ((fname, "o_data 1, 2  %s, %s\n", o_data [1], o_data [2]));
/* added by naidu --1 Feb 95 **************/
       if (strcmp ( d_data [2], "ORACLE") == 0)
	{
       		sprintf (user_name, "%s", o_data [1]);
	        sprintf (passwd,    "%s", o_data [2]);
	}
	else
	{
       		sprintf (user_name, "%s", d_data [9]);
	        sprintf (passwd,    "%s", d_data [10]);
	}
      _NFMdebug ((fname, "username, passwd  %s, %s\n", user_name, passwd));
      
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
    }



long NFMupdate_db (node_data, user_data, st_data)
  MEMptr node_data, user_data, st_data ;
{
  static char *fname = "NFMupdate_db" ;
  char  e_passwd [50], username [50], enc_passwd [50] ;
  char  str_stmt [500], str_stmt1 [500], str_stmt2 [500] ;
  long status ;
  char  node_name [50] ;
  char  **n_data, **u_data, *c_status, **s_data ;
  MEMptr return_buffer = NULL ;
 
  /* Because Ingres does not allow updates in key combinations that
     already exist, we have to do a select first and make sure that no
     rows exist before we do updates - MMS */

  _NFMdebug ((fname, "ENTER\n")) ;
  
  /*********   NFMNODES */
  n_data = (char **) node_data -> data_ptr ;
  
  node_name [0] = 0;
  /* Missing 4th argument added - SSRS 2 Mar 94 */
  c_status = (char *) clh_vbyop ("TEMPLATE", "NODENAME", node_name, 25);
  if (c_status)
    {
      _NFMdebug ((fname, "Node Name Not Defined : status = <0x%.8x>\n",
		NFM_E_BAD_TEMPLATE));
      ERRload_struct (NFM, NFM_E_BAD_TEMPLATE, NULL, NULL) ;
      return (NFM_E_BAD_TEMPLATE);            
    }

  NFMupper_case (n_data [3], n_data [3]);
  
  sprintf (str_stmt, "SELECT n_nodename FROM  NFMNODES WHERE \
n_nodename = '%s' AND n_nodeno = 1",
	   node_name) ;

  status = SQLquery (str_stmt, &return_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  MEMclose (&return_buffer) ;

  if (status == SQL_I_NO_ROWS_FOUND)
    {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
      /*Updating machid and opsys to UNIX in case of SUN/SCO - SSRS 20 Apr 94 */
      sprintf (str_stmt, "UPDATE NFMNODES SET \
n_nodename = '%s', n_nodedesc = '%s', n_tcpip = '%s', n_xns = '%s', \
n_decnet = '%s', n_netware = '%s', n_nfs = '%s' \
, n_machid = 'UNIX', n_opsys = 'UNIX' \
WHERE n_nodeno = 1",
#else
      sprintf (str_stmt, "UPDATE NFMNODES SET \
n_nodename = '%s', n_nodedesc = '%s', n_tcpip = '%s', n_xns = '%s', \
n_decnet = '%s', n_netware = '%s', n_nfs = '%s' \
WHERE n_nodeno = 1",
#endif
	       node_name, n_data [2], n_data [3], n_data [4],
	       n_data [5], n_data [6], n_data [7]) ;

      status = SQLexec_imm (str_stmt) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
	{
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Updating basic node failed") ;
	  return (NFM_E_MESSAGE) ;
	}
    }
  else
    {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
      /*Updating machid and opsys to UNIX in case of SUN/SCO - SSRS 20 Apr 94 */
      sprintf (str_stmt, "UPDATE NFMNODES SET \
n_nodedesc = '%s', n_tcpip = '%s', n_xns = '%s', \
n_decnet = '%s', n_netware = '%s', n_nfs = '%s' \
, n_machid = 'UNIX', n_opsys = 'UNIX' \
WHERE n_nodeno = 1",
#else
      sprintf (str_stmt, "UPDATE NFMNODES SET \
n_nodedesc = '%s', n_tcpip = '%s', n_xns = '%s', \
n_decnet = '%s', n_netware = '%s', n_nfs = '%s' \
WHERE n_nodeno = 1",
#endif
	       n_data [2], n_data [3], n_data [4],
	       n_data [5], n_data [6], n_data [7]) ;
      
      status = SQLexec_imm (str_stmt) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
	{
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Updating basic node failed") ;
	  return (NFM_E_MESSAGE) ;
	}
    }

  /************   NFMSTORAGEAREA AREA  ******************************/
  s_data = (char **) st_data -> data_ptr;
/*  
  strcpy (username , s_data [3]) ;
*/
  strcpy (username , "nfmadmin") ;

  status = NFMencrypt (s_data [4], enc_passwd) ;
  if (status != NFM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "encryption failed") ;
      return (NFM_E_MESSAGE) ;
    }

  status = NFMtic_to_tics (enc_passwd, e_passwd) ;
  if (status != NFM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "eliminating single tic failed") ;
      return (NFM_E_MESSAGE) ;
    }
  
  sprintf (str_stmt, "SELECT n_saname FROM  NFMSTORAGEAREA WHERE \
n_saname = 'nfm' AND n_sano = 1") ;
  
  status = SQLquery (str_stmt, &return_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
      return (NFM_E_SQL_QUERY) ;
    }

  MEMclose (&return_buffer) ;

  if (status == SQL_I_NO_ROWS_FOUND)
    {
      sprintf (str_stmt, "UPDATE NFMSTORAGEAREA SET \
n_saname = '%s', n_passwd = '%s' WHERE n_sano = 1",
	       s_data [1], e_passwd) ;
      
      status = SQLexec_imm (str_stmt) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
	{
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Update nfmstoragearea failed") ;
	  return (NFM_E_MESSAGE) ;
	}
    }
  else
    {
      sprintf (str_stmt, "UPDATE NFMSTORAGEAREA SET \
n_passwd = '%s' WHERE n_sano = 1",
	       e_passwd) ;
      
      status = SQLexec_imm (str_stmt) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
	{
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Update nfmstoragearea failed") ;
	  return (NFM_E_MESSAGE) ;
	}
    }

  sprintf (str_stmt, "SELECT n_saname FROM  NFMSTORAGEAREA WHERE \
n_username = '%s' AND n_pathname = '%s' AND n_sano = 1",
	   username, NFMCWD) ;
  
  status = SQLquery (str_stmt, &return_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
      return (NFM_E_SQL_QUERY) ;
    }

  MEMclose (&return_buffer) ;

  if (status == SQL_I_NO_ROWS_FOUND)
    {
      sprintf (str_stmt, "UPDATE NFMSTORAGEAREA SET \
n_username = '%s', n_pathname = '%s' WHERE n_sano = 1",
	       username, NFMCWD) ;
      
      status = SQLexec_imm (str_stmt) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
	{
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Update nfmstoragearea failed") ;
	  return (NFM_E_MESSAGE) ;
	}
    }
  

  strcpy (str_stmt, "UPDATE NFMSTORAGEAREA SET \
n_username = '%s', n_passwd = '%s', n_pathname = '%s' WHERE n_saname = '%s'") ;

  sprintf (str_stmt1, str_stmt, username, e_passwd, NFM_SYS, "SYSTEM") ;
  
  status = SQLexec_imm (str_stmt1) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
    {
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Update nfmstoragearea failed") ;
      return (NFM_E_MESSAGE) ;
    }

  sprintf (str_stmt1, str_stmt, username, e_passwd, NFM_UTL, "UTILITIES") ;
  
  status = SQLexec_imm (str_stmt1) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
    {
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "update nfmstoragea failed") ;
      return (NFM_E_MESSAGE) ;
    }
  
  sprintf (str_stmt1, str_stmt, username, e_passwd, NFM_FILES, "NFMFILES") ;
  status = SQLexec_imm (str_stmt1) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
    {
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "update nfmstoragearea failed") ;
      return (NFM_E_MESSAGE) ;
    }

  sprintf (str_stmt2, "SELECT n_saname FROM  NFMSTORAGEAREA WHERE \
n_username = '%s' AND n_pathname = '%s' AND n_saname = '1-UTIL'",
           username, NFM_SA_UTIL) ;
  
  status = SQLquery (str_stmt2, &return_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  MEMclose (&return_buffer) ;
  
  if (status == SQL_I_NO_ROWS_FOUND)
    {

      sprintf (str_stmt1, str_stmt, username, e_passwd, NFM_SA_UTIL, "1-UTIL") ;
      status = SQLexec_imm (str_stmt1) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE)) 
	{
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Updating utility sa failed") ;
	  return (NFM_E_MESSAGE) ;
	}
    }
  else
    {
      sprintf (str_stmt, 
	      "UPDATE NFMSTORAGEAREA SET n_passwd='%s' WHERE n_saname = '1-UTIL'",
		  e_passwd);

      status = SQLexec_imm (str_stmt) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE)) 
	{
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Updating utility sa failed") ;
	  return (NFM_E_MESSAGE) ;
	}
    }
  
  /******* NFMUSERS ********/
  u_data = (char **) user_data -> data_ptr ;

  sprintf (str_stmt, "SELECT n_username FROM  NFMUSERS WHERE \
n_username = 'nfmadmin' AND n_passwd = '%s' AND n_userdesc = '%s' AND n_emailaddr = '%s' AND n_userno = 1",
	   e_passwd, u_data [3], u_data [4]) ;

  status = SQLquery (str_stmt, &return_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
      return (NFM_E_SQL_QUERY) ;
    }

  MEMclose (&return_buffer) ;

  if (status == SQL_I_NO_ROWS_FOUND)
    {
      sprintf (str_stmt, "UPDATE NFMUSERS SET \
n_username = 'nfmadmin', n_passwd = '%s', n_userdesc = '%s', n_emailaddr = '%s' \
WHERE n_userno = 1",
	       e_passwd, u_data [3], u_data [4]) ;
      status = SQLexec_imm (str_stmt) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
	{
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Updating basic user failed") ;
	  return (NFM_E_MESSAGE) ;
	}
    }
  else
    {
      sprintf (str_stmt, "UPDATE NFMUSERS SET \
n_passwd = '%s', n_userdesc = '%s', n_emailaddr = '%s' \
WHERE n_userno = 1",
	       e_passwd, u_data [3], u_data [4]) ;

      status = SQLexec_imm (str_stmt) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
	{
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Updating basic user failed") ;
	  return (NFM_E_MESSAGE) ;
	}
    }

 /***************** VERSION *****************/
  sprintf (str_stmt, "UPDATE nfmsyscat SET \
n_description = '%s' WHERE n_infotype = 'VERSION'",
	   NFMversion) ;
  
  status = SQLexec_imm (str_stmt) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
    {
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Updating NFM revision failed") ;
      return (NFM_E_MESSAGE) ;
    }
/**********************
  status = NFMget_datetime (date) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get Date Time Failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  sprintf (str_stmt, "UPDATE NFMCATALOGS \
SET n_creationdate  = timestamp '%s'",
	   date) ;

  status = SQLexec_imm(str_stmt) ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQL exec imm failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL) ;
      return (NFM_E_SQL_STMT) ;
    }
***********************/

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMcheck_ris_bad (ris_bad_file)
     char *ris_bad_file ;
{
  char *fname = "_NFMcheck_ris_bad" ;
  long status ;
  struct stat file_buf ;

  _NFMdebug ((fname, "ris bad file <%s>\n", ris_bad_file)) ;

  status = stat (ris_bad_file, &file_buf) ;
  if ((status) && (errno != 2))
    {
      _NFMdebug ((fname, "Failure : stat failed : errno <%d>\n",
		  errno)) ;
      ERRload_struct (NFM, NFM_E_STAT, "", "") ;
      return (NFM_E_STAT) ;
    }

  if ((!status) && (file_buf.st_size != 0))
    {
      _NFMdebug ((fname, "Failure : file status : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Ris operation failed") ;
      return (NFM_E_MESSAGE) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}





