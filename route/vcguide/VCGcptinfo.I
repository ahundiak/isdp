
/* $Id: VCGcptinfo.I,v 1.2 2002/04/09 20:38:48 louis Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcguide / VCGcptinfo.I
 *
 * Description:
 *   Information methods for cable guide
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCGcptinfo.I,v $
 *        Revision 1.2  2002/04/09 20:38:48  louis
 *        TR5649-standardize tolerance
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:20:16  pinnacle
# Integ into Route 02040304
#
# Revision 1.3  1997/03/06  23:07:12  pinnacle
# Replaced: vcguide/VCGcptinfo.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/09  21:58:14  pinnacle
# Replaced: vcguide/VCGcptinfo.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:40:22  pinnacle
# Created: vcguide/VCGcptinfo.I by hverstee for cabling
#
 *
 * History:
 *        06/20/96        hv         Initial
 *        04/05/02        law        TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

class implementation VCGuide;

#include  "VDmem.h"

#include  "bsmkvec.h"
#include  "bsnorvec.h"
#include  "bscrossp.h"
#include  "bsdotp.h"
#include  "VRMath.h"

/*  remove this idiotic prototype and replace with something sensible
#include  "bscvarrevt.h"
*/

extern void BScvarrevt (struct IGRbsp_curve *bspcurve,
                               IGRdouble    *dPar,
                               IGRint        id,
                               IGRdouble     dFac,
                               IGRdouble    *dResult,
                               BSrc         *rc);

from   GRlinear    import    GRgetpolyline;

/*
#define MY_DEBUG
*/


method  VCGetCptCoord (IGRlong      *msg;
                       IGRshort      nCpNum;
                       IGRdouble    *dCptCoor;
                struct GRmd_env     *md_env)
{
  IGRint      status;
  IGRlong     retmsg;

  struct GRid         GraphicId;

  /*A initialization */
  *msg=MSSUCC;

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

    Index = (nCpNum == 0) ? 0 : PolyLine.num_points-1;

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
      dCptCoor[i] = PolyLine.points[Index*3+i];

    _FREE (PolyLine.points);
  }
  else
  { /*   retrieve spline coords/tangents   */
    IGRdouble              dResult[9];
    IGRdouble              dPar;
    IGRdouble              dFac;
    BSrc                   rc;
    IGRint                 i;

    struct IGRbsp_curve    *bspcurve;

    dPar = (IGRdouble) nCpNum;

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

    if (dCptCoor)
    {
      for (i=0; i<3; i++)
        dCptCoor[i] = dResult[i];
    }
  }

  return (OM_S_SUCCESS);
}



method VCGetCptGeom(IGRlong     *msg ;    /* I/O - return status */
                    IGRshort     nCptNum;  /* I - Cpt Num          */
                    IGRdouble   *dCptCoor;  /* O - X,Y,Z coordinates */
                    IGRdouble   *dConAxis;  /* O - Con Axis         */
                    IGRdouble   *dOrientation;  /* O - Orientation */
                    IGRboolean  *bFree;         /* O - free orient         */
             struct GRmd_env    *md_env)       /* I - Mod Env of the Cable*/
{
  IGRint      status;
  IGRlong     retmsg;

  struct GRid         GraphicId;

  /*A initialization */
  *msg=MSSUCC;

  /*A return if module environment is not provided */
  if ( !md_env )  return  OM_E_INVARG;

  /*A nothing to output */
  if ( !dCptCoor && !dConAxis && !dOrientation )
    return OM_S_SUCCESS;

  status =
  om$send ( msg = message VCGuide.VCGd_GetGRid (&retmsg , &GraphicId, md_env),
       targetid = my_id);
  as$status(action = RET_STATUS);

  if (me->nVCType & VCGD_STRING)
  {
    BSrc         rc;
    IGRint       Index;
    IGRdouble    dCoord[3];
    IGRdouble    dCnVec[3];
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

#ifdef MY_DEBUG
    printf (" Get Cpt %d string , %d vertices\n",Index, PolyLine.num_points);
#endif

    Action = 1;
    PolyLine.points = _MALLOC ((3 * PolyLine.num_points) ,IGRdouble );

    if (PolyLine.points == NULL) return (OM_E_NODYNMEM);

    status =
    om$send(msg = message GRlinear.GRgetpolyline
                             (&retmsg, &md_env->md_env.matrix_type,
                              md_env->md_env.matrix, &Action, &PolyLine),
       targetid = GraphicId.objid,
       targetos = GraphicId.osnum );
    as$status(action = RET_STATUS);

#ifdef MY_DEBUG
    printf (" from getpolyline\n");
#endif

    for (i=0; i<3; i++)
      dCoord[i] = PolyLine.points[Index*3+i];

    if (nCptNum == 0)
    {    /* return the start point */
      BSmkvec ( &rc,  dCnVec, &PolyLine.points[Index*3],
                              &PolyLine.points[(Index+1)*3]);
    }
    else
    {    /* return the end point  */
      BSmkvec ( &rc,  dCnVec, &PolyLine.points[Index*3],
                              &PolyLine.points[(Index-1)*3] );
    }
    if ( rc != BSSUCC )  return OM_E_ABORT;

    BSnorvec (&rc, dCnVec);

#ifdef MY_DEBUG
    printf (" made vector %f %f %f\n", dCnVec[0],dCnVec[1], dCnVec[2]);
#endif

    if (dCptCoor)
    {
      for (i=0; i<3; i++)
        dCptCoor[i] = dCoord[i];
    }

    if (dConAxis)
    {
      for (i=0; i<3; i++)
        dConAxis[i] = dCnVec[i];
    }

#ifdef MY_DEBUG
    printf (" to orient calc\n");
#endif

    if ( dOrientation )
    {
      IGRdouble  d3Zaxis[3], dDotp;

      /*A find the vector perpendicular connection axis */

      /*C try with z axis first */
      d3Zaxis[0] = 0.; d3Zaxis[1] = 0.; d3Zaxis[2] = 1.;

      dDotp = BSdotp(&rc, dCnVec, d3Zaxis);
      if ( fabs(dDotp) < VRGetTol(VR_DOTPROD_TOL) )
        goto  ret_orient;

      /*C try with y axis first */
      d3Zaxis[0] = 0.; d3Zaxis[1] = 1.; d3Zaxis[2] = 0.;

      dDotp = BSdotp(&rc, dCnVec, d3Zaxis);
      if ( fabs( dDotp ) < VRGetTol(VR_DOTPROD_TOL) )
        goto  ret_orient;

      /*C try with x axis first */
      d3Zaxis[0] = 1.; d3Zaxis[1] = 0.; d3Zaxis[2] = 0.;

      dDotp = BSdotp(&rc, dCnVec, d3Zaxis);
/*NYC*/
      if ( fabs( dDotp ) < VRGetTol(VR_DOTPROD_TOL) ) ;
      else  *msg = MSFAIL;

ret_orient:
      BScrossp (&rc, d3Zaxis, dCnVec, dOrientation);
      BSnorvec (&rc, dOrientation);

    } /* end return orientation */

    _FREE (PolyLine.points);
#ifdef MY_DEBUG
    printf (" done, free memory\n");
#endif
  }
  else
  { /*   retrieve spline coords/tangents   */
    IGRdouble              dResult[9];
    IGRdouble              dPar;
    IGRdouble              dFac;
    BSrc                   rc;
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

    if (dCptCoor)
    {
      for (i=0; i<3; i++)
        dCptCoor[i] = dResult[i];
    }

    if (dConAxis)
    {
      for (i=0; i<3; i++)
        dConAxis[i] = dResult[i+3];
    }

    if (dOrientation)
    {
/*
      for (i=0; i<3; i++)
        dOrientation[i] = dResult[i+6];
*/
      dOrientation[0] = dOrientation[1] = 0.0;
      dOrientation[2] = 1.0;
    }
  } /* end return con axis or orientation */

  return ( OM_S_SUCCESS );

}/* end VCGetCptGeom */

end implementation VCGuide;

