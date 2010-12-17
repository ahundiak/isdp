/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**  xform_sample1.rc is a simple example of how to call a RIS form function.
**  This particular example calls RISfrm_display_create_schema_form().
*/

#include <stdlib.h>
#include <X11/Xlib.h>
#include <FI.h>
#include "risforms.h"
#include "ris.h"

Display *display;

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
	char *display_ptr;


	if ((display_ptr = getenv("DISPLAY")) == NULL)
	{
		display_ptr = "unix:0.0";
	}

	if ((display = XOpenDisplay(display_ptr)) == None)
	{ 
		printf("Unable to open DISPLAY=\"%s\"\n", display_ptr);
		return -1;
	}

	FSEnter(display, 0);
	FI_enter(display, 0, 0);

    /*
    **  Initialize the RIS forms subsystem
    */
    if (RISfrm_initialize() != RIS_SUCCESS)
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
