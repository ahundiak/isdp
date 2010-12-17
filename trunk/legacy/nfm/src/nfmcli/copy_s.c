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


long  CLIcopy_set( )
{
    char *fname = "CLIcopy_set" ;
    char  message[256]={"\0"};
    long  status;
    long  err_no=NFM_S_SUCCESS;

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
    int   subsystem; 
#else
    char  returned_string[256]={"\0"};
#endif
    int  flag ;

    _CLI_str( "%s : ENTER", fname) ;

    CLIprint( CLIout_file, 
       "COPY_SET : Catalog <%s> Item <%s> Revision <%s> Storage Area <%s>",
        CLIcatalog, CLIitem, CLIrev, CLIstorage );

    CLIprint( stderr, 
       "COPY_SET : Catalog <%s> Set <%s> Revision <%s> Storage Area <%s>",
        CLIcatalog, CLIitem, CLIrev, CLIstorage );
 
  status = NFMRvalidate_revision ( CLIcatalog, CLIitem, CLIrev, &flag ) ;
  if (status != NFM_S_SUCCESS)
    {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
     ERRget_message( message );
     ERRreset_struct();
#else
     _NFMget_server_response (err_no, message, returned_string) ;
#endif

     _CLI_num ("Copy Set Message : <0x%.8lx>", status);
     _CLI_str ("Copy Set Message : %s", message);

     CLIprint (CLIout_file, 
	"Copy Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Copy Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
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

      _CLI_num ("Copy Set Message : <0x%.8lx>", status);
      _CLI_str ("Copy Set Message : %s", message);

      CLIprint (CLIout_file, 
	"Copy Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      CLIprint (stderr, 
	"Copy Set <%s.%s> from catalog <%s> ws <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, CLIstorage, message) ;
      return(CLI_E_FAILURE);

    }


    status = NFMRvalidate_user_access ( 0, COPY_SET_FILES, "", "",
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
    strcpy (CLIwf_info.command, COPY_SET_FILES);
    strcpy (CLIwf_info.workflow_name, "NFM_ITEM_WORKFLOW");
    strcpy (CLIwf_info.project_name, "\0");
    strcpy (CLIwf_info.app_name, "NFM");

    _CLI_num ("CLIwf_info.workflow = <%d>", CLIwf_info.workflow);
    _CLI_str ("CLIwf_info.command = <%s>", CLIwf_info.command);
    _CLI_str ("CLIwf_info.workflow_name = <%s>", CLIwf_info.workflow_name);
    _CLI_str ("CLIwf_info.project_name = <%s>", CLIwf_info.project_name);
    _CLI_str ("CLIwf_info.app_name = <%s>", CLIwf_info.app_name);

    status = NFMRcopy_set_files( CLIcatalog, -1,  CLIitem, CLIrev, -1, 
              CLIstorage, CLIwf_info, NFM_SAME_OPERATION, &CLIoperation, 0) ;

    ERRget_message( message );
    ERRget_number( &err_no, &subsystem );

#else

    status = NFMRcopy_set( CLIcatalog, 0,  CLIitem, CLIrev, 0, CLIstorage,
		CLIwf_info, 0, &CLIoperation, 0) ;
    _NFMget_server_response (err_no, message, returned_string) ;

#endif

    if (status != NFM_S_SUCCESS)
    {
       _CLI_num("Copy set files Message : <0x%.8lx>", status);
       _CLI_str("Copy set files Message : %s", message);
       CLIprint (CLIout_file, "Copy Set <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
       CLIprint(stderr, "Copy Set <%s.%s> from catalog <%s> Message : %s",
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
       CLIprint( CLIout_file, "Copy Set Message : %s",message);
       CLIprint( stderr, "Copy Set Message : %s",message);
       return( CLI_E_FAILURE );
    } 
    if (status != NFM_S_SUCCESS)
    {
       _CLI_str("%s : EXIT", fname);
       return( CLI_E_FAILURE );
    }
	
    fprintf( CLIout_file, "   Successful Set Copy.\n" );
    fprintf( stderr, "   Successful Set Copy.\n" );
    _CLI_str( "%s :SUCCESSFUL", fname) ;

    return( CLI_S_SUCCESS );
}

