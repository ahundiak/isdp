#include "machine.h"
#include <stdio.h>
#include "NFMstruct.h"
#include "NFMerrordef.h"
#include "NFMdef.h" 
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMversion.h"
#include "NETstruct.h"
#include "MSGstruct.h"
#include <pwd.h>

       extern MSGptr NFMmsg_ptr;
       int  max_itemno ;
      char   SCHEMA[100] ;
      struct NFMglobal_st NFMglobal ;
      long silent_mode ;

main (argc, argv)
     int argc ;
     char **argv ;
{
  char *fname = "main" ;
  long    status ;
  char    debug_file [1024], env_name [200] ;
  char    SCHEMA_NAME [100] ;
  long    all_environments, count, NO_ENVIRONMENTS ;
  char    msg[256];
  MEMptr  env_buffer = NULL ;
  char   **data = NULL ;
  FILE   *update_err;


  _NFMdebug ((fname, "ENTER\n")) ;
  silent_mode = 0 ;
  all_environments = 0 ;
  NO_ENVIRONMENTS = 0 ;
  status = UPDline_options (argc, argv,
			    debug_file, env_name,
			    &silent_mode, &all_environments) ;
  if (status != NFM_S_SUCCESS)
    {
      exit(1) ;
    }
  
  if (! silent_mode) 
    {
      _NFMprint_copyright ("3.0 Update Utility") ;
/*      _NFMprint_description ("3.0 Update Utility") ; */
    }

  if (strlen (debug_file))
    {
      strcpy (_NFMdebug_st.NFMdebug_file, debug_file) ;
      strcpy (_NFMdebug_st.SQLdebug_file, debug_file) ;
      _NFMdebug_st.NFMdebug_on = 1 ;
      _NFMdebug_st.SQLdebug_on = 1 ;
      _NFMdebug ((fname, "DEBUG GOES TO %s\n", _NFMdebug_st.NFMdebug_file));
    }
  else
    {
      _NFMdebug_st.NFMdebug_on = 0 ;
      _NFMdebug_st.SQLdebug_on = 0 ;
    }

  if (all_environments)
    {
      status = _NFMget_env_list (&env_buffer) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	  exit(1) ;
	}
      if (env_buffer -> rows == 0)
	{
	  _NFMdebug ((fname, "No environment exist\n")) ;
	  MEMclose (&env_buffer) ;
	  exit (1) ;
	}

      status = MEMbuild_array (env_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	  MEMclose (&env_buffer) ;
	  exit (1) ;
	}
      data = (char **) env_buffer->data_ptr ;
      NO_ENVIRONMENTS = env_buffer -> rows ;
    }

  count = 1 ;
  while (1)
    {
      if (all_environments)
	{
	  if (count > NO_ENVIRONMENTS)
	    {
	      MEMclose (&env_buffer) ;
	      _NFMdebug ((fname, "DONE with multiple ENVIRONMENTS\n")) ;
	      break ;
	    }
	  strcpy (env_name, data [count-1]) ;
	}
      else
	{
	  if (count > 1)
	    {
	      _NFMdebug ((fname, "DONE with single ENVIRONMENT\n")) ;
	      break ;
	    }
	}

      _NFMdebug ((fname, "ENVIRONMENT <%d : %s>\n", count, env_name)) ;
      ++count ;

      if (!strlen (env_name))
	{
	  MEMclose (&env_buffer) ;
	  if (! silent_mode) fprintf (stderr, "environment not given\n") ;
	  break ;
	}
      
      /* KT - initial global structure - environment name */
      strcpy (NFMglobal.environment_name, env_name);
      
      _NFMdebug ((fname, "Getting schema information...\n")) ;

      status = TMPget_schema_info (env_name, SCHEMA_NAME) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		      status)) ;
	}
      strcpy (SCHEMA, SCHEMA_NAME) ;

      if (! silent_mode) fprintf (stderr, "Updating Environment <%s>\n",
				  env_name) ;

      status = TMPprogram () ;
      if (status != NFM_S_SUCCESS)
    	{
 printf("Unable To Add REDLINE Catalog Info To Environment <%s>\n", env_name);
 _NFMdebug ((fname, "TSTsql Failed : status = <0x%.8x>\n",
              status));
    	}
  
      close_schema () ;
    }

  MEMclose (&env_buffer) ;
  _NFMdebug ((fname, "EXITING UPDATE UTILITY\n")) ;
  if (! silent_mode) fprintf(stderr, "EXITING UPDATE UTILITY\n") ;
  exit (0) ;
}







