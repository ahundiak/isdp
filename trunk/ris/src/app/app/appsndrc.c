/* Do not alter this SPC information: $Revision: 1.1.59.1 $ */
/*
**	NAME:							appsndrc.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

/*
**	INCLUDES
*/
#include "risapp.h"
#include "risapp_app.h"
#include "riscom.h"
#include "rismem.h"
#include "risnet.h"

extern void RISapp_send_rec()
{
	int sts;
	char opcode = RIS_write->opcode;

	APP_DBG(("RISapp_send_rec()\nRISapp_send_rec: opcode:%d <%s>\n",
		opcode, RIS_cli_codes[opcode]));

	switch(opcode)
	{
		/*** BLOB *******/
		case RISCLI_FETCH_CODE:
		case RISCLI_FETCH_CODE_4:
			/*
			**	replace read buffer with cursor buffer
			*/
			RIS_read_size = RIS_stmt->fetch_buf_size;
			RIS_read = RIS_stmt->fetch_buf;
			break;

		default:
			/*
			**	set read buffer with saved read buffer
			*/
			RIS_read_size = RIS_save_read_size;
			RIS_read = RIS_save_read;
			break;
	}
	sts = SETJMP();
	if (!sts)
	{
		RISapp_init_signal();
		RISapp_check_client(RIS_net);
		NET_write(RIS_net, (char *)RIS_write, &RIS_write_len, BLOCKING);
		RIS_read_len = 0;
		NET_read(RIS_net, (char *)RIS_read, &RIS_read_len, BLOCKING);
		RISapp_restore_signal();
		RESETJMP();
	}
	else
	{
		RESETJMP();
		RISapp_restore_signal();
		LONGJMP(sts);
	}

	APP_DBG(("RISapp_send_rec: RIS_read:0x%x RIS_read_len:%d\n",
		RIS_read, RIS_read_len));

	if(RIS_arc->remote_arch != LOCAL_ARCH)
	{
		if (ARC_INTEGER_IS_DIFFERENT(RIS_arc->conversion_flags))
		{
			ARC_convert(RIS_arc, FROM_NET, CONVERT_INTEGER, &RIS_read->status, 0);
		}
	}

	APP_DBG(("RISapp_send_rec: RIS_read->status:%d\n", RIS_read->status));
	APP_DBG(("RISapp_send_rec: RIS_read->warning:%x\n", RIS_read->warning));

	sts = RIS_read->status;

	if (sts != RIS_SUCCESS)
	{
		RISapp_buf_to_err();

		switch(sts)
		{
			case RIS_E_DEFAULT_SCHEMA_DIED:
				RIS_def_schname[0] = '\0';
				break;
		
			default:
				break;
		}
		LONGJMP(sts);
	}

    /*
    **  Map warnings if any
    */
	RISapp_map_warnings(RIS_read->warning);

	RIS_test_completion_flag = 0;
	
	switch(opcode)
	{
		case RISCLI_INIT_CODE:
			if (RISbuf_debug)
			{
				RIScom_output_debug("APPsend_rec: RISCLI_INIT_CODE\n");
				RIScom_output_debug("\txns_addr:<%s>\n", 
					RIS_read->buf.init.xns_addr);
				RIScom_output_debug("\ttcp_addr:<%s>\n", 
					RIS_read->buf.init.tcp_addr);
				RIScom_output_debug("\tdnp_addr:<%s>\n", 
					RIS_read->buf.init.dnp_addr);
				RIScom_output_debug("\tlu62_addr:<%s>\n", 
					RIS_read->buf.init.lu62_addr);
			}
			strcpy(RIS_local_xns_addr, RIS_read->buf.init.xns_addr);
			strcpy(RIS_local_tcp_addr, RIS_read->buf.init.tcp_addr);
			strcpy(RIS_local_dnp_addr, RIS_read->buf.init.dnp_addr);
			strcpy(RIS_local_lu62_addr, RIS_read->buf.init.lu62_addr);
			break;

		case RISCLI_PREPARE_CODE:
		{
			struct ris_cliapp_buf_prep *prep = &RIS_read->buf.prep;

			PREPARE_FROM_NET(RIS_arc, &RIS_read->buf.prep);

			if (RISbuf_debug)
			{
				int				i;
				struct sqlvar	*var;

				RIScom_output_debug("RISapp_send_rec: RISCLI_PREPARE_CODE\n");
				RIScom_output_debug("\tin_sqlvar(offset):%d\n", 
					prep->in_sqlvars);
				RIScom_output_debug("\tout_sqlvar(offset):%d\n", 
					prep->out_sqlvars);
				RIScom_output_debug("\tin_count:%d\n", prep->in_count);
				RIScom_output_debug("\tout_count:%d\n", prep->out_count);
				RIScom_output_debug("\tfetch_buf_size:%d\n", 
					prep->fetch_buf_size);
				RIScom_output_debug("\twrite_buf_size:%d\n", 
					prep->write_buf_size);
				if (prep->in_count)
				{
					RIScom_output_debug("\tinput sqlvars:\n");
					var = (sqlvar *)(prep->data + prep->in_sqlvars);
					for (i = 0; i < prep->in_count; i++)
					{
						RIScom_output_debug("\t\tsqlvar #%d:\n", i);
						RIScom_output_sqlvar(RIScom_output_debug, var + i, 3);
					}
				}
				if (prep->out_count)
				{
					RIScom_output_debug("\toutput sqlvars:\n");
					var = (sqlvar *)(prep->data + prep->out_sqlvars);
					for (i = 0; i < prep->out_count; i++)
					{
						RIScom_output_debug("\t\tsqlvar #%d:\n", i);
						RIScom_output_sqlvar(RIScom_output_debug, var + i, 3);
					}
				}
				RIScom_output_debug("\ttable count:%d\n", prep->tab_count);
				if (prep->tab_count)
				{
					RIScom_output_debug("\ttable list:\n");
					for(i = 0; i < prep->tab_count; i++)
					{
						RIScom_output_debug("\t\t<%s>\n",
							prep->data + prep->tab_list + (i*RIS_MAX_ID_SIZE));
					}
				}
				RIScom_output_debug("\tschname:<%s>\n", prep->schname);
				RIScom_output_debug("\tstmt_type:<%s>\n",
					RIScom_get_stmt_type_name(prep->stmt_type));
			}

			RIS_stmt->fetch_buf_size = prep->fetch_buf_size;
			RIS_stmt->write_buf_size = prep->write_buf_size;
			if (prep->in_count)
			{
				RIS_stmt->input_len = prep->in_len;
				RIS_stmt->input = ALLOCT(sqlda);
				RIS_stmt->input->sqln = (short)prep->in_count;
				RIS_stmt->input->sqld = (short)prep->in_count;
				RIS_stmt->input->sqlvar = ALLOCN(sqlvar, prep->in_count);
				memcpy(RIS_stmt->input->sqlvar,
					(prep->data + prep->in_sqlvars),
					(sizeof(sqlvar) * prep->in_count));
			}

			if (prep->out_count)
			{
				RIS_stmt->output_len = prep->out_len;
				RIS_stmt->output = ALLOCT(sqlda);
				RIS_stmt->output->sqln = (short)prep->out_count;
				RIS_stmt->output->sqld = (short)prep->out_count;
				RIS_stmt->output->sqlvar = ALLOCN(sqlvar, prep->out_count);
				memcpy(RIS_stmt->output->sqlvar,
					(prep->data + prep->out_sqlvars),
					(sizeof(sqlvar) * prep->out_count));
			}

			RIS_stmt->tab_count = prep->tab_count;
			if (prep->tab_count)
			{
				RIS_stmt->tab_list = (char (*)[RIS_MAX_ID_SIZE])
					ALLOCB(prep->tab_count * RIS_MAX_ID_SIZE);
				memcpy(RIS_stmt->tab_list, prep->data + prep->tab_list,
					prep->tab_count * RIS_MAX_ID_SIZE);
			}

			strcpy(RIS_stmt->schname, prep->schname);
			RIS_stmt->stmt_type = prep->stmt_type;

			strcpy(RIS_stmt->prep_def_schname, RIS_def_schname);
		}
		break;

		case RISCLI_SCHEMA_MGR_CODE:
			strcpy(RIS_def_schname, RIS_read->buf.schema_mgr.RIS_def_schname);
			break;

		case RISCLI_GROW_CLI_TO_APP_BUF_CODE:
		{
			struct ris_appcli_buf_grow_buf *grow_buf = &RIS_write->buf.grow_buf;

			GROW_BUF_FROM_NET(RIS_arc, &RIS_write->buf.grow_buf);

			if (RISbuf_debug)
			{
				RIScom_output_debug("RISapp_send_rec: RISCLI_GROW_CLI_TO_APP_BUF_CODE\n");
				RIScom_output_debug("\tnew_size:%d\n", grow_buf->new_size);
			}
		}

		case RISCLI_GET_FLAGS_CODE:
		{
			struct ris_cliapp_buf_get_flags *get_flags = 
				&RIS_read->buf.get_flags;

			GET_FLAGS_FROM_NET(RIS_arc, &RIS_read->buf.get_flags);

			if (RISbuf_debug)
			{
				RIScom_output_debug("RISapp_send_rec: RISCLI_GET_FLAGS_CODE\n");
				RIScom_output_debug("\tansi_mode:%d\n", get_flags->ansi_mode);
				RIScom_output_debug("\tenable_dbms:%d\n", 
					get_flags->enable_dbms);
				RIScom_output_debug("\tverify_mode:%d\n", 
					get_flags->verify_mode);
				RIScom_output_debug("\tblankstrip_mode:%d\n", 
					get_flags->blankstrip_mode);
				RIScom_output_debug("\tautocommit:%d\n", get_flags->autocommit);
				RIScom_output_debug("\tautorename:%d\n", get_flags->autorename);
			}
		}
		break;

		case RISCLI_GET_SS_NAMES_CODE:
		{
			struct ris_cliapp_buf_get_ss_names *get_ss_names = 
				&RIS_read->buf.get_ss_names;

			GET_SS_NAMES_FROM_NET(RIS_arc, &RIS_read->buf.get_ss_names);

			if (RISbuf_debug)
			{
				RIScom_output_debug("RISapp_send_rec: RISCLI_GET_SS_NAMES_CODE\n");
				RIScom_output_debug("\tss_count:%d\n", get_ss_names->ss_count);
			}
		}
		break;

		case RISCLI_GET_SS_DEF_CODE:
		{
			struct ris_cliapp_buf_get_ss_def *get_ss_def = 
				&RIS_read->buf.get_ss_def;

			GET_SS_DEF_FROM_NET(RIS_arc, &RIS_read->buf.get_ss_def);

			if (RISbuf_debug)
			{
				RIScom_output_debug("RISapp_send_rec: RISCLI_GET_SS_DEF_CODE\n");
				RIScom_output_debug("\tss_count:%d\n", get_ss_def->ss_count);
			}
		}
		break;

		case RISCLI_GET_SCH_IN_TRANS_CODE:
		{
			struct ris_cliapp_buf_get_sch_in_trans *get_sch_in_trans = 
				&RIS_read->buf.get_sch_in_trans;

			GET_SCH_IN_TRANS_FROM_NET(RIS_arc, &RIS_read->buf.get_sch_in_trans);

			if (RISbuf_debug)
			{
				RIScom_output_debug("RISapp_send_rec: RISCLI_GET_SCH_IN_TRANS_CODE\n");
				RIScom_output_debug("\tsch_count:%d\n", 
					get_sch_in_trans->sch_count);
			}
		}
		break;

		case RISCLI_GET_SCHEMA_FILE_CODE:
		case RISCLI_SHOW_HASH_TABLE_CODE:
		case RISCLI_SHOW_MEMORY_CODE:
		case RISCLI_SHOW_SERVERS_CODE:
		case RISCLI_SHOW_STMTS_CODE:
			STRING_FROM_NET(RIS_arc, &RIS_read->buf.string);	
			if(RISbuf_debug)
			{
				RIScom_output_debug("RISapp_send_rec: GET & SHOW Fns.\n");
			}
		break;

		case RISCLI_EXEC_BLOB_CODE:
			if (ARC_INTEGER_IS_DIFFERENT(RIS_arc->conversion_flags))
			{
				ARC_convert(RIS_arc, FROM_NET, CONVERT_INTEGER, &RIS_read->buf.exec_blob.x_fercount, 0);
			}
		break;
		default:
			break;
	}

	APP_DBG(("RISapp_send_rec:complete\n"));
}

/******************************************************************************/
