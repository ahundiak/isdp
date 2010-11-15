/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comtree.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscl_pa.h"
#include "riscom.h"
#include "rismem.h"

/*
**	FUNCTION PROTOTYPES
*/
#define comtree_c
#include "comalloc.prt"
#include "comtree.prt"
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

/* Hitesh */
extern ristree * RIScom_copy_tree_node(
	ristree * tp1)
{
	ristree * tp2 = 0;
	
	if (tp1)
	{
		tp2 = ALLOCT(ristree);
		memcpy(tp2, tp1, sizeof(ristree));
	}
	return(tp2);
}

/******************************************************************************/

extern ristree * RIScom_copy_tree(
	ristree * tp1)
{
	ristree * tp2 = 0;
	
	if (tp1)
	{
		tp2 = RIScom_copy_tree_node(tp1);
		tp2->lhs = RIScom_copy_tree(tp1->lhs);
		tp2->rhs = RIScom_copy_tree(tp1->rhs);
	}
	return(tp2);
}

/******************************************************************************/

extern risaccess * RIScom_copy_access_node(
	short		schid,
    risaccess * acc1)
{
    risaccess * acc2 = 0;

    if (acc1)
    {
		acc2 = ALLOCTS(schid,risaccess);
    	memcpy(acc2, acc1, sizeof(risaccess));
    }
    return(acc2);
}

/******************************************************************************/

extern risaccess * RIScom_copy_access_list(
	short		schid,
    risaccess * acc1)
{
    risaccess * acc2 = 0;
    risaccess * temp1;
    risaccess * temp2 = 0;

    for(temp1=acc1;temp1;temp1=temp1->next)
    {
		if (temp2)
		{
       		temp2->next = RIScom_copy_access_node(schid,temp1);
			temp2 = temp2->next;
		}
		else
		{
       		temp2 = RIScom_copy_access_node(schid,temp1);
			acc2 = temp2;
		}
    }
    return(acc2);
}

/******************************************************************************/
