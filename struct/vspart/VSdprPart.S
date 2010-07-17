/*
	I/STRUCT
*/
class specification VSdprPart(0:0) of VSpart ;

/*+c
	Abstract class of parts whose graphic component is a DPR history of
	parent part (operand) and operators.
	This classes defines data and messages which allow to match some
	components of the graphic component with components of the operand's
	graphic components.
-c*/

#define VS_K_CMP_LOST (-2)

instance VSdprPart {
	/*
	 * Index paths of components which have a counterpart among parent's
	 * components.
	 */
	variable char	realIPATHs[0],
	/*
	 * Index paths in parent's component of counterpart components
	 */
			virtIPATHs[0] ;
	/*
	 * Both index paths look as follows :
	 * If the original (non-dpr) part had N components and sub-components
	 * both arrays will store N index paths. Say that the index paths in
	 * the non-dpr part were:
	 *
	 *	#0 : 0 0
	 *	#1 : 0 0 1
	 *	#2 : 0 0 2
	 *	#3 : 0 0 3
	 *	#4 : 0 0 4
	 *	#5 : 0 1
	 *	#6 : 0 2
	 * Then this ownership hierarchy will be store in virtIPATHs as
	 * 0 0 -1 0 0 0 -1 0 0 2 -1 0 0 3 -1 0 0 4 -1 0 1 -1 0 2 -1
	 * Where -1 (#defined as VS_K_NULL_INDEX) is a separator.
	 *
	 * To those N paths which designated objects in the non-dpr part will
	 * correspond the same components in the present object, but with
	 * different paths since the dpr operation re-organizes things:
	 *
	 *	#0 : 0 0 0
	 *	#1 : 0 0 0 1
	 *	#2 : 0 0 0 2
	 *	#3 : 0 0 0 3
	 *	#4 : 0 0 0 4
	 *	#5 : 0 0 1
	 *	#6 : 0 0 2
	 *
	 * NOTE 1
	 * `virtPath' is the paths of the components of the solid input to
	 * the dpr operation but AFTER the operation (ie. the input solid has
	 * been topologically included by EMS in the resulting solid, possibly
	 * with some components removed).
	 * NOTE 2
	 * If the input solid also belong to another VSdprPart object, then
	 * this object's virtIPATHs and realIPATHs will be used to build
	 * the virtIPATHs and realIPATHs of the present object, this way
	 * all parts understand the same virtual path and return the real
	 * indexing path into themselves which may be used to retrieve the
	 * wanted components.
	 *
	 * Example:
	 *	Let B be a source beam. In this beam, the index path to the
	 *	left web side is, say:
	 *		0 (index of solid in beam complex)
	 *		0 (index of composite surface in solid)
	 *		4 (index of side surface in composite surface)
	 *	Have B be extended at one end, the new result B' will store
	 *
	 *	virt : ... -1 0 0 4 -1 ...
	 *	real : ... -1 0 0 0 4 -1 ...
	 *
	 *	Then have B' extended at the other end into B'' which will
	 *	compare
	 *
	 *	virt : ... -1 0 0 4 -1 ...
	 *	real : ... -1 0 0 0 4 -1 ...		from B', and
	 *	virt : ... -1 0 0 0 4 -1 ...
	 *	real : ... -1 0 0 0 0 0 0 4 -1 ...	from himself, and will
	 *	finally store:
	 *	virt : ... -1 0 0 4 -1 ...
	 *	real : ... -1 0 0 0 0 0 0 4 -1 ...
	 *
	 * Finally, the fact that dpr operations suppress components must be
	 * taken into account: to use again the example above, extending a
	 * beam at one end causes the end cap of that beam to be deleted, and
	 * the capping plane is no more available from now on, it is "lost".
	 * The path for a lost component is -2 (VS_K_CMP_LOST).
	 */
} ;

override

/*+o
Message VSget_sub_cmp_ix

Abstract
	Using matching of index paths stored in instance data, translates
	virtual paths to real paths and vice versa.
Arguments
	See message VSget_sub_cmp_ix of class VSpart.
-o*/
	VSget_sub_cmp_ix ;

/*+d
Message VSbuildIPATHs

Abstract
	Builds the real and virtual index paths matching the components of
	the solid before and after the DPR operation.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*parentId	Id of parent.
	IN	int		bfCount		Count of (sub-)components in
						solid before DPR operation.
	IN	VSipathANDid	*bfList		List of ids and IPATHs of (sub-)
						components in solid before
						DPR operation.
	IN	struct GRid	*solidAfter	Id of solid after operation.
Note
	`bfList' must be filled before the DPR operation is performed on the
	solid using macro` vs$getIPATHsandIDs'.
	This message is for internal use.
-d*/
message VSbuildIPATHs(	long		*msg ;
			int		solidIndex,
					bfCount ;
			VSipathANDid	*bfList ;
			struct GRid	*parentId,
					*solidAfter ) ;

/*+d
Message VSgetMatchingIPATHs

Abstract
	Returns the real and virtual index paths associated with this object,
	as well as their sizes.
Arguments
	OUT	long	*msg		Completion code.
	OUT	int	*rsize		Size of array of real paths.
	OUT	char	**p_rpaths	Address of pointer to real paths.
	OUT	int	*vsize		Size of array of virtual paths.
	OUT	char	**p_vpaths	Address of pointer to virtual paths.
Note
	`*p_rpaths' and `*p_vpaths' are malloc'ed, it is up to the caller to
	free them if not NULL.
	This message is private and for internal use.
-d*/
message VSgetMatchingIPATHs(	long	*msg ;
				int	*rsize ;
				char	**p_rpaths ;
				int	*vsize ;
				char	**p_vpaths ) ;

end specification VSdprPart ;

