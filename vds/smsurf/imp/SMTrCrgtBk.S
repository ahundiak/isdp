/* $Id: SMTrCrgtBk.S,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/imp / SMTrCrgtBk.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMTrCrgtBk.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*---------------------------------------------------------------------------
/*  SMTrCrgtBk.S
/*  Pascale Lacroix
/*  Nov 9 92.
/*
/*  Abstract
/*	Class defining a Transversal Corrugated Bulkhead
/*	(projection of a profile)
/*
/*  The roots are:
/*
/*		- Coord syst
/*		- ACrg_collect
/*			- dir_axis
/*			- y_axis
/*			- hight
/*			- period
/*			- len1
/*			- len2
/*			- extension (0=hull range + 50%, 1 =bounded by hull, 
/*				2=user defined)
/*			- reverse
/*			- ext_y1
/*			- ext_y2	user defined extension
/*			- ext_z1
/*			- ext_z2
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

class specification SMTrCrgtBk (0:1) of VDSroot;

override	ACmplace_from_def, ACconstruct_feet;

override	GRgetobjinfo; /* Print SMTrCrgtBk at locate time */

override        VDgetObjDef;    /* object specific information */

end specification SMTrCrgtBk;
