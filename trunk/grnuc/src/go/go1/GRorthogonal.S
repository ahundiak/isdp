/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	This is a subclass of GRplanar which encompasses all orthogonal 
	(by definition) graphics objects.  All of the subclasses of 
	GRorthogonal can be geometrically described as consisting of a
	set of n points connected by n-1 line segments between adjacent 
	points.  Each edge is orthogonal to its neighboring edge.  Each  
	subclass of GRorthogonal can be represented as a 2nd order 
	B-spline curve.
Notes
	None
History	
	MAS     03/25/86 : Design date.
	MAS	09/03/87 : Altered for Release 1.1
*/


class specification GRorthogonal (1:1) of GRplanar;


override GRmodify,GRinsvertex,GRdelvertex;

/* 
Motivation

GRinsvertex - overridden to  maintain the orthogonality of the object
	when the vertex is inserted

GRdelvertex - overridden to  maintain the orthogonality of the object
	when the vertex is inserted

GRmodify - overridden to  maintain the orthogonality of the object
	when it is modified 

*/

end specification  GRorthogonal;
