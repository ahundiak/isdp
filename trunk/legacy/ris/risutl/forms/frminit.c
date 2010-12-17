/* Do not alter this SPC information: $Revision: 1.3.27.1 $ */
/*
**	NAME:							frminit.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/90
**	ABSTRACT:
**		The code to process the initialization of RIS forms.
**	
**	REVISION HISTORY:
**		Modified for dictionary access and secure schema access forms
**							by Linda wang 03/94
*/
 
/*
**	INCLUDES
*/
#define DEFINE_FRM_GLOBALS
#include "riscom.h"
#include "forms.h"
#include "risver.h"
#include "risprods.h"
#include "risstjmp.h"
#include "ris_err.h"
#if defined(WIN32)
#include "windows.h"
#endif

/*
**	FUNCTION PROTOTYPES
*/
#define frminit_c
#include "comdebug.prt"
#include "comgtdir.prt"
#include "comlang.prt"
#include "comjmp.prt"
#include "frmerror.prt"
#include "frminit.prt"
#include "ucodebug.prt"
#include "ucoumsg.prt"
#include "fi.prt"
#include "ris.prt"
#include "sys.prt"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/
static debug_info_s debug_info[] =
{
	{ "frm", 3, &RISfrm_debug },
}
;
static int debug_count = sizeof(debug_info)/sizeof(debug_info_s);

/*
**	FUNCTIONS
*/
extern int RISAPI RISXfrm_initialize(
	RISfrm_init_parms	*init_parms)
{
	int		sts;
	int		lang_code;
	int		development;
	char	*lang_dir;
	char	dir[256];
	char	form_path[256];
	char	symbol_path[256];

	FRM_DBG(("RISXfrm_initialize(init_parms:0x%x)\n", init_parms));

	if (RISfrm_initialized)
	{
		CLEAR_ERROR;
		return RIS_SUCCESS;
	}
	if (RISload_dll())
	{
		RISfrm_form_errhandle(RIS_E_DYNAMIC_LOADING_FAILED, 0);
		return RIS_forms_error.error;
	}
	if ((sts = SETJMP()) != 0)
	{
		RISfrm_form_errhandle(sts, 0);
		return RIS_forms_error.error;
	}

	RISuco_initialize_debug(debug_info, debug_count);
	RISuco_initialize_ums(INIT_UTL_UMS_FILE);

	RESETJMP();

/*
**	Passing RIS_LANGUAGE environment variable to RISinitialize
**	to fix TR# 249406609. RAJU 10/07/94
*/
	RISinitialize(getenv("RIS_LANGUAGE"));
	if (SQLCODE != RIS_SUCCESS)
	{
		RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
		return RIS_forms_error.error;
	}

	sts = RIScom_get_risdir(RIS_CLIENT_RUNTIME_PRODUCT, RIS_version_maj,
		RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
		0, RISCONFIG_FILE, dir, &development, 0);
	if (sts != 0)
	{
		RISfrm_form_errhandle(sts, 0);
		return RIS_forms_error.error;
	}

 	RISint_get_language_code(&lang_code);
	lang_dir = RIScom_ris_lang_dir(lang_code);
	if (development)
	{
#if defined(unix)
		sprintf(form_path,"%s/risutl/config/%s/forms/unix/v5forms", dir, lang_dir);
		sprintf(symbol_path,"%s/risutl/config/%s/icons", dir, lang_dir);
#elif defined(WIN32)
		sprintf(form_path,"%s\\risutl\\config\\%s\\forms\\nt\\v5forms", dir, lang_dir);
		sprintf(symbol_path,"%s\\risutl\\config\\%s\\icons", dir, lang_dir);
#endif
	}
	else
	{
#if defined(unix)
		sprintf(form_path,"%s/config/%s/forms/v5forms", dir, lang_dir);
		sprintf(symbol_path,"%s/config/%s/icons", dir, lang_dir);
#elif defined(WIN32)
		sprintf(form_path,"%s\\config\\%s\\forms\\v5forms", dir, lang_dir);
		sprintf(symbol_path,"%s\\config\\%s\\icons", dir, lang_dir);
#endif
	}
	sts = FI_append_form_path(form_path);
	if (sts)
	{
		RISfrm_form_errhandle(RISUTL_E_APPEND_FORM_PATH, sts);
		return RIS_forms_error.error;
	}
	sts = FI_append_symbol_path(symbol_path);
	if (sts)
	{
		RISfrm_form_errhandle(RISUTL_E_APPEND_SYMBOL_PATH, sts);
		return RIS_forms_error.error;
	}

	if (lang_code != 0) /* english */
	{
		/*
		** add english to search paths
		*/
		lang_dir = RIScom_ris_lang_dir(0);
		if (development)
		{
#if defined(unix)
			sprintf(form_path,"%s/risutl/config/%s/forms/unix/v5forms", dir, lang_dir);
			sprintf(symbol_path,"%s/risutl/config/%s/icons", dir, lang_dir);
#elif defined(WIN32)
			sprintf(form_path,"%s\\risutl\\config\\%s\\forms\\nt\\v5forms",dir,lang_dir);
			sprintf(symbol_path,"%s\\risutl\\config\\%s\\icons",dir,lang_dir);
#endif
		}
		else
		{
#if defined(unix)
			sprintf(form_path,"%s/config/%s/forms/v5forms", dir, lang_dir);
			sprintf(symbol_path,"%s/config/%s/icons", dir, lang_dir);
#elif defined(WIN32)
			sprintf(form_path,"%s\\config\\%s\\forms\\v5forms", dir, lang_dir);
			sprintf(symbol_path,"%s\\config\\%s\\icons", dir, lang_dir);
#endif
		}
		sts = FI_append_form_path(form_path);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_APPEND_FORM_PATH, sts);
			return RIS_forms_error.error;
		}
		sts = FI_append_symbol_path(symbol_path);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_APPEND_SYMBOL_PATH, sts);
			return RIS_forms_error.error;
		}
	}
	
	if (init_parms)
	{
		if (init_parms->pre_notification_routine)
			RISfrm_pre_notification = init_parms->pre_notification_routine;
		if (init_parms->post_notification_routine)
			RISfrm_post_notification = init_parms->post_notification_routine;

		if (init_parms->schema_mgr_init_routine)
			RISfrm_user_init_sm_form = init_parms->schema_mgr_init_routine;

		if (init_parms->schema_definition_init_routine)
			RISfrm_user_init_sd_form=init_parms->schema_definition_init_routine;
		if (init_parms->data_definition_init_routine)
			RISfrm_user_init_dd_form = init_parms->data_definition_init_routine;
		if (init_parms->schema_file_init_routine)
			RISfrm_user_init_sf_form = init_parms->schema_file_init_routine;
		if (init_parms->locate_client_init_routine)
			RISfrm_user_init_lc_form = init_parms->locate_client_init_routine;
		if (init_parms->set_init_routine)
			RISfrm_user_init_se_form = init_parms->set_init_routine;

		if (init_parms->schema_info_init_routine)
			RISfrm_user_init_si_form = init_parms->schema_info_init_routine;
		if (init_parms->create_schema_init_routine)
			RISfrm_user_init_cs_form = init_parms->create_schema_init_routine;
		if (init_parms->drop_schema_init_routine)
			RISfrm_user_init_ds_form = init_parms->drop_schema_init_routine;
		if (init_parms->schema_access_init_routine)
			RISfrm_user_init_sa_form = init_parms->schema_access_init_routine;
		if (init_parms->dict_access_init_routine)
			RISfrm_user_init_da_form = init_parms->dict_access_init_routine;
		if (init_parms->schema_password_init_routine)
			RISfrm_user_init_sp_form = init_parms->schema_password_init_routine;
		if (init_parms->node_info_init_routine)
			RISfrm_user_init_ni_form = init_parms->node_info_init_routine;
		if (init_parms->db2pass_init_routine)
			RISfrm_user_init_dp_form = init_parms->db2pass_init_routine;

		if (init_parms->ris_dbs_init_routine)
			RISfrm_user_init_rd_form = init_parms->ris_dbs_init_routine;

		if (init_parms->table_info_init_routine)
			RISfrm_user_init_ti_form = init_parms->table_info_init_routine;
		if (init_parms->create_table_init_routine)
			RISfrm_user_init_ct_form = init_parms->create_table_init_routine;
		if (init_parms->alter_table_init_routine)
			RISfrm_user_init_at_form = init_parms->alter_table_init_routine;
		if (init_parms->drop_table_init_routine)
			RISfrm_user_init_dt_form = init_parms->drop_table_init_routine;
		if (init_parms->include_init_routine)
			RISfrm_user_init_in_form = init_parms->include_init_routine;
		if (init_parms->exclude_init_routine)
			RISfrm_user_init_ex_form = init_parms->exclude_init_routine;


		if (init_parms->set_exec_routine)
			RISfrm_user_exec_se_form = init_parms->set_exec_routine;

		if (init_parms->create_schema_exec_routine)
			RISfrm_user_exec_cs_form = init_parms->create_schema_exec_routine;
		if (init_parms->drop_schema_exec_routine)
			RISfrm_user_exec_ds_form = init_parms->drop_schema_exec_routine;
		if (init_parms->schema_access_exec_routine)
			RISfrm_user_exec_sa_form = init_parms->schema_access_exec_routine;
		if (init_parms->dict_access_exec_routine)
			RISfrm_user_exec_da_form = init_parms->dict_access_exec_routine;
		if (init_parms->schema_password_exec_routine)
			RISfrm_user_exec_sp_form = init_parms->schema_password_exec_routine;
		if (init_parms->node_info_exec_routine)
			RISfrm_user_exec_ni_form = init_parms->node_info_exec_routine;
		if (init_parms->db2pass_exec_routine)
			RISfrm_user_exec_dp_form = init_parms->db2pass_exec_routine;

		if (init_parms->create_table_exec_routine)
			RISfrm_user_exec_ct_form = init_parms->create_table_exec_routine;
		if (init_parms->alter_table_exec_routine)
			RISfrm_user_exec_at_form = init_parms->alter_table_exec_routine;
		if (init_parms->drop_table_exec_routine)
			RISfrm_user_exec_dt_form = init_parms->drop_table_exec_routine;
		if (init_parms->include_exec_routine)
			RISfrm_user_exec_in_form = init_parms->include_exec_routine;
		if (init_parms->exclude_exec_routine)
			RISfrm_user_exec_ex_form = init_parms->exclude_exec_routine;

		if (init_parms->error_handler_routine)
			RISfrm_user_error_handler = init_parms->error_handler_routine;

		RISfrm_display_help_buttons = init_parms->display_help_buttons;
	}

	RISfrm_initialized = 1;

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern int RISAPI RISXfrm_set_pre_notification_routine(
	void	(*pre_notification_routine)())
{
	RISfrm_pre_notification = pre_notification_routine;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern int RISAPI RISXfrm_set_post_notification_routine(
	void	(*post_notification_routine)())
{
	RISfrm_post_notification = post_notification_routine;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern int RISAPI RISXfrm_set_form_init_routine(
	int		form_label,
	void	(*form_init_routine)())
{
	switch(form_label)
	{
		case SM_FORM: RISfrm_user_init_sm_form = form_init_routine; break;

		case SD_FORM: RISfrm_user_init_sd_form = form_init_routine; break;
		case DD_FORM: RISfrm_user_init_dd_form = form_init_routine; break;
		case SF_FORM: RISfrm_user_init_sf_form = form_init_routine; break;
		case LC_FORM: RISfrm_user_init_lc_form = form_init_routine; break;
		case SE_FORM: RISfrm_user_init_se_form = form_init_routine; break;

		case SI_FORM: RISfrm_user_init_si_form = form_init_routine; break;
		case CS_FORM: RISfrm_user_init_cs_form = form_init_routine; break;
		case DS_FORM: RISfrm_user_init_ds_form = form_init_routine; break;
		case SA_FORM: RISfrm_user_init_sa_form = form_init_routine; break;
		case DA_FORM: RISfrm_user_init_da_form = form_init_routine; break;
		case SP_FORM: RISfrm_user_init_sp_form = form_init_routine; break;
		case NI_FORM: RISfrm_user_init_ni_form = form_init_routine; break;
		case DP_FORM: RISfrm_user_init_dp_form = form_init_routine; break;

		case RD_FORM: RISfrm_user_init_rd_form = form_init_routine; break;

		case TI_FORM: RISfrm_user_init_ti_form = form_init_routine; break;
		case CT_FORM: RISfrm_user_init_ct_form = form_init_routine; break;
		case DT_FORM: RISfrm_user_init_dt_form = form_init_routine; break;
		case AT_FORM: RISfrm_user_init_at_form = form_init_routine; break;
		case IN_FORM: RISfrm_user_init_in_form = form_init_routine; break;
		case EX_FORM: RISfrm_user_init_ex_form = form_init_routine; break;
	}
	return RIS_SUCCESS;
}

/******************************************************************************/

extern int RISAPI RISXfrm_set_form_exec_routine(
	int	form_label,
	int	(*form_exec_routine)())
{
	switch(form_label)
	{
		case SE_FORM: RISfrm_user_exec_se_form = form_exec_routine; break;

		case CS_FORM: RISfrm_user_exec_cs_form = form_exec_routine; break;
		case DS_FORM: RISfrm_user_exec_ds_form = form_exec_routine; break;
		case SA_FORM: RISfrm_user_exec_sa_form = form_exec_routine; break;
		case DA_FORM: RISfrm_user_exec_da_form = form_exec_routine; break;
		case SP_FORM: RISfrm_user_exec_sp_form = form_exec_routine; break;
		case NI_FORM: RISfrm_user_exec_ni_form = form_exec_routine; break;
		case DP_FORM: RISfrm_user_exec_dp_form = form_exec_routine; break;

		case CT_FORM: RISfrm_user_exec_ct_form = form_exec_routine; break;
		case AT_FORM: RISfrm_user_exec_at_form = form_exec_routine; break;
		case DT_FORM: RISfrm_user_exec_dt_form = form_exec_routine; break;
		case IN_FORM: RISfrm_user_exec_in_form = form_exec_routine; break;
		case EX_FORM: RISfrm_user_exec_ex_form = form_exec_routine; break;
	}
	return RIS_SUCCESS;
}

/******************************************************************************/

extern int RISAPI RISXfrm_set_error_handler_routine(
	int	(*error_handler_routine)())
{
	RISfrm_user_error_handler = error_handler_routine;
	return RIS_SUCCESS;
}

/******************************************************************************/
