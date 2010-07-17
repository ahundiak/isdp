/*
	I/STRUCT
*/
class specification VSdivFeature(0:0) of VSmodFeature ;

/*+c
	Class for a feature which is the result of a division (eg. split)
	operation.
		From one objects to several, the consumee (operand) undergoes a
	division.

		operand -> { result1, result2, ..., resultM }

	a) User perception

		The operation gives birth to M new entities ( called
	sub-features ) which must have a high degree of independance (they are
	siblings) except that their geometries are constrained. They must be
	independently modifiable ( attributes, color, style, weight, level,
	name, etc. ).

		They also may be deleted independently.

	b) Implementation of operation

		The implementation is done by means of a DIVISION MANAGER :


				operand		operator
				   |		   |
				   +---------------+
					   |
				     division manager
					   |
				   +-------+-------+
				   |	   |	   |
				result1 result2  resultM

		The division manager consumes the operand, divides the
	operand's output in M graphic objects, then constructs under itself
	M results which will in turn consume the division manager's M
	graphic feet to use them as their own. To be modifiable, the results
	must be very much like source objects.

		The division manager orders the results (following criteria
	of its own), the first result being distinguished.
		When a result is deleted, the division manager re-organizes
	itself and will know at recompute that of the M graphic objects
	regenerated, M-1 must be kept. If the first result is deleted then
	result2 ( the new result1 ) becomes the distinguished result.
		When the last result remaining is deleted (which means
	that the user does not want the object anymore), the original
	object (the operand) goes away too.
		When the operator is deleted, the operand is restored.
	The distinguished result is the one reflecting what the attributes
	of the restored operand will be when the operator is deleted.
-c*/

#ifndef _LIMITS_H
#	include <limits.h>
#endif

instance VSdivFeature {
	/*
	 * Mask indicating the results of the operation which are present.
	 */
	OMbyte	subMask ;
} ;

override
	NDmove_to_root,
	NDparent_deleted,
	NDcopy_to_root,
	NDdelete,

/*+o
Message GRconstruct

Abstract
	Uses VSfeature.GRconstruct, then hooks sub-features as children
	consuming its feet.
	The type (class id) of the sub-features to construct in put in
	the following way :

	extern OMuword		OPP_<sub-feature>_class_id ;
	struct GRvg_construct	cst ;
	struct VScnst_list	vsargs ;
	VSpartAttr		partAttr ;
	VSdivArgs		dvargs ;
	VSjoinInfo		jnInfo ;

	cst.class_attr		= (char	*) &vsargs ;
	vsargs.feature_att	= (char *) &dvargs ;
	dvargs.subFeatureClassId= OPP_<sub-feature>_class_id ;
	dvargs.subFeatureAttr	= &partAttr ;
	dvargs.divInfo		= NULL ;

	The other fields of `cst', `vsargs', `partAttr' must be filled as usual.

	If it is wished that a joint be automatically placed between the results
	of the division, then set

	dvargs.divInfo		= (void *) jnInfo ;

	with the fields of `jnInfo' properly set.	
-o*/
	GRconstruct,
	VSchildDeleted,

/*+o
Message VSremoveOperator

Abstract
	The removal of the division operator induces the removal of this object
	but also of the associated sub-features.
Arguments
	See message VSremoveOperator of class VSmodFeature.
-o*/
	VSremoveOperator ;

/*+d
Message	VSgetSubMask

Abstract
	Returns the mask indicating the generated and kept sub-features,
	as well a the maximum of sub-features which can be generated.
Arguments
	OUT	long		*msg		Completion code.
	OUT	unsigned int	*mask		Mask of sub-features.
	OUT	int		*count		Count of existing sub-plate.
	OUT	int		*max		Max of sub-features.
Note
	If there can be `*max' sub-features, a bit in [0,*max-1] in *mask
	will be set if the sub-plate is present and cleared if not.
-d*/
message	VSgetSubMask(	long		*msg ;
			unsigned int	*mask ;
			int		*count,
					*max ) ;

/*+d
Message	VSsetSubMask

Abstract
	Sets the sub-plate mask. This is a purely internal message and shall
	not be used by anybody except objects of this class.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		action		Bit-setting action.
	IN	unsigned int	mask		Input mask.
Note
	Action is one of the following :
	VS_K_ADD_BITS:	input make will be ORed with the objects.
	VS_K_REM_BITS:	bits which are set in the input mask will be cleared in
			the object's mask.
	VS_K_SET_BITS:	input mask will ovewrite object's mask.
	VS_K_SET_ALL :	all bits of object's mask set (argument `mask' ignored)
-d*/
message	VSsetSubMask(	long		*msg ;

#define	VS_K_ADD_BITS	0
#define	VS_K_REM_BITS	1
#define	VS_K_SET_BITS	2
#define	VS_K_SET_ALL	3

			int		action ;
			unsigned int	mask ) ;


/*+d
Message VSget_sub_features

Abstract
	Returns the sub-features given by the division operation and managed by
	this object.
Arguments
	OUT	long		*msg			Completion code.
	OUT	int		*count			Count of sub-features.
	OUT	struct GRid	list[VS_K_MAX_SUBS]	List of sub-features.
Note
	If `p_features' is NULL, only the count is returned.
-d*/
message VSget_sub_features(	long		*msg ;
				int		*count ;
				struct GRid	list[VS_K_MAX_SUBS] ) ;

end specification VSdivFeature ;
