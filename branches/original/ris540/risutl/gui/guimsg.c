/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							guimsg.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/90
**	ABSTRACT:
**		This file contains the routines that manage the message fields for
**		the forms
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Rick Kramer
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include <string.h>
#include "gui.h"

/*
**	FUNCTION PROTOTYPES
*/
#define guimsg_c
#include "comdebug.prt"
#include "fi.prt"
#include "guimsg.prt"
#include "sys.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISgui_display_msgs()
{
	int			i,j;
	ris_gui_msg	*msgp;

	GUI_DBG(("RISgui_display_msgs()\n"));

	for (i = 0; i < FORM_MSG_COUNT; i++)
	{
		msgp = &RIS_gui_msgs[i];
		for (j = 0; j < msgp->count; j++)
		{
			FIg_hilite(msgp->fp, msgp->label[j]);
		}
		if (msgp->str[0])
		{
			RISgui_set_message_text(msgp->fp, msgp->msg_fld_label, msgp->str);
		}
	}
}

/******************************************************************************/

extern void RISgui_clear_msgs()
{
	int			i,j;
	ris_gui_msg	*msgp;

	GUI_DBG(("RISgui_clear_msgs()\n"));

	for (i = 0; i < FORM_MSG_COUNT; i++)
	{
		msgp = &RIS_gui_msgs[i];
		
		for (j = 0; j < msgp->count; j++)
		{
			FIg_unhilite(msgp->fp, msgp->label[j]);
		}
		if (msgp->str[0])
		{
			FIfld_set_text(msgp->fp, msgp->msg_fld_label, 0, 0, "",0);
		}
		msgp->count = 0;
		msgp->str[0] = '\0';
	}
}

/******************************************************************************/

extern void RISgui_set_message_text(
	Form	fp,
	int		label,
	char	*text)
{
	int i,j;

	if (text)
	{
		j = strlen(text);
		for (i = 0; i < j; i++)
		{
			if (text[i] == '\n')
			{
				text[i] = ' ';
			}
		}

		FIfld_set_text(fp, label, 0, 0, text, 0);
	}
	else
	{
		FIfld_set_text(fp, label, 0, 0, "", 0);
	}
/*
this is the original below changed 10/31/94 by Rick for internationalization
	char *s;
	char *d;

	if (text)
	{

		for (s = text, d = text; *s; *s++)
		{
			if (!isprint(*s))
			{
				continue;
			}
			*d++ = *s;
		}
		*d = '\0';

		FIfld_set_text(fp, label, 0, 0, text, 0);
	}
	else
	{
		FIfld_set_text(fp, label, 0, 0, "", 0);
	}
*/
}

/******************************************************************************/
