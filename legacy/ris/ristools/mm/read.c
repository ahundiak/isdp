/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
/*
**	NAME:							read.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

/*
**	INCLUDES
*/
#include "mm.h"
#include "stack.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define read_c
#include "preproc.prt"
#include "depend.prt"
#include "ignore.prt"
#include "path.prt"
#include "read.prt"
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

static void read_source_file(
	FILE	*fp,
	char	*filename,
	int		file_index)
{
	int		line;
	int		stack_index = 0;
	stack_s	stack[MAX_STACK];
	char	s[BUFSIZ];
	char	*ptr;
	char	*type;

	DBG(("read_source_file(fliename:<%s> file_index:%d)\n",
		filename, file_index));

	line = 0;
	INIT_STACK();

	while(fgets(s, BUFSIZ, fp))
	{
		line++;
		if (s[0] != '#') continue;

		type = NULL;
		switch(preprocessor_directive(filename, line, s, &ptr, &type))
		{
			case IF_TRUE:
				PUSH(READ, line, type);
				break;

			case IF_FALSE:
				PUSH(SKIP, line, type);
				break;

			case IF_UNKNOWN:
				if (warnings)
				{
					ERRHEADER(line, filename);
					fprintf(stderr,
						"Ignoring preprocessor directive: %s.\n", s);
				}
				PUSH(READ_BOTH, line, type);
				break;

			case ELIF_UNKNOWN:
				if (warnings)
				{
					ERRHEADER(line, filename);
					fprintf(stderr,
						"Ignoring preprocessor directive: %s.\n", s);
				}
				break;

			case IF_INVALID:
			case ELIF_INVALID:
				error_count++;
				ERRHEADER(line, filename);
				fprintf(stderr, "Invalid preprocessor directive: %s.\n", s);
				DBG(("read_source_file: returning\n"));
				return;

			case ELIF_TRUE:
				if (STACK_EMPTY())
				{
					error_count++;
					ERRHEADER(line, filename);
					fprintf(stderr, "Unmatched #elif.\n");
					DBG(("read_source_file: returning\n"));
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
					ERRHEADER(line, filename);
					fprintf(stderr, "Unmatched #elif.\n");
					DBG(("read_source_file: returning\n"));
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
					ERRHEADER(line, filename);
					fprintf(stderr, "Unmatched #else.\n");
					DBG(("read_source_file: returning\n"));
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
					ERRHEADER(line, filename);
					fprintf(stderr, "Unmatched #endif.\n");
					DBG(("read_source_file: returning\n"));
					return;
				}
				POP();
				break;

			case INCLUDE:
			{
				int		include_error = 0;
				char	*include_filename = NULL;

				if (!OK_TO_READ()) break;

				if (*ptr == '<')
				{
					ptr++;
					include_filename = ptr;

					while(1)
					{
						if (!*ptr)
						{
							include_error = 1; break;
						}
						if (*ptr == '>')
						{
							*ptr = '\0'; break;
						}
						ptr++;
					}
				}
				else if (*ptr == '\"')
				{
					ptr++;
					include_filename = ptr;
					while(1)
					{
						if (!*ptr)
						{
							include_error = 1; break;
						}
						if (*ptr == '\"')
						{
							*ptr = '\0'; break;
						}
						ptr++;
					}
				}
				else
				{
					include_error = 1;
				}

				if (include_error)
				{
					error_count++;
					ERRHEADER(line, filename);
					fprintf(stderr, "Invalid #include.\n");
					DBG(("read_source_file: returning\n"));
					return;
				}

				if (!strcmp(include_filename, filename))
				{
					error_count++;
					ERRHEADER(line, filename);
					fprintf(stderr, "File includes itself.\n");
					DBG(("read_source_file: returning\n"));
					return;
				}

				DBG(("include filename:<%s>\n", include_filename));
				read_depend(include_filename, filename, file_index);
			}
			break;

			default:
				break;
		}
	}

	if (!(STACK_EMPTY()))
	{
		error_count++;
		ERRHEADER(line, filename);
		fprintf(stderr, "Unmatched %s on line %d.\n", stack[stack_index].type,
			stack[stack_index].line);
		DBG(("read_source_file: returning\n"));
		return;
	}

	DBG(("read_source_file: returning\n"));
}

/******************************************************************************/

static void read_depend(
	char	*filename,
	char	*parent,
	int		parent_index)
{
	int		file_index;
	FILE	*fp = NULL;

	char	path[PATH_MAX];

	DBG(("read_depend(filename:<%s> parent:<%s>)\n", filename, parent));

	if ((fp = fopen_with_paths(filename, "r", path)) == NULL)
	{
		if (add_file(filename, &file_index))
		{
			error_count++;
			fprintf(stderr,
				"%s: Unable to open \"%s\" included by \"%s\": %s\n", exe,
				filename, parent, strerror(errno));
		}
		return;
	}

	if (!ignore(path))
	{
		if (add_file(path, &file_index))
		{
			read_source_file(fp, path, file_index);
		}

		add_file_depend(parent_index, file_index);
	}

	fclose(fp);


	DBG(("read_depend:returning\n"));
}

/******************************************************************************/

extern void read_dependencies(
	char *filename,
	char *obj_filename)
{
	int		file_index;
	char	path[PATH_MAX];
	FILE	*fp = NULL;

	DBG(("read_dependencies(filename:<%s> obj_filename:<%s>)\n",
		filename, obj_filename));

	if (*filename == '/')
	{
		strcpy(path, filename);
	}
	else
	{
		sprintf(path, "%s%c%s", src, PATH_CHAR, filename);
	}
	if ((fp = fopen(path, "r")) == NULL)
	{
		error_count++;
		fprintf(stderr, "%s: Unable to open \"%s\": %s\n",
			exe, path, strerror(errno));
		return;
	}

	add_file(path, &file_index);
	read_source_file(fp, path, file_index);
	fclose(fp);

	write_depends(obj_filename, file_index);
	
	DBG(("read_dependencies:returning\n"));
}

/******************************************************************************/
