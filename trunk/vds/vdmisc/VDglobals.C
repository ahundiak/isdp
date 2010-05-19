/*
	I/VDS	Copy

Function VSinitGlobals

Abstract
	Initializes I/VDS's global variables.
Arguments
	IN	long	*msg		Completion code
Note
	Must be called at startup.
*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"

#include "VDmsg.h"
#include "SMmsg.h"
#define VD_DECLARE_EXTERNS	/* For the following include	*/
#include "v_globalmsg.h"

/*----------------------------------------------------------------------------*/
long				VD_Gi_DummyLevel	= 1 ;
static struct IGRdisplay	VD_Gs_DummyDisplay	= { 1, 1, 1 } ;
struct IGRdisplay*		VD_Gp_DummyDisplay	= &VD_Gs_DummyDisplay ;
char*				VD_Ga_Group		= "ige" ;
char*				VD_Ga_Passwd		= "IGE" ;
/*----------------------------------------------------------------------------*/

