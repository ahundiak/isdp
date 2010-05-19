/* $Id: SMCnstLoop.c,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/vol / SMCnstLoop.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCnstLoop.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1996/04/29  09:18:36  pinnacle
 * Replaced: smspace/vol/SMCnstLoop.c for:  by ksundar for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* -------------------------------------------------------------------
 *  History :
 *	CH  : 16 Oct 92	  creation date.
 *
 * -------------------------------------------------------------------*/


#include "OMtypes.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "bserr.h"

#include "SMLoops.h"
#include "VDmem.h"
/*
 * SMFndMinClsLp
 *
 * Find all the loops
 *
 * */

SMFndMinClsLp(NbCrv, Crv, NbPt, Pt, Vz, NbLoops, Loops)
IGRint		NbCrv;		/* Number of curves			(I) */
struct SMGrCrv  *Crv;		/* Array of curves definition		(I) */
IGRint		NbPt;		/* Number of points			(I) */
struct SMGrPt	*Pt;		/* Array of points definition		(I) */
IGRdouble	*Vz;		/* Normal vector			(I) */
IGRint		*NbLoops;	/* Number of loops found		(O) */
struct SMLoop   **Loops;	/* Array of allocated loops found	(O) */
{
 IGRint			i, j, k, NbAllocLp, CurLp;
 IGRboolean		Found;

 *NbLoops = 0;

 *Loops = _MALLOC(ALLOC_LP_INCR, struct SMLoop);
 if(*Loops == NULL) goto wrapup;

 NbAllocLp = ALLOC_LP_INCR;

 /* Look for each curves */
 CurLp = 0;
 for(i=0;i<NbCrv;i++)
  {
   if(*NbLoops >= NbAllocLp)
    {
     /* Realloc */
     *Loops = _REALLOC(*Loops, (NbAllocLp + ALLOC_LP_INCR), struct SMLoop);
     if(*Loops == NULL) goto wrapup;
     NbAllocLp += ALLOC_LP_INCR;
    }

   /* Right loop */
   if(!(Crv[i].RLDef & RIGHT))
    {
     SMFndMinClsLp1(i, RIGHT, NbCrv, Crv, NbPt, Pt, Vz, &Found, &((*Loops)[CurLp]));
     if(Found) 
      {
       /* Marque loop curves (p0, p1) */
       for(k=0;k<(*Loops)[CurLp].NbCrv;k++) 
        {
	 if((*Loops)[CurLp].Rev[k] == TRUE) Crv[(*Loops)[CurLp].Crv[k]].RLDef |= LEFT;
	 else 			  	    Crv[(*Loops)[CurLp].Crv[k]].RLDef |= RIGHT;
	}
       CurLp++;
      }
    }

   /* Left loop */
   if(Crv[i].RLDef & LEFT) continue;
   SMFndMinClsLp1(i, LEFT, NbCrv, Crv, NbPt, Pt, Vz, &Found, &((*Loops)[CurLp]));
   if(Found == FALSE) continue;

   /* Verify that it is not as the first one */
   if((CurLp > 0) &&((*Loops)[CurLp-1].NbCrv == (*Loops)[CurLp].NbCrv))
    {
     /* May be the same */
     Found = FALSE;
     for(j=0;j<(*Loops)[CurLp].NbCrv;j++)
      {
       if((*Loops)[CurLp-1].Crv[i] != (*Loops)[CurLp].Crv[i] ||
  	  (*Loops)[CurLp-1].Pt[i]  != (*Loops)[CurLp].Pt[i]) 
	{
	 /* Not the same */
	 Found = TRUE;
	 break;
	}
      }
    }

   /*
    * One case is not detected, if there is no choice a RIGHT loop can
    * also be returned. The only way (I know) to verify that it is the
    * right loop, is to construct the curve and see if the point is inside.
    */

   if(Found) 
    {
     /* Marque loop curves (p0, p1) */
     for(k=0;k<(*Loops)[CurLp].NbCrv;k++) 
      {
       if((*Loops)[CurLp].Rev[k] == TRUE) Crv[(*Loops)[CurLp].Crv[k]].RLDef |= RIGHT;
       else 			  	  Crv[(*Loops)[CurLp].Crv[k]].RLDef |= LEFT;
      }
     CurLp++;
    }
  }
 /* That all folk !!! */
 *NbLoops = CurLp; 
 return 1;

wrapup:
 return 0;
}


/*
 * SMFndMinClsLp1
 *
 * Find 1 the loop
 *
 * */

SMFndMinClsLp1(SCrv, RL, NbCrv, Crv, NbPt, Pt, Vz, Found, Loop)
IGRint		SCrv;		/* Start curve index (start loop)	(I) */
IGRshort	RL;		/* 1 => right loop, 2 => left loop	(I) */
IGRint		NbCrv;		/* Number of curves			(I) */
struct SMGrCrv  *Crv;		/* Array of curves definition		(I) */
IGRint		NbPt;		/* Number of points			(I) */
struct SMGrPt	*Pt;		/* Array of points definition		(I) */
IGRdouble	*Vz;		/* Normal vector			(I) */
IGRboolean	*Found;		/* 1 => found, 0 => not found		(O) */
struct SMLoop   *Loop;	  	/* loop found				(O) */
{
 IGRint		 CurCrv;
 IGRint		 CurPt, IntPt;
 IGRboolean	 RevCrv, Found2;

 *Found = FALSE;

 Loop->Crv[0] = SCrv; 		/* P0 -> P1 */
 Loop->Pt[0]  = Crv[SCrv].P0;
 Loop->Rev[0] = FALSE; 
 Loop->NbCrv  = 1;

 CurCrv      = SCrv;
 CurPt       = Loop->Pt[0];

 /* Verify that it is not already a close profile */
 if(Crv[CurCrv].P0 == -1 && Crv[CurCrv].P1 == -1)
  {
   /* Close one */
   Crv[CurCrv].RLDef = 3;
   *Found = TRUE;
   return 1;
  }

 IntPt = Crv[SCrv].P1;
 while(1)
  {
   SMGetNxtCrv(IntPt, CurCrv, RL, NbCrv, Crv, NbPt, Pt, Vz, &CurCrv,
    	       &IntPt, &RevCrv, &Found2, Loop);

   if(Found2 == FALSE)
    {
     /* Dead end !!! */
     printf("A dead end !!!\n");
     return 1;
    }

   /* Test if it is already a loop */
   if(Loop->Crv[0] == CurCrv && Loop->Pt[0] == CurPt)
    {
     *Found = TRUE;
     break;
    }
   
   /* Put it in the loop */
   Loop->Crv[Loop->NbCrv] = CurCrv;
   Loop->Pt[Loop->NbCrv]  = CurPt;
   Loop->Rev[Loop->NbCrv] = RevCrv;
   Loop->RLType		  = RL;
   Loop->NbCrv++;
  } 
 return 1;
}


SMGetNxtCrv(IntPt, CurCrv, RL, NbCrv, Crv, NbPt, Pt, Vz, NextCrv, NextPt, 
	    RevCrv, Found, CurLoop)
IGRint		IntPt;		/* Index of current intersection pt	(I) */
IGRint		CurCrv;	        /* Index of current curve		(I) */
IGRshort	RL;		/* 1 => right loop, 2 => left loop	(I) */
IGRint		NbCrv;		/* Number of curves			(I) */
struct SMGrCrv  *Crv;		/* Array of curves definition		(I) */
IGRint		NbPt;		/* Number of points			(I) */
struct SMGrPt	*Pt;		/* Array of points definition		(I) */
IGRdouble	*Vz;		/* Normal vector			(I) */
IGRint		*NextCrv;	/* Next curve index 			(O) */
IGRint		*NextPt;	/* Next point index 			(O) */
IGRboolean	*RevCrv;	/* 1 => Curve reversed			(O) */
IGRboolean	*Found;		/* 1 => found, 0 => not found		(O) */
struct SMLoop   *CurLoop;  	/* Current Loop				(I) */
{
 IGRint		i, NbPosCrv;
 IGRint		PosCrv[MAX_CRV_PT], PosPt[MAX_CRV_PT], PosRev[MAX_CRV_PT];
 IGRint		NtPt, OutCrv, NtRv;
 IGRboolean	Val;

 *Found = 0;

 /* To get the next curves */
 NbPosCrv = 0;
 NtPt = -1;
 NtRv = FALSE;

 for(i=0;i<Pt[IntPt].NbCrv;i++)
  {
   /* Dont come back by the current curve */
   if(Pt[IntPt].Crv[i] == CurCrv) continue;

   /* Get the possible next pt */
   if(Crv[Pt[IntPt].Crv[i]].P0 == IntPt) 
    {
     NtPt = Crv[Pt[IntPt].Crv[i]].P1;
     NtRv = FALSE;
    }
   else if(Crv[Pt[IntPt].Crv[i]].P1 == IntPt)
    {
     NtPt = Crv[Pt[IntPt].Crv[i]].P0;
     NtRv = TRUE;
    }
   else
    {
     printf("Bad graph topology found in SMGetNxtCrv\n");
    }

   if(NtPt == -1) continue;  /* Go to a dead end */

   /* Test if the curve has not been used in a loop (rigth/left) */
   if(Crv[Pt[IntPt].Crv[i]].RLDef & RL) continue;
   
   /* Test if possible loop */
   if(NtPt == CurLoop->Pt[0]) 
    {
     *Found   = TRUE;
     *NextCrv = Pt[IntPt].Crv[i];
     *NextPt  = NtPt;
     *RevCrv  = NtRv;
    }

   /* Test if it does already belong to the loop */
   SMValCrv(CurLoop, Pt[IntPt].Crv[i], NtPt, &Val);
   if(Val == FALSE) continue;

   PosCrv[NbPosCrv]  = Pt[IntPt].Crv[i];
   PosRev[NbPosCrv]  = NtRv;
   PosPt[NbPosCrv++] = NtPt;
  }

 if(NbPosCrv == 0)
  {
   /* No more ... */
   *Found = FALSE;
  }
 else if(NbPosCrv == 1)
  {
   /* Don't worry it is this one */
   *Found = TRUE;
   *NextCrv = PosCrv[0];
   *NextPt  = PosPt[0];
  }
 else 
  {
   /* Get the good one */
   OutCrv = -1;
   SMGetGoodCrv(IntPt, CurCrv, NbPosCrv, PosCrv, RL, NbCrv, Crv, NbPt, Pt, Vz, &OutCrv);
   if(OutCrv >= 0)
    {
     *NextCrv = OutCrv;
     *NextPt  = -1;
     for(i=0;i<NbPosCrv;i++)
      {
       if(PosCrv[i] != OutCrv) continue;
       *NextPt = PosPt[i];
       *RevCrv = PosRev[i];
       break;
      }
     if(*NextPt == -1) { printf("Plante les choux\n"); return 0;}
     *Found = TRUE;
    }
  }
 return 1;
} 


SMValCrv(CurLoop, Crv, Pt, Val)
struct SMLoop   *CurLoop;  	/* Current Loop				(I) */
IGRint		Crv;		/* Possible curve index			(I) */
IGRint		Pt;		/* Possible point index			(I) */
IGRboolean	*Val;		/* True if valid			(O) */
{
 IGRint	i;
 /* Does not test the beginning (stop condition) */
 *Val = FALSE;

 for(i=1; i<CurLoop->NbCrv; i++)
  {
   if(CurLoop->Crv[i] == Crv) return 1;
   if(CurLoop->Pt[i]  == Pt)  return 1;
  }
 *Val = TRUE;
 return 1;
}

/* 
 * SMGetGoodCrv.
 *
 * The nice part:
 *
 * Which the dot and scalar product I can know in which half side are
 * the possible curves. With this info and the dot product length I can
 * select the one I want. The tangency vector at intersection point are used.
 *
 *   curve: .....
 *         
 *        	|
 *      A  	|     B
 *        	|
 *        	|
 *  .............++++++++++++
 *        	|
 *      D      	|     C
 *        	|
 *        	|
 *        	|
 *
 *    If right area (Relative to vz and curve orienation) then the order is:
 *
 *         	- Bigger in D,
 *
 *		- Smaller in C,
 *
 *         	- Bigger in B,
 *
 *		- Smaller in A,
 *
 * */


SMGetGoodCrv(IntPt, CurCrv, NbPosCrv, PosCrv, RL, NbCrv, Crv, NbPt, Pt, Vz, OutCrv)
IGRint		IntPt;		/* Index of current intersection pt	(I) */
IGRint		CurCrv;	        /* Index of current curve		(I) */
IGRint		NbPosCrv;	/* Index of possible curve solutions	(I) */
IGRint		PosCrv[];	/* Array of Index of possuble curve	(I) */
IGRshort	RL;		/* 1 => right loop, 2 => left loop	(I) */
IGRint		NbCrv;		/* Number of curves			(I) */
struct SMGrCrv  *Crv;		/* Array of curves definition		(I) */
IGRint		NbPt;		/* Number of points			(I) */
struct SMGrPt	*Pt;		/* Array of points definition		(I) */
IGRdouble	*Vz;		/* Normal vector			(I) */
IGRint		*OutCrv;	/* Good curve index (-1 if no)		(O) */
{
 IGRint		i, k;
 BSrc		rc;
 IGRdouble	Vcross[3], Vz2[3];
 IGRdouble 	Tg[3], Tg2[3], aa, fabs();
 IGRdouble	DotP[MAX_CRV_PT], ScalSign[MAX_CRV_PT], BSdotp();
 IGRint		GrA[MAX_CRV_PT], GrB[MAX_CRV_PT];
 IGRint		NbA, NbB;

 *OutCrv = -1;

 if     (Crv[CurCrv].P0 == IntPt) for(i=0;i<3;i++) Tg[i] = Crv[CurCrv].TgP0[i];
 else if(Crv[CurCrv].P1 == IntPt) for(i=0;i<3;i++) Tg[i] = Crv[CurCrv].TgP1[i];
 else  { printf("Error end point (C)\n"); return 0; }

 if(RL & RIGHT) { for(k=0;k<3;k++) Vz2[k] = -Vz[k]; }
 else           { for(k=0;k<3;k++) Vz2[k] =  Vz[k]; }

 i = 0;
 for(i=0;i<NbPosCrv;i++)
  {
   if     (Crv[PosCrv[i]].P0 == IntPt) for(k=0;k<3;k++) Tg2[k] = Crv[PosCrv[i]].TgP0[k];
   else if(Crv[PosCrv[i]].P1 == IntPt) for(k=0;k<3;k++) Tg2[k] = Crv[PosCrv[i]].TgP1[k];
   else { printf("Error end point (D)\n"); return 0; }

   for(k=0;k<3;k++) Tg2[k] = -Tg2[k];  /* Reverse for continuity */
   DotP[i] = BSdotp(&rc, Tg, Tg2);
   if(rc != BSSUCC) { printf("Error in BSdopt (1)\n"); return 0; }

   if(fabs(DotP[i]) > 0.9999999) 
    {
     ScalSign[i] = 0;
    }
   else
    {
     BScrossp(&rc, Tg, Tg2, Vcross);
     if(rc != BSSUCC) { printf("Error in BScrossp\n"); return 0; }

     ScalSign[i] = BSdotp(&rc, Vcross, Vz2);
     if(rc != BSSUCC) { printf("Error in BSdopt (2)\n"); return 0; }
    }
  }
 
 /* construct the 2 groups */
 NbA = 0;
 NbB = 0;
 
 for(i=0;i<NbPosCrv;i++)
  {
   if(ScalSign[i] >= 0) GrA[NbA++] = i;
   if(ScalSign[i] <  0) GrB[NbB++] = i;
  }

 /* Selection :
  *	- A min,
  *	- B max,
  */

 aa = 2.;
 for(i=0;i<NbA;i++)
  {
   if(DotP[GrA[i]] > aa) continue;
   aa = DotP[GrA[i]];
   *OutCrv = PosCrv[GrA[i]];
  }

 if(NbA >= 1) return 1;

 aa = -2.;
 for(i=0;i<NbB;i++)
  {
   if(DotP[GrB[i]] < aa) continue;
   aa = DotP[GrB[i]];
   *OutCrv = PosCrv[GrB[i]];
  }
 return 1;

}

