/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**  form_sample1.rc is a simple example of how to call a RIS form function.
**  This particular example calls RISfrm_display_create_schema_form().
*/

#include <tools.h>
#include <FI.h>
#include "risforms.h"
#include "ris.h"

static void print_forms_error(char *function_name)
{
    if (function_name)
    {
        printf("%s failed.\n", function_name);
    }
    if (ris_forms_error->error)
    {
        printf("error: 0x%x\n",ris_forms_error->error);
        printf("error_name: %s\n",ris_forms_error->error_name);
        printf("error_message: %s\n",ris_forms_error->error_message);
    }
    if (ris_forms_error->FI_error)
    {
        printf("FI_error: %d\n",ris_forms_error->FI_error);
        printf("FI_error_name: %s\n",ris_forms_error->FI_error_name);
        printf("FI_error_message: %s\n",ris_forms_error->FI_error_message);
    }
}

main()
{
    int                 vs;
    int                 fixed_slots;
    struct vlt_slot     *fixed_vlt;

    /*
    **  Initialize Environ V
    */
    Enter_tools();
    Enable_events(FI_EVENT_MASK);

    /*
    **  Load the fixed VLT
    */
    Inq_displayed_vs(&vs);
    Get_fixed_vlt(&fixed_vlt, &fixed_slots);
    Loadvlt(vs, fixed_vlt, fixed_slots);

    /*
    **  Initialize the FI subsystem
    */
    FI_enter();

    /*
    **  Initialize the RIS forms subsystem
    */
    if (RISfrm_initialize() != RIS_SUCCESS)
    {
        print_forms_error("RISfrm_initialize()");
        Exit_tools();
        return(1);
    }

    /*
    **  Display the RIS create schema form
    */
    if (RISfrm_display_create_schema_form() != RIS_SUCCESS)
    {
        print_forms_error("RISfrm_display_create_schema_form()");
        Exit_tools();
        return(1);
    }

    /*
    **  Process any input to the form
    */
    FI_process_forms();

    /*
    **  Exit Environ5
    */
    Exit_tools();

    /*
    **  Exit the program
    */
    return RIS_SUCCESS;
}
