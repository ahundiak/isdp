/* Do not alter this SPC information: $Revision: 1.4.29.1 $ */
/*
**	NAME:							generate.c
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

#define LINE1	"/* PRODUCTION ******************************************************************"
#define LINE2	"*******************************************************************************/"
#define LINE3	"/******************************************************************************/"

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
#define generate_c
#include "generate.prt"
#include "msg.prt"
#include "tests.prt"
#include "write.prt"
#include "ums.prt"
#include "sys.prt"


/*
** VARIABLES
*/

static	int		c_line;
static	char	c_filename[256];
static	name_s	*keyword_list = NULL;
static	FILE	*c_fp;
static	FILE	*dec_fp;
static	FILE	*first_fp;
static	FILE	*kw_fp;

/******************************************************************************/

extern void my_fputs(
	char	*s,
	FILE	*fp)
{
	char *ptr;

	if (fp == c_fp)
	{
		for(ptr = s; *ptr; ptr++)
		{
			if (*ptr == '\n')
				c_line++;
		}
	}
	fputs(s, fp);
}

/******************************************************************************/

extern void my_fprintf(
	FILE *fp, 
	char *fmt,
	...)
{
			va_list args;
	auto	char	s[256];

	va_start(args,fmt);
	vsprintf(s, fmt, args);
	va_end(args);

	my_fputs(s, fp);
}

/******************************************************************************/

static void get_new_filename(
	char *filename,
	char *new_filename)
{	
	char *fname;
	char *ext;

	strcpy(new_filename, filename);
	
	if ((fname = strrchr(new_filename, PATH_CHAR)) == NULL)
	{
		fname = new_filename;
	}
	else
	{
		fname++;
	}
	
	if ((ext = strchr(fname, '.')) == NULL)
	{
		strcat(new_filename, ".N");
	}
	else
	{
		ext++;
		strcpy(ext, "N");
	}
}

/******************************************************************************/

extern int filecmp(
	char *new_filename, 
	char *old_filename)
{
	int return_sts;
	char *sts1, *sts2;
	char s1[1024];
	char s2[1024];
	FILE *fp1, *fp2;

	if ((fp1 = fopen(new_filename, OPEN_TO_READ_MODE)) == NULL)
	{
		fprintf(stderr, "filecmp(): Unable to open \"%s\":", new_filename);
		perror("");
		exit(1);
	}

#if defined(unix)
	if (access(old_filename, 00))
#endif
#if defined(WIN32) || defined(DOS)
	if (_access(old_filename, 00))
#endif
	{
		fclose(fp1);
		return 1;
	}
	if ((fp2 = fopen(old_filename, OPEN_TO_READ_MODE)) == NULL)
	{
		fprintf(stderr, "filecmp(): Unable to open \"%s\": ", old_filename);
		perror("");
		exit(2);
	}

	while(1)
	{
		sts1 = fgets(s1, 1024, fp1);
		sts2 = fgets(s2, 1024, fp2);

		if (!sts1 && !sts2)
		{
			return_sts = 0;
			break;
		}

		if ((sts1 && !sts2) || (!sts1 && sts2))
		{
			return_sts = 1;
			break;
		}

		if (!strncmp(s1, "#line", 5) && !strncmp(s2, "#line", 5))
		{
			continue;
		}

		if (strcmp(s1, s2))
		{
			return_sts = 1;
			break;
		}
	}
	fclose(fp1);
	fclose(fp2);

	return return_sts;
}

/******************************************************************************/

extern FILE *open_file(
	char	*filename)
{
	char	new_filename[256];
	FILE	*fp;

	get_new_filename(filename, new_filename);

	if ((fp = fopen(new_filename,OPEN_TO_WRITE_MODE)) == NULL)
	{
		fprintf(stderr, "open_file(): Unable to open \"%s\":", new_filename);
		perror("");
		exit(3);
	}

	return fp;
}

/******************************************************************************/

extern FILE *open_h_file(
	char	*filename)
{
	char	*ptr;
	char	*name;
	char	definename[16];
	FILE	*fp;

	fp = open_file(filename);

	write_header(fp, filename);

	if ((name = strrchr(filename, PATH_CHAR)) == NULL)
	{
		name = filename;
	}
	else
	{
		name++;
	}

	for (ptr = definename; *name; name++, ptr++)
	{
		if (*name == '.')
		{
			*ptr = '_';
		}
		else
		{
			if (islower(*name))
			{
				*ptr = _toupper(*name);
			}
			else
			{
				*ptr = *name;
			}
		}
	}
	*ptr = '\0';

	my_fprintf(fp, "#ifndef %s\n", definename);
	my_fprintf(fp, "#define %s\n", definename);

	return fp;
}

/******************************************************************************/

extern void open_c_file(
	char	*filename)
{
	name_s	*ptr;

	c_fp = open_file(filename);

	c_line = 1;
	strcpy(c_filename, filename);

	write_header(c_fp, c_filename);

	for (ptr = include_file_list; ptr; ptr = ptr->next)
	{
		my_fprintf(c_fp, "#include \"%s\"\n", ptr->name);
	}
	my_fprintf(c_fp, "#include \"%s\"\n", first_file);
	my_fprintf(c_fp, "#include \"%s\"\n", declare_file);
	my_fputs("\n", c_fp);
}

/******************************************************************************/

extern void open_first_file()
{
	first_fp = open_h_file(first_file);
}

/******************************************************************************/

extern void open_dec_file()
{
	dec_fp = open_h_file(declare_file);
}

/******************************************************************************/

extern void open_kw_file()
{
	kw_fp = open_file(keywords_file);
}

/******************************************************************************/

extern void close_file(
	FILE *fp,
	char *filename)
{
	char new_filename[256];


	fclose(fp);

	get_new_filename(filename, new_filename);

	if (filecmp(new_filename, filename))
	{
        remove(filename);
        rename(new_filename,filename);
	}
	else
	{
        remove(new_filename);
	}
}

/******************************************************************************/

extern void close_h_file(
	FILE	*fp,
	char	*filename)
{
	my_fputs("#endif\n", fp);
	close_file(fp, filename);
}

/******************************************************************************/

extern void close_c_file()
{
	close_file(c_fp, c_filename);
}

/******************************************************************************/

extern void close_first_file()
{
	close_h_file(first_fp, first_file);
}

/******************************************************************************/

extern void close_dec_file()
{
	close_h_file(dec_fp, declare_file);
}

/******************************************************************************/

extern void close_kw_file()
{
	close_file(kw_fp, keywords_file);
}

/******************************************************************************/

extern void add_keyword(
	char *name)
{
	int		sts;
	name_s	*ptr;
	name_s	*temp;
	name_s	**listp;

	for (ptr = non_keyword_list; ptr; ptr = ptr->next)
	{
		if (!strcmp(name, ptr->name))
		{
			return;
		}
	}

	for (listp = &keyword_list; (*listp); listp = &((*listp)->next))
	{
		if ((sts = strcmp(name, (*listp)->name)) < 0)
		{
			MALLOC(temp, name_s);
			strcpy(temp->name, name);
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
		MALLOC((*listp), name_s);
		strcpy((*listp)->name, name);
	}
}

/******************************************************************************/

extern void generate_keyword_file()
{
	name_s	*ptr;

	VERBOSE(("generate_keyword_files()\n"));

	open_kw_file();

	for (ptr = keyword_list; ptr; ptr = ptr->next)
	{
		if (!strncmp(ptr->name, "RIS_TOK_", 8))
		{
			my_fprintf(kw_fp, "%s\n", ptr->name + 8);
		}
		else
		{
			fprintf(stderr,
				"generate_keyword_file(): \"%s\" is not a valid keyword\n",
				ptr->name);
		}
	}

	close_kw_file();
}

/******************************************************************************/

extern void generate_declaration(
	char *name)
{
	my_fprintf(dec_fp, "extern\tlex_s\tRISpar_%s(\n\tvoid)\n;\n\n", name);
}

/******************************************************************************/

extern void generate_first(
	char *name)
{
	int		len;
	int		line_len;
	int		first_pass;
	char	s[40];
	prod_s	*prod;
	rule_s	*rule;
	data_s	*first;

	for (prod = prod_list; prod; prod = prod->next)
		if (!strcmp(prod->name, name))
			break;
	if (!prod)
	{
		fprintf(stderr,
			"generate_first(): Unable to find production <%s> in prod_list\n",
			name);
		exit(4);
	}
	if (prod->first_generated)
		return;

	my_fprintf(first_fp, "\n#define FIRST_%s \\\n", prod->name);
	line_len = 0;
	first_pass = 1;
	for (rule = prod->rule; rule; rule = rule->next)
	{
		get_first_for_rule(rule);

		for (first = rule->first; first; first = first->next)
		{
			if (first->name[0] == '\0') continue;

			if (!first_pass)
			{
				my_fputs(":", first_fp);
				line_len++;
			}

			if (first_pass)
			{
				len = sprintf(s, "      %s", first->name);
				first_pass = 0;
			}
			else
			{
				len = sprintf(s, " case %s", first->name);
			}

			if (line_len + len > 77)
			{
				my_fputs("\\\n", first_fp);
				line_len = 0;
			}

			my_fputs(s, first_fp);
			line_len += len;
		}
	}
	my_fputs("\n", first_fp);
	prod->first_generated = 1;
}

/******************************************************************************/

extern void generate_dbg(
	char *prod_name,
	rule_s *rule)
{
	data_s *data;

	my_fprintf(c_fp, "\t\t\tPAR_DBG((\"%s ->", prod_name);

	for (data = rule->data; data; data = data->next)
		my_fprintf(c_fp, " %s", data->name);

	my_fputs("\\n\"));\n", c_fp);
}

/******************************************************************************/

extern void generate_error(
	prod_s *prod)
{
	char *msg, *ptr;
	char ums_key[256], ums_msg[256];
	rule_s *rule;
	int		i;

	/*
	**	Generate debug
	*/
	my_fprintf(c_fp, "\t\t\tPAR_DBG((\"%s(): expected ", prod->name);
	for (rule = prod->rule; rule; rule = rule->next)
	{
		my_fputs(rule->data->name, c_fp);
		if (rule->next)
			my_fputs("|", c_fp);
	}
	my_fputs("; got <%s>\\n\", RIScom_get_token_name(RISpar_token)));\n", c_fp);

	if (prod->secondary_call)
	{
		/*
		**	Generate error message
		*/
		ums_key[0] = '\0';
		ums_msg[0] = '\0';
		my_fputs("\t\t\tsprintf(RIS_ERRMSGC, ", c_fp);
		strcat(ums_key, "RIS_E");
		strcat(ums_msg, "Expected ");
		for (rule = prod->rule; rule; rule = rule->next)
		{
			strcat(ums_key, "_");
			strcat(ums_key, rule->data->name);
			if (ISTOKEN(rule->data->name))
				msg = get_tok_msg(rule->data->name);
			else
				msg = get_prod_msg(rule->data->name);
			strcat(ums_msg, msg);
			if (rule->next)
			{
				if (rule->next->next)
					strcat(ums_msg, ", ");
				else
					strcat(ums_msg, " or ");
			}
		}
		for(ptr = ums_key, i = 0; *ptr && i < (UMS_EXT_MAX + 6); ptr++, i++)
		{
			if (islower(*ptr))
			{
				*ptr = _toupper(*ptr);
			}
		}
		*ptr = '\0';
		if (ums_key[UMS_EXT_MAX+5] == '_')
		{
			ums_key[UMS_EXT_MAX+5] = '\0';
		}

		strcat(ums_msg, ", got %s.");
		add_ums(ums_key, ums_msg);

		my_fputs("RIScom_umsg(", c_fp);
		my_fputs(ums_key, c_fp);
		my_fputs("), RISpar_got_string());\n", c_fp);

		add_ums(prod->errorname, get_err_msg(prod->errorname));
		
		if (!strcmp(prod->errorname, "RIS_E_INV_GRANT_STMT")) 
		{
		my_fprintf(c_fp, "\t\tif((!PREPROCESSOR) && (RIS_app_cli_version < 5)){\n");
		my_fprintf(c_fp, "\t\t\tRISpar_ERR_RETURN(RIS_E_INV_GRANT_PRIVILEGES, RISpar_lex.pos);\n");
			
		my_fprintf(c_fp, "\t\t} else {\n");
		my_fprintf(c_fp, "\t\t\tRISpar_ERR_RETURN(RIS_E_INV_GRANT_STMT, RISpar_lex.pos);}\n");
		}
		else
		{
		my_fprintf(c_fp, "\t\t\tRISpar_ERR_RETURN(%s, RISpar_lex.pos);\n",
			prod->errorname);
		}
	}
	else
	{
		my_fprintf(c_fp,
			"\t\t\tRISpar_ERR_RETURN(RIS_E_INTERNAL_ERROR,RISpar_lex.pos);\n");
	}
}

/******************************************************************************/

extern void generate_action(
	rule_s	*rule)
{
	int		count;
	data_s *data;

	count = 1;
	if (rule->code)
		write_code(c_fp, rule->code);
	for (data = rule->data; data; data = data->next)
	{
		my_fprintf(c_fp, "\t\t\t_%d = ", count++);
		if (ISTOKEN(data->name))
		{
			add_keyword(data->name);

			if (data == rule->data)
				my_fprintf(c_fp,
					"RISpar_match(%s, \"%s\", RIS_E_INTERNAL_ERROR);\n",
					data->name, data->name);
			else
				my_fprintf(c_fp,
					"RISpar_match(%s, \"%s\", match_error);\n",
					data->name, get_tok_msg(data->name));
		}
		else
			my_fprintf(c_fp, "RISpar_%s();\n", data->name);

		if (data->code)
			write_code(c_fp, data->code);
	}
}

/******************************************************************************/

extern void generate_variables(
	prod_s *prod)
{
	int count;
	int max_count;
	int match;
	rule_s	*rule;
	data_s	*data;

	match = 0;
	max_count = 0;
	for (rule = prod->rule; rule; rule = rule->next)
	{
		count = 0;
		for (data = rule->data; data; data = data->next)
		{
			/*
			**	If the first data of a rule is a match, then it's
			**	match_error is RIS_E_INTERNAL_ERROR;
			*/
			if (data != rule->data && ISTOKEN(data->name))
				match = 1;
			count++;
		}
		if (count > max_count)
			max_count = count;
	}
	if (match)
	{
		add_ums(prod->errorname, get_err_msg(prod->errorname));
		my_fprintf(c_fp, "\tunsigned int\t\tmatch_error = %s;\n", prod->errorname);
	}
	my_fputs("\tlex_s\t_1 = {0,0};\n", c_fp);
	if (max_count > 1)
	{
		my_fputs("\tlex_s\t_2", c_fp);
		for (count = 3; count <= max_count; count++)
			my_fprintf(c_fp, ", _%d", count);
		my_fputs(";\n", c_fp);
	}
}

/******************************************************************************/

extern void write_code(
	FILE *fp,
	code_s *code)
{
	char *filename;

	if ((filename = strrchr(rules_file, PATH_CHAR)) == NULL)
	{
		filename = rules_file;
	}
	else
	{
		filename++;
	}
#ifdef COMPILER_ERROR
	my_fprintf(fp, "#line %d \"%s\"\n", code->line + 1, filename);
#endif

	my_fputs(code->data, fp);

	if ((filename = strrchr(c_filename, PATH_CHAR)) == NULL)
	{
		filename = c_filename;
	}
	else
	{
		filename++;
	}
#ifdef COMPILER_ERROR
	my_fprintf(fp, "#line %d \"%s\"\n", c_line + 1, filename);
#endif
}

/******************************************************************************/

extern void generate_code()
{
	name_s	*preproc;
	rule_s	*rule;
	rule_s	*null_token_rule;
	prod_s	*prod;

	open_first_file();
	open_dec_file();

	for (;add_keyword_list; add_keyword_list = add_keyword_list->next)
		add_keyword(add_keyword_list->name);

	open_c_file("parse.c");

	VERBOSE(("Generating \"%s\":parse()\n", c_filename));
	my_fprintf(c_fp, "extern lex_s RISpar_parse(\n\tvoid)\n");
	my_fprintf(c_fp, "{\n");
	my_fprintf(c_fp, "\tlex_s\t_1 = {0,0};\n");
	my_fprintf(c_fp, "\tRISpar_token = 0;\n");
	my_fprintf(c_fp, "\tRISpar_%s();\n", prod_list->name);
	my_fprintf(c_fp, "\treturn _1;\n");
	my_fprintf(c_fp, "}\n");

	generate_declaration("parse");

	for (prod = prod_list; prod; prod = prod->next)
	{
		if (!prod->used)
			continue;

		if (prod->filename[0])
		{
			close_c_file();
			open_c_file(prod->filename);
			for (preproc = prod->preprocs; preproc; preproc = preproc->next)
			{
				my_fprintf(c_fp, "#%s\n", preproc->name);
			}
		}

		VERBOSE(("Generating \"%s\":%s()\n", c_filename, prod->name));
		generate_declaration(prod->name);
		my_fprintf(c_fp, "%s\n", LINE1);
		write_prod(c_fp, prod);
		my_fprintf(c_fp, "%s\n", LINE2);
		my_fprintf(c_fp, "extern lex_s RISpar_%s(\n\tvoid)\n", prod->name);
		my_fprintf(c_fp, "{\n");

		generate_variables(prod);

		if (prod->code)
			write_code(c_fp, prod->code);

		my_fprintf(c_fp, "\n\tif (!RISpar_token) RISpar_get_next_token();\n");

		my_fprintf(c_fp, "\n\tswitch(RISpar_token)\n");
		my_fprintf(c_fp, "\t{\n");

		null_token_rule = NULL;
		for (rule = prod->rule; rule; rule = rule->next)
		{
			if (rule->data == NULL)
			{
				null_token_rule = rule;
				continue;
			}

			if (ISTOKEN(rule->data->name))
			{
				my_fprintf(c_fp, "\t\tcase %s:\n", rule->data->name);
			}
			else
			{
				generate_first(rule->data->name);
				my_fprintf(c_fp, "\t\tcase FIRST_%s:\n", rule->data->name);
			}
			generate_dbg(prod->name, rule);
			generate_action(rule);

			my_fputs("\t\t\tbreak;\n", c_fp);
			if (rule->next)
				my_fputs("\n", c_fp);
		}

		if (null_token_rule)
		{
			my_fprintf(c_fp, "\t\tdefault:\n");
			generate_dbg(prod->name, null_token_rule);
			if (null_token_rule->code)
				write_code(c_fp, null_token_rule->code);

			my_fprintf(c_fp, "\t\t\tbreak;\n");
		}
		else
		{
			my_fprintf(c_fp, "\t\tdefault:\n");
			generate_error(prod);
			my_fprintf(c_fp, "\t\t\tbreak;\n");
		}
		my_fprintf(c_fp, "\t}\n");
		my_fprintf(c_fp, "\treturn _1;\n");
		my_fprintf(c_fp, "}\n");
		my_fprintf(c_fp, "%s\n", LINE3);
	}
	close_c_file();
	close_first_file();
	close_dec_file();

	generate_ums_file();
	generate_keyword_file();
}
/**************************************************************************/

