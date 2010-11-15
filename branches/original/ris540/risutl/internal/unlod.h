/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**  NAME:                           unlod.h
**  AUTHORS:                        Jennifer Xia
**  CREATION DATE:                  9/90
**  ABSTRACT:
**      It contains common inclusion files, debug macros, constances, structure
**      definitions, global variable definitions and external function
**      declarations.
**
**  REVISION HISTORY: for where_clause (Hitesh Patel)
*/
 
#ifndef UNLOD_H
#define UNLOD_H

#ifdef UNLOAD_GLOBAL_DEFINE
# define UNLOAD_EXTERN
#else
# define UNLOAD_EXTERN extern
#endif

/*
**	INCLUDES
*/
#include <stdio.h>
#include "risstjmp.h"

#ifdef MM
#include "lduld.h"
#endif
exec sql include "lduld.h";

#ifdef MM
#include "rislimit.h"
#endif
exec sql include "rislimit.h";


/*
**	DEFINES
*/
#ifdef NO_ULD_DBG
# define ULD_DBG(s)
#else
# define ULD_DBG(s)	if (RISuld_debug) { RIScom_output_debug s;}
#endif

#define TERMINATE_RISUNLOAD	\
{ \
	RISuld_stop_timer();\
	RISuld_print_msg(RIScom_umsg(RISUTL_E_RISUNLOAD_TERMINATE)); \
	LONGJMP(1); \
};

#define CHK_OPEN_FILE_ERR(fp, nld_err_code) \
{ \
    if (fp == NULL) \
    { \
		RISuld_fatal_err_handler(nld_err_code);\
        TERMINATE_RISUNLOAD \
    } \
};


#define WRITING_FILE_ERR(nld_err_code) \
{ \
	RISuld_fatal_err_handler(nld_err_code);\
	TERMINATE_RISUNLOAD \
};


#define CHK_MEM_ALLOC_ERR(mem_ptr) \
{ \
	if (mem_ptr == NULL) \
	{ \
		RISuld_fatal_err_handler(RISUTL_E_OUT_OF_MEMORY);\
		TERMINATE_RISUNLOAD \
	}\
};

#define UNLOD_WARNING_CHECK(sqlp) \
if (risca->sqlwarn[0] == 'W') \
{ \
	if (RISuld_mode == EMBED) \
	{ \
		strncpy(sqlp,risca->sqlwarn,8); \
	} \
	else \
	{ \
		RISuco_file_warning_box(stdout, risca->sqlwarn, 1); \
	} \
}

#define UNLOD_REPORT_ERROR(risp,dbp) \
if (risca->sqlwarn[0] == 'W') \
{ \
	if (RISuld_mode == EMBED) \
	{ \
		risp = risca->sqlcode; \
		dbp = dbca->sqlcode; \
	} \
	else \
	{ \
		RISuld_display_error(); \
	} \
}


/*
**	TYPES
*/
typedef struct
{
	int	table;		/* a,p,e or n */
	int	def_data;	/* b or o */
	int	dfile;		/* s or d */
	int	declare_tab;	/* y or n */
	int format;
	int	index;
	int	view;
	int	declare_view;	/* y or n */
	int	grant;
} which_to_nld_type; 

typedef struct
{
	char	sch_name[RIS_MAX_ID_SIZE];
	char	sch_pwd[RIS_MAX_ID_SIZE];
	long	sch_pwd_ind;
	char	os_name[RIS_MAX_ID_SIZE];
	char	os_pwd[RIS_MAX_ID_SIZE];
	char	db_name[RIS_MAX_ID_SIZE];
	char	db_pwd[RIS_MAX_ID_SIZE];
	long	slnd_err_code;
	long	sris_err_code;
	long	sdb_err_code;
	char	ssqlwarnings[8];
	long	tlnd_err_code;
	long	tris_err_code;
	long	tdb_err_code;
	char	tsqlwarnings[8];
	long	vlnd_err_code;
	long	vris_err_code;
	long	vdb_err_code;
	char	vsqlwarnings[8];
	long	ilnd_err_code;
	long	iris_err_code;
	long	idb_err_code;
	char	isqlwarnings[8];
	long	plnd_err_code;
	long	pris_err_code;
	long	pdb_err_code;
	char	psqlwarnings[8];
} sch_node_type;

typedef struct
{
	char		tab_name[RIS_MAX_ID_SIZE];
	char		*where_clause_ptr;		/* for where_clause */	
	char		datafile[RIS_MAX_PATH_SIZE];
	int			rowsdonewith;
	int			err_row;
	short int	unloaded;
	long		lnd_err_code;
	long		ris_err_code;
	long		db_err_code;
	char		sqlwarnings[8];
} tab_node_type;

typedef struct
{
	char		indx_name[RIS_MAX_ID_SIZE];
	char		indx_tab[RIS_MAX_ID_SIZE];
	int			total_indx;
	int			indx_unloaded;
	int			processed;
	long		lnd_err_code;
	long		ris_err_code;
	long		db_err_code;
	char		sqlwarnings[8];
} indx_node_type;

typedef struct
{
	char		view_name[RIS_MAX_ID_SIZE];
	short int	unloaded;
	long		lnd_err_code;
	long		ris_err_code;
	long		db_err_code;
	char		sqlwarnings[8];
} view_node_type;

typedef struct
{
	char	original_gtor[RIS_MAX_ID_SIZE];
	char	rel_name[RIS_MAX_ID_SIZE];
	int		total_priv;		/* for EMBED */
	int		priv_unloaded;	/* for EMBED */
	int		mark;			/* for EMBED */
	long	lnd_err_code;
	long	ris_err_code;
	long	db_err_code;
	char	sqlwarnings[8];
} grant_node_type;

typedef struct batch_tnode_type
{
	tab_node_type			*tnode_ptr;
	struct batch_tnode_type	*btlink;
} batch_tnode_type;

typedef struct
{
	int					tab_select;
	int					def_data_select;
	int					dfile_select;
	int					declare_select;
	int					format_select;
	batch_tnode_type 	*btlink;
} batch_thnode_type;

typedef struct batch_inode_type
{
	indx_node_type			*inode_ptr;
	struct batch_inode_type	*bilink;
} batch_inode_type; 

typedef struct
{
	int					indx_select;
	batch_inode_type 	*bilink;
} batch_ihnode_type;

typedef struct batch_vnode_type
{
	view_node_type			*vnode_ptr;
	struct batch_vnode_type	*bvlink;
} batch_vnode_type;

typedef struct
{
	int					view_select;
	int					declare_select;
	batch_vnode_type 	*bvlink;
} batch_vhnode_type;

typedef struct batch_gnode_type
{
	grant_node_type			*gnode_ptr;
	struct batch_gnode_type	*bglink;
} batch_gnode_type;

typedef struct
{
	char				grant_select;
	batch_gnode_type 	*bglink;
} batch_ghnode_type;

typedef struct batch_snode_type
{
	sch_node_type			*snode_ptr;
	struct batch_snode_type	*bslink;
	batch_thnode_type		*bthlink;
	batch_ihnode_type		*bihlink;
	batch_vhnode_type		*bvhlink;
	batch_ghnode_type		*bghlink;
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
	
typedef struct grantee_s
{
	char				gteename[RIS_MAX_ID_SIZE];
	int					without_grant_option;
	int					with_grant_option;
	struct grantee_s	*next;
} grantee_s;

/*
**	VARIABLES
*/

exec sql begin declare section;

exec sql ifdef UNLOAD_GLOBAL_DEFINE;
	sqlda RISuld_out_desc;
	sqlda RISuld_out_desc1;
	sqlda RISuld_out_desc2;
exec sql else;
	extern sqlda RISuld_out_desc;
	extern sqlda RISuld_out_desc1;
	extern sqlda RISuld_out_desc2;
exec sql endif;

exec sql end declare section;


UNLOAD_EXTERN  int	RISuld_debug;
UNLOAD_EXTERN  int	RISuld_mode;

UNLOAD_EXTERN  long	*RISuld_general_err;
UNLOAD_EXTERN  char	*RISuld_general_warn;

UNLOAD_EXTERN  char RISuld_filemode;
UNLOAD_EXTERN  char RISuld_mfile[RIS_MAX_PATH_SIZE];
UNLOAD_EXTERN  char RISuld_sfile[RIS_MAX_PATH_SIZE];

UNLOAD_EXTERN  FILE *RISuld_out_fp;
UNLOAD_EXTERN  FILE *RISuld_spec_fp;

UNLOAD_EXTERN  char	RISuld_sql_stmt1[SQL_MAX_STMT_LEN];
UNLOAD_EXTERN  char	RISuld_sql_stmt2[SQL_MAX_STMT_LEN];

UNLOAD_EXTERN  int	RISuld_tab_unload;
UNLOAD_EXTERN  int	RISuld_indx_unload;
UNLOAD_EXTERN  int	RISuld_view_unload;
UNLOAD_EXTERN  int	RISuld_priv_unload;

UNLOAD_EXTERN  ptr_struct_type	*RISuld_ptr_struct_ptr;

UNLOAD_EXTERN debug_info_s RISuld_debug_info[]
#ifdef UNLOAD_GLOBAL_DEFINE
=
{
	{ "uld", 3, &RISuld_debug }
}
#endif
;

UNLOAD_EXTERN	 int RISuld_debug_count
#ifdef UNLOAD_GLOBAL_DEFINE
= sizeof(RISuld_debug_info)/sizeof(debug_info_s)
#endif
;

#endif
