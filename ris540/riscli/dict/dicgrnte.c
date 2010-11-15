/*
**	NAME:							dicgrnte.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					1/91
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscom.h"
#include "rismem.h"
#include "dict.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define dicgrnte_c
#include "comalloc.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "dicgrnte.prt"
#include "filsch.prt"
#include "usrsndrc.prt"
#include "sys.prt"

/* the following is a new wrapper to get around the problem of network
   messing around with schema file during a "grant all to public" when
   it doesn't need to, slowing things down and breaking other things 
   Dianne Ferrans 10/94 */

extern void RISdic_update_grantees(
	risschema *schema,
	int flag,
	int exec_mode)
{
	RISdic_update_grantees2(schema,flag,exec_mode,0); /*not a grant to public*/
}

/* the original RISdic_update_grantees - DD Ferrans 10/94 */

extern void RISdic_update_grantees2(
	risschema *schema,
	int flag,
	int exec_mode,
	int public_mode)
{
	int			more_to_follow=0;
	int			new_grantees_count=0;
	char		*new_grantees=0;
	risgrantee	*grantee;
	int		first_buffer;

	DIC_DBG(("RISdic_update_grantees(schema:0x%x)\n", schema));

	if (IN_START_MODE(exec_mode))
	{
		schema->grantee = 0;
		RIS_sdp->schema = schema;
	
		first_buffer = 1;
		do
		{
			/*
			** get a buffer full of grantees from the server
			**
			** Modified 3/11/92 - Sunil. Server will send the first buffer of
			** grantees information to client at the end of RIS_UPD_ACCESS_CODE,
			** RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE, and 
			** RIS_CRE_SCH_GET_GRANTEES_CODE.
			*/
			if (!first_buffer)
			{
				RISusr_send_rec(RIS_GET_SCHEMA_GRANTEES_CODE, RIS_sdp,
								(unsigned short)exec_mode);
				more_to_follow = RIS_srv_read->buf.get_grantees.more_to_follow;
				new_grantees_count = RIS_srv_read->buf.get_grantees.count;
				new_grantees = (char *)RIS_srv_read->buf.get_grantees.data;
				first_buffer = 0;
			}
			else
			{
				if (flag == GRANT_REVOKE)
				{
					more_to_follow = RIS_srv_read->buf.get_grantees.more_to_follow;
					new_grantees_count = RIS_srv_read->buf.get_grantees.count;
					new_grantees = (char *)RIS_srv_read->buf.get_grantees.data;
				}
				else if (flag == CREATE_SCHEMA)
				{
					more_to_follow = RIS_srv_read->buf.create_schema.more_to_follow;
					new_grantees_count = RIS_srv_read->buf.create_schema.count;
					new_grantees = (char *)RIS_srv_read->buf.create_schema.data;
					DIC_DBG(("RISdic_update_grantees(new_grantees:0x%x)\n", new_grantees));
				}
				else
				{
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}
			}
			DIC_DBG(("# of grantees returned:%d\n", new_grantees_count));
#ifdef OLD
			if (!new_grantees) break;
#else
			if (!new_grantees_count) break;
#endif
	
			/*
			** Add the grantees to the schema.
			** The structures no longer come in any specified order
			*/
	
			for (; new_grantees_count > 0; new_grantees_count--)
			{
				DIC_DBG(("got grantee <%s>\n", new_grantees));
	
				grantee = ALLOCT(risgrantee);
				strcpy(grantee->schname, new_grantees);
				grantee->next = schema->grantee;
				schema->grantee = grantee;
	
				new_grantees += RIS_MAX_ID_SIZE;
			}
		}
		while (more_to_follow);
		DIC_DBG(("out of the loop in dicgrantee \n"));
                if (!public_mode)	
		{
		RISfil_update_schema(schema, GRANTEE_FLAG); 
		}
	}
}
