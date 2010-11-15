/* Do not alter this SPC information: $Revision: 1.2.51.1 $ */
/*
**	NAME:							clifetch.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscom.h"
#include "client.h"
/**** BLOB *******/
#include "arch.h"
#include "errno.h"
#include <fcntl.h>

#if defined(WIN32) || defined(DOS)
#define close(a) _close(a)
#define open(a,b)  _open(a, b)
#define read(a,b,c)  _read(a,b,c)
#define write(a,b,c) _write(a,b,c)
#define lseek(a,b,c) _lseek(a,b,c)
#include <sys\stat.h>
#endif


/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clifetch_c
#include "clifetch.prt"
#include "comdebug.prt"
#include "comexmod.prt"
#include "comjmp.prt"
#include "usrsndrc.prt"
/**** BLOB *******/
#include "sys.prt"
#include "arcgnerc.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

extern void RIScli_fetch(
	short			id,
	unsigned int	row_count,
	int             fetch_V5,
	unsigned char	execute_mode)
{
	CLI_DBG(("RIScli_fetch(id:%d row_count:%d execute_mode:%s)\n",
		id, row_count, RIScom_get_execute_mode_name(execute_mode)));

	if (id < 0 || (unsigned int)id >= RIS_max_stmts || !RIS_stmts[id])
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	RIS_current_stmt_id = id;
	RIS_stmt = RIS_stmts[RIS_current_stmt_id];

	if (IN_START_OR_FINISH_MODE(execute_mode))
	{
		if (RIS_stmt->fetch_buf == (ris_srvcli_buf *)0)
		{
			LONGJMP(RIS_E_CURSOR_CLOSED);
		}
		RIS_stmt->sql->misc = (unsigned int *)row_count;

        if (fetch_V5)
            RISusr_send_rec(RIS_FETCH_BUF_CODE, RIS_stmt->sql, execute_mode);
        else
		RISusr_send_rec(RIS_FETCH_BUF_CODE_4, RIS_stmt->sql, execute_mode);
	}

	/* FIX TR# 249403625 */
    if (!fetch_V5)
	{
		int i;
		internal_sqlvar *sqlvar;

		for ( i=0, sqlvar=RIS_stmt->sql->output->sqlvar; i < RIS_stmt->sql->output->sqld; ++i)
		{
			if(sqlvar->sqltype == RIS_TEXT || sqlvar->sqltype == RIS_BLOB)
				LONGJMP(RIS_E_UNSUPPORTED_TYPE);

			++sqlvar;	
		}
	}
	CLI_DBG(("RIScli_fetch:complete\n"));
}

extern void RIScli_fetch_blob(
	ris_blob *blob_field)
{
	int  fd=0, read_length, ret_status, status;
    unsigned int total_output_length=0;
	arc_s *arc;
    struct stat stat_buf;

	CLI_DBG(("RIScli_fetch_blob\n"));

    arc = RIS_stmt->sql->schema->arc;

	/* open the file */
   	CLI_DBG(("blob_file_name : %s\n", blob_field->filename));

   	if ((ret_status=stat(blob_field->filename, &stat_buf)) <0)
	{
		/*
		** file does not exist! but file should have been
		** created by the application RISint_fetch()
		*/
        LONGJMP(RIS_E_OPEN_BLOB_FILE_ERROR);
	}
	else
	{
    	if (blob_field->file_offset <= 0)
		{
			/* No file offset, start from beginning of file */
			/* File should have been created in app.        */
#if defined(WIN32) || defined(DOS)
    		if ((fd=open(blob_field->filename,  O_TRUNC | O_RDWR |  O_BINARY))< 0)
#else
    		if ((fd=open(blob_field->filename,  O_TRUNC | O_RDWR ))< 0)
#endif
				LONGJMP(RIS_E_OPEN_BLOB_FILE_ERROR);
		}
		else
		{		
            struct stat file_st;
            long int seek_size=0;
			int st=0;

#if defined(WIN32) || defined(DOS)
    		if ((fd=open(blob_field->filename, O_RDWR | O_BINARY))< 0)
#else
    		if ((fd=open(blob_field->filename, O_RDWR))< 0)
#endif
				LONGJMP(RIS_E_OPEN_BLOB_FILE_ERROR);

            if ((st = stat(blob_field->filename, &file_st)) == -1)
				LONGJMP(RIS_E_ACCESS_BLOB_FILE_ERROR);

             /*
			 ** If offset spcified is biger than size of the file,
			 ** we will append the data to the end of file
			 */

             seek_size= ((unsigned int)file_st.st_size < blob_field->file_offset) ?
                                file_st.st_size:
                                blob_field->file_offset;

            if((st=lseek(fd, seek_size , 0))< 0)
			{
                CLI_DBG(("lseek returned errno <%d> for seek_size = <%d>\n",
						  errno, seek_size));
                LONGJMP(RIS_E_ACCESS_BLOB_FILE_ERROR);
			}
		}
	}
 
	do
	{
		/* use the full length of the buffer */

		status = SETJMP();
		if (!status)
		{
			RISusr_send_rec (RIS_FETCH_BLOB_CODE, RIS_stmt->sql, SYNC_MODE);
		}
		RESETJMP();

		if (status)
			/* RISusr_send_rec failed */
			LONGJMP(status);

		/*
		** architecture conversion stuff has been
		** taken care of in RISusr_send_rec()
		**
		** Surjit (Jan 9, 1995)
		*/

		read_length = RIS_srv_read->buf.fetch_blob.xfercount;

		if ((ret_status= write(fd,
			(char *) RIS_srv_read->buf.fetch_blob.data, read_length)) < 0)
			LONGJMP(RIS_E_WRITE_BLOB_FILE_ERROR);

		CLI_DBG(("RIScli_fetch_blob: read_length = <%d>, ret_status = <%d>\n",
				 read_length, ret_status));

		if (ret_status != read_length)
			LONGJMP(RIS_E_INTERNAL_ERROR);

		total_output_length += read_length;

	} while(RIS_srv_read->buf.fetch_blob.more_to_follow); 

    if ((ret_status = close(fd)) <0)
		LONGJMP(RIS_E_CLOSE_BLOB_FILE_ERROR);

	/* Raise a flag to tell app that dirty job has been done */ 
	(*(int * )&RIS_app_write->buf.fetch_blob.xfercount) = -1;

	/* Return the total output length to app */ 
	(*(int * )&RIS_app_write->buf.fetch_blob.data) = total_output_length;

	CLI_DBG(("RIScli_fetch_blob:complete\n"));
}
