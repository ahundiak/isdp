#include "machine.h"
#include <stdio.h>
#include <string.h>

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
# include "CLI.h"
#include "MEMstruct.h"
#else
# include <direct.h>
# include "CLIerrordef.h"
# include "CLIstruct.h"
# include "CLIextern.h"
# include "NFMerrordef.h"
# include "proto.h"
# include <memcheck.h>
#endif


long  CLIlogin()
{
  long  status ;
  char  cwd[51];
  char  temp_str[15];
  char  message[256]={"\0"};
  long  err_no = NFM_S_SUCCESS;

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  int   subsystem;
  char  user[NFM_USERNAME+1] ;
  char  nodename [NFM_NODENAME+1] ;
  char  pathname [NFM_PATHNAME+1] ;
  char  wa[NFM_SANAME+1] ;
  MEMptr node_info = NULL ;
  MEMptr sa_info = NULL ;
#else
  char  internet_address[31];
  char  nfs_node[2];
  char  nfs_sa[2];
  char  returned_string[256]={"\0"};
#endif
  
  _CLI_str( "%s", "Entering CLIlogin" );

  if ( strncmp(CLIenv,"nfme_", 5) != 0)
  {
     CLIprint( CLIout_file, "LOGIN : Environment <%s>  Username <%s>", 
	  CLIenv, CLIuser) ;
     CLIprint( stderr, "LOGIN : Environment <%s>  Username <%s>", 
	  CLIenv, CLIuser);
     strcpy(temp_str, CLIenv);
     sprintf(CLIenv, "nfme_%s", temp_str);
  }
  else
  {
     CLIprint( CLIout_file, "LOGIN : Environment <%s>  Username <%s>", 
	  &CLIenv[5], CLIuser) ;
     fprintf( stderr, "LOGIN : Environment <%s>  Username <%s>", 
	  &CLIenv[5], CLIuser);
  }
  status = NFMRlog_in( CLIuser, CLIpasswd, CLIenv, "NFM" );

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  ERRget_number( &err_no, &subsystem );
  ERRget_message( message );
#else
  _NFMget_server_response ( err_no, message, returned_string) ;
#endif

  if( status != NFM_S_SUCCESS )
    {
      _CLI_num ("CLIlogin failed : err_no <0x%.8lx>\n", err_no) ;
      _CLI_str ("CLIlogin failed : message <%s>\n", message) ;
      CLIprint( stderr, 
	"Error logging into environment <%s> : %s", &CLIenv[5], message);
      CLIprint( CLIout_file, 
	"Error logging into environment <%s> : %s", &CLIenv[5], message);
      return( CLI_E_FAILURE );
    }
  else
    {
      _CLI_str ("CLIlogin : Successful Login%s","");
      fprintf( CLIout_file, "   Successful Login.\n" );
      fprintf( stderr, "   Successful Login.\n" );
    }

  /* determine current working directory */
  if (getcwd(cwd,50) == NULL)
    {
      fprintf ( stderr, "Error retrieving current working directory\n");
      fprintf ( CLIout_file, "Error retrieving current working directory\n");
      return( CLI_E_FAILURE );
    } 


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
/* post login information */
  _CLI_str ("CLIstorage area is <%s>", CLIstorage) ;
  if (! strlen (CLIstorage))
    {
      _CLI_str ("Get default working area ...%s","") ;
      status = _NFMget_wa_system_info (nodename, user, pathname,
				       &node_info, &sa_info) ;
      if (status == NFM_S_SUCCESS)
	{
	  status = NFMRadd_default_working_area (nodename, user, pathname,
						 wa, node_info, sa_info);
	  if (status == NFM_S_SUCCESS)  strcpy (CLIstorage, wa) ;
	  MEMclose (&node_info) ;
	  MEMclose (&sa_info) ;
	}
    }
#else
  /* determine internet address of PC */
  if (get_tcp(CLIpcid,internet_address) != 0)
    {
      fprintf ( stderr, "Error retrieving internet address of client\n");
      fprintf ( CLIout_file, "Error retrieving internet address of client\n");
      return( CLI_E_FAILURE );
    }

  strcpy (nfs_node, "") ;
  strcpy (nfs_sa, "") ; 

  CLIprint( stderr, "ACTIVATING WORKING AREA <%s> : CWD <%s>", 
	  internet_address, cwd) ;
  CLIprint( CLIout_file, "ACTIVATING WORKING AREA <%s> : CWD <%s>", 
	  internet_address, cwd) ;

  status = NFMRpc_post_log_in( internet_address, CLIstorage, cwd, nfs_node, 
			      nfs_sa);
  _NFMget_server_response (err_no, message, returned_string) ;
  if (! strlen (CLIstorage))
    strcpy (CLIstorage, returned_string) ;
#endif

  if( status != NFM_S_SUCCESS )
    {
      CLIprint( stderr, "Error defaulting to working area <%s> or <%s>", 
	      CLIstorage, cwd );
      CLIprint( CLIout_file, "Error defaulting to working area <%s> or <%s>", 
	      CLIstorage, cwd );
      return( CLI_E_FAILURE );
    }
  else
    {
      fprintf( CLIout_file, "   Successful Post Login.\n" );
      fprintf( stderr, "   Successful Post Login.\n" );
    }


  _CLI_str( "%s", "Exiting CLIlogin" );
  return( CLI_S_SUCCESS );
}

long  CLIlogout( )
{
  long  status ;
  char  temp_str[15];

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifndef OS_UNIX
  long  err_no=NFM_S_SUCCESS;
  char  message[256]={"\0"};
  char returned_string[256]={"\0"};
#endif
  
  _CLI_str( "%s", "Entering CLIlogout" );
 
  if (strncmp (CLIenv, "nfme_", 5) == 0)
     strcpy (temp_str, &CLIenv[5]);
  else
     strcpy (temp_str, CLIenv);
 
  fprintf( CLIout_file, "LOGOUT : Environment <%s>\n", temp_str );
  fprintf( stderr, "LOGOUT : Environment <%s>\n", temp_str );
  

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  status = NFMRlogout(0);
#else
  status = NFMRlogout();
  _NFMget_server_response ( err_no, message, returned_string) ;
#endif
  if( status != NFM_S_SUCCESS )
    {
      CLIprint( stderr, "Error logging out of environment <%s>", 
	      temp_str);
      CLIprint( CLIout_file, "Error logging out of environment <%s>", 
	      temp_str);
      return( CLI_E_FAILURE );
    }
  else
    {
      fprintf( CLIout_file, "   Successful Logout.\n" );
      fprintf( stderr, "   Successful Logout.\n" );
    }
  
  _CLI_str( "%s", "Exiting CLIlogout" );
  return( CLI_S_SUCCESS );
}





