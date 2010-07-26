/*
Abstract
	The class GRlbsys is the subclass of GRvg and consists of
	geometric entities which can be used to specify a box in
	space.  The local bounded system is defined in terms of a
	local coordinate system (representable by a transformation
	matrix which transforms points from local to world 
	coordinates) and two points (called diagonal points)
	which define the extents of the local bounded system.
Notes
	None
History	
	SDG	3/25/86:   Creation date.
*/

class specification GRlbsys (1:1) of GRvg;

override GRptproject, GRlnproject, GRxform, GRkeypoint,
	GRdetplane,GRgetgeom,GRlocate_processing,GRgetrang,
	GRprismrel, GRgetsize, GRgeomprops;
override GRinplane;

/*
Motivation

GRptproject, GRlnproject, GRxform, GRkeypoint, GRinplane, GRdetplane,
	GRgetgeom, GRprismrel , GRgetsize
	- the declaration of the methods by the parent class
	is a method declaration only so it must be overridden at this
	class if the class wishes to answer to the method.
GRlocate_processing, GRgetrang - is overridden because of special handling 
	needed for this type of geometry.
*/

end specification GRlbsys;
