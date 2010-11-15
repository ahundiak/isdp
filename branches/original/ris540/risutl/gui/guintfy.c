/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							guintfy.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/90
**	ABSTRACT:
**		The code to process the input to all RIS forms.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "gui.h"

/*
**	FUNCTION PROTOTYPES
*/
#define guintfy_c
#include "comdebug.prt"
#include "event.prt"
#include "guiabou.prt"
#include "guintfy.prt"
#include "guiin.prt"
#include "guipswd.prt"
#include "guimsg.prt"
#include "guiopts.prt"
#include "guiosusr.prt"
#include "guiparm.prt"
#include "guishow.prt"
#include "guishtr.prt"
#include "guisrch.prt"
#include "guiset.prt"
#include "guitran.prt"
#include "guiuspw.prt"
#include "guiutls.prt"
#if defined(unix)
#include "guicfrm.prt"
#include "guifile.prt"
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/
extern int RISgui_notification_routine(
	int     f_label,
	int     g_label,
	double  value,
	Form    fp)
{
	int	i;

	static	ris_gui_label_function	process_form[] = 
	{
		{	IN_FORM,	RISgui_process_in_form	},
		{	PW_FORM,	RISgui_process_pw_form	},
		{	SR_FORM,	RISgui_process_sr_form	},
		{	UT_FORM,	RISgui_process_ut_form	},
		{	OP_FORM,	RISgui_process_op_form	},
		{	SE_FORM,	RISgui_process_se_form	},
		{	SH_FORM,	RISgui_process_sh_form	},
		{	PA_FORM,	RISgui_process_pa_form	},
		{	AB_FORM,	RISgui_process_ab_form	},
		{	TR_FORM,	RISgui_process_tr_form	},
		{	ST_FORM,	RISgui_process_st_form	},
		{	UP_FORM,	RISgui_process_up_form	},
		{	OS_FORM,	RISgui_process_os_form	},
#if defined(unix)
		{	CF_FORM,	RISgui_process_cf_form	},
		{	FI_FORM,	RISgui_process_fi_form	},
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif
	};
	static	int	process_form_count =
		sizeof(process_form)/sizeof(ris_gui_label_function);


	GUI_DBG(("RISgui_notification_routine(f_label:%d g_label:%d value:%f fp:0x%x)\n", f_label, g_label, value, fp));

	RISgui_hourglass_cursor(fp);

	RISgui_clear_msgs();

	for (i = 0; i < process_form_count; i++)
	{
		if (process_form[i].label == f_label)
		{
			(process_form[i].function_ptr)(g_label);
			break;
		}
	}

	RISgui_display_msgs();

	RISgui_default_cursor(fp);

	GUI_DBG(("RISgui_notification_routine: returning 0\n"));
	return 0;
}

/******************************************************************************/
