/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							guistack.c
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
#include "rispath.h"
#if defined(WIN32)
#include <io.h>
#elif defined(unix) && !defined(__clipper__)
#include <unistd.h>
#endif

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define guistack_c
#include "guierror.prt"
#include "guistack.prt"
#include "comdebug.prt"
#include "comumsg.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static query_stack_s		*query_stack_head = NULL;
static query_stack_s		*query_stack_ptr = NULL;
static char					*filename;
static char					filebuf[256];

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISgui_query_stack_push(
	char *query)
{
	query_stack_s *temp;

	GUI_DBG(("RISgui_query_stack_push(query:<%s>)\n", STRING(query)));

	if (query_stack_head->prev && !strcmp(query, query_stack_head->prev->query))
	{
		GUI_DBG(("RISgui_query_stack_push:query == prev->query:returning\n"));
		return;
	}
	temp = (query_stack_s *)malloc(sizeof(query_stack_s));
	temp->query = (char *)malloc(strlen(query) + 1);
	strcpy(temp->query, query);

	temp->prev = query_stack_head->prev;
	if (query_stack_head->prev)
	{
		query_stack_head->prev->next = temp;
	}
	query_stack_head->prev = temp;
	temp->next = query_stack_head;

	query_stack_ptr = query_stack_head;

	GUI_DBG(("RISgui_query_stack_push:returning\n"));
}

/******************************************************************************/

extern int RISgui_query_stack_next(
	char *query)
{
	int return_sts = 1;

	GUI_DBG(("RISgui_query_stack_next(query:0x%x)\n", query));

	if (query_stack_ptr && query_stack_ptr->next)
	{
		query_stack_ptr = query_stack_ptr->next;
		strcpy(query, query_stack_ptr->query);
		return_sts = 0;
	}

	GUI_DBG(("RISgui_query_stack_next:returning %d\n", return_sts));
	return return_sts;
}

/******************************************************************************/

extern int RISgui_query_stack_next_invalid()
{
	int return_sts = 1;

	GUI_DBG(("RISgui_query_stack_next_invalid()\n"));

	if (query_stack_ptr && query_stack_ptr->next)
	{
		return_sts = 0;
	}

	GUI_DBG(("RISgui_query_stack_next_invalid:returning %d\n", return_sts));
	return return_sts;
}

/******************************************************************************/

extern int RISgui_query_stack_prev(
	char *query)
{
	int len;
	int return_sts = 1;

	GUI_DBG(("RISgui_query_stack_prev(query:0x%x)\n", query));

	if (query_stack_ptr == query_stack_head)
	{
		if (strcmp(query_stack_head->query, query))
		{
			len = strlen(query);
			query_stack_ptr->query =
				(char *)realloc(query_stack_ptr->query,len+1);
			strcpy(query_stack_ptr->query, query);
		}
	}

	if (query_stack_ptr && query_stack_ptr->prev)
	{
		query_stack_ptr = query_stack_ptr->prev;
		strcpy(query, query_stack_ptr->query);
		return_sts = 0;
	}

	GUI_DBG(("RISgui_query_stack_prev:returning %d\n", return_sts));
	return return_sts;
}

/******************************************************************************/

extern int RISgui_query_stack_prev_invalid()
{
	int return_sts = 1;

	GUI_DBG(("RISgui_query_stack_prev_invalid()\n"));

	if (query_stack_ptr && query_stack_ptr->prev)
	{
		return_sts = 0;
	}

	GUI_DBG(("RISgui_query_stack_prev_invalid:returning %d\n", return_sts));
	return return_sts;
}

/******************************************************************************/

extern void RISgui_query_stack_load()
{
	int				len;
	char			*home;
	char			msg[384];
	FILE			*fp;
	query_stack_s	*temp;

	GUI_DBG(("RISgui_query_stack_load()\n"));

	/*
	** Make room for the current command.
	*/
	query_stack_head = (query_stack_s *)malloc(sizeof(query_stack_s));
	query_stack_head->query = (char *)malloc(1);
	query_stack_head->query[0] = 0;
	query_stack_head->next = NULL;
	query_stack_head->prev = NULL;

	query_stack_ptr = query_stack_head;

	if ((filename = getenv("RIS_HISTORY_FILE")) == NULL)
	{
		if ((home = getenv("HOME")) != NULL)
		{
			int len;

			len = strlen(home);
			if (home[len - 1] == PATH_CHAR)
			{
				sprintf(filebuf, "%s%s", home, RIS_HISTORY_FILE);
			}
			else
			{
				sprintf(filebuf, "%s%c%s", home, PATH_CHAR, RIS_HISTORY_FILE);
			}
			filename = filebuf;
		}
		else
		{
			filename = RIS_HISTORY_FILE;
		}
	}
	else if (!*filename) 	/* indicates history not wanted */
	{
		GUI_DBG(("RISgui_query_stack_load: returning\n"));
		return;
	}

	/*
	**	load_old_cmds
	*/
	GUI_DBG(("RISgui_query_stack_load:filename:<%s>\n", STRING(filename)));
#if defined(unix)
	if (access(filename, F_OK))
#elif defined(WIN32)
	if (_access(filename, 00))
#else
ERROR - NO CODE
#endif
	{
		sprintf(msg, MSG(RISUTL_I_NEW_HISTORY_FILE), filename);
		RISgui_note_box(msg);

		GUI_DBG(("RISgui_query_stack_load: new history file:returning\n"));
		return;
	}

	if ((fp = fopen(filename, "r")) == NULL)
	{
		sprintf(msg, MSG(RISUTL_I_READ_HISTORY_FILE), filename);
		RISgui_warning_box(msg);

		GUI_DBG(("RISgui_query_stack_load: fp == NULL:returning\n"));
		return;
	}

	while ((fscanf(fp, "%d", &len) != EOF) && len > 0)
	{
		temp = (query_stack_s *)malloc(sizeof(query_stack_s));
		temp->query = (char *)malloc(len + 1);
		fread(temp->query, len, 1, fp);
		temp->query[len] = 0;

		query_stack_ptr->prev = temp;
		temp->next = query_stack_ptr;
		temp->prev = NULL;
		query_stack_ptr = temp;

		len = 0;
	}
	fclose(fp);

	query_stack_ptr = query_stack_head;

	GUI_DBG(("RISgui_query_stack_load:returning\n"));
}

/******************************************************************************/

extern void RISgui_query_stack_save()
{
	int				len;
	int				count;
	char			msg[384];
	FILE			*fp;
	query_stack_s	*temp;

	GUI_DBG(("RISgui_query_stack_save()\n"));

	if (!query_stack_head)
	{
		GUI_DBG(("RISgui_query_stack_save:!query_stack_head:returning\n"));
		return;
	}

	if (!filename || !*filename)
	{
		GUI_DBG(("RISgui_query_stack_save: filename == NULL:returning\n"));
		return;
	}

	if ((fp = fopen(filename, "w")) == NULL)
	{
		sprintf(msg, MSG(RISUTL_I_WRITE_HISTORY_FILE), filename);
		RISgui_warning_box(msg);

		GUI_DBG(("RISgui_query_stack_save: fp == NULL:returning\n"));
		return;
	}

	/* skip the current command */
	query_stack_head = query_stack_head->prev;

	count = 0;
	while(query_stack_head)
	{
		if (query_stack_head->query)
		{
			if (count < MAX_CMDS)
			{
				len = strlen(query_stack_head->query);
				fprintf(fp, "%d%s", len, query_stack_head->query);
				count++;
			}
			free(query_stack_head->query);
		}

		temp = query_stack_head;
		query_stack_head = query_stack_head->prev;
		free(temp);	
	}

	fclose(fp);

	GUI_DBG(("RISgui_query_stack_save:returning\n"));
}

/******************************************************************************/

extern query_stack_s *RISgui_query_stack_head()
{
	return query_stack_head;
}

/******************************************************************************/
