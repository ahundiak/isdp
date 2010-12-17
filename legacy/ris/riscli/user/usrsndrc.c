/*
**	NAME:							usrsndrc.c
**	AUTHORS:						Sarah Byram
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**
**	REVISION HISTORY:
**		11/91 sjb split into send and receive functions.  RISusr_send_rec now
**		just calls both functions
**		11/94 Radha Shivakumar 
**			error messages for the V4 app to V5 client were returned incorrectly**			and they were changed 
**      12/94 Radha Shivakumar
**          Network verification being turned on, if the server sends an error
**          the client resets the srv_busy flag so that all future statements
**          don't error out with "server busy"
**
**      7/22/96 - Ashley Burns - fix for TR 439502534.   
*/
 
/*
**	INCLUDES
*/
#include <time.h>
#include <signal.h>
#include <stdlib.h>
#include "risasync.h"
#include "riscl_sr.h"
#include "riscli.h"
#include "risver.h"
#include "riscom.h"
#include "rismem.h"
#include "ristoken.h"
#include "riswarn.h"
#include "arch.h"
#include "net.h"
#include "user.h"


/*
**	FUNCTION PROTOTYPES
*/
#define usrsndrc_c
#include "arcgnerc.prt"
#include "ccooutpt.prt"
#include "ccoschid.prt"
#include "comdebug.prt"
#include "comfree.prt"
#include "comoutpt.prt"
#include "comjmp.prt"
#include "compd.prt"
#include "comwrap.prt"
#include "comsttyp.prt"
#include "dicrem.prt"
#include "netgnerc.prt"
#include "usrcnv.prt"
#include "usrkill.prt"
#include "usrsndrc.prt"
#include "usrsrv.prt"
#include "usrmisc.prt"
#include "sys.prt"

/*
**	DEFINES
*/
#define ALIGN_OFFSET(offset, type) \
{int mod;if((mod=(offset)%(sizeof(type)))!=0)(offset)+= sizeof(type)-mod;}


/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RISusr_send_rec(
	char			opcode,
	rissql			*sql,
	unsigned short	execute_mode)
{

	int             status;
	int             offset;
	int             return_sts = 0;
	int             blocking;
	int             initial_time_diff;
	int             initial_time_correction;
	unsigned int    *save_misc;
	time_t          start_time;
	arc_s           *arc;
	net_s           *net;
	ristimestamp	*timestamp;
	risnetvstate    *netvstate;
	risschema		*schema;

	USR_DBG(("RISusr_send_rec(opcode:%d (%s) sql:0x%x execute_mode:0x%x)\n",
		opcode, RIS_srv_codes[opcode], sql, execute_mode));

	if (!sql)
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	sql->rollback = 0;

	arc = sql->schema->arc;
	net = sql->schema->net;
	timestamp = &(sql->schema->timestamp);
	netvstate = &(sql->schema->netvstate);

	USR_DBG(("RISusr_send_rec: timestamp->timestamp_interval = %d\n",
		timestamp->timestamp_interval));
	USR_DBG(("RISusr_send_rec: timestamp->initial_timeout = %d\n",
		timestamp->initial_timeout));
	USR_DBG(("RISusr_send_rec: timestamp->timestamp_tolerance = %d\n",
		timestamp->timestamp_tolerance));
	USR_DBG(("RISusr_send_rec: timestamp->buffer_full_size = %d\n",
		timestamp->buffer_full_size));
	USR_DBG(("RISusr_send_rec: timestamp->buffer_full_timeout = %d\n",
		timestamp->buffer_full_timeout));
	USR_DBG(("RISusr_send_rec: timestamp->response_interval = %d\n",
		timestamp->response_interval));

	if (net == 0)
	{
		LONGJMP(RIS_E_SERVER_NOT_ALLOCATED);
	}

	/*
	**	Setup the correct read buffer
	*/
	switch(opcode)
	{
		case RIS_FETCH_BUF_CODE_4:
		/*********           BLOB     **********/ 
		case RIS_FETCH_BUF_CODE: 
		case RIS_FETCH_BLOB_CODE:
		/*********           BLOB     **********/ 
			if (IN_START_MODE(execute_mode))
			{
				/* 
				**	Check if buffer is large enough
				*/
				if (RIS_stmt->fetch_buf_size > sql->schema->srv_to_cli_buf_size)
				{
					/*
					**	Send a grow buffer code
					*/
					save_misc = sql->misc;
					sql->misc = (unsigned int *)RIS_stmt->fetch_buf_size;
					RISusr_send_rec(RIS_GROW_SRV_TO_CLI_BUF_CODE,sql,SYNC_MODE);
					sql->schema->srv_to_cli_buf_size = RIS_stmt->fetch_buf_size;
					sql->misc = save_misc;
				}
			}
			/*
			**	replace server read buffer with application write buffer
			*/
			RIS_srv_read_size = RIS_stmt->fetch_buf_size;
			RIS_srv_read = (ris_srvcli_buf *)RIS_app_write;
			break;

		default:
			/*
			**	set read buffer with saved read buffer
			*/
			RIS_srv_read_size = RIS_save_srv_read_size;
			RIS_srv_read = RIS_save_srv_read;
			break;
	}

	/*
	**	The setup the write buffer
	*/
	switch(opcode)
	{
		case RIS_PREP_DESC_DECL_OPEN_CODE:
		case RIS_PREP_EXEC_CODE:
		case RIS_OPEN_CODE:
		case RIS_EXEC_CODE:
        /* BLOB support */
        case RIS_EXEC_DEFERRED_CODE:
        case RIS_PREP_EXEC_DEFERRED_CODE:
        case RIS_EXEC_BLOB_CODE:
        case RIS_FETCH_BUF_CODE: /* send the filename of blob */
        case RIS_FETCH_BLOB_CODE:
        /* BLOB support */

			/*
			**	These are the only codes which send data to the servers.
			**	Use the application read buffer so the data doesn't have to
			**	be copied
			*/

			if (IN_START_MODE(execute_mode))
			{
				/*
				**	See if the application read buffer is larger than the
				**	server read buffer buffer
				*/
				if (RIS_app_read_size > (int)sql->schema->cli_to_srv_buf_size)
				{
					/*
					**	Send a grow buffer code
					*/
					save_misc = sql->misc;
					sql->misc = (unsigned int *)RIS_app_read_size;
					RISusr_send_rec(RIS_GROW_CLI_TO_SRV_BUF_CODE,sql,SYNC_MODE);
					sql->schema->cli_to_srv_buf_size = RIS_app_read_size;
					save_misc = sql->misc;
				}
			}
            if (opcode != RIS_EXEC_BLOB_CODE )
            /* the blob write buffers have been assigned in usrexecbl.c */
            {
				RIS_srv_write_size = RIS_app_read_size;
				RIS_srv_write = (ris_clisrv_buf *)RIS_app_read;
			}
			break;

		default:
			RIS_srv_write_size = RIS_save_srv_write_size;
			RIS_srv_write = RIS_save_srv_write;
			break;
	}

	if (IN_START_MODE(execute_mode))
	{
		/*
		**	Load the buffer
		*/
		offset = 0;
		RIS_srv_write->opcode = opcode;

		if (RIS_stmt)
		{
			RIS_srv_write->stmt_id = RIS_stmt->stmt_id;
		}
		else
		{
			RIS_srv_write->stmt_id = RIS_current_stmt_id;
		}

		ARC_SHORT_TO_NET(arc, &RIS_srv_write->stmt_id);
    	
		RIS_srv_write->timestamp_interval = timestamp->timestamp_interval;
    	RIS_srv_write->response_flag = 0;
    	if (timestamp->response_interval != 0)
		{
    		if (timestamp->timestamp_interval > 0)
			{
				RIS_srv_write->timestamp_interval = 
					abs(timestamp->response_interval);
    			if (timestamp->response_interval > 0)
				{
					RIS_srv_write->response_flag = 1;
				}
				else
				{
					RIS_srv_write->response_flag = -1;
				}
			}
		}

		/* TR249406899 - Sol2 needed timestamp conversion for
		   12-02-94	 "set network verification" stmt bug. Wanda */

		ARC_INTEGER_TO_NET(arc, &RIS_srv_write->timestamp_interval);

		switch(opcode)
		{
			case RIS_PREP_DESC_DECL_OPEN_CODE:
			{
				struct ris_clisrv_buf_pddo *pddo = &RIS_srv_write->buf.pddo;

				/*
				**	First, we load the fixed length data.  While doing
				**	this we can also calculate the size of the the variable
				**	length data and set up the pointers into the data section
				*/

				/* statement type */
				pddo->stmt_type = sql->stmt_type;

				/*
				**	input data --	VERY IMPORTANT: Because we are using the
				**				same buffer that we read the data from the
				**				the application, the data is already in place.
				**				The data should always be the first the in 
				**				the buffer and the offset should always be 0.
				*/
				pddo->in_data = offset; 
				if (sql->input->sqld)
				{
					offset += sql->input_len;
				}

				/* input sqlvars */
				ALIGN_OFFSET(offset, long *);
				pddo->in_sqlvar = offset;
				pddo->in_count = sql->input->sqld;
				offset += sql->input->sqld * sizeof(internal_sqlvar);

				/* output sqlvars */
				ALIGN_OFFSET(offset, long *);
				pddo->out_sqlvar = offset;
				pddo->out_count = sql->output->sqld;
				offset += sql->output->sqld * sizeof(internal_sqlvar);

				/* the query */
				ALIGN_OFFSET(offset, char);
				pddo->query = offset;
				pddo->query_len = strlen(sql->query) + 1;
				offset += pddo->query_len;

				/*
				**	Test if the buffer is large enough
				*/
				RIS_srv_write_len =
					(int)&(((ris_clisrv_buf *)0)->buf.pddo.data) + offset;
				if (RIS_srv_write_len > RIS_srv_write_size)
				{
					USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
						"RIS_srv_write_size:%d\n", RIS_srv_write_len,
						RIS_srv_write_size));
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}

				/*
				**	Now, load the variable length data
				*/

				/*
				**	input data --	VERY IMPORTANT: Because we are using the
				**				same buffer that we read the data from the
				**				the application, the data is already in place.
				*/

				/* input sqlvars */
				if (sql->input->sqld)
				{
					memcpy((pddo->data + pddo->in_sqlvar), sql->input->sqlvar,
						sizeof(internal_sqlvar) * sql->input->sqld);
				}

				/* the output sqlvars */
				memcpy((pddo->data + pddo->out_sqlvar), sql->output->sqlvar,
					sizeof(internal_sqlvar) * sql->output->sqld);

				/* the query */
				memcpy((pddo->data + pddo->query), sql->query, pddo->query_len);

				if (RISbuf_debug)
				{
					unsigned int i;

					RIScom_output_debug("USRsend_rec: RIS_PREP_DESC_DECL_OPEN_CODE\n");
					RIScom_output_debug("\tin_data(offset):%d\n", pddo->in_data);
					RIScom_output_debug("\tin_sqlvar(offset):%d\n", pddo->in_sqlvar);
					RIScom_output_debug("\tout_sqlvar(offset):%d\n", pddo->out_sqlvar);
					RIScom_output_debug("\tquery(offset):%d\n", pddo->query);
					RIScom_output_debug("\tin_count:%d\n", pddo->in_count);
					RIScom_output_debug("\tout_count:%d\n", pddo->out_count);
					RIScom_output_debug("\tquery_len:%d\n", pddo->query_len);
					RIScom_output_debug("\tstmt_type:%s\n",
						RIScom_get_stmt_type_name(pddo->stmt_type));

					RIScom_output_debug("\tinput data:\n");
					RIScco_output_internal_data(RIScom_output_debug, sql->input->sqld,
						sql->input->sqlvar,
						(char *)(pddo->data + pddo->in_data), 2);

					RIScom_output_debug("\tinput sqlvars:\n");
					for (i = 0; i < pddo->in_count; i++)
					{
						RIScom_output_debug("\t\tinternal_sqlvar[%d]:\n", i);
						RIScco_output_internal_sqlvar(RIScom_output_debug,
							(internal_sqlvar *)(pddo->data+pddo->in_sqlvar),3);
					}

					RIScom_output_debug("\toutput sqlvars:\n");
					for (i = 0; i < pddo->in_count; i++)
					{
						RIScom_output_debug("\t\tinternal_sqlvar[%d]:\n", i);
						RIScco_output_internal_sqlvar(RIScom_output_debug,
							(internal_sqlvar *)(pddo->data+pddo->in_sqlvar),3);
					}

					RIScom_output_debug("\tquery:<%s>\n", pddo->data+pddo->query);
				}
				PDDO_TO_NET(arc, sql, pddo);
			}
			break;

/*************   

			BLOB **

*************/

			case RIS_EXEC_BLOB_CODE:
			{
				struct ris_clisrv_buf_exec_blob *eb 
								= &RIS_srv_write->buf.exec_blob;

#ifdef OLD
				/*
				**	Make sure the data aligns with the data already in
				**	the buffer.
				*/
				if ((int)&(((ris_appcli_buf *)0)->buf.exec_blob.data) !=
					(int)&(((ris_clisrv_buf *)0)->buf.exec_blob.data))
				{
					USR_DBG(("RISusr_send_rec:ERROR:data fields dont align\n"));
					 LONGJMP(RIS_E_INTERNAL_ERROR);
				}
#endif

				/*
				**	Test if the buffer is large enough
				*/

				RIS_srv_write_len = 
					(int)&(((ris_clisrv_buf *)0)->buf.exec_blob.data) + 
					eb->xfcount;
					
						
				if (RIS_srv_write_len > RIS_srv_write_size)
				{
					USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
						"RIS_srv_write_size:%d\n", RIS_srv_write_len,
						RIS_srv_write_size));
					 LONGJMP(RIS_E_INTERNAL_ERROR);
				}

				EB_TO_NET(arc, eb);

				if (RISbuf_debug)
				{

					RIScom_output_debug("USRsend_rec: RIS_EXEC_BLOB_CODE\n");
					RIScom_output_debug("\txfcount:%d\n", eb->xfcount);
					RIScom_output_debug("\tmore_to_follow:%d\n", eb->more_to_follow);
					RIScom_output_debug("\tfile_used:%d\n", eb->file_used);

				}
			}
			break;

			case RIS_FETCH_BLOB_CODE:
		
			if (RIS_srv_write_len > RIS_srv_write_size)
			{
				USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
					"RIS_srv_write_size:%d\n", RIS_srv_write_len,
					RIS_srv_write_size));
				 LONGJMP(RIS_E_INTERNAL_ERROR);
			}

			FETCH_BLOB_TO_NET(arc, &RIS_srv_write->buf.fetch_blob);
		
			break;

			case RIS_PREP_EXEC_DEFERRED_CODE:
			case RIS_PREP_EXEC_CODE:
			{
				struct ris_clisrv_buf_pe *pe = &RIS_srv_write->buf.pe;

				/*
				**	First, we load the fixed length data.  While doing
				**	this we can also calculate the size of the the variable
				**	length data and set up the pointers into the data section
				*/

				/* statement type */
				pe->stmt_type = sql->stmt_type;

				/*
				**	input data --	VERY IMPORTANT: Because we are using the
				**				same buffer that we read the data from the
				**				the application, the data is already in place.
				**				The data should always be the first the in 
				**				the buffer and the offset should always be 0.
				*/
				pe->in_data = offset;
				if (sql->input->sqld)
				{
					offset += sql->input_len;
				}

				/* input sqlvars */
				ALIGN_OFFSET(offset, double);
				pe->in_sqlvar = offset;
				pe->in_count = sql->input->sqld;
				offset += sql->input->sqld * sizeof(internal_sqlvar);

				/* the query */
				ALIGN_OFFSET(offset, char);
				pe->query = offset;
				pe->query_len = strlen(sql->query) + 1;
				offset += pe->query_len;

				/*
				**	Test if the buffer is large enough
				*/
				RIS_srv_write_len =
					(int)&(((ris_clisrv_buf *)0)->buf.pe.data) + offset;
				if (RIS_srv_write_len > RIS_srv_write_size)
				{
					USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
						"RIS_srv_write_size:%d\n", RIS_srv_write_len,
						RIS_srv_write_size));
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}

				/*
				**	Now, load the variable length data
				*/

				/*
				**	input data --	VERY IMPORTANT: Because we are using the
				**				same buffer that we read the data from the
				**				the application, the data is already in place.
				*/

				/* input sqlvars */
				if (sql->input->sqld)
				{
					memcpy((pe->data + pe->in_sqlvar), sql->input->sqlvar,
						sizeof(internal_sqlvar) * sql->input->sqld);
				}

				/* the query */
				memcpy((pe->data + pe->query), sql->query, pe->query_len);

				if (RISbuf_debug)
				{
					unsigned int i;

					RIScom_output_debug("USRsend_rec: RIS_PREP_EXEC_CODE\n");
					RIScom_output_debug("\tin_data(offset):%d\n", pe->in_data);
					RIScom_output_debug("\tin_sqlvar(offset):%d\n", pe->in_sqlvar);
					RIScom_output_debug("\tquery(offset):%d\n", pe->query);
					RIScom_output_debug("\tin_count:%d\n", pe->in_count);
					RIScom_output_debug("\tquery_len:%d\n", pe->query_len);
					RIScom_output_debug("\tstmt_type:<%s>\n",
						RIScom_get_stmt_type_name(pe->stmt_type));

					RIScom_output_debug("\tinput data:\n");
					RIScco_output_internal_data(RIScom_output_debug, sql->input->sqld,
						sql->input->sqlvar,
						(char *)(pe->data + pe->in_data), 2);

					RIScom_output_debug("\tinput sqlvars:\n");
					for (i = 0; i < pe->in_count; i++)
					{
						RIScom_output_debug("\t\tsqlvar[%d]:\n", i);
						RIScco_output_internal_sqlvar(RIScom_output_debug,
							/****  BUG ********/
                           (internal_sqlvar *)(pe->data + pe->in_sqlvar +
                           sizeof(internal_sqlvar) *i), 3);
					}

					RIScom_output_debug("\tquery:<%s>\n", pe->data+pe->query);
				}
				PE_TO_NET(arc, sql, pe);
			}
			break;


			case RIS_OPEN_CODE:
			{
				struct ris_clisrv_buf_open *open = &RIS_srv_write->buf.open;

				/*
				**	First, we load the fixed length data.  While doing
				**	this we can also calculate the size of the the variable
				**	length data and set up the pointers into the data section
				*/

				/* Load dbms */
				open->dbms = sql->dbms;

				/*
				**	old statement id;
				*/
				open->old_stmt_id = RIS_stmt->old_stmt_id;

				/*
				**	input data --	VERY IMPORTANT: Because we are using the
				**				same buffer that we read the data from the
				**				the application, the data is already in place.
				**				The data should always be the first the in 
				**				the buffer and the offset should always be 0.
				*/
				open->in_data = offset;
				if (sql->input->sqld)
				{
					offset += sql->input_len;
				}


				RIS_srv_write_len =
					(int)&(((ris_clisrv_buf *)0)->buf.open.data) + offset;
				if (RIS_srv_write_len > RIS_srv_write_size)
				{
					USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
						"RIS_srv_write_size:%d\n", RIS_srv_write_len,
						RIS_srv_write_size));
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}

				/*
				**	input data --	VERY IMPORTANT: Because we are using the
				**				same buffer that we read the data from the
				**				the application, the data is already in place.
				*/

				if (RISbuf_debug)
				{
					RIScom_output_debug("USRsend_rec: RIS_OPEN_CODE\n");
					RIScom_output_debug("\tdbms:%d\n", open->dbms);
					RIScom_output_debug("\told_stmt_id:%d\n", open->old_stmt_id);
					RIScom_output_debug("\tin_data(offset):%d\n", open->in_data);

					RIScom_output_debug("\tinput data:\n");
					RIScco_output_internal_data(RIScom_output_debug, sql->input->sqld,
						sql->input->sqlvar,
						(char *)(open->data + open->in_data), 2);
				}
				OPEN_TO_NET(arc, sql, open);
			}
			break;


			case RIS_EXEC_DEFERRED_CODE:
			case RIS_EXEC_CODE:
			{
				struct ris_clisrv_buf_exec *exec = &RIS_srv_write->buf.exec;

				/*
				**	First, we load the fixed length data.  While doing
				**	this we can also calculate the size of the the variable
				**	length data and set up the pointers into the data section
				*/

				/* dbms */
				exec->dbms = sql->dbms;

				/*
				**	old statement id;
				*/
				exec->old_stmt_id = RIS_stmt->old_stmt_id;

				/* input data */
				/*
				**	input data --	VERY IMPORTANT: Because we are using the
				**				same buffer that we read the data from the
				**				the application, the data is already in place.
				**				The data should always be the first the in 
				**				the buffer and the offset should always be 0.
				*/
				exec->in_data = offset;
				if (sql->input->sqld)
				{
					offset += sql->input_len;
				}

				RIS_srv_write_len =
					(int)&(((ris_clisrv_buf *)0)->buf.exec.data) + offset;
				if (RIS_srv_write_len > RIS_srv_write_size)
				{
					USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
						"RIS_srv_write_size:%d\n", RIS_srv_write_len,
						RIS_srv_write_size));
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}

				/*
				**	input data --	VERY IMPORTANT: Because we are using the
				**				same buffer that we read the data from the
				**				the application, the data is already in place.
				*/

				if (RISbuf_debug)
				{
					RIScom_output_debug("USRsend_rec: RIS_EXEC_CODE\n");
					RIScom_output_debug("\tdbms:%d\n", exec->dbms);
					RIScom_output_debug("\told_stmt_id:%d\n", exec->old_stmt_id);
					RIScom_output_debug("\tin_data(offset):%d\n", exec->in_data);

					RIScom_output_debug("\tinput data:\n");
					RIScco_output_internal_data(RIScom_output_debug, sql->input->sqld,
						sql->input->sqlvar,
						(char *)(exec->data + exec->in_data), 2);
				}
				EXEC_TO_NET(arc, sql, exec);
			}
			break;

/*********         BLOB          *********/
			case RIS_FETCH_BUF_CODE:
			{
				struct ris_clisrv_buf_fetch *fetch=
					&RIS_srv_write->buf.fetch;

				RIS_srv_write->buf.fetch.dbms = sql->dbms;
				RIS_srv_write->buf.fetch.row_count = (int)sql->misc;
				RIS_srv_write->buf.fetch.old_stmt_id = RIS_stmt->old_stmt_id;

				RIS_srv_write_len = 
					(int)&(((ris_clisrv_buf *)0)->buf.fetch.data) + 
						fetch->out_data+fetch->file_names;

				if (RISbuf_debug)
				{
					RIScom_output_debug("RISusr_send: RIS_FETCH_BUF_CODE\n");
					RIScom_output_debug("\tdbms:0x%x\n", RIS_srv_write->buf.fetch.dbms);
					RIScom_output_debug("\trow_count:%d\n",
						RIS_srv_write->buf.fetch.row_count);
					RIScom_output_debug("\told_stmt_id:%d\n",
						RIS_srv_write->buf.fetch.old_stmt_id);
				}
				/* We have data to be converted */ 
				FETCH_TO_NET(arc,&RIS_srv_write->buf.fetch);		
			}
			break;
/*********         BLOB          *********/

			case RIS_FETCH_BUF_CODE_4:
			{
				RIS_srv_write->buf.fetch_4.dbms = sql->dbms;
				RIS_srv_write->buf.fetch_4.row_count = (int)sql->misc;
				RIS_srv_write->buf.fetch_4.old_stmt_id = RIS_stmt->old_stmt_id;
				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE + sizeof(RIS_srv_write->buf.fetch_4);

				if (RISbuf_debug)
				{
					RIScom_output_debug("RISusr_send: RIS_FETCH_BUF_CODE\n");
					RIScom_output_debug("\tdbms:0x%x\n", RIS_srv_write->buf.fetch_4.dbms);
					RIScom_output_debug("\trow_count:%d\n",
						RIS_srv_write->buf.fetch_4.row_count);
					RIScom_output_debug("\told_stmt_id:%d\n",
						RIS_srv_write->buf.fetch_4.old_stmt_id);
				}

				/* dbms doesn't need to be converted */
				ARC_INTEGER_TO_NET(arc, &RIS_srv_write->buf.fetch_4.row_count);
				ARC_SHORT_TO_NET(arc, &RIS_srv_write->buf.fetch_4.old_stmt_id);
			}
			break;
/*********         BLOB          *********/
			case RIS_GET_TAB_CODE:
			case RIS_GET_TAB_NOVERIFY_CODE:
/*********         BLOB          *********/
			case RIS_GET_TABTYPE_CODE:
			{
				 strcpy(RIS_srv_write->buf.get_tab.tabname, 
					sql->query);

				USR_DBG(("table name:<%s>\n", 
				RIS_srv_write->buf.get_tab.tabname));

				RIS_srv_write_len = RIS_CLISRV_HDR_SIZE +
					sizeof(RIS_srv_write->buf.get_tab);

				ARC_DATA_TO_NET(arc, RIS_srv_write->buf.get_tab.tabname,
					RIS_MAX_ID_SIZE);
			}
			break;

			case RIS_GET_SCHEMA_GRANTORS_CODE: /* formerly INQUIRE_SCHREF */
			{
				memcpy(RIS_srv_write->buf.get_schema_grantors.schname,
					sql->query, RIS_MAX_ID_SIZE);

				RIS_srv_write_len = RIS_CLISRV_HDR_SIZE +
					sizeof(RIS_srv_write->buf.get_schema_grantors);

				ARC_DATA_TO_NET(arc,
					RIS_srv_write->buf.get_schema_grantors.schname,
					RIS_MAX_ID_SIZE);
			}
			break;

			case RIS_ALT_SCHEMA_INCLUDE_CODE:
			{
 				
 				struct ris_clisrv_buf_alt_schema *al_sch =
 				&RIS_srv_write->buf.alt_schema;
 				al_sch->tabtype = (char)sql->stmt_type;
 				memcpy(al_sch->tabowner,
 					sql->relowner, RIS_MAX_ID_SIZE);
 				memcpy(al_sch->extern_tabname,
 				sql->relname, RIS_MAX_ID_SIZE);
 				USR_DBG(("table user and table name:<%s> <%s>\n", 
				al_sch->tabowner, al_sch->extern_tabname));
 				RIS_srv_write_len = RIS_CLISRV_HDR_SIZE +
 					sizeof(RIS_srv_write->buf.alt_schema);

 				ARC_CHARACTER_TO_NET(arc, &al_sch->tabtype);
 				ARC_DATA_TO_NET(arc, al_sch->tabowner, RIS_MAX_ID_SIZE);

 				ARC_DATA_TO_NET(arc, al_sch->extern_tabname, RIS_MAX_ID_SIZE);
 				al_sch->col_count = sql->input_len;
                                /* Column count should be converted below.  Error to do it here.*/
 				if (!sql->query)
 				{
 						/* simple case : no renaming */
 					memcpy(al_sch->tabname, sql->relname, RIS_MAX_ID_SIZE);
 				}
 				else
 				{
 					memcpy(al_sch->tabname, sql->query, RIS_MAX_ID_SIZE);
 					
 
 					/*  The array of column names starts at
 						alt_sch->data ; 
 						No alignment is done, since we are passing
 						only one type of data and it is character
 						type. Issues with Internationalization ????
 						
 						Shiva 2-23-94
 					*/
 
 					offset = al_sch->col_count * RIS_MAX_ID_SIZE;

 					RIS_srv_write_len =
 						(int)&(((ris_clisrv_buf *)0)->buf.alt_schema.data) +
 					offset;

 					if (RIS_srv_write_len > RIS_srv_write_size)
 					{
 					USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
 						"RIS_srv_write_size:%d\n", RIS_srv_write_len,
 						RIS_srv_write_size));
 					LONGJMP(RIS_E_INTERNAL_ERROR);
 					}
 
 					/*
 					**	Load the variable length data
 					*/
 
 					/* column names */
 					memcpy(al_sch->data , &sql->query[RIS_MAX_ID_SIZE],
 						offset);
 	
 					if (RISbuf_debug)
 					{
 						unsigned int i;
 						char *cptr;
 
 						RIScom_output_debug("USRsend_rec: RIS_ALTER_SCHEMA_CODE\n");
 						RIScom_output_debug("\tinternal tabname:%s\n", 
 							al_sch->tabname);
 						RIScom_output_debug("\tcol_count:%d\n", al_sch->col_count);
 						RIScom_output_debug("\tcolumn names:\n");
 						for (i = 0, cptr= al_sch->data; 
 									i < al_sch->col_count; 
 									i++, cptr += RIS_MAX_ID_SIZE)
 						{
 							RIScom_output_debug("\t\t%s:\n", cptr);
 						}
 					}
	 				ARC_INTEGER_TO_NET(arc, &al_sch->col_count);
 					ARC_DATA_TO_NET(arc, al_sch->data, offset);

 				} /* if !sql->query */
 				ARC_DATA_TO_NET(arc, al_sch->tabname, RIS_MAX_ID_SIZE);
 			}
 			break;
 			case RIS_ALT_SCHEMA_EXCLUDE_CODE:
 			{
 				
 				struct ris_clisrv_buf_alt_schema *al_sch =
 				&RIS_srv_write->buf.alt_schema;
 				al_sch->tabtype = (char)sql->stmt_type;
 				memcpy(al_sch->tabname,
 				sql->relname, RIS_MAX_ID_SIZE);
 				USR_DBG(("table name:<%s> \n", 
 				al_sch->tabname));

				RIS_srv_write_len = RIS_CLISRV_HDR_SIZE +
					sizeof(RIS_srv_write->buf.alt_schema);

 				ARC_CHARACTER_TO_NET(arc, &al_sch->tabtype);
 				ARC_DATA_TO_NET(arc, al_sch->tabname, RIS_MAX_ID_SIZE);

			}
			break;

			case RIS_DROP_TABLE_CODE:
			case RIS_DROP_VIEW_CODE:
			{
				struct 	ris_clisrv_buf_drop *drop = &RIS_srv_write->buf.drop;

				/*
				**	Load the fixed len data
				*/
                USR_DBG(("RISusr_send_rec: sql->ris_relname:<%s>\n ",
                    sql->ris_relname));
                USR_DBG(("RISusr_send_rec: sql->ext_relname:<%s>\n ",
                    sql->ext_relname));
                USR_DBG(("RISusr_send_rec: sql->relowner:<%s>\n ",
                    sql->relowner));
				memcpy(drop->ris_relname, sql->ris_relname, RIS_MAX_ID_SIZE);
				memcpy(drop->ext_relname, sql->ext_relname, RIS_MAX_ID_SIZE);
				memcpy(drop->relowner, sql->relowner, RIS_MAX_ID_SIZE);

				RIS_srv_write_len = RIS_CLISRV_HDR_SIZE +
					sizeof(RIS_srv_write->buf.drop);

				ARC_DATA_TO_NET(arc, drop->ris_relname, RIS_MAX_ID_SIZE);
				ARC_DATA_TO_NET(arc, drop->ext_relname, RIS_MAX_ID_SIZE);
				ARC_DATA_TO_NET(arc, drop->relowner, RIS_MAX_ID_SIZE);
			}
			break;
			
			case RIS_DROP_INDEX_CODE:
			{
				struct 	ris_clisrv_buf_drop_index *drop_idx = 
							&RIS_srv_write->buf.drop_idx;
				/*
				**	Load the fixed len data
				*/
                USR_DBG(("RISusr_send_rec: sql->ris_relname:<%s>\n ",
                    sql->ris_relname));
				memcpy(RIS_srv_write->buf.drop_idx.ris_idxname, 
					sql->ris_relname, RIS_MAX_ID_SIZE);

				RIS_srv_write_len = RIS_CLISRV_HDR_SIZE +
					sizeof(RIS_srv_write->buf.drop_idx);

				ARC_DATA_TO_NET(arc, drop_idx->ris_idxname, RIS_MAX_ID_SIZE);
			}
			break;

			case RIS_GET_ACCESS_CODE:
			case RIS_GET_ALL_ACCESS_CODE:
			{
				struct ris_clisrv_buf_get_access *get_access = 
					&RIS_srv_write->buf.get_access;
				
				RISusr_access_to_access_info((risaccess *)sql->query,
					&get_access->data);

				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE + sizeof(RIS_srv_write->buf.get_access);

				GET_ACCESS_TO_NET(arc, get_access);
			}
			break;

			case RIS_CREATE_TABLE_CODE:
			{
				int def_string_len;

				struct ris_clisrv_buf_create_table *cr_tab =
					&RIS_srv_write->buf.create_table;

				/*
				**	First load in the fixed length data
				*/
                /* internal table name */
                USR_DBG(("RISusr_send_rec: sql->ris_relname:<%s>\n ",
                    sql->ris_relname));
                USR_DBG(("RISusr_send_rec: sql->ext_relname:<%s>\n ",
                    sql->ext_relname));
                strcpy(cr_tab->ris_relname, sql->ris_relname);
                strcpy(cr_tab->ext_relname, sql->ext_relname);

				/* column definition sqlvars */
				ALIGN_OFFSET(offset, double);
				cr_tab->col_sqlvar = offset;
				cr_tab->col_count = sql->input->sqln;
				offset += sql->input->sqln * sizeof(internal_sqlvar);


				/* definition string */
				ALIGN_OFFSET(offset, char);
				cr_tab->def_string = offset;
				def_string_len = strlen(sql->query) + 1;
				offset += def_string_len;

				RIS_srv_write_len =
					(int)&(((ris_clisrv_buf *)0)->buf.create_table.data) +
					offset;
				if (RIS_srv_write_len > RIS_srv_write_size)
				{
					USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
						"RIS_srv_write_size:%d\n", RIS_srv_write_len,
						RIS_srv_write_size));
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}

				/*
				**	Load the variable length data
				*/

				/* column definition sqlvars */
				memcpy((cr_tab->data + cr_tab->col_sqlvar), sql->input->sqlvar,
					(sizeof(internal_sqlvar) * sql->input->sqln));

				/* definition string */
				memcpy((cr_tab->data + cr_tab->def_string), sql->query,
					def_string_len);

				if (RISbuf_debug)
				{
					unsigned int i;

					RIScom_output_debug("USRsend_rec: RIS_CREATE_TABLE_CODE\n");
					RIScom_output_debug("\tcol_sqlvar(offset):%d\n", 
						cr_tab->col_sqlvar);
					RIScom_output_debug("\tdef_string(offset):%d\n", 
						cr_tab->def_string);
					RIScom_output_debug("\tcol_count:%d\n", cr_tab->col_count);
					RIScom_output_debug("\tcolumn sqlvars:\n");
					for (i = 0; i < cr_tab->col_count; i++)
					{
						RIScom_output_debug("\t\tinternal_sqlvar[%d]:\n", i);
						RIScco_output_internal_sqlvar(RIScom_output_debug,
							(internal_sqlvar *)(cr_tab->data + cr_tab->col_sqlvar), 3);
					}
					RIScom_output_debug("\tdef_string:<%s>\n",
						cr_tab->data+cr_tab->def_string);
				}
				CREATE_TABLE_TO_NET(arc, cr_tab);
			}
			break;

			case RIS_CREATE_INDEX_CODE:
			{
				int def_string_len;
				int	i;

				struct ris_clisrv_buf_create_index *create_index =
					&RIS_srv_write->buf.create_index;

				/*
				**	First load in the fixed length data
				*/

				/* definition string */
				ALIGN_OFFSET(offset, char);
				create_index->def_string = offset;
				def_string_len = strlen(sql->query) + 1;
				offset += def_string_len;

				/* column definition sqlvars */
				ALIGN_OFFSET(offset, double);
				create_index->int_col_names = offset;
				create_index->col_count = sql->input->sqln;
				offset += sql->input->sqln * RIS_MAX_ID_SIZE;

                USR_DBG(("RISusr_send_rec: sql->ris_relname:<%s>\n ",
                    sql->ris_relname));
                USR_DBG(("RISusr_send_rec: sql->ext_relname:<%s>\n ",
                    sql->ext_relname));
                USR_DBG(("RISusr_send_rec: sql->relname:<%s>\n ",
                    sql->relname));
/*
**	Format specifier for the following DEBUG statement is changed
**	%c from %s which was causing an exception in risclient when
**	USR debug is turned on. Fix for TR# 249403288. RAJU
*/
                USR_DBG(("RISusr_send_rec: sql->reltype:<%c>\n ",
                    sql->reltype));
                strcpy(create_index->ris_index_name,sql->ris_relname);
                strcpy(create_index->ext_index_name,sql->ext_relname);
                strcpy(create_index->ris_table_name,sql->relname);
                create_index->index_type = sql->reltype;

				RIS_srv_write_len =
					(int)&(((ris_clisrv_buf *)0)->buf.create_index.data) +
					offset;
				if (RIS_srv_write_len > RIS_srv_write_size)
				{
					USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
						"RIS_srv_write_size:%d\n", RIS_srv_write_len,
						RIS_srv_write_size));
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}

				/*
				**	Load the variable length data
				*/

				/* definition string */
				memcpy((create_index->data + create_index->def_string),
					sql->query, def_string_len);

				/* column definition sqlvars */
				for (i=0;i<sql->input->sqln;i++)
				{
					memcpy((create_index->data + create_index->int_col_names
							+ i*RIS_MAX_ID_SIZE), 
							sql->input->sqlvar[i].sqlname.sqlnamec,
							RIS_MAX_ID_SIZE);
				}

				ARC_STRING_TO_NET(arc, 
					(char *)(create_index->data + create_index->def_string));
				ARC_INTEGER_TO_NET(arc, &create_index->def_string);
				ARC_STRING_TO_NET(arc, 
					(char *)(create_index->data + create_index->int_col_names));
				ARC_INTEGER_TO_NET(arc, &create_index->int_col_names);
				ARC_INTEGER_TO_NET(arc, &create_index->col_count);
			}
			break;

			case RIS_CREATE_VIEW_CODE:
			{
				int dbms_string_len;
				int ris_string_len;
				struct ris_clisrv_buf_create_view *create_view =
					&RIS_srv_write->buf.create_view;

				/*
				**	First, load the fixed length data
				*/
                USR_DBG(("RISusr_send_rec: sql->ris_relname:<%s>\n ",
                    sql->ris_relname));
                USR_DBG(("RISusr_send_rec: sql->ext_relname:<%s>\n ",
                    sql->ext_relname));
                strcpy(create_view->ris_relname, sql->ris_relname);
                strcpy(create_view->ext_relname, sql->ext_relname);

				/* column definition sqlvars */
				ALIGN_OFFSET(offset, double);
				create_view->col_sqlvar = offset;
				create_view->col_count = sql->input->sqln;
			offset += sql->input->sqln * sizeof(internal_sqlvar);

			/* dbms definition string */
			ALIGN_OFFSET(offset, char);
			create_view->dbms_string = offset;

			dbms_string_len = strlen(sql->query) + 1;
			offset += dbms_string_len;

			/* ris definition string */
			ALIGN_OFFSET(offset, char);
			create_view->ris_string = offset;

			ris_string_len = strlen(RIS_stmt->view_string) + 1;
			offset += ris_string_len;

			RIS_srv_write_len =
				(int)&(((ris_clisrv_buf *)0)->buf.create_view.data) +
				offset;
			if (RIS_srv_write_len > RIS_srv_write_size)
			{
				USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
					"RIS_srv_write_size:%d\n", RIS_srv_write_len,
					RIS_srv_write_size));
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}

			/*
			**	Now, load the variable length data
			*/

			/* column definition sqlvars */
				memcpy((create_view->data + create_view->col_sqlvar),
					sql->input->sqlvar, (sizeof(internal_sqlvar) * sql->input->sqln));

				/* dbms definition string */
				memcpy((create_view->data + create_view->dbms_string),
					sql->query, dbms_string_len);

				/* ris definition string */
				memcpy((create_view->data + create_view->ris_string),
					RIS_stmt->view_string,ris_string_len);

				if (RISbuf_debug)
				{
					unsigned int i;

					RIScom_output_debug("RISusr_send: RIS_CREATE_VIEW_CODE\n");
					RIScom_output_debug("\tcol_sqlvar(offset):%d\n",
						create_view->col_sqlvar);
					RIScom_output_debug("\tdbms_string(offset):%d\n",
						create_view->dbms_string);
					RIScom_output_debug("\tris_string(offset)%d\n", 
						create_view->ris_string);
					RIScom_output_debug("\tcol_count:%d\n", create_view->col_count);
					RIScom_output_debug("\tcolumn sqlvars:\n");
					for (i = 0; i < create_view->col_count; i++)
					{
						RIScom_output_debug("\t\tinternal_sqlvar[%d]:\n", i);
						RIScco_output_internal_sqlvar(RIScom_output_debug,
							(internal_sqlvar *)(create_view->data +
							create_view->col_sqlvar), 3);
					}
					RIScom_output_debug("\tdbms_string:<%s>\n",
						(create_view->data+create_view->dbms_string));
					RIScom_output_debug("\tris_string:<%s>\n",
						(create_view->data+create_view->ris_string));
				}
				CREATE_VIEW_TO_NET(arc, create_view);
			}
			break;

			case RIS_ALTER_TABLE_CODE:
			{
				int def_string_len;
				struct ris_clisrv_buf_alter_table *alter_table =
					&RIS_srv_write->buf.alter_table;

				/*
				**	First, load the fixed length data
				*/

				/* the single column definition sqlvar */
				memcpy(&alter_table->col_sqlvar, sql->input->sqlvar,
					sizeof(internal_sqlvar));

				/* the definition string */
				ALIGN_OFFSET(offset, char);
				alter_table->def_string = offset;
				def_string_len = strlen(sql->query) + 1;
				offset += def_string_len;

				RIS_srv_write_len =
					(int)&(((ris_clisrv_buf *)0)->buf.alter_table.data) +
					offset;
				if (RIS_srv_write_len > RIS_srv_write_size)
				{
					USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
						"RIS_srv_write_size:%d\n", RIS_srv_write_len,
						RIS_srv_write_size));
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}

				/*
				**	Now, load the variable length data
				*/

				/* definition string */
				memcpy((alter_table->data + alter_table->def_string),
					sql->query, def_string_len);

				ALTER_TABLE_TO_NET(arc, alter_table);
			}
			break;

			case RIS_EXEC_NOW_CODE:
			{
				int string_len;
				struct ris_clisrv_buf_exec_now *exec_now =
					&RIS_srv_write->buf.exec_now;

				/*
				**	First, load the fixed length data
				*/

				/* the exec_now string */
				ALIGN_OFFSET(offset, char);
				exec_now->string = offset;
				string_len = strlen(sql->query) + 1;
				offset += string_len;

				/* statement type */
				exec_now->stmt_type = sql->stmt_type;

				RIS_srv_write_len =
					(int)&(((ris_clisrv_buf *)0)->buf.exec_now.data) + offset;
				if (RIS_srv_write_len > RIS_srv_write_size)
				{
					USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
						"RIS_srv_write_size:%d\n", RIS_srv_write_len,
						RIS_srv_write_size));
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}

				/*
				**	Now, load the variable length data
				*/

				/* the exec_now string */
				memcpy((exec_now->data + exec_now->string), sql->query,
					string_len);

				if (RISbuf_debug)
				{
					RIScom_output_debug("RISusr_send: RIS_EXEC_NOW_CODE\n");
					RIScom_output_debug("\tstring(offset):%d\n",
						exec_now->string);
					RIScom_output_debug("\tstmt_type:<%s>\n",
						RIScom_get_stmt_type_name(exec_now->stmt_type));
					RIScom_output_debug("\texec_now string:<%s>\n",
						exec_now->data+exec_now->string);
				}

				ARC_DATA_TO_NET(arc,(char *)(exec_now->data + exec_now->string),
					string_len);
				ARC_INTEGER_TO_NET(arc, &exec_now->string);
				/* stmt_type doesn't need to be converted */
			}
			break;

			case RIS_LOCK_TABLES_CODE:
			{
				int string_len;
				struct ris_clisrv_buf_lock_tables *lock_tables =
					&RIS_srv_write->buf.lock_tables;

				/*
				**	First, load the fixed length data
				*/

				/* the lock_tables string */
				ALIGN_OFFSET(offset, char);
				lock_tables->string = offset;
				string_len = strlen(sql->query) + 1;
				offset += string_len;

				RIS_srv_write_len =
					(int)&(((ris_clisrv_buf *)0)->buf.lock_tables.data) +
					offset;
				if (RIS_srv_write_len > RIS_srv_write_size)
				{
					USR_DBG(("RISusr_send_rec: ERROR: RIS_srv_write_len:%d > "
						"RIS_srv_write_size:%d\n", RIS_srv_write_len,
						RIS_srv_write_size));
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}

				/*
				**	Now, load the variable length data
				*/

				/* the lock_tables string */
				memcpy((lock_tables->data + lock_tables->string), sql->query,
					string_len);

				ARC_DATA_TO_NET(arc,
					(char *)(lock_tables->data + lock_tables->string),
					string_len);
				ARC_INTEGER_TO_NET(arc, &lock_tables->string);
			}
			break;

			case RIS_CRE_SCH_GET_GRANTEES_CODE:
			case RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE:
			{
				int i;
				ris_db_info *dbinfo;

				RIS_srv_write->buf.create_schema.max_rows = RIS_parms.max_rows;
				RIS_srv_write->buf.create_schema.max_buf_size =
					RIS_parms.max_buf_size;
				RIS_srv_write->buf.create_schema.debug =
					RIScom_debug_flags_to_mask();

				RIS_srv_write->buf.create_schema.maj=(char)RIS_version_maj;
				RIS_srv_write->buf.create_schema.min=(char)RIS_version_min;
				RIS_srv_write->buf.create_schema.rel=(char)RIS_version_rel;

				USR_DBG(("usrsndrc: LANGUAGE CODE:<%d>\n", RIS_language_code));
				RIS_srv_write->buf.create_schema.lang =
					(unsigned char)RIS_language_code;

				RISusr_schema_to_sch_intern_info(sql->schema, 
					&RIS_srv_write->buf.create_schema.schema);
				
				RISusr_db_to_db_info(sql->schema->db, 
					&RIS_srv_write->buf.create_schema.db);



				if (RIS_cli_license_bypass)  /* arw RIS License 2-8-94 */
                                  {   
                                      for (i=0,dbinfo=&RIS_srv_write->buf.create_schema.db; i<RIS_MAX_PROTOCOLS; i++)
                                        {
                                          if ((strncmp(dbinfo->pathways[i].netaddr, "NULL", 4)) == 0 ||
                                              (strlen(dbinfo->pathways[i].netaddr)) == 0 )
                                             {
                                                  strcpy(dbinfo->pathways[i].netaddr,"license bypass");
                                                  USR_DBG(("Setting RIS License Bypass enable\n"));
                                                  break;
                                              }
                                         }
                                  }   

/*
** Tweak the netaddrs so that NULLS are removed.
*/
for (i=0,dbinfo=&RIS_srv_write->buf.create_schema.db; i<RIS_MAX_PROTOCOLS; i++)
{
	if (strncmp(dbinfo->pathways[i].netaddr, "NULL", 4) == 0)
	{
		dbinfo->pathways[i].protocol = 0;
		memset(dbinfo->pathways[i].netaddr, 0, RIS_MAX_NODE_SIZE);
	}
}
				memcpy(RIS_srv_write->buf.create_schema.schpass,
					sql->schema->schpass, RIS_MAX_PASSWD_SIZE);

				RIS_srv_write->buf.create_schema.autocommit_flag =
					(unsigned char) RIS_autocommit;

				RIS_srv_write->buf.create_schema.blankstrip_flag =
					(unsigned char) RIS_blankstrip_mode;

				/* Sunil */
				RIS_srv_write->buf.create_schema.options_flag =
					(unsigned char) sql->misc;
					
				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE +
					sizeof(RIS_srv_write->buf.create_schema);

				CREATE_SCHEMA_TO_NET(arc, &RIS_srv_write->buf.create_schema);
			}
			break;

			case RIS_OPEN_SCHEMA_CODE:
			case RIS_ALTER_RACF_PWD_CODE:
			{
				int i;
				ris_db_info *dbinfo;

				RIS_srv_write->buf.schema_db.max_rows = RIS_parms.max_rows;
				RIS_srv_write->buf.schema_db.max_buf_size =
					RIS_parms.max_buf_size;
				RIS_srv_write->buf.schema_db.debug =
					RIScom_debug_flags_to_mask();

				RIS_srv_write->buf.schema_db.maj = (char)RIS_version_maj;
				RIS_srv_write->buf.schema_db.min = (char)RIS_version_min;
				RIS_srv_write->buf.schema_db.rel = (char)RIS_version_rel;

				USR_DBG(("usrsndrc: LANGUAGE CODE:<%d>\n", RIS_language_code));
				RIS_srv_write->buf.schema_db.lang = 
					(unsigned char)RIS_language_code;

				RISusr_schema_to_sch_intern_info(sql->schema, 
					&RIS_srv_write->buf.schema_db.schema);

				RISusr_db_to_db_info(sql->schema->db, 
					&RIS_srv_write->buf.schema_db.db);


				if (RIS_cli_license_bypass)                     /* arw RIS License 2-8-94 */
                                  {   
                                      for (i=0,dbinfo=&RIS_srv_write->buf.create_schema.db; i<RIS_MAX_PROTOCOLS; i++)
                                        {
                                          if ((strncmp(dbinfo->pathways[i].netaddr, "NULL", 4)) == 0 ||
                                              (strlen(dbinfo->pathways[i].netaddr)) == 0 )
                                             {
                                                  strcpy(dbinfo->pathways[i].netaddr,"license bypass");
                                                  USR_DBG(("Setting RIS License Bypass enable\n"));
                                                  break;
                                              }
                                         }
                                  }   


/*
** Tweak the netaddrs so that NULLS are removed.
*/
for (i=0,dbinfo=&RIS_srv_write->buf.schema_db.db; i<RIS_MAX_PROTOCOLS; i++)
{
	if (strncmp(dbinfo->pathways[i].netaddr, "NULL", 4) == 0)
	{
		dbinfo->pathways[i].protocol = 0;
		memset(dbinfo->pathways[i].netaddr, 0, RIS_MAX_NODE_SIZE);
	}
}

				memcpy(RIS_srv_write->buf.schema_db.schpass,
					sql->schema->schpass, RIS_MAX_PASSWD_SIZE);

				if (opcode == RIS_ALTER_RACF_PWD_CODE)
				{
					RIScom_pd(RIS_stmt->tree->lhs->rhs->rhs->info.val,
					 RIS_srv_write->buf.schema_db.newpasswd);
				}
					
				RIS_srv_write->buf.schema_db.autocommit_flag =
					(unsigned char) RIS_autocommit;

				RIS_srv_write->buf.schema_db.blankstrip_flag =
					(unsigned char) RIS_blankstrip_mode;

				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE + sizeof(RIS_srv_write->buf.schema_db);

				SCHEMA_DB_TO_NET(arc, &RIS_srv_write->buf.schema_db);
			}
			break;

			case RIS_DBG_CODE:
				RIS_srv_write->buf.debug.data = (int)sql->misc;
				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE + sizeof(RIS_srv_write->buf.debug);

				ARC_INTEGER_TO_NET(arc, &RIS_srv_write->buf.debug.data);
				break;

			case RIS_GROW_SRV_TO_CLI_BUF_CODE:
				RIS_srv_write->buf.grow.new_size = (int)sql->misc;
				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE + sizeof(RIS_srv_write->buf.grow);

				ARC_INTEGER_TO_NET(arc, &RIS_srv_write->buf.grow.new_size);
				break;

			case RIS_GROW_CLI_TO_SRV_BUF_CODE:
				RIS_srv_write->buf.grow.new_size = (int)sql->misc;
				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE + sizeof(RIS_srv_write->buf.grow);

				ARC_INTEGER_TO_NET(arc, &RIS_srv_write->buf.grow.new_size);
				break;

			case RIS_CREATE_USER_CODE:
			{
				memcpy(RIS_srv_write->buf.create_user.data, sql->query,
					RIS_MAX_ID_SIZE + 1);

				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE +
					sizeof(RIS_srv_write->buf.create_user);

				ARC_STRING_TO_NET(arc, RIS_srv_write->buf.create_user.data);
			}
			break;

			case RIS_NEW_SCHPASS_CODE:
			{
				memcpy(RIS_srv_write->buf.new_schpass.data, sql->query,
					RIS_MAX_PASSWD_SIZE);

				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE +
					sizeof(RIS_srv_write->buf.new_schpass);

				ARC_DATA_TO_NET(arc, RIS_srv_write->buf.new_schpass.data,
					RIS_MAX_PASSWD_SIZE);
			}
			break;

			case RIS_UPD_ACCESS_CODE:
				/* data is already in buffer */
				UPD_ACCESS_TO_NET(arc, &RIS_srv_write->buf.upd_access);
				break;

			case RIS_LOAD_RISDBS_CODE:
				/* data is already in buffer */
				if (RISbuf_debug)
				{
					unsigned int						i;
					ris_db_info							*dbs;
					struct ris_clisrv_buf_load_risdbs	*buf;

					buf = &RIS_srv_write->buf.load_risdbs;

					RIScom_output_debug("RISusr_send: RIS_LOAD_RISDBS_CODE\n");
					RIScom_output_debug("\tdbs(offset):%d\n", buf->dbs);
					RIScom_output_debug("\tdb_count:%d\n", buf->db_count);
					RIScom_output_debug("\tdelete_flag:%s\n", 
						buf->delete_flag?"YES":"NO");
					RIScom_output_debug("\tmore_to_follow:%s\n",
						buf->more_to_follow?"YES":"NO");
					for(i = 0, dbs = (ris_db_info *)(buf->data + buf->dbs);
						i < buf->db_count;
						i++, dbs++)
					{
						RIScom_output_debug("\tdb #%d:\n", i + 1);
						RIScom_output_db_info(RIScom_output_debug, dbs, 2);
					}
				}
				LOAD_RISDBS_TO_NET(arc, &RIS_srv_write->buf.load_risdbs);
				break;

			case RIS_LOAD_RISSCHEMAS_CODE:
				/* data is already in buffer */
				if (RISbuf_debug)
				{
					unsigned int							i;
					ris_schema_info							*schemas;
					struct ris_clisrv_buf_load_risschemas	*buf;

					buf = &RIS_srv_write->buf.load_risschemas;

					RIScom_output_debug("RISusr_send: RIS_LOAD_RISDBS_CODE\n");
					RIScom_output_debug("\tschemas(offset):%d\n", buf->schemas);
					RIScom_output_debug("\tschema_count:%d\n", buf->schema_count);
					RIScom_output_debug("\tdelete_flag:%s\n", 
						buf->delete_flag?"YES":"NO");
					RIScom_output_debug("\tmore_to_follow:%s\n",
						buf->more_to_follow?"YES":"NO");
					for(i = 0,
						schemas = (ris_schema_info *)(buf->data + buf->schemas);
						i < buf->schema_count;
						i++, schemas++)
					{
						RIScom_output_debug("\tschema #%d:\n", i + 1);
						RIScom_output_schema_info(RIScom_output_debug, schemas, 2);
					}
				}
				LOAD_RISSCHEMAS_TO_NET(arc,&RIS_srv_write->buf.load_risschemas);
				break;

			case RIS_DROP_SCHEMA_CODE:
				/* temporary change by goverdhan */
				/*
				RIS_srv_write_len = RIS_CLISRV_HDR_SIZE;
				*/
				RIS_srv_write_len = RIS_CLISRV_HDR_SIZE + 
				sizeof(RIS_srv_write->buf.drop_schema);

				if (RIS_stmt->tree->rhs->rhs && 
					(RIS_stmt->tree->rhs->rhs->lhs->tok == RIS_TOK_FORCE))
				{
					USR_DBG (("RISusr_send_rec: force_flag = 1\n"));
					RIS_srv_write->buf.drop_schema.force_flag = 1;
				}
				else
				{
					USR_DBG (("RISusr_send_rec: force_flag = 0\n"));
					RIS_srv_write->buf.drop_schema.force_flag = 0;
				}
				break;

			case RIS_CLOSE_CODE:
				RIS_srv_write->buf.close.old_stmt_id = RIS_stmt->old_stmt_id;
				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE + sizeof(RIS_srv_write->buf.close);

				if (RISbuf_debug)
				{
					RIScom_output_debug("RISusr_send: RIS_CLOSE_CODE\n");
					RIScom_output_debug("\told_stmt_id:%d\n",
						RIS_srv_write->buf.close.old_stmt_id);
				}

				ARC_SHORT_TO_NET(arc, &RIS_srv_write->buf.close.old_stmt_id);
				break;

			case RIS_CLEANUP_CODE:
				RIS_srv_write->buf.cleanup.old_stmt_id = RIS_stmt->old_stmt_id;
				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE + sizeof(RIS_srv_write->buf.cleanup);

				if (RISbuf_debug)
				{
					RIScom_output_debug("RISusr_send: RIS_CLEANUP_CODE\n");
					RIScom_output_debug("\told_stmt_id:%d\n",
						RIS_srv_write->buf.cleanup.old_stmt_id);
				}

				ARC_SHORT_TO_NET(arc, &RIS_srv_write->buf.cleanup.old_stmt_id);
				break;

			case RIS_GRANT_SCHEMA_CODE:
			case RIS_GRANT_CONNECT_CODE:
			case RIS_GRANT_RESOURCE_CODE:
			case RIS_REVOKE_SCHEMA_CODE:
			case RIS_REVOKE_CONNECT_CODE:
			case RIS_REVOKE_RESOURCE_CODE:
			{
				memcpy(RIS_srv_write->buf.grant_revoke.login, 
				RIS_stmt->tree->rhs->lhs->info.val, RIS_MAX_ID_SIZE);
				
				RIS_srv_write_len =
					RIS_CLISRV_HDR_SIZE +
					sizeof(RIS_srv_write->buf.grant_revoke);
				
				ARC_STRING_TO_NET(arc, 
					RIS_srv_write->buf.grant_revoke.login);
			}
				break;


			case RIS_CLOSE_SCHEMA_CODE:
			case RIS_BLANKSTRIP_ON_CODE:
			case RIS_BLANKSTRIP_OFF_CODE:
			case RIS_AUTOCOMMIT_ON_CODE:
			case RIS_AUTOCOMMIT_OFF_CODE:
			case RIS_COMMIT_WORK_CODE:
			case RIS_ROLLBACK_WORK_CODE:
			case RIS_GET_SCHEMA_GRANTEES_CODE:
			case RIS_ALT_SCHEMA_SECURE_CODE:
				RIS_srv_write_len = RIS_CLISRV_HDR_SIZE;
				break;

			default:
				USR_DBG(("RISusr_send_rec: invalid opcode:%d\n", opcode));
				LONGJMP(RIS_E_INTERNAL_ERROR); 
			break;
		}
		/*
		** Set the old_stmt_id to current_stmt_id. This is necessary if a swap
		** was executed on a superschema. The server needs to know new stmt_id.
		** ONLY for opcodes which require stmt_id on the server side.
		*/
		if( RIS_stmt &&
			(opcode == RIS_PREP_DESC_DECL_OPEN_CODE ||
			 opcode == RIS_PREP_EXEC_CODE ||
				/* BLOB support */
    			opcode == RIS_EXEC_DEFERRED_CODE ||
				opcode == RIS_PREP_EXEC_DEFERRED_CODE ||
   				opcode == RIS_EXEC_BLOB_CODE ||
  				opcode == RIS_FETCH_BUF_CODE ||
   				opcode == RIS_FETCH_BLOB_CODE ||
         		/* BLOB support */
			 opcode == RIS_OPEN_CODE ||
			 opcode == RIS_EXEC_CODE ||
			 opcode == RIS_FETCH_BUF_CODE_4 ||
			 opcode == RIS_CLOSE_CODE ||
			 opcode == RIS_CLEANUP_CODE ))
		{
			RIS_stmt->old_stmt_id = RIS_stmt->stmt_id;
			USR_DBG(("RISusr_send_rec: Updated old_stmt_id to %d\n",
				RIS_stmt->old_stmt_id));
		}
	}

	status = SETJMP();
	if (status)
	{
        /* When the network verification is ON, if the server sends back
            an error and if we LONGJMPed because of that we need to reset
            the srv_busy flag as the client will not process any other
            valid statement after that error. It will error out "server busy"
                    12/07/94    Radha

			TR#249407608  12/15/94
			The timestamp_interval is always set to > 0 for ASYNC_MODE,
			make sure we are not testing server completion  before
			setting srv_busy to 0.

										James

        TR#439409704 12/22/94
            Added checks for existence of sql, sql->schema and timestamp
            before the structures are referenced.
                                                    Radha


        */

        if ( (sql) && (sql->schema)
                    && (timestamp) && (timestamp->timestamp_interval)
                    && (status != STATEMENT_NOT_COMPLETE))
        {
            sql->schema->srv_busy = 0;
        }

		RESETJMP();

		USR_DBG(("RISusr_send_rec: got network error: %d\n", status));

		if ((status == RIS_E_SERVER_DIED ||
			status == RIS_E_SERVER_NETWORK_ERROR ||
			status == RIS_E_CANT_START_SERVER) &&
			opcode != RIS_ALTER_RACF_PWD_CODE &&
			opcode != RIS_CLOSE_SCHEMA_CODE &&
			opcode != RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE &&
			opcode != RIS_CRE_SCH_GET_GRANTEES_CODE &&
			opcode != RIS_OPEN_SCHEMA_CODE)
		{
			int			default_schema_died;
			int			default_schema_primary;

			schema = sql->schema;
			default_schema_died = (schema == RIS_default);
			default_schema_primary = schema->superschema_flag;
#if defined(unix) 
			RIScom_sighold(SIGCLD);
#endif
			RISusr_kill_srv(schema, CLOSE_NET, SYNC_MODE);
#if defined(unix) 
			RIScom_sigrelse(SIGCLD);
#endif

			if (SETJMP())
			{
				RISdic_remove_schema_no_transaction(schema);
				FREES(schema->schid);
				RIScco_clear_schema_id(schema->schid);
				if( default_schema_primary == REGULAR_SCHEMA )
				{
					status = (default_schema_died) ? RIS_E_DEFAULT_SCHEMA_DIED:
						RIS_E_SCHEMA_DIED;
				}
				else
				{
					status = RIS_E_SCHEMA_DIED;
				}
			}
			else
			{
				RISusr_server(schema, 0, 0);
				if (default_schema_died && 
				   (default_schema_primary == REGULAR_SCHEMA))
				{
					RIS_default = schema;
				}
				status = RIS_E_SCHEMA_RESTARTED;
			}
			RESETJMP();
		}
/* Fix for TR249407021 where the error messages for the V4 applications
were not returned (instead V5 error messages were returned) -Radha 11/18/94 */

		/* ERROR CODE MAPPING */
		if ( RIS_app_cli_version < 5)
		{
			switch(status){
			
				case RIS_E_UNKNOWN_INDEX : 
						status = RIS_E_DROP_INDEX; break;
				case RIS_E_CANNOT_INCLUDE :	
						status = RIS_E_UNKNOWN_RELATION; break;
				/* added by kmreddy - TR#249406985 */
				case RIS_E_INV_FETCH 	:
						status = RIS_E_INV_OPEN; break;
				default :
							break;
			}
		}
		LONGJMP(status);
	}

	if (IN_START_MODE(execute_mode))
	{
		if (sql->schema->srv_busy)
		{
			USR_DBG(("RISusr_send_rec: server already busy\n"));
			LONGJMP(RIS_E_SERVER_BUSY);
		}

		/*
		**  mark t1 time for NET VERIFY
		*/
		start_time = start_timer();

		USR_DBG(("RISusr_send_rec:calling NET_write,RIS_srv_write_len:%d\n",
			RIS_srv_write_len));
		NET_write(net, (char *)RIS_srv_write, &RIS_srv_write_len, BLOCKING);
		USR_DBG(("RISusr_send_rec: successful NET_write,"
			"RIS_srv_write_len:%d\n", RIS_srv_write_len));
		sql->schema->srv_busy = 1;
		if (timestamp->timestamp_interval)
		{
			/*
			**  Wait for initial_timeout time to receive an
			**  acknowledgement from server
			*/
			blocking = timestamp->initial_timeout;
			RIS_srv_read_len = RIS_srv_read_size;

			USR_DBG(("RISusr_send_rec:calling NET_read for first response\n"));
			status = SETJMP();
			if (!status)
			{
				NET_read(net, (char *)RIS_srv_read, &RIS_srv_read_len,
					blocking);
				RESETJMP();
			}
			else
			{
				RESETJMP();
				if (status == STATEMENT_NOT_COMPLETE)
				{
					USR_DBG(("RISusr_send_rec: longjmp SERVER NOT RESPONDING\n"));
					schema = sql->schema;
					if (schema->net->protocol == SHMEM)
					{
						RISusr_kill_srv(schema,CLEAR_SCHEMA, SYNC_MODE);
					}
					else
					{
						RISusr_kill_srv(schema,CLEAR_SCHEMA|CLOSE_NET,
						 SYNC_MODE);
					}
					RISdic_remove_schema_no_transaction(schema);
					FREES(schema->schid);
					RIScco_clear_schema_id(schema->schid);
					LONGJMP(RIS_E_SERVER_NOT_RESPONDING);
				}
				else
				{
					sql->schema->srv_busy = 0;
					USR_DBG(("RISusr_send_rec: longjmp NET READ ERROR\n"));
					LONGJMP(status);
				}
			}

			USR_DBG(("RISusr_send_rec: successful NET_read,"
			 "RIS_srv_read_len:%d\n", RIS_srv_read_len));

			ARC_NET_TO_INTEGER(arc, &RIS_srv_read->status);

			USR_DBG(("RISusr_send_rec: RIS_srv_read->status:%d RIS_srv_read->timestamp_count:%d\n",
			 RIS_srv_read->status, RIS_srv_read->timestamp_count));

			if (RIS_srv_read->status == RIS_UNSUPPORTED)
			{
				/* The server does not support network verification mechanism
				** and therefore client should turn off this mechanism.
				*/
				timestamp->timestamp_interval = 0;
			}
			else
			{
				if (RIS_srv_read->status != RIS_SUCCESS)
				{
					sql->schema->srv_busy = 0;
					LONGJMP(RIS_srv_read->status);
				}

				/*
				**  get round message time interval (at t2 time)
				*/
				initial_time_diff = get_diff_time(start_time);

				/*
				**  Rounding mechanism to calculate initial correction
				*/
				initial_time_correction
					= (int) ((((double) initial_time_diff) / 2.0) + 0.5);
				USR_DBG(("initial_time_diff = %d correction = %d\n",
					initial_time_diff, initial_time_correction));

				/*
				**  now syncing with slave (hopefully)
				*/
				netvstate->start_net_v_time = start_timer();
				netvstate->start_net_v_time -= initial_time_correction;
				
				netvstate->actual_timestamp_count = 0;
				netvstate->buffer_full_flag = 0;
				netvstate->buffer_empty_flag = 1;
			}
		}
	}

	if (IN_FINISH_MODE(execute_mode))
	{
		int blocking;

		if (!sql->schema->srv_busy)
		{
			USR_DBG(("RISusr_send_rec: nothing to finish. schema:<%s>\n",
			 sql->schema ? sql->schema->schname : "NULL"));
			LONGJMP(RIS_E_NOTHING_TO_FINISH);
		}

		blocking = (execute_mode & BLOCKING_MODE) ? 0 : -1;
		if (timestamp->timestamp_interval)
		{
			if (blocking == 0)
			{
				wait_completion(sql->schema, (char *)RIS_srv_read,
					&RIS_srv_read_len);
			}
			else
			{
				/*
				**kmreddy  - TR # 439600070  02/02/96
				*/ 
#if defined (__hpux__)
				if ( opcode == RIS_CLOSE_SCHEMA_CODE &&
					sql->schema->net->protocol == SHMEM)
				{
					test_completion(sql->schema, (char *)RIS_srv_read,
					&RIS_srv_read_len, 0);
				}
				else
#endif
					test_completion(sql->schema, (char *)RIS_srv_read,
					&RIS_srv_read_len, -1);
			}
		}
		else
		{
        		if (opcode == RIS_GROW_SRV_TO_CLI_BUF_CODE)
        		{
        		/* For some strange reason this first read will only read 0 bytes but 
        		** the next read will return the correct number of bytes read from the 
        		** server 7/22/96 - Ashley - fix for TR 439502534
        		*/

           			USR_DBG(("RISusr_send_rec: at GROW_SRV_TO_CLI trying to read %d bytes with blocking\n",RIS_srv_read_len));
           			NET_read(net,(char *)RIS_srv_read, &RIS_srv_read_len, 0);
           			ARC_NET_TO_INTEGER(arc, &RIS_srv_read->status);
				if ( RIS_srv_read_len == 0 ) /* try again */
				{
					NET_read(net,(char *)RIS_srv_read, &RIS_srv_read_len, blocking);
					ARC_NET_TO_INTEGER(arc, &RIS_srv_read->status);
				}
		
        		}
		        else
			{	
				NET_read(net,(char *)RIS_srv_read, &RIS_srv_read_len, blocking);
				ARC_NET_TO_INTEGER(arc, &RIS_srv_read->status);
			}
		}
		sql->schema->srv_busy = 0;
		RIS_test_completion_flag = 0; /* When this flag is clear, an error
										is no longer considered a test
										completion error */

		USR_DBG(("RISusr_send_rec: RIS_srv_read->status:%d\n",
			RIS_srv_read->status));

		if (RIS_srv_read->status != RIS_SUCCESS &&
			RIS_srv_read->status != END_OF_DATA)
		{
			int							len;
			struct ris_srvcli_buf_error *error = &RIS_srv_read->buf.error;

			/* Did we get error info from the server? */
			if (RIS_srv_read_len > RIS_SRVCLI_HDR_SIZE)
			{

				NET_TO_ERROR(arc, error);

				if (RISbuf_debug)
				{
					RIScom_output_debug("RISusr_rec: ERROR returned by server\n");
					RIScom_output_debug("\tdbms:0x%x\n", error->dbms);
					RIScom_output_debug("\tsqlerrml:%d\n", 
						error->dbca.sqlerrm.sqlerrml);
					if (error->dbca.sqlerrm.sqlerrml)
					{
						RIScom_output_debug("\tsqlerrmc:<%s>\n",
							error->dbca.sqlerrm.sqlerrmc);
					}
					RIScom_output_debug("\tdbstmt_len:%d\n", error->dbstmt_len);
					if (error->dbstmt_len)
					{
						RIScom_output_debug("\tdbstmt:<%s>\n", error->data);
					}
					else
					{
						RIScom_output_debug("\tdbstmt:NULL\n");
					}
				}

				if (error->dbstmt_len > RIS_MAX_STMT_LEN - 1)
				{
					len = RIS_MAX_STMT_LEN - 1;
				}
				else if (error->dbstmt_len > 0)
				{
					len = error->dbstmt_len;
				}
				else
				{
					len = 0;
				}
				memcpy(RIS_dbstmt, error->data, len);
				RIS_dbstmt[len] = '\0';

				memcpy(dbca, &error->dbca, sizeof(rissqlca));
				dbca->sqlstmt = RIS_dbstmt;

				switch (opcode)
				{
					case RIS_PREP_DESC_DECL_OPEN_CODE:
						sql->dbms = RIS_srv_read->buf.error.dbms;
						break;

					case RIS_PREP_EXEC_CODE:
				/**            BLOB          **/
					case RIS_PREP_EXEC_DEFERRED_CODE:
				/**            BLOB          **/
						sql->dbms = RIS_srv_read->buf.error.dbms;
						sql->rollback = RIS_srv_read->buf.error.rollback;
						break;
				/**            BLOB          **/
					case RIS_EXEC_DEFERRED_CODE:
					case RIS_EXEC_BLOB_CODE:
				/**            BLOB          **/
					case RIS_EXEC_CODE:
						sql->rollback = RIS_srv_read->buf.error.rollback;
						break;

					default:
						break;
				}
			}

			LONGJMP(RIS_srv_read->status);
		}

#ifdef ROW_COUNT_SUPPORTED
		ARC_NET_TO_INTEGER(arc, &RIS_srv_read->ca.num_rows);
		USR_DBG(("RISusr_send_rec: ca.num_rows:%d\n",
			RIS_srv_read->ca.num_rows));
#endif

		switch (opcode)
		{
			case RIS_FETCH_BUF_CODE_4:
			{
				struct ris_srvcli_buf_fetch *fetch = &RIS_srv_read->buf.fetch;

				NET_TO_FETCH_BUF(arc, RIS_stmt, fetch);

				if (RISbuf_debug)
				{
					unsigned int i;
					int offset;

					RIScom_output_debug("RISusr_rec: RIS_FETCH_BUF_CODE_4\n");
					RIScom_output_debug("\trow_count:%d\n", fetch->row_count);
					RIScom_output_debug("\tmore_to_follow:%s\n",
						fetch->more_to_follow ? "YES" : "NO");

					for(i = 0, offset = 0;
						i < fetch->row_count;
						i++, offset += RIS_stmt->row_len)
					{
						RIScom_output_debug("\trow %d:\n", i);
						RIScco_output_internal_data(RIScom_output_debug, 
							RIS_stmt->sql->output->sqld,
							RIS_stmt->sql->output->sqlvar,
							(char *)(fetch->data + offset), 2);
					}
				}
			}
			break;

			/* BLOB support */
			case RIS_FETCH_BUF_CODE:
			{
				struct ris_srvcli_buf_fetch *fetch=&RIS_srv_read->buf.fetch;

				NET_TO_FETCH_BUF(arc, RIS_stmt, fetch);

				if (RISbuf_debug)
				{
					int i;
					int offset;

					RIScom_output_debug("RISusr_rec: RIS_FETCH_BUF_CODE\n");
					RIScom_output_debug("\trow_count:%d\n", fetch->row_count);
					RIScom_output_debug("\tmore_to_follow:%s\n",
						fetch->more_to_follow ? "YES" : "NO");
					RIScom_output_debug("\tblob_to_follow:%s\n",
						fetch->blob_to_follow ? "YES" : "NO");

					for(i = 0, offset = 0;
						(unsigned int) i < fetch->row_count;
						i++, offset += RIS_stmt->row_len)
					{
						RIScom_output_debug("\trow %d:\n", i);
						RIScco_output_internal_data(RIScom_output_debug, 
							RIS_stmt->sql->output->sqld,
							RIS_stmt->sql->output->sqlvar,
							(char *)(fetch->data + offset), 2);
					}
				}
			}
			break;

			case RIS_FETCH_BLOB_CODE:

				NET_TO_FETCH_BLOB(arc, &RIS_srv_read->buf.fetch_blob);
				break;

			/* BLOB support
			   RIS_GET_TAB_CODE and RIS_GET_TAB_NOVERIFY_CODE are
               modified for 5.0.  RIS_GET_TAB_CODE_4 and 
			   RIS_GET_TAB_NOVERIFY_CODE_4 (both maintain the old
				opcode number) are used for old client */

			case RIS_GET_TAB_CODE:
			case RIS_GET_TAB_NOVERIFY_CODE:
			{
				struct ris_srvcli_buf_get_tab *get_tab =
					&RIS_srv_read->buf.get_tab;

				NET_TO_GET_TAB(arc, get_tab);
				if (RISbuf_debug)
				{
					unsigned int	i;
					ris_attr_info	*attr_info;

					RIScom_output_debug("RISusr_rec: %s\n", RIS_srv_codes[opcode]);
					RIScom_output_debug("\ttab_count:%d\n", get_tab->count);
					for(i = 0, attr_info = (ris_attr_info *)get_tab->data;
						i < get_tab->count;
						i++, attr_info++)
					{
						RIScom_output_debug("\tattr_info #%d:\n", i);
						RIScom_output_attr_info(RIScom_output_debug, attr_info, 2);
					}
				}
				sql->query = (char *)get_tab->data;
				sql->input_len = (unsigned int)get_tab->tabid;
                strcpy(sql->ext_relname, get_tab->extern_relname);
                strcpy(sql->relowner, get_tab->tabowner);
				return_sts = get_tab->count;
			}
			break;

			case RIS_GET_TABTYPE_CODE:
				ARC_NET_TO_CHARACTER(arc, &RIS_srv_read->buf.get_tabtype.data);
				sql->query = (char *)&RIS_srv_read->buf.get_tabtype.data;
				break;

			case RIS_GET_ACCESS_CODE:
			case RIS_GET_ALL_ACCESS_CODE:
			case RIS_GET_SCHEMA_GRANTORS_CODE:
				NET_TO_GET_ACCESS(arc, &RIS_srv_read->buf.get_access);
				break;

		case RIS_UPD_ACCESS_CODE:
			/*
			** If there's nothing more to send to the server, then we should
			** expect that the first buffer of information about schema grantees
			** is sent back by the server.
			*/
			if (!RIS_srv_write->buf.upd_access.more_to_follow)
			{
				NET_TO_GET_GRANTEES(arc, &RIS_srv_read->buf.get_grantees);
			}
			break;
			
			case RIS_GET_SCHEMA_GRANTEES_CODE:
				NET_TO_GET_GRANTEES(arc, &RIS_srv_read->buf.get_grantees);
				break;

			case RIS_PREP_DESC_DECL_OPEN_CODE:
				sql->dbms = RIS_srv_read->buf.pddo.dbms;
#ifdef ROW_COUNT_SUPPORTED
				risca->sqlerrd[2] = RIS_srv_read->ca.num_rows;
#endif
			   break;

			case RIS_PREP_EXEC_CODE:
				sql->dbms = RIS_srv_read->buf.pe.dbms;
#ifdef ROW_COUNT_SUPPORTED
				risca->sqlerrd[2] = RIS_srv_read->ca.num_rows;
#endif
			   break;

	/*******       BLOB        *******/
			case RIS_PREP_EXEC_DEFERRED_CODE:
				sql->dbms = RIS_srv_read->buf.pe_deferred.dbms;
#ifdef ROW_COUNT_SUPPORTED
				risca->sqlerrd[2] = RIS_srv_read->ca.num_rows;
#endif
			   break;
	/*******       BLOB        *******/

			case RIS_CRE_SCH_GET_GRANTEES_CODE:
			case RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE:
			{
			  risschema   *schema = sql->schema;
				struct ris_srvcli_buf_create_schema *info =
					&RIS_srv_read->buf.create_schema;

				ARC_NET_TO_INTEGER(arc, &info->pid);
				ARC_NET_TO_STRING(arc, info->xns_addr);
				ARC_NET_TO_STRING(arc, info->tcp_addr);
				ARC_NET_TO_STRING(arc, info->dnp_addr);
				ARC_NET_TO_STRING(arc, info->lu62_addr);
				ARC_NET_TO_STRING(arc, info->dict_dbusr);
				ARC_NET_TO_STRING(arc, info->schown_dbusr);
				ARC_NET_TO_STRING(arc, info->login_dbusr);

				NET_TO_CRE_SCH_GET_GRANTEES(arc,
					&RIS_srv_read->buf.create_schema);
				ARC_NET_TO_CHARACTER(arc, &info->privilege);

				schema->srv_pid = info->pid;
				schema->privilege = info->privilege;

				memcpy(RIS_remote_xns_addr,info->xns_addr, RIS_MAX_NODE_SIZE );
				memcpy(RIS_remote_tcp_addr, info->tcp_addr, RIS_MAX_NODE_SIZE );
				memcpy(RIS_remote_dnp_addr, info->dnp_addr, RIS_MAX_NODE_SIZE );
				memcpy(RIS_remote_lu62_addr, info->lu62_addr,RIS_MAX_NODE_SIZE);
				memcpy(schema->dict_dbusr,info->dict_dbusr,RIS_MAX_ID_SIZE);
				memcpy(schema->schown_dbusr,info->schown_dbusr,RIS_MAX_ID_SIZE);
				memcpy(schema->login_dbusr,info->login_dbusr,RIS_MAX_ID_SIZE);

				if ( IS_RIS_ILICENSE_WARNING (info->warning) )
				{
					SET_RIS_ILICENSE_WARNING (RIS_warning_flag);		
				}

				USR_DBG(("RISusr_send_rec: srv_pid:%d privilege:<%c>\n"
					"\tdict_dbusr:<%s>\n\tschown_dbusr:<%s>\n\tlogin_dbusr:<%s>\n"
					"\tRIS_remote_xns_addr:<%s>\n\tRIS_remote_tcp_addr:<%s>\n"
					"\tRIS_remote_dnp_addr:<%s>\n\tRIS_remote_lu62_addr:<%s>\n"
					"\tcount:<%d>\n\tmore_to_follow:<%c>\n\twarning:<%c>\n",
					schema->srv_pid, schema->privilege, 
					schema->dict_dbusr, schema->schown_dbusr, 
					schema->login_dbusr, RIS_remote_xns_addr,
					RIS_remote_tcp_addr, RIS_remote_dnp_addr,
					RIS_remote_lu62_addr, 
					RIS_srv_read->buf.create_schema.count,
					RIS_srv_read->buf.create_schema.more_to_follow,
					RIS_warning_flag));
			}
			break;

			case RIS_OPEN_SCHEMA_CODE:
			{
			  risschema   *schema = sql->schema;
				struct ris_srvcli_buf_open_schema *info =
					&RIS_srv_read->buf.open_schema;

				ARC_NET_TO_INTEGER(arc, &info->pid);
				ARC_NET_TO_STRING(arc, info->xns_addr);
				ARC_NET_TO_STRING(arc, info->tcp_addr);
				ARC_NET_TO_STRING(arc, info->dnp_addr);
				ARC_NET_TO_STRING(arc, info->lu62_addr);
				ARC_NET_TO_DATA(arc, info->schpass, RIS_MAX_PASSWD_SIZE);
				ARC_NET_TO_STRING(arc, info->dict_dbusr);
				ARC_NET_TO_STRING(arc, info->schown_dbusr);
				ARC_NET_TO_STRING(arc, info->login_dbusr);
				ARC_NET_TO_CHARACTER(arc, &info->privilege);

				schema->srv_pid = info->pid;
				schema->privilege = info->privilege;

				memcpy(RIS_remote_xns_addr,info->xns_addr, RIS_MAX_NODE_SIZE );
				memcpy(RIS_remote_tcp_addr, info->tcp_addr, RIS_MAX_NODE_SIZE );
				memcpy(RIS_remote_dnp_addr, info->dnp_addr, RIS_MAX_NODE_SIZE );
				memcpy(RIS_remote_lu62_addr, info->lu62_addr,RIS_MAX_NODE_SIZE);

				memcpy(schema->schpass, info->schpass,RIS_MAX_PASSWD_SIZE );
				memcpy(schema->dict_dbusr,info->dict_dbusr,RIS_MAX_ID_SIZE);
				memcpy(schema->schown_dbusr,info->schown_dbusr,RIS_MAX_ID_SIZE);
				memcpy(schema->login_dbusr,info->login_dbusr,RIS_MAX_ID_SIZE);

				if ( IS_RIS_ILICENSE_WARNING (info->warning) )
				{
					SET_RIS_ILICENSE_WARNING (RIS_warning_flag);		
				}

				USR_DBG(("RISusr_send_rec: srv_pid:%d privilege:<%c>\n"
					"\tdict_dbusr:<%s>\n\tschown_dbusr:<%s>\n\tlogin_dbusr:<%s>\n"
					"\tRIS_remote_xns_addr:<%s>\n\tRIS_remote_tcp_addr:<%s>\n"
					"\tRIS_remote_dnp_addr:<%s>\n\tRIS_remote_lu62_addr:<%s>\n"
					"\twarning:<%c>\n",
					schema->srv_pid, schema->privilege, 
					schema->dict_dbusr, schema->schown_dbusr, 
					schema->login_dbusr, RIS_remote_xns_addr,
					RIS_remote_tcp_addr, RIS_remote_dnp_addr,
					RIS_remote_lu62_addr, RIS_warning_flag));
			}
			break;

			case RIS_ALTER_RACF_PWD_CODE:
			{
				struct ris_srvcli_buf_schema_db *info =
					&RIS_srv_read->buf.schema_db;

				if ( IS_RIS_ILICENSE_WARNING (info->warning) )
				{
					SET_RIS_ILICENSE_WARNING (RIS_warning_flag);		
				}
			}
			break;

			default:
				break;
		}

		if (RIS_srv_read->status == END_OF_DATA)
		{
			LONGJMP(END_OF_DATA);
		}
	}
	RESETJMP();

	USR_DBG(("RISusr_send_rec: returning %d\n", return_sts));
	return return_sts;
}

/******************************************************************************/

extern void RISusr_send_all_srvs(
	char opcode,
	int arg,
	int exec_mode)
{
	risschema *schema;
	int status;

	USR_DBG(("\nRISusr_send_all_srvs opcode:%d, arg:%d exec_mode:0x%x\n",
		opcode,arg, exec_mode));

	for (schema = RIS_srvs; schema; schema = schema->next)
	{
		RIS_sdp->schema = schema;
		RIS_sdp->misc = (unsigned int*)arg;
		do
		{
			status = SETJMP();
			if (!status)
			{
				RISusr_send_rec(opcode, RIS_sdp, (unsigned short)exec_mode);
			}
			RESETJMP();
		}
		while (status == STATEMENT_NOT_COMPLETE);
	}
}

/******************************************************************************/

/*
**	Start timer ==> get current time
*/
static time_t start_timer()
{
	time_t	start_time;

	start_time = time((long *)0);
	USR_DBG(("start_timer: curr_time = %d\n",start_time));
	return(start_time);
}

/******************************************************************************/

/*
**	Get difference of time from current time with respect to start_time
*/
static int get_diff_time(
	time_t	start_time)
{
	time_t	curr_time = 0;
	time_t	difference = 0;

	curr_time = time((long *)0);
	difference = curr_time - start_time;
	USR_DBG(("get_diff_time: start = %d curr = %d difference = %d\n", 
			start_time, curr_time, difference));
	return difference;
}

/******************************************************************************/

static void test_completion(
	risschema		*schema,
	char			*buffer,
	int				*len,
	int				blocking)
{
	arc_s			*arc;
	net_s			*net;
	ristimestamp	*timestamp;
	risnetvstate	*netvstate;
	int 			status;
	int 			actual_reads;
	unsigned int 	buff_full_time_diff;

	USR_DBG(("test_completion: schema:0x%x buffer:0x%x len:0x%x blocking:%d\n",
			schema, buffer, len, blocking));
	arc = schema->arc;
	net = schema->net;
	timestamp = &(schema->timestamp);
	netvstate = &(schema->netvstate);
	USR_DBG(("test_completion: netvstate->buffer_full_flag = %d\n",
		netvstate->buffer_full_flag));
	USR_DBG(("test_completion: netvstate->buffer_empty_flag = %d\n",
		netvstate->buffer_empty_flag));
	USR_DBG(("test_completion: netvstate->actual_timestamp_count = %d\n",
		netvstate->actual_timestamp_count));
	USR_DBG(("test_completion: netvstate->start_net_v_time = %d\n",
		netvstate->start_net_v_time));
	USR_DBG(("test_completion: netvstate->start_buff_full_time = %d\n",
		netvstate->start_buff_full_time));
	
	/* read  until actual data found or error */

	actual_reads = 0;
	while(1)	
	{
		status = SETJMP();
		if (!status)
		{
			NET_read(net, buffer, len, blocking);
			RESETJMP();
		}
		else
		{
			RESETJMP();
			if (status == STATEMENT_NOT_COMPLETE)
			{
				netvstate->buffer_empty_flag = 1;
				if (is_server_alive(timestamp, netvstate))
				{
					USR_DBG(("test_completion: longjmp SERVER ALIVE\n"));
					LONGJMP(status);
				}
				if (netvstate->buffer_full_flag)
				{
					/*
					**	Do this test only if the last test_completion reported 
					**	buffer full mode
					**	Wait for buff_full_time_diff time seconds.
					**	If buff_full_time_diff has expired report SERVER dead.
					*/

					USR_DBG(("test_completion: start_buff_full_time = %d\n",
							netvstate->start_buff_full_time));

					buff_full_time_diff = get_diff_time(
							netvstate->start_buff_full_time);

					USR_DBG(("test_completion: buff_full_time_diff = %d\n",
							buff_full_time_diff));

					USR_DBG(("test_completion: buffer_full_timeout = %d\n", 
							timestamp->buffer_full_timeout));

					if( buff_full_time_diff < timestamp->buffer_full_timeout )
					{
						USR_DBG(("test_completion: longjmp MAY BE ALIVE\n"));
						LONGJMP(status);
					}
				}
				netvstate->buffer_full_flag = 0;

				USR_DBG(("test_completion: longjmp SERVER NOT RESPONDING\n"));
				if (schema->net->protocol == SHMEM)
				{
					RISusr_kill_srv(schema,CLEAR_SCHEMA, SYNC_MODE);
				}
				else
				{
					RISusr_kill_srv(schema,CLEAR_SCHEMA|CLOSE_NET, SYNC_MODE);
				}
				RISdic_remove_schema_no_transaction(schema);
            	FREES(schema->schid);
            	RIScco_clear_schema_id(schema->schid);
				LONGJMP(RIS_E_SERVER_NOT_RESPONDING);
			}
			else
			{
				USR_DBG(("test_completion: longjmp NET READ ERROR\n"));
				LONGJMP(status);
			}
		}

		USR_DBG(("test_completion: RIS_srv_read_len=<%d>\n",
				RIS_srv_read_len));

		ARC_NET_TO_INTEGER(arc, &RIS_srv_read->status);

		USR_DBG(("test_completion: RIS_srv_read->status=<%d>\n",
				RIS_srv_read->status));

		if (RIS_srv_read->status != RIS_SUCCESS &&
			RIS_srv_read->status != END_OF_DATA)
		{

/* Changes made to display the database error when error occurs in
server during wait_completion (E911 fix) Radha 5/6/95
*/
      if (RIS_srv_read->status != RIS_SUCCESS &&
        RIS_srv_read->status != END_OF_DATA)
      {
        int             len;
        struct ris_srvcli_buf_error *error = &RIS_srv_read->buf.error;

        /* Did we get error info from the server? */
        if (RIS_srv_read_len > RIS_SRVCLI_HDR_SIZE)
        {
          arc = schema->arc;

          NET_TO_ERROR(arc, error);

          if (RISbuf_debug)
          {
            RIScom_output_debug("%s,%d:test_completion: ERROR returned by server\n",__FILE__,__LINE__);
            RIScom_output_debug("\tdbms:0x%x\n", error->dbms);
            RIScom_output_debug("\tsqlerrml:%d\n",
              error->dbca.sqlerrm.sqlerrml);
            if (error->dbca.sqlerrm.sqlerrml)
            {
              RIScom_output_debug("\tsqlerrmc:<%s>\n",
                error->dbca.sqlerrm.sqlerrmc);
            }
            RIScom_output_debug("\tdbstmt_len:%d\n", error->dbstmt_len);
            if (error->dbstmt_len)
            {
              RIScom_output_debug("\tdbstmt:<%s>\n", error->data);
            }
            else
            {
              RIScom_output_debug("\tdbstmt:NULL\n");
            }
          }

          if (error->dbstmt_len > RIS_MAX_STMT_LEN - 1)
          {
            len = RIS_MAX_STMT_LEN - 1;
          }
          else if (error->dbstmt_len > 0)
          {
            len = error->dbstmt_len;
          }
          else
          {
            len = 0;
          }
          memcpy(RIS_dbstmt, error->data, len);
          RIS_dbstmt[len] = '\0';
          memcpy(dbca, &error->dbca, sizeof(rissqlca));
          dbca->sqlstmt = RIS_dbstmt;
        }
      }

			LONGJMP(RIS_srv_read->status);
		}

		actual_reads++;
		
		if (netvstate->buffer_empty_flag)
		{
			netvstate->buffer_empty_flag = 0;
			netvstate->buffer_full_flag = 0;
		}

		USR_DBG(("test_completion: actual_reads = %d\n",actual_reads));
		USR_DBG(("test_completion: received %d bytes from slave\n", *len));
		USR_DBG(("test_completion: RIS_srv_read->status = <%d>\n",
				RIS_srv_read->status));
		USR_DBG(("test_completion: RIS_srv_read->timestamp_count = <%d>\n",
				RIS_srv_read->timestamp_count));
		USR_DBG(("test_completion: buffer_full_flag = %d buffer_empty_flag = %d\n",
				netvstate->buffer_full_flag, netvstate->buffer_empty_flag));

		if ((unsigned int)(actual_reads * RIS_SRVCLI_HDR_SIZE) >= timestamp->buffer_full_size)
		{
			/*
			**	This means logically buffer is full and therefore set
			**	buffer_full_flag so that next test_completion might return
			**	MAY BE ALIVE
			*/
			USR_DBG(("test_completion: setting buffer_full_flag = 1\n"));
			netvstate->buffer_full_flag = 1;
			netvstate->start_buff_full_time = start_timer();
		}

		if (RIS_srv_read->timestamp_count)
		{
			/*
			**	 read actual # of missed alarm
			*/
			ARC_NET_TO_INTEGER(arc, &(RIS_srv_read->timestamp_count));
			netvstate->actual_timestamp_count += RIS_srv_read->timestamp_count;
			USR_DBG(("test_completion: actual_timestamp_count = %d\n", 
					netvstate->actual_timestamp_count));
		}
		else 
		{
			netvstate->buffer_full_flag = 0;
			netvstate->buffer_empty_flag = 1;
			USR_DBG(("test_completion: returning SERVER DATA\n"));
			break;
		}	
	}
}

/******************************************************************************/

static int is_server_alive(
	ristimestamp    *timestamp,
	risnetvstate    *netvstate)
{
	int ideal_count = 0;
	int	elapsed_time;
	int result; /* signed int type */

	USR_DBG(("is_server_alive( netvstate: 0x%x\n", netvstate));

	elapsed_time = get_diff_time(netvstate->start_net_v_time);

	USR_DBG(("is_server_alive: elapsed_time = %d\n",elapsed_time));

	ideal_count = elapsed_time/timestamp->timestamp_interval;

	USR_DBG(("is_server_alive: ideal_count = %d\n", ideal_count));

	result = ideal_count - netvstate->actual_timestamp_count;

	USR_DBG(("is_server_alive: result = %d\n", result));

	if (result > (int)timestamp->timestamp_tolerance)
	{
		USR_DBG(("is_server_alive: returning server DIED\n"));
		return 0;
	}
	else
	{
		USR_DBG(("is_server_alive: returning server ALIVE\n"));
		return 1;
	}
}

/******************************************************************************/

static void wait_completion(
	risschema	*schema,
	char		*buffer,
	int			*len)
{
	int status;
	arc_s *arc;
	USR_DBG(("wait_completion: schema:0x%x buffer:0x%x len:0x%x\n",
	 schema, buffer, len));

	status = SETJMP();
	for (;;)
	{
		USR_DBG(("wait_completion: status = %d\n", status));
		if (!status)
		{
			test_completion(schema, buffer, len,
				schema->timestamp.timestamp_interval);
			RESETJMP();
			break;
		}
		else
		{
			if (status != STATEMENT_NOT_COMPLETE)
			{
				RESETJMP();
				USR_DBG(("wait_completion: longjmp NET READ ERROR\n"));

				/* Changes made to display the database error
				   when error occurs in server during
				   wait_completion (E911 fix) Radha 5/6/95 */
				if (RIS_srv_read->status != RIS_SUCCESS &&
					RIS_srv_read->status != END_OF_DATA)
				{
					int	len;
					struct ris_srvcli_buf_error	*error = &RIS_srv_read->buf.error;

					/* Did we get error info from the server? */
					if (RIS_srv_read_len > RIS_SRVCLI_HDR_SIZE)
					{
						arc = schema->arc;
						NET_TO_ERROR(arc, error);

						if (RISbuf_debug)
						{
							RIScom_output_debug("wait_completion: ERROR returned by server\n");
							RIScom_output_debug("\tdbms:0x%x\n", error->dbms);
							RIScom_output_debug("\tsqlerrml:%d\n",
								error->dbca.sqlerrm.sqlerrml);
							if (error->dbca.sqlerrm.sqlerrml)
							{
								RIScom_output_debug("\tsqlerrmc:<%s>\n",
									error->dbca.sqlerrm.sqlerrmc);
							}
							RIScom_output_debug("\tdbstmt_len:%d\n", error->dbstmt_len);
							if (error->dbstmt_len)
							{
								RIScom_output_debug("\tdbstmt:<%s>\n", error->data);
							}
							else
							{
								RIScom_output_debug("\tdbstmt:NULL\n");
							}
						}

						if (error->dbstmt_len > RIS_MAX_STMT_LEN - 1)
						{
							len = RIS_MAX_STMT_LEN - 1;
						}
						else if (error->dbstmt_len > 0)
						{
							len = error->dbstmt_len;
						}
						else
						{
							len = 0;
						}
						memcpy(RIS_dbstmt, error->data, len);
						RIS_dbstmt[len] = '\0';
						memcpy(dbca, &error->dbca, sizeof(rissqlca));
						dbca->sqlstmt = RIS_dbstmt;
					}
				}
				LONGJMP(status);
			} /* status != STATEMENT_NOT_COMPLETE */
			status = 0;
		} /* else status */
	} /* for (;;) */
	USR_DBG(("wait_completion: returning\n"));
}

/******************************************************************************/
