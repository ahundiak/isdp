/* Do not alter this SPC information: $Revision: 1.2.37.1 $ */
/*
**	NAME:							riscli.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
#ifndef RISCLI_H
#define RISCLI_H

#ifdef CLI_GLOBAL_DEFINE
# define CLI_EXTERN
# define CLI_INIT(value) = value
#else
# define CLI_EXTERN extern
# define CLI_INIT(value)
#endif

/*
**	INCLUDES
*/
#include "risap_cl.h"
#include "riscl_sr.h"
#include "riscl_pa.h"
#include "rislimit.h"
#include "net.h"

/*
**	DEFINES
*/

/* look-up masks */
#define HASH_TABLE		0x1
#define SCHEMA_FILE		0x2

/* Mode values for RISusr_kill_srv() */
#define CLOSE_SCHEMA	0x1
#define CLEAR_SCHEMA	0x2
#define CLOSE_NET		0x4

/* Copy declare schema flags */
#define SCHPASS_FLAG  0x00000001
#define OSUSRPD_FLAG  0x00000002
#define SCHUSPD_FLAG  0x00000004

/* Copy schema flags */
#define SCHNAME_FLAG	0x00000001
#define SCHOWNER_FLAG	0x00000002
#define SCHOWNPASS_FLAG	0x00000004
#define GRANTEE_FLAG	0x00000008
#define SCHDBID_FLAG	0x00000010
#define SECURE_FLAG		0x00000020
#define DICTOWNER_FLAG	0x00000040
#define DEFAULT_USER_FLAG	0x00000060
#define VERSION_FLAG	0x00000080

/* Copy database flags */
#define DBID_FLAG		0x00000001
#define DTYPE_FLAG		0x00000002
#define DBNAME_FLAG		0x00000004
#define PARMS_FLAG		0x00000008
#define PROTADDR_FLAG	0x00000010
#define OSTYPE_FLAG		0x00000020
#define ALL_FLAG		0xFFFFFFFF

/* Superschema related flags */
#define REGULAR_SCHEMA   0
#define PRIMARY_SCHEMA   1
#define SECONDARY_SCHEMA 2
#define SUPER_SCHEMA     3

#define IS_SERVER_DEAD(status)  \
				(status == RIS_E_SCHEMA_RESTARTED || \
				status == RIS_E_SERVER_RESTARTED || \
				status == RIS_E_DEFAULT_SCHEMA_DIED || \
				status == RIS_E_SERVER_DIED || \
				status == RIS_E_SCHEMA_DIED || \
				status == RIS_E_SERVER_NOT_RESPONDING)

/* define the network protocol for DB2 */
#define PROTOCOL_DEF_TCP		"tcp"
#define PROTOCOL_DEF_LU			"lu6.2"

/* return sts for RIScco_compare_dbs */
#define SAME_DATABASE	0
#define DIFF_DATABASE	1
#define NOT_ALL_PARMS	0
#define ALL_PARMS		1

/*
**	TYPES
*/
typedef struct ris_acc_link_list_node
{
	struct risaccess    *racc;
	struct ris_acc_link_list_node *next;
} ris_acc_link_list_node;

typedef struct ristablist
{
    struct  ristab      *tab;
    struct  ristablist  *next;
} ristablist;

typedef struct risstmt
{
	struct ristree			*tree;
	struct rissql			*sql;
    struct ristablist       *tablist;
	struct ris_srvcli_buf	*fetch_buf;
	char					*query;
	char					*view_string;
	unsigned int			row_len;
	unsigned int			write_buf_size;
	unsigned int			read_buf_size;
	unsigned int			fetch_buf_size;
	struct
	{
		char				risdbs;
		char				risschemas;
	} flags;
    short         			stmt_id;
    short         			old_stmt_id;
    short         			primary_id;
    int                     *user_id;
    struct risstmt 			*next;
	char					prep_def_schname[RIS_MAX_ID_SIZE];
	char					swap_n_clear_flag;
} risstmt;

typedef struct risschmem
{
	char		schname[RIS_MAX_ID_SIZE];
	ristab		*free_ristab;
	risattr		*free_risattr;
	risaccess	*free_risaccess;
	int			ristab_cnt;
	int			risattr_cnt;
	int			risaccess_cnt;
} risschmem;

typedef struct rispermmem
{
	struct risdb			*free_risdb;
	struct risuser			*free_risuser;
	struct risdclrschema	*free_risdclrschema;
	struct risschema		*free_risschema;
	struct hashnode			*free_hashnode;
	struct ristablist		*free_ristablist;
	struct net_s			*free_net_s;
	int						risdb_cnt;
	int						risuser_cnt;
	int						risdclrschema_cnt;
	int						risschema_cnt;
	int						hashnode_cnt;
	int						ristablist_cnt;
	int						net_s_cnt;
} rispermmem;

typedef struct risschname_list
{
	char					schname[RIS_MAX_ID_SIZE];
	struct risschname_list	*next;
} risschname_list;

/*
**	VARIABLES
*/
CLI_EXTERN net_s			*RIS_app_net;
CLI_EXTERN arc_s			*RIS_app_arc;
CLI_EXTERN ris_appcli_buf	*RIS_app_read;
CLI_EXTERN int				RIS_app_read_len;
CLI_EXTERN int				RIS_app_read_size;
CLI_EXTERN ris_cliapp_buf	*RIS_app_write;
CLI_EXTERN int				RIS_app_write_len;
CLI_EXTERN int				RIS_app_write_size;

CLI_EXTERN ris_srvcli_buf	*RIS_srv_read;
CLI_EXTERN int				RIS_srv_read_len;
CLI_EXTERN int				RIS_srv_read_size;
CLI_EXTERN ris_clisrv_buf	*RIS_srv_write;
CLI_EXTERN int				RIS_srv_write_len;
CLI_EXTERN int				RIS_srv_write_size;

CLI_EXTERN ris_srvcli_buf	*RIS_save_srv_read;
CLI_EXTERN int				RIS_save_srv_read_size;
CLI_EXTERN ris_clisrv_buf	*RIS_save_srv_write;
CLI_EXTERN int				RIS_save_srv_write_size;

CLI_EXTERN rissqlca			RIS_risca;		/* Later this will be an array */
CLI_EXTERN rissqlca			RIS_dbca;		/* Later this will be an array */
CLI_EXTERN rissqlca			*risca CLI_INIT(&RIS_risca);
CLI_EXTERN rissqlca			*dbca CLI_INIT(&RIS_dbca);

CLI_EXTERN rissql			*RIS_sdp;
CLI_EXTERN risstmt			*RIS_stmt;
CLI_EXTERN risstmt			*RIS_stmts[RIS_MAX_STMTS];
CLI_EXTERN risschema		*RIS_default;
CLI_EXTERN risschema		*RIS_srvs;
CLI_EXTERN risschema		*RIS_deadbeat_srvs;
CLI_EXTERN rissuperschema   *RIS_super_schema;
CLI_EXTERN risdclrschema    *RIS_declare_schema CLI_INIT(0);

CLI_EXTERN char				RIS_risstmt[RIS_MAX_STMT_LEN];
CLI_EXTERN char				RIS_dbstmt[RIS_MAX_STMT_LEN];

CLI_EXTERN int				RIS_autocommit CLI_INIT(1);
CLI_EXTERN int         		RIS_autorename_mode CLI_INIT(1);
CLI_EXTERN int				RIS_ansi_mode CLI_INIT(1);
CLI_EXTERN int				RIS_verify_mode CLI_INIT(1);
CLI_EXTERN int				RIS_blankstrip_mode CLI_INIT(1);
CLI_EXTERN unsigned int		RIS_enable_dbms CLI_INIT(RIS_ENABLE_ALL);

CLI_EXTERN int				RIS_max_id_size CLI_INIT(18);
CLI_EXTERN int				RIS_ris5dbs_flag;
CLI_EXTERN int				RIS_ris5schemas_flag;
CLI_EXTERN int				RIS_ris5dict_flag;
CLI_EXTERN int				RIS_killing_srv_pid;
CLI_EXTERN int				RIS_dict_select_flag;
CLI_EXTERN int				RIS_test_completion_flag;
CLI_EXTERN char				RIS_warning_flag CLI_INIT(0);

CLI_EXTERN rispermmem		RIS_permmem;
CLI_EXTERN risschmem		RIS_schmem[RIS_MAX_OPEN_SCHEMAS];
CLI_EXTERN rissuperschema	*RIS_ssmem[RIS_MAX_OPEN_SUPERSCHEMAS];
CLI_EXTERN int                  RIS_cli_license_bypass CLI_INIT(0);

#endif
