/* Do not alter this SPC information: $Revision: 1.6.3.1 $ */
/*
**	NAME:							frmincl.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					06/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "forms.h"
#include "riscom.h"
#include "ris_err.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmincl_c
#include "comstcmi.prt"
#include "comdebug.prt"
#include "comumsg.prt"
#include "frmdadef.prt"
#include "frmdbcol.prt"
#include "frmdbobj.prt"
#include "frmdbusr.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmfile.prt"
#include "frmincl.prt"
#include "frmntfy.prt"
#include "frmutil.prt"
#include "fi.prt"
#include "ris.prt"
#include "sys.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif
#include "comisfn.prt"
/*
**	DEFINES
*/
#define TABLE		0
#define VIEW		1
#define INDEX		2

/*
**	VARIABLES
*/
char				include_command[10000];
static  Form			in_form = 0;
static RISfrm_msg	*in_msg = &RISfrm_msgs[IN_FORM_MSG];

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** IN_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(in_form, IN_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(in_form, IN_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** TEXT ******************************************************
*******************************************************************************/

static void update_text(
	void)
{
	char s[32];
	char typestr[32];

	FRM_DBG(("update_text()\n"));

	switch(get_type_rollthru())
	{
		case INDEX:
			strcpy(typestr, MSG(RISUTL_I_INDEX));
			break;

		case VIEW:
			strcpy(typestr, MSG(RISUTL_I_VIEW));
			break;

		case TABLE:
		default:
			strcpy(typestr, MSG(RISUTL_I_TABLE));
			break;
	}
	FIg_erase(in_form, IN_DBMS_OBJECTS_TEXT);
	FIg_erase(in_form, IN_DBMS_OBJECT_TEXT);
	FIg_erase(in_form, IN_OBJECT_TEXT);

	sprintf(s, MSG(RISUTL_I_DBMS_USER_S_NAMES), typestr);
	FIg_set_text(in_form, IN_DBMS_OBJECTS_TEXT, s);

	sprintf(s, MSG(RISUTL_I_DBMS_S_NAME), typestr);
	FIg_set_text(in_form, IN_DBMS_OBJECT_TEXT, s);

	sprintf(s, MSG(RISUTL_I_S_NAME), typestr);
	FIg_set_text(in_form, IN_OBJECT_TEXT, s);

	FIg_display(in_form, IN_DBMS_OBJECTS_TEXT);
	FIg_display(in_form, IN_DBMS_OBJECT_TEXT);
	FIg_display(in_form, IN_OBJECT_TEXT);
}

/*******************************************************************************
******************** TYPE ROLLTHRU *********************************************
*******************************************************************************/

static int get_type_rollthru()
{
	int row;
	int pos;

	FRM_DBG(("get_type_rollthru()\n"));
	FIfld_get_active_row(in_form, IN_TYPE_ROLLTHRU, &row, &pos);
	return row;
}

/******************************************************************************/

static void process_type_rollthru()
{
	FRM_DBG(("process_type_rollthru()\n"));

	update_text();
	load_dbms_objects_field();
	clear_dbms_object_field();
	clear_object_field();
	clear_columns_field();
	load_columns_field();

}
	
/******************************************************************************/

static void clear_type_rollthru()
{
	FRM_DBG(("clear_type_rollthru()\n"));

	FIfld_set_active_row(in_form, IN_TYPE_ROLLTHRU, TABLE, 0);
}

/*******************************************************************************
******************** IN_USER_FIELD *********************************************
*******************************************************************************/

static char *get_user_field()
{
	static	 char	user[RIS_MAX_ID_SIZE];
	static	 char	upper_user[RIS_MAX_ID_SIZE];
	int     i;
        char  	        schname[RIS_MAX_ID_SIZE];
        ris_schema_info *schema;
        unsigned char   dtype;

	FRM_DBG(("get_user_field()\n"));

        RISget_default_schema_name(schname);
        schema = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);

		/*
		** The following if statement is a fix for a coredump when the trying to
		** include a table and scrolling to select a "Type" when NO SCHEMA is selected
		** Radha Shivakumar 4/26/95
		*/
		if (schema)
			dtype = RISfrm_get_dtype(schema->dbid);

        FRM_DBG(("dtype in get_user_field() = %c\n", dtype));

	RISfrm_get_field(in_form, IN_USER_FIELD, RIS_MAX_ID_SIZE, user);

	
	if (dtype == 'O' || dtype == 'D' || dtype == 'R' || dtype == '4')
	{
	  	i = strlen(user);
		for (i = 0; user[i]; i++)
	 	{
			if (user[i] > 96 && user[i] < 123)
	              		 upper_user[i] = RIScom_toupper(user[i]);
			else
	              		 upper_user[i] = user[i];
		}
		upper_user[i] = '\0';
		strcpy(user, upper_user);
	}

   FRM_DBG(("user name in get_user_field() = %s\n", user));
	return user[0] ? user : NULL;
}

/******************************************************************************/

static void process_user_field()
{
	FRM_DBG(("process_user_field()\n"));
	clear_columns_field();
	load_dbms_objects_field();
}

/******************************************************************************/

static void update_user_field(
	char	*user)
{
	FRM_DBG(("update_user_field(user:<%s>)\n", user));
	FIfld_set_text(in_form, IN_USER_FIELD, 0, 0, user, 0);
}

/******************************************************************************/

static void clear_user_field()
{
	FRM_DBG(("clear_user_field()\n"));
	FIfld_set_text(in_form, IN_USER_FIELD, 0, 0, "", 0);
}

/******************************************************************************/

static void load_user_field()
{
	/*
	**	For now, initialize the users field to the schema owner.
	*/
	char			schname[RIS_MAX_ID_SIZE];
	ris_schema_info	*schema;

	if (get_user_field() == NULL)
	{
		RISget_default_schema_name(schname);
		schema = RISfrm_get_schema(schname,update_msg_field,clear_msg_field);
		if (schema != NULL)
		{
			update_user_field(schema->schowner);
		}
	}
}

/******************************************************************************/

static void load_user_field_list(
	void)
{
	int		i;
	char	schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("load_user_field_list()\n"));

	FIfld_set_list_num_rows(in_form, IN_USER_FIELD, 0,0);

	RISget_default_schema_name(schname);
	if (!schname[0])
	{
		return;
	}

/*
	if (strcmp(RISfrm_dbms_user_schname, schname))
	{
		RISfrm_dbms_user_list_up_to_date = 0;
	}

	if (!RISfrm_dbms_user_list_up_to_date)
*/
	RISfrm_get_dbms_user_list(schname, update_msg_field, clear_msg_field);
	clear_msg_field();
	if (RIS_forms_error.error && RISfrm_report_error())
	{
		switch(RIS_forms_error.error)
		{
		}
		return;
	}

	FIfld_set_list_num_rows(in_form, IN_USER_FIELD, 0, RISfrm_dbms_users_cnt);
	if (RISfrm_dbms_users_cnt)
	{
		for (i = 0; i < RISfrm_dbms_users_cnt; i++)
		{
			FIfld_set_list_text(in_form, IN_USER_FIELD, i, 0,
				RISfrm_dbms_users[i]->user, 0);
		}
	}
}

/******************************************************************************/

static void clear_user_field_list(
	void)
{
	FRM_DBG(("clear_user_field_list()\n"));
	FIfld_set_list_num_rows(in_form, IN_USER_FIELD, 0,0);
}

/*******************************************************************************
******************** IN_DBMS_OBJECTS_FIELD *************************************
*******************************************************************************/

static char *get_dbms_objects_field()
{
	int		row;
	int		num_rows;
	int		sel_flag;
	int		r_pos;
	static  char	name[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_dbms_objects_field()\n"));

	FIfld_get_num_rows(in_form, IN_DBMS_OBJECTS_FIELD, &num_rows);

	name[0] = '\0';
	for (row = 0; row < num_rows; row++)
	{
		FIfld_get_select(in_form, IN_DBMS_OBJECTS_FIELD, row, 0, &sel_flag);
		if (sel_flag)
		{
			FIfld_get_text(in_form, IN_DBMS_OBJECTS_FIELD, row, 0,
				sizeof(name), (unsigned char *)name, &sel_flag, &r_pos);
			break;
		}
	}

	return name[0] ? name : NULL;
}

/******************************************************************************/

static void process_dbms_objects_field(
	void)
{
	char	*name;

	FRM_DBG(("process_dbms_objects_field()\n"));

	name = get_dbms_objects_field();
	if (name && name[0])
	{
		update_dbms_object_field(name);
		update_object_field(name);
		FIfld_pos_cursor(in_form, IN_OBJECT_FIELD, 0, 0, 0, 0, 0, 0);
		clear_columns_field();
		load_columns_field();
	}
	else
	{
		clear_dbms_object_field();
		clear_object_field();
		clear_columns_field();
	}
}

/******************************************************************************/

static void load_dbms_objects_field(
	void)
{
	int		i;
	int		row_count;
	char	*user;
	char	type_char;
	char	schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("load_dbms_objects_field()\n"));

	if ((user = get_user_field()) == NULL)
	{
		FIfld_set_num_rows(in_form, IN_DBMS_OBJECTS_FIELD, 0);
		return;
	}
	FRM_DBG(("load_dbms_objects_field()\n user = <%s>\n", user));

	RISget_default_schema_name(schname);

	/*Supraja Gaini:Fix for TR439503090:When a table is dropped via "rismgr" 
	  and in the same session the "include Table" form is invoked the dropped
	  table will no longer appear. A check on the RISfrm_dbms_obj_list_up_to_date
	  is no longer made before the RISfrm_get_dbms_obj_list() is called*/

	/*if (strcmp(user, RISfrm_dbms_obj_owner) ||
		strcmp(schname, RISfrm_dbms_obj_schname))
	{
		RISfrm_dbms_obj_list_up_to_date = 0;
	}*/

	/*if (!RISfrm_dbms_obj_list_up_to_date)*/
	/*{*/
		RISfrm_get_dbms_obj_list(schname, user, update_msg_field,
			clear_msg_field);
		clear_msg_field();
		if (RIS_forms_error.error && RISfrm_report_error())
		{
			switch(RIS_forms_error.error)
			{
			}
			return;
		}
	/*}*/

	switch(get_type_rollthru())
	{
		case VIEW:
			type_char = VIEW_CHAR;
			break;

		case INDEX:
			type_char = INDEX_CHAR;
			break;

		case TABLE:
		default:
			type_char = TABLE_CHAR;
			break;
	}

	row_count = 0;
	for (i = 0; i < RISfrm_dbms_objs_cnt; i++)
	{
		if (type_char == RISfrm_dbms_objs[i]->type)
		{
			FIfld_set_text(in_form, IN_DBMS_OBJECTS_FIELD, row_count++, 1,
				RISfrm_dbms_objs[i]->name, 0);
		}
	}
	FIfld_set_num_rows(in_form, IN_DBMS_OBJECTS_FIELD, row_count);
}

/******************************************************************************/

static void update_dbms_objects_field(
	char	*object)
{
	int		row;
	int		r_pos;
	int		offset;
	int		sel_flag;
	int		num_rows;
	int		num_vis_rows;
	char	name[RIS_MAX_ID_SIZE];

	FRM_DBG(("update_dbms_objects_field(object:<%s>)\n", STRING(object)));

	VALID_FORM_CHECK(in_form);

	if (object && *object)
	{
		FIfld_get_num_rows(in_form, IN_DBMS_OBJECTS_FIELD, &num_rows);
		FIfld_get_num_vis_rows(in_form, IN_DBMS_OBJECTS_FIELD, &num_vis_rows);
		for (row = 0; row < num_rows; row++)
		{
			FIfld_get_text(in_form, IN_DBMS_OBJECTS_FIELD, row, 0, sizeof(name),
				(unsigned char *)name, &sel_flag, &r_pos);

			if (!RIScom_strcmp_ic(name, object))
			{
				FIfld_set_select(in_form, IN_DBMS_OBJECTS_FIELD, row, 0, 1);
				FIfld_get_row_offset(in_form, IN_DBMS_OBJECTS_FIELD, &offset);
				if (row < offset || row > offset + num_vis_rows)
				{
					FIfld_set_active_row(in_form, IN_DBMS_OBJECTS_FIELD, row,0);
				}
				continue;
			}

			if (sel_flag)
			{
				FIfld_set_select(in_form, IN_DBMS_OBJECTS_FIELD, row, 0, 0);
			}
		}
	}
	else
	{
		FIfld_get_num_rows(in_form, IN_DBMS_OBJECTS_FIELD, &num_rows);
		for (row = 0; row < num_rows; row++)
		{
			FIfld_get_select(in_form, IN_DBMS_OBJECTS_FIELD, row, 0, &sel_flag);
			if (sel_flag)
			{
				FIfld_set_select(in_form, IN_DBMS_OBJECTS_FIELD, row, 0, 0);
			}
		}
	}
}

/******************************************************************************/

static void clear_dbms_objects_field(
	void)
{
	FRM_DBG(("clear_dbms_objects_field()\n"));
	FIfld_set_num_rows(in_form, IN_DBMS_OBJECTS_FIELD, 0);
}

/*******************************************************************************
******************** IN_DBMS_OBJECT_FIELD **************************************
*******************************************************************************/

static char *get_dbms_object_field()
{
	static	 char	dbms_object[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_dbms_object_field()\n"));

	RISfrm_get_field(in_form, IN_DBMS_OBJECT_FIELD, RIS_MAX_ID_SIZE,
		dbms_object);
	return dbms_object[0] ? dbms_object : NULL;
}

/******************************************************************************/

static void process_dbms_object_field()
{
	char *dbms_object;
	char *actual_dbms_object;
	FRM_DBG(("process_dbms_object_field()\n"));

	dbms_object = get_dbms_object_field();
	update_dbms_objects_field(dbms_object);

	actual_dbms_object = get_dbms_objects_field();
	if (actual_dbms_object && actual_dbms_object[0])
	{
		if (strcmp(dbms_object, actual_dbms_object))
		{
			update_dbms_object_field(actual_dbms_object);
		}
		update_object_field(actual_dbms_object);
		clear_columns_field();
		load_columns_field();
	}
	else
	{
		if (dbms_object && dbms_object[0])
		{
			update_object_field(dbms_object);
		}
		clear_columns_field();
	}
}

/******************************************************************************/

static void update_dbms_object_field(
	char	*dbms_object)
{
	FRM_DBG(("update_dbms_object_field(dbms_object:<%s>)\n", dbms_object));
	FIfld_set_text(in_form, IN_DBMS_OBJECT_FIELD, 0, 0, dbms_object, 0);
}

/******************************************************************************/

static void clear_dbms_object_field()
{
	FRM_DBG(("clear_dbms_object_field()\n"));
	FIfld_set_text(in_form, IN_DBMS_OBJECT_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** IN_OBJECT_FIELD *******************************************
*******************************************************************************/

static char *get_object_field()
{
	static	 char	object[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_object_field()\n"));

	RISfrm_get_field(in_form, IN_OBJECT_FIELD, RIS_MAX_ID_SIZE, object);
	return object[0] ? object : NULL;
}

/******************************************************************************/

static void process_object_field(
	void)
{
	char *dbms_object;
	FRM_DBG(("process_object_field()\n"));

	if (get_object_field() == NULL)
	{
		if ((dbms_object = get_dbms_object_field()) != NULL)
		{
			update_object_field(dbms_object);
		}
	}
}

/******************************************************************************/

static void update_object_field(
	char	*object)
{
	FRM_DBG(("update_object_field(object:<%s>)\n", object));
	FIfld_set_text(in_form, IN_OBJECT_FIELD, 0, 0, object, 0);
}

/******************************************************************************/

static void clear_object_field()
{
	FRM_DBG(("clear_object_field()\n"));
	FIfld_set_text(in_form, IN_OBJECT_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** IN_COLUMNS_FIELD ******************************************
*******************************************************************************/

static char *get_dbms_column_name(
	int row)
{
	int pos;
	int sel_flag;
	static  char column[RIS_MAX_ID_SIZE];

	column[0] = '\0';

	FIfld_get_text(in_form, IN_COLUMNS_FIELD, row, 0, sizeof(column),
		(unsigned char *)column, &sel_flag, &pos);
	return column[0] ? column : NULL;
}

/******************************************************************************/

static char *get_column_name(
	int row)
{
	int pos;
	int sel_flag;
	static  char column[RIS_MAX_ID_SIZE];

	column[0] = '\0';

	FIfld_get_text(in_form, IN_COLUMNS_FIELD, row, 1, sizeof(column),
		(unsigned char *)column, &sel_flag, &pos);
	return column[0] ? column : NULL;
}

/******************************************************************************/

static void update_column_name(
	int row,
	char *name)
{
	FRM_DBG(("update_column_name(row:%d name:<%s>)\n", row, STRING(name)));
	FIfld_set_text(in_form, IN_COLUMNS_FIELD, row, 1, name, 0);
}

/******************************************************************************/

static void process_columns_field(
	void)
{
	int row;
	int num_rows;
	char *dbms_column_name;
	FIfld_get_num_rows(in_form, IN_COLUMNS_FIELD, &num_rows);

	for (row = 0; row < num_rows; row++)
	{
		if (get_column_name(row) == NULL)
		{
			if ((dbms_column_name = get_dbms_column_name(row)) != NULL)
			{
				update_column_name(row, dbms_column_name);
			}
		}
	}
}

/******************************************************************************/

static void load_columns_field(
	void)
{
	int type;
	char *user;
	char *dbms_object;

	FRM_DBG(("load_columns_field()\n"));

	type = get_type_rollthru();
	if (type == INDEX)
	{
		FIg_disable(in_form, IN_COLUMNS_FIELD);
	}
	else
	{
		FIg_enable(in_form, IN_COLUMNS_FIELD);

		user = get_user_field();
		dbms_object = get_dbms_object_field();

		clear_columns_field();
		if (user && dbms_object)
		{
			update_msg_field(MSG(RISUTL_I_READING_DICTIONARY_TABLES));
			RISfrm_load_dbms_columns_mcf(user, dbms_object, in_form,
				IN_COLUMNS_FIELD);
			if (RIS_forms_error.error != RIS_SUCCESS && RISfrm_report_error())
			{
				switch(RIS_forms_error.error)
				{
				}
			}
			clear_msg_field();
		}
	}
}

/******************************************************************************/

static void clear_columns_field(
	void)
{
	FRM_DBG(("clear_columns_field()\n"));
	FIfld_set_num_rows(in_form, IN_COLUMNS_FIELD, 0);
}

/*******************************************************************************
******************** IN_DISABLE_GROUP ******************************************
*******************************************************************************/

extern void RISfrm_disable_in_form()
{
	FRM_DBG(("disable_in_form()\n"));

	VALID_FORM_CHECK(in_form);

	FIg_disable(in_form, FI_RESET);
	FIg_disable(in_form, FI_EXECUTE);
	FIg_disable(in_form, IN_DISABLE_GROUP);
}

/******************************************************************************/

extern void RISfrm_enable_in_form()
{
	FRM_DBG(("enable_in_form()\n"));

	VALID_FORM_CHECK(in_form);

	FIg_enable(in_form, FI_RESET);
	FIg_enable(in_form, FI_EXECUTE);
	FIg_enable(in_form, IN_TYPE_ROLLTHRU);
	FIg_enable(in_form, IN_USER_FIELD);
	FIg_enable(in_form, IN_DBMS_OBJECTS_FIELD);
	FIg_enable(in_form, IN_DBMS_OBJECT_FIELD);
	FIg_enable(in_form, IN_OBJECT_FIELD);
	/* Fix TR # 439503065 --kmreddy */
	FIf_set_start_seq(in_form, IN_USER_FIELD );
}

/*******************************************************************************
******************** EXECUTE BUTTON ********************************************
*******************************************************************************/

static void process_execute_button()
{
	int		m1;
	int		m2;
	int		m3;
	int		m4;
	int		row;
	int		num_rows;
	char	*ptr;
	char	*cmd;
	char	*type;
	char	*column;
	char	*dbms_obj_name;
	char	schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("process_execute_button()\n"));

	cmd = include_command;

	RISget_default_schema_name(schname);

	cmd += sprintf(cmd, "ALTER SCHEMA %s INCLUDE ", schname);

	switch(get_type_rollthru())
	{
		case INDEX:
			type = "INDEX";
			m1 = RISUTL_I_DBMS_INDEX_MUST_BE_SPEC;
			m2 = RISUTL_I_INDEX_MUST_BE_SPEC;
			m3 = RISUTL_I_INCLUDING_INDEX;
			m4 = RISUTL_I_INDEX_INCLUDED;
			break;

		case VIEW:
			type = "VIEW";
			m1 = RISUTL_I_DBMS_VIEW_MUST_BE_SPEC;
			m2 = RISUTL_I_VIEW_MUST_BE_SPEC;
			m3 = RISUTL_I_INCLUDING_VIEW;
			m4 = RISUTL_I_VIEW_INCLUDED;
			break;

		case TABLE:
		default:
			type = "TABLE";
			m1 = RISUTL_I_DBMS_TABLE_MUST_BE_SPEC;
			m2 = RISUTL_I_TABLE_MUST_BE_SPEC;
			m3 = RISUTL_I_INCLUDING_TABLE;
			m4 = RISUTL_I_TABLE_INCLUDED;
			break;
	}
	cmd += sprintf(cmd, "%s ", type);

	if ((ptr = get_user_field()) == NULL)
	{
		strcpy(in_msg->str, MSG(RISUTL_I_USER_MUST_BE_SPEC));
		in_msg->label[in_msg->count++] = IN_USER_FIELD;
		in_msg->label[in_msg->count++] = IN_USER_TEXT;
		FIfld_pos_cursor(in_form, IN_USER_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}
	cmd += sprintf(cmd, "%s.", ptr);

	if ((dbms_obj_name = get_dbms_object_field()) == NULL)
	{
		strcpy(in_msg->str, MSG(m1));
		in_msg->label[in_msg->count++] = IN_DBMS_OBJECT_TEXT;
		in_msg->label[in_msg->count++] = IN_DBMS_OBJECT_FIELD;
		FIfld_pos_cursor(in_form, IN_DBMS_OBJECT_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}
	cmd += sprintf(cmd, "%s", dbms_obj_name);

	if ((ptr = get_object_field()) == NULL)
	{
		strcpy(in_msg->str, MSG(m2));
		in_msg->label[in_msg->count++] = IN_OBJECT_TEXT;
		in_msg->label[in_msg->count++] = IN_OBJECT_FIELD;
		FIfld_pos_cursor(in_form, IN_OBJECT_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}
	cmd += sprintf(cmd, " AS %s", ptr);


	FIfld_get_num_rows(in_form, IN_COLUMNS_FIELD, &num_rows);
	if (num_rows > 0)
	{
		cmd += sprintf(cmd, "(");

		for (row = 0; row < num_rows; row++)
		{
			column = get_column_name(row);
			cmd += sprintf(cmd, "%s", column);
			if (row < num_rows - 1)
			{
				cmd += sprintf(cmd, ", ");
			}
		}

		cmd += sprintf(cmd, ") ");
	}

	FRM_DBG(("%s\n", include_command));

	if (RISfrm_user_exec_in_form &&
		RISfrm_user_exec_in_form(in_form, include_command) == 0)
			return;

	sprintf(in_msg->str, MSG(m3), dbms_obj_name);
	update_msg_field(in_msg->str);
	RISfrm_execute_command(include_command);
	clear_msg_field();
	in_msg->str[0] = '\0';

	if (SQLCODE)
	{
		RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
		if (RISfrm_report_error() == 0) return;
		switch(SQLCODE)
		{
			case RIS_E_OBJECT_INCLUDED:
				in_msg->label[in_msg->count++] = IN_OBJECT_TEXT;
				in_msg->label[in_msg->count++] = IN_OBJECT_FIELD;
				strcpy(in_msg->str, MSG(RISUTL_I_ENTER_UNIQUE_TABNAME));
				break;
		}
		return;
	}

	sprintf(in_msg->str, MSG(m4), dbms_obj_name);
	update_msg_field(in_msg->str);

	RISfrm_object_list_up_to_date = 0;
	RISfrm_dbms_obj_list_up_to_date = 0;

	load_dbms_objects_field();
	clear_dbms_object_field();
	clear_object_field();
	clear_columns_field();
	if (RISfrm_dd_form_displayed())
	{
		RISfrm_load_dd_objects_mcf(schname);
	}
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));
	RISfrm_erase_in_form();
	if (RISfrm_dd_form_displayed())
	{
		RISfrm_clear_dd_include_button();
	}
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	RISfrm_clear_in_form();
	DISPLAY_HELP_BUTTON(in_form);

	RISfrm_call_user_init_in_form();

	load_user_field();
	load_user_field_list();
	load_dbms_objects_field();
	clear_dbms_object_field();
	clear_object_field();
	clear_columns_field();
}

/*******************************************************************************
******************** IE FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_in_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,				process_cancel_button		},
		{	FI_RESET,				process_reset_button		},
		{	FI_EXECUTE,				process_execute_button		},
		{	IN_TYPE_ROLLTHRU,		process_type_rollthru		}, 
		{	IN_USER_FIELD,			process_user_field			}, 
		{	IN_DBMS_OBJECTS_FIELD,	process_dbms_objects_field	}, 
		{	IN_DBMS_OBJECT_FIELD,	process_dbms_object_field	}, 
		{	IN_OBJECT_FIELD,		process_object_field		}, 
		{	IN_COLUMNS_FIELD,		process_columns_field		}, 
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_in_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(in_form);

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

extern void RISfrm_call_user_init_in_form()
{
	FRM_DBG(("RISfrm_call_user_init_in_form()\n"));

	if (RISfrm_user_init_in_form)
	{
		FRM_DBG(("calling RISfrm_user_init_in_form()\n"));
		RISfrm_user_init_in_form(in_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_in_form(
	int	called_by_user,
	int	disable_flag)
{
	int		sts;
	char	def_schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("RISfrm_display_in_form(called_by_user:%d disable_flag:%d)\n",
		called_by_user, disable_flag));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!in_form)
	{
		sts = FIf_new(IN_FORM, IN_FORM_FILE, RISfrm_notification_routine,
			&in_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_IC_FORM, sts);
			return RIS_forms_error.error;
		}
#if defined(WIN32)
		FIf_SetDefaultButton(in_form, FI_EXECUTE);
		FIg_set_text(in_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));

#endif
	}

	if (!RISfrm_in_form_displayed())
	{
		in_msg->str[0] = 0;
		in_msg->count = 0;
		in_msg->msg_fld_label = IN_MSG_FIELD;
		in_msg->fp = in_form;

		DISPLAY_HELP_BUTTON(in_form);

		if (disable_flag)
		{
			RISfrm_disable_in_form();
		}
		else
		{
			RISfrm_enable_in_form();
		}

		if (called_by_user)
		{
			RISget_default_schema_name(def_schname);
			if (!def_schname[0])
			{
				RISfrm_form_errhandle(RISUTL_E_FORM_NO_SCHEMA, 0);
				return RIS_forms_error.error;
			}

			RISfrm_call_user_init_in_form();
		}

		update_text();

		sts = FIf_display(in_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_IC_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern void RISfrm_update_in_form(
	RISfrm_object *object)
{
	/*
	**	Note: object is unused for this form.
	*/
	FRM_DBG(("RISfrm_update_in_form(object:0x%x)\n", object));

	VALID_FORM_CHECK(in_form);

/*	RISfrm_dbms_obj_list_up_to_date = 0; */
/*	RISfrm_dbms_user_list_up_to_date = 0; */

	load_user_field();
	load_user_field_list();
	load_dbms_objects_field();
	clear_dbms_object_field();
	clear_object_field();
	clear_columns_field();
}

/******************************************************************************/

extern void RISfrm_clear_in_form()
{
	FRM_DBG(("RISfrm_clear_in_form()\n"));

	VALID_FORM_CHECK(in_form);

	clear_type_rollthru();
	update_text();

	clear_user_field();
	clear_user_field_list();
	clear_dbms_objects_field();
	clear_dbms_object_field();
	clear_object_field();
	clear_columns_field();
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISfrm_in_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_in_form_displayed()\n"));
	if (!in_form)
	{
		return(0);
	}
	FIf_is_displayed(in_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_in_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_in_form()\n"));

	if (RISfrm_in_form_displayed())
	{
		sts = FIf_erase(in_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_IC_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_in_form();

		if (RISfrm_dd_form_displayed())
		{
			RISfrm_clear_dd_include_button();
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_include_form_displayed()
{
	return RISfrm_in_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_include_form()
{
	return RISfrm_display_in_form(CALLED_BY_USER, DISPLAY_ENABLED);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_include_form()
{
	return RISfrm_erase_in_form();
}

/******************************************************************************/
