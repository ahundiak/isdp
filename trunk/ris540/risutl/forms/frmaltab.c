/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:									frmcrtab.c
**	AUTHORS:								Terry McIntyre
**	CREATION DATE:							11/90
**	ABSTRACT:
**	
**		The code to process the schema info form.
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include "ristypes.h"
#include "forms.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmaltab_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "frmaltab.prt"
#include "frmcolmn.prt"
#include "frmdadef.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmntfy.prt"
#include "frmobj.prt"
#include "frmutil.prt"
#include "fi.prt"
#include "ris.prt"
#include "sys.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif

/*
**	DEFINES
*/
#define CHECK_ALL_ROWS		-1
#define TYPE_COUNT			9

/*
**	VARIABLES
*/
static	 Form		at_form = 0;
static	RISfrm_msg	*at_msg = &RISfrm_msgs[AT_FORM_MSG];

static struct
{
	int type;
	int	label;
} type_check_info[TYPE_COUNT] = 
{
	{	RIS_SMALLINT,	AT_SMALLINT_CHECK	},
	{	RIS_INTEGER,	AT_INTEGER_CHECK	},
	{	RIS_REAL,		AT_REAL_CHECK		},
	{	RIS_DOUBLE,		AT_DOUBLE_CHECK		},
	{	RIS_CHARACTER,	AT_CHARACTER_CHECK	},
	{	RIS_DECIMAL,	AT_DECIMAL_CHECK	},
	{	RIS_DATETIME,	AT_TIMESTAMP_CHECK	},
	{	RIS_BLOB,		AT_BLOB_CHECK		},
	{	RIS_TEXT,		AT_TEXT_CHECK		},
};

static   char		initial_table_name[RIS_MAX_ID_SIZE] = "";

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** AT_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(at_form, AT_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(at_form, AT_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** AT_COLUMNS_MCF ********************************************
*******************************************************************************/

static void clear_columns_mcf()
{
	FRM_DBG(("clear_columns_mcf()\n"));
	RISfrm_clear_multi_row_field(at_form, AT_COLUMNS_MCF);
}

/******************************************************************************/

static void load_columns_mcf(
	char	*table_name)
{
	FRM_DBG(("load_columns_mcf(table_name:<%s>)\n", table_name));

	clear_columns_mcf();
	update_msg_field(MSG(RISUTL_I_READING_DICTIONARY_TABLES));
	RISfrm_load_columns_mcf(table_name, at_form, AT_COLUMNS_MCF);
	if (RIS_forms_error.error && RISfrm_report_error())
	{
		switch(RIS_forms_error.error)
		{
		}
	}
	clear_msg_field();
}

/*******************************************************************************
******************** AT_TABLE_NAME_FIELD **************************************
*******************************************************************************/

static char *get_table_name_field()
{
	static	 char	table_name[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_table_name_field()\n"));
	RISfrm_get_field(at_form, AT_TABLE_NAME_FIELD, RIS_MAX_ID_SIZE, table_name);
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
			sprintf(at_msg->str, MSG(RISUTL_I_UNKNOWN_TABLE), table_name);
		}
	}

	if (RISfrm_dd_form_displayed())
	{
		RISfrm_update_dd_objects_mcf(object);
	}

	update_at_form(object);
}

/******************************************************************************/

static void update_table_name_field(
	char	*table_name)
{
	FRM_DBG(("update_table_name_field(table_name:<%s>)\n",table_name));
	FIfld_set_text(at_form, AT_TABLE_NAME_FIELD, 0, 0, table_name, 0);
	strcpy(initial_table_name, table_name);
}

/******************************************************************************/

static void clear_table_name_field()
{
	FRM_DBG(("clear_table_name_field()\n"));
	FIfld_set_text(at_form, AT_TABLE_NAME_FIELD, 0, 0, "", 0);
	strcpy(initial_table_name, "");
}

/*******************************************************************************
******************** AT_COLUMN_NAME_FIELD **************************************
*******************************************************************************/

static int duplicate_column_name(
	char	*column_name,
	int		exception_row)
{
	int		i;
	int		num_rows;
	int		sel_flag;
	int		r_pos;
	unsigned char	row_column_name[RIS_MAX_ID_SIZE];

	FRM_DBG(("duplicate_column_name(column_name:<%s> exception_row:%d)\n",
		column_name, exception_row));

	FIfld_get_num_rows(at_form, AT_COLUMNS_MCF, &num_rows);
	for (i = 0; i < num_rows; i++)
	{
		if (i == exception_row) continue;

		FIfld_get_text(at_form, AT_COLUMNS_MCF, i, 1, RIS_MAX_ID_SIZE,
			row_column_name, &sel_flag, &r_pos);

		if (!strcmp(column_name, (char *)row_column_name))
		{
			sprintf(at_msg->str, MSG(RISUTL_I_COLUMN_ALREADY_DEFINED),
				column_name);
			at_msg->label[at_msg->count++] = AT_COLUMN_NAME_TEXT;
			at_msg->label[at_msg->count++] = AT_COLUMN_NAME_FIELD;
			FIfld_pos_cursor(at_form, AT_COLUMN_NAME_FIELD, 0, 0, 0, 0, 0, 0);
			return 1;
		}
	}
	return 0;
}

/******************************************************************************/

static char *get_column_name_field()
{
	static	 char	name[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_column_name_field()\n"));

	RISfrm_get_field(at_form, AT_COLUMN_NAME_FIELD, RIS_MAX_ID_SIZE, name);
	return name[0] ? name : NULL;
}

/******************************************************************************/

static void process_column_name_field()
{
	char *column_name;

	if ((column_name = get_column_name_field()) != NULL)
	{
#ifdef MAYBE
		if (get_dbms_column_name_field() == NULL)
		{
#endif
			update_dbms_column_name_field(column_name);
#ifdef MAYBE
		}
#endif
	}
}

/******************************************************************************/

static void clear_column_name_field()
{
	FRM_DBG(("clear_column_name_field()\n"));
	FIfld_set_text(at_form, AT_COLUMN_NAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** AT_DBMSCOL_NAME_FIELD *************************************
*******************************************************************************/

static char *get_dbms_column_name_field()
{
	static	 char			name[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_dbms_column_name_field()\n"));
	RISfrm_get_field(at_form, AT_DBMSCOL_NAME_FIELD, RIS_MAX_ID_SIZE, name);
	return name[0] ? name : NULL;
}

/******************************************************************************/

static void process_dbms_column_name_field()
{
	char *column_name;

	if (get_dbms_column_name_field() == NULL)
	{
		if ((column_name = get_column_name_field()) != NULL)
		{
			update_dbms_column_name_field(column_name);
		}
	}
}

/******************************************************************************/

static void update_dbms_column_name_field(
	char	*dbms_column_name)
{
	FRM_DBG(("update_dbms_column_name_field(dbms_column_name:<%s>)\n",
		dbms_column_name));
	FIfld_set_text(at_form, AT_DBMSCOL_NAME_FIELD, 0, 0, dbms_column_name, 0);
}

/******************************************************************************/

static void clear_dbms_column_name_field()
{
	FRM_DBG(("clear_dbms_column_name_field()\n"));
	FIfld_set_text(at_form, AT_DBMSCOL_NAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** AT_LENGTH_FIELD *******************************************
*******************************************************************************/

static void clear_length_field()
{
	FRM_DBG(("clear_length_field()\n"));
	FIfld_set_text(at_form, AT_LENGTH_FIELD, 0, 0, "", 0);
}

/******************************************************************************/

static int get_length_field()
{
	int		sel_flag;
	int		r_pos;
	double	length;

	FRM_DBG(("get_length_field()\n"));

	FIfld_get_value(at_form, AT_LENGTH_FIELD, 0, 0, &length, &sel_flag, &r_pos);
	return (unsigned int)length;
}

/******************************************************************************/

static void update_length_field(
        unsigned int	length)
{
	FRM_DBG(("update_length_field(length:%d)\n",length));
	if (length == 0)
		clear_length_field();
	else
		FIfld_set_value(at_form, AT_LENGTH_FIELD, 0, 0, (double)length, 0);
}

/*******************************************************************************
******************** AT_SCALE_FIELD *******************************************
*******************************************************************************/

static void clear_scale_field()
{
	FRM_DBG(("clear_scale_field()\n"));
	FIfld_set_text(at_form, AT_SCALE_FIELD, 0, 0, "", 0);
}

/******************************************************************************/

static int get_scale_field()
{
	int		sel_flag;
	int		r_pos;
	double	scale;

	FRM_DBG(("get_scale_field()\n"));

	FIfld_get_value(at_form, AT_SCALE_FIELD, 0, 0, &scale, &sel_flag, &r_pos);
	return (int)scale;
}

/******************************************************************************/

static void update_scale_field(
	int	scale)
{
	FRM_DBG(("update_scale_field(scale:%d)\n",scale));
	if (scale == -1)
		clear_scale_field();
	else
		FIfld_set_value(at_form, AT_SCALE_FIELD, 0, 0, (double)scale, 0);
}

/*******************************************************************************
******************** AT_TYPE_CHECKS ********************************************
*******************************************************************************/

static int get_type_check()
{
	int	i;
	int	state;

	FRM_DBG(("get_type_check()\n"));

	for (i = 0; i < TYPE_COUNT; i++)
	{
		FIg_get_state(at_form, type_check_info[i].label, &state);
		if (state) return type_check_info[i].type;
	}

	return RIS_UNKNOWN_TYPE;
}

/******************************************************************************/

static void process_type_check()
{
	int	type;

	FRM_DBG(("process_type_check()\n"));

	type = get_type_check();
	switch (type)
	{
		case RIS_CHARACTER:
			FIg_enable(at_form, AT_LENGTH_FIELD);
			FIg_disable(at_form, AT_SCALE_FIELD);
			update_length_field(0);
			clear_scale_field();
		break;

		case RIS_BLOB:
			FIg_enable(at_form, AT_LENGTH_FIELD);
			FIg_disable(at_form, AT_SCALE_FIELD);
			update_length_field(0);
			clear_scale_field();
		break;

		case RIS_TEXT:
			FIg_enable(at_form, AT_LENGTH_FIELD);
			FIg_disable(at_form, AT_SCALE_FIELD);
			update_length_field(0);
			clear_scale_field();
		break;

		case RIS_DECIMAL:
			FIg_enable(at_form, AT_LENGTH_FIELD);
			FIg_enable(at_form, AT_SCALE_FIELD);
			update_length_field(0);
			update_scale_field(0);
		break;

		default:
			FIg_disable(at_form, AT_LENGTH_FIELD);
			FIg_disable(at_form, AT_SCALE_FIELD);
			clear_length_field();
			clear_scale_field();
		break;
	}
}

/******************************************************************************/

static void update_type_check(
	int		type)
{
	int	i;

	FRM_DBG(("update_type_field(type:%d)\n",type));

	for (i = 0; i < TYPE_COUNT; i++)
	{
		if (type == type_check_info[i].type)
			FIg_set_state(at_form, type_check_info[i].label, 1);
		else
			FIg_set_state(at_form, type_check_info[i].label, 0);
	}
}

/******************************************************************************/

static void clear_type_check()
{
	FRM_DBG(("clear_type_check()\n"));
	update_type_check(0);
}

/*******************************************************************************
******************** AT_NULLS_TOGGLE *******************************************
*******************************************************************************/

static int get_nulls_toggle()
{
	int	state;

	FRM_DBG(("get_nulls_toggle()\n"));
	FIg_get_state(at_form, AT_NULLS_TOGGLE, &state);
	return state;
}

/******************************************************************************/

static void update_nulls_toggle(
	int	nulls_allowed)
{
	FRM_DBG(("update_nulls_field(nulls_allowed:%d)\n",nulls_allowed));
	FIg_set_state(at_form, AT_NULLS_TOGGLE, nulls_allowed);
}

/******************************************************************************/

static void clear_nulls_toggle()
{
	FRM_DBG(("clear_nulls_toggle()\n"));
	update_nulls_toggle(1);
}

/*******************************************************************************
******************** AT_COLUMN_GROUP *******************************************
*******************************************************************************/

static int get_column_group(
	char	**namep,
	char	**dbmsnamep,
	char	**typep,
	int		*nullp)
{
	int				type;
	unsigned int				length;
	int				scale;
	char			ristypestr[16];
	static	 char	typestr[16];

	/*
	**	Returns 0 if successful, otherwise
	**	returns 1
	*/

	FRM_DBG(("get_column_group(namep:0x%x typep:0x%x nullp:0x%x)\n",
		namep, typep, nullp));

	/*
	**	column name
	*/
	if ((*namep = get_column_name_field()) == NULL)
	{
		strcpy(at_msg->str, MSG(RISUTL_I_COLNAME_MUST_BE_SPEC));
		at_msg->label[at_msg->count++] = AT_COLUMN_NAME_TEXT;
		at_msg->label[at_msg->count++] = AT_COLUMN_NAME_FIELD;
		FIfld_pos_cursor(at_form, AT_COLUMN_NAME_FIELD, 0, 0, 0, 0, 0, 0);
		return 1;
	}

	/*
	**	dbms column name
	*/
	*dbmsnamep = get_dbms_column_name_field();

	/*
	**	column type
	*/
	if ((type = get_type_check()) == RIS_UNKNOWN_TYPE)
	{
		strcpy(at_msg->str, MSG(RISUTL_I_COLTYPE_MUST_BE_SPEC));
		at_msg->label[at_msg->count++] = AT_TYPE_GROUP;
		return 1;
	}
	switch(type)
	{
		case RIS_DECIMAL:
			length = get_length_field();
			scale = get_scale_field();
			RISget_ris_sqltype_string(ristypestr, type);
			sprintf(typestr, "%s(%d,%d)", ristypestr, length, scale);
			break;

		case RIS_CHARACTER:
			length = get_length_field();
			if (length == 0)
            {
                at_msg->label[at_msg->count++] = AT_LENGTH_FIELD;
                strcpy(at_msg->str, MSG(RISUTL_I_DTYPE_ENTER_LEN));
                return 1;
            }
			RISget_ris_sqltype_string(ristypestr, type);
			sprintf(typestr, "%s(%d)", ristypestr, length);
			break;

		case RIS_BLOB:
			length = get_length_field();
			if (length == 0)
            {
                at_msg->label[at_msg->count++] = AT_LENGTH_FIELD ;
                strcpy(at_msg->str, MSG(RISUTL_I_DTYPE_ENTER_LEN));
				return 1;
			}
			RISget_ris_sqltype_string(ristypestr, type);
			sprintf(typestr, "%s(%d)", ristypestr, length);
			break;

		case RIS_TEXT:
			length = get_length_field();
			if (length == 0)
            {
                at_msg->label[at_msg->count++] = AT_LENGTH_FIELD;
                strcpy(at_msg->str, MSG(RISUTL_I_DTYPE_ENTER_LEN));
				return 1;
			}
			RISget_ris_sqltype_string(ristypestr, type);
			sprintf(typestr, "%s(%d)", ristypestr, length);
			break;

		case RIS_DATETIME:
			sprintf(typestr, TIMESTAMP_STRING);
			break;

		default:
			RISget_ris_sqltype_string(typestr, type);
			break;
	}
	*typep = typestr;

	/*
	**	nulls allowed
	*/
	*nullp = get_nulls_toggle();

	return 0;
}

/******************************************************************************/

static void clear_column_group()
{
	FRM_DBG(("clear_column_group()\n"));

	clear_column_name_field();
	clear_dbms_column_name_field();
	clear_type_check();
	clear_length_field();
	clear_scale_field();
	clear_nulls_toggle();
}

/*******************************************************************************
******************** AT_DISABLE_GROUP ******************************************
*******************************************************************************/

extern void RISfrm_disable_at_form()
{
	FRM_DBG(("disable_at_form()\n"));

	VALID_FORM_CHECK(at_form);

	FIg_disable(at_form, FI_RESET);
	FIg_disable(at_form, FI_EXECUTE);
	FIg_disable(at_form, AT_DISABLE_GROUP);
	FIg_disable(at_form, AT_LENGTH_FIELD);
	FIg_disable(at_form, AT_SCALE_FIELD);
}

/******************************************************************************/

extern void RISfrm_enable_at_form()
{
	FRM_DBG(("enable_at_form()\n"));

	VALID_FORM_CHECK(at_form);

	FIg_enable(at_form, FI_RESET);
	FIg_enable(at_form, FI_EXECUTE);
	FIg_enable(at_form, AT_DISABLE_GROUP);
	FIf_set_start_seq(at_form, AT_TABLE_NAME_FIELD);
}

/*******************************************************************************
******************** EXECUTE_BUTTON ********************************************
*******************************************************************************/

static void process_execute_button()
{
	char			*table_name;
	char			*column_name;
	char			*dbms_column_name = NULL;
	char			*typestr;
	char			*nullstr;
	int				nulls;
	char			*cmd;
	char			alter_table_command[256];
	int				row;
	int				num_rows;
	double			position;
	RISfrm_object	*object;

	FRM_DBG(("process_execute_button()\n"));

	cmd = alter_table_command;

	if ((table_name = get_table_name_field()) == NULL)
	{
		at_msg->label[at_msg->count++] = AT_TABLE_NAME_TEXT;
		at_msg->label[at_msg->count++] = AT_TABLE_NAME_FIELD;
		strcpy(at_msg->str, MSG(RISUTL_I_TABNAME_MUST_BE_SPEC));
		FIfld_pos_cursor(at_form, AT_TABLE_NAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}
	object = RISfrm_get_table_object(table_name, RIS_NAME, update_msg_field,
		clear_msg_field);
	if (object == NULL)
	{
		at_msg->label[at_msg->count++] = AT_TABLE_NAME_TEXT;
		at_msg->label[at_msg->count++] = AT_TABLE_NAME_FIELD;
		sprintf(at_msg->str, MSG(RISUTL_I_UNKNOWN_TABLE), table_name);
		FIfld_pos_cursor(at_form, AT_TABLE_NAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}

	cmd += sprintf(cmd, "ALTER TABLE %s ADD ", table_name);

	if (get_column_group(&column_name, &dbms_column_name, &typestr, &nulls))
		return;

	if (duplicate_column_name(column_name, CHECK_ALL_ROWS))
		return;

	cmd += sprintf(cmd, "%s %s", column_name, typestr);
	if (!nulls)
	{
		cmd += sprintf(cmd, " NOT NULL");
		nullstr = "NO";
	}
	else
	{
		nullstr = "YES";
	}

	if (dbms_column_name)
	{
		cmd += sprintf(cmd, " EXTERN %s", dbms_column_name);
	}

	FRM_DBG(("%s\n",alter_table_command));

	if (RISfrm_user_exec_at_form &&
		RISfrm_user_exec_at_form(at_form, alter_table_command) == 0)
			return;

	strcpy(at_msg->str, MSG(RISUTL_I_ALTERING_TABLE));
	update_msg_field(at_msg->str);
	RISfrm_execute_command(alter_table_command);
	at_msg->str[0] = 0;
	clear_msg_field();

	if (SQLCODE)
	{
		RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
		if (RISfrm_report_error() == 0) return;

		switch(SQLCODE)
		{
		}
		return;
	}
	strcpy(at_msg->str, MSG(RISUTL_I_ALTER_TABLE_SUCCESS));
	update_msg_field(at_msg->str);


	/*
	**	append the column
	*/
	FIfld_get_num_rows(at_form, AT_COLUMNS_MCF, &num_rows);
	num_rows++;
	FIfld_set_num_rows(at_form, AT_COLUMNS_MCF, num_rows);

	row = num_rows - 1;
	position = num_rows;
	FIfld_set_value(at_form, AT_COLUMNS_MCF, row, 0, position, 0);
	FIfld_set_text(at_form, AT_COLUMNS_MCF, row, 1, column_name, 0);
	FIfld_set_text(at_form, AT_COLUMNS_MCF, row, 2, dbms_column_name, 0);
	FIfld_set_text(at_form, AT_COLUMNS_MCF, row, 3, typestr, 0);
	FIfld_set_text(at_form, AT_COLUMNS_MCF, row, 4, nullstr, 0);

	if (row > 8) FIfld_set_active_row(at_form, CT_COLUMNS_MCF, row, 8);
}
/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));

	RISfrm_clear_at_form();
	if (RISfrm_dd_form_displayed())
		RISfrm_update_dd_objects_mcf((RISfrm_object *)0);
	DISPLAY_HELP_BUTTON(at_form);
	RISfrm_call_user_init_at_form();
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));

	RISfrm_erase_at_form();
	if (RISfrm_dd_form_displayed())
		RISfrm_clear_dd_alter_table_button();
}

/*******************************************************************************
******************** TI FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_at_form(
	int g_label)
{
	int	i;

	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_EXECUTE,					process_execute_button			},
		{	FI_RESET,					process_reset_button			},
		{	FI_CANCEL,					process_cancel_button			},
		{	AT_TABLE_NAME_FIELD,		process_table_name_field		},
		{	AT_COLUMN_NAME_FIELD,		process_column_name_field		},
		{	AT_DBMSCOL_NAME_FIELD,		process_dbms_column_name_field	},
		{	AT_SMALLINT_CHECK,			process_type_check				},
		{	AT_INTEGER_CHECK,			process_type_check				},
		{	AT_REAL_CHECK,				process_type_check				},
		{	AT_DOUBLE_CHECK,			process_type_check				},
		{	AT_CHARACTER_CHECK,			process_type_check				},
		{	AT_DECIMAL_CHECK,			process_type_check				},
		{	AT_TIMESTAMP_CHECK,			process_type_check				},
		{	AT_BLOB_CHECK,			process_type_check				},
		{	AT_TEXT_CHECK,			process_type_check				},
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_at_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(at_form);

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

extern void RISfrm_process_at_form_initial(
	int g_label)
{
	FRM_DBG(("RISfrm_process_at_form_initial(g_label:%d)\n", g_label));
	switch(g_label)
	{
		case AT_TABLE_NAME_FIELD:
			RISfrm_get_field(at_form, AT_TABLE_NAME_FIELD, RIS_MAX_ID_SIZE,
				initial_table_name);
			break;
	}
}

/******************************************************************************/

extern void RISfrm_call_user_init_at_form()
{
	FRM_DBG(("RISfrm_call_user_init_at_form()\n"));

	VALID_FORM_CHECK(at_form);

	if (RISfrm_user_init_at_form)
	{
		FRM_DBG(("calling RISfrm_user_init_at_form()\n"));
		RISfrm_user_init_at_form(at_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_at_form(
	int	called_by_user,
	int	disable_flag)
{
	int		sts;
	char	def_schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("RISfrm_display_at_form(called_by_user:%d disable_flag:%d)\n",
		called_by_user, disable_flag));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!at_form)
	{
		sts = FIf_new(AT_FORM, AT_FORM_FILE, RISfrm_notification_routine,
			&at_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_AT_FORM, sts);
			return RIS_forms_error.error;
		}

		FIf_set_initial_notification_routine(at_form,
			RISfrm_initial_notification_routine);
		FIgrp_add_to_group(at_form, AT_TYPE_GROUP, AT_DISABLE_GROUP);

#if defined(WIN32)
		FIf_SetDefaultButton(at_form, FI_EXECUTE);
		FIg_set_text(at_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));

#endif
	}

	at_msg->str[0] = 0;
	at_msg->count = 0;
	at_msg->msg_fld_label = AT_MSG_FIELD;
	at_msg->fp = at_form;

	if (!RISfrm_at_form_displayed())
	{
		DISPLAY_HELP_BUTTON(at_form);

		if (disable_flag)
		{
			RISfrm_disable_at_form();
		}
		else
		{
			RISfrm_enable_at_form();
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
			RISfrm_call_user_init_at_form();
		}

		sts = FIf_display (at_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_AT_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

static void update_at_form(
	RISfrm_object *object)
{
	/*
	**	This routine is called internally when ever the table_name changes.
	**	It should update every thing on the form that needs updating
	**	except the table_name_field()
	*/

	FRM_DBG(("update_at_form(object: 0x%x)\n", object));

	if (!object || object->type != TABLE_CHAR)
	{
		clear_column_group();
		clear_columns_mcf();
	}
	else
	{
		clear_column_group();
		load_columns_mcf(object->name);
	}
}

/******************************************************************************/

extern void RISfrm_update_at_form(
	RISfrm_object *object)
{
	/*
	**	This routine is called by other forms to update this form.  It should
	**	update the table_name field, then call the internal update function.
	*/

	FRM_DBG(("RISfrm_update_at_form(object: 0x%x)\n", object));

	VALID_FORM_CHECK(at_form);

	if (!object || object->type != TABLE_CHAR)
	{
		clear_table_name_field();
	}
	else
	{
		update_table_name_field(object->name);
	}

	update_at_form(object);
}

/******************************************************************************/

extern void RISfrm_clear_at_form()
{
	FRM_DBG(("RISfrm_clear_at_form()\n"));

	VALID_FORM_CHECK(at_form);

	clear_columns_mcf();
	clear_table_name_field();
	clear_column_group();
}

/******************************************************************************/

extern int RISfrm_at_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_at_form_displayed()\n"));

	if (!at_form)
	{
		return(0);
	}

	FIf_is_displayed(at_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_at_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_at_form()\n"));
	if (RISfrm_at_form_displayed())
	{
		sts = FIf_erase(at_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_AT_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_at_form();
		if (RISfrm_dd_form_displayed())
			RISfrm_clear_dd_alter_table_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER CALLABLE FUNCTIONS *****************************************
*******************************************************************************/

extern int RISAPI RISXfrm_alter_table_form_displayed()
{
	return RISfrm_at_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_alter_table_form()
{
	return(RISfrm_display_at_form(CALLED_BY_USER, DISPLAY_ENABLED));
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_alter_table_form()
{
	return RISfrm_erase_at_form();
}

/******************************************************************************/
