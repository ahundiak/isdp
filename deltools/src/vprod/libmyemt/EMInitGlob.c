#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMInitGlobals					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMInitGlobals ()						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function initalizes needed globals.			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  Zero.								*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMInitGlobals ()
{
	Inq_screen_info (_EMScreenInfo);

	return (EM_NO_ERROR);
}
