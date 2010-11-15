/* Do not alter this SPC information: $Revision: 1.2.53.1 $ */
/*
**	NAME:							parser.h
**	AUTHORS:						David Michal
**	CREATION DATE:					03/17/88
**	ABSTRACT:
**		This file is included in all parser routines.
**	
**	REVISION HISTORY:
*/

#ifdef PARSE_GLOBAL_DEFINE
#define PARSE_EXTERN
#define PARSE_INITIAL(value) = value
#else
#define PARSE_EXTERN extern
#define PARSE_INITIAL(value)
#endif

/*
**	INCLUDES
*/
#include "riscom.h"
#include "riscl_pa.h"
#include "risdebug.h"
#include "rismem.h"
#include "ris_err.h"
#include "risstjmp.h"
#include "ristoken.h"
/*
**	DEFINES
*/
#define RISpar_ERR_RETURN(status,errpos) \
{ \
	risca->sqlerrd[4] = errpos; \
	risca->sqlerrd[5] = 1;  /* indicates parser error */ \
	LONGJMP(status); \
}

#define RISpar_PREPROCESSOR_ONLY() \
{ \
	if (!PREPROCESSOR) \
	{ \
		RISpar_ERR_RETURN(RIS_E_INV_DYNAMIC_STMT, 1) \
	} \
}

#define RISpar_CLIENT_ONLY() \
{ \
	if (!CLIENT) \
	{ \
		RISpar_ERR_RETURN(RIS_E_INV_STATIC_STMT, 1) \
	} \
}

#define RISpar_VERSION_5_REQUIRED(pos) \
{ \
	if (RIS_app_cli_version < 5) \
	{ \
		RISpar_ERR_RETURN(RIS_E_VERSION_5_APP_REQUIRED, pos) \
	} \
}

#define SPACE_FLAG		0x0001
#define DOT_FLAG		0x0002
#define SEMICOLON_FLAG	0x0004
#define COMMA_FLAG		0x0008
#define RPAREN_FLAG		0x0010

#define ALL_FLAGS	(SPACE_FLAG|DOT_FLAG|SEMICOLON_FLAG|COMMA_FLAG|RPAREN_FLAG)


/*
**	TYPES
*/
typedef struct lex_s
{
	char *val;
	int pos;
}lex_s;

/*
**	VARIABLES
*/


#if defined(WIN32)
PARSE_EXTERN  	wchar_t			*RISpar_head_bufp;
PARSE_EXTERN  	wchar_t			*RISpar_cur_bufp;
PARSE_EXTERN  	wchar_t			*RISpar_end_bufp;
PARSE_EXTERN  	wchar_t			*RISpar_beg_ptr;
PARSE_EXTERN  	wchar_t			*RISpar_cur_ptr;
PARSE_EXTERN  	wchar_t			*RISpar_end_ptr;
PARSE_EXTERN 	char			*RISpar_hold_multi;
PARSE_EXTERN 	int			 RISpar_hold_multi_size;
#else
PARSE_EXTERN  	char			*RISpar_head_bufp;
PARSE_EXTERN  	char			*RISpar_cur_bufp;
PARSE_EXTERN  	char			*RISpar_end_bufp;
PARSE_EXTERN  	char			*RISpar_beg_ptr;
PARSE_EXTERN  	char			*RISpar_cur_ptr;
PARSE_EXTERN  	char			*RISpar_end_ptr;
#endif

PARSE_EXTERN     char			*RISpar_old_sch;
PARSE_EXTERN     char			*RISpar_new_sch;
PARSE_EXTERN  	int				RISpar_lex_flag;
PARSE_EXTERN  	int				RISpar_exclude_flag;
PARSE_EXTERN  	int				RISpar_dot_flag;
PARSE_EXTERN  	int				RISpar_host_ident_flag;
PARSE_EXTERN  	int				RISpar_no_parms;
PARSE_EXTERN  	lex_s			RISpar_lex;
PARSE_EXTERN  	int				RISpar_token;
PARSE_EXTERN  	int				RISpar_union_all;
PARSE_EXTERN  	macro_list_node *RISpar_macro_list;
PARSE_EXTERN  	risschema		*RISpar_schema;
