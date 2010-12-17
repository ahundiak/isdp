class implementation PDUstartup;

#include <stdio.h>
#include <PDUerror.h>
#include <PDUstr.h>
#include <FEI.h>

method execute ( int *response; char *response_data; int pos )
  {
    unsigned int status = PDM_S_SUCCESS;
    extern int PDM_debug_on;
    extern int PDUinitialize_help();
    char file_name[257];
    char *filename = NULL;
    int found;
    
/*
    PDM_debug_on = TRUE;
*/
    if ( PDM_debug_on)
      printf("In the startup method\n");

   /*status = GRlicense("SM01052", 0);
   _pdm_status("GRlicense", status);*/

   PDUsetup_status_structure();

    *response = TERMINATE;
    if ( PDM_debug_on )
      printf("Entering PDUstartup.execute\n");

  FI_modify_env(FI_ACTIVATE_HELP, PDUinitialize_help);

   /* initialize global structures */
   if (PDM_debug_on)
     printf("initializing global structures\n");
   PDUuser_init();
   refresh_init();
   PDUpart_init();
   PDUpdm_exec_init();
   PDUstorage_init();

   PALglbs_init();
   PDUload_PDUexit_save();
   PDUload_PDUexit_nosave();
   PDUfill_in_string(&filename, "PDUdba.o");
   if (dload_address_lookup("_dba_setup") == 0)
     {
    strcpy( file_name, find_file( filename, "config/dload/cmds/", &found ) );
  if( ! found )
    return(PDM_E_FAILURE); 

  _pdm_debug("file_name = <%s>", file_name);
  status = om$dynamic_load( filename = file_name );
  }
    if ( PDM_debug_on )
      printf("Exiting PDUstartup.execute\n");

    return ( OM_S_SUCCESS );
  }  /* execute */

end implementation PDUstartup;
