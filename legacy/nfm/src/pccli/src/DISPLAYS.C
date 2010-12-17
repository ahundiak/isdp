#include <stdio.h>

# include "CLIstruct.h"
#ifdef UNIX
#include "CLI.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#else
# include "CLIerrordef.h"
# include "CLIextern.h"
# include "NFMerrordef.h"
# include "proto.h"
# include <memcheck.h>
#endif
# include "WFcommands.h"

long  CLIdisplay_items( )
{
    char  *fname = "CLIdisplay_items";
#ifdef UNIX
    long clix_display_items () ;
#else
    long pc_display_items () ;
#endif

    _CLI_str( "%s", "Entering CLIdisplay_items" );

#ifdef UNIX
    clix_display_items () ;
#else
    pc_display_items () ;
#endif


    _CLI_str( "%s", "Exiting CLIdisplay_items" );
    return( CLI_S_SUCCESS );
}

#ifdef UNIX
long clix_display_items()
{
  char *fname = "clix_display_items" ;
  int    subsystem ;
  long   i,y, offset ;
  MEMptr syn_list = NULL, data_list = NULL ;
  char   **data, **data1, **format1, tmp_str [512] ;
  long   size ;
  char  message[256] = {"\0"};
  long  status ;
  long  err_no=NFM_S_SUCCESS;
  FILE *display_fd ;
  
  _CLI_str ("%s : ENTER\n", fname) ;

  status = NFMRdisplay_items (CLIcatalog, "", "", 0, &syn_list, &data_list);
  ERRget_message( message );
  ERRget_number( &err_no, &subsystem );
  if (status != NFM_S_SUCCESS)
    {
      _CLI_num("Display Items failed : <0x%.8lx>", status);
      _CLI_str("Display Items failed : %s", message);
      CLIprint (CLIout_file,
		"Display Items from catalog <%s> failed : %s",
		CLIcatalog, message) ;
      CLIprint (stderr,
		"Display Items from catalog <%s> failed : %s",
		CLIcatalog, message) ;
    }
  else
    {
      if (strlen (CLIdisplay_file))
	{
	  display_fd = fopen (CLIdisplay_file, "w") ;
	  if (display_fd == NULL)
	    {
	      return (CLI_E_FAILURE) ;
	    }
	  status = MEMbuild_array (syn_list) ;
	  status = MEMbuild_array (data_list) ;
	  data = (char **) syn_list -> data_ptr ;
	  data1 = (char **) data_list->data_ptr ;
	  format1 = (char **) data_list->format_ptr ;
/****** HEADER - Column Name ***************/
	  for (i=0; i<syn_list->rows; i++)
	    {
	      if (! strcmp  (format1[i], "integer" ))   size = 15;
	      else if (! strcmp  (format1[i], "smallint"))   size = 15;
	      else if (! strcmp  (format1[i], "double"  ))   size = 50;
	      else if (! strcmp  (format1[i], "real"    ))   size = 50;
	      else if (! strcmp  (format1[i], "decimal" ))   size = 15;
	      else if (! strcmp  (format1[i], "date"    ))   size = 15;
	      else if (! strcmp  (format1[i], "timestamp"))  size = 21;
	      else if (! strncmp (format1[i], "char(", 5))
		{
		  sscanf (format1[i], "%5s%d", tmp_str, &size);
		}
	      else size = 15 ;
	      sprintf (tmp_str, "%%-%ds ", size) ;
	      fprintf (display_fd, tmp_str, data [i]) ;
	    }
	  fprintf (display_fd, "\n") ;
	  MEMclose (&syn_list) ;

/******** HEADER - Datatype ***********/	  
	  for (i=0; i<data_list->columns; i++)
	    {
	      if (! strcmp  (format1[i], "integer" ))   size = 15;
	      else if (! strcmp  (format1[i], "smallint"))   size = 15;
	      else if (! strcmp  (format1[i], "double"  ))   size = 50;
	      else if (! strcmp  (format1[i], "real"    ))   size = 50;
	      else if (! strcmp  (format1[i], "decimal" ))   size = 15;
	      else if (! strcmp  (format1[i], "date"    ))   size = 15;
	      else if (! strcmp  (format1[i], "timestamp"))  size = 21;
	      else if (! strncmp (format1[i], "char(", 5))
		{
		  sscanf (format1[i], "%5s%d", tmp_str, &size);
		}
	      else size = 15 ;
	      sprintf (tmp_str, "%%-%ds ", size) ;
	      fprintf (display_fd, tmp_str, format1[i]) ;
	    }
	  fprintf (display_fd, "\n") ;

/******** DATA ***********/
	  data = (char **) data_list -> data_ptr ;
	  for (i=0; i<data_list->rows; i++)
	    {
	      offset = i*data_list->columns ;
	      for (y=0; y<data_list->columns; y++) 
		{
		  if (! strcmp  (format1[y], "integer" ))   size = 15;
		  else if (! strcmp  (format1[y], "smallint"))   size = 15;
		  else if (! strcmp  (format1[y], "double"  ))   size = 50;
		  else if (! strcmp  (format1[y], "real"    ))   size = 50;
		  else if (! strcmp  (format1[y], "decimal" ))   size = 15;
		  else if (! strcmp  (format1[y], "date"    ))   size = 15;
		  else if (! strcmp  (format1[y], "timestamp"))  size = 21;
		  else if (! strncmp (format1[y], "char(", 5))
		    {
		      sscanf (format1[y], "%5s%d", tmp_str, &size);
		    }
		  else size = 15 ;
		  sprintf (tmp_str, "%%%ds ", size) ;
		  fprintf (display_fd, tmp_str, data [offset+y]) ;
		}
	      fprintf (display_fd, "\n") ;
	    }
	  MEMclose (&data_list) ;
	  fclose (display_fd) ;
	}
      else
	{
	  MEMprint_buffer ("syn list", syn_list, "/usr/tmp/cli_displays") ;
	  MEMprint_buffer ("data list", data_list, "/usr/tmp/cli_display") ;
	}
      fprintf( CLIout_file, "   Successful Display Items.\n" );
      fprintf( stderr , "   Successful Display Items.\n" );
    }
  return (CLI_S_SUCCESS) ;
}
#else

long pc_display_items()
{
  char *fname = "pc_display_items";
  long status, err_no ;
  char returned_string[256] = {"\0"} ;
  char message [256] ;

  status = NFMRpc_display_items (CLIcatalog, CLIsearch, CLIsort) ;
  _NFMget_server_response ( err_no, message, returned_string) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str("Display Items failed : <0x%.8lx>", status);
      _CLI_str("Display Items failed : %s", message);
      CLIprint (CLIout_file,
		"Display Items from catalog <%s> failed : %s",
		CLIcatalog, message) ;
      CLIprint (stderr,
		"Display Items from catalog <%s> failed : %s",
		CLIcatalog, message) ;
    }
  else
    {
      fprintf( CLIout_file, "   Successful Display Items.\n" );
	fprintf( stderr , "   Successful Display Items.\n" );
    }
  return (CLI_S_SUCCESS) ;
}
#endif














