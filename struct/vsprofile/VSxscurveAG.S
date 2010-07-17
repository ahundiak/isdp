/*
	I/STRUCT
*/
class specification VSxscurveAG(0:0) of AScompcurve, VSxscurve ;

/*+c
	Same as VSxscurve but associative (See AScompcurve).
-c*/

override
/*+o
Message NDcopy_to_root

Abstract
	The GRcompcurve returned by this message is moved to a VSxscurve.
Arguments
	See message NDcopy_to_root of class NDnode.
-o*/
	NDcopy_to_root,

/*+o
Message NDmove_to_root

Abstract
	The GRcompcurve returned by this message is moved to a VSxscurve.
Arguments
	See message NDmove_to_root of class NDnode.
-o*/
	NDmove_to_root,

/*+o
Message ACcopy_to_Groot

Abstract
	The GRcompcurve returned by this message is moved to a VSxscurve.
Arguments
	See message ACcopy_to_Groot of class NDmacro.
-o*/
	ACcopy_to_Groot ;

end specification VSxscurveAG ;

