/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clishmem.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "rismem.h"
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
#define clishmem_c
#include "clibuff.prt"
#include "clishmem.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comoutpt.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_show_memory(
	void)
{
	short			id;
	int				sts;
	ris_alloc_info	*stmt_mem;
	ris_block_info	*tempblock;
	static int		continue_flag = 0;

	CLI_DBG(("RIScli_show_memory()\n"));

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

	RIScli_string_to_buf("\nRISCLIENT MEMORY:\n");
	if (!RIS_mem)
	{
		RIScli_string_to_buf("NOT ALLOCATED\n");
		return;
	}

	RIScli_string_to_buf("RIS_mem:0x%x\n", RIS_mem);

	RIScli_string_to_buf("\nstatement memory:\n");
	for (id = 0; (unsigned int)id < RIS_max_stmts; id++)
	{
		if (RIS_mem->statement[id].blk)
		{
			stmt_mem = &RIS_mem->statement[id];

			RIScli_string_to_buf("\tstatement id:%d\n",id);
			RIScom_output_alloc_info(RIScli_string_to_buf, stmt_mem, 1);
			RIScli_string_to_buf("\tallocated block list:\n");
			for (tempblock=stmt_mem->blk;tempblock;tempblock=tempblock->next)
			{
				RIScli_string_to_buf("\t\tallocated_block:0x%x\n", tempblock);
				RIScom_output_block_info(RIScli_string_to_buf, tempblock, 3);
				RIScli_ckpt_string_to_buf((char *)tempblock);
			}
			RIScli_ckpt_string_to_buf((char *)&RIS_mem->statement[id]);
		}
	}

	RIScli_string_to_buf("\nasync statement memory:\n");
	/*
	**	Declare a global client variable RIS_max_transactions
	*/
	for (id = 0;id < (short)RIS_parms.max_transactions; id++)
	{
		if (RIS_mem->async[id].blk)
		{
			stmt_mem = &RIS_mem->async[id];

			RIScli_string_to_buf("\tasync statement id:%d\n",id);
			RIScom_output_alloc_info(RIScli_string_to_buf, stmt_mem, 1);
			RIScli_string_to_buf("\tallocated block list:\n");
			for (tempblock=stmt_mem->blk;tempblock;tempblock=tempblock->next)
			{
				RIScli_string_to_buf("\t\tallocated_block:0x%x\n", tempblock);
				RIScom_output_block_info(RIScli_string_to_buf, tempblock, 3);
				RIScli_ckpt_string_to_buf((char *)tempblock);
			}
			RIScli_ckpt_string_to_buf((char *)&RIS_mem->async[id]);
		}
	}

	RIScli_string_to_buf("\nschema memory:\n");
	for (id = 0;id < RIS_MAX_OPEN_SCHEMAS; id++)
	{
		if (RIS_mem->schema[id].blk)
		{
			stmt_mem = &RIS_mem->schema[id];

			RIScli_string_to_buf("\tschema id:%d\n",id);
			RIScom_output_alloc_info(RIScli_string_to_buf, stmt_mem, 2);
			RIScli_string_to_buf("\t\tallocated block list:\n");
			for (tempblock=stmt_mem->blk;tempblock;tempblock=tempblock->next)
			{
				RIScli_string_to_buf("\t\t\tallocated_block:0x%x\n", tempblock);
				RIScom_output_block_info(RIScli_string_to_buf, tempblock, 4);
				RIScli_ckpt_string_to_buf((char *)tempblock);
			}

			RIScli_ckpt_string_to_buf((char *)&RIS_mem->schema[id]);
		}
	}

	RIScli_string_to_buf("\nsuperschema memory:\n");
	for (id = 0;id < RIS_MAX_OPEN_SUPERSCHEMAS; id++)
	{
		if (RIS_mem->sschema[id].blk)
		{
			stmt_mem = &RIS_mem->sschema[id];

			RIScli_string_to_buf("\tsschema id:%d\n",id);
			RIScom_output_alloc_info(RIScli_string_to_buf, stmt_mem, 2);
			RIScli_string_to_buf("\t\tallocated block list:\n");
			for (tempblock=stmt_mem->blk;tempblock;tempblock=tempblock->next)
			{
				RIScli_string_to_buf("\t\t\tallocated_block:0x%x\n", tempblock);
				RIScom_output_block_info(RIScli_string_to_buf, tempblock, 4);
				RIScli_ckpt_string_to_buf((char *)tempblock);
			}

			RIScli_ckpt_string_to_buf((char *)&RIS_mem->sschema[id]);
		}
	}

	RIScli_string_to_buf("\npermanent memory:\n");
	if (RIS_mem->permanent.blk)
	{
		stmt_mem = &RIS_mem->permanent;

		RIScom_output_alloc_info(RIScli_string_to_buf, stmt_mem, 1);
		RIScli_string_to_buf("\tallocated block list:\n");
		for (tempblock=stmt_mem->blk;tempblock;tempblock=tempblock->next)
		{
			RIScli_string_to_buf("\t\tallocated_block:0x%x\n", tempblock);
			RIScom_output_block_info(RIScli_string_to_buf, tempblock, 3);
			RIScli_ckpt_string_to_buf((char *)tempblock);
		}
		RIScli_ckpt_string_to_buf((char *)&RIS_mem->permanent);
	}

	RIScli_string_to_buf("\nfree block list:\n");
	for (tempblock = RIS_mem->free; tempblock; tempblock = tempblock->next)
	{
		RIScli_string_to_buf("\tfree_block:0x%x\n", tempblock);
		RIScom_output_block_info(RIScli_string_to_buf, tempblock, 2);
		RIScli_ckpt_string_to_buf((char *)tempblock);
	}

	RESETJMP();

	continue_flag = 0;

	CLI_DBG(("RIScli_show_memory: complete\n"));
}

/******************************************************************************/
