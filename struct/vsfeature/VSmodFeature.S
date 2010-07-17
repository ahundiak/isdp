/*
	I/STRUCT
*/ 
class specification VSmodFeature(0:0) of VSfeature ;

/*+c
	Abstract class for a modified feature.
-c*/

override
/*+o
Message NDget_virtual_objects

Abstract
	Ensures the right propagation of recomputation in the consume history:

				  P1
				   |
				   +-------+
				   |	   |
				feature    |
				|  |  |    |
				C1 C2 consumer feature

	We want recomputation to be P1, feature, C1, C2, consumer feature and
	not P1, feature, consumer feature, C1, C2 since in this latter case
	the consumer feature will take over the graphic members of feature,
	leaving nothing to C1 and C2 to recompute with.
	When sent this message, the consumer feature will get its parent
	feature's other children than itself (here C1 and C2), and return them
	at its virtual parents, thus ensuring that they get recoputed before
	it.
Arguments
	See message NDget_virtual_objects of class NDnode.
-o*/
	NDget_virtual_objects,
	VSgetUserEditableAttr,

/*+o
Message ACput/get/set_NV_rep

Abstract
	Puts/sets/gets NV representation to/to/from the part. Since this part
	comes in fact from an original un-end-treated part, the representation
	is in actually put to/set to/gotten from the original part.
-o*/
	ACput_NV_rep,
	ACset_NV_rep,
	ACget_NV_rep,

/*+o
Message NDcopy

Abstract
	Do not copy when dynamics is in progress.
Arguments
	See message NDcopy of class NDnode.
-o*/
	NDcopy,

/*+o
Message NDcopy_to_root

Abstract
	Sends VSfeature.VScopy_to_root to self. See VSfeature.S.
-o*/
	NDcopy_to_root,

/*+o
Message GRgetattr

Abstract
	Asks for the attributes of the uppermost (source) feature in the
	hierarchy.
Arguments
	Same as those of the GRgetattr message of the source feature which
	will get the message.
-o*/
	GRgetattr,

/*+o
Message GRputattr

Abstract
	Puts the attributes to the uppermost parent part in the hierarchy.
Arguments
	Same as those of the GRputattr message of the source feature which
	will get the message.
-o*/
	GRputattr,

/*+o
Message VSevaluate

Abstract
	Performs the regular VSevalute but takes consumed parent's symbology.
Arguments
	Same as message "VSevaluate" of class "VScpx".
-o*/
	VSevaluate,

/*+o
Message GRchgcolor/dp/level/style/weight GRputsymb

Abstract
	Changes its symbology attributes as well as those of its consumed
	parent, so that when unconsume occurs, the objects pops back up with
	the right symbology.
Arguments
	Same as messages "GRchgcolor/dp/level/style/weight, GRputsymb" of class
	"GRvg".
-o*/
	GRchgcolor, GRchgdp, GRchglevel, GRchgstyle, GRchgweight, GRputsymb,


/*+o
Message VSifSourceThenSend

Abstract
	Condition message for bubbling-up.
	Answers no (returns OM_W_ABORT): modified features are not source
	features.
-o*/
	VSifSourceThenSend,

/*+o
Message VSgetSupports

Abstract
	Finds the supports of a part, i.e. the surface which is the template
	of the uppermost part in a plate hierarchy. Not all templates may be
	returned: graphics objects and expressions will be returned but
	not private or user attibute collections.
Arguments
	See message VSgetSupports of class VSpart.
-o*/
	VSgetSupports,

/*+o
Message VSalways_TRUE

Abstract
	Message which is a pass-up condition for message ACbubble_up of class
	ACncpx so that complex receives bubbling-up message no matter what
	and passes it up.
Arguments
	none
Note
	Returns OM_S_SUCCESS.
-o*/
	VSalways_TRUE,

/*+o
Message VSisOriginal

Abstract
	A condition message for bubbling-up action through the history.
	Queries the object if it is original, i.e. a source part which is not
	a sub-part, BUT a modified part in an assembly (macro-construction) may
	present itself as original.
Argument
	See message VSisOriginal of class VSfeature.
-o*/
	VSisOriginal,

/*+o
Message VSisNameHolder

Abstract
	No modifiable plate is a name holder, ie. it bears the name of the
	source feature up in the hierarchy.
Argument
	See message VSisNameHolder of class VSpart.
-o*/
	VSisNameHolder ;

/*+d
Message VStransferRep

Abstract
	Transfers object's representation to its parent because object is going
	to be delete and consumed parent will pop back up.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*realParent	Id of real parent.
	IN	struct GRobj_env
				*virtParent	Virtual parent (optional).
-d*/
message VStransferRep(	long			*msg ;
			struct GRid		*realParent ;
			struct GRobj_env	*virtParent ) ;

/*+d
Message VSremoveOperator

Abstract
	Removes an operator from operation whose result is the target of this
	message.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		Module environment of target.
	IN	struct GRid	*operator	Operator representing the
						operation.
	OUT	int		*deleted	Target of message was deleted ?
						(TRUE/FALSE)
Note
	`operator' is expected to be a parent of the target of this message.
	The undoing may result in the deletion of the target of the message
	if the operator was the last one.
-d*/
message VSremoveOperator( long			*msg ;
			 struct GRmd_env 	*myEnv ;
			 struct GRid		*operator ;
			 int			*deleted ) ;

/*+d
Message VSundoOperation

Abstract
	Undoes the operation, represented by the input operator, whose result
	is the target of this message. This message must be sent to a visible
	result ie. an unconsumed modified feature.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		Module environment of target.
	IN	struct GRmd_env	*oprtrEnv	Module environment of operator.
	IN	struct GRid	*oprtrId	Id of operator.
	OUT	struct GRobj_env*visibleObj	Visible result after undoing.
Notes
	`*msg' will be MSINARG if the object given as an operator is not an
	operator of a modified feature somewhere in the hierarchy.
	The undoing may result in the deletion of the target of the message
	if the operator was the last one, in this case `visibleObj' is the new
	last one/ If the target is not deleted, then `visibleObj' contains its
	id and module environment.

	if `visibleObj' is NULL, it is only checked that the input operator
	is in the history, no undo takes place.
-d*/
message VSundoOperation(	long		*msg ;
				struct GRmd_env	*myEnv,
						*oprtrEnv ;
				struct GRid	*oprtrId ;
				struct GRobj_env*visibleObj ; ) ;

end specification VSmodFeature ;

