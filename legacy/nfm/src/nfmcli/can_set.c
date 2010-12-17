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
# include "WFcommands.h"

long  CLIcancel_set_archive( )
{
  char *fname = "CLIcancel_set_archive" ;
  char message[256] = {"\0"};
  long  status;
  long  user_id = 0;
  long  err_no = NFM_S_SUCCESS;
  int  flag ;

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  int   subsystem;
#else
  char returned_string[256] = {"\0"};
#endif

  _CLI_str( "%s : ENTER", fname) ;
  
  CLIprint( CLIout_file, 
	"CANCEL_SET_ARCHIVE_FLAG : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);
  
  CLIprint( stderr, 
	"CANCEL_SET_ARCHIVE_FLAG : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);
 

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

      _CLI_num ("Cancel Set Archive Flag Message : <0x%.8lx>", status);
      _CLI_str ("Cancel Set Archive Flag Message : %s", message);

      CLIprint (CLIout_file, 
	"Cancel Set Archive Flag <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Cancel Set Archive Flag <%s.%s> from catalog <%s> ws <%s> Message : %s",
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

      _CLI_num ("Cancel Set Archive Flag Message : <0x%.8lx>", status);
      _CLI_str ("Cancel Set Archive Flag Message : %s", message);

      CLIprint (CLIout_file, 
	"Cancel Set Archive Flag <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Cancel Set Archive Flag <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);

    }



  status = NFMRvalidate_user_access ( 0, CANCEL_SET_ARCHIVE_FLAG, "", "",
                                        CLIcatalog, CLIitem, CLIrev);
  if (status != NFM_S_SUCCESS)
  {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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
 
  status = NFMRcancel_set_archive_flag( user_id, CLIcatalog, CLIitem, CLIrev );

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  ERRget_message( message );
  ERRget_number( &err_no, &subsystem );
#else
  _NFMget_server_response (err_no, message, returned_string) ;
#endif

  if (status != NFM_S_SUCCESS)
  {
     _CLI_num("Cancel Set archive flag Message : <0x%.8lx>", status);
     _CLI_str("Cancel Set archive flag Message : %s", message);
     CLIprint (CLIout_file,
        "Cancel Set Archive <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
     CLIprint (stderr,
        "Cancel Set Archive <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
  } 

  if (NFMRset_wf_state ( "NFM", err_no, message ) != NFM_S_SUCCESS)
  {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif
     _CLI_str("%s : Set to State Message", fname );
     CLIprint( CLIout_file, "Cancel Set Archive Flag Message : %s", message);
     CLIprint( stderr, "Cancel Set Archive Flag Message : %s", message);
     return( CLI_E_FAILURE );
  }
  if (status != NFM_S_SUCCESS)
  {
     _CLI_str ("%s : EXIT", fname);
     return(CLI_E_FAILURE);
  }

  fprintf( CLIout_file, "   Successful Cancel Set Archive Flag.\n" );
  fprintf( stderr, "   Successful Cancel Set Archive Flag.\n" );
  _CLI_str( "%s : SUCCESSFUL", fname) ;
  return( CLI_S_SUCCESS );
}

long  CLIcancel_set_backup( )
{
  char *fname = "CLIcancel_set_backup" ;
  char message[256] = {"\0"};
  long  status;
  long  user_id = 0;
  long  err_no= NFM_S_SUCCESS;
  int  flag ;

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  int   subsystem;
#else
  char returned_string[256] = {"\0"};
#endif

  _CLI_str( "%s : ENTER", fname) ;
  
  CLIprint( CLIout_file, 
	"CANCEL_SET_BACKUP_FLAG : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);
  
  CLIprint( stderr, 
	"CANCEL_SET_BACKUP_FLAG : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);

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

      _CLI_num ("Cancel Set Backup Flag Message : <0x%.8lx>", status);
      _CLI_str ("Cancel Set Backup Flag Message : %s", message);

      CLIprint (CLIout_file, 
	"Cancel Set Backup Flag <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Cancel Set Backup Flag <%s.%s> from catalog <%s> ws <%s> Message : %s",
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

      _CLI_num ("Cancel Set Backup Flag Message : <0x%.8lx>", status);
      _CLI_str ("Cancel Set Backup Flag Message : %s", message);

      CLIprint (CLIout_file, 
	"Cancel Set Backup Flag <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Cancel Set Backup Flag <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);

    }

  status = NFMRvalidate_user_access ( 0, CANCEL_SET_BACKUP_FLAG, "", "",
                                        CLIcatalog, CLIitem, CLIrev);

  if (status != NFM_S_SUCCESS)
  {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif
     _CLI_num("Validate user access Message  : <0x%.8lx>", status);
     CLIprint( CLIout_file, "Validate User Access Message : %s", message) ;
     CLIprint( stderr, "Validate User Access Message : %s", message) ;
     return( CLI_E_FAILURE );
  }

  status = NFMRcancel_set_backup_flag( user_id, CLIcatalog, CLIitem, CLIrev );


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  ERRget_message( message );
  ERRget_number( &err_no, &subsystem );
#else
  _NFMget_server_response (err_no, message, returned_string) ;
#endif
  if (status != NFM_S_SUCCESS)
  {
     _CLI_num("Cancel set backup flag Message : <0x%.8lx>", status);
     _CLI_str("Cancel set backup flag Message : %s", message);
     CLIprint (CLIout_file,
        "Cancel Set Backup <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
     CLIprint (stderr,
        "Cancel Set Backup <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
  }

  if (NFMRset_wf_state ( "NFM", err_no, message ) != NFM_S_SUCCESS)
  {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif
     _CLI_str( "%s : Set to State Message", fname );
     CLIprint( CLIout_file, "Cancel Set Backup Flag Message : %s",message);
     CLIprint( stderr, "Cancel Set Backup Flag Message : %s",message);
     return( CLI_E_FAILURE );
  }
  if (status != NFM_S_SUCCESS)
  {
     _CLI_str ("%s : EXIT", fname);
     return( CLI_E_FAILURE );
  }

  fprintf( CLIout_file, "   Successful Cancel Set Backup Flag.\n" );
  fprintf( stderr, "   Successful Cancel Set Backup Flag.\n" );
  _CLI_str( "%s : SUCCESSFUL", fname) ;
  return( CLI_S_SUCCESS );
}

long  CLIcancel_set_restore( )
{
  char *fname = "CLIcancel_set_restore" ;
  char message[256] = {"\0"};
  long  status;
  long  user_id = 0;
  long  err_no = NFM_S_SUCCESS;
  int flag ;

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  int   subsystem;
#else
  char returned_string[256] = {"\0"};
#endif
  
  _CLI_str( "%s : ENTER", fname) ;
  
  CLIprint( CLIout_file, 
	"CANCEL_SET_RESTORE_FLAG : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);
  
  CLIprint( stderr, 
	"CANCEL_SET_RESTORE_FLAG : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);

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

      _CLI_num ("Cancel Set Restore Message : <0x%.8lx>", status);
      _CLI_str ("Cancel Set Restore Message : %s", message);

      CLIprint (CLIout_file, 
	"Cancel Set Restore <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Cancel Set Restore <%s.%s> from catalog <%s> ws <%s> Message : %s",
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

      _CLI_num ("Cancel Set Restore Message : <0x%.8lx>", status);
      _CLI_str ("Cancel Set Restore Message : %s", message);

      CLIprint (CLIout_file, 
	"Cancel Set Restore <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Cancel Set Restore <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);

    }

  status = NFMRvalidate_user_access ( 0, CANCEL_SET_RESTORE_FLAG, "", "",
                                        CLIcatalog, CLIitem, CLIrev);

  if (status != NFM_S_SUCCESS)
  {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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

  status = NFMRcancel_set_restore_flag( user_id, CLIcatalog, CLIitem, CLIrev );

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  ERRget_message( message );
  ERRget_number( &err_no, &subsystem );
#else
  _NFMget_server_response (err_no, message, returned_string) ;
#endif

  if (status != NFM_S_SUCCESS)
  {
     _CLI_num("Cancel set restore flag Message : <0x%.8lx>", status);
     _CLI_str("Cancel set restore flag Message : %s", message);
     CLIprint (CLIout_file,
        "Cancel Set Restore <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
     CLIprint (stderr,
        "Cancel Set Restore <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
  }

  if (NFMRset_wf_state ( "NFM", err_no, message ) != NFM_S_SUCCESS)
  {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif
     _CLI_str( "%s : Set to State Message", fname );
      CLIprint (CLIout_file,
        "Cancel Set Restore <%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
      CLIprint (stderr,
        "Cancel Set Restore <%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;

      return( CLI_E_FAILURE );
  }
  if (status!= NFM_S_SUCCESS)
  {
      _CLI_str ("%s : EXIT", fname);
      return( CLI_E_FAILURE );
  }

  fprintf( CLIout_file, "   Successful Cancel Set Restore.\n" );
  fprintf( stderr, "   Successful Cancel Set Restore.\n" );
  _CLI_str( "%s : SUCCESSFUL", fname) ;
  return( CLI_S_SUCCESS );
}

long  CLIcancel_set_checkout( )
{
  char *fname = "CLIcancel_set_checkout" ;


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  int   subsystem;
#else
  char returned_string [256]={"\0"};
#endif
  char message[256] = {"\0"};
  long status;
  long err_no = NFM_S_SUCCESS;
  int flag ;
  
  _CLI_str( "%s : ENTER", fname) ;
  
  CLIprint( CLIout_file, "CANCEL_SET_CHECKOUT : Catalog <%s> Set <%s> Revision <%s>", CLIcatalog, CLIitem, CLIrev);

  CLIprint( stderr, "CANCEL_SET_CHECKOUT : Catalog <%s> Set <%s> Revision <%s>", CLIcatalog, CLIitem, CLIrev);


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  CLIoperation.transfer = NFM_CONDITIONAL_TRANSFER;
  CLIoperation.delete   = NFM_CONDITIONAL_DELETE;
  CLIoperation.purge    = NFM_PURGE;

  strcpy (CLIoperation.catalog, CLIcatalog);
  CLIoperation.catalog_no = -1;
  strcpy (CLIoperation.item_name, CLIitem);
  strcpy (CLIoperation.item_rev, CLIrev);

  CLIwf_info.workflow = NFM_WORKFLOW;
  strcpy (CLIwf_info.command, CANCEL_SET_CHECKOUT);
  strcpy (CLIwf_info.workflow_name, "NFM_ITEM_WORKFLOW");
  strcpy (CLIwf_info.project_name, "\0");
  strcpy (CLIwf_info.app_name, "NFM");

  _CLI_num ("CLIwf_info.workflow = <%d>", CLIwf_info.workflow);
  _CLI_str ("CLIwf_info.command = <%s>", CLIwf_info.command);
  _CLI_str ("CLIwf_info.workflow_name = <%s>", CLIwf_info.workflow_name);
  _CLI_str ("CLIwf_info.project_name = <%s>", CLIwf_info.project_name);
  _CLI_str ("CLIwf_info.app_name = <%s>", CLIwf_info.app_name);
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

      _CLI_num ("Cancel Set Checkout Message : <0x%.8lx>", status);
      _CLI_str ("Cancel Set Checkout Message : %s", message);

      CLIprint (CLIout_file, 
	"Cancel Set Checkout <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Cancel Set Checkout <%s.%s> from catalog <%s> ws <%s> Message : %s",
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

      _CLI_num ("Cancel Set Checkout Message : <0x%.8lx>", status);
      _CLI_str ("Cancel Set Checkout Message : %s", message);

      CLIprint (CLIout_file, 
	"Cancel Set Checkout <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Cancel Set Checkout <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);

    }

  status = NFMRcancel_check_out_set( CLIcatalog, -1, CLIitem, CLIrev, -1,
			CLIwf_info, NFM_SAME_OPERATION, &CLIoperation, 0 );

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  ERRget_message( message );
  ERRget_number( &err_no, &subsystem );
#else
  _NFMget_server_response (err_no, message, returned_string) ;
#endif

  if( status != NFM_S_SUCCESS )
  {
      _CLI_num("Cancel Set Checkout Message : <0x%.8lx>", status);
      _CLI_str("Cancel Set Checkout Message : %s", message);
      CLIprint (CLIout_file, 
       "Cancel Set Checkout <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
      CLIprint (stderr, 
       "Cancel Set Checkout <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
  }

 if (NFMRset_wf_state ( "NFM", err_no, message ) != NFM_S_SUCCESS)
  {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif
     _CLI_str( "%s : Set to State Message", fname );
      CLIprint (CLIout_file,
        "Cancel Set Checkout <%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog,message);
      CLIprint (stderr,
        "Cancel Set Checkout <%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog,message);

      return( CLI_E_FAILURE );
   }
   if (status != NFM_S_SUCCESS)
   {
      _CLI_str("%s : EXIT", fname);
      return(CLI_E_FAILURE);
   } 
   fprintf( CLIout_file, "   Successful Cancel Set Checkout.\n" );
   fprintf( stderr, "   Successful Cancel Set Checkout.\n" );
    _CLI_str( "%s : SUCCESSFUL", fname) ;
    return( CLI_S_SUCCESS );
}




