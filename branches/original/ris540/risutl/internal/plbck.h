/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							playback.h
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					6/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

#ifndef PLAYBACK_H
#define PLAYBACK_H

#ifdef DEFINE_GLOBALS
# define EXTERN
# define INIT(value)	= value
#else
# define EXTERN			extern
# define INIT(value)
#endif


/*
**	INCLUDES
*/
#include <stdio.h>
#include "ris.h"
#include "rislimit.h"

/*
**	DEFINES
*/
#define EXE			"risplbck"

#define EOF_OK		0
#define EOF_ERROR	1

#define DROP_NL		0
#define KEEP_NL		1

#define VERBOSE(s)	if (verbose) printf s
#define GET_NEXT_LINE(ef, nl) if (get_next_line(ef, nl)) return 1;
#define GET_STRING_DATA(s, end) if (get_string_data(&s, end)) return 1;
#define GET_BLOB_DATA(b) if (get_blob_data(b)) return 1;
#define GET_INPUT_SQLDA(sqlda) if (get_input_sqlda(sqlda)) return 1;
#define GET_OUTPUT_SQLDA(sqlda) if (get_output_sqlda(sqlda)) return 1;
#define GET_TEST_SQLDA(sqlda) if (get_test_sqlda(sqlda)) return 1;
#define GET_DESCRIBE_SQLDA(sqlda) if (get_describe_sqlda(sqlda)) return 1;
#define GET_COMMAND_STATUS(cmd) if (get_command_status(cmd)) return 1;

#define CHECKSUM					1
#define CLEAR						2
#define CLEAR_ASYNC					3
#define CLOSE						4
#define DEBUG						5
#define DESCRIBE					6
#define EXECUTE						7
#define EXECUTE_IMM					8
#define FETCH						9
#define GET_CLIENT_LOCATION			10
#define GET_DB_INFO					11
#define GET_DEFAULT_SCHNAME			12
#define GET_FLAGS					13
#define GET_PARAMETERS				14
#define GET_SCHEMA_FILE				15
#define GET_SCHEMA_FILE_LOCATION	16
#define GET_SCHEMA_INFO				17
#define GET_SCHEMA_NAMES			18
#define GET_SS_DEF					19
#define GET_SS_NAMES				20
#define GET_STMT_SCHNAME			21
#define INITIALIZE					22
#define LOCATE_CLIENT				23
#define LOCATE_SCHEMA_FILE			24
#define PREPARE						25
#define REPORT_ERROR				26
#define REPORT_SS_ERROR				27
#define SCHEMA_MGR					28
#define SELECT_INTO					29
#define START_CLIENT				30
#define STOP_CLIENT					31
#define TERMINATE					32
#define TEST_COMPLETION				33
#define GET_ASYNC_STMTS				34
#define GET_APP_VERSION				35
#define GET_SCHEMA_TRANSACTIONS		36
#define GET_LANGUAGE_NAME			37
#define GET_RIS_TYPE_CODE			38
#define GET_RIS_TYPE_STRING			39


#define EXPECTED_SUCCESS			0
#define EXPECTED_END_OF_DATA		1
#define EXPECTED_ERROR				2

#define GOT_SUCCESS					0
#define GOT_END_OF_DATA				1
#define GOT_ERROR					2

#define CONTINUE					0
#define	STOP						-1
#define RETRY						1

/*
**	TYPES
*/
typedef struct clear_s
{
	short			stmt_id;
	unsigned char	execute_mode;
	short			new_stmt_id;
	int				async_id;
} clear_s;

typedef struct clear_async_s
{
	int		async_id;
	int		new_async_id;
} clear_async_s;

typedef struct close_s
{
	short			stmt_id;
	unsigned char	execute_mode;
	int				async_id;
} close_s;

typedef struct debug_s
{
	char	*s;
	int		output_flag;
} debug_s;

typedef struct describe_s
{
	short	stmt_id;
	sqlda	*data;
	int		in_out;
} describe_s;

typedef struct execute_s
{
	short			stmt_id;
	sqlda			*in_sqlda;
	unsigned char	execute_mode;
	int				clear_flag;
	int				static_flag;
	short			new_stmt_id;
	int				async_id;
} execute_s;

typedef struct execute_imm_s
{
	short			*stmt_id;
	char			*query;
	sqlda			*in_sqlda;
	unsigned char	execute_mode;
	int				clear_flag;
	int				static_flag;
	short			new_stmt_id;
	int				async_id;
} execute_imm_s;

typedef struct fetch_s
{
	short			stmt_id;
	sqlda			*output;
	int				one_row_only;
	unsigned char	execute_mode;
	int				async_id;
} fetch_s;

typedef struct get_client_location_s
{
	client_parms	*parms;
} get_client_location_s;

typedef struct get_db_info_s
{
	int			dbid;
	ris_db_info	**dbp;
} get_db_info_s;

typedef struct get_default_schname_s
{
	char	*buffer;
} get_default_schname_s;

typedef struct get_flags_s
{
	int	*ansi_mode;
	int	*enable_dbms;
	int	*verify_mode;
	int	*blankstrip_mode;
	int	*autocommit;
	int	*autorename;
} get_flags_s;

typedef struct get_parameters_s
{
	ris_parameters	*parameters;
} get_parameters_s;

typedef struct get_schema_file_s
{
	char				**schema_filenamep;
	ris_db_info			**dblistp;
	ris_schema_info		**schlistp;
	ris_grantee_info	**granteep;
} get_schema_file_s;

typedef struct get_schema_file_location_s
{
	schema_file_parms	*parms;
} get_schema_file_location_s;

typedef struct get_schema_info_s
{
	char				*schname;
	ris_db_info			**dbp;
	ris_schema_info		**schemap;
	ris_grantee_info	**granteep;
} get_schema_info_s;

typedef struct get_schema_names_s
{
	char	(*buffer)[RIS_MAX_ID_SIZE];
	int		*countp;
} get_schema_names_s;

typedef struct get_ss_names_s
{
	char	(*buffer)[RIS_MAX_ID_SIZE];
	int		*countp;
} get_ss_names_s;

typedef struct get_ss_def_s
{
	char	*ss_name;
	char	(*buffer)[RIS_MAX_ID_SIZE];
	int		*countp;
} get_ss_def_s;

typedef struct get_stmt_schname_s
{
	char	*buffer;
} get_stmt_schname_s;

typedef struct initialize_s
{
	char 	*language_name;
} initialize_s;

typedef struct locate_client_s
{
	client_parms	*parms;
} locate_client_s;

typedef struct locate_schema_file_s
{
	schema_file_parms	*parms;
} locate_schema_file_s;

typedef struct prepare_s
{
	short	stmt_id;
	char	*query;
	int		clear_flag;
	int		static_flag;
	short	new_stmt_id;
} prepare_s;

typedef struct report_error_s
{
	int		*async_id;
	char	**ptrp;
} report_error_s;

typedef struct report_ss_error_s
{
	char	*ss_name;
} report_ss_error_s;

typedef struct schema_mgr_s
{
	int		mode;
	char	*data;
	char	*str;
} schema_mgr_s;

typedef struct select_into_s
{
	short			stmt_id;
	char			*query;
	sqlda			*in_sqlda;
	sqlda			*out_sqlda;
	unsigned char	execute_mode;
	short			new_stmt_id;
	int				async_id;
} select_into_s;

typedef struct test_completion_s
{
	sqlda	*desc;
	int		wait_flag;
} test_completion_s;

typedef struct get_async_stmts_s
{
	int		*buffer;
	int		*countp;
} get_async_stmts_s;

typedef struct get_app_version_s
{
	int		*maj;
	int		*min;
	int		*rel;
} get_app_version_s;

typedef struct get_schema_transactions_s
{
	char	(*buffer)[RIS_MAX_ID_SIZE];
	int		*countp;
} get_schema_transactions_s;

typedef struct get_language_name_s
{
	char	*name;
} get_language_name_s;

typedef struct get_ris_type_code_s
{
	int		*code;
	char	*str;
} get_ris_type_code_s;

typedef struct get_ris_type_string_s
{
	char	*str;
	int		code;
} get_ris_type_string_s;


typedef struct command_info_s
{
	int number;
	int type;
	int sqlcode;
	int command_time;
	int total_time;
} command_info_s;

typedef struct delay_info_s
{
	int delay_time;
	int total_time;
} delay_info_s;

typedef struct system_info_s
{
	char	*cmd;
} system_info_s;

/*
**	VARIABLES
*/
EXTERN int	action[3][3];
EXTERN char	*p;
EXTERN char	s[80];
EXTERN FILE	*in_fp;
EXTERN FILE	*out_fp;

EXTERN int	line			INIT(0);
EXTERN int	report_errors	INIT(1);
EXTERN char	*in_filename	INIT(NULL);
EXTERN char	*out_filename	INIT(NULL);

EXTERN int	fetch_blob_same_files	INIT(0);
EXTERN int	no_action				INIT(0);
EXTERN int	immediate_playback		INIT(0);
EXTERN int	compare_command_times	INIT(0);
EXTERN int	compare_delay_times		INIT(0);
EXTERN int	compare_total_times		INIT(0);
EXTERN int	verbose					INIT(0);
EXTERN int	version					INIT(0);

EXTERN clear_s						clear;
EXTERN clear_async_s				clear_async;
EXTERN close_s						clse;
EXTERN debug_s						debug;
EXTERN describe_s					describe;
EXTERN execute_imm_s				execute_imm;
EXTERN execute_s					execute;
EXTERN fetch_s						fetch;
EXTERN get_client_location_s		get_client_location;
EXTERN get_db_info_s				get_db_info;
EXTERN get_default_schname_s		get_default_schname;
EXTERN get_flags_s					get_flags;
EXTERN get_parameters_s				get_parameters;
EXTERN get_schema_file_s			get_schema_file;
EXTERN get_schema_file_location_s	get_schema_file_location;
EXTERN get_schema_info_s			get_schema_info;
EXTERN get_schema_names_s			get_schema_names;
EXTERN get_ss_def_s					get_ss_def;
EXTERN get_ss_names_s				get_ss_names;
EXTERN get_stmt_schname_s			get_stmt_schname;
EXTERN initialize_s					initialize;
EXTERN locate_client_s				locate_client;
EXTERN locate_schema_file_s			locate_schema_file;
EXTERN prepare_s					prepare;
EXTERN report_error_s				report_error;
EXTERN report_ss_error_s			report_ss_error;
EXTERN schema_mgr_s					schema_mgr;
EXTERN select_into_s				select_into;
EXTERN test_completion_s			test_completion;
EXTERN get_async_stmts_s			get_async_stmts;
EXTERN get_app_version_s			get_app_version;
EXTERN get_schema_transactions_s	get_schema_transactions;
EXTERN get_language_name_s			get_language_name;
EXTERN get_ris_type_code_s			get_ris_type_code;
EXTERN get_ris_type_string_s		get_ris_type_string;


/*
**	PROTOTYPES
*/

#endif
