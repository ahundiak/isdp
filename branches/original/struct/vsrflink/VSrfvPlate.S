/*
	I/STRUCT
*/
class specification VSrfvPlate(0:0) of VSrflPlate ;

/*+c
	Same as class VSrflPlate, but represents a parametric plate.
-c*/

	override
/*+o
Message VSgetObjDef

Abstract
	Retuns its type and object info as that of a parametric plate, not a
	"regular" plate.
Arguments
	See message VSgetObjDef of class VScpx.
-o*/
	VSgetObjDef,

/*+o
Message VSgetUserEditableAttr

Abstract
	Not editable at all, and returns its type as that of a parametric
	plate.
Arguments
	See message VSgetUserEditableAttr of class VSpart.
-o*/
	VSgetUserEditableAttr ;

end specification VSrfvPlate ;

