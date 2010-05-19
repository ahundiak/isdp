/* $Id: SMLtdVol.S,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/vol / SMLtdVol.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMLtdVol.S,v $
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
/*  ----------------------------------------------------------------------
/*  SMLtdVol.S
/*  Alain CLAUDE
/*  02 Nov 92
/*
/*  Abstract
/*	"Limited Volume"
/*	Class defining a C macro having a composite solid as its foot,
/*	and a set of surfaces as its parents.  The solid is defined by
/*	the volume limited by the given set of surfaces.
/*
/*  History
/*
/*  ---------------------------------------------------------------------- */

class specification SMLtdVol (0:1) of VDSroot ;

override ACmplace_from_def, ACconstruct_feet ;
override GRgetobjinfo, GRdelete ; 
override        ACgive_path, ACreturn_foot; /* To connect to a face */
override        VDgetObjDef;    /* object specific information */


end specification SMLtdVol ;

