#include "machine.h"
#include <stdio.h>
#include <string.h>

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
# include "CLI.h"
#else
# include <io.h>
# include "CLIerrordef.h"
# include "CLIstruct.h"
# include "CLIextern.h"
# include "NFMerrordef.h"
# include "proto.h"
# include "pc.h"
# include <memcheck.h>
#endif
#include "WFcommands.h"

extern char *buffer;

long  CLIcheckin_item( )
{
  long  status ;
  char  message[256] = {"\0"};
  char  *fname = "CLIcheckin_item";


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifndef OS_UNIX
  char returned_string[256]={"\0"};
  long  err_no = NFM_S_SUCCESS;
#endif

  _CLI_str( "%s", "Entering CLIcheckin_item" );
  
  CLIprint( CLIout_file, "CHECKIN_ITEM : Catalog <%s> Item <%s> Revision <%s> Storage Area <%s>", CLIcatalog, CLIitem, CLIrev, CLIstorage );
  CLIprint( stderr, "CHECKIN_ITEM : Catalog <%s> Item <%s> Revision <%s> Storage Area <%s>", CLIcatalog, CLIitem, CLIrev, CLIstorage );


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX

  CLIoperation.transfer = NFM_CONDITIONAL_TRANSFER;
  CLIoperation.delete   = NFM_CONDITIONAL_DELETE;
  CLIoperation.purge    = NFM_PURGE;

  CLIwf_info.workflow = NFM_WORKFLOW;
  strcpy (CLIwf_info.command, CHECKIN_ITEM);
  strcpy (CLIwf_info.workflow_name, "NFM_ITEM_WORKFLOW");
  strcpy (CLIwf_info.project_name, "\0");
  strcpy (CLIwf_info.app_name, "NFM");

  _CLI_num ("CLIwf_info.workflow = <%d>", CLIwf_info.workflow);
  _CLI_str ("CLIwf_info.command = <%s>", CLIwf_info.command);
  _CLI_str ("CLIwf_info.workflow_name = <%s>", CLIwf_info.workflow_name);
  _CLI_str ("CLIwf_info.project_name = <%s>", CLIwf_info.project_name);
  _CLI_str ("CLIwf_info.app_name = <%s>", CLIwf_info.app_name);
#endif

  
  status = NFMRcheckin_item( CLIcatalog, -1, CLIitem, CLIrev, CLIstorage,
			    CLIwf_info, CLIoperation );

  if( status != NFM_S_SUCCESS )
  {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif

      _CLI_num ("Checkin Item Message : <0x%.8lx>", status);
      _CLI_str ("Checkin Item Message : %s", message);
      CLIprint (CLIout_file, 
	"Checkin Item <%s.%s> from catalog <%s> ws <%s> Message : %s", 
	       CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Checkin Item <%s.%s> from catalog <%s> ws <%s> Message : %s", 
	       CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);
    }
  else
    {
      fprintf( CLIout_file, "   Successful Item Checkin.\n" );
      fprintf( stderr, "   Successful Item Checkin.\n" );
    }
  
  _CLI_str( "%s : SUCCESSFUL", fname );
  return( CLI_S_SUCCESS );
}
