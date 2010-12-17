/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							frmntfy.c
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
#if defined(WIN32)
#include <windows.h>
#endif
#include "forms.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmntfy_c
#include "comdebug.prt"
#include "frmschdf.prt"
#include "frmaltab.prt"
#include "frmcrsch.prt"
#include "frmcrtab.prt"
#include "frmdadef.prt"
#include "frmdb2ps.prt"
#include "frmdbs.prt"
#include "frmdicac.prt"
#include "frmdrsch.prt"
#include "frmdrtab.prt"
#include "frmexcl.prt"
#include "frmincl.prt"
#include "frmlocli.prt"
#include "frmmsg.prt"
#include "frmnodin.prt"
#include "frmntfy.prt"
#include "frmosusr.prt"
#include "frmpswd.prt"
#include "frmschac.prt"
#include "frmschfl.prt"
#include "frmschin.prt"
#include "frmschmg.prt"
#include "frmschps.prt"
#include "frmset.prt"
#include "frmtabin.prt"
#include "frmuspw.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/
#if defined(WIN32)
static  HCURSOR hCursor = 0;
#endif

/*
**	FUNCTIONS
*/
extern int RISfrm_notification_routine(
	int     f_label,
	int     g_label,
	double  value,
	Form    fp)
{
	int	i;

	static	RISfrm_label_function	process_form[] = 
	{
		{	SM_FORM,	RISfrm_process_sm_form	},
		{	SI_FORM,	RISfrm_process_si_form	},
		{	CS_FORM,	RISfrm_process_cs_form	},
		{	DS_FORM,	RISfrm_process_ds_form	},
		{	SD_FORM,	RISfrm_process_sd_form	},
		{	RD_FORM,	RISfrm_process_rd_form	},
		{	DD_FORM,	RISfrm_process_dd_form	},
		{	TI_FORM,	RISfrm_process_ti_form	},
		{	CT_FORM,	RISfrm_process_ct_form	},
		{	DT_FORM,	RISfrm_process_dt_form	},
		{	AT_FORM,	RISfrm_process_at_form	},
		{	SF_FORM,	RISfrm_process_sf_form	},
		{	SP_FORM,	RISfrm_process_sp_form	},
		{	NI_FORM,	RISfrm_process_ni_form	},
		{	DP_FORM,	RISfrm_process_dp_form	},
		{	SE_FORM,	RISfrm_process_se_form	},
		{	LC_FORM,	RISfrm_process_lc_form	},
		{	DA_FORM,	RISfrm_process_da_form	},
		{	SA_FORM,	RISfrm_process_sa_form	},
		{	PW_FORM,	RISfrm_process_pw_form	},
		{	UP_FORM,	RISfrm_process_up_form	},
		{	IN_FORM,	RISfrm_process_in_form	},
		{	EX_FORM,	RISfrm_process_ex_form	}, 
		{	OS_FORM,	RISfrm_process_os_form	}, 
	};
	static	int	process_form_count =
		sizeof(process_form)/sizeof(RISfrm_label_function);


	FRM_DBG(("RISfrm_notification_routine(f_label:%d g_label:%d value:%f)\n",
		f_label, g_label, value));

	if (RISfrm_pre_notification)
	{
		FRM_DBG(("Calling RISfrm_pre_notification()\n"));
		RISfrm_pre_notification(f_label, g_label, value, fp);
	}

#if defined(WIN32)
	hourglass_cursor();
#endif

	RISfrm_clear_msgs();

	for (i = 0; i < process_form_count; i++)
	{
		if (process_form[i].label == f_label)
		{
			(process_form[i].function_ptr)(g_label);
			break;
		}
	}

	RISfrm_display_msgs();

#if defined(WIN32)
	default_cursor();
#elif defined(unix)
#else
ERROR -- NO CODE
#endif

	if (RISfrm_post_notification)
	{
		FRM_DBG(("Calling RISfrm_post_notification()\n"));
		RISfrm_post_notification(f_label, g_label, value, fp);
	}

	return 0;
}

/******************************************************************************/

extern void RISfrm_initial_notification_routine(
	int     f_label,
	int     g_label,
	double  value,
	Form    fp)
{
	int	i;

	static	RISfrm_label_function	process_form[] = 
	{
		{	SI_FORM,	RISfrm_process_si_form_initial	},
		{	DD_FORM,	RISfrm_process_dd_form_initial	},
		{	TI_FORM,	RISfrm_process_ti_form_initial	},
		{	CT_FORM,	RISfrm_process_ct_form_initial	},
		{	AT_FORM,	RISfrm_process_at_form_initial	},
	};
	static	int	process_form_count =
		sizeof(process_form)/sizeof(RISfrm_label_function);


	FRM_DBG(("RISfrm_initial_notification_routine(f_label:%d g_label:%d value:%f fp:0x%x)\n", f_label, g_label, value, fp));

	for (i = 0; i < process_form_count; i++)
	{
		if (process_form[i].label == f_label)
		{
			(process_form[i].function_ptr)(g_label);
			break;
		}
	}
}

/******************************************************************************/

#if defined(WIN32)
static void hourglass_cursor()
{
	static  HCURSOR hHourglass = 0;

	FRM_DBG(("hourglass_cursor()\n"));

	if (hHourglass == 0)
	{
		hHourglass = LoadCursor(NULL, IDC_WAIT);
	}
	hCursor = SetCursor(hHourglass);

	FRM_DBG(("hourglass_cursor:returning\n"));
}
#elif defined(unix)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(WIN32)
static void default_cursor()
{
	FRM_DBG(("default_cursor()\n"));

	if (hCursor)
	{
		SetCursor(hCursor);
	}

	FRM_DBG(("default_cursor:returning\n"));
}
#elif defined(unix)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/
