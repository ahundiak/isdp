#include "machine.h"
#include <stdio.h>
#include "NFMstruct.h"
#include "NFMerrordef.h"
#include "NFMdef.h" 
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFIerrordef.h"
#include "SCstruct.h"
#include "SCdef.h" 
#include "ERR.h"
#include "NDXstruct.h" 
#include "DEBUG.h"
#include "NFMversion.h"
#include "NETstruct.h"
#include <pwd.h>

      struct NFMglobal_st NFMglobal ;
      extern char *optarg ;
      extern long silent_mode ;
      extern char SCHEMA[] ;

long UPDline_options (argc,  argv, filename,  environment, 
                    silent_mode,  all_environments)
     int argc ;
     char **argv ;
     char *filename, *environment ;
     long *silent_mode ;
     long *all_environments ;
{
  int c ;
  long stop_flag ;
  FILE *UPDconsole ;

  UPDconsole = NULL ;
  stop_flag = 0 ;
  *silent_mode = 0 ;
  while (((c = getopt(argc,argv,"d:e:?SA")) != EOF) && (!stop_flag))
    {
      switch(c)
	{
	case 'd':
	  strcpy(filename,optarg);
	  if ( strlen (filename))
	    {
	      if ((UPDconsole = fopen(filename,"w")) == NULL)
		{
		  if (! silent_mode) fprintf(stderr,"%s: unable to open \"%s\" for debug\n",
			  argv[0],filename);
		  return (NFM_E_FAILURE) ;
		}
	    }
	  else
	    {
	      strcpy (filename, "/dev/console") ;
	      if ((UPDconsole = fopen("/dev/console","w")) == NULL)
		{
		  if (! silent_mode) fprintf(stderr,"%s: unable to open /dev/console for debug\n");
		  return (NFM_E_FAILURE) ;
		}
	    }

	  break;
	  
	case 'e':
	  /* the environment to connect to */
	  strcpy (environment, optarg);
	  break;

        case 'S' :
          /* silent mode */
          *silent_mode = 1;
          break ;

        case 'A' :
          /* all environments */
          *all_environments = 1;
          break ;

	case '?':
	  stop_flag = 1 ;
	  fprintf (stderr,
		   "Usage: Nfmupdate -e environment|-A  [-d output_file] [-S]\n");
	  fprintf (stderr, "     : -e environment name\n") ;
	  fprintf (stderr, "     : -d output file\n") ;
	  fprintf (stderr, "     : -S silent mode\n") ;
	  fprintf (stderr, "     : -A all environments in owned\n") ;
	  fprintf (stderr, "-A has priority over -e\n") ;
	  break;

	  default :
	    stop_flag = 1 ;
	  fprintf (stderr,
		   "Usage: Nfmupdate -e environment|-A [-d output_file] [-S]\n");
	  fprintf (stderr, "     : -e environment name\n") ;
	  fprintf (stderr, "     : -d output file\n") ;
	  fprintf (stderr, "     : -S silent mode\n") ;
	  fprintf (stderr, "     : -A all environments in owned\n") ;
	  fprintf (stderr, "-A has priority over -e\n") ;
	  break ;
	}
    }

  if (stop_flag)
    {
      return (NFM_E_FAILURE) ;
    }
  return (NFM_S_SUCCESS) ;
}



long _NFMget_schema_info (env_name, SCHEMA_NAME)
     char    *env_name;
     char    *SCHEMA_NAME ;
{
  char *fname = "_NFMget_schema_info" ;
  long      status, tmp_flag ;
  char      sql_str[200], *clh_status, *clh_vbyop ();
  char      sch_name   [100], d_sch_name   [100];
  char      sch_pwd    [100], d_sch_pwd    [100];
  char      temp_str   [100] ;
  char      node_name [100] ;
  char      NFM_SRV_NODE [100] ;
  char      NFM_ENV_NODE [100] ;


  _NFMdebug ((fname, "Environment Name = <%s>\n", env_name)) ;
  
  /* look up the node_name of the server */
  sprintf (node_name, "nfme_%s", env_name) ;
  
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
      ERRload_struct (NFM, NFM_E_CLH, "%s%s", 
		      "Nodename", node_name) ;
      _NFMdebug ((fname, "Get Nodename of risschema file : status = <0x%.8x>\n",
		  NFM_E_CLH));
      return (NFM_E_CLH);
    }


  /*  changed size from 25 to 26 -SSRS - 29/11/93*/
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
  clh_status = clh_vbyop (node_name,  "NETPROP20",  sch_name,  26);
#else
  clh_status = clh_vbyop (node_name, "NETPROP20", sch_name, 25);
#endif
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

  _NFMdebug ((fname, "schema name <%s>\n", d_sch_name)) ;
/*  strcpy (SCHEMA_NAME, d_sch_name) ; */


  /* changed size from 25 to 26 -  SSRS - 29/11/93 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
  clh_status = clh_vbyop (node_name,  "NETPROP21",  sch_pwd,  26);
#else
  clh_status = clh_vbyop (node_name, "NETPROP21", sch_pwd, 25);
#endif
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

  status = NFMdecrypt (temp_str, d_sch_pwd);
  if (status != NFM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_NET, "", NULL);
      _NFMdebug ((fname, "Decrypt Schema Password : status = <0x%.8x>\n",
		  status));
      return (status);
    }
  
  sql_str [0] = 0;
  
  _NFMdebug ((fname, "Executing default schema statement\n")) ;
  tmp_flag = _NFMdebug_st.SQLdebug_on ;  
  _NFMdebug_st.SQLdebug_on = 0 ; 
  if (! strlen (d_sch_pwd))      
    sprintf (sql_str, "DEFAULT SCHEMA %s", d_sch_name);
  else
    sprintf (sql_str, "DEFAULT SCHEMA %s.%s", d_sch_name, d_sch_pwd);
  
  status = SQLexec_imm (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug_st.SQLdebug_on = tmp_flag ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "Default Schema : status = <0x%.8x>\n",
		  status));
      return (NFM_E_SQL_STMT);
    }
  _NFMdebug_st.SQLdebug_on = tmp_flag ; 

  strcpy (SCHEMA_NAME, d_sch_name) ;
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long close_schema ()
{
  long   status;
  static char *fname = "close_schema" ;
  char str [512] ;
  long sql_flag ;
  
  _NFMdebug ((fname, "ENTER\n"));
  
  sql_flag = _NFMdebug_st.SQLdebug_on ;
  _NFMdebug_st.SQLdebug_on = 0 ;
  sprintf (str, "CLOSE SCHEMA %s", SCHEMA) ;
  status = SQLexec_imm (str) ;
  _NFMdebug_st.SQLdebug_on = sql_flag ;
  _NFMdebug ((fname, "EXIT : status = <0x%.8x>\n", status));
  
  _NFMdebug ((fname, "EXIT\n"));
  return (NFM_S_SUCCESS);
}

long _NFMget_env_list (output_buffer)
     MEMptr	*output_buffer;
{
  long	status;
  char  type [50] ;
  
  char *fname = "_NFMget_env_list" ;
  
  strcpy (type, "nfme_") ;

  _NFMdebug((fname, "Entry:type = <%s> MEMptr *output_buffer <%x>\n", type,*output_buffer));
  
  /*  Open output_buffer  */
  
  if ((status = MEMopen (output_buffer, MEM_SIZE)) != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMopen = <0x%.8x>\n", status));
      status = NFM_E_MEM_ERR;
      ERRload_struct(NFM,status,"%s%s%s%x","MEMopen",fname,"status",status);
      return (status);
    }
  
  if ((status = MEMwrite_format
       (*output_buffer, "name", "char(14)")) != MEM_S_SUCCESS)
    {
      MEMclose (output_buffer);
      _NFMdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
      status = NFM_E_MEM_ERR;
      ERRload_struct(NFM,status,"%s%s%s%s","MEMwrite_format",fname,"name","name");
      return (status);
    }
  
  /*  mms - DO NOT Get all files in the local directory first  
  
  if ((status = NFMfind_files
       ("/usr/lib/nodes/local", type, *output_buffer)) != NFM_S_SUCCESS)
    {
      MEMclose (output_buffer);
      _NFMdebug ((fname, "NFMfind_files = <0x%.8x>\n", status));
      return (status);
    }

  */

  /*  Get all files in the owned directory  */
 
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
  /* Getting environments from *.dat files for SUN - SSRS - 8/12/93 */
  if ((status = NFMget_entries
       ("owned", type, *output_buffer)) != NFM_S_SUCCESS)
    {
      MEMclose (output_buffer);
      _NFMdebug ((fname, "NFMget_entries: status = <0x%.8x>\n", status));
      return (status);
    }
 #else
  if ((status = NFMfind_files
       ("/usr/lib/nodes/owned", type, *output_buffer)) != NFM_S_SUCCESS)
    {
      MEMclose (output_buffer);
      _NFMdebug ((fname, "NFMfind_files: status = <0x%.8x>\n", status));
      return (status);
    }
 #endif

  if ((status = NFMsort_buffer
       (*output_buffer)) != NFM_S_SUCCESS)
    {
      MEMclose (output_buffer);
      _NFMdebug ((fname, "NFMsort_buffer: status = <0x%.8x>\n", status));
      return (status);
    }

  
  _NFMdebug ((fname, "SUCCESSFUL <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

void _NFMprint_description (label)
     char    *label;
{
  fputs ("\nI/NFM ", stderr);
  
  if ((strcmp (label, "")) != 0)
    {
      fputs (label, stderr);
      fputs (" Version ", stderr);
    }
  else
    {
      fputs ("Version ", stderr);
    }
  fputs ("\nAdd new commands\n", stderr);
  fputs ("Change attributes in the nfmattributes table\n", stderr);
  fputs ("Change ownership in default search criterias\n", stderr);
  sleep (2) ;
  return;
}

/* this function checks the NFM version to be greater or equal to 3.0 */
long _NFMcheck_30version ()
{
char *fname = "NFMcheck_30version" ;
long status,  l_version ;
MEMptr return_buffer = NULL ;
char   sql_str [512],  version[NFM_DESCRIPTION+1] ;
char  *p1, **data ;

	_NFMdebug ((fname,  "ENTER\n")) ;
	strcpy (sql_str,  "SELECT n_description FROM nfmsyscat WHERE n_infotype = 'VERSION'") ;
	status = SQLquery (sql_str,  &return_buffer,  MEM_SIZE) ;
	if (status != SQL_S_SUCCESS)
	{
		ERRload_struct (NFM,  NFM_E_SQL_QUERY, "",  "") ;
		_NFMdebug ((fname,  "Failure : status = <0x%.8x>\n", 
			status)) ;
		return (NFM_E_SQL_QUERY) ;
	}
	status = MEMbuild_array (return_buffer) ;
	if (status != MEM_S_SUCCESS)
	{
		MEMclose (&return_buffer) ;
		_NFMdebug ((fname,  "Failure : status = <0x%.8x>\n", 
			status)) ;
		ERRload_struct (NFM,  NFM_E_MEM,  "", "") ;
		return (NFM_E_MEM) ;
	}
	data = (char **) return_buffer -> data_ptr ;
	strcpy (version,  data [0]) ;
	MEMclose (&return_buffer) ;
	
	p1 = (char *) strchr (version,  '.') ;
	if (p1 == NULL)
	{
		_NFMdebug ((fname,  "Version %s in nfmsyscat is	corrupted\n"));
		ERRload_struct (NFM,  NFM_E_MALLOC,  "", "") ;
		return (NFM_E_MALLOC) ;
	}
	*p1 = 0 ;

	l_version = atol (version) ;

	_NFMdebug ((fname,  "NFM VERSION (long) %d\n", 	l_version)) ;

	if (l_version < 3)
	{
		if (!silent_mode) fprintf (stderr, 
			"Version of I/NFM environment is not 3.0 or greater\n");
		_NFMdebug ((fname,  "Version is smaller than 3.0\n")) ;
		ERRload_struct (NFM,  NFM_E_BAD_VERSION,  "",  "") ;
		return (NFM_E_BAD_VERSION) ;
	}

	_NFMdebug ((fname,  "SUCCESSFUL\n")) ;
	return (NFM_S_SUCCESS) ;
}
