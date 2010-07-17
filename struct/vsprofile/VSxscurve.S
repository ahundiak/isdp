/*
	I/STRUCT
*/
class specification VSxscurve(0:0) of VScompcurve ;

/*+c
	Class of composite curves with an indexing of the components so that
	the components may be retrieved with that index, or by name. This curves
	are used as cross-sections for beams.
-c*/

override debug ;

/*+d
Message VStransCmpToUsrNm

Abstract
	Returns the component's name corresponsing to the input component
	curve index.
Arguments
	IN	long		*msg	Completion code.
	IN	int		cmpIx	Component index.
	IN	struct GRid	*cmpId	Id of component.
	OUT	GRname		cmpNm	Component name.
Note
	If `cmpId' is NULL, then `cmpIndex' will be used, else `cmpIndex'
	may be set to anything.
	If component name has not been named then "$<n>" will be returned
	where <n> is the component number.
-d*/
message VStransCmpToUsrNm(	long		*msg ;
				int		cmpIx ;
				struct GRid	*cmpId ;
				GRname		cmpNm ; ) ;


/*+d
Message VStransUsrNmToCmp

Abstract
	Given a component name returns its channel index and/or its id.
Arguments
	IN	long		*msg		Completion code.
	IN	GRname		cmpNm		Component name.
	OUT	int		*p_cmpIndex	Channel index of component.
	OUT	struct GRid	*p_cmpId	Id of component.
Note
	`*p_cmpId' and/or `*p_cmpIndex' will be set depending whether
	`p_cmpId' and/or `p_cmpIndex' are NULL or not.
-d*/
message VStransUsrNmToCmp(	long		*msg ;
				GRname		cmpNm ;
				int		*p_cmpIndex ;
				struct GRid	*p_cmpId ) ;

end specification VSxscurve ;
