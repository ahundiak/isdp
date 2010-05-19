/* $Id: SMContUtil.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / SMContUtil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMContUtil.I,v $
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
/*  History :
/*	CH  : 16 Oct 92	  creation date.
/*
/* */

class implementation Root;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"

#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emsdattyp.h"
#include "emssfintdef.h"
#include "emsdef.h"
#include "EMSssprops.h"
#include "bserr.h"


#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h" 
#include "vdsmacros.h"


#include "AS_status.h"

#define AS_DEBUG

from	GRgraphics	import	GRcopy, GRconstruct, GRgetrang, GRdelete;

#define MAX_CRV_PT	10	/* Maximun number of curve ending to a point */
#define MAX_LP_CRV	10	/* Maximun number of curves composing a loop */

struct SMGrCrv
 {
  struct GRid		CvId;		/* Curve Id			*/
  struct SMGrPt		*P0;		/* Pointeur to the starting Pt  */
  IGRdouble		TgP0[0];	/* P0 tangent			*/
  struct SMGrPt		*P1;	 	/* Pointeur to the ending Pt    */
  IGRdouble		TgP1[0];	/* P1 tangent			*/
  IGRboolean		RDef;		/* Already Def Right Side	*/
  IGRboolean		LDef;		/* Already Def Right Side	*/
  IGRdouble
 };

struct SMGrPt
 {
  struct GRid		Pt;		/* Point Id			*/
  IGRint		NbCrv;		/* Number of curve ending here  */
  srtuct SMGrCrv	*Crv[MAX_CRV_PT]; /* Array of pointer on curves */
 };

struct SMLoop
 {
  IGRint		NbCrv;		/* Number of curve of the loop	*/
  struct SMGrCrv	*Crv[MAX_LP_CRV]; /* array of pointer on curves */
  struct SMOrPt		*Pt[MAX_LP_CRV];  /* array of pointer on points */
  IGRboolean 		Rev[MAX_LP_CRV]; /* Need to be reversed		*/
 };


#define ALLOC_LP_INCR		10
#define RIGHT			1
#define LEFT			2

/*
/* SMFndMinClsLp
/*
/* Find all the loops
/*
/* */

SMFndMinClsLp(NbCrv, Crv, NbPt, Pt, Vz, NbLoops, Loops)
IGRint		NbCrv;		/* Number of curves			(I) */
struct SMGrCrv  *Crv;		/* Array of curves definition		(I) */
IGRint		NbPt;		/* Number of points			(I) */
struct SMGrPt	*Pt;		/* Array of points definition		(I) */
IGRdouble	*Vz;		/* Normal vector			(I) */
IGRint		*NbLoops;	/* Number of loops found		(O) */
struct SMLoop   **Loops;	/* Array of allocated loops found	(O) */
{
 IGRint			i, NbAllocLp, CurLp;
 IGRboolean		Found;

 *NbLoops = 0;

 *Loops = (struct SMLoop *) om$malloc(size = sizeof(struct SMLoop) * ALLOC_LP_INCR);
 if(*Loops == NULL) goto wrapup;

 NbAllocLp = ALLOC_LP_INCR;

 /* Look for each curves */
 for(i=0;i<NbCrv;i++)
  {
   if(*NbLoops >= NbAllocLp)
    {
     /* Realloc */
     *Loops = (struct SMLoop *) om$reaalloc(
     		size = sizeof(struct SMLoop) * (NbAllocLp + ALLOC_LP_INCR),
		pt   = *loops);
     if(*Loops == NULL) goto wrapup;
    }

   /* Right loop */
   if(!(SMFndMinClsLp1(i, RIGHT, NbCrv, Crv, NbPt, Pt, &Found, Loops[CurLp] & 1)
    {
     printf("Error in SMFndMinClsLp1\n");
     goto wrapup;
    }
   if(Found) CurLp++;

/* Problem if only one loop, it will find right & left .... */
   /* Left loop */
   if(!(SMFndMinClsLp1(&Crv[i], RIGHT, NbCrv, Crv, NbPt, Pt, &Found, Loops[CurLp] & 1)
    {
     printf("Error in SMFndMinClsLp1\n");
     goto wrapup;
    }
   if(Found) CurLp++;
  }
 /* That all folk !!! */
 *NbLoops = CurLp; 
}


/*
/* SMFndMinClsLp1
/*
/* Find 1 the loop
/*
/* */

SMFndMinClsLp(SCrv, RL, NbCrv, Crv, NbPt, Pt, Vz, Found, Loop)
struct SMGrCrv  *SCrv;		/* Start curve (start loop)		(I) */
IGRint		RL;		/* 1 => right loop, 2 => left loop	(I) */
IGRint		NbCrv;		/* Number of curves			(I) */
struct SMGrCrv  *Crv;		/* Array of curves definition		(I) */
IGRint		NbPt;		/* Number of points			(I) */
struct SMGrPt	*Pt;		/* Array of points definition		(I) */
IGRdouble	*Vz;		/* Normal vector			(I) */
IGRboolean	*Found;		/* 1 => found, 0 => not found		(O) */
struct SMLoop   *Loop;	  	/* loop found				(O) */
{
 struct SMGrCrv  *CurCrv;
 IGRint		 FrPt, CurPt;
 IGRboolean	 END;

 *Found = FALSE;

 FrPt 	     = 0; /* Start by point 0 */
 CurPt       = FrPt;
 CurCrv      = SCrv;
 Loop.Crv[0] = SCrv;
 Loop.NbCrv  = 1;
 while(1)
  {
   if(!(SMGetNxtCrv(CurPt, CurCrv, RL, NbCrv, Crv, NbPt, Pt, Vz, &CurCrv,
		    &CurPt, &End) & 1))
    {
     printf("Error in SMGetNxtCrv\n");
     goto wrapup;
    }
   if(End == TRUE)
    {
     /* Dead end !!! */
     printf("A dead end !!!\n");
     return 1;
    }

   /* Test if it is already a loop */
   /* Test only objid because all in the current OS */
   if(SCrv->CvId.objid == CurCrv->CvId.objid && CurPt == FrPt)
    {
     *Found = TRUE;
     break;
    }
   
   /* Test of validity (avoid infinit loop by rejecting bad loop) */
   /* Should not bee necessary but can improve the speed */

   /* Put it in the loop */
   Loop.Crv[NbCrv++] = SCrv;
  } 
}


SMGetNxtCrv(FrPt, CurCrv, NbCrv, Crv, NbPt, Pt, Vz, NectCrv, ComPt, Found)
IGRint		FrPt;		/* From pt (0: P0, 1: P1)		(I) */
struct SMGrCrv *CurCrv;		/* Current curve 			(I) */
IGRint		RL;		/* 1 => right loop, 2 => left loop	(I) */
IGRint		NbCrv;		/* Number of curves			(I) */
struct SMGrCrv  *Crv;		/* Array of curves definition		(I) */
IGRint		NbPt;		/* Number of points			(I) */
struct SMGrPt	*Pt;		/* Array of points definition		(I) */
IGRdouble	*Vz;		/* Normal vector			(I) */
struct SMGrCrv  **NextCrv;	/* Next curve	 			(O) */
IGRint		*ComPt;		/* Comming pt (0: P0, 1: P1)		(O) */
IGRboolean	*Found;		/* 1 => found, 0 => not found		(O) */
{
 *Found = 0;

 /* To get the next curve
}

end implementation Root;

