/*
	I/STRUCT
*/ 
class specification VSbooBeam(0:0) of VSdprPart, VSmodBeam ;

#include "OMmacros.h"
#include "emsbool.h"
#include "vs.h"
#include "vsbeamdef.h"
#include "vsbeam.h"

/*+c
	This class defines objects which are beams having undergone a boolean
	difference to cut them out.

	Parents : #0		a beam				(operand)
		  #1 to n	a solid			OR	(operator)
				a surface		OR
				a planar curve	

	Note :
		If a parent is a surface, the boolean difference will be
	performed so that the part of the beam which is on the same side
	as the normal of the surface will be removed.

		If parent is a closed curve, a surface of projection will
	be created, using the normal of the plane of the curve, big enough
	so as to traverse the beam. Then the boolean difference will be
	performed so that the part of the beam which is on the same side
	as the center of the planar curve will be removed.

		The maximum number of operator parents allowed is
	`VS_K_bbMAX_NOTCHES' #define'd in "vsbeamdef.h".
-c*/

from VSdprPart inherit VSget_sub_cmp_ix ;

override
	ACconstruct_feet,
	VSgetObjDef,

/*+o
Message GRgetrang

Abstract
	Sends range of parent beam. See GRgraphics.S.
-o*/
	GRgetrang,

/*+o
Message NDdelete

Abstract
	Sends VSfeature.VSdelete to self. See VSfeature.S.
-o*/
	NDdelete,

/*+o
Message NDmove_to_root

Abstract
	Sends VSfeature.VSmove_to_root to self. See VSfeature.S.
-o*/
	NDmove_to_root,

/*+o
Message NDparent_deleted

Abstract
	Sends VSfeature.VSparentsDeleted to self. See VSfeature.S.
-o*/
	NDparent_deleted,

/*+o
Message VSgetSupportAxis

Abstract
	The axis of this beam is possibly resized if beam has been cut back at
	the ends.
Arguments
	See message VSgetSupportAxis of class VSbeam.
-o*/
	VSgetSupportAxis ;

/*+o
Message GRconstruct

Abstract
	Avoids VSbeam.GRconstruct and use the general one of VScpx.

	The `class_attr' field of the construction list should contain a
	pointer to a `struct VScnst_list'.
	(See GRvg.S for further details on GRconstruct)
	The objects deletes itself if the construction failed.	
-o*/
from VSfeature	inherit GRconstruct ;

end specification VSbooBeam ;
