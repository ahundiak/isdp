/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	The class GRorthpoly is a subclass of GRorthogonal which 
	is a closed, planar geometry (first and last point are equal) 
	with each edge orthogonal to its neighboring edges.
Notes
	None
History	
	MAS     03/25/86 : Design date.
	MAS	09/03/87 : Altered for Release 1.1
*/

class specification GRorthpoly  (1:1) of GRorthogonal;

override GRgeomprops, GRgetobjinfo, GRremovepts, GRadd_to_display_list;

/* 
Motivation

GRgeomprops  - overridden because it has to return special
	information about the object

GRgetobjinfo - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

GRremovepts - overridded because it requires more minimum points
	than a polygon.
*/

end specification GRorthpoly;

