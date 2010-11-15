/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnalias.c
**	AUTHORS:						David Michal
**	CREATION DATE:					9/88
**	ABSTRACT:
**		This file contains the routines that handle table aliases.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "rismem.h"
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trnalias_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comtree.prt"
#include "trnalias.prt"
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

extern void RIStrn_make_alias_tree(
	ristree * aliasp,
	ristree * old_tablep)
{
	ristree	*new_tablep, *temp;
	ristab	*new_tab, *old_tab, *orig_tab;
	risattr *new_attr, *old_attr;

	TRN_DBG(("RIStrn_make_alias_tree(aliasp:0x%x old_tablep:0x%x)\n",
		aliasp,old_tablep));

/* set up pointers */

	old_tab = old_tablep->info.tab;
	if (old_tab->tabtype == 'A')
	{
		orig_tab = old_tab->tab;
	}
	else
	{
		orig_tab = old_tab;
	}

/* make a copy of the tree */

	new_tablep = RIScom_copy_tree(old_tablep); /* Hitesh */

/* make a new ristab */

	new_tab = ALLOCT(ristab);
	new_tab->schema = orig_tab->schema;
	new_tab->tabtype = 'A';
	strcpy(new_tab->tabname,aliasp->info.val);
	strcpy(new_tab->tabowner,orig_tab->tabowner);
	new_tablep->pos = aliasp->pos;
	new_tab->tab = orig_tab;
	new_tablep->info.tab = new_tab;

/* make new risattrs */

	for(temp=new_tablep->rhs;temp;temp=temp->rhs)
	{
		old_attr = temp->lhs->info.attr;
		new_attr = ALLOCT(risattr);
		new_attr->tab = new_tab;
		strcpy(new_attr->attrname,old_attr->attrname);
		strcpy(new_attr->extern_attrname,old_attr->extern_attrname);
		new_attr->atype = old_attr->atype;
		new_attr->asize = old_attr->asize;
		temp->lhs->info.attr = new_attr;
	}
	memcpy((char*)old_tablep ,(char*)new_tablep, sizeof(ristree));

	TRN_DBG(("RIStrn_make_alias_tree:complete\n"));
}

/******************************************************************************/
