#include "machine.h"
#include <stdio.h>

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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


long  CLIcheckout_set( )
{

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifndef OS_UNIX
  char returned_string[256]={"\0"};
  long  err_no = NFM_S_SUCCESS;
#endif
  char message[256]={"\0"};
  char *fname = "CLIcheckout_set" ;
  long  status;
  int   flag ;
  
  _CLI_str( "%s : ENTER", fname) ;

    CLIprint( CLIout_file, "CHECKOUT_SET : Catalog <%s> Set <%s> Revision <%s> Storage Area <%s>", CLIcatalog, CLIitem, CLIrev, CLIstorage );
  CLIprint( stderr, "CHECKOUT_SET : Catalog <%s> Set <%s> Revision <%s> Storage Area <%s>", CLIcatalog, CLIitem, CLIrev, CLIstorage );

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  CLIoperation.transfer = NFM_CONDITIONAL_TRANSFER;
  CLIoperation.delete   = NFM_CONDITIONAL_DELETE;
  CLIoperation.purge    = NFM_PURGE;

  strcpy(CLIoperation.catalog, CLIcatalog);
  CLIoperation.catalog_no = -1;
  strcpy(CLIoperation.item_name, CLIitem);
  strcpy(CLIoperation.item_rev, CLIrev);

  CLIwf_info.workflow = NFM_WORKFLOW;
  strcpy (CLIwf_info.command, CHECKOUT_SET);
  strcpy (CLIwf_info.workflow_name, "NFM_ITEM_WORKFLOW");
  strcpy (CLIwf_info.project_name, "\0");
  strcpy (CLIwf_info.app_name, "NFM");
#endif

  status = NFMRvalidate_revision ( CLIcatalog, CLIitem, CLIrev, &flag) ;
  if (status != NFM_S_SUCCESS)
    {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif

      _CLI_num ("NFMRvalidate_revision:Checkout Set Message : <0x%.8lx>", status);
      _CLI_str ("NFMRvalidate_revision:Checkout Set Message : %s", message);

      CLIprint (CLIout_file, 
	"NFMRvalidate_revision:Checkout Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Checkout Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);
      
   }

  if (flag == 0)
    {
     _CLI_str ("Item must be a set parent%s", "") ;

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
     ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item must be a set parent") ;
     ERRget_message( message );
     ERRreset_struct () ;
#else
     strcpy (message, "Item must be a set parent") ;
     _NFMget_server_response (err_no, message, returned_string) ;
#endif

      _CLI_num ("NFMRvalidate_revision:Checkout Set Message : <0x%.8lx>", status);
      _CLI_str ("NFMRvalidate_revision:Checkout Set Message : %s", message);

      CLIprint (CLIout_file, 
	"NFMRvalidate_revision:Checkout Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Checkout Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);

    }

  status = NFMRcheckout_set( CLIcatalog, -1, CLIitem, CLIrev, -1, CLIstorage, 
			CLIwf_info, NFM_SAME_OPERATION, &CLIoperation, 0) ;

  if( status != NFM_S_SUCCESS )
  {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif

      _CLI_num ("NFMRcheckout_set:Checkout Set Message : <0x%.8lx>", status);
      _CLI_str ("NFMRcheckout_set:Checkout Set Message : %s", message);

      CLIprint (CLIout_file, 
	"NFMRcheckout_set:Checkout Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Checkout Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);
      
  }
  else
      fprintf( CLIout_file, "NFMRcheckout_set: Successful Set Checkout.\n" );
      fprintf( stderr, "   Successful Set Checkout.\n" );
  
  _CLI_str( "%s : SUCCESSFUL", fname) ;
  return( CLI_S_SUCCESS );
}
