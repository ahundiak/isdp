/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	The class GRpllnstr is a subclass of GRplanar.  This is the 
	representation of a planar line string.
Notes
	None
History	
	KMO     03/25/86 : Design date.
	MAS	09/03/87 : Altered for Release 1.1
*/

class specification GRpllnstr  (1:1) of GRplanar;

override GRgetobjinfo;

/* 
Motivation

GRgetobjinfo - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

*/

end specification GRpllnstr;

