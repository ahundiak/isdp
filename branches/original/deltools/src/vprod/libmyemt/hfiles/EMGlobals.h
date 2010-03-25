#ifndef _EMGLOBALS
#define _EMGLOBALS	0


#ifndef MAX_SCREENS
#include <tools.h>
#endif

#include <stdio.h>
#include "EMTCB.h"


/************************************************************************/
/*									*/
/*	Terminal Control Block List					*/
/*									*/
/************************************************************************/
	
#define	NUMBER_OF_SLOTS	40

extern EM_TCB	*EM_TCB_list[NUMBER_OF_SLOTS];


/************************************************************************/
/*									*/
/*	Global vlt offset						*/
/*	All references to the vlt must add in this value in order to	*/
/*	avoid conflict with workstations that use a fixed vlt.		*/
/*	(EMState.c)							*/
/*									*/
/************************************************************************/

extern int	_EMFixedVLTOffset[MAX_SCREENS];


/************************************************************************/
/*									*/
/*	Screen info (EMInitTCB.c)					*/
/*									*/
/************************************************************************/

extern struct scr_info	_EMScreenInfo[MAX_SCREENS];


/************************************************************************/
/*									*/
/*	Font drawing modes (EMInitTCB.c)				*/
/*									*/
/************************************************************************/

extern int	_EMFontModes[];


/************************************************************************/
/*									*/
/*	Menu globals							*/
/*									*/
/************************************************************************/

extern int	_EMMenuWindow;
extern int	(*_EMMenuDriver[])();


#endif
