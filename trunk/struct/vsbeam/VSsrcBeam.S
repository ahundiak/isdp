/* $Id: VSsrcBeam.S,v 1.1.1.1 2001/01/04 21:10:12 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsbeam/VSsrcBeam.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSsrcBeam.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/10/06  09:01:12  pinnacle
# Replaced: vsbeam/VSsrcBeam.S for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 ***************************************************************************/
/*
	I/STRUCT
*/
 
class specification VSsrcBeam(0:0) of VSbeam ;

/*+c
	Class for a source beam. A source beam a is a beam which may be acted
	upon, i.e. modified.

	Parent #0	: a surface
	Parent #1	: a curve

	How to construct a beam :

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;	<STRUCT-specific arg list>
	VSpartAttr		part ;
	VSbeamAttr		beam ;
	struct GRobj_env	surface ;	<Support surface of beam>
	struct GRobj_env	curve ;		<Axis of beam>
	struct GRobj_env	parents[2] ;	<List of parents>
	struct GRid		usrAttr ;	<Optional user attributes>

	Fill

	cstargs.msg,
	cstargs.display,
	cstargs.level,
	cstargs.properties

	cstargs.env_info	= <module environment of design file>
	cstargs.name		= <full name of object, NULL if unnamed>
	cstargs.geometry	= NULL ; <this field is ignored>
	cstargs.newflag		= FALSE ;
	cstargs.class_attr	= (char *) &vsargs ;

	parents[0]		= surface ;	<id and module env>
	parents[1]		= curve ;	<id and module env>
	vsargs.parent_count	= 2 ;
	vsargs.parent_list	= parents ;
	vsargs.representation	= <display representation>
	vsargs.feature_att	= (char *) &part ;

	Use macro "vs$fillBeamAttr" defined in "vsbeammacros.h" to fill in
	beam-specific attributes ( `part' and `beam' ).

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
				partAttr	= &part,
				beamAttr	= &beam ) ;

	Then use

	sts = om$construct(	msg = message GRvg.GRconstruct( &cstarg ),
				... ) ;

	The user attributes are a collection of data created by the user which
	the beam keeps without touching or consulting them, so data may be
	added at will to a beam. The user attributes are optional, i.e. one
	may decide to input none to the beam.
-c*/

override
	ACconstruct_feet,
	VSsetOrientation,
	VSgetOrientation,
	VShasOrientation,
	VSgetObjDef,
	VSgetUserEditableAttr,
	
/*+o
Message NDmove_to_root

Abstract
	Deletes self when either support surface or axis goes away.
Arguments
	See message NDmove_to_root of class NDnode.
-o*/
	NDmove_to_root,

/*+o
Message GRgetattr

Abstract
	Retrieves the attributes of a beam.
Arguments
	OUT	long		*msg	Completion code.
	OUT	VSpartAttr	*attr	Beam attributes.
Note
	The attributes to be set should be specified in the "Iwant" field of
	the structure:

		attr->Iwant = VS_m_MatGrade | VS_m_Mto | VS_m_Section ;

	or, if all are to be set :

		attr->Iwant = VS_m_All ;

	Then the "specific" field should point to a beam-specific data
	structure:

		VSbeamAttr	beam ;

		attr->specific = (void *) &beam ;
-o*/
	GRgetattr,

/*+o
Message GRputattr

Abstract
	Put attributes to a beam.
Arguments
	OUT	long		*msg	Completion code.
	IN	VSpartAttr	*attr	Beam attributes.
Notes
	The attributes to be set should be specified in the "Iwant" field of
	the structure:

		attr->Iwant = VS_m_MatGrade | VS_m_Mto | VS_m_Section ;

	or, if all are to be set :

		attr->Iwant = VS_m_All ;

	Then the "specific" field should point to a beam-specific data
	structure:

		VSbeamAttr	beam ;

		attr->specific = (void *) &beam ;

	And the fields corresponding to the mask should be set.
-o*/
	GRputattr,

/*+o
Message VDget_trans_table_entries

Abstract
	Returns the surface support as main root and 'beam' as command name.
Arguments
	See message VDget_trans_table_entries of class VDSroot.
-o*/
	VDget_trans_table_entries,


/*+o
Message VSgetsolidbeam

Abstract
	Constructs the solid beam in filleted representation. If fails in
	filleted representation then constructs the beam in 3D rep.
	The message must sent to an already existing beam for getting its
	solid in filleted representation.

	The caller must delete the solidBeam once its use is completed.
	See message VSgetSolidBeam of class VSbeam.
-o*/

	VSgetSolidBeam,

/*+o
Message VSgetSupportAxis

Abstract
	Returns the axis with which the beam was built.
Arguments
	See message VSgetSupportAxis of class VSbeam.
-o*/
	VSgetSupportAxis,
	
/*+o
Message VSgetSupportSf

Abstract
	Returns the surface with which the beam was built.
Arguments
	See message VSgetSupportSf of class VSbeam.
-o*/
	VSgetSupportSf ;
	
/*+d
Message VScnst_line_rep

Abstract
	Constructs the linear representation of a beam.
Arguments
        OUT     long			*msg		Completion code.
        IN	struct GRmd_env		*my_env		My module environment.
        IN      struct GRobj_env	supports[2]	Template graphics.
        IN      struct GRvg_construct	*cst		Construction list.
        IN	struct GRid		*xsect		Cross-section.
	OUT	struct GRid		*linearRep	Linear rep. object.
-d*/
message VScnst_line_rep(	long			*msg ;
				struct GRmd_env		*my_env ;
				struct GRobj_env	supports[2] ;
				struct GRvg_construct	*cst ;
				struct GRid		*xsect ;
				struct GRid		*linearRep ) ;

/*+d
Message VScnst_solid_rep

Abstract
	Called within ACconstruct_feet method.
	Constructs the "solid" representation of a beam.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env		*my_env		My module environment.
	IN	struct GRvg_construct	*cst		Construction list.
	IN	struct GRobj_env	*surface	Support surface.
	IN	struct GRobj_env	*axis		Axis of beam.
	IN	struct GRid		*xsec		Section.
	OUT	struct GRid		*solidRep	Solid rep. object.
-d*/
message VScnst_solid_rep(	long			*msg ;
				struct GRmd_env		*my_env ;
				struct GRvg_construct	*cst ;
				struct GRobj_env	*surface,
							*axis ;
				struct GRid		*xsec ;
				struct GRid		*solidRep ) ;

end specification VSsrcBeam ;

