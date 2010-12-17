/*
**	NAME:							sqlpred.c
**	AUTHORS:						David  Michal
**	CREATION DATE:					2/90
**	ABSTRACT:
**
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "ristoken.h"
#include "rissql.h"

/*
**	FUNCTION PROTOTYPES
*/
#define sqlpred_c
#include "sqlpred.prt"
#include "sys.prt"
#include "comdebug.prt"
#include "comjmp.prt"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

static char * buffer_type_name(
	int buffer_type)
{
	char *sts;

	switch(buffer_type)
	{
		case PREDICT_WRITE_BUFFER: sts = "WRITE BUFFER"; break;
		case PREDICT_READ_BUFFER: sts = "READ BUFFER"; break;
		case PREDICT_FETCH_BUFFER: sts = "FETCH BUFFER"; break;
		default: sts = "UNKNOWN"; break;
	}
	return sts;
}

/******************************************************************************/

/*
** This function predicts buffer size requirements for statements.
*/

extern int RISsql_predict_buffer_size(
	ristree * tp,
	int buffer_type)
{
	int buffer_size = 0;

	SQL_DBG(("RISsql_predict_buffer_size(tp->tok:%hu buffer_type:%s)\n",
		tp->tok,buffer_type_name(buffer_type)));

	if (buffer_type == PREDICT_WRITE_BUFFER)
	{
		/*
		**	write buffer
		*/
		switch(tp->tok)
		{
			/*
			**	fixed size
			*/
			case RIS_TOK_COMMIT:
			case RIS_TOK_ROLLBACK:
			case RIS_TOK_SET:
			case RIS_TOK_CREATE_SCHEMA:
			case RIS_TOK_DROP_SCHEMA:
			case RIS_TOK_DEFAULT_SCHEMA:
			case RIS_TOK_DROP_VIEW:
			case RIS_TOK_OPEN_SCHEMA:
			case RIS_TOK_CLOSE_SCHEMA:
			case RIS_TOK_DROP_TABLE:
			case RIS_TOK_ALTER_SCHEMA:
			case RIS_TOK_LOCK_TABLES:
			case RIS_TOK_ALTER_TABLE:
			case RIS_TOK_DROP_INDEX:
			case RIS_TOK_CREATE_TABLE:
			case RIS_TOK_CREATE_VIEW:
			case RIS_TOK_GRANT:
			case RIS_TOK_GRANT_ON_TABLE:
			case RIS_TOK_GRANT_SCHEMA:
			case RIS_TOK_GRANT_CONNECT:
			case RIS_TOK_GRANT_RESOURCE:
			case RIS_TOK_REVOKE:
			case RIS_TOK_REVOKE_ON_TABLE:
			case RIS_TOK_REVOKE_SCHEMA:
			case RIS_TOK_REVOKE_CONNECT:
			case RIS_TOK_REVOKE_RESOURCE:
			case RIS_TOK_CREATE_INDEX:
			case RIS_TOK_EXEC:
			case RIS_TOK_DECLARE_TABLE:	/* Hitesh */
			case RIS_TOK_DECLARE_VIEW:	/* Hitesh */
			case RIS_TOK_UNDECLARE_TABLE:	/* Hitesh */
			case RIS_TOK_UNDECLARE_VIEW:	/* Hitesh */
			case RIS_TOK_DECLARE_SUPERSCHEMA:
			case RIS_TOK_UNDECLARE_SUPERSCHEMA:
			case RIS_TOK_REDECLARE_SUPERSCHEMA:
			case RIS_TOK_DECLARE_SCHEMA:
			case RIS_TOK_UNDECLARE_SCHEMA:
				buffer_size = RIS_INITIAL_BUFFER_SIZE;
			break;

			/*
			**	variable size depending on parameters and statement
			**	length and the number of values selected
			*/
			case RIS_TOK_INSERT:
			case RIS_TOK_UPDATE:
			case RIS_TOK_DELETE:
			case RIS_TOK_SELECT:
				buffer_size =
					(int)&(((ris_clisrv_buf *)0)->buf.pddo.data) +
					RIS_stmt->sql->input_len +
					RIS_stmt->sql->input->sqld * sizeof(internal_sqlvar) +
					RIS_stmt->sql->output->sqld * sizeof(internal_sqlvar) +
					strlen(RIS_stmt->sql->query) + 1;
			break;

			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
			break;
		}
	}
	else if (buffer_type == PREDICT_READ_BUFFER)
	{
		/*
		**	read buffer
		*/
		switch(tp->tok)
		{
			/*
			**	fixed size
			*/
			case RIS_TOK_CREATE_SCHEMA:
			case RIS_TOK_DROP_SCHEMA:
			case RIS_TOK_DEFAULT_SCHEMA:
			case RIS_TOK_CREATE_VIEW:
			case RIS_TOK_DROP_VIEW:
			case RIS_TOK_ALTER_TABLE:
			case RIS_TOK_CREATE_TABLE:
			case RIS_TOK_DROP_TABLE:
			case RIS_TOK_ALTER_SCHEMA:
			case RIS_TOK_GRANT:
			case RIS_TOK_GRANT_ON_TABLE:
			case RIS_TOK_GRANT_SCHEMA:
			case RIS_TOK_GRANT_CONNECT:
			case RIS_TOK_GRANT_RESOURCE:
			case RIS_TOK_REVOKE:
			case RIS_TOK_REVOKE_ON_TABLE:
			case RIS_TOK_REVOKE_SCHEMA:
			case RIS_TOK_REVOKE_CONNECT:
			case RIS_TOK_REVOKE_RESOURCE:
			case RIS_TOK_OPEN_SCHEMA:
			case RIS_TOK_CLOSE_SCHEMA:
			case RIS_TOK_CREATE_INDEX:
			case RIS_TOK_DROP_INDEX:
			case RIS_TOK_EXEC:
			case RIS_TOK_COMMIT:
			case RIS_TOK_ROLLBACK:
			case RIS_TOK_SET:
			case RIS_TOK_INSERT:
			case RIS_TOK_UPDATE:
			case RIS_TOK_DELETE:
			case RIS_TOK_LOCK_TABLES:
			case RIS_TOK_SELECT:
			case RIS_TOK_DECLARE_TABLE:	/* Hitesh */
			case RIS_TOK_DECLARE_VIEW:	/* Hitesh */
			case RIS_TOK_UNDECLARE_TABLE:	/* Hitesh */
			case RIS_TOK_UNDECLARE_VIEW:	/* Hitesh */
			case RIS_TOK_DECLARE_SUPERSCHEMA:
			case RIS_TOK_UNDECLARE_SUPERSCHEMA:
			case RIS_TOK_REDECLARE_SUPERSCHEMA:
			case RIS_TOK_DECLARE_SCHEMA:
			case RIS_TOK_UNDECLARE_SCHEMA:
				buffer_size = RIS_INITIAL_BUFFER_SIZE;
			break;

			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
			break;
		}
	}
	else if (buffer_type == PREDICT_FETCH_BUFFER)
	{

		/*
		**	fetch buffer
		*/
		switch(tp->tok)
		{
			/*
			**	fixed size
			*/
			case RIS_TOK_CREATE_SCHEMA:
			case RIS_TOK_DROP_SCHEMA:
			case RIS_TOK_DEFAULT_SCHEMA:
			case RIS_TOK_CREATE_VIEW:
			case RIS_TOK_DROP_VIEW:
			case RIS_TOK_ALTER_TABLE:
			case RIS_TOK_CREATE_TABLE:
			case RIS_TOK_DROP_TABLE:
			case RIS_TOK_ALTER_SCHEMA:
			case RIS_TOK_GRANT:
			case RIS_TOK_GRANT_ON_TABLE:
			case RIS_TOK_GRANT_SCHEMA:
			case RIS_TOK_GRANT_CONNECT:
			case RIS_TOK_GRANT_RESOURCE:
			case RIS_TOK_REVOKE:
			case RIS_TOK_REVOKE_ON_TABLE:
			case RIS_TOK_REVOKE_SCHEMA:
			case RIS_TOK_REVOKE_CONNECT:
			case RIS_TOK_REVOKE_RESOURCE:
			case RIS_TOK_OPEN_SCHEMA:
			case RIS_TOK_CLOSE_SCHEMA:
			case RIS_TOK_CREATE_INDEX:
			case RIS_TOK_DROP_INDEX:
			case RIS_TOK_EXEC:
			case RIS_TOK_COMMIT:
			case RIS_TOK_ROLLBACK:
			case RIS_TOK_SET:
			case RIS_TOK_INSERT:
			case RIS_TOK_UPDATE:
			case RIS_TOK_DELETE:
			case RIS_TOK_LOCK_TABLES:
			case RIS_TOK_DECLARE_TABLE:	/* Hitesh */
			case RIS_TOK_DECLARE_VIEW:	/* Hitesh */
			case RIS_TOK_UNDECLARE_TABLE:	/* Hitesh */
			case RIS_TOK_UNDECLARE_VIEW:	/* Hitesh */
			case RIS_TOK_DECLARE_SUPERSCHEMA:
			case RIS_TOK_UNDECLARE_SUPERSCHEMA:
			case RIS_TOK_REDECLARE_SUPERSCHEMA:
			case RIS_TOK_DECLARE_SCHEMA:
			case RIS_TOK_UNDECLARE_SCHEMA:
				buffer_size = 0;
			break;

			/*
			**	variable size depending on row length and max rows
			*/
			case RIS_TOK_SELECT:
				buffer_size = (int)&(((ris_srvcli_buf *)0)->buf.fetch.data) +
					RIS_stmt->row_len * RIS_parms.max_rows;

				/*
				**	make sure size is <= max_buf_size
				*/
				if (buffer_size > RIS_parms.max_buf_size)
				{
					buffer_size =
						RIS_parms.max_buf_size - ((RIS_parms.max_buf_size -
						(int)&(((ris_srvcli_buf*)0)->buf.fetch.data)) %
						RIS_stmt->row_len);
				}

				/*
				**	make sure that size is big enough to hold 1 row
				*/
				if (buffer_size < (int)&(((ris_srvcli_buf*)0)->buf.fetch.data) +
					(int)RIS_stmt->row_len)
				{
					buffer_size = (int)&(((ris_srvcli_buf*)0)->buf.fetch.data) +
						RIS_stmt->row_len;
				}
			break;

			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
			break;
		}
	}
	else
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	SQL_DBG(("RISsql_predict_buffer_size: returns %s size:%d\n",
		buffer_type_name(buffer_type), buffer_size));

	return buffer_size;
}

/******************************************************************************/
