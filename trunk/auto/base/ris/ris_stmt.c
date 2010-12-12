#include "risx.h"

static ris_appcli_buf *RIS_write = NULL;
static int   RIS_write_len;
static short RIS_current_stmt_id;

void RISapp_prep_to_buf(int len, char *query)
{
  if (!RIS_write) RIS_write = g_malloc(4096);

	RIS_write->opcode       = RISCLI_PREPARE_CODE;
	RIS_write->execute_mode = SYNC_MODE;
	RIS_write->stmt_id      = RIS_current_stmt_id;

	memcpy(RIS_write->buf.prep.data, query, len);
	RIS_write->buf.prep.query_len = len;

	RIS_write_len = (int)&(((ris_appcli_buf *)0)->buf.prep.data) + len;

  // g_assert_cmpint(35,==,len);
  // g_assert_cmpint(47,==,RIS_write_len);
}

/* ===============================================================================
 * List of available statements
 */
static GPtrArray    *RIS_stmts = NULL;
static ris_app_stmt *RIS_stmt;

static guint timestamp = 1;

/* =====================================
 * stmt_id     = -1
 * clear_flag  =  1 == RIS_DONT_CLEAR_FLAG
 * static flag =  0 != RIS_STATIC_STMT
 */

/*****************************************************************************
 * Not sure about the whole clear and static thing
 * Need to see some examples of static statements
 * Can't imaging that there is really enough to worry about
 */
short RISapp_new_stmt(int clear_flag, int static_flag)
{
	short	id;

	/*
	**	Search for open slot in statement map for both static and dynamic stmts
	*/
	id = -1;

	if(static_flag == RIS_STATIC_STMT)
	{
    g_assert(0);
#if 0
		if(clear_flag == RIS_DONT_CLEAR_FLAG)
		{
			RIS_static_stmt_cnt++;
		}
		if (RIS_static_stmt_cnt > RIS_parms.max_static_stmts)
		{
			id = make_open_slot();
    }
#endif
	}
  if (!RIS_stmts)
  {
    RIS_stmts = g_ptr_array_sized_new(256);
  //g_ptr_array_set_free_func (RIS_stmts,g_free);
  }
	if (id == -1)
	{
		for (id = 0; id < RIS_stmts->len; id++)
		{
      if (!RIS_stmts->pdata[id]) break;
		}
		if (id == RIS_stmts->len) g_ptr_array_add(RIS_stmts,NULL);
	}

	/*
	**	Give back next statement id
	*/
	RIS_current_stmt_id = id;

	/*
	**	Fill in new stmt stuff
	*/
	RIS_stmt = g_malloc0(sizeof(ris_app_stmt));
	RIS_stmts->pdata[id] = RIS_stmt;

	if (static_flag == RIS_STATIC_STMT && clear_flag == RIS_DONT_CLEAR_FLAG)
	{
		RIS_stmt->timestamp = timestamp++;
		/*
		**	if timestamp exceeds UINT_MAX, it 'wraps' around to
		**	zero.  Since zero is not a valid timestamp, increment it.
		*/
		if(timestamp == 0) timestamp = 1;
	}
	else
	{
		RIS_stmt->timestamp = 0;
	}
	return id;
}

void RISint_prepare(short *stmt_id, char *query, int clear_flag, int static_flag)
{
  short temp_id;

  RISint_set_sqlcode(RIS_E_FAIL);

	temp_id = -1;

	if (RIS_client_died)
	{
    return;
	}
	if (!RIS_mem)
	{
		// RISapp_initialize(getenv("RIS_LANGUAGE"));
	}

	if (!RIS_net)
	{
		// RISapp_start_client();
	}
  // Clear the statement if it is not new
	if (*stmt_id != -1)
	{
		if (static_flag == RIS_STATIC_STMT)
		{
      return;
		}
		else
		{
      g_error("RISapp_clear");
			// RISapp_clear(stmt_id,DONT_SET_SQLCODE,CLEAR_CLIENT,SYNC_MODE);
		}
	}
	temp_id = RISapp_new_stmt(clear_flag, static_flag);

	/* save the query */
	RIS_stmt->query = g_strdup(query);

  // Replaces whitespace with spaces
	// RIScom_fix_space(RIS_stmt->query);
  {
    char *p;
    for(p = RIS_stmt->query; *p; p++) { if (*p < ' ') *p = ' '; }
  }
	/*
	**	Save the stmt_id address
	*/
	RIS_stmt->stmt_id_addr = stmt_id;

	RISapp_prep_to_buf(strlen(query) + 1, query);

	// RISapp_send_rec();
  // Writes RIS_write then reads and fills up RIS_stmt info
  
	*stmt_id = RIS_current_stmt_id;

}
