/* Do not alter this line: $Revision: 1.5.22.1 $ */
/*
**	NAME:							main.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#if defined(sco)
#include <prototypes.h>
#endif

/*
**	DEFINES
*/
#define MAX_TOKENS	50

#define READ		0
#define SKIP		1
#define SKIP_REST	2

#define TOK_FALSE	0
#define TOK_TRUE	1
#define TOK_OR		2
#define TOK_AND		3
#define TOK_NOT		4
#define TOK_LPAREN	5
#define TOK_RPAREN	6
#define TOK_END		7

#define IF_FALSE	0
#define IF_TRUE		1
#define ELIF_FALSE	2
#define ELIF_TRUE	3
#define ELSE		4
#define ENDIF		5
#define INCLUDE		6
#define DEFINE		7
#define OTHER		8

#define DEBUG(x)					if (debug) printf x
#define VERBOSE(x)					if (verbose) printf x
#define	SKIP_WHITE_SPACE(ptr)		while(*(ptr) && isspace(*(ptr))) {(ptr)++;}
#define	SKIP_TO_WHITE_SPACE(ptr)	while(*(ptr) && !isspace(*(ptr))) {(ptr)++;}
#define MALLOC(type)				(type *)malloc(sizeof(type))

/*
**	TYPES
*/
typedef struct data_s
{
	char			data[256];
	char			file[256];
	int				used;
	struct data_s	*next;
}data_s;

/*
**	FUNCTION PROTOTYPES
*/
static int	evaluate_if_tokens();
extern char	*getenv();

/*
**	VARIABLES
*/
int		debug = 0;
int		verbose = 0;
int		warnings = 0;
int		rm_object = 0;
char	*exe = "chk_prt";
char	src_path[256];
char	obj_path[256];
char	*nonfunc_path = NULL;
char	prot_filename[15];

int		if_tokens_index;
char	if_tokens[MAX_TOKENS];
char	*if_string;
char	*if_file;
int		if_line;

data_s	*incpath_list = NULL;
data_s	*nonfunc_list = NULL;
data_s	*def_list = NULL;
data_s	*func_list = NULL;
data_s	*protfile_list = NULL;
data_s	*prot_list = NULL;

extern 	int		errno;
extern	char	*sys_errlist[];

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void Exit(
	int	sts)
{
	char	cmd[300];

	DEBUG(("Exit(sts:%d)\n",sts));
	if (sts && rm_object)
	{
		sprintf(cmd, "rm -f %s 2>&1", obj_path);
		DEBUG(("check_prototypes: executing :<%s>\n", cmd));
		system(cmd);
	}
	exit(sts);
}


/******************************************************************************/

static FILE *open_prototype_file(
	char	*filename,
	char	*mode)
{
	char	path[256];
	data_s	*incpath;
	FILE	*fp = NULL;

	DEBUG(("open_prototype_file(filename:<%s> mode:<%s>)\n",
		filename, mode));

	if (filename[0] == '/')
	{
		DEBUG(("open_prototype_file: Trying to open <%s>\n", filename));
		fp = fopen(filename, mode);
	}
	else
	{
		for (incpath = incpath_list; incpath; incpath = incpath->next)
		{
			sprintf(path, "%s/%s", incpath->data, filename);
			DEBUG(("open_prototype_file: Trying to open <%s>\n", path));
			if ((fp = fopen(path, mode)) != NULL)
				break;
		}
	}
	DEBUG(("open_prototype_file: complete\n"));
	return fp;
}

/******************************************************************************/

static int token_defined(
	char *tok,
	int len)
{
	data_s	*def;

	DEBUG(("token_defined(tok:<%s>, len:%d)\n", tok, len));


	for (def = def_list; def; def = def->next)
	{
		if (!strncmp(tok, def->data, len) && def->data[len] == '\0') 
		{
			return TOK_TRUE;
		}
	}

	return TOK_FALSE;
}

/******************************************************************************/

static int get_next_if_token(
	char	**sp)
{
	char	*ptr;
	int		token = 0;

	DEBUG(("get_next_if_token(*sp:<%s>)\n", *sp));	

	ptr = *sp;
	
	SKIP_WHITE_SPACE(ptr);
	if (!*ptr)
	{
		token = TOK_END;
	}
	else if (!strncmp(ptr, "0", 1))
	{
		ptr += 1;
		token = TOK_FALSE;
	}
	else if (!strncmp(ptr, "1", 1))
	{
		ptr += 1;
		token = TOK_TRUE;
	}
	else if (!strncmp(ptr, "defined", 7))
	{
		int		len;
		int		paren;
		char	*tok;

		ptr += 7;
		paren = 0;

		SKIP_WHITE_SPACE(ptr);
		if (*ptr == '(')
		{
			ptr++;
			paren = 1;
			SKIP_WHITE_SPACE(ptr);
		}
		len = 0;
		tok = ptr;
		while(*ptr && !isspace(*ptr) && *ptr != ')')
		{
			len++;
			ptr++;
		}

		if (paren)
		{
			SKIP_WHITE_SPACE(ptr);
			if (*ptr != ')')
			{
				DEBUG(("get_next_if_token: Expected a ')' for defined(\n"));
				fprintf(stderr,
					"%s: \"%s\", line %d: Invalid #if expression:<%s>\n",
					exe, if_file, if_line, if_string);
				Exit(1);
			}
			ptr++;
		}

		token = token_defined(tok, len);
	}
	else if (*ptr == '&' && *(ptr + 1) == '&')
	{
		ptr += 2;
		token = TOK_AND;
	}
	else if (*ptr == '|' && *(ptr + 1) == '|')
	{
		ptr += 2;
		token = TOK_OR;
	}
	else if (*ptr == '!')
	{
		ptr++;
		token = TOK_NOT;
	}
	else if (*ptr == '(')
	{
		ptr++;
		token = TOK_LPAREN;
	}
	else if (*ptr == ')')
	{
		ptr++;
		token = TOK_RPAREN;
	}
	else
	{
		DEBUG(("get_next_if_token: Unknown token: <%s>\n", ptr));
		fprintf(stderr,"%s: \"%s\", line %d: Invalid #if expression:<%s>\n",
			exe, if_file, if_line, if_string);
		Exit(1);
	}

	*sp = ptr;

	DEBUG(("get_next_if_token: returning token:%d\n", token));	
	return token;
}

/******************************************************************************/

/*
**	get value and increment if_tokens_index
*/

static int get_if_value()
{
	int value = 0;

	DEBUG(("get_if_value()\n"));

	switch(if_tokens[if_tokens_index])
	{
		case TOK_FALSE:
		case TOK_TRUE:
			value = if_tokens[if_tokens_index];
			if_tokens_index++;
			break;

		case TOK_NOT:
			if_tokens_index++;
			value = !get_if_value();
			break;

		case TOK_LPAREN:
			if_tokens_index++;
			value = evaluate_if_tokens();
			if (if_tokens[if_tokens_index] != TOK_RPAREN)
			{
				DEBUG(("get_if_value: expected TOK_RPAREN got:%d\n",
					if_tokens[if_tokens_index]));
				fprintf(stderr,
					"%s: \"%s\", line %d: Invalid #if expression:<%s>\n",
					exe, if_file, if_line, if_string);
				Exit(1);
			}
			if_tokens_index++;
			break;

		default:
			DEBUG(("get_if_value: invalid token for value:%d\n",
				if_tokens[if_tokens_index]));
			fprintf(stderr,
				"%s: \"%s\", line %d: Invalid #if expression:<%s>\n",
				exe, if_file, if_line, if_string);
			Exit(1);
	}

	DEBUG(("get_if_value:returning:%d\n", value));
	return value;
}

/******************************************************************************/

static int evaluate_if_tokens()
{
	int val1 = 0;
	int	op = 0;
	int val2 = 0;

	/*
	**	Get val1 and increment if_tokens_index
	*/
	val1 = get_if_value();
	DEBUG(("evaluate_if_tokens: val1:%d\n", val1));

	/*
	**	Get op and increment if_tokens_index
	*/
	switch(if_tokens[if_tokens_index])
	{
		case TOK_AND:
		case TOK_OR:
			op = if_tokens[if_tokens_index];
			if_tokens_index++;
			break;

		case TOK_RPAREN:
		case TOK_END:
			DEBUG(("evaluate_if_tokens: returning:%d\n", val1));
			return val1;

		default:
			DEBUG(("evaluate_if_tokens: invalid token for op:%d\n",
				if_tokens[if_tokens_index]));
			fprintf(stderr,
				"%s: \"%s\", line %d: Invalid #if expression:<%s>\n",
				exe, if_file, if_line, if_string);
			Exit(1);
	}
	DEBUG(("evaluate_if_tokens: op:%d\n", op));

	while(op == TOK_AND)
	{
		val2 = get_if_value();
		DEBUG(("evaluate_if_tokens: val2:%d\n", val2));
		val1 = val1 && val2;

		switch(if_tokens[if_tokens_index])
		{
			case TOK_AND:
			case TOK_OR:
				op = if_tokens[if_tokens_index];
				if_tokens_index++;
				break;
	
			case TOK_RPAREN:
			case TOK_END:
				DEBUG(("evaluate_if_tokens: returning:%d\n", val1));
				return val1;
	
			default:
				DEBUG(("evaluate_if_tokens: invalid token for op:%d\n",
					if_tokens[if_tokens_index]));
				fprintf(stderr,
					"%s: \"%s\", line %d: Invalid #if expression:<%s>\n",
					exe, if_file, if_line, if_string);
				Exit(1);
		}
		DEBUG(("evaluate_if_tokens: op:%d\n", op));
	}

	if (op == TOK_OR)
	{
		/*
		**	Get val2
		*/
		val2 = evaluate_if_tokens();
		DEBUG(("evaluate_if_tokens: val2:%d\n", val2));

		val1 = val1 || val2;
	}
	return val1;
}

/******************************************************************************/

static int evaluate_if(
	char	*file,
	int		line,
	char	*string)
{
	int		i;
	int		sts = 0;

	DEBUG(("evaluate_if(file:<%s> line:%d string:<%s>)\n", file, line, string));

	if_file = file;
	if_line = line;
	if_string = string;

	for (i = 0; i < MAX_TOKENS; i++)
	{
		if ((if_tokens[i] = (char)get_next_if_token(&string)) == TOK_END)
			break;
	}

	if (i == MAX_TOKENS)
	{
		fprintf(stderr, "%s: increase MAX_TOKENS(currently set to %d)\n",
			exe, MAX_TOKENS);
		Exit(1);
	}

	if_tokens_index = 0;
	switch(evaluate_if_tokens())
	{
		case TOK_TRUE:
			sts = IF_TRUE;
			break;

		case TOK_FALSE:
			sts = IF_FALSE;
			break;

		default:
			fprintf(stderr,
				"%s: internal error: evaluate_if_tokens returned an invalid"
				"value\n", exe);
			Exit(1);
	}
	
	DEBUG(("evaluate_if:returning sts:%d\n", sts));
	return sts;
}

/******************************************************************************/

static int evaluate_elif(
	char	*file,
	int		line,
	char	*string)
{
	int		sts = 0;

	DEBUG(("evaluate_elif()\n"));

	switch(evaluate_if(file, line, string))
	{
		case IF_TRUE: sts = ELIF_TRUE; break;
		case IF_FALSE: sts = ELIF_FALSE; break;
		default:
			fprintf(stderr,
				"%s: internal error: evaluate_elif returned an invalid"
				"value\n", exe);
			Exit(1);
	}

	DEBUG(("evaluate_elif:returning sts:%d\n", sts));
	return sts;
}

/******************************************************************************/

static int evaluate_ifdef(
	char *s)
{
	char	*tok;
	int		return_sts;

	SKIP_WHITE_SPACE(s);

	tok = s;
	SKIP_TO_WHITE_SPACE(s);
	if (token_defined(tok, (int)(s - tok)))
		return_sts = IF_TRUE;
	else
		return_sts = IF_FALSE;

	return return_sts;
}

/******************************************************************************/

static int preprocessor_directive(
	char	*file,
	int		line,
	char	*s,
	char	**argp)
{
	int return_sts;

	*argp = NULL;
	return_sts = OTHER;

	s++; /* skip the '#' */

	SKIP_WHITE_SPACE(s);
	if (!strncmp(s, "ifdef", 5))
	{
		s += 5;
		SKIP_WHITE_SPACE(s);
		return_sts = evaluate_ifdef(s);

	}
	else if (!strncmp(s, "ifndef", 6))
	{
		s += 6;
		SKIP_WHITE_SPACE(s);
		return_sts = !evaluate_ifdef(s);
	}
	else if (!strncmp(s, "if", 2))
	{
		s += 2;
		SKIP_WHITE_SPACE(s)
		return_sts = evaluate_if(file, line, s);
	}
	else if (!strncmp(s, "elif", 4))
	{
		s += 4;
		SKIP_WHITE_SPACE(s)
		return_sts = evaluate_elif(file, line, s);
	}
	else if (!strncmp(s, "else", 4))
	{
		return_sts = ELSE;
	}
	else if (!strncmp(s, "endif", 5))
	{
		return_sts = ENDIF;
	}
	else if (!strncmp(s, "include", 7))
	{
		s += 7;
		SKIP_WHITE_SPACE(s)
		*argp = s;
		return_sts = INCLUDE;
	}
	else if (!strncmp(s, "define", 6))
	{
		s += 6;
		SKIP_WHITE_SPACE(s)
		*argp = s;
		return_sts = DEFINE;
	}

	return return_sts;
}

/******************************************************************************/

static void read_prototype_file(
	FILE	*fp,
	char	*filename,
	int		*line,
	int		mode,
	int		level)
{
	int		sts;
	int		len;
	char	*pp_arg;
	char	s[BUFSIZ];
	char	*ptr;
	data_s	*temp = NULL;
	data_s	**protp;

	DEBUG(("read_prototype_file(fp:0x%x filename:<%s> *line:%d mode:%d"
		" level:%d)\n", fp, filename, *line, mode, level));

	while(fgets(s, BUFSIZ, fp))
	{
		(*line)++;
		if (s[0] == '#')
		{
			switch(preprocessor_directive(filename, *line, s, &pp_arg))
			{
				case IF_TRUE:
					read_prototype_file(fp, filename, line, READ, level + 1);
					break;

				case IF_FALSE:
					read_prototype_file(fp, filename, line, SKIP, level + 1);
					break;

				case ELIF_TRUE:
					if (level == 0)
					{
						fprintf(stderr,
							"%s: \"%s\", line %d: Unmatched \"#elif\".\n",
							exe, filename, *line, temp->data);
						Exit(1);
					}
					switch(mode)
					{
						case READ:		mode = SKIP_REST;	break;
						case SKIP:		mode = READ;		break;
						case SKIP_REST:						break;
					}
					break;

				case ELIF_FALSE:
					if (level == 0)
					{
						fprintf(stderr,
							"%s: \"%s\", line %d: Unmatched \"#elif\".\n",
							exe, filename, *line, temp->data);
						Exit(1);
					}
					switch(mode)
					{
						case READ:		mode = SKIP_REST;	break;
						case SKIP:							break;
						case SKIP_REST:						break;
					}
					break;

				case ELSE:
					if (level == 0)
					{
						fprintf(stderr,
							"%s: \"%s\", line %d: Unmatched \"#else\".\n",
							exe, filename, *line, temp->data);
						Exit(1);
					}
					switch(mode)
					{
						case READ:		mode = SKIP;	break;
						case SKIP:		mode = READ;	break;
						case SKIP_REST:					break;
					}
					break;

				case ENDIF:
					if (level == 0)
					{
						fprintf(stderr,
							"%s: \"%s\", line %d: Unmatched \"#endif\".\n",
							exe, filename, *line, temp->data);
						Exit(1);
					}
					DEBUG(("read_prototype_file:complete\n"));
					return;
			}
		}

		if (mode == SKIP || mode == SKIP_REST) continue;

		/*
		**	remove trailing white space
		*/
		len = strlen(s) - 1;
		while(len > 0 && isspace(s[len-1]))
			len--;
		s[len] = '\0';

		if ((!strncmp(s, "static", 6) || !strncmp(s, "extern", 6)) &&
			(s[len - 1] == '(' || s[len - 1] == ')'))
		{
			/* search backwards for '(' */
			while(len > 0 && s[len-1] != '(')
				len--;

			/* skip the '(' */
			len--;

			/* skip white space */
			while(len > 0 && isspace(s[len-1]))
				len--;

			/* check if function returns a pointer to a function */
			if (len > 0 && s[len-1] == ')')
			{
				/* skip the ')' */
				len--;

				/* skip white space */
				while(len > 0 && isspace(s[len-1]))
				len--;
			}

			/* add a null terminator to the end of the function name */
			s[len] = '\0';

			while(len > 0 && !isspace(s[len-1]) && s[len-1] != '*')
				len--;

			ptr = s + len;

			DEBUG(("read_prototype_file: function prototype:<%s>\n", ptr));

			for (protp = &prot_list; (*protp); protp = &((*protp)->next))
			{
				sts = strcmp(ptr, (*protp)->data);
				if (sts < 0)
				{
					temp = MALLOC(data_s);
					strcpy(temp->data, ptr);
					strcpy(temp->file, filename);
					temp->next = (*protp);
					(*protp) = temp;
					break;
				}
#ifdef OLD
				if (sts == 0)
				{
					fprintf(stderr,
						"%s: \"%s\", line %d: %s has been prototyped twice.\n",
						exe, filename, *line, ptr);
					Exit(1);
				}
#else
				if (sts == 0)
					break;
#endif
			}
			if ((*protp) == NULL)
			{
				(*protp) = MALLOC(data_s);
				(*protp)->next = NULL;
				strcpy((*protp)->data, ptr);
				strcpy((*protp)->file, filename);
			}
		}
	}
	if (level)
	{
		fprintf(stderr,
			"%s: \"%s\", line %d: Missing \"#endif\".\n",
			exe, filename, *line, temp->data);
		Exit(1);
	}
	DEBUG(("read_prototype_file:complete\n"));
}

/******************************************************************************/

/*
**	Given a prototype filename, read that file and get all the prototypes.
*/
static void get_prototypes()
{
	int		line;
	data_s	*prot;
	data_s	*protfile;
	FILE	*fp;

	DEBUG(("get_prototypes()\n"));

	for(protfile = protfile_list; protfile; protfile = protfile->next)
	{
		line = 0;
		if ((fp = open_prototype_file(protfile->file, "r")) == NULL)
		{
			fprintf(stderr, "%s: \"%s\", line %d: Unable to open <%s>: %s\n",
				exe, protfile->file, line, protfile->file, sys_errlist[errno]);
			Exit(1);
		}
		read_prototype_file(fp, protfile->file, &line, READ, 0);
		fclose(fp);
	}

	if (verbose)
	{
		printf("\n%s: Prototypes:\n", exe);
		for (prot = prot_list; prot; prot = prot->next)
		{
			printf("%s:    %s\n", exe, prot->data);
		}
	}

	DEBUG(("get_prototypes:complete\n"));
}

/******************************************************************************/

/*
**	Given a filename, read that file and get all the prototype files included.
**	Checks for duplicate files.
*/

static void read_source_file(
	FILE	*fp,
	char	*filename,
	int		*line,
	int		mode,
	int		level)
{
	int		sts;
	int		len;
	char	s[BUFSIZ];
	char	path[256];
	char	*ptr;
	data_s	*temp = NULL;
	data_s	**protfilep;

	DEBUG(("read_source_file()\n"));

	while(fgets(s, BUFSIZ, fp))
	{
		(*line)++;
		if (s[0] != '#') continue;

		switch(preprocessor_directive(filename, *line, s, &ptr))
		{
			case IF_TRUE:
				read_source_file(fp, filename, line, READ, level + 1);
				break;

			case IF_FALSE:
				read_source_file(fp, filename, line, SKIP, level + 1);
				break;

			case ELIF_TRUE:
				if (level == 0)
				{
					fprintf(stderr,
						"%s: \"%s\", line %d: Unmatched \"#elif\".\n",
						exe, filename, *line, temp->data);
					Exit(1);
				}
				switch(mode)
				{
					case READ:		mode = SKIP_REST;	break;
					case SKIP:		mode = READ;		break;
					case SKIP_REST:						break;
				}
				break;

			case ELIF_FALSE:
				if (level == 0)
				{
					fprintf(stderr,
						"%s: \"%s\", line %d: Unmatched \"#elif\".\n",
						exe, filename, *line, temp->data);
					Exit(1);
				}
				switch(mode)
				{
					case READ:		mode = SKIP_REST;	break;
					case SKIP:							break;
					case SKIP_REST:						break;
				}
				break;

			case ELSE:
				if (level == 0)
				{
					fprintf(stderr,
						"%s: \"%s\", line %d: Unmatched \"#else\".\n",
						exe, filename, *line, temp->data);
					Exit(1);
				}
				mode = !mode;
				break;

			case ENDIF:
				if (level == 0)
				{
					fprintf(stderr,
						"%s: \"%s\", line %d: Unmatched \"#endif\".\n",
						exe, filename, *line, temp->data);
					Exit(1);
				}
				DEBUG(("read_prototype_file:complete\n"));
				return;

			case INCLUDE:
				if (mode == SKIP || mode == SKIP_REST) break;
				if (*ptr != '\"') break;

				ptr++;

				len = 0;
				while (*ptr != '\"')
					path[len++] = *ptr++;
				path[len] = '\0';

				if (strcmp(&path[len - 4], ".prt")) continue;

				DEBUG(("prototype path:<%s>\n", path));

				for (protfilep = &protfile_list;
					 (*protfilep);
					 protfilep = &((*protfilep)->next))
				{
					sts = strcmp(path, (*protfilep)->file);
					if (sts < 0)
					{
						temp = MALLOC(data_s);
						strcpy(temp->file, path);
						temp->used = 0;
						temp->next = (*protfilep);
						(*protfilep) = temp;
						break;
					}
					if (sts == 0)
					{
						fprintf(stderr,
							"%s: \"%s\", line %d: prototype file \"%s\" is"
							" included twice.\n", exe, src_path, *line, path);
						Exit(1);
					}
				}
				if ((*protfilep) == NULL)
				{
					(*protfilep) = MALLOC(data_s);
					(*protfilep)->next = NULL;
					(*protfilep)->used = 0;
					strcpy((*protfilep)->file, path);
				}
				break;

			default:
				break;
		}
	}
	DEBUG(("read_source_file: complete\n"));
}

/******************************************************************************/

static void get_prototype_files()
{
	int		line;
	FILE	*fp;
	data_s	*protfile;

	DEBUG(("get_prototype_files()\n"));

	line = 0;
	if ((fp = fopen(src_path, "r")) == NULL)
	{
		fprintf(stderr, "%s: \"%s\", line %d: Unable to open <%s>: %s\n",
			exe, src_path, line, src_path, sys_errlist[errno]);
		Exit(1);
	}
	read_source_file(fp, src_path, &line, READ, 0);
	fclose(fp);

	if (verbose)
	{
		printf("\n%s: Prototype_files:\n", exe);
		for (protfile = protfile_list; protfile; protfile = protfile->next)
		{
			printf("%s:    %s\n", exe, protfile->file);
		}
	}

	DEBUG(("get_prototype_files: complete\n"));
}

/******************************************************************************/

static int check_for_nonfunc(
	char *func)
{
	int		sts;
	data_s	*nonfunc;

	DEBUG(("check_for_nonfunc(func:<%s>)\n", func));

	for(nonfunc = nonfunc_list; nonfunc; nonfunc = nonfunc->next)
	{
		sts = strcmp(func, nonfunc->data);
		if (sts < 0)
		{
			break;
		}

		if (sts == 0)
		{
			DEBUG(("check_for_nonfunc: returning 1\n"));
			return 1;
		}
	}

	DEBUG(("check_for_nonfunc: returning 0\n"));
	return 0;
}

/******************************************************************************/

extern void get_functions()
{
	int		sts;
	char	s[256];
	char	*ptr;
	data_s	*temp = NULL;
	data_s	*func;
	data_s	**funcp;
	FILE	*pp;

	DEBUG(("get_functions()\n"));

#if defined(__Sol2__) || defined(Soli) ||  defined(__hpux__)
	/* 
	 *  If we do not use the -h option, nm generates a header.
	 *  This caused parsing below to become confused and result
	 *  in a core dump.
	 */
	sprintf(s, "nm -hup %s", obj_path);
	if ((pp = (FILE *)popen(s, "r")) == NULL)
#else 
	sprintf(s, "nm -up %s", obj_path);
	if ((pp = popen(s, "r")) == NULL)
#endif
	{
		fprintf(stderr, "%s: Unable to execute \"%s\"\n", exe, s);
		perror(exe);
		Exit(1);
	}

	while (fgets(s, 256, pp))
	{
		DEBUG(("get_functions: fgets gives :<%s>\n", s));

		/*
		** On CLIX and SunOS systems, the compilers generate function
		** names that begin with "_" so running "nm" on an object file
		** that calls strlen() will show the symbol "_strlen".  This
		** is the reason that the following code sets ptr to strtok+1;
		** it advances the pointer by 1 to ignore the initial underline
		** that has been added.
		**
		** On sco systems (SCO Unix,Intel,SMP) and also on the WYSE
		** system, there is no preceding underline, so "nm" gives
		** "strlen" as the symbol and advancing by 1 gives "trlen"
		** which does not work too well.
		**
		** It seems very odd to me that SCO UNIX and the WYSE system
		** both are different from CLIX/SUN, and if
		** I were not brain dead I might remember something useful about
		** symbols and underlines.
		*/

		ptr = strtok(s, " \t\n");
#if defined(__clipper__) || defined(sun) 
		ptr++;	/* skip the leading '_' */
#endif
		DEBUG(("get_functions: ptr gives :<%s>\n", ptr));

		if (check_for_nonfunc(ptr)) continue;

		DEBUG(("get_functions: function:<%s>\n", ptr));

		for (funcp = &func_list; (*funcp); funcp = &((*funcp)->next))
		{
			sts = strcmp(ptr, (*funcp)->data);
			if (sts < 0)
			{
				temp = MALLOC(data_s);
				strcpy(temp->data, ptr);
				temp->next = (*funcp);
				(*funcp) = temp;
				break;
			}
			if (sts == 0)
			{
				break;
			}
		}
		if ((*funcp) == NULL)
		{
			(*funcp) = MALLOC(data_s);
			(*funcp)->next = NULL;
			strcpy((*funcp)->data, ptr);
		}
	}
	pclose(pp);

	if (verbose)
	{
		printf("\n%s: Functions called:\n", exe);
		for (func = func_list; func; func = func->next)
		{
			printf("%s:    %s\n", exe, func->data);
		}
	}

	DEBUG(("get_functions: complete\n"));
}

/******************************************************************************/

static void set_file_used(
	char *filename)
{
	data_s *protfile;

	DEBUG(("set_file_used(filename:<%s>)\n", filename));

	for (protfile = protfile_list; protfile; protfile = protfile->next)
	{
		if (!strcmp(filename, protfile->file))
		{
			protfile->used = 1;
			break;
		}
	}

	DEBUG(("set_file_used:complete\n"));
}

/******************************************************************************/

static void get_non_functions()
{
	int		sts;
	int		line;
	char	s[256];
	char	*tok;
	char	*arg1;
	data_s	*temp;
	data_s	*nonfunc;
	data_s	**nonfuncp;
	FILE	*fp;

	DEBUG(("get_non_functions()\n"));

	line = 0;
	if ((fp = fopen(nonfunc_path, "r")) == NULL)
	{
		fprintf(stderr, "%s: \"%s\", line %d: Unable to open \"%s\": %s\n",
			exe, nonfunc_path, line, nonfunc_path, sys_errlist[errno]);
		Exit(1);
	}

	while(fgets(s, 256, fp))
	{
		line++;
		if (s[0] == '#') continue;

		arg1 = s;
		while((tok = strtok(arg1, " \t\n")))
		{
			DEBUG(("get_non_functions: tok:<%s>\n", tok));
			temp = MALLOC(data_s);
			temp->next = NULL;
			strcpy(temp->data, tok);

			for (nonfuncp = &nonfunc_list;
				 (*nonfuncp);
				 nonfuncp = &((*nonfuncp)->next))
			{
				sts = strcmp(tok, (*nonfuncp)->data);
				if (sts < 0)
				{
					temp->next = (*nonfuncp);
					(*nonfuncp) = temp;
					break;
				}
				if (sts == 0)
				{
					fprintf(stderr,
						"%s: \"%s\", line %d: %s is in the non-function list"
						"twice.\n", exe, nonfunc_path, line, tok);
					Exit(1);
				}
			}
			if ((*nonfuncp) == NULL)
			{
				(*nonfuncp) = temp;
			}
			arg1 = NULL;
		}
	}

	fclose(fp);

	if (verbose)
	{
		printf("\n%s: Non-functions:\n", exe);
		for (nonfunc = nonfunc_list; nonfunc; nonfunc = nonfunc->next)
		{
			printf("%s:    %s\n", exe, nonfunc->data);
		}
	}

	DEBUG(("get_non_functions:complete\n"));
}

/******************************************************************************/

static void check_prototypes()
{
	int		sts;
	int		return_sts = 0;
	data_s	*protfile;
	data_s	*prot = NULL;
	data_s	*func = NULL;

	DEBUG(("check_prototypes()\n"));

	if (nonfunc_path)
		get_non_functions();

	get_functions();

	get_prototype_files();

	get_prototypes();

	func = func_list;
	prot = prot_list;
	while(func && prot)
	{
		sts = strcmp(func->data, prot->data);
		
		if (sts < 0)
		{
			return_sts = 1;
			fprintf(stderr, "%s: function \"%s\" is not prototyped.\n",
				exe, func->data);

			func = func->next;
		}
		else if (sts == 0)
		{
			VERBOSE(("%s: \"%s\" is prototyped.\n", exe, func->data));
			set_file_used(prot->file);
			func = func->next;
			prot = prot->next;
		}
		else
		{
			prot = prot->next;
		}
	}

	if (func)
	{
		return_sts = 1;
		for (; func; func = func->next)
			fprintf(stderr, "%s: function \"%s\" is not prototyped.\n",
				exe, func->data);
	}

	for (protfile = protfile_list; protfile; protfile = protfile->next)
	{
		if (strcmp(protfile->file, prot_filename) && !protfile->used &&
			warnings)
		{
			fprintf(stderr,
				"%s: \"%s\": Prototype file \"%s\" is included unnecessarily.\n",
				exe, src_path, protfile->file);
		}
	}

	if (return_sts)
	{
		Exit(return_sts);
	}

	DEBUG(("check_prototypes:complete\n"));
}

/******************************************************************************/

static void setup_paths(
	char *path)
{
	char	*ptr;
	char	*objdir;
	char	*dbdir;
	char	filename[15];

	DEBUG(("setup_paths(path:<%s>)\n", path));
	
	if ((objdir = getenv("OBJDIR")) == NULL)
		objdir = "objdir";

	if (((dbdir = getenv("DB_DIR")) != NULL) && (!*dbdir))
		dbdir = NULL;

	strcpy(src_path, path);
	if ((ptr = strrchr(path, '/')))
	{
		*ptr++ = 0;
		strcpy(filename, ptr);
		sprintf(obj_path, "%s/%s%s/", path, dbdir ? dbdir : "", objdir);
	}
	else
	{
		strcpy(filename, path);
		sprintf(obj_path, "%s%s/", dbdir ? dbdir : "", objdir);
	}

	if ((ptr = strrchr(filename, '.')))
	{
		*ptr = 0;
	}
	strcat(obj_path, filename);
	strcat(obj_path, ".o");

	strcpy(prot_filename, filename);
	strcat(prot_filename, ".prt");

	DEBUG(("src_path:<%s> obj_path:<%s> prot_filename:<%s>\n",
		src_path, obj_path, prot_filename));

	DEBUG(("setup_paths:complete\n"));
}

/******************************************************************************/

extern void Usage()
{
	fprintf(stderr,
		"Usage: %s [-db] [-v] [-r] [-nfile] [-Ddefine]... [-Idir]... file\n",
		exe);
	fprintf(stderr, "           -db : debug on\n");
	fprintf(stderr, "           -v  : verbose\n");
	fprintf(stderr, "           -r  : rm object file on error\n");
	fprintf(stderr, "           -n  : file containing list of non-functions\n");
	fprintf(stderr,
		"           -D  : defines used while reading prototype files\n");
	fprintf(stderr,
		"           -I  : search dir for included prototype files\n");
	exit(1);
}

/******************************************************************************/

extern void main(
	int		argc,
	char	*argv[])
{
	int		i;
	char	*ptr;
	char	*srcpath = NULL;
	data_s	**incpathp = NULL;
	data_s	**defp = NULL;

	if (argc < 2)
	{
		Usage();
	}

	defp = &def_list;

#if defined(unix)
	(*defp) = MALLOC(data_s);
	(*defp)->next = NULL;
	strcpy((*defp)->data, "unix");
	defp = &((*defp)->next);
#endif
#if defined(__clipper__)
	(*defp) = MALLOC(data_s);
	(*defp)->next = NULL;
	strcpy((*defp)->data, "clipper");
	defp = &((*defp)->next);

	(*defp) = MALLOC(data_s);
	(*defp)->next = NULL;
	strcpy((*defp)->data, "__clipper__");
	defp = &((*defp)->next);
#endif
#if defined(sco)
	(*defp) = MALLOC(data_s);
	(*defp)->next = NULL;
	strcpy((*defp)->data, "sco");
	defp = &((*defp)->next);
#endif
#if defined(__hpux__)
	(*defp) = MALLOC(data_s);
	(*defp)->next = NULL;
	strcpy((*defp)->data, "hpux");
	defp = &((*defp)->next);
	(*defp) = MALLOC(data_s);
	(*defp)->next = NULL;
	strcpy((*defp)->data, "__hpux__");
	defp = &((*defp)->next);
#endif
#if defined(sun) 
	(*defp) = MALLOC(data_s);
	(*defp)->next = NULL;
	strcpy((*defp)->data, "sun");
	defp = &((*defp)->next);
#endif
#if defined(__Sol2__)
	(*defp) = MALLOC(data_s);
	(*defp)->next = NULL;
	strcpy((*defp)->data, "Sol2");
	defp = &((*defp)->next);

	(*defp) = MALLOC(data_s);
	(*defp)->next = NULL;
	strcpy((*defp)->data, "__Sol2__");
	defp = &((*defp)->next);
#endif
#if defined(Soli)
	(*defp) = MALLOC(data_s);
	(*defp)->next = NULL;
	strcpy((*defp)->data, "Soli");
	defp = &((*defp)->next);
#endif

	incpathp = &incpath_list;
	(*incpathp) = MALLOC(data_s);
	(*incpathp)->next = NULL;
	strcpy((*incpathp)->data, ".");
	incpathp = &((*incpathp)->next);

	for (i = 1; i < argc; i++)
	{
		if (argv[i][0] == '-' && argv[i][1] == 'd' && argv[i][2] == 'b')
		{
			debug = 1;
			continue;
		}

		if (argv[i][0] == '-' && argv[i][1] == 'v')
		{
			verbose = 1;
			continue;
		}

		if (argv[i][0] == '-' && argv[i][1] == 'w')
		{
			warnings = 1;
			continue;
		}

		if (argv[i][0] == '-' && argv[i][1] == 'r')
		{
			rm_object = 1;
			continue;
		}

		if (argv[i][0] == '-' && argv[i][1] == 'n')
		{
			if (argv[i][2])
			{
				nonfunc_path = &argv[i][2];
			}
			else
			{
				i++;
				nonfunc_path = argv[i];
			}
			continue;
		}

		if (argv[i][0] == '-' && argv[i][1] == 'I')
		{
			if (argv[i][2])
			{
				ptr = &argv[i][2];
			}
			else
			{
				i++;
				ptr = argv[i];
			}
			(*incpathp) = MALLOC(data_s);
			(*incpathp)->next = NULL;
			strcpy((*incpathp)->data, ptr);
			incpathp = &((*incpathp)->next);

			continue;
		}

		if (argv[i][0] == '-' && argv[i][1] == 'D')
		{
			if (argv[i][2])
			{
				ptr = &argv[i][2];
			}
			else
			{
				i++;
				ptr = argv[i];
			}
			(*defp) = MALLOC(data_s);
			(*defp)->next = NULL;
			strcpy((*defp)->data, ptr);
			defp = &((*defp)->next);

			continue;
		}

		if (srcpath)
		{
			Usage();		
		}

		srcpath = argv[i];
	}

	setup_paths(srcpath);

	check_prototypes();

	Exit(0);
}

/******************************************************************************/
