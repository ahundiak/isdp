/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	This is a subclass of GRlinear which encompasses all planar 
	(by definition) graphics objects.  All of the subclasses of 
	GRplanar can be geometrically described as consisting of a 
	set of n points connected by n-1 line segments between 
	adjacent points.  Each subclass can be represented as a 
	2nd order B-spline curve.

Notes
	None

History	
	MAS     03/25/86 : Design date.
	MAS	09/03/87 : alteredc for Release 1.1
*/

class specification GRplanar (1:1) of GRlinear;

override GRinsvertex,GRmodify;

/* 
Motivation

GRinsvertex - overridden to  maintain the planarity of the object
	when the vertex is inserted

GRmodify - overridden to  maintain the planarity of the object
	when it is modified
*/

end specification  GRplanar;

