/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							riscom.h
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					3/88
**	ABSTRACT:

TDM:11/10/93:	Added ODBC flag to RIS_process

**		
**	
**	REVISION HISTORY:
*/

#ifndef RISCOM_H
#define RISCOM_H

#ifndef COM_EXTERN
#ifdef COM_GLOBAL_DEFINE
#define COM_EXTERN
#else
#define COM_EXTERN extern
#endif
#endif

#ifndef COM_INITIAL
#ifdef COM_GLOBAL_DEFINE
#define COM_INITIAL(value) = value
#else
#define COM_INITIAL(value)
#endif
#endif

#include <stdio.h>
#include <setjmp.h>
#include "ris.h"
#include "rislimit.h"
#include "rislang.h"
#include "rismem.h"
#include "risrap.h"

/* Values for RIS_process */
#define SET_APPLICATION    RIS_process |= 0x1
#define APPLICATION       (RIS_process &  0x1)
#define SET_CLIENT         RIS_process |= 0x2
#define CLIENT            (RIS_process &  0x2)
#define SET_SERVER         RIS_process |= 0x4
#define SERVER            (RIS_process &  0x4)
#define SET_PREPROCESSOR   RIS_process |= 0x8
#define PREPROCESSOR      (RIS_process &  0x8)
#define SET_TCPSERVER      RIS_process |= 0x10
#define TCPSERVER         (RIS_process &  0x10)
#if defined(WIN32)
#define SET_ODBCDLL        RIS_process |= 0x20
#define ODBCDLL           (RIS_process &  0x20)
#endif

/* Modes for RIScom_get_risdir() */
#define MATCH_MAJOR                1  /* 3.x.x.x & < Appli/Client         */
#define MATCH_MAJOR_MINOR          2  /* 3.x.x.x & < Client/Server       */
#define MATCH_MAJOR_MINOR_RELEASE  3  /* 3.x.x.x & < ?                   */
#define MATCH_HIGHEST              4  /* UMS msg files                   */
#define MATCH_COMPATIBLE           5  /* 4.x.x.x & > Appli/Client/Server */
#define MATCH_MAJOR_FEATURE        6  /* 5.x.x.x & > Appli/Client/Server */

/* Starting V5 we have two types of schemas. "Secure schemas" and
** "Standard schemas". JP 12/08/93
*/

#define SECURE_SCHEMA    1
#define STANDARD_SCHEMA  0

/* Access macros */
#define ACC_SELECT		0
#define ACC_INSERT		1
#define ACC_DELETE		2
#define ACC_UPDATE		3
#define ACC_CONNECT		4
#define ACC_RESOURCE	        5
#define ACC_DBA			6

#define ACC_SIZE		7

#define NO_ACCESS		"-------"
#define SELECT_ACCESS	"s------"
#define INSERT_ACCESS	"-i-----"
#define DELETE_ACCESS	"--d----"
#define UPDATE_ACCESS	"---u---"
#define GRANTABLE_SELECT_ACCESS	"S------"
#define GRANTABLE_INSERT_ACCESS	"-I-----"
#define GRANTABLE_DELETE_ACCESS	"--D----"
#define GRANTABLE_UPDATE_ACCESS	"---U---"

#define ALL_ACCESS				"sidu---"
#define GRANTABLE_ALL_ACCESS	"SIDU---"

#define ANY_ACCESS				"****---"

/*
** Added for V5: JP 12/10/93
*/

#define DICTIONARY_ADMIN_PRIV   'D'
#define SCHEMA_ADMIN_PRIV       'S'
#define CONNECT_PRIV            'C'
#define RESOURCE_PRIV           'R'

/* dtime defines */
#define DT_SECOND		0
#define DT_MINUTE		1
#define DT_HOUR			2
#define DT_DAY			3
#define DT_MONTH		4
#define DT_YEAR			5
#define DT_COUNT		6

/*
**	TYPES
*/
typedef struct dtime_s
{
 unsigned int data[DT_COUNT];
} dtime;

/*
**	VARIABLES
*/
COM_EXTERN  int     RIS_app_cli_version   COM_INITIAL(0);

COM_EXTERN  int     RIS_language_code     COM_INITIAL(-1);

COM_EXTERN  int     RIS_process	          COM_INITIAL(0);
COM_EXTERN  short   RIS_current_stmt_id	  COM_INITIAL(-1);

COM_EXTERN  int	    RIS_development                        COM_INITIAL(0);
COM_EXTERN  char    RIS_dir[RIS_MAX_PATH_SIZE]             COM_INITIAL("");

COM_EXTERN  char    RIS_local_xns_addr [RIS_MAX_NODE_SIZE] COM_INITIAL("");
COM_EXTERN  char    RIS_local_tcp_addr [RIS_MAX_NODE_SIZE] COM_INITIAL("");
COM_EXTERN  char    RIS_local_dnp_addr [RIS_MAX_NODE_SIZE] COM_INITIAL("");
COM_EXTERN  char    RIS_local_lu62_addr[RIS_MAX_NODE_SIZE] COM_INITIAL("");

/* ===========================================================
 * RIS generates prt files automatically
 * Just do it manually for now
 */
#ifdef __cplusplus
extern "C" {
#endif

/* comver.c */
extern short RIScom_ver_str_to_number(char *val);
extern void RIScom_ver_number_to_str (short val, char *ret_val);

/* comstrcp.c */
extern int RIScom_strcpy (char *dst, char *src);
extern int RIScom_strncpy(char *dst, char *src, int n);

extern int RIScom_upper_strcpy (char *dst, char *src);
extern int RIScom_lower_strcpy (char *dst, char *src);
extern int RIScom_upper_strncpy(char *dst, char *src, int n);
extern int RIScom_lower_strncpy(char *dst, char *src, int n);

/* comwrap.c */
extern int   RIScom_access(char *path, int access_mode);
extern int   RIScom_chmod (char *path, int mode);
extern int   RIScom_chown (char *path, int owner, int group);
extern int   RIScom_close (int   fd);
extern int   RIScom_creat (char *path, int mode);
extern int   RIScom_execv (char *path, char *argv[]);
extern int   RIScom_execve(char *path, char *argv[], char *envp[]);
extern int   RIScom_execvp(char *file, char *argv[]);
extern int   RIScom_fclose(FILE *stream);
extern char *RIScom_fgets (char *st, int n, FILE *fd);
extern FILE *RIScom_fopen (char *fname, char *type);
extern int   RIScom_fputc (int   c,  FILE *fd);
extern int   RIScom_fputs (char *st, FILE *fd);
extern int   RIScom_fread (char *ptr, int size, int nitems, FILE *stream);

/* comisfn.c */
extern int RIScom_isspace(int c);
extern int RIScom_isdigit(int c);
extern int RIScom_isxdigit(int c);
extern int RIScom_islower(int c);
extern int RIScom_isupper(int c);
extern int RIScom_isalpha(int c);
extern int RIScom_isalnum(int c);
extern int RIScom_iscntrl(int c);
extern int RIScom_ispunct(int c);
extern int RIScom_isprint(int c);
extern int RIScom_isgraph(int c);
extern int RIScom_isascii(int c);
extern int RIScom_tolower(int c);
extern int RIScom_toupper(int c);
extern int RIScom_toascii(int c);

/* comdebug.c */
extern void  RIScom_initialize_debug(void);

extern void  RIScom_get_output_device_name(char *input, char *output_device);

extern char *RIScom_debug_flags(char *s, int *applicationp,int *clientp, int *serverp);

extern int   RIScom_output_debug(const char *fmt, ...);

/* comjmp.c */
extern void     RIScom_longjmp (int st, char *file, int line);
extern void     RIScom_resetjmp(char *file, int line);
extern jmp_buf *RIScom_setjmp  (char *file, int line);

/* comuni.c */
extern int   RIScom_isleadbyte(int leadbyte);
extern char *RIScom_strrchr (char *input_string, int char_to_match);
extern char *RIScom_strchr  (char *input_string, int char_to_match);
extern char *RIScom_charnext(char *ptr);
extern char *RIScom_charprev(char *start_ptr,char *curr_ptr);
extern char *RIScom_skipwhitespace(char *string);
extern char *RIScom_strstr   (char *in_string,char *match_string);
extern char *RIScom_unpad    (char *string, int len);
extern char *RIScom_strpbrk  (char *string, char *compare_string);
extern void  RIScom_StripSlash(char *sz1);

/* comalloc.c */
extern char           *RIScom_alloc(int size, int id, int mark, char type);
extern ris_block_info *RIScom_get_block(int size);

extern char           *RIScom_sys_malloc (int size);
extern char           *RIScom_sys_calloc (unsigned int nelem, unsigned int size);
extern char           *RIScom_sys_realloc(char *user_buffer, int size);
extern void            RIScom_sys_free   (char *user_buffer);

/* commem.c */
extern void RIScom_get_mem(void);
extern void RIScom_remove_mem();

/* comfree.c */
extern void RIScom_free(int id, int mark, char type);

/* comdate.c */
extern          int  RIScom_leap_year(unsigned int year);
extern unsigned int  RIScom_days_in_month(unsigned int month, unsigned int year);
extern          int  RIScom_invalid_date(datetime *date);
extern unsigned int  RIScom_calc_doy    (datetime *date);
extern          int  RIScom_days_between(datetime *date1,datetime *date2);
extern          int  RIScom_calc_dow    (datetime *date);
extern          char RIScom_dtseparator(char index);
extern          int  RIScom_char_to_datetime(char *source,dtime *dest);

/* comrap.c */
extern int RIScom_read_rap_file(ris_rap_options *rap_options,int expand_pid_flag);

/* compd.c */
extern void RIScom_rap_depd(char *crpt, char *decrpt);
extern void RIScom_rap_pd(  char *pd,   char *crpt);

/* comlang.c */
extern int   RIScom_ris_lang_code(char *name);
extern char *RIScom_ris_lang_name(int code);
extern char *RIScom_ris_lang_dir (int code);
extern char *RIScom_default_ris_langname();
extern int   RIScom_get_code_page(int RIS_language_code);
extern void  RIScom_initialize_langs(char *path);

/* comstcmi.c */
extern int RIScom_strcmp_ic (char *s1, char *s2);
extern int RIScom_strncmp_ic(char *s1, char *s2, int n);

/* comsyser.c */
extern void RIScom_syserr(int msgno, rissqlca *dbcap);

/* comumsg.c */
extern int   RIScom_init_ums_msg (int file_type, char *dir, int development, char *lang_name);
extern char *RIScom_umsg         (int errcode);
extern char *RIScom_umsg_by_key  (char *errkey);
extern char *RIScom_error_code   (int errcode);
extern void  RIScom_clear_ums_msg(int file_type);

/* comgtdir.c */
extern int RIScom_get_risdir(
  char     *prodname,
  int       version_maj,
  int       version_min,
  int       version_rel,
  int       mode,
  char     *risdir_file,
  char     *config_file,
  char     *risdir,
  int      *developmentp,
  rissqlca *dbcap);

// Close up
#ifdef __cplusplus
}
#endif

#endif /* RISCOM_H */
