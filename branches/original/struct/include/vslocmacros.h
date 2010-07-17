/*
	I/STRUCT
*/

#ifndef vslocmacros_include
#	define vslocmacros_include

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

/*+M
Macro vs$range_locate

Abstract
	This macro executes a locate with respect to a given range ( locate
	elements inside, outside or overlapping range ).
Arguments
	OUT	long		 *msg		Completion code.
	IN	GRrange 	 range		Range in world coordinates.
	IN	long		 properties	Properties of elements to
						locate ( see lcdef.h ).
	IN	long		 owner_action	Owner action of elements to
						locate ( see lcdef.h ).
	IN	int		 levels[]	Levels of elements to locate.
	IN	long		 relationship	Relation ship of elements to
						locate with respect to range.
						GO_INSIDE
						GO_OUTSIDE
						GO_OVERLAP
						GO_INSIDE  | GO_OVERLAP
						GO_OUTSIDE | GO_OVERLAP
						( defined in grgsdef.h ).
	IN	char		 *classes	Classes of elements to locate.
	OUT	int		 *count 	Count of located elements.
	OUT	struct GRobj_env **list 	List of located elements.
Notes
	`*list` is malloced and should be freed by the caller.

	The size of `levels[]` should be equal to DP_NUM_OF_LEVELS/32 + 1.
	The valid levels are those that have their corresponding bit set to 1.
	If `levels[]` is NULL, all the levels are validated.

	The classes are given like in COB argument `locate_class`.
	i.e :
		"GRcurve" -> Wants elements only of class GRcurve.

		"+GRcurve" or
		"&GRcurve" -> Wants elements of class and subclass of
			      GRcurve.

		"!GRcurve" or
		"~GRcurve" or
		"-GRcurve" -> Wants elements NOT of class and subclass of
			      GRcurve.

		"GRcurve,GRpoint" or
		"GRcurve;GRpoint" -> Wants elements of class GRcurve or
				     GRpoint.

	if `classes` is NULL, all classes are validated.

-M*/
extern long
VSrangeLocate			__((	long		 *msg,
					GRrange 	 range,
					long		 properties,
					long		 owner_action,
					int		 levels[],
					long		 relationship,
					char		 *classes,
					int		 *count,
					struct GRobj_env **list )) ;
#omdef vs$range_locate( msg,
			range,
			properties = LC_DP_ONLY | LC_LC_ONLY | LC_RW,
			owner_action = LC_RIGID_COMP | LC_RIGID_OWNER |
				       LC_FLEX_COMP  | LC_FLEX_OWNER  |
				       LC_REF_OBJECTS,
			levels = NULL,
			relationship = GO_INSIDE,
			classes = NULL,
			count,
			list )

       VSrangeLocate( (msg),
		      (range),
		      (properties),
		      (owner_action),
		      (levels),
		      (relationship),
		      (classes),
		      (count),
		      (list) )
#endomdef

#endif
