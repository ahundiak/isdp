/* Do not alter this SPC information: $Revision: 1.7.3.1 $ */
/*
**	NAME:							frmschmg.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/90
**	ABSTRACT:
**		The code to process the schema manager form.
**	
**	REVISION HISTORY:
**		Add sc_form and da_form. Move create schema and drop schema
**		two buttons to frmschdf.c. Delete alter schema button
**   					                 by Linda Wang 2/94
**
**	11/94:	Added support for INTERNATIONALIZATION.  Lind Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "risver.h"
#include "forms.h"
#include "riscom.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmschmg_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "fi.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif
#include "frmschdf.prt"
#include "frmcrsch.prt"
#include "frmdadef.prt"
#include "frmdb2ps.prt"
#include "frmdebug.prt"
#include "frmdicac.prt"
#include "frmdrsch.prt"
#include "frmerror.prt"
#include "frmfile.prt"
#include "frmlocli.prt"
#include "frmmsg.prt"
#include "frmnodin.prt"
#include "frmntfy.prt"
#include "frmschac.prt"
#include "frmschfl.prt"
#include "frmschin.prt"
#include "frmschmg.prt"
#include "frmschps.prt"
#include "frmset.prt"
#include "frmutil.prt"
#include "sys.prt"
#include "comisfn.prt"

/*
**	DEFINES
*/
#define SM_TITLE_TEXT	13

/*
**	VARIABLES
*/
static	 Form		sm_form = 0;
static	RISfrm_msg	*sm_msg = &RISfrm_msgs[SM_FORM_MSG];
static	 int			debug_form_enabled = 0;

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** SM_TITLE_TEXT ***************************************************
*******************************************************************************/

#if defined(unix)
static void process_title_text()
{
	int 	len;
	char	*text;
	char	version[32];

	FRM_DBG(("process_title_text()\n"));

	FIg_get_text_length(sm_form, SM_TITLE_TEXT, &len);
	text = (char *)malloc(len);
	FIg_get_text(sm_form, SM_TITLE_TEXT, text);

	sprintf(version,MSG(RISUTL_I_VERSION), RIS_version);

	FIg_erase(sm_form, SM_TITLE_TEXT);
	FIg_set_text(sm_form, SM_TITLE_TEXT, version);
	FIg_display(sm_form, SM_TITLE_TEXT);
	sleep(2);
	FIg_erase(sm_form, SM_TITLE_TEXT);
	FIg_set_text(sm_form, SM_TITLE_TEXT, text);
	FIg_display(sm_form, SM_TITLE_TEXT);

	free(text);
}
#endif

/*******************************************************************************
************** SM_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(sm_form, SM_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(sm_form, SM_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
************** SM_SCHEMAS_FIELD ************************************************
*******************************************************************************/

static void load_schemas_field()
{
	int			row;
	ris_schema_info	*schema;

	FRM_DBG(("load_schemas_field()\n"));
	FIfld_set_num_rows(sm_form, SM_SCHEMAS_FIELD, RISfrm_schemas_cnt);
	if (RISfrm_schemas_cnt > 0)
	{
		for (schema = RISfrm_schemas, row = 0;
			 schema;
			 schema = schema->next, row++)
		{
			FIfld_set_text(sm_form, SM_SCHEMAS_FIELD,row,0, schema->schname, 0);
			if (schema->secure)
			{
				FIfld_set_text(sm_form, SM_SCHEMAS_FIELD, row, 1, "SECURE", 0);
			}	            		
			else
			{
				FIfld_set_text(sm_form, SM_SCHEMAS_FIELD, row, 1,"STANDARD", 0);
			}	            		

			if (strcmp(schema->dictowner, schema->schowner) == 0)
			{
				FIfld_set_text(sm_form, SM_SCHEMAS_FIELD, row, 2, "OWNED", 0);
			}
			else
			{
				FIfld_set_text(sm_form, SM_SCHEMAS_FIELD, row, 2, "SHARED", 0);
			}
		}
	}
	else
	{
		strcpy(sm_msg->str, MSG(RISUTL_I_NO_SCHEMAS_DEFINED));
	}
}

/******************************************************************************/

extern char *RISfrm_get_selected_schname()
{
	int		row;
	int		num_rows;
	int		sel_flag;
	int		r_pos;
	static  char	schname[RIS_MAX_ID_SIZE];

	FIfld_get_num_rows(sm_form, SM_SCHEMAS_FIELD, &num_rows);

	for (row = 0; row < num_rows; row++)
	{
		FIfld_get_text(sm_form, SM_SCHEMAS_FIELD, row, 0, 
                RIS_MAX_ID_SIZE, (unsigned char *)schname, &sel_flag, &r_pos);
		if (sel_flag) return(schname);
	}
	return (char *)0;
}

/******************************************************************************/

static void process_schemas_field()
{
	char		*schname;
	ris_schema_info	*schemap;

	FRM_DBG(("process_schemas_field()\n"));

	schname = RISfrm_get_selected_schname();
	schemap = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);

	if (RISfrm_si_form_displayed()) RISfrm_update_si_form(schemap);
	if (RISfrm_cs_form_displayed()) RISfrm_update_cs_form(schemap);
	if (RISfrm_ds_form_displayed()) RISfrm_update_ds_form(schemap);
	if (RISfrm_sa_form_displayed()) RISfrm_update_sa_form(schemap);
	if (RISfrm_da_form_displayed()) RISfrm_update_da_form(schemap);
	if (RISfrm_sp_form_displayed()) RISfrm_update_sp_form(schemap);
	if (RISfrm_ni_form_displayed()) RISfrm_update_ni_form(schemap);
	if (RISfrm_dp_form_displayed()) RISfrm_update_dp_form(schemap);
	if (RISfrm_dd_form_displayed()) RISfrm_update_dd_form(schemap);
	if (schname && !schemap)
	{
		sprintf(sm_msg->str,MSG(RISUTL_I_UNKNOWN_SCHEMA), schname);
	}
}

/******************************************************************************/

extern void RISfrm_update_sm_schemas_field(
	char	*schname)
{
	int		row;
	int		r_pos;
	int		offset;
	int		sel_flag;
	int		num_rows;
	int		num_vis_rows;
	char	rowname[RIS_MAX_ID_SIZE];

	FRM_DBG(("RISfrm_update_sm_schemas_field(schname:<%s>)\n",
		schname?schname:"NULL"));

	VALID_FORM_CHECK(sm_form);

	FIfld_get_num_rows(sm_form, SM_SCHEMAS_FIELD, &num_rows);
	FIfld_get_num_vis_rows(sm_form, SM_SCHEMAS_FIELD, &num_vis_rows);

	for (row = 0; row < num_rows; row++)
	{
		FIfld_get_text(sm_form, SM_SCHEMAS_FIELD, row, 0, RIS_MAX_ID_SIZE,
			(unsigned char *)rowname, &sel_flag, &r_pos);
		if (schname && *schname && !strcmp(rowname, schname))
		{
			FIfld_set_select(sm_form, SM_SCHEMAS_FIELD, row, 0, 1);
			FIfld_set_select(sm_form, SM_SCHEMAS_FIELD, row, 1, 1);
			FIfld_set_select(sm_form, SM_SCHEMAS_FIELD, row, 2, 1);
   			FIfld_get_row_offset(sm_form, SM_SCHEMAS_FIELD, &offset);
   			if (row < offset || row >= offset + num_vis_rows)
   			{
				FIfld_set_active_row(sm_form, SM_SCHEMAS_FIELD, row, 0);
   			}
		}
		else if (sel_flag)
		{
			FIfld_set_select(sm_form, SM_SCHEMAS_FIELD, row, 0, 0);
			FIfld_set_select(sm_form, SM_SCHEMAS_FIELD, row, 1, 0);
			FIfld_set_select(sm_form, SM_SCHEMAS_FIELD, row, 2, 0);
		}
	}
}

/******************************************************************************/

static void clear_sm_schemas_field()
{
	FRM_DBG(("clear_sm_schemas_field()\n"));

	VALID_FORM_CHECK(sm_form);
	RISfrm_clear_multi_row_field(sm_form, SM_SCHEMAS_FIELD);
}

/*******************************************************************************
************** SUBFORM *********************************************************
*******************************************************************************/

static void erase_subform(
	int ex_f_label)
{
	FRM_DBG(("erase_subform(ex_f_label:%d)\n", ex_f_label));
	/*
	**	All the "erase" functions take asction only if the form is displayed
	**	They also call the "clear" functions
	*/
/*	if (ex_f_label != SI_FORM) RISfrm_erase_si_form(); */
/*	if (ex_f_label != CS_FORM) RISfrm_erase_cs_form(); */
/*	if (ex_f_label != DS_FORM) RISfrm_erase_ds_form(); */
	if (ex_f_label != SD_FORM) RISfrm_erase_sd_form();
	if (ex_f_label != DD_FORM) RISfrm_erase_dd_form();
	if (ex_f_label != SF_FORM) RISfrm_erase_sf_form();
	if (ex_f_label != LC_FORM) RISfrm_erase_lc_form();
	if (ex_f_label != SE_FORM) RISfrm_erase_se_form();
	if (ex_f_label != DB_FORM) RISfrm_erase_db_form();
/*	if (ex_f_label != DA_FORM) RISfrm_erase_da_form(); */
}

/******************************************************************************/

static int display_update_form(
	int		(*form_displayed)(),
	int		(*display_form)(),
	void	(*update_form)(),
	void	(*call_user_init_form)())
{
	int			sts;
	char		*schname;
	ris_schema_info	*schemap;

	FRM_DBG(("display_update_form()\n"));

	if (!form_displayed())
	{
		if ((sts = display_form(CALLED_BY_SCHEMA_MGR)) != RIS_SUCCESS)
		{
			FRM_DBG(("display_update_form() sts = %d\n", sts));
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
	FIg_set_state(sm_form, g_label, 0);
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

	FIg_get_state(sm_form, g_label, &state);

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
************** SM_SCHEMA_DEFINITION_BUTTON *************************************
*******************************************************************************/

static void process_schema_def_button()
{
	FRM_DBG(("process_schema_def_button()\n"));

	process_button(SD_FORM, SM_SCHEMA_DEFINITION_BUTTON,
		RISfrm_sd_form_displayed, RISfrm_display_sd_form,
		NULL, NULL,
		RISfrm_erase_sd_form);
}

/******************************************************************************/

extern void RISfrm_clear_sm_schema_def_button()
{
	FRM_DBG(("RISfrm_clear_sm_schema_def_button()\n"));
	VALID_FORM_CHECK(sm_form);
	clear_button(SM_SCHEMA_DEFINITION_BUTTON);
}

/*******************************************************************************
************** SM_DATA_DEFINITION_BUTTON ***************************************
******************************************************************************/

static void process_data_def_button()
{
	FRM_DBG(("process_data_def_button()\n"));

	process_button(DD_FORM, SM_DATA_DEFINITION_BUTTON,
		RISfrm_dd_form_displayed, RISfrm_display_dd_form,
		RISfrm_update_dd_form, NULL,
		RISfrm_erase_dd_form);
}

/******************************************************************************/

extern void RISfrm_clear_sm_data_def_button()
{
	FRM_DBG(("RISfrm_clear_sm_data_def_button()\n"));
	VALID_FORM_CHECK(sm_form);
	clear_button(SM_DATA_DEFINITION_BUTTON);
}

/*******************************************************************************
************** SM_SCHEMA_FILE_BUTTON ***************************************
*******************************************************************************/

static void process_schema_file_button()
{
	FRM_DBG(("process_schema_file_button()\n"));

	process_button(SF_FORM, SM_SCHEMA_FILE_BUTTON,
		RISfrm_sf_form_displayed, RISfrm_display_sf_form,
		RISfrm_update_sf_form, RISfrm_call_user_init_sf_form,
		RISfrm_erase_sf_form);
}

/******************************************************************************/

extern void RISfrm_clear_sm_schema_file_button()
{
	FRM_DBG(("RISfrm_clear_sm_schema_file_button()\n"));
	VALID_FORM_CHECK(sm_form);
	clear_button(SM_SCHEMA_FILE_BUTTON);
}

/*******************************************************************************
************** SM_LOCATE_CLIENT_BUTTON *****************************************
*******************************************************************************/

static void process_locate_client_button()
{
	FRM_DBG(("process_locate_client_button()\n"));

	process_button(LC_FORM, SM_LOCATE_CLIENT_BUTTON,
		RISfrm_lc_form_displayed, RISfrm_display_lc_form,
		RISfrm_update_lc_form, RISfrm_call_user_init_lc_form,
		RISfrm_erase_lc_form);
}

/******************************************************************************/

extern void RISfrm_clear_sm_locate_client_button()
{
	FRM_DBG(("RISfrm_clear_sm_locate_client_button()\n"));
	VALID_FORM_CHECK(sm_form);
	clear_button(SM_LOCATE_CLIENT_BUTTON);
}

/*******************************************************************************
************** SM_SET_BUTTON ***************************************************
*******************************************************************************/

static void process_set_button()
{
	FRM_DBG(("process_set_button()\n"));

	process_button(SE_FORM, SM_SET_BUTTON,
		RISfrm_se_form_displayed, RISfrm_display_se_form,
		NULL, RISfrm_call_user_init_se_form,
		RISfrm_erase_se_form);
}

/******************************************************************************/

extern void RISfrm_clear_sm_set_button()
{
	FRM_DBG(("RISfrm_clear_sm_set_button()\n"));
	VALID_FORM_CHECK(sm_form);
	clear_button(SM_SET_BUTTON);
}

/*******************************************************************************
************** SM_DEBUG_BUTTON *************************************************
*******************************************************************************/

static void process_debug_button()
{
	int	sts;
	int	state;

	FRM_DBG(("process_debug_button()\n"));

	FIg_get_state(sm_form, SM_DEBUG_BUTTON, &state);
	if (state)
	{
		sts = RISfrm_display_db_form();
		if (sts != RIS_SUCCESS)
		{
			RISfrm_report_error();
			RISfrm_clear_sm_debug_button();
			return;
		}
	}
	else
	{
		RISfrm_erase_db_form();
	}
}

/******************************************************************************/

extern void RISfrm_clear_sm_debug_button()
{
	FRM_DBG(("RISfrm_clear_sm_debug_button()\n"));
	VALID_FORM_CHECK(sm_form);
	clear_button(SM_DEBUG_BUTTON);
}

/*******************************************************************************
************** SM_RESET_BUTTON *************************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));

	erase_subform(0);
	clear_schema_mgr();
	RISfrm_file_info_up_to_date = 0;
	RISfrm_update_schema_mgr();
	DISPLAY_HELP_BUTTON(sm_form);
	RISfrm_call_user_init_sm_form();
}

/*******************************************************************************
************** FI_CANCEL_BUTTON ************************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));

	erase_subform(0);
	RISfrm_erase_sm_form();
}

/*******************************************************************************
************** SCHEMA_MGR_FORM *************************************************
*******************************************************************************/

extern void RISfrm_process_sm_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_RESET,					process_reset_button			},
		{	FI_CANCEL,					process_cancel_button			},
		{	SM_SCHEMAS_FIELD,			process_schemas_field			},
		{	SM_SCHEMA_DEFINITION_BUTTON,process_schema_def_button		},
		{	SM_DATA_DEFINITION_BUTTON,	process_data_def_button			},
		{	SM_SCHEMA_FILE_BUTTON,		process_schema_file_button		},
		{	SM_LOCATE_CLIENT_BUTTON,	process_locate_client_button	},
		{	SM_SET_BUTTON,				process_set_button				},
		{	SM_DEBUG_BUTTON,			process_debug_button			},
#if defined(unix)
		{	SM_TITLE_TEXT,				process_title_text				},
#endif
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_sm_form(g_label:%d)\n", g_label));

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}

} /* END notification_routine() */

/******************************************************************************/

extern void RISfrm_call_user_init_sm_form()
{
	FRM_DBG(("RISfrm_call_user_init_sm_form()\n"));

	if (RISfrm_user_init_sm_form)
	{
		FRM_DBG(("calling RISfrm_user_init_sm_form()\n"));
		RISfrm_user_init_sm_form(sm_form);
	}
}

/******************************************************************************/

extern void RISfrm_update_schema_mgr()
{
	FRM_DBG(("RISfrm_update_schema_mgr()\n"));

	VALID_FORM_CHECK(sm_form);

	if (!RISfrm_file_info_up_to_date)
	{
		update_msg_field(MSG(RISUTL_I_READING_SCHFILE));
		RISfrm_read_schema_file();
		clear_msg_field();
		if (RIS_forms_error.error && RISfrm_report_error())
		{
			switch(RIS_forms_error.error)
			{
			}
		}
	}

	load_schemas_field();
}

/******************************************************************************/

static void clear_schema_mgr()
{
	FRM_DBG(("clear_schema_mgr()\n"));

	VALID_FORM_CHECK(sm_form);
	clear_sm_schemas_field();
	RISfrm_clear_sm_schema_def_button();
	RISfrm_clear_sm_data_def_button();
	RISfrm_clear_sm_schema_file_button();
	RISfrm_clear_sm_locate_client_button();
	RISfrm_clear_sm_set_button();
	RISfrm_clear_sm_debug_button();
}

/******************************************************************************/

extern int RISfrm_sm_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_sm_form_displayed()\n"));
	if (!sm_form)
	{
		return(0);
	}
	FIf_is_displayed(sm_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_display_sm_form()
{
	int		sts;
#if defined(WIN32)
	char	title[128];
#endif

	FRM_DBG(("RISfrm_display_sm_form()\n"));

	CLEAR_ERROR;
	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!sm_form)
	{
		sts = FIf_new(SM_FORM, SM_FORM_FILE, RISfrm_notification_routine,
			&sm_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_SM_FORM, sts);
			return RIS_forms_error.error;
		}
#if defined(WIN32)
		sprintf(title, MSG(RISUTL_I_RISSCHMG_HEADING), RIS_version);
		FIf_SetTitlebarText(sm_form, (TCHAR *)title);
		FIf_SetDefaultButton(sm_form, FI_CANCEL);
		FIg_set_text(sm_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));
#endif
	}

	if (!RISfrm_sm_form_displayed())
	{
		sm_msg->str[0] = 0;
		sm_msg->count = 0;
		sm_msg->msg_fld_label = SM_MSG_FIELD;
		sm_msg->fp = sm_form;

		DISPLAY_HELP_BUTTON(sm_form);

		if (debug_form_enabled)
		{
			FIg_display(sm_form, SM_DEBUG_BUTTON);
		}

		RISfrm_call_user_init_sm_form();

		sts = FIf_display(sm_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_SM_FORM, sts);
			return RIS_forms_error.error;
		}

		RISfrm_file_info_up_to_date = 0;
		RISfrm_update_schema_mgr();

		if (!sm_msg->str[0])
		{
			char sm_msg_str[512]; /* 1996.03.12:Alan Barksdale:copied from definition of RISfrm_msg in risutl\internal\forms.h; should be a typedef */
			char *ptr;

			/*ptr = RIScom_umsg(RISUTL_I_COPYRIGHT);*/
			/* 1996.03.12:Alan Barksdale:TR439600483 */
			strcpy(sm_msg_str, RIScom_umsg(RISUTL_I_BEGIN_COPYRIGHT));
			strcat(sm_msg_str, " ");
			strcat(sm_msg_str, COPYRIGHTYEAR);
			strcat(sm_msg_str, ", ");
			strcat(sm_msg_str, RIScom_umsg(RISUTL_I_END_COPYRIGHT));
			ptr = sm_msg_str;
			FRM_DBG(("ptr:<%s>\n", STRING(ptr)));
			while (ptr && isascii(*ptr) && RIScom_isspace(*ptr))
			{
				 ptr++;
		 	}
			strcpy(sm_msg->str, ptr);
		}

		RISfrm_display_msgs();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern int RISfrm_erase_sm_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_sm_form()\n"));

	if (RISfrm_sm_form_displayed())
	{
		erase_subform(0);
		sts = FIf_erase(sm_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_SM_FORM, sts);
			return RIS_forms_error.error;
		}

		clear_schema_mgr();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_schema_mgr_form_displayed()
{
	return RISfrm_sm_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_schema_mgr_form()
{
	return RISfrm_display_sm_form();
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_schema_mgr_form()
{
	return RISfrm_erase_sm_form();
}

/******************************************************************************/

extern void RISAPI RISXfrm_enable_debug_form()
{
	debug_form_enabled = 1;
}

/******************************************************************************/
