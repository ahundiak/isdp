/* $Id: SMbulkhead.S,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/imp / SMbulkhead.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMbulkhead.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1997/02/06  21:05:48  pinnacle
# Created: smsurf/imp/SMbulkhead.S by jwfrosch for vds.241
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*---------------------------------------------------------------------------
/*
/*  Abstract
/*	Class defining a Longitudinal Corrugated Bulkhead
/*	(projection of a profile)
/*
/*  The roots are:
/*
/*		- Coord syst
/*		- ACrg_collect
/*			- dir_axis
/*			- x_axis
/*			- hight
/*			- period
/*			- len1
/*			- len2
/*			- extension (	0 = hull range + 50%,
/*					1 = bounded by hull, 
/*					2 = user defined)
/*			- reverse
/*			- ext_x1
/*			- ext_x2	user defined extension
/*			- ext_z1
/*			- ext_z2
/*			- rad1
/*			- rad2
/*
/*		- A point 
/*   Feet:
/*		- surface
/*   
/*
/*  History
/*
/*
/*---------------------------------------------------------------------------*/

class specification SMbulkhead (0:1) of VDSroot;

override	ACmplace_from_def, ACconstruct_feet;

override	GRgetobjinfo;	/* Print SMbulkhead at locate time */

override	VDgetObjDef;	/* object specific information */

end specification SMbulkhead;
