/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							guisrch.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					5/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Rick Kramer
*/
 
/*
**	INCLUDES
*/
#include "rislimit.h"
#include "gui.h"

/*
**	DEFINES
*/
#define UP		0
#define DOWN	1

#define SEPARATOR_CHAR	'-'

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define guisrch_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "comumsg.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guistack.prt"
#include "guisrch.prt"
#include "guiutil.prt"
#include "guiin.prt"
#include "sys.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
int					exit_status;
char				search_string[128];
query_stack_s		*head = NULL;
query_stack_s		*tail = NULL;
query_stack_s		*current = NULL;
query_stack_s		*search_current = NULL;
static Form			sr_form = 0;
static ris_gui_msg	*sr_msg = &RIS_gui_msgs[SR_FORM_MSG];

/*
**	FUNCTIONS
*/

/******************************************************************************/

static int query_completely_visable()
{
	int num_rows;
	int offset;

	FIfld_get_num_vis_rows(sr_form, SR_QUERY_FIELD, &num_rows);
	FIfld_get_row_offset(sr_form, SR_QUERY_FIELD, &offset);

	if (current->start_row >= offset &&
		current->stop_row < offset + num_rows)
	{
		return 1;
	}
	return 0;
}

/******************************************************************************/

static query_stack_s *get_query_from_row(
	int row)
{
	query_stack_s *query;

	GUI_DBG(("get_query_from_row(row:%d)\n", row));

	for (query = head; query; query = query->prev)
	{
		if (row >= query->start_row && row <= query->stop_row)
		{
			break;
		}
	}

	GUI_DBG(("get_query_from_row:returning 0x%x\n", query));
	return query;
}

/******************************************************************************/

static void search(
	query_stack_s *start)
{
	int direction;
	query_stack_s *ptr;

	GUI_DBG(("search(start:0x%x)\n"));
	
	get_search_field();
	if (search_string[0])
	{
		if (current)
		{
			update_query_field(current, 0);
			current = NULL;
		}

		direction = get_direction();
		for (ptr = start; ptr; ptr = (direction == UP)?ptr->next:ptr->prev)
		{
			if (RISgui_substrcmp(ptr->query, search_string))
			{
				current = ptr;
				update_query_field(current, 1);
				if (!query_completely_visable()) 
				{
					FIfld_set_active_row(sr_form, SR_QUERY_FIELD,
						ptr->start_row,1);
				}
				break;
			}
		}
		if (ptr == NULL)
		{
			strcpy(sr_msg->str,MSG(RISUTL_I_STRING_NOT_FOUND));
		}
	}
	else
	{
		strcpy(sr_msg->str, MSG(RISUTL_I_STRING_MUST_BE_SPEC));
	}

	GUI_DBG(("search:returning\n"));
}

/******************************************************************************/
/************** SR_DOWN_CHECK *************************************************/
/******************************************************************************/

static int get_direction()
{
	int state;	

	GUI_DBG(("get_direction()\n"));

	FIg_get_state(sr_form, SR_DOWN_CHECK, &state);

	GUI_DBG(("get_direction:returning %s\n", state ? "DOWN" : "UP"));
	return state;
}

/******************************************************************************/
/************** SR_SEARCH_FIELD ***********************************************/
/******************************************************************************/

static void get_search_field()
{
	int	r_pos;
	int	sel_flag;

	GUI_DBG(("get_search_field()\n"));

	FIfld_get_text(sr_form, SR_SEARCH_FIELD, 0, 0, sizeof(search_string),
		(unsigned char *)search_string, &sel_flag, &r_pos);
	
	GUI_DBG(("get_search_field:returning\n"));
}

/******************************************************************************/

static void clear_search_field()
{
	GUI_DBG(("clear_search_field()\n"));

	FIfld_set_text(sr_form, SR_SEARCH_FIELD, 0, 0, "", 0);

	GUI_DBG(("clear_search_field:returning\n"));
}

/******************************************************************************/

static void process_next_button()
{
	int direction;
	query_stack_s *start;

	GUI_DBG(("process_next_button()\n"));

	direction = get_direction();
	if (current)
	{
		start = (direction == UP) ? current->next : current->prev;
	}
	else
	{
		start = (direction == UP) ? tail : head;
	}
	search(start);

	GUI_DBG(("process_prev_button:returning\n"));
}

/******************************************************************************/
/************** SR_QUERY_FIELD ************************************************/
/******************************************************************************/

static void set_query_field()
{
	int				row;
	int				len, max_len;
	int				vis_chars;
	char			*p;
	char			*nl;
	char			*separator;
	query_stack_s	*ptr;

	GUI_DBG(("set_query_field()\n"));

	row = 0;
	head = RISgui_query_stack_head();
	head = head->prev;
	current = NULL;

	FIfld_get_num_vis_chars(sr_form, SR_QUERY_FIELD, 0, &vis_chars);

#ifdef OLD
	memset(separator, SEPARATOR_CHAR, vis_chars-1);
	separator[vis_chars-1] = '\0';
#endif

	max_len = 0;
	ptr = head;
	if (ptr)
	{
		/* Separator */
#ifdef OLD
		FIfld_set_text(sr_form, SR_QUERY_FIELD, row, 0, separator, 0);
#endif
		row++;
	}

	while(ptr)
	{
		ptr->start_row = row;
#ifdef old
		FIfld_set_text(sr_form, SR_QUERY_FIELD, row, 0, ptr->query, 0);
		FIfld_get_num_rows(sr_form, SR_QUERY_FIELD, &row);
#else
		p = ptr->query;
		while(p && *p)
		{
			if ((nl = strchr(p, '\n')) != NULL)
			{
				*nl = '\0';
				FIfld_set_text(sr_form, SR_QUERY_FIELD, row++, 0, p, 0);
				if ((len = strlen(p)) > max_len)
				{
					max_len = len;
				}
				*nl = '\n';
				p = nl + 1;
			}
			else
			{
				FIfld_set_text(sr_form, SR_QUERY_FIELD, row++, 0, p, 0);
				if ((len = strlen(p)) > max_len)
				{
					max_len = len;
				}
				break;
			}
		}
#endif
		ptr->stop_row = row - 1;

		/* separator */
#ifdef OLD
		FIfld_set_text(sr_form, SR_QUERY_FIELD, row, 0, separator, 0);
#endif
		row++;

		tail = ptr;
		ptr = ptr->prev;
	}

	/* go back through and fill in separators */
	ptr = head;
	if (ptr)
	{
		if (max_len < vis_chars)
		{
			max_len = vis_chars;
		}
		separator = malloc(max_len + 1);
		if (!separator)
		{
			RISgui_errhandle(RISUTL_E_MALLOC, 0);
			RISgui_report_error();
			return;
		}
		memset(separator, SEPARATOR_CHAR, max_len);
		separator[max_len] = '\0';
		while(1)
		{
			FIfld_set_text(sr_form, SR_QUERY_FIELD, ptr->start_row - 1, 0,
				separator, 0);
			if (ptr->prev)
			{
				ptr = ptr->prev;
			}
			else
			{
				FIfld_set_text(sr_form, SR_QUERY_FIELD, ptr->stop_row + 1, 0,
					separator, 0);
				break;
			}
		}
		free(separator);
	}

	GUI_DBG(("set_query_field:returning\n"));
}

/******************************************************************************/

static void update_query_field(
	query_stack_s *ptr,
	int sel_flag)
{
	int row;
	GUI_DBG(("update_query_field(ptr:0x%x sel_flag:%d)\n", ptr, sel_flag));

	if (ptr)
	{
		for (row = ptr->start_row; row <= ptr->stop_row; row++)
		{
			FIfld_set_select(sr_form, SR_QUERY_FIELD, row, 0, sel_flag);
		}
	}

	GUI_DBG(("update_query_field:returning\n"));
}

/******************************************************************************/

static void process_query_field()
{
	int row;
	int pos;
	int sel_flag;
	query_stack_s *new;

	GUI_DBG(("process_query_field()\n"));

	FIfld_get_active_row(sr_form, SR_QUERY_FIELD, &row, &pos);
	FIfld_get_select(sr_form, SR_QUERY_FIELD, row, 0, &sel_flag);

	if ((new = get_query_from_row(row)) == NULL)
	{
		/* must a separator */
		FIfld_set_select(sr_form, SR_QUERY_FIELD, row, 0, 0);
		strcpy(sr_msg->str, MSG(RISUTL_I_INV_SELECTION));
	}
	else
	{
		update_query_field(current, 0);
		if (sel_flag)
		{
			current = new;
			update_query_field(current, sel_flag);
		}
		else
		{
			current = NULL;
		}
	}

	GUI_DBG(("process_query_field:returning\n"));
}

/******************************************************************************/

static void clear_query_field()
{
	GUI_DBG(("clear_query_field()\n"));

	FIfld_set_num_rows(sr_form, SR_QUERY_FIELD, 0);

	GUI_DBG(("clear_query_field:returning\n"));
}

/******************************************************************************/

static int sr_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("sr_form_displayed()\n"));

	if (sr_form)
	{
		FIf_is_displayed(sr_form, &form_displayed);
	}

	GUI_DBG(("sr_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_sr_form()
{
	int		sts;

	GUI_DBG(("display_sr_form()\n"));

	if (!sr_form)
	{
		sts = FIf_new(SR_FORM, SR_FORM_FILE, RISgui_notification_routine,
			&sr_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_SR_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_sr_form:returning\n"));
			return;
		}
		RISgui_center_form(sr_form);
	}

	sr_msg->str[0] = 0;
	sr_msg->count = 0;
	sr_msg->msg_fld_label = SR_MESSAGE_FIELD;
	sr_msg->fp = sr_form;

	set_query_field();

	if (!sr_form_displayed())
	{
		sts = FIf_display(sr_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_SR_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_sr_form:returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("display_sr_form:returning\n"));
	return;
}

/******************************************************************************/

extern void erase_sr_form()
{
	int	sts;

	GUI_DBG(("erase_sr_form()\n"));

	if (sr_form_displayed())
	{
		sts = FIf_erase(sr_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_SR_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("erase_sr_form: returning\n"));
			return;
		}
	}

	clear_search_field();
	clear_query_field();

	CLEAR_ERROR;

	GUI_DBG(("erase_sr_form: returning\n"));
	return;
}

/******************************************************************************/

static void process_accept_button()
{
	GUI_DBG(("process_accept_button()\n"));

	if (current)
	{
		erase_sr_form();
		exit_status = 1;
	}
	else
	{
		strcpy(sr_msg->str, MSG(RISUTL_I_QUERY_MUST_BE_SPEC));
	}
	GUI_DBG(("process_accept_button:returning\n"));
}

/******************************************************************************/

static void process_cancel_button()
{
	GUI_DBG(("process_cancel_button()\n"));

	erase_sr_form();

	exit_status = 0;
	GUI_DBG(("process_cancel_button:returning\n"));
}

/******************************************************************************/

extern void RISgui_process_sr_form(
	int	g_label)
{
	int	i;
	static	ris_gui_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,			process_cancel_button	},
		{	FI_ACCEPT,			process_accept_button	},
		{	SR_QUERY_FIELD,		process_query_field		},
		{	SR_NEXT_BUTTON,		process_next_button		},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(ris_gui_label_function);

	GUI_DBG(("RISgui_process_sr_form(g_label:%d)\n", g_label));

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}

	GUI_DBG(("RISgui_process_sr_form:returning\n"));
}

/******************************************************************************/

extern int RISgui_search_for_query(
	char *query)
{
	exit_status = 0;
	GUI_DBG(("RISgui_search_for_query()\n"));

	display_sr_form();

	RISgui_event_loop(sr_form_displayed);

	if (exit_status)
	{
		strcpy(query, current->query);
	}

	GUI_DBG(("RISgui_search_for_query:returning exit_status:%d\n",
		exit_status));

	return exit_status;
}

/******************************************************************************/
