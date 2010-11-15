/*
**	NAME:							DIChash_misc.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION. Dianne
*/
 
/*
**	INCLUDES
*/
#include "rismem.h"
#include "ristoken.h"
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
#define dicmisc_c
#include "ccostmgr.prt"
#include "comgtnme.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "dicmisc.prt"
#include "sys.prt"

/******************************************************************************/

extern int RISdic_hash_on_id(
	int id)
{
	return(id % HASH_TAB_SIZE);
}

/******************************************************************************/

extern int RISdic_hash_on_name(
	char *name)
{
	int i, len, inc, mid;
	int val=1;
	char *end;

	len = strlen(name);
	if (!len) return(0);

	end = name + len - 1;
	inc = (len+8)/8;
	mid = (len-1)/2;

	for (i=0 ; i <= mid; i+=inc)
	{
		val += ((i+1) * name[i]) + (len * end[-i]);
	}
	if (val < 0) val = -val;
	return(val % HASH_TAB_SIZE);
}

/******************************************************************************/

extern char *RISdic_get_name(
	int		tok,
	void	*ptr)
{
	DIC_DBG(("RISdic_get_name(tok:%s ptr:0x%x\n", RIScom_get_token_name(tok),
		ptr));

	switch(tok)
	{
		case RIS_TOK_TABLE:
			return(((ristab *)ptr)->tabname);
		case RIS_TOK_DATABASE:
			return(((risdb *)ptr)->dbname);
		case RIS_TOK_SCHEMA:
			return(((risschema *)ptr)->schname);
		case RIS_TOK_DECLARE_SCHEMA:
			return(((risdclrschema *)ptr)->schname);
		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	return "";
}

/******************************************************************************/

static void free_table(
	ristab *tab)
{
	risattr		*attr;
	risattr		*temp;

	DIC_DBG(("free_table(tab:0x%x)\n", tab));

	if (tab)
	{
		attr = tab->attr;
		RIScco_free_risaccess_list(tab->schema->schid, tab->acc);
		RIScco_free_ristab(tab->schema->schid, tab);
		while(attr)
		{
			temp = attr;
			attr = attr->next;
			temp->next = NULL;

			RIScco_free_risaccess_list(tab->schema->schid, temp->acc);
			RIScco_free_risattr(tab->schema->schid, temp);
		}
	}

	DIC_DBG(("free_table:returning\n"));
}

/******************************************************************************/

extern void RISdic_free_dschema(
	risdclrschema *dschema)
{
	DIC_DBG(("RISdic_free_dschema(dschema:0x%x)\n", dschema));

	if (dschema)
	{
		RIScco_free_risdclrschema(dschema);
	}

	DIC_DBG(("RISdic_free_dschema:returning\n"));
}

/******************************************************************************/

static void RISdic_free_schema(
	risschema *schema)
{
	DIC_DBG(("RISdic_free_schema(schema:0x%x)\n", schema));

	if (schema)
	{
		RIScco_free_risschema(schema);
	}

	DIC_DBG(("RISdic_free_schema:returning\n"));
}

/******************************************************************************/

extern void RISdic_free_hash(
	hashnode	*hashp)
{
	DIC_DBG(("RISdic_free_hash(hashp:0x%x)\n", hashp));

	if (hashp)
	{
		switch(hashp->tok)
		{
			case RIS_TOK_TABLE:
				free_table((ristab *)hashp->ptr);
				break;

			case RIS_TOK_DATABASE:
				RIScco_free_risdb((risdb *)hashp->ptr);
				break;

			case RIS_TOK_SCHEMA:
				RISdic_free_schema((risschema *)hashp->ptr);
				break;

			case RIS_TOK_DECLARE_SCHEMA:
				RISdic_free_dschema((risdclrschema *)hashp->ptr);
				break;

			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
		}
		RIScco_free_hashnode(hashp);
	}

	DIC_DBG(("RISdic_free_hash: returning\n"));
}

/******************************************************************************/
