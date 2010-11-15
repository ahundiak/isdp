/* Do not alter this SPC information: $Revision: 1.7.9.1 $ */
/*
**	NAME:							cppproc.c
**	AUTHORS:						Prasad Challa
**	CREATION DATE:					6/14/91
**	ABSTRACT:
**		The functions process .rc files.
**	
**	REVISION HISTORY:
**
**	1/95:	Added Internationalization support.  Paula
*/
 
/*
**	INCLUDES
*/
#include "ris_err.h"
#include "rismem.h"
#include "commacro.h"
#include "cpp.h"

/*
**	DEFINES
*/
#define HASH_TABLE_SIZE 4096

/*
**	VARIABLES
*/
static char line_buf[RIScpp_LINE_BUF_SIZE+2];
static int len;

/*
**	TYPES
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cppproc_c
#include "comdebug.prt"
#include "comalloc.prt"
#include "comuni.prt"
#include "comwrap.prt"
#include "cpperror.prt"
#include "cppfopen.prt"
#include "cppmacro.prt"
#include "cppmisc.prt"
#include "cppproc.prt"
#include "cpptrans.prt"
#include "parlex.prt"
#include "sys.prt"
#if defined(DOS) || defined(WIN32) || defined(vms)
#include "wrap.prt"
#endif
/*
#undef RIScpp_LINE_BUF_SIZE
#define RIScpp_LINE_BUF_SIZE 24
*/
/******************************************************************************/

static int print_line_directive(
	int line,
 	char *filename)
{
	int retn;
#if defined(WIN32)
	char buffer[512];
	char *src, *dst;
	wchar_t *wfilename, wdst[RIS_MAX_PATH_SIZE], *wptr;
	wchar_t *wsrc;
	int i;
#endif

	CPP_DBG(("\nprint_line_directive(line:%d file_name:%s)\n", line,
 		STRING(filename)));

/*
** Following is the text from NT's help for fseek:
** "For streams opened in text mode, fseek has limited use because CR-LF
** translations can cause fseek to produce unexpected results."
**
** For DOS and NT, LF are written as CR-LF but sprintf returns as one byte.
** This will cause problem for fseek as it tries to fseek one but actually 
** there were two bytes. Kludge is to have extra LF before sprintf string.
** (NOTE: we will be fseeking in backward order from current position so 
** kludge is OK.)
**
** Also, NT compiler requires '\' to be escaped to generated correct error 
** message.
*/
#if defined(WIN32)
	dst = buffer;
	dst += sprintf(dst, "\n#line %d \"", line);
	*dst = '\0';

	RIScom_multiwide(&RISwide_ptr,&filename,&RISwide_size,MULTITOWIDE,0);
	wfilename = RISwide_ptr;

	for (i = 0, wsrc = wfilename; *wsrc; src++,wsrc++,dst++, i++)
	{
		if (*wsrc == WIDECHAR('\\') )
		{
			wdst[i++] = WIDECHAR('\\');
		}
		wdst[i] = *wsrc;
	}
	wdst[i++] = WIDECHAR('"');
	wdst[i++] = WIDECHAR('\n');
	wdst[i] = WIDECHAR('\0');

	wptr = wdst;
	RIScom_multiwide(&wptr, &RISmulti_ptr, &RISmulti_size, WIDETOMULTI, 0);
	strcat(buffer, RISmulti_ptr);

	retn = fprintf(RIScpp_temp_file, "%s", buffer);
#endif
/*
** DOS compiler (HIGH C) does not require '\' to be escaped.
** Extra newline char is required for fseek to work as explained before.
** For UNIX platform, it is OK to have extra newline char.
*/
#if defined(unix) || defined(DOS)
	retn = fprintf(RIScpp_temp_file, "\n#line %d \"%s\"\n", line, filename);
#endif
	CPP_DBG(("print_line_directive: returning %d\n", retn));
	return retn;
}

/******************************************************************************/

char GetNextChar(FILE *fp, char *mb)
{
	char c;
	int j;

	c = getc(fp);

#ifdef WIN32
	if ( c != EOF )
	{
		mb[0] = c;
		j = 1;
		if ( RIScom_isleadbyte(c) )
		{
			/* encountered the first byte of a multi-byte char */
			for(j = 1; j < MULTIBYTE_SIZE; j++)
				mb[j] = getc(fp);
		}
		mb[j] = '\0';
		return (char)0;
	}
	else
	{
		return c;
	}
#endif
	return ( c );
}

/******************************************************************************/

extern int RIScpp_process_file(
	char * file_name)
{
#ifdef WIN32
	wchar_t *begin_ptr;
	wchar_t *wfile_name;
#else
	char * begin_ptr;
#endif
	char * dot_ptr;
	int nest = 0;
	int line_num=1;

	CPP_DBG(("\nRIScpp_process_file file_name = %s\n", STRING(file_name)));

	/* This code is moved to top as there is no need to work further
	when the input file does not exist. -kmreddy 09.13.95 
	TR # 439503095 */

	RIScpp_in_file = RIScom_fopen(file_name, "r");
	if (!RIScpp_in_file)
	{
		RIScpp_err_return(RIS_E_OPEN_INPUT_FILE_ERROR,0,0,file_name,0);
		return(-1);  
	}

	RIScpp_ident_num = 0;
	RIScpp_stmt_index = 0;
	RIScpp_cursor_list = 0;
	RIScpp_notfound_targ = 0;
	RIScpp_sqlerror_targ = 0;
	RIScpp_scope_stack = 0;

	/* search for base file name */
#ifdef WIN32
	RIScom_multiwide(&RISwide_ptr, &file_name, &RISwide_size, MULTITOWIDE,0);
	wfile_name = RISwide_ptr;

	if ((begin_ptr = wcsrchr(wfile_name, WIDECHAR('\\'))) != 0)
		begin_ptr++;
	else
		begin_ptr = wfile_name;

	len = wcslen(wfile_name);
	RIScpp_out_name = ALLOCBP(len+1);
	RIScom_multiwide(&begin_ptr, &RISmulti_ptr, &RISmulti_size, WIDETOMULTI,0);
	memcpy(RIScpp_out_name, RISmulti_ptr, len);
#else
	if ((begin_ptr = RIScom_strrchr(file_name, PATH_CHAR)) != 0)
	{
		begin_ptr++;
	}
	else
	{
		begin_ptr = file_name;
	}
	len = strlen(begin_ptr);
	RIScpp_out_name = ALLOCBP(len+1);
	memcpy(RIScpp_out_name,begin_ptr,len);
#endif

	/* replace extension .rc and .ext with .c */

	dot_ptr = RIScom_strrchr(RIScpp_out_name, '.');
	dot_ptr[1] = 'c';
	dot_ptr[2] = '\0';

	/* open output file */

	RIScpp_out_file = RIScom_fopen(RIScpp_out_name,"w");
	if (!RIScpp_out_file)
	{
		RIScpp_err_return(RIS_E_OPEN_OUTPUT_FILE_ERROR,0,0,RIScpp_out_name,0);
		return(-1); 
	}

	/* open temporary file */

	RIScom_tmpnam(RIScpp_temp_name);
	RIScpp_temp_file = RIScom_fopen(RIScpp_temp_name,"w+");
	if (!RIScpp_temp_file)
	{
		RIScpp_err_return(RIS_E_OPEN_TEMP_FILE_ERROR,0,0,RIScpp_temp_name,0);
		return(-1); 
	}

	/* write global stuff to output file */

	fprintf(RIScpp_out_file,"#include \"ris.h\"\n");

	/* create hash table for host variables and cursor names */

	if (!hcreate(HASH_TABLE_SIZE))
	{
		RIScpp_err_return(RIS_E_CREATE_HASH_ERROR,0,0,file_name,0);
		return(-1); 
	}

	/* set up scope stack for outermost level */

	RIScpp_push_scope();
/*
**  Below 6 lines are moved to top -kmreddy  09/13/95
	TR 439503095

	RIScpp_in_file = RIScom_fopen(file_name, "r");
	if (!RIScpp_in_file)
	{
		RIScpp_err_return(RIS_E_OPEN_INPUT_FILE_ERROR,0,0,file_name,0);
		return(-1);  
	}
**
*/
	/** puts the line number 1 in the .c file */

	if(RIScpp_pound_lines)
	{
		print_line_directive(line_num, file_name);
	}
	RIScpp_process(1, file_name, &line_num, RIScpp_in_file, &nest);

	if (nest > 0)
	{
		RIScpp_err_return(RIS_E_UNMATCHED_IFDEF,0,0,file_name,0);
		return(-1);
	}

	/* print statement id variable declarations in output file */

	RIScpp_print_stmt_id_var_decls();

	/* copy temp file to output file */

	RIScpp_copy_temp_to_out();

	/* remove hash table */

	hdestroy();

	/* close temp file */

	if (RIScom_fclose(RIScpp_temp_file))
	{
		RIScpp_err_return(RIS_E_CLOSE_TEMP_FILE_ERROR,0,0,RIScpp_temp_name,0);
		return(-1);
	}

	/* remove temp file */

    if (remove(RIScpp_temp_name))
	{
		RIScpp_err_return(RIS_E_UNLINK_TEMP_FILE_ERROR,0,0,RIScpp_temp_name,0);
		return(-1);
	}

	/* close output file */

	if (RIScom_fclose(RIScpp_out_file))
	{
		RIScpp_err_return(RIS_E_CLOSE_OUTPUT_FILE_ERROR,0,0,RIScpp_out_name,0);
		return(-1);
	}

	/* close input file */

	if (RIScom_fclose(RIScpp_in_file))
	{
		RIScpp_err_return(RIS_E_CLOSE_INPUT_FILE_ERROR,0,0,file_name,0);
		return(-1);
	}

	CPP_DBG(("RIScpp_process_file file_name: returning\n"));
	return(0);
}

/******************************************************************************/

extern int RIScpp_process(
	int process_flag,
	char *file_name,
	int *line_num,
	FILE * fip,
	int * nest)
{
	FILE *temp_file;
	int sts;
	int i;
	int c;
	int token;
	int grow_size;
	int query_offset = 0;
	ristree * tp;
	static int begin_flag = 0;
	int line_len = 0;
	int func_def_flag = 0;
	int found_single = 0;
	int found_double = 0;
	int found_comment = 0;
	int get_new_c = 1;
	int newline_flag = 0;
	int temp_num;
	char *mb = (char *)SYS_MALLOC(RIS_MAX_CHAR_STRING_SIZE);

#ifdef WIN32
	wchar_t tmp_char;
#else
	int tmp_char;
#endif

	CPP_DBG(("\nRIScpp_process process_flag=%d file_name = <%s> line_num = %d fip=0x%x nest=%d\n", 
			process_flag, STRING(file_name), *line_num, fip, *nest));

	/* read a block of text */
	/* GetNextChar returns -1 if end-of-file is encountered */
	while ((c = GetNextChar(fip,mb)) != EOF )
	{
#ifdef WIN32
			/*convert multibyte char to wide char */

			RIScom_multiwide(&RISwide_ptr,&mb,&RISwide_size, MULTITOWIDE,0);
			tmp_char = *RISwide_ptr;
#else
		tmp_char = c;
#endif
		/* process input file */ 

		for(i=0;i < RIScpp_LINE_BUF_SIZE && tmp_char != -1 &&
			(RIScpp_ignore_special || tmp_char != WIDECHAR(';')) &&
			tmp_char != WIDECHAR('\n'); i++)
		{


			/* if a scope boundary is hit push or pop scope stack appropriately */

			switch(tmp_char)
			{
				case WIDECHAR('-'):
					line_buf[i] = '\0';
					if (!RIScpp_ignore_special && (query_offset || 
						RIScpp_find_exec_sql(line_buf)))
					{
						c = GetNextChar(fip, mb);
#ifdef WIN32
						RIScom_multiwide(&RISwide_ptr,&mb,&RISwide_size,MULTITOWIDE,0);
						tmp_char = *RISwide_ptr;
#else
						tmp_char = c;
#endif
						if (tmp_char == WIDECHAR('-') )
						{
							while((c=GetNextChar(fip,mb)) != -1 )
								if (c == '\n')  break;
							i--;
						}
						else
						{
							line_buf[i] = '-';
						}
						get_new_c = 0;
					}
					else
					{
#ifdef WIN32					
						i = copy_linebuf(mb, i);
						if ( i == -1 )
						{
							RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
							return(-1);
						}
#else					
						line_buf[i] = (char)c;
#endif
					}
				break;

				case WIDECHAR('\''):
					if (found_single || !RIScpp_ignore_special)
					{
						RIScpp_ignore_special = ~RIScpp_ignore_special;
						found_single = ~ found_single;
					}
#ifdef WIN32
						i = copy_linebuf(mb, i);
						if ( i == -1 )
						{
							RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
							return(-1);
						}
#else
					line_buf[i] = (char)c;
#endif
				break;

				case WIDECHAR('\\'):
					if (found_single || found_double)
					{
						c = GetNextChar(fip,mb);
#ifdef WIN32
						RIScom_multiwide(&RISwide_ptr, &mb, &RISwide_size,
								MULTITOWIDE, 0);
						tmp_char = *RISwide_ptr;
#else
						tmp_char = c;
#endif
						switch(tmp_char)
						{
							case WIDECHAR('\n'):
								i--;
								(*line_num)++;
							break;

							case WIDECHAR('\''):
								line_buf[i] = '\\';
								i++;
								if (i >= RIScpp_LINE_BUF_SIZE)
								{
									RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
									return(-1);
								}
								line_buf[i] = '\'';
							break;

							case WIDECHAR('\"'):
								line_buf[i] = '\\';
								i++;
								if (i >= RIScpp_LINE_BUF_SIZE)
								{
									RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
									return(-1);
								}
								line_buf[i] = '\"';
							break;

							case WIDECHAR('\\'):
								line_buf[i] = '\\';
								i++;
								if (i >= RIScpp_LINE_BUF_SIZE)
								{
									RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
									return(-1);
								}
								line_buf[i] = '\\';
							break;

							default:
								line_buf[i] = '\\';
								get_new_c = 0;
							break;
						}
					}
					else
					{
#ifdef WIN32
						i = copy_linebuf(mb, i);
						if ( i == -1 )
						{
							RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
							return(-1);
						}
#else
						line_buf[i] = c;
#endif
					}
				break;
				
				case WIDECHAR('\"'):
					if (found_double || !RIScpp_ignore_special)
					{
						RIScpp_ignore_special = ~RIScpp_ignore_special;
						found_double = ~found_double;
					}
#ifdef WIN32
					i = copy_linebuf(mb, i);
					if ( i == -1 )
					{
						RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
						return(-1);
					}
#else
					line_buf[i] = (char)c;
#endif
				break;

				case WIDECHAR('/'):
#ifdef WIN32
					i = copy_linebuf(mb, i);
					if ( i == -1 )
					{
						RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
						return(-1);
					}
#else
					line_buf[i] = (char)c;
#endif
					c = GetNextChar(fip,mb);
#ifdef WIN32
					RIScom_multiwide(&RISwide_ptr, &mb, &RISwide_size,
							MULTITOWIDE, 0);
					tmp_char = *RISwide_ptr;
#else
					tmp_char = c;
#endif
					if (tmp_char == WIDECHAR('*') && !RIScpp_ignore_special)
					{
						if (query_offset || RIScpp_find_exec_sql(line_buf))
						{
							RIScpp_err_return(RIS_E_INVALID_COMMENT,0,0,
								file_name,*line_num);
							return(-1);
						}
						/*----------------------------------------------------------------
						**	Increment i to accommodate the / character for the comment.
						**	Before we copy this character into line_buf, we must make 
						**	we are not over the byte limit.  Paula 12/94
						----------------------------------------------------------------*/
						++i;
						if (i >= RIScpp_LINE_BUF_SIZE)
						{
							RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
							return(-1);
						}
#ifdef WIN32
						i = copy_linebuf(mb, i);
						if ( i == -1 )
						{
							RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
							return(-1);
						}
#else
						line_buf[i] = (char)c;
#endif
						RIScpp_ignore_special = 1;
						found_comment = 1;
					}
					else
					{
						get_new_c = 0;
					}
				break;

				case WIDECHAR('*'):
#ifdef WIN32
					i = copy_linebuf(mb, i);
					if ( i == -1 )
					{
						RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
						return(-1);
					}
#else
					line_buf[i] = (char)c;
#endif
					c = GetNextChar(fip,mb);

#ifdef WIN32
					RIScom_multiwide(&RISwide_ptr, &mb, &RISwide_size,
							MULTITOWIDE, 0);
					tmp_char = *RISwide_ptr;
#else
					tmp_char = c;
#endif
					if (tmp_char == WIDECHAR('/') && found_comment)
					{
						/*----------------------------------------------------------------
						**	Increment i to accommodate the * character for the comment.
						**	Before we copy this character into line_buf, we must make 
						**	we are not over the byte limit.  Paula 12/94
						----------------------------------------------------------------*/
						++i;
						if (i >= RIScpp_LINE_BUF_SIZE)
						{
							RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
							return(-1);
						}
#ifdef WIN32
						i = copy_linebuf(mb, i);
						if ( i == -1 )
						{
							RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
							return(-1);
						}
#else
						line_buf[i] = (char)c;
#endif
						RIScpp_ignore_special = 0;
						found_comment = 0;

						/*----------------------------------------------------------------
						**	Increment i to accommodate the null.  Before we copy the null
						**	to line_buf we must make sure we are not over the byte limit
						----------------------------------------------------------------*/
						++i;
						if (i >= RIScpp_LINE_BUF_SIZE)
						{
							RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
							return(-1);
						}
						
						/* copy block to temporary file unaltered */
						line_buf[i] = '\0';
						if (process_flag)
						{
							fprintf(RIScpp_temp_file,"%s",line_buf);
						}
						line_len = 0;
						i = -1;
					}
					else
					{
						get_new_c = 0;
					}
				break;

				case WIDECHAR('('):
					if (!RIScpp_ignore_special)			 
					{
						/*
						** First check for the existence of the stack pointer
						** then the pointed "next" value - TR#???????? Radha 7/94 
						*/
						if (RIScpp_scope_stack && !RIScpp_scope_stack->next)
						{
							/* if an lparen is found and
							** we are not inside a function
							** this may be the beginning of
							** a function def
							*/

							RIScpp_push_scope();
							func_def_flag = 1;
						}
					}
#ifdef WIN32
					i = copy_linebuf(mb, i);
					if ( i == -1 )
					{
						RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
						return(-1);
					}
#else
					line_buf[i] = (char)c;
#endif
				break;

				case WIDECHAR('{'):
					if (!RIScpp_ignore_special)
					{
						if (func_def_flag)
						{
							/* a function def was found */
							func_def_flag = 0;
						}
						else
						{
							RIScpp_push_scope();
						}
					}
#ifdef WIN32
					i = copy_linebuf(mb, i);
					if ( i == -1 )
					{
						RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
						return(-1);
					}
#else
					line_buf[i] = (char)c;
#endif
				break;
				
				case WIDECHAR('}'):
					if (!RIScpp_ignore_special)
					{
						RIScpp_pop_scope();
					}
#ifdef WIN32
					i = copy_linebuf(mb, i);
					if ( i == -1 )
					{
						RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
						return(-1);
					}

#else
					line_buf[i] = (char)c;
#endif
				break;

				case WIDECHAR('?'):
					c = GetNextChar(fip,mb);
#ifdef WIN32
					RIScom_multiwide(&RISwide_ptr, &mb, &RISwide_size,
							MULTITOWIDE, 0);
					tmp_char = *RISwide_ptr;
#else
					tmp_char = c;
#endif
					if (tmp_char == WIDECHAR('?'))
					{
						c = GetNextChar(fip,mb);
#ifdef WIN32
						RIScom_multiwide(&RISwide_ptr, &mb, &RISwide_size,
								MULTITOWIDE, 0);
						tmp_char = *RISwide_ptr;
#else
						tmp_char = c;
#endif
						if(tmp_char == WIDECHAR('('))
						{
							line_buf[i] = '[';
						}
						else if (tmp_char == WIDECHAR('<'))
						{
							line_buf[i] = '{';
						}
						else if (tmp_char == WIDECHAR(')'))
						{
							line_buf[i] = ']';
						}
						else if (tmp_char == WIDECHAR('>'))
						{
							line_buf[i] = '}';
						}
						else if (tmp_char == WIDECHAR('/'))
						{
							line_buf[i] = '\\';
						}
						else if (tmp_char == WIDECHAR('\''))
						{
							line_buf[i] = '^';
						}
						else if (tmp_char == WIDECHAR('='))
						{
							line_buf[i] = '#';
						}
						else if (tmp_char == WIDECHAR('!'))
						{
							line_buf[i] = '|';
						}
						else if (tmp_char == WIDECHAR('-'))
						{
							line_buf[i] = '~';
						}
						else
						{
							line_buf[i] = '?';
							i++;
							if (i >= RIScpp_LINE_BUF_SIZE)
							{
								RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
								return(-1);
							}
							line_buf[i] = '?';
							get_new_c = 0;
						}
					}
					else
					{
						line_buf[i] = '?';
						get_new_c = 0;
					}
				break;

				default:
#ifdef WIN32
				i = copy_linebuf(mb, i);
				if ( i == -1 )
				{
					RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
					return(-1);
				}
#else
				line_buf[i] = (char)c;
#endif
				break;
			}

			if (get_new_c)
			{
				c = GetNextChar(fip,mb);
#ifdef WIN32
				RIScom_multiwide(&RISwide_ptr, &mb, &RISwide_size,
						MULTITOWIDE, 0);
				tmp_char = *RISwide_ptr;
#else
				tmp_char = c;
#endif
			}
			else
			{
				get_new_c = 1;
			}
		}
		line_buf[i] = '\0';

		CPP_DBG(("line_buf = <%s>\n",STRING(line_buf)));

		if (i >= RIScpp_LINE_BUF_SIZE)
		{
			RIScpp_err_return(RIS_E_LINE_TOO_LONG,0,0,file_name,*line_num);
			return(-1);
		}
		if (found_single || found_double)
		{
			RIScpp_err_return(RIS_E_MISSING_CLOSING_QUOTE,0,0,file_name,
			*line_num);
			return(-1);
		}

		token = RIScpp_stmt_brk(line_buf);
		if(!process_flag 
		&& (token != RIS_TOK_ELSE)
		&& (token != RIS_TOK_ENDIF)
		&& (token != RIS_TOK_IFDEF)
		&& (token != RIS_TOK_IFNDEF))
		{

			line_buf[0] = '\0';
		}
		if (found_comment)
		{
			/* copy block to temporary file unaltered */

			if (process_flag)
			{
				fprintf(RIScpp_temp_file,"%s\n",line_buf);
			}
			(*line_num)++;
			line_len = 0;
		}
		else
		{
			switch(tmp_char)
			{
				case WIDECHAR(';'):
					newline_flag = 0;
					if (func_def_flag)
					{
						/* a false alarm so pop scope stack */
						func_def_flag = 0;
						RIScpp_pop_scope();
					}
					if (query_offset)
					{
						len = strlen(line_buf)+1;
						if ((grow_size = query_offset + len -
						RIScpp_query_buf_size) > 0)
						{
							RIScpp_expand_buf(&RIScpp_query_buf,
							&RIScpp_query_buf_size,grow_size);
						}
						memcpy(&RIScpp_query_buf[query_offset],line_buf,len);

						/* find beginning of ris statement */

						i = RIScpp_find_exec_sql(RIScpp_query_buf);

						/* translate embeded ris statement to ris function calls */

						if (begin_flag
							&&(token != RIS_TOK_INCLUDE)
							&&(token != RIS_TOK_DEFINE)
							&&(token != RIS_TOK_UNDEF)
							&&(token != RIS_TOK_ENDIF)
							&&(token != RIS_TOK_ELSE)
							&&(token != RIS_TOK_IFDEF)
							&&(token != RIS_TOK_IFNDEF))
						{
							tp = RIScpp_translate_stmt(i,1,RIScpp_query_buf,*line_num, file_name);
							if (!tp)
							{
								query_offset = 0;
								break;
							}
							switch(tp->tok)
							{
								case RIS_TOK_HOST_VAR_DEF:
									if (RIScpp_pound_lines)
									{
										line_len = print_line_directive(
											*line_num,file_name);
									}
								break;
								case RIS_TOK_VIRTUAL:
									if (RIScpp_pound_lines)
									{
										fseek(RIScpp_temp_file,-line_len,1);
										line_len = print_line_directive(
											*line_num,file_name);
									}
								break;
								case RIS_TOK_END_DECLARE:
									begin_flag = 0;
									if (RIScpp_pound_lines)
									{
										fseek(RIScpp_temp_file,-line_len,1);
										line_len = print_line_directive(
											*line_num,file_name);
									}
								break;
								default:
									begin_flag = 0;
									RIScpp_err_return(RIS_E_MISSING_END_DECLARE
									,RIScpp_query_buf,tp->pos,file_name,
									*line_num);
								break;
							}
						}
						else
						{
							tp = RIScpp_translate_stmt(i,0,RIScpp_query_buf,*line_num, file_name);
							if (!tp)
							{
								query_offset = 0;
								break;
							}
							switch(tp->tok)
							{
								case RIS_TOK_BEGIN_DECLARE:
									begin_flag = 1;
									if (RIScpp_pound_lines)
									{
										fseek(RIScpp_temp_file,-line_len,1);
										line_len=print_line_directive(
									 		*line_num,file_name);
									}
								break;
       							case RIS_TOK_INCLUDE:
									temp_file = RIScpp_fopen(RIScpp_start_i_list,
									 tp->rhs->lhs->info.val);
									if (!temp_file)
									{
										RIScpp_err_return(
										 RIS_E_OPEN_INPUT_FILE_ERROR,0,0,
									 	 tp->rhs->lhs->info.val,0);
										return(-1);  
									}
									temp_num = 1;
									if(RIScpp_pound_lines)
									{
										line_len=print_line_directive(
											temp_num, tp->rhs->lhs->info.val);
									}
									RIScpp_process(1,tp->rhs->lhs->info.val,
									&temp_num,temp_file,nest);
									if (RIScpp_pound_lines)
									{
										line_len=print_line_directive(
											*line_num,file_name);
									}
									if (RIScom_fclose(temp_file))
									{
										RIScpp_err_return(
										 RIS_E_CLOSE_INPUT_FILE_ERROR,0,0,
										 tp->rhs->lhs->info.val,0);
										return(-1);
									}
									break;
								case RIS_TOK_WHENEVER:
									if (RIScpp_pound_lines)
									{
										fseek(RIScpp_temp_file,-line_len,1);
										line_len = print_line_directive(
											*line_num,file_name);
									}
								break;
								default:
									if (RIScpp_pound_lines)
									{
										line_len = print_line_directive(
											*line_num,file_name);
									}
								break;
							}
						}
						query_offset = 0;
					}
					else
					{
						/* check for an embedded ris statement */

						if (((i = RIScpp_find_exec_sql(line_buf)) != 0) ||
						 (begin_flag && line_buf[0] != '#' && process_flag))
						{
							/* translate embeded ris statement to ris function calls */

							memcpy(RIScpp_query_buf,line_buf,strlen(line_buf)+1);
							if (begin_flag
								&&(token != RIS_TOK_INCLUDE)
								&&(token != RIS_TOK_DEFINE)
								&&(token != RIS_TOK_UNDEF)
								&&(token != RIS_TOK_ENDIF)
								&&(token != RIS_TOK_ELSE)
								&&(token != RIS_TOK_IFDEF)
								&&(token != RIS_TOK_IFNDEF))
							{
								tp = RIScpp_translate_stmt(i,1,RIScpp_query_buf,*line_num, file_name);
								if (!tp)
								{
									break;
								}
								switch(tp->tok)
								{
									case RIS_TOK_HOST_VAR_DEF:
										if (RIScpp_pound_lines)
										{
											line_len = print_line_directive( 
										 		*line_num,file_name);
										}
									break;
									case RIS_TOK_VIRTUAL:
										if (RIScpp_pound_lines)
										{
											fseek(RIScpp_temp_file,-line_len,1);
											line_len = print_line_directive(
												*line_num,file_name);
										}
									break;
									case RIS_TOK_END_DECLARE:
										begin_flag = 0;
										if (RIScpp_pound_lines)
										{
											fseek(RIScpp_temp_file,-line_len,1);
											line_len = print_line_directive(
												*line_num,file_name);
										}
									break;
									default:
										begin_flag = 0;
										RIScpp_err_return(RIS_E_MISSING_END_DECLARE
									 	,RIScpp_query_buf,tp->pos,file_name,
									 	*line_num);
									break;
								}
							}
							else
							{
								tp = RIScpp_translate_stmt(i,0,RIScpp_query_buf,*line_num, file_name);
								if (!tp)
								{
									break;
								}
								switch(tp->tok)
								{
									case RIS_TOK_BEGIN_DECLARE:
										begin_flag = 1;
										if(RIScpp_pound_lines)
										{
											fseek(RIScpp_temp_file,-line_len,1);
											line_len=print_line_directive(
										 		*line_num,file_name);
										}
									break;

									case RIS_TOK_IFDEF:
										if (RIScpp_pound_lines)
										{
											line_len=print_line_directive(
										 		*line_num,file_name);
										}
										(*nest)++;
										if(RIScpp_find_macro_name(tp, RIS_TOK_IFDEF))
										{
											sts = RIScpp_process(process_flag, 
											 file_name,line_num, fip,nest); 
											switch (sts)
											{
												case RIS_TOK_ELSE:
													sts = RIScpp_process(0,
													 file_name, line_num, fip,
													 nest);
												break;
												case RIS_TOK_ENDIF:
												break;
											}

										}
										else
										{
											sts = RIScpp_process(0, file_name,
											 line_num, fip, nest);
											switch(sts)
											{
												case RIS_TOK_ELSE:
													sts = RIScpp_process(
													 process_flag, file_name,
													 line_num, fip, nest);
												break;
												case RIS_TOK_ENDIF:
												break;
											}
										}
									break;
									case RIS_TOK_IFNDEF:
										if (RIScpp_pound_lines)
										{
											line_len=print_line_directive(
										 		*line_num,file_name);
										}
										(*nest)++;
										if(!(RIScpp_find_macro_name(tp, RIS_TOK_IFNDEF)))
										{
											sts = RIScpp_process(process_flag,
											file_name, line_num, fip,nest);
											switch (sts)
											{
												case RIS_TOK_ELSE:
													sts = RIScpp_process(0,
													 file_name, line_num, fip,
													 nest);
												break;
												case RIS_TOK_ENDIF:
												break;
											}

										}
										else
										{
											sts = RIScpp_process(0, file_name,
											 line_num, fip,nest);
											switch(sts)
											{
												case RIS_TOK_ELSE:
													sts = RIScpp_process(
													process_flag, file_name,
													line_num, fip, nest);
												break;
												case RIS_TOK_ENDIF:
												break;
											}
										}
									break;
									case RIS_TOK_ELSE:
										if (RIScpp_pound_lines)
										{
											line_len=print_line_directive(
										 		*line_num,file_name);
										}
										return(RIS_TOK_ELSE);
									case RIS_TOK_ENDIF:
										if (RIScpp_pound_lines)
										{
											line_len=print_line_directive(
										 		*line_num,file_name);
										}
										(*nest)--;
										if (*nest < 0)
										{
											RIScpp_err_return(
											 RIS_E_UNMATCHED_ENDIF,0,0,
											 file_name, *line_num);
											return(-1);
										}
										return(RIS_TOK_ENDIF);
        							case RIS_TOK_INCLUDE:
									temp_file = RIScpp_fopen(RIScpp_start_i_list,
									 tp->rhs->lhs->info.val);
									if (!temp_file)
									{
										RIScpp_err_return(
										 RIS_E_OPEN_INPUT_FILE_ERROR,0,0,
									 	 tp->rhs->lhs->info.val,0);
										return(-1);  
									}
									temp_num = 1;
									if(RIScpp_pound_lines)
									{
										line_len=print_line_directive(
											temp_num, tp->rhs->lhs->info.val);
									}
									RIScpp_process(1,tp->rhs->lhs->info.val,
									&temp_num, temp_file,nest);
									if (RIScpp_pound_lines)
									{
										line_len=print_line_directive(
											*line_num,file_name);
									}
									if (RIScom_fclose(temp_file))
									{
										RIScpp_err_return(
										 RIS_E_CLOSE_INPUT_FILE_ERROR,0,0,
										 tp->rhs->lhs->info.val,0);
										return(-1);
									}
									break;
									case RIS_TOK_WHENEVER:
										if (RIScpp_pound_lines)
										{
											fseek(RIScpp_temp_file,-line_len,1);
											line_len = print_line_directive(
												*line_num,file_name);
										}
									break;
									default:
										if (RIScpp_pound_lines)
										{
											line_len = print_line_directive(
												*line_num,file_name);
										}
									break;
								}
							}
						}
						else
						{
							/* copy block to temporary file unaltered */
							if(process_flag)
							{
								fprintf(RIScpp_temp_file,"%s;",line_buf);
								line_len = 0;
							}
						}
					}
				break;
				case '\n':
					if (query_offset)
					{
						len = strlen(line_buf);
						if ((grow_size = query_offset + len -
						 RIScpp_query_buf_size) > 0)
						{
							RIScpp_expand_buf(&RIScpp_query_buf,
							 &RIScpp_query_buf_size,grow_size);
						}
						line_buf[i] = ' ';
						memcpy(&RIScpp_query_buf[query_offset],line_buf,len);
						query_offset += len;
					}
					else
					{
						if ((begin_flag && line_buf[0] != '#') ||
						 RIScpp_find_exec_sql(line_buf))
						{
							len = strlen(line_buf);
							line_buf[i] = ' ';
							memcpy(RIScpp_query_buf,line_buf,len);
							query_offset = len;
						}
						else
						{
							if (newline_flag || RIScpp_find_non_white(line_buf))
							{
								line_len = 0;
								newline_flag = 0;
							}
							else
							{
								if (line_len)
								{
									line_len += strlen(line_buf)+1;
									newline_flag = 1;
								}
							}
							if(process_flag)
							{
								fprintf(RIScpp_temp_file,"%s\n",line_buf);
							}
						}
					}
					(*line_num)++;

				break;
				case -1:
					if (query_offset || RIScpp_find_exec_sql(line_buf))
					{
						RIScpp_err_return(RIS_E_MISSING_SEMICOLON,0,0,file_name,
						 *line_num);
						 return(-1);
					}
					else if (begin_flag)
					{
						RIScpp_err_return(RIS_E_MISSING_END_DECLARE,0,0,
						 file_name,*line_num);
						 return(-1);
					}
					else
					{
						fprintf(RIScpp_temp_file,"%s",line_buf);
					}
				break;
				default:
					RIScpp_err_return(RIS_E_INTERNAL_ERROR,0,0,file_name,
					 *line_num);
				break;
			}
		}
	}
	if (query_offset)
	{
		RIScpp_err_return(RIS_E_MISSING_SEMICOLON,0,0,file_name,
		 *line_num);
		 return(-1);
	}

	return(0);  
}

/******************************************************************************/

static int RIScpp_stmt_brk(
 	char * buf) 
{
	char tok_buf[3][RIS_MAX_ID_SIZE];
	char buf1[RIScpp_LINE_BUF_SIZE];
	char * tokptr;
	char * strptr;
	int i;
	
	CPP_DBG(("\nRIScpp_stmt_brk buf=%s\n", STRING(buf)));

	tok_buf[0][0] = '\0';
	tok_buf[1][0] = '\0';
	tok_buf[2][0] = '\0';
	strcpy(buf1, buf);
	strptr = buf1;

/*----------------------------------------------------------------------------
**  SPECIAL INTERNATIONALIZATION NOTE:
**		Leaving alone.  Since we are searching for keywords, it will always
**  	work for the english case.  If, for some reason, one of the byte 
**		patterns match one of the special characters, the whole word would
**		not be equal to a keyword.  It is not worth time to convert to 
**		wide characters.  Paula 1/23/95
----------------------------------------------------------------------------*/
	for(i=0; i<3; i++)	
	{
		if((tokptr = strtok(strptr, " \t;\"")) != 0) /*itbokic 3/30 */
		{
       		strncpy(tok_buf[i], tokptr, RIS_MAX_ID_SIZE); /*itbokic 3/30 */
			tok_buf[i][RIS_MAX_ID_SIZE-1] = '\0';
       		strptr = 0;
		}
		else
		{
			break;
		}
	}

	if( RISpar_lookup_keyword(tok_buf[0],0)==RIS_TOK_EXEC 
		&& RISpar_lookup_keyword(tok_buf[1],0)==RIS_TOK_SQL )
	{
		return(RISpar_lookup_keyword(tok_buf[2],0));
	}
	else
	{
		return(0);
	}
}

static int copy_linebuf ( 
	char *mb, 
	int i)
{
	int	j;
	
	j = strlen ( mb );
	if (( j + i) >= RIScpp_LINE_BUF_SIZE )
	{
		return(-1);
	}

	for(j=0; mb[j]; j++)
	{
		line_buf[i] = mb[j];
		if (mb[j+1] == '\0')
			break;
		else
			i++;
	}
	return ( i );
}

/******************************************************************************/
