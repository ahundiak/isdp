/*
	I/STRUCT
*/

#ifndef vsiscvabvpln_include
#	define vsiscvabvpln_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

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
#ifndef growner_include
#	include "growner.h"
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

extern long
VSisCvAbovePlane	__((	long			*msg,
				struct GRobj_env	*curve,
				struct GRobj_env	*plane, 
				double			more,
				int			*isAbovePlane )) ;

/*+f
Function VSisCvAbovePlane

Abstract	
	Tests whether a curve is above or on a plane, i.e. if it is planar,
	if the curve plane is parallel to the input plane and if the curve
	does not go outside the boundaries of the plane:
	
	    ------------ cv	 ------------ cv ----------- cv   ------ pl
	 ----------------- pl     ------ pl      ---------- pl         ---- pl
	         OK               not OK            not OK        not OK
	 The input curve is already supposed here
	 - to be planar
	 - that its plane is // to the input plane.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRobj_env *curve		Input curve.
	IN	struct GRobj_env *plane		Input plane.
	IN	double		 more		Safety factor, see note.
	OUT	int		 *isAbovePlane	TRUE/FALSE
Note
	`more' is used to extend the range box of the input curve in the plane
	coordinate system's x- and y-directions, if `more' is non-zero we'll
	have a bigger box (this is to make sure in some cases that some curve
	parts are not too close to the plane's boundaries ).
-f*/

#endif
