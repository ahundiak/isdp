#ifndef emsedgedef_include
#define emsedgedef_include

/*
 * This include file defines a type for every possible curve type
 * in the system.  These types are store in the edges and are used
 * to map the edges to and from model space.
 *
 * rlw : 05/27/87 : Creation date
 *
 * Added a constant defining the total number of types of curves. 
 * The file EMcvtypsupp.I in the ems/src_funk/misc must be updated and
 * recompiled whenever a curve type is added. 
 *
 * ss : 04/04/88
 *
 * Added a type indicating composite curves. I could not find the file
 * EMcvtypsupp.I. I am going to assume that the above comment is out-of-date.
 *
 * ss : 05/17/89
 */

#define EMfreeform_curve		0 
#define EMcircular_arc			1
#define EMcircle			2
#define EMelliptical_arc		3
#define EMellipse			4
#define EMinfinite_line			5
#define EMlinesegment			6
#define EMlinestring			7
#define EMorthogonal_linestring		8
#define EMorthogonal_polygon		9
#define EMplanar_linestring		10
#define EMpoint				11
#define EMpolygon			12
#define EMintersection_curve		13
#define EMcomposite_curve		14
#define SKprofile_vertex		15

#define EMcurve_Types_Total		16

#endif
