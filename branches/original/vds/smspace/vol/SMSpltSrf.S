/* $Id: SMSpltSrf.S,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/vol / SMSpltSrf.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSpltSrf.S,v $
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
/*  SMSpltSrf.S
/*  Chistian HERAUD
/*  21 Oct 92.
/*
/*  Abstract
/*	Class defining of a bounded surface (or volume) resulting of splitting
/*  and save side operations.
/*
/*  The roots are:
/*
/*  expression (unsigned int): mask indicated:
/*			       if planar support taken as infinite 
/*			       if generated normal object has to be reversed.
/*			       if the splitting surface normal have to 
/*			       be inversed.
/*		      	       0x 8000 => Planar as infinite..
/*		      	       0x 4000 => Reverse normal.
/*			       0x 0001 => First plane reversed normal.
/*			       0x 0002 => Second plane reversed normal.
/*			       0x 0004 => Third plane reversed normal.
/*		                 .................. ......
/*				Maximun 14 possible planes 
/*
/*  expression		      : Offset distance.
/*
/*  Support:		      : Can be solid/surface.
/*
/*  14 * splitting surfaces   : Can be solid/surface.
/*
/*
/*  The foot is either a plane, surface, or solid.
/*
/*  History
/*
/*---------------------------------------------------------------------------*/

class specification SMSpltSrf (0:1) of VDSroot;

override	ACmplace_from_def, ACconstruct_feet;

override	GRgetobjinfo; /* Print COMPARTMENT at locate time */
override        ACgive_path, ACreturn_foot; /* To connect to a face */ 
override        VDgetObjDef;    /* object specific information */

end specification SMSpltSrf;
