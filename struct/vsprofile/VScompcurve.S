/*
	I/STRUCT
*/
class specification VScompcurve(0:0) of GRcompcurve ;

/*+c
	Class of composite curves with an indexing of the components so that
	the components may be retrieved with that index.
-c*/

instance VScompcurve {
	/*
	 * Mapping array:
	 *	index of component on to-owner channel -> user index.
	 *
	 * No more than CHAR_MAX (defined in <limits.h> components allowed.
	 */
	variable char cmpToUsr[0] ;
} ;

override	debug,
		GRrevparm ;

/*+d
Message VSinitMapping

Abstract
	Sets the mapping of the composite curve so that component #i will have
	user index usrIndices[i].
Arguments
	OUT	long	*msg		Completion code.
	IN	int	usrIndices[]	Array of user indices.
Note
	All `usrIndices[i]' must be different from one another and must
	range between 0 and CHAR_MAX. The size of `usrIndices' must be equal
	to the number of components. If `usrIndices[i]' is "-1", it means that
	no index is associated with curve #i.
	If the number of component curves changes, this message must be sent
	again to the object with an updated array.
-d*/
message VSinitMapping(	long	*msg ;
			int	usrIndices[] ) ;

/*+d
Message VSgetMapping

Abstract
	Returns the mapping array.
Arguments
	OUT	long	*msg		Completion code.
	OUT	int	*size		Size of mapping array.
	OUT	int	**usrIndices	Mapping array.
Note
	`*usrIndices' is malloc'ed, it is up to the caller to free it with
	`free( *usrIndices )' if not NULL.
-d*/
message VSgetMapping( long *msg ; int *size, **usrIndices ) ;

/*+d
Message VStransCmpToUsrIx

Abstract
	Given a component index or id, returns its user index.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		cmpIndex	Channel index of component.
	IN	struct GRid	*cmpId		Id of component.
	OUT	int		*p_usrIndex	User index of component.
Note
	if `cmpId' is NULL, then `cmpIndex' will be used, else `cmpIndex'
	may be set to anything.
	If component curve has no user index, the opposite of its component
	index will be returned.
-d*/	
message VStransCmpToUsrIx(	long		*msg ;
				int		cmpIndex ;
				struct GRid	*cmpId ;
				int		*p_usrIndex ) ;

/*+d
Message VStransUsrIxToCmp

Abstract
	Given a component user index returns its channel index and/or its id.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		usrIndex	User index of component.
	OUT	int		*p_cmpIndex	Channel index of component.
	OUT	struct GRid	*p_cmpId	Id of component.
Note
	`*p_cmpId' and/or `*p_cmpIndex' will be set depending whether
	`p_cmpId' and/or `p_cmpIndex' are NULL or not.
-d*/	
message VStransUsrIxToCmp(	long		*msg ;
				int		usrIndex ;
				int		*p_cmpIndex ;
				struct GRid	*p_cmpId ) ;

end specification VScompcurve ;
