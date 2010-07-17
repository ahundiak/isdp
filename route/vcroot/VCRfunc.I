
/* $Id: VCRfunc.I,v 1.3 2002/04/10 14:56:36 louis Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCRfunc.I
 *
 * Description:
 *   Service functions for VC package
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCRfunc.I,v $
 *        Revision 1.3  2002/04/10 14:56:36  louis
 *        TR5649-standardize tolerances
 *
 *        Revision 1.2  2001/02/20 01:11:09  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1999/01/28  04:56:00  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:09:22  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by r250_int for route
#
# Revision 1.21  1997/11/17  23:47:08  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by kddinov for cabling
#
# Revision 1.20  1997/08/13  14:05:08  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.19  1997/08/11  21:40:18  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.17  1997/07/22  14:31:02  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.16  1997/05/22  14:59:58  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.15  1997/05/19  13:05:44  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.14  1997/05/06  13:26:36  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.13  1997/05/02  17:06:14  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.12  1997/04/28  21:47:46  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.11  1997/03/28  20:46:36  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.10  1997/03/07  13:48:40  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.9  1997/03/06  22:33:58  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.8  1997/01/23  23:31:00  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.7  1996/12/16  16:48:42  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.6  1996/10/25  13:47:58  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.5  1996/10/03  18:09:24  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.4  1996/09/30  15:19:18  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/26  20:59:18  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:30:30  pinnacle
# Replaced: vcroot/VCRfunc.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:12:22  pinnacle
# Created: vcroot/VCRfunc.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *        01/27/99        Reddy      TR179800054 - Cable length calculations
 *				     are corrected for PID mode . Code will
 *                                   reviewed later for length cal. in 3D mode
 *        04/05/02        law        TR5649-standardize tolerance with VRGetTol
 *************************************************************************/

class implementation VCRoot;

#include    "PDUerror.h"
#include    "v_risproto.h"

#include    "VDSsymb_def.h"
#include    "VDSsymb_mac.h"
#include    "VDDbDef.h"

#include    "vdbmacros.h"
#include    "vrdbgmacros.h"

#include    "VCproto.h"
#include    "VCMacLib.h"
#include    "VRMath.h"
#include    "expression.h"

#include    "bsdotp.h"
#include    "bsroto.h"
#include    "bscrossp.h"
#include    "bslenvec.h"
#include    "bsnorvec.h"
#include    "bsmkvec.h"
#include    "bsmult_mats.h"
#include    "bsdistptpt.h"

#include    "maidmx.h"
#include    "mainvmx.h"
#include    "mamulmx.h"
#include    "matypemx.h"

#define     VC_EPS     0.00001

/*
#define MY_DEBUG
*/



/*     compute an angle from a vector    */

extern
IGRdouble VC_compute_angle (IGRdouble    *vx,
                            IGRdouble    *vy,
                            IGRdouble    *vz)
{
  IGRlong         retmsg;
  IGRdouble       cosinus,sinus,angle,kz;
  IGRdouble       normal[3];
  BSrc            rc;

  cosinus = BSdotp ( &rc, vx, vy );

  BScrossp ( &rc, vx, vy, normal);

  sinus = BSlenvec ( &retmsg, normal );

  angle = atan2(sinus,cosinus);

  if ( vz )
  {
    /* angle or PI - angle depending upon vz value */

    kz = BSdotp ( &rc, normal, vz );

    /* -- if kz < 0 => take the complementary angle -- */
    if (kz < 0) angle = 2*M_PI - angle;
  }

  return (angle);
}


/*    compute the length of a linestring, with corrections for bends   */

extern
IGRdouble VC_compute_strlen (IGRlong       *msg,
                      struct IGRpolyline   *LineIn,
                             IGRshort       jBeg,
                             IGRshort       jEnd,
                             IGRdouble     *dBtab)
{
  IGRshort      i;
  BSrc          rc;
  IGRdouble     totlen;
SetProc(VC_compute_strlen ); Begin 
  *msg   = MSFAIL;
  totlen = 0.0;

#ifdef MY_DEBUG
  printf (" strlen %d %d\n",jBeg, jEnd);
#endif

  if ((LineIn == NULL) ||
      (jBeg > (jEnd-1)))       return (totlen);

  *msg   = MSSUCC;

  /*   calculate uncorrected string length    */
  for (i=jBeg; i< jEnd; i++)
  {
     totlen += BSdistptpt(&rc, &(LineIn->points[3*i]),
                               &(LineIn->points[3*i+3]));
#ifdef MY_DEBUG
     printf (" totlen %d %f\n",i, totlen);
#endif
  }

  if (dBtab != NULL)
  {
    IGRdouble     va[3];          /* va = vertex[i+3] - vertex[i]     */
    IGRdouble     vb[3];          /* vb = vertex[i+6] - vertex[i+3]   */
    IGRdouble     vn[3];          /* vn = va /\ vb                    */
    IGRdouble     teta;           /* angle between (va,vb)            */
    IGRdouble     tan_teta;       /* tangente of teta                 */

    /*   loop through embedded vertices         */
    for (i = jBeg; i < (jEnd-2); i++)
    {
      BSmkvec  (&rc, va,  &(LineIn->points[3*i+3]),  &(LineIn->points[3*i]));
      BSnorvec (&rc, va);
      /* vector of second line */
      BSmkvec  (&rc, vb,  &(LineIn->points[3*i+3]),  &(LineIn->points[3*i+6]));
      BSnorvec (&rc, vb);

      BScrossp (&rc, va, vb, vn);
      BSnorvec (&rc, vn);

      teta = VC_compute_angle (va, vb, vn);

      __DBGpr_dbl( " Computed angle is ",teta);

      /* The following code is commented in order to get the length calculations 
      correctly. So here the bend effects  are  not considered in calculating
      the total length of the cable . Hence the length calculated here is 
      applicable for 2D / PID mode only  TR179800054 */

      #ifdef THREED_MODE

      if( !(VC_EQUAL(teta,0.0)))
      {
        IGRdouble    dADD, dSUB;

        /*    add curved bend    */
        teta = M_PI - fabs( teta);
        dADD = dBtab[i] * teta;
        totlen = totlen + dADD;

        printf (" --ADD teta, dADD %f %f\n",teta, dADD);

        /*    subtract straight sections   */
        teta = teta / 2.0;
        tan_teta = fabs( tan( teta));
        dSUB = 2.0 * dBtab[i] * tan_teta;

        totlen = totlen - dSUB;

        printf (" --SUB teta, tan_teta, dSUB %f %f %f\n",
                         teta, tan_teta, dSUB);

        /*" len: %f;teta: %f;tan: %f\n", *tot_length,teta,tan_teta */
      }

      #endif

    }
  }

#ifdef MY_DEBUG
  printf (" return len  %f\n", totlen);
#endif
End
  return (totlen);
}


/*    convert world coordinates to offset          */

extern
IGRint  VC_to_offset (IGRdouble   *RefMat,
                      IGRint       Type,
                      IGRshort     nVal,
                      IGRdouble   *dOffIn,
                      IGRdouble   *dOffOut)

{
  IGRint         i;
  IGRlong        retmsg;

#ifdef MY_DEBUG
  printf (" OFFSET VAL %d\n",nVal);
#endif

  i = Type;     /*   compiler warning    */

  if (nVal <= 0) return (OM_S_SUCCESS);

  if (nVal <= 3)
  {  /*   only offset specified     */
    IGRdouble   dMat1[16],dMat2[16];
    IGRdouble   dResMat[16];

#ifdef MY_DEBUG
    printf ("calc offset in %f %f %f\n",dOffIn[0],dOffIn[1],dOffIn[2]);
    for (i=0;i<4;i++)
    printf ("refmat -in- %f %f %f %f\n",RefMat[i*4], RefMat[i*4+1],
                                        RefMat[i*4+2],RefMat[i*4+3]);
#endif
    for (i=0; i<16; i++)
      dMat1[i] = RefMat[i];

    /*A   set up displacement in matrix   */
    /*A   Correct first for a non_aligned parent CS     */

    MAidmx (&retmsg, dMat2);
    dMat2[3]  =  dOffIn[0] - dMat1[3];
    dMat2[7]  =  dOffIn[1] - dMat1[7];
    dMat2[11] =  dOffIn[2] - dMat1[11];

#ifdef MY_DEBUG
    for (i=0;i<4;i++)
    printf ("dmat2  -st- %f %f %f %f\n",dMat2[i*4], dMat2[i*4+1],
                                        dMat2[i*4+2],dMat2[i*4+3]);
#endif
    dMat1[3]  = dMat1[7]  = dMat1[11] = 0.0;

    /*A  And compute the local coordinates     */
    VC_mat_invert (dMat1, dMat1);

#ifdef MY_DEBUG
    for (i=0;i<4;i++)
    printf ("dmat1  -iv- %f %f %f %f\n",dMat1[i*4], dMat1[i*4+1],
                                        dMat1[i*4+2],dMat1[i*4+3]);
#endif
    VC_mat_multiply (dMat1, dMat2, dResMat);

#ifdef MY_DEBUG
    for (i=0;i<4;i++)
    printf ("resmat calc %f %f %f %f\n",dResMat[i*4], dResMat[i*4+1],
                                        dResMat[i*4+2],dResMat[i*4+3]);
#endif
    dOffOut[0] = dResMat[3];
    dOffOut[1] = dResMat[7];
    dOffOut[2] = dResMat[11];
#ifdef MY_DEBUG
    printf ("calc offset out %f %f %f\n",dOffOut[0],dOffOut[1],dOffOut[2]);
#endif
  }
  else
  if (nVal == 16)
  {
    for (i=0; i<16; i++)
     dOffOut[i] = dOffIn[i];
  }
  else
  {

    IGRdouble      dLCx[3];
    IGRdouble      dLCy[3];
    IGRdouble      dLCz[3];
    IGRdouble      dLocIn[16];
    IGRdouble      dZDot;
    IGRdouble      dXDot;
    IGRdouble      dA1loc, dA2loc;
    IGRdouble      dMat2[16];
    IGRdouble      dResMat[16];

  for (i=0; i<16; i++)
    dLocIn[i] = RefMat[i];

  dA1loc = dOffIn[3];
  dA2loc = dOffIn[4];

  for (i = 0; i < 3 ; i++)
  {
    dLCx[i] = dLocIn[i*4];
    dLCy[i] = dLocIn[i*4+1];
    dLCz[i] = dLocIn[i*4+2];
  }

  /*A   set up displacement in matrix   */
  /*A   Correct first for a non_aligned parent CS     */

  MAidmx (&retmsg, dMat2);
  dMat2[3]  =  dOffIn[0] - dLocIn[3];
  dMat2[7]  =  dOffIn[1] - dLocIn[7];
  dMat2[11] =  dOffIn[2] - dLocIn[11];

  dLocIn[3]  = dLocIn[7]  = dLocIn[11] = 0.0;

  dXDot = BSdotp ( &retmsg,&dMat2[0], dLCx);
  dZDot = BSdotp ( &retmsg,&dMat2[8], dLCz);

  dA1loc -= VC_compute_angle (&dMat2[0], dLCx, dLCz);

  while (dA1loc > (2.0 * M_PI)) dA1loc -= (2.0 * M_PI);
  while (dA1loc <   -0.0001)    dA1loc += (2.0 * M_PI);

  /*   If the Z angle is > abs(90deg) reverse both angles.... */
  if (dZDot < 0.0)
  {
    dA1loc = (2.0 * M_PI) -  dA1loc;
  }

  /*A  And compute the local coordinates     */
  VC_mat_invert (dLocIn, dLocIn);

  VC_mat_multiply (dLocIn, dMat2, dResMat);

  /*   set output values   */

  dOffOut[0] = dResMat[3];
  dOffOut[1] = dResMat[7];
  dOffOut[2] = dResMat[11];
  dOffOut[3] = dA1loc;
  }

  return (OM_S_SUCCESS);
}


/*     convert offset to world coordinates    */


extern
IGRint  VC_to_world  (IGRdouble   *InMat,
                      IGRint       Type,
                      IGRshort     nVal,
                      IGRdouble   *dOffIn,
                      IGRdouble   *OutMat)
{
  IGRint        i;
  IGRdouble     dX[3],dY[3],dZ[3],dO[3];
  IGRdouble     dDispMat[16],dResMat[16];
  IGRdouble     dLocMat[16];
  IGRboolean    bBooleanVar;
  BSrc          rc;
  IGRlong       retmsg;
  IGRdouble    *pIN;
  IGRdouble     dLocIn[16];

  bBooleanVar = TRUE;

  if (InMat == NULL)
  {
    MAidmx (&retmsg, dLocIn);
    pIN = dLocIn;
  }
  else
    pIN = InMat;

  if ((nVal <= 0) || (dOffIn == NULL))
  {  /* if no offsets move directly through   */
    for (i=0; i<16; i++)
      OutMat[i] = pIN[i];
  }
  else
  if (Type & VC_TOFF_C_FULL)
  {  /*   full translation matrix supplied     */

    VC_mat_multiply (pIN, dOffIn, OutMat);

#ifdef MY_DEBUG
    printf (" FULL MATRIX OFFSET\n");
    VC_printmat ("IN ---",pIN);
    VC_printmat ("OFF --",dOffIn);
    VC_printmat ("RES --",OutMat);
#endif

  }
  else
  if ((Type & VC_TOFF_COORDS) || (Type & VC_TOFF_C_ANG))
  {
#ifdef MY_DEBUG
    printf ("set offset in %f %f %f\n",dOffIn[0],dOffIn[1],dOffIn[2]);
#endif

    for (i=0; i<16; i++)
      dLocMat[i] = OutMat[i] = InMat[i];

    /*   Set up for coordinate translation  */
    MAidmx (&retmsg, dDispMat);
    for ( i=0; i<3; i++ )
      dDispMat[i*4+3] =  dOffIn[i];

    /*A -- fill in temporary variables -- */
    for ( i=0; i<3; i++ )
    {
      dX[i]          = dLocMat[i*4];
      dY[i]          = dLocMat[i*4+1];
      dZ[i]          = dLocMat[i*4+2];
      dO[i]          = 0.0;
      dLocMat[i*4+3] = 0.0;
    }

    /*A  Adapt local coordinates  */
    VC_mat_multiply (dLocMat, dDispMat, dResMat);

    OutMat[3]  += dResMat[3];
    OutMat[7]  += dResMat[7];
    OutMat[11] += dResMat[11];

#ifdef MY_DEBUG
    VC_printmat ("ORIG", OutMat);
    {
      IGRdouble    dDD[16];

      VC_mat_multiply (InMat, dDispMat, dDD);

      VC_printmat ("NEW ",dDD);
    }
#endif

    /*    now if needed adapt the X and Y vectors for rotation   */
    if ((Type & VC_TOFF_C_ANG) && (nVal >= 4))
    {
      /*A  Rotate X around Z and recalculate Y       */
      BSroto (&rc, dO, dZ, &bBooleanVar, &dOffIn[3], dX, dX);

      BScrossp (&retmsg, dZ, dX, dY);

      /*A And normalize the vectors   */

      BSnorvec (&rc, dX);
      BSnorvec (&rc, dY);

      /*A Fill the transformation matrix   */
      for ( i=0; i<3; i++ )
      {
        OutMat[i*4]   = dX[i];
        OutMat[i*4+1] = dY[i];
      }
    }
  }

  return ( OM_S_SUCCESS );
}


/*     construct a matrix from a vector             */

extern
IGRint   VC_mat_from_vector  (IGRdouble       *dOrg,
                              IGRdouble       *dVC,
                              IGRdouble       *dMat)
{
  IGRlong         retmsg;
  BSrc            rc;
  IGRdouble       dTaxis[3], dDotp;
  IGRdouble       dX[3], dY[3], dZ[3];
  IGRint          i;

  MAidmx (&retmsg, dMat);

  for (i=0; i<3; i++)
   dX[i] = dVC[i] - dOrg[i];

  BSnorvec (&rc, dX);

  /*A find the vector perpendicular connection axis */

  /*C try with z axis first */
  dTaxis[0] = 0.;
  dTaxis[1] = 0.;
  dTaxis[2] = 1.;
  dDotp = BSdotp(&rc, dX, dTaxis);

  if ( fabs(dDotp) > 0.99995)
  { /*  Too close to parallel, try y axis instead   */
    dTaxis[0] = 0.;
    dTaxis[1] = 1.;
    dTaxis[2] = 0.;
    BScrossp( &rc, dX, dTaxis, dZ);
    BScrossp( &rc, dZ, dX, dY);
  }
  else
  {
    BScrossp( &rc, dTaxis, dX, dY);
    BScrossp( &rc, dX, dY, dZ);
  }

  BSnorvec (&rc, dX);
  BSnorvec (&rc, dY);
  BSnorvec (&rc, dZ);

  /*A Fill the matrix   */
  for ( i=0; i<3; i++ )
  {
     dMat[i*4]   = dX[i];
     dMat[i*4+1] = dY[i];
     dMat[i*4+2] = dZ[i];
     dMat[i*4+3] = dOrg[i];
  }

  return (OM_S_SUCCESS);
}

extern
IGRint   VC_mat_normalize (IGRdouble  *dMat)
{
  IGRint     i;
  IGRdouble  dVector[3];
  BSrc       rc;

  for (i=0; i<3; i++)
  {
    dVector[0] = dMat[i];
    dVector[1] = dMat[i+4];
    dVector[2] = dMat[i+8];
    BSnorvec (&rc, dVector);

    dMat[i]    = dVector[0];
    dMat[i+4]  = dVector[1];
    dMat[i+8]  = dVector[2];
  }

  return ( OM_S_SUCCESS );
}



/*    Check if an intermediate vertex needs to be removed   */
/* Some of the logical tests are questionable but this function has not been
   used, so no attempt has been made to correct the potential errors */

extern
IGRboolean   VCC_ptremove (IGRdouble       *dPt1,
                           IGRdouble       *dPt2,
                           IGRdouble       *dPt3,
                           IGRdouble        dMin)
{
  IGRboolean     bRet;
  IGRdouble      Vec1[3],Vec2[3];
  IGRdouble      dLen;
  BSrc           rc;
  IGRint         i;

  if (dMin < 0) dMin = BSBASISVAL;

  bRet = TRUE;

  BSmkvec (&rc, Vec1, dPt1, dPt2);
  BSnorvec (&rc, Vec1);
  BSmkvec (&rc, Vec2, dPt2, dPt3);
  dLen = BSlenvec (&rc, Vec2);
  BSnorvec (&rc, Vec2);

  for (i=0; i<3; i++)
    if (fabs (Vec1[i] - Vec2[i]) > 0.01) bRet = FALSE;

  /*   check mindist if not yet set to remove    */

  if (dLen <= dMin) bRet = TRUE;

  return (bRet);
}


/*   test for equal position structures   */

extern
IGRboolean   VC_posequal (struct VCpos    *pos1,
                          struct VCpos    *pos2)
{
  IGRboolean     bRet;

  bRet = FALSE;


  if (pos1->nType == pos2->nType )
  {
/*----  KDD 11-97 Here is the place to test for VC_UNKNOWN ---- */
    if ( pos1->nType == VC_UNKNOWN ) {
	   bRet = TRUE;
    }
    else if (pos1->nType == VC_CABLE_TYPE)
    {
      if ((pos1->Conn.Cable.nCpt == pos2->Conn.Cable.nCpt) &&
          (strcmp (pos1->Conn.Cable.szLeadId, pos2->Conn.Cable.szLeadId) == 0))
          bRet = TRUE;
    }
    else
    {
      if ((strcmp (pos1->Conn.Term.szModId, pos2->Conn.Term.szModId) == 0) &&
          (strcmp (pos1->Conn.Term.szPosId, pos2->Conn.Term.szPosId) == 0))
          bRet = TRUE;
    }
  }
/* KDD 11-97 
* else if ((pos1->nType == VC_UNKNOWN) || (pos2->nType == VC_UNKNOWN))
*          bRet = TRUE;
*/

  return (bRet);
}

extern
IGRint   VC_posmove  (struct VCpos    *pos1,
                      struct VCpos    *pos2)
{

  pos1->nType = pos2->nType;

  if (pos2->nType == VC_CABLE_TYPE)
  {
    pos1->Conn.Cable.nCpt = pos2->Conn.Cable.nCpt;

    strcpy (pos1->Conn.Cable.szLeadId, pos2->Conn.Cable.szLeadId);
  }
  else
  {
/*
    pos1->Conn.Term.ioType = pos2->Conn.Term.ioType;
    pos1->Conn.Term.nPAR   = pos2->Conn.Term.nPAR;
*/

    strcpy (pos1->Conn.Term.szModId, pos2->Conn.Term.szModId);
    strcpy (pos1->Conn.Term.szPosId, pos2->Conn.Term.szPosId);
  }

  return (0);
}



/*    Reverse a linestring     */

extern
void   VC_revcoord (IGRint  NumCrd, IGRdouble   *pCoord)

{
  IGRint      i, j, iend, ifrom;
  IGRdouble   dTemp;

  if (NumCrd <= 0)
  {
    printf (" reverse empty array... %d\n",NumCrd);
    return;
  }

  iend = NumCrd / 2;

  for (i=0; i< iend; i++)
  {
    ifrom = NumCrd -i -1;

    for (j=0; j<2; j++)
    {
      dTemp             = pCoord[i*3+j];
      pCoord[i*3+j]     = pCoord[ifrom*3+j];
      pCoord[ifrom*3+j] = dTemp;
    }
  }

  return;
}


/*    check if two nodes are equal    */

extern
IGRboolean  VC_node_equal (struct VC_contrace    *TR1,
                           struct VC_contrace    *TR2)
{
  IGRboolean   bRet;

  bRet = FALSE;

  if ((TR1 != NULL) && (TR2 != NULL))
  {
    if ((TR1->GRid.objid == TR2->GRid.objid) &&
        (TR1->GRid.osnum == TR2->GRid.osnum))
    {
      bRet = VC_posequal (&TR1->OutId, &TR2->OutId);
    }
  }

  return (bRet);
}

extern
IGRboolean    VC_test_pidact ()
{
        IGRlong         retmsg;
        struct VDSsymb  Symb;
        struct GRid     DumbGrid;

        /* Get VDS representation */

        vd$symbology(   msg         = &retmsg,
                        operation   = RETRIEVE,
                        symb_id     = &DumbGrid,
                        symb        = &Symb  );

        return (Symb.representation == VC_PID_REP);
}

extern
IGRboolean    VC_test_2dact ()
{
        IGRlong         retmsg;
        struct VDSsymb  Symb;
        struct GRid     DumbGrid;

        /* Get VDS representation */

        vd$symbology(   msg         = &retmsg,
                        operation   = RETRIEVE,
                        symb_id     = &DumbGrid,
                        symb        = &Symb  );

        return ((Symb.representation == VC_PID_REP) ||
                (Symb.representation == AC_2D_REP));
}

extern
IGRboolean   VC_colinear(IGRdouble *p1, IGRdouble *p2, IGRdouble *p3)
{
  IGRdouble       Vec1[3],Vec2[3];
  BSrc            rc;
  IGRint          i;
  IGRboolean      bRet;

  bRet = TRUE;

  if ((BSdistptpt (&rc, p1, p2) < VRGetTol(VR_DIST_TOL)) ||
      (BSdistptpt (&rc, p2, p3) < VRGetTol(VR_DIST_TOL)))     return bRet;

  BSmkvec (&rc, Vec1, p1, p2);
  BSnorvec (&rc, Vec1);
  BSmkvec (&rc, Vec2, p2, p3);
  BSnorvec (&rc, Vec2);

  for (i=0; i<3; i++)
    if (fabs (fabs(Vec1[i]) - fabs (Vec2[i])) > VRGetTol(VR_DEFAULT_TOL))
        bRet = FALSE;

  return (bRet);
}

extern
IGRboolean   VC_samept (IGRdouble *p1, IGRdouble *p2)
{
  BSrc            rc;

  return (BSdistptpt (&rc, p1, p2) < VRGetTol(VR_DIST_TOL));
}

extern
IGRboolean   VCC_addcoord (IGRdouble       *buff,
                           IGRint          *ctr,
                           IGRdouble       *dPT)
{
  IGRboolean      retval;
  IGRint          ii, i;

  retval = TRUE;
  ii     = *ctr;

  if (*ctr > 0)
  {
    if (VC_samept (dPT, &buff[(ii-1)*3]))   retval = FALSE;
  }

  if (retval)
  {
    for (i=0; i<3; i++)
     buff[ii*3+i]    = dPT[i];

    (*ctr)++;
  }

  return (retval);
}


extern
IGRint       VC_pidmac (IGRlong        *msg,
                        IGRchar        *szCode,
                        IGRchar        *szMac)
{
  IGRint      status;
  IGRchar   **DbIO;
  IGRint      iRow;
  IGRchar     szWhere[30];

  *msg = MSFAIL;
  VC_INITSTR (szMac);

  if ((VDSverify_login() == PDM_S_SUCCESS) &&
      (VdsVerifyRisTable(VC_PID_SYM_TAB) == VDS_DBTABLE_FOUND))
  {
    strcpy (szWhere, VC_N_COMP_CODE_AN);
    strcat (szWhere, "=\'");
    strcat (szWhere, szCode);
    strcat (szWhere, "\'");

    status=
    vdb$RisSelect (select     = VC_N_MACRO_NAME_AN,
                   table_name = VC_PID_SYM_TAB,
                   where      = szWhere,
                   numselect  = 1,
                   p_numrows  = &iRow,
                   p_buffer   = &DbIO);

    if (status & OM_S_SUCCESS)
    {

      if (iRow >= 1)
      {
        *msg = MSSUCC;
        strcpy (szMac, DbIO[0]);
      }

      VdsRisFreeBuffer (DbIO, iRow);
    }
  }

  return (OM_S_SUCCESS);
}

extern
IGRint      VC_digit    (IGRdouble     *p1,
                         IGRdouble     *p2)

{
  IGRint    retval;
  IGRint    i;
  IGRdouble dTest;

  retval = 0;

  for (i=0; i<3; i++)
  {
    dTest = p1[i] - p2[i];

    if (fabs(dTest) > VRGetTol(VR_DEFAULT_TOL))
    {
      if (retval > 0) retval = retval + i + 2;
      else            retval = i+1;
    }
  }

  return (retval);
}

extern
IGRint     VC_printmat (IGRchar   *tx,
                        IGRdouble *d)
{
  printf (" %s -  %10f %10f %10f %10f\n", tx, d[0],d[1],d[2],d[3]);
  printf (" %s -  %10f %10f %10f %10f\n", tx, d[4],d[5],d[6],d[7]);
  printf (" %s -  %10f %10f %10f %10f\n", tx, d[8],d[9],d[10],d[11]);
  printf (" %s -  %10f %10f %10f %10f\n", tx, d[12],d[13],d[14],d[15]);

  return 0;
}

extern
IGRint   VC_mat_multiply (IGRdouble       *dMat1,
                          IGRdouble       *dMat2,
                          IGRdouble       *dMout)
{
  BSrc        rc;

  BSmult_mats( 4, 4, dMat1, FALSE,
               4, 4, dMat2, FALSE, dMout, &rc);

  VC_mat_normalize (dMout);

  return (OM_S_SUCCESS);
}

extern
IGRint   VC_mat_invert   (IGRdouble       *dMat1,
                          IGRdouble       *dMout)
{
  IGRshort    four;
  BSrc        rc;

  four = 4;

  MAinvmx (&rc, &four, dMat1, dMout);

  return (OM_S_SUCCESS);
}


end implementation VCRoot;

