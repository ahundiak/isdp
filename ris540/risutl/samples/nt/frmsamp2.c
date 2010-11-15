/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**  form_sample2.rc is an example of how to call a RIS form function.
**  This particular example calls RISfrm_display_create_schema_form() and
**  also takes advantage of the 'hooks' provided for the RIS forms.
*/

#include <windows.h>
#include <stdio.h>
#include <shampub.h>
#include "risforms.h"
#include "risforms.prt"
#include "ris.h"
#include "rislimit.h"

/*
**  Help support
*/
static int	help_initialized = 0;
static char	help_path[RIS_MAX_PATH_SIZE] = "";
static HWND	help_handle = 0;
static char     language[] = "english" ;


static void my_pre_notify(
	int		f_label,
	int		g_label,
	double		value,
	Form		fp)
{
 	if (g_label == FI_HELP)
	{
		if (!help_initialized)
		{
                	sprintf(help_path,"\\Program Files\\Common Files\\Intergraph\\ris05.04\\config\\%s\\help\\risutl.hlp", language) ;
		}
		help_initialized = 1 ;
		FIf_get_window(fp, &help_handle);
		WinHelp(help_handle, help_path, HELP_KEY, (unsigned long )"rismgr");
	}
	else
	{
        	MessageBeep(0xffffffff);
	}
}

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

    MessageBox(NULL, buffer, "RIS FORMS ERROR", MB_OK|MB_ICONSTOP);
}

static void my_init(fp)
Form *fp;
{
    MessageBox(NULL,
    	"This box is displayed by my_init()\n"
    	"This routine also placed \"schema1\" in the schema name field",
    	"my_init()", MB_OK|MB_ICONASTERISK);
    FIfld_set_text(fp, CS_SCHNAME_FIELD, 0, 0, "schema1", 0);
}


static void my_post_notify(f_label, g_label, value, fp)
            int     f_label;
            int     g_label;
            double  value;
            Form    fp;
{
	MessageBeep(0xffffffff);
}

static int my_error_handler(ris_error, ris_error_str)
int ris_error;
char *ris_error_str;
{
	MessageBox(NULL, ris_error_str, "my_error_handler()", MB_OK|MB_ICONSTOP);

    /*
    **  Note by returning 0, I'm telling RIS do NOT display the error message
    */
    return(0);
}

static int my_exec(fp, cmd_str)
Form *fp;
char *cmd_str;
{
	MessageBox(NULL, cmd_str, "my_exec()", MB_OK|MB_ICONASTERISK);

    /*
    **  Note by returning 0, I'm telling RIS do NOT execute the cmd_str
    */
    return(0);
}

extern int WINAPI WinMain(
	HANDLE hInst,
	HANDLE hPrevInst,
	LPSTR lpCmdLn,
	int nShowCmd)

{
    RISfrm_init_parms   init_parms;


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
    init_parms.display_help_buttons = 1;
    
    init_parms.post_notification_routine =  my_post_notify;
    init_parms.error_handler_routine =  my_error_handler;
    if (RISfrm_initialize(&init_parms) != RIS_SUCCESS)
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
