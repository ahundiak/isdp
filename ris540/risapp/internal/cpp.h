/*
**	NAME:							cpp.h
**	AUTHORS:						David Michal
**	CREATION DATE:					6/88
**	ABSTRACT:
**		The include file for all CPP preprocessor source files.	
**	
**	REVISION HISTORY:
*/
 
#ifndef RIS_CPP_H
#define RIS_CPP_H

#ifdef CPP_GLOBAL_DEFINE
#define CPP_EXTERN
#define CPP_INIT(value) = value
#else
#define CPP_EXTERN extern
#define CPP_INIT(value)
#endif

/*
**	INCLUDES
*/
#include <stdio.h>
#if defined(unix)
#include <search.h>
#endif
#if defined(WIN32) || defined(DOS)
#include "RIShsrch.h"
#endif
#include "risapi.h"
#include "riscl_pa.h"
#include "risdebug.h"
#include "rislimit.h"
#include "ristoken.h"
#include "risstjmp.h"
#include "rislang.h"


/*
**	DEFINES
*/

/* this indicates the number of bytes in a multibyte character */
#define MULTIBYTE_SIZE 	2

#define RIScpp_QUERY_CHUNK_SIZE 2048
#define RIScpp_LINE_BUF_SIZE 1024

#define BEGIN_BRACE fprintf(RIScpp_temp_file,"{")
#define END_BRACE fprintf(RIScpp_temp_file,"}\n")

#define CPP_ERR_RETURN(status,errpos)	\
{										\
	RIS_ERRPOS = errpos;				\
	LONGJMP(status);					\
}


#if defined(unix)
#define PATH_CHAR '/'
#define PATH_CHAR_STR "/"
#endif
#if defined(WIN32) || defined(DOS)
#define PATH_CHAR '\\'
#define PATH_CHAR_STR "\\"
#endif

#if defined(unix) || defined(WIN32)
#define STDERR stderr
#endif
#if defined(DOS)
#define STDERR stdout
#endif

/*
**	TYPES
*/
typedef	struct var_list_node
{
	int ident;
	struct type_spec_list_node * type;
	int * sizes;
	int ptr;
	int array;
	char * name;
	char * string;
	struct var_list_node * next;
} var_list_node;

typedef struct type_spec_list_node
{
	int spec_tok;
	struct type_spec_list_node * next;
}type_spec_list_node;

typedef	struct parm_list_node
{
	var_list_node * var;
	int var_pos;
	var_list_node * ind_var;
	struct parm_list_node * next;
} parm_list_node;

typedef struct include_dir_list_node
{
	char include_dir[RIS_MAX_PATH_SIZE];
	struct include_dir_list_node * next;
}include_dir_list_node;

typedef	struct stmt_id_list_node
{
	int ident;
	int index;
	char * name;
	struct stmt_id_list_node * next;
} stmt_id_list_node;

typedef	struct cursor_list_node
{
	int ident;
	int index;
	char * name;
	int in_parm_count;	
	parm_list_node * in_parm_list;	
	struct cursor_list_node * next;
} cursor_list_node;

typedef struct scope_stack_node
{
	var_list_node * var_list;
	struct scope_stack_node * next;
} scope_stack_node;

/*
**	VARIABLES
*/

CPP_EXTERN int					RIScpp_line_num;
CPP_EXTERN int					RIScpp_ident_num;
CPP_EXTERN int					RIScpp_async_flag;
CPP_EXTERN int					RIScpp_found_error;
CPP_EXTERN int					RIScpp_found_error_in_file;
CPP_EXTERN int					RIScpp_ignore_special;
CPP_EXTERN int					RIScpp_inc_line_num;
CPP_EXTERN int					RIScpp_pound_lines;
CPP_EXTERN int					RIScpp_query_buf_size;
CPP_EXTERN int					RIScpp_stmt_index;
CPP_EXTERN char					*RIScpp_in_name;
CPP_EXTERN char					*RIScpp_notfound_targ;
CPP_EXTERN char					*RIScpp_out_name;
CPP_EXTERN char					*RIScpp_query_buf;
CPP_EXTERN char					*RIScpp_sqlerror_targ;
CPP_EXTERN char					RISCLI_dir[RIS_MAX_PATH_SIZE];
CPP_EXTERN char					RISDP_dir[RIS_MAX_PATH_SIZE];
#if defined(unix) || defined(DOS)
CPP_EXTERN char					RIScpp_temp_name[L_tmpnam];
#endif
#if defined(WIN32)
CPP_EXTERN char					RIScpp_temp_name[MAX_PATH];
#endif
CPP_EXTERN char					*RIScpp_async_id_name;
CPP_EXTERN FILE					* RIScpp_in_file;
CPP_EXTERN FILE					* RIScpp_out_file;
CPP_EXTERN FILE					* RIScpp_temp_file;
CPP_EXTERN macro_list_node		*RIScpp_macro_list;
CPP_EXTERN cursor_list_node		*RIScpp_cursor_list;
CPP_EXTERN scope_stack_node		* RIScpp_scope_stack;
CPP_EXTERN stmt_id_list_node	*RIScpp_stmt_id_list;
CPP_EXTERN include_dir_list_node *RIScpp_start_i_list;
#if defined(DOS)
CPP_EXTERN char	 				szAppPath[RIS_MAX_PATH_SIZE];
#endif

#endif /* RIS_CPP_H */
