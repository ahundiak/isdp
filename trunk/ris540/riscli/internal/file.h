/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							file.h
**	AUTHORS:						David Michal
**	CREATION DATE:					9/88
**	ABSTRACT:
**		Describes global stuff for file directory.
**	
**	REVISION HISTORY:
*/

#ifdef FILE_GLOBAL_DEFINE
# define FILE_EXTERN
# define FILE_INIT(value) = value
#else
# define FILE_EXTERN extern
# define FILE_INIT(value)
#endif

 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "riscl_pa.h"
#include "riscom.h"
#include "risdebug.h"
#include "rislimit.h"
#include "rismem.h"
#include "ris_err.h"
#include "risstjmp.h"
#include "net.h"

/*
**	DEFINES
*/

/* Transaction states */
#define NO_TRANSACTION			0
#define READ_ONLY_TRANSACTION	1
#define READ_WRITE_TRANSACTION	2

/* 	values for RISfil_update_dict mode */
#define UPDATE_SCHFILE_LOCATION	0x01
#define UPDATE_LOCK_FILE_RETRY	0x02
#define UPDATE_ALL				0xFF

#define UPDATE_LOCK_OFF	0
#define UPDATE_LOCK_ON	1


#define DECR_TRANS_COUNT() \
    if (RISfil_trans_count <= 0)           						\
    {                                   						\
        LONGJMP(RIS_E_INTERNAL_ERROR); 						\
    }                                   						\
	else														\
    {                                   						\
		RISfil_schema_tmp_list[RIS_stmt->stmt_id]->trans = 0;	\
        RISfil_trans_count--;           						\
    }                                   						\

#define LINE_BUFFER_SIZE (RIS_MAX_DBPARMS_SIZE + 1)

/*
**	TYPES
*/

typedef struct filsch_tmp_array
{
	int trans;
	struct filsch_tmp_list *list;
} filsch_tmp_array ;

typedef struct filsch_list
{
    int         update_lock_flag;
    risschema   *schemap;
    struct filsch_list * next;
} filsch_list ;

typedef struct filsch_tmp_list
{
    filsch_list *master_schp;
    risschema   *tmp_schemap;
    struct filsch_tmp_list * next;
} filsch_tmp_list ;

typedef struct fildb_list
{
    int         update_lock_flag;
    risdb       *dbp;
    struct fildb_list * next;
} fildb_list;

typedef struct fildb_tmp_list
{
    fildb_list  *master_dbp;
    risdb       *tmp_dbp;
    struct fildb_tmp_list * next;
} fildb_tmp_list;


/*
**	VARIABLES
*/

FILE_EXTERN long				RISfil_timestamp;
FILE_EXTERN fildb_list			*RISfil_db_list;
FILE_EXTERN fildb_tmp_list		*RISfil_db_tmp_list[RIS_MAX_STMTS];
FILE_EXTERN filsch_list			*RISfil_schema_list;
FILE_EXTERN filsch_tmp_array	*RISfil_schema_tmp_list[RIS_MAX_STMTS];

/*
** Keeps a count of the number of statements in a transaction that directly
** use the schema file.
*/
FILE_EXTERN int             RISfil_trans_count;

/*
** This is to see if any statement has modified the RISfil_schema_list or 
** RISfil_db_list.
*/
FILE_EXTERN int             RISfil_commit_flag;

FILE_EXTERN net_s			RIS_file_net;
FILE_EXTERN net_connect_s	RIS_file_connect;
FILE_EXTERN char			RIS_file[RIS_MAX_PATH_SIZE] FILE_INIT("");
FILE_EXTERN char			RIS_lock_file[RIS_MAX_PATH_SIZE] FILE_INIT("");
FILE_EXTERN char			RIS_id_file[RIS_MAX_PATH_SIZE] FILE_INIT("");
FILE_EXTERN int				RIS_lock_file_retry ;

FILE_EXTERN	unsigned int	RISfil_checksum;
FILE_EXTERN	unsigned int	RISfil_linenum;
FILE_EXTERN	int				RISfil_write_flag;
FILE_EXTERN	FILE			*RISfil_fp;

#define READ_ERROR(sts) \
{ \
	sprintf(RIS_ERRMSGC, "The error occured on line %d of the schema file.", \
		RISfil_linenum); \
	LONGJMP(sts); \
}

