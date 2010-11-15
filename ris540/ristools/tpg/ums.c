/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							ums.c
**	AUTHORS:						
**	CREATION DATE:					
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
** DEFINES
*/

/*
** INCLUDES
*/

#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>
#if defined (WIN32) || defined(DOS)
#include <stdlib.h>
#endif
#include "tpg.h"

/*
**	FUNCTION PROTOTYPES
*/
#define ums_c
#include "generate.prt"
#include "msg.prt"
#include "tests.prt"
#include "write.prt"
#include "sys.prt"
#include "ums.prt"


/*
** VARIABLES
*/

static	msg_s	*ums_list = NULL;

/******************************************************************************/

extern void add_ums(
	char *name,
	char *msg)
{
	int		sts;
	msg_s	**listp;

	for (listp = &ums_list; (*listp); listp = &((*listp)->next))
	{
		if ((sts = strcmp(name, (*listp)->name)) == 0)
		{
			if (strcmp((*listp)->msg, msg))
			{
				strcpy((*listp)->msg, msg);
			}
			return;
		}
	}
	if (*listp == NULL)
	{
		MALLOC((*listp), msg_s);
		strcpy((*listp)->name, name);
		strcpy((*listp)->msg, msg);
	}
}

/******************************************************************************/

extern void generate_ums_file()
{
	msg_s	*ptr;
	FILE	*fp;

	VERBOSE(("generate_ums_fille()\n"));

	fp = open_file(ums_msg_data_file);

	for (ptr = ums_list; ptr; ptr = ptr->next)
	{
		my_fprintf(fp, "%s %s\n", ptr->name, ptr->msg);
	}

	close_file(fp, ums_msg_data_file);
}

/******************************************************************************/

extern void read_ums_file()
{
	char	*s;
	char	*msg;
	char	*name;
	char	buffer[300];
	msg_s	**ptr;
	FILE	*fp;

	ptr = &ums_list;

	if ((fp = fopen(ums_msg_data_file, "r")) == NULL)
	{
		return;
	}

	while(fgets(buffer, sizeof(buffer), fp) != NULL)
	{
		if ((s = strchr(buffer, '\n')) != NULL) *s = '\0';

		s = name = buffer;
		while(*s && !isspace(*s))
		{
			s++;
		}

		if (*s)
		{
			*s++ = '\0';
			/* skip white space */
			while(*s && isspace(*s))
			{
				s++;
			}
			msg = s;
		}
		else
		{
			msg = "";
		}

		MALLOC((*ptr), msg_s);
		strcpy((*ptr)->name, name);
		strcpy((*ptr)->msg, msg);
		ptr = &((*ptr)->next);
	}

	fclose(fp);
}

/******************************************************************************/
