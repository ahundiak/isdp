/* $Id: SMsection.S,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsection/imp / SMsection.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMsection.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
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
/*  SMsection.S
/*  Chistian HERAUD
/*  11 June 92.
/*
/*  Abstract
/*	Class defining special behavior for calculation sections.
/*
/*
/*
/*  History
/*
/*---------------------------------------------------------------------------*/

class specification SMsection (0:1) of SMAttMgr, VDSroot;

override	ACmplace_from_def, ACconstruct_feet;

override	GRgetobjinfo; /* Print COMPARTMENT at locate time */

override	SMWhoAreYou; /* Return the compartment type and sub_type */

override	SMFillSfFile; /* Seasafe extraction */

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

/*---------------------------------------------------------------------*/

message SMGetComp(IGRlong *msg; struct GRid *comp; struct GRmdenv_info *md_env);

/*
/*  SMGetComp:
/* 
/*    Return the compartment on which depend the calculation sections.
/*
/*  Argument description:
/*  --------------------
/*
/*  IGRlong		*msg		O : Completion code.
/*
/*  struct GRid		*comp		O : Compartment id (can be NULL).
/*
/*  struct GRmdenv_info *md_env		O : Compartmenrt env (can be NULL).
/*
/*  */
/*---------------------------------------------------------------------*/

message SMSectGetCal(IGRlong *msg; struct GRid *cs, *comp; IGRint *NbFrame;
                  struct GRid *frame; struct SMSectInfo *Info);
/*
/*  SMSectGetCal:
/* 
/*    Use to get info about a calculation section object.
/*  The array of frame can be sized to SM_MAX_PARTS * 2
/*
/*  Argument description:
/*  --------------------
/*
/*  IGRlong		*msg		O : Completion code.
/*
/*  struct GRid		*comp		I : Compartment id (can be NULL).
/*  
/*  struct GRid		*cs		I : Coord. system (can be NULL).
/* 
/*  IGRint              *NbFrame        I : Number of frames.
/*
/*  struct GRid		*frame		I : List of frames (can be NULL).
/*
/*  IGRSectInfo         *Info           I : Parameters info (can be NULL).
/*                                          (see SMdef.h)
/*  */
/*---------------------------------------------------------------------*/


message SMSectSetCal(IGRlong *msg; struct GRid *cs, *comp; IGRint NbFrame;
                  struct GRid *frame; struct SMSectInfo *Info);
/*
/*  SMSectGetCal:
/* 
/*    Use to create or modify a calculation section object.
/*
/*  Argument description:
/*  --------------------
/*
/*  IGRlong		*msg		O : Completion code.
/*
/*  struct GRid		*comp		I : Compartment id (can be NULL).
/*  
/*  struct GRid		*cs		I : Coord. system (can be NULL).
/* 
/*  IGRint              NbFrame         I : Number of frames.
/*
/*  struct GRid		*frame		I : List of frames (can be NULL).
/*
/*  IGRSectInfo         *Info           I : Parameters info.
/*                                          (see SMdef.h)
/*  */
/*---------------------------------------------------------------------*/


end specification SMsection;
