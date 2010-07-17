/*
	I/STRUCT
*/
class specification VSstfBeam(0:0) of VSsrcBeam ;

#include "vsstfnrdef.h"
#include "vsstfnr.h"

/*+c
	Class defining a stiffener beam, ie. a source beam constrained to one
	side of a plate.

	Parent #0	: a plate
	Parent #1	: a curve (axis)
-c*/

instance VSstfBeam {
	VSstfnrFlags	flags ;
} ;

override

/*+o
Message GRconstruct

Abstract
	Stores the flag indicating which side of plate it must stick to then
	constructs self a an object of class VSsrcBeam.
Arguments
	See how a VSsrcBeam is constructed, the only difference is that the
	`feature_att' field of the VScnst_list structure points to a VSstfnrBeam
	structure which contains a VSpartAttr structure as for objects of class
	VSsrcBeam and the which-side flag :

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;	<STRUCT-specific arg list>
	VSstfnrAttr		stfnr ;
	VSbeamAttr		beam ;
	struct GRobj_env	plate ;		<Support plate of beam>
	struct GRobj_env	curve ;		<Axis of beam>
	struct GRobj_env	parents[2] ;	<List of parents>
	struct GRid		usrAttr ;	<Optional user attributes>

	Fill

	cstargs.msg,
	cstargs.display,
	cstargs.level,
	cstargs.properties
	cstargs.class_attr	= (char *) &vsargs ;

	cstargs.env_info	= <module environment of design file>
	cstargs.name		= <full name of object, NULL if unnamed>
	cstargs.geometry	= NULL ; <this field is ignored>
	cstargs.newflag		= FALSE ;
	cstargs.class_attr	= (char *) &vsargs ;

	parents[0]		= plate ;	<id and module env>
	parents[1]		= curve ;	<id and module env>
	vsargs.parent_count	= 2 ;
	vsargs.parent_list	= parents ;
	vsargs.representation	= <display representation>
	vsargs.feature_att	= (char *) &stfnr ;

	Use macro "vs$fillBeamAttr" defined in "vsbeammacros.h" to fill in
	beam-specific attributes ( `stfnr.attr' and `beam' ).

	The mandatory fields are

		`cardPnt', `symmetry', `matGrade', `matType', `partFam'
		`xsName' to construct a beam.
	
	E.g.
	vs$fillBeamAttr(	msg		= cstargs.msg,
				options		= VS_m_MatGrade
						| VS_m_MatType
						| VS_m_PartType
						| VS_m_Section
						| VS_m_cardPnt
						| VS_m_Symmetry,
				cardPnt		= VS_e_BOT_LEFT,
				symmetry	= VS_e_No_Symm,
				matType		= <material type>,
				matGrade	= <material grade>,
				partFam		= <part family>,
				xsName		= <section name>,
				partAttr	= &stfnr.attr,
				beamAttr	= &beam ) ;

	Then
		Set `stfnr.onWhichSideOfPlate' to either
			VS_K_stOnBotOfPlate
		or	VS_K_stOnTopOfPlate
-o*/
	GRconstruct,
	ACconstruct_feet,

/*+o
Message	VSgetUserEditableAttr

Abstract
	Since a stiffener is constrained to a plate side, hence cannot go
	through it, some of its degrees of freedom are suppressed.
Arguments
	See message VSgetUserEditableAttr of class VSpart.
-o*/
	VSgetUserEditableAttr,
	
/*+o
Message VSgetSupportSf

Abstract
	Returns the support surface of a stiffener, i.e. the face of the
	plate (not the plate itself !) 
Arguments
	See message VSgetSupportSf of class VSbeam.
-o*/
	VSgetSupportSf,
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
Message VSputPlateSide

Abstract
	Sets the plate side to which stiffener must stick.
Arguments
	OUT	long	*msg	Completion code.
	IN	int	side	VS_K_stOnBotOfPlate or VS_K_stOnTopOfPlate
				( #define'd in vsstfnrdef.h ).
Note
	According to the value of `side' the stiffener will used the following
	sides of its support plate :
		VS_K_stOnTopOfPlate -> VS_K_plTopSfPathABS
		VS_K_stOnBotOfPlate -> VS_K_plBotSfPathABS
	Which will be obtained from the plate via the message ACreturn_foot
	of class NDmacro.
-d*/
message VSputPlateSide( long *msg ; int side ) ;

/*+d
Message VSgetPlateSide

Abstract
	Gets the plate side to which stiffener sticks.
Arguments
	OUT	long	*msg	Completion code.
	IN	int	*p_side	The plate side.
Note
	`*p_side' is one of the following
		- VS_K_stOnBotOfPlate
		- VS_K_stOnTopOfPlate
	Both are #define'd in vsstfnrdef.h
-d*/
message VSgetPlateSide( long *msg ; int *p_side ) ;

/*+d
Message VSputConstructionType

Abstract
	Tells stiffener how to generate itself.

	VS_K_stNormalToSide :
		- normal to the side of the plate.
	VS_K_stUseSurfOfPrj :
	 	- normal to a surface of projection built on its axis here
	 	  supposed planar but not linear (otherwise same as above).

Arguments
	OUT	long	*msg	Completion code.
	IN	int	ctype	Construction type.
Note
	`ctype' is one of the following
		- VS_K_stNormalToSide
		- VS_K_stUseSurfOfPrj
	Both are #define'd in vsstfnrdef.h
-d*/
message VSputConstructionType( long *msg ; int ctype ) ;

/*+d
Message VSgetConstructionType

Abstract
	Returns the construction type of the stiffener.

Arguments
	OUT	long	*msg		Completion code.
	OUT	int	*p_ctype	Construction type.
Note
	`*p_ctype' is one of the following
		- VS_K_stNormalToSide
		- VS_K_stUseSurfOfPrj
	Both are #define'd in vsstfnrdef.h
-d*/
message VSgetConstructionType( long *msg ; int *p_ctype ) ;

/*+d
Message VSgetStiffenedPlate

Abstract
	Finds the plate stiffened by stiffener.
Arguments
	OUT	long			*msg	Completion code.
	OUT	struct GRobj_env	*plate	The stiffened plate.
-d*/
message VSgetStiffenedPlate( long *msg ; struct GRobj_env *plate ) ;

/*+d
Message VSgetPlateSurface

Abstract
	Retrieves the side surface of the plate on which stiffener lies.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		Mod. env. of stiffener.
	IN	struct GRid	*plate		Id of plate (optional).
	OUT	struct GRobj_env*surface	Surface of plate.
Note
	If `plate' is NULL, the stiffener will retrieve plate by itself.
-d*/
message VSgetPlateSurface(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRid		*plate ;
				struct GRobj_env	*surface ) ;

end specification VSstfBeam ;

