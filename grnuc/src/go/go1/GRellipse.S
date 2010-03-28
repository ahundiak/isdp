/*
Abstract
	The class GRellipse is the subclass of GRconic which
	represents an ellipse.
Notes
	None

History
	SDG     11/14/85 : Creation date.
	KMO	03/26/86 : Revision date.
	MAS	09/03/87 : altered for Release 1.1
 
*/

class specification GRellipse (1:1) of GRconic;

override GRgeomprops, GRgetobjinfo, GRreport_defaults, GRreport,
         GRupdate_gadgets;

/* 
Motivation

GRgetobjinfo - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

GRgeomprops - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

*/

end specification GRellipse;
