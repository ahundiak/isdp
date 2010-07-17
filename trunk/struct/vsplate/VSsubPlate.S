/*
	I/STRUCT
*/
class specification VSsubPlate(0:0) of VSsrcPlate, VSsubFeature ;

/*+c
	Sub-plates are source plates which are part of a bigger plate ie. they
	are the RESULTS of some OPERATION which has divided another plate.
-c*/

override

/*+o
Message VSgetObjDef

Abstract
	One template named "plate".
Arguments
	See message VSgetObjDef of class VScpx.
-o*/
	VSgetObjDef,

/*+o
Message ACconstruct_feet

Abstract
	A sub-plate consumes its parent plate since it is a part of it.
Arguments
	See message ACconstruct_feet of class ACncpx.
-o*/
	ACconstruct_feet,

/*+o
Message VSgetSupports

Abstract
	Bubbles up message to source plate on top of the hierarchy.
Arguments
	See message VSgetSupports of class VSpart.
-o*/
	VSgetSupports ;

from VSsrcPlate inherit	GRdetplane,
			GRgetattr,
			GRputattr,
			NDdrawing_copy_geom,
			ACgive_structure,
			ACreturn_foot,
			ACgive_path,
			VSdescribeOutput,
			VSshowOrientation,
			VSgetMassProperties,
			VStransIPATHToName,
			VStransNameToIPATH,
			VScreateFrozenCopy,
			VSgetSupportedElements,
			VDget_prefix_name ;

end specification VSsubPlate ;

