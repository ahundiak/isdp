/*
	I/STRUCT
*/
class specification VSplate(0:0) of VSfeature ;

#ifndef OM_D_MACROS
#	include "OMmacros.h"
#endif
#ifndef vs_include
#	include "vs.h"
#endif
#ifndef vsplatedef_include
#	include "vsplatedef.h"
#endif
#ifndef vsplate_include
#	include "vsplate.h"
#endif

/*+c
	Abstract class for all types of plates.
-c*/
	
override

/*+o
Message GRdetplane

Abstract
	Forwards message to base (bottom) surface.
Arguments
	See message GRdetplane of class GRvg.
-o*/
	GRdetplane,
	VSgetObjDef,
	VScreateFrozenCopy,
	VSshowOrientation,
	VSdescribeOutput,
	VSgetSupportedElements,

/*+o
Message VDget_prefix_name

Abstract
	Returns 'P' as prefix and FALSE for 'real_name'.
Arguments
	See message VDget_prefix_name of class VDSroot.
-o*/
	VDget_prefix_name,

/*+o
Message VSgetMassProperties

Abstract
	Just to mention that the plate area is computed as twice the area of
	on side of the plate.
Arguments
	See message VSgetMassProperties of class VSpart.
-o*/
		VSgetMassProperties,

/*+o
Message ACgive_structure

Abstract
	Queries the object for data to feed the Relational Data Base in
	connection with I/STRUCT. May use same message defined in ancestor
	classes.
Arguments
	See message ACgive_structure of class NDmacro.
-o*/
		ACgive_structure,

/*+o
Message ACreturn_foot

Abstract
	In case plate is consumed hence its output is a surface, and a request
	is performed with a path from back when the output was an offset solid,
	attempts to return an object satisfying the query.
Arguments
	See message ACreturn_foot of class NDmacro.
-o*/
		ACreturn_foot,

/*+o
Message ACgive_path

Abstract
	If we are in 2D and the id of the output whose name is wanted is
	that of our component (which is a surface), we return "plate:base"
	instead of "plate", so that when we have moved to 3D, we get
	an ACreturn_foot message with "plate:base" and then return the
	base surface of our component solid ( whose output name is "plate" ),
	instead of the component solid itself.
Arguments
	See message ACgive_path of class ACcpx.
-o*/
	ACgive_path,

/*+o
Message VStransIPATHToName

Abstract
	We want to give a name to the top and bottom surfaces of a plate.
Arguments
	See message VStransIPATHToName of class VSpart.
-o*/
		VStransIPATHToName,

/*+o
Message VStransNameToIPATH

Abstract
	Translate a plate's top or bottom name to an index path.
Arguments
	See message VStransNameToIPATH of class VSpart.
-o*/
		VStransNameToIPATH ;

/*+d
Message VStopBottomMapping

Abstract
	Returns the component indices and names of the bottom an top surfaces
	of a plate:

			^			"Top" and "bottom" depend
			| orientation		upon the orientation choosen
	+---------------|-----top-------+	fot the plate.
	| PLATE		|		|
	+---------------|-----bottom----+
Arguments
	OUT	long	*msg		Completion code.
	IN	int	count		Count of components of solid.
	OUT	int	index[2]	Component indices (0=bottom,1=top).
	OUT	GRname	name[2]		Component names (0=bottom,1=top).
-d*/
message VStopBottomMapping(	long	*msg ;
				int	count,
					index[2] ;
				GRname name[2] ) ;

/*+d
Message VSchgRepForConsume

Abstract
	Sent to a consumed plate by a consuming plate telling it to change
	its consumed representation. In turn, the target of the message
	sends this same message to the parent plate it consumes (if any)
	to get it a good consumed representation.
Argument
	IN	VSdspRep	consumedRep	The wanted representation in
						consumed state.
-d*/
message VSchgRepForConsume( VSdspRep consumedRep ) ;

/*+d
Message VSgetFaceCount

Abstract
	Returns the number of faces of a plate in 3D representation.
Arguments
	OUT	long		*msg	Completion code.
	OUT	int		*count	Number of faces.
-d*/
message VSgetFaceCount( long *msg ; int *count ) ;

/*+d
Message VSgetPlateWidthLength

Abstract
	Computes the width and length of the plate ( width < length ).
Arguments
	OUT	long		*msg	Completion code.
	IN	struct GRmd_env	*myEnv	Module environment of plate.
	OUT	double		*width	Width of plate.
	OUT	double		*length	Length of plate.	
-d*/
message VSgetPlateWidthLength(	long		*msg ;
				struct GRmd_env	*myEnv ;
				double		*width,
						*length ; ) ;


end specification VSplate ;
