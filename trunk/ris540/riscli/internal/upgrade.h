/*
**	NAME:							upgrade.h
**	AUTHORS:						David Michal
**	CREATION DATE:					6/27/90
**	ABSTRACT:
**		The include file for all upgrade utility source files.
**	
**	REVISION HISTORY:
**	 6/11/96 Ashley - increased structure size to handle longer file names
**			  also use RIS_MAX_NODE_SIZE instead of 30
*/

#ifdef UPGRADE_GLOBAL_DEFINE
#define UPGRADE_EXTERN
#else
#define UPGRADE_EXTERN extern
#endif
 
#include <stdio.h>
#include "rislimit.h"
#include "risstjmp.h"
#include "ris_err.h"
#include "ris_inf.h"
#include "risupg.h"
#ifdef WIN32
#include <direct.h>
#endif

/*
**      DEFINES
*/


#ifdef NO_UPG_DBG
#define UPG_DBG(s)
#else
#define UPG_DBG(s)      if (RISupg_debug) {RIScom_output_debug s;}
#endif

exec sql include "rislimit.h";

/*
**	Global Defines
*/
#define SUCCESS					 0
#define FAILURE					-1
#define SET_INTERRUPT()         RISupg_interrupt = 1
#define CLEAR_INTERRUPT()       RISupg_interrupt = 0
#define INTERRUPTED()           (RISupg_interrupt)

#define FORM_COL_PRIV           301 
#define FORM_GRANT_CLAUSE       302
#define FORM_INDEX_COL          303
#define FORM_INDEX_CLAUSE       304
#define FORM_ON_TO_CLAUSE       305
#define FORM_TAB_PRIV           306
#define	TABUNLOAD				0x00000001
#define	VIEWUNLOAD				0x00000002
#define	COLUNLOAD				0x00000004
#define	PRIVUNLOAD				0x00000008
#define	DROPSCHEMA				0x00000010
#define	CREATESCHEMA			0x00000020
#define	TABCREATE				0x00000100
#define	VIEWCREATE				0x00000200
#define	COLUPDATE				0x00000400
#define	PRIVCREATE				0x00000800
#define	LINE_BUFFER_SIZE	(RIS_MAX_DBPARMS_SIZE + 1)
#define USR						"USR="
#define USR_SIZE				(sizeof(USR) - 1)
#define USRPASS					"USRPASS="
#define USRPASS_SIZE			(sizeof(USRPASS) - 1)
#define UPG_LONGJMP(error)\
{\
	memset((char*)risca,0,sizeof(rissqlca));\
	memset((char*)dbca,0,sizeof(rissqlca));\
	LONGJMP(error);\
}

UPGRADE_EXTERN int	RISupg_debug;
UPGRADE_EXTERN debug_info_s RISupg_debug_info[]
#ifdef UPGRADE_GLOBAL_DEFINE
=
{
        { "upg", 3, &RISupg_debug }
}
#endif
;
UPGRADE_EXTERN     int RISupg_debug_count
#ifdef UPGRADE_GLOBAL_DEFINE
= sizeof(RISupg_debug_info)/sizeof(debug_info_s)
#endif
;

#if 0
exec sql define UPG_CREATE_SCHEMA_SIZE	1024;
#else
#define UPG_CREATE_SCHEMA_SIZE			1024
#endif

#if 0
exec sql define UPG_CHUNK_SIZE			512;
#else
#define UPG_CHUNK_SIZE					512
#endif

#if 0
exec sql define UPG_STRING_SIZE			81;
#else
#define UPG_STRING_SIZE					81
#endif


typedef struct access_struct
{
	char grantor[RIS_MAX_ID_SIZE];
	char *grant_stmt;
	int	 mark_as_done;
	struct access_struct * next;
} access_struct;

typedef struct objs_name_struct
{
	char objs_name[RIS_MAX_ID_SIZE];
	char tabtype;
	int  done;
} objs_name_struct;

typedef struct view_name_struct
{
	char view_name[RIS_MAX_ID_SIZE];
} view_name_struct;

typedef struct view_str_struct
{
	char view_name[RIS_MAX_ID_SIZE];
	char view_string[65];
	int	 seq_id;
	int  *done;
	struct view_str_struct *next;
} view_str_struct;

typedef struct RISupg_inf_struct
{
/* change from 50 bytes to RIS_MAX_PATH_SIZE */
	char sch_fil_name[RIS_MAX_PATH_SIZE];
	char new_sch_fil_name[RIS_MAX_PATH_SIZE];
	char sch_fil_prot;
	char sch_fil_address[RIS_MAX_NODE_SIZE];
	struct RISupg_sch_struct *sch_list;
	struct RISupg_inf_struct *next;
} risupg_inf_struct;

typedef struct RISupg_sch_struct
{
	char	sch_name[24];
	char	sch_passwd;
	int	tabunload;
	int	viewunload;
	int	colunload;
	int	grantunload;
	int drop_schema;
	int	cre_schema;
	int 	cre_tab;
	int 	cre_view;
	int 	upd_col;
	int 	cre_grant;
	struct RISupg_sch_struct *next;
} risupg_sch_info;

typedef struct COL_list
{
    char    tabname[RIS_MAX_ID_SIZE];
    char    colname[RIS_MAX_ID_SIZE];
    int     ristype;
    char    ristypestring[12];
    int     charmaxlen;
    int     prec;
    int     scale;
	int 	*done;
    struct COL_list *next;
} COL_list;

typedef struct dropped_sch_info
{
	char	sch_name[24];
	struct dropped_sch_info *next;
} dropped_sch_info;

typedef struct sch_db_map
{
    char    schname[24];
    int     dbid;
    int     dbtype;
    struct sch_db_map   *next;
}   schdbmap;

typedef struct db_info
{
    int     dbid;
    char    dbtype;
    struct db_info *next;
}   dbinfo;



		/*
		**	UPG SUB_SYSTEM GLOBALS
		*/

exec sql begin declare section;

	exec sql ifdef UPGRADE_GLOBAL_DEFINE;
		sqlda RISupg_out_desc;
	exec sql else;
	extern sqlda RISupg_out_desc;
exec sql endif;

exec sql end declare section;

UPGRADE_EXTERN int	upgrade_flag;
UPGRADE_EXTERN char	RIS_dir[RIS_MAX_PATH_SIZE];
UPGRADE_EXTERN char	RISupg_dict_file[RIS_MAX_PATH_SIZE];
UPGRADE_EXTERN char	RISupg_sql_stmt1[RIS_MAX_STMT_LEN];
UPGRADE_EXTERN char	RISupg_sql_stmt2[RIS_MAX_STMT_LEN];
UPGRADE_EXTERN FILE	*RISupg_fp;
UPGRADE_EXTERN FILE 	*RISupg_table_fp;
UPGRADE_EXTERN FILE 	*RISupg_view_fp;
UPGRADE_EXTERN FILE 	*RISupg_col_fp;
UPGRADE_EXTERN FILE 	*RISupg_priv_fp;
UPGRADE_EXTERN schema_file_parms	*file_parms;
UPGRADE_EXTERN risupg_inf_struct 	*risupg_inf_list;
UPGRADE_EXTERN risupg_sch_info 		*risupg_sch_list;
UPGRADE_EXTERN risupg_inf_struct 	*risupg_cur_file;
UPGRADE_EXTERN risupg_sch_info 		*risupg_cur_sch;
UPGRADE_EXTERN int 					RISupg_got_signal;
UPGRADE_EXTERN int 					RISupg_interrupt;
