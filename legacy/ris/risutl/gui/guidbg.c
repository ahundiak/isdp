/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:								guidbg.c
**	AUTHORS:							Terry McIntyre
**	CREATION DATE:						11/90
**	ABSTRACT:
**		The code to process the debug form.
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Rick Kramer
*/
 
/*
**	INCLUDES
*/
#include <stdarg.h>
#include "risdebug.h"
#include "risstjmp.h"
#include "rislimit.h"
#include "gui.h"
#include "arch.h"
#include "net.h"
#include "ucommon.h"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	DEFINES
*/
#define APP_TOGGLE				61
#define ARC_TOGGLE				14
#define BUF_TOGGLE				17
#define CCO_TOGGLE				68
#define CLI_TOGGLE				15
#define COM_TOGGLE				18
#define DBS_TOGGLE				42
#define DDS_TOGGLE				20
#define DIC_TOGGLE				64
#define FIL_TOGGLE				39
#define GUI_TOGGLE				21
#define INT_TOGGLE				23
#define JMP_TOGGLE				26
#define NET_TOGGLE				35
#define PAR_TOGGLE				24
#define REM_TOGGLE				62
#define SQL_TOGGLE				58
#define SRV_TOGGLE				27
#define STMT_TOGGLE				29
#define TREE_TOGGLE				30
#define TRN_TOGGLE				33
#define UCO_TOGGLE				32
#define USR_TOGGLE				70

#define ALL_OFF_BUTTON			66
#define SHOW_SERVERS_BUTTON		48
#define SHOW_HASH_BUTTON		51
#define SHOW_CLI_MEMORY_BUTTON	47
#define SHOW_CLI_STMTS_BUTTON	50
#define SHOW_APP_MEMORY_BUTTON	54
#define SHOW_APP_STMTS_BUTTON	56
#define SHOW_SCHEMA_FILE_BUTTON	53
#define SHOW_STRUCT_MGRS_BUTTON	36

#define TEXT_FIELD				67
/*
**	TYPES
*/
typedef struct ris_debug_info_s
{
	int		label;
	char	*str;
	int		len;
	int		flag;
} ris_debug_info_s;

/*
**	FUNCTION PROTOTYPES
*/
#define guidbg_c
#include "comdebug.prt"
#if defined(WIN32)
#include "comumsg.prt"
#endif
#include "fi.prt"
#include "guidbg.prt"
#include "guierror.prt"
#include "guiin.prt"
#include "ucoshfil.prt"
#include "ris.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static	Form		db_form = 0;
static ris_debug_info_s debug_info[] =
{
	{	APP_TOGGLE,		"app",		3, 0	},
	{	ARC_TOGGLE,		"arc",		3, 0	},
	{	BUF_TOGGLE,		"buf",		3, 0	},
	{	CCO_TOGGLE,		"cco",		3, 0	},
	{	CLI_TOGGLE,		"cli",		3, 0	},
	{	COM_TOGGLE,		"com",		3, 0	},
	{	DBS_TOGGLE,		"dbs",		3, 0	},
	{	DDS_TOGGLE,		"dds",		3, 0	},
	{	DIC_TOGGLE,		"dic",		3, 0	},
	{	FIL_TOGGLE,		"fil",		3, 0	},
	{	INT_TOGGLE,		"int",		3, 0	},
	{	JMP_TOGGLE,		"jmp",		3, 0	},
	{	NET_TOGGLE,		"net",		3, 0	},
	{	PAR_TOGGLE,		"par",		3, 0	},
	{	REM_TOGGLE,		"remote",	6, 0	},
	{	SQL_TOGGLE,		"sql",		3, 0	},
	{	SRV_TOGGLE,		"srv",		3, 0	},
	{	STMT_TOGGLE,	"stmt",		4, 0	},
	{	TREE_TOGGLE,	"tree",		4, 0	},
	{	TRN_TOGGLE,		"trn",		3, 0	},
	{	USR_TOGGLE,		"usr",		3, 0	},
};
static int debug_count = sizeof(debug_info)/sizeof(ris_debug_info_s);
static int col = 0;
static int row = 0;
static char buffer[8192];


/*
**	FUNCTIONS
*/

/*******************************************************************************
******************** SHOW_FIELD ************************************************
*******************************************************************************/

extern void clear_text_field()
{
	GUI_DBG(("clear_text_field()\n"));

	col = 0;
	row = 0;
	FIfld_set_num_rows(db_form, TEXT_FIELD, 0);

	GUI_DBG(("clear_text_field:returning\n"));
}

/******************************************************************************/

static void add_text(
	char	*s,
	int		len)
{
	int		r_pos;
	int		sel_flag;
	char	*temp;

	GUI_DBG(("add_text(s:<%s> len:%d)\n", s, len));

	if (col != 0)
	{
		if ((temp = (char *)malloc(len + col + 1)) != NULL)
		{
			FIfld_get_text(db_form, TEXT_FIELD, row, 0, col + 1,
				(unsigned char *)temp, &sel_flag, &r_pos);
			strcpy(temp+col, s);
			FIfld_set_text(db_form, TEXT_FIELD, row, 0, temp, 0);
			free(temp);
		}
	}
	else
	{
		FIfld_set_text(db_form, TEXT_FIELD, row, 0, s, 0);
	}

	GUI_DBG(("add_text:returning\n"));
}

/******************************************************************************/

static int append_text_field(
	const char *fmt,
	...)
{
	int		sts;
	int		len;
	char	*s;
	char	*p;
	va_list	args;

	GUI_DBG(("append_text_field()\n"));

	va_start(args, fmt);
	sts = vsprintf(buffer, fmt, args);
	if (sts >= sizeof(buffer))
	{
		sts = sprintf(buffer,
			"\"%s\", line %d: increase size of buffer to at least %d\n",
			__FILE__, __LINE__, sts);
	}
	va_end(args);

	s = buffer;
	p = buffer;
	while(1)
	{
		if (*p == '\t')
		{
			*p = ' ';
		}
		else if (*p == '\n')
		{
			*p = '\0';
			add_text(s, strlen(s));
			row++;
			col = 0;
			s = p+1;
			if (*s == '\0')
			{
				break;
			}
		}
		else if (*p == '\0')
		{
			len = strlen(s);
			add_text(s, len);
			col += len;
			break;
		}
		p++;
	}

	GUI_DBG(("append_text_field:returning sts:%d\n", sts));
	return sts;
}

/******************************************************************************/

static void update_flags()
{
	int i;
	char *ptr;
	char debugstr[128];

	RISint_get_debug_flags(debugstr);

	for (i = 0; i < debug_count; i++)
	{
		debug_info[i].flag = 0;
	}

	ptr = debugstr;
	while(*ptr)
	{
		for (i = 0; i < debug_count; i++)
		{
			if (!strncmp(ptr, debug_info[i].str, debug_info[i].len))
			{
				debug_info[i].flag = 1;
				ptr += debug_info[i].len;
				break;
			}
		}
		if (i == debug_count)
		{
			ptr++;
		}
	}
}

/******************************************************************************/

static void update_toggles(
	void)
{
	int i;

	GUI_DBG(("update_toggles()\n"));

	FIg_set_state(db_form, GUI_TOGGLE, RIS_gui_debug);
	FIg_set_state(db_form, UCO_TOGGLE, RISuco_debug);

	update_flags();
	for (i = 0; i < debug_count; i++)
	{
		FIg_set_state(db_form, debug_info[i].label, debug_info[i].flag);
	}
}

/*******************************************************************************
******************** ALL_OFF_BUTTON ********************************************
*******************************************************************************/


static void process_all_off_button()
{
	GUI_DBG(("process_all_off_button()\n"));

	RIS_gui_debug = 0;
	RISuco_debug = 0;

	RISint_process_debug("off");
	update_toggles();
	if (SQLCODE)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
	}
}

/*******************************************************************************
******************** DEBUG_TOGGLE **********************************************
*******************************************************************************/

static void process_debug_toggle(
	int g_label)
{
	int		i;
	int		state;
	char	cmd[32];

	GUI_DBG(("process_debug_toggle(g_label:%d)\n", g_label));

	switch(g_label)
	{
		case GUI_TOGGLE:
			FIg_get_state(db_form, GUI_TOGGLE, &RIS_gui_debug);
			break;

		case UCO_TOGGLE:
			FIg_get_state(db_form, UCO_TOGGLE, &RISuco_debug);
			break;

		default:
			for (i = 0; i < debug_count; i++)
			{
				if (debug_info[i].label == g_label)
				{
					FIg_get_state(db_form, debug_info[i].label, &state);
					sprintf(cmd, "%c%s", state ? '+' : '-',
						debug_info[i].str);
					RISint_process_debug(cmd);
					if (SQLCODE)
					{
						RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
						RISgui_report_error();
					}
					update_toggles();
				}
			}
			break;
	}
}

/*******************************************************************************
******************** SHOW_SERVERS_BUTTON ***************************************
*******************************************************************************/

static void process_show_servers_button()
{
	GUI_DBG(("process_show_servers_button()\n"));
	clear_text_field();
	RISint_show_cli_servers(append_text_field);
}

/*******************************************************************************
******************** SHOW_HASH_BUTTON ******************************************
*******************************************************************************/

static void process_show_hash_button()
{
	GUI_DBG(("process_show_hash_button()\n"));
	clear_text_field();
	RISint_show_cli_hash_table(append_text_field);
}

/*******************************************************************************
******************** SHOW_CLI_MEMORY_BUTTON ************************************
*******************************************************************************/

static void process_show_cli_memory_button()
{
	GUI_DBG(("process_show_cli_memory_button()\n"));
	clear_text_field();
	RISint_show_cli_memory(append_text_field);
}

/*******************************************************************************
******************** SHOW_CLI_STMTS_BUTTON *************************************
*******************************************************************************/

static void process_show_cli_stmts_button()
{
	GUI_DBG(("process_show_cli_stmts_button()\n"));
	clear_text_field();
	RISint_show_cli_stmts(append_text_field);
}

/*******************************************************************************
******************** SHOW_APP_MEMORY_BUTTON ************************************
*******************************************************************************/

static void process_show_app_memory_button()
{
	GUI_DBG(("process_show_app_memory_button()\n"));
	clear_text_field();
	RISint_show_app_memory(append_text_field);
}

/*******************************************************************************
******************** SHOW_APP_STMTS_BUTTON *************************************
*******************************************************************************/

static void process_show_app_stmts_button()
{
	GUI_DBG(("process_show_app_stmts_button()\n"));
	clear_text_field();
	RISint_show_app_stmts(append_text_field);
}

/*******************************************************************************
******************** SHOW_SCHEMA_FILE_BUTTON ***********************************
*******************************************************************************/

static void process_show_schema_file_button()
{
	GUI_DBG(("process_show_schema_file_button()\n"));
	clear_text_field();
	RISuco_show_schfile(append_text_field);
}

/*******************************************************************************
******************** SHOW_STRUCT_MGRS_BUTTON ***********************************
*******************************************************************************/

static void process_show_struct_mgrs_button()
{
	GUI_DBG(("process_show_struct_mgrs_button()\n"));
	clear_text_field();
	RISint_show_cli_struct_mgrs(append_text_field);
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	GUI_DBG(("process_cancel_button()\n"));
	RISgui_erase_db_form();
}

/*******************************************************************************
******************** DB FORM ***************************************************
*******************************************************************************/

static int process_db_form(
	int     f_label,
	int     g_label,
	double  value,
	Form    fp)
{
	GUI_DBG(("process_db_form(f_label:%d g_label:%d value:%f fp:0x%x)\n",
		f_label, g_label, value, fp));

	if (!db_form) return 0;

	switch(g_label)
	{
		case FI_CANCEL:
			process_cancel_button();
			break;

		case APP_TOGGLE:
		case ARC_TOGGLE:
		case BUF_TOGGLE:
		case CCO_TOGGLE:
		case CLI_TOGGLE:
		case COM_TOGGLE:
		case DBS_TOGGLE:
		case DDS_TOGGLE:
		case DIC_TOGGLE:
		case FIL_TOGGLE:
		case GUI_TOGGLE:
		case INT_TOGGLE:
		case JMP_TOGGLE:
		case NET_TOGGLE:
		case PAR_TOGGLE:
		case REM_TOGGLE:
		case SQL_TOGGLE:
		case SRV_TOGGLE:
		case STMT_TOGGLE:
		case TREE_TOGGLE:
		case TRN_TOGGLE:
		case UCO_TOGGLE:
		case USR_TOGGLE:
			process_debug_toggle(g_label);
			break;

		case ALL_OFF_BUTTON:
			process_all_off_button();
			break;

		case SHOW_SERVERS_BUTTON:
			process_show_servers_button();
			break;

		case SHOW_HASH_BUTTON:
			process_show_hash_button();
			break;

		case SHOW_CLI_MEMORY_BUTTON:
			process_show_cli_memory_button();
			break;

		case SHOW_CLI_STMTS_BUTTON:
			process_show_cli_stmts_button();
			break;

		case SHOW_APP_MEMORY_BUTTON:
			process_show_app_memory_button();
			break;

		case SHOW_APP_STMTS_BUTTON:
			process_show_app_stmts_button();
			break;

		case SHOW_SCHEMA_FILE_BUTTON:
			process_show_schema_file_button();
			break;

		case SHOW_STRUCT_MGRS_BUTTON:
			process_show_struct_mgrs_button();
			break;
	}

	return 0;
}

/******************************************************************************/

extern int RISgui_db_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("RISgui_db_form_displayed()\n"));

	if (db_form)
	{
		FIf_is_displayed(db_form, &form_displayed);
	}

	GUI_DBG(("RISgui_db_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

extern void RISgui_display_db_form()
{
	int	sts;

	GUI_DBG(("RISgui_display_db_form()\n"));

	if (!db_form)
	{
		sts = FIf_new(DB_FORM, DB_FORM_FILE, process_db_form, &db_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_DB_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("RISgui_display_db_form:returning\n"));
			return;
		}
		RISgui_center_form(db_form);
		FIg_set_text(db_form, 28, "GUI");
	}

	if (!RISgui_db_form_displayed())
	{
		sts = FIf_display (db_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_DB_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("RISgui_display_db_form:returning\n"));
			return;
		}
	}

	update_toggles();
	clear_text_field();

	CLEAR_ERROR;

	GUI_DBG(("RISgui_display_db_form:returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_erase_db_form()
{
	int	sts;

	GUI_DBG(("RISgui_erase_db_form()\n"));

	if (RISgui_db_form_displayed())
	{
		sts = FIf_erase(db_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_DB_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("RISgui_erase_db_form:returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("RISgui_erase_db_form:returning\n"));
	return;
}

/******************************************************************************/
