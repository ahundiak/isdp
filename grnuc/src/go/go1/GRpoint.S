/*
Abstract
	The class GRpoint is a subclass of GRlinear which represents 
	a zero length line.  A point object has no further geometry 
	interpretation than that of a 3-D point in space.
Notes
	None
History	
	MAS     11/12/85 : Design date.
*/

class specification GRpoint  (1:1) of GRlinear;
#ifndef BASE_EMS
override GRdisyourself,GRgetobjinfo,GRmodify,GRadd_to_display_list;
reject GRcpparallel,GR2ptpartdel,GR3ptpartdel,GRdelvertex,
 	GRsplit;
reject	GRfragment;

/* 
Motivation

GRgetobjinfo - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

GRdisyourself - overridden to allow the capability to display 
	points  in a special symbology.
*/

#endif
end specification GRpoint;

