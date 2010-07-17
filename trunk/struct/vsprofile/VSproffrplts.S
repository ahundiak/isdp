/*
	I/STRUCT
*/
class specification VSproffrplts(0:0) of VShelper ;

/*+c
	Beam profile made from plate definitions. The graphic curves owned by
	the profile are in the z=0 plane. With their origin coincident with
	the origin of the parent coordinate system.

	How to construct such a profile:

	struct VScnst_list	vsargs ;	< Construction args	>
	VSxsFrPlsAttr		attr ;		< Specific attributes	>
	VSxsPlateDef		plDefs[3] ;	< Plate definitions	>
	VSxsPlConn		plCnxs[2] ;	< Plate connections	>
	struct GRobj_env	CS ;		< Coordinate system	>
	struct GRvg_construct	cst ;		< Construction list	>

	attr.plCount		= plCount ;
	attr.cnxCount		= cnxCount ;
	attr.plDefs		= 3 ;
	attr.plCnxs		= 2 ;
	attr.thicknesses[0]	= "pl1" ;	< The thicknesses are	>
	attr.thicknesses[1]	= "pl2" ;	<  the part names of	>
	attr.thicknesses[2]	= "pl3" ;	<  the plates in PDM	>
	vsargs.parent_list	= &CS ;
	vsargs.parent_count	= 1 ;
	vsargs.feature_att	= (char *) &attr ;

	Fill construction list (cst.geometry is ignored) and set

	cst.class_attr		= (char *) &vsargs ;

	om$construct the profile, then send in a GRgraphivs.GRconstruct message.

	A sample filling of `plDefs' and `plCnxs' to build a I-shaped profile
	is:

	plDefs[0].length	= 3 ;
	plDefs[0].thickness	= 1 ;
	plDefs[0].type		= VS_K_HORIZONTAL ;

	plDefs[1].length	= 1 ;
	plDefs[1].thickness	= 1 ;
	plDefs[1].type		= VS_K_VERTICAL ;

	plDefs[2].length	= 3 ;
	plDefs[2].thickness	= 1 ;
	plDefs[2].type		= VS_K_HORIZONTAL ;

	<*
	 * Connect bottom side of plate #0 to top side of plate #1, offsetting
	 * plate #1 by 1 from plate #0's leftmost side.
	 *>
	plCnxs[0].plate1	= 0 ;
	plCnxs[0].plate2	= 1 ;
	plCnxs[0].side1		= VS_K_BOTTOM ;
	plCnxs[0].side2		= VS_K_TOP ;
	plCnxs[0].offset	= 1 ;

	<*
	 * Connect bottom side of plate #1 to top side of plate #2, offsetting
	 * plate #2 by -1 from plate #1's leftmost side.
	 *>
	plCnxs[1].plate1	= 1 ;
	plCnxs[1].plate2	= 2 ;
	plCnxs[1].side1		= VS_K_BOTTOM ;
	plCnxs[1].side2		= VS_K_TOP ;
	plCnxs[1].offset	= -1 ;
	
-c*/

#ifndef vssectiondef_include
#	include "vssectiondef.h"
#endif
#ifndef vsxsfrpldef_include
#	include "vsxsfrpldef.h"
#endif
#ifndef vsxsfrpl_include
#	include "vsxsfrpl.h"
#endif

instance VSproffrplts {
	/*
	 * Definition of plates in this profile.
	 * (maximum VS_K_NAX_XSPLATE #defined in "vsxsfrpl.h" )
	 */
	variable VSxsPlateDef	plateDefs[0] ;
	/*
	 * Connections between the above plates (which size of one plate stuck
	 * to which side of the other plate).
	 * (maximum VS_K_NAX_XSPLATE #defined in "vsxsfrpl.h" )
	 */
	variable VSxsPlConn	plateCnxs[0] ;
	/*
	 * Array containing the part names of the plates separated by '\0's
	 * (e.g  p,l,1,'\0',p,l,2,'\0',p,l,3,'\0')
	 */
	variable char		plateThks[0] ;
	/*
	 * Reference point of profile contour.
	 */
	variable VS2dPoint	refPoints[0] ;
} ;

override
/*+o
Message GRputattr

Abstract
	Puts data to the profile. A pointer to a variable of type `VSxsFrPlsAtt'
	(defined in "vsxsfrpl.h") must be passed.
Arguments
	See message GRputattr of class GRvg.
-o*/	
	GRputattr,

/*+o
Message GRgetattr

Abstract
	Gets data from the profile. A pointer to a variable of type
	`VSxsFrPlsAtt' (defined in "vsxsfrpl.h") must be passed.
	The array field `thicknesses' must have its elements (thicknesses[0],
	thicknesses[1], etc.) point to characted buffers allocated by the user,
	of size at least
			1 + VS_K_rdbPartNumLen, (#defined in "vsRDBdef.h" )
	same for fields `plDefs' and `plCnxs' dimensioned to
			VS_K_MAX_XSPLATES
	at least
	eg.

			char		b0[1 + VS_K_rdbPartNumLen],
					b1[1 + VS_K_rdbPartNumLen], ...
			VSxsPlateDef	p[VS_K_MAX_XSPLATES] ;
			VSxsPlConn	d[VS_K_MAX_XSPLATES] ;
			VSxsFrPlsAtt	attr ;

			attr.plDefs		= p ;
			attr.plCnxs		= d ;
			attr.thicknesses[0]	= b0 ; etc.
Arguments
	See message GRputattr of class GRvg.
-o*/	
	GRgetattr,

/*+o
Message ACfind_temp_struct

Abstract
	Overriden just to return the values of the parameters :
		- VS_K_scHeight		profile height
		- VS_K_scWidth		profile width
		- VS_K_scFlgThk		flange thickness
		- VS_K_scWebThk		web thickness
		- VS_K_scFltRad		fillet radius
	(#defined in "vssectiondef.h")
	which do not actually correspond to templates in this object (composite
	profile made from plate definitions) but do for regular profiles.
	This enables us to have a common interface disregarding the type of
	profile.
Arguments
	See message ACfind_temp_struct of class ACcpx.
-o*/
	ACfind_temp_struct,

/*+o
Message ACreturn_foot

Abstract
	Overriden so as to return the foot named
			VS_K_WoFilletCv		(without fillet)
	When asked for
			VS_K_WFilletCv		(with fillet)
	or		VS_K_SchematicCv	(schematic)
	(#defined in "vssectiondef.h")

	since this type of profile only has feet
			VS_K_WoFilletCv
	and		VS_K_EnvelopeCv		(interference envelope)
Arguments
	See message ACreturn_foot of class NDmacro.
*/
	ACreturn_foot,
	ACconstruct_feet,
	VSgetObjDef,
	NDdelete ;

end specification VSproffrplts ;
