
/* $Id: VCGmatrix.I,v 1.2 2001/01/11 21:53:33 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcguide/VCGmatrix.I
 *
 * Description:
 *
 *      Method to retrieve guides matrix
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCGmatrix.I,v $
 *      Revision 1.2  2001/01/11 21:53:33  anand
 *      SP merge
 *
# Revision 1.1  2000/04/13  21:18:40  pinnacle
# Created: route/vcguide/VCGmatrix.I by lawaddel for Service Pack
#
# Revision 1.2  2000/03/13  17:07:02  pinnacle
# Replaced: vcguide/VCGmatrix.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:20:16  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/03/06  23:07:00  pinnacle
# Replaced: vcguide/VCGmatrix.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:41:12  pinnacle
# Created: vcguide/VCGmatrix.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *      03/13/00    law         cr179900814-set backshells at 0 deg on ends of
 *                              cables. Disabled return of vector angles.
 *      04/13/00    law         tr179901302-customer wanted guide ends to move
 *                              so VCGetMatrix returns identity matrix.
 *
 *************************************************************************/

class implementation VCGuide;

#include "VDmem.h"
#include "VCproto.h"

#include "bsnorvec.h"
#include "bsmkvec.h"

from       GRlinear    import  GRgetpolyline;

method VCGetMatrix (    IGRlong     *msg;
                        IGRshort     nCptNum;
                        IGRdouble   *dRefMatrix;
                 struct GRmd_env    *md_env)
{
  IGRlong            retmsg;
  IGRint             status;
  IGRdouble          dCoord[3];
  IGRdouble          dCnVec[3];
  BSrc               rc;

  struct GRid         GraphicId;

  /*A return if module environment is not provided */
  if ( !md_env )  return  OM_E_INVARG;

  status =
  om$send ( msg = message VCGuide.VCGd_GetGRid (&retmsg , &GraphicId, md_env),
       targetid = my_id);
  as$status(action = RET_STATUS);

  if (me->nVCType & VCGD_STRING)
  {
    IGRint       Index;
    IGRint       i, Action;

    struct IGRpolyline  PolyLine;

    PolyLine.points = NULL;

    /*A Get size of geometry */
    Action = 0;
    status =
    om$send(msg = message GRlinear.GRgetpolyline
                             (&retmsg, &md_env->md_env.matrix_type,
                              md_env->md_env.matrix, &Action, &PolyLine),
       targetid = GraphicId.objid,
       targetos = GraphicId.osnum );
    as$status(action = RET_STATUS);


    Index = (nCptNum == 0) ? 0 : PolyLine.num_points-1;

    Action = 1;
    PolyLine.points = _MALLOC ((3 * PolyLine.num_points), IGRdouble);

    status =
    om$send(msg = message GRlinear.GRgetpolyline
                             (&retmsg, &md_env->md_env.matrix_type,
                              md_env->md_env.matrix, &Action, &PolyLine),
       targetid = GraphicId.objid,
       targetos = GraphicId.osnum );
    as$status(action = RET_STATUS);

    for (i=0; i<3; i++)
      dCoord[i] = PolyLine.points[Index*3+i];

    if (nCptNum == 0)
    {    /* return the start point */
      BSmkvec ( &rc,  dCnVec, &PolyLine.points[(Index+1)*3],
                              &PolyLine.points[Index*3]);
    }
    else
    {    /* return the end point  */
      BSmkvec ( &rc,  dCnVec, &PolyLine.points[(Index-1)*3],
                              &PolyLine.points[Index*3]);
    }
    if ( rc != BSSUCC )  return OM_E_ABORT;

    _FREE (PolyLine.points);
  }
  else
  { /*   retrieve spline coords/tangents   */
    IGRdouble              dResult[9];
    IGRdouble              dPar;
    IGRdouble              dFac;
    IGRint                 i;

    struct IGRbsp_curve    *bspcurve;

    dPar = (IGRdouble) nCptNum;

#ifdef MY_DEBUG
    printf (" Get Cpt %f parameter curve \n",dPar);
#endif

    status =
    om$send(msg = message GRvg.GRgenabsg
                          (&retmsg, &md_env->md_env.matrix_type,
                            md_env->md_env.matrix, (IGRchar **)&bspcurve),
       targetid = GraphicId.objid,
       targetos = GraphicId.osnum );
    as$status(action = RET_STATUS);


#ifdef MY_DEBUG
    printf (" To BScvarrevt\n");
#endif

    dFac = 1.0;

    BScvarrevt (bspcurve, &dPar, 1, dFac, dResult, &rc);

#ifdef MY_DEBUG
    for (i=0; i<9 ; i++)
      printf (" From BScvarrevt, result %f\n",dResult[i]);
#endif

    for (i=0; i<3; i++)
    {
      dCoord[i] = dResult[i];
      dCnVec[i] = -dResult[i+3];
    }
  }

  BSnorvec (&rc, dCnVec);

  /*   construct matrix    */
/*** deleted for cr179900814 
  status =
  VC_mat_from_vector (dCoord, dCnVec, dRefMatrix);
***/
  /* added for cr179900814 */
  MAidmx (msg, dRefMatrix);
/* deleted for tr179901302 ****************************************
dRefMatrix[3] = dCoord[0];
dRefMatrix[7] = dCoord[1];
dRefMatrix[11] = dCoord[2];
*/
  return ( OM_S_SUCCESS );
}/* end VCGetMatrix */

end implementation VCGuide;

