/*
	I/STRUCT
	Global variables.

	File dependency :	igr.h
				vspart.h
*/

#ifndef vsglobals_include
#	define vsglobals_include

#	ifdef VS_DECLARE_EXTERNS
#		define vs_extern
#	else
#		define vs_extern extern
#	endif

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif
#ifndef gr_include
#	include "gr.h"
#endif
#ifndef igr_include
#	include "igr.h"
#endif
#ifndef igrdp_include
#	include "igrdp.h"
#endif
#ifndef godef_include
#	include "godef.h"
#endif
#ifndef go_include
#	include "go.h"
#endif
#ifndef vspart_include
#	include "vspart.h"
#endif

/*
	Dummy symbology.
*/
vs_extern	struct IGRdisplay	*VS_Gp_DummyDisplay ;
vs_extern	long			VS_Gi_DummyLevel ;

/*
	Group.
*/
vs_extern	char		*VS_Ga_Group,
				*VS_Ga_Passwd ;

#endif
