/* $Id: SMreports.S,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smreports/imp / SMreports.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMreports.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
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
/*  SMreports.S
/*  Chistian HERAUD
/*  9 Sept 92.
/*
/*  Abstract
/*	Class defining special behavior for reports.
/*
/*
/*
/*  History
/*
/*---------------------------------------------------------------------------*/

class specification SMreports (0:1) of SMAttMgr, VDSroot ;

override	ACmplace_from_def, ACconstruct_feet;

override	GRgetobjinfo; /* Print Reports at locate time         */

override	SMWhoAreYou; /* Return the reports type and sub_type   */

override	NDparent_deleted; /* if a root object has been deleted     */

override	SMFillRpFile; /* print out a report                        */

override 	GRputname, GRchgname; /* Modified the displayed name */

/*+mo
  Overriden Message
	VDgetObjDef from VDSroot

  Abstract
        Returns the definition of an object: name of templates and feet, etc.
  Arguments
        OUT     long            *msg            Completion code.
        IN      VDobjDef        *objDef         Object definition.
  Note
        The fields of `objDef' point to static buffers and therefore should
        not be freed.
-mo*/

override VDgetObjDef;

message SMRptClean(IGRlong *msg);

 /*  SMRptClean
 /*
 /* Remove duplicated expression */
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg            O : Completion code
 /*
 /* */


message SMRptAddObj(IGRlong *msg; IGRdouble VolMass;
                 IGRshort type; struct GRid *obj);

 /* SMRptAddOj.
 /*
 /* Add a new object for reports. Create if necessary the needed expressions.
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg            O : Completion code
 /*
 /*   IGRdouble         thickness       I : Thickness if surface
 /*
 /*   IGRdouble         VolMass         I : Volumic mass.
 /*
 /*   IGRshort          type            I : Type of the object (SM_RP_SF,
 /*                                         (SM_RT_SL, SM_RP_RP).
 /*
 /*   struct GRid       *obj            I : Object to be added.       
 /*
 /* */


message SMRptDelObj(IGRlong *msg; struct GRid *obj);

 /* SMRptDelOj.
 /*
 /* Remove (disconnect) an exising object from report. don't delete the
 /* unussed expressions. The caller can use SMRptClean afterwards.
 /*
 /*  Argument description:
 /*  ---------------------
 /*
 /*   IGRlong           *msg            O : Completion code
 /*
 /*   struct GRid       *obj            I : Object to be removed.
 /*
 /* */

/*-------------------------------------------------------------------------*/

end specification SMreports;
