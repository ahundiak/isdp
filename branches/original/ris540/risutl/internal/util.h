/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							util.h
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	REVISION HISTORY:
*/

#ifndef UTIL_H
#define UTIL_H
 
#ifdef UTIL_GLOBAL_DEFINE
# define EXTERN
# define INIT(value) = value
#else
# define EXTERN extern
# define INIT(value)
#endif

/*
**	INCLUDES
*/
#include <stdio.h>
#include "ris.h"
#include "utl_err.h"
#include "utl_inf.h"
#include "ris_err.h"
#include "rislimit.h"
#include "risstjmp.h"
#include "risutl.h"
#include "edit.h"

/*
**	DEFINES
*/
#define LINE_LEN			10000
#define ERROR_LEN			(2 * LINE_LEN + 500)

#define STOP_READ_EOF		1
#define STOP_READ_EOS		2
#define STOP_READ_ERROR		3

#define RETRIEVE_MODE		0
#define FETCH_MODE			1
#define NEXT_MODE			2
#define ASYNC_FETCH_MODE	-1
#define ASYNC_NEXT_MODE		-2

#if defined (WIN32) || defined(DOS)
#define NEWLINE				13	/* MSDOS CRT */
#else
#define NEWLINE				'\n'
#endif

#ifdef NO_UTL_DBG
#define UTL_DBG(s)
#else
#define UTL_DBG(s)			if (RISutl_debug) {RIScom_output_debug s;}
#endif

#define SET_INTERRUPT()		RISutl_interrupt = 1
#define CLEAR_INTERRUPT()	RISutl_interrupt = 0
#define INTERRUPTED()		(RISutl_interrupt)

#define UTL_ERROR_CHECK() \
{ \
	if (SQLCODE < RIS_SUCCESS) \
	{ \
		RISutl_get_ris_error(); \
		if (SQLCODE == RIS_E_INCONSISTENT_RESULTS) \
		{ \
			RISutl_get_ss_error(); \
		} \
		LONGJMP(RISUTL_E_RIS_ERROR); \
	} \
}

#define UTL_WARNING_CHECK() \
if (risca->sqlwarn[0] == 'W') \
{ \
	int i; \
	for(i = 0; i < 8; i ++ ) \
	{ \
		RISutl_warnings[i] |= risca->sqlwarn[i]; \
	} \
}


/*
**	TYPES
*/
typedef struct ris_utl_stmt_s
{
	short	stmt_id;
	sqlda	input;
	sqlda	output;
}ris_utl_stmt;

typedef struct RISutl_file_stack
{
	FILE *file;
	struct RISutl_file_stack *next;
} RISutl_file_stack;

/*
**	VARIABLES
*/
EXTERN int					RISutl_debug					INIT(0);
EXTERN int					RISutl_help_debug				INIT(0);
EXTERN int					RISutl_command_flag				INIT(0);
EXTERN int					RISutl_ignore_errors_flag		INIT(0);

EXTERN int					RISutl_async_id					INIT(-1);
EXTERN int					RISutl_testbed_output			INIT(0);
EXTERN int					RISutl_columns					INIT(80);
EXTERN int					RISutl_rows						INIT(24);
EXTERN char					RISutl_interrupt				INIT(0);

EXTERN short				RISutl_stmt_id;
EXTERN ris_utl_stmt			*RISutl_stmts;
EXTERN ris_parameters		RISutl_parameters;
EXTERN RISutl_file_stack	*RISutl_file_tos;

EXTERN char					RISutl_line[LINE_LEN];
EXTERN char					RISutl_buffer[LINE_LEN];
EXTERN char					*RISutl_ptr						INIT(RISutl_buffer);

EXTERN char							RISutl_warnings[8];
EXTERN char							RISutl_ris_error[ERROR_LEN];
EXTERN ris_superschema_error_info	RISutl_ss_error;


EXTERN debug_info_s RISutl_debug_info[]
#ifdef UTIL_GLOBAL_DEFINE
=
{
	{	"edt",	3,	&RISedt_debug	},
	{	"help",	4,	&RISutl_help_debug	},
	{	"utl",	3,	&RISutl_debug	},
}
#endif
;
EXTERN int RISutl_debug_count	INIT((sizeof(RISutl_debug_info)/sizeof(debug_info_s)));

#endif
