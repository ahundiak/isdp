/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							data.c
**	AUTHORS:						
**	CREATION DATE:					
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <ctype.h>
#include "tpg.h"

/*
**	DEFINES
*/

#define RULES_FILE					"RULES_FILE:"
#define RULES_FILE_SIZE				(sizeof(RULES_FILE)-1)

#define INC_FILE					"INCLUDE_FILE:"
#define INC_FILE_SIZE				(sizeof(INC_FILE)-1)

#define ERR_MSG_DATA_FILE			"ERR_MSG_DATA_FILE:"
#define ERR_MSG_DATA_FILE_SIZE		(sizeof(ERR_MSG_DATA_FILE)-1)

#define UMS_MSG_DATA_FILE			"UMS_MSG_DATA_FILE:"
#define UMS_MSG_DATA_FILE_SIZE		(sizeof(UMS_MSG_DATA_FILE)-1)

#define PROD_MSG_DATA_FILE			"PROD_MSG_DATA_FILE:"
#define PROD_MSG_DATA_FILE_SIZE		(sizeof(PROD_MSG_DATA_FILE)-1)

#define TOK_MSG_DATA_FILE			"TOK_MSG_DATA_FILE:"
#define TOK_MSG_DATA_FILE_SIZE		(sizeof(TOK_MSG_DATA_FILE)-1)

#define FIRST_FILE					"FIRST_FILE:"
#define FIRST_FILE_SIZE				(sizeof(FIRST_FILE)-1)
	
#define DECLARE_FILE				"DECLARE_FILE:"
#define DECLARE_FILE_SIZE			(sizeof(DECLARE_FILE)-1)

#define KEYWORDS_FILE				"KEYWORDS_FILE:"
#define KEYWORDS_FILE_SIZE			(sizeof(KEYWORDS_FILE)-1)

#define ADDITIONAL_KEYWORD			"ADDITIONAL_KEYWORD:"
#define ADDITIONAL_KEYWORD_SIZE		(sizeof(ADDITIONAL_KEYWORD)-1)

#define NON_KEYWORD					"NON_KEYWORD:"
#define NON_KEYWORD_SIZE			(sizeof(NON_KEYWORD)-1)

/*
**	FUNCTION PROTOTYPES
*/
#define data_c
#include "data.prt"
#include "read.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

static struct file_data_s
{
	char	*name;
	int		size;
	char	*ptr;
} file_data[] = 
{
	{	RULES_FILE,			RULES_FILE_SIZE,			rules_file			},
	{	ERR_MSG_DATA_FILE,	ERR_MSG_DATA_FILE_SIZE,		err_msg_data_file	},
	{   UMS_MSG_DATA_FILE,	UMS_MSG_DATA_FILE_SIZE,		ums_msg_data_file   },
	{	PROD_MSG_DATA_FILE,	PROD_MSG_DATA_FILE_SIZE,	prod_msg_data_file	},
	{	TOK_MSG_DATA_FILE,	TOK_MSG_DATA_FILE_SIZE,		tok_msg_data_file	},
	{	FIRST_FILE,			FIRST_FILE_SIZE,			first_file			},
	{	DECLARE_FILE,		DECLARE_FILE_SIZE,			declare_file		},
	{	KEYWORDS_FILE,		KEYWORDS_FILE_SIZE,			keywords_file		},
};
static int file_data_count = sizeof(file_data)/sizeof(struct file_data_s);

/*
**	FUNCTIONS
*/

/**************************************************************************/


extern void remove_white_space(
	char *s)
{
	char *src;
	char *dst;

	for (src = s, dst = s; *src; src++)
	{
		if (!isspace(*src))
			*dst++ = *src;
	}
	*dst = '\0';
}

/******************************************************************************/

#if defined(WIN32) || defined(DOS)
static void adjust_path_for_dos(
	char *path)
{
	while(*path)
	{
		if (*path == '/')
			*path = '\\';
		path++;
	}
}
#endif

/**************************************************************************/

extern void remove_leading_trailing_white_space(
	char *s)
{
	char *src;
	char *dst;

	for (src = s, dst = s; *src && isspace(*src); src++);

	for (;*src; src++, dst++)
		*dst = *src;

	for (; dst > s && isspace(*(dst-1)); dst--);

	*dst = '\0';
}

/******************************************************************************/

extern void read_data(
	char *data_file)
{
	int i;
	char s[256];
	char *path;
	name_s *ptr;
	name_s **include_file_list_ptr = &include_file_list;
	name_s **add_keyword_list_ptr = &add_keyword_list;
	name_s **non_keyword_list_ptr = &non_keyword_list;


	in_line = 0;
	in_file = data_file;
	if ((in_fp = fopen(in_file,OPEN_TO_READ_MODE)) == NULL)
	{
		err_msg("unable to open \"%s\" to read.\n", in_file);
		exit(1);
	}

	while(get_s(s) != NULL)
	{
		if (s[0] == '#') continue;
		
		remove_white_space(s);

		if (s[0] == '\0') continue;

		for (i = 0; i < file_data_count; i++)
		{
			if (!strncmp(s, file_data[i].name, file_data[i].size))
			{
				if (*file_data[i].ptr)
				{
					err_msg("%s has already been specified\n",
						file_data[i].name);
					exit(1);
				}
				path = s + file_data[i].size;
#if defined(WIN32) || defined(DOS)
				adjust_path_for_dos(path);
#endif
				strcpy(file_data[i].ptr, path);
				break;
			}
		}

		if (i == file_data_count)
		{
			if (!strncmp(s, INC_FILE, INC_FILE_SIZE))
			{
				path = s + INC_FILE_SIZE;
#if defined(WIN32) || defined(DOS)
				adjust_path_for_dos(path);
#endif
				MALLOC((*include_file_list_ptr), name_s);
				strcpy((*include_file_list_ptr)->name, path);
				include_file_list_ptr = &((*include_file_list_ptr)->next);
				continue;
			}
			if (!strncmp(s, ADDITIONAL_KEYWORD, ADDITIONAL_KEYWORD_SIZE))
			{
				MALLOC((*add_keyword_list_ptr), name_s);
				strcpy((*add_keyword_list_ptr)->name,
					s + ADDITIONAL_KEYWORD_SIZE);
				add_keyword_list_ptr = &((*add_keyword_list_ptr)->next);
				continue;
			}
			if (!strncmp(s, NON_KEYWORD, NON_KEYWORD_SIZE))
			{
				MALLOC((*non_keyword_list_ptr), name_s);
				strcpy((*non_keyword_list_ptr)->name, s + NON_KEYWORD_SIZE);
				non_keyword_list_ptr = &((*non_keyword_list_ptr)->next);
				continue;
			}
			err_msg("invalid data:<%s>\n", s);
			exit(1);
		}
	}
	fclose(in_fp);

	for (i = 0; i < file_data_count; i++)
	{
		if (!(*file_data[i].ptr))
		{
			err_msg("%s has not been specified\n", file_data[i].name);
			exit(1);
		}
		VERBOSE(("%s%s\n", file_data[i].name, file_data[i].ptr));
	}

	if (verbose)
	{
		for (ptr = include_file_list; ptr; ptr = ptr->next)
			printf("%s%s\n", INC_FILE, ptr->name);

		for (ptr = add_keyword_list; ptr; ptr = ptr->next)
			printf("%s%s\n", ADDITIONAL_KEYWORD, ptr->name);

		for (ptr = non_keyword_list; ptr; ptr = ptr->next)
			printf("%s%s\n", NON_KEYWORD, ptr->name);
	}
}

/*************************************************************************/

