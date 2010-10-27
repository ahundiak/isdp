/* $Id: SMAttMgr.S,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smmgr / SMAttMgr.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMAttMgr.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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
/*  SMAttMgr.S
/*  Chistian HERAUD
/*  29-May-1992
/*
/*  Abstract:
/*	Abstract class defining the common behaviour for I/SMAN objects.
/*   
/*      It is for the objects which are subclass of SMmgr & ACcnpx which
/*	have an rg collection as the first root
/*      
/*	It manages the attributes (set/get/modify).
/*
/*  History:
/*
/*---------------------------------------------------------------------------*/

class specification SMAttMgr (0:1) of SMmgr, ACncpx;

 /* Attribute management: */

override SMGetAtt,SMResetAtt,SMListAtt,SMSetAtt, SMGetAttType, SMAddAtt;

override ACgive_structure;

end specification SMAttMgr;

