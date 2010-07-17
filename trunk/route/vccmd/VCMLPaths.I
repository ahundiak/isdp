
/* $Id: VCMLPaths.I,v 1.1.1.1 2001/01/04 21:12:28 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCMLPaths.I
 *
 * Description:
 *      Implementation file for place cable command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCMLPaths.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.6  1997/05/07  14:19:06  pinnacle
# Replaced: vccmd/VCMLPaths.I for:  by hverstee for cabling
#
# Revision 1.5  1997/04/28  22:33:24  pinnacle
# Replaced: vccmd/VCMLPaths.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/03  18:11:00  pinnacle
# Replaced: vccmd/VCMLPaths.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/26  21:18:16  pinnacle
# Replaced: vccmd/VCMLPaths.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:36:30  pinnacle
# Replaced: vccmd/VCMLPaths.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:22:26  pinnacle
# Created: vccmd/VCMLPaths.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *
 *************************************************************************/

class implementation VCCmdPC;

#include "VCproto.h"

/*
#define MY_DEBUG
*/

method  VCMLAddPath (IGRint      nType;
                     IGRshort    lDig;
                     IGRdouble  *dCin;
                     IGRdouble  *dCot;
                     IGRshort    nCP;
                     IGRshort    nCPo;
                     IGRshort    ldDig;
              struct GRid       *Node)

{
  IGRint        status;
  IGRshort      nXdig;
  IGRint        i;
  IGRboolean    bBeg, bEnd;

  IGRdouble     dInt1[3];
  IGRdouble     dInt2[3];

  IGRdouble     dBeg[3];
  IGRdouble     dEnd[3];

  bBeg = bEnd = FALSE;

  if (!(me->bOrtho))
  { /*   not ortho, just go directly   */
#ifdef MY_DEBUG
    printf (" path- non ortho\n");
#endif

    status =
    om$send (msg = message VCCmdPC.VCMLAddNode
                      (nType, dCin, dCot, nCP, nCPo, Node),
        targetid = my_id);

    goto quit;
  }

  /*     setup    */

  for (i=0; i<3; i++)
  {
    dBeg[i]  = me->dLAST[i];
    dEnd[i]  = dCin[i];
  }

#ifdef MY_DEBUG
  printf ("Setuppath beg %f %f %f\n",dBeg[0],dBeg[1],dBeg[2]);
  printf ("Setuppath end %f %f %f\n",dEnd[0],dEnd[1],dEnd[2]);
  printf (" digit %d %d\n",lDig, ldDig);
#endif

  if ((lDig > 0) && (lDig < 4))
  { /*   extend or contract start segment   */
    dBeg[lDig-1] = dCin[lDig-1];
    bBeg = TRUE;
  }

#ifdef MY_DEBUG
  printf ("adjusted beg %f %f %f\n",dBeg[0],dBeg[1],dBeg[2]);
#endif

  if ((ldDig > 0) && (ldDig < 4))
  { /*   extend or contract end segment     */
    dEnd[ldDig-1] = dCin[ldDig-1];  
    bEnd = TRUE;
  }

#ifdef MY_DEBUG
  printf ("adjusted end %f %f %f\n",dEnd[0],dEnd[1],dEnd[2]);
#endif

  for (i=0; i<3; i++)
  {
    dInt1[i] = dBeg[i];
    dInt2[i] = dBeg[i];
  }
#ifdef MY_DEBUG
  printf ("adjusted ibg %f %f %f\n",dBeg[0],dBeg[1],dBeg[2]);
  printf ("adjusted ind %f %f %f\n",dEnd[0],dEnd[1],dEnd[2]);
#endif

  nXdig = VC_digit (dBeg, dEnd);

#ifdef MY_DEBUG
  printf ("adjusted beg %f %f %f\n",dBeg[0],dBeg[1],dBeg[2]);
  printf ("adjusted end %f %f %f\n",dEnd[0],dEnd[1],dEnd[2]);
  printf (" digit %d\n",nXdig);
#endif

  if (nXdig < 1)
  {
    printf (" no path\n");

    status =
    om$send (msg = message VCCmdPC.VCMLAddNode
                      (nType, dCin, dCot, nCP, nCPo, Node),
        targetid = my_id);
    goto quit;
  }

  if (nXdig < 4)    /*    only one move remaining, finish off   */
  {
    dInt1[nXdig-1] = dInt2[nXdig-1] = dEnd[nXdig-1];
  }
  else
  if (nXdig < 7)    /*   3d, 2 moves remaining make another corner  */
  {
    IGRdouble      d1, d2;
    IGRshort       i1, i2, iDD;

    if (nXdig == 6)     i1 = 1;
    else                i1 = 0;

    if (nXdig == 4)     i2 = 1;
    else                i2 = 2;

    d1 = fabs (dBeg[i1] - dEnd[i1]);
    d2 = fabs (dBeg[i2] - dEnd[i2]);

    if (d1 > d2) /*  swap sequence take largest last    */
    {
      iDD = i1;
      i1  = i2;
      i2  = iDD;
    }

    dInt1[i1] = dInt2[i1] = dEnd[i1];
    dInt2[i2] = dEnd[i2];
  }
  else
  {                 /*   3d, three free moves      TBD       */
    dInt1[0] = dInt2[0] = dEnd[0];
    dInt2[1] = dEnd[1];
  }

  if (bBeg)
  {
    status =
    om$send (msg = message VCCmdPC.VCMLAddStrP (dBeg),
        targetid = my_id);
  }

  status =
  om$send (msg = message VCCmdPC.VCMLAddStrP (dInt1),
      targetid = my_id);

  if (bEnd)
  {
    status =
    om$send (msg = message VCCmdPC.VCMLAddStrP (dInt2),
        targetid = my_id);
  }

  /*    add the destination node    */

  status =
  om$send (msg = message VCCmdPC.VCMLAddNode
                      (nType, dCin, dCot, nCP, nCPo, Node),
      targetid = my_id);

  quit:
  return (OM_S_SUCCESS);
}

end implementation VCCmdPC;

