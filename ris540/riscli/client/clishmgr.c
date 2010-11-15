/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clishmgr.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "rismem.h"
#include "rishshtb.h"
#include "client.h"
#include "net.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clishmgr_c
#include "clibuff.prt"
#include "clishmgr.prt"
#include "ccostmgr.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_show_struct_mgrs(
	void)
{
	int			sts;
	int			tab_count;
	int			acc_count;
	int			attr_count;
	int			db_count;
	int			schema_count;
	int			tablist_count;
	int			hash_count;
	int			net_count;
	short		id;
	ristab		*tab;
	risattr		*attr;
	risaccess	*acc;
	risdb		*db;
	risschema	*schema;
	ristablist	*tablist;
	hashnode	*hash;
	net_s		*net;
	static int	continue_flag = 0;

	CLI_DBG(("RIScli_show_struct_mgrs()\n"));

	sts = SETJMP();
	if (sts)
	{
		RESETJMP();
		if (sts == RIS_E_BUFFER_FULL)
		{
			continue_flag = 1;
			return;
		}

		continue_flag = 0;
		LONGJMP(sts);
	}

	RIScli_init_string_to_buf(continue_flag);

	RIScli_string_to_buf("RISCLIENT STRUCTURE MANAGERS:\n");

	RIScli_string_to_buf("\nschema:\n");
	for (id = 0;id < RIS_MAX_OPEN_SCHEMAS; id++)
	{
		if (RIS_schmem[id].schname[0])
		{
			RIScli_string_to_buf("\tschema id:%d\n",id);
			RIScli_string_to_buf("\t\tschema name:%s\n",
				RIS_schmem[id].schname);

			RIScli_string_to_buf("\t\tfree risaccess struct list:");
			for(acc = RIS_schmem[id].free_risaccess, acc_count = 0;
				acc;
				acc = acc->next, acc_count++)
			{
				if ((acc_count % 3) == 0)
				{
					RIScli_string_to_buf("\n\t\t\t");
				}
				RIScli_string_to_buf("%3d:0x%08x", acc_count+1, acc);
				if (!RIScco_in_memory(&RIS_mem->schema[id], acc))
				{
					RIScli_string_to_buf("\nWARNING: risaccess 0x%x not in "
						"schema memory\n", acc);
				}
				if ((acc_count % 3) != 2)
				{
					RIScli_string_to_buf("    ");
				}
				RIScli_ckpt_string_to_buf((char *)acc);
			}
			RIScli_string_to_buf("\n\t\tfree risaccess struct count:%d\n",
				acc_count);
			RIScli_string_to_buf("\t\ttotal risaccess struct count:%d\n\n",
				RIS_schmem[id].risaccess_cnt);

			RIScli_string_to_buf("\t\tfree risattr struct list:");
			for(attr = RIS_schmem[id].free_risattr, attr_count = 0;
				attr;
				attr = attr->next, attr_count++)
			{
				if ((attr_count % 3) == 0)
				{
					RIScli_string_to_buf("\n\t\t\t");
				}
				RIScli_string_to_buf("%3d:0x%08x", attr_count+1, attr);
				if (!RIScco_in_memory(&RIS_mem->schema[id], attr))
				{
					RIScli_string_to_buf("\nWARNING: risattr 0x%x not "
						"in schema memory\n", attr);
				}
				if ((attr_count % 3) != 2)
				{
					RIScli_string_to_buf("    ");
				}
				RIScli_ckpt_string_to_buf((char *)attr);
			}
			RIScli_string_to_buf("\n\t\tfree risattr struct count:%d\n",
				attr_count);
			RIScli_string_to_buf("\t\ttotal risattr struct count:%d\n\n",
				RIS_schmem[id].risattr_cnt);

			RIScli_string_to_buf("\t\tfree ristab struct list:");
			for(tab = RIS_schmem[id].free_ristab, tab_count = 0;
				tab;
				tab = tab->next, tab_count++)
			{
				if ((tab_count % 3) == 0)
				{
					RIScli_string_to_buf("\n\t\t\t");
				}
				RIScli_string_to_buf("%3d:0x%08x", tab_count+1, tab);
				if (!RIScco_in_memory(&RIS_mem->schema[id], tab))
				{
					RIScli_string_to_buf("\nWARNING: ristab struct 0x%x not "
						"in schema memory\n", tab);
				}
				if ((tab_count % 3) != 2)
				{
					RIScli_string_to_buf("    ");
				}
				RIScli_ckpt_string_to_buf((char *)tab);
			}
			RIScli_string_to_buf("\n\t\tfree ristab struct count:%d\n",
				tab_count);
			RIScli_string_to_buf("\t\ttotal ristab struct count:%d\n\n",
				RIS_schmem[id].ristab_cnt);

			RIScli_ckpt_string_to_buf((char *)&RIS_schmem[id]);
		}
	}

	RIScli_string_to_buf("\npermanent:\n");

	RIScli_string_to_buf("\tfree risdb struct list:");
	for(db = RIS_permmem.free_risdb, db_count = 0;
		db;
		db = db->next, db_count++)
	{
		if ((db_count % 3) == 0)
		{
			RIScli_string_to_buf("\n\t\t");
		}
		RIScli_string_to_buf("%3d:0x%08x", db_count+1, db);
		if (!RIScco_in_memory(&RIS_mem->permanent, db))
		{
			RIScli_string_to_buf("\nWARNING: risdb 0x%x not "
				"in permanent memory\n", db);
		}
		if ((db_count % 3) != 2)
		{
			RIScli_string_to_buf("    ");
		}
		RIScli_ckpt_string_to_buf((char *)db);
	}
	RIScli_string_to_buf("\n\tfree risdb struct count:%d\n",
		db_count);
	RIScli_string_to_buf("\ttotal risdb struct count:%d\n\n",
		RIS_permmem.risdb_cnt);

	RIScli_string_to_buf("\tfree risschema struct list:");
	for(schema = RIS_permmem.free_risschema, schema_count = 0;
		schema;
		schema = schema->next, schema_count++)
	{
		if ((schema_count % 3) == 0)
		{
			RIScli_string_to_buf("\n\t\t");
		}
		RIScli_string_to_buf("%3d:0x%08x", schema_count+1, schema);
		if (!RIScco_in_memory(&RIS_mem->permanent, schema))
		{
			RIScli_string_to_buf("\nWARNING: risschema 0x%x not "
				"in permanent memory\n", schema);
		}
		if ((schema_count % 3) != 2)
		{
			RIScli_string_to_buf("    ");
		}
		RIScli_ckpt_string_to_buf((char *)schema);
	}
	RIScli_string_to_buf("\n\tfree risschema struct count:%d\n",
		schema_count);
	RIScli_string_to_buf("\ttotal risschema struct count:%d\n\n",
		RIS_permmem.risschema_cnt);

	RIScli_string_to_buf("\tfree ristablist struct list:");
	for(tablist = RIS_permmem.free_ristablist, tablist_count = 0;
		tablist;
		tablist = tablist->next, tablist_count++)
	{
		if ((tablist_count % 3) == 0)
		{
			RIScli_string_to_buf("\n\t\t");
		}
		RIScli_string_to_buf("%3d:0x%08x", tablist_count+1, tablist);
		if (!RIScco_in_memory(&RIS_mem->permanent, tablist))
		{
			RIScli_string_to_buf("\nWARNING: ristablist 0x%x not "
				"in permanent memory\n", tablist);
		}
		if ((tablist_count % 3) != 2)
		{
			RIScli_string_to_buf("    ");
		}
		RIScli_ckpt_string_to_buf((char *)tablist);
	}
	RIScli_string_to_buf("\n\tfree ristablist struct count:%d\n",
		tablist_count);
	RIScli_string_to_buf("\ttotal ristablist struct count:%d\n\n",
		RIS_permmem.ristablist_cnt);

	RIScli_string_to_buf("\tfree hashnode struct list:");
	for(hash = RIS_permmem.free_hashnode, hash_count = 0;
		hash;
		hash = hash->next, hash_count++)
	{
		if ((hash_count % 3) == 0)
		{
			RIScli_string_to_buf("\n\t\t");
		}
		RIScli_string_to_buf("%3d:0x%08x", hash_count+1, hash);
		if (!RIScco_in_memory(&RIS_mem->permanent, hash))
		{
			RIScli_string_to_buf("\nWARNING: hashnode 0x%x not "
				"in permanent memory\n", hash);
		}
		if ((hash_count % 3) != 2)
		{
			RIScli_string_to_buf("    ");
		}
		RIScli_ckpt_string_to_buf((char *)hash);
	}
	RIScli_string_to_buf("\n\tfree hashnode struct count:%d\n",
		hash_count);
	RIScli_string_to_buf("\ttotal hashnode struct count:%d\n\n",
		RIS_permmem.hashnode_cnt);

	RIScli_string_to_buf("\tfree net_s struct list:");
	for(net = RIS_permmem.free_net_s, net_count = 0;
		net;
		net = net->next, net_count++)
	{
		if ((net_count % 3) == 0)
		{
			RIScli_string_to_buf("\n\t\t");
		}
		RIScli_string_to_buf("%3d:0x%08x", net_count+1, net);
		if (!RIScco_in_memory(&RIS_mem->permanent, net))
		{
			RIScli_string_to_buf("\nWARNING: net_s 0x%x not "
				"in permanent memory\n", net);
		}
		if ((net_count % 3) != 2)
		{
			RIScli_string_to_buf("    ");
		}
		RIScli_ckpt_string_to_buf((char *)net);
	}
	RIScli_string_to_buf("\n\tfree net_s struct count:%d\n",
		net_count);
	RIScli_string_to_buf("\ttotal net_s struct count:%d\n\n",
		RIS_permmem.net_s_cnt);

	RIScli_ckpt_string_to_buf((char *)&RIS_permmem);

	RESETJMP();

	continue_flag = 0;

	CLI_DBG(("RIScli_show_struct_mgrs: complete\n"));
}

/******************************************************************************/
