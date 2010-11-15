/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							msg.c
**	AUTHORS:						
**	CREATION DATE:					
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/


/*
** TYPES
*/

/*
** INCLUDES
*/

#include <stdio.h>
#include "tpg.h"

/*
**	FUNCTION PROTOTYPES
*/
#define msg_c
#include "msg.prt"
#include "read.prt"
#include "data.prt"
#include "sys.prt"


/*
** DEFINES
*/

#define NAME_STATE	0
#define MSG_STATE	1

#define ERROR				"ERROR_NAME:"
#define ERROR_SIZE			(sizeof(ERROR)-1)

#define PROD				"PRODUCTION_NAME:"
#define PROD_SIZE			(sizeof(PROD)-1)

#define TOKEN				"TOKEN_NAME:"
#define TOKEN_SIZE			(sizeof(TOKEN)-1)

#define MSG					"MESSAGE:"
#define MSG_SIZE			(sizeof(MSG)-1)

#define DEFAULT_ERROR_MSG	"Error message to be defined."

/*
**	VARIABLES
*/

static	msg_s	*err_msg_list = NULL;
static	msg_s	*new_err_msg_list = NULL;
static	msg_s	*prod_msg_list = NULL;
static	msg_s	*new_prod_msg_list = NULL;
static	msg_s	*tok_msg_list = NULL;
static	msg_s	*new_tok_msg_list = NULL;

/******************************************************************************/

static void add_msg(
	char *name,
	char *msg,
	msg_s **listp)
{
	int		sts;
	msg_s	*temp;

	for (; (*listp); listp = &((*listp)->next))
	{
		if ((sts = strcmp(name, (*listp)->name)) < 0)
		{
			MALLOC(temp, msg_s);
			strcpy(temp->name, name);
			strcpy(temp->msg, msg);
			temp->next = (*listp);
			*listp = temp;
			return;
		}

		if (sts == 0)
		{
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

static void read_msg_file(
	char	*filename,
	char	*name_str,
	int		name_len,
	msg_s	**listp)
{
	int state;
	int	cmp_len = 0;
	char *cmp_str = "";
	char *ptr;
	char s[256];
	char name[48];
	extern char *get_s();

	in_line = 0;
	in_file = filename;
	if ((in_fp = fopen(in_file,OPEN_TO_READ_MODE)) == NULL)
	{
		err_msg("unable to open \"%s\" to read.\n", in_file);
		exit(1);
	}

	state = NAME_STATE;
	while(1)
	{
		if (get_s(s) == NULL)
			break;

		if (s[0] == '#') continue;
		if (s[0] == '\0') continue;

		switch(state)
		{
			case NAME_STATE:
				cmp_str = name_str;
				cmp_len = name_len;
				break;

			case MSG_STATE:
				cmp_str = MSG;
				cmp_len = MSG_SIZE;
				break;
		}

		if (strncmp(s, cmp_str, cmp_len))
		{
			err_msg("expected \"%s\"; got \"%s\"\n", cmp_str, s);
			exit(1);
		}

		switch(state)
		{
			case NAME_STATE:
				ptr = s + cmp_len;
				remove_white_space(ptr);
				if (!*ptr)
				{
					err_msg("expected a name; got nothing\n");
					exit(1);
				}
				strcpy(name, ptr);
				state = MSG_STATE;
				break;

			case MSG_STATE:
				ptr = s + cmp_len;
				remove_leading_trailing_white_space(ptr);
				if (*ptr)
					add_msg(name, ptr, listp);
				state = NAME_STATE;
				break;
		}
	}
	fclose(in_fp);
}

/******************************************************************************/

static char *get_msg(
	char *name,
	msg_s	*list,
	msg_s	**new_listp)
{
	int		sts;
	msg_s	*ptr;

	for (ptr = list; ptr; ptr = ptr->next)
	{
		if ((sts = strcmp(name, ptr->name)) == 0)
		{
			add_msg(name, ptr->msg, new_listp);

			return ptr->msg;
		}

		if (sts < 0)
			break;
	}

	/*
	**	The message wasn't found;
	*/
	add_msg(name, "", new_listp);

	return NULL;
}

/******************************************************************************/

static void write_msg_file(
	char *filename,
	char *name_str,
	msg_s *list)
{
	char	filename0[512];
	msg_s	*ptr;
	FILE	*out_fp;

	sprintf(filename0,"%s0",filename);
	remove(filename0);
	rename(filename, filename0);
	
	if ((out_fp = fopen(filename,OPEN_TO_WRITE_MODE)) == NULL)
	{
		err_msg("unable to open \"%s\" to read.\n", in_file);
		exit(1);
	}

	for (ptr = list; ptr; ptr = ptr->next)
	{
		if (ptr->msg[0] == '\0')
		{
			fprintf(out_fp, "%s%s\n", name_str, ptr->name);
			fprintf(out_fp, "%s\n\n", MSG);
		}
	}

	for (ptr = list; ptr; ptr = ptr->next)
	{
		if (ptr->msg[0] != '\0')
		{
			fprintf(out_fp, "%s%s\n", name_str, ptr->name);
			fprintf(out_fp, "%s%s\n\n", MSG, ptr->msg);
		}
	}

	fclose(out_fp);
}

/******************************************************************************/

extern void read_err_msg_file()
{
	read_msg_file(err_msg_data_file, ERROR, ERROR_SIZE, &err_msg_list);
}

/******************************************************************************/

extern void read_prod_msg_file()
{
	read_msg_file(prod_msg_data_file, PROD, PROD_SIZE, &prod_msg_list);
}

/******************************************************************************/

extern void read_tok_msg_file()
{
	read_msg_file(tok_msg_data_file, TOKEN, TOKEN_SIZE, &tok_msg_list);
}

/******************************************************************************/

extern char *get_err_msg(
	char *name)
{
	char *sts;

	if ((sts = get_msg(name, err_msg_list, &new_err_msg_list)) == NULL)
		sts = DEFAULT_ERROR_MSG;
	return sts;
}

/******************************************************************************/

extern char *get_prod_msg(
	char *name)
{
	char *sts;

	if ((sts = get_msg(name, prod_msg_list, &new_prod_msg_list)) == NULL)
		sts = name;
	return sts;
}

/******************************************************************************/

extern char *get_tok_msg(
	char *name)
{
	char *sts;

	if ((sts = get_msg(name, tok_msg_list, &new_tok_msg_list)) == NULL)
		sts = name;
	return sts;
}

/******************************************************************************/

extern int write_err_msg_file()
{
	int		return_sts = 0;
	msg_s	*ptr;

	for (ptr = new_err_msg_list; ptr ; ptr =  ptr->next)
	{
		if (ptr->msg[0] == '\0')
		{
			fprintf(stderr, "Error \"%s\" needs a message defined.\n",
				ptr->name);
			return_sts++;	
		}
	}
	write_msg_file(err_msg_data_file, ERROR, new_err_msg_list);
	return return_sts;
}

/******************************************************************************/

extern int write_prod_msg_file()
{
	int		return_sts = 0;
	msg_s	*ptr;

	for (ptr = new_prod_msg_list; ptr ; ptr =  ptr->next)
	{
		if (ptr->msg[0] == '\0')
		{
			fprintf(stderr, "Production \"%s\" needs a message defined.\n",
				ptr->name);
			return_sts++;	
		}
	}
	write_msg_file(prod_msg_data_file, PROD, new_prod_msg_list);
	return return_sts;
}

/******************************************************************************/

extern int write_tok_msg_file()
{
	int		return_sts = 0;
	msg_s	*ptr;

	for (ptr = new_tok_msg_list; ptr ; ptr =  ptr->next)
	{
		if (ptr->msg[0] == '\0')
		{
			fprintf(stderr, "Token \"%s\" needs a message defined.\n",
				ptr->name);
			return_sts++;	
		}
	}
	write_msg_file(tok_msg_data_file, TOKEN, new_tok_msg_list);
	return return_sts;
}

/******************************************************************************/
