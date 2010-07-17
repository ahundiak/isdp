/*
	I/STRUCT
*/
class specification VSrfsBeam(0:0) of VSrflBeam ;

/*+c
	Same as class VSrflBeam, but represents a stiffener.
-c*/

	override
/*+o
Message VSgetObjDef

Abstract
	Retuns its type and object info as that of a stiffener, not a beam.
Arguments
	See message VSgetObjDef of class VScpx.
-o*/
	VSgetObjDef,

/*+o
Message VSgetUserEditableAttr

Abstract
	Not editable at all, and returns its type as that of a stiffener.
Arguments
	See message VSgetUserEditableAttr of class VSpart.
-o*/
	VSgetUserEditableAttr,

/*+o
Message VSimportData

Abstract
	Same as message VSimportData of class VSrfsBeam, but additionaly stores
	the fact whether the profile direction must be reversed to respect the
	orientation of the surface which defined the stiffener's axis.
Arguments
	See message VSimportData of class VSrflBeam.
-o*/
	VSimportData,

/*+o
Message VSgetXdirectionForCrossSectionCS

Abstract
	This method returns the available direction for the x-vector of the
	cross-section CS if any, deduced from the data stored by method
	VSimportData.
Arguments
	See message VSgetXdirectionForCrossSectionCS of class VSbeam.
-o*/
	VSgetXdirectionForCrossSectionCS ;

end specification VSrfsBeam ;

