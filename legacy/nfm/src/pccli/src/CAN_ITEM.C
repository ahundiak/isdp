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
# include "WFcommands.h"

long  CLIcancel_item_archive( )
{
  char *fname = "CLIcancel_item_archive" ;
  char message[256] = {"\0"};
  long  status;
  long  user_id = 0;
  long  err_no = NFM_S_SUCCESS;
#ifdef UNIX
  int   subsystem;
#else
  char returned_string [256] = {"\0"};
#endif
 
  _CLI_str( "%s : ENTER", fname ) ;

  CLIprint( stderr, 
	"CANCEL_ITEM_ARCHIVE_FLAG : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );

  CLIprint( CLIout_file, 
	"CANCEL_ITEM_ARCHIVE_FLAG : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );

  status = NFMRvalidate_user_access ( 0, CANCEL_ITEM_ARCHIVE_FLAG, "", "",
                                        CLIcatalog, CLIitem, CLIrev);
  
  if (status != NFM_S_SUCCESS)
  {
#ifdef UNIX 
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif 
     _CLI_num("Validate user access Message : <0x%.8lx>", status);
     _CLI_str("Validate user access Message : %s", message);
     CLIprint( CLIout_file, "Validate User Access Message : %s", message) ;
     CLIprint( stderr, "Validate User Access Message : %s", message) ;
     return( CLI_E_FAILURE );
  }

  status = NFMRcancel_item_archive_flag( user_id, CLIcatalog, CLIitem, CLIrev );

#ifdef UNIX 
  ERRget_message( message );
  ERRget_number( &err_no, &subsystem );
#else
  _NFMget_server_response (err_no, message, returned_string) ;
#endif 
  if (status != NFM_S_SUCCESS) 
  {
     _CLI_num("Cancel item archive flag Message : <0x%.8lx>", status);
     _CLI_str("Cancel item archive flag Message : %s", message);
     CLIprint (CLIout_file, 
	"Cancel Item Archive <%s.%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog, message) ;
     CLIprint (stderr, 
	"Cancel Item Archive <%s.%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog, message) ;
  }

  if ( NFMRset_wf_state ( "NFM", err_no, message ) != NFM_S_SUCCESS) 
  {
#ifdef UNIX 
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif 
     _CLI_str( "%s : Set to State Message", fname );
     CLIprint( CLIout_file, "Cancel Item Archive Flag Message : %s",message);
     CLIprint( stderr, "Cancel Item Archive Flag Message : %s",message);
     return( CLI_E_FAILURE );
  }
 
  if (status != NFM_S_SUCCESS)
  {
     _CLI_str( "%s : EXIT", fname) ;
     return(CLI_E_FAILURE);
  } 

  fprintf( CLIout_file, "   Successful Cancel Item Archive Flag.\n" );
  fprintf( stderr , "   Successful Cancel Item Archive Flag.\n" );
  _CLI_str( "%s : SUCCESSFUL", fname) ;
  return( CLI_S_SUCCESS );
}

long  CLIcancel_item_backup( )
{
  char *fname = "CLIcancel_item_backup" ;
  char message[256] = {"\0"};
  long  status;
  long  user_id = 0;
  long  err_no = NFM_S_SUCCESS;
#ifdef UNIX
  int   subsystem;
#else
  char returned_string [256]={"\0"};
#endif

  _CLI_str( "%s: ENTER", fname) ;

  CLIprint( CLIout_file, 
	"CANCEL_ITEM_BACKUP_FLAG : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );
  
  CLIprint( stderr, 
	"CANCEL_ITEM_BACKUP_FLAG : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );
  
  status = NFMRvalidate_user_access ( 0, CANCEL_ITEM_BACKUP_FLAG, "", "",
                                        CLIcatalog, CLIitem, CLIrev);
  if (status != NFM_S_SUCCESS)
  {
#ifdef UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif
     _CLI_num("Validate user access Message : <0x%.8lx>", status);
     _CLI_str("Validate user access Message : %s", message);
     CLIprint( CLIout_file, "Validate User Access Message : %s", message) ;
     CLIprint( stderr, "Validate User Access Message : %s", message) ;
     return( CLI_E_FAILURE );
  }

  status = NFMRcancel_item_backup_flag( user_id, CLIcatalog, CLIitem, CLIrev );

#ifdef UNIX 
     ERRget_message( message );
     ERRget_number( &err_no, &subsystem );
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif 
  if (status != NFM_S_SUCCESS) 
  {
     _CLI_num("Cancel item backup flag Message : <0x%.8lx>", status);
     _CLI_str("Cancel item backup flag Message : %s", message);
     CLIprint (CLIout_file, 
	"Cancel Item Backup <%s.%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog, message) ;
     CLIprint (stderr, 
	"Cancel Item Backup <%s.%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog, message ) ;
  }
  
  if ( NFMRset_wf_state ( "NFM", err_no, message ) != NFM_S_SUCCESS) 
  {
#ifdef UNIX 
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif 
     _CLI_str( "%s : Set to State Message", fname );
     CLIprint( CLIout_file, 
	"     Cancel Item Backup Flag Message : %s",message);
     CLIprint( stderr, 
	"     Cancel Item Backup Flag Message : %s",message);
     return( CLI_E_FAILURE );
  }
  if (status != NFM_S_SUCCESS)
  {
     _CLI_str("%s : EXIT", fname);
     return (CLI_E_FAILURE);
  }

  fprintf( CLIout_file, "   Successful Cancel Item Backup Flag.\n" );
  fprintf( stderr , "   Successful Cancel Item Backup Flag.\n" );
  _CLI_str( "%s : SUCCESSFUL", fname) ;
  return( CLI_S_SUCCESS );
}

long  CLIcancel_item_restore( )
{
  char *fname = "CLIcancel_item_restore" ;
  char message[256] = {"\0"};
  long  status;
  long  user_id = 0;
  long  err_no = NFM_S_SUCCESS;
#ifdef UNIX
  int   subsystem;
#else
  char returned_string [256]={"\0"};
#endif
  
  _CLI_str( "%s : ENTER", fname) ;
  
  CLIprint( CLIout_file, 
	"CANCEL_ITEM_RESTORE_FLAG : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );

  CLIprint( stderr, 
	"CANCEL_ITEM_RESTORE_FLAG : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );

  status = NFMRvalidate_user_access ( 0, CANCEL_ITEM_RESTORE_FLAG, "", "",
                                        CLIcatalog, CLIitem, CLIrev);
  
  if (status != NFM_S_SUCCESS)
  {
#ifdef UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif
     _CLI_num("Validate user access Message : <0x%.8lx>", status);
     _CLI_str("Validate user access Message : %s", message);
     CLIprint( CLIout_file, "Validate User Access Message : %s", message) ;
     CLIprint( stderr, "Validate User Access Message : %s", message) ;
     return( CLI_E_FAILURE );
  }

  status = NFMRcancel_item_restore_flag( user_id, CLIcatalog, CLIitem, CLIrev );

#ifdef UNIX 
     ERRget_message( message );
     ERRget_number( &err_no, &subsystem );
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif 

  if (status != NFM_S_SUCCESS) 
  {
     _CLI_num("Cancel item restore flag Message : <0x%.8lx>", status);
     _CLI_str("Cancel item restore flag Message : %s", message);
     CLIprint (CLIout_file, 
	"Cancel Item Restore <%s.%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog, message) ;
     CLIprint (stderr, 
	"Cancel Item Restore <%s.%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog, message) ;
  }
   
  if (NFMRset_wf_state ( "NFM", err_no, message ) != NFM_S_SUCCESS) 
  {
#ifdef UNIX 
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif 
     _CLI_str( "%s : Set to State Message", fname );
      CLIprint (CLIout_file, 
	"Cancel Item Restore <%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog,message);
      CLIprint (stderr, 
	"Cancel Item Restore <%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog,message);
      
      return( CLI_E_FAILURE );
  }
  if (status != NFM_S_SUCCESS)
  {
      _CLI_str("%s : EXIT", fname);
      return(CLI_E_FAILURE);
  }

  fprintf( CLIout_file, "   Successful Cancel Item Restore Flag.\n" );
  fprintf( stderr, "   Successful Cancel Item Restore Flag.\n" );
  _CLI_str( "%s : SUCCESSFUL", fname) ;
  return( CLI_S_SUCCESS );
}

long  CLIcancel_item_checkout( )
{
  char *fname = "CLIcancel_item_checkout" ;
#ifdef UNIX
  int subsystem;
#else
  char returned_string [256]={"\0"};
#endif
  char message[256] = {"\0"};
  long  err_no = NFM_S_SUCCESS;
  long  status;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  CLIprint( CLIout_file, 
	"CANCEL_ITEM_CHECKOUT : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );
  
  CLIprint( stderr, 
	"CANCEL_ITEM_CHECKOUT : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );

#ifdef UNIX
  CLIoperation.transfer = NFM_CONDITIONAL_TRANSFER;
  CLIoperation.delete   = NFM_CONDITIONAL_DELETE;
  CLIoperation.purge    = NFM_PURGE;

  CLIwf_info.workflow = NFM_WORKFLOW;
  strcpy (CLIwf_info.command, CANCEL_ITEM_CHECKOUT);
  strcpy (CLIwf_info.workflow_name, "NFM_ITEM_WORKFLOW");
  strcpy (CLIwf_info.project_name, "\0");
  strcpy (CLIwf_info.app_name, "NFM");

  _CLI_num ("CLIwf_info.workflow = <%d>", CLIwf_info.workflow);
  _CLI_str ("CLIwf_info.command = <%s>", CLIwf_info.command);
  _CLI_str ("CLIwf_info.workflow_name = <%s>", CLIwf_info.workflow_name);
  _CLI_str ("CLIwf_info.project_name = <%s>", CLIwf_info.project_name);
  _CLI_str ("CLIwf_info.app_name = <%s>", CLIwf_info.app_name);
#endif


  status = NFMRcancel_check_out_item(CLIcatalog, 0, CLIitem, CLIrev, 
						CLIwf_info, CLIoperation );
#ifdef UNIX 
      ERRget_message( message );
      ERRget_number (&err_no, &subsystem);
#else
      _NFMget_server_response (err_no, message, returned_string) ;
#endif 

  if( status != NFM_S_SUCCESS )
    {
      _CLI_num("Cancel Item Checkout Message : <0x%.8lx>", status);
      _CLI_str("Cancel Item Checkout Message : %s", message);
      CLIprint (CLIout_file, 
	"Cancel Item checkout <%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog, message);
      CLIprint (stderr, 
	"Cancel Item checkout <%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog, message) ;
    }

  if (NFMRset_wf_state ( "NFM", err_no, message ) != NFM_S_SUCCESS) 
  {
#ifdef UNIX 
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif 
     _CLI_str( "%s : Set to State Message", fname );
      CLIprint (CLIout_file, 
	"Cancel Item Checkout <%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog,message);
      CLIprint (stderr, 
	"Cancel Item Checkout <%s> from catalog <%s> Message : %s",
	       CLIitem, CLIrev, CLIcatalog,message);
      
      return( CLI_E_FAILURE );
   }
   if (status != NFM_S_SUCCESS)
   {
      _CLI_str("%s : EXIT", fname);
      return(CLI_E_FAILURE);
   }
     
   fprintf( CLIout_file, "   Successful Cancel Item Checkout.\n" );
   fprintf( stderr, "   Successful Cancel Item Checkout.\n" );
   _CLI_str( "%s : SUCCESSFUL", fname) ;
   return( CLI_S_SUCCESS );
}
