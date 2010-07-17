/*
	I/STRUCT
*/ 
class specification VSsubFeature(0:0) of VSfeature ;

/*+c
	Sub-features are source features which are part of a bigger feature.
-c*/

instance VSsubFeature {
	/*
	 * Index of sub-feature as imposed by the division manager.
	 */
	OMbyte	index ;
} ;

override

/*+o
Message VSisNameHolder

Abstract
	Sub-feature may have a name of their own or carry the name of their
	parent feature.
Arguments
	See message VSisNameHolder of class VSpart.
-o*/
	VSisNameHolder,

/*+o
Message NDdelete,

Abstract
	A sub-feature warns its parent feature when it is being deleted.
Arguments
	See message NDdelete of class NDnode.
-o*/
	NDdelete,

/*+o
Message VSisOriginal

Abstract
	A condition message for bubbling-up action through the history.
	A sub-part is not an original except if result of an assembly.
Argument
	See message VSisOriginal of class VSfeature.
-o*/
	VSisOriginal,

/*+o
Message VSgetOperationMgr

Abstract
	Parent #0 is the real manager of the operation.
Arguments
	See message VSgetOperationMgr of class VSfeature.
-o*/
	VSgetOperationMgr,

/*+o
Message VSgetUserEditableAttr

Abstract
	Forwards this very message to the orginal feature on top of the
	hierarchy, since if top features has attributes which cannot be modified
	by user, this sub-feature cannot have these same attributes modified
	too.
Arguments
	See arguments of message VSgetUserEditableAttr of class VSpart.
-o*/
	VSgetUserEditableAttr ;

/*+d
Message VSsetIndex

Abstract
	Sets index of sub-feature.
Arguments
	OUT	long	*msg	Completion code.
	IN	int	index	Index of sub-feature.
-d*/
message VSsetIndex( long *msg ; int index ) ;

/*+d
Message VSgetIndex

Abstract
	Gets index of sub-feature.
Arguments
	OUT	long	*msg	Completion code.
	OUT	int	*index	Index of sub-feature.
-d*/
message VSgetIndex( long *msg ; int *index ) ;

end specification VSsubFeature ;

