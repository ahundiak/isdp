/*
	I/VDS	Copy.

	Global variables.

	File dependency :	igr.h
				v_part.h
*/

#ifndef v_globals_include
#	define v_globals_include

#	ifdef VD_DECLARE_EXTERNS
#		define vds_extern
#	else
#		define vds_extern extern
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

/*
	Dummy symbology.
*/
vds_extern	struct IGRdisplay	*VD_Gp_DummyDisplay ;
vds_extern	long			VD_Gi_DummyLevel ;

#endif
