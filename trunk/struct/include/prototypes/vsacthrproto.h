/*
	I/STRUCT

	Locate action handlers and process-fence action handlers.
*/

#ifndef vsacthrproto_include
#	define vsacthrproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vscmd_include
#	include "vscmd.h"
#endif

/*+f
Function VSisAClosedPlanarCurve_PFAH

Abstract
	Filter function for macro vs$process_fence which only retains closed
	planar curves.
Arguments
	IN	struct GRobj_env	*curve	Element to test.
	IN	VSfenceArgs		*PFargs
Keywords
	#closed#curve#fence#planar#
Note
	This function is designed to be passed as an argument to macro
	vs$process_fence.
-f*/
extern int
VSisAClosedPlanarCurve_PFAH	__((	struct GRobj_env	*curve,
					VSfenceArgs		*PFargs )) ;
/*+f
Function VSisAClosedPlanarCurve_LCAH

Abstract
	Filter function for macro lc$locate which only retains closed
	planar curves.
Arguments
	Standard arguments for a locate action handler (see documentation on
	lc$locate).
Keywords
	#closed#curve#locate#planar#
Note
	This function is designed to be passed as an argument to macro
	lc$locate.
-f*/
extern int
VSisAClosedPlanarCurve_LCAH	__((	VSlocateArgs		*LCargs,
					struct GRlc_info	*entry,
					struct LC_action_args	*args,
					enum GRlocate_action	*action )) ;

extern int
VSisAnExtOrOrgStiffener_PFAH	__((	struct GRobj_env	*stiffener,
					VSfenceArgs		*PFargs )) ;

extern int
VSisAnExtOrOrgStiffener_LCAH	__((	VSlocateArgs		*LCargs,
					struct GRlc_info	*entry,
					struct LC_action_args	*args,
					enum GRlocate_action	*action )) ;

/*+f
Function VSfilterFeature_PFAH

Abstract
	Filter function for macro vs$process_fence which only retains
	structural elements according to a specified input type.
Arguments
	IN	struct GRobj_env	*object	Element to test.
	IN	VSfenceArgs		*PFargs	Contains type to retain in
						`PFargs->value'.
Keywords
	#fence#structural#
Note
	This function is designed to be passed as an argument to macro
	vs$process_fence.
Example
	To retain beams `PFargs->value' must be set to `VS_m_BEAM' and plates
	`VS_m_PLATE'.
-f*/
extern int
VSfilterFeature_PFAH		__((	struct GRobj_env	*object,
					VSfenceArgs		*PFargs )) ;

/*+f
Function VSfilterFeature_LCAH

Abstract
	Filter function for macro lc$locate which only retains structural
	elements according to a specified input type.
Arguments
	Standard arguments for a locate action handler (see documentation on
	lc$locate).
Keywords
	#structural#locate#
Note
	This function is designed to be passed as an argument to macro
	lc$locate.
Example
	To retain beams `LCargs->value' must be set to `VS_m_BEAM' and plates
	`VS_m_PLATE'.
-f*/
extern int
VSfilterFeature_LCAH		__((	VSlocateArgs		*LCargs,
					struct GRlc_info	*entry,
					struct LC_action_args	*args,
					enum GRlocate_action	*action )) ;

/*+f
Function VSfilterFeatureNeg_PFAH

Abstract
	Filter function for macro vs$process_fence which only retains
	structural elements *not being* of a specified input type.
Arguments
	IN	struct GRobj_env	*object	Element to test.
	IN	VSfenceArgs		*PFargs	Contains type to retain in
						`PFargs->value'.
Keywords
	#fence#negation#structural#
Note
	This function is designed to be passed as an argument to macro
	vs$process_fence.
Example
	To reject structural elements which are images `PFargs->value' must be
	set to `VS_m_IMG_generic'.
-f*/
extern int
VSfilterFeatureNeg_PFAH		__((	struct GRobj_env	*object,
					VSfenceArgs		*PFargs )) ;

/*+f
Function VSfilterFeatureNeg_LCAH

Abstract
	Filter function for macro lc$locate which only retains structural
	elements *not being* of a specified input type.
Arguments
	Standard arguments for a locate action handler (see documentation on
	lc$locate).
Keywords
	#structural#locate#negation#
Note
	This function is designed to be passed as an argument to macro
	lc$locate.
Example
	To reject structural elements which are images `LCargs->value' must be
	set to `VS_m_IMG_generic'.
-f*/
extern int
VSfilterFeatureNeg_LCAH		__((	VSlocateArgs		*LCargs,
					struct GRlc_info	*entry,
					struct LC_action_args	*args,
					enum GRlocate_action	*action )) ;

extern int
VSnoFrozenFeature_PFAH		__((	struct GRobj_env	*object,
					VSfenceArgs		*PFargs )) ;

extern int
VSnoFrozenFeature_LCAH		__((	VSlocateArgs		*LCargs,
					struct GRlc_info	*entry,
					struct LC_action_args	*args,
					enum GRlocate_action	*action )) ;

extern int
VSfilterFeature_PF		__((	struct GRobj_env	*object,
					VSfenceArgs		*arg,
					unsigned long		yesMask,
					unsigned long		noMask )) ;

extern int
VSfilterFeature			__((	VSlocateArgs		*LCargs,
					struct GRlc_info	*entry,
					struct LC_action_args	*args,
					enum GRlocate_action	*action,
					unsigned long		yesMask,
					unsigned long		noMask )) ;

extern int
VSisAnEditableFeature_PFAH	__((	struct GRobj_env	*object,
					VSfenceArgs		*arg )) ;

extern int
VSisAnEditableFeature_LCAH	__((	VSlocateArgs		*LCargs,
					struct GRlc_info	*entry,
					struct LC_action_args	*args,
					enum GRlocate_action	*action )) ;

extern int
VSisSupportOfBeam_PFAH		__((	struct GRobj_env	*surface,
					VSfenceArgs		*arg )) ;

extern int
VSisSupportOfBeam_LCAH		__((	VSlocateArgs		*LCargs,
					struct GRlc_info	*entry,
					struct LC_action_args	*args,
					enum GRlocate_action	*action )) ;

extern int
VSisSupportOfStiffener_PFAH	__((	struct GRobj_env	*plate,
					VSfenceArgs		*arg )) ;

extern int
VSisSupportOfStiffener_LCAH	__((	VSlocateArgs		*LCargs,
					struct GRlc_info	*entry,
					struct LC_action_args	*args,
					enum GRlocate_action	*action )) ;

extern int
VSisSupportOfPlate		__((	long			*msg,
					struct GRobj_env	*surface )) ;

extern int
VSnotSupportOfPlate_PFAH	__((	struct GRobj_env	*plate,
					VSfenceArgs		*arg )) ;

extern int
VSnotSupportOfPlate_LCAH	__((	VSlocateArgs		*LCargs,
					struct GRlc_info	*entry,
					struct LC_action_args	*args,
					enum GRlocate_action	*action )) ;

extern int
VSrejectSubClass_PFAH		__((	struct GRobj_env	*object,
					VSfenceArgs		*arg )) ;

extern int
VSrejectSubClass_LCAH		__((	VSlocateArgs		*LCargs,
					struct GRlc_info	*entry,
					struct LC_action_args	*args,
					enum GRlocate_action	*action )) ;

#endif /* vsacthrproto_include */
