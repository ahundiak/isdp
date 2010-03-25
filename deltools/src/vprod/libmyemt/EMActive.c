#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMActivate					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMActivate (TCBD)						*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function makes the specified terminal active.  It makes	*/
/*	  the previously active terminal inactive.			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMActivate (TCBD)

int	TCBD;
{
    int		i;
    EM_TCB	*TCB;

    for (i = 0; i < NUMBER_OF_SLOTS; i++)
    {
	if ((EM_TCB_list[i] != NULL) && EM_TCB_list[i]->active)
	    EM_TCB_list[i]->active = FALSE;
    }

    TCB = EM_TCB_list[TCBD];
    TCB->active = TRUE;
    _EMPutEnv (TCB);
    _EMUpdateKeyboardMode (TCB);

    return (EM_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMDeactivate					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMDeactivate (TCBD)					*/
/*									*/
/*	  int	TCBD;		 -- TCB descriptor of the terminal	*/
/*				    instance				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function deactivates the specified terminal.		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMDeactivate (TCBD)

int	TCBD;
{
    EM_TCB	*TCB;

    TCB = EM_TCB_list[TCBD];
    TCB->active = FALSE;

    return (EM_NO_ERROR);
}
