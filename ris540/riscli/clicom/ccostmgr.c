/*
**	NAME:							ccostmgr.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/90
**	ABSTRACT:
**	contains the functions that do the memory management of risaccess
**	structures in permanent memory.
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "rishshtb.h"
#include "rismem.h"
#include "clicom.h"

/*
**      FUNCTION PROTOTYPES
*/
#define ccostmgr_c
#include "comalloc.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "ccostmgr.prt"
#include "sys.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RIScco_in_memory(
	ris_alloc_info	*alloc,
	void			*ptr)
{
	int				size;
	int				ret = 0;
	ris_block_info	*block;

	CCO_DBG(("RIScco_in_memory(alloc:0x%x ptr:0x%x)\n", alloc, ptr));

	for (block = alloc->blk; block; block = block->next)
	{
		size = (block->count+1) * (RIS_BLOCK_SIZE + sizeof(ris_block_info));
		if ((int)ptr >= (int)block && (int)ptr < ((int)block) + size)
		{
			
			ret = 1;
			break;
		}
	}
	CCO_DBG(("RIScco_in_memory: returning %d\n", ret));
	return ret;
}

/*******************************************************************************
********** SCHEMA STRUCTS ******************************************************
*******************************************************************************/

/********* RISACCESS **********************************************************/

extern risaccess *RIScco_alloc_risaccess(
	short	schid)
{
	risaccess *return_ptr;

	CCO_DBG(("RIScco_alloc_risaccess(schid:%d)\n", schid));

	if (schid < 0 || schid >= RIS_MAX_OPEN_SCHEMAS ||
		!RIS_schmem[schid].schname[0])
	{
		LONGJMP(RIS_E_INVALID_SCHEMA_ID);
	}

	if (RIS_schmem[schid].free_risaccess)
	{
		return_ptr = RIS_schmem[schid].free_risaccess;
		RIS_schmem[schid].free_risaccess =
			RIS_schmem[schid].free_risaccess->next;
		memset(return_ptr, 0, sizeof(risaccess));
	}
	else
	{
		/*
		**	Alloc the needed structs and add them to the front
		**	of the return list.
		*/
		return_ptr = ALLOCTS(schid, risaccess);
		RIS_schmem[schid].risaccess_cnt++;
	}
	return return_ptr;
}

/******************************************************************************/

extern void RIScco_free_risaccess(
	short		schid,
	risaccess	*ptr)
{
	risaccess	**tempp;

	CCO_DBG(("RIScco_free_risaccess(schid:%d ptr:0x%x)\n", schid, ptr));

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
		CCO_DBG(("RIScco_free_risaccess: 0x%x is not in schema memory\n", ptr));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	for(tempp = &RIS_schmem[schid].free_risaccess;
		*tempp;
		tempp = &((*tempp)->next))
	{
		if (ptr < *tempp)
		{
			ptr->next = *tempp;
			*tempp = ptr;
			break;
		}
		else if (ptr == *tempp)
		{
			CCO_DBG(("FREE_STRUCT: tried to free a free risaccess "
				"struct.\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}
	if (*tempp == NULL)
	{
		ptr->next = NULL;
		*tempp = ptr;
	}
}

/******************************************************************************/

extern void RIScco_free_risaccess_list(
	short		schid,
	risaccess	*ptr)
{
	risaccess	*temp;

	CCO_DBG(("RIScco_free_risaccess_list(schid:%d ptr:0x%x)\n", schid, ptr));

	while(ptr)
	{
		temp = ptr;
		ptr = ptr->next;
		RIScco_free_risaccess(schid, temp);
	}
}

/********* RISATTR ************************************************************/

extern risattr *RIScco_alloc_risattr(
	short	schid)
{
	risattr *return_ptr;

	CCO_DBG(("RIScco_alloc_risattr(schid:%d)\n", schid));

	if (schid < 0 || schid >= RIS_MAX_OPEN_SCHEMAS ||
		!RIS_schmem[schid].schname[0])
	{
		LONGJMP(RIS_E_INVALID_SCHEMA_ID);
	}

	if (RIS_schmem[schid].free_risattr)
	{
		return_ptr = RIS_schmem[schid].free_risattr;
		RIS_schmem[schid].free_risattr =
			RIS_schmem[schid].free_risattr->next;
		memset(return_ptr, 0, sizeof(risattr));
	}
	else
	{
		/*
		**	Alloc the needed structs and add them to the front
		**	of the return list.
		*/
		return_ptr = ALLOCTS(schid, risattr);
		RIS_schmem[schid].risattr_cnt++;
	}
	return return_ptr;
}

/******************************************************************************/

extern void RIScco_free_risattr(
	short		schid,
	risattr	*ptr)
{
	risattr	**tempp;

	CCO_DBG(("RIScco_free_risattr(schid:%d ptr:0x%x)\n", schid, ptr));

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
		CCO_DBG(("RIScco_free_risattr: 0x%x is not in schema memory\n", ptr));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	for(tempp = &RIS_schmem[schid].free_risattr;
		*tempp;
		tempp = &((*tempp)->next))
	{
		if (ptr < *tempp)
		{
			ptr->next = *tempp;
			*tempp = ptr;
			break;
		}
		else if (ptr == *tempp)
		{
			CCO_DBG(("FREE_STRUCT: tried to free a free risattr "
				"struct.\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}
	if (*tempp == NULL)
	{
		ptr->next = NULL;
		*tempp = ptr;
	}
}

/******************************************************************************/

extern void RIScco_free_risattr_list(
	short		schid,
	risattr	*ptr)
{
	risattr	*temp;

	CCO_DBG(("RIScco_free_risattr_list(schid:%d ptr:0x%x)\n", schid, ptr));

	while(ptr)
	{
		temp = ptr;
		ptr = ptr->next;
		RIScco_free_risattr(schid, temp);
	}
}

/********* RISTAB *************************************************************/

extern ristab *RIScco_alloc_ristab(
	short	schid)
{
	ristab *return_ptr;

	CCO_DBG(("RIScco_alloc_ristab(schid:%d)\n", schid));

	if (schid < 0 || schid >= RIS_MAX_OPEN_SCHEMAS ||
		!RIS_schmem[schid].schname[0])
	{
		LONGJMP(RIS_E_INVALID_SCHEMA_ID);
	}

	if (RIS_schmem[schid].free_ristab)
	{
		return_ptr = RIS_schmem[schid].free_ristab;
		RIS_schmem[schid].free_ristab =
			RIS_schmem[schid].free_ristab->next;
		memset(return_ptr, 0, sizeof(ristab));
	}
	else
	{
		/*
		**	Alloc the needed structs and add them to the front
		**	of the return list.
		*/
		return_ptr = ALLOCTS(schid, ristab);
		RIS_schmem[schid].ristab_cnt++;
	}
	return return_ptr;
}

/******************************************************************************/

extern void RIScco_free_ristab(
	short		schid,
	ristab	*ptr)
{
	ristab	**tempp;

	CCO_DBG(("RIScco_free_ristab(schid:%d ptr:0x%x)\n", schid, ptr));

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
		CCO_DBG(("RIScco_free_ristab: 0x%x is not in schema memory\n", ptr));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	for(tempp = &RIS_schmem[schid].free_ristab;
		*tempp;
		tempp = &((*tempp)->next))
	{
		if (ptr < *tempp)
		{
			ptr->next = *tempp;
			*tempp = ptr;
			break;
		}
		else if (ptr == *tempp)
		{
			CCO_DBG(("FREE_STRUCT: tried to free a free ristab "
				"struct.\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}
	if (*tempp == NULL)
	{
		ptr->next = NULL;
		*tempp = ptr;
	}
}

/******************************************************************************/

extern void RIScco_free_ristab_list(
	short		schid,
	ristab	*ptr)
{
	ristab	*temp;

	CCO_DBG(("RIScco_free_ristab_list(schid:%d ptr:0x%x)\n", schid, ptr));

	while(ptr)
	{
		temp = ptr;
		ptr = ptr->next;
		RIScco_free_ristab(schid, temp);
	}
}

/*******************************************************************************
********** PERMANENT STRUCTS ***************************************************
*******************************************************************************/

/********* RISDB *************************************************************/

extern risdb *RIScco_alloc_risdb(
	void)
{
	risdb *return_ptr;

	CCO_DBG(("RIScco_alloc_risdb()\n"));

	if (RIS_permmem.free_risdb)
	{
		return_ptr = RIS_permmem.free_risdb;
		RIS_permmem.free_risdb =
			RIS_permmem.free_risdb->next;
		memset(return_ptr, 0, sizeof(risdb));
	}
	else
	{
		/*
		**	Alloc the needed structs and add them to the front
		**	of the return list.
		*/
		return_ptr = ALLOCTP(risdb);
		RIS_permmem.risdb_cnt++;
	}
	return return_ptr;
}

/******************************************************************************/

extern void RIScco_free_risdb(
	risdb	*ptr)
{
	risdb	**tempp;

	CCO_DBG(("RIScco_free_risdb(ptr:0x%x)\n", ptr));

	if (!ptr)
	{
		return;
	}

	if (!RIScco_in_memory(&RIS_mem->permanent, ptr))
	{
		CCO_DBG(("RIScco_free_risdb: 0x%x is not in permanent memory\n", ptr));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	for(tempp = &RIS_permmem.free_risdb;
		*tempp;
		tempp = &((*tempp)->next))
	{
		if (ptr < *tempp)
		{
			ptr->next = *tempp;
			*tempp = ptr;
			break;
		}
		else if (ptr == *tempp)
		{
			CCO_DBG(("FREE_STRUCT: tried to free a free risdb "
				"struct.\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}
	if (*tempp == NULL)
	{
		ptr->next = NULL;
		*tempp = ptr;
	}
}

/******************************************************************************/

extern void RIScco_free_risdb_list(
	risdb	*ptr)
{
	risdb	*temp;

	CCO_DBG(("RIScco_free_risdb_list(ptr:0x%x)\n", ptr));

	while(ptr)
	{
		temp = ptr;
		ptr = ptr->next;
		RIScco_free_risdb(temp);
	}
}

/********* RISDCLRSCHEMA ******************************************************/

extern risdclrschema *RIScco_alloc_risdclrschema(
	void)
{
	risdclrschema *return_ptr;

	CCO_DBG(("RIScco_alloc_risdclrschema()\n"));

	if (RIS_permmem.free_risdclrschema)
	{
		return_ptr = RIS_permmem.free_risdclrschema;
		RIS_permmem.free_risdclrschema =
			RIS_permmem.free_risdclrschema->next;
		memset(return_ptr, 0, sizeof(risdclrschema));
	}
	else
	{
		/*
		**	Alloc the needed structs and add them to the front
		**	of the return list.
		*/
		return_ptr = ALLOCTP(risdclrschema);
		RIS_permmem.risdclrschema_cnt++;
	}
	return return_ptr;
}

/******************************************************************************/

extern void RIScco_free_risdclrschema(
	risdclrschema	*ptr)
{
	risdclrschema	**tempp;

	CCO_DBG(("RIScco_free_risdclrschema(ptr:0x%x)\n", ptr));

	if (!ptr)
	{
		return;
	}

	if (!RIScco_in_memory(&RIS_mem->permanent, ptr))
	{
		CCO_DBG(("RIScco_free_risdclrschema: 0x%x is not in permanent memory\n",
			ptr));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	for(tempp = &RIS_permmem.free_risdclrschema;
		*tempp;
		tempp = &((*tempp)->next))
	{
		if (ptr < *tempp)
		{
			ptr->next = *tempp;
			*tempp = ptr;
			break;
		}
		else if (ptr == *tempp)
		{
			CCO_DBG(("FREE_STRUCT: tried to free a free risdclrschema "
				"struct.\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}
	if (*tempp == NULL)
	{
		ptr->next = NULL;
		*tempp = ptr;
	}
}

/******************************************************************************/

extern void RIScco_free_risdclrschema_list(
	risdclrschema	*ptr)
{
	risdclrschema	*temp;

	CCO_DBG(("RIScco_free_risdclrschema_list(ptr:0x%x)\n", ptr));

	while(ptr)
	{
		temp = ptr;
		ptr = ptr->next;
		RIScco_free_risdclrschema(temp);
	}
}

/********* RISSCHEMA **********************************************************/

extern risschema *RIScco_alloc_risschema(
	void)
{
	risschema *return_ptr;

	CCO_DBG(("RIScco_alloc_risschema()\n"));

	if (RIS_permmem.free_risschema)
	{
		return_ptr = RIS_permmem.free_risschema;
		RIS_permmem.free_risschema =
			RIS_permmem.free_risschema->next;
		memset(return_ptr, 0, sizeof(risschema));
	}
	else
	{
		/*
		**	Alloc the needed structs and add them to the front
		**	of the return list.
		*/
		return_ptr = ALLOCTP(risschema);
		RIS_permmem.risschema_cnt++;
	}
	return return_ptr;
}

/******************************************************************************/

extern void RIScco_free_risschema(
	risschema	*ptr)
{
	risschema	**tempp;

	CCO_DBG(("RIScco_free_risschema(ptr:0x%x)\n", ptr));

	if (!ptr)
	{
		return;
	}

	if (!RIScco_in_memory(&RIS_mem->permanent, ptr))
	{
		CCO_DBG(("RIScco_free_risschema: 0x%x is not in permanent memory\n",
			ptr));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	for(tempp = &RIS_permmem.free_risschema;
		*tempp;
		tempp = &((*tempp)->next))
	{
		if (ptr < *tempp)
		{
			ptr->next = *tempp;
			*tempp = ptr;
			break;
		}
		else if (ptr == *tempp)
		{
			CCO_DBG(("FREE_STRUCT: tried to free a free risschema "
				"struct.\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}
	if (*tempp == NULL)
	{
		ptr->next = NULL;
		*tempp = ptr;
	}
}

/******************************************************************************/

extern void RIScco_free_risschema_list(
	risschema	*ptr)
{
	risschema	*temp;

	CCO_DBG(("RIScco_free_risschema_list(ptr:0x%x)\n", ptr));

	while(ptr)
	{
		temp = ptr;
		ptr = ptr->next;
		RIScco_free_risschema(temp);
	}
}

/********* RISTAB_LIST ********************************************************/

extern ristablist *RIScco_alloc_ristablist(
	void)
{
	ristablist *return_ptr;

	CCO_DBG(("RIScco_alloc_ristablist()\n"));

	if (RIS_permmem.free_ristablist)
	{
		return_ptr = RIS_permmem.free_ristablist;
		RIS_permmem.free_ristablist =
			RIS_permmem.free_ristablist->next;
		memset(return_ptr, 0, sizeof(ristablist));
	}
	else
	{
		/*
		**	Alloc the needed structs and add them to the front
		**	of the return list.
		*/
		return_ptr = ALLOCTP(ristablist);
		RIS_permmem.ristablist_cnt++;
	}
	return return_ptr;
}

/******************************************************************************/

extern void RIScco_free_ristablist(
	ristablist	*ptr)
{
	ristablist	**tempp;

	CCO_DBG(("RIScco_free_ristablist(ptr:0x%x)\n", ptr));

	if (!ptr)
	{
		return;
	}

	if (!RIScco_in_memory(&RIS_mem->permanent, ptr))
	{
		CCO_DBG(("RIScco_free_ristablist: 0x%x is not in permanent memory\n",
			ptr));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	for(tempp = &RIS_permmem.free_ristablist;
		*tempp;
		tempp = &((*tempp)->next))
	{
		if (ptr < *tempp)
		{
			ptr->next = *tempp;
			*tempp = ptr;
			break;
		}
		else if (ptr == *tempp)
		{
			CCO_DBG(("FREE_STRUCT: tried to free a free ristablist "
				"struct.\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}
	if (*tempp == NULL)
	{
		ptr->next = NULL;
		*tempp = ptr;
	}
}

/******************************************************************************/

extern void RIScco_free_ristablist_list(
	ristablist	*ptr)
{
	ristablist	*temp;

	CCO_DBG(("RIScco_free_ristablist_list(ptr:0x%x)\n", ptr));

	while(ptr)
	{
		temp = ptr;
		ptr = ptr->next;
		RIScco_free_ristablist(temp);
	}
}

/********* HASHNODE ***********************************************************/

extern hashnode *RIScco_alloc_hashnode(
	void)
{
	hashnode *return_ptr;

	CCO_DBG(("RIScco_alloc_hashnode()\n"));

	if (RIS_permmem.free_hashnode)
	{
		return_ptr = RIS_permmem.free_hashnode;
		RIS_permmem.free_hashnode =
			RIS_permmem.free_hashnode->next;
		memset(return_ptr, 0, sizeof(hashnode));
	}
	else
	{
		/*
		**	Alloc the needed structs and add them to the front
		**	of the return list.
		*/
		return_ptr = ALLOCTP(hashnode);
		RIS_permmem.hashnode_cnt++;
	}
	return return_ptr;
}

/******************************************************************************/

extern void RIScco_free_hashnode(
	hashnode	*ptr)
{
	hashnode	**tempp;

	CCO_DBG(("RIScco_free_hashnode(ptr:0x%x)\n", ptr));

	if (!ptr)
	{
		return;
	}

	if (!RIScco_in_memory(&RIS_mem->permanent, ptr))
	{
		CCO_DBG(("RIScco_free_hashnode: 0x%x is not in permanent memory\n",
			ptr));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	for(tempp = &RIS_permmem.free_hashnode;
		*tempp;
		tempp = &((*tempp)->next))
	{
		if (ptr < *tempp)
		{
			ptr->next = *tempp;
			*tempp = ptr;
			break;
		}
		else if (ptr == *tempp)
		{
			CCO_DBG(("FREE_STRUCT: tried to free a free hashnode "
				"struct.\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}
	if (*tempp == NULL)
	{
		ptr->next = NULL;
		*tempp = ptr;
	}
}

/******************************************************************************/

extern void RIScco_free_hashnode_list(
	hashnode	*ptr)
{
	hashnode	*temp;

	CCO_DBG(("RIScco_free_hashnode_list(ptr:0x%x)\n", ptr));

	while(ptr)
	{
		temp = ptr;
		ptr = ptr->next;
		RIScco_free_hashnode(temp);
	}
}

/********* NET_E_S **************************************************************/

extern net_s *RIScco_alloc_net_s(
	void)
{
	net_s *return_ptr;

	CCO_DBG(("RIScco_alloc_net_s()\n"));

	if (RIS_permmem.free_net_s)
	{
		return_ptr = RIS_permmem.free_net_s;
		RIS_permmem.free_net_s =
			RIS_permmem.free_net_s->next;
		memset(return_ptr, 0, sizeof(net_s));
	}
	else
	{
		/*
		**	Alloc the needed structs and add them to the front
		**	of the return list.
		*/
		return_ptr = ALLOCTP(net_s);
		RIS_permmem.net_s_cnt++;
	}
	return return_ptr;
}

/******************************************************************************/

extern void RIScco_free_net_s(
	net_s	*ptr)
{
	net_s	**tempp;

	CCO_DBG(("RIScco_free_net_s(ptr:0x%x)\n", ptr));

	if (!ptr)
	{
		return;
	}

	if (!RIScco_in_memory(&RIS_mem->permanent, ptr))
	{
		CCO_DBG(("RIScco_free_net_s: 0x%x is not in permanent memory\n",
			ptr));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	for(tempp = &RIS_permmem.free_net_s;
		*tempp;
		tempp = &((*tempp)->next))
	{
		if (ptr < *tempp)
		{
			ptr->next = *tempp;
			*tempp = ptr;
			break;
		}
		else if (ptr == *tempp)
		{
			CCO_DBG(("FREE_STRUCT: tried to free a free net_s "
				"struct.\n"));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}
	if (*tempp == NULL)
	{
		ptr->next = NULL;
		*tempp = ptr;
	}
}

/******************************************************************************/

extern void RIScco_free_net_s_list(
	net_s	*ptr)
{
	net_s	*temp;

	CCO_DBG(("RIScco_free_net_s_list(ptr:0x%x)\n", ptr));

	while(ptr)
	{
		temp = ptr;
		ptr = ptr->next;
		RIScco_free_net_s(temp);
	}
}

/******************************************************************************/
