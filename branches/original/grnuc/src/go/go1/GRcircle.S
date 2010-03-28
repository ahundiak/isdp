/*
Abstract
	The class GRcircle is the subclass of GRconic and
	represents a circle.

Notes
	None

History	
	SDG     11/12/85 : Creation date.
	SDG	3/24/86	 :   Revision date.
	MAS	9/03/87  :  Alter for release 1.1
    msm 4/29/91  :  removed GRloadform method and insted added 
                    GRreport_defaults, GRreport and GRupdate_gadgets.
*/

class specification GRcircle (1:1) of GRconic;

override
GRgeomprops; 

#ifndef BASE_EMS
override GRgetobjinfo, GRreport_defaults, GRreport,
         GRupdate_gadgets;

override GRaxmodify;

/* 
Motivation

GRgeomprops  - overridden because it has to return special
	information about the circle

GRaxmodify - overrided because the first input point determines
	the primary axis for the new ellipse the circle is modified
	to be.

GRgetobjinfo - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.
*/

#endif
end specification GRcircle;
