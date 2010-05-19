/* $Id: SMSketchVol.S,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/vol / SMSketchVol.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSketchVol.S,v $
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
/*  SMSketchVol.S
/*  Chistian HERAUD
/*  16 Oct 92.
/*
/*  Abstract
/*	Class defining of a sketch volume. Using a bounded volume ann
/*      and profile, create a solid include inside the bounded volume.
/*
/*	The assumption are that the walls are created with the Vz axis.
/*
/*  The roots are:
/*
/*  expression (unsigned int): 1 => That the area side of the contour has 
/*				    to be reversed.
/*
/*  Volume		     :	Bounded volume (solid).
/*
/*  Countour:		     : Curve (composite or not).
/*
/*
/*  The foot is either solid.
/*   
/*
/*  History
/*
/*
/*  Notes:
/*
/*   An extention is planned. Instead of given a curve, a set of curve could
/*   be given.
/*
/*---------------------------------------------------------------------------*/

class specification SMSketchVol (0:1) of VDSroot;

override	ACmplace_from_def, ACconstruct_feet;

override	GRgetobjinfo; /* Print COMPARTMENT at locate time */
override        ACgive_path, ACreturn_foot; /* To connect to a face */
override        VDgetObjDef;    /* object specific information */



end specification SMSketchVol;
