#include <stdio.h>
#ifdef UNIX
# include "CLI.h"
#else
# include "CLIerrordef.h"
# include "CLIstruct.h"
# include "CLIextern.h"
# include "NFMerrordef.h"
# include "proto.h"
# include <memcheck.h>
#endif
#include "WFcommands.h"

long  CLIcheckin_set( )
{
  char *fname = "CLIcheckin_set" ;
#ifndef UNIX
  char  returned_string[256] = {"\0"};
  long  err_no = NFM_S_SUCCESS;
#endif
  char  message[256] = {"\0"};
  long  status ;
  int   flag ;

  _CLI_str( "%s : ENTER", fname) ;

  CLIprint( CLIout_file, "CHECKIN_SET : Catalog <%s> Set <%s> Revision <%s> Storage Area <%s>", CLIcatalog, CLIitem, CLIrev, CLIstorage );
  CLIprint( stderr, "CHECKIN_SET : Catalog <%s> Set <%s> Revision <%s> Storage Area <%s>", CLIcatalog, CLIitem, CLIrev, CLIstorage );

#ifdef UNIX
  CLIoperation.transfer = NFM_CONDITIONAL_TRANSFER;
  CLIoperation.delete   = NFM_CONDITIONAL_DELETE;
  CLIoperation.purge    = NFM_PURGE;
 
  strcpy (CLIoperation.catalog, CLIcatalog); 
  CLIoperation.catalog_no = -1;
  strcpy (CLIoperation.item_name, CLIitem);
  strcpy (CLIoperation.item_rev, CLIrev);

  CLIwf_info.workflow = NFM_WORKFLOW;
  strcpy (CLIwf_info.command, CHECKIN_SET);
  strcpy (CLIwf_info.workflow_name, "NFM_ITEM_WORKFLOW");
  strcpy (CLIwf_info.project_name, "\0");
  strcpy (CLIwf_info.app_name, "NFM");

  _CLI_num ("CLIwf_info.workflow = <%d>", CLIwf_info.workflow);
  _CLI_str ("CLIwf_info.command = <%s>", CLIwf_info.command);
  _CLI_str ("CLIwf_info.workflow_name = <%s>", CLIwf_info.workflow_name);
  _CLI_str ("CLIwf_info.project_name = <%s>", CLIwf_info.project_name);
  _CLI_str ("CLIwf_info.app_name = <%s>", CLIwf_info.app_name);
#endif

#ifdef UNIX
  status = NFMRvalidate_revision ( CLIcatalog, CLIitem, CLIrev, &flag ) ;
  if (status != NFM_S_SUCCESS)
    {

     ERRget_message( message );
     ERRreset_struct();

     _CLI_num ("Checkin Set Message : <0x%.8lx>", status);
     _CLI_str ("Checkin Set Message : %s", message);

     CLIprint (CLIout_file, 
	"Checkin Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Checkin Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);
    }

  if (flag == 0)
    {
     _CLI_str ("Item must be a set parent%s", "") ;

     ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item must be a set parent") ;
     ERRget_message( message );
     ERRreset_struct () ;


      _CLI_num ("Checkin Set Message : <0x%.8lx>", status);
      _CLI_str ("Checkin Set Message : %s", message);

      CLIprint (CLIout_file, 
	"Checkin Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Checkin Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);

    }
#endif

  status = NFMRcheckin_set( CLIcatalog, -1, CLIitem, CLIrev, -1, CLIstorage,
		CLIwf_info, NFM_SAME_OPERATION, &CLIoperation, 0);

  if( status != NFM_S_SUCCESS )
  {
#ifdef UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif

     _CLI_num ("Checkin Set Message : <0x%.8lx>", status);
     _CLI_str ("Checkin Set Message : %s", message);

     CLIprint (CLIout_file, 
	"Checkin Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Checkin Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);
    }
  else
    fprintf( CLIout_file, "   Successful Set Checkin.\n" );
    fprintf( stderr, "   Successful Set Checkin.\n" );
  
  _CLI_str( "%s : SUCCESSFUL", fname) ;
  return( CLI_S_SUCCESS );
}





