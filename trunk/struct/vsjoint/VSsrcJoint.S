/*
	I/STRUCT
*/ 
class specification VSsrcJoint(0:0) of VSjoint ;

/*+c
	Class for a source joint. A source joint a is a joint which may be acted
	upon, i.e. modified.

	Parent #0	: a beam or plate
	Parent #1	: a beam or plate

	How to construct a joint :

	struct GRvg_construct	cstargs ;	<Construction list>
	struct VScnst_list	vsargs ;	<STRUCT-specific arg list>
	VSpartAttr		part ;
	VSjointAttr		joint ;
	struct GRobj_env	feature1 ;	<1st feature of joint>
	struct GRobj_env	feature2 ;	<2nd feature of joint>
	struct GRobj_env	parents[2] ;	<List of parents>
	struct GRid		usrAttr ;	<Optional user attributes>
	Fill

	cstargs.msg,
	cstargs.display,
	cstargs.level,
	cstargs.properties

	cstargs.env_info	= <module environment of design file>
	cstargs.name		= <object's name, NULL if unnamed>
	cstargs.geometry	= NULL ; <this field is ignored>
	cstargs.newflag		= FALSE ;
	cstargs.class_attr	= (char *) &vsargs ;

	parents[0]		= feature1 ;	<id and module env>
	parents[1]		= feature2 ;	<id and module env>
	vsargs.parent_count	= 2 ;
	vsargs.parent_list	= parents ;
	vsargs.representation	= <display representation>
	vsargs.feature_att	= (char *) &part ;
	part.specific		= (void *) &joint ;
	part.Iwant		= VS_m_WeldCode ;
	joint.weldCode		= <weld code specification for joint>

	Then use

	sts = om$construct(	msg = message GRgraphics.GRconstruct( &cstarg ),
				... ) ;

	The user attributes are a collection of data created by the user which
	the joints keeps without touching or consulting them, so data may be
	added at will to a joint. The user attributes are optional, ie. one
	may decide to input none to the joint.
-c*/

override
	VSgetObjDef,
	VSgetUserEditableAttr,
/*+o
Message NDmove_to_root

Abstract
        Deletes self when either of the features goes away.
Arguments
        See message NDmove_to_root of class NDnode.
-o*/
        NDmove_to_root,


/*+o
Message GRgetattr

Abstract
	Retrieves the attributes of a joint.
Arguments
	OUT	long		*msg	Completion code.
	OUT	VSpartAttr	*attr	Joint attributes.
Note
	The attributes to be set should be specified in the "Iwant" field of
	the structure:

		attr->Iwant = VS_m_WeldCode ;

	or, if all are to be set :

		attr->Iwant = VS_m_All ;

	Then the "specific" field should point to a beam-specific data
	structure:

		VSjointAttr	joint ;

		attr->specific = (void *) &joint ;
-o*/
	GRgetattr,

/*+o
Message GRputattr

Abstract
	Put attributes to a joint.
Arguments
	OUT	long		*msg	Completion code.
	IN	VSpartAttr	*attr	Joint attributes.
Notes
	The attributes to be set should be specified in the "Iwant" field of
	the structure:

		attr->Iwant = VS_m_WeldCode ;

	or, if all are to be set :

		attr->Iwant = VS_m_All ;

	Then the "specific" field should point to a beam-specific data
	structure:

		VSjointAttr	joint ;

		attr->specific = (void *) &joint ;

	And the fields corresponding to the mask should be set.
-o*/
	GRputattr ;

end specification VSsrcJoint ;
