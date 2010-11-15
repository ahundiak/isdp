/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							guifile.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					6/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#if defined(unix)
# include <ctype.h>
# include <sys/stat.h>
# if ! defined(__clipper__)
#  include <unistd.h>
# endif
# include "rispath.h"
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif
#include "utl_inf.h"
#include "gui.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/
#if defined(unix)
typedef struct path_s
{
	char name[16];
	int value;
	struct path_s *next;
} path_s;

typedef struct data_s
{
	char name[16];
	int value;
	struct data_s *right;
	struct data_s *left;
} data_s;
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/*
**	FUNCTION PROTOTYPES
*/
#define guifile_c
#include "comdebug.prt"
#if defined(unix)
# include "comumsg.prt"
# include "event.prt"
# include "fi.prt"
# include "guintfy.prt"
# include "guiutil.prt"
# include "guierror.prt"
# include "sys.prt"
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif
#include "guiin.prt"
#include "guifile.prt"

/*
**	VARIABLES
*/
#if defined(unix)
static path_s		*path = NULL;
static data_s		*dirs = NULL;
static data_s		*files = NULL;
static char		file_type[16];
static char		cwd[256];
static Form		fi_form = 0;
static ris_gui_msg	*fi_msg = &RIS_gui_msgs[FI_FORM_MSG];
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif
static int		exit_status;

/*
**	FUNCTIONS
*/

/******************************************************************************/
/************** DIRS **********************************************************/
/******************************************************************************/

#if defined(unix)
static void init_dirs()
{
	int value = 0;
	int access_type;
	path_s **pathp;
	data_s **datap;
	char			s[256];
	char			*ptr;
	char			*name;
	struct stat		statbuf;
	struct dirent	*d;
	DIR				*dp;
	
	GUI_DBG(("init_dirs()\n"));

	dirs = NULL;
	files = NULL;
	path = NULL;

	if (getcwd(cwd, sizeof(cwd)) == NULL)
	{
		erase_fi_form();
		RISgui_errhandle(RISUTL_E_GETCWD, 0);
		RISgui_report_error();
		GUI_DBG(("init_dirs: getcwd failed: returning\n"));
		return;
	}
	strcpy(s, cwd);

	path = (path_s *)malloc(sizeof(path_s));
	if (!path)
	{
		erase_fi_form();
		RISgui_errhandle(RISUTL_E_MALLOC, 0);
		RISgui_report_error();
		GUI_DBG(("init_dirs: malloc failed: returning\n"));
		return;
	}
	strcpy(path->name, PATH_CHAR_STR);
	path->next = NULL;
	pathp = &(path->next);
	if ((ptr = strtok(s, PATH_CHAR_STR)) != NULL)
	{
		do
		{
			(*pathp) = (path_s *)malloc(sizeof(path_s));
			if (!(*pathp))
			{
				erase_fi_form();
				RISgui_errhandle(RISUTL_E_MALLOC, 0);
				RISgui_report_error();
				GUI_DBG(("init_dirs: malloc failed: returning\n"));
				return;
			}
			strcpy((*pathp)->name, ptr);
			(*pathp)->value = value++;
			(*pathp)->next = NULL;
			pathp = &((*pathp)->next);
		} while ((ptr = strtok(NULL, PATH_CHAR_STR)) != NULL);
	}

	if ((dp = opendir(".")) == NULL)
	{
		erase_fi_form();
		RISgui_errhandle(RISUTL_E_OPEN_DIR, 0);
		RISgui_report_error();
		GUI_DBG(("init_dirs: open_dir failed: returning\n"));
		return;
	}

	while((d = readdir(dp)) != NULL)
	{
		name = d->d_name;
		if (name[0] == '.' &&
			(name[1] == '\0') ||
			(name[1] == '.' && name[2] == '\0'))
		{
			continue;
		}

		if (stat(name, &statbuf) == -1)
		{
			erase_fi_form();
			RISgui_errhandle(RISUTL_E_STAT, 0);
			RISgui_report_error();
			GUI_DBG(("init_dirs: stat failed: returning\n"));
			return;
		}

		if (statbuf.st_mode & S_IFDIR)
		{
			/*
			**	It's a directory
			*/
			datap = &dirs;
			access_type = X_OK;
		}
		else
		{
			/*
			**	It's a file
			*/
			datap = &files;
			access_type = R_OK;
		}

		if (!access(name, access_type))
		{
			/*
			**	We have permission
			*/
			while(*datap)
			{
				if (strcmp(name, (*datap)->name) < 0)
				{
					datap = &(*datap)->left;
				}
				else
				{
					datap = &(*datap)->right;
				}
			}
			(*datap) = (data_s *)malloc(sizeof(data_s));
			if (!(*datap))
			{
				erase_fi_form();
				RISgui_errhandle(RISUTL_E_MALLOC, 0);
				RISgui_report_error();
				GUI_DBG(("init_dirs: malloc failed: returning\n"));
				return;
			}
			strcpy((*datap)->name, name);
			(*datap)->left = NULL;
			(*datap)->right = NULL;
		}
	}
	closedir(dp);

	GUI_DBG(("init_dirs:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void free_data(
	data_s	*data)
{
	GUI_DBG(("free_data(data:0x%x)\n", data));

	if (data)
	{
		free_data(data->left);
		free_data(data->right);
		free(data);
	}

	GUI_DBG(("free_data:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void free_dirs()
{
	path_s *cur;
	path_s *temp;

	GUI_DBG(("free_dirs()\n"));

	free_data(files);
	free_data(dirs);
	for (cur = path; cur;)
	{
		temp = cur;
		cur = cur->next;
		free(temp);
	}

	GUI_DBG(("free_dirs:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void display_files(
	data_s	*data,
	int		*row)
{
	GUI_DBG(("display_files(data:0x%x row:0x%x)\n", data, row));

	if (data)
	{
		display_files(data->left, row);

		if (!RISgui_strcmp_wildcard(file_type, data->name))
		{
			FIfld_set_text(fi_form, FI_FILES_FIELD, *row, 0, data->name, 0);
			data->value = *row;
			(*row)++;
		}
		else
		{
			data->value = -1;
		}

		display_files(data->right, row);
	}

	GUI_DBG(("display_files:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void display_dirs(
	data_s	*data,
	int		*row,
	int		level)
{
	char s[128];

	GUI_DBG(("display_dirs(data:0x%x row:0x%x level:%d)\n", data, row, level));

	if (data)
	{
		display_dirs(data->left, row, level);

		sprintf(s, "%*s%s", level, "", data->name);
		FIfld_set_text(fi_form, FI_DIRS_FIELD, *row, 0, s, 0);
		data->value = *row;
		(*row)++;

		display_dirs(data->right, row, level);
	}

	GUI_DBG(("display_dirs:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static char *get_dir(
	data_s	*data,
	int		value)
{
	char *sts;

	GUI_DBG(("get_dir()\n"));

	if (data)
	{
		if (value == data->value)
		{
			sts = data->name;
		}
		else
		{
			sts = get_dir(data->left, value);
			if (sts == NULL)
			{
				sts = get_dir(data->right, value);
			}
		}
	}
	else
	{
		sts = NULL;
	}

	GUI_DBG(("get_dir:returning sts:<%s>\n", STRING(sts)));

	return sts;
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void get_filename(
	char *ptr)
{
	char *filename;

	GUI_DBG(("get_filename(ptr:0x%x)\n", ptr));

	if ((filename = get_file_field()) != NULL)
	{
		sprintf(ptr, "%s%c%s", cwd, PATH_CHAR, filename);
	}
	else
	{
		*ptr = '\0';
	}

	GUI_DBG(("get_filename:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/
/************** FI_FILE_FIELD *************************************************/
/******************************************************************************/

#if defined(unix)
static char *get_file_field(
	void)
{
	int	r_pos;
	int	sel_flag;
	char *return_sts;
	static unsigned char filename[16];

	GUI_DBG(("get_file_field()\n"));

	FIfld_get_text(fi_form, FI_FILE_FIELD, 0, 0, sizeof(filename),
		filename, &sel_flag, &r_pos);

	if (!filename[0])
	{
		return_sts = NULL;
	}
	else
	{
		return_sts = (char *)filename;
	}

	GUI_DBG(("get_file_field:returning <%s>\n", STRING(return_sts)));
	return return_sts;
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void set_file_field(
	char *file)
{
	GUI_DBG(("set_file_field(file:<%s>)\n", STRING(file)));

	if (!file) file = "";
	FIfld_set_text(fi_form, FI_FILE_FIELD, 0, 0, file, 0);
	
	GUI_DBG(("set_file_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void clear_file_field()
{
	GUI_DBG(("clear_file_field()\n"));

	FIfld_set_text(fi_form, FI_FILE_FIELD, 0, 0, "", 0);

	GUI_DBG(("clear_file_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void process_file_field()
{
	GUI_DBG(("process_file_field()\n"));

	update_files_field();

	GUI_DBG(("process_file_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/
/************** FI_FILES_FIELD ************************************************/
/******************************************************************************/

#if defined(unix)
static void set_files_field()
{
	int row = 0;

	GUI_DBG(("set_files_field()\n"));

	FIfld_set_num_rows(fi_form, FI_FILES_FIELD, 0);
	display_files(files, &row);

	GUI_DBG(("set_files_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void update_files_field()
{
	int row;
	int num_rows;
	int sel_flag, pos;
	char *file;
	unsigned char filename[16];

	GUI_DBG(("update_files_field()\n"));

	FIfld_get_num_rows(fi_form, FI_FILES_FIELD, &num_rows);

	row = 0;
	file = get_file_field();
	if (file)
	{
		for (; row < num_rows; row++)
		{
			FIfld_get_text(fi_form, FI_FILES_FIELD, row, 0, sizeof(filename),
				filename, &sel_flag, &pos);
			if (strcmp(file, (char *)filename))
			{
				if (sel_flag)
				{
					FIfld_set_select(fi_form, FI_FILES_FIELD, row, 0, 0);
				}
			}
			else
			{
				if (!sel_flag)
				{
					FIfld_set_select(fi_form, FI_FILES_FIELD, row, 0, 1);
					row++;
					break;
				}
			}
		}
	}
	for (; row < num_rows; row++)
	{
		FIfld_get_select(fi_form, FI_FILES_FIELD, row, 0, &sel_flag);
		if (sel_flag)
		{
			FIfld_set_select(fi_form, FI_FILES_FIELD, row, 0, 0);
		}
	}

	GUI_DBG(("update_files_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void process_files_field(
	void)
{
	int row;
	int	pos;
	int	sel_flag;
	unsigned char filename[16];

	GUI_DBG(("process_files_field()\n"));

	FIfld_get_active_row(fi_form, FI_FILES_FIELD, &row, &pos);
	FIfld_get_text(fi_form, FI_FILES_FIELD, row, 0, sizeof(filename), filename,
		&sel_flag, &pos);
	
	if (sel_flag)
	{
		set_file_field((char *)filename);
	}
	else
	{
		clear_file_field();
	}

	GUI_DBG(("process_files_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/
/************** FI_DIR_FIELD **************************************************/
/******************************************************************************/

#if defined(unix)
static void set_dir_field()
{
	int len;
	int vis_chars;
	char *ptr;
	char *s = NULL;

	GUI_DBG(("set_dir_field()\n"));

	FIfld_get_num_vis_chars(fi_form, FI_DIR_FIELD, 0, &vis_chars);

	if ((len = strlen(cwd)) > vis_chars)
	{
		if ((s = (char *)malloc(vis_chars + 1)) == NULL)
		{
			erase_fi_form();
			RISgui_errhandle(RISUTL_E_MALLOC, 0);
			RISgui_report_error();
			GUI_DBG(("set_dir_field: malloc failed: returning\n"));
			return;
		}
		ptr = cwd;
		while ((ptr = strchr(ptr, PATH_CHAR)) != NULL)
		{
			len = strlen(ptr);
			if (len + 4 <= vis_chars)
			{
				sprintf(s, "%c...%s", PATH_CHAR, ptr);
				ptr = s;
				break;
			}
			ptr++;
		}
		if (ptr == NULL)
		{
			ptr = cwd;
		}
	}
	else
	{
		ptr = cwd;
	}

	FIfld_set_text(fi_form, FI_DIR_FIELD, 0, 0, ptr, 0);

	if (s)
	{
		free(s);
	}

	GUI_DBG(("set_dir_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/
/************** FI_DIRS_FIELD *************************************************/
/******************************************************************************/

#if defined(unix)
static void set_dirs_field()
{
	int row;
	int level;
	int selected;
	char s[128];
	path_s *cur;

	GUI_DBG(("set_dirs_field()\n"));

	FIfld_set_num_rows(fi_form, FI_DIRS_FIELD, 0);
	for (cur = path, row = 0, level = 0; cur; cur = cur->next, row++, level++)
	{
		cur->value = row;
		sprintf(s, "%*s%s", level, "", cur->name);
		selected = (cur->next == NULL);
		FIfld_set_text(fi_form, FI_DIRS_FIELD, row, 0, s, selected);
	}

	display_dirs(dirs, &row, level);

	GUI_DBG(("set_dirs_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void process_dirs_field()
{
	int		row;
	int		pos;
	char	*sts;
	char	name[256];
	path_s	*cur;

	GUI_DBG(("process_dirs_field()\n"));

	FIfld_get_active_row(fi_form, FI_DIRS_FIELD, &row, &pos);

	strcpy(name, "");
	for (cur = path; cur; cur = cur->next)
	{
		strcat(name, cur->name);
		if (cur->value == row)
		{
			break;
		}
		if (cur != path)
		{
			strcat(name, PATH_CHAR_STR);
		}
	}
	if (!cur)
	{
		if ((sts = get_dir(dirs, row)) == NULL)
		{
			if (!path)
			{
				erase_fi_form();
				RISgui_errhandle(RISUTL_E_INTERNAL, 0);
				RISgui_report_error();
				GUI_DBG(("process_dirs_field: invalid row: returning\n"));
				return;
			}
		}
		strcat(name, sts);
	}

	GUI_DBG(("process_dirs_field: name:<%s>\n", name));

	if (chdir(name))
	{
		RISgui_errhandle(RISUTL_E_CHDIR, 0);
		RISgui_report_error();
	}

	update_form();

	GUI_DBG(("process_dirs_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/
/************** FI_TITLE_TEXT *************************************************/
/******************************************************************************/

#if defined(unix)
static void update_title(
	const char *title)
{
	GUI_DBG(("update_title(title:<%s>)\n", STRING(title)));

	if (title)
	{
		FIg_set_text(fi_form, FI_TITLE_TEXT, (char *)title);
	}
	GUI_DBG(("update_title:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/
/************** FI_FILE_TYPE_FIELD ********************************************/
/******************************************************************************/

#if defined(unix)
static void get_file_type_field()
{
	int	r_pos;
	int	sel_flag;

	GUI_DBG(("get_file_type_field()\n"));

	FIfld_get_text(fi_form, FI_FILE_TYPE_FIELD, 0, 0, sizeof(file_type),
		(unsigned char *)file_type, &sel_flag, &r_pos);

	GUI_DBG(("get_file_type_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void process_file_type_field()
{
	int i;
	int num_row;
	int sel_flag;
	unsigned char type[16];

	GUI_DBG(("process_file_type_field()\n"));

	get_file_type_field();

	FIfld_get_list_num_rows(fi_form, FI_FILE_TYPE_FIELD, 0, &num_row);
	for (i = 0; i < num_row; i++)
	{
		FIfld_get_list_text(fi_form, FI_FILE_TYPE_FIELD, i, 0, 16, type,
			&sel_flag);
		if (strcmp(file_type, (char *)type))
		{
			FIfld_set_list_select(fi_form, FI_FILE_TYPE_FIELD, i, 0, 0);
		}
		else
		{
			FIfld_set_list_select(fi_form, FI_FILE_TYPE_FIELD, i, 0, 1);
		}
	}

	clear_file_field();
	set_files_field();
	GUI_DBG(("process_file_type_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void update_file_type_field(
	char *s)
{
	int count = 0;
	GUI_DBG(("update_file_type_field(s:<%s>)\n", STRING(s)));

	if (s)
	{
		/*
		**	To be compatible with NT, s is in the following format:
		**	"Filter name\0Filter\0Filter name\0Filter\0\0".  We will
		**	ignore the filter name and just use the filters.
		*/

		while(1)
		{
			/* skip the Filter name */
			while(*s) s++; s++;
			if (*s == '\0') break;

			if (count == 0)
			{
				FIfld_set_list_text(fi_form, FI_FILE_TYPE_FIELD, count, 0,
					s, 1);
				FIfld_set_text(fi_form, FI_FILE_TYPE_FIELD, 0, 0, s, 0);
				strcpy(file_type, s);
			}
			else
			{
				FIfld_set_list_text(fi_form, FI_FILE_TYPE_FIELD, count, 0,
					s, 0);
			}
			count++;

			/* skip the filter */
			while(*s) s++; s++;
			if (*s == '\0') break;
		}
		FIfld_set_list_num_rows(fi_form, FI_FILE_TYPE_FIELD, 0, count);
	}

	GUI_DBG(("update_file_type_field:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/
/************** FI_ACCEPT_BUTTON **********************************************/
/******************************************************************************/

#if defined(unix)
static void process_accept_button()
{
	char *filename;

	GUI_DBG(("process_accept_button()\n"));

	if ((filename = get_file_field()) != NULL)
	{
		erase_fi_form();
		exit_status = 1;
	}
	else
	{
		strcpy(fi_msg->str,MSG(RISUTL_I_FILENAME_MUST_BE_SPEC));
	}

	GUI_DBG(("process_accept_button:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/
/************** FI_CANCEL_BUTTON **********************************************/
/******************************************************************************/

#if defined(unix)
static void process_cancel_button()
{
	GUI_DBG(("process_cancel_button()\n"));

	erase_fi_form();

	exit_status = 0;
	GUI_DBG(("process_cancel_button:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/
/************** FI_FILE_FORM **************************************************/
/******************************************************************************/

#if defined(unix)
extern void RISgui_process_fi_form(
	int	g_label)
{
	int	i;
	static	ris_gui_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,			process_cancel_button	},
		{	FI_ACCEPT,			process_accept_button	},
		{	FI_FILE_FIELD,		process_file_field		},
		{	FI_FILES_FIELD,		process_files_field		},
		{	FI_DIRS_FIELD,		process_dirs_field		},
		{	FI_FILE_TYPE_FIELD,	process_file_type_field	},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(ris_gui_label_function);

	GUI_DBG(("RISgui_process_fi_form(g_label:%d)\n", g_label));

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}

	GUI_DBG(("RISgui_process_fi_form:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void update_form()
{
	GUI_DBG(("update_form()\n"));

	free_dirs();
	init_dirs();
	set_dir_field();
	set_dirs_field();
	clear_file_field();
	set_files_field();


	GUI_DBG(("update_form:returning\n"));
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static int fi_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("fi_form_displayed()\n"));

	if (fi_form)
	{
		FIf_is_displayed(fi_form, &form_displayed);
	}

	GUI_DBG(("fi_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
static void display_fi_form(
	const char *title,
	char *type)
{
	int		sts;

	GUI_DBG(("display_fi_form(title:<%s> type:<%s>)\n", STRING(title),
		STRING(type)));

	if (!fi_form)
	{
		sts = FIf_new(FI_FORM, FI_FORM_FILE, RISgui_notification_routine,
			&fi_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_FI_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_fi_form:returning\n"));
			return;
		}
		RISgui_center_form(fi_form);
	}

	update_title(title);
	update_file_type_field(type);
	update_form();

	if (!fi_form_displayed())
	{
		sts = FIf_display(fi_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_FI_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_fi_form:returning\n"));
			return;
		}

		fi_msg->str[0] = 0;
		fi_msg->count = 0;
		fi_msg->msg_fld_label = FI_MESSAGE_FIELD;
		fi_msg->fp = fi_form;
	}

	CLEAR_ERROR;

	GUI_DBG(("display_fi_form:returning\n"));
	return;
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix)
extern void erase_fi_form()
{
	int	sts;

	GUI_DBG(("erase_fi_form()\n"));

	if (fi_form_displayed())
	{
		sts = FIf_erase(fi_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_FI_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("erase_fi_form: returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("erase_fi_form: returning\n"));
	return;
}
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

/******************************************************************************/

extern int RISgui_get_filename(
	int		mode,
	char 	*filter,
	char 	*filename,
	int		size)
{
#if defined(WIN32)
	OPENFILENAME	data;
#elif defined(unix)
#else
ERROR - NO CODE
#endif

	GUI_DBG(("RISgui_get_filename(mode:%d filter:<%s> filename:0x%x)\n",
		mode, STRING(filter), filename));

	exit_status = 0;

#if defined(unix)
	size = size;

	display_fi_form(MSG(mode), filter);

	RISgui_event_loop(fi_form_displayed);

	if (exit_status)
	{
		get_filename(filename);
	}
#elif defined(WIN32)

	memset(&data, '\0', sizeof(OPENFILENAME));
	data.lStructSize = sizeof(OPENFILENAME);

	data.hwndOwner = RISgui_get_in_handle();

	data.lpstrFilter = filter;

	memset(filename, '\0', sizeof(filename));
	data.lpstrFile = filename;
	data.nMaxFile = size;

	if (mode == RISUTL_I_OPEN)
	{
		data.Flags = OFN_FILEMUSTEXIST|OFN_HIDEREADONLY;
		exit_status = GetOpenFileName(&data);
	}
	else if (mode == RISUTL_I_SAVE)
	{
		data.Flags = OFN_OVERWRITEPROMPT|OFN_HIDEREADONLY;
		exit_status = GetSaveFileName(&data);
	}
	if (!exit_status)
	{
		GUI_DBG(("last_error:%d extended_error:%d\n",
			GetLastError(), CommDlgExtendedError()));
	}
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_get_filename:returning exit_status:%d\n", exit_status));

	return exit_status;
}

/******************************************************************************/
