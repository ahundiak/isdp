/*
	I/STRUCT
*/
class specification VSsrcPlate(0:0) of VSplate ;

/*+c
	Class for a source plate. A source plate a is a plate which may be
	acted upon, i.e. modified.

	Parent #0	: a surface

	How to construct a plate :

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;	<STRUCT-specific arg list>
	VSpartAttr		part ;
	VSplateAttr		plate ;
	struct GRobj_env	surface ;	<Support surface of plate>
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
	cstargs.class_attr	= (char *)  &vsargs ;

	vsargs.parent_count	= 1 ;
	vsargs.parent_list	= &surface ; <id and module env>
	vsargs.representation	= <display representation>
	vsargs.feature_att	= (char *) &part ;

	Use macro "vs$fillPlateAttr" defined in "vsplatmacros.h" to fill in
	plate-specific attributes ( `part' and `plate' ).

	The mandatory fields are

		`matGrade', `matType', `partFam', `thkName', `thickness',
		`orientation' to construct a plate.

	E.g.
	vs$fillPlateAttr(	msg		= cstargs.msg,
				options		= VS_m_MatGrade
						| VS_m_MatType
						| VS_m_PartType
						| VS_m_ThicknessName,
						| VS_m_Thickness
						| VS_m_Orientation,
				matType		= <material type>,
				matGrade	= <material grade>,
				partFam		= <part family>,
				thkName		= <thickness name>,
				orientation	= <orientation>,
				partAttr	= &part,
				plateAttr	= &plate ) ;

	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
				... ) ;

	The user attributes are a collection of data created by the user which
	the plate keeps without touching or consulting them, so data may be
	added at will to a plate. The user attributes are optional, ie. one
	may decide to input none to the plate.
-c*/
 
override

/*+o
Message NDmove_to_root

Abstract
	Deletes self when support parent is lost.
Arguments
	See message "NDmove_to_root" of class "NDnode".
-o*/
	NDmove_to_root,
	ACconstruct_feet,
	VSgetObjDef,
	VSgetUserEditableAttr,

/*+o
Message GRgetattr

Abstract
	Retrieves the attributes of a plate.
Arguments
	OUT	long		*msg		Completion code.
	OUT	VSpartAttr	*attr		Plate attributes.
Note
	The attributes to be set should be specified in the "Iwant" field of
	the structure:

		attr->Iwant = VS_m_MatGrade | VS_m_Mto | VS_m_Thickness ;

	or, if all are to be set :

		attr->Iwant = VS_m_All ;

	Then the "specific" field should point to a plate-specific data
	structure:

		VSplateAttr	plate ;

		attr->specific = (void *) &plate ;

	And the fields corresponding to the mask should be set.
-o*/
	GRgetattr,

/*+o
Message GRputattr

Abstract
	Put attributes to a plate.
Arguments
	OUT	long		*msg		Completion code.
	IN	VSpartAttr	*attr		Plate attributes.
Notes
	The attributes to be set should be specified in the "Iwant" field of
	the structure:

		attr->Iwant = VS_m_MatGrade | VS_m_Mto | VS_m_Thickness ;

	or, if all are to be set :

		attr->Iwant = VS_m_All ;

	Then the "specific" field should point to a plate-specific data
	structure:

		VSplateAttr	plate ;

		attr->specific = (void *) &plate ;

	And the fields corresponding to the mask should be set.
-o*/
	GRputattr,

/*+o
Message VSgetSupports

Abstract
	Finds the support of a plate, i.e. the surface which is the template
	of the uppermost plate in a plate hierarchy.
Arguments
	See message VSgetSupports of class VSpart.
Note
	Support #0 : surface
-o*/
	VSgetSupports,
	
/*+o
Message VDget_trans_table_entries

Abstract
	Returns the surface support as main root and 'plate' as command name.
Arguments
	See message VDget_trans_table_entries of class VDSroot.
-o*/
	VDget_trans_table_entries ;

end specification VSsrcPlate ;

