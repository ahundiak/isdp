/* #######################    APOGEE COMPILED   ######################## */
/*
History
	The class GRlineseg is the subclass of GRlinear which 
	corresponds to a line segment without the property of 
	infinite length.
Notes
	None
History	
	MAS     11/12/85 : Design date.
	MAS	09/03/87 : Altered for Release 1.1
*/

class specification GRlineseg (1:1)  of GRlinear;

#ifndef BASE_EMS
override  GRgetobjinfo;

/* 
Motivation

GRgetobjinfo - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

*/
#endif

end specification GRlineseg;

