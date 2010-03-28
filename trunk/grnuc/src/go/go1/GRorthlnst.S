/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	This is the abstract class for planar orthogonal line strings.
Notes
	None
History
	RDH     03/25/86 : Design date.
	MAS	09/03/87 : Altered for Release 1.1
*/

class specification GRorthlnst (1:1) of GRorthogonal;

override GRgetobjinfo;

/* 
Motivation

GRgetobjinfo - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

*/

end specification GRorthlnst;

