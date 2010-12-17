/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clishhsh.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscl_pa.h"
#include "rishshtb.h"
#include "rismem.h"
#include "ristoken.h"
#include "client.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clishhsh_c
#include "clishhsh.prt"
#include "clibuff.prt"
#include "ccostmgr.prt"
#include "comdebug.prt"
#include "comoutpt.prt"
#include "comgtnme.prt"
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RIScli_show_hash(
	void)
{
	int				i;
	int				sts;
	risaccess		*acc;
	risattr			*attr;
	ristab			*tab;
	risschema		*schema;
	risdb			*db;
	hashnode		*hashp;
	static int		continue_flag = 0;

	CLI_DBG(("RIScli_show_hash()\n"));

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

	RIScli_string_to_buf("\nRISCLIENT HASH TABLE:\n");

	for (i=0; i<HASH_TAB_SIZE; ++i)
	{
		if (RIS_hashtab[i])
		{
			for (hashp = RIS_hashtab[i]; hashp; hashp = hashp->next)
			{
				RIScli_string_to_buf("hashtab[%d]:0x%x bucket:0x%x\n",
					i, &RIS_hashtab[i], hashp);
				check_hashnode(hashp);
				switch (hashp->tok)
				{
					case RIS_TOK_TABLE:
						tab = (ristab *)hashp->ptr;
						RIScli_string_to_buf("\ttable: 0x%x\n", tab);
						RIScom_output_table(RIScli_string_to_buf, tab, 2);
						check_ristab(tab->schema->schid, tab);
						for (acc = tab->acc; acc; acc = acc->next)
						{
							RIScli_string_to_buf("\t\taccess:0x%x\n",acc);
							RIScom_output_acc(RIScli_string_to_buf,acc,3);
							check_risaccess(tab->schema->schid, acc);
						}
						for (attr = tab->attr; attr; attr = attr->next)
						{
							RIScli_string_to_buf("\t\tattribute:0x%x\n", attr);
							RIScom_output_attr(RIScli_string_to_buf, attr, 3);
							check_risattr(tab->schema->schid, attr);
							for (acc = attr->acc; acc; acc = acc->next)
							{
								RIScli_string_to_buf("\t\t\taccess:0x%x\n",acc);
								RIScom_output_acc(RIScli_string_to_buf,acc,4);
								check_risaccess(tab->schema->schid, acc);
							}
						}
						break;

					case RIS_TOK_DATABASE:
						db = (risdb *)hashp->ptr;
						RIScli_string_to_buf("\tdatabase: 0x%x\n", db);
						RIScom_output_db(RIScli_string_to_buf, db, 2);
						check_risdb(db);
						break;

					case RIS_TOK_SCHEMA:
						schema = (risschema *)hashp->ptr;
						RIScli_string_to_buf("\tschema: 0x%x\n", schema);
						RIScom_output_schema(RIScli_string_to_buf, schema, 2);
						check_risschema(schema);
						break;

					default:
						CLI_DBG(("RIScli_print_hash: got bad tok:<%s>\n",
							RIScom_get_token_name(hashp->tok)));
						LONGJMP(RIS_E_INTERNAL_ERROR);
				}
				RIScli_ckpt_string_to_buf((char *)hashp);
			}
		}
	}
	RIScli_ckpt_string_to_buf((char *)RIS_hashtab);

	RESETJMP();

	continue_flag = 0;

	CLI_DBG(("RIScli_show_hash: complete\n"));
}

/******************************************************************************/

static void check_risaccess(
	short		schid,
	risaccess	*ptr)
{
	risaccess	*temp;

	CLI_DBG(("check_risaccess(schid:%d ptr:0x%x)\n", schid, ptr));

	if (!ptr)
	{
		return;
	}

	if (schid < 0 || schid >= RIS_MAX_OPEN_SCHEMAS ||
		!RIS_schmem[schid].schname[0])
	{
		LONGJMP(RIS_E_INVALID_SCHEMA_ID);
	}

	if (!RIScco_in_memory(&RIS_mem->schema[schid], ptr))
	{
		RIScli_string_to_buf("WARNING risaccess 0x%x is not in schema memory\n",
			ptr);
	}

	for(temp = RIS_schmem[schid].free_risaccess; temp; temp = temp->next)
	{
		if (ptr == temp)
		{
			RIScli_string_to_buf("WARNING 0x%x is in the struct_mgr "
				"free risaccess list.\n", ptr);
			break;
		}
	}
}

/******************************************************************************/

static void check_risattr(
	short	schid,
	risattr	*ptr)
{
	risattr	*temp;

	CLI_DBG(("check_risattr(schid:%d ptr:0x%x)\n", schid, ptr));

	if (!ptr)
	{
		return;
	}

	if (schid < 0 || schid >= RIS_MAX_OPEN_SCHEMAS ||
		!RIS_schmem[schid].schname[0])
	{
		LONGJMP(RIS_E_INVALID_SCHEMA_ID);
	}

	if (!RIScco_in_memory(&RIS_mem->schema[schid], ptr))
	{
		RIScli_string_to_buf("WARNING risattr 0x%x is not in schema memory\n",
			ptr);
	}

	for(temp = RIS_schmem[schid].free_risattr; temp; temp = temp->next)
	{
		if (ptr == temp)
		{
			RIScli_string_to_buf("WARNING! 0x%x is in the struct_mgr "
				"free risattr list.\n", ptr);
			break;
		}
	}
}

/******************************************************************************/

static void check_ristab(
	short		schid,
	ristab	*ptr)
{
	ristab	*temp;

	CLI_DBG(("check_ristab(schid:%d ptr:0x%x)\n", schid, ptr));

	if (!ptr)
	{
		return;
	}

	if (schid < 0 || schid >= RIS_MAX_OPEN_SCHEMAS ||
		!RIS_schmem[schid].schname[0])
	{
		LONGJMP(RIS_E_INVALID_SCHEMA_ID);
	}

	if (!RIScco_in_memory(&RIS_mem->schema[schid], ptr))
	{
		RIScli_string_to_buf("WARNING ristab 0x%x is not in schema memory\n",
			ptr);
	}

	for(temp = RIS_schmem[schid].free_ristab; temp; temp = temp->next)
	{
		if (ptr == temp)
		{
			RIScli_string_to_buf("WARNING! 0x%x is in the struct_mgr "
				"free ristab list.\n", ptr);
			break;
		}
	}
}

/******************************************************************************/

static void check_risdb(
	risdb	*ptr)
{
	risdb	*temp;

	CLI_DBG(("check_risdb(ptr:0x%x)\n", ptr));

	if (!ptr)
	{
		return;
	}

	if (!RIScco_in_memory(&RIS_mem->permanent, ptr))
	{
		RIScli_string_to_buf("WARNING risdb 0x%x is not in permanent memory\n",
			ptr);
	}

	for(temp = RIS_permmem.free_risdb; temp; temp = temp->next)
	{
		if (ptr == temp)
		{
			RIScli_string_to_buf("WARNING! 0x%x is in the struct_mgr "
				"free risdb list.\n", ptr);
			break;
		}
	}
}

/******************************************************************************/

static void check_risschema(
	risschema	*ptr)
{
	risschema	*temp;

	CLI_DBG(("check_risschema(ptr:0x%x)\n", ptr));

	if (!ptr)
	{
		return;
	}

	if (!RIScco_in_memory(&RIS_mem->permanent, ptr))
	{
		RIScli_string_to_buf("WARNING risschema 0x%x is not in permanent "
			"memory\n", ptr);
	}

	for(temp = RIS_permmem.free_risschema; temp; temp = temp->next)
	{
		if (ptr == temp)
		{
			RIScli_string_to_buf("WARNING! 0x%x is in the struct_mgr "
				"free risschema list.\n", ptr);
			break;
		}
	}
}

/******************************************************************************/

#ifdef FUTURE_USE
static void check_ristablist(
	ristablist	*ptr)
{
	ristablist	*temp;

	CLI_DBG(("check_ristablist(ptr:0x%x)\n", ptr));

	if (!ptr)
	{
		return;
	}

	if (!RIScco_in_memory(&RIS_mem->permanent, ptr))
	{
		RIScli_string_to_buf("WARNING ristablist 0x%x is not in permanent "
			"memory\n", ptr);
	}

	for(temp = RIS_permmem.free_ristablist; temp; temp = temp->next)
	{
		if (ptr == temp)
		{
			RIScli_string_to_buf("WARNING! 0x%x is in the struct_mgr "
				"free ristablist list.\n", ptr);
			break;
		}
	}
}
#endif
/******************************************************************************/

static void check_hashnode(
	hashnode	*ptr)
{
	hashnode	*temp;

	CLI_DBG(("check_hashnode(ptr:0x%x)\n", ptr));

	if (!ptr)
	{
		return;
	}

	if (!RIScco_in_memory(&RIS_mem->permanent, ptr))
	{
		RIScli_string_to_buf("WARNING hashnode 0x%x is not in permanent "
			"memory\n", ptr);
	}

	for(temp = RIS_permmem.free_hashnode; temp; temp = temp->next)
	{
		if (ptr == temp)
		{
			RIScli_string_to_buf("WARNING! 0x%x is in the struct_mgr "
				"free hashnode list.\n", ptr);
			break;
		}
	}
}

/******************************************************************************/
