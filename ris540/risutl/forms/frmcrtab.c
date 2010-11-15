/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							frmcrtab.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/90
**	ABSTRACT:
**	
**		The code to process the schema info form.
**	
**	REVISION HISTORY:
**
**	Added support for INTERNATIONALIZATION.  Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include "ristypes.h"
#include "forms.h"
#include "ris_err.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmcrtab_c
#include "comdebug.prt"
#include "comstcmi.prt"
#include "comumsg.prt"
#include "fi.prt"
#include "frmcolmn.prt"
#include "frmcrtab.prt"
#include "frmdadef.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmntfy.prt"
#include "frmobj.prt"
#include "frmutil.prt"
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

#define NO_ACTION		-1
#define INSERT_COLUMN	0
#define DROP_COLUMN		1
#define MODIFY_COLUMN	2
#define ACTION_COUNT	3

#define VALID_ACTION(action) ((action) >= 0 && (action) < ACTION_COUNT)

/*
**	VARIABLES
*/
static	 Form		ct_form = 0;
static	RISfrm_msg	*ct_msg = &RISfrm_msgs[CT_FORM_MSG];

static struct
{
	int type;
	int	label;
} type_check_info[TYPE_COUNT] = 
{
	{	RIS_SMALLINT,	CT_SMALLINT_CHECK	},
	{	RIS_INTEGER,	CT_INTEGER_CHECK	},
	{	RIS_REAL,		CT_REAL_CHECK		},
	{	RIS_DOUBLE,		CT_DOUBLE_CHECK		},
	{	RIS_CHARACTER,	CT_CHARACTER_CHECK	},
	{	RIS_DECIMAL,	CT_DECIMAL_CHECK	},
	{	RIS_DATETIME,	CT_TIMESTAMP_CHECK	},
	{	RIS_BLOB,		CT_BLOB_CHECK		},
	{	RIS_TEXT,		CT_TEXT_CHECK		},
};

static struct
{
	int button;
} action_info[ACTION_COUNT] =
{
	{	CT_INSERT_COLUMN_BUTTON		},
	{	CT_DROP_COLUMN_BUTTON		},
	{	CT_MODIFY_COLUMN_BUTTON		},
};

static  char initial_table_name[RIS_MAX_ID_SIZE] = "";

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** CT_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(ct_form, CT_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(ct_form, CT_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** ACTION ****************************************************
*******************************************************************************/

static int get_action()
{
	int	i;
	int	state;

	FRM_DBG(("get_action()\n"));

	for (i = 0; i < ACTION_COUNT; i++)
	{
		FIg_get_state(ct_form, action_info[i].button, &state);
		if (state) return i;
	}
	return NO_ACTION;
}

/******************************************************************************/

static void clear_action()
{
	int	i;

	FRM_DBG(("clear_action()\n"));

	for (i = 0; i < ACTION_COUNT; i++)
	{
		FIg_set_state(ct_form, action_info[i].button, 0);
	}
}

/*******************************************************************************
******************** CT_COLUMNS_MCF ********************************************
*******************************************************************************/

static int get_selected_row()
{
	int	row;
	int	sel_flag;
	int	num_rows;

	FRM_DBG(("get_selected_row()\n"));

	FIfld_get_num_rows(ct_form, CT_COLUMNS_MCF, &num_rows);
	for (row = 0; row < num_rows; row++)
	{
		FImcf_get_select(ct_form, CT_COLUMNS_MCF, row, &sel_flag);
		if (sel_flag)
			return row;
	}

	return -1;
}

/******************************************************************************/

static void load_columns_mcf(
	char	*table_name)
{
	FRM_DBG(("load_columns_mcf(table_name:<%s>)\n", table_name));

	clear_columns_mcf();
	update_msg_field(MSG(RISUTL_I_READING_DICTIONARY_TABLES));
	RISfrm_load_columns_mcf(table_name, ct_form, CT_COLUMNS_MCF);
	if (RIS_forms_error.error != RIS_SUCCESS && RISfrm_report_error())
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
	FRM_DBG(("process_columns_mcf()\n"));

	if (get_action() == INSERT_COLUMN)
	{
		return;
	}

	update_column_group();
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

	VALID_FORM_CHECK(ct_form);

	FIfld_get_num_rows(ct_form, CT_COLUMNS_MCF, &num_rows);
	FIfld_get_num_vis_rows(ct_form, CT_COLUMNS_MCF, &num_vis_rows);

	for (row = 0; row < num_rows; row++)
	{
		FIfld_get_text(ct_form, CT_COLUMNS_MCF, row, 1, RIS_MAX_ID_SIZE,
			(unsigned char *)rowname, &sel_flag, &r_pos);
		if (!column_found && column_name && *column_name &&
			!RISfrm_wildcard_strcmp(column_name, rowname))
		{
			column_found = 1;
			FImcf_set_select(ct_form, CT_COLUMNS_MCF, row, 1);
   			FIfld_get_row_offset(ct_form, CT_COLUMNS_MCF, &offset);
   			if (row < offset || row >= offset + num_vis_rows)
				FIfld_set_active_row(ct_form, CT_COLUMNS_MCF, row, 0);
			else
				FIfld_set_active_row(ct_form, CT_COLUMNS_MCF, row, r_pos);
		}
		else if (sel_flag)
		{
			FImcf_set_select(ct_form, CT_COLUMNS_MCF, row, 0);
		}
	}

	if (column_name && *column_name && !column_found)
	{
		sprintf(ct_msg->str, MSG(RISUTL_I_UNKNOWN_COLUMN), column_name);
		clear_search_column_field();
	}
	process_columns_mcf();
}

/******************************************************************************/

static void clear_columns_mcf()
{
	FRM_DBG(("clear_columns_mcf()\n"));
	RISfrm_clear_multi_row_field(ct_form, CT_COLUMNS_MCF);
}

/*******************************************************************************
******************** CT_TABLE_NAME_FIELD **************************************
*******************************************************************************/

static char *get_table_name_field()
{
	static	 char			table_name[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_table_name_field()\n"));

	RISfrm_get_field(ct_form, CT_TABLE_NAME_FIELD, RIS_MAX_ID_SIZE, table_name);
	FRM_DBG(("get_table_name_field() in frmcrtab.c table name=<%s>\n", table_name));
	return table_name[0] ?  table_name : NULL;
}

/******************************************************************************/

static void process_table_name_field()
{
	RISfrm_object	*object;
	char			*table_name;

	FRM_DBG(("process_table_name_field()\n"));

	table_name = get_table_name_field();
	if (!RISfrm_field_changed(table_name, initial_table_name))
	{
		return;
	}

	object = RISfrm_get_table_object(table_name, RIS_NAME, update_msg_field,
		clear_msg_field);
	if (RISfrm_dd_form_displayed())
	{
		RISfrm_update_dd_objects_mcf(object);
	}

	if (object)
	{
		RISfrm_update_ct_form(object);
	}
	else
	{
#ifdef MAYBE
		if (get_dbms_table_name_field() == NULL)
		{
#endif
			update_dbms_table_name_field(table_name);
#ifdef MAYBE
		}
#endif
	}
}

/******************************************************************************/

static void update_table_name_field(
	char	*table_name)
{
	FRM_DBG(("update_table_name_field(table_name:<%s>)\n",table_name));
	FIfld_set_text(ct_form, CT_TABLE_NAME_FIELD, 0, 0, table_name, 0);
	strcpy(initial_table_name, table_name);
}

/******************************************************************************/

static void clear_table_name_field()
{
	FRM_DBG(("clear_table_name_field()\n"));
	FIfld_set_text(ct_form, CT_TABLE_NAME_FIELD, 0, 0, "", 0);
	strcpy(initial_table_name, "");
}

/*******************************************************************************
******************** CT_DBMSTAB_NAME_FIELD *************************************
*******************************************************************************/

static char *get_dbms_table_name_field()
{
	static	 char	dbms_table_name[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_dbms_table_name_field()\n"));

	RISfrm_get_field(ct_form, CT_DBMSTAB_NAME_FIELD, RIS_MAX_ID_SIZE,
		dbms_table_name);
	return dbms_table_name[0] ?  dbms_table_name : NULL;
}

/******************************************************************************/

static void process_dbms_table_name_field()
{
	char			*table_name;

	FRM_DBG(("process_dbms_table_name_field()\n"));

	if (get_dbms_table_name_field() == NULL)
	{
		if ((table_name = get_table_name_field()) != NULL)
		{
			update_dbms_table_name_field(table_name);
		}
	}
}

/******************************************************************************/

static void update_dbms_table_name_field(
	char	*dbms_table_name)
{
	FRM_DBG(("update_dbms_table_name_field(dbms_table_name:<%s>)\n",
		dbms_table_name));
	FIfld_set_text(ct_form, CT_DBMSTAB_NAME_FIELD, 0, 0, dbms_table_name, 0);
}

/******************************************************************************/

static void clear_dbms_table_name_field()
{
	FRM_DBG(("clear_dbms_table_name_field()\n"));
	FIfld_set_text(ct_form, CT_DBMSTAB_NAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CT_SEARCH_COLUMN_FIELD ************************************
*******************************************************************************/

static char *get_search_column_field()
{
	static	 char		search[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_search_column_field()\n"));
	RISfrm_get_field(ct_form, CT_SEARCH_COLUMN_FIELD, RIS_MAX_ID_SIZE, search);
	return search[0] ? search : NULL;
}

/******************************************************************************/

static void process_search_column_field()
{
	FRM_DBG(("process_search_column_field()\n"));

	update_columns_mcf(get_search_column_field());
	clear_search_column_field();
}

/******************************************************************************/

static void clear_search_column_field()
{
	FRM_DBG(("clear_search_column_field()\n"));
	FIfld_set_text(ct_form, CT_SEARCH_COLUMN_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CT_COLUMN_NAME_FIELD **************************************
*******************************************************************************/

static int duplicate_column_name(
	char	*column_name,
	int		exception_row)
{
	int		i;
	int		num_rows;
	int		sel_flag;
	int		r_pos;
	char	row_column_name[RIS_MAX_ID_SIZE];

	FRM_DBG(("duplicate_column_name(column_name:<%s> exception_row:%d)\n",
		column_name, exception_row));

	FIfld_get_num_rows(ct_form, CT_COLUMNS_MCF, &num_rows);
	for (i = 0; i < num_rows; i++)
	{
		if (i == exception_row) continue;

		FIfld_get_text(ct_form, CT_COLUMNS_MCF, i, 1, RIS_MAX_ID_SIZE,
			(unsigned char *)row_column_name, &sel_flag, &r_pos);

		if (!strcmp(column_name, row_column_name))
		{
			sprintf(ct_msg->str, MSG(RISUTL_I_COLUMN_ALREADY_DEFINED),
				column_name);
			ct_msg->label[ct_msg->count++] = CT_COLUMN_NAME_TEXT;
			ct_msg->label[ct_msg->count++] = CT_COLUMN_NAME_FIELD;
			FIfld_pos_cursor(ct_form, CT_COLUMN_NAME_FIELD, 0, 0, 0, 0, 0, 0);
			return 1;
		}
	}
	return 0;
}

/******************************************************************************/

static char *get_column_name_field()
{
	static	 char			name[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_column_name_field()\n"));
	RISfrm_get_field(ct_form, CT_COLUMN_NAME_FIELD, RIS_MAX_ID_SIZE, name);
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

static void update_column_name_field(
	char	*column_name)
{
	FRM_DBG(("update_column_name_field(column_name:<%s>)\n",column_name));
	FIfld_set_text(ct_form, CT_COLUMN_NAME_FIELD, 0, 0, column_name, 0);
}

/******************************************************************************/

static void clear_column_name_field()
{
	FRM_DBG(("clear_column_name_field()\n"));
	FIfld_set_text(ct_form, CT_COLUMN_NAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CT_DBMSCOL_NAME_FIELD *************************************
*******************************************************************************/

static char *get_dbms_column_name_field()
{
	static	 char			name[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_dbms_column_name_field()\n"));
	RISfrm_get_field(ct_form, CT_DBMSCOL_NAME_FIELD, RIS_MAX_ID_SIZE, name);
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
	FIfld_set_text(ct_form, CT_DBMSCOL_NAME_FIELD, 0, 0, dbms_column_name, 0);
}

/******************************************************************************/

static void clear_dbms_column_name_field()
{
	FRM_DBG(("clear_dbms_column_name_field()\n"));
	FIfld_set_text(ct_form, CT_DBMSCOL_NAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CT_TYPE_CHECKS ********************************************
*******************************************************************************/

static int get_type_check()
{
	int	i;
	int	state;

	FRM_DBG(("get_type_check()\n"));

	for (i = 0; i < TYPE_COUNT; i++)
	{
		FIg_get_state(ct_form, type_check_info[i].label, &state);
		if (state) return type_check_info[i].type;
	}

	return RIS_UNKNOWN_TYPE;
}

/******************************************************************************/

static void enable_disable_type_check(
	int	type)
{
	FRM_DBG(("enable_disable_type_check(type:%d)\n",type));

	switch (get_action())
	{
		case INSERT_COLUMN:
			switch (type)
			{
				case RIS_CHARACTER:
					FIg_enable(ct_form, CT_LENGTH_FIELD);
					FIg_disable(ct_form, CT_SCALE_FIELD);
				break;

				case RIS_BLOB:
					FIg_enable(ct_form, CT_LENGTH_FIELD);
					FIg_disable(ct_form, CT_SCALE_FIELD);
				break;

				case RIS_TEXT:
					FIg_enable(ct_form, CT_LENGTH_FIELD);
					FIg_disable(ct_form, CT_SCALE_FIELD);
				break;
		
				case RIS_DECIMAL:
					FIg_enable(ct_form, CT_LENGTH_FIELD);
					FIg_enable(ct_form, CT_SCALE_FIELD);
				break;
		
				default:
					FIg_disable(ct_form, CT_LENGTH_FIELD);
					FIg_disable(ct_form, CT_SCALE_FIELD);
				break;
			}
		break;

		case MODIFY_COLUMN:
			switch (type)
			{
				case RIS_CHARACTER:
					FIg_enable(ct_form, CT_LENGTH_FIELD);
					FIg_disable(ct_form, CT_SCALE_FIELD);
				break;

				case RIS_BLOB:
					FIg_enable(ct_form, CT_LENGTH_FIELD);
					FIg_disable(ct_form, CT_SCALE_FIELD);
				break;

				case RIS_TEXT:
					FIg_enable(ct_form, CT_LENGTH_FIELD);
					FIg_disable(ct_form, CT_SCALE_FIELD);
				break;
		
				case RIS_DECIMAL:
					FIg_enable(ct_form, CT_LENGTH_FIELD);
					FIg_enable(ct_form, CT_SCALE_FIELD);
				break;
		
				default:
					FIg_disable(ct_form, CT_LENGTH_FIELD);
					FIg_disable(ct_form, CT_SCALE_FIELD);
				break;
			}
		break;

		default:		
			FIg_disable(ct_form, CT_LENGTH_FIELD);
			FIg_disable(ct_form, CT_SCALE_FIELD);
		break;
	}
}

/******************************************************************************/

static void process_type_check()
{
	int	type;

	FRM_DBG(("process_type_check()\n"));

	type = get_type_check();
	enable_disable_type_check(type);
	switch (type)
	{
		case RIS_CHARACTER:
			update_length_field(0);
			clear_scale_field();
		break;

		case RIS_BLOB:
			update_length_field(0);
			clear_scale_field();
		break;

		case RIS_TEXT:
			update_length_field(0);
			clear_scale_field();
		break;

		case RIS_DECIMAL:
			update_length_field(0);
			update_scale_field(0);
		break;

		default:
			clear_length_field();
			clear_scale_field();
		break;
	}
}

/******************************************************************************/

static void update_type_check(
	int	type)
{
	int	i;

	FRM_DBG(("update_type_field(type:%d)\n",type));

	for (i = 0; i < TYPE_COUNT; i++)
	{
		if (type == type_check_info[i].type)
			FIg_set_state(ct_form, type_check_info[i].label, 1);
		else
			FIg_set_state(ct_form, type_check_info[i].label, 0);
	}
	enable_disable_type_check(type);
}

/******************************************************************************/

static void clear_type_check()
{
	FRM_DBG(("clear_type_check()\n"));
	update_type_check(0);
}

/*******************************************************************************
******************** CT_NULLS_TOGGLE *******************************************
*******************************************************************************/

static int get_nulls_toggle()
{
	int	state;

	FRM_DBG(("get_nulls_toggle()\n"));
	FIg_get_state(ct_form, CT_NULLS_TOGGLE, &state);
	return state;
}

/******************************************************************************/

static void update_nulls_toggle(
	int	nulls_allowed)
{
	FRM_DBG(("update_nulls_field(nulls_allowed:%d)\n",nulls_allowed));
	FIg_set_state(ct_form, CT_NULLS_TOGGLE, nulls_allowed);
}

/******************************************************************************/

static void clear_nulls_toggle()
{
	FRM_DBG(("clear_nulls_toggle()\n"));
	update_nulls_toggle(1);
}

/*******************************************************************************
******************** CT_LENGTH_FIELD *******************************************
*******************************************************************************/

static int get_length_field()
{
	int		sel_flag;
	int		r_pos;
	double	length;

	FRM_DBG(("get_length_field()\n"));

	FIfld_get_value(ct_form, CT_LENGTH_FIELD, 0, 0, &length, &sel_flag, &r_pos);
	FRM_DBG(("length=%d\n", length));
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
		FIfld_set_value(ct_form, CT_LENGTH_FIELD, 0, 0, (double)length, 0);
}

/******************************************************************************/

static void clear_length_field()
{
	FRM_DBG(("clear_length_field()\n"));
	FIfld_set_text(ct_form, CT_LENGTH_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CT_SCALE_FIELD *******************************************
*******************************************************************************/

static int get_scale_field()
{
	int		sel_flag;
	int		r_pos;
	double	scale;

	FRM_DBG(("get_scale_field()\n"));

	FIfld_get_value(ct_form, CT_SCALE_FIELD, 0, 0, &scale, &sel_flag, &r_pos);
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
		FIfld_set_value(ct_form, CT_SCALE_FIELD, 0, 0, (double)scale, 0);
}

/******************************************************************************/

static void clear_scale_field()
{
	FRM_DBG(("clear_scale_field()\n"));
	FIfld_set_text(ct_form, CT_SCALE_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** CT_COLUMN_GROUP *******************************************
*******************************************************************************/

static int get_column_group(
	char	**namep,
	char	**dbmsnamep,
	char	**typep,
	char	**nullp)
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
		strcpy(ct_msg->str, MSG(RISUTL_I_COLNAME_MUST_BE_SPEC));
		ct_msg->label[ct_msg->count++] = CT_COLUMN_NAME_TEXT;
		ct_msg->label[ct_msg->count++] = CT_COLUMN_NAME_FIELD;
		FIfld_pos_cursor(ct_form, CT_COLUMN_NAME_FIELD, 0, 0, 0, 0, 0, 0);
		return 1;
	}

	/*
	**	dbmscolumn name
	*/
	*dbmsnamep = get_dbms_column_name_field();

	/*
	**	column type
	*/
	if ((type = get_type_check()) == RIS_UNKNOWN_TYPE)
	{
		strcpy(ct_msg->str, MSG(RISUTL_I_COLTYPE_MUST_BE_SPEC));
		ct_msg->label[ct_msg->count++] = CT_TYPE_GROUP;
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
				ct_msg->label[ct_msg->count++] = CT_LENGTH_FIELD;
				strcpy(ct_msg->str, MSG(RISUTL_I_DTYPE_ENTER_LEN));
				return 1;
			}
			RISget_ris_sqltype_string(ristypestr, type);
			sprintf(typestr, "%s(%d)", ristypestr, length);
			break;

		case RIS_BLOB:
			length = get_length_field();
			if (length == 0)
			{
				strcpy(ct_msg->str, MSG(RISUTL_I_DTYPE_ENTER_LEN));
				ct_msg->label[ct_msg->count++] = CT_LENGTH_FIELD;
				return 1;
			}
			RISget_ris_sqltype_string(ristypestr, type);
			RISget_ris_sqltype_string(ristypestr, type);
			sprintf(typestr, "%s(%d)", ristypestr, length);
			break;

		case RIS_TEXT:
			length = get_length_field();
			if (length == 0)
			{
				ct_msg->label[ct_msg->count++] = CT_LENGTH_FIELD;
				strcpy(ct_msg->str, MSG(RISUTL_I_DTYPE_ENTER_LEN));
				return 1;
			}
			RISget_ris_sqltype_string(ristypestr, type);
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
	*nullp = get_nulls_toggle() ? "YES" : "NO";

	return 0;
}

/******************************************************************************/

static void update_column_group()
{
	int		t;
	int		row;
	int		type;
	unsigned int 		length;
	int		scale;
	int		nulls_allowed;
	int		pos, sel_flag;
	char	*ptr;
	char	name[RIS_MAX_ID_SIZE];
	char	dbms_name[RIS_MAX_ID_SIZE];
	char	ristypestr[16];
	char	typestr[16];
	char	nullstr[4];

	FRM_DBG(("update_column_group()\n"));

	if ((row = get_selected_row()) == -1)
	{
		if (get_action() != INSERT_COLUMN)
			clear_column_group();
		return;
	}

	/*
	**	get column name
	*/
	FIfld_get_text(ct_form, CT_COLUMNS_MCF, row, 1, RIS_MAX_ID_SIZE,
		(unsigned char *)name, &sel_flag, &pos);

	/*
	**	get column name
	*/
	FIfld_get_text(ct_form, CT_COLUMNS_MCF, row, 2, RIS_MAX_ID_SIZE,
		(unsigned char *)dbms_name, &sel_flag, &pos);

	/*
	**	get type
	*/
	FIfld_get_text(ct_form, CT_COLUMNS_MCF, row, 3, 16,
		(unsigned char *)typestr, &sel_flag, &pos);
	type = -1;
	length = 0;
	scale = -1;
	for (t = 0; t < RIS_MAX_TYPES; t++)
	{
		RISget_ris_sqltype_string(ristypestr, t);
		if (!strncmp(typestr, ristypestr, strlen(ristypestr)))
		{
			type = t;
			break;
		}
	}
	if (t == RIS_MAX_TYPES)
	{
		if (!strncmp(typestr, TIMESTAMP_STRING, sizeof(TIMESTAMP_STRING) - 1))
		type = RIS_DATETIME;
	}

	if (type == RIS_CHARACTER)
	{
		RISget_ris_sqltype_string(ristypestr, type);
		ptr = typestr + strlen(ristypestr);
		sscanf(ptr, "(%d)", &length);
	}
	else if (type == RIS_DECIMAL)
	{
		RISget_ris_sqltype_string(ristypestr, type);
		ptr = typestr + strlen(ristypestr);
		sscanf(ptr, "(%d,%d)", &length, &scale);
	}

	/*
	**	get nulls allowed
	*/
	FIfld_get_text(ct_form, CT_COLUMNS_MCF, row, 4, 4,
		(unsigned char *)nullstr, &sel_flag, &pos);
	nulls_allowed = !RIScom_strcmp_ic(nullstr,"YES");

	update_column_name_field(name);
	update_dbms_column_name_field(dbms_name);
	update_type_check(type);
	update_length_field(length);
	update_scale_field(scale);
	update_nulls_toggle(nulls_allowed);
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

/******************************************************************************/

static void enable_column_group()
{
	FRM_DBG(("enable_column_group()\n"));

	FIg_enable(ct_form, CT_COLUMN_GROUP);
}

/******************************************************************************/

static void disable_column_group()
{
	FRM_DBG(("disable_column_group()\n"));

	FIg_disable(ct_form, CT_COLUMN_GROUP);
	FIg_disable(ct_form, CT_LENGTH_FIELD);
	FIg_disable(ct_form, CT_SCALE_FIELD);
}

/*******************************************************************************
******************** CT_INSERT_COLUMN_BUTTON ***********************************
*******************************************************************************/

static void process_insert_column_button()
{
	FRM_DBG(("process_insert_column_button()\n"));
	enable_column_group();
	enable_disable_type_check(get_type_check());
}

/*******************************************************************************
******************** CT_DROP_COLUMN_BUTTON *************************************
*******************************************************************************/

static void process_drop_column_button()
{
	FRM_DBG(("process_drop_column_button()\n"));
	disable_column_group();
	update_column_group();
}

/*******************************************************************************
******************** CT_MODIFY_COLUMN_BUTTON ***********************************
*******************************************************************************/

static void process_modify_column_button()
{
	FRM_DBG(("process_modify_column_button()\n"));
	enable_column_group();
	update_column_group();
}

/*******************************************************************************
******************** CT_EXECUTE_BUTTON *****************************************
*******************************************************************************/

static void insert_column()
{
	int		num_rows;
	int		row;
	double	position;
	char	*column_name;
	char	*dbms_column_name;
	char	*typestr;
	char	*nullstr;

	FRM_DBG(("insert_column()\n"));

	if (get_column_group(&column_name, &dbms_column_name, &typestr, &nullstr))
		return;

	if (duplicate_column_name(column_name, CHECK_ALL_ROWS))
		return;

	if ((row = get_selected_row()) == -1)
	{
		/*
		**	append the column
		*/
		FIfld_get_num_rows(ct_form, CT_COLUMNS_MCF, &num_rows);
		num_rows++;
		FIfld_set_num_rows(ct_form, CT_COLUMNS_MCF, num_rows);

		row = num_rows - 1;
		position = row + 1;
		FIfld_set_value(ct_form, CT_COLUMNS_MCF, row, 0, position, 0);
		FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 1, column_name, 0);
		FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 2, dbms_column_name, 0);
		FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 3, typestr, 0);
		FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 4, nullstr, 0);

		if (row > 8) FIfld_set_active_row(ct_form, CT_COLUMNS_MCF, row, 8);
	}
	else
	{
		double d1;
		int d2;
		int r_pos;
		/*
		**	insert the column
		*/
		FImcf_set_select(ct_form, CT_COLUMNS_MCF, row, 0);

		FIfld_insert_blank_row(ct_form, CT_COLUMNS_MCF, row);
		FIfld_get_num_rows(ct_form, CT_COLUMNS_MCF, &num_rows);
		FIfld_set_num_rows(ct_form, CT_COLUMNS_MCF, num_rows);
		position = row + 1;
		FIfld_set_value(ct_form, CT_COLUMNS_MCF, row, 0, position, 0);
		FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 1, column_name, 0);
		FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 2, dbms_column_name, 0);
		FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 3, typestr, 0);
		FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 4, nullstr, 0);

		row++;
		position = row + 1;
		FIfld_set_value(ct_form, CT_COLUMNS_MCF, row, 0, position, 1);
		FIfld_get_value(ct_form, CT_COLUMNS_MCF, row, 0, &d1, &d2, &r_pos);
		if (r_pos == -1)
			FIfld_set_active_row(ct_form, CT_COLUMNS_MCF, row, 9);
		FImcf_set_select(ct_form, CT_COLUMNS_MCF, row, 1);

		for (row++; row < num_rows; row++)
		{
			position = row + 1;
			FIfld_set_value(ct_form, CT_COLUMNS_MCF, row, 0, position, 0);
		}
	}
}

/******************************************************************************/

static void drop_column()
{
	int		row;
	int		delete_row;
	int		num_rows;
	double	position;

	FRM_DBG(("drop_column()\n"));

	if ((delete_row = get_selected_row()) == -1)
	{
		strcpy(ct_msg->str, MSG(RISUTL_I_COLUMN_MUST_BE_SPEC));
		return;
	}

	FIfld_get_num_rows(ct_form, CT_COLUMNS_MCF, &num_rows);

	FIfld_delete_rows(ct_form, CT_COLUMNS_MCF, delete_row, 1);
	num_rows--;

	FIfld_set_num_rows(ct_form, CT_COLUMNS_MCF, num_rows);

	for (row = 0; row < num_rows; row++)
	{
		if (row >= delete_row)
		{
			position = row + 1;
			FIfld_set_value(ct_form, CT_COLUMNS_MCF, row, 0, position, 0);
		}
		FImcf_set_select(ct_form, CT_COLUMNS_MCF, row, 0);
	}
}

/******************************************************************************/

static void modify_column()
{
	int		row;
	char	*column_name;
	char	*dbms_column_name;
	char	*typestr;
	char	*nullstr;


	FRM_DBG(("modify_column()\n"));

	if ((row = get_selected_row()) == -1)
	{
		strcpy(ct_msg->str, MSG(RISUTL_I_COLUMN_MUST_BE_SPEC));
		return;
	}

	if (get_column_group(&column_name, &dbms_column_name, &typestr, &nullstr))
		return;

	if (duplicate_column_name(column_name, row))
		return;

	FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 1, column_name, 1);
	FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 2, dbms_column_name, 1);
	FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 3, typestr, 1);
	FIfld_set_text(ct_form, CT_COLUMNS_MCF, row, 4, nullstr, 1);
}

/******************************************************************************/

static void process_ct_execute_button()
{
	FRM_DBG(("process_ct_execute_button()\n"));

	switch(get_action())
	{
		case INSERT_COLUMN:
			insert_column();
			break;

		case DROP_COLUMN:
			drop_column();
			break;

		case MODIFY_COLUMN:
			modify_column();
			break;

		default:
			strcpy(ct_msg->str, MSG(RISUTL_I_NO_ACTION_TAKEN));
			break;
	}
}

/*******************************************************************************
******************** CT_RESET_BUTTON *******************************************
*******************************************************************************/

static void process_ct_reset_button()
{
	int	row;

	FRM_DBG(("process_ct_reset_button()\n"));
	disable_column_group();
	clear_column_group();
	clear_action();
	if ((row = get_selected_row()) != -1)
		FImcf_set_select(ct_form, CT_COLUMNS_MCF, row, 0);
}

/*******************************************************************************
******************** CT_DISABLE_GROUP ******************************************
*******************************************************************************/

extern void RISfrm_disable_ct_form()
{
	FRM_DBG(("disable_ct_form()\n"));

	VALID_FORM_CHECK(ct_form);

	FIg_disable(ct_form, FI_RESET);
	FIg_disable(ct_form, FI_EXECUTE);
	FIg_disable(ct_form, CT_DISABLE_GROUP);
}

/******************************************************************************/

extern void RISfrm_enable_ct_form()
{
	FRM_DBG(("enable_ct_form()\n"));

	VALID_FORM_CHECK(ct_form);

	FIg_enable(ct_form, FI_RESET);
	FIg_enable(ct_form, FI_EXECUTE);
	FIg_enable(ct_form, CT_TABLE_NAME_FIELD);
	FIf_set_start_seq(ct_form, CT_TABLE_NAME_FIELD);
	FIg_enable(ct_form, CT_DBMSTAB_NAME_FIELD);
	FIg_enable(ct_form, CT_SEARCH_COLUMN_FIELD);
	FIg_enable(ct_form, CT_COLUMNS_MCF);
	FIg_enable(ct_form, CT_RESET_BUTTON);
	FIg_enable(ct_form, CT_EXECUTE_BUTTON);
	FIg_enable(ct_form, CT_BUTTON_GROUP);
}

/*******************************************************************************
******************** EXECUTE_BUTTON ********************************************
*******************************************************************************/

static void process_execute_button()
{
	int				row;
	int				num_rows;
	int				sel_flag, pos;
	char			*ptr;
	char			buffer[32];
	char			*cmd;
	char			create_table_command[10000];
	RISfrm_object	object;

	FRM_DBG(("process_execute_button()\n"));

	clear_column_group();
	disable_column_group();
	clear_action();

	cmd = create_table_command;

	if ((ptr = get_table_name_field()) == NULL)
	{
		strcpy(ct_msg->str, MSG(RISUTL_I_TABNAME_MUST_BE_SPEC));
		ct_msg->label[ct_msg->count++] = CT_TABLE_NAME_TEXT;
		ct_msg->label[ct_msg->count++] = CT_TABLE_NAME_FIELD;
		FIfld_pos_cursor(ct_form, CT_TABLE_NAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}
	cmd += sprintf(cmd, "CREATE TABLE %s (", ptr);

	FIfld_get_num_rows(ct_form, CT_COLUMNS_MCF, &num_rows);
	if (num_rows == 0)
	{
		strcpy(ct_msg->str, MSG(RISUTL_I_ONE_COL_MUST_BE_SPEC));
		ct_msg->label[ct_msg->count++] = CT_COLUMNS_MCF;
		return;
	}

	for (row = 0; row < num_rows; row++)
	{
		/*
		**	column name
		*/
		FIfld_get_text(ct_form, CT_COLUMNS_MCF, row, 1, 32,
			(unsigned char *)buffer, &sel_flag, &pos);
		cmd += sprintf(cmd, "%s", buffer);

		/*
		**	column type
		*/
		FIfld_get_text(ct_form, CT_COLUMNS_MCF, row, 3, 32,
			(unsigned char *)buffer, &sel_flag, &pos);
		cmd += sprintf(cmd, " %s", buffer);

		/*
		**	nulls
		*/
		FIfld_get_text(ct_form, CT_COLUMNS_MCF, row, 4, 32,
			(unsigned char *)buffer, &sel_flag, &pos);
		if (!RIScom_strcmp_ic(buffer, "NO"))
			cmd += sprintf(cmd, " NOT NULL");

		if (row < num_rows - 1)
			cmd += sprintf(cmd, ", ");
	}
	cmd += sprintf(cmd, ") ");

	ptr = get_dbms_table_name_field();
	cmd += sprintf(cmd, "EXTERN %s (", ptr);
	for (row = 0; row < num_rows; row++)
	{
		/*
		**	dbms_column name
		*/
		FIfld_get_text(ct_form, CT_COLUMNS_MCF, row, 2, 32,
			(unsigned char *)buffer, &sel_flag, &pos);
		cmd += sprintf(cmd, "%s", buffer);

		if (row < num_rows - 1)
		{
			cmd += sprintf(cmd, ", ");
		}
	}
	cmd += sprintf(cmd, ") ");

	FRM_DBG(("%s\n",create_table_command));

	if (RISfrm_user_exec_ct_form &&
		RISfrm_user_exec_ct_form(ct_form, create_table_command) == 0)
			return;

	update_msg_field(MSG(RISUTL_I_CREATING_TAB));
	RISfrm_execute_command(create_table_command);
	clear_msg_field();

	if (SQLCODE)
	{
		RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
		if (RISfrm_report_error() == 0) return;
		switch(SQLCODE)
		{
			case RIS_E_TABVIEW_ALREADY_EXISTS:
				strcpy(ct_msg->str, MSG(RISUTL_I_ENTER_UNIQUE_TABNAME));
				ct_msg->label[ct_msg->count++] = CT_TABLE_NAME_TEXT;
				ct_msg->label[ct_msg->count++] = CT_TABLE_NAME_FIELD;
				FIfld_pos_cursor(ct_form, CT_TABLE_NAME_FIELD,0,0,0,0,0,0);
				break;
		}
		return;
	}
	RISfrm_object_list_up_to_date = 0;

	strcpy(ct_msg->str, MSG(RISUTL_I_CREATE_TABLE_SUCCESS));
	update_msg_field(ct_msg->str);

	if (RISfrm_dd_form_displayed())
	{
		char	def_schname[RIS_MAX_ID_SIZE] = "";

		RISget_default_schema_name(def_schname);
		RISfrm_load_dd_objects_mcf(def_schname);

		strcpy(object.name, get_table_name_field());
		object.type = TABLE_CHAR;
		RISfrm_update_dd_objects_mcf(&object);
	}
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));

	RISfrm_clear_ct_form();
	if (RISfrm_dd_form_displayed())
		RISfrm_update_dd_objects_mcf((RISfrm_object *)0);
	DISPLAY_HELP_BUTTON(ct_form);
	RISfrm_call_user_init_ct_form();
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));

	RISfrm_erase_ct_form();
	if (RISfrm_dd_form_displayed())
		RISfrm_clear_dd_create_table_button();
}

/*******************************************************************************
******************** TI FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_ct_form(
	int g_label)
{
	int	i;

	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_EXECUTE,					process_execute_button			},
		{	FI_RESET,					process_reset_button			},
		{	FI_CANCEL,					process_cancel_button			},
		{	CT_EXECUTE_BUTTON,			process_ct_execute_button		},
		{	CT_RESET_BUTTON,			process_ct_reset_button			},
		{	CT_COLUMNS_MCF,				process_columns_mcf				},
		{	CT_TABLE_NAME_FIELD,		process_table_name_field		},
		{	CT_DBMSTAB_NAME_FIELD,		process_dbms_table_name_field	},
		{	CT_COLUMN_NAME_FIELD,		process_column_name_field		},
		{	CT_DBMSCOL_NAME_FIELD,		process_dbms_column_name_field	},
		{	CT_SEARCH_COLUMN_FIELD,		process_search_column_field		},
		{	CT_SMALLINT_CHECK,			process_type_check				},
		{	CT_INTEGER_CHECK,			process_type_check				},
		{	CT_REAL_CHECK,				process_type_check				},
		{	CT_DOUBLE_CHECK,			process_type_check				},
		{	CT_CHARACTER_CHECK,			process_type_check				},
		{	CT_DECIMAL_CHECK,			process_type_check				},
		{	CT_TIMESTAMP_CHECK,			process_type_check				},
		{	CT_BLOB_CHECK,		       	process_type_check				},
		{	CT_TEXT_CHECK,		       	process_type_check				},
		{	CT_INSERT_COLUMN_BUTTON,	process_insert_column_button	},
		{	CT_DROP_COLUMN_BUTTON,		process_drop_column_button		},
		{	CT_MODIFY_COLUMN_BUTTON,	process_modify_column_button	},
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_ct_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(ct_form);

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

extern void RISfrm_process_ct_form_initial(
	int g_label)
{
	FRM_DBG(("RISfrm_process_ct_form_initial(g_label:%d)\n", g_label));
	switch(g_label)
	{
		case CT_TABLE_NAME_FIELD:
			RISfrm_get_field(ct_form, CT_TABLE_NAME_FIELD, RIS_MAX_ID_SIZE,
				initial_table_name);
			break;
	}
}

/******************************************************************************/

extern void RISfrm_call_user_init_ct_form()
{
	FRM_DBG(("RISfrm_call_user_init_ct_form()\n"));

	VALID_FORM_CHECK(ct_form);

	if (RISfrm_user_init_ct_form)
	{
		FRM_DBG(("calling RISfrm_user_init_ct_form()\n"));
		RISfrm_user_init_ct_form(ct_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_ct_form(
	int	called_by_user,
	int	disable_flag)
{
	int		sts;
	char	def_schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("RISfrm_display_ct_form(called_by_user:%d disable_flag:%d)\n",
		called_by_user, disable_flag));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!ct_form)
	{
		sts = FIf_new(CT_FORM, CT_FORM_FILE, RISfrm_notification_routine,
			&ct_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_CT_FORM, sts);
			return RIS_forms_error.error;
		}

		FIf_set_initial_notification_routine(ct_form,
			RISfrm_initial_notification_routine);

		FIgrp_add_to_group(ct_form, CT_TYPE_GROUP, CT_COLUMN_GROUP);
		FIgrp_add_to_group(ct_form, CT_COLUMN_GROUP, CT_DISABLE_GROUP);
		FIgrp_add_to_group(ct_form, CT_BUTTON_GROUP, CT_DISABLE_GROUP);

#if defined(WIN32)
		FIf_SetDefaultButton(ct_form, FI_EXECUTE);
		FIg_set_text(ct_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));

#endif
	}

	ct_msg->str[0] = 0;
	ct_msg->count = 0;
	ct_msg->msg_fld_label = CT_MSG_FIELD;
	ct_msg->fp = ct_form;

	if (!RISfrm_ct_form_displayed())
	{
		DISPLAY_HELP_BUTTON(ct_form);

		if (disable_flag)
			RISfrm_disable_ct_form();
		else
			RISfrm_enable_ct_form();

		if (called_by_user)
		{
			RISget_default_schema_name(def_schname);
			if (!def_schname[0])
			{
				RISfrm_form_errhandle(RISUTL_E_FORM_NO_SCHEMA, 0);
				return RIS_forms_error.error;
			}
			RISfrm_object_list_up_to_date = 0;
			RISfrm_call_user_init_ct_form();
		}

		sts = FIf_display (ct_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_CT_FORM, sts);
			return RIS_forms_error.error;
		}

		clear_columns_mcf();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern void RISfrm_update_ct_form(
	RISfrm_object *object)
{
	FRM_DBG(("RISfrm_update_ct_form(object: 0x%x)\n", object));

	VALID_FORM_CHECK(ct_form);

	if (!object || object->type != TABLE_CHAR)
	{
		RISfrm_clear_ct_form();
		return;
	}

	update_table_name_field(object->name);
	update_dbms_table_name_field(object->dbms_name);
	clear_search_column_field();
	clear_column_group();
	disable_column_group();
	clear_action();
	load_columns_mcf(object->name);
}

/******************************************************************************/

extern void RISfrm_clear_ct_form()
{
	FRM_DBG(("RISfrm_clear_ct_form()\n"));

	VALID_FORM_CHECK(ct_form);

	clear_columns_mcf();
	clear_table_name_field();
	clear_dbms_table_name_field();
	clear_search_column_field();
	clear_column_group();
	clear_action();
}

/******************************************************************************/

extern int RISfrm_ct_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_ct_form_displayed()\n"));

	if (!ct_form)
	{
		return(0);
	}

	FIf_is_displayed(ct_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_ct_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_ct_form()\n"));
	if (RISfrm_ct_form_displayed())
	{
		sts = FIf_erase(ct_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_CT_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_ct_form();
		if (RISfrm_dd_form_displayed())
			RISfrm_clear_dd_create_table_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER CALLABLE FUNCTIONS *****************************************
*******************************************************************************/

extern int RISAPI RISXfrm_create_table_form_displayed()
{
	return RISfrm_ct_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_create_table_form()
{
	return RISfrm_display_ct_form(CALLED_BY_USER, DISPLAY_ENABLED);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_create_table_form()
{
	return RISfrm_erase_ct_form();
}

/******************************************************************************/
