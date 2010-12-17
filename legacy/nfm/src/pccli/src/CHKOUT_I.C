#include <stdio.h>
#include <string.h>

#ifdef UNIX
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


long  CLIcheckout_item( )
{
#ifndef UNIX
  char returned_string [256]={"\0"};
  long  err_no = NFM_S_SUCCESS;
#endif
  char  message [256]={"\0"};
  long  status;
  
  _CLI_str( "%s", "Entering CLIcheckout_item" );
  
  CLIprint( CLIout_file, "CHECKOUT_ITEM : Catalog <%s> Item <%s> Revision <%s> : Working Area <%s>", 
	  CLIcatalog, CLIitem, CLIrev, CLIstorage );
  CLIprint( stderr, "CHECKOUT_ITEM : Catalog <%s> Item <%s> Revision <%s> : Working Area <%s>", 
	  CLIcatalog, CLIitem, CLIrev, CLIstorage );

#ifdef UNIX  
  CLIoperation.transfer = NFM_CONDITIONAL_TRANSFER;
  CLIoperation.delete   = NFM_CONDITIONAL_DELETE;
  CLIoperation.purge    = NFM_PURGE;

  CLIwf_info.workflow = NFM_WORKFLOW; 
  strcpy (CLIwf_info.command, CHECKOUT_ITEM); 
  strcpy (CLIwf_info.workflow_name, "NFM_ITEM_WORKFLOW"); 
  strcpy (CLIwf_info.project_name, "\0");
  strcpy (CLIwf_info.app_name, "NFM");

  _CLI_num ("CLIwf_info.workflow = <%d>", CLIwf_info.workflow);
  _CLI_str ("CLIwf_info.command = <%s>", CLIwf_info.command);
  _CLI_str ("CLIwf_info.workflow_name = <%s>", CLIwf_info.workflow_name);
  _CLI_str ("CLIwf_info.project_name = <%s>", CLIwf_info.project_name);
  _CLI_str ("CLIwf_info.app_name = <%s>", CLIwf_info.app_name);
#endif

  status = NFMRcheckout_item( CLIcatalog, -1, CLIitem, CLIrev, 
			     CLIstorage, CLIwf_info, CLIoperation );
  
  if( status != NFM_S_SUCCESS )
  {
#ifdef UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif
      
      _CLI_num ("Checkout Item Message : <0x%.8lx>", status);
      _CLI_str ("Checkout Item Message : %s", message);
      CLIprint( CLIout_file, 
	"Checkout Item <%s.%s> from catalog <%s> ws <%s> Message : %s",
	      CLIitem, CLIrev, CLIcatalog, CLIstorage, message);
      CLIprint( stderr, 
	"Checkout Item <%s.%s> from catalog <%s> ws <%s> Message : %s",
	      CLIitem, CLIrev, CLIcatalog, CLIstorage, message);
      return( CLI_E_FAILURE );
    }
  else
    {
      fprintf( CLIout_file, "   Successful Checkout Item.\n" );
      fprintf( stderr, "   Successful Checkout Item.\n" );
    }
  _CLI_str( "%s", "Exiting CLIcheckout_item" );
  
  return( CLI_S_SUCCESS );
}



