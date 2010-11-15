/* Do not alter this SPC information: $Revision: 1.8.3.1 $ */
/*
**	NAME:							guiin.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/90
**	ABSTRACT:
**		The code to process the schema manager form.
**	
**	REVISION HISTORY:
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
**
**		11/94:	Added support for INTERNATIONALIZATION.  Rick Kramer
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include <limits.h>
#if defined(unix) && !defined(__clipper__)
#include <unistd.h>
#endif
#include "risver.h"
#include "rislimit.h"
#include "ris_err.h"
#include "risstjmp.h"
#include "gui.h"
#include <FIdyn.h>

/*
**	FUNCTION PROTOTYPES
*/
#define guiin_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "comjmp.prt"
#include "event.prt"
#include "fi.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#include "guihelp.prt"
#endif
#include "guicfrm.prt"
#include "guidbg.prt"
#include "guierror.prt"
#include "guiexec.prt"
#include "guifile.prt"
#include "guiin.prt"
#include "guimsg.prt"
#include "guintfy.prt"
#include "guiopts.prt"
#include "guiquery.prt"
#include "guiset.prt"
#include "guishow.prt"
#include "guistack.prt"
#include "guisrch.prt"
#include "guitran.prt"
#include "guiutls.prt"
#include "ucocmd.prt"
#include "ucoumsg.prt"
#include "ucoerrbx.prt"
#include "ris.prt"
#include "sys.prt"
#include "comisfn.prt"

/*
**	DEFINES
*/
#define MAX_ROWS_IN_FIELD	5000


/*
**	VARIABLES
*/
static  int		gui_file_info_up_to_date = 0;
static  ris_db_info	*gui_dbs = NULL;
static  int		gui_dbs_cnt = 0;
static  ris_schema_info	*gui_schemas = NULL;
static  int		gui_schemas_cnt = 0;
static	int			debug_enabled = 0;
static	char		query_buffer[10000];
static	query_s		query;
static	options_s	options = 
{
	H_SCROLL_COL,
	FETCH_SCREEN_APPEND
};
static struct dbms_info_s
{
	char	*name;
	int		bitmask;
} dbms_info[] =
{
	{	"INFORMIX",	RIS_ENABLE_INFORMIX	},
	{	"ORACLE",	RIS_ENABLE_ORACLE	},
	{	"INGRES",	RIS_ENABLE_INGRES	},
	{	"DB2",		RIS_ENABLE_DB2		},
	{	"RDB",		RIS_ENABLE_RDB		},
	{	"SYBASE",	RIS_ENABLE_SYBASE	},
	{	"SQLDS",	RIS_ENABLE_SQLDS	},
	{	"OS400",	RIS_ENABLE_OS400	},
	{	"MSSQL",	RIS_ENABLE_MSSQL	},
/*
	{	"ADABAS",	RIS_ENABLE_ADABAS	},
*/
};
static int dbms_info_cnt = sizeof(dbms_info)/sizeof(struct dbms_info_s);

static	int			result_field_column_offset = 0;
static	int			result_field_vis_rows = 0;
static	int			result_field_vis_chars = 0;
static	int			fetching = 0;
static	Form		in_form = 0;
static	ris_gui_msg	*in_msg = &RIS_gui_msgs[IN_FORM_MSG];

/*
**	FUNCTIONS
*/

/******************************************************************************/
static int compare_dtype(
        ris_db_info *dbs1,
        ris_db_info *dbs2)
{
        GUI_DBG(("compare_dbs() in guiin.c dbs1->dbid:%d\n", dbs1->dbid));
        GUI_DBG(("compare_dbs() in guiin.c dbs2->dbid:%d\n",dbs2-> dbid));
        if (dbs1->dbid == dbs2->dbid)
                return 0;
        else
                return 1;
}
/******************************************************************************/
static int compare_dbs(
        ris_db_info *dbs1,
        ris_db_info *dbs2)
{
        GUI_DBG(("compare_dbs() in guiin.c dbs1->dbid:%d\n", dbs1->dbid));
        GUI_DBG(("compare_dbs() in guiin.c dbs2->dbid:%d\n",dbs2-> dbid));
        if (dbs1->dbid  >  dbs2->dbid)
                return 1;
        else
                return 0;
}
/******************************************************************************/

static int compare_schemas(
        ris_schema_info *schema1,
        ris_schema_info *schema2)
{
        GUI_DBG(("compare_schemas() in guiin.c schema1->schname:%s\n", schema1->schname));
        GUI_DBG(("compare_schemas() in guiin.c schema2->schname:%s\n",schema2-> schname));
        return(strcmp(schema1->schname, schema2->schname));
}
/******************************************************************************/

static int compare_schemas_dbid(
        ris_schema_info *schema1,
        ris_schema_info *schema2)
{
        GUI_DBG(("compare_schemas() in guiin.c schema1->schname:%s\n", schema1->schname));
        GUI_DBG(("compare_schemas() in guiin.c schema2->schname:%s\n",schema2-> schname));
        return(strcmp(schema1->schname, schema2->schname));
}
/******************************************************************************/
static int   read_schema_file()
{
	void			*temp;
	ris_db_info		*dbs = NULL;
	ris_schema_info	*schemas = NULL;

	GUI_DBG(("read_schema_file()\n"));

	while (gui_dbs)
	{
		temp = gui_dbs;
		gui_dbs = gui_dbs->next;
		free(temp);
	}
	gui_dbs_cnt = 0;

	while (gui_schemas)
	{
		temp = gui_schemas;
		gui_schemas = gui_schemas->next;
		free(temp);
	}
	gui_schemas_cnt = 0;

	RISget_schema_file(NULL, &dbs, &schemas, NULL);
	GUI_DBG(("RISget_schema_file:returning \n"));
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		GUI_DBG(("RISget_schema_file:returning :%d\n",
			RISgui_report_error));
		return 1;
	}

	while(dbs)
	{
		ris_db_info	**dbsp;
		ris_db_info	*temp_db;
		ris_db_info	**max_dbsp;

		max_dbsp = &dbs;
		dbsp = &dbs->next;
		while(*dbsp)
		{
			if (compare_dbs((*dbsp), (*max_dbsp)) > 0)
			{
				max_dbsp = dbsp;
			}
			dbsp = &(*dbsp)->next;
		}

		temp_db = *max_dbsp;
		(*max_dbsp) = (*max_dbsp)->next;
		temp_db->next = gui_dbs;
		gui_dbs = temp_db;
		gui_dbs_cnt++;
	}

	while(schemas)
	{
		ris_schema_info	**schemasp;
		ris_schema_info	*temp_schema;
		ris_schema_info	**max_schemasp;

		max_schemasp = &schemas;
		schemasp = &schemas->next;
		while(*schemasp)
		{
			if (compare_schemas((*schemasp), (*max_schemasp)) > 0)
			{
				max_schemasp = schemasp;
			}
			schemasp = &(*schemasp)->next;
		}

		temp_schema = *max_schemasp;
		(*max_schemasp) = (*max_schemasp)->next;
		temp_schema->next = gui_schemas;
		gui_schemas = temp_schema;
		gui_schemas_cnt++;
	}
	gui_file_info_up_to_date = 1;

	CLEAR_ERROR;

	GUI_DBG(("read_schema_file:returning :%d\n",RIS_SUCCESS));
	return RIS_SUCCESS;
}

/******************************************************************************/

static ris_schema_info *get_schema(
	char	*schname)
{
	ris_schema_info	key;
	ris_schema_info	*schema = NULL;


	GUI_DBG(("get_schema(schname:<%s>)\n", schname?schname:"NULL"));

	if (!schname) return NULL;
	
	if (gui_file_info_up_to_date == 0)
	{
		GUI_DBG(("I am going to read schema file\n"));
		read_schema_file();
	}

	strcpy(key.schname, schname);
	GUI_DBG((" after read_schema_file(schname:<%s>)\n", schname?schname:"NULL"));
	GUI_DBG((" after read_schema_file(key.schname:<%s>)\n", key.schname));

	for (schema = gui_schemas; schema; schema = schema->next)
	{
	GUI_DBG((" I am in schema:<0x%x>)\n", schema));
		if (!compare_schemas_dbid(schema, &key))
		{
			break;
		}
	}

	GUI_DBG(("get_schema:returning schema->dbid:%d\n", schema->dbid));
	GUI_DBG(("get_schema:returning schema->schname:%s\n", schema->schname));

	return schema;
}
/******************************************************************************/
static get_db(
        unsigned short dbid)
{
        ris_db_info     key;
        ris_db_info     *dbs = NULL;

        GUI_DBG(("get_db() in guiexec.rc dbid:%d\n", dbid));

        key.dbid = dbid;

        GUI_DBG(("get_db() in guiexec.rc dbid:%d\n", key.dbid));

        for (dbs = gui_dbs; dbs; dbs = dbs->next)
        {
                if (!compare_dtype(dbs, &key))
                {
                        GUI_DBG(("get_db() in guiin.c dbs->dtype:%c\n",
                        dbs->dtype));
                        break;
                }
        }

        GUI_DBG(("get_db() in guiexec.rc dbs->dtype:<%c>\n", dbs->dtype));
        return dbs->dtype;
}
/*******************************************************************************
************** DEBUG ***********************************************************
*******************************************************************************/

extern void RISgui_enable_debug()
{
	debug_enabled = 1;
}

/*******************************************************************************
************** IN_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	GUI_DBG(("update_msg_field(msg:<%s>)\n", msg));
	RISgui_set_message_text(in_form, IN_MSG_FIELD, (char *)msg);
}

/******************************************************************************/

static void clear_msg_field()
{
	GUI_DBG(("clear_msg_field()\n"));
	FIfld_set_text(in_form, IN_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
************** IN_DEFAULT_SCHEMA_FIELD *****************************************
*******************************************************************************/

static void update_default_schema_field()
{
	char def_schname[RIS_MAX_ID_SIZE];

	GUI_DBG(("update_default_schema_field()\n"));

	RISget_default_schema_name(def_schname);
	FIfld_set_text(in_form, IN_DEFAULT_SCHEMA_FIELD, 0, 0, def_schname, 0);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
		GUI_DBG(("update_default_schema_field: returning\n"));
		return;
	}

	GUI_DBG(("update_default_schema_field: returning\n"));
}

/******************************************************************************/

static void update_default_schema_field_list(
	int display_message)
{
	int i;
	int count;
	char (*buffer)[RIS_MAX_ID_SIZE];

	GUI_DBG(("update_default_schema_field_list(display_message:%d)\n",
		display_message));

	if (display_message)
	{
		update_msg_field(MSG(RISUTL_I_READING_SCHFILE));
	}
	count = 0;
	buffer = NULL;
	RISget_schema_names(buffer, &count);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
		if (display_message)
		{
			clear_msg_field();
		}
		GUI_DBG(("update_default_schema_field: returning\n"));
		return;
	}
	
	if (count)
	{
		buffer = (char (*)[RIS_MAX_ID_SIZE])malloc(count * RIS_MAX_ID_SIZE);
		if (buffer == NULL)
		{
			RISgui_errhandle(RISUTL_E_MALLOC, 0);
			RISgui_report_error();
			if (display_message)
			{
				clear_msg_field();
			}
			GUI_DBG(("update_default_schema_field: returning\n"));
			return;
		}

		RISget_schema_names(buffer, &count);
		if (SQLCODE != RIS_SUCCESS)
		{
			RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
			RISgui_report_error();
			if (display_message)
			{
				clear_msg_field();
			}
			GUI_DBG(("update_default_schema_field: returning\n"));
			return;
		}

	}

	FIfld_set_list_num_rows(in_form, IN_DEFAULT_SCHEMA_FIELD, 0, count);
	for (i = 0; i < count; i++)
	{
		FIfld_set_list_text(in_form, IN_DEFAULT_SCHEMA_FIELD, i, 0,buffer[i],0);
	}

	if (buffer)
	{
		free(buffer);
	}

	if (display_message)
	{
		clear_msg_field();
	}

	GUI_DBG(("update_default_schema_field_list: returning\n"));
}

/******************************************************************************/

static void process_default_schema_field()
{

	int r_pos;
	int sel_flag;
	char def_schname[RIS_MAX_ID_SIZE];
	char msg[255];
	ris_schema_info *schema = NULL;
	unsigned char dtype;

	GUI_DBG(("process_default_schema_field()\n"));

	FIfld_get_text(in_form, IN_DEFAULT_SCHEMA_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)def_schname, &sel_flag, &r_pos);

	if (!def_schname[0])
	{
		GUI_DBG(("bad def_schname in guiin.c\n"));
		GUI_DBG(("process_default_schema_field: !def_schname[0]: returning\n"));
		return;
	}

	sprintf(msg, MSG(RISUTL_I_SETTING_DEF_SCH), def_schname);
	update_msg_field((const char *)msg);

	schema = get_schema(def_schname);
	GUI_DBG(("guiin.c schema:0x%x\n", schema));
	dtype = get_db(schema->dbid);
	GUI_DBG(("guiin.c dtype:%c\n", dtype));

	RISgui_set_default_schema(def_schname, dtype);
	
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
	}
	else
	{
		sprintf(in_msg->str, MSG(RISUTL_I_DEF_SCH_SET), def_schname);
	}

	clear_msg_field();

	update_default_schema_field();

	GUI_DBG(("process_default_schema_field:returning\n"));
}

/*******************************************************************************
************** IN_QUERY_FIELD **************************************************
*******************************************************************************/

static int get_query_field()
{
	int i;
	int r_pos;
	int	sel_flag;
	int num_row;
	int num_char;
	int chars_read;

	GUI_DBG(("get_query_field()\n"));
	FIfld_get_num_rows(in_form, IN_QUERY_FIELD, &num_row);

	chars_read = 0;
	for (i = 0; i < num_row; i++)
	{
		FIfld_get_text_length(in_form, IN_QUERY_FIELD, i, 0, &num_char);

		if (chars_read + num_char >= sizeof(query_buffer))
		{
			GUI_DBG(("get_query_field: returning RISUTL_E_QUERY_TOO_LARGE\n"));
			return RISUTL_E_QUERY_TOO_LARGE;
		}

		if (num_char)
		{
			FIfld_get_text(in_form, IN_QUERY_FIELD, i, 0, num_char,
				(unsigned char *)(query_buffer + chars_read),&sel_flag,&r_pos);
			chars_read += num_char;
		}

		if (i < num_row - 1)
		{
#ifdef old
			while(chars_read > 0 &&
				  (query_buffer[chars_read - 1] == '\0' ||
				   RIScom_isspace(query_buffer[chars_read - 1])))
			{
				chars_read--;
			}
			query_buffer[chars_read++] = '\n';
#else
			if (chars_read > 0 && query_buffer[chars_read - 1] == '\0')
			{
				query_buffer[chars_read - 1] = '\n';
			}
#endif
		}
	}
	query_buffer[chars_read] = '\0';

	GUI_DBG(("get_query_field:query_buffer:<%s>\n", query_buffer));
	GUI_DBG(("get_query_field:returning 0\n"));

	return 0;
}

/******************************************************************************/

static int query_specified()
{
	char *ptr;
	int return_sts;

	GUI_DBG(("query_specified()\n"));

	for (ptr = query_buffer; *ptr && RIScom_isspace(*ptr); ptr++);
	return_sts = *ptr ? 1 : 0;	

	GUI_DBG(("query_specified:returning %d\n", return_sts));
	return return_sts;
}

/******************************************************************************/

static void set_query_field()
{
	int row;
	char *ptr;
	char *nl;

	GUI_DBG(("set_query_field()\n"));

	FIfld_set_num_rows(in_form, IN_QUERY_FIELD, 0);

	row = 0;
	ptr = query_buffer;
	while(*ptr)
	{
		if ((nl = strchr(ptr, '\n')) != NULL)
		{
			*nl = '\0';
			FIfld_set_text(in_form, IN_QUERY_FIELD, row++, 0, ptr, 0);
			ptr = nl + 1;
		}
		else
		{
			FIfld_set_text(in_form, IN_QUERY_FIELD, row, 0, ptr, 0);
			break;
		}
	}

	GUI_DBG(("set_query_field:returning\n"));
}

/******************************************************************************/

static void clear_query_field()
{
	GUI_DBG(("clear_query_field()\n"));

	FIfld_set_num_rows(in_form, IN_QUERY_FIELD, 0);

	GUI_DBG(("clear_query_field:returning\n"));
}

/*******************************************************************************
************** IN_RESULT_FIELD *************************************************
*******************************************************************************/

static void process_result_field(
	void)
{
	GUI_DBG(("process_result_field()\n"));
	GUI_DBG(("process_result_field:returning\n"));
}

/******************************************************************************/

static int append_result_field()
{
	int num_row;

	FIfld_get_num_rows(in_form, IN_RESULT_FIELD, &num_row);
	if (num_row == MAX_ROWS_IN_FIELD)
	{
		GUI_DBG(("append_result_field:returning RISUTL_E_MAX_ROWS_FETCHED\n"));
		return RISUTL_E_MAX_ROWS_FETCHED;
	}

	GUI_DBG(("append_result_field:returning 0\n"));
	return 0;
}

/******************************************************************************/

static void clear_result_field()
{
	GUI_DBG(("clear_result_field()\n"));

	FIfld_set_num_rows(in_form, IN_RESULT_FIELD, 0);
	FIscrl_set_view(in_form, IN_RESULT_SCROLLBAR, 1.0);
	GUI_DBG(("clear_result_field:returning\n"));
}

/*******************************************************************************
************** IN_RESULT_HEADER_FIELD ******************************************
*******************************************************************************/


extern void update_result_header_field()
{
	int num_frm_cols;
	int i;

	GUI_DBG(("update_result_header_field()\n"));

	FImcf_get_num_cols(in_form,IN_RESULT_HEADER_FIELD,&num_frm_cols);
	for (i = 0; i < num_frm_cols; i++)
		FIfld_set_active_char(in_form, IN_RESULT_HEADER_FIELD, i,0,0);

	GUI_DBG(("update_result_header_field:returning\n"));
}

/******************************************************************************/

extern void clear_result_header_field()
{
	int num_frm_cols;
	int i;

	GUI_DBG(("clear_result_header_field()\n"));
	FImcf_get_num_cols(in_form,IN_RESULT_HEADER_FIELD,&num_frm_cols);
	for (i = 0; i < num_frm_cols; i++)
		FIfld_set_text(in_form, IN_RESULT_HEADER_FIELD, 0, i, "", 0);

	GUI_DBG(("clear_result_header_field:returning\n"));
}

/*******************************************************************************
************** FI_CANCEL_BUTTON ************************************************
*******************************************************************************/

static void process_cancel_button()
{
	GUI_DBG(("process_cancel_button()\n"));

	if (!RISgui_close_transactions())
	{
		GUI_DBG(("process_cancel_button:user cancel:returning\n"));
		return;
	}
	RISgui_erase_in_form();
	GUI_DBG(("process_cancel_button:returning\n"));
}


/*******************************************************************************
************** FI_HELP_BUTTON **************************************************
*******************************************************************************/

#if defined(WIN32)
static void process_help_button()
{
	GUI_DBG(("process_help_button()\n"));

	RISgui_display_help(in_form);

	GUI_DBG(("process_help_button:returning\n"));
}
#endif

/*******************************************************************************
************** IN_EXEC_QUERY_BUTTON ********************************************
*******************************************************************************/

static void process_exec_query_button()
{
	int	sts;
	int rows;
	char *begin_comment;

	GUI_DBG(("process_exec_query_button()\n"));

	RIS_gui_num_rows = 0;
	if ((sts = get_query_field()) != 0)
	{
		RISgui_errhandle(sts, 0);
		RISgui_report_error();
		strcpy(in_msg->str, MSG(RISUTL_I_EXECUTE_QUERY_FAILED));
		GUI_DBG(("process_exec_query_button:bad query: returning\n"));
		return;
	}

	if (!query_specified())
	{
		RISgui_errhandle(RISUTL_E_NO_QUERY, 0);
		RISgui_report_error();
		strcpy(in_msg->str, MSG(RISUTL_I_EXECUTE_QUERY_FAILED));
		GUI_DBG(("process_exec_query_button:no query: returning\n"));
		return;
	}

	clear_result_header_field();
	clear_result_field();
	RISgui_free_query(&query);
	FIg_enable(in_form, IN_RESULT_GROUP);

	RISgui_query_stack_push(query_buffer);

	update_prev_query_button();
	update_next_query_button();
	RIS_gui_num_rows = 0;

	if ((begin_comment = RISuco_eat_comment(query_buffer)) != NULL)
	{
		*begin_comment = '\0';
	}
	if (RISgui_prepare_query(query_buffer))
	{
		strcpy(in_msg->str, MSG(RISUTL_I_PREP_FAILED));
		GUI_DBG(("process_exec_query_button:prepare failed: returning\n"));
		return;
	}
	if (RISgui_describe_query(&query,in_form))	
	{
		strcpy(in_msg->str, MSG(RISUTL_I_DESCRIBE_FAILED));
		GUI_DBG(("process_exec_query_button:prepare failed: returning\n"));
		return;
	}

	GUI_DBG(("process_exec_query_button:query.desc.sqld:%d\n",query.desc.sqld));
	if (query.desc.sqld == 0)
	{
		FIg_disable(in_form, IN_RESULT_GROUP);

		if (RISgui_execute_query(&query))
		{
			strcpy(in_msg->str, MSG(RISUTL_I_EXECUTE_FAILED));
			GUI_DBG(("process_exec_query_button:returning\n"));
			return;
		}

		update_default_schema_field();
		update_default_schema_field_list(0);

		if (query.status == END_OF_DATA)
		{
			strcpy(in_msg->str, MSG(RISUTL_I_NO_ROWS_UPDATED));
		}
		else
		{
			strcpy(in_msg->str, MSG(RISUTL_I_RIS_SUCCESS_MSG));
		}

		if (RISgui_clear_query(&query))
		{
			strcpy(in_msg->str, MSG(RISUTL_I_CLEAR_FAILED));
			GUI_DBG(("process_exec_query_button:returning\n"));
			return;
		}
	}
	else
	{
		initialize_result_scrollbar();

		FIg_enable(in_form, IN_QUERY_GROUP);

		update_result_header_field();

		if (RISgui_execute_query(&query))
		{
			strcpy(in_msg->str, MSG(RISUTL_I_EXECUTE_FAILED));
			GUI_DBG(("process_exec_query_button:returning\n"));
			return;
		}

		rows = 0;
		fetching = 1;
		update_query_buttons();
		while(1)
		{
			if (RISgui_fetch_query(&query,in_form))
			{
				fetching = 0;
				update_query_buttons();
				GUI_DBG(("process_exec_query_button:returning\n"));
				return;
			}
			if (query.status == END_OF_DATA)
			{
				fetching = 0;
				update_query_buttons();
				strcpy(in_msg->str, MSG(RISUTL_I_END_OF_DATA_FOUND));
				if (RISgui_clear_query(&query))
				{
					strcpy(in_msg->str, MSG(RISUTL_I_CLEAR_FAILED));
					GUI_DBG(("process_exec_query_button:returning\n"));
					return;
				}
				break;
			}
			else
			{
				if ((options.fetch_mode == FETCH_SCREEN_APPEND ||
					 options.fetch_mode == FETCH_SCREEN_OVERWRITE) &&
					rows == result_field_vis_rows -1)
				{
					strcpy(in_msg->str, MSG(RISUTL_I_MORE_TO_FOLLOW));
					break;
				}
				if ((sts = append_result_field()) != 0)
				{
					RISgui_errhandle(sts, 0);
					RISgui_report_error();
					fetching = 0;
					update_query_buttons();
					RISgui_clear_query(&query);
					GUI_DBG(("process_exec_query_button:returning\n"));
					return;
				}
				rows++;
			}
		}
	}
	GUI_DBG(("process_exec_query_button:returning\n"));
}

/*******************************************************************************
************** IN_CONT_QUERY_BUTTON *******************************************
*******************************************************************************/

static void process_cont_query_button()
{
	int sts;
	int num_rows;

	GUI_DBG(("process_cont_query_button()\n"));

	if (options.fetch_mode == FETCH_SCREEN_OVERWRITE)
	{
		RIS_gui_num_rows = 0;
		FIfld_set_num_rows(in_form, IN_RESULT_FIELD, 0);
	}

	num_rows = 0;
	while(num_rows < result_field_vis_rows)
	{
		if ((sts = append_result_field()) != 0)
		{
			RISgui_errhandle(sts, 0);
			RISgui_report_error();
			fetching = 0;
			update_query_buttons();
			RISgui_clear_query(&query);
			GUI_DBG(("process_cont_query_button:returning\n"));
			return;
		}
		num_rows++;

		if (RISgui_fetch_query(&query,in_form))
		{
			fetching = 0;
			GUI_DBG(("process_cont_query_button:returning\n"));
			return;
		}
		if (query.status == END_OF_DATA)
		{
			fetching = 0;
			update_query_buttons();
			strcpy(in_msg->str, MSG(RISUTL_I_END_OF_DATA_FOUND));

			if (RISgui_clear_query(&query))
			{
				strcpy(in_msg->str, MSG(RISUTL_I_CLEAR_FAILED));
				GUI_DBG(("process_cont_query_button:returning\n"));
				return;
			}
			break;
		}
		else if (num_rows == result_field_vis_rows)
		{
			strcpy(in_msg->str, MSG(RISUTL_I_MORE_TO_FOLLOW));
			break;
		}
	}

	if (options.fetch_mode == FETCH_SCREEN_APPEND)
	{
		FIfld_get_num_rows(in_form, IN_RESULT_FIELD, &num_rows);
		FIfld_set_active_row(in_form, IN_RESULT_FIELD, num_rows-1,
			result_field_vis_rows);
	}

	GUI_DBG(("process_cont_query_button:returning\n"));
}

/*******************************************************************************
************** IN_ABORT_QUERY_BUTTON ******************************************
*******************************************************************************/

static void process_abort_query_button()
{
	GUI_DBG(("process_abort_query_button()\n"));

	fetching = 0;
	update_query_buttons();
	strcpy(in_msg->str, MSG(RISUTL_I_QUERY_ABORTED));

	if (RISgui_clear_query(&query))
	{
		strcpy(in_msg->str, MSG(RISUTL_I_CLEAR_FAILED));
		GUI_DBG(("process_abort_query_button:returning\n"));
		return;
	}

	GUI_DBG(("process_abort_query_button:returning\n"));
}

/*******************************************************************************
************** IN_SAVE_QUERY_BUTTON ********************************************
*******************************************************************************/

static void process_save_query_button()
{
	int sts;
	char filename[256];
	FILE *fp;

	GUI_DBG(("process_save_query_button()\n"));

	if ((sts = get_query_field()) != 0)
	{
		RISgui_errhandle(sts, 0);
		RISgui_report_error();
		strcpy(in_msg->str, MSG(RISUTL_I_SAVE_QUERY_FAILED));
		GUI_DBG(("process_save_query_button:bad query: returning\n"));
		return;
	}

	if (!query_specified())
	{
		RISgui_errhandle(RISUTL_E_NO_QUERY, 0);
		RISgui_report_error();
		strcpy(in_msg->str, MSG(RISUTL_I_SAVE_QUERY_FAILED));
		GUI_DBG(("process_save_query_button:no query: returning\n"));
		return;
	}

	if (RISgui_get_filename(RISUTL_I_SAVE, 
		"Queries (*.qry)\0*.qry\0All Files (*.*)\0*.*\0",
		filename, sizeof(filename)))
	{
		GUI_DBG(("process_save_query_button:filename:<%s>\n", filename));

#if defined(unix)
		if (!access(filename, F_OK) &&
			!RISgui_confirm(MSG(RISUTL_I_FILE_EXISTS_REPLACE)))
		{
			GUI_DBG(("process_save_query_button: don't replace: returning\n"));
			return;
		}
#endif
		if ((fp = fopen(filename, "w")) == NULL)
		{
			RISgui_errhandle(RISUTL_E_OPEN_FILE_WRITE, 0);
			RISgui_report_error();

			strcpy(in_msg->str, MSG(RISUTL_I_SAVE_QUERY_FAILED));

			GUI_DBG(("process_save_query_button:fopen failed: returning\n"));
			return;
		}

		fputs(query_buffer, fp);

		fclose(fp);
	}

	GUI_DBG(("process_save_query_button:returning\n"));
}

/*******************************************************************************
************** IN_OPEN_QUERY_BUTTON ********************************************
*******************************************************************************/

static void process_open_query_button()
{
	int c;
	int i;
	char filename[256];
	FILE *fp;

	GUI_DBG(("process_open_query_button()\n"));

	if (RISgui_get_filename(RISUTL_I_OPEN, 
		"Queries (*.qry)\0*.qry\0All Files (*.*)\0*.*\0",
	 	filename, sizeof(filename)))
	{
		GUI_DBG(("process_open_query_button:filename:<%s>\n", filename));

		if ((fp = fopen(filename, "r")) == NULL)
		{
			RISgui_errhandle(RISUTL_E_OPEN_FILE_READ, 0);
			RISgui_report_error();

			strcpy(in_msg->str, MSG(RISUTL_I_OPEN_QUERY_FAILED));

			GUI_DBG(("process_open_query_button:fopen failed: returning\n"));
			return;
		}

		for (i = 0; i< sizeof(query_buffer) && (c = getc(fp)) != EOF; i++)
		{
			if (i >= (sizeof(query_buffer) - 1))
			{
				RISgui_errhandle(RISUTL_E_QUERY_TOO_LARGE, 0);
				RISgui_report_error();

				query_buffer[0] = '\0';
				strcpy(in_msg->str, MSG(RISUTL_I_OPEN_QUERY_FAILED));

				GUI_DBG(("process_open_query_button:query too large failed: returning\n"));
				return;
			}
			query_buffer[i] = c;
		}
		query_buffer[i] = '\0';

		fclose(fp);

		set_query_field();
	}


	GUI_DBG(("process_open_query_button:returning\n"));
}

/*******************************************************************************
************** IN_CLEAR_QUERY_BUTTON *******************************************
*******************************************************************************/

static void process_clear_query_button()
{
	GUI_DBG(("process_clear_query_button()\n"));

	clear_query_field();
	clear_result_header_field();
	clear_result_field();
	FIg_disable(in_form, IN_RESULT_GROUP);

	query_buffer[0] = '\0';
	RISgui_free_query(&query);

	GUI_DBG(("process_clear_query_button:returning\n"));
}

/*******************************************************************************
************** IN_PREV_QUERY_BUTTON ********************************************
*******************************************************************************/

static void process_prev_query_button()
{
	int sts;
	GUI_DBG(("process_prev_query_button()\n"));

	if ((sts = get_query_field()) != 0)
	{
		RISgui_errhandle(sts, 0);
		RISgui_report_error();
		strcpy(in_msg->str, MSG(RISUTL_I_PREV_QUERY_FAILED));
		GUI_DBG(("process_exec_query_button:bad query: returning\n"));
		return;
	}

	if (!RISgui_query_stack_prev(query_buffer))
	{
		set_query_field();
	}

	update_prev_query_button();
	update_next_query_button();
	GUI_DBG(("process_prev_query_button:returning\n"));
}

/******************************************************************************/

static void update_prev_query_button()
{
	GUI_DBG(("update_prev_query_button()\n"));

	if (RISgui_query_stack_prev_invalid())
	{
		FIg_disable(in_form, IN_PREV_QUERY_BUTTON);
	}
	else
	{
		FIg_enable(in_form, IN_PREV_QUERY_BUTTON);
	}

	GUI_DBG(("update_prev_query_button:returning\n"));
}

/*******************************************************************************
************** IN_NEXT_QUERY_BUTTON ********************************************
*******************************************************************************/

static void process_next_query_button()
{
	GUI_DBG(("process_next_query_button()\n"));

	if (!RISgui_query_stack_next(query_buffer))
	{
		set_query_field();
	}

	update_prev_query_button();
	update_next_query_button();
	GUI_DBG(("process_next_query_button:returning\n"));
}

/******************************************************************************/

static void update_next_query_button()
{
	GUI_DBG(("update_next_query_button()\n"));

	if (RISgui_query_stack_next_invalid())
	{
		FIg_disable(in_form, IN_NEXT_QUERY_BUTTON);
	}
	else
	{
		FIg_enable(in_form, IN_NEXT_QUERY_BUTTON);
	}

	GUI_DBG(("update_next_query_button:returning\n"));
}

/*******************************************************************************
************** IN_SEARCH_QUERY_BUTTON ******************************************
*******************************************************************************/

static void process_search_query_button()
{
	GUI_DBG(("process_search_query_button()\n"));
	
	if (RISgui_search_for_query(query_buffer))
	{
		set_query_field();
	}

	GUI_DBG(("process_search_query_button:returning\n"));
}

/*******************************************************************************
************** QUERY_BUTTONS ***************************************************
*******************************************************************************/

static void update_query_buttons()
{
	GUI_DBG(("update_query_buttons()\n"));
	if (fetching)
	{
		FIg_disable(in_form, IN_EXEC_QUERY_BUTTON);
		FIg_disable(in_form, IN_SAVE_QUERY_BUTTON);
		FIg_disable(in_form, IN_OPEN_QUERY_BUTTON);
		FIg_disable(in_form, IN_CLEAR_QUERY_BUTTON);
		FIg_disable(in_form, IN_SEARCH_QUERY_BUTTON);
		FIg_disable(in_form, IN_PREV_QUERY_BUTTON);
		FIg_disable(in_form, IN_NEXT_QUERY_BUTTON);
		if (options.fetch_mode == FETCH_ALL_ROWS)
		{
			FIg_disable(in_form, IN_CONT_QUERY_BUTTON);
			FIg_disable(in_form, IN_ABORT_QUERY_BUTTON);
		}
		else
		{
			FIg_enable(in_form, IN_CONT_QUERY_BUTTON);
			FIg_enable(in_form, IN_ABORT_QUERY_BUTTON);
		}
	}
	else
	{
		FIg_enable(in_form, IN_EXEC_QUERY_BUTTON);
		FIg_enable(in_form, IN_SAVE_QUERY_BUTTON);
		FIg_enable(in_form, IN_OPEN_QUERY_BUTTON);
		FIg_enable(in_form, IN_CLEAR_QUERY_BUTTON);
		FIg_enable(in_form, IN_SEARCH_QUERY_BUTTON);
		update_prev_query_button();
		update_next_query_button();
		FIg_disable(in_form, IN_CONT_QUERY_BUTTON);
		FIg_disable(in_form, IN_ABORT_QUERY_BUTTON);
	}
	GUI_DBG(("update_query_buttons:returning\n"));
}

/*******************************************************************************
************** IN_RESULT_SCROLLBAR *********************************************
*******************************************************************************/

static void initialize_result_scrollbar()
{
 	GUI_DBG(("initialize_result_scrollbar()\n"));
	GUI_DBG(("initialize_result_scrollbar:returning\n"));
}

/******************************************************************************/

static void scroll_results(
	double dvalue)
{
	int value, sts;
	int max_column_offset;
	int old_column_offset;

	GUI_DBG(("scroll_results(dvalue:%f)\n", dvalue));

	value = (int)(dvalue + 0.5);
	max_column_offset = query.select.width - result_field_vis_chars;
	if (max_column_offset < 0)
	{
		max_column_offset = 0;
	}

	old_column_offset = result_field_column_offset;

	if (options.h_scroll_mode == H_SCROLL_COL)
	{
		result_field_column_offset = query.select.col[value].pos;
		if (result_field_column_offset > max_column_offset)
		{
			result_field_column_offset = max_column_offset;
		}
	}
	else
	{
		if (value < 0)
		{
			value = 0;
		}
		result_field_column_offset = value;
		GUI_DBG(("I am scroll_results:result_field_column_offset%d\n"
		,result_field_column_offset));
	}

	if (result_field_column_offset != old_column_offset)
	{
		FIfld_set_active_char(in_form, IN_RESULT_HEADER_FIELD, 0,
			result_field_column_offset,0);

		sts = FIfld_set_active_char(in_form, IN_RESULT_FIELD, 0,
			result_field_column_offset, 0);
		GUI_DBG(("sts of scroll_results:%d\n",sts));

		FIg_display(in_form, IN_RESULT_FIELD);   
	}

	GUI_DBG(("scroll_results:returning\n"));
}

/******************************************************************************/

extern void process_result_scrollbar()
{
	double dvalue;

	GUI_DBG(("process_result_scrollbar()\n"));

	FIg_get_value(in_form, IN_RESULT_SCROLLBAR, &dvalue);
	scroll_results(dvalue);

	GUI_DBG(("process_result_scrollbar:returning\n"));
}

/******************************************************************************/

static int continuous_result_scrollbar_routine(
	int     f_label,
	int     g_label,
	double  dvalue,
	Form    fp)
{
	GUI_DBG(("continuous_result_scrollbar_routine(f_label:%d g_label:%d dvalue:%f fp:0x%x)\n", f_label, g_label, dvalue, fp));

	scroll_results(dvalue);

	GUI_DBG(("continuous_result_scrollbar_routine:returning 0\n"));
	return 0;
}

/******************************************************************************/

static void save_results()
{
	int row;
	int num_row;
	int sel_flag, r_pos;
	char filename[RIS_MAX_PATH_SIZE];
	FILE *fp;
	int num_cols;
	double width;
	int i;
	int total_width;
	char temp[20];

	GUI_DBG(("save_results()\n"));

	if (query.type != SELECT)
	{
		RISgui_errhandle(RISUTL_E_NO_RESULTS, 0);
		RISgui_report_error();

		strcpy(in_msg->str, MSG(RISUTL_I_SAVE_RESULTS_FAILED));

		GUI_DBG(("save_results: no results: returning\n"));
		return;
	}

	if (RISgui_get_filename(RISUTL_I_SAVE, "All Files (*.*)\0*.*\0",
		filename, sizeof(filename)))
	{
		GUI_DBG(("save_results:filename:<%s>\n", filename));
#if defined(unix)
		if (!access(filename, F_OK) &&
			!RISgui_confirm(MSG(RISUTL_I_FILE_EXISTS_REPLACE)))
		{
			GUI_DBG(("save_results:don't replace: returning\n"));
			return;
		}
#endif
		if ((fp = fopen(filename, "w")) == NULL)
		{
			RISgui_errhandle(RISUTL_E_OPEN_FILE_WRITE, 0);
			RISgui_report_error();

			strcpy(in_msg->str, MSG(RISUTL_I_SAVE_RESULTS_FAILED));

			GUI_DBG(("save_results:fopen failed: returning\n"));
			return;
		}

		/* Get header */
/*
		FIfld_get_text(in_form, IN_RESULT_HEADER_FIELD, 0, 0,
			query.select.width + 1, (unsigned char *)query.select.buffer,
			&sel_flag, &r_pos);
		fprintf(fp, "%s\n", query.select.buffer);
*/		
		/* add dashed line */
/*
		memset(query.select.buffer, '-', query.select.width);
		query.select.buffer[query.select.width] = '\0';
		fprintf(fp, "%s\n", query.select.buffer);
*/
		total_width = 0;
		FImcf_get_num_cols(in_form,IN_RESULT_HEADER_FIELD,&num_cols);
		for (i=0; i<num_cols;i++)
		{
			FImcf_get_high_value(in_form,IN_RESULT_HEADER_FIELD,i,&width);
			FIfld_get_text(in_form, IN_RESULT_HEADER_FIELD, 0, i,
				(int)width+1,(unsigned char *)query.select.buffer,	&sel_flag, &r_pos);
			sprintf(temp,"%%-%.0fs ",width);
			fprintf(fp, temp, query.select.buffer);
			total_width += (int)width +1;
		}
		fprintf(fp, "\n");

		/* add dashed line */
		memset(query.select.buffer, '-', total_width);
		query.select.buffer[total_width] = '\0';
		fprintf(fp, "%s\n", query.select.buffer);

		/* get data */
/*
		FIfld_get_num_rows(in_form, IN_RESULT_FIELD, &num_row);
		for (row = 0; row < num_row; row++)
		{
			FIfld_get_text(in_form, IN_RESULT_FIELD, row, 0,
				query.select.width + 1, (unsigned char *)query.select.buffer,
				&sel_flag, &r_pos);
			fprintf(fp, "%s\n", query.select.buffer);
		}

		fclose(fp);
*/
		FIfld_get_num_rows(in_form, IN_RESULT_FIELD, &num_row);
		for (row = 0; row < num_row; row++)
		{
			for (i=0; i<num_cols;i++)
			{
				FImcf_get_high_value(in_form,IN_RESULT_HEADER_FIELD,i,&width);
				FIfld_get_text(in_form, IN_RESULT_FIELD, row, i,
					(int)width+1, (unsigned char *)query.select.buffer,
					&sel_flag, &r_pos);
				sprintf(temp,"%%-%.0fs ",width);
				fprintf(fp, temp, query.select.buffer);
			}
			fprintf(fp, "\n");
		}
		fclose(fp);

	}
	GUI_DBG(("save_results:returning\n"));
}

/******************************************************************************/

static void modify_scroll_mode(
	int new_mode)
{
	GUI_DBG(("modify_scroll_mode(new_mode:%s)\n",
		new_mode ? "H_SCROLL_CHAR" : "H_SCROLL_COL"));

	GUI_DBG(("modify_scroll_mode:returning\n"));
}

/******************************************************************************/

static void modify_fetch_mode(
	int new_mode)
{
	int sts;
	GUI_DBG(("modify_fetch_mode(new_mode:%d)\n",new_mode));

	options.fetch_mode = new_mode;

	if (query.type != SELECT)
	{
		GUI_DBG(("modify_fetch_mode: query.type != SELECT: returning\n"));
		return;
	}

	if (fetching && options.fetch_mode == FETCH_ALL_ROWS)
	{
		update_query_buttons();
		while(1)
		{
			if (RISgui_fetch_query(&query,in_form))
			{
				break;
			}
			if (query.status == END_OF_DATA)
			{
				fetching = 0;
				update_query_buttons();
				strcpy(in_msg->str,MSG(RISUTL_I_END_OF_DATA_FOUND));
				if (RISgui_clear_query(&query))
				{
					strcpy(in_msg->str, MSG(RISUTL_I_CLEAR_FAILED));
				}
				break;
			}
			if ((sts = append_result_field()) != 0)
			{
				RISgui_errhandle(sts, 0);
				RISgui_report_error();
				fetching = 0;
				update_query_buttons();
				RISgui_clear_query(&query);
				break;
			}
		}
	}
	GUI_DBG(("modify_fetch_mode:returning\n"));
}

/******************************************************************************/

static int set_ansi_mode(
	int ansi_mode)
{
	char cmd[24];

	sprintf(cmd, "set mode ansi %s", ansi_mode ? "on" : "off");
	RISgui_execute_command(cmd);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
		return 1;
	}
	return 0;
}

/******************************************************************************/

static int set_verify_mode(
	int verify_mode)
{
	char cmd[24];

	sprintf(cmd, "set mode verify %s", verify_mode ? "on" : "off");
	RISgui_execute_command(cmd);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
		return 1;
	}
	return 0;
}

/******************************************************************************/

static int set_blankstrip_mode(
	int blankstrip_mode)
{
	char cmd[25];

	sprintf(cmd, "set mode blank strip %s", blankstrip_mode ? "on" : "off");
	RISgui_execute_command(cmd);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
		return 1;
	}
	return 0;
}

/******************************************************************************/

static int set_autocommit_mode(
	int autocommit_mode)
{
	char cmd[32];

	sprintf(cmd,"set transaction autocommit %s",autocommit_mode ? "on" : "off");
	RISgui_execute_command(cmd);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
		return 1;
	}
	return 0;
}

/******************************************************************************/

static int set_autorename_mode(
	int autorename_mode)
{
	char cmd[24];

	sprintf(cmd, "set mode autorename %s", autorename_mode ? "on" : "off");
	RISgui_execute_command(cmd);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
		return 1;
	}
	return 0;
}

/******************************************************************************/

static int set_enable_dbms(
	int enable_dbms)
{
	int		i;
	int		dbms_cnt;
	char	*ptr;
	char	cmd[128];

	ptr = cmd;
	ptr += sprintf(ptr,"set database enable only ");
	for (i = 0, dbms_cnt = 0; i < dbms_info_cnt; i++)
	{
		if (enable_dbms & dbms_info[i].bitmask)
		{
			if (dbms_cnt)
			{
				*ptr++ = ',';
			}
			ptr += sprintf(ptr, " %s", dbms_info[i].name);
			dbms_cnt++;
		}
	}
	RISgui_execute_command(cmd);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
		return 1;
	}
	return 0;
}

/******************************************************************************/

static void restart()
{
	int		sts;
	int		before_modes_valid;
	int		before_def_schname_valid;
	char	command[255];
	char	before_def_schname[RIS_MAX_ID_SIZE];
	modes_s modes;
	modes_s before_modes;
	ris_schema_info *schema = NULL;
	unsigned char dtype;

	GUI_DBG(("restart()\n"));

if (!RISgui_confirm(MSG(RISUTL_I_WANT_RESTART)))
	{
		GUI_DBG(("restart:user cancel:returning\n"));
		return;
	}

	if (fetching)
	{
		if (!RISgui_confirm(MSG(RISUTL_I_ABORT_QUERY_RESTART)))
		{
			GUI_DBG(("restart:user cancel:returning\n"));
			return;
		}

		fetching = 0;

	}
	update_msg_field(MSG(RISUTL_I_RESTARTING_RIS));

	query_buffer[0] = '\0';
	RISgui_free_query(&query);
	initialize_result_scrollbar();
	FIg_enable(in_form, IN_QUERY_GROUP);
	FIg_enable(in_form, IN_RESULT_GROUP);
	FIg_disable(in_form, IN_CONT_QUERY_BUTTON);
	FIg_disable(in_form, IN_ABORT_QUERY_BUTTON);
	clear_query_field();
	clear_result_header_field();
	clear_result_field();
	gui_file_info_up_to_date = 0;
	before_def_schname[0] = 0;

	if (!RISgui_close_transactions())
	{
		GUI_DBG(("restart:user cancel:returning\n"));
		return;
	}


	FIfld_set_text(in_form, IN_DEFAULT_SCHEMA_FIELD, 0,0, "", 0);
	FIfld_set_text(in_form, IN_QUERY_FIELD, 0,0, "", 0);
	clear_result_header_field();
/*
	RISget_default_schema_name(before_def_schname);
*/
	before_def_schname_valid = (SQLCODE == RIS_SUCCESS);

	RISint_get_flags(&before_modes.ansi, &before_modes.enable_dbms,
		&before_modes.verify, &before_modes.blankstrip,
		&before_modes.autocommit, &before_modes.autorename);
	before_modes_valid = (SQLCODE == RIS_SUCCESS);

	RISterminate();

	sts = SETJMP();
	if (sts)
	{
		static char buffer[1072];

		RESETJMP();

		RISuco_char_error_box(buffer, RISUTL_I_RIS_ERROR, 0, sts, NULL, 0, 1);
		RISgui_error_box(buffer);

 		exit(sts);
	}

	RISuco_initialize_ums(INIT_UTL_UMS_FILE|INIT_RIS_UMS_FILE);

	RESETJMP();

	/* Reinitialize RIS */

/*
**	Reinitialize RIS 
**      Passing RIS_LANGUAGE environment variable to RISinitialize
**      to fix TR# 249406609. RAJU 10/07/94
*/
	RISinitialize(getenv("RIS_LANGUAGE"));
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
	}

	/* Restore modes */
	update_msg_field(MSG(RISUTL_I_RESTORING_MODES));
	RISint_get_flags(&modes.ansi, &modes.enable_dbms, &modes.verify,
		&modes.blankstrip, &modes.autocommit, &modes.autorename);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
	}
	else if (before_modes_valid)
	{
		if (before_modes.ansi != modes.ansi)
		{
			set_ansi_mode(before_modes.ansi);
		}
		if (before_modes.verify!= modes.verify)
		{
			set_verify_mode(before_modes.verify);
		}
		if (before_modes.autocommit != modes.autocommit)
		{
			set_autocommit_mode(before_modes.autocommit);
		}
		if (before_modes.enable_dbms != modes.enable_dbms)
		{
			set_enable_dbms(before_modes.enable_dbms);
		}
		if (before_modes.blankstrip != modes.blankstrip)
		{
			set_blankstrip_mode(before_modes.blankstrip);
		}
		if (before_modes.autorename != modes.autorename)
		{
			set_autorename_mode(before_modes.autorename);
		}
	}

	update_default_schema_field_list(1);

	if (before_def_schname_valid && before_def_schname[0])
	{
		sprintf(command, MSG(RISUTL_I_SETTING_DEF_SCH), before_def_schname);
		update_msg_field((const char *)command);

		schema = get_schema(before_def_schname);
		dtype = get_db(schema->dbid);
/*
		RISgui_set_default_schema(before_def_schname, dtype);
		if (SQLCODE != RIS_SUCCESS)
		{
			RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
			RISgui_report_error();
		}
		else
		{
			sprintf(in_msg->str, MSG(RISUTL_I_DEF_SCH_SET), before_def_schname);
		}

*/
		clear_msg_field();
	}

	update_default_schema_field();

	GUI_DBG(("restart:returning\n"));
}

/*******************************************************************************
************** IN_OPTIONS_BUTTON ***********************************************
*******************************************************************************/

static void process_options_button()
{
	options_s temp;

	GUI_DBG(("process_options_button()\n"));

	memcpy(&temp, &options, sizeof(options_s));

	if (!RISgui_get_options(&temp))
	{
		GUI_DBG(("process_results_button:options canceled:returning\n"));
		return;
	}

	if (temp.h_scroll_mode != options.h_scroll_mode)
	{
		modify_scroll_mode(temp.h_scroll_mode);
	}

	if (temp.fetch_mode != options.fetch_mode)
	{
		modify_fetch_mode(temp.fetch_mode);
	}

	GUI_DBG(("process_results_button:returning\n"));
}

/*******************************************************************************
************** IN_UTILITIES_BUTTON *********************************************
*******************************************************************************/

static void process_utilities_button()
{
	GUI_DBG(("process_utilities_button()\n"));
/*
	gui_schemas = 0;
*/

	if (!RISgui_ut_form_displayed())
	{
		RISgui_display_ut_form();
	}

	GUI_DBG(("process_utilities_button:returning\n"));
}

/*******************************************************************************
************** IN_SAVE_RESULTS_BUTTON ******************************************
*******************************************************************************/

static void process_save_results_button()
{
	GUI_DBG(("process_save_results_button()\n"));

	save_results();

	GUI_DBG(("process_save_results_button:returning\n"));
}

/*******************************************************************************
************** IN_RESTART_BUTTON ***********************************************
*******************************************************************************/

static void process_restart_button()
{
	GUI_DBG(("process_restart_button()\n"));

	restart();

	GUI_DBG(("process_options_button:returning\n"));
}

/*******************************************************************************
************** IN_SET_BUTTON ***************************************************
*******************************************************************************/

static void process_set_button()
{
	modes_s modes;
	modes_s temp;

	GUI_DBG(("process_set_button()\n"));

	RISint_get_flags(&modes.ansi, &modes.enable_dbms, &modes.verify,
		&modes.blankstrip, &modes.autocommit, &modes.autorename);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
		return;
	}

	memcpy(&temp, &modes, sizeof(modes_s));

	if (!RISgui_get_set_modes(&temp))
	{
		GUI_DBG(("process_set_button: set form canceled: returning\n"));
		return;	
	}

	if (temp.ansi != modes.ansi)
	{
		set_ansi_mode(temp.ansi);
	}

	if (temp.verify != modes.verify)
	{
		set_verify_mode(temp.verify);
	}

	if (temp.blankstrip != modes.blankstrip)
	{
		set_blankstrip_mode(temp.blankstrip);
	}

	if (temp.autocommit != modes.autocommit)
	{
		set_autocommit_mode(temp.autocommit);
	}

	if (temp.autorename != modes.autorename)
	{
		set_autorename_mode(temp.autorename);
	}

	if (temp.enable_dbms != modes.enable_dbms)
	{
		set_enable_dbms(temp.enable_dbms);
	}

	GUI_DBG(("process_set_button:returning\n"));
}

/*******************************************************************************
************** SHOW_BUTTON *****************************************************
*******************************************************************************/

static void process_show_button()
{
	GUI_DBG(("process_show_button()\n"));

	if (!RISgui_sh_form_displayed())
	{
		RISgui_display_sh_form();
	}

	GUI_DBG(("process_show_button:returning\n"));
}

/*******************************************************************************
************** DEBUG_BUTTON ****************************************************
*******************************************************************************/

static void process_debug_button()
{
	GUI_DBG(("process_debug_button()\n"));

	if (!RISgui_db_form_displayed())
	{
		RISgui_display_db_form();
	}

	GUI_DBG(("process_debug_button:returning\n"));
}

/*******************************************************************************
************** INTERACTIVE_FORM ************************************************
*******************************************************************************/

extern int RISgui_window_event_in_form(
	int form_label,
	int event,
	Form form)
{
	int row, num_row, length, sel_flag, r_pos ;
        char text[10240];	
	
	GUI_DBG(("RISgui_window_event_in_form(form_label:%d rvrnt:%d form:0x%x)\n",
	 form_label, event, form));

	if (event == FI_UNCOLLAPSE || event == FI_REFRESH)
	{
/*
		FIfld_get_text_length(in_form, IN_RESULT_HEADER_FIELD,
                                             0, 0, &length);//rick
		FIfld_get_text(in_form, IN_RESULT_HEADER_FIELD,
  				 0, 0, length,
			(unsigned char *)text, &sel_flag, &r_pos);
		FIfld_set_text(in_form, IN_RESULT_HEADER_FIELD, 0, 0,
			 	text, 0);
		FIfld_set_active_char(in_form, IN_RESULT_HEADER_FIELD, 
				0, result_field_column_offset, 0);
*/
		FIfld_get_num_rows(in_form, IN_RESULT_FIELD, &num_row);

		if (query.status == END_OF_DATA && num_row == 0)
			num_row++;

		for (row = 0; row < num_row; row++)
		{
			FIfld_get_text_length(in_form, IN_RESULT_FIELD, row,
                                               0, &length);
			FIfld_get_text(in_form, IN_RESULT_FIELD,
  					 row, 0, length,
				(unsigned char *)text, &sel_flag, &r_pos);
			FIfld_set_text(in_form, IN_RESULT_FIELD, row, 0,
			 	text, 0);
		}
	}

	GUI_DBG(("RISgui_window_event_in_form:returning\n"));
	return 0;
}

/******************************************************************************/

extern void RISgui_process_in_form(
	int	g_label)
{
	int	i;
	static	ris_gui_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,					process_cancel_button			},
#if defined(WIN32)
		{	FI_HELP,					process_help_button				},
#endif
		{	IN_DEFAULT_SCHEMA_FIELD,	process_default_schema_field	},
		{	IN_EXEC_QUERY_BUTTON, 		process_exec_query_button		},
		{	IN_CLEAR_QUERY_BUTTON,		process_clear_query_button		},
		{	IN_PREV_QUERY_BUTTON,		process_prev_query_button		},
		{	IN_NEXT_QUERY_BUTTON,		process_next_query_button		},
		{	IN_SEARCH_QUERY_BUTTON,		process_search_query_button		},
		{	IN_CONT_QUERY_BUTTON,		process_cont_query_button		},
		{	IN_ABORT_QUERY_BUTTON,		process_abort_query_button		},
		{	IN_SAVE_QUERY_BUTTON,		process_save_query_button		},
		{	IN_OPEN_QUERY_BUTTON,		process_open_query_button		},
		{	IN_RESULT_FIELD,			process_result_field			},
		{	IN_RESULT_SCROLLBAR,		process_result_scrollbar		},
		{	IN_OPTIONS_BUTTON,			process_options_button			},
		{	IN_UTILITIES_BUTTON,		process_utilities_button		},
		{	IN_SAVE_RESULTS_BUTTON,		process_save_results_button		},
		{	IN_RESTART_BUTTON,			process_restart_button			},
		{	IN_SET_BUTTON,				process_set_button				},
		{	IN_SHOW_BUTTON,				process_show_button				},
		{	IN_DEBUG_BUTTON,			process_debug_button			},

	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(ris_gui_label_function);

	GUI_DBG(("RISgui_process_in_form(g_label:%d)\n", g_label));

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

extern void RISgui_update_in_form()
{
	GUI_DBG(("RISgui_update_in_form()\n"));

	if (!in_form)
	{
		GUI_DBG(("RISgui_update_in_form: !in_form:  returning\n"));
		return;
	}

	update_default_schema_field();
	update_default_schema_field_list(1);

	GUI_DBG(("RISgui_update_in_form: returning\n"));
}

/******************************************************************************/

extern int RISgui_in_form_displayed()
{
	int	form_displayed;

	GUI_DBG(("RISgui_in_form_displayed()\n"));
	if (!in_form) return(0);
	FIf_is_displayed(in_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISgui_display_in_form()
{
	int		sts;
#if defined(WIN32)
	char	title[255];
#endif

	GUI_DBG(("RISgui_display_in_form()\n"));

	CLEAR_ERROR;
	if (!RIS_gui_initialized)
	{
		RISgui_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_gui_error.error;
	}

	if (!in_form)
	{
		sts = FIf_new(IN_FORM, IN_FORM_FILE, RISgui_notification_routine,
			&in_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_IN_FORM, sts);
			return RIS_gui_error.error;
		}
		FIg_set_continuous_routine(in_form, IN_RESULT_SCROLLBAR,
			continuous_result_scrollbar_routine);


#if defined(WIN32)
		sprintf(title, MSG(RISUTL_I_RISGUI_HEADING), RIS_version);
		FIf_SetTitlebarText(in_form, (TCHAR *)title);
#endif

		FIfld_get_num_vis_rows(in_form, IN_RESULT_FIELD,
			&result_field_vis_rows);
		FIfld_get_num_vis_chars(in_form, IN_RESULT_FIELD, 0,
			&result_field_vis_chars);

		if (debug_enabled)
		{
			FIg_display(in_form, IN_DEBUG_BUTTON);
		}
		else
		{
			FIg_erase(in_form, IN_DEBUG_BUTTON);
		}
		
	}


	if (!RISgui_in_form_displayed())
	{
		in_msg->str[0] = 0;
		in_msg->count = 0;
		in_msg->msg_fld_label = IN_MSG_FIELD;
		in_msg->fp = in_form;

		FIg_disable(in_form, IN_RESULT_GROUP);
		FIg_disable(in_form, IN_CONT_QUERY_BUTTON);
		FIg_disable(in_form, IN_ABORT_QUERY_BUTTON);

		sts = FIf_display(in_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_IN_FORM, sts);
			return RIS_gui_error.error;
		}

		RISgui_hourglass_cursor(in_form);

		RISgui_query_stack_load();
		update_prev_query_button();
		update_next_query_button();

		RISgui_update_in_form();

		if (!in_msg->str[0])
		{
			/*strcpy(in_msg->str,MSG(RISUTL_I_COPYRIGHT));*/
			/* 1996.03.12:Alan Barksdale:TR439600483 */
			strcpy(in_msg->str,MSG(RISUTL_I_BEGIN_COPYRIGHT));
			strcat(in_msg->str," ");
			strcat(in_msg->str,COPYRIGHTYEAR);
			strcat(in_msg->str,", ");
			strcat(in_msg->str,MSG(RISUTL_I_END_COPYRIGHT));
		}

		RISgui_display_msgs();
	}

#if defined(WIN32)
		FIf_set_window_event_routine(in_form, RISgui_window_event_in_form);
#endif

	RISgui_default_cursor(in_form);

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern int RISgui_erase_in_form()
{
	int	sts;

	GUI_DBG(("RISgui_erase_in_form()\n"));

	if (RISgui_in_form_displayed())
	{
		if (RISgui_ut_form_displayed())
		{
			RISgui_erase_ut_form();
		}
		if (RISgui_sh_form_displayed())
		{
			RISgui_erase_sh_form();
		}
		if (RISgui_db_form_displayed())
		{
			RISgui_erase_db_form();
		}

		RISgui_query_stack_save();

		sts = FIf_erase(in_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_IN_FORM, sts);
			return RIS_gui_error.error;
		}

#if defined(WIN32)
		RISgui_erase_help();
#endif
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

#if defined(WIN32)
extern HWND RISgui_get_in_handle()
{
	HWND in_handle;

	FIf_get_window(in_form, &in_handle);

	return in_handle;
}
#endif

/******************************************************************************/

extern void RISgui_center_form(
	Form fp)
{
	int in_x, in_y, in_xsize, in_ysize;
	int x, y, xsize, ysize;
	
	GUI_DBG(("RISgui_center_form()\n"));

	FIf_get_location(in_form, &in_x, &in_y);
	FIf_get_size(in_form, &in_xsize, &in_ysize);

	FIf_get_size(fp, &xsize, &ysize);
	x = in_x + (in_xsize - xsize)/2;
	y = in_y + (in_ysize - ysize)/2;

	FIf_set_location(fp, x, y);
	GUI_DBG(("RISgui_center_form:returning\n"));
}

/******************************************************************************/

extern void RISgui_create_grid(
	Form form,
	int num_cols_needed)
{
	int num_vis_cols;
	int num_frm_cols;
	int col_width;
	long attr_mask;
	int i;

	GUI_DBG(("RISgui_create_grid()\n"));

	FIg_erase(form,IN_RESULT_HEADER_FIELD);
	FIg_erase(form,IN_RESULT_FIELD);
	FIfld_get_attr(form,IN_RESULT_FIELD,0,&attr_mask);


	/* calculate number of columns needed */
	FImcf_get_num_cols(form,IN_RESULT_HEADER_FIELD,&num_frm_cols);
	FImcf_get_num_vis_cols(form,IN_RESULT_HEADER_FIELD,&num_vis_cols);
	FIfld_get_num_vis_chars(form,IN_RESULT_HEADER_FIELD,0,&col_width);

	GUI_DBG(("columns needed:%d\n",num_cols_needed));
	GUI_DBG(("form columns:%d\n",num_frm_cols));
	GUI_DBG(("form vis columns:%d\n",num_vis_cols));
	GUI_DBG(("Column width:%d\n",col_width));


	FImcf_set_active_col(form,IN_RESULT_HEADER_FIELD,0,0);
	FImcf_set_active_col(form,IN_RESULT_FIELD,0,0);

	/* remove columns */
	if (num_cols_needed < num_frm_cols)
	{
		GUI_DBG(("remove columns\n"));
		for (i= num_vis_cols; i < num_frm_cols; i++)
		{
/*			GUI_DBG(("remove column%d \n",i));*/
			FImcf_delete_col(form,IN_RESULT_HEADER_FIELD,num_vis_cols);
			FImcf_delete_col(form,IN_RESULT_FIELD,num_vis_cols);
		}
		FImcf_get_num_cols(form,IN_RESULT_HEADER_FIELD,&num_frm_cols);
	}

	/* add columns */
	if (num_cols_needed > num_frm_cols)
	{
		for (i=num_vis_cols; i < num_cols_needed; i++)
		{
/*			GUI_DBG(("adding column%d \n",i));*/
			FImcf_insert_col(form,IN_RESULT_HEADER_FIELD,num_vis_cols,col_width,FI_REVIEW,FI_ALPHA);
			FImcf_insert_col(form,IN_RESULT_FIELD,num_vis_cols,col_width,FI_REVIEW,FI_ALPHA);
			FIfld_set_attr(form,IN_RESULT_FIELD,num_vis_cols,attr_mask);
			FIfld_set_num_vis_chars(form,IN_RESULT_FIELD,num_vis_cols,col_width);
		}
	}

	/* print new values to debug */
	FImcf_get_num_cols(form,IN_RESULT_HEADER_FIELD,&num_frm_cols);
	FImcf_get_num_vis_cols(form,IN_RESULT_HEADER_FIELD,&num_vis_cols);
	GUI_DBG(("New Number of form columns:%d\n",num_frm_cols));
	GUI_DBG(("New Number of form vis columns:%d\n",num_vis_cols));

	FIg_display(form,IN_RESULT_HEADER_FIELD);
	FIg_display(form,IN_RESULT_FIELD);
	GUI_DBG(("RISgui_create_grid:returning\n"));
}

/******************************************************************************/

