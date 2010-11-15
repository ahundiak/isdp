/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							rissql.h
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
#ifdef SQL_GLOBAL_DEFINE
# define SQL_EXTERN
# define SQL_INITIAL(value) = value
#else
# define SQL_EXTERN extern
# define SQL_INITIAL(value)
#endif

/*
**	INCLUDES
*/
#include "riscl_pa.h"
#include "risdebug.h"
#include "rislimit.h"
#include "risstjmp.h"
#include "ris_err.h"

/*
**	DEFINES
*/
#define INIT_BUF_SIZE		RIS_BLOCK_SIZE
#define INC_BUF_SIZE		RIS_BLOCK_SIZE	
#define MAX_BUF_SIZE		(RIS_MAX_STMT_LEN - 1)
				/* save one space for the '\0' character (appended to the end 
				   of the query by RISsql_driver */

#define PREDICT_WRITE_BUFFER		0
#define PREDICT_READ_BUFFER			1
#define PREDICT_FETCH_BUFFER		2

#define STRADD(sp) \
{ \
	int STRADD_LEN = strlen(sp); \
	RISsql_xpnd_buf_ifneed(STRADD_LEN); \
	memcpy(RISsql_query_buf + RISsql_query_len, sp, STRADD_LEN); \
	RISsql_query_len += STRADD_LEN; \
}

#define CONSTADD(sp) \
{ \
	int CONSTADD_LEN = sizeof(sp) - 1; \
	RISsql_xpnd_buf_ifneed(CONSTADD_LEN); \
	memcpy(RISsql_query_buf + RISsql_query_len, sp, CONSTADD_LEN); \
	RISsql_query_len += CONSTADD_LEN; \
}

#define VERIFY_TOK(tp, tk) if (tp->tok != tk) LONGJMP(RIS_E_INTERNAL_ERROR)


/*
**	TYPES
*/
typedef struct tablelist
{
	ristab				*tab;
	char				possible_view;
	char				schema_flag;
	struct tablelist	*next;
}tablelist;


typedef struct sqlalias
{
	char			*tabowner;
	char			*tabname;
	char			alias[RIS_MAX_ID_SIZE];
	struct sqlalias	*next;
}sqlalias;


/*
**	VARIABLES
*/
 
SQL_EXTERN int	RISsql_parm_num;		/* parameter sequence # */
SQL_EXTERN int	RISsql_query_len;
SQL_EXTERN int	RISsql_query_buf_size 	SQL_INITIAL(INIT_BUF_SIZE);
SQL_EXTERN char	*RISsql_query_buf 		SQL_INITIAL(0);
SQL_EXTERN sqlalias	*RISsql_alias_list	SQL_INITIAL(0);
SQL_EXTERN int  RISsql_in_subquery;

