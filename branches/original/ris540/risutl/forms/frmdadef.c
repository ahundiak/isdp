/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:									frmdadef.c
**	AUTHORS:								Terry McIntyre
**	CREATION DATE:							11/90
**	ABSTRACT:
**	
**		The code to process the drop definition form.
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include "forms.h"
#include "ris_err.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmdadef_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "fi.prt"
#include "frmaltab.prt"
#include "frmcrtab.prt"
#include "frmdadef.prt"
#include "frmdrtab.prt"
#include "frmerror.prt"
#include "frmexcl.prt"
#include "frmfile.prt"
#include "frmincl.prt"
#include "frmntfy.prt"
#include "frmobj.prt"
#include "frmschmg.prt"
#include "frmtabin.prt"
#include "frmutil.prt"
#include "sys.prt"
#include "ris.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif

/*
**	DEFINES
*/
#define NO_ACTION		-1
#define TABLE_INFO		0
#define CREATE_TABLE	1
#define DROP_TABLE		2
#define ALTER_TABLE		3
#define INCLUDE			4
#define EXCLUDE			5
#define ACTION_COUNT	6

#define VALID_ACTION(action) ((action) >= 0 && (action) < ACTION_COUNT)

#define SET_DEF_SCH_SUCCESS		0
#define SET_DEF_SCH_ERROR		1
#define SET_DEF_SCH_ALREADY_SET	2
#define SET_DEF_SCH_NO_SCHNAME	3

/*
**	VARIABLES
*/
static	 Form		dd_form = 0;
static	RISfrm_msg	*dd_msg = &RISfrm_msgs[DD_FORM_MSG];

static struct action_s
{
	int		button;
	int		form;
	int		(*form_displayed)();
	int		(*display_form)();
	int		(*erase_form)();
	void	(*update_form)();
	void	(*clear_form)();
	void	(*enable_form)();
	void	(*disable_form)();
	void	(*call_user_init)();
} action_info[ACTION_COUNT] = 
{
	{
		DD_TABLE_INFO_BUTTON, TI_FORM,
		RISfrm_ti_form_displayed, RISfrm_display_ti_form,
		RISfrm_erase_ti_form,
		RISfrm_update_ti_form, RISfrm_clear_ti_form,
		RISfrm_enable_ti_form, RISfrm_disable_ti_form,
		RISfrm_call_user_init_ti_form,
	},
	{
		DD_CREATE_TABLE_BUTTON,	CT_FORM,
		RISfrm_ct_form_displayed, RISfrm_display_ct_form,
		RISfrm_erase_ct_form,
		RISfrm_update_ct_form, RISfrm_clear_ct_form,
		RISfrm_enable_ct_form, RISfrm_disable_ct_form,
		RISfrm_call_user_init_ct_form,
	},
	{
		DD_DROP_TABLE_BUTTON,	DT_FORM,
		RISfrm_dt_form_displayed, RISfrm_display_dt_form,
		RISfrm_erase_dt_form,
		RISfrm_update_dt_form, RISfrm_clear_dt_form,
		RISfrm_enable_dt_form, RISfrm_disable_dt_form,
		RISfrm_call_user_init_dt_form,
	},
	{
		DD_ALTER_TABLE_BUTTON,	AT_FORM,
		RISfrm_at_form_displayed, RISfrm_display_at_form,
		RISfrm_erase_at_form,
		RISfrm_update_at_form, RISfrm_clear_at_form,
		RISfrm_enable_at_form, RISfrm_disable_at_form,
		RISfrm_call_user_init_at_form,
	},
	{
		DD_INCLUDE_BUTTON, IN_FORM,
		RISfrm_in_form_displayed, RISfrm_display_in_form,
		RISfrm_erase_in_form,
		RISfrm_update_in_form, RISfrm_clear_in_form,
		RISfrm_enable_in_form, RISfrm_disable_in_form
	},
	{
		DD_EXCLUDE_BUTTON, EX_FORM,
		RISfrm_ex_form_displayed, RISfrm_display_ex_form,
		RISfrm_erase_ex_form,
		RISfrm_update_ex_form, RISfrm_clear_ex_form,
		RISfrm_enable_ex_form, RISfrm_disable_ex_form
	},
};

static   char	initial_schname[RIS_MAX_ID_SIZE] = "";

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** DD_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(dd_form, DD_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(dd_form, DD_MSG_FIELD, 0, 0, "", 0);
	FIfld_set_text(dd_form, DD_MSG_FIELD, 1, 0, "", 0);
}

/*******************************************************************************
******************** DD_SCHNAME FIELD ******************************************
*******************************************************************************/

extern char *RISfrm_get_dd_schname_field()
{
	static	 char	schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("RISfrm_get_dd_schname_field()\n"));

	RISfrm_get_field(dd_form, DD_SCHNAME_FIELD, RIS_MAX_ID_SIZE, schname);
	return schname[0] ? schname : NULL;
}

/******************************************************************************/

static void process_schname_field()
{
	char			*schname;
	ris_schema_info	*schema;

	FRM_DBG(("process_schname_field()\n"));

	schname = RISfrm_get_dd_schname_field();
	if (!RISfrm_field_changed(schname, initial_schname))
	{
		return;
	}
	schema = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);
	if (schema == NULL)
	{
		if (schname)
		{
			sprintf(dd_msg->str, MSG(RISUTL_I_UNKNOWN_SCHEMA), schname);
		}
		schname = NULL;
	}

	if (RISfrm_sm_form_displayed())
	{
		RISfrm_update_sm_schemas_field(schname);
	}

	update_dd_form(schema);
}

/******************************************************************************/

static void update_schname_field(
	char	*schname)
{
	FRM_DBG(("update_schname_field(schname:<%s>)\n",schname));
	FIfld_set_text(dd_form, DD_SCHNAME_FIELD, 0, 0, schname, 0);
	strcpy(initial_schname, schname);
}

/******************************************************************************/

static void clear_schname_field()
{
	FRM_DBG(("clear_schname_field()\n"));
	FIfld_set_text(dd_form, DD_SCHNAME_FIELD, 0, 0, "", 0);
	strcpy(initial_schname, "");
}

/*******************************************************************************
************** DD_OBJECTS_MCF **************************************************
*******************************************************************************/

extern void RISfrm_load_dd_objects_mcf(
	char	*schname)
{
	int		i;
	char	type[3];

	FRM_DBG(("RISfrm_load_dd_objects_mcf(schname:<%s>)\n", STRING(schname)));

	VALID_FORM_CHECK(dd_form);
		
	clear_objects_mcf();

	if (!*schname) return;

	if (!RISfrm_object_list_up_to_date)
	{
		RISfrm_get_object_list(schname,update_msg_field,clear_msg_field);
		clear_msg_field();
		if (RIS_forms_error.error && RISfrm_report_error())
		{
			switch(RIS_forms_error.error)
			{
			}
			return;
		}
	}

	FIfld_set_num_rows(dd_form, DD_OBJECTS_MCF, RISfrm_objects_cnt);

	if (RISfrm_objects_cnt)
	{
		for (i = 0; i < RISfrm_objects_cnt; i++)
		{
			type[0] = RISfrm_objects[i]->type;
			type[1] = '\0';
			FIfld_set_text(dd_form, DD_OBJECTS_MCF, i, 0, type, 0);
			FIfld_set_text(dd_form, DD_OBJECTS_MCF, i, 1,
				RISfrm_objects[i]->name, 0);
		}
	}
	else
	{
		strcpy(dd_msg->str, MSG(RISUTL_I_NO_TABLES_VIEWS_INDEXES));
	}
}

/******************************************************************************/

static RISfrm_object *get_selected_object()
{
	int				row;
	int				num_rows;
	int				sel_flag;
	int				r_pos;
	unsigned char	type[3];
	unsigned char	name[RIS_MAX_ID_SIZE];
	RISfrm_object	*object;

	FRM_DBG(("get_selected_object()\n"));

	FIfld_get_num_rows(dd_form, DD_OBJECTS_MCF, &num_rows);

	for (row = 0; row < num_rows; row++)
	{
		FIfld_get_select(dd_form, DD_OBJECTS_MCF, row, 0, &sel_flag);
		if (sel_flag)
		{
			FIfld_get_text(dd_form, DD_OBJECTS_MCF, row, 0, sizeof(type),
				type, &sel_flag, &r_pos);
			FIfld_get_text(dd_form, DD_OBJECTS_MCF, row, 1, RIS_MAX_ID_SIZE,
				name, &sel_flag, &r_pos);

			object = RISfrm_get_object((char *)name, RIS_NAME, type[0], NULL,
				NULL);
			return object;
		}
	}
	return NULL;
}

/******************************************************************************/

static void process_objects_mcf()
{
	int				action;
	RISfrm_object	*objectp;

	FRM_DBG(("process_objects_mcf()\n"));

	action = get_action();
	if (!VALID_ACTION(action))
	{
		return;
	}

	if (action_info[action].form_displayed())
	{
		objectp = get_selected_object();
		if (is_default_schema())
		{
			if (action_info[action].enable_form)
				action_info[action].enable_form();
			if (action_info[action].update_form)
				action_info[action].update_form(objectp);
			if (action_info[action].call_user_init)
				action_info[action].call_user_init();
		}
	}
}

/******************************************************************************/

extern void RISfrm_update_dd_objects_mcf(
	RISfrm_object	*object)
{
	int		row;
	int		r_pos;
	int		offset;
	int		sel_flag;
	int		num_rows;
	int		num_vis_rows;
	char	rowname[RIS_MAX_ID_SIZE];
	char	rowtype[3];

	FRM_DBG(("RISfrm_update_dd_objects_mcf(object:0x%x)\n",object));

	VALID_FORM_CHECK(dd_form);

	FIfld_get_num_rows(dd_form, DD_OBJECTS_MCF, &num_rows);
	FIfld_get_num_vis_rows(dd_form, DD_OBJECTS_MCF, &num_vis_rows);

	for (row = 0; row < num_rows; row++)
	{
		FIfld_get_text(dd_form, DD_OBJECTS_MCF, row, 0, 2,
			(unsigned char *)rowtype, &sel_flag, &r_pos);
		FIfld_get_text(dd_form, DD_OBJECTS_MCF, row, 1, RIS_MAX_ID_SIZE,
			(unsigned char *)rowname, &sel_flag, &r_pos);

		if (object && object->name[0] && !strcmp(rowname, object->name))
		{
			if ((object->type == TABLE_CHAR && rowtype[0] == TABLE_CHAR) ||
				(object->type == VIEW_CHAR  && rowtype[0] == VIEW_CHAR)  ||
				(object->type == INDEX_CHAR && rowtype[0] == INDEX_CHAR))
			{
				FIfld_set_select(dd_form, DD_OBJECTS_MCF, row, 0, 1);
				FIfld_set_select(dd_form, DD_OBJECTS_MCF, row, 1, 1);
   				FIfld_get_row_offset(dd_form, DD_OBJECTS_MCF, &offset);
   				if (row < offset || row > offset + num_vis_rows)
   				{
					FIfld_set_active_row(dd_form, DD_OBJECTS_MCF, row, 0);
   				}
				continue;
			}
		}

		if (sel_flag)
		{
			FIfld_set_select(dd_form, DD_OBJECTS_MCF, row, 0, 0);
			FIfld_set_select(dd_form, DD_OBJECTS_MCF, row, 1, 0);
		}
	}
}

/******************************************************************************/

static void clear_objects_mcf()
{
	FRM_DBG(("clear_objects_mcf()\n"));
	RISfrm_clear_multi_row_field(dd_form, DD_OBJECTS_MCF);
}

/*******************************************************************************
******************** ACTIONS ***************************************************
*******************************************************************************/

static int get_action()
{
	int	i;
	int	state;

	FRM_DBG(("get_action()\n"));

	for (i = 0; i < ACTION_COUNT; i++)
	{
		FIg_get_state(dd_form, action_info[i].button, &state);
		if (state) return i;
	}
	return NO_ACTION;
}

/******************************************************************************/

static void clear_action()
{
	int		i;

	FRM_DBG(("clear_action()\n"));

	for (i = 0; i < ACTION_COUNT; i++)
	{
		FIg_set_state(dd_form, action_info[i].button, 0);
	}
}

/*******************************************************************************
******************** DD_DEFAULT_SCHEMA *****************************************
*******************************************************************************/

static int is_default_schema()
{
	int		return_sts = 0;
	char	*schname;
	char	defschname[RIS_MAX_ID_SIZE] = "";

	if ((schname = RISfrm_get_dd_schname_field()) != NULL)
	{
		RISget_default_schema_name(defschname);
		if (!strcmp(schname, defschname))
		{
			return_sts = 1;
		}
	}
	
	return return_sts;
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
	if (ex_f_label != TI_FORM) RISfrm_erase_ti_form();
	if (ex_f_label != CT_FORM) RISfrm_erase_ct_form();
	if (ex_f_label != DT_FORM) RISfrm_erase_dt_form();
	if (ex_f_label != AT_FORM) RISfrm_erase_at_form();
	if (ex_f_label != IN_FORM) RISfrm_erase_in_form();
	if (ex_f_label != EX_FORM) RISfrm_erase_ex_form(); 
}

/*******************************************************************************
************** BUTTONS *********************************************************
*******************************************************************************/

static void clear_button(
	int	g_label)
{
	FRM_DBG(("clear_button(g_label:%d)\n", g_label));
	FIg_set_state(dd_form, g_label, 0);
}

/******************************************************************************/

static void process_button()
{
	int				sts;
	int				action;
	RISfrm_object	*objectp;

	FRM_DBG(("process_button()\n"));

	action = get_action();

	if (!VALID_ACTION(action))
	{
		erase_subform(0);
		return;
	}

	erase_subform(action_info[action].form);

	objectp = get_selected_object();

	if (is_default_schema())
	{
		sts = action_info[action].display_form(CALLED_BY_SCHEMA_MGR,
			DISPLAY_ENABLED);
		if (sts != RIS_SUCCESS)
		{
			RISfrm_report_error();
			clear_button(action_info[action].button);
			return;
		}
		if (action_info[action].update_form)
			action_info[action].update_form(objectp);
		if (action_info[action].call_user_init)
			action_info[action].call_user_init();
	}
	else
	{
		sts = action_info[action].display_form(CALLED_BY_SCHEMA_MGR,
			DISPLAY_DISABLED);
		if (sts != RIS_SUCCESS)
		{
			RISfrm_report_error();
			clear_button(action_info[action].button);
			return;
		}
	}
}

/******************************************************************************/

extern void RISfrm_clear_dd_table_info_button()
{
	FRM_DBG(("RISfrm_clear_dd_table_info_button()\n"));
	VALID_FORM_CHECK(dd_form);
	clear_button(DD_TABLE_INFO_BUTTON);
}

/******************************************************************************/

extern void RISfrm_clear_dd_create_table_button()
{
	FRM_DBG(("RISfrm_clear_dd_create_table_button()\n"));
	VALID_FORM_CHECK(dd_form);
	clear_button(DD_CREATE_TABLE_BUTTON);
}

/******************************************************************************/

extern void RISfrm_clear_dd_drop_table_button()
{
	FRM_DBG(("RISfrm_clear_dd_drop_table_button()\n"));
	VALID_FORM_CHECK(dd_form);
	clear_button(DD_DROP_TABLE_BUTTON);
}

/******************************************************************************/

extern void RISfrm_clear_dd_alter_table_button()
{
	FRM_DBG(("RISfrm_clear_dd_alter_table_button()\n"));
	VALID_FORM_CHECK(dd_form);
	clear_button(DD_ALTER_TABLE_BUTTON);
}

/******************************************************************************/

extern void RISfrm_clear_dd_include_button()
{
	FRM_DBG(("RISfrm_clear_dd_include_button()\n"));
	VALID_FORM_CHECK(dd_form);
	clear_button(DD_INCLUDE_BUTTON);
}

/******************************************************************************/

extern void RISfrm_clear_dd_exclude_button()
{
	FRM_DBG(("RISfrm_clear_dd_exclude_button()\n"));
	VALID_FORM_CHECK(dd_form);
	clear_button(DD_EXCLUDE_BUTTON);
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));
	RISfrm_erase_dd_form();
	if (RISfrm_sm_form_displayed())
		RISfrm_clear_sm_data_def_button();
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	if (RISfrm_sm_form_displayed())
		RISfrm_update_sm_schemas_field(NULL);
	RISfrm_clear_dd_form();
	DISPLAY_HELP_BUTTON(dd_form);
	RISfrm_call_user_init_dd_form();
}

/*******************************************************************************
******************** DD FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_dd_form(
	int	g_label)
{
	int	i;

	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,				process_cancel_button		},
		{	FI_RESET,				process_reset_button		},
		{	DD_SCHNAME_FIELD,		process_schname_field		},
		{	DD_OBJECTS_MCF,			process_objects_mcf			},
		{	DD_TABLE_INFO_BUTTON,	process_button	},
		{	DD_CREATE_TABLE_BUTTON,	process_button	},
		{	DD_DROP_TABLE_BUTTON,	process_button	},
		{	DD_ALTER_TABLE_BUTTON,	process_button	},
		{	DD_INCLUDE_BUTTON,		process_button	},
		{	DD_EXCLUDE_BUTTON,		process_button	},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_dd_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(dd_form);

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

extern void RISfrm_process_dd_form_initial(
	int g_label)
{
	FRM_DBG(("RISfrm_process_dd_form_initial(g_label:%d)\n", g_label));
	switch(g_label)
	{
		case DD_SCHNAME_FIELD:
			RISfrm_get_field(dd_form, DD_SCHNAME_FIELD, RIS_MAX_ID_SIZE,
				initial_schname);
			break;
	}
}

/******************************************************************************/

extern void RISfrm_call_user_init_dd_form()
{
	FRM_DBG(("RISfrm_call_user_init_dd_form()\n"));

	if (RISfrm_user_init_dd_form)
	{
		FRM_DBG(("calling RISfrm_user_init_dd_form()\n"));
		RISfrm_user_init_dd_form(dd_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_dd_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_dd_form(called_by_user:%d)\n", called_by_user));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!dd_form)
	{
		sts = FIf_new(DD_FORM, DD_FORM_FILE, RISfrm_notification_routine,
			&dd_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_DD_FORM, sts);
			return RIS_forms_error.error;
		}

		FIf_set_initial_notification_routine(dd_form,
			RISfrm_initial_notification_routine);

#if defined(WIN32)
		FIf_SetDefaultButton(dd_form, FI_CANCEL);
		FIg_set_text(dd_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));

#endif

		FIfld_set_max_num_chars(dd_form, DD_SCHNAME_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
	}

	if (!RISfrm_dd_form_displayed())
	{
		dd_msg->str[0] = 0;
		dd_msg->count = 0;
		dd_msg->msg_fld_label = DD_MSG_FIELD;
		dd_msg->fp = dd_form;

		DISPLAY_HELP_BUTTON(dd_form);

		if (called_by_user) RISfrm_call_user_init_dd_form();

		sts = FIf_display (dd_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_DD_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

static void update_dd_form(
	ris_schema_info	*schema)
{
	/*
	**	This routine is called internally when ever the schname changes.
	**	It should update every thing on the form that needs updating
	**	except the schname_field()
	*/

	int	action;

	FRM_DBG(("update_dd_form(schema:0x%x)\n", schema));

	VALID_FORM_CHECK(dd_form);

	action = get_action();
	RISfrm_object_list_up_to_date = 0;

	clear_objects_mcf();
	if (VALID_ACTION(action))
	{
		if (action_info[action].form_displayed())
		{
			if (action_info[action].clear_form)
				action_info[action].clear_form();
			if (action_info[action].disable_form)
				action_info[action].disable_form();
		}
	}

	if (schema)
	{
		update_msg_field(MSG(RISUTL_I_OPENING_SCHEMA));
		RISfrm_set_default_schema(schema->schname, schema->dbid);
		clear_msg_field();
		if (SQLCODE != RIS_SUCCESS)
		{
			RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
			RISfrm_report_error();

			clear_schname_field();
			if (RISfrm_sm_form_displayed())
			{
				RISfrm_update_sm_schemas_field(NULL);
			}
			schema = NULL;
		}
	}

	if (schema)
	{
		RISfrm_load_dd_objects_mcf(schema->schname);
	
		if (VALID_ACTION(action))
		{
			if (action_info[action].form_displayed())
			{
				if (action_info[action].enable_form)
					action_info[action].enable_form();
				if (action_info[action].update_form)
					action_info[action].update_form(NULL);
				if (action_info[action].call_user_init)
					action_info[action].call_user_init();
			}
		}
	}
}

/******************************************************************************/

extern void RISfrm_update_dd_form(
	ris_schema_info	*schema)
{
	/*
	**	This routine is called by other forms to update this form.  It should
	**	update the schname field, then call the internal update function.
	*/

	if (schema)
	{
		update_schname_field(schema->schname);
	}
	else
	{
		clear_schname_field();
	}

	update_dd_form(schema);
}

/******************************************************************************/

extern void RISfrm_clear_dd_form()
{
	FRM_DBG(("RISfrm_clear_dd_form()\n"));
	VALID_FORM_CHECK(dd_form);

	RISfrm_object_list_up_to_date = 0;
	erase_subform(0);
	clear_schname_field();
	clear_objects_mcf();
	clear_action();
}

/******************************************************************************/

extern int RISfrm_dd_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_dd_form_displayed()\n"));
	if (!dd_form)
	{
		return(0);
	}
	FIf_is_displayed(dd_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_dd_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_dd_form()\n"));

	if (RISfrm_dd_form_displayed())
	{
		sts = FIf_erase(dd_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_DD_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_dd_form();
		if (RISfrm_sm_form_displayed())
			RISfrm_clear_sm_data_def_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_data_def_form_displayed()
{
	return RISfrm_dd_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_data_def_form()
{
	return RISfrm_display_dd_form(CALLED_BY_USER);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_data_def_form()
{
	return RISfrm_erase_dd_form();
}

/******************************************************************************/
