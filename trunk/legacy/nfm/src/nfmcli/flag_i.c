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

long  CLIflag_item_archive( )
{
    char  *fname = "CLIflag_item_archive";
    char  message[256] = {"\0"};
    long  status;
    long  user_id = 0;
    long  err_no=NFM_S_SUCCESS;

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
    int   subsystem;
#else
    char returned_string[256] = {"\0"};
#endif


    _CLI_str( "%s", "Entering CLIflag_item_archive" );

    CLIprint( CLIout_file, 
	"FLAG_ITEM_ARCHIVE : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );

    CLIprint( stderr, 
	"FLAG_ITEM_ARCHIVE : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );

    status = NFMRvalidate_user_access ( user_id, FLAG_ITEM_ARCHIVE, "", "",
                                        CLIcatalog, CLIitem, CLIrev);

    if (status != NFM_S_SUCCESS)
    {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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

    status = NFMRflag_item_archive( user_id, CLIcatalog, CLIitem, CLIrev );


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
       ERRget_message( message );
       ERRget_number( &err_no, &subsystem );
#else
       _NFMget_server_response ( err_no, message, returned_string) ;
#endif
    if (status != NFM_S_SUCCESS)
    {
       _CLI_num("Flag item archive Message : <0x%.8lx>", status);
       _CLI_str("Flag item archive Message : %s", message);
     CLIprint (CLIout_file,
       "Flag Item Archive <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
     CLIprint (stderr,
       "Flag Item Archive <%s.%s> from catalog <%s> Message : %s",
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
       CLIprint( CLIout_file, "Flag Item Archive Message : %s", message);
       CLIprint( stderr, "Flag Item Archive Message : %s",message);
       return( CLI_E_FAILURE );
    }	
    if (status  != NFM_S_SUCCESS)
    {  
       _CLI_str("%s : EXIT", fname);
       return( CLI_E_FAILURE );
    }
       
    fprintf( CLIout_file, "   Successful Flag Item Archive.\n" );
    fprintf( stderr , "   Successful Flag Item Archive.\n" );
    _CLI_str( "%s", "Exiting CLIflag_item_archive" );

    return( CLI_S_SUCCESS );
}

long  CLIflag_item_backup( )
{
    char  *fname = "CLIflag_item_backup";
    char message[256] = {"\0"};
    long  status;
    long  user_id = 0;
    long  err_no=NFM_S_SUCCESS;

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
    int   subsystem;
#else
    char returned_string[256] = {"\0"};
#endif


    _CLI_str( "%s", "Entering CLIflag_item_backup" );

    CLIprint( CLIout_file, 
	"FLAG_ITEM_BACKUP : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );

    CLIprint( stderr, 
	"FLAG_ITEM_BACKUP : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );

    status = NFMRvalidate_user_access ( user_id, FLAG_ITEM_BACKUP, "", "",
                                        CLIcatalog, CLIitem, CLIrev);

    if (status != NFM_S_SUCCESS)
    {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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

    status = NFMRflag_item_backup( user_id, CLIcatalog, CLIitem, CLIrev );


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
    ERRget_message( message );
    ERRget_number( &err_no, &subsystem );
#else
    _NFMget_server_response ( err_no, message, returned_string) ;
#endif
    if (status != NFM_S_SUCCESS)
    {
       _CLI_num("Flag item backup Message : <0x%.8lx>", status);
       _CLI_str("Flag item backup Message : %s", message);
       CLIprint (CLIout_file,
        "Flag Item Backup <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
     CLIprint (stderr,
        "Flag Item Backup <%s.%s> from catalog <%s> Message: %s",
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
       CLIprint( CLIout_file, "Flag Item Backup Message : %s",message);
       CLIprint( stderr, "Flag Item Backup Message : %s",message);
       return( CLI_E_FAILURE );
    }	
    if (status != NFM_S_SUCCESS)
    {
       _CLI_str("%s : EXIT", fname);
       return( CLI_E_FAILURE );
    }
       
    fprintf( CLIout_file, "   Successful Flag Item Backup.\n" );
    fprintf( stderr , "   Successful Flag Item Backup.\n" );

    _CLI_str( "%s", "Exiting CLIflag_item_backup" );

    return( CLI_S_SUCCESS );
}

long  CLIflag_item_restore( )
{
    char  *fname = "CLIflag_item_restore";
    char message[256] = {"\0"};
    long  status;
    long  user_id=0;
    long  err_no=NFM_S_SUCCESS;

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
    int   subsystem;
#else
    char returned_string[256]={"\0"};
#endif


    _CLI_str( "%s", "Entering CLIflag_item_restore" );

    CLIprint( CLIout_file, 
	"FLAG_ITEM_RESTORE : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );

    CLIprint( stderr, 
	"FLAG_ITEM_RESTORE : Catalog <%s> Item <%s> Revision <%s>", 
	CLIcatalog, CLIitem, CLIrev );

    status = NFMRvalidate_user_access ( 0, FLAG_ITEM_RESTORE, "", "",
                                        CLIcatalog, CLIitem, CLIrev);

    if (status != NFM_S_SUCCESS)
    {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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

    status = NFMRflag_item_restore( user_id, CLIcatalog, CLIitem, CLIrev );


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
    ERRget_message( message );
    ERRget_number( &err_no, &subsystem );
#else
    _NFMget_server_response ( err_no, message, returned_string) ;
#endif

    if (status != NFM_S_SUCCESS)
    {
       _CLI_num("Flag item restore Message : <0x%.8lx>", status);
       _CLI_str("Flag item restore Message : %s", message);
       CLIprint (CLIout_file,
        "Flag Item Restore <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
       CLIprint (stderr,
        "Flag Item Restore <%s.%s> from catalog <%s> Message : %s",
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
       CLIprint( CLIout_file, "Flag Item Restore Message : %s",message);
       CLIprint( stderr, "Flag Item Restore Message : %s",message);
       return( CLI_E_FAILURE );
    }	
    if (status != NFM_S_SUCCESS)
    {
       _CLI_str ("%s : EXIT", fname);
       return( CLI_E_FAILURE );
    }
       
    fprintf( CLIout_file, "   Successful Flag Item Restore.\n" );
    fprintf( stderr , "   Successful Flag Item Restore.\n" );

    _CLI_str( "%s", "Exiting CLIflag_item_restore" );

    return( CLI_S_SUCCESS );
}
