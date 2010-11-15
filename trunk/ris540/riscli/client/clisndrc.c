/* Do not alter this SPC information: $Revision: 1.11.3.1 $ */
/*
**	NAME:							clisndrc.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**	4/17/96:	Added check for language code page.  Fix for   
**			TR 439600180.  Ashley B.  
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "rismem.h"
#include "riswarn.h"
#include "ristoken.h"
#include "rispath.h"
#include "risums.h"
#include "client.h"
#include "clicnv.h"
/*         BLOB       */
#include <fcntl.h> 
#include <sys/stat.h> 
#include "risasync.h"
/****   BLOB *****/
#if defined(WIN32) || defined(DOS)
#define close(a) _close(a)
#define open(a,b)  _open(a, b)
#define read(a,b,c)  _read(a,b,c)
#define write(a,b,c) _write(a,b,c)
#define lseek(a,b,c) _lseek(a,b,c)
#endif

#if defined(unix) 
#include <dirent.h>
#endif 

/*
**	DEFINES
*/
#define ALIGN_OFFSET(offset, type) \
{int mod;if((mod=(offset)%(sizeof(type)))!=0)(offset)+= sizeof(type)-mod;}

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clisndrc_c
#include "arcgnerc.prt"
#include "ccoclstm.prt"
#include "ccoeot.prt"
#include "clicksum.prt"
#include "cliclear.prt"
#include "cliclose.prt"
#include "clicnv.prt"
#include "clidebug.prt"
#include "cliexec.prt"
#include "clifetch.prt"
#include "cligetfl.prt"
#include "cliinit.prt"
#include "clilocfl.prt"
#include "cliprep.prt"
#include "clischmg.prt"
#include "clisndrc.prt"
#include "clishhsh.prt"
#include "clishmem.prt"
#include "clishmgr.prt"
#include "clishsrv.prt"
#include "clishstm.prt"
#include "clisserr.prt"
#include "clitrans.prt"
#include "ccooutpt.prt"
#include "comjmp.prt"
#include "comlang.prt"
#include "comdebug.prt"
#include "comoutpt.prt"
#include "comstrng.prt"
#include "comstrcp.prt"
#include "comstmt.prt"
#include "comumsg.prt"
#include "comsttyp.prt"
#include "dicundss.prt"
#include "filglob.prt"
#include "netgnerc.prt"
#include "sys.prt"
/*****  BLOB *******/
#include "usrsndrc.prt"
#include "comalloc.prt"
/*****  BLOB *******/


/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RIScli_send_rec(
	char opcode)
{
	int 	offset;
	arc_s	*arc;
	ris_cliapp_buf *save_app_write;
	ris_appcli_buf *save_app_read;
	int save_app_write_size;
	int save_app_read_size;
	int lang_used;
    /********   BLOB         *******/
    static ris_blob *fetch_blob_fields = 0;
    /********   BLOB         *******/
	int hold_stmt_id;	/* BLOB TR fix */

	CLI_DBG(("RIScli_send_rec(opcode:%d <%s>)\n",
		opcode, RIS_cli_codes[opcode]));

	/*
	**  If we are dealing with a different architecture,
	**  we have to worry about architecture conversion.
	*/
	arc = RIS_app_arc;
	ARC_CONVERT_SHORT(arc, FROM_NET, &RIS_app_read->stmt_id);

    /*
	**  Reset the warning flag before executing any opcode
	*/
	RESET_RIS_WARNING(RIS_warning_flag);
	switch(opcode)
	{
		case RISCLI_INIT_CODE:
		{
			char	config_dir[RIS_MAX_PATH_SIZE];
			char	tmp_config_dir[RIS_MAX_PATH_SIZE];
			char	ums_file[RIS_MAX_PATH_SIZE];
			char 	*lang_name;
			char 	*dir_name;
			struct ris_appcli_buf_client_init *init =
				&RIS_app_read->buf.client_init;

			NET_TO_INIT(arc, init);

                       if ((strcmp((char *)RIS_app_read->pad,"pas")) == 0)   /*arw License bypass 2-8-95 */
                           RIS_cli_license_bypass = 1;

			/*
			** Initialize the language code in the network structures.
			*/
			if (RIS_development)
			{
				sprintf(config_dir, "%s%criscom", RIS_dir, PATH_CHAR);
			}
			else
			{
				strcpy(config_dir, RIS_dir);
			}

			sprintf(tmp_config_dir, "%s%cconfig", config_dir, PATH_CHAR);
			RIScom_initialize_langs(tmp_config_dir);
			if ((lang_name = RIScom_ris_lang_name(init->lang)) == NULL)
			{
				LONGJMP(RIS_E_INVALID_LANG);
			}
#if defined (WIN32)
			/*
			** For NT we initialize it to the default language that has been 
			** set.
			*/
			lang_used = RIScom_init_ums_msg(RIS_UMS_FILE, RIS_dir, 
											RIS_development, 0);
#else
			/*
			** For all other systems, we use the laguage passed in by
			** the application.
			*/
			lang_used = RIScom_init_ums_msg(RIS_UMS_FILE, RIS_dir, 
											RIS_development, lang_name);
#endif
			/*
			** For NT, compare the language code sent by application,
			** with RIS_language_code. If different, error out.
			** For non-NT systems, we should never see this errror, since
			** it is always the application that decides the language code..
			*/
			
			
			CLI_DBG(("RIScli_snd_rec - RIS_language_code = <%d>, code_page = <%d>\n",
			  RIS_language_code, RIScom_get_code_page(RIS_language_code)));
			CLI_DBG(("RIScli_snd_rec - init->lang = <%d>, code_page = <%d>\n",
			  (int)init->lang, RIScom_get_code_page((int)init->lang)));
			if (RIS_language_code != (int)init->lang)
			{
				/* map language ID to code page.  As long as the ANSI code
				** pages are the same then the languages character sets are
				** compatible.  Ashley 4/17/96  TR 439600180
				**/
				if (RIScom_get_code_page(RIS_language_code) !=
				    RIScom_get_code_page((int) init->lang))
					/* fix TR# 249407459 Misspelled error Ris error*/
					LONGJMP(RIS_E_INCOMPATIBLE_LANGS);
			}
			/*
			** Get the language directory name.
			*/
			if (lang_used >= 0)
			{
				dir_name = RIScom_ris_lang_dir(lang_used);
			}
			else
			{
				dir_name = RIScom_ris_lang_dir(init->lang);
			}

			/*
			** Initialize network ums file.
			*/
			sprintf(ums_file,"%s%c%s%cmessages%cnet.msg",
				tmp_config_dir, PATH_CHAR, dir_name, PATH_CHAR, PATH_CHAR);
			NET_init_lang(RIS_app_net, ums_file); 

			RIScli_init(&init->schfile_parms, &init->client_parms, 
				&init->parms, &init->timestamp_parms, init->debug, 
				init->maj, init->min, init->rel);

			strcpy(RIS_app_write->buf.init.xns_addr, RIS_local_xns_addr);
			strcpy(RIS_app_write->buf.init.tcp_addr, RIS_local_tcp_addr);
			strcpy(RIS_app_write->buf.init.dnp_addr, RIS_local_dnp_addr);
			strcpy(RIS_app_write->buf.init.lu62_addr, RIS_local_lu62_addr);

			RIS_app_write_len = RIS_CLIAPP_HDR_SIZE + 
				sizeof(RIS_app_write->buf.init);
		}
		break;

		case RISCLI_DEBUG_CODE:

			NET_TO_DEBUG(arc, &RIS_app_read->buf.debug);

			RIScli_set_debug(RIS_app_read->buf.debug.data,
				RIS_app_read->buf.debug.server_flag);
			RIS_app_write_len = RIS_CLIAPP_HDR_SIZE;
			break;

		case RISCLI_LOCATE_SCHEMA_FILE_CODE:

			NET_TO_LOCATE_SCHEMA_FILE(arc, &RIS_app_read->buf.locate_schfile);

			RIScli_locate_schfile(RIS_app_read->stmt_id);
			RIS_app_write_len = RIS_CLIAPP_HDR_SIZE;
			break;

		case RISCLI_TERM_CODE:
			RIS_app_write_len = RIS_CLIAPP_HDR_SIZE;
			break;

		case RISCLI_CHECKSUM_SCHEMA_FILE_CODE:
			if (RISbuf_debug)
			{
				RIScom_output_debug("RIScli_send_rec: RISCLI_CHECKSUM_SCHEMA_FILE_CODE\n");
				RIScom_output_debug("\tstmt_id:%d\n", RIS_app_read->stmt_id);
			}
			RIScli_checksum_schfile(RIS_app_read->stmt_id);
			RIS_app_write_len = RIS_CLIAPP_HDR_SIZE;
			break;

		case RISCLI_GET_SCHEMA_FILE_CODE:
			RIScli_get_schfile(RIS_app_read->stmt_id);
			RIS_app_write_len = (int)&(((ris_cliapp_buf *)0)->buf.string.data) +
				RIS_app_write->buf.string.len;

			STRING_TO_NET (arc, &RIS_app_write->buf.string);

			break;

		case RISCLI_PREPARE_CODE:
		{
                        int                                                     reset_flags = 0;
			int							tab_count;
			int							i;
			struct rissql				*sql;
			struct ris_cliapp_buf_prep	*prep;
    		struct ristablist			*tab_list;
                        char                                            temp_str[20];

                        
                                              

			NET_TO_PREPARE(arc, &RIS_app_read->buf.prep);
			 RIScom_strncpy(temp_str, RIS_app_read->buf.prep.data, 14);
                        RIScom_uppercase(14, (unsigned char *)temp_str);
                        if (!strncmp(temp_str, "DECLARE SCHEMA", 14))/*itbokic 3/30 */
                        {
                                reset_flags = 1;
                                RIScom_backup_and_reset_flags(0,1,0);
                        }

			RIScli_prepare(RIS_app_read->stmt_id, RIS_app_read->buf.prep.data,
			 0,0,-1);

			prep = &RIS_app_write->buf.prep;
			prep->stmt_type = RIS_stmt->sql->stmt_type;

			if (RIS_stmt->sql)
			{
				offset = 0;
				sql = RIS_stmt->sql;

				/*
				**	First, we load the fixed length data.  While doing
				**	this we can also calculate the size of the variable
				**	length data and set up the pointers into the data section
				*/

				/* input sqlvars */
				ALIGN_OFFSET(offset, long *);
				prep->in_sqlvars = offset;
				prep->in_count = sql->input->sqld;
				prep->in_len = sql->input_len;
				offset += sql->input->sqld * sizeof(sqlvar);

				/* output sqlvars */
				ALIGN_OFFSET(offset, long *);
				prep->out_sqlvars = offset;
				prep->out_count = sql->output->sqld;
				prep->out_len = RIS_stmt->row_len;
				prep->fetch_buf_size = RIS_stmt->fetch_buf_size;
				prep->write_buf_size = RIS_stmt->write_buf_size;
				offset += sql->output->sqld * sizeof(sqlvar);

				/* table list */
				for(tab_count = 0, tab_list = RIS_stmt->tablist;
					tab_list;
					tab_count++, tab_list = tab_list->next);
				prep->tab_list = offset;
				prep->tab_count = tab_count;
				offset += tab_count * RIS_MAX_ID_SIZE;

				/*	schema name */
				if (sql->schema)
				{
					strcpy(prep->schname, sql->schema->schname);
				}
				else
				{
					prep->schname[0] = '\0';
				}

				/*
				**	Test if the buffer is large enough
				*/
				RIS_app_write_len =
					(int)&(((ris_cliapp_buf *)0)->buf.prep.data) + offset;
				if (RIS_app_write_len > RIS_app_write_size)
				{
					CLI_DBG(("RIScli_send_rec: ERROR: RIS_app_write_len:%d > "
						"RIS_app_write_size:%d\n", RIS_app_write_len,
						RIS_app_write_size));
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}

				/*
				**	Now, load the variable length data
				*/

				/* input sqlvars */
				if (sql->input->sqld > 0)
				{
					for (i = 0, offset=0; i < sql->input->sqld;
						  offset += sizeof(sqlvar), i++)
					{
						memcpy((prep->data + prep->in_sqlvars) + offset,
							sql->input->sqlvar + i, (sizeof(sqlvar)));
					}
				}

				/* output sqlvars */
				if (sql->output->sqld > 0)
				{
					for (i=0,offset = 0; i < sql->output->sqld;
						 offset += sizeof(sqlvar), i++)
					{
						memcpy((prep->data + prep->out_sqlvars) + offset,
							sql->output->sqlvar + i, (sizeof(sqlvar)));
					}
				}

				/* table list */
				for(offset = 0, tab_list = RIS_stmt->tablist;
					tab_list;
					offset += RIS_MAX_ID_SIZE, tab_list = tab_list->next)
				{
					memcpy((prep->data + prep->tab_list) + offset,
						tab_list->tab->tabname, RIS_MAX_ID_SIZE);
				}
			}
			else
			{
				prep->in_sqlvars = 0;
				prep->in_count = 0;
				prep->in_len = 0;
				prep->out_sqlvars = 0;
				prep->out_count = 0;
				prep->out_len = 0;
				prep->fetch_buf_size = 0;
				prep->write_buf_size = 0;
				prep->tab_list = 0;
				prep->tab_count = 0;
				prep->schname[0] = '\0';
				RIS_app_write_len =
					(int)&(((ris_cliapp_buf *)0)->buf.prep.data);
			}

			if (RISbuf_debug)
			{
				int				i;
				struct sqlvar	*var;

				RIScom_output_debug("RIScli_send_rec: RISCLI_PREPARE_CODE\n");
				RIScom_output_debug("\tRIS_app_write:0x%x RIS_app_write_len:%d\n",
					RIS_app_write, RIS_app_write_len);
				RIScom_output_debug("\tRIS_app_write->status:%d\n",
					RIS_app_write->status);
				RIScom_output_debug("\tin_sqlvar(offset):%d\n", prep->in_sqlvars);
				RIScom_output_debug("\tout_sqlvar(offset):%d\n", prep->out_sqlvars);
				RIScom_output_debug("\tin_count:%d\n", prep->in_count);
				RIScom_output_debug("\tout_count:%d\n", prep->out_count);
				RIScom_output_debug("\tin_len:%d\n", prep->in_len);
				RIScom_output_debug("\tout_len:%d\n", prep->out_len);
				RIScom_output_debug("\tfetch_buf_size:%d\n", prep->fetch_buf_size);
				RIScom_output_debug("\twrite_buf_size:%d\n", prep->write_buf_size);

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

				RIScom_output_debug("\ttab_count:%d\n", prep->tab_count);
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
		
			if (reset_flags)
                        {
                                RIScom_restore_flags();
                                reset_flags = 0;
                        }
	
			PREPARE_TO_NET (arc, prep);
		}
		break;

		case RISCLI_EXECUTE_CODE:
        /* *************  blob ********** */
        /* cli_exec_deferred is for non blob data */
        case RISCLI_EXEC_DEFERRED_CODE:
        /* cli_exec_blob is for blob data */
        case RISCLI_EXEC_BLOB_CODE:
 
		{
                        int                                                     reset_flags = 0;
			int							eot_schname_count;
			char						*eot_schname_list;
			int							clear_stmt_count;
			short						*clear_stmt_list;
            struct ris_cliapp_buf_exec  *exec = 0;
            struct ris_appcli_buf_exec  *exec_deferred=0;
            struct ris_appcli_buf_exec_blob *exec_blob = 0;
			/*  The blobinfo:

			 7 6  5 4  3 2  1 0	
			 | |  | |  | |  | |
			 | |  | |  | |  | | 
			 | |  | |unnused|
			 | |  | |  		| - more_blob_data_to_follow
			 | |             _more_blob_column_to_follow
		     | |  | local_file 		 
			 | |  remote_file
		     | deffered_code 		 
			 execblob_code 
			*/
            unsigned char blobinfo =0x00;
            char *data=0;

	       CLI_DBG(("RIScli_send_rec: tree->tok <%d>\n",
               RIS_stmts[RIS_app_read->stmt_id]->tree->tok));
               if (RIS_stmts[RIS_app_read->stmt_id]->tree->tok ==
                          RIS_TOK_DECLARE_SCHEMA)
                        {
                                reset_flags = 1;
                                RIScom_backup_and_reset_flags(0,1,0);
                        }


            switch(opcode)
            {
            case RISCLI_EXEC_BLOB_CODE:
                    exec_blob = &RIS_app_read->buf.exec_blob;
                	data= RIS_app_read->buf.exec_blob.data;


			NET_TO_BLOB_EXECUTE(arc, exec_blob);

            blobinfo = 0x80;
			
            /* file_used ? */
           	switch	(exec_blob->file_used) 
			{
				case 1 :
						blobinfo |= 0x10;
				break;

				case 2 :
						blobinfo |= 0x20;
				break;
			}

            /* more_blob_data_to_follow ? */
            if (exec_blob->more_to_follow & 0x01)
             blobinfo |= 0x01;

			/* more_blob_colulmns ? */
            if (exec_blob->more_to_follow & 0x02)
             blobinfo |= 0x02;

            if (RISbuf_debug)
            {

                RIScom_output_debug("APP_TO_CLI: RISCLI_EXEC_BLOB_CODE\n");
                RIScom_output_debug("\tmore_to_follow:%d\n", exec_blob->more_to_follow);
                RIScom_output_debug("\tfile_used:%d\n", exec_blob->file_used);
                RIScom_output_debug("\txfcount:%d\n", exec_blob->xfcount);
                RIScom_output_debug("\tblob_col_pos:%d\n", exec_blob-> blob_col_pos);
                RIScom_output_debug("RIS_app_read_len %d\n", RIS_app_read_len);
            }
            break;
           case RISCLI_EXEC_DEFERRED_CODE:
            /* deferred */
                exec_deferred= &RIS_app_read->buf.exec;

                data= RIS_app_read->buf.exec.data;
                blobinfo = 0x40;

				NET_TO_EXECUTE(arc, 
								RIS_stmts[RIS_app_read->stmt_id]->sql, 
								exec_deferred);

                if (RISbuf_debug)
                {
                    RIScom_output_debug("APP_TO_CLI: RISCLI_EXEC_DEFERRED_CODE\n");
                }
            break;
           case RISCLI_EXECUTE_CODE:

				NET_TO_EXECUTE(arc, RIS_stmts[RIS_app_read->stmt_id]->sql,
				&RIS_app_read->buf.exec);
			break;
			}
		

			if (RISbuf_debug)
			{
                if (opcode != RISCLI_EXEC_BLOB_CODE)
                {
				RIScom_output_debug("BUFFER: APP_TO_CLI: RISCLI_EXECUTE_CODE\n");
				RIScom_output_debug("\texecute_mode:0x%x\n",
					RIS_app_read->execute_mode);
				RIScom_output_debug("\tstmt_id:%d\n", RIS_app_read->stmt_id);
				RIScom_output_debug("\tinput data:\n");
				RIScco_output_internal_data(RIScom_output_debug,
					RIS_stmts[RIS_app_read->stmt_id]->sql->input->sqld, 
					RIS_stmts[RIS_app_read->stmt_id]->sql->input->sqlvar, 
					RIS_app_read->buf.exec.data, 2);
				}
                else
                {
                    static int fd = 0;
                    int ret_status = 0;
                    if (fd == 0)
                    {
                        fd=open("/usr/tmp/clibuf.out", O_CREAT|O_RDWR|O_APPEND);
                    }
                    ret_status=write(fd, data, exec_blob->xfcount);

                    RIScom_output_debug("client blob buffer write : %d\n", ret_status);

                }

			}

			RIScli_execute(RIS_app_read->stmt_id, RIS_app_read->execute_mode,
						blobinfo);

			/*
			**	Fill in the fixed size data;
			*/
			offset = 0;
			exec = &RIS_app_write->buf.exec;

			/* default schema name */
			if (RIScom_can_change_dflt_schema(RIS_stmt->sql->stmt_type) &&
				RIS_default)
			{
				if (RIS_default->superschema_flag == PRIMARY_SCHEMA)
				{
					strcpy(exec->RIS_def_schname,
					 RIS_default->super_schp->schname);
				}
				else
				{
					strcpy(exec->RIS_def_schname, RIS_default->schname);
				}
			}
			else
			{
				exec->RIS_def_schname[0] = 0;
			}

			/*************        BLOB  *********/

            if (opcode == RISCLI_EXEC_BLOB_CODE) 
			{		
				CLI_DBG(("RIScli_send_rec srv exec_blob->x_fercount %d\n",
           			RIS_srv_read->buf.exec_blob.x_fercount));

				/* exec_blob returns x_fercount to app. */
                ARC_CONVERT_INTEGER(arc,TO_NET,
							&RIS_app_write->buf.exec_blob.x_fercount);

				CLI_DBG(("RIScli_send_rec app exec_blob.x_fercount %d\n",
           			RIS_app_write->buf.exec_blob.x_fercount));

           		RIS_app_write_len = RIS_srv_read_len;

                break;
			}

            /* EXEC_CODE and EXEC_DEFERRD_CODE shared same data stru. */
            exec = &RIS_app_write->buf.exec;

			/*************        BLOB  *********/

			/* eot schname list */
			RIScco_get_eot_schname_list(&eot_schname_count, &eot_schname_list);
			exec->eot_schname_count = eot_schname_count;
			exec->eot_schname_list = offset;
			offset += eot_schname_count * RIS_MAX_ID_SIZE;

			/* clear stmt list */
			RIScco_get_clear_stmt_list(&clear_stmt_count, &clear_stmt_list);
			exec->clear_stmt_count = clear_stmt_count;
			exec->clear_stmt_list = offset;
			offset += clear_stmt_count * sizeof(short);

			/*
			**	Test if the buffer is large enough
			*/
			RIS_app_write_len =
				(int)&(((ris_cliapp_buf *)0)->buf.exec.data) + offset;
			if (RIS_app_write_len > RIS_app_write_size)
			{
				CLI_DBG(("RIScli_send_rec: ERROR: RIS_app_write_len:%d > "
					"RIS_app_write_size:%d\n", RIS_app_write_len,
					RIS_app_write_size));
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}

			/*
			**	Now, load the variable length data
			*/

			/* eot schname list */
			memcpy(exec->data, eot_schname_list,
				eot_schname_count * RIS_MAX_ID_SIZE);

			RIScco_clear_eot_schname_list();

			/* clear stmt list */
			memcpy(exec->data,clear_stmt_list,clear_stmt_count * sizeof(short));
			RIScco_clear_clear_stmt_list();

			if (RISbuf_debug)
			{
				int i;

				RIScom_output_debug("RIScli_send_rec: RISCLI_EXEC_CODE\n");
				RIScom_output_debug("\tRIS_def_schname:<%s>\n",
					exec->RIS_def_schname);
				RIScom_output_debug("\teot_schname_count:%d\n",
					exec->eot_schname_count);
				if (exec->eot_schname_count)
				{
					RIScom_output_debug("\teot_schname list:\n");
					for(i = 0; i < exec->eot_schname_count; i++)
					{
						RIScom_output_debug("\t\t<%s>\n",
							exec->data + exec->eot_schname_list +
							(i*RIS_MAX_ID_SIZE));
					}
				}
				RIScom_output_debug("\tclear_stmt_count:%d\n", exec->clear_stmt_count);
				if (exec->clear_stmt_count)
				{
					RIScom_output_debug("\tclear_stmt list:\n");
					for(i = 0; i < exec->clear_stmt_count; i++)
					{
						RIScom_output_debug("\t\t%d\n",
							*(exec->data + exec->clear_stmt_list +
							(i * sizeof(short))));
					}
				}
			}
			EXECUTE_TO_NET(arc, exec);
			if (reset_flags)
                        {
                                RIScom_restore_flags();
                                reset_flags = 0;
                        }

		}
		break;

		case RISCLI_FETCH_BLOB_CODE:
		{
			CLI_DBG(("RIScli_send_rec: RISCLI_FETCH_BLOB_CODE\n"));
			NET_TO_FETCH_BLOB(arc, &RIS_app_read->buf.fetch_blob);
            if (RISbuf_debug)
            {
                RIScom_output_debug("\tblob_col_pos %d\n",  
                    RIS_app_read->buf.fetch_blob.blob_col_pos);
                RIScom_output_debug("\tfile_used %d\n",  
                    RIS_app_read->buf.fetch_blob.file_used);
            }

		   	if ( RIS_app_net->protocol == SHMEM   
				 && RIS_app_read->buf.fetch_blob.file_used == 1)
			{
				if(! fetch_blob_fields)
					LONGJMP(RIS_E_INTERNAL_ERROR);

		   		if (RIS_stmt->sql->schema->net->protocol != SHMEM)
				{
					/* app is local, server is remote, retrieve the data
					from server build the file right here in the client
					save the client -> app etwork traffic */

					RIScli_fetch_blob(fetch_blob_fields);
				}			
				else
				{
					/* app, client and server are on same node
						and a file is used , the blob data should
						have been fetched to the file by FETCH_BUF_CODE */
					RIS_app_write->buf.fetch_blob.more_to_follow=0;	

					RIS_app_write->buf.fetch_blob.xfercount=0;	

               		RIS_app_write_len = 
					(int)&(((ris_cliapp_buf *)0)->buf.fetch_blob.data);

					CLI_DBG(("\tfetch_blob.xfercount=%d, RIS_app_write_len = %d\n",
						RIS_app_write->buf.fetch_blob.xfercount,RIS_app_write_len));
				}
				/* Update the fetch_blob_fileds for next blob column */
				fetch_blob_fields ++;
			}
			else
			{
				/* No variable data to be sent to server */
				/* Pass whatever we got from server to app */ 

           		RISusr_send_rec (RIS_FETCH_BLOB_CODE, RIS_stmt->sql, SYNC_MODE);

           		RIS_app_write_len = RIS_srv_read_len;
           		if (RISbuf_debug)
           		{
					RIScom_output_debug("\txfercount:<%d>\n",
						RIS_srv_read->buf.fetch_blob.xfercount);
					RIScom_output_debug("\tmore_to_follow:<%d>\n",
						RIS_srv_read->buf.fetch_blob.more_to_follow);
				}

				FETCH_BLOB_TO_NET(arc, &RIS_app_write->buf.fetch_blob);
			}
		}
		break;

		case RISCLI_FETCH_CODE_4:
		case RISCLI_FETCH_CODE:
		{
			struct ris_appcli_buf_fetch_4 *fetch_appcl_4 = 
										&RIS_app_read->buf.fetch_4;
			struct ris_appcli_buf_fetch *fetch_appcl = 
										&RIS_app_read->buf.fetch;
			ris_srvcli_buf *DBG_RIS_srv_read = 0;
			unsigned int *row_count=0;
 
			if (opcode == RISCLI_FETCH_CODE_4)
			{			
				CLI_DBG(("RIScli_send_rec: RISCLI_FETCH_CODE_4\n"));
				NET_TO_FETCH_4(arc, fetch_appcl_4);
				row_count=&fetch_appcl_4->row_count;
			}
			else
			{
				CLI_DBG(("RIScli_send_rec: RISCLI_FETCH_CODE\n"));
				NET_TO_FETCH(arc, fetch_appcl);
				row_count=&fetch_appcl->row_count;
			}	
			CLI_DBG(("\tRIS_app_read_len = <%d>\n", RIS_app_read_len));

			/***********          BLOB      **************/
			if (RISbuf_debug && opcode == RISCLI_FETCH_CODE)
			{
				int i;
				ris_blob *tmp_ris_blob = (ris_blob *) fetch_appcl->data;

				RIScom_output_debug("\tout_data %d\n", fetch_appcl->out_data);
				RIScom_output_debug("\tfile_names %d\n", fetch_appcl->file_names);
				RIScom_output_debug("\trow_count %d\n", fetch_appcl->row_count);
				RIScom_output_debug("\tblob_count %d\n", fetch_appcl->blob_count);
				for (i=0; i < fetch_appcl->blob_count; ++i, tmp_ris_blob++)
				{
					RIScom_output_debug("\tBLOB column %d:\n", i);
					RIScom_output_debug("\t\tfile_used=<%d>\n", tmp_ris_blob->file_used);
					RIScom_output_debug("\t\tarray_size=<%d>\n", tmp_ris_blob->array_size);
				}
			}
			/***********          BLOB      **************/

			/*
			** Check if the write buffer is large enough
			*/
			CLI_DBG(("RIS_stmt->fetch_buf_size:%d\n",RIS_stmt->fetch_buf_size));
			CLI_DBG(("RIS_app_write_size:%d\n", RIS_app_write_size));

			if (RIS_stmt->fetch_buf_size > (unsigned int)RIS_app_write_size)
			{
				save_app_write = RIS_app_write;
				save_app_write_size = RIS_app_write_size;
				RIS_app_write = (ris_cliapp_buf *)
					NET_realloc((char *)RIS_app_write,RIS_stmt->fetch_buf_size);
				if (RIS_app_write == NULL)
				{
					RIS_app_write = save_app_write;
					RIS_app_write_size = save_app_write_size;

					LONGJMP(RIS_E_NET_ALLOC_ERROR);
				}
				RIS_app_write_size = RIS_stmt->fetch_buf_size;
			}

			/* 
			** Save the file name and blobinfo to be used
			** in the FETCH_BLOB_CODE 	
			**
			** We only need to do this if blob/long col are
			** involved and there are rows to be fetched
			**
			** We used to do it after we fetch from server
			** (so that we could check fetch_srvcli->row_count)
			** But, the fetch_appcl will be converted when it's
			** sent to server; so we need to save before we call
			** RIScli_fetch().			Surjit (Dec.28, 1994)
			*/ 

			if (RIS_app_net->protocol == SHMEM && opcode == RISCLI_FETCH_CODE
			   && fetch_appcl->blob_count > 0 && fetch_appcl->file_names > 0)
			{
				int i=0;
				ris_blob *app_blob_fields=(ris_blob *) fetch_appcl ->data; 
				ris_blob *tmp_fetch_blob_fields=0; 
				char *file_names_list=fetch_appcl->data + fetch_appcl->out_data;
 
				fetch_blob_fields = ALLOCN(ris_blob,fetch_appcl->blob_count);
				tmp_fetch_blob_fields=fetch_blob_fields; 

				for (i=0; i< fetch_appcl->blob_count; ++i, ++app_blob_fields)
				{
					if (app_blob_fields->file_used)
					{
						tmp_fetch_blob_fields->array_size = app_blob_fields->array_size;
						tmp_fetch_blob_fields->file_offset = app_blob_fields->file_offset;
						tmp_fetch_blob_fields->file_used = app_blob_fields->file_used;

						tmp_fetch_blob_fields->filename = 
							ALLOCN(char,app_blob_fields->array_size); 
						strcpy(tmp_fetch_blob_fields->filename, file_names_list);

						if (RISbuf_debug)
						{
							RIScom_output_debug("Saving blob filenames ...\n");
							RIScom_output_debug("\tfile_used=<%d>, filename=<%s>\n",
								tmp_fetch_blob_fields->file_used,
								tmp_fetch_blob_fields->filename);
						}

						file_names_list += app_blob_fields->array_size ;
						tmp_fetch_blob_fields++;
					}
				}
			}

			/*
			** RIScli_fetch will convert RIS_app_read->stmt_id
			** so lets save the value  12/6/94 - Ashley
			*/
			hold_stmt_id = RIS_app_read->stmt_id;
			CLI_DBG(("HOLD stmt_id <%d>\n",RIS_app_read->stmt_id));

			CLI_DBG(("RIScli_send_rec: RIS_srv_write_len = <%d>\n",
					RIS_srv_write_len));
			RIScli_fetch(RIS_app_read->stmt_id, *row_count, 
				(opcode == RISCLI_FETCH_CODE),
				RIS_app_read->execute_mode);

			/*
			** Since RIScli_fetch() changed RIS_app_read->stmt_id,
			** let's change it back to saved value.  12/6/94 - Ashley
			*/
			RIS_app_read->stmt_id = hold_stmt_id;
			CLI_DBG(("RESTORE stmt_id <%d>\n",RIS_app_read->stmt_id));

			RIS_app_write_len = RIS_srv_read_len;

			if (RISbuf_debug)
			{
				RIScom_output_debug("\trow_count:%d\n",
					RIS_app_write->buf.fetch.row_count);
				RIScom_output_debug("\tmore_to_follow:%d\n",
					RIS_app_write->buf.fetch.more_to_follow);
			}

			DBG_RIS_srv_read = RIS_srv_read;
			FETCH_TO_NET(arc, RIS_stmts[RIS_app_read->stmt_id],
					&RIS_app_write->buf.fetch);
		}
		break;

		case RISCLI_CLOSE_CODE:
		{
			int							eot_schname_count;
			char						*eot_schname_list;
			struct ris_cliapp_buf_close	*close;

			RIScli_close(RIS_app_read->stmt_id, RIS_app_read->execute_mode);

			/*
			**	Fill in the fixed size data;
			*/
			offset = 0;
			close = &RIS_app_write->buf.close;

			/* eot schname list */
			RIScco_get_eot_schname_list(&eot_schname_count, &eot_schname_list);
			close->eot_schname_count = eot_schname_count;
			offset += eot_schname_count * RIS_MAX_ID_SIZE;

			/*
			**	Test if the buffer is large enough
			*/
			RIS_app_write_len =
				(int)&(((ris_cliapp_buf *)0)->buf.close.data) + offset;
			if (RIS_app_write_len > RIS_app_write_size)
			{
				CLI_DBG(("RIScli_send_rec: ERROR: RIS_app_write_len:%d > "
					"RIS_app_write_size:%d\n", RIS_app_write_len,
					RIS_app_write_size));
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}

			/*
			**	Now, load the variable length data
			*/

			/* eot schname list */
			memcpy(close->data, eot_schname_list,
				eot_schname_count * RIS_MAX_ID_SIZE);
			RIScco_clear_eot_schname_list();

			if (RISbuf_debug)
			{
				int i;

				RIScom_output_debug("RIScli_send_rec: RISCLI_CLOSE_CODE\n");
				RIScom_output_debug("\teot_schname_count:%d\n",
					close->eot_schname_count);
				if (close->eot_schname_count)
				{
					RIScom_output_debug("\teot_schname list:\n");
					for(i = 0; i < close->eot_schname_count; i++)
					{
						RIScom_output_debug("\t\t<%s>\n",
							close->data + (i*RIS_MAX_ID_SIZE));
					}
				}
			}

			CLOSE_TO_NET (arc, close);

		}
		break;

		case RISCLI_CLEAR_CODE:
		{
			int							eot_schname_count;
			char						*eot_schname_list;
			struct ris_cliapp_buf_clear	*clear;

			NET_TO_CLEAR(arc, &RIS_app_read->buf.clear);

			RIScli_clear(RIS_app_read->stmt_id,
				RIS_app_read->buf.clear.set_sqlcode,
				RIS_app_read->execute_mode,
				0);

			/*
			**	Fill in the fixed size data;
			*/
			offset = 0;
			clear = &RIS_app_write->buf.clear;

			/* eot schname list */
			RIScco_get_eot_schname_list(&eot_schname_count, &eot_schname_list);
			clear->eot_schname_count = eot_schname_count;
			offset += eot_schname_count * RIS_MAX_ID_SIZE;

			/*
			**	Test if the buffer is large enough
			*/
			RIS_app_write_len =
				(int)&(((ris_cliapp_buf *)0)->buf.clear.data) + offset;
			if (RIS_app_write_len > RIS_app_write_size)
			{
				CLI_DBG(("RIScli_send_rec: ERROR: RIS_app_write_len:%d > "
					"RIS_app_write_size:%d\n", RIS_app_write_len,
					RIS_app_write_size));
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}

			/*
			**	Now, load the variable length data
			*/

			/* eot schname list */
			memcpy(clear->data, eot_schname_list,
				eot_schname_count * RIS_MAX_ID_SIZE);
			RIScco_clear_eot_schname_list();

			if (RISbuf_debug)
			{
				int i;

				RIScom_output_debug("RIScli_send_rec: RISCLI_CLEAR_CODE\n");
				RIScom_output_debug("\teot_schname_count:%d\n",
					clear->eot_schname_count);
				if (clear->eot_schname_count)
				{
					RIScom_output_debug("\teot_schname list:\n");
					for(i = 0; i < clear->eot_schname_count; i++)
					{
						RIScom_output_debug("\t\t<%s>\n",
							clear->data + (i*RIS_MAX_ID_SIZE));
					}
				}
			}

			CLEAR_TO_NET (arc, clear);

		}
		break;

		case RISCLI_SHOW_MEMORY_CODE:
			RIScli_show_memory();
			RIS_app_write_len = (int)&(((ris_cliapp_buf *)0)->buf.string.data) +
				RIS_app_write->buf.string.len;

			STRING_TO_NET (arc, &RIS_app_write->buf.string);

			break;

		case RISCLI_SHOW_STMTS_CODE:
			RIScli_show_stmts();
			RIS_app_write_len = (int)&(((ris_cliapp_buf *)0)->buf.string.data) +
				RIS_app_write->buf.string.len;

			STRING_TO_NET (arc, &RIS_app_write->buf.string);

			break;

		case RISCLI_SHOW_HASH_TABLE_CODE:
			RIScli_show_hash();
			RIS_app_write_len = (int)&(((ris_cliapp_buf *)0)->buf.string.data) +
				RIS_app_write->buf.string.len;

			STRING_TO_NET (arc, &RIS_app_write->buf.string);

			break;

		case RISCLI_SHOW_SERVERS_CODE:
			RIScli_show_servers();
			RIS_app_write_len = (int)&(((ris_cliapp_buf *)0)->buf.string.data) +
				RIS_app_write->buf.string.len;

			STRING_TO_NET (arc, &RIS_app_write->buf.string);

			break;

		case RISCLI_SHOW_STRUCT_MGRS_CODE:
			RIScli_show_struct_mgrs();
			RIS_app_write_len = (int)&(((ris_cliapp_buf *)0)->buf.string.data) +
				RIS_app_write->buf.string.len;

			STRING_TO_NET (arc, &RIS_app_write->buf.string);

			break;

		case RISCLI_DICT_ROLLBACK_CODE:
			RISfil_globals_rollback();
			RIS_app_write_len = RIS_CLIAPP_HDR_SIZE;
			break;

		case RISCLI_REPORT_SS_ERROR_CODE:
			RIScli_report_ss_error(RIS_app_read->buf.report_ss_error.ss_name);

			REPORT_SS_ERROR_TO_NET(arc, &RIS_app_write->buf.report_ss_error);

			break;

		case RISCLI_SCHEMA_MGR_CODE:
			if (RISbuf_debug)
			{
				RIScom_output_debug("RIScli_send_rec: RISCLI_SCHEMA_MGR_CODE\n");
				RIScom_output_debug("\tstmt_id:%d\n", RIS_app_read->stmt_id);
				RIScom_output_debug("\tmode:%d\n", RIS_app_read->buf.schema_mgr.mode);
				RIScom_output_debug("\tdata:<%s>\n",
					STRING(RIS_app_read->buf.schema_mgr.data));
				RIScom_output_debug("\tstr:<%s>\n",
					STRING(RIS_app_read->buf.schema_mgr.str));
			}
			RIScli_schema_mgr(RIS_app_read->stmt_id,
				RIS_app_read->buf.schema_mgr.mode,
				RIS_app_read->buf.schema_mgr.data,
				RIS_app_read->buf.schema_mgr.str);

			if (RIS_default)
			{
				strcpy(RIS_app_write->buf.schema_mgr.RIS_def_schname,
					RIS_default->schname);
			}
			else
			{
				RIS_app_write->buf.schema_mgr.RIS_def_schname[0] = 0;
			}

			RIS_app_write_len = RIS_CLIAPP_HDR_SIZE +
				sizeof(RIS_app_write->buf.schema_mgr);

			if (RISbuf_debug)
			{
				RIScom_output_debug("RIScli_send_rec: RISCLI_SCHEMA_MGR_CODE\n");
				RIScom_output_debug("\tRIS_def_schname:<%s>\n", 
					RIS_app_write->buf.schema_mgr.RIS_def_schname);
			}
			break;

		case RISCLI_GET_FLAGS_CODE:
			RIS_app_write->buf.get_flags.ansi_mode = RIS_ansi_mode;
			RIS_app_write->buf.get_flags.enable_dbms = RIS_enable_dbms;
			RIS_app_write->buf.get_flags.verify_mode = RIS_verify_mode;
			RIS_app_write->buf.get_flags.blankstrip_mode = RIS_blankstrip_mode;
			RIS_app_write->buf.get_flags.autocommit = RIS_autocommit;
			RIS_app_write->buf.get_flags.autorename = RIS_autorename_mode;
			RIS_app_write_len = RIS_CLIAPP_HDR_SIZE +
				sizeof(RIS_app_write->buf.get_flags);

			GET_FLAGS_TO_NET (arc, &RIS_app_write->buf.get_flags);

			break;

		case RISCLI_GROW_APP_TO_CLI_BUF_CODE:

			ARC_CONVERT_INTEGER(arc, FROM_NET, 
				&RIS_app_read->buf.grow_buf.new_size);

			RIS_app_read_size = RIS_app_read->buf.grow_buf.new_size;

			save_app_read = RIS_app_read;
			save_app_read_size = RIS_app_read_size;
			RIS_app_read = (ris_appcli_buf *)
				NET_realloc((char *)RIS_app_read, RIS_app_read_size);
			if (RIS_app_read == NULL)
			{
				RIS_app_read = save_app_read;
				RIS_app_read_size = save_app_read_size;

				LONGJMP(RIS_E_NET_ALLOC_ERROR);
			}
			RIS_app_write_len = RIS_CLIAPP_HDR_SIZE;
			break;

		case RISCLI_GROW_CLI_TO_APP_BUF_CODE:

			ARC_CONVERT_INTEGER(arc, TO_NET, 
				&RIS_app_read->buf.grow_buf.new_size);

			RIS_app_write_size = RIS_app_read->buf.grow_buf.new_size;

			save_app_write = RIS_app_write;
			save_app_write_size = RIS_app_write_size;
			RIS_app_write = (ris_cliapp_buf *)	
				NET_realloc((char *)RIS_app_write, RIS_app_write_size);
			if (RIS_app_write == NULL)
			{
				RIS_app_write = save_app_write;
				RIS_app_write_size = save_app_write_size;

				LONGJMP(RIS_E_NET_ALLOC_ERROR);
			}
			RIS_app_write_len = RIS_CLIAPP_HDR_SIZE;
			break;

		case RISCLI_GET_SS_NAMES_CODE:
		{
			int count;
			rissuperschema *sschema;

			count = 0;
			for (sschema = RIS_super_schema; sschema; sschema = sschema->next)
			{
				count++;
			}
			offset = count * RIS_MAX_ID_SIZE;

			RIS_app_write_len =
				(int)&(((ris_cliapp_buf *)0)->buf.get_ss_names.data) + offset;
			if (RIS_app_write_len > RIS_app_write_size)
			{
				CLI_DBG(("RIScli_send_rec: ERROR: RIS_app_write_len:%d > "
					"RIS_app_write_size:%d\n", RIS_app_write_len,
					RIS_app_write_size));
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}

			RIS_app_write->buf.get_ss_names.ss_count = count;

			offset = 0;
			for (sschema = RIS_super_schema; sschema; sschema = sschema->next)
			{
				memcpy(RIS_app_write->buf.get_ss_names.data + offset,
					sschema->schname, RIS_MAX_ID_SIZE);
				offset += RIS_MAX_ID_SIZE;
			}
			GET_SS_NAMES_TO_NET(arc, &RIS_app_write->buf.get_ss_names);
		}

		break;

		case RISCLI_GET_SS_DEF_CODE:
		{
			int count;
			rissuperschema *sschema;
			risschema *schema;

			sschema=RISdic_find_supersch(RIS_app_read->buf.get_ss_def.ss_name);
			if (sschema == NULL)
			{
				LONGJMP(RIS_E_SUPERSCHEMA_NOT_DECLARED);
			}
			if (!sschema->sub_schp)
			{
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}

			count = 0;
			for (schema = sschema->sub_schp; schema; schema = schema->sub_schp)
			{
				count++;
			}
			offset = count * RIS_MAX_ID_SIZE;

			RIS_app_write_len =
				(int)&(((ris_cliapp_buf *)0)->buf.get_ss_def.data) + offset;
			if (RIS_app_write_len > RIS_app_write_size)
			{
				CLI_DBG(("RIScli_send_rec: ERROR: RIS_app_write_len:%d > "
					"RIS_app_write_size:%d\n", RIS_app_write_len,
					RIS_app_write_size));
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}

			RIS_app_write->buf.get_ss_def.ss_count = count;

			offset = 0;
			for (schema = sschema->sub_schp; schema; schema = schema->sub_schp)
			{
				memcpy(RIS_app_write->buf.get_ss_def.data + offset,
					schema->schname, RIS_MAX_ID_SIZE);
				offset += RIS_MAX_ID_SIZE;
			}

			GET_SS_DEF_TO_NET(arc, &RIS_app_write->buf.get_ss_def);

		}
		break;

		case RISCLI_GET_SCH_IN_TRANS_CODE:
		{
			RIScli_get_sch_in_trans_tobuf();
			GET_SCH_IN_TRANS_TO_NET(arc, &RIS_app_write->buf.get_sch_in_trans);
		}
		break;

		default:
			CLI_DBG(("RIScli_send_rec: invalid opcode:%d\n", opcode));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		break;
	}
	RIS_app_write->status = RIS_SUCCESS;
	if( RISbuf_debug )
	{
		RIScom_output_debug("RIScli_send_rec: RIS_warning_flag:%d\n", RIS_warning_flag);
	}
	RIS_app_write->warning = RIS_warning_flag;

	ARC_CONVERT_INTEGER(arc, TO_NET, &RIS_app_write->status);

	CLI_DBG(("RIScli_send_rec:complete\n"));
}

/******************************************************************************/
