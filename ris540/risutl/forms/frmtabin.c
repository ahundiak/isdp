/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							frmtabin.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/90
**	ABSTRACT:
**		The code to process the table information form.
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include "forms.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmtabin_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "fi.prt"
#include "frmcolmn.prt"
#include "frmdadef.prt"
#include "frmerror.prt"
#include "frmntfy.prt"
#include "frmobj.prt"
#include "frmtabin.prt"
#include "frmutil.prt"
#include "ris.prt"
#include "sys.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif


/*
**	DEFINES
*/

/*
**	VARIABLES
*/
static   char		initial_table_name[RIS_MAX_ID_SIZE] = "";
static	 Form		ti_form = 0;
static	RISfrm_msg	*ti_msg = &RISfrm_msgs[TI_FORM_MSG];

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** TI_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(ti_form, TI_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(ti_form, TI_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** TI_COLUMNS_MCF ********************************************
*******************************************************************************/

static void load_columns_mcf(
	char	*table_name)
{
	FRM_DBG(("load_columns_mcf(table_name:<%s>)\n", table_name));

	clear_columns_mcf();
	update_msg_field(MSG(RISUTL_I_READING_DICTIONARY_TABLES));
	RISfrm_load_columns_mcf(table_name, ti_form, TI_COLUMNS_MCF);
	if (RIS_forms_error.error && RISfrm_report_error())
	{
		switch(RIS_forms_error.error)
		{
		}
	}
	clear_msg_field();
}

/******************************************************************************/

static void process_columns_mcf()
{
	int		row;
	int		r_pos;
	int		sel_flag;
	int		position;
	char	column_name[RIS_MAX_ID_SIZE];

	FRM_DBG(("process_columns_mcf()\n"));

	FIfld_get_active_row(ti_form, TI_COLUMNS_MCF, &row, &position);
	FIfld_get_text(ti_form, TI_COLUMNS_MCF, row, 1, RIS_MAX_ID_SIZE,
		(unsigned char *)column_name, &sel_flag, &r_pos);
	if (sel_flag)
	{
		update_search_column_field(column_name);
	}
	else
	{
		clear_search_column_field();
	}
}

/******************************************************************************/

static void update_columns_mcf(
	char	*column_name)
{
	int		row;
	int		r_pos;
	int		offset;
	int		sel_flag;
	int		num_rows;
	int		num_vis_rows;
	int		column_found = 0;
	char	rowname[RIS_MAX_ID_SIZE];

	FRM_DBG(("update_columns_mcf(column_name:<%s>)\n",
		column_name ? column_name : "NULL"));

	VALID_FORM_CHECK(ti_form);

	FIfld_get_num_rows(ti_form, TI_COLUMNS_MCF, &num_rows);
	FIfld_get_num_vis_rows(ti_form, TI_COLUMNS_MCF, &num_vis_rows);

	for (row = 0; row < num_rows; row++)
	{
		FIfld_get_text(ti_form, TI_COLUMNS_MCF, row, 1, RIS_MAX_ID_SIZE,
			(unsigned char *)rowname, &sel_flag, &r_pos);
		if (!column_found && column_name && *column_name &&
			!RISfrm_wildcard_strcmp(column_name, rowname))
		{
			column_found = 1;
			FIfld_set_select(ti_form, TI_COLUMNS_MCF, row, 0, 1);
			FIfld_set_select(ti_form, TI_COLUMNS_MCF, row, 1, 1);
			FIfld_set_select(ti_form, TI_COLUMNS_MCF, row, 2, 1);
			FIfld_set_select(ti_form, TI_COLUMNS_MCF, row, 3, 1);
			FIfld_set_select(ti_form, TI_COLUMNS_MCF, row, 4, 1);
   			FIfld_get_row_offset(ti_form, TI_COLUMNS_MCF, &offset);
   			if (row < offset || row >= offset + num_vis_rows)
   			{
				FIfld_set_active_row(ti_form, TI_COLUMNS_MCF, row, 0);
   			}
		}
		else if (sel_flag)
		{
			FIfld_set_select(ti_form, TI_COLUMNS_MCF, row, 0, 0);
			FIfld_set_select(ti_form, TI_COLUMNS_MCF, row, 1, 0);
			FIfld_set_select(ti_form, TI_COLUMNS_MCF, row, 2, 0);
			FIfld_set_select(ti_form, TI_COLUMNS_MCF, row, 3, 0);
			FIfld_set_select(ti_form, TI_COLUMNS_MCF, row, 4, 0);
		}
	}
	if (column_name && *column_name && !column_found)
	{
		sprintf(ti_msg->str, MSG(RISUTL_I_UNKNOWN_COLUMN), column_name);
	}
}


/******************************************************************************/

static void clear_columns_mcf()
{
	FRM_DBG(("clear_columns_mcf()\n"));
	RISfrm_clear_multi_row_field(ti_form, TI_COLUMNS_MCF);
}

/*******************************************************************************
******************** TI_TABLE_NAME_FIELD **************************************
*******************************************************************************/

static char *get_table_name_field()
{
	static	 char	table_name[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_table_name_field()\n"));
	RISfrm_get_field(ti_form, TI_TABLE_NAME_FIELD, RIS_MAX_ID_SIZE, table_name);
	return table_name[0] ? table_name : NULL;
}

/******************************************************************************/

static void process_table_name_field()
{
	char			*table_name;
	RISfrm_object	*object;

	FRM_DBG(("process_table_name_field()\n"));

	table_name = get_table_name_field();
	if (!RISfrm_field_changed(table_name, initial_table_name))
	{
		return;
	}
	object = RISfrm_get_table_object(table_name, RIS_NAME, update_msg_field,
		clear_msg_field);
	if (object == NULL)
	{
		if (table_name)
		{
			sprintf(ti_msg->str, MSG(RISUTL_I_UNKNOWN_TABLE), table_name);
		}
	}
	clear_search_column_field();

	if (RISfrm_dd_form_displayed())
	{
		RISfrm_update_dd_objects_mcf(object);
	}

	update_ti_form(object);
}

/******************************************************************************/

static void update_table_name_field(
	char	*table_name)
{
	FRM_DBG(("update_table_name_field(table_name:<%s>)\n",table_name));

	FIfld_set_text(ti_form, TI_TABLE_NAME_FIELD, 0, 0, table_name, 0);
	strcpy(initial_table_name, table_name);
}

/******************************************************************************/

static void clear_table_name_field()
{
	FRM_DBG(("clear_table_name_field()\n"));

	FIfld_set_text(ti_form, TI_TABLE_NAME_FIELD, 0, 0, "", 0);
	strcpy(initial_table_name, "");
}

/*******************************************************************************
******************** TI_DBMSTAB_NAME_FIELD *************************************
*******************************************************************************/

static void update_dbms_table_name_field(
	char	*dbms_table_name)
{
	FRM_DBG(("update_dbms_table_name_field(dbms_table_name:<%s>)\n",
		dbms_table_name));

	FIfld_set_text(ti_form, TI_DBMSTAB_NAME_FIELD, 0, 0, dbms_table_name, 0);
}

/******************************************************************************/

static void clear_dbms_table_name_field()
{
	FRM_DBG(("clear_dbms_table_name_field()\n"));

	FIfld_set_text(ti_form, TI_DBMSTAB_NAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** TI_SEARCH_COLUMN_FIELD ************************************
*******************************************************************************/

static char *get_search_column_field()
{
	static	 char	search_column[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_search_column_field()\n"));
	RISfrm_get_field(ti_form, TI_SEARCH_COLUMN_FIELD, RIS_MAX_ID_SIZE,
		search_column);
	return search_column[0] ? search_column : NULL;
}

/******************************************************************************/

static void process_search_column_field()
{
	FRM_DBG(("process_search_column_field()\n"));

	update_columns_mcf(get_search_column_field());
}

/******************************************************************************/

static void update_search_column_field(
	char	*search_column)
{
	FRM_DBG(("update_search_column_field(search_column:<%s>)\n",search_column));

	FIfld_set_text(ti_form, TI_SEARCH_COLUMN_FIELD, 0, 0, search_column, 0);
}

/******************************************************************************/

static void clear_search_column_field()
{
	FRM_DBG(("clear_search_column_field()\n"));

	FIfld_set_text(ti_form, TI_SEARCH_COLUMN_FIELD, 0, 0, "", 0);
}

/******************************************************************************/

static void disable_search_column_field()
{
	FRM_DBG(("disable_search_column_field()\n"));

	FIg_disable(ti_form, TI_SEARCH_COLUMN_FIELD);
}

/******************************************************************************/

static void enable_search_column_field()
{
	FRM_DBG(("enable_search_column_field()\n"));

	FIg_enable(ti_form, TI_SEARCH_COLUMN_FIELD);
}

/*******************************************************************************
******************** TI_DISABLE_GROUP ******************************************
*******************************************************************************/

extern void RISfrm_disable_ti_form()
{
	FRM_DBG(("disable_ti_form()\n"));

	VALID_FORM_CHECK(ti_form);

	FIg_disable(ti_form, TI_TABLE_NAME_FIELD);
	FIg_disable(ti_form, TI_DBMSTAB_NAME_FIELD);
	FIg_disable(ti_form, TI_SEARCH_COLUMN_FIELD);
	FIg_disable(ti_form, TI_COLUMNS_MCF);
}

/******************************************************************************/

extern void RISfrm_enable_ti_form()
{
	FRM_DBG(("enable_ti_form()\n"));

	VALID_FORM_CHECK(ti_form);

	FIg_enable(ti_form, TI_TABLE_NAME_FIELD);
	FIg_enable(ti_form, TI_DBMSTAB_NAME_FIELD);
	FIg_enable(ti_form, TI_COLUMNS_MCF);
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));

	RISfrm_erase_ti_form();
	if (RISfrm_dd_form_displayed())
	{
		RISfrm_clear_dd_table_info_button();
	}
}

/*******************************************************************************
******************** TI FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_ti_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,					process_cancel_button		},
		{	TI_TABLE_NAME_FIELD,		process_table_name_field	},
		{	TI_SEARCH_COLUMN_FIELD,		process_search_column_field	},
		{	TI_COLUMNS_MCF,				process_columns_mcf			},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_ti_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(ti_form);

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

extern void RISfrm_process_ti_form_initial(
	int g_label)
{
	FRM_DBG(("RISfrm_process_ti_form_initial(g_label:%d)\n", g_label));
	switch(g_label)
	{
		case TI_TABLE_NAME_FIELD:
			RISfrm_get_field(ti_form, TI_TABLE_NAME_FIELD, RIS_MAX_ID_SIZE,
				initial_table_name);
			break;
	}
}

/******************************************************************************/

extern void RISfrm_call_user_init_ti_form()
{
	FRM_DBG(("RISfrm_call_user_init_ti_form()\n"));

	VALID_FORM_CHECK(ti_form);

	if (RISfrm_user_init_ti_form)
	{
		FRM_DBG(("calling RISfrm_user_init_ti_form()\n"));
		RISfrm_user_init_ti_form(ti_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_ti_form(
	int	called_by_user,
	int	disable_flag)
{
	int		sts;
	char	def_schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("RISfrm_display_ti_form(called_by_user:%d disable_flag:%d)\n",
		called_by_user, disable_flag));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!ti_form)
	{
		sts = FIf_new(TI_FORM, TI_FORM_FILE, RISfrm_notification_routine,
			&ti_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_TI_FORM, sts);
			return RIS_forms_error.error;
		}

		FIf_set_initial_notification_routine(ti_form,
			RISfrm_initial_notification_routine);

#if defined(WIN32)
		FIf_SetDefaultButton(ti_form, FI_CANCEL);
		FIg_set_text(ti_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));
#endif

	}

	ti_msg->str[0] = 0;
	ti_msg->count = 0;
	ti_msg->msg_fld_label = TI_MSG_FIELD;
	ti_msg->fp = ti_form;

	if (!RISfrm_ti_form_displayed())
	{
		DISPLAY_HELP_BUTTON(ti_form);

		disable_search_column_field();

		if (disable_flag)
		{
			RISfrm_disable_ti_form();
		}
		else
		{
			RISfrm_enable_ti_form();
		}

		if (called_by_user)
		{
			RISget_default_schema_name(def_schname);
			if (!def_schname[0])
			{
				RISfrm_form_errhandle(RISUTL_E_FORM_NO_SCHEMA, 0);
				return RIS_forms_error.error;
			}
			RISfrm_object_list_up_to_date = 0;
			RISfrm_call_user_init_ti_form();
		}

		sts = FIf_display (ti_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_TI_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

static void update_ti_form(
	RISfrm_object *object)
{
	/*
	**	This routine is called internally when ever the table_name changes.
	**	It should update every thing on the form that needs updating
	**	except the tabname_field()
	*/

	FRM_DBG(("update_ti_form(object: 0x%x)\n", object));

	if (object && object->type == TABLE_CHAR)
	{
		update_dbms_table_name_field(object->dbms_name);
		load_columns_mcf(object->name);
		enable_search_column_field();
		clear_search_column_field();
	}
	else
	{
		clear_dbms_table_name_field();
		clear_columns_mcf();
		clear_search_column_field();
		disable_search_column_field();
	}
}

/******************************************************************************/

extern void RISfrm_update_ti_form(
	RISfrm_object *object)
{
	/*
	**	This routine is called by other forms to update this form.  It should
	**	update the table_name_field, then call the internal update function.
	*/
	FRM_DBG(("RISfrm_update_ti_form(object: 0x%x)\n", object));

	VALID_FORM_CHECK(ti_form);

	if (object && object->type == TABLE_CHAR)
	{
		update_table_name_field(object->name);
	}
	else
	{
		clear_table_name_field();
	}

	update_ti_form(object);
}

/******************************************************************************/

extern void RISfrm_clear_ti_form()
{
	FRM_DBG(("RISfrm_clear_ti_form()\n"));

	VALID_FORM_CHECK(ti_form);

	clear_table_name_field();
	clear_dbms_table_name_field();
	clear_columns_mcf();
	clear_search_column_field();
	disable_search_column_field();
}

/*******************************************************************************
************** USER CALLABLE FUNCTIONS *****************************************
*******************************************************************************/

extern int RISfrm_ti_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_ti_form_displayed()\n"));

	if (!ti_form)
	{
		return(0);
	}

	FIf_is_displayed(ti_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_ti_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_ti_form()\n"));

	if (RISfrm_ti_form_displayed())
	{
		sts = FIf_erase(ti_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_TI_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_ti_form();
		if (RISfrm_dd_form_displayed())
			RISfrm_clear_dd_table_info_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER CALLABLE FUNCTIONS *****************************************
*******************************************************************************/

extern int RISAPI RISXfrm_table_info_form_displayed()
{
	return RISfrm_ti_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_table_info_form()
{
	return RISfrm_display_ti_form(CALLED_BY_USER, DISPLAY_ENABLED);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_table_info_form()
{
	return RISfrm_erase_ti_form();
}

/******************************************************************************/
