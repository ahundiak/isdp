/*
	I/STRUCT
*/
#ifndef vsxsfpmacros_include
#	define vsxsfpmacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

/*+M
Macro vs$getContour

Abstract
	Generates a closed contour from plate definitions and connections.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		nbPlates	Count of plates
	IN	VSxsPlateDef	plates[]	List of plates.
	IN	int		nbCnxs		Count of connections.
	IN	VSxsPlConn	connections[]	List of connections.
	OUT	VSxsPlContour	*contour	Generated contour.
	OUT	VSxsPlShpDesc	*shapeDescr	Shape description.
Note
	- `nbPlates' must be <= VS_K_MAX_XSPLATES
	- `nbCnxs' must be   <= VS_K_MAX_XSPLATES
	- `shapeDescr->faceNames' will have its values among VS_K_sc_FlgSupR,
	   VS_K_sc_FlgSupE, etc.
	- `shapeDescr->type' will be one of the above
		- VS_K_I_SHAPE
		- VS_K_L_SHAPE
		- VS_K_T_SHAPE
		- VS_K_GAMMA_SHAPE
		- VS_K_H_SHAPE
		- VS_K_C_SHAPE
		- VS_K_BAR_SHAPE
		- VS_K_UNKNOWN_SHAPE (shape not recognized: faces not named)

	VS_K_MAX_XSPLATES and VS_K_*_SHAPE	#defined in vssxfrpldef.h
	VS_K_sc_MAXFACES  and VS_K_sc_*		#defined in vssectiondef.h
-M*/
extern long
VSgetContour			__((	long		*msg,
					int		nbPlates,
					VSxsPlateDef	plates[],
					int		nbCnxs,
					VSxsPlConn	connections[],
					VSxsPlContour	*contour,
					VSxsPlShpDesc	*shapeDescr )) ;

#omdef	vs$getContour( msg, nbPlates, plates, nbCnxs, connections, contour,
			shapeDescr )
	VSgetContour( (msg), (nbPlates), (plates), (nbCnxs), (connections),
			(contour), (shapeDescr) )
#endomdef

/*+M
Macro vs$mkProfileFromPlates

Abstract
	Generates a composite profile (object) from plate definitions and
	connections, also generates a coordinate system, parent of the
	profile with the identity matrix.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		nbPlates	Count of plates
	IN	VSxsPlateDef	plates[]	List of plates.
	IN	int		nbCnxs		Count of connections.
	IN	VSxsPlConn	connections[]	List of connections.
	IN	struct GRvg_construct
				*cst		Construction list.
	IN	VSxsPlType	*plType		Material and family of
						all plates.
	IN	char		*thicknesses[]	Part name of each plate.
	OUT	struct GRid	*profile
-M*/
extern long
VSmkProfileFrPlDefs		__((	long			*msg,
					int			nbPlates,
					VSxsPlateDef		plates[],
					int			nbCnxs,
					VSxsPlConn		connections[],
					struct GRvg_construct	*cst,
					VSxsPlType		*plType,
					char			*thicknesses[],
					struct GRid		*profile )) ;

#omdef	vs$mkProfileFromPlates( msg, nbPlates, plates, nbCnxs, connections,
				cst, plType, thicknesses, profile )
	VSmkProfileFrPlDefs( (msg), (nbPlates), (plates), (nbCnxs),
				(connections), (cst), (plType), (thicknesses),
				(profile) )
#endomdef

/*+M
Macro vs$doesCmpPrflExist

Abstract
	Given an Object Space number, a material, a plate family and a part
	name, checks whether the composite profile defined by those attributes
	exists in the specified Object Space. Returns TRUE if it exists else
	FALSE.
Arguments
	IN	OMuword		osnum		Object Space number.
	IN	char		*material	Material of profile.
	IN	char		*family		Family of plates defining
						the profile.
	IN	char		*partName	Part name of profile.
-M*/
extern int
VSdoesCmpPrflExist		__((	OMuword		osnum,
					char		*material,
					char		*family,
					char		*partName )) ;

#omdef	vs$doesCmpPrflExist( osnum, material, family, partName )
	VSdoesCmpPrflExist( (osnum), (material), (family), (partName) )
#endomdef

#endif
