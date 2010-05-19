/* $Id: SMVolBySplt.S,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/vol / SMVolBySplt.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMVolBySplt.S,v $
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
/*  SMVolBySplt.S
/*  Chistian HERAUD
/*  27 Oct 92.
/*
/*  Abstract
/*	Class defining of a volume which is bounded by surfaces. It uses
/*      the split way for making the volume.
/*
/*  The roots are:
/*
/*  expression (unsigned short): mask indicated:
/*			       if planar faces are taken as infinite 
/*			       if floor & ceiling specified.
/*			       if the splitting surface normal have to 
/*			       be inversed.
/*		      	       0x 8000 => If faces planar, taken as infinite.
/*		      	       0x 4000 => Floor and ceiling specified.
/*			       0x 0001 => First surface reversed normal.
/*			       0x 0002 => Second surface reversed normal.
/*			       0x 0004 => Third surface reversed normal.
/*		                 .................. ......
/*				Maximun 14 possible planes 
/*
/*
/*  14 * splitting surfaces   : Can be solid/surface.
/*
/*  if floor & ceiling flag defined => The two first surf roots are: floor, 
/*  ceiling.
/*
/*  The foot is a solid.
/*
/*  History
/*
/*---------------------------------------------------------------------------*/

class specification SMVolBySplt (0:1) of VDSroot;

override	ACmplace_from_def, ACconstruct_feet;

override	GRgetobjinfo; /* Print Split Volume at locate time */
override        ACgive_path, ACreturn_foot; /* To connect to a face */
override        VDgetObjDef;    /* object specific information */


end specification SMVolBySplt;
