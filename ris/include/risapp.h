/*
** Copyright 1993, Intergraph Corporation, All Rights Reserved
*/
#ifndef RISAPP_H
#define RISAPP_H

#ifdef APP_GLOBAL_DEFINE
#define APP_EXTERN
#define APP_INIT(value) = value
#else
#define APP_EXTERN extern
#define APP_INIT(value)
#endif

#include "ris.h"
#include "rislimit.h"
#include "risap_cl.h"
#include "risnet.h"
#include "risarch.h"

#include "risapi.h"
#include "rislang.h"
#include "risstjmp.h"
#include "risdebug.h"
#include "ris_err.h"

#include "risapp_app.h"
#include "risapp_rap.h"
#include "risapp_interface.h"

/* Modes for RISapp_process_parms() */
#define OUTPUT  0
#define INPUT   1

/* Modes for RISapp_get_schfile */
#define USE_ALLOCB      0
#define USE_MALLOC      1

#define VALID_PROTOCOL(p) ((p) == 'M' || (p) == 'X' || (p) == 'T' || (p) == 'D')

/*
**      TYPES
*/
typedef struct ris_app_stmt
{
        char                    *query;
        int                             input_len;
        int                             output_len;
        int                             fetch_buf_size;
        int                             write_buf_size;
        struct sqlda    *input;
        struct sqlda    *output;
        int                             tab_count;
        char                    (*tab_list)[RIS_MAX_ID_SIZE];
        ris_cliapp_buf  *fetch_buf;
        int                             row_count;
        int                             end_of_data;
        char                    *row;
        char                    prep_def_schname[RIS_MAX_ID_SIZE];      /* the default schema */
                                                                                                                /* at  prepare time   */
        char                    schname[RIS_MAX_ID_SIZE];       /* the schema the stmt */
                                                                                                /* accesses            */
        char                    stmt_type;
        unsigned int    timestamp;
        short                   *stmt_id_addr;  /* the address of the variable containing */
        struct risasync *async;
} ris_app_stmt;

typedef struct risasync
{
        int                             async_id;
        short                   stmt_id;
        ris_app_stmt    *stmt;
        int                             state;
        union
        {
                struct
                {
                        struct sqlda    *in_sqlda;
                        int                             clear_flag;
                        int                             static_flag;
                } execute;
                struct
                {
                        int                             one_row_only;
                        struct sqlda    *output;
                } fetch;
                struct
                {
                        short                   *stmt_idp;
                } clear;
                struct
                {
                        short                   *stmt_idp;
                        struct sqlda    *in_sqlda;
                        int                             clear_flag;
                        int                             static_flag;
                } execute_imm;
                struct
                {
                        short                   *stmt_idp;
                        struct sqlda    *in_sqlda;
                        struct sqlda    *out_sqlda;
                } select_into;
        } args;
    struct rissqlca     risca;
    struct rissqlca     dbca;
        char                            *rissqlstmt;
        char                            *dbsqlstmt;
} risasync;

/*
**      New Client process parms
*/
typedef struct ris_app_client_parms_s
{
    char                        protocol;
    char                        address[RIS_MAX_NODE_SIZE];
    char                        username[RIS_MAX_ID_SIZE];
    char                        password[RIS_MAX_PASSWD_SIZE];
        short                   major;
        short                   feature;
} ris_app_client_parms_s;

/*
**      VARIABLES
*/
APP_EXTERN       int                                            RIS_upgrade_parms_file APP_INIT(0);
APP_EXTERN       int                                            RIS_lang_code_used APP_INIT(-1);

APP_EXTERN       int                                            RIS_client_died;
APP_EXTERN       int                                            RIS_test_completion_flag;
APP_EXTERN       char                                   RIS_def_schname[RIS_MAX_ID_SIZE];
APP_EXTERN       char                                   RIS_parms_filename[RIS_MAX_PATH_SIZE];

APP_EXTERN       ris_app_client_parms_s RIS_client_parms;
APP_EXTERN       ris_schfile_parms_s            RIS_schfile_parms;

APP_EXTERN       char                                   RIS_risstmt[RIS_MAX_STMT_LEN];
APP_EXTERN       char                                   RIS_dbstmt[RIS_MAX_STMT_LEN];

APP_EXTERN       ris_app_stmt                   *RIS_stmt;
APP_EXTERN       ris_app_stmt                   **RIS_stmts;
APP_EXTERN       int                                            RIS_static_stmt_cnt;
APP_EXTERN       risasync                               *RIS_async;
APP_EXTERN       risasync                               *RIS_asyncs[RIS_MAX_TRANSACTIONS];

APP_EXTERN       net_s                                  *RIS_net;
APP_EXTERN       arc_s                                  *RIS_arc;
APP_EXTERN       int                                            RIS_net_finish_mode APP_INIT(DEALLOCATE);
APP_EXTERN       int                                            RIS_write_len;
APP_EXTERN       int                                            RIS_read_len;
APP_EXTERN       int                                            RIS_write_size;
APP_EXTERN       int                                            RIS_read_size;
APP_EXTERN       ris_appcli_buf                 *RIS_write;
APP_EXTERN       ris_cliapp_buf                 *RIS_read;

APP_EXTERN       int                                            RIS_save_write_size;
APP_EXTERN       int                                            RIS_save_read_size;
APP_EXTERN       ris_appcli_buf                 *RIS_save_write;
APP_EXTERN       ris_cliapp_buf                 *RIS_save_read;

APP_EXTERN      rissqlca        RIS_risca
#ifdef APP_GLOBAL_DEFINE
= {"",0,0,{"",0,0},"",{0,0,0,0,0,0,0,0},"","",RIS_risstmt}
#endif
;

APP_EXTERN      rissqlca                                RIS_dbca
#ifdef APP_GLOBAL_DEFINE
= {"",0,0,{"",0,0},"",{0,0,0,0,0,0,0,0},"","",RIS_dbstmt}
#endif
;

APP_EXTERN       ris_superschema_error_info     RISsuperschema_error;/* internal only */

APP_EXTERN  char                                RIS_app_version[12]; /* XX.XX.XX.XX\0 */
APP_EXTERN  int                                         RIS_app_version_maj APP_INIT(0);
APP_EXTERN  int                                         RIS_app_version_min APP_INIT(0);
APP_EXTERN  int                                         RIS_app_version_rel APP_INIT(0);
APP_EXTERN  int     RIS_license_bypass APP_INIT(0);         /* internal only */

/* Variables available to applications */
APP_EXTERN       int                                                    SQLCODE;
APP_EXTERN       int                                                    superschema_warning;
APP_EXTERN      rissqlca                                        *risca          APP_INIT(&RIS_risca);
APP_EXTERN      rissqlca                                        *dbca           APP_INIT(&RIS_dbca);
APP_EXTERN      ris_superschema_error_info      *superschema_error APP_INIT(&RISsuperschema_error);

/* ====================================================================
 * Some prototypes
 */

#ifdef __cplusplus
extern "C" {
#endif

extern char *RISascii_to_datetime(
	datetime *date,
	char *buffer,
	char *format)
;
extern void RISrestore_schema_file_checksum(
	void)
;
extern void RISint_clear(
	short *stmt_id,
	int *async_id,
	unsigned char execute_mode)
;
extern void RISint_clear_async(
	int *async_id)
;
extern void RISint_close(
	short stmt_id,
	int *async_id,
	unsigned char execute_mode)
;
extern void RISint_process_debug(
	char *s)
;
extern void RISint_process_debug_noRAP(
	char *s)
;
extern void RISint_process_debug_no_output(
	char *s)
;
extern void RISint_process_debug_no_output_noRAP(
	char *s)
;
extern void RISint_describe(
	short stmt_id,
	sqlda *data,
	int in_out)
;
extern int RISdatetime_to_ascii(
	datetime *date,
	char *buffer,
	char *format)
;
extern int RISint_error_msg(
	int errcode,
	char *buf,
	char *errname)
;
extern void RISint_term_error_msg()
;
extern void RISint_set_error(
	int status)
;
extern void RISint_clear_error()
;
extern void RISint_upgrade_parms_file()
;
extern void RISint_execute(
	short *stmt_id,
	int *async_id,
	sqlda *in_sqlda,
	unsigned char execute_mode,
	int clear_flag,
	int static_flag)
;
extern void RISint_execute_immediate(
	short *stmt_id,
	int *async_id,
	char *query,
	sqlda *in_sqlda,
	int execute_mode,
	int clear_flag,
	int static_flag)
;
extern void RISint_fetch(
	short stmt_id,
	int *async_id,
	sqlda *output,
	int one_row_only,
	unsigned char execute_mode)
;
extern void RISget_superschema_names(
	char (*buffer)[RIS_MAX_ID_SIZE],
	int *countp)
;
extern void RISget_superschema_definition(
	char *ss_name,
	char (*buffer)[RIS_MAX_ID_SIZE],
	int *countp)
;
extern void RISget_async_stmts(
	int *buffer,
	int *countp)
;
extern void RISget_schema_info(
	char *schname,
	ris_schema_info **schemap,
	ris_db_info **dbp,
	ris_grantee_info **granteep)
;
extern void RISget_db_info(
	int dbid,
	ris_db_info **dbp)
;
extern void RISget_schema_file(
	char **schema_filenamep,
	ris_db_info **dblistp,
	ris_schema_info **schlistp,
	ris_grantee_info **granteep)
;
extern void RISint_get_flags(
	int *ansi_mode,
	int *enable_dbms,
	int *verify_mode,
	int *blankstrip_mode,
	int *autocommit,
	int *autorename)
;
extern void RISget_ansi_mode(
	int *ansi_mode)
;
extern void RISget_enabled_databases(
	int *enable_dbms)
;
extern void RISget_verify_mode(
	int *verify_mode)
;
extern void RISget_blankstrip_mode(
	int *blankstrip_mode)
;
extern void RISget_autocommit_mode(
	int *autocommit)
;
extern void RISget_autorename_mode(
	int *autorename)
;
extern void RISget_schema_names(
	char (*buffer)[RIS_MAX_ID_SIZE],
	int *countp)
;
extern void RISget_default_schema_name(
	char buffer[RIS_MAX_ID_SIZE])
;
extern void RISget_current_stmt_schema_name(
	char buffer[RIS_MAX_ID_SIZE])
;
extern void RISget_parameters(
	ris_parameters *parameters)
;
extern void RISget_schema_transactions(
	char (*buffer)[RIS_MAX_ID_SIZE],
	int *countp)
;
extern void RISget_app_version(
	int *maj,
	int *min,
	int *rel)
;
extern void RISinitialize(
	char *language_name)
;
extern void RISstart_client(
	void)
;
extern void RISlocate_schema_file(
	schema_file_parms *parms)
;
extern void RISget_schema_file_location(
	schema_file_parms *parms)
;
extern void RISlocate_client(
	client_parms *parms)
;
extern void RISget_client_location(
	client_parms *parms)
;
extern void RISint_prepare(
	short *stmt_id,
	char *query,
	int clear_flag,
	int static_flag)
;
extern void RISint_report_error(
	int *async_id,
	char **ptrp)
;
extern void RISint_show_app_memory(
#if defined(sunx)
	int (* output_func)())
#elif defined(unix) || defined(WIN32) || defined(DOS)
	int (* output_func)(const char *, ...))
#endif 
;
extern void RISint_show_app_stmts(
#if defined(sunx)
	int (* output_func)())
#elif defined(unix) || defined(WIN32) || defined(DOS)
	int (* output_func)(const char *, ...))
#endif 
;
extern void RISint_show_async_stmts(
#if defined(sunx)
	int (* output_func)())
#elif defined(unix) || defined(WIN32) || defined(DOS)
	int (* output_func)(const char *, ...))
#endif 
;
extern void RISint_show_cli_memory(
#if defined(sunx)
	int (* output_func)())
#elif defined(unix) || defined(WIN32) || defined(DOS)
	int (* output_func)(const char *, ...))
#endif 
;
extern void RISint_show_cli_stmts(
#if defined(sunx)
	int (* output_func)())
#elif defined(unix) || defined(WIN32) || defined(DOS)
	int (* output_func)(const char *, ...))
#endif 
;
extern void RISint_show_cli_hash_table(
#if defined(sunx)
	int (* output_func)())
#elif defined(unix) || defined(WIN32) || defined(DOS)
	int (* output_func)(const char *, ...))
#endif 
;
extern void RISint_show_cli_servers(
#if defined(sunx)
	int (* output_func)())
#elif defined(unix) || defined(WIN32) || defined(DOS)
	int (* output_func)(const char *, ...))
#endif 
;
extern void RISint_show_cli_struct_mgrs(
#if defined(sunx)
	int (* output_func)())
#elif defined(unix) || defined(WIN32) || defined(DOS)
	int (* output_func)(const char *, ...))
#endif 
;
extern void RISint_select(
	short *stmt_id,
	int *async_id,
	char *query,
	sqlda *in_sqlda,
	sqlda *out_sqlda,
	unsigned char execute_mode)
;
extern void RISint_schema_mgr(
	char mode,
	char *data,
	char *str)
;
extern void RISint_report_superschema_error(
	char *ss_name)
;
extern void RISterminate(
	void)
;
extern void RISstop_client(
	void)
;
extern void RISint_test_completion(
	sqlda *desc,
	int wait_flag)
;
extern void RISint_get_debug_flags(
	char *s)
;
extern void RISint_set_sqlcode(
	int status)
;
extern int RISget_sqlcode()
;
extern rissqlca *RISget_risca()
;
extern rissqlca *RISget_dbca()
;
extern ris_superschema_error_info *RISget_superschema_error()
;
extern int RISget_superschema_warning()
;
extern void RISint_get_language_code(
	int *code)
;
extern void RISget_language_name(
	char *name)
;
extern void RISint_get_client_addresses(
	char *xns_addr,
	char *tcp_addr,
	char *lu62_addr,
	char *dnp_addr)
;
extern void RISget_ris_sqltype_code(
	int  *code,
	char *str)
;
extern void RISget_ris_sqltype_string(
	char *str,
	int  code)
;

extern int RISload_dll();

extern void RISfree_memory(int type, ...);

extern void RISfree_memory_malloc(int type, ...);

extern int RISget_platform(void);

/* =============================================================== */

/* appcli.c */
extern void RISapp_start_client();
extern void RISapp_stop_client();
extern void RISapp_cleanup_client();
extern void RISapp_check_client(struct net_s * net);

extern void RISapp_validate_client_spec(
  char  protocol,
  char *address,
  char *username,
  char *password,
  short parms_cli_major);

extern void RISapp_update_client_spec(
  char  protocol,
  char *address,
  char *username,
  char *password,
  short parms_cli_major,
  short parms_cli_feature);

/* appparmf.c */
extern void RISapp_read_parms_file();
extern void RISapp_write_parms_file();
extern void RISapp_save_parameters();
extern void RISapp_restore_parameters();

/* appschf.c */
extern void RISapp_validate_schfile_spec(
  char  protocol,
  char *address,
  char *username,
  char *password,
  char *filename);

extern void RISapp_update_schfile_spec(
  char  protocol,
  char *address,
  char *username,
  char *password,
  char *filename);

/* appmisc.c */
extern void RISapp_check_alignment();
extern void RISapp_net_errhandle(struct net_s *net);
extern void RISapp_arc_errhandle(struct arc_s *arc);
extern void RISapp_process_eot_schname_list(int count, char *data);
extern void RISapp_process_clear_stmt_list (int count, char *data);

/* appver.c */
extern int RISapp_init_version();

/* appinit.c */
extern void RISapp_initialize(char *language_name);

/* appclear.c */
extern void RISapp_clear(short *id, int set_sqlcode, int client_flag, unsigned char execute_mode);

extern void RISapp_clear_all(int client_flag);

extern void RISapp_clear_async(int *async_id, int set_sqlcode);

extern void RISapp_clear_all_async(void);

/* appsqlca.c */
extern void RISapp_push_risca_dbca();
extern void RISapp_pop_risca_dbca();
extern void RISapp_empty_risca_dbca_stack();

/* appcrsr.c */
extern void RISapp_alloc_cursor(short id);
extern void RISapp_close_cursor(short id);
extern void RISapp_close_all_cursors(void);
extern void RISapp_close_all_cursors_for_schema(char *schname);

/* appterm.c */
extern void RISapp_terminate(void);

/* apptobuf.c */
extern void RISapp_opcode_to_buf(unsigned char	opcode, unsigned char	execute_mode);
extern void RISapp_client_init_to_buf();
extern void RISapp_debug_to_buf(int server_flag);
extern void RISapp_locate_schfile_to_buf(char protocol,char *address, char *username, char *password, char *filename);
extern void RISapp_prep_to_buf(int len, char *query);
extern void RISapp_execute_to_buf(sqlda	*in_sqlda, unsigned char execute_mode);
extern void RISapp_fetch_to_buf(unsigned int row_count, unsigned char execute_mode);
extern void RISapp_fetch_blob_to_buf();
extern void RISapp_clear_to_buf(int set_sqlcode, unsigned char execute_mode);
extern void RISapp_schema_mgr_to_buf(char mode, char *data, char * str);
extern void RISapp_grow_buf_to_buf(unsigned char opcode);
extern void RISapp_get_ss_def_to_buf(char *ss_name);
extern void RISapp_report_ss_error_to_buf(char *ss_name);

extern void RISapp_execute_blob_to_buf(
  sqlvar        *input_blob_sqlvar,
  int            text_type_reserved,
  unsigned char  execute_mode,
  unsigned char *blobinfo);

/* appid.c */
extern short RISapp_new_stmt(int clear_flag, int static_flag);

/* appcnv.c */
extern void RISapp_init_to_net              (arc_s *arc, struct ris_appcli_buf_client_init *init);
extern void RISapp_debug_to_net             (arc_s *arc, struct ris_appcli_buf_debug *debug);
extern void RISapp_locate_sch_file_to_net   (arc_s *arc, struct ris_appcli_buf_locate_schfile *locate_schfile);
extern void RISapp_prepare_to_net           (arc_s *arc, struct ris_appcli_buf_prep *prep);
extern void RISapp_execute_to_net           (arc_s *arc, sqlda *in_sqlda, struct ris_appcli_buf_exec *exec);
extern void RISapp_clear_to_net             (arc_s *arc, struct ris_appcli_buf_clear *clear);
extern void RISapp_grow_buf_to_net          (arc_s *arc, struct ris_appcli_buf_grow_buf *grow_buf);
extern void RISapp_grow_buf_from_net        (arc_s *arc, struct ris_appcli_buf_grow_buf *grow_buf);
extern void RISapp_prepare_from_net         (arc_s *arc, struct ris_cliapp_buf_prep *prep);
extern void RISapp_execute_from_net         (arc_s *arc, struct ris_cliapp_buf_exec *exec);
extern void RISapp_fetch_from_net           (arc_s *arc, ris_app_stmt *stmt, struct ris_cliapp_buf_fetch *fetch);
extern void RISapp_close_from_net           (arc_s *arc, struct ris_cliapp_buf_close *close);
extern void RISapp_clear_from_net           (arc_s *arc, struct ris_cliapp_buf_clear *clear);
extern void RISapp_string_from_net          (arc_s *arc, struct ris_cliapp_buf_string *string);
extern void RISapp_get_flags_from_net       (arc_s *arc, struct ris_cliapp_buf_get_flags *get_flags);
extern void RISapp_report_ss_error_from_net (arc_s *arc, struct ris_cliapp_buf_report_ss_error *error);
extern void RISapp_get_ss_names_from_net    (arc_s *arc, struct ris_cliapp_buf_get_ss_names *get_ss_names);
extern void RISapp_get_ss_def_from_net      (arc_s *arc, struct ris_cliapp_buf_get_ss_def *get_ss_def);
extern void RISapp_get_sch_in_trans_from_net(arc_s *arc, struct ris_cliapp_buf_get_sch_in_trans *get_sch_in_trans);
extern void RISapp_error_from_net           (arc_s *arc, struct ris_cliapp_buf_error *error);
extern void RISapp_execute_blob_to_net      (arc_s *arc, struct ris_appcli_buf_exec_blob *exec_blob);
extern void RISapp_fetch_blob_to_net        (arc_s *arc, struct ris_appcli_fetch_blob *fetch_blob);
extern void RISapp_net_to_fetch_blob        (arc_s *arc, struct ris_cliapp_fetch_blob *fetch_blob);
extern void RISapp_blob_struct_to_net       (arc_s *arc, ris_blob *blob_struct);
extern void RISapp_execute_deferred_to_net  (arc_s *arc, sqlda *in_sqlda, struct ris_appcli_buf_exec *exec_deferred);
extern void RISapp_fetch_buf_to_net         (arc_s *arc, struct ris_appcli_buf_fetch *fetch);

/* appgetfl.c */
extern void RISapp_get_schfile(char **filenamep, ris_db_info **dbp, ris_schema_info **schemap, ris_grantee_info **granteep, int mem_mode);
extern void RISapp_get_schema(char     *schname, ris_schema_info **schemap, ris_db_info **dbp, ris_grantee_info **granteep, int mem_mode);
extern void RISapp_get_db(int dbid, ris_db_info **dbp, int mem_mode);

/* appsndrc.c */
extern void RISapp_send_rec();

/* appsig.c */
extern void RISapp_sighandle(int signo);
extern void RISapp_init_signal();
extern void RISapp_restore_signal();

/* appparms.c */
extern void RISapp_move_to_next_row();
extern void RISapp_adjust_parms(sqlda *parms, char *buf);
extern void RISapp_fill_blob_parms(sqlvar *output_sqlvar, int text_type_reserved, int *array_full);
extern void RISapp_process_parms(sqlda *source, sqlda *dest, int input);
extern void RISapp_process_one_parm(sqlda *source, sqlda *dest, int input, int iparam);
extern void RISapp_process_blob_parms(sqlvar *input_blob_sqlvar, int text_type_reserved, char *dest, unsigned char *blobinfo);

/* appdcml.c */
extern void RISapp_char_to_decimal(char s[], int s_len, char d[], int d_len, int d_scale);
extern void RISapp_int_to_decimal(int s, char d[], int d_len, int d_scale);
extern void RISapp_double_to_decimal(double s, char *d, int d_len, int d_scale);

/* appbufto.c */
extern void RISapp_buf_to_err    (void);
extern void RISapp_buf_to_execute(void);
extern void RISapp_buf_to_fetch  (void);
extern void RISapp_buf_to_close  (void);
extern void RISapp_buf_to_clear  (void);
extern  int RISapp_buf_to_report_ss_error(ris_schema_error_info *ss_error);
extern void RISapp_map_warnings(char warning_flag);

#ifdef __cplusplus
}
#endif

#endif /* RISAPP_H */
