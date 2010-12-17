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
# include "WFcommands.h"

extern char *buffer;

long  CLIcopy_item( )
{
  char  message[256]={"\0"};
  char  *fname = "CLIcopy_item";
  long  status;
  long  err_no=NFM_S_SUCCESS;


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
  int   subsystem; 
#else
  char  returned_string[256]={"\0"};
#endif

  _CLI_str( "%s", "Entering CLIcopy_item" );

  CLIprint( CLIout_file, 
      "COPY_ITEM : Catalog <%s> Item <%s> Revision <%s> Storage Area <%s>",
       CLIcatalog, CLIitem, CLIrev, CLIstorage );
  
  CLIprint( stderr, 
      "COPY_ITEM : Catalog <%s> Item <%s> Revision <%s> Storage Area <%s>",
       CLIcatalog, CLIitem, CLIrev, CLIstorage );
  
  status = NFMRvalidate_user_access ( 0, COPY_ITEM_FILES, "", "",
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

  CLIwf_info.workflow = NFM_WORKFLOW;
  strcpy (CLIwf_info.command, COPY_ITEM_FILES);
  strcpy (CLIwf_info.workflow_name, "NFM_ITEM_WORKFLOW");
  strcpy (CLIwf_info.project_name, "\0");
  strcpy (CLIwf_info.app_name, "NFM");

  _CLI_num ("CLIwf_info.workflow = <%d>", CLIwf_info.workflow);
  _CLI_str ("CLIwf_info.command = <%s>", CLIwf_info.command);
  _CLI_str ("CLIwf_info.workflow_name = <%s>", CLIwf_info.workflow_name);
  _CLI_str ("CLIwf_info.project_name = <%s>", CLIwf_info.project_name);
  _CLI_str ("CLIwf_info.app_name = <%s>", CLIwf_info.app_name);

  status = NFMRcopy_item_files( CLIcatalog, -1, CLIitem, CLIrev,CLIstorage,
			 CLIwf_info, CLIoperation );
  ERRget_message( message );
  ERRget_number( &err_no, &subsystem );
#else
  status = NFMRcopy_item( CLIcatalog, 0, CLIitem, CLIrev,CLIstorage,
			 CLIwf_info, CLIoperation );
  _NFMget_server_response (err_no, message, returned_string) ;
#endif
     
if (status != NFM_S_SUCCESS)
  {
     _CLI_num("Copy item files Message : <0x%.8lx>", status);
     _CLI_str("Copy item files Message : %s", message);
     CLIprint (CLIout_file,
        "Copy Item <%s.%s> from catalog <%s> Message : %s",
               CLIitem, CLIrev, CLIcatalog, message) ;
     CLIprint (stderr,
        "Copy Item <%s.%s> from catalog <%s> Message : %s",
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
     CLIprint( CLIout_file, "Copy Item Message : %s",message);
     CLIprint( stderr, "Copy Item Message : %s",message);
     return( CLI_E_FAILURE );
  }
  if (status != NFM_S_SUCCESS)
  {  
     _CLI_str ("%s : EXIT", fname);
     return( CLI_E_FAILURE );
  }
     
  fprintf( CLIout_file, "   Successful Copy Item.\n" );
  fprintf( stderr , "   Successful Copy Item.\n" );
  _CLI_str( "%s", "Exiting CLIcopy_item" );
  
  return( CLI_S_SUCCESS );
}
