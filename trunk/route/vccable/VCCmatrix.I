
/* $Id: VCCmatrix.I,v 1.2 2001/02/20 01:08:51 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCmatrix.I
 *
 * Description:
 *
 *      Method to retrieve guides matrix
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmatrix.I,v $
 *      Revision 1.2  2001/02/20 01:08:51  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/01  20:30:22  pinnacle
# Replaced: vccable/VCCmatrix.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/03/06  22:54:38  pinnacle
# Replaced: vccable/VCCmatrix.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:48:24  pinnacle
# Created: vccable/VCCmatrix.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
*/

#include "VDmem.h"
#include "VCproto.h"

#include "bsnorvec.h"
#include "bsmkvec.h"
#include "vrdbgmacros.h"

from   GRlinear   import   GRgetpolyline;

method VCGetMatrix (    IGRlong     *msg;
                        IGRshort     nCptNum;
                        IGRdouble   *dRefMatrix;
                 struct GRmd_env    *md_env)
{
  IGRint      status;
  IGRlong     retmsg;
  IGRint      i, Action;
  IGRshort    NbCpts;
  IGRint      jcomp, jndex;
  IGRint      Index;
  IGRdouble   dCptCoor[3];
  IGRdouble   d3Vec[3];
  BSrc        rc;

  struct IGRpolyline  PolyLine;

SetProc(VCCable_VCGetMatrix ); Begin

  /*A initialization */
  *msg=MSSUCC;

  /*A return if module environment is not provided */
  if ( !md_env )  return  OM_E_INVARG;

  /*A get the number of connect points */
  status=
  om$send ( msg = message VCRoot.VCGetNumberOfCpts (&retmsg , &NbCpts),
       targetid = my_id);

  /*A validity check for the input Cpt Num */
  if ( nCptNum < 0 || nCptNum >= NbCpts )
  {
    *msg=MSFAIL;
    return ( OM_E_INVARG );
  }

  jndex = 0;
  jcomp = om$dimension_of (varray = me->Sect);
  for (i=0; i<jcomp; i++)
  {
    if (me->Sect[i].type == VCC_STRING)
      jndex = me->Sect[i].strno;

    if (nCptNum == 0) break;
  }

  /*A retrieve actual polyline geometry from graphic */
  /*A Get size of geometry */

  Action = 0;
  status =
  om$send(msg = message GRlinear.GRgetpolyline
                             (&retmsg, &md_env->md_env.matrix_type,
                              md_env->md_env.matrix, &Action, &PolyLine),
     p_chanselect = &AS_to_comp,
     from         = jndex,
     to           = jndex);
  as$status(action = RET_STATUS);

  /*A Get geometry */
  Action = 1;
  PolyLine.points = _MALLOC ((3 * PolyLine.num_points),IGRdouble);

  status =
  om$send(msg = message GRlinear.GRgetpolyline
                             (&retmsg, &md_env->md_env.matrix_type,
                              md_env->md_env.matrix, &Action, &PolyLine),
     p_chanselect = &AS_to_comp,
     from         = jndex,
     to           = jndex);
  as$status(action = RET_STATUS);

  Index = (nCptNum == 0) ? 0 : PolyLine.num_points-1;

  /*A return the cpt coordinates */
  for (i=0;i<3;i++)
    dCptCoor[i] =  PolyLine.points[Index*3+i];

#ifdef MY_DEBUG
  printf( " Cpt Coordinates = %f %f %f \n",
      dCptCoor[0],dCptCoor[1],dCptCoor[2] );
#endif

  if (nCptNum == 0)
  {    /* return the start point */
    BSmkvec ( &rc,  d3Vec, &PolyLine.points[(Index+1)*3],
                           &PolyLine.points[Index*3]); 
  }
  else
  {    /* return the end point  */
    BSmkvec ( &rc,  d3Vec, &PolyLine.points[(Index-1)*3],
                           &PolyLine.points[Index*3]);
  }
  if ( rc != BSSUCC )  return OM_E_ABORT;

  BSnorvec (&rc, d3Vec);

  _FREE (PolyLine.points);

#ifdef MY_DEBUG
    printf( " ConAxis Vector Unit = %f %f %f \n",
                                         d3Vec[0], d3Vec[1], d3Vec[2] );
#endif

  status =
  VC_mat_from_vector (dCptCoor, d3Vec, dRefMatrix);

End;
  return ( OM_S_SUCCESS );

}/* end VCGetMatrix   */

end implementation VCCable;

