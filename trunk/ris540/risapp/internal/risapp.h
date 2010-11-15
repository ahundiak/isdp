/* Do not alter this SPC information: $Revision: 1.2.38.1 $ */
/*
**	NAME:							RISapp.h
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

#ifndef RISAPP_H
#define RISAPP_H

#ifdef APP_GLOBAL_DEFINE
# define APP_EXTERN
# define APP_INIT(value) = value
#else
# define APP_EXTERN extern
# define APP_INIT(value)
#endif
 
/*
**	INCLUDES
*/
#include "net.h"
#include "arch.h"
#include "ris.h"
#include "rislimit.h"
#include "risap_cl.h"
#include "rislang.h"

/*
**	DEFINES
*/

/* Modes for RISapp_process_parms() */
#define OUTPUT	0
#define INPUT	1

/* Modes for RISapp_get_schfile */
#define USE_ALLOCB	0
#define USE_MALLOC	1

/*
**	TYPES
*/
typedef struct ris_app_stmt
{
	char			*query;
	int				input_len;
	int				output_len;
	int				fetch_buf_size;
	int				write_buf_size;
	struct sqlda	*input;
	struct sqlda	*output;
	int				tab_count;
	char			(*tab_list)[RIS_MAX_ID_SIZE];
	ris_cliapp_buf 	*fetch_buf;
	int				row_count;
	int				end_of_data;
	char			*row;
	char			prep_def_schname[RIS_MAX_ID_SIZE];	/* the default schema */
														/* at  prepare time   */
	char			schname[RIS_MAX_ID_SIZE];	/* the schema the stmt */
												/* accesses            */
	char			stmt_type;
	unsigned int	timestamp;
	short			*stmt_id_addr;	/* the address of the variable containing */
	struct risasync	*async;
} ris_app_stmt;

typedef struct risasync
{
	int				async_id;
	short			stmt_id;
	ris_app_stmt	*stmt;
	int				state;
	union
	{
		struct
		{
			struct sqlda	*in_sqlda;
			int				clear_flag;
			int				static_flag;
		} execute;
		struct
		{
			int				one_row_only;
			struct sqlda	*output;
		} fetch;
		struct
		{
			short			*stmt_idp;
		} clear;
		struct
		{
			short			*stmt_idp;
			struct sqlda	*in_sqlda;
			int				clear_flag;
			int				static_flag;
		} execute_imm;
		struct
		{
			short			*stmt_idp;
			struct sqlda	*in_sqlda;
			struct sqlda	*out_sqlda;
		} select_into;
	} args;
    struct rissqlca     risca;
    struct rissqlca     dbca;
	char				*rissqlstmt;
	char				*dbsqlstmt;
} risasync;

/*
**	New Client process parms
*/
typedef struct ris_app_client_parms_s
{
    char			protocol;
    char			address[RIS_MAX_NODE_SIZE];
    char			username[RIS_MAX_ID_SIZE];
    char			password[RIS_MAX_PASSWD_SIZE];
	short			major;
	short			feature;
} ris_app_client_parms_s;

/*
**	VARIABLES
*/
APP_EXTERN	 int						RIS_upgrade_parms_file APP_INIT(0);
APP_EXTERN	 int						RIS_lang_code_used APP_INIT(-1);

APP_EXTERN	 int						RIS_client_died;
APP_EXTERN	 int						RIS_test_completion_flag;
APP_EXTERN	 char					RIS_def_schname[RIS_MAX_ID_SIZE];
APP_EXTERN	 char					RIS_parms_filename[RIS_MAX_PATH_SIZE];

APP_EXTERN	 ris_app_client_parms_s	RIS_client_parms;
APP_EXTERN	 ris_schfile_parms_s		RIS_schfile_parms;

APP_EXTERN	 char					RIS_risstmt[RIS_MAX_STMT_LEN];
APP_EXTERN	 char					RIS_dbstmt[RIS_MAX_STMT_LEN];

APP_EXTERN	 ris_app_stmt			*RIS_stmt;
APP_EXTERN	 ris_app_stmt			**RIS_stmts;
APP_EXTERN	 int						RIS_static_stmt_cnt;
APP_EXTERN	 risasync				*RIS_async;
APP_EXTERN	 risasync				*RIS_asyncs[RIS_MAX_TRANSACTIONS];

APP_EXTERN	 net_s					*RIS_net;
APP_EXTERN	 arc_s					*RIS_arc;
APP_EXTERN	 int						RIS_net_finish_mode APP_INIT(DEALLOCATE);
APP_EXTERN	 int						RIS_write_len;
APP_EXTERN	 int						RIS_read_len;
APP_EXTERN	 int						RIS_write_size;
APP_EXTERN	 int						RIS_read_size;
APP_EXTERN	 ris_appcli_buf			*RIS_write;
APP_EXTERN	 ris_cliapp_buf			*RIS_read;

APP_EXTERN	 int						RIS_save_write_size;
APP_EXTERN	 int						RIS_save_read_size;
APP_EXTERN	 ris_appcli_buf			*RIS_save_write;
APP_EXTERN	 ris_cliapp_buf			*RIS_save_read;

APP_EXTERN	rissqlca	RIS_risca
#ifdef APP_GLOBAL_DEFINE
= {"",0,0,{"",0,0},"",{0,0,0,0,0,0,0,0},"","",RIS_risstmt}
#endif
;

APP_EXTERN	rissqlca				RIS_dbca
#ifdef APP_GLOBAL_DEFINE
= {"",0,0,{"",0,0},"",{0,0,0,0,0,0,0,0},"","",RIS_dbstmt}
#endif
;

APP_EXTERN	 ris_superschema_error_info	RISsuperschema_error;/* internal only */

APP_EXTERN  char 				RIS_app_version[12]; /* XX.XX.XX.XX\0 */ 
APP_EXTERN  int 					RIS_app_version_maj APP_INIT(0);
APP_EXTERN  int 					RIS_app_version_min APP_INIT(0);
APP_EXTERN  int 					RIS_app_version_rel APP_INIT(0);
APP_EXTERN  int     RIS_license_bypass APP_INIT(0);         /* internal only */

/* Variables available to applications */
APP_EXTERN	 int							SQLCODE;
APP_EXTERN	 int							superschema_warning;
APP_EXTERN	rissqlca					*risca		APP_INIT(&RIS_risca);
APP_EXTERN	rissqlca					*dbca		APP_INIT(&RIS_dbca);
APP_EXTERN	ris_superschema_error_info	*superschema_error APP_INIT(&RISsuperschema_error);

#endif /* RISAPP_H */
