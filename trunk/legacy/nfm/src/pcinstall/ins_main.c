#include "machine.h"
/******************************************************************************
  
 SOURCE FILE: ins_main.c
  
 AUTHOR: Melania M Seward (modified Rick Kramer code)
  
 DATE: 09/03/92
  
 DESCRIPTION: Main program will install or update PC NFM.
  
   FUNCTIONS INVOKED:
						MakeDir(ins_util.c)
						InstallProduct(ins_util.c)
						VerifyHost(ins_util.c)
						WhichPCID(ins_pcid);
						WriteCFGFile(ins_main.c)
						UpdateAutoexec(ins_util.c)
						GetFreeSpace(ins_util.c)
 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT:
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
  
#include "pcinst.h"
#include "getopt.h"
#include "ins_proto.h"

/* GLOBALS */

char wrk[255];
char pcid [80] ;
char nfm_path[130] ;
char bpath[130] ;
char cpath[130] ;
char tpath[130] ;
int  nfs_package ;
char host_path[130] ;
CLIptr CLImsg_ptr = {0, "nfm.dbg", 0, ""} ;
char CLIexec[200] = "PC Command Line Interface Installation" ;

/*** EXTERNALS ***/
extern char *optarg ;

/****************************************************************************
        Name: main
****************************************************************************/
long main(argc, argv)
     int argc;
     char *argv[];
{
  long j ;
  long status, i ;
  unsigned long free_space;
  unsigned long disk_req;
  float disk_reqf;
  char  path [130] ;

  /* Print the Copyright */
  _NFMprint_copyright (CLIexec) ;
/*  sleep (3) ; */

  /* Read command switches */
  status = options (argc,argv) ;
  if (status != CLI_S_SUCCESS)
    {
      exit (-1) ;
    }

  /* Verify that host name is in host file */
  fprintf (stderr, "  Verifying the host name in the host file..\n") ;
  status = VerifyHost();
  if (status != CLI_S_SUCCESS)
    {
      exit (-1) ;
    }
/*********
  fprintf (stderr, "  Checking disk space ..\n") ;
  
  disk_req = 6 ;
  disk_reqf = (float)disk_req / 1000000L;
  GetFreeSpace (&free_space); 
  if (free_space <= disk_req)
    {
      _CLI_num ("free space <%ld>", free_space) ;
      _CLI_num ("disk requirements <%ld>", disk_reqf) ;
      fprintf (stderr, "free space <%ld> <= disk requirement <%ld>\n",
	       free_space, disk_reqf) ;
      exit (-1) ;
    }
  _CLI_num ("free space <%ld>", free_space) ;
  _CLI_num ("disk requirements <%ld>", disk_reqf) ;
****************/  

  /***** Make directories ******/
  sprintf(bpath, "%s\\bin", nfm_path);
  sprintf(tpath, "%s\\temp", nfm_path);
  sprintf(cpath, "%s\\cfg", nfm_path);
  
  _CLI_str ("NFM path=[%s]",nfm_path);
  _CLI_str ("TEMP path=[%s]",tpath);				
  _CLI_str ("CFG path=[%s]",cpath);
	  
  fprintf (stderr, "  Making directory <%s> ..\n", nfm_path) ;
  /* make the main directory if not there */
  status = MakeDir(nfm_path);
  if (status != CLI_S_SUCCESS) 
    {
      fprintf (stderr, "Could not make directory %s\n", nfm_path) ;
      exit (-1) ;
    }
  else
    {
      fprintf (stderr, "  Making directory <%s> ..\n", cpath) ;
      status = MakeDir(cpath);
      if (status != CLI_S_SUCCESS)
	{
	  fprintf (stderr, "Could not make directory %s\n", cpath) ;
	  exit (-1) ;
	}

      fprintf (stderr, "  Making directory <%s> ..\n", bpath) ;
      status = MakeDir(bpath);				
      if (status != CLI_S_SUCCESS)
	{
	  fprintf (stderr, "Could not make directory %s\n", bpath) ;
	  exit (-1) ;
	}

      fprintf (stderr, "  Making directory <%s> ..\n", tpath) ;
      status = MakeDir(tpath);
      if (status != CLI_S_SUCCESS)
	{
	  fprintf (stderr, "Could not make directory %s. Please make directory manually\n", tpath) ;
	}
    }


  /* write the configuration file */
  fprintf (stderr, "  Writing to I/NFM default file ..\n") ;
  status = WriteCFGFile();
  if (status != CLI_S_SUCCESS)
    {
      exit (-1) ;
    }

	  
  /* unpack CNFM.EXE - it has README, nremove.exe, nfmpc.exe 
   */
  fprintf (stderr, "  Installing Product ..\n") ;
  status = InstallProduct();
  if (status != CLI_S_SUCCESS)
    {
      exit (-1) ;
    }

  fprintf (stderr, "  Updating Autoexec.bat ..\n") ;
  
  /* update autoexec.bat file */
  i = UpdateAutoexec();
  if (i == -1)
    {
      exit (-1) ;
    }

  fprintf (stderr, "Installation Complete\n") ;
  DeleteFiles();
  exit (0) ;
}


long options (argc, argv)
     int argc;
     char *argv[];
{
  char *fname = "options" ;
  char c ;
  long debug_on, error_flag, no_switches_flag ;
  char debug_file [128] ;

  /*init debug = OFF ; error = FALSE */
  debug_on = 0 ; error_flag = 0 ; debug_file [0] = 0 ;
  nfm_path [0] = 0 ; pcid [0] = 0 ;

  /* check options */
/* may have to add an extra option for selecting the nfs_option 
   such as -n (nfs) -w (wollengong) -f (ftp) 
   default to ftp (1)
*/
  nfs_package = FTP ;

  no_switches_flag = 1 ;

  while ((c = getopt(argc,argv,"do:p:h:")) != EOF)
    {
      no_switches_flag = 0 ;
      switch(c)
        {
	case 'p':
	  strncpy (nfm_path, optarg, sizeof(nfm_path)) ;
	  break;
	  
	case 'h':
	  strncpy (pcid, optarg, sizeof(pcid)) ;
	  break ;

	case 'd' :
	  debug_on = 1 ;
	  break ;

        case 'o' :
	  strncpy (debug_file, optarg, sizeof(debug_file)) ;
          break ;

	  default :
	    error_flag = 1;
	  fprintf (stderr,"Usage: %s [-d [-o debug file] [-h hostname] [-p complete nfm_path] \n", argv[0]);
	  break ;

	}
    }

  if (no_switches_flag)
    {
      error_flag = 1;
      fprintf (stderr,"Usage: %s [-d [-o debug file] [-h hostname] [-p absolute nfm_path] \n", argv[0]);
    }

  if( error_flag )
    {
      return (CLI_E_FAILURE) ;
    }

  if (debug_on)
    {
      if (strlen (debug_file))
	{
	  CLImsg_ptr.debug_on = 1 ;
	  strcpy (CLImsg_ptr.debug_file, debug_file) ;
	}
      else
	{
	  fprintf (stderr, "Please specify Debug File [-d -o <debug file>]\n") ;
	  return (CLI_E_FAILURE) ;
	}
    }

  if (! strlen (nfm_path))
    {
      fprintf (stderr, "Please specify I/NFM absolute path [-p <absolute nfm_path>]\n") ;
      return (CLI_E_FAILURE) ;
    }
  else
    {
      if ((strncmp (nfm_path, "c:\\", 3)) &&
	  (strncmp (nfm_path, "C:\\", 3)))
	{
	  fprintf (stderr, "Not a absolute path from root\n") ;
	  return (CLI_E_FAILURE) ;
	}

    }

  if (! strlen (pcid))
    {
      fprintf (stderr, "Please specify Host Name [-h <host name>]\n") ;
      return (CLI_E_FAILURE) ;
    }

  if (debug_on)
    {
      _CLI_str ("debug file <%s>", CLImsg_ptr.debug_file) ;
      _CLI_str ("debug goes here ..") ;
    }
  _CLI_str ("nfm path <%s>", nfm_path) ;
  _CLI_str ("pc id <%s>", pcid) ;
  return (CLI_S_SUCCESS) ;
}


long WriteCFGFile()
{
  char  *fname="WriteCFGFile" ;
  char  filename [128] ;
  FILE  *cfg_file ;

  sprintf (filename, "%s\\defaults", cpath) ;
  cfg_file = fopen(filename, "w") ;
  if( cfg_file == NULL )
    {
      _CLI_str("Could not open defaults file <%s>", filename) ;
      return (CLI_E_FAILURE) ;
    }

  fprintf (cfg_file, "PCID : %s\n", pcid) ;
  fprintf(cfg_file, "HOSTSFILE : %s\n", host_path);
  fprintf (cfg_file, "SERVER      :\n") ;
  fprintf (cfg_file, "ENVIRONMENT :\n") ;
  fprintf (cfg_file, "USERNAME    :\n") ;
  fprintf(cfg_file,  "PASSWORD    :\n") ;
  fprintf (cfg_file, "CATALOG     :\n") ;
  fprintf (cfg_file, "ITEMNAME    :\n") ;
  fprintf (cfg_file, "REVISION    :\n") ;
  fprintf (cfg_file, "OVERWRITE   : N\n");
  fprintf (cfg_file, "SEARCH_NAME :\n") ;
  fprintf (cfg_file, "SORT_NAME   :\n") ;
  fprintf (cfg_file, "LIST_ITEM_FILE :\n") ;
  fprintf (cfg_file, "ADD_ITEM_FILE :\n") ;
  fprintf (cfg_file, "DEFAULTS_FILE :\n") ;
  fclose( cfg_file );
  return (CLI_S_SUCCESS) ;
}
