/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							guiutil.c
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

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define guiutil_c
#include "guiutil.prt"
#include "comdebug.prt"
#include "fi.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISgui_set_passwd_echo(
	Form	fp,
	int		toggle_label,
	int		field_label)
{
	int	passwd_echo;
	long	attr_mask;

	GUI_DBG(("RISgui_set_passwd_echo(fp:0x%x toggle_label:%d field_label:%d)\n",
		fp, toggle_label, field_label));

	FIg_get_state(fp, toggle_label, &passwd_echo);
	
	FIfld_get_attr(fp, field_label, 0, &attr_mask);
	if (passwd_echo)
	{
		attr_mask &= ~FI_NO_ECHO;
	}
	else
	{
		attr_mask |= FI_NO_ECHO;
	}
	FIfld_set_attr(fp, field_label, 0, attr_mask);
	FIg_display(fp, field_label);

	GUI_DBG(("RISgui_set_passwd_echo: returning\n"));
}

/******************************************************************************/

extern void RISgui_clear_desc(
	sqlda	*desc)
{
	int i;

	GUI_DBG(("RISgui_clear_desc(desc:0x%x)\n",desc));

	if (desc)
	{
		if (desc->sqlvar)
		{
			for (i = 0; i < desc->sqln; i++)
			{
				if (desc->sqlvar[i].sqldata)
				{
					free(desc->sqlvar[i].sqldata);
				}

				if (desc->sqlvar[i].sqlind)
				{
					free(desc->sqlvar[i].sqlind);
				}
			}
		
			free(desc->sqlvar);
		}
		memset(desc, 0, sizeof(sqlda));
	}

	GUI_DBG(("RISgui_clear_desc:returning\n"));
}

/******************************************************************************/

extern void RISgui_disable_gadgets(
	Form fp,
	int list[],
	int count)
{
	int i;
	GUI_DBG(("RISgui_disable_gadgets(fp:0x%x list:0x%x count:%d)\n",
		fp, list, count));

	for (i = 0; i< count; i++)
		FIg_disable(fp, list[i]);
	
	GUI_DBG(("RISgui_disable_gadgets:returning\n"));
}

/******************************************************************************/

extern void RISgui_enable_gadgets(
	Form fp,
	int list[],
	int count)
{
	int i;
	GUI_DBG(("RISgui_enable_gadgets(fp:0x%x list:0x%x count:%d)\n",
		fp, list, count));

	for (i = 0; i< count; i++)
		FIg_enable(fp, list[i]);
	
	GUI_DBG(("RISgui_enable_gadgets:returning\n"));
}

/******************************************************************************/

extern int RISgui_strcmp_wildcard(
	char *s1,	/* string with possible wild card */
	char *s2)	/* string to compare against */
{
	if (*s1 == MULTI_WILDCARD_CHAR)
	{
		while(*s1 == MULTI_WILDCARD_CHAR)
			s1++;

		while(*s2)
		{
			if(RISgui_strcmp_wildcard(s1, s2) == 0)
				return 0;
			s2++;
		}

		if (*s1 == 0 && *s2 == 0)
			return 0;
	}
	else if (*s1 == SINGLE_WILDCARD_CHAR)
	{
		if (*s2)
			return RISgui_strcmp_wildcard(s1+1, s2+1);
		else
			return 1;
	}
	else
	{
		if (*s1 == *s2)
		{
			if (*s1 == 0) /* which implies s2 == 0 */
			{
				return 0;
			}
			return RISgui_strcmp_wildcard(s1+1, s2+1);
		}
		else
		{
			return 1;
		}
	}

	return 1;
}

/******************************************************************************/

extern char *RISgui_substrcmp(
	char *str,
	char *substr)
{
	int i;
	int str_len;
	int substr_len;

	str_len = strlen(str);
	substr_len = strlen(substr);

	for (i = 0; i <= (str_len - substr_len); i++)
	{
		if (!strncmp(str + i, substr, substr_len))
		{
			return str + i;
		}
	}

	return NULL;
}

/******************************************************************************/
