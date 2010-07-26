/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	The class GRpolygon is a subclass of GRlinear which is a closed,
	planar geometry (first and last point are equal).
Notes
	None
History	
	MAS     11/12/85 : Design date.
	RDH	03/25/86 : Rewrite
	MAS	09/03/87 : Altered for 1.1 Release
*/

class specification GRpolygon  (1:1) of GRplanar;

override GRgeomprops, GRgetobjinfo, GRadd_to_display_list;

/* 
Motivation

GRgetobjinfo - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

GRgeomprops - overridden because it returns information about
	the geometry which cannot be determined at parent
	classes.

*/

end specification GRpolygon;

