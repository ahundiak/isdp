/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
/*
**	NAME:							readm.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "mm.h"
#include "stack.h"

/*
**	DEFINES
*/
#define BUFFER_SIZE		256

#define INCLUDES		1
#define SRC				2
#define SOURCE			3
#define SPECIAL			4
#define	POST_SPECIAL	5
#define IGNORE			6

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define readm_c
#include "ignore.prt"
#include "mm.prt"
#include "output.prt"
#include "path.prt"
#include "preproc.prt"
#include "readm.prt"
#include "special.prt"
#include "stack.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
#if defined(unix) || defined(WIN32)
extern int	errno;
#endif
#if defined(DOS)
extern volatile int	errno;
#endif

/*
**	FUNCTIONS
*/

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

/******************************************************************************/

static int get_obj_filename(
	char *name,
	char *obj_name)
{
	int		sts;
	char	*ptr;

	strcpy(obj_name, name);
	if ((ptr = strrchr(obj_name, '.')) == NULL)
	{
		return -1;
	}

	ptr++;

	if (*ptr == 'c' && *(ptr + 1) == '\0')
	{
		sts = C_TYPE;
	}
	else if (*ptr == 'r' && *(ptr + 1) == 'c' && *(ptr + 2) == '\0')
	{
		sts = RC_TYPE;
	}
	else
	{
		sts = UNK_TYPE;
	}

#if defined(unix)
	*ptr++ = 'o';
#endif
#if defined(WIN32) || defined(DOS)
	*ptr++ = 'o';
	*ptr++ = 'b';
	*ptr++ = 'j';
#endif
	*ptr = '\0';

	return sts;
}

/******************************************************************************/

extern void read_m_file(
	char *name)
{
	int		line = 0;
	int		state = 0;
	int		stack_index = 0;
	stack_s	stack[MAX_STACK];
	char	buffer[BUFFER_SIZE];
	char	*ptr;
	char	*type;
	FILE	*fp;

	if ((fp = fopen(name, "r")) == NULL)
	{
		fprintf(stderr, "%s: Unable to open \"%s\": %s\n", exe, name,
			strerror(errno));
		EXIT(1);
	}

	while(fgets(buffer, BUFFER_SIZE, fp))
	{
		line++;

		type = NULL;
		if (buffer[0] == '#')
		{
			switch(preprocessor_directive(name, line, buffer, &ptr, &type))
			{
				case IF_TRUE:
					PUSH(READ,line, type);
					break;

				case IF_FALSE:
					PUSH(SKIP,line, type);
					break;

				case ELIF_TRUE:
					if (STACK_EMPTY())
					{
						error_count++;
						ERRHEADER(line, name);
						fprintf(stderr, "Unmatched #elif.\n");
						DBG(("read_m_file: returning\n"));
						return;
					}
					switch(POP())
					{
						case READ:		PUSH(SKIP_REST, line, type);	break;
						case READ_BOTH:	PUSH(READ_BOTH, line, type);	break;
						case SKIP:		PUSH(READ, line, type);			break;
						case SKIP_REST:	PUSH(SKIP_REST, line, type);	break;
					}
					break;

				case ELIF_FALSE:
					if (STACK_EMPTY())
					{
						error_count++;
						ERRHEADER(line, name);
						fprintf(stderr, "Unmatched #elif.\n");
						DBG(("read_m_file: returning\n"));
						return;
					}
					switch(POP())
					{
						case READ:		PUSH(SKIP_REST, line, type);	break;
						case READ_BOTH:	PUSH(READ_BOTH, line, type);	break;
						case SKIP:		PUSH(SKIP, line, type);			break;
						case SKIP_REST:	PUSH(SKIP_REST, line, type);	break;
					}
					break;
	
				case ELSE:
					if (STACK_EMPTY())
					{
						error_count++;
						ERRHEADER(line, name);
						fprintf(stderr, "Unmatched #else.\n");
						DBG(("read_m_file: returning\n"));
						return;
					}
					switch(POP())
					{
						case READ:		PUSH(SKIP, line, type);			break;
						case READ_BOTH:	PUSH(READ_BOTH, line, type);	break;
						case SKIP:		PUSH(READ, line, type);			break;
						case SKIP_REST:	PUSH(SKIP_REST, line, type);	break;
					}
					break;

				case ENDIF:
					if (STACK_EMPTY())
					{
						error_count++;
						ERRHEADER(line, name);
						fprintf(stderr, "Unmatched #endif.\n");
						DBG(("read_m_file: returning\n"));
						return;
					}
					POP();
					break;

				case IF_UNKNOWN:
				case IF_INVALID:
				case ELIF_UNKNOWN:
				case ELIF_INVALID:
				case INCLUDE:
				default:
					error_count++;
					ERRHEADER(line, name);
					fprintf(stderr, "Invalid preprocessor directive: %s.\n",
						buffer);
					DBG(("read_m_file: returning\n"));
					return;
			}
		}
		else if (OK_TO_READ())
		{
			ptr = buffer;

			if (state != SPECIAL && state != POST_SPECIAL)
			{
				SKIP_WHITE_SPACE(ptr);
				if (!*ptr || *ptr == '#') continue;
			}

			if (MATCH(buffer, "INCLUDE"))
			{
				state = INCLUDES;
			}
			else if (MATCH(buffer, "SRC"))
			{
				state = SRC;
			}
			else if (MATCH(buffer, "SOURCE"))
			{
				state = SOURCE;
			}
			else if (MATCH(buffer, "SPECIAL"))
			{
				state = SPECIAL;
			}
			else if (MATCH(buffer, "POST_SPECIAL"))
			{
				state = POST_SPECIAL;
			}
			else if (MATCH(buffer, "IGNORE"))
			{
				state = IGNORE;
			}
			else if (MATCH(buffer, "END"))
			{
				state = 0;
			}
			else
			{
				switch(state)
				{
					case INCLUDES:
					{
						char *path;
						char expanded_path[PATH_MAX];

						path = ptr;
						SKIP_TO_WHITE_SPACE(ptr);
						*ptr = '\0';

#if defined(WIN32) || defined(DOS)
						adjust_path_for_dos(path);
#endif
						expand_path(path, expanded_path, name, line);
						add_path(expanded_path);
					}
					break;

					case SRC:
					{
						char *path;
						char expanded_path[PATH_MAX];

						path = ptr;
						SKIP_TO_WHITE_SPACE(ptr);
						*ptr = '\0';

#if defined(WIN32) || defined(DOS)
						adjust_path_for_dos(path);
#endif
						expand_path(path, expanded_path, name, line);
						strcpy(src, expanded_path);
						state = 0;
					}
					break;

					case SOURCE:
					{
						int		type;
						char	*filename;
						char	obj_filename[PATH_MAX];

						filename = ptr;
						SKIP_TO_WHITE_SPACE(ptr);
						*ptr = '\0';

#if defined(WIN32) || defined(DOS)
						adjust_path_for_dos(filename);
#endif
						type = get_obj_filename(filename, obj_filename);
						if (type == -1)
						{
							ERRHEADER(line, name);
							fprintf(stderr, "Invalid source file: \"%s\"\n",
								filename);
							EXIT(1);
						}

						add_source(type, filename, obj_filename);
					}
					break;

					case SPECIAL:
					{
						add_pre_special(ptr);
					}
					break;

					case POST_SPECIAL:
					{
						add_post_special(ptr);
					}
					break;

					case IGNORE:
					{
						char *path;
						char expanded_path[PATH_MAX];

						path = ptr;
						SKIP_TO_WHITE_SPACE(ptr);
						*ptr = '\0';

#if defined(WIN32) || defined(DOS)
						adjust_path_for_dos(path);
#endif
						expand_path(path, expanded_path, name, line);
						add_ignore(expanded_path);
					}
					break;

					default:
					break;
				}
			}
		}
	}
	fclose(fp);

	if (!STACK_EMPTY())
	{
		error_count++;
		ERRHEADER(line, name);
		fprintf(stderr, "Unmatched %s on line %d\n", stack[stack_index].type,
			stack[stack_index].line);
		DBG(("read_m_file: returning\n"));
		return;
	}
}

/******************************************************************************/
