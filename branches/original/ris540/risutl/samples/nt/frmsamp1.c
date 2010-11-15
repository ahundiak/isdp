/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

#include <windows.h>
#include <stdio.h>
#include <shampub.h>
#include "risforms.h"
#include "risforms.prt"
#include "ris.h"

/*
**  form_sample1.rc is a simple example of how to call a RIS form function.
**  This particular example calls RISfrm_display_create_schema_form().
*/

static void print_forms_error(char *function_name)
{
	char *ptr;
	char buffer[5000];

	ptr = buffer;
    if (function_name)
    {
        ptr += sprintf(ptr, "%s failed.\n", function_name);
    }
    if (ris_forms_error->error)
    {
        ptr += sprintf(ptr, "error: 0x%x\n",ris_forms_error->error);
        ptr += sprintf(ptr, "error_name: %s\n",ris_forms_error->error_name);
        ptr += sprintf(ptr, "error_message: %s\n",ris_forms_error->error_message);
    }
    if (ris_forms_error->FI_error)
    {
        ptr += sprintf(ptr, "FI_error: %d\n",ris_forms_error->FI_error);
        ptr += sprintf(ptr, "FI_error_name: %s\n",ris_forms_error->FI_error_name);
        ptr += sprintf(ptr, "FI_error_message: %s\n",ris_forms_error->FI_error_message);
    }

    MessageBox(NULL, buffer, "ERROR", MB_OK|MB_ICONSTOP);
}

extern int WINAPI WinMain(
	HANDLE hInst,
	HANDLE hPrevInst,
	LPSTR lpCmdLn,
	int nShowCmd)

{
    /*
    **  Initialize the FI subsystem
    */
	FI_enter();

    /*
    **  Initialize the RIS forms subsystem
    */
    if (RISfrm_initialize(NULL) != RIS_SUCCESS)
    {
        print_forms_error("RISfrm_initialize()");
        return(1);
    }

    /*
    **  Display the RIS create schema form
    */
    if (RISfrm_display_create_schema_form() != RIS_SUCCESS)
    {
        print_forms_error("RISfrm_display_create_schema_form()");
        return(1);
    }

    /*
    **  Process any input to the form
    */
    FI_process_forms();

    /*
    **  Exit the program
    */
    return RIS_SUCCESS;
}
