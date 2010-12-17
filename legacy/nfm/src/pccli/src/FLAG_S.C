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

long  CLIflag_set_archive( )
{
    char  *fname = "CLIflag_set_archive";
    char  message[256] = {"\0"};
    long  status;
    long  user_id = 0;
    long  err_no=NFM_S_SUCCESS;
#ifdef UNIX
    int   subsystem;
#else
    char returned_string[256]={"\0"};
#endif
    int flag ;

    _CLI_str( "%s", "Entering CLIflag_set_archive" );

    CLIprint( CLIout_file, 
	"FLAG_SET_ARCHIVE : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);

    CLIprint( stderr, 
	"FLAG_SET_ARCHIVE : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);

#ifdef UNIX
  status = NFMRvalidate_revision ( CLIcatalog, CLIitem, CLIrev, &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
     ERRget_message( message );
     ERRreset_struct();

     _CLI_num ("Flag Set Archive Message : <0x%.8lx>", status);
     _CLI_str ("Flag Set Archive Message : %s", message);

     CLIprint (CLIout_file, 
	"Flag Set Archive <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Flag Set Archive Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);
    }


  if (flag == 0)
    {
     _CLI_str ("Item must be a set parent%s", "") ;
     ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item must be a set parent") ;
     ERRget_message( message );
     ERRreset_struct () ;
      _CLI_num ("Flag Set Archive Message : <0x%.8lx>", status);
      _CLI_str ("Flag Set Archive Message : %s", message);

      CLIprint (CLIout_file, 
	"Flag Set Archive <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Flag Set Archive <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);

    }
#endif

    status = NFMRvalidate_user_access ( user_id, FLAG_SET_ARCHIVE, "", "",
                                        CLIcatalog, CLIitem, CLIrev);
    if (status != NFM_S_SUCCESS)
    {
#ifdef UNIX
       ERRget_message( message );
       ERRreset_struct();
#else
       _NFMget_server_response ( err_no, message, returned_string) ;
#endif
       _CLI_num( "Validate user access Message : <0x%.8lx>", status );
       _CLI_str( "Validate user access Message : %s", message );
       CLIprint( CLIout_file, "Validate User Access Message : %s", message) ;
       CLIprint( stderr, "Validate User Access Message : %s", message) ;
       return( CLI_E_FAILURE );
    }

    status = NFMRflag_set_archive( user_id, CLIcatalog, CLIitem, CLIrev );

#ifdef UNIX
    ERRget_message( message );
    ERRget_number( &err_no, &subsystem );
#else
    _NFMget_server_response ( err_no, message, returned_string) ;
#endif
    if (status != NFM_S_SUCCESS)
    {
       _CLI_num("Flag set archive Message : <0x%.8lx>", status);
       _CLI_str("Flag set archive Message : %s", message);
       CLIprint (CLIout_file,
        "Flag Set Archive <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
       CLIprint (stderr,
        "Flag Set Archive <%s.%s> from catalog <%s> Message : %s",
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
       CLIprint( CLIout_file, "Flag Set Archive Message : %s",message);
       CLIprint( stderr, "Flag Set Archive Message : %s",message);
       return( CLI_E_FAILURE );
    }
    if (status != NFM_S_SUCCESS)
    {
       _CLI_str ("%s : EXIT", fname);
       return( CLI_E_FAILURE );
    }
       
    fprintf( CLIout_file, "   Successful Flag Set Archive.\n" );
    fprintf( stderr , "   Successful Flag Set Archive.\n" );
    _CLI_str( "%s", "Exiting CLIflag_set_archive" );

    return( CLI_S_SUCCESS );
}

long  CLIflag_set_backup( )
{
    char  *fname = "CLIflag_set_backup";
    char  message[256] = {"\0"};
    long  status;
    long  user_id = 0;
    long  err_no=NFM_S_SUCCESS;
    int   flag ;
#ifdef UNIX
    int   subsystem;
#else
    char returned_string[256]={"\0"};
#endif


    _CLI_str( "%s", "Entering CLIflag_set_backup" );

    CLIprint( CLIout_file, 
	"FLAG_SET_BACKUP : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);

    CLIprint( stderr, 
	"FLAG_SET_BACKUP : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);

#ifdef UNIX
  status = NFMRvalidate_revision ( CLIcatalog, CLIitem, CLIrev, &flag ) ;
  if (status != NFM_S_SUCCESS)
    {
     ERRget_message( message );
     ERRreset_struct();

     _CLI_num ("Flag Set Backup Message : <0x%.8lx>", status);
     _CLI_str ("Flag Set Backup Message : %s", message);

     CLIprint (CLIout_file, 
	"Flag Set Backup <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Flag Set Backup <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);
    }


  if (flag == 0)
    {
     _CLI_str ("Item must be a set parent%s", "") ;

     ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item must be a set parent") ;
     ERRget_message( message );
     ERRreset_struct () ;

      _CLI_num ("Flag Set Backup Message : <0x%.8lx>", status);
      _CLI_str ("Flag Set Backup Message : %s", message);

      CLIprint (CLIout_file, 
	"Flag Set Backup <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Flag Set Backup <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);

    }
#endif


    status = NFMRvalidate_user_access ( user_id, FLAG_SET_BACKUP, "", "",
                                        CLIcatalog, CLIitem, CLIrev);
    if (status != NFM_S_SUCCESS)
    {
#ifdef UNIX
       ERRget_message( message );
       ERRreset_struct();
#else
       _NFMget_server_response ( err_no, message, returned_string) ;
#endif
       _CLI_num( "Validate user access Message : <0x%.8lx>", status );
       _CLI_str( "Validate user access Message : %s", message );
       CLIprint( CLIout_file, "Validate User Access Message : %s", message) ;
       CLIprint( stderr, "Validate User Access Message : %s", message) ;
       return( CLI_E_FAILURE );
    }

    status = NFMRflag_set_backup( user_id, CLIcatalog, CLIitem, CLIrev );

#ifdef UNIX
       ERRget_message( message );
       ERRget_number( &err_no, &subsystem );
#else
       _NFMget_server_response ( err_no, message, returned_string) ;
#endif

    if (status != NFM_S_SUCCESS)
    {
       _CLI_num("Flag set backup Message : <0x%.8lx>", status);
       _CLI_str("Flag set backup Message : %s", message);
       CLIprint (CLIout_file,
        "Flag Set Backup <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
       CLIprint (stderr,
        "Flag Set Backup <%s.%s> from catalog <%s> Message : %s",
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
       _CLI_str( "%s: Set to State Message", fname );
       CLIprint( CLIout_file, "Flag Set Backup Message : %s",message);
       CLIprint( stderr, "Flag Set Backup Message : %s",message);
       return( CLI_E_FAILURE );
    }
    if (status != NFM_S_SUCCESS)
    {
       _CLI_str ("%s : EXIT", fname);
       return( CLI_E_FAILURE );
    }
       
    fprintf( CLIout_file, "   Successful Flag Set Backup.\n" );
    fprintf( stderr , "   Successful Flag Set Backup.\n" );

    _CLI_str( "%s", "Exiting CLIflag_set_backup" );

    return( CLI_S_SUCCESS );
}

long  CLIflag_set_restore( )
{
    char  *fname = "CLIflag_set_restore";
    char  message[256] = {"\0"};
    long  status;
    long  user_id = 0;
    long  err_no=NFM_S_SUCCESS;
    int   flag ;
#ifdef UNIX
    int   subsystem;
#else
    char returned_string[256]={"\0"};
#endif


    _CLI_str( "%s", "Entering CLIflag_set_restore" );

    CLIprint( CLIout_file, 
	"FLAG_SET_RESTORE : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);

    CLIprint( stderr, 
	"FLAG_SET_RESTORE : Catalog <%s> Set <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev);

#ifdef UNIX
  status = NFMRvalidate_revision ( CLIcatalog, CLIitem, CLIrev, &flag ) ;
  if (status != NFM_S_SUCCESS)
    {

     ERRget_message( message );
     ERRreset_struct();

     _CLI_num ("Flag Set Restore Message : <0x%.8lx>", status);
     _CLI_str ("Flag Set Restore Message : %s", message);

     CLIprint (CLIout_file, 
	"Flag Set Restore <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Flag Set Restore <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);
    }


  if (flag == 0)
    {
     _CLI_str ("Item must be a set parent%s", "") ;

     ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Item must be a set parent") ;
     ERRget_message( message );
     ERRreset_struct () ;

      _CLI_num ("Flag Set Restore Message : <0x%.8lx>", status);
      _CLI_str ("Flag Set Restore Message : %s", message);

      CLIprint (CLIout_file, 
	"Flag Set Restore <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Flag Set Restore <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);

    }
#endif

    status = NFMRvalidate_user_access ( user_id, FLAG_SET_RESTORE, "", "",
                                        CLIcatalog, CLIitem, CLIrev);
    if (status != NFM_S_SUCCESS)
    {
#ifdef UNIX
       ERRget_message( message );
       ERRreset_struct();
#else
       _NFMget_server_response ( err_no, message, returned_string) ;
#endif
       _CLI_num( "Validate user access Message : <0x%.8lx>", status );
       _CLI_str( "Validate user access Message : %s", message );
       CLIprint( CLIout_file, "Validate User Access Message : %s", message) ;
       CLIprint( stderr, "Validate User Access Message : %s", message) ;
       return( CLI_E_FAILURE );
    }

    status = NFMRflag_set_restore( user_id, CLIcatalog, CLIitem, CLIrev );

#ifdef UNIX
    ERRget_message( message );
    ERRget_number( &err_no, &subsystem );
#else
    _NFMget_server_response ( err_no, message, returned_string) ;
#endif

    if (status != NFM_S_SUCCESS)
    {
       _CLI_num("Flag set restore Message : <0x%.8lx>", status);
       _CLI_str("Flag set restore Message : %s", message);
       CLIprint (CLIout_file,
        "Flag Set Restore <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
       CLIprint (stderr,
        "Flag Set Restore <%s.%s> from catalog <%s> Message : %s",
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
       CLIprint( CLIout_file, "Flag Set Restore Message : %s",message);
       CLIprint( stderr, "Flag Set Restore Message : %s",message);
       return( CLI_E_FAILURE );
    }
    if (status != NFM_S_SUCCESS)
    { 
       _CLI_str ("%s : EXIT", fname);
       return( CLI_E_FAILURE );
    }
       
    fprintf( CLIout_file, "   Successful Flag Set Restore.\n" );
    fprintf( stderr , "   Successful Flag Set Restore.\n" );

    _CLI_str( "%s", "Exiting CLIflag_set_restore" );

    return( CLI_S_SUCCESS );
}









