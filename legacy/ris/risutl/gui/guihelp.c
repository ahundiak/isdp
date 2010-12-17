/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							guihelp.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					5/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "gui.h"
#include "rislimit.h"
#include "rispath.h"

/*
**	DEFINES
*/
#define HELP_FILE	"risutl.hlp"

/*
**	TYPES
*/
typedef struct path_data_s
{
	char 				path[RIS_MAX_PATH_SIZE];
	struct path_data_s	*next;
} path_data_s;

/*
**	FUNCTION PROTOTYPES
*/
#define guihelp_c
#include "guihelp.prt"
#include "comdebug.prt"
#include "fi.prt"
#include "fi_winnt.prt"
#include "ris.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static path_data_s *paths = NULL;
static path_data_s **current = &paths;
static HWND handle = 0;
static char path[RIS_MAX_PATH_SIZE];

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISgui_append_help_path(
	char *path)
{
	if (path)
	{
		if (((*current) = (path_data_s *)malloc(sizeof(path_data_s))) == NULL)
		{
			return;
		}

		strcpy((*current)->path, path);
		(*current)->next = NULL;

		current = &((*current)->next);
	}
}

/******************************************************************************/

extern void RISgui_display_help(
	Form fp)
{
	path_data_s *ptr;

	FIf_get_window(fp, &handle);

	for (ptr = paths; ptr; ptr = ptr->next)
	{
		sprintf(path, "%s%c%s", ptr->path, PATH_CHAR, HELP_FILE);
		if (_access(path, 04) == 0)
		{
			//WinHelp(handle, path, HELP_CONTENTS, 0);
			WinHelp(handle, path, HELP_KEY, (unsigned long )"risgui");
			return;
		}
	}

	strcpy(path, HELP_FILE);
	//WinHelp(handle, path, HELP_CONTENTS, 0);
	WinHelp(handle, path, HELP_KEY, (unsigned long )"risgui");
}

/******************************************************************************/

extern void RISgui_erase_help()
{
	if (handle)
	{
		WinHelp(handle, path, HELP_QUIT, 0);
	}
}

/******************************************************************************/
