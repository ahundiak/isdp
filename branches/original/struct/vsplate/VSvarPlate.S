/*
	I/STRUCT
*/ 
class specification VSvarPlate(0:0) of VSsrcPlate ;

/*+c
	Variable plates are source plates which have a variable thickness.
	The actual thickness taken by the plate will be that found in the
	Relational Data Base which is closest to the parent expression's value.
-c*/
override

/*+o
Message VSgetUserEditableAttr

Abstract
	Being constrained by the expression's value, the thickness of a
	parametric plate is not user-modifiable.
Arguments
	See message VSgetUserEditableAttr of class VSpart.
-o*/
	VSgetUserEditableAttr,

/*+o
Message VSgetObjDef

Abstract
	Two templates named "support" and "thickness".
Arguments
	See message VSgetObjDef of class VScpx.
-o*/
	VSgetObjDef,

/*+o
Message VSgetSupport

Abstract
	Returns the id of the support and the expression giving the thickness.
Arguments
	See message VSgetSupports of class VSpart.
-o*/
	VSgetSupports,

/*+o
Message ACconstruct_feet

Abstract
	Chooses its thickness from the Relational Data Base then computes as
	parent class.
Arguments
	See message ACconstruct_feet of class ACncpx.
-o*/
	ACconstruct_feet ;

/*+d
Message VSselectThicknessFromRDB

Abstract
	Given the minimum thickness needed for a construction, searches the
	Relational Data Base for the closest value available.
Arguments
	OUT	long	*msg		Completion code.
	IN	double	minVal		Minimum value needed.
	OUT	double	*rdbVal		Available Relational Data Base value.
	OUT	char	*thkname	Name of thickness found.
-d*/
message	VSselectThicknessFromRDB(	long	*msg ;
					double	minVal,
						*rdbVal ;
					char	*thkname ) ;

end specification VSvarPlate ;

