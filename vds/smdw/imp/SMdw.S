/* $Id: SMdw.S,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdw/imp / SMdw.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMdw.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
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
# Revision 1.2  1994/11/11  22:15:34  pinnacle
# Replaced:  smdw/imp/*.S r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*---------------------------------------------------------------------------
/*  SMdw.S
/*  Chistian HERAUD
/*  1-June-1992
/*
/*  Abstract:
/*	Class defining the dead weight object.
/*
/*
/*
/*  History:
/*
/*---------------------------------------------------------------------------*/

class specification SMdw (0:1) of SMmgr, ACrg_collect;

override GRgetobjinfo;	/* Object name at locate time			*/


override SMWhoAreYou; 	/* Return the dead weight type 			*/

override SMFillSfFile;	/* Seasafe output print				*/

override SMFillRpFile;	/* Reports output print				*/

override SMGetAtt;	/* Get attribute values				*/

override SMSetAtt;	/* Set attribute values				*/

override SMGetAttType;	/* Get attribute values	depending on type  	*/

override SMAddAtt;	/* Add new attributes				*/

end specification SMdw;

