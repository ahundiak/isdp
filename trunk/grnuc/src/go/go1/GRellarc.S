/*
Abstract
	The class GRellarc is the subclass of GRconic and
	is an elliptical arc.
Notes
	None.

History	
	SDG     11/15/85 : Creation date.
	RDH	03/25/86 : Rewrite.
	MAS	09/03/87 : Alter for release 1.1

*/

class specification GRellarc (1:1) of GRconic;

override GRgetobjinfo, GRreport_defaults, GRreport, GRupdate_gadgets;
 
/* 
Motivation

GRgetobjinfo - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

*/
end specification GRellarc;
