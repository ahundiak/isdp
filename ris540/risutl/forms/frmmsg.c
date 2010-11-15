/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							frmmsg.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/90
**	ABSTRACT:
**		This file contains the routines that manage the message fields for
**		the forms
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "forms.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmmsg_c
#include "comdebug.prt"
#include "fi.prt"
#include "frmmsg.prt"


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

extern void RISfrm_display_msgs()
{
	int			i,j;
	RISfrm_msg	*msgp;

	FRM_DBG(("RISfrm_display_msgs()\n"));

	for (i = 0; i < FORM_MSG_COUNT; i++)
	{
		msgp = &RISfrm_msgs[i];
		for (j = 0; j < msgp->count; j++)
		{
			FIg_hilite(msgp->fp, msgp->label[j]);
		}
		if (msgp->str[0])
		{
			FIfld_set_text(msgp->fp, msgp->msg_fld_label, 0, 0, msgp->str,0);
		}
	}
}

/******************************************************************************/

extern void RISfrm_clear_msgs()
{
	int			i,j;
	RISfrm_msg	*msgp;

	FRM_DBG(("RISfrm_clear_msgs()\n"));

	for (i = 0; i < FORM_MSG_COUNT; i++)
	{
		msgp = &RISfrm_msgs[i];
		
		for (j = 0; j < msgp->count; j++)
		{
			FIg_unhilite(msgp->fp, msgp->label[j]);
		}
		if (msgp->str[0])
		{
			FIfld_set_text(msgp->fp, msgp->msg_fld_label, 0, 0, "",0);
			FIfld_set_text(msgp->fp, msgp->msg_fld_label, 1, 0, "",0);
		}
		msgp->count = 0;
		msgp->str[0] = '\0';
	}
}

/******************************************************************************/
