/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**  form_sample2.rc is an example of how to call a RIS form function.
**  This particular example calls RISfrm_display_create_schema_form() and
**  also takes advantage of the 'hooks' provided for the RIS forms.
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

static void my_init(fp)
Form *fp;
{
    printf("\n\nCalling my_init(fp:0x%x)\n\n\n", fp);
    FIfld_set_text(fp, CS_SCHNAME_FIELD, 0, 0, "schema1", 0);
}

static void my_pre_notify(f_label, g_label, value, fp)
            int     f_label;
            int     g_label;
            double  value;
            Form    fp;
{
    printf("\n\nMy pre_notify\n");
    printf("f_label:%d\n", f_label);
    printf("g_label:%d\n", g_label);
    printf("value:%f\n", value);
    printf("fp:0x%x\n\n\n", fp);
    if (g_label == FI_HELP)
    {
        printf ("Call to help goes here..\n") ;
    }
}

static void my_post_notify(f_label, g_label, value, fp)
            int     f_label;
            int     g_label;
            double  value;
            Form    fp;
{
    printf("\n\nMy post_notify\n");
    printf("f_label:%d\n", f_label);
    printf("g_label:%d\n", g_label);
    printf("value:%f\n", value);
    printf("fp:0x%x\n\n\n", fp);
}

static int my_error_handler(ris_error, ris_error_str)
int ris_error;
char *ris_error_str;
{
    printf("ris error:%d\n", ris_error);
    printf("ris error_str:\n%s", ris_error_str);

    /*
    **  Note by returning 0, I'm telling RIS do NOT display the error message
    */
    return(0);
}

static int my_exec(fp, cmd_str)
Form *fp;
char *cmd_str;
{
    printf("fp: 0x%x\n", fp);
    printf("cmd_str:\n%s\n", cmd_str);

    /*
    **  Note by returning 0, I'm telling RIS do NOT execute the cmd_str
    */
    return(0);
}

main()
{
    int                 vs;
    int                 fixed_slots;
    struct vlt_slot     *fixed_vlt;
    RISfrm_init_parms   init_parms;


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
    memset(&init_parms, 0, sizeof(init_parms));
    init_parms.create_schema_init_routine =  my_init;
    init_parms.create_schema_exec_routine =  my_exec;
    init_parms.pre_notification_routine =  my_pre_notify;
    init_parms.display_help_buttons = 1 ; 
    init_parms.post_notification_routine =  my_post_notify;
    init_parms.error_handler_routine =  my_error_handler;
    if (RISfrm_initialize(&init_parms) != RIS_SUCCESS)
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