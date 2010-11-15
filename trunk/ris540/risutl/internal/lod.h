/* Do not alter this SPC information: $Revision: 1.2.13.1 $ */
/*
**  NAME:                           lod.h
**  AUTHORS:                        Jennifer Xia
**  CREATION DATE:                  6/90
**  ABSTRACT:
**      This file contains common inclusion files, debug macros,
**      constances, structure definitions, global variable
**       definitions and external function declarations.
**
**  REVISION HISTORY:
**      Changes made by Hitesh Patel (May 1991)
*/

#ifndef LOD_H
#define LOD_H

#ifdef LOAD_GLOBAL_DEFINE
# define LOAD_EXTERN
#else
# define LOAD_EXTERN extern
#endif
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include "rislimit.h"
#include "risstjmp.h"

#ifdef MM
#include "lduld.h"
#endif
exec sql include "lduld.h";

/*
**	DEFINES
*/
#ifdef NO_LOD_DBG
#define LOD_DBG(s)
#else
#define LOD_DBG(s)	if (RISlod_debug) {RIScom_output_debug s;}
#endif

#define TERMINATE_RISLOAD \
{ \
	RISlod_remove_tmp_files(RISlodindx_tfpg,RISlodview_tfpg,RISlodgrant_tfpg); \
	RISlod_stop_timer(); \
    RISlod_print_msg(RIScom_umsg(RISUTL_E_RISLOAD_TERMINATE)); \
    LONGJMP(1); \
};

#define UNEXPECTED_EOF(lod_err_code) \
{ \
	RISlod_fatal_err_handler(lod_err_code,TRUE);\
	TERMINATE_RISLOAD \
};

#define CHK_OPEN_FILE_ERR(fp, lod_err_code) \
{ \
	if (fp == NULL) \
	{ \
		RISlod_fatal_err_handler(lod_err_code,FALSE);\
		TERMINATE_RISLOAD \
	} \
};

#define WRITING_FILE_ERR(lod_err_code) \
{ \
	RISlod_fatal_err_handler(lod_err_code,FALSE);\
	TERMINATE_RISLOAD \
};

#define CHK_MEM_ALLOC_ERR(mem_ptr) \
{ \
	if (mem_ptr == NULL) \
	{ \
		RISlod_fatal_err_handler(RISUTL_E_OUT_OF_MEMORY,FALSE);\
		TERMINATE_RISLOAD \
	}; \
};

#define LOD_WARNING_CHECK(sqlp) \
if (risca->sqlwarn[0] == 'W') \
{ \
	if (RISlod_mode == EMBED) \
	{ \
		strncpy(sqlp,risca->sqlwarn,8); \
	} \
	else \
	{ \
		RISuco_file_warning_box(stdout, risca->sqlwarn, 1);\
	} \
}

#define LOD_REPORT_ERROR(risp,dbp) \
if (risca->sqlwarn[0] == 'W') \
{ \
	if (RISlod_mode == EMBED) \
	{ \
		risp = risca->sqlcode; \
		dbp = dbca->sqlcode; \
	} \
	else \
	{ \
		RISlod_display_error(); \
	} \
}

/*
**	TYPES
*/
typedef struct dbs_type
{
	char		dbsname[RIS_MAX_KEYWORD_SIZE];
	struct dbs_type	*next;
} dbs_type;

typedef struct
{
	int schema;
	int table;
	int def_data;
	int exist_tab;
	int clear_tab;
	int index;
	int view;
	int grant;
} which_to_load_type;

typedef struct
{
	char		col_name[RIS_MAX_ID_SIZE];
	int			start;
	int			end;
	short int	col_type;
	short int	format;
} field_type;

typedef struct indx_node_type
{
	char					indx_name[RIS_MAX_ID_SIZE];
	char					indx_tab[RIS_MAX_ID_SIZE];
	long					offset;
	int						processed;
	int						no_of_indxs;
	int						indxsdonewith;
	long					lnd_err_code;
	long					ris_err_code;
	long					db_err_code;
	char					sqlwarnings[8];
	struct indx_node_type	*link;
} indx_node_type;

typedef struct view_node_type
{
	char					view_name[RIS_MAX_ID_SIZE];
	long					offset;
	struct view_node_type	*link;
} view_node_type;

typedef struct grant_node_type
{
	char					rel_spec[2 * RIS_MAX_ID_SIZE];
	long					offset;
	int						processed;
	int						mark;		/* EMBED */
	int						no_of_privs;	
	int						privsdonewith;
	long					lnd_err_code;
	long					ris_err_code;
	long					db_err_code;
	char					sqlwarnings[8];
	struct grant_node_type	*nlink;
} grant_node_type;

typedef struct grant_hnode_type
{
	char					sch_name[RIS_MAX_ID_SIZE];
	char					sch_pwd[RIS_MAX_ID_SIZE];
	char					new_sch_name[RIS_MAX_ID_SIZE];
	char					new_sch_pwd[RIS_MAX_ID_SIZE];
	grant_node_type			*nlink;
	struct grant_hnode_type	*hlink;
} grant_hnode_type;

typedef struct lod_what_indx_type
{
	char						indx_tab[RIS_MAX_ID_SIZE];
	char						lod_or_dmp;
	struct lod_what_indx_type	*link;
} lod_what_indx_type;

typedef struct lod_what_grant_type
{
	char						rel_spec[2 * RIS_MAX_ID_SIZE];
	char						lod_or_dmp;
	struct lod_what_grant_type	*link;
} lod_what_grant_type;

typedef struct batch_tnode_type
{
	char					tab_name[RIS_MAX_ID_SIZE];
	int						totalrows;
	int						rowsdonewith;
	long					lnd_err_code;
	long					ris_err_code;
	long					db_err_code;
	char					sqlwarnings[8];
	struct batch_tnode_type	*btlink;
} batch_tnode_type;

typedef struct
{
	int					tab_select;
	int					def_data_select;
	int					exist_tab_select;
	int					clear_tab_select;
	batch_tnode_type 	*btlink;
} batch_thnode_type;

typedef struct batch_inode_type
{
	char					indx_tab[RIS_MAX_ID_SIZE];
	struct batch_inode_type	*bilink;
} batch_inode_type;

typedef struct 
{
	int					indx_select;
	batch_inode_type 	*bilink;
} batch_ihnode_type;

typedef struct batch_vnode_type
{
	char					view_name[RIS_MAX_ID_SIZE];
	long					lnd_err_code;
	long					ris_err_code;
	long					db_err_code;
	char					sqlwarnings[8];
	struct batch_vnode_type	*bvlink;
} batch_vnode_type;

typedef struct
{
	int					view_select;
	batch_vnode_type 	*bvlink;
} batch_vhnode_type;

typedef struct batch_gnode_type
{
	char					rel_spec[2 * RIS_MAX_ID_SIZE];
	struct batch_gnode_type	*bglink;
} batch_gnode_type;

typedef struct
{
	int					grant_select;
	batch_gnode_type 	*bglink;
} batch_ghnode_type;

typedef struct batch_snode_type
{
	char		sch_name[RIS_MAX_ID_SIZE];
	short int	num_sch_pwd;
	short int	num_relations; /*num pwds which are not schema pwds*/
	char			sch_pwd_matrix[MAX_NUM_PWD][RIS_MAX_ID_SIZE];
	char	user_name[RIS_MAX_ID_SIZE]; /* for DECLARE SCHEMA, secure sch */
	char	db_name[RIS_MAX_ID_SIZE]; /* for DECLARE SCHEMA, when stmt in */
					/* file is DEFAULT SCHEMA */
	char					new_sch_name[RIS_MAX_ID_SIZE];
	char					new_sch_pwd[RIS_MAX_ID_SIZE];
	char					new_user_name[RIS_MAX_ID_SIZE];
	char					new_user_pwd[RIS_MAX_ID_SIZE];
	struct batch_snode_type	*bslink;
	batch_thnode_type		*bthlink;
	batch_ihnode_type		*bihlink;
	batch_vhnode_type		*bvhlink;
	batch_ghnode_type		*bghlink;
	long					lnd_err_code;
	long					ris_err_code;
	long					db_err_code;
	char					sqlwarnings[8];
	short int				processed; /* Set to 1 when done with schema */
} batch_snode_type;

typedef struct
{
	batch_snode_type	*bshnode_ptr;
	batch_snode_type	*bsnode_ptr;
	batch_thnode_type	*bthnode_ptr;
	batch_tnode_type	*btnode_ptr;
	batch_ihnode_type	*bihnode_ptr;
	batch_inode_type	*binode_ptr;
	batch_vhnode_type	*bvhnode_ptr;
	batch_vnode_type	*bvnode_ptr;
	batch_ghnode_type	*bghnode_ptr;
	batch_gnode_type	*bgnode_ptr;
} ptr_struct_type;

/*
**	VARIABLES
*/
LOAD_EXTERN  int	RISlod_debug;

exec sql begin declare section;

exec sql ifdef LOAD_GLOBAL_DEFINE;
	char RISlod_sql_stmt[SQL_MAX_STMT_LEN];
exec sql else;
	extern char	RISlod_sql_stmt[SQL_MAX_STMT_LEN];
exec sql endif;

/* used to store each line of statement from ASCII files.  Data rows are stored
   at RISlod_sql_stmt+1 while all other stmts are at RISlod_sql_stmt */

exec sql ifdef LOAD_GLOBAL_DEFINE;
	sqlda RISlod_in_desc;
exec sql else;
	extern sqlda RISlod_in_desc;
exec sql endif;

/* used in describing insert into statement */

exec sql end declare section;

LOAD_EXTERN  short int	RISlod_err_fnd_in_sch;
/* used together with sch_name in function RISlod_dump_to_log in deciding
   whether to print the following in log file: For schema __, the following were
   not loaded: */

LOAD_EXTERN  short int	RISlod_err_fnd_in_tab;
/* used together with tab_name in function RISlod_dump_to_log in deciding
   whether to print the following in log file: For table __, the following were
   not loaded: */

LOAD_EXTERN  char			RISlod_default_sch_stmt[50];

LOAD_EXTERN  int				RISlod_global_err_ind;
LOAD_EXTERN  int				RISlod_mode;
LOAD_EXTERN  char			RISlod_delimiter;
LOAD_EXTERN  int				RISlod_commit_interval;

LOAD_EXTERN  long			*RISlod_general_err;
LOAD_EXTERN  char			*RISlod_general_warn;

LOAD_EXTERN  char			RISlod_filemode;
LOAD_EXTERN  char			RISlod_mfile[RIS_MAX_PATH_SIZE];
LOAD_EXTERN  char			RISlod_lfile[RIS_MAX_PATH_SIZE];
LOAD_EXTERN  char			RISlod_bfile[RIS_MAX_PATH_SIZE];
LOAD_EXTERN  char			RISlod_sfile[RIS_MAX_PATH_SIZE];

LOAD_EXTERN  FILE			*RISlod_in_fp;
LOAD_EXTERN  FILE			*RISlod_log_fp;
LOAD_EXTERN  FILE			*RISlod_bad_fp;
LOAD_EXTERN  FILE			*RISlod_spec_fp;

LOAD_EXTERN  long			RISlod_current_stmt_spot;
LOAD_EXTERN  long			RISlod_create_stmt_spot;
LOAD_EXTERN  long			RISlod_insert_stmt_spot;
LOAD_EXTERN  long			RISlod_field_stmt_spot;

LOAD_EXTERN  char			RISlod_indx_tfname[RIS_MAX_PATH_SIZE];
LOAD_EXTERN  char			RISlod_view_tfname[RIS_MAX_PATH_SIZE];
LOAD_EXTERN  char			RISlod_grant_tfname[RIS_MAX_PATH_SIZE];

LOAD_EXTERN  FILE			*RISlodindx_tfpg;
LOAD_EXTERN  FILE			*RISlodview_tfpg;
LOAD_EXTERN  FILE			*RISlodgrant_tfpg;

LOAD_EXTERN  int			RISlod_tab_loaded;
LOAD_EXTERN  int			RISlod_indx_loaded;
LOAD_EXTERN  int			RISlod_view_loaded;
LOAD_EXTERN  int			RISlod_grant_loaded;

LOAD_EXTERN  char			RISlod_err_buf[RIS_MAX_ERROR_MSG]; /* remove */
LOAD_EXTERN  long			RISlod_gen_err; /* remove */
/* general errors such as not enough memory, cannot open file ... */

LOAD_EXTERN  ptr_struct_type	*RISlod_ptr_struct_ptr; /* this is now global */

LOAD_EXTERN debug_info_s RISlod_debug_info[]
#ifdef LOAD_GLOBAL_DEFINE
=
{
	{ "lod", 3, &RISlod_debug }
}
#endif
;
LOAD_EXTERN	 int RISlod_debug_count
#ifdef LOAD_GLOBAL_DEFINE
= sizeof(RISlod_debug_info)/sizeof(debug_info_s)
#endif
;

#endif
