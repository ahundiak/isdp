/* Do not alter this SPC information: $Revision: 1.2.39.1 $ */
/*
**	NAME:							apptobuf.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**		The routine to fill in the RIS_write buffer and RIS_write_len;
**	
**	REVISION HISTORY:
**		Jan. 94,	Modified to take care of interoperability -- SK
**
**		Sep. 94,	Modified RISapp_locate_schfile_to_buf to work with multi-byte chars.
**					Mark Boswell
*/
 
/*
**	INCLUDES
*/
#include <stdarg.h>
#include <ctype.h>
#include "app.h"
#include "commacro.h"
#include "riscom.h"
#include "risasync.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define apptobuf_c
#include "appcnv.prt"
#include "arcgnerc.prt"
#include "appsndrc.prt"
#include "apptobuf.prt"
#include "appparms.prt"
#include "comdebug.prt"
#include "comexmod.prt"
#include "comisfn.prt"
#include "comuni.prt"
#include "comjmp.prt"
#include "netgnerc.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISapp_opcode_to_buf(
	unsigned char	opcode,
	unsigned char	execute_mode)
{
	APP_DBG(("RISapp_opcode_to_buf(opcode:%d(%s) execute_mode:%s)\n",
		opcode, RIS_cli_codes[opcode],
		RIScom_get_execute_mode_name(execute_mode)));

	RIS_write->opcode = opcode;
	RIS_write->execute_mode = execute_mode;
	RIS_write->stmt_id = RIS_current_stmt_id;

	RIS_write_len = RIS_APPCLI_HDR_SIZE;

	convert_stmt_id();
	APP_DBG(("RISapp_opcode_to_buf: complete\n"));
}

/******************************************************************************/

extern void RISapp_client_init_to_buf()
{
	APP_DBG(("RISapp_client_init_to_buf()\n"));

	RIS_write->opcode = RISCLI_INIT_CODE;
	RIS_write->execute_mode = SYNC_MODE;
	RIS_write->stmt_id = RIS_current_stmt_id;

	if (RIS_license_bypass)                         /* arw license bypass 2-8-95 */
	      strcpy((char *)RIS_write->pad,"pas");     /* arw license bypass 2-8-95 */

	memcpy(&RIS_write->buf.client_init.schfile_parms, &RIS_schfile_parms,
		sizeof(RIS_schfile_parms));
	/*
	**	only copy the relevent info to the buffer for client -- SK
	*/
	RIS_write->buf.client_init.client_parms.protocol
			= RIS_client_parms.protocol;
	strcpy(RIS_write->buf.client_init.client_parms.address, 
			RIS_client_parms.address);
	strcpy(RIS_write->buf.client_init.client_parms.username, 
			RIS_client_parms.username);
	strcpy(RIS_write->buf.client_init.client_parms.password, 
			RIS_client_parms.password);

	memcpy(&RIS_write->buf.client_init.parms,&RIS_parms, sizeof(RIS_parms));
	memcpy(&RIS_write->buf.client_init.timestamp_parms,&RIS_timestamp,
		sizeof(RIS_timestamp));

	RIS_write->buf.client_init.lang = (unsigned char)RIS_language_code;
	RIS_write->buf.client_init.debug = RIScom_debug_flags_to_mask();

	RIS_write->buf.client_init.maj = (unsigned char)RIS_app_version_maj;
	RIS_write->buf.client_init.min = (unsigned char)RIS_app_version_min;
	RIS_write->buf.client_init.rel = (unsigned char)RIS_app_version_rel;

	RIS_write_len = RIS_APPCLI_HDR_SIZE + sizeof(RIS_write->buf.client_init);

	convert_stmt_id();
	INIT_TO_NET(RIS_arc, &RIS_write->buf.client_init);
	APP_DBG(("RISapp_client_init_to_buf:complete\n"));
}

/******************************************************************************/

extern void RISapp_debug_to_buf(
	int server_flag)
{
	APP_DBG(("RISapp_debug_to_buf(server_flag:%d)\n", server_flag));

	RIS_write->opcode = RISCLI_DEBUG_CODE;
	RIS_write->execute_mode = SYNC_MODE;
	RIS_write->stmt_id = RIS_current_stmt_id;

	RIS_write->buf.debug.server_flag = server_flag;
	RIS_write->buf.debug.data = RIScom_debug_flags_to_mask();
	RIS_write_len = RIS_APPCLI_HDR_SIZE + sizeof(RIS_write->buf.debug);

	convert_stmt_id();
	DEBUG_TO_NET(RIS_arc, &RIS_write->buf.debug);
	APP_DBG(("RISapp_debug_to_buf:complete\n"));
}

/******************************************************************************/

extern void RISapp_locate_schfile_to_buf(
	char	protocol,
	char	*address,
	char	*username,
	char	*password,
	char	*filename)
{
	APP_DBG(("RISapp_locate_schfile_to_buf(protocol:%c address:<%s> "
		"username:<%s> filename:<%s>)\n",protocol,address,username,filename));

	RIS_write->opcode = RISCLI_LOCATE_SCHEMA_FILE_CODE;
	RIS_write->execute_mode = SYNC_MODE;
	RIS_write->stmt_id = RIS_current_stmt_id;

	if (ISLOWER(protocol))
	{
		RIS_write->buf.locate_schfile.parms.protocol = 
			(char)RIScom_toupper(protocol);
	}
	else
	{
		RIS_write->buf.locate_schfile.parms.protocol = protocol;
	}

	if (RIS_write->buf.locate_schfile.parms.protocol != 'M')
	{
		strcpy(RIS_write->buf.locate_schfile.parms.address, address);	
		strcpy(RIS_write->buf.locate_schfile.parms.username, username);	
		if (password && *password)
		{
			strcpy(RIS_write->buf.locate_schfile.parms.password, password);	
		}
		else
		{
			RIS_write->buf.locate_schfile.parms.password[0] = '\0';	
		}
	}
	strcpy(RIS_write->buf.locate_schfile.parms.filename, filename);	

	RIS_write_len = RIS_APPCLI_HDR_SIZE + sizeof(RIS_write->buf.locate_schfile);

	convert_stmt_id();
	LOCATE_SCH_FILE_TO_NET(RIS_arc, &RIS_write->buf.locate_schfile);
	APP_DBG(("RISapp_locate_schfile_to_buf:complete\n"));
}

/******************************************************************************/

extern void RISapp_prep_to_buf(
	int		len,
	char	*query) 
{
	APP_DBG(("RISapp_prep_to_buf(len:%d, query)\n", len));

        /*NOTE query was removed from this debug string to prevent passwords
          from being printed out. */
	
	RIS_write->opcode = RISCLI_PREPARE_CODE;
	RIS_write->execute_mode = SYNC_MODE;
	RIS_write->stmt_id = RIS_current_stmt_id;

	memcpy(RIS_write->buf.prep.data, query, len);
	RIS_write->buf.prep.query_len = len;

	RIS_write_len =
		(int)&(((ris_appcli_buf *)0)->buf.prep.data) + len;

	convert_stmt_id();
	PREPARE_TO_NET(RIS_arc, &RIS_write->buf.prep);
	APP_DBG(("RISapp_prep_to_buf:complete\n"));
}

/******************************************************************************/

extern void RISapp_execute_to_buf(
	sqlda	*in_sqlda,
	unsigned char		execute_mode)
{
	APP_DBG(("RISapp_execute_to_buf(in_sqlda:0x%x execute_mode:%s)\n",
		in_sqlda, RIScom_get_execute_mode_name(execute_mode)));

	if (RIS_stmt->write_buf_size > RIS_write_size)
	{
		RIS_write_size = RIS_stmt->write_buf_size;

		RIS_write = (ris_appcli_buf *)NET_realloc((char *)RIS_write,
			RIS_write_size);
		if (RIS_write == NULL)
		{
			APP_DBG(("RISapp_execute_to_buf: Unable to realloc RIS_write\n"));
			LONGJMP(RIS_E_NET_ALLOC_ERROR);
		}

		RIS_save_write_size = RIS_write_size;
		RIS_save_write = RIS_write;

		/*
		**	Send a grow buffer code to the client
		*/
		RISapp_grow_buf_to_buf(RISCLI_GROW_APP_TO_CLI_BUF_CODE);
		RISapp_send_rec();
	}

	RIS_write->opcode = RISCLI_EXECUTE_CODE;
	RIS_write->execute_mode = execute_mode;
	RIS_write->stmt_id = RIS_current_stmt_id;

	if (in_sqlda && in_sqlda->sqln > 0)
	{
		/* input data */
		RISapp_adjust_parms(RIS_stmt->input, RIS_write->buf.exec.data);
		RISapp_process_parms(in_sqlda, RIS_stmt->input, INPUT); 
		RIS_write_len = (int)&(((ris_appcli_buf *)0)->buf.exec.data) +
			RIS_stmt->input_len;
	}
	else
	{
		RIS_write_len = (int)&(((ris_appcli_buf *)0)->buf.exec.data);
	}

	convert_stmt_id();
/*
**	Changed the parameter to RIS_stmt->input from in_sqlda, since
**	RISapp_adjust_parms and RISapp_process_parms functions take care
**	of mapping user data(in_sqlda) to RIS_stmt->input to a format 
**	consistent with the database to be sent to RIS client. So the
**	application should actually do architecture conversion based
**	on RIS_stmt->input, since the data to be sent to Client has
**	been converted to be consistent with database info.
**	This fixes TRS 249403640 and TR# 249402467. RAJU 11/03/94
*/
	EXECUTE_TO_NET(RIS_arc, RIS_stmt->input, &RIS_write->buf.exec);
	APP_DBG(("RISapp_execute_to_buf:complete\n"));
}

/******************************************************************************/
extern void RISapp_execute_blob_to_buf(
    sqlvar *input_blob_sqlvar,
	int text_type,
   	unsigned char     execute_mode,
   	unsigned char    *blobinfo)
{

   	APP_DBG(("RISapp_execute_blob_to_buf(execute_mode:%s)\n",
       RIScom_get_execute_mode_name(execute_mode)));

   	RIS_write->opcode = RISCLI_EXEC_BLOB_CODE;
   	RIS_write->stmt_id = RIS_current_stmt_id;


   	RISapp_process_blob_parms( input_blob_sqlvar, text_type,
							(char *)(RIS_write-> buf.exec_blob.data ), 
							blobinfo);

   	/*  RIS_write_len is set in RISapp_process_blob_parms() */

   	APP_DBG(("RIS_write_len :%d\n", RIS_write_len));

   	RIS_write->opcode = RISCLI_EXEC_BLOB_CODE;
   	RIS_write->execute_mode = (*blobinfo & 0x02)?
                           SYNC_MODE : execute_mode ;

	/* More data for this blob column */
   	RIS_write->buf.exec_blob.more_to_follow = (*blobinfo & 0x01)? 0x01:0;

   	if (*blobinfo & 0x02)
	{
		/* More blob columns ?  */
   		RIS_write->buf.exec_blob.more_to_follow |= 0x02;
	}

   	RIS_write_len = RIS_write->buf.exec_blob.xfcount
                	+ (int)&(((ris_appcli_buf *)0)->buf.exec_blob.data);


   	EXECUTE_BLOB_TO_NET(RIS_arc, &RIS_write->buf.exec_blob);
   	APP_DBG(("RISapp_execute_blob_to_buf:complete\n"));
}

/******************************************************************************/

extern void RISapp_fetch_to_buf(
	unsigned int	row_count,
	unsigned char				execute_mode)
{
	APP_DBG(("RISapp_fetch_to_buf(row_count:%d execute_mode:%s)\n",
		row_count, RIScom_get_execute_mode_name(execute_mode)));

	/******   BLOB *********/
	RIS_write->opcode = RISCLI_FETCH_CODE;
	RIS_write->execute_mode = execute_mode;
	RIS_write->stmt_id = RIS_current_stmt_id;

	RIS_write->buf.fetch.row_count = row_count;

	RIS_write_len = RIS_APPCLI_HDR_SIZE + sizeof(RIS_write->buf.fetch);

	convert_stmt_id();
	FETCH_TO_NET(RIS_arc, &RIS_write->buf.fetch);
	APP_DBG(("RISapp_fetch_to_buf: complete\n"));
}

/******************************************************************************/


extern void RISapp_fetch_blob_to_buf()
{

	RIS_write->opcode = RISCLI_FETCH_BLOB_CODE;

	RIS_write->execute_mode = SYNC_MODE;

	RIS_write->stmt_id = RIS_current_stmt_id;

	RIS_write_len = RIS_APPCLI_HDR_SIZE+ sizeof(short) + sizeof(char);
	APP_DBG(("RISapp_fetch_blob_to_buf: complete\n"));
}

/******************************************************************************/

extern void RISapp_clear_to_buf(
	int				set_sqlcode,
	unsigned char				execute_mode)
{
	APP_DBG(("RISapp_clear_to_buf(set_sqlcode:%d execute_mode:%s)\n",
		set_sqlcode, RIScom_get_execute_mode_name(execute_mode)));

	RIS_write->opcode = RISCLI_CLEAR_CODE;
	RIS_write->execute_mode = execute_mode;
	RIS_write->stmt_id = RIS_current_stmt_id;

	RIS_write->buf.clear.set_sqlcode = set_sqlcode;

	RIS_write_len = RIS_APPCLI_HDR_SIZE + sizeof(RIS_write->buf.clear);

	convert_stmt_id();
	CLEAR_TO_NET(RIS_arc, &RIS_write->buf.clear);
	APP_DBG(("RISapp_clear_to_buf: complete\n"));
}

/******************************************************************************/

extern void RISapp_schema_mgr_to_buf(
	char mode,
	char *data,
	char * str)
{
	APP_DBG(("RISapp_schema_mgr_to_buf(mode:%d data:<%s> str:0x%x)\n",
		mode, data?data:"NULL", str));

	RIS_write->opcode = RISCLI_SCHEMA_MGR_CODE;
	RIS_write->execute_mode = SYNC_MODE;
	RIS_write->stmt_id = RIS_current_stmt_id;

	RIS_write->buf.schema_mgr.mode = mode;
	if (data)
	{
		strcpy(RIS_write->buf.schema_mgr.data, data);
	}
	else
	{
		*RIS_write->buf.schema_mgr.data = 0;
	}
	if (str)
	{
		strcpy(RIS_write->buf.schema_mgr.str, str);
	}
	else
	{
		*RIS_write->buf.schema_mgr.str = 0;
	}

	RIS_write_len = RIS_APPCLI_HDR_SIZE + sizeof(RIS_write->buf.schema_mgr);

	convert_stmt_id();
	APP_DBG(("RISapp_schema_mgr_to_buf:complete\n"));
}

/******************************************************************************/

extern void RISapp_grow_buf_to_buf(
	unsigned char	opcode)
{
	APP_DBG(("RISapp_grow_buf_to_buf(opcode:%d(%s))\n",
		opcode, RIS_cli_codes[opcode]));

	RIS_write->opcode = opcode;
	RIS_write->execute_mode = SYNC_MODE;
	RIS_write->stmt_id = RIS_current_stmt_id;

	switch(opcode)
	{
		case RISCLI_GROW_APP_TO_CLI_BUF_CODE:
			RIS_write->buf.grow_buf.new_size = RIS_write_size;
			break;

		case RISCLI_GROW_CLI_TO_APP_BUF_CODE:
			RIS_write->buf.grow_buf.new_size = RIS_read_size;
			break;
	}
	RIS_write_len = RIS_APPCLI_HDR_SIZE + sizeof(RIS_write->buf.grow_buf);

	convert_stmt_id();
	GROW_BUF_TO_NET(RIS_arc, &RIS_write->buf.grow_buf);
	APP_DBG(("RISapp_grow_buf_to_buf: complete\n"));
}

/******************************************************************************/
extern void RISapp_get_ss_def_to_buf(
	char *ss_name)
{
	APP_DBG(("RISapp_get_ss_def_to_buf(ss_name:<%s>)\n", STRING(ss_name)));

	RIS_write->opcode = RISCLI_GET_SS_DEF_CODE;
	RIS_write->execute_mode = SYNC_MODE;
	RIS_write->stmt_id = RIS_current_stmt_id;

	strcpy(RIS_write->buf.get_ss_def.ss_name, ss_name);

	RIS_write_len = RIS_APPCLI_HDR_SIZE + sizeof(RIS_write->buf.get_ss_def);

	convert_stmt_id();
	APP_DBG(("RISapp_get_ss_def_to_buf:complete\n"));
}

/******************************************************************************/

extern void RISapp_report_ss_error_to_buf(
	char *ss_name)
{
	APP_DBG(("RISapp_report_ss_error_to_buf(ss_name:<%s>)\n", STRING(ss_name)));

	RIS_write->opcode = RISCLI_REPORT_SS_ERROR_CODE;
	RIS_write->execute_mode = SYNC_MODE;
	RIS_write->stmt_id = RIS_current_stmt_id;

	if (ss_name)
	{
		strcpy(RIS_write->buf.report_ss_error.ss_name, ss_name);
	}
	else
	{
		RIS_write->buf.report_ss_error.ss_name[0] = '\0';
	}

	RIS_write_len = RIS_APPCLI_HDR_SIZE +
		sizeof(RIS_write->buf.report_ss_error);

	convert_stmt_id();
	APP_DBG(("RISapp_report_ss_error_to_buf:complete\n"));
}

/******************************************************************************/

static void convert_stmt_id()
{
	if(RIS_arc->remote_arch != LOCAL_ARCH)
	{
		ARC_CONVERT_SHORT(RIS_arc, TO_NET, &RIS_write->stmt_id);
	}
}

/******************************************************************************/
