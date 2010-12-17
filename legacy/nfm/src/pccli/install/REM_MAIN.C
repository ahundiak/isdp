/*****************************************************************************\
 SOURCE FILE: nremove.c
 AUTHOR: Rick Kramer Modified by Melania M Seward (no user interface) 9/9/92
 DATE: 02/25/1992
 SDM NUMBER:
 DESCRIPTION: This program will remove nfm from the path in the autoexec.bat
 				file, and remove all NFMPC programs, files and directories.
 				product.
   FUNCTIONS INVOKED:
						RemoveDir_Files(rem_dir.c)
						RemovePath(rem_path.c)
 PARAMETERS:
  ON ENTRY:
  ON EXIT:
 EXTERNAL VARIABLES:
 CHANGE HISTORY:
******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <ctype.h>
#include <process.h>
#include <string.h>
#include <dos.h>
#include <direct.h>
#include <io.h>
#include "getopt.h"
#include "ins_proto.h"
#include "pcinst.h"

/**** GLOBALS ****/
char wrk[255];
char pcid [80] ;
char nfm_path[130] ;
char bpath[130] ;
char cpath[130] ;
char tpath[130] ;
int  nfs_package ;
char host_path[130] ;
CLIptr CLImsg_ptr = {0, "nfm.dbg", 0, ""} ;
char CLIexec[200] = "PC Command Line Interface Remove" ;


/****************************************************************************
        Name: main rtn
****************************************************************************/
long main(argc, argv)
int argc;
char *argv[];
{
  char answer[10] ;
  long status ;

  fprintf (stderr, 
	   " Are you sure you want to delete product/path %s [y/n] (n) ") ;

  if(argc > 1)
  {
	CLImsg_ptr.debug_on =1 ;
  }
  
  gets (answer) ;
  if ((answer[0] != 'y') && (answer[0] != 'Y'))
    {
      exit(0) ;
    }

  _CLI_str("  Starting Remove\n",0);
  fprintf (stderr, "Checking if NFMPC.EXE is in path <%s>\n", nfm_path) ;

  _searchenv("NFMPC.EXE", "PATH", nfm_path);
  
  if (nfm_path[0] == '\0')
    {
      fprintf(stderr, "NFMPC.EXE program not found in %s\n", nfm_path);
      exit(1);
    }

  _CLI_str("NFMPC dpath=[%s]\n",nfm_path);
  
  chdir("\\");
  status = RemoveDir_Files(nfm_path);
  if (status != CLI_S_SUCCESS)
    {
      exit(-1) ;
    }
  
  RemovePath_auto(nfm_path);
  
  _CLI_str("Ending Remove\n",0);
}/*main */

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
  nfm_path [0] = 0 ; 

  no_switches_flag = 1 ;

  while ((c = getopt(argc,argv,"do:p:")) != EOF)
    {
      no_switches_flag = 0 ;
      switch(c)
        {
	case 'p':
	  strncpy (nfm_path, optarg, sizeof(nfm_path)) ;
	  break;
	  
	case 'd' :
	  debug_on = 1 ;
	  break ;

        case 'o' :
	  strncpy (debug_file, optarg, sizeof(debug_file)) ;
          break ;

	  default :
	    error_flag = 1;
	  fprintf (stderr,"Usage: %s [-d [-o debug file] [-p complete nfm_path] \n", argv[0]);
	  break ;

	}
    }

  if (no_switches_flag)
    {
      error_flag = 1;
      fprintf (stderr,"Usage: %s [-d [-o debug file] [-p absolute nfm_path] \n", argv[0]);
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

  if (debug_on)
    {
      _CLI_str ("debug file <%s>", CLImsg_ptr.debug_file) ;
      _CLI_str ("debug goes here ..") ;
    }
  _CLI_str ("nfm path <%s>", nfm_path) ;

  return (CLI_S_SUCCESS) ;
}
