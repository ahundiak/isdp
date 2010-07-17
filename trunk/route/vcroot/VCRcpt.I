
/* $Id: VCRcpt.I,v 1.1.1.1 2001/01/04 21:12:37 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCRcpt.I
 *
 * Description:
 *   This file contains the methods dealing with connectpoints
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCRcpt.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.3  1997/03/19  15:52:30  pinnacle
# Replaced: vcroot/VCRcpt.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/09  21:53:48  pinnacle
# Replaced: vcroot/VCRcpt.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:11:50  pinnacle
# Created: vcroot/VCRcpt.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCRoot;

#include "bsmkvec.h"
#include "bslenvec.h"

/*
#define MY_DEBUG
*/


method  VCGetNumberOfCpts (IGRlong     *msg ;
                           IGRshort    *NbCpts)
{ /*   default for cables/guides, override for terminals   */
  *msg = MSSUCC;

  *NbCpts = 2;

  return (OM_S_SUCCESS);
}

method  VCSelectCpt (IGRlong    *msg ;
                     IGRdouble  *dTentative;
                     IGRshort   *nCpNum;
                     IGRdouble  *dConPos;
                     IGRdouble  *dConVect;
                     IGRboolean *bFree;
              struct GRmd_env   *md_env)
{
  IGRint         status;
  IGRlong        retmsg;
  IGRdouble      dCon[3];
  IGRdouble      dVec[3];
  IGRdouble      dTst[3];
  IGRdouble      dDist, dCheck;
  IGRboolean     bLF;
  IGRshort       icp, nIcp;
  BSrc           rc;

  *msg   = MSFAIL;
  dCheck = MAXDOUBLE;

  status =
  om$send (msg = message VCRoot.VCGetNumberOfCpts (&retmsg, &nIcp),
      targetid = my_id);

  for (icp=0; icp<nIcp; icp++)
  {
#ifdef MY_DEBUG
    printf (" selectcpt get %d for test\n",icp);
#endif

    status =
    om$send (msg = message VCRoot.VCGetCptGeom
                   (&retmsg, icp, dCon, dVec, NULL, &bLF, md_env),
        targetid = my_id);

    BSmkvec ( &rc, dTst, dCon, dTentative);
    dDist =  BSlenvec ( &rc, dTst );

#ifdef MY_DEBUG
    printf (" selectcpt %d at dist %f\n",icp, dDist);
#endif

    if (dDist < dCheck)
    {
      IGRshort     i;

      *msg = MSSUCC;

      for (i=0; i<3; i++)
      {
        dConPos[i] = dCon[i];

        if (dConVect) dConVect[i] = dVec[i];
      }

      *bFree  = bLF;
      *nCpNum = icp;

      dCheck  = dDist;
    }
  }

  return (OM_S_SUCCESS);
}

method  VCGetCptCoord (IGRlong      *msg;
                       IGRshort      nCpNum;
                       IGRdouble    *dCptCoor;
                struct GRmd_env     *md_env)
{
  IGRint       status;
  IGRdouble    dMat[16];

  status =
  om$send (msg = message VCRoot.VCGetMatrix (msg, nCpNum, dMat, md_env),
      targetid = my_id);

  if (*msg & MSSUCC)
  {
    dCptCoor[0] = dMat[3];
    dCptCoor[1] = dMat[7];
    dCptCoor[2] = dMat[11];
  }

  return ( OM_S_SUCCESS );
}

method  VCGetCptVec   (IGRlong      *msg;
                       IGRshort      nCpNum;
                       IGRdouble    *dCptVec;
                       IGRboolean   *bFree;
                struct GRmd_env     *md_env)
{
  IGRint       status;
  IGRdouble    dMat[16];

  status =
  om$send (msg = message VCRoot.VCGetMatrix (msg, nCpNum, dMat, md_env),
      targetid = my_id);

  if (*msg & MSSUCC)
  {
    dCptVec[0] = dMat[0];
    dCptVec[1] = dMat[4];
    dCptVec[2] = dMat[6];
  }

  *bFree = FALSE;

  return ( OM_S_SUCCESS );
}


method  VCGetCptGeom (IGRlong      *msg;
                      IGRshort      nCpNum;
                      IGRdouble    *dCptCoor;
                      IGRdouble    *dCptVec;
                      IGRdouble    *dOrientation;
                      IGRboolean   *bFree;
               struct GRmd_env     *md_env)
{
  IGRint       status;
  IGRdouble    dMat[16];

  status =
  om$send (msg = message VCRoot.VCGetMatrix (msg, nCpNum, dMat, md_env),
      targetid = my_id);

  if (*msg & MSSUCC)
  {
    if (dCptCoor)
    {
      dCptCoor[0] = dMat[3];
      dCptCoor[1] = dMat[7];
      dCptCoor[2] = dMat[11];
    }

    if (dCptVec)
    {
      dCptVec[0] = dMat[0];
      dCptVec[1] = dMat[4];
      dCptVec[2] = dMat[6];
    }

    if (dOrientation)     /*   give z axis   */
    {
      dOrientation[0] = dMat[2];
      dOrientation[1] = dMat[6];
      dOrientation[2] = dMat[10];
    }
  }

  *bFree = FALSE;

  return ( OM_S_SUCCESS );
}


end implementation VCRoot;

