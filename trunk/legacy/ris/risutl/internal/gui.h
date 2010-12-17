/* Do not alter this SPC information: $Revision: 1.3.27.1 $ */
/*
**	NAME:							gui.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					5/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**		10/24/94 -Radha 
**			Added changes for MSSQL data server.
**
**		11/94:	Added variable RISgui_num_rows for INTERNATIONALIZATION.  Rick
*/
#ifndef INTERNAL_GUI_H
#define INTERNAL_GUI_H

#ifdef EXTERN
#undef EXTERN
#endif

#ifdef INIT
#undef INIT
#endif

#ifdef DEFINE_GUI_GLOBALS
# define EXTERN
# define INIT(x)	= x
#else
# define EXTERN		extern
# define INIT(x)
#endif
 
/*
**	INCLUDES
*/
#include <stdio.h>
#if defined(WIN32)
#include <windows.h>
#endif
#include <FI.h>
#include "risutl.h"
#include "ris.h"
#include "utl_err.h"
#include "utl_inf.h"

/*
**	DEFINES
*/
#ifdef NO_GUI_DBG
#define GUI_DBG(s)
#else
#define GUI_DBG(s)	if (RIS_gui_debug) {RIScom_output_debug s;}
#endif

#define CLEAR_ERROR memset(&RIS_gui_error, '\0', sizeof(RIS_gui_error));

/* 	Form files */
#define IN_FORM_FILE	"risgin.frm"	/* Interactive Form		*/
#define PW_FORM_FILE	"risgpswd.frm"	/* Password Form		*/
#define FI_FORM_FILE	"risgfile.frm"	/* File Form			*/
#define SR_FORM_FILE	"risgsrch.frm"	/* Search Form			*/
#define CF_FORM_FILE	"risgcfrm.frm"	/* Confirm Form			*/
#define UT_FORM_FILE	"risgutls.frm"	/* Utilities Form		*/
#define OP_FORM_FILE	"risgopts.frm"	/* Options Form			*/
#define SE_FORM_FILE	"risgset.frm"	/* Set Form				*/
#define SH_FORM_FILE	"risgshow.frm"	/* Show Form			*/
#define PA_FORM_FILE	"risgparm.frm"	/* Parms Form			*/
#define AB_FORM_FILE	"risgabou.frm"	/* About Form			*/
#define DB_FORM_FILE	"risdebug.frm"	/* Debug Form			*/
#define TR_FORM_FILE	"risgtran.frm"	/* Transaction Form		*/
#define ST_FORM_FILE	"risgshtr.frm"	/* Show Transactions Form		*/
#define UP_FORM_FILE	"risguspw.frm"	/* User Password Form	*/
#define OS_FORM_FILE	"risosusr.frm"	/* OS User Password Form	*/

/* Form labels */
#define IN_FORM			200				/* Interactive Form		*/
#define PW_FORM			201				/* Password Form		*/
#define FI_FORM			202				/* File Form			*/
#define SR_FORM			203				/* Search Form			*/
#define CF_FORM			204				/* Confirm Form			*/
#define UT_FORM			205				/* Utilities Form		*/
#define OP_FORM			206				/* Options Form			*/
#define SE_FORM			207				/* Set Form				*/
#define SH_FORM			208				/* Show Form			*/
#define PA_FORM			209				/* Parms Form			*/
#define AB_FORM			210				/* About Form			*/
#define DB_FORM			211				/* Debug Form			*/
#define TR_FORM			212				/* Transaction Form		*/
#define ST_FORM			213				/* Show Transaction Form*/
#define UP_FORM			214				/* User Password Form	*/
#define OS_FORM			215				/* OS User Password Form	*/

/* Form Messages */
#define IN_FORM_MSG		0
#define FI_FORM_MSG		1
#define SR_FORM_MSG		2
#define SE_FORM_MSG		3
#define FORM_MSG_COUNT	4

/* Interactive Form Gadget Labels */
#define IN_OPTIONS_BUTTON			15
#define IN_UTILITIES_BUTTON			16
#define IN_SAVE_RESULTS_BUTTON		17
#define IN_RESTART_BUTTON			18
#define IN_SET_BUTTON				19
#define IN_SHOW_BUTTON				20
#define IN_DEBUG_BUTTON				21
#define IN_MENU_BUTTON_8			22

#define IN_DEFAULT_SCHEMA_TEXT		25
#define IN_DEFAULT_SCHEMA_FIELD		26

#define IN_QUERY_TEXT				27
#define IN_QUERY_FIELD				28

#define IN_RESULT_TEXT				29
#define IN_RESULT_HEADER_FIELD		44
#define IN_RESULT_FIELD				30

#define IN_EXEC_QUERY_BUTTON		32
#define IN_CONT_QUERY_BUTTON		33
#define IN_ABORT_QUERY_BUTTON		43
#define IN_SAVE_QUERY_BUTTON		38
#define IN_OPEN_QUERY_BUTTON		39
#define IN_CLEAR_QUERY_BUTTON		40
#define IN_PREV_QUERY_BUTTON		35
#define IN_NEXT_QUERY_BUTTON		36
#define IN_SEARCH_QUERY_BUTTON		37
#define IN_QUERY_GROUP				52

#define IN_RESULT_SCROLLBAR			46
#define IN_RESULT_GROUP				53

#define IN_MSG_FIELD				41

/* Password form gadgets */
#define PW_PASSWORD_FIELD			27
#define PW_PASSWORD_TOGGLE			28

/* Options form gadgets */
#define OP_BY_COLUMN_CHECK			12
#define OP_BY_CHAR_CHECK			16
#define OP_ALL_ROWS_CHECK			22
#define OP_SCREEN_APPEND_CHECK		24
#define OP_SCREEN_OVERWRITE_CHECK	27

/* Open file form gadgets */
#define FI_TITLE_TEXT				13
#define FI_FILES_FIELD				20
#define FI_FILE_FIELD				12
#define FI_DIRS_FIELD				19
#define FI_DIR_FIELD				21
#define FI_FILE_TYPE_FIELD			17
#define FI_MESSAGE_FIELD			22

#define FI_APPEND_CHECK				24
#define FI_OVERWRITE_CHECK			23
#define FI_APPEND_OVERWRITE_GROUP	25

/* Search form gadgets */
#define SR_SEARCH_FIELD				15
#define SR_QUERY_FIELD				28
#define SR_UP_CHECK					18
#define SR_DOWN_CHECK				19
#define SR_NEXT_BUTTON				21
#define SR_MESSAGE_FIELD			16

/* Confirm form gadgets */
#define CF_MESSAGE_TEXT				16
#define CF_YES_BUTTON				11
#define CF_NO_BUTTON				12

/* Utilities form gadgets */
#define UT_RIS_BUTTON				25
#define UT_SCHEMA_MANAGER_BUTTON	12
#define UT_LOADER_BUTTON			16
#define UT_UNLOADER_BUTTON			17
#define UT_RECORD_BUTTON			19
#define UT_PLAYBACK_BUTTON			20
#define UT_CLEAN_SERVER_BUTTON		21
#define UT_DATA_TYPES_BUTTON		22
#define UT_DECODE_BUTTON			23

/* Set form gadgets */
#define SE_ANSI_CHECK				11
#define SE_VERIFY_CHECK				12
#define SE_AUTOCOMMIT_CHECK			16
#define SE_BLANKSTRIP_CHECK			32
#define SE_AUTORENAME_CHECK			33
#define SE_INFORMIX_CHECK			23
#define SE_ORACLE_CHECK				25
#define SE_INGRES_CHECK				26
#define SE_DB2_CHECK				27
#define SE_RDB_CHECK				28
#define SE_SYBASE_CHECK				29
#define SE_MSSQL_CHECK				35
#define SE_SQLDS_CHECK				31
#define SE_OS400_CHECK				34
#define SE_MESSAGE_FIELD			24

/* Show Form Gadgets */
#define SH_PARAMETERS_BUTTON		12
#define SH_ABOUT_BUTTON				16
#define SH_TRANSACTIONS_BUTTON		17

/* Parms Form Gadgets */
#define PA_SHARED_MEMORY_TEXT		33
#define PA_MAX_LOCAL_SERVERS_TEXT	34
#define PA_MAX_ROWS_TEXT			35
#define PA_MAX_BUFFER_SIZE_TEXT		36
#define PA_MAX_STATIC_STMTS_TEXT	37
#define PA_USER_STMTS_TEXT			38
#define PA_SECONDARY_SCHEMAS_TEXT	39
#define PA_TRANSACTIONS_TEXT		40
#define PA_TABLES_IN_MEM_TEXT		41
#define PA_TIMESTAMP_INTERVAL_TEXT	42
#define PA_INITIAL_TIMEOUT_TEXT		43
#define PA_TIMESTAMP_TOLERANCE_TEXT	44
#define PA_BUFFER_FULL_SIZE_TEXT	45
#define PA_BUFFER_FULL_TIMEOUT_TEXT	46
#define PA_LOCK_FILE_RETRY_TEXT		47

/* about form gadgets */
#define AB_TEXT_1					11
#define AB_TEXT_2					12

/* transaction form gadgets */
#define TR_SCHNAME_FIELD			17
#define TR_COMMIT_CHECK				13
#define TR_ROLLBACK_CHECK			14

/* show transactions form gadgets */
#define ST_SCHNAME_FIELD			11

/* User Password form gadgets */
#define UP_USERNAME_FIELD			11
#define UP_PASSWORD_FIELD			27
#define UP_PASSWORD_TOGGLE			28


/*
**   OS User Password form gadgets
*/
#define OS_USERNAME_FIELD           11
#define OS_PASSWORD_FIELD           27
#define OS_PASSWORD_TOGGLE          28
#define OS_OS_USERNAME_FIELD           17
#define OS_OS_PASSWORD_FIELD           19
#define OS_OS_PASSWORD_TOGGLE          18

/* query types */
#define SELECT		1
#define NONSELECT	2

#define RIS_HISTORY_FILE		"ris.his"
#define MAX_CMDS				50

/* options */
#define		H_SCROLL_COL			1
#define		H_SCROLL_CHAR			2
#define		FETCH_SCREEN_APPEND		3
#define		FETCH_SCREEN_OVERWRITE	4
#define		FETCH_ALL_ROWS			5


/* wildcard values */
#define MULTI_WILDCARD_CHAR		'*'
#define SINGLE_WILDCARD_CHAR	'?'

/*
**	TYPES
*/

/* Message */
typedef struct ris_gui_msg_s
{
	int		count;
	int		label[16];
	char	str[512];
	int		msg_fld_label;
	Form	fp;
} ris_gui_msg;


/* Process gadget struct */
typedef struct ris_gui_label_function_s
{
	int		label;
	void	(*function_ptr)();
} ris_gui_label_function;

/* Error info */
typedef struct ris_gui_error_info
{
	int		error;
	char	error_name[48];
	char	error_message[256];

	int		FI_error;
	char	FI_error_name[48];
	char	FI_error_message[256];
} ris_gui_error_info;

typedef struct column_s
{
	int		pos;
	int		width;
	double	view;	/* percent of data displayed; used by scrollbar */
} column_s;

typedef struct select_s
{
	char			*header;
	char			*buffer;
	int				width;
	int				col_count;
	struct column_s	*col;
} select_s;

typedef struct query_s
{
	int				status;
	int				type;
	sqlda			desc;
	struct select_s select;
} query_s;

typedef struct options_s
{
	int h_scroll_mode;
	int fetch_mode;
} options_s;

typedef struct modes_s
{
	int ansi;
	int verify;
	int blankstrip;
	int autocommit;
	int autorename;
	int	enable_dbms;
} modes_s;

typedef struct query_stack_s
{
	int start_row;
	int stop_row;
	char *query;
	struct query_stack_s *prev;
	struct query_stack_s *next;
} query_stack_s;

/*
**	VARIABLES
*/
EXTERN	int					RIS_gui_num_rows				INIT(0);
EXTERN	int					RIS_gui_debug					INIT(0);
EXTERN	int					RIS_gui_initialized				INIT(0);
EXTERN	ris_gui_msg			RIS_gui_msgs[FORM_MSG_COUNT];
EXTERN	ris_gui_error_info	RIS_gui_error;
EXTERN	debug_info_s		RIS_gui_debug_info[]
#ifdef DEFINE_GUI_GLOBALS
=
{
	{ "gui", 3, &RIS_gui_debug },
}
#endif
;
EXTERN int RIS_gui_debug_count INIT(sizeof(RIS_gui_debug_info)/sizeof(debug_info_s));

#endif
