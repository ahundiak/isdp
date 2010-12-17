#include "machine.h"
#include "INIT.h"

  char DRP_STR [1024];
  extern char NFMCWD[] ;

  long NFMcreate_nfmdb (db_data, user_name, passwd, def, db2_data, os_data, SYserver,SYinterfaces)
    MEMptr   db_data;
    char     *user_name, *passwd ;
    long     def ;
    MEMptr   db2_data;
    MEMptr   os_data;
    char     *SYserver, *SYinterfaces ;
    {
      static char *fname = "NFMcreate_nfmdb" ;
      long    status ;
      char    sql_str [1024], sql_str1[1024], sql_str2 [1024] ;
      char    **d_data, **d2_data, **o_data;
      char    sch_passwd [100], usr_passwd [100], sch_name [100] ;
      char    def_passwd [100];
      char    nodename [50] ;
      char    message [500], gateway_str [500], dir_str [50] ;
      char    ifx_opt [500] ;
      long    nfm_debug_flag, sql_debug_flag ;
      long    clh_status;
      char    os_str[10], value[100], os_user[400];

      _NFMdebug ((fname, "ENTER\n")) ;

      d_data = (char **) db_data -> data_ptr;
      d2_data = (char **) db2_data -> data_ptr ;
      o_data = (char **) os_data -> data_ptr;

      NFMlower_case (d_data [0], d_data [0]);
      NFMlower_case (d_data [1], d_data [1]);

      NFMupper_case (d_data [2], d_data [2]);
      NFMupper_case (d_data [6], d_data [6]);

      sch_passwd [0] = 0;   usr_passwd [0] = 0; 
      def_passwd [0] = 0;

      /* schema passwd */
      if (def)
      {
	strcpy (sch_name, "nfm_template") ;
      }
      else
      { 
         strcpy (sch_name, d_data [7]) ;
        if (strlen (d_data [8]))        
             sprintf (sch_passwd, ".%s", d_data [8]);
      }  

      sql_str [0] = 0;                     /* v was d_data [6] MMS 3/17/91 */
      sprintf (DRP_STR, "DROP SCHEMA %s%s", sch_name, sch_passwd);

      dir_str [0] = 0 ;

      if (strlen (d_data [3]))
	  sprintf (dir_str, ", DIR %s", d_data [3]) ;

      ifx_opt[0] = 0 ;
      if (strcmp (d_data [2], "INFORMIX") == 0)
      {
	  if (d_data [4][0] == '/')
	    {
	      /* standard engine */
	      sprintf (ifx_opt, ", option (sqlexec = %s/lib/sqlexec)",
		       d_data[3]) ;
	    }
	  else
	    {
	      /* online engine */
/* PS 12th Dec 95 */
#if defined (OS_INTELSOL)
              sprintf (ifx_opt, ", option (sqlexec = %s/lib/sqlrm)",
                       d_data[3]) ;
#else
              sprintf (ifx_opt, ", option (sqlexec = %s/lib/sqlturbo)",
                       d_data[3]) ;
#endif
	    }
         os_user[0] = '\0';
          
       }
       else
       {
         /* 1/25/93 -MFB- If the dbase == DB2 | ORACLE | SYBASE,
                          build the query with OSUSER */
	if(strlen(passwd) > 0 )
         sprintf (os_user, ", OSUSER %s.%s", user_name,passwd);
	else
         sprintf (os_user, ", OSUSER %s", user_name);
       }
       /* 1/25/93 -MFB- look up for OSTYPE in object file and build the query
                        with found OSTYPE */
       _NFMdebug ((fname, "d_data[5] = %s\n", d_data[5]));
       value[0] = '\0';

       /* OS type as input - IGI 20 Dec 94 */
       _NFMdebug ((fname, "o_data[0] = %s\n", o_data[0]));
       /*strcpy(os_str, "UNIX");*/
       strcpy(os_str, o_data[0]);

       /*clh_status = clh_vbyop (d_data[5], "NETMAP_info", value, 4);
       if (clh_status)
       {
         ERRload_struct (NFM, NFM_E_CLH, "%s%s", 
                         "operating system information", d_data[5] );
         _NFMdebug ((fname, "Failed to retrieve OS information\n"));
         return (NFM_E_CLH);
       }

       if (! strncmp (value, "UNIX", 4))
       {
         strcpy (os_str, "UNIX");
       }
       else if (!strncmp (value, "VMS", 3))
       {
         strcpy (os_str, "VMS");
       }
       else if (!strcmp (value, "NT", 2))
       {
         strcpy (os_str, "NT");
       }
       else
       {
         ERRload_struct (NFM, NFM_E_CLH, "%s%s",
                         "valid operating system information", d_data[5]);
         _NFMdebug ((fname, "retrieved OS info is not valid\n"));
         return (NFM_E_CLH);
       }*/

      _NFMdebug ((fname, "OSTYPE %s OSUSER [%s]\n",
                  os_str, os_user));

/* KT 1/21/93 - Added OSTYPE for RIS 4.2 */

      sprintf (sql_str, 
      "CREATE SCHEMA %s%s ON DATABASE (%s ,DBNAME %s %s %s, OSTYPE %s %s ",
          sch_name, sch_passwd, d_data [2], d_data [4], dir_str, ifx_opt,
          os_str, os_user) ;
/* JM 4/22/94 - Added SYBASE options*/
      if (strcmp(d_data [2], "SYBASE") == 0 )
      {
	sql_str1 [0] = 0;
	sprintf (sql_str1, ", OPTION (DSQUERY=%s,FILENAME=%s) ",SYserver,
				SYinterfaces);
	strcat (sql_str, sql_str1);
      }

      NFMlower_case (d_data [5], d_data [5]);

      strcpy (nodename, d_data [5]) ;

       sql_str1 [0] = 0 ;

      if (strcmp (d_data [6], "") == 0)
        {
         sprintf (sql_str1, ", REMOTE (XNS %s)", nodename) ;
       }
      else
        {
         sprintf (sql_str1, ", REMOTE (%s %s)",
                 d_data [6], nodename, nodename) ;
       }

      if (strcmp (d_data [2], "DB2") == 0)
	{
	  sprintf (gateway_str,
		   ", gateway (arch = %s, os = %s, env = %s, \
host_program = %s, ris_lu = %s, host_lu = %s, mode = %s, net_protocol = %s)",
		   d2_data [4], d2_data [5], d2_data [6],
		   d2_data [2], d2_data [0], d2_data [1], d2_data [3],
		   d2_data [7]) ;
	  strcat (sql_str1, gateway_str) ;
	}

      if (strlen (d_data[10]))
	sprintf (sql_str2, " ) USER %s.%s", d_data[9], d_data[10]) ;
      else
	sprintf (sql_str2, " ) USER %s", d_data[9]) ;

      if (strlen (sql_str1))
	strcat (sql_str, sql_str1) ;

      strcat (sql_str, sql_str2) ;
		 
      _INIT_str ("CREATE SCHEMA AND DEFAULT TO IT : %s", "") ;
      _NFMdebug ((fname, "Creating schema and defaulting to it\n")) ;

/*      _NFMdisable_nfm_sql_debug (&nfm_debug_flag, &sql_debug_flag) ; */

      status = SQLexec_imm (sql_str);
      if (status != SQL_S_SUCCESS)
       {
	 _NFMenable_nfm_sql_debug (nfm_debug_flag, sql_debug_flag) ;
	  if (status == SQL_E_MESSAGE)
	    {
	      ERRget_specific_message (SQL, message) ;
	      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
	      return (NFM_E_MESSAGE) ;
	    }

          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); 
          _NFMdebug ((fname, "Create DB : status =  <0x%.8x>\n",
		      status)) ;
          return (NFM_E_SQL_STMT);
       }

      _NFMdebug ((fname, "Default schema\n")) ;
      sprintf (sql_str, "DEFAULT SCHEMA %s%s", sch_name, sch_passwd); 

      status = SQLexec_imm (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         SQLexec_imm (DRP_STR); 
	 _NFMenable_nfm_sql_debug (nfm_debug_flag, sql_debug_flag) ;
         if (status == SQL_E_MESSAGE)
            {
              ERRget_specific_message (SQL, message) ;
              ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
              return (NFM_E_MESSAGE) ;
            }
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          _NFMdebug ((fname, "Default schema : status =  <0x%.8x>\n",
		      status)) ;
          return (NFM_E_SQL_STMT);
       }

      _NFMenable_nfm_sql_debug (nfm_debug_flag, sql_debug_flag) ;

/********
      _NFMdebug ((fname, "Set transaction autocommit on\n")) ;

      status = SQLexec_imm ("SET TRANSACTION AUTOCOMMIT ON");
      if (status != SQL_S_SUCCESS)
       {
          SQLexec_imm (DRP_STR); 
         if (status == SQL_E_MESSAGE)
            {
              ERRget_specific_message (SQL, message) ;
              ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
              return (NFM_E_MESSAGE) ;
            }
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          _NFMdebug ((fname, "Commit Off : status =  <0x%.8x>\n",
		      status)) ;
          return ( NFM_E_SQL_STMT);
       }
*********************/
      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
    }


