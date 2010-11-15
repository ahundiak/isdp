/*
**	NAME:							USRexec_blob.c
**	AUTHORS:						James Chang	
**	CREATION DATE:					12/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

/*
**	INCLUDES
*/
#include "risasync.h"
#include "client.h"
#include "user.h"
#include "riscom.h"
#include "rismem.h"
#include "arch.h"
#include <fcntl.h>		 

/*
**	DEFINES
*/

/*  The blobinfo:
**
**  7 6  5 4  3 2  1 0
**  | |  | |  | |  | |
**  | |  | |  | |  | |
**  | |  | |  | |  | |_more_blob_data_to_follow
**  | |  | |  | |  |_more_blob_col_to_follow
**  | |  | |  | |_unused bit
**  | |  | |  |_unused bit
**  | |  | |_local_file
**  | |  |_remote_file
**  | |_deffered_code
**  |_execblob_code
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#include "comexmod.prt"
#include "comjmp.prt"
#include "usrsndrc.prt"
#include "sys.prt"
#include "comdebug.prt"
#include "arcgnerc.prt"
#include "comwrap.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
** This routine handles the blob data sent by app.
*/
extern void RISusr_exec_blob(
    risstmt			*blob_stmt,	
	unsigned char	execute_mode,
	unsigned int    blobinfo) 
{
	int status = 0;
	arc_s *arc = blob_stmt->sql->schema->arc;
	net_s *net = blob_stmt->sql->schema->net;

	USR_DBG(("RISusr_exec_blob (execute_mode):%s \n",
		RIScom_get_execute_mode_name(execute_mode)));

	if ((net->protocol != SHMEM) && /* server is remote */
		(RIS_app_net->protocol == SHMEM) && /* app is local */
		(blobinfo & 0x10)) /* local file is used */
	{
		internal_sqlda *da = blob_stmt->sql->input;
		internal_sqlvar *var = da->sqlvar;
		int i = 0;
#if defined (WIN32) || defined(DOS) || defined(WIN32S) 
		FILE *fd = 0;
#else
		int	fd = 0;
#endif
		int ret_status = 0;
		unsigned char blob_execute_mode = 0; 
		unsigned int read_length = RIS_srv_write_size -
				(int)&(((ris_clisrv_buf *)0)->buf.exec_blob.data); 
		char *filename = RIS_app_read->buf.exec_blob.data;

		for (i = 0; i < da->sqld; ++i)
		{
			/*
			** look for RIS_BLOB/RIS_TEXT column in the internal_sqlvar
			** To fix TR# 439601350. See fopen() below.  -surjit (07/96)
			*/
			if (((ATTR_TYPE(var[i].sqltype) == RIS_BLOB) ||
				 (ATTR_TYPE(var[i].sqltype) == RIS_TEXT)) &&
				RIS_app_read->buf.exec_blob.blob_col_pos == i)
				break;	
		}

		if (i == da->sqld)
			LONGJMP(RIS_E_INTERNAL_ERROR); /* no blob column in sqlvar */

#if defined (WIN32) || defined(DOS) || defined(WIN32S) 
		/* open in TEXT mode for RIS_TEXT. TR# 439601350 - surjit */
		if (ATTR_TYPE(var[i].sqltype) == RIS_TEXT)
			fd = fopen(filename, "rt");
		else
			fd = fopen(filename, "rb");
		if (fd == 0)
#else  
		fd = open(filename, O_RDONLY);
		if (fd <= 0)
#endif 
			LONGJMP(RIS_E_OPEN_BLOB_FILE_ERROR);

		/* use the full length of the buffer */
		USR_DBG(("Full length of buffer=%u\n", read_length));

		RIS_app_write->buf.exec_blob.x_fercount = 0;
		do	/* loop untill entire blob data is sent */
		{
#if defined (WIN32) || defined(DOS) || defined(WIN32S) 
			if ((ret_status =
				 RIScom_fread((char *)RIS_srv_write->buf.exec_blob.data,
					 sizeof(char), read_length, fd)) < 0)
#else
			if ((ret_status =
				 RIScom_read(fd, (char *)RIS_srv_write->buf.exec_blob.data,
					read_length)) < 0)
#endif
				LONGJMP(RIS_E_READ_BLOB_FILE_ERROR);

			USR_DBG(("ret_status=%d\n", ret_status));

			/* put the length of this read in the xfcount */
			RIS_srv_write->buf.exec_blob.xfcount = ret_status;

			if ((unsigned int)ret_status < read_length)
			{
				USR_DBG(("NO more_to_follow\n"));
				RIS_srv_write->buf.exec_blob.more_to_follow = 0;
				blob_execute_mode = execute_mode;
			}
			else
			{
				USR_DBG(("BLOB more_to_follow\n"));
				RIS_srv_write->buf.exec_blob.more_to_follow = 1;
				blob_execute_mode = SYNC_MODE;
			}

			if (blobinfo & 0x02) /* MORE_BLOB_COL_TO_FOLLOW */
				RIS_srv_write->buf.exec_blob.more_to_follow |= 0x02;

			/* Telling the server the file is a remote one */
			RIS_srv_write->buf.exec_blob.file_used = 0x02;

			RIS_srv_write_len = ret_status +
				(int)&(((ris_clisrv_buf *)0)->buf.exec_blob.data);

			status = SETJMP();
			if (!status)
			{
				RISusr_send_rec(RIS_EXEC_BLOB_CODE,
					blob_stmt->sql, blob_execute_mode); 	
			}
			RESETJMP();

			/* Return the input len */
			ARC_NET_TO_INTEGER(arc, &RIS_srv_read->buf.exec_blob.x_fercount);

			RIS_app_write->buf.exec_blob.x_fercount +=
				RIS_srv_read->buf.exec_blob.x_fercount;

			if (status)
				LONGJMP(status); /* RISusr_send_rec failed */
		}
		while (RIS_srv_write->buf.exec_blob.more_to_follow & 0x01);
	}
	else
	{
		RIS_srv_write_size = RIS_app_read_size;
		RIS_srv_write = (ris_clisrv_buf *)RIS_app_read;

		USR_DBG(("RISusr_exec_blob()\n"
				 "Server is local. So app. dictates operation\n"
				 "Sending application buffer to server ...\n"));

		RISusr_send_rec(RIS_EXEC_BLOB_CODE, blob_stmt->sql, execute_mode);

		/* Return the input len */
		ARC_NET_TO_INTEGER(arc, &RIS_srv_read->buf.exec_blob.x_fercount);

		RIS_app_write->buf.exec_blob.x_fercount =
			RIS_srv_read->buf.exec_blob.x_fercount;

		if (status)
			LONGJMP(status); /* RISusr_send_rec() failed */
	}

	USR_DBG(("RISusr_exec_blob: complete\n"));
}
