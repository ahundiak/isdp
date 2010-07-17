/* $Id: VSbeamAxis.S,v 1.1.1.1 2001/01/04 21:10:13 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        vsbmaxis/VSbeamAxis.S
 *
 * Description:
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VSbeamAxis.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/02/20  20:05:02  pinnacle
# CR179800676
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/20/98  ah      CR179800676 - Allow axis to extend past edge of plate
 * 02/20/98  ah      CR179800677 - Option to force paramertization to follow
 *                                 parent support curve vice surface
 ***************************************************************************/
class specification VSbeamAxis(0:0) of VShelper ;

#ifndef OM_D_TYPES
#	include "OMtypes.h"
#endif

instance VSbeamAxis {
	OMbyte	flagAttr ;	/* Side of plate wanted <VS_K_baOnTopOfPlate>
				   or <VS_K_baOnBotOfPlate> ( #define'd in file
				   vsbmaxisdef.h ).			    */
} ;

/*+c
	Class for a beam axis. This axis is constructed from 4 elements which
	are :

	Parent #0	: a plate
	Parent #1	: a surface or a curve
	Parent #2	: a limiting start surface
	Parent #3	: a limiting end surface

	If Parent #1 is a surface, the axis direction will be the intersection
	between this surface and a side of the plate, or else, Parent #1 is a
	curve and the direction of the axis will be the same projected onto
	the side of the plate.

	Parents #2 and #3 are optional, they delimit the axis ( see further
	for more details ).

	For all surfaces, if planar they will be considered as infinite planes.

	How to construct a beam axis :

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;	<STRUCT-specific arg list>

	Fill

	cstargs.msg,
	cstargs.display,
	cstargs.level,
	cstargs.properties,

	cstargs.env_info	= <module environment of design file>
	cstargs.name		= <full name of object, NULL if unnamed>
	cstargs.geometry	= NULL ; <this field is ignored>
	cstargs.newflag 	= FALSE ;
	cstargs.class_attr	= (char *)  &vsargs ;

	parents[0]		= plate ;		<id and module env>
	parents[1]		= <surface or curve> ;	<id and module env>
	parents[2]		= <start surface> ;	<id and module env>
	parents[3]		= <end surface> ;	<id and module env>

	Note :
	-----
		If no start and end surfaces, don't fill arguments `parents[2]'
		and `parents[3]'.

	vsargs.parent_count	= 2 ;  <if no start and end surfaces>
				= 4 ;  <if start and end surfaces>

	vsargs.parent_list	= parents ;
	vsargs.representation	= <display representation>
	vsargs.feature_att	= (char *) &flagAttr ;	<side of plate :
							 VS_K_baOnTopOfPlate or
							 VS_K_baOnBotOfPlate>

Note: CR179800676,179800677 I did not test this but you should be able to set
the other flagAttr bits with this as well. ah 

	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
				... ) ;

	Notes about start and end surfaces :
	------------------------------------

	1) No start and end surfaces :

		. Parent #1 is a curve, the axis will be the projection
		  of the curve onto the plate side.

		. Parent #1 is a surface, the axis will be the intersection
		  between the side and this surface.

	2) Start and end surfaces :

		Fill arguments :

			parents[2]		= <start surface> ;
			parents[3]		= <end surface> ;
			vsargs.parent_count	= 4 ;

		The axis will be the curve constructed onto the plate side
		( projection or intersection as in 1) ) delimited by these
		two surfaces.
		The axis is inside the area delimited by these surfaces.

				  /		\
				 /		 \
		    curve  -----/-----------------\--------
			       / |_______________| \
			      / 	|	    \
			     /	      axis	     \
			start surface		end surface.
-c*/

override
	GRputattr,
	ACconstruct_feet,
	VSgetObjDef,

/*+o
Message VDget_trans_table_entries

Abstract
	Returns the plate support as main root and 'stiffener' as command name.
Arguments
	See message VDget_trans_table_entries of class VDSroot.
-o*/
	VDget_trans_table_entries ;

/*+d
Message VScnst_axis_project_onto_side

Abstract
	Called within the ACconstruct_feet method.
	Constructs the beam axis which is the curve projected onto the side of
	the plate.
Arguments
	OUT	long			*msg		Completion code :
							- MSSUCC if successful
							  operation.
							- EMS_W_NoSolution if no
							  solution found.
							- EMS_E_NoDynamicMemory
							  if no dynamic memory.
	IN	struct GRobj_env	*curve		Curve to project.
	IN	struct GRobj_env	*side		Side of plate.
	IN	struct GRobj_env	*s_surface	Limiting start surface .
	IN	struct GRobj_env	*e_surface	Limiting end surface.
	IN	struct GRvg_construct	*cst		Of axis.
	OUT	struct GRid		*axis		Constructed axis.
Notes
	If no limiting surfaces, `s_surface' and `e_surface' should be NULL.
-d*/
message VScnst_axis_project_onto_side(
			long			*msg ;
			struct GRobj_env	*curve ;
			struct GRobj_env	*side;
			struct GRobj_env	*s_surface ;
			struct GRobj_env	*e_surface ;
			struct GRvg_construct	*cst ;
			struct GRid		*axis ) ;

/*+d
Message VScnst_axis_int_surf_and_side

Abstract
	Called within the ACconstruct_feet method.
	Constructs the beam axis which is the intersection between a surface and
	a side of the plate.
Arguments
	OUT	long			*msg		Completion code :
							- MSSUCC if successful
							  operation.
							- EMS_W_NoSolution if no
							  solution found.
							- EMS_E_NoDynamicMemory
							  if no dynamic memory.
	IN	struct GRobj_env	*surface	Surface to intersect.
	IN	struct GRobj_env	*side		Side to intersect.
	IN	struct GRobj_env	*s_surface	Limiting start surface.
	IN	struct GRobj_env	*e_surface	Limiting end surface.
	IN	struct GRvg_construct	*cst		Of axis.
	OUT	struct GRid		*axis		Constructed axis.
Notes
	If no limiting surfaces, `s_surface' and `e_surface' should be NULL.

-d*/
message VScnst_axis_int_surf_and_side(
			long			*msg ;
			struct GRobj_env	*surface ;
			struct GRobj_env	*side ;
			struct GRobj_env	*s_surface ;
			struct GRobj_env	*e_surface ;
			struct GRvg_construct	*cst ;
			struct GRid		*axis ) ;

/*+d
Message VSgetConstructionType

Abstract
	Returns the construction type of the beam axis.
Arguments
	OUT	long	*msg		Completion code.
	OUT	int	*p_ctype	Construction type.
Note
	`*p_ctype' is one of the following
		- VS_K_baProjection
		- VS_K_baIntersection
	Both are #define'd in vsbmaxisdef.h
-d*/
message VSgetConstructionType( long	*msg ;
			       int	*p_ctype ) ;

/*+d
Message VSgetSideSupport

Abstract
	Returns the side of plate on which the beam axis lies.
Arguments
	OUT	long			*msg	Completion code.
	OUT	struct GRobj_env	*side	Side of plate.
-d*/
message VSgetSideSupport( long			*msg ;
			  struct GRobj_env	*side ) ;

/*+d
Message VSgeneratePerpSfToParentSf

Abstract
	This method generates a surface of projection perpendicular to
	the parent surface #1. The constructed surface will be moved to
	have the beam axis in the middle.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRvg_construct
				*cst		Construction list of surface.
	IN	double		half_width	Half-width of surface.
	OUT	struct GRobj_env
				*surface	Surface of projection.
	OUT	int		*plateSideUsed	if TRUE the returned object
						is a face of the parent plate.

Notes
	If parent #1 of the beam axis is a curve, the resulting surface
	is the side of plate where the axis lies, in this case `*plateSideUsed'
	is TRUE: do not delete this object upon some clean-up process !

	The orientation of the constructed surface is the same as the side
	of plate where the axis lies.
-d*/
message VSgeneratePerpSfToParentSf( long			*msg ;
				    struct GRvg_construct	*cst ;
				    double			half_width ;
				    struct GRobj_env		*surface ;
				    int 			*plateSideUsed);

/*+d
Message VSputPlateSide

Abstract
	This method puts to the object the side of plate on which the beam axis
	must lie.
Arguments
	OUT	long			*msg	   Completion code.
	IN	int			whichSide  Side of plate :
						   - VS_K_baOnTopOfPlate or
						     VS_K_baOnBotOfPlate
						   #define'd in vsbmaxisdef.h.
-d*/
message VSputPlateSide( long	*msg ;
			int	whichSide ) ;

/* ------------------------------------------------- */
/* CR179800676
 * CR179800677
 * I added some methods to access additional attrFlag bits.
 * I also added one for getting the plate side.  The existing code
 * used a a bit map test for this which I don't understand.
 * I replaced these tests with a call to this message VSgetPlateSide.
 * So if something gets broke, then we can fix this method.
 *
 * I also put in a generic get attribute method just because
 */
message VSgetPlateSide(long *msg; int *whichSide);

message VSputExtend(long *msg; int  extend0; int  extend1);
message VSgetExtend(long *msg; int *extend0; int *extend1);

message VSputByCurve(long *msg; int  flag);
message VSgetByCurve(long *msg; int *flag);

message VSputSpare(long *msg; int  flag);
message VSgetSpare(long *msg; int *flag);

message VSgetAttr(long *msg; int *flag);

/* CR179800676,CR179800677 End of additional methods */
/* ------------------------------------------------- */
 
/*+d
Message VSputExtendFlag

Abstract
	This method puts the extension flag.
Arguments
	OUT	long			*msg	   Completion code.
	IN	int			extend	   Extension flag (TRUE/FALSE).
Notes
	To have the axis such that it will go through the surface limits,
	set 'extend = TRUE', otherwise set 'extend = FALSE'.
-d*/
message VSputExtendFlag( long	*msg ;
			 int	extend ) ;

/*+d
Message VSgetExtendFlag

Abstract
	This method returns the extension flag.
Arguments
	OUT	long			*msg	   Completion code.
	IN	int			*extend    Extension flag (TRUE/FALSE).
Notes
	If the axis was extended, '*extend' is TRUE, otherwise '*extend' is
	FALSE.
-d*/
message VSgetExtendFlag( long	*msg ;
			 int	*extend ) ;

/*+d
Message VSgetXdirectionForCrossSectionCS

Abstract
	This method returns the available direction for the x-vector of the
	cross-section coordinate system if any.
Arguments
	OUT	long			*msg	   Completion code.
	OUT	int			*haveDir   Have direction (TRUE/FALSE).
	OUT	IGRvector		xDir	   X direction.
-d*/
message VSgetXdirectionForCrossSectionCS( long		*msg ;
					  int		*haveDir ;
					  IGRvector	xDir ) ;

end specification VSbeamAxis ;
