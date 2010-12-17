/*
**	NAME:							usracc.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscl_sr.h"
#include "riscli.h"
#include "riscom.h"
#include "user.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define usracc_c
#include "comexmod.prt"
#include "comdebug.prt"
#include "usracc.prt"
#include "usrmisc.prt"
#include "usrsndrc.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISusr_update_access(
	ris_acc_link_list_node	*access,
	risschema				*schema,
	int 					exec_mode)
{
	int max;
	int count;
	int offset;
	int first_buffer;

	USR_DBG(("RISusr_update_access(access:0x%x schema:0x%x exec_mode:%s)\n",
		access, schema,
		RIScom_get_execute_mode_name((unsigned char)exec_mode)));

	if ((IN_FINISH_MODE_ONLY(exec_mode)) && (schema->srv_busy))
	{
		RIS_sdp->schema = schema;
		RISusr_send_rec(RIS_UPD_ACCESS_CODE, RIS_sdp, (unsigned short)exec_mode);
	}

	if (exec_mode & START_MODE)
	{
		struct ris_clisrv_buf_upd_access *upd_access =
			&RIS_srv_write->buf.upd_access;

		max = (RIS_srv_write_size -
			(int)&(((ris_clisrv_buf*)0)->buf.upd_access.data))/
			sizeof(ris_access_info);

		USR_DBG(("RISusr_update_access: RIS_srv_write_size:%d max:%d\n",
			RIS_srv_write_size, max));

		offset = 0;
		count = 0;
		first_buffer = 1;

		/*
		** For Rdb, if there's no access to update, send a commit code
		*/
		if (!access)
		{
			RIS_sdp->schema = schema;
			RISusr_send_rec(RIS_COMMIT_WORK_CODE, RIS_sdp, SYNC_MODE);
		}
		else
		{
			while(access)
			{
				USR_DBG(("RISusr_update_access: access:0x%x\n\tschname:<%s>\n"
					"\trelowner:<%s>\n\trelname:<%s>\n\trelid:<%d>\n"
					"\tcolname:<%s>\n", 
					access->racc,
					access->racc->schname, access->racc->relowner,
					access->racc->relname, access->racc->relid,
					access->racc->colname));

				RISusr_access_to_access_info(access->racc,
					(ris_access_info *)(upd_access->data + offset));

				count++;
				offset += sizeof(ris_access_info);
				access = access->next;

				if (count == max || !access)
				{
					upd_access->acc = 0;
					upd_access->count = count;

					if (first_buffer)
					{
						first_buffer = 0;
						upd_access->delete_flag = 1;
					}
					else
					{
						upd_access->delete_flag = 0;
					}

					if (access)
					{
						upd_access->more_to_follow = 1;
					}
					else
					{
						upd_access->more_to_follow = 0;
					}

					RIS_srv_write_len =
						(int)&(((ris_clisrv_buf *)0)->buf.upd_access.data) + offset;

					RIS_sdp->schema = schema;

					if (upd_access->more_to_follow)
					{
						USR_DBG(("upd_access->more_to_follow = 1\n"));
						RISusr_send_rec(RIS_UPD_ACCESS_CODE, RIS_sdp, SYNC_MODE);
					}
					else if (!upd_access->more_to_follow)
					{
						USR_DBG(("upd_access->more_to_follow = 0\n"));
						RISusr_send_rec(RIS_UPD_ACCESS_CODE, RIS_sdp,
							(unsigned short)exec_mode);
					}

					offset = 0;
					count = 0;
				}
			}
		}
	}
	USR_DBG(("RISusr_update_access: complete\n"));
}
/******************************************************************************/
