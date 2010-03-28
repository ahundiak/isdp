/* #######################    APOGEE COMPILED   ######################## */
/*	
Abstract
	The class GRlinestr is a subclass of GRlinear.  This is the 
	representation of a line string.
Notes
	None

History
	KMO     03/24/86 : Design date.
	MAS	09/03/87 : Altered for Release 1.1
*/

class specification GRlinestr  (1:1) of GRlinear;

override GRgetobjinfo;

/* 
Motivation

GRgetobjinfo - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

*/

end specification GRlinestr;

