/* $Id: VSbeamSupp.S,v 1.1.1.1 2001/01/04 21:10:21 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmsupp/VSbscnstfeet.I
 *
 * Description: Gets top or bottom of plate
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbeamSupp.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:21  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/02/20  20:26:00  pinnacle
# CR179800676
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 02/20/98  ah        CR179800676 - Allow axis to extend past edge of plate
 *                     See note in construct feet
 ***************************************************************************/
class specification VSbeamSupp(0:0) of VShelper ;

#ifndef OM_D_TYPES
#	include "OMtypes.h"
#endif

instance VSbeamSupp {
	OMbyte	flagAttr ;	/* Side of plate wanted <VS_K_bsOnTopOfPlate>
				   or <VS_K_bsOnBotOfPlate> ( #define'd in file
				   vsbmsuppdef.h ).			    */
} ;

/*+c
	Class for a beam support. This support is constructed 
	from 2 elements which
	are :

	Parent #0	: a beam axis
	parent #1	: an expression containg info of twist
			  it should defined like 
				"stAng|stRefType|edAng|edRefType"
	Parent #i	: variable parent count for angle at interval i.


	How to construct a beam support:

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
	parents[1]		= <beam axis> ;		<id and module env>
	parents[i]		= <angle expr> ;	<id and module env>

	Note :
	-----

	vsargs.parent_count	= 2 + count of intermediate 
					position/anlge/reftypes;
	vsargs.parent_list	= parents ;
	vsargs.representation	= <display representation>
	vsargs.feature_att	= (char *) &flagAttr ;	<side of plate :
							 VS_K_baOnTopOfPlate or
							 VS_K_baOnBotOfPlate>


	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
				... ) ;

-c*/

override
	ACconstruct_feet,
	VSgetObjDef,
	GRputattr ;

/*+d
Message VSputPlateSide

Abstract
	This method puts to the object the side of plate on which the beam axis
	must lie.
Arguments
	OUT	long			*msg	   Completion code.
	IN	int			whichSide  Side of plate :
						   - VS_K_bsOnTopOfPlate or
						     VS_K_bsOnBotOfPlate
						   #define'd in vsbmsuppdef.h.
-d*/
message VSputPlateSide( long	*msg ;
			int	whichSide ) ;

end specification VSbeamSupp ;













