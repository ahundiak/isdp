/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:						frmschdf.c
**	AUTHORS:					Terry McIntyre
**	CREATION DATE:				11/90
**	ABSTRACT:
**	
**		The code to process the schema form
**	
**	REVISION HISTORY:
**		Move create schema, drop schema two buttons from sm_form 
**  		to here and add dirctioary access and secure schema access
**              two buttons.                            Linda wang 2/94  
**
**		11/94:	Added support for INTERNATIONALIZATION.  Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include "forms.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmschdf_c
#include "comdebug.prt"
#if defined(WIN32)
#include "comumsg.prt"
#include "fi_winnt.prt"
#endif
#include "fi.prt"
#include "frmschdf.prt"
#include "frmcrsch.prt"
#include "frmdb2ps.prt"
#include "frmdicac.prt"
#include "frmdrsch.prt"
#include "frmerror.prt"
#include "frmfile.prt"
#include "frmschin.prt"
#include "frmnodin.prt"
#include "frmntfy.prt"
#include "frmschac.prt"
#include "frmschmg.prt"
#include "frmschps.prt"
#include "sys.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/
static	 Form 		sd_form = 0;
static	RISfrm_msg	*sd_msg = &RISfrm_msgs[SD_FORM_MSG];

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** SD_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char *msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(sd_form, SD_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(sd_form, SD_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
************** SUBFORM *********************************************************
*******************************************************************************/

static void erase_subform(
	int ex_f_label)
{
	FRM_DBG(("erase_subform(ex_f_label:%d)\n", ex_f_label));
	/*
	**	All the "erase" functions take action only if the form is displayed
	**	They also call the "clear" functions
	*/
	if (ex_f_label != SI_FORM) RISfrm_erase_si_form();
	if (ex_f_label != CS_FORM) RISfrm_erase_cs_form();
	if (ex_f_label != DS_FORM) RISfrm_erase_ds_form();
	if (ex_f_label != SA_FORM) RISfrm_erase_sa_form();
	if (ex_f_label != DA_FORM) RISfrm_erase_da_form();
	if (ex_f_label != SP_FORM) RISfrm_erase_sp_form();
	if (ex_f_label != NI_FORM) RISfrm_erase_ni_form();
	if (ex_f_label != DP_FORM) RISfrm_erase_dp_form();
}

/******************************************************************************/

static int display_update_form(
	int		(*form_displayed)(),
	int		(*display_form)(),
	void	(*update_form)(),
	void	(*call_user_init_form)())
{
	int				sts;
	char			*schname;
	ris_schema_info	*schemap;

	FRM_DBG(("display_update_form()\n"));

	if (!form_displayed())
	{
		if ((sts = display_form(CALLED_BY_SCHEMA_MGR)) != RIS_SUCCESS)
		{
			return sts;
		}

		if (update_form)
		{
			schname = RISfrm_get_selected_schname();

			schemap = RISfrm_get_schema(schname, update_msg_field,
				clear_msg_field);
			update_form(schemap);
		}

		if (call_user_init_form)
			call_user_init_form();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** BUTTONS *********************************************************
*******************************************************************************/

static void clear_button(
	int	g_label)
{
	FRM_DBG(("clear_button(g_label:%d)\n", g_label));
	FIg_set_state(sd_form, g_label, 0);
}

/******************************************************************************/

static void process_button(
	int		f_label,
	int		g_label,
	int		(*form_displayed)(),
	int		(*display_form)(),
	void	(*update_form)(),
	void	(*call_user_init_form)(),
	int		(*erase_form)())
{
	int	sts;
	int	state;

	FRM_DBG(("process_button(f_label:%d g_label:%d)\n", f_label, g_label));

	FIg_get_state(sd_form, g_label, &state);

	if (state)
	{
		erase_subform(f_label);

		sts = display_update_form(form_displayed, display_form,
			update_form, call_user_init_form);
		if (sts != RIS_SUCCESS)
		{
			RISfrm_report_error();
			clear_button(g_label);
			return;
		}
	}
	else
	{
		erase_form();
	}
}

/*******************************************************************************
************** SD_DICT_ACCESS_BUTTON *******************************************
*******************************************************************************/

static void process_dict_access_button()
{
	FRM_DBG(("process_dict_access_button()\n"));

	process_button(DA_FORM, SD_DICT_ACCESS_BUTTON,
		RISfrm_da_form_displayed, RISfrm_display_da_form,
		RISfrm_update_da_form, RISfrm_call_user_init_da_form,
		RISfrm_erase_da_form);
}

/******************************************************************************/

extern void RISfrm_clear_sd_dict_access_button()
{
	FRM_DBG(("RISfrm_clear_sd_dict_access_button()\n"));
	VALID_FORM_CHECK(sd_form);
	clear_button(SD_DICT_ACCESS_BUTTON);
}

/*******************************************************************************
************** SD_CREATE_SCHEMA_BUTTON *****************************************
*******************************************************************************/

static void process_create_schema_button()
{
	FRM_DBG(("process_create_schema_button()\n"));

	process_button(CS_FORM, SD_CREATE_SCHEMA_BUTTON,
		RISfrm_cs_form_displayed, RISfrm_display_cs_form,
		RISfrm_update_cs_form, RISfrm_call_user_init_cs_form,
		RISfrm_erase_cs_form);
}

/******************************************************************************/

extern void RISfrm_clear_sd_create_schema_button()
{
	FRM_DBG(("RISfrm_clear_sd_create_schema_button()\n"));
	VALID_FORM_CHECK(sd_form);
	clear_button(SD_CREATE_SCHEMA_BUTTON);
}

/*******************************************************************************
************** SD_DROP_SCHEMA_BUTTON *******************************************
*******************************************************************************/

static void process_drop_schema_button()
{
	FRM_DBG(("process_drop_schema_button()\n"));

	process_button(DS_FORM, SD_DROP_SCHEMA_BUTTON,
		RISfrm_ds_form_displayed, RISfrm_display_ds_form,
		RISfrm_update_ds_form, RISfrm_call_user_init_ds_form,
		RISfrm_erase_ds_form);
}

/******************************************************************************/

extern void RISfrm_clear_sd_drop_schema_button()
{
	FRM_DBG(("RISfrm_clear_sd_drop_schema_button()\n"));
	VALID_FORM_CHECK(sd_form);
	clear_button(SD_DROP_SCHEMA_BUTTON);
}

/*******************************************************************************
************** SD_SECURE_SCH_ACCESS_BUTTON *************************************
*******************************************************************************/

static void process_secure_sch_access_button()
{
	FRM_DBG(("process_secure_sch_access_button()\n"));

	process_button(SA_FORM, SD_SECURE_SCH_ACCESS_BUTTON,
		RISfrm_sa_form_displayed, RISfrm_display_sa_form,
		RISfrm_update_sa_form, RISfrm_call_user_init_sa_form,
		RISfrm_erase_sa_form);
}

/******************************************************************************/

extern void RISfrm_clear_sd_secure_sch_access_button()
{
	FRM_DBG(("RISfrm_clear_sd_secure_sch_access_button()\n"));
	VALID_FORM_CHECK(sd_form);
	clear_button(SD_SECURE_SCH_ACCESS_BUTTON);
}

/*******************************************************************************
************** SD_SCHPASS_BUTTON ***********************************************
*******************************************************************************/

static void process_schpass_button()
{
	FRM_DBG(("process_schpass_button()\n"));

	process_button(SP_FORM, SD_SCHPASS_BUTTON,
		RISfrm_sp_form_displayed, RISfrm_display_sp_form,
		RISfrm_update_sp_form, RISfrm_call_user_init_sp_form,
		RISfrm_erase_sp_form);
}

/******************************************************************************/

extern void RISfrm_clear_sd_schpass_button()
{
	FRM_DBG(("RISfrm_clear_sd_schpass_button()\n"));
	VALID_FORM_CHECK(sd_form);
	clear_button(SD_SCHPASS_BUTTON);
}

/*******************************************************************************
************** SD_NODE_INFO_BUTTON *********************************************
*******************************************************************************/

static void process_node_info_button()
{
	FRM_DBG(("process_node_info_button()\n"));

	process_button(NI_FORM, SD_NODE_INFO_BUTTON,
		RISfrm_ni_form_displayed, RISfrm_display_ni_form,
		RISfrm_update_ni_form, RISfrm_call_user_init_ni_form,
		RISfrm_erase_ni_form);
}

/******************************************************************************/

extern void RISfrm_clear_sd_node_info_button()
{
	FRM_DBG(("RISfrm_clear_sd_node_info_button()\n"));
	VALID_FORM_CHECK(sd_form);
	clear_button(SD_NODE_INFO_BUTTON);
}

/*******************************************************************************
************** SD_SCHEMA_INFO_BUTTON *******************************************
*******************************************************************************/

static void process_schema_info_button()
{
	FRM_DBG(("process_schema_info_button()\n"));

	process_button(IE_FORM, SD_SCHEMA_INFO_BUTTON,
		RISfrm_si_form_displayed, RISfrm_display_si_form,
		RISfrm_update_si_form, RISfrm_call_user_init_si_form,
		RISfrm_erase_si_form);
}

/******************************************************************************/

extern void RISfrm_clear_sd_schema_info_button()
{
	FRM_DBG(("RISfrm_clear_sd_schema_info_button()\n"));
	VALID_FORM_CHECK(sd_form);
	clear_button(SD_SCHEMA_INFO_BUTTON);
}

/*******************************************************************************
************** SD_DB2PASS_BUTTON **********************************************
*******************************************************************************/

static void process_db2pass_button()
{
	FRM_DBG(("process_db2pass_button()\n"));

	process_button(DP_FORM, SD_DB2PASS_BUTTON,
		RISfrm_dp_form_displayed, RISfrm_display_dp_form,
		RISfrm_update_dp_form, RISfrm_call_user_init_dp_form,
		RISfrm_erase_dp_form);
}

/******************************************************************************/

extern void RISfrm_clear_sd_db2pass_button()
{
	FRM_DBG(("RISfrm_clear_sd_db2pass_button()\n"));
	VALID_FORM_CHECK(sd_form);
	clear_button(SD_DB2PASS_BUTTON);
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	RISfrm_clear_sd_form();
	DISPLAY_HELP_BUTTON(sd_form);
	RISfrm_call_user_init_sd_form();
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));
	RISfrm_erase_sd_form();
}

/*******************************************************************************
******************** AS FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_sd_form(
	int	g_label)
{
	int	i;

	static	RISfrm_label_function	process_gadget[] = 
	{
		{FI_CANCEL,						process_cancel_button			},
		{FI_RESET,						process_reset_button			},
		{SD_DICT_ACCESS_BUTTON,			process_dict_access_button		},
		{SD_CREATE_SCHEMA_BUTTON,		process_create_schema_button	},
		{SD_DROP_SCHEMA_BUTTON,			process_drop_schema_button		},
		{SD_SECURE_SCH_ACCESS_BUTTON,	process_secure_sch_access_button},
		{SD_SCHPASS_BUTTON,				process_schpass_button			},
		{SD_NODE_INFO_BUTTON, 			process_node_info_button		},
		{SD_SCHEMA_INFO_BUTTON,			process_schema_info_button		},
		{SD_DB2PASS_BUTTON,				process_db2pass_button			},
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_sd_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(sd_form);

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}
}

/******************************************************************************/

extern void RISfrm_call_user_init_sd_form()
{
	FRM_DBG(("RISfrm_call_user_init_sd_form()\n"));

	if (RISfrm_user_init_sd_form)
	{
		FRM_DBG(("calling RISfrm_user_init_sd_form()\n"));
		RISfrm_user_init_sd_form(sd_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_sd_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_sd_form(called_by_user:%d)\n",called_by_user));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!sd_form)
	{
		sts = FIf_new(SD_FORM, SD_FORM_FILE, RISfrm_notification_routine,
			&sd_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_SD_FORM, sts);
			return RIS_forms_error.error;
		}
#if defined(WIN32)
		FIf_SetDefaultButton(sd_form, FI_CANCEL);
		FIg_set_text(sd_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));
#endif
	}

	if (!RISfrm_sd_form_displayed())
	{
		sd_msg->str[0] = 0;
		sd_msg->count = 0;
		sd_msg->msg_fld_label = SD_MSG_FIELD;
		sd_msg->fp = sd_form;

		DISPLAY_HELP_BUTTON(sd_form);

		if (called_by_user) RISfrm_call_user_init_sd_form();

		sts = FIf_display (sd_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_SD_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern void RISfrm_clear_sd_form()
{
	FRM_DBG(("RISfrm_clear_sd_form()\n"));

	VALID_FORM_CHECK(sd_form);

	erase_subform(0);
	RISfrm_clear_sd_dict_access_button();
	RISfrm_clear_sd_create_schema_button();
	RISfrm_clear_sd_drop_schema_button();
	RISfrm_clear_sd_secure_sch_access_button();
	RISfrm_clear_sd_schpass_button();
	RISfrm_clear_sd_node_info_button();
	RISfrm_clear_sd_schema_info_button();
	RISfrm_clear_sd_db2pass_button();
}

/******************************************************************************/

extern int RISfrm_sd_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_sd_form_displayed()\n"));

	if (!sd_form)
	{
		return 0;
	}
	FIf_is_displayed(sd_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_sd_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_sd_form()\n"));

	if (RISfrm_sd_form_displayed())
	{
		sts = FIf_erase(sd_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_SD_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_sd_form();
		if (RISfrm_sm_form_displayed())
			RISfrm_clear_sm_schema_def_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
******************** USER FUNCTIONS ********************************************
*******************************************************************************/

extern int RISAPI RISXfrm_schema_definition_form_displayed()
{
	return RISfrm_sd_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_schema_definition_form()
{
	return RISfrm_display_sd_form(CALLED_BY_USER);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_schema_definition_form()
{
	return RISfrm_erase_sd_form();
}

/******************************************************************************/
