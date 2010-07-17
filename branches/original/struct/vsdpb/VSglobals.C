/*
	I/STRUCT

Function VSinitGlobals

Abstract
	Initializes I/STRUCT's global variables.
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

#include "VSmsg.h"
#define VS_DECLARE_EXTERNS	/* For the following include	*/
#include "vsglobalmsg.h"
/*----------------------------------------------------------------------------*/
long				VS_Gi_DummyLevel	= 1 ;
static struct IGRdisplay	VS_Gs_DummyDisplay	= { 1, 1, 1 } ;
struct IGRdisplay*		VS_Gp_DummyDisplay	= &VS_Gs_DummyDisplay ;
char*				VS_Ga_Group		= "ige" ;
char*				VS_Ga_Passwd		= "IGE" ;
/*----------------------------------------------------------------------------*/

