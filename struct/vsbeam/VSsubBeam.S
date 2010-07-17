/*
	I/STRUCT
*/ 
class specification VSsubBeam(0:0) of VSsrcBeam, VSsubFeature ;

/*+c
	Sub-beams are source beams which are part of a bigger beam, ie. they
	are the RESULTS of some OPERATION which has divided another beam.
	Some of them do carry attributes. 
-c*/

override

/*+o
Message VSgetObjDef

Abstract
	One template named "beam".
Arguments
	See message VSgetObjDef of class VScpx.
-o*/
	VSgetObjDef,

/*+o
Message ACconstruct_feet

Abstract
	A sub-beam consumes its parent beam since it is a part of it.
Arguments
	See message ACconstruct_feet of class ACncpx.
-o*/
	ACconstruct_feet,

/*+o
Message VSgetSupportAxis

Abstract
	Returns the part of the original axis corresponding to this sub-beam.
Arguments
	See message VSgetSupportAxis of class VSbeam.
-o*/
	VSgetSupportAxis,

/*+o
Message VSgetSupportSf

Abstract
	Returns the same suport surface as before the division.
Arguments
	See message VSgetSupportSf of class VSbeam.
-o*/
	VSgetSupportSf ;

from VSsrcBeam inherit	NDdrawing_copy_geom,
			GRgetattr,
			GRputattr,
			ACgive_structure,
			ACgive_db_structure,
			ACcheckin_candidate,
			ACadd_to_list_1,
			ACreturn_foot,
			VSgetSupports,
			VSdescribeOutput,
			VStransNameToIPATH,
			VStransIPATHToName,
			VSgetMassProperties,
			VScreateFrozenCopy,
			VDget_prefix_name ;

end specification VSsubBeam ;

