/* $Id: VSfeature.S,v 1.2 2001/01/17 23:06:18 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsfeature/VSfeature.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSfeature.S,v $
 *	Revision 1.2  2001/01/17 23:06:18  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:10:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.6  1998/04/20  14:23:02  pinnacle
# TR179801020
#
# Revision 1.5  1998/01/07  09:30:20  pinnacle
# Replaced: vsfeature/VSfeature.S for:  by svkadamb for struct
#
# Revision 1.4  1998/01/07  08:01:10  pinnacle
# Replaced: vsfeature/VSfeature.S for:  by svkadamb for struct
#
# Revision 1.3  1997/12/15  22:24:46  pinnacle
# VDprocAttr
#
# Revision 1.2  1997/11/14  12:49:00  pinnacle
# Replaced: vsfeature/VSfeature.S for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 *	12/14/97	ah		Added override of VDSroot.VDprocAttr
 *	01/06/98        suresh          added method VSfwdTosource which checks
 *					for return code.
 *	04/20/98        ah		TR179801020 Moved VDgetCenterLine to here from
 *                                      VSbeam since VSsubBeam was not getting the message
 ***************************************************************************/
/*
	I/STRUCT
*/
class specification VSfeature(0:3) of VScpx, VSpart ;

/*+c
	Abstract class defining the behaviors of structural parts as well
	as the protocols ruling the modifications of those structural parts.
	A modification is viewed as an OPERATION, the part which is modified
	is the OPERAND, the other objects symbolizing the tools performing
	the operation are the OPERATORS, the modified part is the RESULT.
-c*/

instance VSfeature {
	char	*fastPtr ;
	int	ConsumedRep ;
} ;

from VScpx inherit delete ;

override  GRget_siblings ;

override  VDGetCenterLine;

override
	VDprocAttr,
	VDSgetUsrAttributes,
	VDSmodUsrAttributes,
/*+o
Message dump

Abstract
	Overriden so that directory forms displays members of the visible
	feature, not those of the feature bearing the name.
Arguments
	See message dump of class IGRdir.
-o*/
	dump,

/*+o
Message DIgive_output

Abstract
	Displays the nature of this object in the "Directory Commands" form.
Arguments
	See message dump of class ACncpx.
-o*/
	DIgive_output,

/*+o
Message GRget_locate_properties

Abstract
	Do not allow write-locate on consumed elements.
Arguments
	See message GRget_locate_properties of class GRowner.
-o*/
	GRget_locate_properties,

/*+o
Message GRdrop

Abstract
	Disconnects graphic components from self, the deletes self.
Arguments
	See message dump of class GRowner.
-o*/
	GRdrop,

/*+o
Message GRgetobjinfo

Abstract
	Returns its part type and well as its display representation.
	For a RESULT part, the type is the same as that of the OPERAND part.
Arguments
	See message GRgetobjinfo of class GRgraphics.
-o*/
	 GRgetobjinfo,

/*+o
Message GRconstruct

Absttract
	At this level, this method is implemented as:
		VScpx.VSpre_construct	sent to self
		VSpart.VSput_part_attr	sent to self
	then	VScpx.VSevaluate	sent to self

Note
	The `class_attr' field of the construction list should contain a
	pointer to a `struct VScnst_list'. The `feature_att' field of this
	struct should contain the address of a part-related structure.
	(See GRvg.S for further details on GRconstruct)

	If the `newflag' field is set to TRUE, the object will not get a 
	compute message. Hence `newflag' should always be set to FALSE,
	except when the object is to receive an additional compute right
	after being constructed. This allows to save one compute message.

	The objects deletes itself if the construction failed.
Arguments
	See message GRconstruct of class GRvg.
-o*/
	GRconstruct,

/*+o
Message GRlocate

Abstract
	Overriden to support locate-by-name: if a feature bears a name but is
	consumed (modified), it has no visible graphics, since it has been
	replaced by a consumer. This message forwards the GRlocate message
	to the consumer which is the one the user expects.
Arguments
	See message GRlocate of class GRgraphics.
-o*/
	GRlocate,

/*+o
Message GRcopy

Abstract
	Does not allow copying if feature is not an original source feature
	(ie. does not consume its parents). Copying a consuming object would
	cause the copy to try to consume the same parent as the copied object,
	thus causing conflicts.
Arguments
	See message GRcopy of class GRgraphics.
-o*/
	GRcopy,

/*+o
Message NDcopy

Abstract
	None.
Arguments
	See message NDcopy of class NDnode.
-o*/
	NDcopy,

/*+o
Message NDcopy_to_root

Abstract
	Creates a frozen (uneditable) copy of object.
Arguments
	See message NDcopy_to_root of class NDnode.
-o*/
	NDcopy_to_root,

/*+o
Message NDdrawing_copy_geom

Abstract
	Runs a use-defined file for drawing extraction of the element.
Arguments
	See message NDdrawing_copy_geom of class NDnode.
-o*/
	NDdrawing_copy_geom,

/*+o
Message ACbecome_macro

Abstract
	Decides upon entering a macro definition in which mode macro occurrences
	will be placed.
Arguments
	See message ACbecome_macro of class NDmacro.
-o*/
	ACbecome_macro,

/*+o
Message ACgive_structure

Abstract
	Queries the object for data to feed the Relational Data Base in
	connection with I/STRUCT.

	This method recognizes pseudo-feet common to all parts.
Arguments
	See message ACgive_structure of class NDmacro.
-o*/
	ACgive_structure,

/*+o
Message GRputname

Abstract
	If element has a name but does not store it, ie. uses the name of
	another consumed element, then puts name to the element actually
	bearing the name, else puts it to self.
Arguments
	See message GRputname of class GRvg.
Note
	If `my_name' is NULL or `*my_name' is '\0', this method does nothing
	and completes with success.
-o*/
	GRputname,

/*+o
Message GRchgname

Abstract
	Renames a structural element.

	- Rename logic :

	new name\old name	|	none	| some name
	------------------------+---------------+----------
		none		|	add	| add
		some name	|	rem	| chg

	add = add name
	chg = change name
	rem = remove name

	new name = none means `my_name' is NULL or `*my_name' is '\0'.
Arguments
	See message GRchgname of class GRvg.
-o*/
	GRchgname,

/*+o
Message GRgetname

Abstract
	If element has a name but does not store it, ie. uses the name of
	another consumed element, then retrieves this name, else uses its own
	if it has one.
Arguments
	See message GRgetname of class GRvg.
-o*/
	GRgetname,

/*+o
Message ACreturn_foot

Abstract
	In addition to indexing into feet of features, manages deeper indexing
	into the components of the solid output to access the faces.
Arguments
	See message ACreturn_foot of class NDmacro.
-o*/ 
	ACreturn_foot,

/*+o
Message ACgive_path

Abstract
	Creates a path down to the faces of a solid output if requested, trying
	to give them a meaningful name.
Arguments
	See message ACgive_path of class NDmacro.
-o*/ 
	ACgive_path,

/*+o
Message ACset_db_info

Abstract
	If consumed, forwards message to the source element, which will store
	the information in its instance data.
Arguments
	See message ACset_db_info of class ACncpx.
-o*/
	ACset_db_info,

/*+o
Message ACget_db_info

Abstract
	If consumed, forwards message to the source element, which will return
	the info in its instance data.
Arguments
	See message ACget_db_info of class ACncpx.
-o*/
	ACget_db_info,

/*+o
Message ACcheckin_candidate

Abstract
	Do not register for checkin if consumed.
Arguments
	See messages ACcheckin_candidate of class ACdb_info.
-o*/
	ACcheckin_candidate,
	ACadd_to_list_1,

/*+o
Message VDget_trans_table_entries

Abstract
	Forwards message to original feature.
Arguments
	See message VDget_trans_table_entries of class VDSroot.
-o*/
	VDget_trans_table_entries ;

/*+d
Message VSregenerate

Abstract
	Provokes the recomputation of an element. This element may be the result
	of several consumptions. Upon reception of this message, the target will
	forward the recompute order to the element high up in the hierarchy
	which is eligible for initiating a recompute.
	If target is eligible itself, it will then recompute.
Arguments
	None.
-d*/
message VSregenerate() ;

/*+d
Message VSsendToEveryoneUp

Abstract
	Used by consumed elements. Sends message to self and everyone up in the
	consumed hierarchy till a source element is found an then sending stops.
Arguments
	OUT	long			*msg		Completion code,
	IN	enum OM_e_wrt_flag	deliver		How message must be
							delivered.
	IN	OM_p_MESSAGE		Message		OM message to forward.
Note
	It is supposed that the source may be reached by successively exploring 
	parents in position 0.
-d*/
message VSsendToEveryoneUp(	long			*msg ;
				enum OM_e_wrt_flag	deliver ;
				OM_p_MESSAGE		Message ) ;

/*+d
Message VSforwardToSource

Abstract
	Bubbles up message to the first source element encountered in the
	hierarchy.
Arguments
	OUT	long			*msg	Completion code.
	IN	enum OM_e_wrt_flag	deliver How message is to be delivered.
	IN	OM_p_MESSAGE		Message	Message to forward.
Note
	It is supposed that the consumed parents are always at slot 0.
-d*/
message VSforwardToSource(	long			*msg ;
				enum OM_e_wrt_flag	deliver ;
				OM_p_MESSAGE		Message ) ;

/*+d
Message VSfwdToSource

Abstract
	Bubbles up message to the first source element encountered in the
	hierarchy.
Arguments
	OUT	long			*msg	Completion code.
	IN	enum OM_e_wrt_flag	deliver How message is to be delivered.
	IN	OM_p_MESSAGE		Message	Message to forward.
Note
	It is supposed that the consumed parents are always at slot 0.
	It checks for the proper return code and sets it. The caller need to
	check the RC after its call.
-d*/
message VSfwdToSource(		long			*msg ;
				enum OM_e_wrt_flag	deliver ;
				OM_p_MESSAGE		Message ) ;
/*+d
Message VSforwardToOriginal

Abstract
	Bubbles up message to the original element (the source one which is the
	beginning of the operation history) encountered in the hierarchy.
	The difference with VSforwardToSource is that VSforwardToSource will
	stop at a sub-feature which almost behaves as a source feature, whereas
	this message will continue up to the source feature which is not a
	sub-feature.
Arguments
	OUT	long			*msg	Completion code.
	IN	enum OM_e_wrt_flag	deliver How message is to be delivered.
	IN	OM_p_MESSAGE		Message	Message to forward.
Note
	It is supposed that the consumed parents are always at slot 0.
-d*/
message VSforwardToOriginal(	long			*msg ;
				enum OM_e_wrt_flag	deliver ;
				OM_p_MESSAGE		Message ) ;

/*+d
Message VSchildDeleted

Abstract
	Used by consumed elements. They receive this message when a sub-element
	is going away, so they may reorganize themselves.
Arguments
	OUT	long		*msg		Completion code.
	IN	OM_S_OBJID	his_id		Object id of deleted child.
	IN	OMuword		his_os		Object space number of child.
	IN	struct GRmd_env	*hid_env	Module environment of child.
-d*/

message VSchildDeleted(	long		*msg ;
			OM_S_OBJID	his_id ;
			OMuword		his_os ;
			struct GRmd_env	*his_env ) ;

/*+d
Message VSdelete

Abstract
	The following message is to be sent to self in NDnode.NDdelete when
	one wishes the following behavior:

	If feature has no parents, then they have just been disconnected from
	feature by the move-to-root operation, else it is a casual delete; the
	behaviour in that latter case is to propagate the deletion up through
	the feature parents which have been consumed.

	This message is for features which are organized in a hierarchy with
	feature #i+1 having consumed feature #i. All are an altered image
	of the uppermost parent feature (the "source" feature):

			source feature
				|
			alt. feature #0 - other parents
				|
			       ...
			alt. feature #i - other parents
			       ...
			        |
			alt. feature #n - other parents

	All the other parents are supposed to be of the same class.

	This message works in conjunction with VSfeature.VSmove_to_root to
	have the following effects:

		- If feature #i loses one "other parent" then
			if it has no "other parents" but feature #i-1
				then it disappears of the hierachy
					( feature #i+1 connected to #i-1 ).
					The hierarchy gets recomputed.
				else it recomputes itself to fill the hole
					left by the suppression of the lost
					"other parent", the recomputation
					is propagated downwards.

		- If feature #n loses one "other parent" then
			as for #i

		- If feature #n gets deleted then all features from n-1
		  to 0 get deleted, as well as the source object.

Arguments
	-- Same as NDnode.NDdelete --
Note
	It is assumed that
		- the consumed parent of a feature is parent #0
		- the consumed output of parent #0 is output #0

	This message is of no use, even dangerous for features which do not
	wish that behavior and in that case may be rejected.
-d*/
message	VSdelete( struct GRmd_env *myEnv ) ;

/*+d
Message VSmove_to_root

Abstract
	The following message is to be sent to self in NDnode.NDmove_to_root
	when one wishes to have the behavior defined in the abstract of
	VSfeature.VSdelete.

	The same conditions and restrictions apply as for VSfeature.VSdelete.
Arguments
	-- Same as NDnode.NDmove_to_root --
-d*/
message	VSmove_to_root(	long		*msg ;
			struct GRid	*src ;
			struct GRmd_env	*myEnv ; ) ;

/*+d
Message VSparentsDeleted

Abstract
	The following message is to be sent to self in NDnode.NDparent_deleted
	when one wishes to have the behavior defined in the abstract of
	VSfeature.VSdelete.

	The same conditions and restrictions apply as for VSfeature.VSdelete.
Arguments
	-- Same as NDnode.NDparent_deleted --

-d*/
message VSparentsDeleted(	long		*msg ;
				int		deletedCount ;
				struct GRid	deletedList[] ; 
				struct GRid	*newObj ;
				struct GRmd_env *myEnv ) ;

/*+d
Message VScopy_to_root

Abstract
	This message will be sent to self in the NDnode.NDmove_to_root method
	by those objects which also use VSfeature.VSmove_to_root.

Arguments
	-- Same as NDnode.NDcopy_to_root --
-d*/
message VScopy_to_root(	long		*msg ;
			int		cp_type ;
			struct GRmd_env	*myEnv,
					*rootEnv ;
			struct GRid	*rootId ; ) ;

/*+d
Message VSisOriginal

Abstract
	A condition message for bubbling-up action through the history.
	Queries the object if it is original, ie. a source element which is not
	a sub-element. According to the input flag `sendToNonOrig', each object
	receiving this message which is not an original will either return
	OM_S_SUCCESS (send me action message and pass up) or OM_W_ABORT
	(don't send me action message but pass up).
Arguments
	IN	int	sendToNonOrig	TRUE/FALSE.
	IN	int	OMmsgType	Type of the bubbling-up action message
					(#defined in vsdef.h)
-d*/
message VSisOriginal( int sendToNonOrig, OMmsgType ) ;

/*+d
Message VSgetOperation

Abstract
	Queries an element for the operation it represents (notching, splitting,
	marking, etc.)
Arguments
	OUT	long		*msg		Completion code.
	OUT	VSopHistory	*history	Operation Description.
Note
	This message in an internal message
-d*/
message VSgetOperation(	long		*msg ;
			VSopHistory	*history ) ;

/*+d
Message VSgetOperators

Abstract
	Queries element which is the result of an operation for the operators.
Arguments
	OUT	long		*msg		Completion code.
	OUT	int		*opCount	Count of operators.
	OUT	VSoperator	**p_opList	List of operators.
Note
	`*p_opPlist' must be released with :
			if( *p_opPlist ) free( *p_opPlist ) ;
-d*/
message VSgetOperators(	long		*msg ;
			int		*opCount ;
			VSoperator	**p_opList ) ;

/*+d
Message VSgetOperationHistory

Abstract
	Returns the operational history of an element, ie. all operations and
	operators since the original element.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		Module environment of element.
	OUT	VSopHistory	**p_history	History of element (linked list).
Note
	`*p_history' must be released with :
			VSfreeOpHistory( *p_history ) ;
-d*/
message VSgetOperationHistory(	long		*msg ;
				struct GRmd_env	*myEnv ;
				VSopHistory	**p_history ; ) ;

/*+d
Message	VSgetResultType

Abstract
	Returns the type of an element as the result of an operation.
Arguments
	OUT	long		*msg		Completion code.
	OUT	unsigned long	*result		Type of operation ( VS_m_...,
						#defined in vsdef.h ).
-d*/
message VSgetResultType( long *msg ; unsigned long *result ) ;

/*+d
Message VSputConsumedRep

Abstract
	Tells object what representation it will have to generate when it
	recomputes to be used by consuming child.
Argument
	IN	VSdspRep	rep		Representation.
-d*/
message VSputConsumedRep( VSdspRep rep ) ;

/*+d
Message VSgetConsumedRep

Abstract
	Gets consumed representation from object.
Argument
	OUT	VSdspRep	*rep		Representation.
-d*/
message VSgetConsumedRep( VSdspRep *rep ) ;

/*+d
Message VSgetOperationMgr

Abstract
	Returns the id of the object managing the operation of which the object
	target of the message is the result; it may be the target itself.
Arguments
	OUT	long		*msg	Completion code.
	OUT	struct GRid	*opMgr	Id of manager.
Notes
	This message is useful when an "undo" must be performed since the undo
	message must be sent to the operation manager.
-d*/
message VSgetOperationMgr(	long		*msg ;
				struct GRid	*opMgr ) ;

/*+d
Message VSgetVisibleObjByName

Abstract
	Support message for locate by name. If feature is consumed one or
	several times, hence invisible, finds the feature at the bottom of
	the history which represents it (and is visible).
Arguments
	OUT	long		*msg		Completion code.
	IN	GRname		name		Name of target of message.
	OUT	struct GRid	*visibleId	Id of visible object.
Note
	`visibleId->objid' is NULL_OBJID if `name' does not correspond to
	feature.
-d*/
	
message VSgetVisibleObjByName(	long		*msg ;
				GRname		name ;
				struct GRid	*visibleId ) ;

/*+d
Message VSputUsrAttributes

Abstract
	Puts a collection of user attributes to object.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*UsrAttr	Id of collection.
Note
	This message is internal: the user-attribute collection should be put
	via the message GRputattr.
-d*/
message VSputUsrAttributes( long *msg ; struct GRid *UsrAttr ) ;

/*+d
Message VSgetUsrAttributes

Abstract
	Gets the object's collection of user attributes.
Arguments
	OUT	long		*msg		Completion code.
	OUT	struct GRid	*p_UsrAttr	Id of collection.
Note
	If object has no collection of user attributes, the message returns
	success and `p_UsrAttr' is set to NULL_OBJID.
	This message is internal: the user-attribute collection should be gotten
	via the message GRgetattr. In any case, it must be used by strangers
	for READ-ONLY purposes.
-d*/
message VSgetUsrAttributes( long *msg ; struct GRid *p_UsrAttr ) ;


/*+d
Message VSmodUsrAttributes

Abstract
	Given a list of user attributes (their names + their values) adds them
	to the target object or modifies them if they already exist or deletes
	them if their name is preceded by '!' (in this case the value is not
	requested and may be NULL).
Arguments
	OUT	long		*msg		Completion code.
	IN	int		nbAttrs		Number of attributes to add.
	IN	char		*attrNames[]	Names of the attributes.
	IN	char		*attrValues[]	Values of the attributes.
-d*/
message VSmodUsrAttributes(	long		*msg ;
				int		nbAttrs ;
				char		*attrNames[],
						*attrValues[] ) ;
/*+d
Message VSgetConsumedParent

Abstract
	Returns the object id and the module environment of the parent which
	object is consuming if any. This messages takes into account the fact
	that the consumed parent may be embedded in an assembly (macro) - in
	this case its real parent is a pretend object - and finds the object
	represented (pointed to) by the pretend.
Arguments
	OUT	long		*msg		Completion code.
	OUT	struct GRid	*consumedParent	Id of consumed parent.
	OUT	struct GRmd_env	*consumedEnv	Env. of consumed parent.
						(optional)
Note
	`consumedEnv' may be NULL.
-d*/
message VSgetConsumedParent(	long		*msg ;
				struct GRid	*consumedParent ;
				struct GRmd_env	*consumedEnv ) ;

/*+d
Message VSgetVisDivRes

Abstract
	Returns all the visible sub-features of a feature. If feature has not
	been divided, then returns the visible feature representing the target
	of this message.
Arguments
	OUT	long		*msg		Completion code.
	OUT	int		*count		Of visible sub-features.
	OUT	struct GRid	**divList	List of visible sub-features.
Note
	`*divList' is malloc'ed, it is up to the caller to free it.
-d*/
message VSgetVisDivRes(	long		*msg ;
			int		*count ;
			struct GRid	**divList ) ;

/*+d
Message VS__getVisDivRes

Abstract
	Internal message to support VSgetVisDivRes. Returns all the visible
	sub-features of a feature. If feature has not been divided, then
	returns the visible feature representing the target of this message.
Arguments
	OUT	long		*msg		Completion code.
	OUT	int		*count		Of visible sub-features.
	OUT	struct GRid	*divList	List of visible sub-features.
						(may be NULL).
Note
	If `divList' is NULL, only the count is returned. `*count' must be set
	to `0' before sending this message since it will be recursively sent.
-d*/
message VS__getVisDivRes(	long		*msg ;
				int		*count ;
				struct GRid	*divList ) ;

/*+d
Message VSisChildConsumingMe

Abstract
	Finds whether input child is consuming me.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*child		One of my children.
	OUT	int		*consuming	TRUE/FALSE.
	OUT	struct GRid	*virtualChild	Virtual child.
Note
	This message assumes
		1) That `*child' is really one of my children.
		2) That I am consumed.
	Erroneous results may be returned if 1) and 2) are not satisfied.

	In case when the real child is an ACpretend or ACpretendin,
	`*virtualChild' is different from `*child' and is the object actually
	consuming; otherwise `*virtualChild' is `*child'.
-d*/
message VSisChildConsumingMe(	long		*msg ;
				struct GRid	*child ;
				int		*consuming ;
				struct GRid	*virtualChild ) ;

/*+d
Message VScreateFrozenCopy

Abstract
	Creates a `frozen' ie. support-less, uneditable, unmodifable copy of
	yourself.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		My module environment.
	IN	struct GRmd_env	*cpyEnv		Module environment of copy.
	OUT	struct GRid	*copy		Id of frozen copy.
-d*/
message VScreateFrozenCopy(	long		*msg ;
				struct GRmd_env	*myEnv,
						*cpyEnv ;
				struct GRid	*copy ) ;

/*+d
Message VSputJoint

Abstract
	Puts a joint between two features.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		
	IN	struct GRobj_env
				*otherFeature	The one I'm joined with.
	IN	struct GRobj_env
				*jnCurve	Joint geometry give directly
	IN	VSdspRep	jointRep	Display rep. for the joint.
	IN	struct GRvg_construct
				*cst		Construction list for the joint.
	IN	char		*dir		Directory where joint will name
						itself (may be NULL).
	OUT	struct GRid	*joint		Constructed joint.
Note
	`cst->geometry' can be NULL (unused).
	The `class_attr' field of `cst' must point to a variable of type
	`VSpartAttr' appropriately filled, eg.

	VSpartAttr	attr ;
	VSjointAttr	jnt ;

	jnt.weldCode	= <some weld specification code>
	attr.Iwant	= VS_m_WeldCode ;
	attr.specific	= (void *) &jnt ;
	cst.class_attr	= (char *) &attr ;
-d*/
message VSputJoint(	long			*msg ;
			struct GRmd_env		*myEnv ;
			struct GRobj_env	*otherFeature ;
			struct GRobj_env	*jnCurve ;
			VSdspRep		jointRep ;
			struct GRvg_construct	*cst ;
			char			*dir ;
			struct GRid		*joint ) ;

/*+d
Message VSgetJoints

Abstract
	Returns the list of joints between a feature and other features.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		My module environment.
	OUT	int		*count		Count of joints.
	OUT	VSjointList	**jList		List of joints and other
						features.
Note
	`*jList' is malloc'ed, it is up to the caller to free it with

			if( *jList ) free( *jList ) ;
-d*/
message VSgetJoints(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		*count ;
			VSjointList	**jList ) ;

/*+d
Message VSputModJoints

Abstract
	If a feature having joints with others is modified, its joints must
	be updated so as to reflect the possible topology changes; which
	is done by sending to the modified feature (the result of the
	operation) this message with the list of the joints of the feature
	before the operation (the operand).
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		My module environment.
	IN	int		count		Count of joints.
	IN	VSjointList	jList[]		List of joints between operand
						and other features.
-d*/
message VSputModJoints(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		count ;
			VSjointList	jList[] ) ;

/*+d
Message VSputSubJoints

Abstract
	If a feature having joints with others is divided, its joints must
	be updated so as to reflect the possible topology changes; which
	is done by sending to the divided feature (the result of the operation)
	this message with the list of the joints of the feature before the
	operation (the operand).
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		My module environment.
	IN	char		*dir		Directory where sub-joints will
						name themselves (may be NULL).
	IN	int		count		Count of joints.
	IN	VSjointList	jList[]		List of joints beween operand
						and other features.
-d*/
message VSputDivJoints(	long		*msg ;
			struct GRmd_env	*myEnv ;
			char		*dir ;
			int		count ;
			VSjointList	jList[] ) ;

/*+d
Message VSfindCollection

Abstract
	Retrieves a collection associated with the object. There is always one
	or two collections associated with a VSfeature:
		- private attributes		Name: VS_K_prPrvAttr
		- user attributes (optional)	Name: VS_K_prUsrAttr
Arguments
	OUT	long		*msg	Completion code (failure if !found).
	IN	char		*name	Name of collection.
	OUT	struct GRid	*coll	Id of collection.
-d*/
message VSfindCollection( long *msg ; char *name ; struct GRid *coll ) ;

/*+d
Message VSgetSupportedElements

Abstract
	Returns the elements that this object supports. Eg. for a plate
	returns the list of stiffeners of which plate is the support (ie.
	the stiffeners stiffening this very plate).
Arguments
	long		*msg		Completion code.
	int		wantVisibleOnes	Want visible elements (TRUE/FALSE).
	int		*count		Count of elements found.
	struct GRid	**list		List of elements found (optional).
Note
	a) `list' may be NULL if the ids of the elements are not wanted.
	   If not NULL it is up to the caller to free `*list' with :
	   	if( *list ) free( (char *) *list ) ;

	b) `wantVisibleOnes' allows either to have the elements which are
	    direct children of the plate or those which consumes those
	    elements and are visible.

	    Example:

	    Suppose the plate was parent of a stiffener S1, which has been split
	    into S2 and S3 :
	    	- S1 is the direct child of the plate.
	    	- it is no longer visible since it has been replaced by S2
	    	  and S3.
	    	- S2 and S3 are visible.

	    If `wantVisibleOnes' is FALSE, `*count' will be 1 and `*list'
	    (if `list' is not NULL) will contain the id of S1.
	    If `wantVisibleOnes' is TRUE , `*count' will be 2 and `*list'
	    (if `list' is not NULL) will contain the ids of S2 and S3.
-d*/
message VSgetSupportedElements(	long		*msg ;
				int		wantVisibleOnes,
						*count ;
				struct GRid	**list ) ;
reject VSgetSupportedElements ;

message NDgetHeaderClassid( OMuword *headerClassid ) ;

/*+d
Message VSgetNormalOfComponent

Abstract
	Returns the normal of a component of a structural element which is
	a surface at the given parameters.
Arguments
	IN	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		Mod. env. of element.
	IN	char*		pathName	Name of component in element.
	IN	double		U		U-parameter on surface.
	IN	double		V		V-parameter on surface.
	OUT	IGRvector	normal		Normal to surface at (U,V).
-d*/
message VSgetNormalOfComponent(	long		*msg ;
				struct GRmd_env	*myEnv ;
				char*		pathName ;
				double		U,
						V ;
				IGRvector	normal ) ;

/*+d
Message VSexecuteFunctionInFuture

Abstract
	Starting at the target structural element, this message explores its
	dependency in search of the elements of the same type which consume
	this element (its "future") and so on recursively. At each step in
	the future a user-function is executed.

			      A ---
				 |
			====> B ---  
				 |
			      C ---  
				| |
			+-------+ +-------+
			|                 |
		     D ---            E  ---  
		                         | |
		                 +-------+ +-------+
		                 |                 |
		              F ---             G ---
	If this message is sent to B, then the function will be executed on
	on B, C, D, E, F, G.

Arguments
	IN	int   (*f)( const struct GRid *target,	Function to execute.
			    void*	      *args )
	IN	void  *args				Args of function.
Note
	The first argument of the function to execute is the id of the element
	in the future history and the second argument is the pointer which is
	passed to the message. If the function to execute returns FALSE then
	the broadcasting is stopped else it is carried on.

	A sample use of this message is:

	int PrintId( const struct GRid *id, void *unused ) {
		printf( "id=%d os=%d\n", is->objid, is->osnum ) ;
		return TRUE ;
	}

	sts = om$send(	msg	 = message VSfeature.VSexecuteFunctionInFuture(
								PrintId, NULL ),
			targetid = element.objid,
			targetos = element.osnum ) ;

	Given an element which is anywhere in the history, to have the function
	be executed on the whole history, do:

	sts = om$send(	msg	 = message VSfeature.VSforwardToOriginal(
				    &msg, OM_e_wrt_object,
				    message VSfeature.VSexecuteFunctionInFuture(
			                                       PrintId, NULL ),
			targetid = element.objid,
			targetos = element.osnum ) ;
-d*/
message VSexecuteFunctionInFuture( int   (*f)( const struct GRid *target,
					       void	         *args ) ;
				   void  *args ) ;

/*+d
Message VSexecuteFunctionAlongGeneration

Abstract
	Starting at the target structural element, this message explores its
	dependency in search of the descendent which is specified in the
	message.
	The user-function is executed at each step of the direct path between
	the target and its descendent (the "generation"). Optionally the
	function can further be executed on the descendent's future.

			      A ---
				 |
		target	====> B ---  
				 |
			      C ---  
				| |
			+-------+ +-------+
			|                 |
		     D ---            E  --- <=== descendent 
		                         | |
		                 +-------+ +-------+
		                 |                 |
		              F ---             G ---
	For instance ifthis message is sent to B with descendent = E, the
	function will be executed on B, C and E, If furthermore the option
	to go on is retained, the function will be executed on B, C, E, F
	and G.

Arguments
	IN	const struct GRid *descendent		Descendent to reach.
	IN	int   (*f)( const struct GRid *target,	Function to execute.
			    void*	      *args )
	IN	void  *args				Args of function.
	IN	int		  goOnAfterDescendent	TRUE/FALSE: to also
							explore descenent's
							futre.
Note
	The first argument of the function to execute is the id of the element
	in the future history and the second argument is the pointer which is
	passed to the message. If the function to execute returns FALSE then
	the broadcasting is stopped else it is carried on.

	If `descendent' is NULL, then this messages acts like message
	`VSexecuteFunctionInFuture'.

	If `*descendent' is the target of the message (i.e. the object this
	message is sent to), then the function is executed on the target
	alone `goOnAfterDescendent' is FALSE, otherwise it is the same as
	the case where `descendent' is NULL above.

	`*generation' is allocated in the method: it is up to the caller to free
	it with `free( *generation ) ;' if not NULL
-d*/
message VSexecuteFunctionAlongGeneration(
			const struct GRid  *descendent ;
			int                (*f)( const struct GRid *target,
						 void	      	   *args );
			void               *args ;
			int                goOnAfterDescendent ) ;

/*+d
Message VStrackDescendent

Abstract
	Collects the ids of the history nodes between the target and its
	descendent (including the target and the descendent).
	 
	                            |
	                          A + <- target
	                           / \
	                        B +   + C
	                         / \
	                      D +   + E
	                       / \
	                    F +   + G <- descendent
	  
	   The list returned will be A, B, D, G

Arguments
	IN	const struct GRid	*descendent	Descendent to reach.
	OUT   				*size		Number of nodes between
							target and descendent.
	OUT	struct GRid		**generation	List of nodes.
Note
	`*generation' is allocated in the method: it is up to the caller to free
	it with `free( *generation ) ;' if not NULL
-d*/
message VStrackDescendent( const struct GRid	*descendent ;
			   int			*size ;
			   struct GRid		**generation ) ;

end specification VSfeature ;
