/*
Abstract
	The class GRcirarc is the subclass of GRconic.  It
	represents a circular arc object.
Notes
	None.

History	
	SDG     11/13/85 : Creation date.
	MAS	03/25/86 : Rewritten.
	MAS	09/03/87 : Altered for Release 1.1

*/

class specification GRcirarc (1:1) of GRconic;

#ifndef BASE_EMS
override  GRgetobjinfo, GRreport_defaults, GRreport, GRupdate_gadgets;

override  GRaxmodify;

/*
Motivation 

GRaxmodify - overridden because the first input point redefines the
	axis of the circular arc to form the new elliptical arc

GRgetobjinfo - overriden because it needs to return the actual type of
	object

*/
#endif

end specification GRcirarc;
